LinkLuaModifier( "modifier_birzha_disconnect", "modifiers/modifier_birzha_disconnect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_loser", "modifiers/donate_modifiers/modifier_birzha_loser", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_donater", "modifiers/modifier_birzha_pet", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_illusion_cosmetics", "modifiers/modifier_birzha_dota_modifiers", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_never_reward", "modifiers/birzhapass_modifiers/modifier_bp_never_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_valakas_reward", "modifiers/birzhapass_modifiers/modifier_bp_valakas_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_druzhko_reward", "modifiers/birzhapass_modifiers/modifier_bp_druzhko_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_effects_reward", "modifiers/birzhapass_modifiers/modifier_bp_effects_reward", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_ayano", "modifiers/birzhapass_modifiers/modifier_bp_ayano", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_dangerous_boy", "modifiers/birzhapass_modifiers/modifier_bp_dangerous_boy", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzhapass_sound", "memespass/soundkill", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gamemode_wtf", "modifiers/modifier_gamemode_wtf", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_bp_sobolev", "modifiers/birzhapass_modifiers/modifier_bp_sobolev", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_mum_arcana", "modifiers/birzhapass_modifiers/modifier_bp_mum_arcana", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_mum_mask", "modifiers/birzhapass_modifiers/modifier_bp_mum_mask", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bp_johncena", "modifiers/birzhapass_modifiers/modifier_bp_johncena", LUA_MODIFIER_MOTION_NONE )

_G.FountainTimer = 900
_G.EventTimer = 900
_G.GameEndTimer = 300
_G.nCOUNTDOWNTIMER = 0

function BirzhaGameMode:OnGameRulesStateChange(params)
	local nNewState = GameRules:State_Get()

	HeroDemo:OnGameRulesStateChange(params)

	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		BirzhaData:RegisterSeasonInfo()
		CustomPick:Init()
	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then

		local maps_scores = 
		{
			["birzhamemov_solo"] = 50,
			["birzhamemov_duo"] = 60,
			["birzhamemov_trio"] = 90,
			["birzhamemov_5v5v5"] = 150,
			["birzhamemov_5v5"] = 100,
			["birzhamemov_zxc"] = 2,
			["birzhamemov_samepick"] = 100,
			["birzhamemov_wtf"] = 50,
		}
		self.ContractTimer = 180
		self.contract_gold = {
			[2] = 1000,
			[3] = 1000,
			[6] = 1000,
			[7] = 1000,
			[8] = 1000,
			[9] = 1000,
			[10] = 1000,
			[11] = 1000,
			[12] = 1000,
			[13] = 1000,
		}
		CustomNetTables:SetTableValue( "game_state", "scores_to_win", { kills = maps_scores[GetMapName()] } )
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
		BirzhaGameMode:SpawnDonaters()
	end
end

function BirzhaGameMode:OnNPCSpawned( event )
	local player = EntIndexToHScript(event.entindex)

	if player:GetUnitName() == "npc_palnoref_chariot" then
		if not player.chariot_sword or ( player.chariot_sword and player.chariot_sword == nil )then
			player.chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
			player.chariot_sword:FollowEntity(player, true)
		end
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

	if player and player:IsIllusion() and player:GetUnitName() == "npc_dota_hero_oracle" then
    	local original_aang = nil
    	for _,hero in pairs (HeroList:GetAllHeroes()) do
    		if hero:GetUnitName() == "npc_dota_hero_oracle" and not hero:IsIllusion() then
    			original_aang = hero
    		end
    	end
    	if original_aang ~= nil then
    		local modifiers = original_aang:FindAllModifiers() 
    		for _,modifier in pairs(modifiers) do 
    			if modifier:GetName() == "modifier_aang_quas" then
    				local modifier_2 = player:AddNewModifier(player, player:FindAbilityByName( "aang_quas" ), "modifier_aang_quas", {})
    				player:FindAbilityByName( "aang_invoke" ):OnUpgrade()
    				player:FindAbilityByName( "aang_invoke" ):AddOrb( modifier_2, "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf" )
    			elseif modifier:GetName() == "modifier_aang_exort" then
    				local modifier_2 = player:AddNewModifier(player, player:FindAbilityByName( "aang_exort" ), "modifier_aang_exort", {})
    				player:FindAbilityByName( "aang_invoke" ):OnUpgrade()
    				player:FindAbilityByName( "aang_invoke" ):AddOrb( modifier_2, "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf" )
    			elseif modifier:GetName() == "modifier_aang_wex" then
    				local modifier_2 = player:AddNewModifier(player, player:FindAbilityByName( "aang_wex" ), "modifier_aang_wex", {})
    				player:FindAbilityByName( "aang_invoke" ):OnUpgrade()
    				player:FindAbilityByName( "aang_invoke" ):AddOrb( modifier_2, "particles/avatar/aang_earth_orb.vpcf" )
    			end 
    		end
    	end
    end

	if player:IsRealHero() then
		local playerID = player:GetPlayerID()
		local playerSteamID = PlayerResource:GetSteamAccountID(playerID)

		if player:GetUnitName() == "npc_dota_hero_treant" then
			if player.BirzhaFirstSpawned then
	   			player:EmitSound("OverlordRein")
	   		end
	   	end

	   	if player:GetUnitName() == "npc_dota_hero_venom" then
			if player.BirzhaFirstSpawned == nil then
	   			player:EmitSound("venom_start")
	   		end
	   	end

	   	if player:GetUnitName() == "npc_dota_hero_travoman" then
	   		player:EmitSound("travoman_spawn")
	   	end

	    local ability_pucci =player:FindAbilityByName("pucci_restart_world")
        if ability_pucci and ability_pucci:GetLevel() > 0 then
            if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_respawn" then
                ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                local Player = PlayerResource:GetPlayer(player:GetPlayerID())
                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                    ability_pucci.current_quest[4] = true
                    ability_pucci.word_count = ability_pucci.word_count + 1
                    ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_stunned"]
                    ability_pucci:SetActivated(true)
                    CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                end
            end
        end

	   	if player:GetUnitName() == "npc_dota_hero_sasake" then
			if player.BirzhaFirstSpawned then
				if RollPercentage(20) then
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

		--if IsPlayerDisconnected(playerID) then
	    --    player:AddNewModifier(player, nil, "modifier_birzha_disconnect", {})
		--end

	   	if player.BirzhaFirstSpawned == nil then
	   		if player:IsRealHero() then
	   			if BirzhaData.PLAYERS_GLOBAL_INFORMATION[playerID] then
	   				BirzhaData.PLAYERS_GLOBAL_INFORMATION[playerID].team = player:GetTeamNumber()
	   			end
	   		end
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

		   	--if playerSteamID == 141989146 then
			--    local buildings = FindUnitsInRadius( player:GetTeamNumber(), player:GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false )
			--    local fountain = nil
			--    for _,building in pairs(buildings) do
			--        if building:GetClassname()=="ent_dota_fountain" then
			--            fountain = building
			--            break
			--        end
			--    end
			--    if fountain ~= nil then
			--		local npc_unit_roga = CreateUnitByName( "npc_unit_roga", Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
			--		npc_unit_roga:AddNewModifier( npc_unit_roga, nil, "modifier_birzha_donater", {} )
			--		fountain.horns = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/roga/roga.vmdl"})
			--		fountain.horns:FollowEntity(fountain, true)
			--		local forward = (Vector(0,0,0) - fountain.horns:GetAbsOrigin()):Normalized()
			--		fountain.horns:SetForwardVector(forward)
			--	end
			--end

	   		local player_table = CustomNetTables:GetTableValue('birzhainfo', tostring(playerID))
	   		if player_table then
	   			if player_table.ban_days and player_table.ban_days > 0 then
	   				local ban_mod = player:AddNewModifier(player, nil, "modifier_birzha_loser", {})
	   				ban_mod:SetStackCount(player_table.ban_days)
	   			end
	   		end

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
		player.overlord_kill = nil
		BirzhaGameMode:OnHeroInGame(player)
	end
end

function BirzhaGameMode:OnTeamKillCredit( event )
	if FountainTimer <= 0 then
		GameEndTimer = 300
	end
	BirzhaGameMode:AddScoreToTeam( event.teamnumber, 1 )
end

function BirzhaGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()



  	if not killedUnit.IsRealHero or not killedUnit:IsRealHero() then
  		local panels = WorldPanels.entToPanels[killedUnit]
		if panels then
	  		for i=1,#panels do
	    		local panel = panels[i]
	    		for j=1,#panel.pids do
	      			local pid = panel.pids[j]
	      			PlayerTables:DeleteTableKey("worldpanels_" .. pid, panel.idString)
	    		end
	  		end
		end
    end

	local hero = nil

	if event.entindex_attacker then
		hero = EntIndexToHScript( event.entindex_attacker )
	end


	if hero ~= nil then
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
			if hero:IsRealHero() and heroTeam ~= killedTeam then
				if killedUnit:GetUnitName() == "npc_dota_hero_treant" then
			   		killedUnit:EmitSound("OverlordDeath")
			   	elseif hero:GetUnitName() == "npc_dota_hero_treant" then
			   		self:OverlordKillSound(hero, killedUnit)
			   	end
			   	if killedUnit:GetUnitName() == "npc_dota_hero_sasake" then
			   		killedUnit:EmitSound("sasake_death")
			   	elseif hero:GetUnitName() == "npc_dota_hero_sasake" then
			   		hero:EmitSound("sasake_kill")
			   	end

			   	if killedUnit:GetUnitName() == "npc_dota_hero_travoman" then
			   		killedUnit:EmitSound("travoman_death")
			   		print("zvuk")
			   	elseif hero:GetUnitName() == "npc_dota_hero_travoman" then
			   		hero:EmitSound("travoman_kill")
			   	end

			   	local bonus = false

			   	local attacker_kills = 0
			   	local target_kills = 0

			   	local team = {}
			    local teams_table = {2,3,6,7,8,9,10,11,12,13}

			    for _, i in ipairs(teams_table) do
			        local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
			        if table_team_score then
			            table.insert(team, {id = i, kills = table_team_score.kills} )
			        end
			    end  

			    table.sort( team, function(x,y) return y.kills < x.kills end )

			    for _, team_info in pairs(team) do
			    	if team_info.id == killedUnit:GetTeamNumber() then
			    		target_kills = team_info.kills
			    	end
			    	if team_info.id == hero:GetTeamNumber() then
			    		attacker_kills = team_info.kills
			    	end
			    end

			    if target_kills > attacker_kills then
			    	bonus = true
			    end

				if bonus and (game_time >= 5 or IsInToolsMode()) then
					local memberID = hero:GetPlayerID()
					local gold = (250 + (250 * game_time / 10)) + ((target_kills - attacker_kills) * 50)
					local exp = (500 * (game_time / 5)) + ((target_kills - attacker_kills) * 100)
					PlayerResource:ModifyGold( memberID, gold, true, 0 )
					hero:AddExperience( exp, 0, false, false )
					local name = hero:GetClassname()
					local victim = killedUnit:GetClassname()
					local kill_alert =
					{
						hero_id = hero:GetUnitName()
					}
					CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
				else
					hero:AddExperience( 100, 0, false, false )
				end
			end

			--- Чекнуть
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

							--- Чекнуть
							local modifier_passive = attacker:FindModifierByName("modifier_Overlord_passive")
				            if modifier_passive then
				                modifier_passive:SetStackCount(modifier_passive:GetStackCount()+2)
				            end


							local mod = attacker:FindModifierByName("modifier_item_birzha_ward")
							if mod then
								if hero:GetTeamNumber() == attacker:GetTeamNumber() then
									mod:GetAbility().assists = mod:GetAbility().assists + 1
									if mod:GetAbility().assists >= 30 then
										attacker:ModifyGold( 125, true, 0 )
										mod:SetStackCount(3)
										mod:GetAbility().level = 3
									elseif mod:GetAbility().assists >= 15 then
										attacker:ModifyGold( 100, true, 0 )
										mod:SetStackCount(2)
										mod:GetAbility().level = 2
									elseif mod:GetAbility().assists < 15 then
										attacker:ModifyGold( 75, true, 0 )
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if killedUnit:IsRealHero() then
		if killedUnit:GetRespawnTime() > 10 then
			if killedUnit:IsReincarnating() == true then
				return nil
			else
				BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit )
			end
		else
			BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit )
		end
	end
