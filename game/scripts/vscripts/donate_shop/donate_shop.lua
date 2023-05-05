if donate_shop == nil then
	donate_shop = class({})
end

LinkLuaModifier("modifier_blinoid_shop", "modifiers/modifier_blinoid_shop", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_penguin_shop", "modifiers/modifier_penguin_shop", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_birzha_high_five", "modifiers/modifier_birzha_high_five", LUA_MODIFIER_MOTION_NONE)

function donate_shop:BuyItem(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local item_id = data.item_id
	local price = data.price
	local currency = data.currency
	local player =	PlayerResource:GetPlayer(id)
	local player_donate_table = CustomNetTables:GetTableValue('birzhashop', tostring(id))

	local change_bitcoin_currency = 0
	local change_dogecoin_currency = 0

	-- Прогрузка текущих предметов у игрока --
	local player_items_table = {}
	for k, v in pairs(player_donate_table.player_items) do
        table.insert(player_items_table, v)
    end

    -- Если покупка за донат валюту
	if tostring(currency) == "gold" then
		if tonumber(player_donate_table.birzha_coin) >= tonumber(price) then
			player_donate_table.birzha_coin = player_donate_table.birzha_coin - tonumber(price)
			change_bitcoin_currency = tonumber(price) * -1
			-- Если покупается валюта

			if (item_id == "21") then
				local player_table_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
				if player_table_info then
					BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].bp_days = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].bp_days + 30
					player_table_info.bp_days = player_table_info.bp_days + 30
					CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_table_info)
				end
			end
			if (item_id == "135") then
				local player_table_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
				if player_table_info then
					BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].bp_days = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].bp_days + 180
					player_table_info.bp_days = player_table_info.bp_days + 180
					CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_table_info)
				end
			end 

			if (item_id == "0") then
				player_donate_table.doge_coin = player_donate_table.doge_coin + tonumber(price)
				change_dogecoin_currency = tonumber(price)
				CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
				CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)
				CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
			else
				CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
				table.insert(player_items_table, item_id)
				player_donate_table.player_items = player_items_table
				CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)
				CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
			end
		else
			print("ошибка биткоинов мало")
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_bitcoin"} )
			return
		end
	elseif tostring(currency) == "gem" then
		if tonumber(player_donate_table.doge_coin) >= tonumber(price) then
			player_donate_table.doge_coin = player_donate_table.doge_coin - tonumber(price)
			change_dogecoin_currency = tonumber(price) * -1
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
			table.insert(player_items_table, item_id)
			player_donate_table.player_items = player_items_table
			CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)
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

function donate_shop:PreOrderBattlePass(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local currency = data.currency
	local player =	PlayerResource:GetPlayer(id)
	local player_donate_table = CustomNetTables:GetTableValue('birzhashop', tostring(id))
	local change_bitcoin_currency = 0
	local change_dogecoin_currency = 0


	print(currency)
    -- Если покупка за донат валюту
	if tostring(currency) == "gold" then
		if tonumber(player_donate_table.birzha_coin) >= 6000 then
			change_bitcoin_currency = -6000
			player_donate_table.birzha_coin = player_donate_table.birzha_coin - 6000

			local player_table_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
			if player_table_info then
				player_table_info.has_battlepass = 1
				CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_table_info)
			end
			CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
		else
			print("ошибка биткоинов мало")
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_bitcoin"} )
			return
		end
	elseif tostring(currency) == "gem" then
		if tonumber(player_donate_table.doge_coin) >= 12000 then
			change_dogecoin_currency = -12000
			player_donate_table.doge_coin = player_donate_table.doge_coin - 12000

			local player_table_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
			if player_table_info then
				player_table_info.has_battlepass = 1
				CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_table_info)
			end
			CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
		else
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_dogecoin"} )
			return
		end
	end

	local post_data = 
	{
		player = 
		{
			{
				steamid = PlayerResource:GetSteamAccountID(id),
				player_bitcoin = change_bitcoin_currency,
				player_dogecoin = change_dogecoin_currency,
			}
		},
	}

	SendData('https://' ..BirzhaData.url .. '/data/bm_post_buy_battlepass.php', post_data, nil)
end

function donate_shop:donate_shop_bp_levels(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local levels = tonumber(data.levels)
	local player =	PlayerResource:GetPlayer(id)
	local player_donate_table = CustomNetTables:GetTableValue('birzhashop', tostring(id))
	local change_bitcoin_currency = 0
	local change_dogecoin_currency = 0

	local cost = levels * 150
	local exp = levels * 1000

    -- Если покупка за донат валюту
	if tonumber(player_donate_table.birzha_coin) >= cost then
		change_bitcoin_currency = -cost
		player_donate_table.birzha_coin = player_donate_table.birzha_coin - cost

		local player_table_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
		if player_table_info then
			player_table_info.battlepass_level = player_table_info.battlepass_level + exp
			CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_table_info)
		end

		CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)
		CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )
		CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
	else
		print("ошибка биткоинов мало")
		CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_bitcoin"} )
		return
	end

	local post_data = 
	{
		player = 
		{
			{
				steamid = PlayerResource:GetSteamAccountID(id),
				player_bitcoin = change_bitcoin_currency,
				bonus_exp = exp,
			}
		},
	}

	SendData('https://' ..BirzhaData.url .. '/data/bm_post_buy_battlepass_levels.php', post_data, nil)
end

function DonateShopIsItemBought(id, item)
	local player_shop_table = CustomNetTables:GetTableValue("birzhashop", tostring(id))
	if player_shop_table then
		local player_shop_table_items = player_shop_table.player_items
		for _, item_id in pairs(player_shop_table_items) do
			if tostring(item_id) == tostring(item) then
				return true
			end
		end
		return false
	end
	return false
