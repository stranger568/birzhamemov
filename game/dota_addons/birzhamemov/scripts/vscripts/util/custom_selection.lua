CustomPick = class({})

LinkLuaModifier( "modifier_birzha_start_movespeed", "modifiers/modifier_birzha_start_movespeed", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_start_game", "modifiers/modifier_birzha_start_game", LUA_MODIFIER_MOTION_NONE )

BIRZHA_PICK_STATE_PLAYERS_LOADED = "BIRZHA_PICK_STATE_PLAYERS_LOADED"
BIRZHA_PICK_STATE_BAN = "BIRZHA_PICK_STATE_BAN"
BIRZHA_PICK_STATE_SELECT = "BIRZHA_PICK_STATE_SELECT"
BIRZHA_PICK_STATE_PRE_END = "BIRZHA_PICK_STATE_PRE_END"
BIRZHA_PICK_STATE_END = "BIRZHA_PICK_STATE_END"

PICK_STATE_STATUS = {}
PICK_STATE_STATUS[1] = BIRZHA_PICK_STATE_PLAYERS_LOADED
PICK_STATE_STATUS[2] = BIRZHA_PICK_STATE_BAN
PICK_STATE_STATUS[3] = BIRZHA_PICK_STATE_SELECT
PICK_STATE_STATUS[4] = BIRZHA_PICK_STATE_PRE_END
PICK_STATE_STATUS[5] = BIRZHA_PICK_STATE_END

TIME_OF_STATE = {}
TIME_OF_STATE[1] = 15
TIME_OF_STATE[2] = 20
TIME_OF_STATE[3] = 60
TIME_OF_STATE[4] = 10

if IsInToolsMode() then
	TIME_OF_STATE[2] = 1
	TIME_OF_STATE[4] = 5
	TIME_OF_STATE[3] = 10222
end

PLAYERS = {}
HEROES = {}
BANNED_HEROES = {}
PICKED_HEROES = {}
IN_STATE = false
PICK_STATE = BIRZHA_PICK_STATE_PLAYERS_LOADED
DISCONNECTED = {}

function CustomPick:RegisterPlayerInfo( pid )
	local pinfo = PLAYERS[ pid ] or {
		bRegistred = false,
		bLoaded = false,
		ban_count = 1,
		steamid = PlayerResource:GetSteamAccountID( pid ),
		picked_hero = nil,
		token_used = false,
		pet=nil,
		effect=nil,
	}
	
	PLAYERS[ pid ] = pinfo
	return pinfo
end

function CustomPick:Init()
	IN_STATE = true
	CustomPick:RegisterHeroes()
	CustomGameEventManager:RegisterListener( 'birzha_pick_select_hero', Dynamic_Wrap( self, 'PlayerSelect'))
	CustomGameEventManager:RegisterListener( "birzha_token_set", Dynamic_Wrap(self, 'TokenSet'))
	CustomGameEventManager:RegisterListener( "change_pet", Dynamic_Wrap(self, 'ChangePet'))
	CustomGameEventManager:RegisterListener( "change_effect", Dynamic_Wrap(self, 'ChangeEffect'))
	CustomGameEventManager:RegisterListener( 'birzha_pick_player_registred', Dynamic_Wrap( self, 'PlayerRegistred' ) )
	CustomGameEventManager:RegisterListener( 'birzha_pick_player_loaded', Dynamic_Wrap( self, 'PlayerLoaded' ) )
	
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidTeamPlayerID(i) then
			CustomPick:RegisterPlayerInfo(i)
		end
	end
	
	Schedule( 1, function()
		CustomPick:ServerReady()
	end )
end

function CustomPick:ServerReady()
	BirzhaData.GetAllPlayersData()
	CustomPick:CheckReadyPlayers()
end

function CustomPick:CheckReadyPlayers( attempt )
	if PICK_STATE ~= BIRZHA_PICK_STATE_PLAYERS_LOADED then
		return
	end
	
	local bAllReady = true
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.bRegistred and not pinfo.bLoaded then
			bAllReady = false
		end
	end

	if server_activated == nil then 
		BirzhaData.GetAllPlayersData()
		bAllReady = false
	end
	
	if bAllReady then
		Timers:CreateTimer(2, function()
			CustomPick:Start()
		end)
	else
		local check_interval = 5
		attempt = ( attempt or 0 ) + check_interval
		if attempt > TIME_OF_STATE[1] then
			CustomPick:Start()
		else
			Schedule( check_interval, function()
				CustomPick:CheckReadyPlayers( attempt )
			end )
		end
	end
end

function CustomPick:PlayerRegistred( kv )
	local pinfo = CustomPick:RegisterPlayerInfo( kv.PlayerID )
	pinfo.bRegistred = true
end

function CustomPick:PlayerLoaded( kv )
	local pid = kv.PlayerID

	local player = PlayerResource:GetPlayer( pid )
	
	if not PLAYERS[ pid ] then
		CustomGameEventManager:Send_ServerToPlayer( player, 'pick_end', {} )
		return
	end
	
	PLAYERS[ pid ].bLoaded = true
	
	local team = PlayerResource:GetTeam( pid )
	
	if not IN_STATE then
		CustomGameEventManager:Send_ServerToPlayer( player, 'pick_end', {} )
		return
	end

	if PICK_STATE ~= BIRZHA_PICK_STATE_PLAYERS_LOADED then
		CustomPick:DrawHeroesForPlayer( pid )
		CustomPick:DrawPickScreenForPlayer( pid )
		CustomGameEventManager:Send_ServerToPlayer( player, 'pick_filter_reconnect', {banned = BANNED_HEROES, banned_length = #BANNED_HEROES, picked = PICKED_HEROES, picked_length = #PICKED_HEROES})
		if PLAYERS[ pid ].picked_hero ~= nil then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = PLAYERS[ pid ].picked_hero})
		end
		if PICK_STATE == BIRZHA_PICK_STATE_BAN then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_ban_start', {})
		elseif PICK_STATE == BIRZHA_PICK_STATE_SELECT then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_start_selection', {} )
		elseif PICK_STATE == BIRZHA_PICK_STATE_PRE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_preend_start', {} )
		elseif PICK_STATE == BIRZHA_PICK_STATE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_end', {} )
		end
	end
end

function CustomPick:Start()
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.bLoaded then
			CustomPick:DrawHeroesForPlayer()
			CustomPick:DrawPickScreenForPlayer( pid )
		end
	end
	CustomPick:StartBanningStage()
end

function CustomPick:DrawPickScreenForPlayer( pid )
	if not PlayerResource:IsValidPlayerID( pid ) then
		return
	end
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( pid ), 'pick_start', {} )
end

