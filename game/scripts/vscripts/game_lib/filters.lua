function BirzhaGameMode:DamageFilter(filterTable)
    -- Проверка наличия атакующего
    if not filterTable["entindex_attacker_const"] then
        return true
    end

    -- Получение сущностей
    local attacker = EntIndexToHScript(filterTable["entindex_attacker_const"])
    local victim = EntIndexToHScript(filterTable["entindex_victim_const"])
    local damagetype = filterTable["damagetype_const"]
    local ability = filterTable["entindex_inflictor_const"] and EntIndexToHScript(filterTable["entindex_inflictor_const"])
    local damage = filterTable["damage"]

    -- Таблицы модификаторов для проверки
    local IMMUNE_MODIFIERS_VICTIM = 
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

    local IMMUNE_MODIFIERS_ATTACKER = 
    {
        "modifier_monika_concept_ill",
        "modifier_item_uebator_active"
    }

    -- Обработка специального модификатора agility_toss
    if victim:HasModifier("modifier_agility_toss") and attacker and attacker:GetUnitName() == "npc_dota_hero_oracle" and ability then
        local aangAbilities = 
        {
            "aang_lunge", "aang_ice_wall", "aang_vacuum", "aang_fast_hit",
            "aang_jumping", "aang_avatar", "aang_fire_hit", "aang_lightning", "aang_firestone"
        }
        for _, abilityName in pairs(aangAbilities) do
            if ability:GetAbilityName() == abilityName then
                filterTable.damage = filterTable.damage * 1.25
                break
            end
        end
    end

    -- Обработка квеста Пуччи
    if attacker:IsRealHero() then
        self:ProcessPucciQuestDamage(attacker, damage)
    end

    -- Обработка модификатора Stray Kill Stealer
    if victim:HasModifier("modifier_stray_kill_stealer") and filterTable.damage >= victim:GetHealth() then
        local scytheModifier = victim:FindModifierByName("modifier_stray_kill_stealer")
        if scytheModifier then
            local scytheCaster = scytheModifier:GetCaster()
            if scytheCaster and scytheCaster:FindAbilityByName("stray_kill_stealer") then
                filterTable["entindex_attacker_const"] = scytheCaster:entindex()
                victim:RemoveModifierByName("modifier_stray_kill_stealer")
            end
        end
    end

    -- Проверка иммунитетов
    if victim:HasModifier("modifier_item_demon_paper_active") and damagetype == 1 then
        return false
    end

    -- Проверка модификаторов иммунитета у жертвы
    for _, modifier in pairs(IMMUNE_MODIFIERS_VICTIM) do
        if victim:HasModifier(modifier) and not victim.overlord_kill then
            return false
        end
    end

    -- Проверка модификаторов иммунитета у атакующего
    for _, modifier in pairs(IMMUNE_MODIFIERS_ATTACKER) do
        if attacker:HasModifier(modifier) then
            return false
        end
    end

    -- Проверка специальных условий дуэлей
    if self:CheckDuelConditions(attacker, victim) then
        return false
    end

    -- Проверка Music Barrier
    if victim:HasModifier("modifier_miku_MusicBarrier_buff") and 
       not attacker:HasModifier("modifier_miku_MusicBarrier_buff") then
        local barrierModifier = victim:FindModifierByName("modifier_miku_MusicBarrier_buff")
        if barrierModifier and barrierModifier:GetAbility():GetCaster():GetTeamNumber() == victim:GetTeamNumber() then
            return false
        end
    end

    return true
end

-- Вспомогательные функции
function BirzhaGameMode:ProcessPucciQuestDamage(attacker, damage)
    local abilityPucci = attacker:FindAbilityByName("pucci_restart_world")
    if not (abilityPucci and abilityPucci:GetLevel() > 0) then return end

    local currentQuest = abilityPucci.current_quest
    if not (currentQuest[4] == false and currentQuest[1] == "pucci_quest_damage") then return end

    currentQuest[2] = currentQuest[2] + math.ceil(damage)
    local player = PlayerResource:GetPlayer(attacker:GetPlayerID())
    
    CustomGameEventManager:Send_ServerToPlayer(player, "pucci_quest_event_set_progress", {
        min = currentQuest[2],
        max = currentQuest[3]
    })

    if currentQuest[2] >= currentQuest[3] then
        currentQuest[4] = true
        abilityPucci.word_count = abilityPucci.word_count + 1
        abilityPucci:SetActivated(true)
        abilityPucci.current_quest = abilityPucci.quests[GetMapName()]["pucci_quest_trees"]
        
        CustomGameEventManager:Send_ServerToPlayer(player, "pucci_quest_event_set_quest", {
            quest_name = abilityPucci.current_quest[1],
            min = abilityPucci.current_quest[2],
            max = abilityPucci.current_quest[3]
        })
    end
end

function BirzhaGameMode:CheckDuelConditions(attacker, victim)
    -- Проверка условий дуэлей
    if victim:HasModifier("modifier_pistoletov_deathfight") and 
        (not attacker:HasModifier("modifier_pistoletov_deathfight") and not attacker:HasModifier("modifier_Pistoletov_NewPirat_boat"))  then
        return true
    end

    if victim:HasModifier("modifier_haku_zerkala") and 
       not attacker:HasModifier("modifier_haku_zerkala") then
        return true
    end

    if attacker:HasModifier("modifier_haku_zerkala") and 
       not victim:HasModifier("modifier_haku_zerkala") then
        return true
    end

    return false
end