end

function BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit )

	if killedUnit:HasModifier("modifier_jull_steal_time") then
		local respawn_time = 10

		if killedTeam == self.leadingTeam then
			if nCOUNTDOWNTIMER >= 600 then
				respawn_time = 20
			elseif nCOUNTDOWNTIMER >= 300 then
				respawn_time = 18
			elseif nCOUNTDOWNTIMER >= 180 then
				respawn_time = 16
			elseif nCOUNTDOWNTIMER >= 120 then
				respawn_time = 14
			elseif nCOUNTDOWNTIMER >= 60 then
				respawn_time = 12
			elseif nCOUNTDOWNTIMER >= 0 then
				respawn_time = 10
			end
		end

		local modifier = killedUnit:FindModifierByName("modifier_jull_steal_time_stack")
		if modifier then
			local stackcount = modifier:GetStackCount()
			if stackcount > 0 then
				for i = 1, stackcount do
					if respawn_time > 1 then
						respawn_time = respawn_time - 1
						modifier:DecrementStackCount()
					end
				end
			end
		end

		if respawn_time < 1 then
			respawn_time = 1
		end

		killedUnit:SetTimeUntilRespawn( respawn_time )
		return
	end



	if killedTeam == self.leadingTeam then
		if nCOUNTDOWNTIMER >= 600 then
			killedUnit:SetTimeUntilRespawn( 20 )
		elseif nCOUNTDOWNTIMER >= 300 then
			killedUnit:SetTimeUntilRespawn( 18 )
		elseif nCOUNTDOWNTIMER >= 180 then
			killedUnit:SetTimeUntilRespawn( 16 )
		elseif nCOUNTDOWNTIMER >= 120 then
			killedUnit:SetTimeUntilRespawn( 14 )
		elseif nCOUNTDOWNTIMER >= 60 then
			killedUnit:SetTimeUntilRespawn( 12 )
		elseif nCOUNTDOWNTIMER >= 0 then
			killedUnit:SetTimeUntilRespawn( 10 )
		end
	else 
		killedUnit:SetTimeUntilRespawn( 10 )
	end
