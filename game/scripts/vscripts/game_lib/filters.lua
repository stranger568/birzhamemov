function BirzhaGameMode:DamageFilter( filterTable  )
	local damage = filterTable["damage"]
	if filterTable["entindex_attacker_const"] == nil then
		return true
	end
    local attacker = EntIndexToHScript( filterTable["entindex_attacker_const"] )
    local victim =EntIndexToHScript( filterTable["entindex_victim_const"] )
    local damagetype = filterTable["damagetype_const"]
    local ability = filterTable["entindex_inflictor_const"]

    local modifiers_return_victim =
    {
    	"modifier_LenaGolovach_Radio_god",
		"modifier_kurumi_zafkiel",
		"modifier_Dio_Za_Warudo",
		"modifier_Felix_WaterShield",
		"modifier_kurumi_god",
		"modifier_ExplosionMagic_immunity",
		"modifier_item_uebator_active",
		"modifier_Overlord_spell_10_invul"
    }

    local modifiers_return_attacker = 
    {
    	"modifier_monika_concept_ill",
		"modifier_item_uebator_active",
    }

	if victim:HasModifier("modifier_agility_toss") then
		if attacker then
			if attacker:GetUnitName() == "npc_dota_hero_oracle" then
				if ability then
					if EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_lunge" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_ice_wall" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_vacuum" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_fast_hit" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_jumping" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_avatar" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_fire_hit" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_fire_hit" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_lightning" or
					EntIndexToHScript(filterTable.entindex_inflictor_const):GetAbilityName() == "aang_firestone" 
					then
						filterTable.damage = filterTable.damage * 1.25
					end
				end
			end
		end
	end

	if attacker:IsRealHero() then
	    local ability_pucci = attacker:FindAbilityByName("pucci_restart_world")
	    if ability_pucci and ability_pucci:GetLevel() > 0 then
	        if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_damage" then
	            ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + math.ceil(damage)
	            local Player = PlayerResource:GetPlayer(attacker:GetPlayerID())
	            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
	            if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
	                ability_pucci.current_quest[4] = true
	                ability_pucci.word_count = ability_pucci.word_count + 1
	                ability_pucci:SetActivated(true)
	                ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_trees"]
	                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
	            end
	        end
	    end
	end

	if victim:HasModifier("modifier_stray_kill_stealer") then
		local victim_health = victim:GetHealth()
		if filterTable.damage >= victim_health then
			local scythe_modifier = victim:FindModifierByName("modifier_stray_kill_stealer")
			local scythe_caster = false
			if scythe_modifier then
				scythe_caster = scythe_modifier:GetCaster()
			end
			if scythe_caster then
				local ability = scythe_caster:FindAbilityByName("stray_kill_stealer")
				if ability then
					filterTable["entindex_attacker_const"] = scythe_caster:entindex()
					victim:RemoveModifierByName("modifier_stray_kill_stealer")
				end
			end
		end
	end

	if victim:HasModifier("modifier_item_demon_paper_active") then
		if damagetype == 1 then
			return false
		end
	end

    for _, mod_return in pairs(modifiers_return_victim) do
	   	if victim:HasModifier(mod_return) and victim.overlord_kill == nil then
	    	return false
	    end
	end

    for _, mod_return in pairs(modifiers_return_attacker) do
	   	if attacker:HasModifier(mod_return) then
	    	return false
	    end
	end

    if victim:HasModifier("modifier_pistoletov_deathfight") then
    	if not attacker:HasModifier("modifier_pistoletov_deathfight") then
    		return false
    	end
    end

    if victim:HasModifier("modifier_haku_zerkala") then
    	if not attacker:HasModifier("modifier_haku_zerkala") then
    		return false
    	end
    end

    if attacker:HasModifier("modifier_haku_zerkala") then
    	if not victim:HasModifier("modifier_haku_zerkala") then
    		return false
    	end
    end

    if victim:HasModifier("modifier_miku_MusicBarrier_buff") then
    	if not attacker:HasModifier("modifier_miku_MusicBarrier_buff") then
    		if victim:FindModifierByName("modifier_miku_MusicBarrier_buff"):GetAbility():GetCaster():GetTeamNumber() == victim:GetTeamNumber() then
    			return false
    		end
    	end
    end

    return true
end
	