function BirzhaGameMode:ExecuteOrderFilter(filterTable)
    -- Передача фильтра в VectorTarget
    VectorTarget:OrderFilter(filterTable)
    
    -- Получение юнита и цели
    local unit = filterTable.units and filterTable.units["0"] and EntIndexToHScript(filterTable.units["0"])
    local target = filterTable.entindex_target ~= 0 and EntIndexToHScript(filterTable.entindex_target) or nil
    local orderType = filterTable.order_type

    -- Проверка модификаторов, блокирующих определенные действия
    if unit then

        -- mods onorder
        for _, order_modifier in pairs(_G.ORDERS_MODIFIERS_BIRZHA) do
            local order_modifier_handle = unit:FindModifierByName(order_modifier)
            if order_modifier_handle and order_modifier_handle.OnOrder then
                order_modifier_handle:OnOrder({unit = unit, new_pos = Vector(filterTable.position_x, filterTable.position_y, filterTable.position_z), target = target, order_type = orderType})
            end
        end

        -- Модификатор fut_mum_eat_caster - блокирует телепортацию
        if unit:HasModifier("modifier_fut_mum_eat_caster") and 
           orderType == DOTA_UNIT_ORDER_CAST_POSITION then
            local ability = filterTable.entindex_ability and EntIndexToHScript(filterTable.entindex_ability)
            if ability and ability:GetAbilityName() == "item_tpscroll" then
                return false
            end
        end

        -- Модификатор JohnCena_Grabbed_buff - аналогично блокирует телепортацию
        if unit:HasModifier("modifier_JohnCena_Grabbed_buff") and 
           orderType == DOTA_UNIT_ORDER_CAST_POSITION then
            local ability = filterTable.entindex_ability and EntIndexToHScript(filterTable.entindex_ability)
            if ability and ability:GetAbilityName() == "item_tpscroll" then
                return false
            end
        end

        -- Модификатор serega_pirat_bike_cast - блокирует несколько типов действий
        if unit:HasModifier("modifier_serega_pirat_bike_cast") then
            local LOCKED_ORDERS = {
                [DOTA_UNIT_ORDER_DROP_ITEM] = true,
                [DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
                [DOTA_UNIT_ORDER_CAST_POSITION] = true,
            }
            if LOCKED_ORDERS[orderType] then
                return false
            end
        end
    end

    -- Специальные звуки при движении для Sasake
    if orderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION and 
       unit and unit:IsRealHero() and unit:GetUnitName() == "npc_dota_hero_sasake" then
        if RollPercentage(5) then
            unit:EmitSound("sasake_move")
        end
    end

    local orders = 
    {
        [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true, 
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
        [DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
        [DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,
        [DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
        [DOTA_UNIT_ORDER_PICKUP_RUNE] = true,
    }

    if unit and unit:HasModifier("modifier_custom_ability_teleport") then
        local ability = filterTable.entindex_ability and EntIndexToHScript(filterTable.entindex_ability)
        if orders[orderType] == true then 
            if orderType ~= DOTA_UNIT_ORDER_CAST_NO_TARGET then 
                return false
            end
        end
    end

    -- Обработка CAST_TARGET заказов
    if orderType == DOTA_UNIT_ORDER_CAST_TARGET then
        local ability = filterTable.entindex_ability and EntIndexToHScript(filterTable.entindex_ability)
        local target = filterTable.entindex_target and EntIndexToHScript(filterTable.entindex_target)
        
        if not ability or not target then return true end

        -- Проверка способностей с особыми условиями
        local ABILITY_CHECKS = {
            ["gorshok_writer_goodwin"] = function()
                if unit:GetPlayerOwnerID() ~= target:GetPlayerOwnerID() then
                    DisplayError(unit:GetPlayerID(), "#dota_hud_error_not_your_unit")
                    return false
                end
                return true
            end,
            ["haku_help"] = function()
                if unit == target then
                    DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
                    return false
                end
                return true
            end,
            ["van_threehundredbucks"] = function()
                if unit == target then
                    DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
                    return false
                end
                return true
            end,
            ["pucci_erace_disk"] = function()
                if unit == target then
                    DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
                    return false
                end
                return true
            end,
            ["migi_inside"] = function()
                if unit == target then
                    DisplayError(unit:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
                    return false
                end
                return true
            end
        }

        local checkFunc = ABILITY_CHECKS[ability:GetAbilityName()]
        if checkFunc and not checkFunc() then
            return false
        end

        -- Обработка тыквенных конфет
        if target and target:IsBaseNPC() and target:GetUnitName() == "npc_pumpkin_candies_custom" and unit:IsRealHero() then
            if unit:HasModifier("modifier_order_cast") or unit:IsChanneling() then 
                return false 
            end
            unit:AddNewModifier(unit, nil, "modifier_order_cast", {target = target:entindex()})
            return false
        end
    end

    -- Обработка подбора предметов
    if orderType == DOTA_UNIT_ORDER_PICKUP_ITEM and filterTable.issuer_player_id_const ~= -1 then
        local item = filterTable.entindex_target and EntIndexToHScript(filterTable.entindex_target)
        if not item then return true end
        
        local pickedItem = item:GetContainedItem()
        if not pickedItem then return true end

        -- Проверка условий для изменения порядка на перемещение
        local shouldChangeToMove = false
        local itemName = pickedItem:GetAbilityName()

        if (unit:IsCourier() or not unit:IsRealHero()) and 
           (itemName == "item_bag_of_gold_event" or itemName == "item_bag_of_gold" or itemName == "item_treasure_chest") then
            shouldChangeToMove = true
        elseif itemName == "item_treasure_chest" and unit:IsRealHero() and unit:GetNumItemsInInventory() >= 9 then
            shouldChangeToMove = true
        elseif pickedItem.is_cooldown_take then
            shouldChangeToMove = true
        end

        if shouldChangeToMove then
            local position = item:GetAbsOrigin()
            filterTable.position_x = position.x
            filterTable.position_y = position.y
            filterTable.position_z = position.z
            filterTable.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
            return true
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