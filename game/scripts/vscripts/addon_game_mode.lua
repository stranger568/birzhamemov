if BirzhaGameMode == nil then
	_G.BirzhaGameMode = class({})
end

require( "functions/table" )
require('functions/vector_targeting')
require( 'util/birzha_events' )
require( 'events' )
require( 'items' )
require( 'filters' )
require( 'timers')
require( 'physics')
require( 'functions/functions' )
require( 'functions/Dota2RuNotifications' )
require( 'commands/custom_commands' )
require( 'addon_init' )
require( 'keyvalues' )
require( "debug_" )
require( "overlord/playertables" )
require( "overlord/worldpanels" )
require( "hero_demo/demo_core" )

---------------------------------------
-------------MMR-----------------------
---------------------------------------

require("util/mmr")
require("util/disconnect")
require('util/requests')
require('util/math')
require('report_system')

---------------------------------------
-------------BIRZHA PASS---------------
---------------------------------------

require('memespass/init')

require('donate_shop/donate_shop')

---------------------------------------
-------------BIRZHA PICK---------------
-------------------------------------- -

require('util/custom_selection')


function Precache( context )
  	local heroes = LoadKeyValues("scripts/npc/dota_heroes.txt")

  	for k,v in pairs(heroes) do
  		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context )  
  		PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context ) 
  	end

  	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts", context )  
  	PrecacheResource( "soundfile", "soundevents/game_sounds_creeps.vsndevts", context )  

  	local list = 
  	{
    	model = {"models/courier/baby_rosh/babyroshan.vmdl","models/courier/donkey_trio/mesh/donkey_trio.vmdl","models/courier/mechjaw/mechjaw.vmdl","models/courier/huntling/huntling.vmdl","models/items/courier/devourling/devourling.vmdl","models/courier/seekling/seekling.vmdl","models/courier/venoling/venoling.vmdl","models/items/courier/amaterasu/amaterasu.vmdl","models/items/courier/beaverknight_s2/beaverknight_s2.vmdl","models/items/courier/nian_courier/nian_courier.vmdl","models/items/courier/faceless_rex/faceless_rex.vmdl","models/pets/icewrack_wolf/icewrack_wolf.vmdl","models/heroes/storm_spirit/storm_spirit.vmdl","materials/models/heroes/slark/bracer.vmdl","materials/models/heroes/slark/cape.vmdl","materials/models/heroes/slark/hood.vmdl","materials/models/heroes/slark/shoulder.vmdl","materials/models/heroes/slark/weapon.vmdl","models/apple_horo.vmdl","models/ball.vmdl","models/bogdan_wrench.vmdl","models/card.vmdl","models/cup_kaneki.vmdl","models/hero_knuckles.vmdl","models/hookah.vmdl","models/knuckles_tank.vmdl","models/omniknight_zelensky_head.vmdl","models/troll_warlord_gorin_stool.vmdl","models/yakub_car.vmdl","models/baldezh/planet.vmdl","models/creeps/thief/thief_01.vmdl","models/creeps/knoll_1/knoll_1.vmdl","models/creeps/knoll_1/werewolf_boss.vmdl","models/hero_rem/hero_rem_base.vmdl","models/heroes/anime/berserk/berserk/berserk.vmdl","models/heroes/anime/berserk/guts/guts.vmdl","models/heroes/anime/ghoul/kaneki/kaneki_base/kaneki_base.vmdl","models/heroes/anime/ghoul/kaneki/kaneki_form/kaneki_form.vmdl","models/heroes/anime/konosuba/megumin/megumin.vmdl","models/heroes/anime/rwby/ruby/ruby_basic.vmdl","models/heroes/anime/rwby/ruby/ruby_skythe.vmdl","models/heroes/antimage/antimage.vmdl","models/heroes/brewmaster/brewmaster.vmdl","models/heroes/faceless_void/faceless_void.vmdl","models/heroes/goku/goku.vmdl","models/heroes/goku/goku_five.vmdl","models/heroes/goku/goku_four.vmdl","models/heroes/goku/goku_one.vmdl","models/heroes/goku/goku_two.vmdl","models/heroes/hisoka/hisoka.vmdl","models/heroes/horo/horo.vmdl","models/heroes/invoker/invoker.vmdl","models/heroes/life_stealer/life_stealer.vmdl","models/heroes/monika/monika.vmdl","models/heroes/pangolier/pangolier_gyroshell2.vmdl","models/heroes/polnaref/chariot.vmdl","models/heroes/polnaref/polnaref.vmdl","models/heroes/rin/rin.vmdl","models/heroes/scp_173/scp_173.vmdl","models/heroes/shiro/shiro.vmdl","models/heroes/siren/siren.vmdl","models/heroes/slark/bracer.vmdl","models/heroes/slark/cape.vmdl","models/heroes/slark/hood.vmdl","models/heroes/slark/shoulder.vmdl","models/heroes/slark/weapon.vmdl","models/heroes/the_world/the_world.vmdl","models/heroes/thomas/thomas.vmdl","models/heroes/weaver/weaver.vmdl","models/heroes/wraith_king/wraith_king.vmdl","models/insane/insane.vmdl","models/models/mega_spinner.vmdl","models/models/heroes/felix/felix.vmdl","models/models/heroes/overlord/clown.vmdl","models/models/heroes/overlord/guard.vmdl","models/models/heroes/overlord/minion.vmdl","models/models/heroes/overlord/guard_weapon.vmdl","models/models/heroes/overlord/overlord.vmdl","models/models/heroes/overlord/overlord_sword.vmdl","models/models/heroes/scp/scp_173.vmdl","models/npc/npc_dingus/dingus.vmdl","models/scp_682/scp_crock_reference.vmdl","models/items/courier/nexon_turtle_01_grey/nexon_turtle_01_grey.vmdl","models/items/courier/nexon_turtle_09_blue/nexon_turtle_09_blue.vmdl","models/items/courier/nexon_turtle_15_red/nexon_turtle_15_red.vmdl","models/heroes/gyro/gyro.vmdl","models/heroes/blood_seeker/blood_seeker.vmdl","models/haku/haku_mask.vmdl","models/kakashi_new/kakashi.vmdl","models/heroes/aang/aang.vmdl","models/haku/haku.vmdl","models/migi/migi.vmdl","models/heroes/anime/overlord/overlord2/overlord2.vmdl","models/kyriyama/girl_2.vmdl","models/heroes/anime/jojo/white_snake/pucci/pucci.vmdl","models/dead_rat/dead_rat.vmdl","models/pyramide/pyramide.vmdl",},
    	soundfile = {"soundevents/voscripts/game_sounds_vo_batrider.vsndevts","soundevents/voscripts/game_sounds_vo_void_spirit.vsndevts","soundevents/voscripts/game_sounds_vo_earth_spirit.vsndevts","soundevents/voscripts/game_sounds_vo_faceless_void.vsndevts","soundevents/game_sounds_creeps.vsndevts","soundevents/voscripts/game_sounds_vo_announcer_dlc_rick_and_morty.vsndevts","soundevents/soundevents_conquest.vsndevts","soundevents/voscripts/game_sounds_vo_terrorblade.vsndevts","soundevents/soundevents_minigames.vsndevts","soundevents/game_sounds_ui_imported.vsndevts"},
    	particle = {"particles/econ/events/nexon_hero_compendium_2014/teleport_end_nexon_hero_cp_2014.vpcf","particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", "particles/leader/leader_overhead.vpcf","particles/last_hit/last_hit.vpcf","particles/units/heroes/hero_zuus/zeus_taunt_coin.vpcf","particles/addons_gameplay/player_deferred_light.vpcf","particles/items_fx/black_king_bar_avatar.vpcf","particles/treasure_courier_death.vpcf","particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf","particles/econ/items/effigies/status_fx_effigies/gold_effigy_ambient_dire_lvl2.vpcf","particles/units/heroes/hero_kunkka/kunkka_ghost_ship_model.vpcf","particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf","particles/memolator3/memolator.vpcf","particles/generic_gameplay/generic_silenced.vpcf","particles/memolator2/desolator_projectile.vpcf","particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf","particles/items2_fx/veil_of_discord.vpcf",},
    	particle_folder = {}
  	}

  	for k,v in pairs(list) do
    	for z,x in pairs(v) do 
    		PrecacheResource(k, x, context)
    	end
  	end

	local mobs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	for k,v in pairs(mobs) do
	  	PrecacheUnitByNameSync(k, context)
	end

	local items = LoadKeyValues("scripts/npc/npc_items_custom.txt")
	for k,v in pairs(items) do
	  	PrecacheItemByNameSync(k, context)
	end

	PrecacheResource( "soundfile", "soundevents/birzha/game_sounds_birzha.vsndevts", context )  