end

--- ПИТОМЦЫ ----

MEMESPASS_PREMIUM_PETS = {}
MEMESPASS_PREMIUM_PETS[1] = {
	effect = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf", model = "models/courier/baby_rosh/babyroshan.vmdl"
}
MEMESPASS_PREMIUM_PETS[2] = {
	effect = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", model = "models/courier/donkey_trio/mesh/donkey_trio.vmdl"
}
MEMESPASS_PREMIUM_PETS[3] = {
	effect = "particles/econ/courier/courier_mechjaw/courier_mechjaw_ambient.vpcf", model = "models/courier/mechjaw/mechjaw.vmdl"
}
MEMESPASS_PREMIUM_PETS[4] = {
	effect = "particles/econ/courier/courier_huntling_gold/courier_huntling_gold_ambient.vpcf", model = "models/courier/huntling/huntling.vmdl"
}
MEMESPASS_PREMIUM_PETS[5] = {
	effect = "particles/econ/courier/courier_devourling/courier_devourling_ambient.vpcf", model = "models/items/courier/devourling/devourling.vmdl"
}
MEMESPASS_PREMIUM_PETS[6] = {
	effect = "particles/econ/courier/courier_seekling_gold/courier_seekling_gold_ambient.vpcf", model = "models/courier/seekling/seekling.vmdl"
}
MEMESPASS_PREMIUM_PETS[7] = {
	effect = "particles/econ/courier/courier_venoling/courier_venoling_ambient.vpcf", model = "models/courier/venoling/venoling.vmdl"
}
MEMESPASS_PREMIUM_PETS[8] = {
	effect = "particles/econ/courier/courier_amaterasu/courier_amaterasu_ambient.vpcf", model = "models/items/courier/amaterasu/amaterasu.vmdl"
}
MEMESPASS_PREMIUM_PETS[9] = {
	effect = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", model = "models/items/courier/beaverknight_s2/beaverknight_s2.vmdl"
}
MEMESPASS_PREMIUM_PETS[10] = {
	effect = "particles/econ/courier/courier_nian/courier_nian_ambient.vpcf", model = "models/items/courier/nian_courier/nian_courier.vmdl"
}
MEMESPASS_PREMIUM_PETS[11] = {
	effect = "particles/econ/courier/courier_faceless_rex/cour_rex_flying.vpcf", model = "models/items/courier/faceless_rex/faceless_rex.vmdl"
}
MEMESPASS_PREMIUM_PETS[12] = {
	effect = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", model = "models/pets/icewrack_wolf/icewrack_wolf.vmdl"
}
MEMESPASS_PREMIUM_PETS[13] = {
	effect = "particles/econ/courier/courier_minipudge/courier_minipudge_ambient.vpcf", model = "models/courier/minipudge/minipudge.vmdl"
}
MEMESPASS_PREMIUM_PETS[14] = {
	effect = "particles/econ/courier/courier_shagbark/courier_shagbark_ambient.vpcf", model = "models/items/courier/shagbark/shagbark.vmdl"
}
MEMESPASS_PREMIUM_PETS[15] = {
	effect = "particles/econ/courier/courier_ti10/courier_ti10_lvl6_dire_ambient.vpcf", model = "models/items/courier/courier_ti10_radiant/courier_ti10_radiant_lvl6/courier_ti10_radiant_lvl6.vmdl"
}
MEMESPASS_PREMIUM_PETS[16] = {
	effect = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", model = "models/items/courier/mango_the_courier/mango_the_courier.vmdl"
}
MEMESPASS_PREMIUM_PETS[17] = {
	effect = "particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient.vpcf", model = "models/items/courier/axolotl/axolotl.vmdl"
}
MEMESPASS_PREMIUM_PETS[18] = {
	effect = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", model = "models/items/courier/teron/teron.vmdl"
}
MEMESPASS_PREMIUM_PETS[19] = {
	effect = "particles/econ/courier/courier_lockjaw/courier_lockjaw_ambient.vpcf", model = "models/courier/lockjaw/lockjaw.vmdl"
}
MEMESPASS_PREMIUM_PETS[187] = {
	effect = "particles/econ/courier/courier_lockjaw/courier_lockjaw_ambient.vpcf", model = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", bonus_model = "models/skelet_head_roflan.vmdl"
}
MEMESPASS_PREMIUM_PETS[188] = {
	effect = "particles/econ/courier/courier_lockjaw/courier_lockjaw_ambient.vpcf", model = "models/items/wraith_king/arcana/wk_arcana_skeleton.vmdl", bonus_model = "models/skelet_head_ebalo.vmdl"
}
MEMESPASS_PREMIUM_PETS[189] = {
	model = "models/pets/amogus/amogus.vmdl"
}
MEMESPASS_PREMIUM_PETS[190] = {
	model = "models/pets/dingus/dingus.vmdl"
}
MEMESPASS_PREMIUM_PETS[191] = {
	model = "models/pets/pochita/pochitafinal.vmdl"
}
MEMESPASS_PREMIUM_PETS[192] = {
	model = "models/pets/squadgame/squadman.vmdl"
}
MEMESPASS_PREMIUM_PETS[193] = {
	model = "models/pets/megumin/megu.vmdl"
}
MEMESPASS_PREMIUM_PETS["Insane"] = {
	effect = "particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", model = "models/insane/insane.vmdl"
}

LinkLuaModifier( "modifier_birzha_pet", "modifiers/modifier_birzha_pet", LUA_MODIFIER_MOTION_NONE )

