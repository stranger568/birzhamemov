CustomPick = class({})

LinkLuaModifier( "modifier_birzha_start_movespeed", "modifiers/modifier_birzha_start_movespeed", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_start_game", "modifiers/modifier_birzha_start_game", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_happy_tank", "modifiers/modifier_birzha_pet", LUA_MODIFIER_MOTION_NONE )

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
TIME_OF_STATE[1] = 7
TIME_OF_STATE[2] = 20
TIME_OF_STATE[3] = 60
TIME_OF_STATE[4] = 10

if IsInToolsMode() or GameRules:IsCheatMode() then
	TIME_OF_STATE[2] = 1
	TIME_OF_STATE[4] = 1 -- dd
end

_G.PLAYERS = {}
_G.HEROES = {}
_G.BANNED_HEROES = {}

if GetMapName() == "birzhamemov_solo" then
	table.insert(BANNED_HEROES, "npc_dota_hero_migi")
end

_G.PICKED_HEROES = {}
_G.IN_STATE = false
_G.PICK_STATE = BIRZHA_PICK_STATE_PLAYERS_LOADED
CustomPick.DISCONNECTED = {}

BIRZHA_PLUS_HEROES = 
{
	-- Всегда уникальные
	"npc_dota_hero_migi",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_overlord",
	"npc_dota_hero_silencer",
	"npc_dota_hero_pudge",
	--------------------------------------
	"npc_dota_hero_nevermore",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_serega_pirat",
	"npc_dota_hero_oracle",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_sven",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_thomas_bebra",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_centaur",
}

function CustomPick:RegisterPlayerInfo( pid )

    if not PlayerResource:IsValidPlayerID(pid) then return end
    if tostring( PlayerResource:GetSteamAccountID( pid ) ) == nil then return end
    if PlayerResource:GetSteamAccountID( pid ) == 0 then return end
    if PlayerResource:GetSteamAccountID( pid ) == "0" then return end
	
	local pinfo = PLAYERS[ pid ] or 
	{
		bRegistred = false,
		bLoaded = false,
		ban_count = 1,
		steamid = PlayerResource:GetSteamAccountID( pid ),
		partyid = tonumber(tostring(PlayerResource:GetPartyID(pid))),
		picked_hero = nil,
		token_used = false,
		pet = 0,
		border = 0,
		effect=0,
		selected_hero = nil,
	}
	
	PLAYERS[ pid ] = pinfo
	return pinfo
end

function CustomPick:Init()
	IN_STATE = true
	CustomPick:RegisterHeroes()
	CustomGameEventManager:RegisterListener( 'birzha_pick_select_hero', Dynamic_Wrap( self, 'PlayerSelect'))
	CustomGameEventManager:RegisterListener( 'birzha_pick_rerandom', Dynamic_Wrap( self, 'PlayerRerandom'))
	CustomGameEventManager:RegisterListener( "birzha_token_set", Dynamic_Wrap(self, 'TokenSet'))
	CustomGameEventManager:RegisterListener( "change_effect", Dynamic_Wrap(self, 'ChangeEffect'))
	CustomGameEventManager:RegisterListener( 'birzha_pick_player_registred', Dynamic_Wrap( self, 'PlayerRegistred' ) )
	CustomGameEventManager:RegisterListener( 'birzha_pick_player_loaded', Dynamic_Wrap( self, 'PlayerLoaded' ) )
	CustomNetTables:SetTableValue('game_state', 'pickstate_name', {pickstate_name = 'loading'})
	--if IsInToolsMode() then
	--	local pinfo_bot = { bRegistred = true, bLoaded = true, ban_count = 1, steamid = 5151515, partyid = 50000, picked_hero = nil, token_used = false, pet = nil, border = nil, effect=nil, }
	--	PLAYERS[ 1 ] = pinfo_bot
	--	PLAYERS[ 2 ] = pinfo_bot
	--	PLAYERS[ 3 ] = pinfo_bot
	--	PLAYERS[ 4 ] = pinfo_bot
	--	PLAYERS[ 5 ] = pinfo_bot
	--end

	Schedule( 1, function()
		CustomPick:ServerReady()
	end )
