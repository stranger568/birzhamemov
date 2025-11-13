if BirzhaGameMode == nil then
	_G.BirzhaGameMode = class({})
end

-- Библиотеки
Precache = require "utils/precache"
require('configs/const')
require('addon_init')
require('utils/table')
require('utils/vector_targeting')
require('utils/functions')
require('utils/timers')
require('utils/playertables')
require('utils/worldpanels')
require('utils/physics')
require('utils/debug_')
require('hero_demo/demo_core')
require('utils/commands/custom_commands')
require('utils/requests')
require('utils/error_tracking')
require('utils/valve_fix')
require("utils/selection")

-- Сервер / Рейтинг / Донат
require('game_lib/server')
require('game_lib/report_system')
require('game_lib/donate_shop')

-- Игровые
require('game_lib/disconnect_lib')
require('game_lib/custom_selection')
require('game_lib/events')
require('game_lib/items')
require('game_lib/filters')

function Activate()
	BirzhaGameMode:InitGameMode()
	BMConnections:RegListeners()
	StartTimerLoading()
	SendToServerConsole("tv_delay 10")
end

function BirzhaGameMode:InitGameMode()
    -- Измененная таблица опыта
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	if IsInToolsMode() then
		GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 30 )
        GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
	else
		GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 30 )
        GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel({0,240,640,1160,1760,2440,3200,4000,4900,5900,7000,8200,9500,10900,12400,14000,15700,17500,19400,21400,23600,26000,28600,31400,34400,38400,43400,49400,56400,63900})
	end
    
    -- Чит режим с тестом героев
	if GameRules:IsCheatMode() then
    	HeroDemo:Init()
	end

    -- Дефолтные настройки овертроу
    self.m_GatheredShuffledTeams = {}
	self.spawnTime = 90
	self.nNextSpawnItemNumber = 1
	self.hasWarnedSpawn = false
	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.tier1ItemBucket = {}
	self.tier2ItemBucket = {}
	self.tier3ItemBucket = {}
	self.tier4ItemBucket = {}
    self.tier5ItemBucket = {}
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }	
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }
    self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"
    
    self.m_GoldRadiusMin = 100
	self.m_GoldRadiusMax = 550
	self.m_GoldDropPercent = 8
	self.effectradius = 900
    
    if GetMapName() == "birzhamemov_5v5v5" then
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 8
		self.effectradius = 1400
	elseif GetMapName() == "birzhamemov_5v5" then
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 8
		self.effectradius = 1400
	elseif GetMapName() == "birzhamemov_zxc" then
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 8
		self.effectradius = 1400
    end
    for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

    -- Настройка количество игроков в команде
	if GetMapName() == "birzhamemov_zxc" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	elseif GetMapName() == "birzhamemov_solo" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )
	elseif GetMapName() == "birzhamemov_duo" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 2 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 2 )
	elseif GetMapName() == "birzhamemov_trio" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 3 )
	elseif GetMapName() == "birzhamemov_5v5" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	elseif GetMapName() == "birzhamemov_5v5v5" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 5 )
	end

    -- Отдельные настройки игры
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1300)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
    GameRules:GetGameModeEntity():SetUseTurboCouriers( true )
	GameRules:GetGameModeEntity():SetPauseEnabled( false )
	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 20 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetStrategyTime( TIME_OF_STATE[4] )
	GameRules:SetShowcaseTime( 1 )
    GameRules:SetHeroSelectionTime(9999999)
    GameRules:SetHeroSelectPenaltyTime(0)
	GameRules:SetFilterMoreGold( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetHideKillMessageHeaders( true )
	GameRules:SetUseUniversalShopMode( true )
    GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0 )
    GameRules:GetGameModeEntity():SetCustomBackpackCooldownPercent(1)
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled(false)
    GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath(false)
    GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_tpscroll_custom")
    GameRules:SetPostGameLayout( DOTA_POST_GAME_LAYOUT_DOUBLE_COLUMN )
    GameRules:GetGameModeEntity():SetForcedHUDSkin( "reborn" )
	GameRules:SetPostGameColumns({ DOTA_POST_GAME_COLUMN_LEVEL, DOTA_POST_GAME_COLUMN_KILLS, DOTA_POST_GAME_COLUMN_DEATHS, DOTA_POST_GAME_COLUMN_ASSISTS, DOTA_POST_GAME_COLUMN_DAMAGE,DOTA_POST_GAME_COLUMN_HEALING})
    SendToServerConsole("dota_max_physical_items_purchase_limit 9999")

    -- Настройки рун
    GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_DOUBLEDAMAGE , true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_HASTE, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ILLUSION, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_INVISIBILITY, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, false )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ARCANE, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, false )
	
    -- Фильтры
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( BirzhaGameMode, "ExecuteOrderFilter" ), self )
	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( BirzhaGameMode, "DamageFilter" ), self )
	GameRules:GetGameModeEntity():SetHealingFilter( Dynamic_Wrap(BirzhaGameMode, "HealingFilter"), self )

    -- Ивенты доты
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap( self, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent("npc_spawned", Dynamic_Wrap( self, "OnNPCSpawned" ), self )
	ListenToGameEvent("dota_team_kill_credit", Dynamic_Wrap( self, 'OnTeamKillCredit' ), self )
	ListenToGameEvent("entity_killed", Dynamic_Wrap( self, 'OnEntityKilled' ), self )
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap( self, "OnItemPickUp"), self )
	ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap( self, "OnNpcGoalReached" ), self )
	ListenToGameEvent("player_chat", Dynamic_Wrap(ChatListener, 'OnPlayerChat'), ChatListener)
    ListenToGameEvent("player_connect_full", Dynamic_Wrap(self, 'OnConnectFull'), self)

    -- Кастомные ивенты
    CustomGameEventManager:RegisterListener( "birzha_contract_target_selected", Dynamic_Wrap(BirzhaData, "birzha_contract_target_selected"))
    CustomGameEventManager:RegisterListener( "birzha_update_check_birzha_plus", Dynamic_Wrap(BirzhaData, "birzha_update_check_birzha_plus"))
	CustomGameEventManager:RegisterListener( "win_condition_predict", Dynamic_Wrap(BirzhaData, "win_condition_predict"))
	CustomGameEventManager:RegisterListener( "change_premium_pet", Dynamic_Wrap(donate_shop, "ChangePetPremium"))
    CustomGameEventManager:RegisterListener( "donate_change_item_active", Dynamic_Wrap(donate_shop, "donate_change_item_active"))
	CustomGameEventManager:RegisterListener( "change_border_effect", Dynamic_Wrap(donate_shop, "change_border_effect"))
    CustomGameEventManager:RegisterListener( "change_tip_effect", Dynamic_Wrap(donate_shop, "change_tip_effect"))
    CustomGameEventManager:RegisterListener( "change_five_effect", Dynamic_Wrap(donate_shop, "change_five_effect"))
    CustomGameEventManager:RegisterListener( "change_hero_effect", Dynamic_Wrap(donate_shop, "change_hero_effect"))
	CustomGameEventManager:RegisterListener( "donate_shop_buy_item", Dynamic_Wrap(donate_shop, "BuyItem"))
	CustomGameEventManager:RegisterListener( "PlayerTip", Dynamic_Wrap(donate_shop, 'PlayerTip'))
	CustomGameEventManager:RegisterListener( "SelectSmile", Dynamic_Wrap(donate_shop, 'SelectSmile'))
	CustomGameEventManager:RegisterListener( "LotteryStart", Dynamic_Wrap(donate_shop, 'LotteryStart'))
	CustomGameEventManager:RegisterListener( "SelectVO", Dynamic_Wrap(donate_shop,'SelectVO'))
	CustomGameEventManager:RegisterListener( "select_chatwheel_player", Dynamic_Wrap(donate_shop,'SelectChatWheel'))
	CustomGameEventManager:RegisterListener( "SpawnHeroDemo", Dynamic_Wrap(HeroDemo,'SpawnHeroDemo'))
    CustomGameEventManager:RegisterListener( "ChangeHeroDemo", Dynamic_Wrap(HeroDemo,'ChangeHeroDemo'))
	CustomGameEventManager:RegisterListener( "player_reported_select", Dynamic_Wrap(report_system, 'player_reported_select'))
    CustomGameEventManager:RegisterListener( "birzha_token_set", Dynamic_Wrap(BirzhaData, 'TokenSet'))
    CustomGameEventManager:RegisterListener( "StartHighFive", Dynamic_Wrap(donate_shop, 'StartHighFive'))
    CustomGameEventManager:RegisterListener( "shop_birzha_open_chest_get_items_list", Dynamic_Wrap(donate_shop, 'shop_birzha_open_chest_get_items_list'))
    CustomGameEventManager:RegisterListener( "shop_birzha_open_chest_get_reward", Dynamic_Wrap(donate_shop, 'shop_birzha_open_chest_get_reward'))
    CustomGameEventManager:RegisterListener( "birzha_neutral_item_choose", Dynamic_Wrap(self, 'birzha_neutral_item_choose'))

    -- Иниты либ
    self:GatherAndRegisterValidTeams()
    BirzhaData:RegisterSeasonInfo()
    BirzhaData:GetHeroesWinrate()

    -- Зимний мод
    self.winter_mode = false

    -- Think на определение позиции героя
    local fix_pos_timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "Fix_position" })
    fix_pos_timer:SetThink( FixPosition, FrameTime() )

	-- Дефолтный think
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )  
end

