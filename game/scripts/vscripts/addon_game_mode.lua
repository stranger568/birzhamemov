if BirzhaGameMode == nil then
	_G.BirzhaGameMode = class({})
end

-- Библиотеки
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

-- Сервер / Рейтинг / Донат
require("game_lib/server")
require('game_lib/report_system')
require('game_lib/donate_shop')

-- Игровые
require('game_lib/disconnect_lib')
require('game_lib/custom_selection')
require('game_lib/events')
require('game_lib/items')
require('game_lib/filters')

function Precache( context )
	PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha.vsndevts", context ) 
    PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha_2.vsndevts", context ) 
    PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha_3.vsndevts", context ) 
    PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha_4.vsndevts", context ) 
    PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha_5.vsndevts", context ) 
    PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha_6.vsndevts", context ) 
	
  	local heroes = LoadKeyValues("scripts/npc/dota_heroes.txt")
  	for k,v in pairs(heroes) do
  		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context )  
  		PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context ) 
  	end

  	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts", context )  
  	PrecacheResource( "soundfile", "soundevents/game_sounds_creeps.vsndevts", context )  

  	local list = 
  	{
    	model = 
        {
            "models/courier/baby_rosh/babyroshan.vmdl",
            "models/courier/donkey_trio/mesh/donkey_trio.vmdl",
            "models/courier/mechjaw/mechjaw.vmdl",
            "models/courier/huntling/huntling.vmdl",
            "models/items/courier/devourling/devourling.vmdl",
            "models/courier/seekling/seekling.vmdl",
            "models/courier/venoling/venoling.vmdl",
            "models/items/courier/amaterasu/amaterasu.vmdl",
            "models/items/courier/beaverknight_s2/beaverknight_s2.vmdl",
            "models/items/courier/nian_courier/nian_courier.vmdl",
            "models/items/courier/faceless_rex/faceless_rex.vmdl",
            "models/pets/icewrack_wolf/icewrack_wolf.vmdl",

            "models/apple_horo.vmdl",
            "models/ball.vmdl",
            "models/bogdan_wrench.vmdl",
            "models/card.vmdl",
            "models/cup_kaneki.vmdl",
            "models/hero_knuckles.vmdl",
            "models/hookah.vmdl",
            "models/knuckles_tank.vmdl",
            "models/omniknight_zelensky_head.vmdl",
            "models/troll_warlord_gorin_stool.vmdl",
            "models/yakub_car.vmdl",

            "models/update_heroes/scp192/scp192.vmdl",
            "models/heroes/anime/opm/saitama/saitama.vmdl",
            "models/heroes/wraith_king/wraith_king.vmdl",
            "models/heroes/meepo/meepo.vmdl",
            "models/update_heroes/migi/migi.vmdl",
            "models/venom/venom.vmdl",
            "models/npc/npc_dingus/dingus.vmdl",
            "models/heroes/undying/undying.vmdl",
            "models/update_heroes/kaneki/kaneki.vmdl",
            "models/nolik/nolik.vmdl",
            "models/pyramide/pyramide.vmdl",
            "models/items/tiny/tiny_bad_to_the_bone_belt/tiny_bad_to_the_bone_belt.vmdl",
            "models/update_heroes/overlord_game/overlord.vmdl",
            "models/creeps/neutral_creeps/n_creep_gargoyle/n_creep_gargoyle.vmdl",
            "models/update_heroes/ruby/ruby.vmdl",
            "models/update_heroes/goku/goku_base.vmdl",
            "models/items/tiny/burning_stone_giant/burning_stone_giant_01.vmdl",
            "models/update_heroes/guts/guts.vmdl",
            "models/update_heroes/akame/akame.vmdl",
            "models/update_heroes/shiro/shiro.vmdl",
            "models/creeps/ogre_1/large_ogre.vmdl",
            "models/update_heroes/scp173/scp173.vmdl",
            "models/update_heroes/hisoka/hisoka.vmdl",
            "models/update_heroes/illidan/illidan_base.vmdl",
            "models/update_heroes/ghostface/ghost_face.vmdl",
            "models/pirat/serega.vmdl",
            "models/update_heroes/kurumi/kurumi_base.vmdl",
            "models/kyriyama/girl_2.vmdl",
            "models/update_heroes/monika/monika.vmdl",
            "models/sonic/sonic.vmdl",
            "models/update_heroes/rin/rin.vmdl",
            "models/heroes/shadow_fiend/arcana_wings.vmdl",
            "models/heroes/shadow_fiend/head_arcana.vmdl",
            "models/heroes/shadow_fiend/shadow_fiend_arcana.vmdl",
            "models/items/shadow_fiend/arms_deso/arms_deso.vmdl",
            "models/heroes/juggernaut/juggernaut_arcana.vmdl",
            "models/heroes/terrorblade/terrorblade_arcana.vmdl",
            "models/heroes/polnaref/polnaref.vmdl",
            "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana.vmdl",
            "models/update_heroes/yuno/yuno.vmdl",
            "models/update_heroes/haku/haku_with_mask.vmdl",
            "models/update_heroes/horo/horo.vmdl",
            "models/dead_rat/dead_rat.vmdl",
            "models/update_heroes/rem/rem.vmdl",
            "models/update_heroes/knuckles/knuckles.vmdl",
            "models/update_heroes/knuckles/knuckles.vmdl",
            "models/knuckles_tank.vmdl",
            "models/items/crystal_maiden/pw_cm_staff/crystal_maiden_weapon.vmdl",
            "models/heroes/crystal_maiden/crystal_maiden_arcana_back.vmdl",
            "models/items/crystal_maiden/immortal_shoulders/cm_immortal_shoulders.vmdl",
            "models/items/crystal_maiden/winter_solstice_fashion/winter_solstice_fashion.vmdl",
            "models/items/lina/origins_flamehair/origins_flamehair.vmdl",
            "models/items/lina/lina_immortal_ii/mesh/lina_immortal_ii.vmdl",
            "models/items/lina/lina_ti7/lina_ti7.vmdl",
            "models/items/windrunner/ti6_falcon_bow/ti6_falcon_bow_model.vmdl",
            "models/items/windrunner/sylvan_cascade/sylvan_cascade.vmdl",
            "models/items/windrunner/orchid_flowersong_head/orchid_flowersong_head.vmdl",
            "models/heroes/warlock/warlock.vmdl",
            "models/tailer/shelby.vmdl",
            "models/heroes/rikimaru/rikimaru.vmdl",
            "models/jull/jull.vmdl",
            "models/items/axe/ti9_jungle_axe/axe_bare.vmdl",
            "models/update_heroes/felix/felix.vmdl",
            "models/update_heroes/megumin/megumin.vmdl",
            "models/heroes/keeper_of_the_light/keeper_of_the_light.vmdl",
            "models/pump/pump.vmdl",
            "models/update_heroes/dio_base/dio_base.vmdl",
            "models/update_heroes/hatsune_miku/hatsune_miku.vmdl",
            "models/freddy/freddy.vmdl",
            "models/travoman/travoman_head.vmdl",
            "models/update_heroes/train_thomas/train_thomas.vmdl",
            "models/update_heroes/pucci/pucci.vmdl",
            "models/heroes/invoker_kid/invoker_kid.vmdl",
            "models/ns/ns_model.vmdl",
            "models/dimon/dimon_model.vmdl",
            "models/update_heroes/ram/ram.vmdl",
            "models/update_heroes/kakashi/kakashi.vmdl",
            "models/update_heroes/avatar_aang/avatar_aang.vmdl",
            "models/update_heroes/overlord_anime/overlord.vmdl",
        },
    	soundfile = {
            "soundevents/voscripts/game_sounds_vo_batrider.vsndevts",
            "soundevents/voscripts/game_sounds_vo_void_spirit.vsndevts",
            "soundevents/voscripts/game_sounds_vo_earth_spirit.vsndevts",
            "soundevents/voscripts/game_sounds_vo_faceless_void.vsndevts",
            "soundevents/game_sounds_creeps.vsndevts",
            "soundevents/voscripts/game_sounds_vo_announcer_dlc_rick_and_morty.vsndevts",
            "soundevents/soundevents_conquest.vsndevts",
            "soundevents/voscripts/game_sounds_vo_terrorblade.vsndevts",
            "soundevents/soundevents_minigames.vsndevts",
            "soundevents/game_sounds_ui_imported.vsndevts"
        },
    	particle = 
        {
            "particles/econ/events/nexon_hero_compendium_2014/teleport_end_nexon_hero_cp_2014.vpcf",
            "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf",
            "particles/leader/leader_overhead.vpcf",
            "particles/last_hit/last_hit.vpcf",
            "particles/units/heroes/hero_zuus/zeus_taunt_coin.vpcf",
            "particles/addons_gameplay/player_deferred_light.vpcf",
            "particles/items_fx/black_king_bar_avatar.vpcf",
            "particles/treasure_courier_death.vpcf",
            "particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf",
            "particles/econ/items/effigies/status_fx_effigies/gold_effigy_ambient_dire_lvl2.vpcf",
            "particles/units/heroes/hero_kunkka/kunkka_ghost_ship_model.vpcf",
            "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
            "particles/memolator3/memolator.vpcf",
            "particles/generic_gameplay/generic_silenced.vpcf",
            "particles/memolator2/desolator_projectile.vpcf",
            "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
            "particles/items2_fx/veil_of_discord.vpcf",
        },
    	particle_folder = {}
  	}

  	for k,v in pairs(list) do
    	for z,x in pairs(v) do 
    		PrecacheResource(k, x, context)
    	end
  	end