function CustomPick:DrawHeroesForPlayer()
	CustomGameEventManager:Send_ServerToAllClients( 'pick_load_heroes', HEROES)
end

function CustomPick:RegisterHeroes()
	local enable_heroes = {}
	local str_heroes = {}
	local ag_heroes = {}
	local int_heroes = {}
	local anime = {}
	local all = {}
	local heroes = LoadKeyValues("scripts/npc/activelist.txt")
	local h = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	local abilki = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

	for k,v in pairs(heroes) do
		if v == 1 then
			table.insert(enable_heroes, k)
		end
	end

	

	for c = 1, #enable_heroes do
		local inf = h[enable_heroes[c]]
		local ability = {}
		local heroid = {}
		if inf then
			for ab = 1, 9 do
				if inf["Ability" ..ab] ~= nil and inf["Ability"..ab] ~= "" and inf["Ability"..ab] ~= "generic_hidden" then
					if abilki[ inf["Ability" ..ab] ] then
						behavior = abilki[ inf["Ability" ..ab] ].AbilityBehavior
					end
					if behavior and not behavior:find('DOTA_ABILITY_BEHAVIOR_HIDDEN') then
						table.insert(ability, inf["Ability"..ab])
					end
				end
			end
			CustomNetTables:SetTableValue("birzha_pick", tostring(enable_heroes[c]), ability)
		end
	end

	HEROES = enable_heroes

	for _,hero in pairs(enable_heroes) do
		if h[hero].AttributePrimary == "DOTA_ATTRIBUTE_AGILITY" then
			table.insert(ag_heroes, hero)
		elseif h[hero].AttributePrimary == "DOTA_ATTRIBUTE_STRENGTH" then
			table.insert(str_heroes, hero)
		elseif h[hero].AttributePrimary == "DOTA_ATTRIBUTE_INTELLECT" then
			table.insert(int_heroes, hero)
		end
	end

	CustomNetTables:SetTableValue("birzha_pick", "hero_list", {str = str_heroes, ag = ag_heroes, int = int_heroes, str_length = #str_heroes, ag_length = #ag_heroes, int_length = #int_heroes})
end

function CustomPick:StartBanningStage()
	if server_activated == nil then
		GameRules:SetSafeToLeave(true)
	end
	PICK_STATE = BIRZHA_PICK_STATE_BAN
	CustomGameEventManager:Send_ServerToAllClients( 'pick_ban_start', {})
	CustomPick:StartTimers( TIME_OF_STATE[2], function()
		CustomPick:EndBanningStage()
	end )
	for pid, pinfo in pairs( PLAYERS ) do
		if IsDonatorID('premium', pinfo.steamid) or IsDonatorID('gob', pinfo.steamid) or IsDonatorID('vip', pinfo.steamid) or IsDonatorID('dragonball', pinfo.steamid) then
			pinfo.ban_count = pinfo.ban_count + 3
		else
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'more_ban_aviable', {})
		end
	end
end

function CustomPick:StartTimers( delay, fExpire )
	local n = 1
	local f = function()
		n = n - 1
		if n == 0 then
			fExpire()
		end
	end
	self:StartTimer( delay, f )
end

function CustomPick:StartTimer( delay, fExpire )
	local timer_number = ( self.StartTimerNumber or 0 ) + 1
	self.StartTimerNumber = timer_number
	self.Timers = delay
	local tick_interval = 1/30
	local delay_int
	
	Timer( function( dt )
		if self.StartTimerNumber ~= timer_number then
			return
		end
		
		delay = delay - dt
		self.Timers = delay
		
		if delay <= 0 then
			self.Timers = 0
			fExpire()
			return
		end
		
		local new_delay_int = math.floor( delay )
		if delay_int ~= new_delay_int then
			delay_int = new_delay_int
			CustomGameEventManager:Send_ServerToAllClients( 'pick_timer_upd', { timer = delay_int })
		end
		return tick_interval
	end )
end

function CustomPick:EndBanningStage()
	if PICK_STATE ~= BIRZHA_PICK_STATE_BAN then
		return
	end
	CustomNetTables:SetTableValue("birzha_pick", "banned_heroes", BANNED_HEROES)
	CustomPick:StartSelectionStage()
end


function CustomPick:PlayerSelect( kv )
	local pid = kv.PlayerID
	local pinfo = PLAYERS[ pid ]
	if PICK_STATE == BIRZHA_PICK_STATE_BAN then
		if kv.random then
			return
		end
		if not pinfo or pinfo.ban_count <= 0 then
			return
		end
		if BANNED_HEROES[kv.hero] == nil then
			BANNED_HEROES[kv.hero] = true
			pinfo.ban_count = pinfo.ban_count - 1
			table.insert(BANNED_HEROES, kv.hero)
			CustomGameEventManager:Send_ServerToAllClients( 'pick_ban_heroes', { hero = kv.hero})
		end
	elseif PICK_STATE == BIRZHA_PICK_STATE_SELECT then
		if kv.random then
			kv.hero = CustomPick:RandomHeroForPlayer()
		end
		if IsHeroNotAvailable(kv.hero) or pinfo.picked_hero then return end
		pinfo.picked_hero = kv.hero
		table.insert(PICKED_HEROES, kv.hero)
		if GetMapName() == "birzhamemov_zxc" or GetMapName() == "birzhamemov_samepick" then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = kv.hero})
			CustomPick:GiveHeroPlayer(pid, pinfo.picked_hero)
			CheckPlayerHeroes()
			return
		end
		CustomGameEventManager:Send_ServerToAllClients( 'pick_select_hero', { hero = kv.hero})
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = kv.hero})
		CustomPick:GiveHeroPlayer(pid, pinfo.picked_hero)
		CheckPlayerHeroes()
	end