function donate_shop:ChangePetPremium(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local pet_id = tonumber(data.pet_id)				
	local player =	PlayerResource:GetPlayer(id)

	if player then
		local hero = player:GetAssignedHero()
		if hero:GetUnitName() ~= "npc_dota_hero_wisp" then
			if player.pet and player.pet ~= nil and data.delete_pet == 0 then
				PLAYERS[ id ].pet = pet_id
				if PLAYERS[ id ].steamid == 113370083 then
					pet_id = "Insane"
				end
				player.pet:SetModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
				player.pet:SetOriginalModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
				if player.pet.particle then
					ParticleManager:DestroyParticle(player.pet.particle, true)
				end
				if MEMESPASS_PREMIUM_PETS[pet_id].effect ~= nil then
					player.pet.particle = ParticleManager:CreateParticle(MEMESPASS_PREMIUM_PETS[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)	
				end
				if player.pet.cosmetic_item then
					player.pet.cosmetic_item:Destroy()
					player.pet.cosmetic_item = nil
				end
				if MEMESPASS_PREMIUM_PETS[pet_id].bonus_model ~= nil then
					player.pet.cosmetic_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = MEMESPASS_PREMIUM_PETS[pet_id].bonus_model})
					player.pet.cosmetic_item:FollowEntity(player.pet, true)
				end			
			elseif player.pet and player.pet ~= nil and data.delete_pet == 1 then
				UTIL_Remove(player.pet)
				player.pet = nil
				PLAYERS[ id ].pet = nil
			else
				PLAYERS[ id ].pet = pet_id
				if PLAYERS[ id ].steamid == 113370083 then
					pet_id = "Insane"
				end
				player.pet = CreateUnitByName("unit_premium_pet", hero:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, hero, nil, hero:GetTeamNumber())
				player.pet:SetOwner(hero)
				player.pet:AddNewModifier( player.pet, nil, "modifier_birzha_pet", {} )
				player.pet:SetModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
				player.pet:SetOriginalModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
				if MEMESPASS_PREMIUM_PETS[pet_id].effect ~= nil then
					player.pet.particle = ParticleManager:CreateParticle(MEMESPASS_PREMIUM_PETS[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)	
				end
				if pet_id == "Insane" then
					player.pet:SetModelScale(0.6)
				end
				if player.pet.cosmetic_item then
					player.pet.cosmetic_item:Destroy()
					player.pet.cosmetic_item = nil
				end
				if MEMESPASS_PREMIUM_PETS[pet_id].bonus_model ~= nil then
					player.pet.cosmetic_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = MEMESPASS_PREMIUM_PETS[pet_id].bonus_model})
					player.pet.cosmetic_item:FollowEntity(player.pet, true)
				end
			end
		end
	end
end

function donate_shop:AddPetFromStart(id)
	local pet_id = PLAYERS[ id ].pet
	local player =	PlayerResource:GetPlayer(id)

	if player then
		local hero = player:GetAssignedHero()
		if hero:GetUnitName() ~= "npc_dota_hero_wisp" then
			CustomGameEventManager:Send_ServerToPlayer(player, "set_player_pet_from_data", {pet_id = pet_id} )
			if PLAYERS[ id ].steamid == 113370083 then
				pet_id = "Insane"
			end
			player.pet = CreateUnitByName("unit_premium_pet", hero:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, hero, nil, hero:GetTeamNumber())
			player.pet:SetOwner(hero)
			player.pet:AddNewModifier( player.pet, nil, "modifier_birzha_pet", {} )
			player.pet:SetModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
			player.pet:SetOriginalModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
			if MEMESPASS_PREMIUM_PETS[pet_id].effect ~= nil then
				player.pet.particle = ParticleManager:CreateParticle(MEMESPASS_PREMIUM_PETS[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)	
			end
			if pet_id == "Insane" then
				player.pet:SetModelScale(0.6)
			end
			if MEMESPASS_PREMIUM_PETS[pet_id].bonus_model ~= nil then
				local cosmetic_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = MEMESPASS_PREMIUM_PETS[pet_id].bonus_model})
				cosmetic_item:FollowEntity(player.pet, true)
			end	
		end
	end
end


-- SOUNDS ----

