_G.birzha_hero_selection = class({})

-- Статусы
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
TIME_OF_STATE[2] = 25
TIME_OF_STATE[3] = 60
TIME_OF_STATE[4] = 10

if IsInToolsMode() or GameRules:IsCheatMode() then
	TIME_OF_STATE[2] = 1
	TIME_OF_STATE[4] = 5
end

birzha_hero_selection.BIRZHA_PLUS_HEROES = 
{
	"npc_dota_hero_migi",
    "npc_dota_hero_skeleton_king",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_overlord",
	"npc_dota_hero_silencer",
	"npc_dota_hero_pudge",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_oracle",
}

BANNED_HEROES = {}
PICKED_HEROES = {}
FULL_ENABLE_HEROES = {}
IN_STATE = false
PICK_STATE = BIRZHA_PICK_STATE_PLAYERS_LOADED
birzha_hero_selection.DISCONNECTED = {}

if GetMapName() == "birzhamemov_solo" then
	table.insert(BANNED_HEROES, "npc_dota_hero_migi")
end

function birzha_hero_selection:Init()
	IN_STATE = true
	birzha_hero_selection:RegisterAbilities()
    birzha_hero_selection:UpdateSubscribersHeroes()
	CustomGameEventManager:RegisterListener( 'birzha_pick_select_hero', Dynamic_Wrap( self, 'PlayerSelect'))
	CustomGameEventManager:RegisterListener( 'birzha_pick_rerandom', Dynamic_Wrap( self, 'PlayerRerandom'))
	CustomGameEventManager:RegisterListener( 'birzha_pick_player_registred', Dynamic_Wrap( self, 'PlayerRegistred' ) )
	CustomGameEventManager:RegisterListener( 'birzha_pick_player_loaded', Dynamic_Wrap( self, 'PlayerLoaded' ) )
	CustomNetTables:SetTableValue('game_state', 'pickstate_name', {pickstate_name = 'loading'})
    birzha_hero_selection:UpdateBannedHeroesLive()
end

function birzha_hero_selection:StartCheckingToStart()
	Schedule( 1, function()
		birzha_hero_selection:CheckReadyPlayers()
	end)
end

function birzha_hero_selection:CheckReadyPlayers( attempt )
	if PICK_STATE ~= BIRZHA_PICK_STATE_PLAYERS_LOADED then
		return
	end
	local bAllReady = true
	for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
		if pinfo.bRegistred and not pinfo.bLoaded then
			bAllReady = false
		end
	end
	if bAllReady then
		Timers:CreateTimer(2, function()
			birzha_hero_selection:Start()
		end)
	else
		local check_interval = 5
		attempt = ( attempt or 0 ) + check_interval
		if attempt > TIME_OF_STATE[1] then
			birzha_hero_selection:Start()
		else
			Schedule( check_interval, function()
				birzha_hero_selection:CheckReadyPlayers( attempt )
			end )
		end
	end
end

function birzha_hero_selection:PlayerRegistred( params )
	if params.PlayerID == nil then return end
    local id = params.PlayerID
	BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].bRegistred = true
	BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].bLoaded = true
end

function birzha_hero_selection:RegisterAbilities()
	local enable_heroes = {}
	local activelist = LoadKeyValues("scripts/npc/activelist.txt")
	local heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	local abilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	for k, v in pairs(activelist) do
		if v == 1 then
			table.insert(enable_heroes, k)
		end
	end
    FULL_ENABLE_HEROES = enable_heroes
	for _, hero_name in pairs(enable_heroes) do
		local hero_info = heroes[hero_name]
        local hero_abilities = {}
        local hero_abilities_bonus = {}
		local difficulty = "Pick_none"
		local role_hero = "Pick_none"
		if hero_info["difficulty"] ~= nil and hero_info["difficulty"] ~= "" then
			difficulty = hero_info["difficulty"]
		end
		if hero_info["role_hero"] ~= nil and hero_info["role_hero"] ~= "" then
			role_hero = hero_info["role_hero"]
		end
        for ab = 1, 50 do
            local ability = hero_info["Ability" ..ab]
            if ability ~= nil and ability ~= "" and ability ~= "generic_hidden" and not ability:find("special_bonus") then
                local behavior = nil
                if abilities[ability] then
                    behavior = abilities[ability].AbilityBehavior
                end
                if behavior and not behavior:find('DOTA_ABILITY_BEHAVIOR_HIDDEN') then
                    table.insert(hero_abilities, ability)
                end
                if behavior and behavior:find('DOTA_ABILITY_BEHAVIOR_HIDDEN') then
                    table.insert(hero_abilities_bonus, ability)
                end
            end
        end
        CustomNetTables:SetTableValue("birzha_pick", tostring(hero_name), {active_table = hero_abilities, hidden_table = hero_abilities_bonus, difficulty = difficulty, role_hero = role_hero})
	end