function BirzhaGameMode:ExecuteOrderFilter( filterTable )
	VectorTarget:OrderFilter(filterTable)
	local unit
	if filterTable.units and filterTable.units["0"] then
		unit = EntIndexToHScript(filterTable.units["0"])
	end
	local target = filterTable.entindex_target ~= 0 and EntIndexToHScript(filterTable.entindex_target) or nil
	local orderType = filterTable["order_type"]

	if unit and unit:HasModifier("modifier_fut_mum_eat_caster") then
		if filterTable.order_type == DOTA_UNIT_ORDER_CAST_POSITION   then
			if EntIndexToHScript(filterTable["entindex_ability"]) == nil then return end
			local ability = EntIndexToHScript(filterTable["entindex_ability"])
			if ability and ability:GetAbilityName() == "item_tpscroll" then
				return false
			end
		end
	end

    if unit and unit:HasModifier("modifier_serega_pirat_bike_cast") then
        local lock_orders = 
        {
            [DOTA_UNIT_ORDER_DROP_ITEM] = true,
            [DOTA_UNIT_ORDER_PICKUP_ITEM ] = true,
            [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        }
        if lock_orders[filterTable.order_type] then
            return false
        end
    end

	if unit and unit:HasModifier("modifier_JohnCena_Grabbed_buff") then
		if filterTable.order_type == DOTA_UNIT_ORDER_CAST_POSITION   then
			if EntIndexToHScript(filterTable["entindex_ability"]) == nil then return end
			local ability = EntIndexToHScript(filterTable["entindex_ability"])
			if ability and ability:GetAbilityName() == "item_tpscroll" then
				return false
			end
		end
	end

	if filterTable.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION  then
		if unit and unit:IsRealHero() and unit:GetUnitName()=="npc_dota_hero_sasake" then
			if RollPercentage(5) then
				unit:EmitSound("sasake_move")
			end
		end
	end

	if filterTable.order_type == DOTA_UNIT_ORDER_CAST_TARGET  then
		if EntIndexToHScript(filterTable["entindex_ability"]) == nil then return end
		local ability = EntIndexToHScript(filterTable["entindex_ability"])
		local target = EntIndexToHScript(filterTable["entindex_target"])
		if ability:GetAbilityName() == "gorshok_writer_goodwin" then
			if unit:GetPlayerOwnerID() ~= target:GetPlayerOwnerID() then
				DisplayError(unit:GetPlayerID(), "#dota_hud_error_not_your_unit")
				return false
			end
		end
	end

	if filterTable.order_type == DOTA_UNIT_ORDER_CAST_TARGET  then
		if EntIndexToHScript(filterTable["entindex_ability"]) == nil then return end
		local ability = EntIndexToHScript(filterTable["entindex_ability"])
		local target = EntIndexToHScript(filterTable["entindex_target"])
		if ability:GetAbilityName() == "haku_help" or ability:GetAbilityName() == "van_threehundredbucks" then
			if unit == target then
				DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
				return false
			end
		end
	end

	if filterTable.order_type == DOTA_UNIT_ORDER_CAST_TARGET  then
		if EntIndexToHScript(filterTable["entindex_ability"]) == nil then return end
		local ability = EntIndexToHScript(filterTable["entindex_ability"])
		local target = EntIndexToHScript(filterTable["entindex_target"])
		if ability:GetAbilityName() == "pucci_erace_disk" then
			if unit == target then
				DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
				return false
			end
		end
	end

	if filterTable.order_type == DOTA_UNIT_ORDER_CAST_TARGET  then
		if EntIndexToHScript(filterTable["entindex_ability"]) == nil then return end
		local ability = EntIndexToHScript(filterTable["entindex_ability"])
		local target = EntIndexToHScript(filterTable["entindex_target"])
		if ability:GetAbilityName() == "migi_inside" then
			if unit == target then
				DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
				return false
			end
		end
	end

	if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()
		if pickedItem == nil then
			return true
		end

		local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
		local hero = player:GetAssignedHero()

		if (unit:IsCourier()) and (pickedItem:GetAbilityName() == "item_bag_of_gold" or pickedItem:GetAbilityName() == "item_treasure_chest" or pickedItem:GetAbilityName() == "item_treasure_chest_winter") then
			local position = item:GetAbsOrigin()
			filterTable["position_x"] = position.x
			filterTable["position_y"] = position.y
			filterTable["position_z"] = position.z
			filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
			return true
		end

		if (not unit:IsRealHero()) and (pickedItem:GetAbilityName() == "item_bag_of_gold" or pickedItem:GetAbilityName() == "item_treasure_chest" or pickedItem:GetAbilityName() == "item_treasure_chest_winter") then
			local position = item:GetAbsOrigin()
			filterTable["position_x"] = position.x
			filterTable["position_y"] = position.y
			filterTable["position_z"] = position.z
			filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
			return true
		end

		if pickedItem:GetAbilityName() == "item_treasure_chest" or pickedItem:GetAbilityName() == "item_treasure_chest_winter" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()
			if hero:GetNumItemsInInventory() < 9 then
				return true
			else
				local position = item:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				return true
			end
		end
	end

	return true
end

function BirzhaGameMode:HealingFilter( keys )
	local hHealingHero = nil

	local htargetHero = nil

	if keys["entindex_healer_const"] ~= nil then
		hHealingHero = EntIndexToHScript( keys["entindex_healer_const"] )
	end
    
	if keys["entindex_target_const"] ~= nil then
		htargetHero = EntIndexToHScript( keys["entindex_target_const"] )
	end

	if keys["entindex_healer_const"] ~= nil and hHealingHero ~= nil then
		if hHealingHero ~= nil and hHealingHero:IsRealHero() then
			local heal_amplify = 0
			for _, mod in pairs(EntIndexToHScript( keys["entindex_healer_const"] ):FindAllModifiers()) do
				if mod.Custom_AllHealAmplify_Percentage and mod:Custom_AllHealAmplify_Percentage() then
					heal_amplify = heal_amplify + mod:Custom_AllHealAmplify_Percentage()
				end
			end
			if heal_amplify ~= 0 then
				keys.heal = keys.heal * (1 + (heal_amplify * 0.01))
			end
		end
	end

	if keys["entindex_target_const"] ~= nil and htargetHero ~= nil then
		local heal_amplify_target = 0
		for _, mod in pairs(EntIndexToHScript( keys["entindex_target_const"] ):FindAllModifiers()) do
			if mod.Custom_HealAmplifyReduce and mod:Custom_HealAmplifyReduce() then
				heal_amplify_target = heal_amplify_target + mod:Custom_HealAmplifyReduce()
			end
		end	
		if heal_amplify_target ~= 0 then
			keys.heal = keys.heal * (1 + (heal_amplify_target * 0.01))
		end	
	end

	return true
end