function donate_shop:SelectVO(keys)
	if keys.PlayerID == nil then return end

	local sounds = {
		"52",
		"53",
		"54",
		"55",
		"56",
		"57",
		"58",
		"59",
		"60",
		"61",
		"62",
		"63",
		"64",
		"65",
		"66",
		"67",
		"68",
		"69",
		"70",
		"71",
		"72",
		"73",
		"74",
		"75",
		"76",
		"77",
		"78",
		"79",
		"80",
		"81",
		"82",
		"83",
		"84",
		"85",
		"86",
		"87",
		"113",
		"114",
		"118",
		"119",
		"120",
		"121",
		"122",
		"123",
		"131",
		"132",
		"133",
		"134",

		-- Лотерея
		"165",
		"166",
		"167",
		"168",
		"169",
		"170",
		"171",
		"172",
		"173",
		"174",
		"175",
		"176",
		"177",
		"178",

		-- Battle pass
		"202",
		"203",
		"204",
		"205",
		"206",
		"207",
		"208",
		"209",
		"210",
		"211",
		"212",
		"213",
		"214",
		"215",
		"216",
		"217",
		"218",
	}

	local sprays = {
		"88",
		"89",
		"90",
		"91",
		"92",
		"93",
		"94",
		"95",
		"96",
		"97",
		"98",
		"99",
		"100",
		"101",
		"102",
		"103",
		"104",
		"105",
		"106",
		"107",
		"108",
		"109",
		"110",
		"111",

		-- Battle Pass
		"249",
		"250",
		"251",
		"252",
		"253",
		"254",
	}

	local toys = {
		"124",
		"125",
		"184",
	}

	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if DonateShopIsItemBought(keys.PlayerID, keys.num) then
		for _,sound in pairs(sounds) do
			if tostring(keys.num) == tostring(sound) then

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
		
        		--if not IsInToolsMode() then
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
        		--end

				local sound_name = "item_wheel_"..keys.num

				local chat_sounds = {
					[52] = "Уху минус три",						
					[53] = "Heelp",	
					[54] = "Держи в курсе",						
					[55] = "Пацаны Вообще Ребята",
					[56] = "Где враги?",							
					[57] = "Опять Работа?",
					[58] = "Лох",
					[59] = "Да это жестко",
					[60] = "Я тут притаился",
					[61] = "Вы хули тут делаете?",
					[62] = "Убейте меня",
					[63] = "Большой член Большие яйца",
					[64] = "Cейчас зарежу",
					[65] = "Йобаный рот этого казино",
					[66] = "Шизофрения",
					[67] = "Я вас уничтожу",
					[68] = "Узнайте родителей этого ублюдка",
					[69] = "Майнкрафт моя жизнь",
					[70] = "Somebody once told me",
					[71] = "Коно Дио да",
					[72] = "Яре яре дазе",
					[73] = "Это Фиаско",
					[74] = "Помянем",
					[75] = "Пам парам",
					[76] = "Отдай сало",
					[77] = "Чел ты",
					[78] = "Крип крипочек",
					[79] = "Нахуй Эту игру",
					[80] = "Мясо для ебли",
					[81] = "Rage Daertc",
					[82] = "Голосование",
					[83] = "Что вы делаете в холодильнике?",
					[84] = "Народ погнали",
					[85] = "Fatality",
					[86] = "О повезло, повезло",
					[87] = "Балаанс",
					[113] = "Нет друг я не оправдываюсь",
					[114] = "Кто пиздел?",
					[118] = "Ахууеть",
					[119] = "Это просто ахуенно",
					[120] = "Ты что тупой?",
					[121] = "Расскажешь чел",
					[122] = "Босс качалки",
					[123] = "Разрабы пидорасы",

					[131] = "Дядя не надо",
					[132] = "Нет, долбоеб",
					[133] = "Похуй, нет, не похуй",
					[134] = "Смех.. DAMAGE!!",

					[165] = "Вот и все долбоеб",
					[166] = "Действительно, блять",
					[167] = "Ты убил моего клоуна",
					[168] = "Это ничего не значит",
					[169] = "Жестко наебал",
					[170] = "Welcome to the CUMzone",
					[171] = "Пошел нахуй гамбургер",
					[172] = "Вот и встретились дебилы",
					[173] = "Отдай шмотку",
					[174] = "Ну не надо, не стукай",
					[175] = "Okay, lets dance",
					[176] = "Алло, дайте покачаться",
					[177] = "Это моя команда",
					[178] = "Еврейский смех",

					[202] = "Что вы мужички творите",
					[203] = "Они зарабатывают миллионы",
					[204] = "Ты оскорбил анимешников",
					[205] = "Я не сосал член !",
					[206] = "Мать сдохла?",
					[207] = "С днем, великой победы",
					[208] = "Ну заплачь !",
					[209] = "Ныыа пид..",
					[210] = "Тупа мочим",
					[211] = "Дааа.. Нееет..",
					[212] = "1 человек - 9 хуесосов",
					[213] = "Как ты заебал",
					[214] = "Папагемабоди",
					[215] = "Ммм хуета",
					[216] = "Это база",
					[217] = "This is my perfect victory",
					[218] = "Осууждаю !!!",
				}

				local hero_name = ""
				local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
				if hero then
					hero_name = hero:GetUnitName()
				end

				CustomGameEventManager:Send_ServerToAllClients( 'chat_birzha_sound', {hero_name = hero_name, player_id = keys.PlayerID, sound_name = chat_sounds[keys.num], sound_name_global = sound_name})
			end
		end

		for _,spray in pairs(sprays) do
			if tostring(keys.num) == tostring(spray) then
				
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
		
        		--if not IsInToolsMode() then
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
        		--end


				local spray_name = "item_wheel_"..keys.num

				local spray = ParticleManager:CreateParticle("particles/birzhapass/"..spray_name..".vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl( spray, 0, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetOrigin() )
				ParticleManager:ReleaseParticleIndex( spray )
				PlayerResource:GetSelectedHeroEntity(keys.PlayerID):EmitSound("Spraywheel.Paint")
			end
		end

		for _,toy in pairs(toys) do
			if tostring(keys.num) == tostring(toy) then
				
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

        		--if not IsInToolsMode() then
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
        		--end

				if keys.num == 124 then
					local toy_unit = CreateUnitByName("npc_dota_blinoid_shop", PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetAbsOrigin() + PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetForwardVector() * 50, true, PlayerResource:GetSelectedHeroEntity(keys.PlayerID), nil, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetTeamNumber())
					toy_unit:SetDayTimeVisionRange(0)
					toy_unit:SetNightTimeVisionRange(0)
					toy_unit:AddNewModifier(toy_unit, nil, "modifier_blinoid_shop", {duration = 30})
				end
				if keys.num == 125 then
					local toy_unit = CreateUnitByName("npc_dota_penguin_shop", PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetAbsOrigin() + PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetForwardVector() * 50, true, PlayerResource:GetSelectedHeroEntity(keys.PlayerID), nil, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetTeamNumber())
					toy_unit:SetDayTimeVisionRange(0)
					toy_unit:SetNightTimeVisionRange(0)
					toy_unit:AddNewModifier(toy_unit, nil, "modifier_penguin_shop", {duration = 30})
				end
				if keys.num == 184 then
					PlayerResource:GetSelectedHeroEntity(keys.PlayerID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(keys.PlayerID), nil, "modifier_birzha_high_five", {duration = 20})
				end
			end
		end
	else
		EmitSoundOnClient("General.Cancel", player)
	end
end


function donate_shop:change_border_effect(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local border_id = tonumber(data.border_id)				
	local player =	PlayerResource:GetPlayer(id)

	if player then
		local hero = player:GetAssignedHero()
		if data.delete_pet == 0 then
			local table_hero = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
			if table_hero then
				table_hero.border_id = border_id
			end
			CustomNetTables:SetTableValue('birzhainfo', tostring(id), table_hero)
			PLAYERS[ id ].border = border_id					
		elseif data.delete_pet == 1 then
			local table_hero = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
			if table_hero then
				table_hero.border_id = nil
			end
			CustomNetTables:SetTableValue('birzhainfo', tostring(id), table_hero)
			PLAYERS[ id ].border = nil
		end
	end
end

function donate_shop:SelectChatWheel(keys)
	if keys.PlayerID == nil then return end
	local id_chatwheel = tostring(keys.id)
	local item_chatwheel = tostring(keys.item)
	local player_table = CustomNetTables:GetTableValue('birzhainfo', tostring(keys.PlayerID))
	if player_table then
		if player_table.chat_wheel then
			local player_chat_wheel_change = {}
			for k, v in pairs(player_table.chat_wheel) do
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

    donate_shop:QuestProgress(7, id_caster, 1)

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
        local player = PlayerResource:GetPlayer(keys.PlayerID)
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

function donate_shop:LotteryStart(keys)
    local playerid = keys.PlayerID
    local dogecoin_currency = 0
    local player_table_info = CustomNetTables:GetTableValue('birzhashop', tostring(playerid))

   	if player_table_info then
   	    dogecoin_currency = player_table_info.doge_coin
   	else
   	    local player = PlayerResource:GetPlayer(playerid)
   	    if player then
   	        CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {})
   	    end
   		return
   	end
    if dogecoin_currency >= 100 then
        player_table_info.doge_coin = player_table_info.doge_coin - 100
        CustomNetTables:SetTableValue("birzhashop", tostring(playerid), player_table_info)
        local player = PlayerResource:GetPlayer(playerid)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {})
        end
        print("запустил колесо")
        donate_shop:LotteryActivate(playerid)
      else
        local player = PlayerResource:GetPlayer(playerid)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {error_name = "shop_no_dogecoin"})
        end
    	return
    end