end

function birzha_hero_selection:UpdateSubscribersHeroes()
    CustomNetTables:SetTableValue("birzha_pick", "subscribe_heroes", {bp_heroes = birzha_hero_selection.BIRZHA_PLUS_HEROES})
end

function birzha_hero_selection:PlayerLoaded( params )
	if params.PlayerID == nil then return end
	local pid = params.PlayerID
	local player = PlayerResource:GetPlayer( pid )
	if player == nil then return end
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[pid]
	if player_info == nil then
		CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_end', {} )
		return
	end
	player_info.bLoaded = true
	if not IN_STATE then
		CustomGameEventManager:Send_ServerToPlayer( player, 'birzha_pick_end', {} )
		return
	end
	if PICK_STATE ~= BIRZHA_PICK_STATE_PLAYERS_LOADED then
		if player_info.picked_hero ~= nil then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = player_info.picked_hero})
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

function birzha_hero_selection:Start()
	birzha_hero_selection:StartBanningStage()
end

-- Выбор героя
function birzha_hero_selection:PlayerSelect( params )
	if params.PlayerID == nil then return end
	local id = params.PlayerID
	local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]

	if PICK_STATE == BIRZHA_PICK_STATE_BAN then
		if params.random then return end
		if not player_info or player_info.ban_count <= 0 then return end
		if not IsHeroNotAvailable(params.hero) then
			player_info.ban_count = player_info.ban_count - 1
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(id), 'ban_count_changed', {count = player_info.ban_count})
			table.insert(BANNED_HEROES, params.hero)
            birzha_hero_selection:UpdateBannedHeroesLive()
		end
	elseif PICK_STATE == BIRZHA_PICK_STATE_SELECT then
		local is_random_hero = false
		if params.random then
			params.hero = birzha_hero_selection:RandomHeroForPlayer()
			if player_info.picked_hero == nil then
				CustomGameEventManager:Send_ServerToAllClients( 'random_hero_chat', { hero = params.hero, id = id })
			end
			is_random_hero = true
		end
		if IsHeroNotAvailable(params.hero) or player_info.picked_hero then return end

        local is_has_subscribe_to_hero = true

		if not GameRules:IsCheatMode() then
			for _, donate_hero in pairs(birzha_hero_selection.BIRZHA_PLUS_HEROES) do
				if donate_hero == params.hero then
                    if player_info.server_data.bp_days <= 0 then
                        is_has_subscribe_to_hero = false
                    end
                    break
				end
			end
		end

        if is_has_subscribe_to_hero then
            player_info.picked_hero = params.hero
            table.insert(PICKED_HEROES, params.hero)
            birzha_hero_selection:UpdatePickedHeroesLive()
            if GetMapName() == "birzhamemov_zxc" or GetMapName() == "birzhamemov_samepick" then
                CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(id), 'hero_is_picked', {hero = params.hero, is_random_hero = is_random_hero})
                birzha_hero_selection:GiveHeroPlayer(id, player_info.picked_hero)
                CheckPlayerHeroes()
                return
            end
            CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(id), 'hero_is_picked', {hero = params.hero, is_random_hero = is_random_hero})
            birzha_hero_selection:GiveHeroPlayer(id, player_info.picked_hero)
            CheckPlayerHeroes()
        end
	end
end

