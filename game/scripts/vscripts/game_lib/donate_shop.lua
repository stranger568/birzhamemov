if donate_shop == nil then
	donate_shop = class({})
end

require("game_lib/donate_info")

function donate_shop:BuyItem(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local item_id = data.item_id
	local price = data.price
	local currency = data.currency
	local player =	PlayerResource:GetPlayer(id)
	local player_donate_table = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].server_data
	local change_bitcoin_currency = 0
	local change_dogecoin_currency = 0

    -- Если покупка за донат валюту
	if tostring(currency) == "gold" then
		if tonumber(player_donate_table.birzha_coin) >= tonumber(price) then
			player_donate_table.birzha_coin = player_donate_table.birzha_coin - tonumber(price)
			change_bitcoin_currency = tonumber(price) * -1
			-- Если покупается валюта
			if (item_id == "0") then
				player_donate_table.doge_coin = player_donate_table.doge_coin + tonumber(price)
				change_dogecoin_currency = tonumber(price)
			else
				table.insert(player_donate_table.player_items, item_id)
			end
            CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
            CustomNetTables:SetTableValue('birzhashop', tostring(id), {doge_coin = player_donate_table.doge_coin, birzha_coin = player_donate_table.birzha_coin, player_items = player_donate_table.player_items})
            CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
		else
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_bitcoin"} )
			return
		end
	elseif tostring(currency) == "gem" then
		if tonumber(player_donate_table.doge_coin) >= tonumber(price) then
			player_donate_table.doge_coin = player_donate_table.doge_coin - tonumber(price)
			change_dogecoin_currency = tonumber(price) * -1
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
			table.insert(player_donate_table.player_items, item_id)
			CustomNetTables:SetTableValue('birzhashop', tostring(id), {doge_coin = player_donate_table.doge_coin, birzha_coin = player_donate_table.birzha_coin, player_items = player_donate_table.player_items})
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
		else
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_dogecoin"} )
			return
		end
	end

	local post_data = {
		player = {
			{
				steamid = PlayerResource:GetSteamAccountID(id),
				player_bitcoin = change_bitcoin_currency,
				player_dogecoin = change_dogecoin_currency,
				item_id = item_id,
			}
		},
	}

	SendData('https://' ..BirzhaData.url .. '/data/bm_post_buy_item.php', post_data, nil)
end

function donate_shop:AddPetFromStart(id)
    local player = PlayerResource:GetPlayer(id)
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    local pet_id = player_info.server_data.pet_id
    local hero = player_info.selected_hero
    if hero and hero:GetUnitName() ~= "npc_dota_hero_wisp" and pet_id ~= 0 and pet_id ~= "0" then
        if player_info.steamid == 113370083 then
            pet_id = "Insane"
        end
        hero.pet = CreateUnitByName("unit_premium_pet", hero:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, hero, nil, hero:GetTeamNumber())
        hero.pet:SetOwner(hero)
        local modifier_birzha_pet = hero.pet:AddNewModifier( hero.pet, nil, "modifier_birzha_pet", {} )
        hero.pet:SetModel(BIRZHA_PETS_LIST[pet_id].model)
        hero.pet:SetOriginalModel(BIRZHA_PETS_LIST[pet_id].model)
        if BIRZHA_PETS_LIST[pet_id].effect ~= nil then
            hero.pet.particle = ParticleManager:CreateParticle(BIRZHA_PETS_LIST[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)
            if modifier_birzha_pet and hero.pet.particle then
                modifier_birzha_pet:AddParticle(hero.pet.particle, false, false, -1, false, false)
            end
        end
        if pet_id == "Insane" then
            hero.pet:SetModelScale(0.6)
        end
        if BIRZHA_PETS_LIST[pet_id].bonus_model ~= nil then
            local cosmetic_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = BIRZHA_PETS_LIST[pet_id].bonus_model})
            cosmetic_item:FollowEntity(hero.pet, true)
        end	
    end
end