end

function donate_shop:LotteryActivate(id)
    local lottery_rewards = {
		136,
		137,
		138,
		139,
		140,
		141,
		142,
		143,
		144,
		145,
		146,
		147,
		148,
		149,
		150,
		151,
		152,
		153,
		154,
		155,
		156,
		157,
		158,
		159,
		160,
		162,
		163,

		--- Sounds
		166,
		168,
		169,
		170,
		171,
		172,
		174,
		175,
		176,
		177,
		178,
    }

    local rarity_items = {
		87,
		131,
		132,
		133,
		165,
		167,
		173,
    }

    local current_rewards = table.random_some(lottery_rewards, 30)

    if RollPercentage(25) then
    	current_rewards = table.random_some(lottery_rewards, 19)
    	current_rewards = table.join(current_rewards,rarity_items)
    end

    current_rewards = table.shuffle(current_rewards)

    local drop_reward = table.random_some(current_rewards, 1)[1]

	if RollPercentage(20) then
		local current_rewards_unique = table.deepcopy(current_rewards)
		for item_id_check = #current_rewards_unique, 1, -1 do
        	if current_rewards_unique[item_id_check] ~= nil then
				if DonateShopIsItemBought(id, current_rewards_unique[item_id_check]) then
					table.remove(current_rewards_unique, item_id_check)
				end
			end
		end
		if #current_rewards_unique >= 1 then
			drop_reward = table.random_some(current_rewards_unique, 1)[1]
			print("Выпадение нового предмета 100%")
		else
			drop_reward = table.random_some(current_rewards, 1)[1]
			print("Выпадение нового предмета 100%, но ты уже все получил")
		end
	end


    local visual = RandomInt(2400, 2535)

    local player = PlayerResource:GetPlayer(id)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "bm_start_lottery", {items_list = current_rewards, visual = visual, drop_reward = drop_reward, rarity_items = rarity_items})
    end

    local sound_check = 0
    Timers:CreateTimer(0.25, function()
    	local player = PlayerResource:GetPlayer(id)
	    if player then
	        CustomGameEventManager:Send_ServerToPlayer(player, "bm_lottery_sound_client", {})
	    end
	    sound_check = sound_check + 0.25
	    if sound_check >= 5 then
	    	return nil
	    else
	    	return 0.25
	    end
    end)

    Timers:CreateTimer(5.1, function()
    	donate_shop:GiveGiftPlayer(id, drop_reward)
    end)
end

function donate_shop:GiveGiftPlayer(id, item_id)
    local player_table_info = CustomNetTables:GetTableValue('birzhashop', tostring(id))
    local player_items_table = {}

    for k, v in pairs(player_table_info.player_items) do
        table.insert(player_items_table, v)
    end

    if DonateShopIsItemBought(id, item_id) then
      player_table_info.doge_coin = player_table_info.doge_coin + 50
      item_id = 0
    else
      table.insert(player_items_table, item_id)
      player_table_info.player_items = player_items_table
    end

    CustomNetTables:SetTableValue("birzhashop", tostring(id), player_table_info)

    local player = PlayerResource:GetPlayer(id)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "bm_reward_lottery", {item_id = item_id})
    end

    local post_data = {
		player = {
			{
				steamid = PlayerResource:GetSteamAccountID(id),
				item_id = item_id,
			}
		},
	}
	SendData('https://' ..BirzhaData.url .. '/data/bm_post_lottery_item.php', post_data, nil)
