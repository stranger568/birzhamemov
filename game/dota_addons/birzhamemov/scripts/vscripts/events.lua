LinkLuaModifier( "modifier_birzha_disconnect", "modifiers/modifier_birzha_disconnect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_donater", "modifiers/modifier_birzha_pet", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_illusion_cosmetics", "modifiers/modifier_birzha_dota_modifiers", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_never_reward", "modifiers/birzhapass_modifiers/modifier_bp_never_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_valakas_reward", "modifiers/birzhapass_modifiers/modifier_bp_valakas_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_druzhko_reward", "modifiers/birzhapass_modifiers/modifier_bp_druzhko_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_effects_reward", "modifiers/birzhapass_modifiers/modifier_bp_effects_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzhapass_sound", "memespass/soundkill", LUA_MODIFIER_MOTION_NONE )


function BirzhaGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()

	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		if IsInToolsMode() then
			GameRules:SetCustomGameSetupAutoLaunchDelay(1)
		else
			GameRules:SetCustomGameSetupAutoLaunchDelay(10)
		end
		GameRules:EnableCustomGameSetupAutoLaunch( true )
	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		if GetMapName() == "birzhamemov_solo" then
			self.TEAM_KILLS_TO_WIN = 50
		elseif GetMapName() == "birzhamemov_duo" then
			self.TEAM_KILLS_TO_WIN = 60
		elseif GetMapName() == "birzhamemov_trio" then
			self.TEAM_KILLS_TO_WIN = 80
		elseif GetMapName() == "birzhamemov_5v5v5" then
			self.TEAM_KILLS_TO_WIN = 150
		elseif GetMapName() == "birzhamemov_5v5" then
			self.TEAM_KILLS_TO_WIN = 100
		elseif GetMapName() == "birzhamemov_zxc" then
			self.TEAM_KILLS_TO_WIN = 2
		elseif GetMapName() == "birzhamemov_samepick" then
			self.TEAM_KILLS_TO_WIN = 100
		end

		FountainTimer = 900
		EventTimer = 900
		GameEndTimer = 300
		nCOUNTDOWNTIMER = 0
		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
		BirzhaGameMode:SpawnDonaters()
		CustomPick:Init()
	end
end

function BirzhaGameMode:OnNPCSpawned( event )
	local player = EntIndexToHScript(event.entindex)

	if player:GetUnitName() == "npc_palnoref_chariot" then
		player.chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
		player.chariot_sword:FollowEntity(player, true)
	end

	if player:GetUnitName() == "npc_palnoref_chariot_illusion" then
		local illusion_chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
		illusion_chariot_sword:FollowEntity(player, true)
		illusion_chariot_sword:SetRenderColor(0, 0, 0)
	end

	if player:GetUnitName() == "npc_palnoref_chariot_illusion_2" then
		local illusion_chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
		illusion_chariot_sword:FollowEntity(player, true)
		illusion_chariot_sword:SetRenderColor(0, 0, 0)
	end

	--if player:GetUnitName() == "npc_overlord_big_prihvost_portal" then
	--	local phihvost_axe = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/models/heroes/overlord/guard_weapon.vmdl"})
	--	phihvost_axe:FollowEntity(player, true)
	--end

	if player:IsRealHero() then
		local playerID = player:GetPlayerID()
		local playerSteamID = PlayerResource:GetSteamAccountID(playerID)

		if player:GetUnitName() == "npc_dota_hero_treant" then
			if player.BirzhaFirstSpawned then
	   			player:EmitSound("OverlordRein")
	   		end
	   	end

	   	if player:GetUnitName() == "npc_dota_hero_sasake" then
			if player.BirzhaFirstSpawned then
				if RollPercentage(50) then
	   				player:EmitSound("sasake_respawn")
	   			end
	   		end
	   	end

		if FountainTimer <= 0 then
			if not player:IsReincarnating() then
				if not player:IsIllusion() then
					player:AddInvul(3)
				end
			end
		end

		if IsPlayerDisconnected(playerID) then
	        player:AddNewModifier(player, nil, "modifier_birzha_disconnect", {})
		end

	   	if player.BirzhaFirstSpawned == nil then
	   		if player:GetUnitName() == "npc_dota_hero_wisp" then
				local start_stun = player:FindAbilityByName("game_start")
			   	if player:IsRealHero() then
			      	if start_stun then
			        	start_stun:SetLevel(1)
			      	end
			    end
	   			return
	   		end
	   		player.BirzhaFirstSpawned = true
	   		if player:GetUnitName() == "npc_dota_hero_treant" then
	   			player:EmitSound("OverlordSpawn")
	   		end
	   		BirzhaGameMode:AddedDonateStart(player, playerID)
			if player:IsHero() then
				BirzhaGameMode:AbilitiesStart(player)
			end
		end	
	end

	if player:IsHero() and player.AddedCustomModels == nil then
		player.AddedCustomModels = true
		BirzhaGameMode:OnHeroInGame(player)
	end