-- Смена питомца
function donate_shop:ChangePetPremium(data)
    if data.PlayerID == nil then return end
    local id = data.PlayerID			
    local player =	PlayerResource:GetPlayer(id)
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    local pet_id = tonumber(data.pet_id)
    local hero = player_info.selected_hero
    --
    if hero == nil or hero:GetUnitName() == "npc_dota_hero_wisp" then
        if data.delete_pet == 0 then
            player_info.server_data.pet_id = pet_id
        else
            player_info.server_data.pet_id = nil
        end
        CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_info.server_data)
        return
    end
    --
    if hero.pet and hero.pet ~= nil then
        if data.delete_pet == 0 then
            player_info.server_data.pet_id = pet_id
            hero.pet:SetModel(BIRZHA_PETS_LIST[pet_id].model)
            hero.pet:SetOriginalModel(BIRZHA_PETS_LIST[pet_id].model)
            if hero.pet.particle then
                ParticleManager:DestroyParticle(hero.pet.particle, true)
                ParticleManager:ReleaseParticleIndex(hero.pet.particle)
            end
            if hero.pet.cosmetic_item then
                hero.pet.cosmetic_item:Destroy()
                hero.pet.cosmetic_item = nil
            end
            if BIRZHA_PETS_LIST[pet_id].effect ~= nil then
                hero.pet.particle = ParticleManager:CreateParticle(BIRZHA_PETS_LIST[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)	
                local modifier_birzha_pet = hero.pet:FindModifierByName("modifier_birzha_pet")
                if modifier_birzha_pet and hero.pet.particle then
                    modifier_birzha_pet:AddParticle(hero.pet.particle, false, false, -1, false, false)
                end
            end
            if BIRZHA_PETS_LIST[pet_id].bonus_model ~= nil then
                hero.pet.cosmetic_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = BIRZHA_PETS_LIST[pet_id].bonus_model})
                hero.pet.cosmetic_item:FollowEntity(hero.pet, true)
            end	
        else
            UTIL_Remove(hero.pet)
            hero.pet = nil
            player_info.server_data.pet_id = nil
        end
    else
        player_info.server_data.pet_id = pet_id
        donate_shop:AddPetFromStart(id)
    end
    CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_info.server_data)
end
-- Смена рамки
function donate_shop:change_border_effect(data)
    if data.PlayerID == nil then return end
    local id = data.PlayerID
    local border_id = tonumber(data.border_id)
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if data.delete_pet == 0 then
        player_info.server_data.border_id = border_id
    else
        player_info.server_data.border_id = nil 
    end
    CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_info.server_data)
end
-- Смена эффекта
function donate_shop:change_hero_effect(data)
    if data.PlayerID == nil then return end
    local id = data.PlayerID
    local effect_id = tonumber(data.effect_id)
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    local hero = player_info.selected_hero
    if hero == nil or hero:GetUnitName() == "npc_dota_hero_wisp" then
        if data.delete_pet == 0 then
            player_info.server_data.effect_id = effect_id
        else
            player_info.server_data.effect_id = nil
        end
        CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_info.server_data)
        return
    end
    if data.delete_pet == 0 then
        player_info.server_data.effect_id = effect_id
    else
        player_info.server_data.effect_id = nil 
    end
    --hero:AddDonate(id)
    CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_info.server_data)
end

function DonateShopIsItemBought(id, item)
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
	local player_shop_table_items = player_info.server_data.player_items
    for _, item_id in pairs(player_shop_table_items) do
        if tostring(item_id) == tostring(item) then
            return true
        end
    end
	return false
end