end


_G.Quest_Information = 
{
	--id, progress, exp
	--[[ 1 --]] {1, 5, 300}, -- Выиграть 5 игр
	--[[ 2 --]] {2, 50, 1500}, -- Выиграть 50 игр
	--[[ 3 --]] {3, 100, 3500}, -- Выиграть 100 игр
	--[[ 4 --]] {4, 5, 1000}, -- Занять топ 1 в режиме Solo 5 раз 
	--[[ 5 --]] {5, 25, 2000}, -- Занять топ 1 в режиме Solo 25 раз 
	--[[ 6 --]] {6, 50, 3000}, -- Занять топ 1 в режиме Solo 50 раз 
	--[[ 7 --]] {7, 100, 3000},  -- Похвалить игрока 100 раз
	--[[ 8 --]] {8, 322, 2500},  -- Убейте вражеского героя 322 раза
	--[[ 9 --]] {9, 100, 1000},  -- Получите 100 зарядов предмета Маска Гуля
	--[[ 10 --]] {10, 20000, 1000},  -- Восстановите 20000 здоровья
	--[[ 11 --]] {11, 120, 1500},  -- Продержите противника в оглушении 120 секунд
	--[[ 12 --]] {12, 25, 500},  -- Убейте 25 героев под действием Балдежа
	--[[ 13 --]] {13, 80000, 3000},  -- Нанесите 80000 урона подконтрольными юнитами
	--[[ 14 --]] {14, 160000, 1500},  -- Нанесите 160000 физического урона вражеским героям
	--[[ 15 --]] {15, 40000, 1500},  -- Нанесите 40000 чистого урона вражеским героям
	--[[ 16 --]] {16, 50000, 2000},  -- Нанесите 50000 урона вражеским героям с помощью Blade Mail
	--[[ 17 --]] {17, 80, 2500},  -- Установите 80 Sentry Wards
	--[[ 18 --]] {18, 50000, 3000},  -- Восстановите 50000 здоровья с помощью вампиризма
	--[[ 19 --]] {19, 80, 2500},  -- Установите 80 Observer Wards
	--[[ 20 --]] {20, 10, 5000},  -- Выиграйте 10 игр с двойной ставкой рейтинга
	--[[ 21 --]] {21, 40000, 750},  -- Восстановить 40000 маны
	--[[ 22 --]] {22, 25, 1200},  -- Отразите вражеский урон с помощью Нимб Лаптева 25 раз
	--[[ 23 --]] {23, 100, 1000},  -- Использовать предмет Рука Роскомнадзора 50 раз
	--[[ 24 --]] {24, 100, 1000},  -- Использовать любой Бургер 50 раз
	--[[ 25 --]] {25, 10, 500},  -- Использовать Шароебский Гем 10 раз
	--[[ 26 --]] {26, 150000, 1500},  -- Нанести 150000 критического урона магией
	--[[ 27 --]] {27, 100, 1000},  -- Использовать Кольцо Вентора 100 раз
	--[[ 28 --]] {28, 200, 500},  -- Использовать Force Boots или Blink Boots 200 раз
	--[[ 29 --]] {29, 40000, 700},  -- Нанести 40000 урона с помощью Mega Spinner
	--[[ 30 --]] {30, 20000, 3000},  -- Заработать 20000 золота от Bitcoin
	--[[ 31 --]] {31, 20000, 5000},  -- Простоять в кругу 10000 секунд
	--[[ 32 --]] {32, 50, 2000},  -- Подобрать сундук с предметом 30 раз
	--[[ 33 --]] {33, 3, 500},  -- Убить босса BristleKek 3 раза
	--[[ 34 --]] {34, 3, 500},  -- Убить босса LolBlade 3 раза
	--[[ 35 --]] {35, 20, 1500},  -- Убить Лидера 15 раз
	--[[ 36 --]] {36, 20, 500},  -- Выиграть тест играя за Big Russian Boss 20 раз
	--[[ 37 --]] {37, 10, 1000},  -- Убить противника В соляного играя за Папича 10 раз
	--[[ 38 --]] {38, 50, 750},  -- Попасть хуком играя за Жирная мамка 50 раз
	--[[ 39 --]] {39, 200, 750},  -- Остановить время играя за Куруми на 200 секунд
	--[[ 40 --]] {40, 999999, 5000},  -- Пройти расстояние 1000000 
	--[[ 41 --]] {41, 1000, 1500},  -- Набрать 1000 зарядов Я не тупой играя за Never
	--[[ 42 --]] {42, 100, 1500},  -- Набрать 100 зарядов Работа играя за Дядя Богдан
	--[[ 43 --]] {43, 15, 3500},  -- Убить противника на расстояние 2500 с помощью Grenade Launcher играя за Ranger 15 раз
	--[[ 44 --]] {44, 10, 1000},  -- Убить двух или более противников Космическим ослеплением играя за Зёма 10 раз
	--[[ 45 --]] {45, 20, 2000},  -- Попасть Метеором по двум целям играя за Мегумин 20 раз
	--[[ 46 --]] {46, 30, 1000},  -- Убить противника комбинацией Фура и Эль фура играя за Рам 30 раз
}

