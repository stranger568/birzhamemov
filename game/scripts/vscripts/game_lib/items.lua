function BirzhaGameMode:ThinkGoldDrop()
	if RollPercentage(self.m_GoldDropPercent) then
		self:SpawnGoldEntity( Vector( 0, 0, 0 ) )
	end
end

function BirzhaGameMode:SpawnGoldEntity( spawnPoint )
	EmitGlobalSound("Item.PickUpGemWorld")
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	local dropRadius = RandomFloat( self.m_GoldRadiusMin+200, self.m_GoldRadiusMax )
	newItem:LaunchLootInitialHeight( false, 0, 500, 0.75, spawnPoint + RandomVector( dropRadius ) )
	newItem:SetContextThink( "KillLoot", function() return self:KillLoot( newItem, drop ) end, 20 )
end

function BirzhaGameMode:KillLoot( item, drop )
	if drop:IsNull() then
		return
	end
	if GameRules:IsGamePaused() then
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
	local t = BIRZHA_GAME_ALL_TIMER
	local tSpawn = ( self.spawnTime * self.nNextSpawnItemNumber )
	local tWarn = tSpawn - 10
	GameTimerUpdater((tSpawn - t), "countdown")
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
	CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ItemWillSpawn", icon = "item"} )
	EmitGlobalSound( "powerup_03" )
	CreateModifierThinker( nil, nil, "modifier_birzha_map_center_vision", { duration = 12, radius = self.effectradius }, spawnLocation, DOTA_TEAM_NEUTRALS, false )
	local particle = "particles/particle_spawn_item_birzha.vpcf"
	if self.winter_mode then
		particle = "particles/particle_spawn_item_birzha_winter.vpcf"
	end
	local effect_spawn = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( effect_spawn, 0, GetGroundPosition(Vector(0, 0, 0), nil) )
	ParticleManager:SetParticleControl( effect_spawn, 1, GetGroundPosition(Vector(0, 0, 0), nil) )
	Timers:CreateTimer(10, function()
		ParticleManager:DestroyParticle(effect_spawn, false)
    	ParticleManager:ReleaseParticleIndex( effect_spawn )
	end)
end

LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