function FixPosition()
	local check_modifiers = _G.MOTION_MODIFIERS_CUSTOM
	local allHeroes = HeroList:GetAllHeroes()
	for _, hero in pairs(allHeroes) do
		if hero:IsRealHero() then
			local return_hero_position = true
			local abs = hero:GetAbsOrigin()
			if not GridNav:IsTraversable(abs) and not hero:HasFlyingVision() and not hero:HasFlyMovementCapability() then
				if not hero:IsCurrentlyHorizontalMotionControlled() and not hero:IsCurrentlyVerticalMotionControlled() then
					for _, mod in pairs(check_modifiers) do
						if hero:HasModifier(mod) then
							return_hero_position = false
						end
					end
					if return_hero_position then
						local direction = (Vector(0,0,0) - hero:GetAbsOrigin()):Normalized()
						local origin = hero:GetAbsOrigin() + direction * 200
						origin.z = GetGroundPosition(origin, hero).z
						hero:SetAbsOrigin(origin)
					end
				end
			end
		end
	end
	return FrameTime()
end

function BirzhaGameMode:OnThink()
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		self:UpdatePlayerColor( nPlayerID )
	end
	self:UpdateScoreboard()
	if GameRules:IsGamePaused() then return 1 end
    if birzha_hero_selection.pick_ended == nil then return 1 end
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return 1 end
    BirzhaGameMode:GameInProgressThink()
	return 1