end

function CheckPlayerHeroes()
	if PICK_STATE == BIRZHA_PICK_STATE_PRE_END or PICK_STATE == BIRZHA_PICK_STATE_END then return end
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.picked_hero == nil then
			return 
		end
	end
	CustomPick:EndSelectionStage()
end

function CustomPick:GiveHeroPlayer(id,hero)
	local wisp = PlayerResource:GetSelectedHeroEntity(id)
	PlayerResource:ReplaceHeroWith(id, hero, 700, 0)
	UTIL_Remove(wisp)
	local new_hero = PlayerResource:GetSelectedHeroEntity(id)
	if new_hero ~= nil then
		new_hero:AddNewModifier( new_hero, nil, "modifier_birzha_start_game", {})
		PlayerResource:SetCameraTarget(new_hero:GetPlayerOwnerID(), new_hero)
		if PICK_STATE == BIRZHA_PICK_STATE_END then
			PlayerResource:SetCameraTarget(new_hero:GetPlayerOwnerID(), nil)
		end
	end
end

function CustomPick:RandomHeroForPlayer()
	local random_hero = CustomPick:UnsafeRandomHero()
	if IsHeroNotAvailable(HEROES[random_hero]) or HEROES[random_hero] == nil then return self:RandomHeroForPlayer() end
	return HEROES[random_hero]