end

function CustomPick:ServerReady()
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
	if kv.PlayerID == nil then return end
	local pinfo = CustomPick:RegisterPlayerInfo( kv.PlayerID )
	pinfo.bRegistred = true
	pinfo.bLoaded = true
end

function CustomPick:PlayerLoaded( kv )
	if kv.PlayerID == nil then return end
	local pid = kv.PlayerID

	local player = PlayerResource:GetPlayer( pid )

	if player == nil then return end
	
	if not PLAYERS[ pid ] then
		CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_end', {} )
		return
	end
	
	PLAYERS[ pid ].bLoaded = true
	
	if not IN_STATE then
		CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_end', {} )
		return
	end

	if PICK_STATE ~= BIRZHA_PICK_STATE_PLAYERS_LOADED then
		CustomPick:DrawHeroesForPlayer( pid )
		CustomPick:DrawPickScreenForPlayer( pid )
		CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_filter_reconnect', {banned = BANNED_HEROES, banned_length = #BANNED_HEROES, picked = PICKED_HEROES, picked_length = #PICKED_HEROES})
		if PLAYERS[ pid ].picked_hero ~= nil then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = PLAYERS[ pid ].picked_hero})
		end
		if PICK_STATE == BIRZHA_PICK_STATE_BAN then
			CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_ban_start', {})
		elseif PICK_STATE == BIRZHA_PICK_STATE_SELECT then
			CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_start_selection', {} )
		elseif PICK_STATE == BIRZHA_PICK_STATE_PRE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_preend_start', {} )
		elseif PICK_STATE == BIRZHA_PICK_STATE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_end', {} )
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
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( pid ), 'birzha_pick_start', {} )
end

function CustomPick:DrawHeroesForPlayer()
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_load_heroes', HEROES)
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
		local ability_h = {}
		local heroid = {}
		local difficulty = "Pick_none"
		local role_hero = "Pick_none"

		if inf["difficulty"] ~= nil and inf["difficulty"] ~= "" then
			difficulty = inf["difficulty"]
		end

		if inf["role_hero"] ~= nil and inf["role_hero"] ~= "" then
			role_hero = inf["role_hero"]
		end

		if inf then
			for ab = 1, 50 do
				if inf["Ability" ..ab] ~= nil and inf["Ability"..ab] ~= "" and inf["Ability"..ab] ~= "generic_hidden" then
					if not inf["Ability"..ab]:find("special_bonus") then
						if abilki[ inf["Ability" ..ab] ] then
							behavior = abilki[ inf["Ability" ..ab] ].AbilityBehavior
						end
						if behavior and not behavior:find('DOTA_ABILITY_BEHAVIOR_HIDDEN') then
							table.insert(ability, inf["Ability"..ab])
						end
						if behavior and behavior:find('DOTA_ABILITY_BEHAVIOR_HIDDEN') then
							table.insert(ability_h, inf["Ability"..ab])
						end
					end
				end
			end
			CustomNetTables:SetTableValue("birzha_pick", tostring(enable_heroes[c]), {active_table = ability, hidden_table = ability_h, difficulty = difficulty, role_hero = role_hero})
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

	CustomNetTables:SetTableValue("birzha_pick", "hero_list", {str = str_heroes, ag = ag_heroes, int = int_heroes, str_length = #str_heroes, ag_length = #ag_heroes, int_length = #int_heroes, bp_heroes = BIRZHA_PLUS_HEROES})
end

function CustomPick:StartBanningStage()
	PICK_STATE = BIRZHA_PICK_STATE_BAN
	CustomNetTables:SetTableValue('game_state', 'pickstate_name', {pickstate_name = 'ban'})
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_ban_start', {})
	CustomPick:StartTimers( TIME_OF_STATE[2], function()
		CustomPick:EndBanningStage()
	end )
	for pid, pinfo in pairs( PLAYERS ) do
		if IsDonatorID('premium', pid) or IsDonatorID('gob', pid) or IsDonatorID('dragonball', pid) then
			pinfo.ban_count = pinfo.ban_count + 5
		elseif IsDonatorID('vip', pid) then
			pinfo.ban_count = pinfo.ban_count + 3
		else
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'more_ban_aviable', {})
		end
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'ban_count_changed', {count = pinfo.ban_count})
	end