_G.Rewards_Information = 
{
	--item_id, bitcoins, is_sound, empty 
	--[[ 1 --]] {184, 0, 0, 0},
	--[[ 2 --]] {-1, 0, 0, 1},
	--[[ 3 --]] {187, 0, 0, 0},
	--[[ 4 --]] {-1, 0, 0, 1},
	--[[ 5 --]] {229, 100, 0, 0},
	--[[ 6 --]] {202, 0, 1, 0},
	--[[ 7 --]] {249, 0, 0, 0},
	--[[ 8 --]] {220, 0, 0, 0},
	--[[ 9 --]] {205, 0, 1, 0},
	--[[ 10 --]] {186, 0, 0, 0},
	--[[ 11 --]] {230, 100, 0, 0},
	--[[ 12 --]] {206, 0, 1, 0},
	--[[ 13 --]] {-1, 0, 0, 1},
	--[[ 14 --]] {250, 0, 0, 0},
	--[[ 15 --]] {188, 0, 0, 0},
	--[[ 16 --]] {231, 100, 0, 0},
	--[[ 17 --]] {221, 0, 0, 0},
	--[[ 18 --]] {214, 0, 1, 0},
	--[[ 19 --]] {-1, 0, 0, 1},
	--[[ 20 --]] {181, 0, 0, 0},
	--[[ 21 --]] {232, 100, 0, 0},
	--[[ 22 --]] {-1, 0, 0, 1},
	--[[ 23 --]] {222, 0, 0, 0},
	--[[ 24 --]] {251, 0, 0, 0},
	--[[ 25 --]] {195, 0, 0, 0},
	--[[ 26 --]] {233, 100, 0, 0},
	--[[ 27 --]] {189, 0, 0, 0},
	--[[ 28 --]] {215, 0, 1, 0},
	--[[ 29 --]] {-1, 0, 0, 1},
	--[[ 30 --]] {199, 0, 0, 0},
	--[[ 31 --]] {-1, 0, 0, 1},
	--[[ 32 --]] {223, 0, 0, 0},
	--[[ 33 --]] {211, 0, 1, 0},
	--[[ 34 --]] {-1, 0, 0, 1},
	--[[ 35 --]] {234, 100, 0, 0},
	--[[ 36 --]] {-1, 0, 0, 1},
	--[[ 37 --]] {216, 0, 1, 0},
	--[[ 38 --]] {-1, 0, 0, 1},
	--[[ 39 --]] {224, 0, 0, 0},
	--[[ 40 --]] {179, 0, 0, 0},
	--[[ 41 --]] {235, 100, 0, 0},
	--[[ 42 --]] {207, 0, 1, 0},
	--[[ 43 --]] {190, 0, 0, 0},
	--[[ 44 --]] {-1, 0, 0, 1},
	--[[ 45 --]] {201, 0, 0, 0},
	--[[ 46 --]] {208, 0, 1, 0},
	--[[ 47 --]] {252, 0, 0, 0},
	--[[ 48 --]] {-1, 0, 0, 1},
	--[[ 49 --]] {225, 0, 0, 0},
	--[[ 50 --]] {185, 0, 0, 0},
	--[[ 51 --]] {236, 100, 0, 0},
	--[[ 52 --]] {253, 0, 0, 0},
	--[[ 53 --]] {210, 0, 1, 0},
	--[[ 54 --]] {-1, 0, 0, 1},
	--[[ 55 --]] {237, 100, 0, 0},
	--[[ 56 --]] {192, 0, 0, 0},
	--[[ 57 --]] {238, 100, 0, 0},
	--[[ 58 --]] {212, 0, 1, 0},
	--[[ 59 --]] {226, 0, 0, 0},
	--[[ 60 --]] {183, 0, 0, 0},
	--[[ 61 --]] {-1, 0, 0, 1},
	--[[ 62 --]] {-1, 0, 0, 1},
	--[[ 63 --]] {239, 100, 0, 0},
	--[[ 64 --]] {204, 0, 1, 0},
	--[[ 65 --]] {-1, 0, 0, 1},
	--[[ 66 --]] {196, 0, 0, 0},
	--[[ 67 --]] {213, 0, 1, 0},
	--[[ 68 --]] {-1, 0, 0, 1},
	--[[ 69 --]] {227, 0, 0, 0},
	--[[ 70 --]] {200, 0, 0, 0},
	--[[ 71 --]] {240, 100, 0, 0},
	--[[ 72 --]] {-1, 0, 0, 1},
	--[[ 73 --]] {219, 0, 0, 0},
	--[[ 74 --]] {203, 0, 1, 0},
	--[[ 75 --]] {194, 0, 0, 0},
	--[[ 76 --]] {241, 100, 0, 0},
	--[[ 77 --]] {191, 0, 0, 0},
	--[[ 78 --]] {209, 0, 1, 0},
	--[[ 79 --]] {-1, 0, 0, 1},
	--[[ 80 --]] {182, 0, 0, 0},
	--[[ 81 --]] {242, 100, 0, 0},
	--[[ 82 --]] {218, 0, 1, 0},
	--[[ 83 --]] {254, 0, 0, 0},
	--[[ 84 --]] {-1, 0, 0, 1},
	--[[ 85 --]] {-1, 0, 0, 1},
	--[[ 86 --]] {197, 0, 0, 0},
	--[[ 87 --]] {243, 100, 0, 0},
	--[[ 88 --]] {-1, 0, 0, 1},
	--[[ 89 --]] {-1, 0, 0, 1},
	--[[ 90 --]] {244, 100, 0, 0},
	--[[ 91 --]] {-1, 0, 0, 1},
	--[[ 92 --]] {198, 0, 0, 0},
	--[[ 93 --]] {245, 100, 0, 0},
	--[[ 94 --]] {246, 100, 0, 0},
	--[[ 95 --]] {247, 100, 0, 0},
	--[[ 96 --]] {193, 0, 0, 0},
	--[[ 97 --]] {228, 0, 0, 0},
	--[[ 98 --]] {217, 0, 1, 0},
	--[[ 99 --]] {248, 100, 0, 0},
	--[[ 100 --]] {180, 0, 0, 0},
}