end

function Activate()
	BirzhaGameMode:InitGameMode()
	BirzhaEvents:RegListeners()
	StartTimerLoading()
	SendToServerConsole("tv_delay 10")	
end

function BirzhaGameMode:InitGameMode()
	XP_PER_LEVEL_TABLE = {0,200,600,1080,1680,2300,3940,4600,5280,6080,6900,7740,8740,9865,11215,12490,13790,15115,16515,18005,19505,21255,23255,25505,28005,32005,37005,43005,50005}
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

	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( BirzhaGameMode, "BountyRunePickupFilter" ), self )
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
	GameRules:SetFilterMoreGold ( true )
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
	SendToServerConsole("dota_max_physical_items_purchase_limit 9999")


	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( self, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( self, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( self, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( self, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( self, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( self, "OnNpcGoalReached" ), self )
	ListenToGameEvent( "player_chat", Dynamic_Wrap(ChatListener, 'OnPlayerChat'), ChatListener)

	CustomGameEventManager:RegisterListener( "change_premium_pet", Dynamic_Wrap(donate_shop, "ChangePetPremium"))
	CustomGameEventManager:RegisterListener( "change_border_effect", Dynamic_Wrap(donate_shop, "change_border_effect"))
	CustomGameEventManager:RegisterListener( "donate_shop_buy_item", Dynamic_Wrap(donate_shop, "BuyItem"))
	CustomGameEventManager:RegisterListener( "donate_shop_bp_preorder", Dynamic_Wrap(donate_shop, "PreOrderBattlePass"))
	CustomGameEventManager:RegisterListener( "PlayerTip", Dynamic_Wrap(donate_shop, 'PlayerTip'))
	CustomGameEventManager:RegisterListener( "SelectSmile", Dynamic_Wrap(donate_shop, 'SelectSmile'))
	CustomGameEventManager:RegisterListener( "LotteryStart", Dynamic_Wrap(donate_shop, 'LotteryStart'))
	CustomGameEventManager:RegisterListener( "SelectVO", Dynamic_Wrap(donate_shop,'SelectVO'))
	CustomGameEventManager:RegisterListener( "select_chatwheel_player", Dynamic_Wrap(donate_shop,'SelectChatWheel'))
	CustomGameEventManager:RegisterListener( "report_player", Dynamic_Wrap(report_system,'ReportPlayer'))
	CustomGameEventManager:RegisterListener( "SpawnHeroDemo", Dynamic_Wrap(HeroDemo,'SpawnHeroDemo'))

    local fix_pos_timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "Fix_position" })
    fix_pos_timer:SetThink( FixPosition, FrameTime() )

	ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'OnConnectFull'), self)
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )   
end