end

function BirzhaGameMode:OnConnectFull(data)
	local player_index = EntIndexToHScript( data.index )
	if player_index == nil then
		return
	end
    BirzhaData:RegisterPlayer(data.PlayerID)
end

-------------OVERTHROW РАСПРЕДЕЛЕНИЕ КОМАНД-----------------------

function BirzhaGameMode:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 }
	end
	return color
end

function BirzhaGameMode:UpdatePlayerColor( nPlayerID )
	if not PlayerResource:HasSelectedHero( nPlayerID ) then
		return
	end

	local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hero == nil then
		return
	end

	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = self:ColorForTeam( teamID )
	PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )
end

function BirzhaGameMode:UpdateScoreboard()
	local sortedTeams = {}

	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(team))
		if table_team_score then
			table.insert( sortedTeams, { teamID = team, teamScore = table_team_score.kills } )
		end
	end

	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
	for _, t in pairs( sortedTeams ) do
		local clr = self:ColorForTeam( t.teamID )
		local score = 
		{
			team_id = t.teamID,
			team_score = t.teamScore
		}
	end

	local leader = sortedTeams[1].teamID
	self.leadingTeam = leader
	self.runnerupTeam = sortedTeams[2].teamID
	self.leadingTeamScore = sortedTeams[1].teamScore
	self.runnerupTeamScore = sortedTeams[2].teamScore
	if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
		self.isGameTied = true
	else
		self.isGameTied = false
	end