end

function BirzhaGameMode:OnTeamKillCredit( event )
	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		table.insert( sortedTeams, { teamID = team, teamScore = GetTeamHeroKills( team ) } )
	end
	local n = TableCount( sortedTeams )
	local lastPlace = sortedTeams[n].teamID
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

	if nKillsRemaining <= 0 then	
		BirzhaGameMode:EndGame( nTeamID )
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "onefrag" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining == 2 then
		EmitGlobalSound( "twofrag" )
	elseif nKillsRemaining == 3 then
		EmitGlobalSound( "threefrag" )
	end

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

function BirzhaGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()
	local extraTime = 0
	local game_time = nCOUNTDOWNTIMER / 60

	if not killedUnit:IsRealHero() and killedUnit:IsOther() then
		local mod = hero:FindModifierByName("modifier_item_birzha_ward")
		if mod then
			if killedUnit:GetUnitName() == "npc_dota_observer_wards" then
				hero:ModifyGold( 50, true, 0 )
			elseif killedUnit:GetUnitName() == "npc_dota_sentry_wards" then
				hero:ModifyGold( 25, true, 0 )
			end 
		end
	end

	if killedUnit:IsRealHero() then
		self.allSpawned = true
		if heroTeam ~= killedTeam then
			if FountainTimer <= 0 then
				GameEndTimer = 300
			end
		end
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			if killedUnit:GetUnitName() == "npc_dota_hero_treant" then
		   		killedUnit:EmitSound("OverlordDeath")
		   	elseif hero:GetUnitName() == "npc_dota_hero_treant" then
		   		hero:EmitSound("OverlordKill")
		   	end
		   	if killedUnit:GetUnitName() == "npc_dota_hero_sasake" then
		   		if RollPercentage(50) then
		   			killedUnit:EmitSound("sasake_death")
		   		end
		   	elseif hero:GetUnitName() == "npc_dota_hero_sasake" then
		   		if RollPercentage(50) then
		   			hero:EmitSound("sasake_kill")
		   		end
		   	end
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false and game_time >= 5 then
				local memberID = hero:GetPlayerID()
				local gold = 250 + (250 * game_time / 10)
				local exp = 500 * game_time / 5
				PlayerResource:ModifyGold( memberID, gold, true, 0 )
				hero:AddExperience( exp, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
				{
					hero_id = hero:GetClassname()
				}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				hero:AddExperience( 100, 0, false, false )
			end
		end
		local modifier_passive = hero:FindModifierByName("modifier_Overlord_passive")
        if modifier_passive then
            modifier_passive:SetStackCount(modifier_passive:GetStackCount()+5)
        end
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker:GetPlayerOwnerID() == killedUnit:GetAttacker( i ) then
					attacker:AddExperience( 50, 0, false, false )
					if attacker ~= hero then
						local modifier_passive = attacker:FindModifierByName("modifier_Overlord_passive")
			            if modifier_passive then
			                modifier_passive:SetStackCount(modifier_passive:GetStackCount()+2)
			            end
						local mod = attacker:FindModifierByName("modifier_item_birzha_ward")
						if mod then
							mod:GetAbility().assists = mod:GetAbility().assists + 1
							if mod:GetAbility().assists >= 30 then
								attacker:ModifyGold( 100, true, 0 )
								mod:SetStackCount(3)
								mod:GetAbility().level = 3
							elseif mod:GetAbility().assists >= 15 then
								attacker:ModifyGold( 75, true, 0 )
								mod:SetStackCount(2)
								mod:GetAbility().level = 2
							elseif mod:GetAbility().assists < 15 then
								attacker:ModifyGold( 50, true, 0 )
							end
						end
					end
				end
			end
		end
		if killedUnit:GetRespawnTime() > 10 then
			if killedUnit:IsReincarnating() == true then
				return nil
			else
				BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
			end
		else
			BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
		end
	end
end

function BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )	
	if killedTeam == self.leadingTeam and self.isGameTied == false then
		if nCOUNTDOWNTIMER <= 299 then
			killedUnit:SetTimeUntilRespawn( 15 + extraTime )
		else
			killedUnit:SetTimeUntilRespawn( 20 + extraTime )
		end
	else 
		killedUnit:SetTimeUntilRespawn( 10 + extraTime )
	end