function BirzhaGameMode:ModifyGoldFilter(params)
	local player_id = params.player_id_const
	local Player = PlayerResource:GetPlayer(player_id)
	if Player then
		local hero = PlayerResource:GetSelectedHeroEntity(player_id)  
		local ability_modifier_shelby = hero:FindAbilityByName("special_bonus_birzha_shelby_4")
		if ability_modifier_shelby and ability_modifier_shelby:GetLevel() > 0 and hero:IsRealHero() then
			if params.reason_const ~= DOTA_ModifyGold_SellItem and params.gold > 0 then
				params.gold = params.gold * (1 + (ability_modifier_shelby:GetSpecialValueFor("value") / 100))
			end
		end
	end
	return true
end

function FixPosition()
	local check_modifiers = {
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
    if CustomPick.pick_ended then
		if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then		
			
			if not GameRules:IsCheatMode() then
				if GameEndTimer <= 0 then
					BirzhaGameMode:EndGame( leaderbirzha )
					GameRules:SetGameWinner( leaderbirzha )
				end
			end
			
			BirzhaGameMode:ThinkGoldDrop()
			BirzhaGameMode:ThinkItemCheck()
			CountdownTimer()

			if self.ContractTimer <= 0 then
				self.ContractTimer = 180
				self:SpawnContracts()
			else
				self.ContractTimer = self.ContractTimer - 1
				if self.ContractTimer - 5 == 0 then
					CustomGameEventManager:Send_ServerToAllClients("contract_event_will", {} )
				end
				CountdownContractTimer(self.ContractTimer)
			end

			if FountainTimer > 0 then
				CountdownFountainTimer()
			else
				CountdownEndGameTimer()
			end	
		end
	end
	return 1
end

function BirzhaGameMode:OnConnectFull(data)
	local player_index = EntIndexToHScript( data.index )
	if player_index == nil then
		return
	end
	CustomPick:RegisterPlayerInfo(data.PlayerID)
	BirzhaData:RegisterPlayerSiteInfo(data.PlayerID)
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

function BirzhaGameMode:SpawnContracts()
	CustomGameEventManager:Send_ServerToAllClients("contract_event_spawn", {} )
	local spawn_points = {
		["birzhamemov_solo"] =
		{
			Vector(-677.264, 1473.03, 256),
			Vector(698.379, 1473.03, 256),
			Vector(1527.58, 707.842, 256),
			Vector(1534.7, -679.804, 256),
			Vector(690.966, -1498.83, 256),
			Vector(-640.588, -1470.73, 256),
			Vector(-1464.22, -687.853, 256),
			Vector(-1489.97, 657.538, 256),
		},

		["birzhamemov_wtf"] =
		{
			Vector(-558.305, -1536, 257),
			Vector(768, -1536, 257),
			Vector(1380.82, -636.846, 257),
			Vector(1380.82, 689.458, 257),
			Vector(768, 1415.6, 257),
			Vector(-558.305, 1415.6, 257),
			Vector(-1570.78, 768, 257),
			Vector(-1570.78, -704, 257),
		},

		["birzhamemov_duo"] =
		{
			Vector(2112, -2112, 128),
			Vector(-2112, -2112, 128),
			Vector(-2112, 2112, 128),
			Vector(2112, 2112, 128),
		},

		["birzhamemov_trio"] =
		{
			Vector(2112, -2112, 128),
			Vector(-2112, -2112, 128),
			Vector(-2112, 2112, 128),
			Vector(2112, 2112, 128),
		},

		["birzhamemov_5v5"] =
		{
			Vector(-643.798, 2946.5, 16),
			Vector(687.784, 2884.86, 16),
			Vector(-655.003, -2836.04, 16),
			Vector(706.284, -2866.63, 16),
		},

		["birzhamemov_zxc"] =
		{
			Vector(-643.798, 2946.5, 16),
			Vector(687.784, 2884.86, 16),
			Vector(-655.003, -2836.04, 16),
			Vector(706.284, -2866.63, 16),
		},


		["birzhamemov_5v5v5"] =
		{
			Vector(621.752, -2791.01, 128),
			Vector(-646.064, -2688.01, 128),
			Vector(1925.06, 1770.08, 128),
			Vector(2399.43, 475.853, 128),
			Vector(-1957.1, 1920.64, 128),
			Vector(-2289.82, 621.959, 128),
		},
	}

	for i=1, 2 do
		local item_contract = CreateItem( "item_birzha_contract", nil, nil )
		local origin = table.remove(spawn_points[GetMapName()], RandomInt(1, #spawn_points[GetMapName()]))
		local drop = CreateItemOnPositionForLaunch( origin, item_contract )
		item_contract:LaunchLootInitialHeight( false, 0, 50, 0.15, origin )
		item_contract:SetContextThink( "KillLoot", function() return self:KillLoot( item_contract, drop ) end, 180 )
		Timers:CreateTimer(1*i, function()
			for team = 2, 13 do
				GameRules:ExecuteTeamPing( team, origin.x, origin.y, nil, 0 )
			end
		end)
	end
end