end

function BirzhaGameMode:OnItemPickUp( event )
	VectorTarget:OnItemPickup(event)
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
	end
	if owner:GetUnitName() == "npc_palnoref_chariot" then
		owner = owner:GetOwner()
	end
	if event.itemname == "item_bag_of_gold" then
		PlayerResource:ModifyGold( owner:GetPlayerID(), 150, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, 150, nil )
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
    for i = 1, 9 do
        local donater = CreateUnitByName( "donater_top" ..i , Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        donater:AddNewModifier( donater, nil, "modifier_birzha_donater", {} )
        if i == 7 then
        	donater:SetMaterialGroup("1")
        	ParticleManager:CreateParticle("particles/econ/courier/courier_golden_doomling/courier_golden_doomling_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, donater)
        end
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

	if GetMapName() == "birzhamemov_wtf" then
		hero:AddNewModifier(hero, nil, "modifier_gamemode_wtf", {})
	end

	if hero:IsIllusion() then
		hero:AddNewModifier( hero, nil, "modifier_birzha_illusion_cosmetics", {} )
	end

	if hero:GetUnitName() == "npc_dota_hero_nevermore" then
		if DonateShopIsItemBought(playerID, 27) then
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

			Timers:CreateTimer(0.25, function()
				local desolator = ParticleManager:CreateParticle("particles/never_arcana/desolationhadow_fiend_desolation_ambient.vpcf", PATTACH_CUSTOMORIGIN, hero)
				ParticleManager:SetParticleControlEnt( desolator, 0, hero, PATTACH_POINT_FOLLOW, "attach_arm_L", Vector(0,0,0), true )
				ParticleManager:SetParticleControlEnt( desolator, 1, hero, PATTACH_POINT_FOLLOW, "attach_arm_R", Vector(0,0,0), true )
			end)
			
			hero:AddNewModifier( hero, nil, "modifier_bp_never_reward", {})
		end
	end

	--if npcName == "npc_dota_hero_zuus" then
	--	hero:SetOriginalModel("models/heroes/zeus/zeus_arcana.vmdl")
	--	hero.ZuusArcanaHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/zeus/zeus_hair_arcana.vmdl"})
	--	hero.ZuusArcanaHead:FollowEntity(hero, true)
	--	hero.ZeusArcana = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_chariot.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	--end

	if npcName == "npc_dota_hero_earthshaker" then
		if DonateShopIsItemBought(playerID, 28) then
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

	if npcName == "npc_dota_hero_legion_commander" then
		if DonateShopIsItemBought(playerID, 126) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:AddActivityModifier("dualwield")
			hero:AddActivityModifier("arcana")
			hero:SetMaterialGroup("1")
			hero.AyanoHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_head/radiant_conqueror_head.vmdl"})
			hero.AyanoHead:FollowEntity(hero, true)
			hero.AyanoArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_arms/radiant_conqueror_arms.vmdl"})
			hero.AyanoArms:FollowEntity(hero, true)
			hero.AyanoBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_back/radiant_conqueror_back.vmdl"})
			hero.AyanoBack:FollowEntity(hero, true)
			hero.AyanoShoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_shoulder/radiant_conqueror_shoulder.vmdl"})
			hero.AyanoShoulder:FollowEntity(hero, true)
			hero.AyanoLegs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_legs/radiant_conqueror_legs.vmdl"})
			hero.AyanoLegs:FollowEntity(hero, true)
			hero.AyanoSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/demon_sword.vmdl"})
			hero.AyanoSword:FollowEntity(hero, true)

			ParticleManager:CreateParticle("particles/econ/items/legion/legion_radiant_conqueror/legion_radiant_conqueror_back_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoBack)
			ParticleManager:CreateParticle("particles/econ/items/legion/legion_radiant_conqueror/legion_radiant_conqueror_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoHead)
			ParticleManager:CreateParticle("particles/econ/items/legion/legion_radiant_conqueror/legion_radiant_conqueror_shoulder_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoShoulder)

			local particle_ayano_1 = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_arcana_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoSword)
			ParticleManager:SetParticleControlEnt( particle_ayano_1, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
			local particle_ayano_2 = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_arcana_weapon_offhand.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoSword)
			ParticleManager:SetParticleControlEnt( particle_ayano_2, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )

			hero:AddNewModifier( hero, nil, "modifier_bp_ayano", {})
		end
	end

	if npcName == "npc_dota_hero_monkey_king" then
		if DonateShopIsItemBought(playerID, 130) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end

			hero:AddActivityModifier("arcana")
			
			hero.BoyHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/monkey_king_arcana_head/mesh/monkey_king_arcana.vmdl"})
			hero.BoyHead:FollowEntity(hero, true)
			hero.BoyWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/monkey_king_immortal_weapon/monkey_king_immortal_weapon.vmdl"})
			hero.BoyWeapon:FollowEntity(hero, true)
			hero.BoyArmor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/mk_ti9_immortal_armor/mk_ti9_immortal_armor.vmdl"})
			hero.BoyArmor:FollowEntity(hero, true)
			hero.BoyShoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/mk_ti9_immortal_shoulder/mk_ti9_immortal_shoulder.vmdl"})
			hero.BoyShoulder:FollowEntity(hero, true)
			hero.BoyWeapon:SetMaterialGroup("2")
			hero:SetMaterialGroup("1")
			ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/monkey_king_arcana_crown_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BoyHead)
			ParticleManager:CreateParticle("particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_armor_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BoyArmor)
			ParticleManager:CreateParticle("particles/econ/items/monkey_king/ti7_weapon/mk_ti7_golden_immortal_weapon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BoyWeapon)
			local particle_boy_1 = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/monkey_king_arcana_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
			ParticleManager:SetParticleControl(particle_boy_1, 0, hero:GetAbsOrigin())
			hero:AddNewModifier( hero, nil, "modifier_bp_dangerous_boy", {})
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

	if npcName == "npc_dota_hero_serega_pirat" then
		hero.pirat_item_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_weapon/god_eater_weapon.vmdl" })
		hero.pirat_item_weapon:FollowEntity(hero, true)

		hero.pirat_item_offhand = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_off_hand/god_eater_off_hand.vmdl" })
		hero.pirat_item_offhand:FollowEntity(hero, true)
		
		hero.pirat_item_shoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_shoulder/god_eater_shoulder.vmdl" })
		hero.pirat_item_shoulder:FollowEntity(hero, true)
		
		hero.pirat_item_head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_head/god_eater_head.vmdl" })
		hero.pirat_item_head:FollowEntity(hero, true)
		
		hero.pirat_item_belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_belt/god_eater_belt.vmdl" })
		hero.pirat_item_belt:FollowEntity(hero, true)
		
		hero.pirat_item_arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_arms/god_eater_arms.vmdl" })
		hero.pirat_item_arms:FollowEntity(hero, true)
		
		hero.pirat_item_armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_armor/god_eater_armor.vmdl" })
		hero.pirat_item_armor:FollowEntity(hero, true)
	end

	if npcName == "npc_dota_hero_travoman" then
		hero.TravomanCostume = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/techies/bigshot/bigshot_squee_costume.vmdl"})
		hero.TravomanCostume:FollowEntity(hero, true)
		hero.TravomanCart = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/techies/bigshot/bigshot.vmdl"})
		hero.TravomanCart:FollowEntity(hero, true)
		local particle_cart = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_ambient_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.TravomanCostume)
		ParticleManager:SetParticleControlEnt( particle_cart, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
		local particle_cart = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_ambient_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:SetParticleControlEnt( particle_cart, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	end

	-- У 

	if hero:GetUnitName() == "npc_dota_hero_lycan" then
		if DonateShopIsItemBought(playerID, 37) then
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
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_queenofpain" then
		if DonateShopIsItemBought(playerID, 26) then
			hero:SetOriginalModel("models/heroes/anime/datealive/kurumi/arcana_kurumi/arcana_kurumi.vmdl")
			hero:SetModelScale(0.92)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_alchemist" then
		if DonateShopIsItemBought(playerID, 36) then
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
		if DonateShopIsItemBought(playerID, 25) then
			hero:SetOriginalModel("models/items/pudge/arcana/pudge_arcana_base.vmdl")
			hero.PudgeBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/pudge/arcana/pudge_arcana_back.vmdl"})
			hero.PudgeBack:FollowEntity(hero, true)
			hero.PudgeEffect = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_back_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PudgeBack)
			hero:AddNewModifier( hero, nil, "modifier_bp_mum_arcana", {})
		end
		if DonateShopIsItemBought(playerID, 39) then
			hero.pudge_mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/pudge_kaneki_mask.vmdl"})
			hero.pudge_mask:FollowEntity(hero, true)
			hero:AddNewModifier( hero, nil, "modifier_bp_mum_mask", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_bounty_hunter" then
		if DonateShopIsItemBought(playerID, 31) then
			hero.BountyWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/bounty_hunter/bh_ti9_immortal_weapon/bh_ti9_immortal_weapon.vmdl"})
			hero.BountyWeapon:FollowEntity(hero, true)
			hero.WeaponEffect = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BountyWeapon)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_skeleton_king" then
		if DonateShopIsItemBought(playerID, 29) then
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
		if DonateShopIsItemBought(playerID, 30) then
			hero:SetOriginalModel("models/items/tiny/tiny_prestige/tiny_prestige_lvl_01.vmdl")
			hero:AddNewModifier( hero, nil, "modifier_bp_johncena", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_terrorblade" then
		hero:AddActivityModifier("arcana")
		hero:AddActivityModifier("abysm")
		if DonateShopIsItemBought(playerID, 34) then
			local TerrorbladeWeapons = {
				"models/heroes/terrorblade/weapon.vmdl",
				"models/items/terrorblade/corrupted_weapons/corrupted_weapons.vmdl",
				"models/items/terrorblade/endless_purgatory_weapon/endless_purgatory_weapon.vmdl",
				"models/items/terrorblade/knight_of_foulfell_terrorblade_weapon/knight_of_foulfell_terrorblade_weapon.vmdl",
				"models/items/terrorblade/marauders_weapon/marauders_weapon.vmdl",
				"models/items/terrorblade/tb_ti9_immortal_weapon/tb_ti9_immortal_weapon.vmdl",
				"models/items/terrorblade/tb_samurai_weapon/tb_samurai_weapon.vmdl",
				"models/heroes/terrorblade/terrorblade_weapon_planes.vmdl",

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
			hero:AddNewModifier( hero, nil, "modifier_bp_sobolev", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_sand_king" then
		if DonateShopIsItemBought(playerID, 22) then
			hero:SetMaterialGroup("event")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_winter_wyvern" then
		if DonateShopIsItemBought(playerID, 35) then
			hero:SetMaterialGroup("event")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_dragon_knight" then
		if DonateShopIsItemBought(playerID, 38) then
			hero:SetOriginalModel("models/heroes/dragon_knight_persona/dk_persona_base.vmdl")
			hero.robbie_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/dragon_knight_persona/dk_persona_weapon_alt.vmdl"})
			hero.robbie_weapon:FollowEntity(hero, true)
		else
			hero.robbie_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_weapon/aurora_warrior_set_weapon.vmdl"})
			hero.robbie_weapon:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_ogre_magi" then
		if DonateShopIsItemBought(playerID, 23) then
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
		if DonateShopIsItemBought(playerID, 24) then
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
			hero:SetRangedProjectileName("particles/gorin_attack_item.vpcf")
		end
	end

	if npcName == "npc_dota_hero_omniknight" then
		if DonateShopIsItemBought(playerID, 32) then
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
		if DonateShopIsItemBought(playerID, 33) then
			hero:AddNewModifier( hero, nil, "modifier_bp_druzhko_reward", {})
		end
		if DonateShopIsItemBought(playerID, 33) then
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
		"migi_death",
		"overlord_spellbook_close",
		"Overlord_passive",
		"gorshok_evil_dance",
		"pucci_passive_dio",
		"pucci_passive_wave",
		"pyramide_passive",
		"sonic_steal_speed",
		"sonic_passive",
		"travoman_minefield_sign",
		"travoman_focused_detonate",
		"jull_light_future",
		"jull_steal_time",
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
	if DonateShopIsItemBought(playerID, 41) then
		player:AddNewModifier( player, nil, "modifier_bp_effects_reward", {})
	end
	
	if DonateShopIsItemBought(playerID, 23) then
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
	if BirzhaGameMode.game_is_end then return end

	BirzhaGameMode.game_is_end = true

	CustomPick:RegisterEndGameItems()

	for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		if not IsPlayerDisconnected(id) and PlayerResource:GetTeam(id) == victoryTeam then
			if PlayerResource:GetSelectedHeroEntity(id) and PlayerResource:GetSelectedHeroEntity(id):GetUnitName() == "npc_dota_hero_skeleton_king" then
				EmitGlobalSound("papich_victory")
				break
			elseif PlayerResource:GetSelectedHeroEntity(id) and PlayerResource:GetSelectedHeroEntity(id):GetUnitName() == "npc_dota_hero_treant" then
				EmitGlobalSound("overlord_win_sound")
				break
			elseif PlayerResource:GetSelectedHeroEntity(id) and PlayerResource:GetSelectedHeroEntity(id):GetUnitName() == "npc_dota_hero_pyramide" then
				EmitGlobalSound("pyramide_win_sound")
				break
			end
		end
	end

	if GameRules:IsCheatMode() and not IsInToolsMode() then GameRules:SetGameWinner( victoryTeam ) return end

	if GetMapName() == "birzhamemov_zxc" then
		CustomNetTables:SetTableValue("birzha_mmr", "game_winner", {t = victoryTeam} )
		BirzhaData.PostData()
		GameRules:SetGameWinner( victoryTeam )
		return
	end

	Timers:CreateTimer(1, function()
		GameRules:SetGameWinner( victoryTeam )
	end)
	
	if BirzhaData:GetPlayerCount() > 5 or IsInToolsMode() then
		if GetMapName() == "birzhamemov_wtf" then
			CustomNetTables:SetTableValue("birzha_mmr", "game_winner", {t = victoryTeam} )
			BirzhaData.PostData()
			GameRules:SetGameWinner( victoryTeam )
			return
		end

		CustomNetTables:SetTableValue("birzha_mmr", "game_winner", {t = victoryTeam} )
		BirzhaData.PostData()
		BirzhaData.PostHeroesInfo()
		BirzhaData.PostHeroPlayerHeroInfo()
	end
end

function BirzhaGameMode:AddScoreToTeam( Team, AddScore )
	local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(Team))
	local table_game_score = CustomNetTables:GetTableValue("game_state", "scores_to_win")
	local team_kills = 0

	if table_team_score then
		team_kills = table_team_score.kills + AddScore
		CustomNetTables:SetTableValue( "game_state", tostring(Team), { kills = team_kills } )
	end

	table_team_score = CustomNetTables:GetTableValue("game_state", tostring(Team))

	if table_team_score and table_game_score then
		if table_team_score.kills >= table_game_score.kills then	
			BirzhaGameMode:EndGame( Team )
			GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[Team] )
		end
	end
end

function BirzhaGameMode:PlayerLeaveUpdateMaxScore()
	local current_max_kills = CustomNetTables:GetTableValue("game_state", "scores_to_win").kills
	local leader_max_kills = BirzhaGameMode:GetMaxKillLeader()

	local maps_scores_change = 
	{
		["birzhamemov_solo"] = 2,
		["birzhamemov_duo"] = 2,
		["birzhamemov_trio"] = 2,
		["birzhamemov_5v5v5"] = 4,
		["birzhamemov_5v5"] = 4,
		["birzhamemov_zxc"] = 0,
		["birzhamemov_samepick"] = 4,
		["birzhamemov_wtf"] = 4,
	}

	local maps_scores = 
	{
		["birzhamemov_solo"] = 50,
		["birzhamemov_duo"] = 60,
		["birzhamemov_trio"] = 90,
		["birzhamemov_5v5v5"] = 150,
		["birzhamemov_5v5"] = 100,
		["birzhamemov_zxc"] = 2,
		["birzhamemov_samepick"] = 100,
		["birzhamemov_wtf"] = 50,
	}

	local new_kills = current_max_kills - maps_scores_change[GetMapName()]

	if leader_max_kills >= new_kills then
		new_kills = leader_max_kills + math.floor(( maps_scores_change[GetMapName()] / 2 ))
	end

	if new_kills > maps_scores[GetMapName()] then
		new_kills = maps_scores[GetMapName()]
	end

	CustomNetTables:SetTableValue( "game_state", "scores_to_win", { kills = new_kills } )
end

function BirzhaGameMode:GetMaxKillLeader()
	local team = {}

    local teams_table = {2,3,6,7,8,9,10,11,12,13}
    for _, i in ipairs(teams_table) do
        local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
        if table_team_score then
            table.insert(team, {id = i, kills = table_team_score.kills} )
        end
    end 

    table.sort( team, function(x,y) return y.kills < x.kills end )

    return team[1].kills
end

function BirzhaGameMode:OverlordKillSound( hero, killedUnit )
	if killedUnit:GetUnitName() == "npc_dota_hero_earth_spirit" then
		hero:EmitSound("overlord_kill_red")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_void_spirit" then
		hero:EmitSound("overlord_kill_van")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_pangolier" then
		hero:EmitSound("overlord_kill_gitelman")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_shredder" then
		hero:EmitSound("overlord_kill_doljan")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_templar_assassin" then
		hero:EmitSound("overlord_kill_megumin")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_dark_willow" then
		hero:EmitSound("overlord_kill_monika")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_overlord" then
		hero:EmitSound("overlord_kill_overlord")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_stone_dwayne" then
		hero:EmitSound("overlord_kill_skala")
	elseif killedUnit:GetUnitName() == "npc_dota_hero_nyx_assassin" then
		hero:EmitSound("overlord_kill_stray")
	else
		hero:EmitSound("OverlordKill")
	end
end