end

function BirzhaGameMode:GatherAndRegisterValidTeams()
	local foundTeams = {}
	for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
		foundTeams[  playerStart:GetTeam() ] = true
	end
	local numTeams = TableCount(foundTeams)
	local foundTeamsList = {}
	for t, _ in pairs( foundTeams ) do
		table.insert( foundTeamsList, t )
	end
	if numTeams == 0 then
		table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
		table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
		numTeams = 2
	end
	local maxPlayersPerValidTeam = math.floor( 10 / numTeams )
	self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )
	for team = 0, (DOTA_TEAM_COUNT-1) do
		CustomNetTables:SetTableValue("game_state", tostring(team), {kills = 0})
	end
end

function BirzhaGameMode:InitObservers()
	for i=1,8 do
		local observer = Entities:FindByName(nil, "birzha_observer"..i)
		if observer then
			observer:AddNewModifier(observer, nil, "modifier_birzha_observer", {})
		end
	end
end

function BirzhaGameMode:SpawnContracts()
    CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ContractHasSpawned", icon = "contract_spawned"} )
    local players_list = {}
    for id, inf in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		if inf.selected_hero ~= nil and not IsPlayerDisconnected(id) then
			table.insert(players_list, {hero = inf.selected_hero, id = id, netw = PlayerResource:GetNetWorth(id)})
		end
	end
    table.sort( players_list, function(x,y) return y.netw > x.netw end )
    for i=1,2 do
        if players_list[i] then
            players_list[i].hero:AddItemByName( "item_birzha_contract" )
        end
    end
end

function BirzhaGameMode:SpawnAntosha()
    local npc_dota_azazin_antosha = CreateUnitByName("npc_dota_azazin_antosha", Vector(0, 0, 0) + RandomVector(200), true, nil, nil, DOTA_TEAM_NEUTRALS)
    npc_dota_azazin_antosha:AddNewModifier(npc_dota_azazin_antosha, nil, "modifier_npc_dota_azazin_antosha", {})
end

function BirzhaGameMode:SpawnKobold()
    local npc_dota_azazin_kobold = CreateUnitByName("npc_dota_azazin_kobold", Vector(0, 0, 0) + RandomVector(200), true, nil, nil, DOTA_TEAM_NEUTRALS)
    npc_dota_azazin_kobold:AddNewModifier(npc_dota_azazin_kobold, nil, "modifier_npc_dota_azazin_kobold", {})
end

function BirzhaGameMode:SpawnGoldKobold( spawnPoint, isEvent )
    local item_n = "item_bag_of_gold_event"
    if isEvent then
        item_n = "item_bag_of_gold"
    end
	local newItem = CreateItem( item_n, nil, nil )
    newItem.is_cooldown_take = true
    Timers:CreateTimer(0.3, function()
        newItem.is_cooldown_take = nil
    end)
	local drop = CreateItemOnPositionForLaunch(spawnPoint, newItem )
	newItem:LaunchLootInitialHeight( false, 0, 500, 0.3, spawnPoint + RandomVector( RandomInt(100, 200) ))
	newItem:SetContextThink( "KillLoot", function() return BirzhaGameMode:KillLoot( newItem, drop ) end, 20 )
end