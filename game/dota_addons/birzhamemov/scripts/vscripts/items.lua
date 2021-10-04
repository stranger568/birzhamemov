LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

function BirzhaGameMode:ThinkGoldDrop()
	local r = RandomInt( 1, 100 )
	if r > ( 100 - self.m_GoldDropPercent ) then
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
		EmitGlobalSound( "powerup_05" )
		EmitGlobalSound( "Hero_Earthshaker.Arcana.GlobalLayer1" )
		local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, Vector(0,0,100) )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 200, 200, 200 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		local targets = FindUnitsInRadius(DOTA_TEAM_NOTEAM,Vector(0,0,100),nil,300,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)
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
			unit:AddNewModifier( unit, self, "modifier_knockback", knockbackProperties )
		end
	end)
end

function BirzhaGameMode:SpecialItemAdd( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	local hero = owner:GetUnitName()
	local ownerTeam = owner:GetTeamNumber()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		table.insert( sortedTeams, { teamID = team, teamScore = GetTeamHeroKills( team ) } )
	end

	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
	local n = TableCount( sortedTeams )
	local leader = sortedTeams[1].teamID
	local lastPlace = sortedTeams[n].teamID

	local tableindex = 0
	local tier1 = 
	{
		"item_ogre_axe",
		"item_blade_of_alacrity",
		"item_staff_of_wizardry",
		"item_quarterstaff",
		"item_helm_of_iron_will",
		"item_broadsword",
		"item_claymore",
		"item_javelin",
		"item_ring_of_tarrasque",
		"item_ring_of_regen",
		"item_ring_of_health",
		"item_void_stone",
		"item_lifesteal",
		"item_ghost",
		"item_soul_ring",
		"item_power_treads",
		"item_buckler",
		"item_urn_of_shadows",
		"item_tranquil_boots",
		"item_medallion_of_courage",
		"item_arcane_boots",
		"item_energy_booster",
		"item_soul_booster",
		"item_vitality_booster",
		"item_platemail",
		"item_talisman_of_evasion",
		"item_baldezh",
		"item_oblivion_staff",
		"item_phase_boots",
		"item_vape",
		"item_hand_of_midas",
		"item_mithril_hammer",
		"item_pers",
		"item_nuts",
		"item_hood_of_defiance",
		"item_mem_sange",
		"item_mem_yasha",
		"item_mithril_hammer",
		"item_roscom_midas",
		"item_podorozhnik"
	}
	local tier2 = 
	{
		"item_blink",
		"item_helm_of_the_dominator",
		"item_ancient_janggo",
		"item_mekansm",
		"item_vladmir",
		"item_spirit_vessel",
		"item_birzha_holy_locket",
		"item_glimmer_cape",
		"item_force_staff",
		"item_vanguard",
		"item_birzha_blade_mail",
		"item_dragon_lance",
		"item_echo_sabre",
		"item_maelstrom",
		"item_hyperstone",
		"item_ultimate_orb",
		"item_demon_edge",
		"item_mystic_staff",
		"item_boots_of_invisibility",
		"item_imba_phase_boots_2",
		"item_nimbus_lapteva",
		"item_burger_larin",
		"item_burger_oblomoff",
		"item_burger_sobolev",
		"item_overheal_trank",
		"item_veil_of_discord",
		"item_aether_lens",
		"item_dagon",
		"item_cyclone",
		"item_rod_of_atos",
		"item_kaya",
		"item_mem_cheburek",
		"item_lesser_crit",
		"item_armlet",
		"item_mana_booster",
		"item_force_staff_2"
	}
	local tier3 = 
	{
		"item_basher",
		"item_reaver",
		"item_birzha_force_boots",
		"item_pt_mem",
		"item_chill_aquila",
		"item_solar_crest",
		"item_moon_shard",
		"item_pipe",
		"item_orchid",
		"item_nullifier",
		"item_bfury",
		"item_monkey_king_bar",
		"item_soul_booster",
		"item_crimson_guard",
		"item_lotus_orb",
		"item_aeon_disk",
		"item_diffusal_blade",
		"item_heavens_halberd",
		"item_eagle",
		"item_memolator",
		"item_aether_lupa",
		"item_magic_crystalis"
	}
	local tier4 = 
	{
		"item_guardian_greaves",
		"item_refresher",
		"item_sheepstick",
		"item_octarine_core",
		"item_butterfly",
		"item_silver_edge",
		"item_radiance",
		"item_greater_crit",
		"item_rapier",
		"item_abyssal_blade",
		"item_bloodthorn",
		"item_sharoeb",
		"item_heart",
		"item_assault",
		"item_skadi",
		"item_mjollnir",
		"item_satanic",
		"item_mega_spinner",
		"item_mem_chebureksword",
		"item_frostmorn",
		"item_cuirass_3",
		"item_ultimate_mem",
		"item_tar2",
		"item_butter2",
		"item_cuirass_2",
		"item_uebator",
		"item_dagon_5",
		"item_ultimate_scepter",
		"item_ethereal_blade",
		"item_shivas_guard",
		"item_bloodstone",
		"item_manta",
		"item_hurricane_pike",
		"item_relic",
		"item_blink_boots",
		"item_angel_boots",
		"item_radiance_2",
		"item_stun_gun",
		"item_banner_crusader",
		"item_demon_paper",
		"item_mystic_booster",
		"item_brain_burner",
		"item_medkit",
		"item_magic_daedalus",
		"item_ghoul",
		"item_excalibur",
		"item_armor_damned"
	}

	if GetMapName() ~= "birzhamemov_5v5" then
		tier4 = 
		{
			"item_guardian_greaves",
			"item_refresher",
			"item_sheepstick",
			"item_octarine_core",
			"item_butterfly",
			"item_silver_edge",
			"item_radiance",
			"item_greater_crit",
			"item_rapier",
			"item_abyssal_blade",
			"item_bloodthorn",
			"item_sharoeb",
			"item_heart",
			"item_assault",
			"item_skadi",
			"item_mjollnir",
			"item_satanic",
			"item_mega_spinner",
			"item_mem_chebureksword",
			"item_frostmorn",
			"item_cuirass_3",
			"item_ultimate_mem",
			"item_tar2",
			"item_butter2",
			"item_cuirass_2",
			"item_uebator",
			"item_dagon_5",
			"item_ultimate_scepter",
			"item_ethereal_blade",
			"item_shivas_guard",
			"item_bloodstone",
			"item_manta",
			"item_hurricane_pike",
			"item_relic",
			"item_blink_boots",
			"item_angel_boots",
			"item_radiance_2",
			"item_stun_gun",
			"item_banner_crusader",
			"item_demon_paper",
			"item_bristback",
			"item_crysdalus"
		}
	end

	local t1 = PickRandomShuffle( tier1, self.tier1ItemBucket )
	local t2 = PickRandomShuffle( tier2, self.tier2ItemBucket )
	local t3 = PickRandomShuffle( tier3, self.tier3ItemBucket )
	local t4 = PickRandomShuffle( tier4, self.tier4ItemBucket )

	local spawnedItem = ""
	
	if GetMapName() == "birzhamemov_5v5" then
		if GetTeamHeroKills( leader ) < self.TEAM_KILLS_TO_WIN / 2 then
			if ( self.leadingTeamScore - self.runnerupTeamScore >= 10 ) then
				if ownerTeam == leader then
					spawnedItem = t1
				else
					spawnedItem = t3
				end
			elseif ( self.leadingTeamScore - self.runnerupTeamScore < 10 ) then
				spawnedItem = t2
			end
		elseif GetTeamHeroKills( leader ) >= self.TEAM_KILLS_TO_WIN / 2 then
			if ( self.leadingTeamScore - self.runnerupTeamScore >= 10 ) then
				if ownerTeam == leader then
					spawnedItem = t2
				else
					spawnedItem = t4
				end
			elseif ( self.leadingTeamScore - self.runnerupTeamScore < 10 ) then
				spawnedItem = t3
			end
		end
	else
		if GetTeamHeroKills( leader ) < self.TEAM_KILLS_TO_WIN / 2 then
			if ( self.leadingTeamScore - self.runnerupTeamScore >= 10 ) then
				if ownerTeam == leader then
					spawnedItem = t1
				elseif ownerTeam == lastPlace then
					spawnedItem = t3
				else
					spawnedItem = t2
				end
			elseif ( self.leadingTeamScore - self.runnerupTeamScore < 10 ) then
				spawnedItem = t2
			end
		elseif GetTeamHeroKills( leader ) >= self.TEAM_KILLS_TO_WIN / 2 then
			if ( self.leadingTeamScore - self.runnerupTeamScore >= 10 ) then
				if ownerTeam == leader then
					spawnedItem = t2
				elseif ownerTeam == lastPlace then
					spawnedItem = t4
				else
					spawnedItem = t3
				end
			elseif ( self.leadingTeamScore - self.runnerupTeamScore < 10 ) then
				spawnedItem = t3
			end
		end
	end
	
	owner:AddItemByName( spawnedItem )
	EmitGlobalSound("powerup_04")
	local overthrow_item_drop =
	{
		hero_id = hero,
		dropped_item = spawnedItem
	}
	CustomGameEventManager:Send_ServerToAllClients( "overthrow_item_drop", overthrow_item_drop )
end