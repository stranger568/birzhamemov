LinkLuaModifier( "modifier_birzha_map_center_vision", "modifiers/modifier_birzha_map_center_vision.lua", LUA_MODIFIER_MOTION_NONE )

function BirzhaGameMode:ThinkGoldDrop()
	if RollPercentage(self.m_GoldDropPercent) then
		self:SpawnGoldEntity( Vector( 0, 0, 0 ) )
	end
end

function BirzhaGameMode:SpawnGoldEntity( spawnPoint )
	EmitGlobalSound("Item.PickUpGemWorld")
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	local dropRadius = RandomFloat( self.m_GoldRadiusMin, self.m_GoldRadiusMax )
	newItem:LaunchLootInitialHeight( false, 0, 500, 0.75, spawnPoint + RandomVector( dropRadius ) )
	newItem:SetContextThink( "KillLoot", function() return self:KillLoot( newItem, drop ) end, 20 )
end

function BirzhaGameMode:KillLoot( item, drop )

	if drop:IsNull() then
		return
	end

	if GameRules:IsGamePaused() == true then
        return 1
    end
	
	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	EmitGlobalSound("Item.PickUpWorld")

	UTIL_Remove( item )
	UTIL_Remove( drop )
end

function BirzhaGameMode:ThinkItemCheck()
	local t = nCOUNTDOWNTIMER
	local tSpawn = ( self.spawnTime * self.nNextSpawnItemNumber )
	local tWarn = tSpawn - 10
	
	ItemTimer(tSpawn - t)

	if not self.hasWarnedSpawn and t >= tWarn then
		self:WarnItem()
		self.hasWarnedSpawn = true
	elseif t >= tSpawn then
		self:SpawnItem()
		self.nNextSpawnItemNumber = self.nNextSpawnItemNumber + 1
		self.hasWarnedSpawn = false
	end
end

function BirzhaGameMode:WarnItem()
	local spawnLocation = Vector(0,0,0)
	CustomGameEventManager:Send_ServerToAllClients( "item_will_spawn", { spawn_location = spawnLocation } )
	EmitGlobalSound( "powerup_03" )

	CreateModifierThinker( nil, nil, "modifier_birzha_map_center_vision", { duration = 12, radius = self.effectradius }, spawnLocation, DOTA_TEAM_NEUTRALS, false )

	local effect_spawn = ParticleManager:CreateParticle( "particles/particle_spawn_item_birzha.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( effect_spawn, 0, GetGroundPosition(Vector(0, 0, 0), nil) )
	ParticleManager:SetParticleControl( effect_spawn, 1, GetGroundPosition(Vector(0, 0, 0), nil) )

	Timers:CreateTimer(10, function()
		ParticleManager:DestroyParticle(effect_spawn, false)
    	ParticleManager:ReleaseParticleIndex( effect_spawn )
	end)
end

function BirzhaGameMode:SpawnItem()
	local newItem = CreateItem( "item_treasure_chest", nil, nil )
	local drop = CreateItemOnPositionForLaunch( Vector(0,0,800), newItem )
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, Vector(0,0,800) )

	Timers:CreateTimer(0.25, function()
		CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
		EmitGlobalSound( "Hero_Earthshaker.Arcana.GlobalLayer1" )
		local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, Vector(0,0,100) )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 200, 200, 200 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		local targets = FindUnitsInRadius(DOTA_TEAM_NOTEAM,Vector(0,0,100),nil,300,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE ,FIND_ANY_ORDER,false)
		for _,unit in pairs(targets) do
			local distance = (unit:GetAbsOrigin() - Vector(0,0,100)):Length2D()
			local direction = (unit:GetAbsOrigin() - Vector(0,0,100)):Normalized()
			local bump_point = Vector(0,0,100) - direction * (distance + 250)
			local knockbackProperties =
			{
				center_x = bump_point.x,
				center_y = bump_point.y,
				center_z = bump_point.z,
				duration = 0.2,
				knockback_duration = 0.2,
				knockback_distance = 600,
				knockback_height = 100
			}
			unit:AddNewModifier( unit, nil, "modifier_knockback", knockbackProperties )
		end
	end)
end