function BirzhaGameMode:SpawnItem()

	local item_name = "item_treasure_chest"
	local particle = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf"
	local spawnLocation = Vector(0,0,800)
	local visual = Vector(0,0,100)

	if self.winter_mode then
		visual = Vector(0,-300,100)
		spawnLocation = Vector(0,-300,0)
		particle = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf"
		item_name = "item_treasure_chest_winter"

		local dropRadius = RandomFloat( self.m_GoldRadiusMin+200, self.m_GoldRadiusMax )
		local end_pos = Vector(0,0,0) + RandomVector( dropRadius )

		local newItem = CreateItem( item_name, nil, nil )
		local drop = CreateItemOnPositionForLaunch( Vector(0,0,0), newItem )
		newItem:LaunchLootInitialHeight( false, 0, 350, 0.25, end_pos )

		Timers:CreateTimer(0.25, function()

			CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ItemHasSpawned", icon = "item2"} )

			EmitGlobalSound( "chest_dropped" )

			local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( effect_cast, 0, end_pos )
			ParticleManager:SetParticleControl( effect_cast, 1, Vector( 200, 200, 200 ) )
			ParticleManager:ReleaseParticleIndex( effect_cast )

			local targets = FindUnitsInRadius(DOTA_TEAM_NOTEAM, end_pos, nil, 300, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			
			for _,unit in pairs(targets) do
				local direction = unit:GetAbsOrigin() - end_pos
				direction.z = 0
				direction = direction:Normalized()
				local knockback = unit:AddNewModifier(
			        unit,
			        nil,	
			        "modifier_generic_knockback_lua",
			        {
			            direction_x = direction.x,
			            direction_y = direction.y,
			            distance = 400,
			            height = 100,	
			            duration = 0.2,
			            IsStun = true,
			        }
			    )
			    local callback = function( bInterrupted )
			    	unit:Stop()
			    	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			    end
			    knockback:SetEndCallback( callback )
			end
		end)
		
		return
	end

	local dropRadius = RandomFloat( self.m_GoldRadiusMin+200, self.m_GoldRadiusMax+200)
	local end_pos = Vector(0,0,0)

	local particle_l = ParticleManager:CreateParticle("particles/spawn_chect_knockback.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_l, 0, Vector(0,0,200))
    ParticleManager:SetParticleControl(particle_l, 60, Vector(255,140,0))
    ParticleManager:SetParticleControl(particle_l, 61, Vector(1,1,1))
    ParticleManager:ReleaseParticleIndex( particle_l )

	local targets = FindUnitsInRadius(DOTA_TEAM_NOTEAM, visual, nil, 300, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _,unit in pairs(targets) do
		local direction = unit:GetAbsOrigin() - visual
		direction.z = 0
		direction = direction:Normalized()
		local knockback = unit:AddNewModifier(
	        unit,
	        nil,	
	        "modifier_generic_knockback_lua",
	        {
	            direction_x = direction.x,
	            direction_y = direction.y,
	            distance = 400,
	            height = 100,	
	            duration = 0.25,
	            IsStun = true,
	        }
	    )
	    local callback = function( bInterrupted )
	    	unit:Stop()
	    	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	    end
	    knockback:SetEndCallback( callback )
	end

	local newItem = CreateItem( item_name, nil, nil )
	local drop = CreateItemOnPositionForLaunch( Vector(0,0,800), newItem )
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, Vector(0,0,800) )

	Timers:CreateTimer(0.25, function()

		CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ItemHasSpawned", icon = "item2"} )

		EmitGlobalSound( "chest_dropped" )

		local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, Vector(0,0,100) )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 200, 200, 200 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
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

	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	local n = TableCount( sortedTeams )
	local leader = sortedTeams[1].teamID
	local lastPlace = sortedTeams[n].teamID

	local tier1 = 
	{
		"item_staff_of_wizardry",
		"item_ogre_axe",
		"item_blade_of_alacrity",
		"item_diadem",
		"item_hand_of_midas_custom",
		"item_vitality_booster",
		"item_helm_of_iron_will",
		"item_broadsword",
		"item_lifesteal",
		"item_ring_of_aquila",
		"item_blitz_knuckles",
		"item_javelin",
	}
	local tier2 = 
	{
		"item_echo_sabre",
		"item_lesser_crit",
		"item_burger_larin",
		"item_burger_sobolev",
		"item_burger_oblomoff",
		"item_hookah",
		"item_nimbus_lapteva",
		"item_armlet",
		"item_magic_crystalis",
		"item_birzha_holy_locket",
		"item_phylactery_custom",
		"item_birzha_blade_mail",
		"item_force_staff",
		"item_hyperstone",
		"item_demon_edge",
		"item_mana_booster",
		"item_vladmir",
		"item_aether_lens",
		"item_rod_of_atos",
	}
	local tier3 = 
	{
		"item_dagon_2",
		"item_radiance",
		"item_aether_lupa",
		"item_dead_of_madness",
		"item_bfury",
		"item_harpoon",
		"item_khanda_custom",
		"item_assault",
		"item_mem_sange_yasha",
		"item_shivas_guard",
		"item_heart",
		"item_ghoul",
		"item_greater_crit",	
		"item_revenants_brooch",
	}
	local tier4 = 
	{
		"item_wind_waker",
		"item_medkit",
		"item_cuirass_3",
		"item_ban_hammer",
		"item_mana_heart",
		"item_cuirass_2",
		"item_brain_burner",
		"item_globus",
		"item_birzha_diffusal_blade_2",
		"item_bloodthorn_custom",
	}

	local tiers_list_items = {}
	tiers_list_items[1] = PickRandomShuffle( tier1, self.tier1ItemBucket )
	tiers_list_items[2] = PickRandomShuffle( tier2, self.tier2ItemBucket )
	tiers_list_items[3] = PickRandomShuffle( tier3, self.tier3ItemBucket )
	tiers_list_items[4] = PickRandomShuffle( tier4, self.tier4ItemBucket )

	local spawnedItem = ""

	local current_tier = 1

	if BIRZHA_GAME_ALL_TIMER > 1080 then
		current_tier = 4
	elseif BIRZHA_GAME_ALL_TIMER > 720 then
		current_tier = 3
	elseif BIRZHA_GAME_ALL_TIMER > 360 then
		current_tier = 2
	else
		current_tier = 1
	end

	if BIRZHA_GAME_ALL_TIMER > 300 then
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
	end

	spawnedItem = tiers_list_items[current_tier]
	
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

	CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "__", icon = "item2", hero_id = hero,dropped_item = spawnedItem } )
end