function birzha_hero_selection:PlayerRerandom( params )
	if params.PlayerID == nil then return end
	local pid = params.PlayerID
	local pinfo = BirzhaData.PLAYERS_GLOBAL_INFORMATION[pid]
	if PICK_STATE == BIRZHA_PICK_STATE_SELECT then
        birzha_hero_selection:RemovePickedHeroFromTable(pinfo.picked_hero)
		params.hero = birzha_hero_selection:RandomHeroForPlayer()
		CustomGameEventManager:Send_ServerToAllClients( 'random_hero_chat', { hero = params.hero, id = pid })
		pinfo.picked_hero = params.hero
		table.insert(PICKED_HEROES, params.hero)
        birzha_hero_selection:UpdatePickedHeroesLive()
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = params.hero, is_random_hero = 0})
		birzha_hero_selection:GiveHeroPlayer(pid, pinfo.picked_hero)
		CheckPlayerHeroes()
	end
end

-- Стадии
function birzha_hero_selection:StartBanningStage()
    for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
		if IsDonatorID('premium', pid) or IsDonatorID('gob', pid) or IsDonatorID('dragonball', pid) then
			pinfo.ban_count = pinfo.ban_count + 5
		elseif IsDonatorID('vip', pid) then
			pinfo.ban_count = pinfo.ban_count + 3
        end
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'ban_count_changed', {count = pinfo.ban_count})
	end
    birzha_hero_selection:UpdatePickedHeroesLive()
	PICK_STATE = BIRZHA_PICK_STATE_BAN
	CustomNetTables:SetTableValue('game_state', 'pickstate_name', {pickstate_name = 'ban'})
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_ban_start', {})
	birzha_hero_selection:StartTimers( TIME_OF_STATE[2], function()
		birzha_hero_selection:EndBanningStage()
	end)
	report_system:UpdateReportsInfo()
end

function birzha_hero_selection:EndBanningStage()
	if PICK_STATE ~= BIRZHA_PICK_STATE_BAN then
		return
	end
	CustomNetTables:SetTableValue("birzha_pick", "banned_heroes", BANNED_HEROES)
	birzha_hero_selection:StartSelectionStage()
end

function birzha_hero_selection:StartSelectionStage()
	PICK_STATE = BIRZHA_PICK_STATE_SELECT
	CustomNetTables:SetTableValue('game_state', 'pickstate_name', {pickstate_name = 'start'})
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_start_selection', {} )
	birzha_hero_selection:StartTimers( TIME_OF_STATE[3], function()
		if GameRules:IsCheatMode() then return end
		birzha_hero_selection:EndSelectionStage()
	end)	
end

function birzha_hero_selection:EndSelectionStage()
	if PICK_STATE ~= BIRZHA_PICK_STATE_SELECT then
		return
	end
	CustomNetTables:SetTableValue("birzha_pick", "picked_heroes", PICKED_HEROES)
	birzha_hero_selection:StartPreEndSelection()
end

function birzha_hero_selection:StartPreEndSelection()
	Debug:Execute( function()
		PICK_STATE = BIRZHA_PICK_STATE_PRE_END
		CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_preend_start', {} )
		birzha_hero_selection:GiveHeroes()
		birzha_hero_selection:StartTimers( TIME_OF_STATE[4], function()
			birzha_hero_selection:EndSelection()
		end )	
	end)
end

function birzha_hero_selection:EndSelection()
	IN_STATE = false
	PICK_STATE = BIRZHA_PICK_STATE_END
	birzha_hero_selection.pick_ended = true
	CustomNetTables:SetTableValue('game_state', 'pickstate', {v = 'ended'})
	CustomGameEventManager:Send_ServerToAllClients( 'birzha_pick_end', {} )
    BirzhaGameMode:InitObservers()
	GameRules:SetTimeOfDay(0.25)
	CustomGameEventManager:Send_ServerToAllClients( 'open_win_predict', {})
    BirzhaData:CheckConnection()
    Timers:CreateTimer({
		useGameTime = false,
		endTime = 15,
		callback = function()
			CustomGameEventManager:Send_ServerToAllClients( 'close_win_predict', {})  
			return nil
		end
	})
    if not IsInToolsMode() then
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
	for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
		if not IsPlayerDisconnected(pid) then
			local hero = pinfo.selected_hero
			if hero then
				local player = PlayerResource:GetPlayer(pid)
				if player then
					CustomGameEventManager:Send_ServerToPlayer(player, "set_camera_target", {id = hero:entindex()} )
				end
                hero:RemoveModifierByName("modifier_birzha_start_game")
				hero:AddNewModifier( hero, nil, "modifier_birzha_start_movespeed", {duration = 10})
				hero:SetGold(700, true)
			end
		end
	end
    for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
		if not IsPlayerDisconnected(pid) then
			local hero = pinfo.selected_hero
			if hero then
                birzha_hero_selection:AddDonateFromStart(pid)
                donate_shop:AddedDonateStart(hero, pid)
			end
		end
	end