end



function CustomPick:UnsafeRandomHero()
	local curstate = 0
	local rndhero = RandomInt(1, #HEROES)

	for name, _ in pairs(HEROES) do
		if curstate == rndhero then
			if IsHeroNotAvailable(HEROES[name]) then
				return CustomPick:UnsafeRandomHero()
			end
			return name
		end
		curstate = curstate + 1
	end
end











function IsHeroNotAvailable(hero)
	for a = 1, #BANNED_HEROES do
		if hero == BANNED_HEROES[a] then
			return true
		end
	end
	if GetMapName() == "birzhamemov_zxc" or GetMapName() == "birzhamemov_samepick" then
		return false
	end
	for b = 1, #PICKED_HEROES do
		if hero == PICKED_HEROES[b] then
			return true
		end
	end
	return false
end

function IsHeroReconnectBanned(hero)
	for a = 1, #BANNED_HEROES do
		if hero == BANNED_HEROES[a] then
			return true
		end
	end
	return false
end

function IsHeroReconnectPicked(hero)
	for b = 1, #PICKED_HEROES do
		if hero == PICKED_HEROES[b] then
			return true
		end
	end
	return false
end

function CustomPick:StartSelectionStage()
	PICK_STATE = BIRZHA_PICK_STATE_SELECT
	CustomGameEventManager:Send_ServerToAllClients( 'pick_start_selection', {} )
	CustomPick:StartTimers( TIME_OF_STATE[3], function()
		CustomPick:EndSelectionStage()
	end )	
end

function CustomPick:EndSelectionStage()
	if PICK_STATE ~= BIRZHA_PICK_STATE_SELECT then
		return
	end
	CustomNetTables:SetTableValue("birzha_pick", "picked_heroes", PICKED_HEROES)
	CustomPick:StartPreEndSelection()
end

function CustomPick:StartPreEndSelection()
	Debug:Execute( function()
		PICK_STATE = BIRZHA_PICK_STATE_PRE_END
		CustomGameEventManager:Send_ServerToAllClients( 'pick_preend_start', {} )
		CustomPick:GiveHeroes()
		CustomPick:StartTimers( TIME_OF_STATE[4], function()
			CustomPick:EndSelection()
		end )	
	end)
end

function CustomPick:GiveHeroes()
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.picked_hero == nil then
			local hero = CustomPick:RandomHeroForPlayer()
			pinfo.picked_hero = hero
			table.insert(PICKED_HEROES, hero)
			CustomGameEventManager:Send_ServerToAllClients( 'pick_select_hero', { hero = hero})
			if IsPlayerDisconnected(pid) then
				DISCONNECTED[pid] = hero
			else
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = hero})
				CustomPick:GiveHeroPlayer(pid, hero)
			end
		end
	end
