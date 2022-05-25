if donate_shop == nil then
	donate_shop = class({})
end

LinkLuaModifier("modifier_blinoid_shop", "modifiers/modifier_blinoid_shop", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_penguin_shop", "modifiers/modifier_penguin_shop", LUA_MODIFIER_MOTION_BOTH)

function donate_shop:BuyItem(data)
	if data.PlayerID == nil then return end
	local id = data.PlayerID
	local item_id = data.item_id
	local price = data.price
	local currency = data.currency
	local player =	PlayerResource:GetPlayer(id)
	local player_bitcoin = (CustomNetTables:GetTableValue('birzhashop', tostring(id)) or {}).birzha_coin
	local player_dogecoin = (CustomNetTables:GetTableValue('birzhashop', tostring(id)) or {}).doge_coin
	local player_items = (CustomNetTables:GetTableValue('birzhashop', tostring(id)) or {}).player_items

	local player_items_table = {}

	for k, v in pairs(player_items) do
        table.insert(player_items_table, v)
    end

	if tostring(currency) == "gold" then
		if tonumber(player_bitcoin) >= tonumber(price) then
			player_bitcoin = player_bitcoin - tonumber(price)

			if (item_id == "0") then
				player_dogecoin = player_dogecoin + (tonumber(price) * 2)
				CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_bitcoin, dogecoin = player_dogecoin} )
				CustomNetTables:SetTableValue('birzhashop', tostring(id), {doge_coin = player_dogecoin, birzha_coin = player_bitcoin, player_items = player_items_table})
			else
				CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_bitcoin, dogecoin = player_dogecoin} )
				table.insert(player_items_table, item_id)
				CustomNetTables:SetTableValue('birzhashop', tostring(id), {doge_coin = player_dogecoin, birzha_coin = player_bitcoin, player_items = player_items_table})
			end
		else
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {text = "shop_no_bitcoin"} )
			return
		end
	elseif tostring(currency) == "gem" then
		if tonumber(player_dogecoin) >= tonumber(price) then
			player_dogecoin = player_dogecoin - tonumber(price)
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_set_currency", {bitcoin = player_bitcoin, dogecoin = player_dogecoin} )
			table.insert(player_items_table, item_id)
			CustomNetTables:SetTableValue('birzhashop', tostring(id), {doge_coin = player_dogecoin, birzha_coin = player_bitcoin, player_items = player_items_table})
		else
			CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {text = "shop_no_dogecoin"} )
			return
		end
	end

	local post_data = {
		player = {
			{
				steamid = PlayerResource:GetSteamAccountID(id),
				player_bitcoin = tonumber(player_bitcoin),
				player_dogecoin = tonumber(player_dogecoin),
				item_id = item_id,
			}
		},
	}

	SendData('https://bmemov.ru/data/post_player_shop_data.php', post_data, nil)
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

MEMESPASS_PREMIUM_PETS["Insane"] = {
	effect = "courier_devourling_gold_ambient", model = "models/insane/insane.vmdl"
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
				player.pet.particle = ParticleManager:CreateParticle(MEMESPASS_PREMIUM_PETS[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)				
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
				player.pet.particle = ParticleManager:CreateParticle(MEMESPASS_PREMIUM_PETS[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)	
				if pet_id == "Insane" then
					player.pet:SetModelScale(0.6)
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

			print(pet_id)

			player.pet = CreateUnitByName("unit_premium_pet", hero:GetAbsOrigin() + RandomVector(RandomFloat(0,100)), true, hero, nil, hero:GetTeamNumber())
			player.pet:SetOwner(hero)
			player.pet:AddNewModifier( player.pet, nil, "modifier_birzha_pet", {} )
			player.pet:SetModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
			player.pet:SetOriginalModel(MEMESPASS_PREMIUM_PETS[pet_id].model)
			player.pet.particle = ParticleManager:CreateParticle(MEMESPASS_PREMIUM_PETS[pet_id].effect, PATTACH_ABSORIGIN_FOLLOW, player.pet)	
			if pet_id == "Insane" then
				player.pet:SetModelScale(0.6)
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
	}

	local toys = {
		"124",
		"125",
	}

	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if DonateShopIsItemBought(keys.PlayerID, keys.num) then
		for _,sound in pairs(sounds) do
			if tostring(keys.num) == tostring(sound) then
				if player.sound_use == 1 then
					EmitSoundOnClient("General.Cancel", player)
					return
				end
				if not IsInToolsMode() then
					player.sound_use = 1
					Timers:CreateTimer(10, function() player.sound_use = 0 end)
				end

				local sound_name = "item_wheel_"..keys.num

				EmitGlobalSound(sound_name)

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
				}

				local hero_name = ""
				local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
				if hero then
					hero_name = hero:GetUnitName()
				end

				CustomGameEventManager:Send_ServerToAllClients( 'chat_birzha_sound', {hero_name = hero_name, player_id = keys.PlayerID, sound_name = chat_sounds[keys.num]})
			end
		end

		for _,spray in pairs(sprays) do
			if tostring(keys.num) == tostring(spray) then
				if player.spray_use == 1 then 
					EmitSoundOnClient("General.Cancel", player)
					return
				end
				if not IsInToolsMode() then
					player.spray_use = 1
					Timers:CreateTimer(10, function() player.spray_use = 0 end)
				end

				local spray_name = "item_wheel_"..keys.num

				local spray = ParticleManager:CreateParticle("particles/birzhapass/"..spray_name..".vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl( spray, 0, PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetOrigin() )
				ParticleManager:ReleaseParticleIndex( spray )
				PlayerResource:GetSelectedHeroEntity(keys.PlayerID):EmitSound("Spraywheel.Paint")
			end
		end

		for _,toy in pairs(toys) do
			if tostring(keys.num) == tostring(toy) then
				if player.toy_use == 1 then 
					EmitSoundOnClient("General.Cancel", player)
					return
				end
				if not IsInToolsMode() then
					player.toy_use = 1
					Timers:CreateTimer(30, function() player.toy_use = 0 end)
				end

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
		if hero:GetUnitName() ~= "npc_dota_hero_wisp" then
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
end