end

function BirzhaGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
	end
	if event.itemname == "item_bag_of_gold" then
		PlayerResource:ModifyGold( owner:GetPlayerID(), 300, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, 300, nil )
		UTIL_Remove( item )
	end
	if event.itemname == "item_bag_of_gold_van" then
		local gold = 0
		for _,hero in pairs (HeroList:GetAllHeroes()) do
			if hero:FindAbilityByName("van_takeitboy") then
				local abilka = hero:FindAbilityByName("van_takeitboy")
				gold = abilka:GetSpecialValueFor("gold")
				break
			end
		end
		PlayerResource:ModifyGold( owner:GetPlayerID(), gold, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, gold, nil )
		UTIL_Remove( item )
	end
	if event.itemname == "item_bag_of_gold_bp_fake" then
		UTIL_Remove( item )
	end
	if event.itemname == "item_treasure_chest" then
		BirzhaGameMode:SpecialItemAdd( event )
		UTIL_Remove( item )
	end
	if item.origin then
        item.origin.is_spawned = nil
		UTIL_Remove(item)
    end   
end

function BirzhaGameMode:SpawnDonaters()
    for i = 1, 6 do
        local donater = CreateUnitByName( "donater_top" ..i , Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        donater:AddNewModifier( donater, nil, "modifier_birzha_donater", {} )
    end
    local creator_1 = CreateUnitByName( "sozdatel_StrangeR", Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
    local creator_2 = CreateUnitByName( "sozdatel_UblueWolf", Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
    local creator_3 = CreateUnitByName( "sozdatel_rolla", Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
	creator_1:AddNewModifier( creator_1, nil, "modifier_birzha_donater", {} )
	creator_2:AddNewModifier( creator_2, nil, "modifier_birzha_donater", {} )
	creator_3:AddNewModifier( creator_3, nil, "modifier_birzha_donater", {} )
end

function BirzhaGameMode:OnHeroInGame(hero)
	local playerID = hero:GetPlayerID()
	local npcName = hero:GetUnitName()

	if hero:IsIllusion() then
		hero:AddNewModifier( hero, nil, "modifier_birzha_illusion_cosmetics", {} )
	end

	if hero:GetUnitName() == "npc_dota_hero_nevermore" then
		if IsUnlockedInPass(playerID, "reward47") then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" and child:GetModelName() ~= "models/heroes/shadow_fiend/shadow_fiend_head.vmdl" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/heroes/shadow_fiend/shadow_fiend_arcana.vmdl")
			hero.NevermoreWings = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/shadow_fiend/arcana_wings.vmdl"})
			hero.NevermoreWings:FollowEntity(hero, true)
			hero.NevermorePauldrons = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/nevermore/ferrum_chiroptera_shoulder/ferrum_chiroptera_shoulder.vmdl"})
			hero.NevermorePauldrons:FollowEntity(hero, true)
			hero.NevermoreHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/shadow_fiend/head_arcana.vmdl"})
			hero.NevermoreHead:FollowEntity(hero, true)
			hero.NevermoreArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/shadow_fiend/arms_deso/arms_deso.vmdl"})
			hero.NevermoreArms:FollowEntity(hero, true)
			hero.NevermoreRocks = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/shadow_fiend/fx_rocks.vmdl"})
			hero.NevermoreRocks:FollowEntity(hero, true)
			
			hero:AddNewModifier( hero, nil, "modifier_bp_never_reward", {})
		end
	end

	if npcName == "npc_dota_hero_earthshaker" then
		if IsUnlockedInPass(playerID, "reward65") then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/items/earthshaker/earthshaker_arcana/earthshaker_arcana.vmdl")
			hero.ValakasHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/earthshaker_arcana/earthshaker_arcana_head.vmdl"})
			hero.ValakasHead:FollowEntity(hero, true)
			hero.ValakasWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/ti9_immortal/ti9_immortal.vmdl"})
			hero.ValakasWeapon:FollowEntity(hero, true)
			hero.ValakasHands = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/frostivus2018_es_frozen_wastes_arms/frostivus2018_es_frozen_wastes_arms.vmdl"})
			hero.ValakasHands:FollowEntity(hero, true)
			hero.HeadSAaker = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.ValakasHead)
			hero.WeaponShaker = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_ti9/earthshaker_ti9_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.ValakasWeapon)
			hero:AddNewModifier( hero, nil, "modifier_bp_valakas_reward", {})
		end
	end

	if npcName == "npc_dota_hero_sasake" then
		hero.JuggHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/arcana/juggernaut_arcana_mask.vmdl"})
		hero.JuggHead:FollowEntity(hero, true)
		hero.JugLegs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/armor_for_the_favorite_legs/armor_for_the_favorite_legs.vmdl"})
		hero.JugLegs:FollowEntity(hero, true)
		hero.JugSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/jugg_ti8/jugg_ti8_sword.vmdl"})
		hero.JugSword:FollowEntity(hero, true)
		hero.JugSword_particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/jugg_ti8_crimson_sword_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.JugSword)
	end

	if hero:GetUnitName() == "npc_dota_hero_lycan" then
		if IsUnlockedInPassFree(playerID, "free_reward41") then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/creeps/knoll_1/werewolf_boss.vmdl")
			hero:SetModelScale(1.4)
		else
			--local head_bul = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/head_bul.vmdl"})
			--head_bul:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_queenofpain" then
		if IsUnlockedInPass(playerID, "reward45") then
			hero:SetOriginalModel("models/heroes/anime/datealive/kurumi/arcana_kurumi/arcana_kurumi.vmdl")
			hero:SetModelScale(0.92)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_alchemist" then
		if IsUnlockedInPassFree(playerID, "free_reward41") then
			hero.brb_crown = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/crown_bigrussianboss.vmdl"})
			hero.brb_crown:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_void_spirit" then
		hero.model_void_1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_head.vmdl"})
		hero.model_void_1:FollowEntity(hero, true)
		hero.model_void_2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_armor.vmdl"})
		hero.model_void_2:FollowEntity(hero, true)
		hero.effectvan = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.model_void_1)
	end

	if hero:GetUnitName() == "npc_dota_hero_pudge" then
		if IsUnlockedInPass(playerID, "reward61") then
			hero:SetOriginalModel("models/items/pudge/arcana/pudge_arcana_base.vmdl")
			hero.PudgeBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/pudge/arcana/pudge_arcana_back.vmdl"})
			hero.PudgeBack:FollowEntity(hero, true)
			hero.PudgeEffect = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_back_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PudgeBack)
		end
		if IsUnlockedInPassFree(playerID, "free_reward95") then
			hero.pudge_mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/pudge_kaneki_mask.vmdl"})
			hero.pudge_mask:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_bounty_hunter" then
		if IsUnlockedInPass(playerID, "reward77") then
			hero.BountyWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/bounty_hunter/bh_ti9_immortal_weapon/bh_ti9_immortal_weapon.vmdl"})
			hero.BountyWeapon:FollowEntity(hero, true)
			hero.WeaponEffect = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BountyWeapon)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_skeleton_king" then
		if IsUnlockedInPass(playerID, "reward67") then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/items/wraith_king/arcana/wraith_king_arcana.vmdl")
			hero.PapichBloodShard = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_weapon.vmdl"})
			hero.PapichBloodShard:FollowEntity(hero, true)
			hero.PapichHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_head.vmdl"})
			hero.PapichHead:FollowEntity(hero, true)
			hero.PapichPauldrons = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_shoulder.vmdl"})
			hero.PapichPauldrons:FollowEntity(hero, true)
			hero.PapichPunch = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/blistering_shade/mesh/blistering_shade_alt.vmdl"})
			hero.PapichPunch:FollowEntity(hero, true)
			hero.PapichCape = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_back.vmdl"})
			hero.PapichCape:FollowEntity(hero, true)
			hero.PapichArmor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_armor.vmdl"})
			hero.PapichArmor:FollowEntity(hero, true)
			hero.PapichEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PapichPunch)
			hero.HeadEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_ambient_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PapichHead)
			hero.AmbientEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_ambient.vpcf", PATTACH_POINT_FOLLOW, hero)
			ParticleManager:SetParticleControl(hero.AmbientEffect, 0, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 1, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 2, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 3, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 4, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 5, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 6, hero:GetAbsOrigin())
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_tiny" then
		if IsUnlockedInPass(playerID, "reward73") then
			hero:SetOriginalModel("models/items/tiny/tiny_prestige/tiny_prestige_lvl_01.vmdl")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_terrorblade" then
		if IsUnlockedInPass(playerID, "reward95") then
			local TerrorbladeWeapons = {
				"models/heroes/terrorblade/weapon.vmdl",
				"models/items/terrorblade/corrupted_weapons/corrupted_weapons.vmdl",
				"models/items/terrorblade/endless_purgatory_weapon/endless_purgatory_weapon.vmdl",
				"models/items/terrorblade/knight_of_foulfell_terrorblade_weapon/knight_of_foulfell_terrorblade_weapon.vmdl",
				"models/items/terrorblade/marauders_weapon/marauders_weapon.vmdl",
				"models/items/terrorblade/tb_ti9_immortal_weapon/tb_ti9_immortal_weapon.vmdl",
			}
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					for _,weapon in pairs(TerrorbladeWeapons) do
						if child:GetClassname() == "dota_item_wearable" and child:GetModelName() == weapon then
							child:RemoveSelf();
						end
					end
				end
			end
			hero.BookLeft = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/terrorblade_sobolev_book_left.vmdl"})
			hero.BookLeft:FollowEntity(hero, true)
			hero.BookRight = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/terrorblade_sobolev_book_right.vmdl"})
			hero.BookRight:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_sand_king" then
		if IsUnlockedInPass(playerID, "reward7") then
			hero:SetMaterialGroup("event")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_winter_wyvern" then
		if IsUnlockedInPassFree(playerID, "free_reward15") then
			hero:SetMaterialGroup("event")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_dragon_knight" then
		if IsUnlockedInPassFree(playerID, "free_reward65") then
			hero:SetOriginalModel("models/heroes/dragon_knight_persona/dk_persona_base.vmdl")
			hero.robbie_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/dragon_knight_persona/dk_persona_weapon_alt.vmdl"})
			hero.robbie_weapon:FollowEntity(hero, true)
		else
			hero.robbie_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_weapon/aurora_warrior_set_weapon.vmdl"})
			hero.robbie_weapon:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_ogre_magi" then
		if IsUnlockedInPass(playerID, "reward23") then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/creeps/ogre_1/boss_ogre.vmdl")
		end
	end


	if hero:GetUnitName() == "npc_dota_hero_abyssal_underlord" then
		hero.SpectreScream = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/spectre/spectre_dress.vmdl"})
		hero.SpectreScream:FollowEntity(hero, true)
		hero.SpectreWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/spectre/spectre_arcana/spectre_arcana_weapon.vmdl"})
		hero.SpectreWeapon:FollowEntity(hero, true)
		hero.spectre_effect = ParticleManager:CreateParticle("particles/econ/items/spectre/spectre_arcana/spectre_arcana_debut_weapon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.SpectreWeapon)
	end

	--if hero:GetUnitName() == "npc_dota_hero_phantom_lancer" then
	--	hero.RinSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/rin/rin_weapon.vmdl"})
	--	hero.RinSword:FollowEntity(hero, true)
	--end

	--if hero:GetUnitName() == "npc_dota_hero_treant" then
	--	hero.OverlordSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/models/heroes/overlord/overlord_sword.vmdl"})
	--	hero.OverlordSword:FollowEntity(hero, true)
	--end

	if hero:GetUnitName() == "npc_dota_hero_grimstroke" then
		if hero ~= nil and hero:IsHero() then
			local children = hero:GetChildren();
			for k,child in pairs(children) do
				if child:GetClassname() == "dota_item_wearable" and child:GetModelName() == "models/heroes/grimstroke/grimstroke_head_item.vmdl" then
					child:RemoveSelf();
				end
			end
		end
	end

	if npcName == "npc_dota_hero_troll_warlord" then
		if IsUnlockedInPass(playerID, "reward59") then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
							child:RemoveSelf();
					end
				end
			end
			hero.GorinStools = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/troll_warlord_gorin_stool.vmdl"})
			hero.GorinStools:FollowEntity(hero, true)
			hero.TrollHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/troll_warlord_head.vmdl"})
			hero.TrollHead:FollowEntity(hero, true)
			hero.TrollShoulders = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/troll_warlord_shoulders.vmdl"})
			hero.TrollShoulders:FollowEntity(hero, true)
			hero.TrollLod = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/mesh/troll_warlord_armor_model_lod0.vmdl"})
			hero.TrollLod:FollowEntity(hero, true)
		end
	end

	if npcName == "npc_dota_hero_omniknight" then
		if IsUnlockedInPass(playerID, "reward82") then
			hero.ZelenskyHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/omniknight_zelensky_head.vmdl"})
			hero.ZelenskyHead:FollowEntity(hero, true)
		end
	end

	if npcName == "npc_dota_hero_invoker" then
		if hero ~= nil and hero:IsHero() then
			local children = hero:GetChildren();
			for k,child in pairs(children) do
				if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
				end
			end
		end
		if IsUnlockedInPass(playerID, "reward90") then
			hero:AddNewModifier( hero, nil, "modifier_bp_druzhko_reward", {})
		end
		if IsUnlockedInPass(playerID, "reward90") then
			hero.InvokerBelt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_armor.vmdl"})
			hero.InvokerBelt:FollowEntity(hero, true)
			hero.InvokerBracer = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_shoulder.vmdl"})
			hero.InvokerBracer:FollowEntity(hero, true)
			hero.InvokerArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_arms.vmdl"})
			hero.InvokerArms:FollowEntity(hero, true)
			hero.InvokerBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_back.vmdl"})
			hero.InvokerBack:FollowEntity(hero, true)
			hero.InvokerApexKid = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/magus_apex_kid.vmdl"})
			hero.InvokerApexKid:FollowEntity(hero, true)
			hero.invoker_effect_1 = ParticleManager:CreateParticle("particles/econ/items/invoker_kid/invoker_dark_artistry/invoker_kid_dark_artistry_cape_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.InvokerBack)
			hero.invoker_effect_2 = ParticleManager:CreateParticle("particles/econ/items/invoker_kid/invoker_dark_artistry/invoker_kid_magus_apex_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.InvokerApexKid)
		else
			hero.InvokerBelt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_cape.vmdl"})
			hero.InvokerBelt:FollowEntity(hero, true)
			hero.InvokerBracer = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_sleeves.vmdl"})
			hero.InvokerBracer:FollowEntity(hero, true)
		end
	end

	if npcName == "npc_dota_hero_abaddon" then
		hero.WeaponMeepo = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/ti8_meepo_pitmouse_fraternity_weapon/ti8_meepo_pitmouse_fraternity_weapon.vmdl"})
		hero.WeaponMeepo:FollowEntity(hero, true)
	end

	if npcName == "npc_dota_hero_enigma" then
		hero.Ricardo = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/axe/ricardaxe.vmdl"})
		hero.Ricardo:FollowEntity(hero, true)
	end

	if npcName == "npc_dota_hero_nyx_assassin" then
		hero.Stray1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/ti6_blink_strike/riki_ti6_blink_strike.vmdl"})
		hero.Stray1:FollowEntity(hero, true)
		hero.Stray2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/umbrage/umbrage.vmdl"})
		hero.Stray2:FollowEntity(hero, true)
		hero.Stray3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/umbrage__offhand/umbrage__offhand.vmdl"})
		hero.Stray3:FollowEntity(hero, true)
		hero.Stray4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/riki_ti8_immortal_head/riki_ti8_immortal_head.vmdl"})
		hero.Stray4:FollowEntity(hero, true)
		hero.Stray5 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/riki_cunning_corsair_ti_2017_tail/riki_cunning_corsair_ti_2017_tail.vmdl"})
		hero.Stray5:FollowEntity(hero, true)
		hero.stray_effect_1 = ParticleManager:CreateParticle("particles/econ/items/riki/riki_head_ti8/riki_head_ambient_ti8.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.Stray4)
		hero.stray_effect_2 = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.Stray1)
	end
end

function BirzhaGameMode:AbilitiesStart(player)
	local FastAbilities = 
	{
		"Ayano_Mischief",
		"Ranger_Jump",
		"edward_bil_prank",
		"Rikardo_Fire",
		"dio_vampire",
		"Akame_Demon",
		"face_esketit",
		"goku_blink_one",
		"Akame_jump",
		"Miku_ritmic_song",
		"Felix_water_block",
		"gorshok_death_passive",
		"overlord_select_target",
		"haku_mask",
		"haku_zerkalo",
		"kakashi_invoke",
		"aang_invoke",
		"van_swallowmycum",
		"migi_death",
		"overlord_spellbook_close",
		"Overlord_passive",
		"gorshok_evil_dance",
	}

	for _,FastAbility in pairs(FastAbilities) do
	   	FastAbility = player:FindAbilityByName(FastAbility)
	   	if player:IsRealHero() then
	      	if FastAbility then
	        	FastAbility:SetLevel(1)
	      	end
	    end
	end
end

function BirzhaGameMode:AddedDonateStart(player,playerID)
	if IsUnlockedInPass(playerID, "reward14") then
		player:AddNewModifier( player, nil, "modifier_bp_effects_reward", {})
	end
	
	if IsUnlockedInPass(playerID, "reward23") then
		local sound_kill_reward =    {
		['npc_dota_hero_ogre_magi'] = true,
		['npc_dota_hero_earthshaker'] = true,
	 
		}
		if sound_kill_reward[player:GetUnitName()] then
			player:AddNewModifier(player, nil, 'modifier_birzhapass_sound', {})
		end 
	end
end

function BirzhaGameMode:EndGame( victoryTeam )
	if game_is_end then return end
	game_is_end = true
	for id = 0, PlayerResource:GetPlayerCount() - 1 do
		if PlayerResource:GetTeam(id) == victoryTeam and not IsPlayerDisconnected(id) then
			if PlayerResource:GetSelectedHeroEntity(id) and PlayerResource:GetSelectedHeroEntity(id):GetUnitName() == "npc_dota_hero_skeleton_king" then
				EmitGlobalSound("papich_victory")
				break
			end
		end
	end
	if GameRules:IsCheatMode() then GameRules:SetGameWinner( victoryTeam ) return end
	if IsInToolsMode() then GameRules:SetGameWinner( victoryTeam ) return end
	if GetMapName() == "birzhamemov_zxc" then GameRules:SetGameWinner( victoryTeam ) return end
	if GetMapName() == "birzhamemov_samepick" then GameRules:SetGameWinner( victoryTeam ) return end
	if PlayerResource:GetPlayerCount() > 5 then
		CustomNetTables:SetTableValue("birzha_mmr", "game_winner", {t = victoryTeam} )
		BirzhaData.PostData()
		BirzhaData.PostHeroesInfo()
		BirzhaData.PostHeroPlayerHeroInfo()
	end
	GameRules:SetGameWinner( victoryTeam )
end