end

function CustomPick:ArrayShuffle(array)
	local size = #array
	for i = size, 1, -1 do
		local rand = math.random(size)
		array[i], array[rand] = array[rand], array[i]
	end
	return array
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
			CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_timer_upd', { timer = delay_int })
		end

		if PICK_STATE == BIRZHA_PICK_STATE_BAN then
			for pid, pinfo in pairs( PLAYERS ) do
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'ban_count_changed', {count = pinfo.ban_count})
			end
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
	if kv.PlayerID == nil then return end
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
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'ban_count_changed', {count = pinfo.ban_count})
			table.insert(BANNED_HEROES, kv.hero)
			CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_ban_heroes', { hero = kv.hero})
		end
	elseif PICK_STATE == BIRZHA_PICK_STATE_SELECT then
		local is_random_hero = false

		if kv.random then
			kv.hero = CustomPick:RandomHeroForPlayer()
			if pinfo.picked_hero == nil then
				CustomGameEventManager:Send_ServerToAllClients( 'random_hero_chat', { hero = kv.hero, id = pid })
			end
			is_random_hero = true
		end
		
		if IsHeroNotAvailable(kv.hero) or pinfo.picked_hero then return end

		if not GameRules:IsCheatMode() then
			for _, donate_hero in pairs(BIRZHA_PLUS_HEROES) do
				if donate_hero == kv.hero then
					local bp_table = CustomNetTables:GetTableValue("birzhainfo", tostring(pid))
					if bp_table then
						if tonumber(bp_table.bp_days) <= 0 then
							return
						end
					else
						return
					end
				end
			end
		end

		pinfo.picked_hero = kv.hero
		table.insert(PICKED_HEROES, kv.hero)
		if GetMapName() == "birzhamemov_zxc" or GetMapName() == "birzhamemov_samepick" then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = kv.hero, is_random_hero = is_random_hero})
			CustomPick:GiveHeroPlayer(pid, pinfo.picked_hero)
			CheckPlayerHeroes()
			return
		end
		CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_select_hero', { hero = kv.hero})
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = kv.hero, is_random_hero = is_random_hero})
		CustomPick:GiveHeroPlayer(pid, pinfo.picked_hero)
		CheckPlayerHeroes()
	end
end

function CustomPick:PlayerRerandom( kv )
	if kv.PlayerID == nil then return end
	local pid = kv.PlayerID
	local pinfo = PLAYERS[ pid ]

	if PICK_STATE == BIRZHA_PICK_STATE_SELECT then
		kv.hero = CustomPick:RandomHeroForPlayer()
		CustomGameEventManager:Send_ServerToAllClients( 'random_hero_chat', { hero = kv.hero, id = pid })
		pinfo.picked_hero = kv.hero
		table.insert(PICKED_HEROES, kv.hero)
		CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_select_hero', { hero = kv.hero})
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = kv.hero, is_random_hero = 0})
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
	local new_hero = PlayerResource:GetSelectedHeroEntity(id)
	if new_hero ~= nil then
		new_hero:AddNewModifier( new_hero, nil, "modifier_birzha_start_game", {})
		PLAYERS[ id ].selected_hero = new_hero
	end
end

function CustomPick:RegisterEndGameItems()
	for id, info in pairs(PLAYERS) do
		local player_items = {}
		if info.selected_hero ~= nil then
			for i = 0, 18 do
				local item = info.selected_hero:GetItemInSlot(i)
				local name = ""
				if item then
					name = item:GetName()
				end
				player_items[i] = name
			end
		end
		CustomNetTables:SetTableValue("end_game_items", tostring(id), player_items)
	end
end