function BirzhaGameMode:SpecialItemAdd( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
	end
	local hero = owner:GetUnitName()
	local ownerTeam = owner:GetTeamNumber()
	local game_score_max = CustomNetTables:GetTableValue("game_state", "scores_to_win").kills

	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(team))
		if table_team_score then
			table.insert( sortedTeams, { teamID = team, teamScore = table_team_score.kills } )
		end
	end

	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
	local n = TableCount( sortedTeams )
	local leader = sortedTeams[1].teamID
	local lastPlace = sortedTeams[n].teamID

	local tier1 = 
	{
		"item_vape",
		"item_oblivion_staff",
		"item_phase_boots",
		"item_wraith_band",
		"item_null_talisman",
		"item_bracer",
		"item_ring_of_aquila",
		"item_arcane_boots",
		"item_hood_of_defiance",
		"item_mekansm",
		"item_lifesteal",
		"item_veil_of_discord",
		"item_helm_of_iron_will",
		"item_vitality_booster",
		"item_talisman_of_evasion",
		"item_quarterstaff",
		"item_platemail",
		"item_blade_of_alacrity",
		"item_podorozhnik",
		"item_baldezh",
		"item_power_treads",
		"item_javelin",
		"item_blitz_knuckles",
		"item_blight_stone",
		"item_ogre_axe",
		"item_staff_of_wizardry",
		"item_broadsword",
		"item_claymore",

	}
	local tier2 = 
	{
		"item_burger_sobolev",
		"item_burger_oblomoff",
		"item_burger_larin",
		"item_hookah",
		"item_nimbus_lapteva",
		"item_superbaldezh",
		"item_magic_crystalis",
		"item_scp500",
		"item_birzha_force_boots",
		"item_mem_cheburek",
		"item_birzha_holy_locket",
		"item_pers",
		"item_cyclone",
		"item_dagon",
		"item_rod_of_atos",
		"item_glimmer_cape",
		"item_lesser_crit",
		"item_armlet",
		"item_basher",
		"item_invis_sword",
		"item_vladmir",
		"item_helm_of_the_dominator",
		"item_birzha_blade_mail",
		"item_vanguard",
		"item_soul_booster",
		"item_maelstrom",
		"item_mystic_staff",
		"item_ultimate_orb",
		"item_hyperstone",
		"item_mem_sange",
		"item_mem_yasha",
		"item_reaver",
		"item_mana_booster",
		"item_echo_sabre",
		"item_chill_aquila",
	}
	local tier3 = 
	{
		"item_force_staff_2",
		"item_drum_of_speedrun",
		"item_aether_lupa",
		"item_dead_of_madness",
		"item_boots_of_invisibility",
		"item_memolator",
		"item_mem_sange_yasha",
		"item_orchid_custom",
		"item_bfury",
		"item_pipe",
		"item_manta",
		"item_crimson_guard",
		"item_lotus_orb",
		"item_diffusal_blade",
		"item_heavens_halberd",
		"item_nullifier",
		"item_moon_shard",
	}
	local tier4 = 
	{
		"item_ultimate_scepter",
		"item_ultimate_mem",
		"item_globus",
		"item_mystic_booster",
		"item_magic_daedalus",
		"item_radiance_2",
		"item_butter2",
		"item_brain_burner",
		"item_birzha_diffusal_blade_2",
		"item_refresher",
		"item_sheepstick",
		"item_silver_edge",
		"item_ethereal_blade_custom",
		"item_radiance",
		"item_monkey_king_bar",
		"item_greater_crit",
		"item_butterfly",
		"item_abyssal_blade",
		"item_heart",
		"item_bloodstone",
		"item_assault",
		"item_satanic",
		"item_skadi",
		"item_mjollnir",
	}

	if GetMapName() ~= "birzhamemov_5v5" then
		tier4 = 
		{
			"item_bristback",
			"item_crysdalus",
			"item_ultimate_scepter",
			"item_ultimate_mem",
			"item_globus",
			"item_mystic_booster",
			"item_magic_daedalus",
			"item_radiance_2",
			"item_butter2",
			"item_brain_burner",
			"item_birzha_diffusal_blade_2",
			"item_refresher",
			"item_sheepstick",
			"item_silver_edge",
			"item_ethereal_blade_custom",
			"item_radiance",
			"item_monkey_king_bar",
			"item_greater_crit",
			"item_butterfly",
			"item_abyssal_blade",
			"item_heart",
			"item_bloodstone",
			"item_assault",
			"item_satanic",
			"item_skadi",
			"item_mjollnir",
		}
	end


	local tiers_list_items = {}
	tiers_list_items[1] = PickRandomShuffle( tier1, self.tier1ItemBucket )
	tiers_list_items[2] = PickRandomShuffle( tier2, self.tier2ItemBucket )
	tiers_list_items[3] = PickRandomShuffle( tier3, self.tier3ItemBucket )
	tiers_list_items[4] = PickRandomShuffle( tier4, self.tier4ItemBucket )


	local spawnedItem = ""

	local current_tier = 1

	if nCOUNTDOWNTIMER > 1080 then
		current_tier = 4
	elseif nCOUNTDOWNTIMER > 720 then
		current_tier = 3
	elseif nCOUNTDOWNTIMER > 360 then
		current_tier = 2
	else
		current_tier = 1
	end

	if GetMapName() == "birzhamemov_solo" then
		if ownerTeam == leader then
			if current_tier > 1 then
				current_tier = current_tier - 1
			end
		end
		if ownerTeam == sortedTeams[n].teamID then
			if current_tier < 4 then
				current_tier = current_tier + 1
			end
		end
		if ownerTeam == sortedTeams[n-1].teamID then
			if current_tier < 4 then
				current_tier = current_tier + 1
			end
		end
	else
		if ownerTeam == leader then
			if current_tier > 1 then
				current_tier = current_tier - 1
			end
		end
		if ownerTeam == sortedTeams[n].teamID then
			if current_tier < 4 then
				current_tier = current_tier + 1
			end
		end
	end

	spawnedItem = tiers_list_items[current_tier]
	
	print(spawnedItem)
	local item_inventory = owner:AddItemByName( spawnedItem )
	if item_inventory then
		item_inventory:SetPurchaseTime(0)
	end

	EmitGlobalSound("powerup_04")

	local overthrow_item_drop =
	{
		hero_id = hero,
		dropped_item = spawnedItem
	}
	CustomGameEventManager:Send_ServerToAllClients( "overthrow_item_drop", overthrow_item_drop )
end