end

function CustomPick:EndSelection()
	Debug:Execute( function()
		IN_STATE = false
		PICK_STATE = BIRZHA_PICK_STATE_END
		pick_ended = true
		CustomNetTables:SetTableValue('game_state', 'pickstate', {v = 'ended'})
		CustomGameEventManager:Send_ServerToAllClients( 'pick_end', {} )
		GameRules:GetGameModeEntity():SetPauseEnabled( true )
		for pid, pinfo in pairs( PLAYERS ) do
			if pid ~= nil and pinfo ~= nil and pinfo.picked_hero ~= nil and PlayerResource:GetSelectedHeroEntity(pid) ~= nil then
				PlayerResource:SetCameraTarget(pid, nil)
				PlayerResource:GetSelectedHeroEntity(pid):AddNewModifier( PlayerResource:GetSelectedHeroEntity(pid), nil, "modifier_birzha_start_movespeed", {duration = 15})
				if pinfo.pet ~= nil then
					SpawnPetForHero(PlayerResource:GetSelectedHeroEntity(pid), pinfo.pet[1], pinfo.pet[2])
				end
				if pinfo.effect ~= nil then
					PlayerResource:GetSelectedHeroEntity(pid):AddDonate(pinfo.effect)
				end
			end
		end
		if IsInToolsMode() then return end
		Convars:SetFloat("host_timescale", 0.25)
		Timers:CreateTimer({
			useGameTime = false,
			endTime = 1.5,
			callback = function()
				Convars:SetFloat("host_timescale", 1)
				return nil
			end
		})
	end)
end

function CustomPick:TokenSet(kv) 
	local pinfo = PLAYERS[ kv.PlayerID ]
    local player_info = CustomNetTables:GetTableValue('birzhainfo', tostring(kv.PlayerID)) or {}
    if GetUnlockedTokens(player_info.bp_lvl or 0) - (player_info.token_used or 0) <= 0 then return end

    if pinfo and pinfo.token_used == false then        
   		pinfo.token_used = true
    	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(kv.PlayerID), 'birzha_token_change', {})
    end                    
end

function GetUnlockedTokens(lvl)
    local count = 0
    for i = 1, (lvl or 0) do
        if string.find(MEMESPASS_REWARD_TABLE[i] or '', 'token') then
        	count = count + 1
        end    
    end    
    return count
end

function CustomPick:ChangePet( kv )
	local pid = kv.PlayerID
	if PLAYERS[ pid ].steamid == 113370083 then
		PLAYERS[ pid ].pet = 
		{
			"models/insane/insane.vmdl",
			"courier_devourling_gold_ambient",
		}
		return
	end
	PLAYERS[ pid ].pet = 
	{
		tostring(kv.model),
		tostring(kv.effect),
	}
end

function CustomPick:ChangeEffect( kv )
	local pid = kv.PlayerID
	PLAYERS[ pid ].effect = tostring(kv.effect)
end





