CustomNetTables:SetTableValue('battlepass_info', "quests", Quest_Information)
CustomNetTables:SetTableValue('battlepass_info', "rewards", Rewards_Information)

function donate_shop:QuestProgress(quest_id, player_id, count)

	if GameRules:IsCheatMode() and not IsInToolsMode() then return end

	local birzhainfo = CustomNetTables:GetTableValue('birzhainfo', tostring(player_id))
    if birzhainfo then
    	if birzhainfo.has_battlepass == 0 then
    		return
    	end
    else
    	return
    end

	local player_table_info = BirzhaData.PLAYERS_BATTLEPASS_INFROMATION[player_id]
	if player_table_info then

	    local quest_base = FindBirzhaQuest(quest_id)
	    if quest_base == nil then return end

	    if HasQuests(quest_id, player_id) then
	    	local quest_key = FindQuestKey(quest_id, player_table_info.quests_list)
	    	if quest_key ~= nil then
	    		player_table_info.quests_list[quest_key].quest_progress = math.min(tonumber(quest_base[2]), tonumber(player_table_info.quests_list[quest_key].quest_progress) + count)
	    		if tonumber(player_table_info.quests_list[quest_key].quest_progress) >= tonumber(quest_base[2]) then
	    			if tonumber(player_table_info.quests_list[quest_key].quest_complete) == 0 then
	    				player_table_info.quests_list[quest_key].quest_complete = 1
	    				player_table_info.new_battlepass_exp = player_table_info.new_battlepass_exp + quest_base[3]
	    				donate_shop:GiveExpInGame(player_id, quest_base[3])
	    			end
				end
	    	end
	    else
	    	local new_quest_info = {}
	    	new_quest_info.quest_id = quest_id
	    	new_quest_info.quest_progress = math.min(tonumber(quest_base[2]), tonumber(count))
	    	new_quest_info.quest_complete = 0
	    	if count >= quest_base[2] then
	    		new_quest_info.quest_complete = 1
	    		player_table_info.new_battlepass_exp = player_table_info.new_battlepass_exp + quest_base[3]
	    		donate_shop:GiveExpInGame(player_id, quest_base[3])
	    	end
	    	table.insert(player_table_info.quests_list, new_quest_info)
	    end
	end
end

function HasQuests(quest_id, player_id)
	local player_table_info = BirzhaData.PLAYERS_BATTLEPASS_INFROMATION[player_id]
	if player_table_info then
		local player_quests_table = player_table_info.quests_list
		for _, quest_info in pairs(player_quests_table) do
			if tonumber(quest_info.quest_id) == tonumber(quest_id) then
				return true
			end
		end
		return false
	end
	return false
end

function FindBirzhaQuest(quest_id)
	for _, quest_info in pairs(Quest_Information) do
		if tonumber(quest_info[1]) == tonumber(quest_id) then
			return quest_info
		end
	end
	return nil
end

function FindQuestKey(quest_id, tabled)
	local key = nil

	for k, v in pairs(tabled) do
		if tonumber(v.quest_id) == tonumber(quest_id) then
			key = k
		end
	end

	return key
end

function donate_shop:GiveExpInGame(id, exp)
	local player_table_info = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
	if player_table_info then
		player_table_info.battlepass_level = player_table_info.battlepass_level + exp
		CustomNetTables:SetTableValue('birzhainfo', tostring(id), player_table_info)
	end
end

function donate_shop:accept_battlepass_reward(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local reward_id = data.reward_id
	local player =	PlayerResource:GetPlayer(id)
	local player_donate_table = CustomNetTables:GetTableValue('birzhashop', tostring(id))

	local find_rewards = donate_shop:FindRewardsInfo(reward_id)

	if Rewards_Information[find_rewards] == nil then return end

	local info = Rewards_Information[find_rewards]

	-- Прогрузка текущих предметов у игрока --
	local player_items_table = {}

	for k, v in pairs(player_donate_table.player_items) do
        table.insert(player_items_table, v)
    end

    local bonus_bitcoins = 0

    table.insert(player_items_table, reward_id)

    if info[2] ~= 0 then
    	player_donate_table.birzha_coin = player_donate_table.birzha_coin + tonumber(info[2])
    	bonus_bitcoins = tonumber(info[2])
    end

	player_donate_table.player_items = player_items_table

	CustomNetTables:SetTableValue('birzhashop', tostring(id), player_donate_table)

	CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_donate_table.birzha_coin, dogecoin = player_donate_table.doge_coin} )

	local post_data = 
	{
		player = {
			{
				steamid = PlayerResource:GetSteamAccountID(id),
				player_bitcoin = bonus_bitcoins,
				player_dogecoin = 0,
				item_id = reward_id,
			}
		},
	}

	SendData('https://' ..BirzhaData.url .. '/data/bm_post_buy_item.php', post_data, nil)
end

function donate_shop:FindRewardsInfo(reward)
	for id, info in pairs(Rewards_Information) do
		if info[1] == reward then
			return id
		end
	end
end

function donate_shop:UpdateBattlePassInfo()
	for id, info in pairs(BirzhaData.PLAYERS_BATTLEPASS_INFROMATION) do
		if info then
			CustomNetTables:SetTableValue('battlepass_info', tostring(id), info)
		end
	end
end

function donate_shop:win_condition_predict(data)
	if BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID] then
		CustomGameEventManager:Send_ServerToAllClients( 'win_predict_chat', { id = data.PlayerID, count = BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].win_predict })  
		BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].player_win_predict_active = 1 
	end
end




