function donate_shop:SelectVO(keys)
	if keys.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(keys.PlayerID)
    if not IsInToolsMode() then
        if not DonateShopIsItemBought(keys.PlayerID, keys.num) then return end
    end
    local current_chatwheel_event = tostring(keys.num)
    if BIRZHA_CHAT_WHEEL_EVENTS[current_chatwheel_event] == nil then return end
    local event_info = BIRZHA_CHAT_WHEEL_EVENTS[current_chatwheel_event]

    if event_info["type"] == "sound" then
        if player.sound_use_one == nil then
            player.sound_use_one = 0
        end
        if player.sound_use_two == nil then
            player.sound_use_two = 0
        end
        if (player.sound_use_one and player.sound_use_one > 0) and (player.sound_use_two and player.sound_use_two > 0) then
            local player = PlayerResource:GetPlayer(keys.PlayerID)
            if player then
                local cooldown_sound = math.max(player.sound_use_one, player.sound_use_two)
                CustomGameEventManager:Send_ServerToPlayer(player, "panorama_cooldown_error", {message="#birzha_sound_error", time=cooldown_sound})
            end
            EmitSoundOnClient("General.Cancel", player)
            return
        end
        if not IsInToolsMode() then
            if player.sound_use_one > 0 then
                player.sound_use_two = 30
                Timers:CreateTimer({
                useGameTime = false,
                endTime = 1,
                callback = function()
                        if player.sound_use_two <= 0 then return nil end
                    player.sound_use_two = player.sound_use_two - 1
                    return 1
                end
            })
            else
            player.sound_use_one = 30
            Timers:CreateTimer({
                useGameTime = false,
                endTime = 1,
                callback = function()
                    if player.sound_use_one <= 0 then return nil end
                    player.sound_use_one = player.sound_use_one - 1
                    return 1
                end
            })
            end
        end
        local sound_name = "item_wheel_"..current_chatwheel_event
		local hero_name = ""
        local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
        if hero then
            hero_name = hero:GetUnitName()
        end
		CustomGameEventManager:Send_ServerToAllClients( 'chat_birzha_sound', {hero_name = hero_name, player_id = keys.PlayerID, sound_name = event_info["localize"], sound_name_global = sound_name})
    elseif event_info["type"] == "spray" then
        if player.spray_use_one == nil then
            player.spray_use_one = 0
        end
        if player.spray_use_two == nil then
            player.spray_use_two = 0
        end
        if (player.spray_use_one and player.spray_use_one > 0) and (player.spray_use_two and player.spray_use_two > 0) then
            local player = PlayerResource:GetPlayer(keys.PlayerID)
            if player then
                local cooldown_sound = math.min(player.spray_use_one, player.spray_use_two)
                CustomGameEventManager:Send_ServerToPlayer(player, "panorama_cooldown_error", {message="#birzha_spray_error", time=cooldown_sound})
            end
            EmitSoundOnClient("General.Cancel", player)
            return
        end
        if not IsInToolsMode() then
            if player.spray_use_one > 0 then
                player.spray_use_two = 10
                Timers:CreateTimer({
                    useGameTime = false,
                    endTime = 1,
                    callback = function()
                        if player.spray_use_two <= 0 then return nil end
                        player.spray_use_two = player.spray_use_two - 1
                        return 1
                    end
                })
            else
                player.spray_use_one = 10
                Timers:CreateTimer({
                    useGameTime = false,
                    endTime = 1,
                    callback = function()
                        if player.spray_use_one <= 0 then return nil end
                        player.spray_use_one = player.spray_use_one - 1
                        return 1
                    end
                })
            end
        end
        local spray_name = "item_wheel_"..current_chatwheel_event
		local spray = ParticleManager:CreateParticle("particles/birzhapass/"..spray_name..".vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl( spray, 0, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetOrigin() )
		ParticleManager:ReleaseParticleIndex( spray )
		PlayerResource:GetSelectedHeroEntity(keys.PlayerID):EmitSound("Spraywheel.Paint")
    elseif event_info["type"] == "toy" then
        if player.toy_use_one == nil then
            player.toy_use_one = 0
        end
        if player.toy_use_two == nil then
            player.toy_use_two = 0
        end
        if (player.toy_use_one and player.toy_use_one > 0) and (player.toy_use_two and player.toy_use_two > 0) then
            local player = PlayerResource:GetPlayer(keys.PlayerID)
            if player then
                local cooldown_sound = math.min(player.toy_use_one, player.toy_use_two)
                CustomGameEventManager:Send_ServerToPlayer(player, "panorama_cooldown_error", {message="#birzha_toy_error", time=cooldown_sound})
            end
            EmitSoundOnClient("General.Cancel", player)
            return
        end
        if not IsInToolsMode() then
            if player.toy_use_one > 0 then
                  player.toy_use_two = 60
                  Timers:CreateTimer({
                    useGameTime = false,
                    endTime = 1,
                    callback = function()
                    if player.toy_use_two <= 0 then return nil end
                        player.toy_use_two = player.toy_use_two - 1
                        return 1
                    end
                })
            else
                  player.toy_use_one = 60
                  Timers:CreateTimer({
                    useGameTime = false,
                    endTime = 1,
                    callback = function()
                    if player.toy_use_one <= 0 then return nil end
                        player.toy_use_one = player.toy_use_one - 1
                        return 1
                    end
                 })
            end
        end
        if current_chatwheel_event == "124" then
            local toy_unit = CreateUnitByName("npc_dota_blinoid_shop", PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetAbsOrigin() + PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetForwardVector() * 50, true, PlayerResource:GetSelectedHeroEntity(keys.PlayerID), nil, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetTeamNumber())
            toy_unit:SetDayTimeVisionRange(0)
            toy_unit:SetNightTimeVisionRange(0)
            toy_unit:AddNewModifier(toy_unit, nil, "modifier_blinoid_shop", {duration = 30})
        end
        if current_chatwheel_event == "125" then
            local toy_unit = CreateUnitByName("npc_dota_penguin_shop", PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetAbsOrigin() + PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetForwardVector() * 50, true, PlayerResource:GetSelectedHeroEntity(keys.PlayerID), nil, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetTeamNumber())
            toy_unit:SetDayTimeVisionRange(0)
            toy_unit:SetNightTimeVisionRange(0)
            toy_unit:AddNewModifier(toy_unit, nil, "modifier_penguin_shop", {duration = 30})
        end
        if current_chatwheel_event == "184" then
            PlayerResource:GetSelectedHeroEntity(keys.PlayerID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(keys.PlayerID), nil, "modifier_birzha_high_five", {duration = 20})
        end
    end
end

function donate_shop:SelectChatWheel(keys)
	if keys.PlayerID == nil then return end
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[keys.PlayerID]
	local id_chatwheel = tostring(keys.id)
	local item_chatwheel = tostring(keys.item)
	local player_table = CustomNetTables:GetTableValue('birzhainfo', tostring(keys.PlayerID))
	if player_table and player_info then
		if player_info.server_data.chat_wheel then
			local player_chat_wheel_change = {}
			for k, v in pairs(player_info.server_data.chat_wheel) do
		        player_chat_wheel_change[k] = v
		    end
		    player_chat_wheel_change[id_chatwheel] = item_chatwheel
		    player_table.chat_wheel = player_chat_wheel_change
		    CustomNetTables:SetTableValue('birzhainfo', tostring(keys.PlayerID), player_table)
		end
	end
end

function donate_shop:PlayerTip(keys)
    local cooldown = 60
    if IsInToolsMode() then
        cooldown = 1
    end
    local id_caster = keys.PlayerID
    local id_target = keys.player_id_tip
    CustomGameEventManager:Send_ServerToAllClients( 'TipPlayerNotification', {player_id_1 = id_caster, player_id_2 = id_target, type = RandomInt(1, 16)})
    CustomNetTables:SetTableValue("tip_cooldown", tostring(id_caster), {cooldown = cooldown})
    Timers:CreateTimer(1, function()
        cooldown = cooldown - 1
        CustomNetTables:SetTableValue("tip_cooldown", tostring(id_caster), {cooldown = cooldown})
        if cooldown <= 0 then return nil end
        return 1
    end)
end

function donate_shop:SelectSmile(keys)
    if keys.PlayerID == nil then return end
    if DonateShopIsItemBought(keys.PlayerID, keys.id) then
        local player = PlayerResource:GetPlayer(keys.PlayerID)
        if player.smile_cooldown == nil then
            player.smile_cooldown = 0
        end
        if player.smile_cooldown and player.smile_cooldown > 0 then
            if player then
                CustomGameEventManager:Send_ServerToPlayer(player, "panorama_cooldown_error", {message="#bm_smile_cooldown", time=player.smile_cooldown})
            end
            return
        end
        player.smile_cooldown = 5
        Timers:CreateTimer(1, function() 
            if player.smile_cooldown <= 0 then return nil end
            player.smile_cooldown = player.smile_cooldown - 1
            return 1
        end)
        local hero_name = ""
        local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
        if hero then
            hero_name = hero:GetUnitName()
        end
        CustomGameEventManager:Send_ServerToAllClients( 'chat_bm_smile', {hero_name = hero_name, player_id = keys.PlayerID, smile_icon = keys.smile_icon})
    end
end

function donate_shop:AddedDonateStart(player, playerID)
	if DonateShopIsItemBought(playerID, 41) then
		player:AddNewModifier( player, nil, "modifier_bp_effects_reward", {})
	end
	if DonateShopIsItemBought(playerID, 23) then
		local sound_kill_reward =    
        {
		    ['npc_dota_hero_ogre_magi'] = true,
		    ['npc_dota_hero_earthshaker'] = true,
		}
		if sound_kill_reward[player:GetUnitName()] then
			player:AddNewModifier(player, nil, 'modifier_birzhapass_sound', {})
		end 
	end
end