function CustomPick:RandomHeroForPlayer()
	local hero 
	repeat
		local array_heroes = self:ArrayShuffle(HEROES)
		local random_hero_number = RandomInt(1, #array_heroes)
		hero = array_heroes[random_hero_number]
	until not IsHeroNotAvailable(array_heroes[random_hero_number]) and not IsHeroDonate(array_heroes[random_hero_number])
	return hero
end


function IsHeroDonate(hero)
	for _, donate in pairs(BIRZHA_PLUS_HEROES) do
		if hero == donate then
			return true
		end
	end
	return false
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
	CustomNetTables:SetTableValue('game_state', 'pickstate_name', {pickstate_name = 'start'})
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_start_selection', {} )
	CustomPick:StartTimers( TIME_OF_STATE[3], function()
		if GameRules:IsCheatMode() then return end
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
		CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_preend_start', {} )
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
			CustomGameEventManager:Send_ServerToAllClients( 'random_hero_chat', { hero = hero, id = pid })
			pinfo.picked_hero = hero
			table.insert(PICKED_HEROES, hero)
			CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_select_hero', { hero = hero})
			if IsPlayerDisconnected(pid) then
				CustomPick.DISCONNECTED[pid] = hero
			else
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = hero})
				CustomPick:GiveHeroPlayer(pid, hero)
			end
		end
	end
end

function CustomPick:EndSelection()
	IN_STATE = false
	PICK_STATE = BIRZHA_PICK_STATE_END
	CustomPick.pick_ended = true
	CustomNetTables:SetTableValue('game_state', 'pickstate', {v = 'ended'})
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_end', {} )
	for pid, pinfo in pairs( PLAYERS ) do
		if not IsPlayerDisconnected(pid) then
			local hero = PlayerResource:GetSelectedHeroEntity(pid)
			if hero then
				local player = PlayerResource:GetPlayer(pid)
				if player then
					CustomGameEventManager:Send_ServerToPlayer(player, "set_camera_target", {id = hero:entindex()} )
				end
				hero:AddNewModifier( hero, nil, "modifier_birzha_start_movespeed", {duration = 15})
				if pinfo.effect ~= nil then
					hero:AddDonate(pinfo.effect)
				end
				CustomPick:AddPetFromStart(pid)
				hero:SetGold(700, true)
			end
		end
	end
	GameRules:SetTimeOfDay(0.25)

	-- 9 МАЯ ПРАЗДНИК

	--for i = 1,5 do
	--	Timers:CreateTimer(i * 2, function()
	--		local tank = CreateUnitByName( "npc_unit_happy_tank", Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
	--		local modifier = tank:AddNewModifier( tank, nil, "modifier_birzha_happy_tank", {} )
	--		local modifier = tank:AddNewModifier( tank, nil, "modifier_kill", {duration = 90} )
	--		if i == 1 then
	--			EmitGlobalSound("happy_may")
	--		end
	--	end)
	--end

	--GameRules:SendCustomMessage("<font color='#58ACFA'>С ДНЕМ ПОБЕДЫ!</font>", 0, 0)

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
end

function CustomPick:TokenSet(kv) 
	if kv.PlayerID == nil then return end
	local pinfo = PLAYERS[ kv.PlayerID ]
    local player_info = CustomNetTables:GetTableValue('birzhainfo', tostring(kv.PlayerID)) or {}
    if 10 - (player_info.token_used or 0) <= 0 then return end

    if pinfo and pinfo.token_used == false then   
    	CustomGameEventManager:Send_ServerToAllClients( 'double_rating_chat', { id = kv.PlayerID })     
   		pinfo.token_used = true
    	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(kv.PlayerID), 'birzha_token_change', {})
    end                    
end

function CustomPick:AddPetFromStart(id)
	local player_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
	if player_info then
		if player_info.pet_id ~= 0 then
			PLAYERS[ id ].pet = player_info.pet_id
			donate_shop:AddPetFromStart(id)
		end
		if player_info.border_id ~= 0 then
			PLAYERS[ id ].border = player_info.border_id
			local player =	PlayerResource:GetPlayer(id)
			CustomGameEventManager:Send_ServerToPlayer(player, "set_player_border_from_data", {border_id = player_info.border_id} )
		end
	end
end

function CustomPick:ChangeEffect( kv )
	if kv.PlayerID == nil then return end
	local pid = kv.PlayerID
	PLAYERS[ pid ].effect = tostring(kv.effect)
end



