end

function birzha_hero_selection:AddDonateFromStart(id)
	local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
	if player_info then
		if player_info.server_data.pet_default ~= 0 then
			donate_shop:AddPetFromStart(id)
		end
        if player_info.server_data.effect_id ~= 0 then
            player_info.selected_hero:AddDonate(id)
        end
	end
end

-- Менее важные функции

function birzha_hero_selection:RandomHeroForPlayer()
	local hero 
	repeat
		local array_heroes = table.shuffle(FULL_ENABLE_HEROES)
		local random_hero_number = RandomInt(1, #array_heroes)
		hero = array_heroes[random_hero_number]
	until not IsHeroNotAvailable(array_heroes[random_hero_number]) and not IsHeroDonate(array_heroes[random_hero_number])
	return hero
end

function CheckPlayerHeroes()
	if PICK_STATE == BIRZHA_PICK_STATE_PRE_END or PICK_STATE == BIRZHA_PICK_STATE_END then return end
	for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
		if pinfo.picked_hero == nil then
			return 
		end
	end
	birzha_hero_selection:EndSelectionStage()
end

function birzha_hero_selection:GiveHeroPlayer(id,hero)
	local wisp = PlayerResource:GetSelectedHeroEntity(id)
	PlayerResource:ReplaceHeroWith(id, hero, 700, 0)
	local new_hero = PlayerResource:GetSelectedHeroEntity(id)
	if new_hero ~= nil then
		new_hero:AddNewModifier( new_hero, nil, "modifier_birzha_start_game", {})
		BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].selected_hero = new_hero
	end
end

function birzha_hero_selection:GiveHeroes()
	for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
		if pinfo.picked_hero == nil then
			local hero = birzha_hero_selection:RandomHeroForPlayer()
			CustomGameEventManager:Send_ServerToAllClients( 'random_hero_chat', { hero = hero, id = pid })
			BirzhaData.PLAYERS_GLOBAL_INFORMATION[pid].picked_hero = hero
			table.insert(PICKED_HEROES, hero)
            birzha_hero_selection:UpdatePickedHeroesLive()
			if IsPlayerDisconnected(pid) then
				birzha_hero_selection.DISCONNECTED[pid] = hero
			else
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {hero = hero})
				birzha_hero_selection:GiveHeroPlayer(pid, hero)
			end
		end
	end
end

-- Дополнительные функции

function IsHeroDonate(hero)
	for _, donate in pairs(birzha_hero_selection.BIRZHA_PLUS_HEROES) do
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

function birzha_hero_selection:StartTimers( delay, fExpire )
	local n = 1
	local f = function()
		n = n - 1
		if n == 0 then
			fExpire()
		end
	end
	self:StartTimer( delay, f )
end

function birzha_hero_selection:StartTimer( delay, fExpire )
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
			for pid, pinfo in pairs( BirzhaData.PLAYERS_GLOBAL_INFORMATION ) do
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'ban_count_changed', {count = pinfo.ban_count})
			end
		end

		return tick_interval
	end )
end

function birzha_hero_selection:RemovePickedHeroFromTable(hero_name)
    for i=#PICKED_HEROES, 1, -1 do
        if PICKED_HEROES[i] and PICKED_HEROES[i] == hero_name then
            table.remove(PICKED_HEROES, i)
        end
    end
    birzha_hero_selection:UpdatePickedHeroesLive()
end

function birzha_hero_selection:UpdatePickedHeroesLive()
    CustomNetTables:SetTableValue("birzha_pick", "picked_heroes", PICKED_HEROES)
end

function birzha_hero_selection:UpdateBannedHeroesLive()
    CustomNetTables:SetTableValue("birzha_pick", "banned_heroes", BANNED_HEROES)
end