end

function Activate()
	BirzhaGameMode:InitGameMode()
	BirzhaEvents:RegListeners()
	StartTimerLoading()
	SendToServerConsole("tv_delay 10")
end

function BirzhaGameMode:InitGameMode()
	XP_PER_LEVEL_TABLE = {0,240,640,1160,1760,2440,3200,4000,4900,5900,7000,8200,9500,10900,12400,14000,15700,17500,19400,21400,23600,26000,28600,31400,34400,38400,43400,49400,56400,63900}

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)

	if IsInToolsMode() then
		XP_PER_LEVEL_TABLE = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 30 )
	else
		GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 30 )
	end

	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)

	if GameRules:IsCheatMode() then
    	HeroDemo:Init()
	end

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
	self.winter_mode = false

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

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

	self.m_GatheredShuffledTeams = {}
	self.numSpawnCamps = 5
	self.specialItem = ""
	self.spawnTime = 90
	self.nNextSpawnItemNumber = 1
	self.hasWarnedSpawn = false
	self.allSpawned = false
	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.countdownEnabled = false
	self.itemSpawnIndex = 1
	self.itemSpawnLocation = Entities:FindByName( nil, "greevil" )
	self.tier1ItemBucket = {}
	self.tier2ItemBucket = {}
	self.tier3ItemBucket = {}
	self.tier4ItemBucket = {}
	self.CLOSE_TO_VICTORY_THRESHOLD = 5
	self:GatherAndRegisterValidTeams()

	GameRules:GetGameModeEntity().BirzhaGameMode = self

	if GetMapName() == "birzhamemov_5v5v5" then
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 10
		self.effectradius = 1400
	elseif GetMapName() == "birzhamemov_5v5" then
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 10
		self.effectradius = 1400
	elseif GetMapName() == "birzhamemov_zxc" then
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 10
		self.effectradius = 1400
	else
		self.m_GoldRadiusMin = 100
		self.m_GoldRadiusMax = 550
		self.m_GoldDropPercent = 10
		self.effectradius = 900
	end

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

	self.end_game_started = nil

	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( BirzhaGameMode, "ExecuteOrderFilter" ), self )
	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( BirzhaGameMode, "DamageFilter" ), self )
	GameRules:GetGameModeEntity():SetHealingFilter( Dynamic_Wrap(BirzhaGameMode, "HealingFilter"), self )
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1300)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
	GameRules:GetGameModeEntity():SetPauseEnabled( false )
	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 20 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetFilterMoreGold( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetHideKillMessageHeaders( true )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_DOUBLEDAMAGE , true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_HASTE, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ILLUSION, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_INVISIBILITY, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, false )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ARCANE, true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, false )
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0 )
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled(false)
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(self, "ModifyGoldFilter"), self)

    GameRules:SetPostGameLayout( DOTA_POST_GAME_LAYOUT_DOUBLE_COLUMN )
	GameRules:SetPostGameColumns( {
		DOTA_POST_GAME_COLUMN_LEVEL,
		DOTA_POST_GAME_COLUMN_KILLS,
		DOTA_POST_GAME_COLUMN_DEATHS,
		DOTA_POST_GAME_COLUMN_ASSISTS,
        DOTA_POST_GAME_COLUMN_DAMAGE,
        DOTA_POST_GAME_COLUMN_HEALING,
	} )

	SendToServerConsole("dota_max_physical_items_purchase_limit 9999")

	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( self, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( self, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( self, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( self, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( self, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( self, "OnNpcGoalReached" ), self )
	ListenToGameEvent( "player_chat", Dynamic_Wrap(ChatListener, 'OnPlayerChat'), ChatListener)

    CustomGameEventManager:RegisterListener( "birzha_contract_target_selected", Dynamic_Wrap(BirzhaData, "birzha_contract_target_selected"))
    CustomGameEventManager:RegisterListener( "birzha_update_check_birzha_plus", Dynamic_Wrap(BirzhaData, "birzha_update_check_birzha_plus"))
	CustomGameEventManager:RegisterListener( "win_condition_predict", Dynamic_Wrap(BirzhaData, "win_condition_predict"))
	CustomGameEventManager:RegisterListener( "change_premium_pet", Dynamic_Wrap(donate_shop, "ChangePetPremium"))
	CustomGameEventManager:RegisterListener( "change_border_effect", Dynamic_Wrap(donate_shop, "change_border_effect"))
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

    local fix_pos_timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "Fix_position" })
    fix_pos_timer:SetThink( FixPosition, FrameTime() )

	--local update_battlepass = SpawnEntityFromTableSynchronous("info_target", { targetname = "update_battlepass" })
    --update_battlepass:SetThink( UpdBattlePass, 5 )

	ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'OnConnectFull'), self)
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

	BirzhaData:RegisterSeasonInfo()  
end

function BirzhaGameMode:ModifyGoldFilter(params)
	return true
end

function UpdBattlePass()
	donate_shop:UpdateBattlePassInfo()
	return 5
end

function FixPosition()
	local check_modifiers = 
	{
		"modifier_girl_charge_of_attack",
		"modifier_aang_vacuum",
		"modifier_aang_lunge",
		"modifier_Akame_slice",
		"modifier_agility_toss",
		"modifier_dio_kakyoin_debuff",
		"modifier_dwayne_stone_strength_arc_lua",
		"modifier_dwayne_stone_strength",
		"modifier_goku_dragon_punch",
		"modifier_klichko_charge_of_darkness",
		"modifier_Kudes_GoldHook_debuff",
		"modifier_migi_inside",
		"modifier_mum_meat_hook_debuff",
		"modifier_Panasenkov_catch_caster",
		"modifier_rem_morgenshtern",
		"modifier_stray_rat",
		"modifier_Vernon_power_cogs_cog_push",
		"modifier_Vernon_power_cogs_cog_push_in",
		"modifier_python_active",
		"modifier_Yakubovich_GiftsInTheStudio_vacuum",
		"modifier_zema_cosmic_blindness_debuff",
		"modifier_rat_burrow_destroy",
		"modifier_rat_burrow_cast",
		"modifier_kakashi_lightning",
		"modifier_kakashi_raikiri",
		"modifier_dio_roller",
		"modifier_dio_roller_caster",
		"modifier_Pocik_penek_passive_aura",
		"modifier_illidan_KidsHit_scepter",
		"modifier_olyasha_love",
		"modifier_JohnCena_Chargehit",
		"modifier_sonic_dash",
		"modifier_sonic_crash_generic_arc_lua",
		"modifier_sonic_gottagofast",
		"modifier_kaneki_pull_debuff",
		"modifier_venom_tentacle",
	}

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
	leaderbirzha = sortedTeams[1].teamID
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
		local maxPlayers = 0
		
		CustomNetTables:SetTableValue("game_state", tostring(team), {kills = 0})

		if ( nil ~= TableFindKey( foundTeamsList, team ) ) then
			maxPlayers = maxPlayersPerValidTeam
		end

		GameRules:SetCustomGameTeamMaxPlayers( team, maxPlayers )
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