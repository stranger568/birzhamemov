function BirzhaGameMode:ThinkGoldDrop()
	if RollPercentage(self.m_GoldDropPercent) then
		self:SpawnGoldEntity( Vector( 0, 0, 0 ) + RandomVector(RandomInt(self.m_GoldRadiusMin, self.m_GoldRadiusMax)) )
	end
end

function BirzhaGameMode:SpawnGoldEntity( spawnPoint )
    spawnPoint = spawnPoint + Vector(0,0,800)
	EmitGlobalSound("Item.PickUpGemWorld")
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
    newItem.is_cooldown_take = true
    Timers:CreateTimer(0.3, function()
        newItem.is_cooldown_take = nil
    end)
	local drop = CreateItemOnPositionForLaunch(spawnPoint, newItem )
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.3, spawnPoint)
	newItem:SetContextThink( "KillLoot", function() return self:KillLoot( newItem, drop ) end, 20 )
end

function BirzhaGameMode:KillLoot( item, drop )
	if drop:IsNull() then return end
	if GameRules:IsGamePaused() then return 1 end
	local particle = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( particle, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( particle, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( particle )
	EmitGlobalSound("Item.PickUpWorld")
	UTIL_Remove( item )
	UTIL_Remove( drop )
end

function BirzhaGameMode:ThinkItemCheck()
	local t = BIRZHA_GAME_ALL_TIMER
	local tSpawn = ( self.spawnTime * self.nNextSpawnItemNumber )
	local tWarn = tSpawn - 10
	GameTimerUpdater((tSpawn - t), "countdown", self.spawnTime)
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
    local chest_point = Entities:FindAllByName("chest_point")
    BirzhaGameMode.RandomGeneratePoint = chest_point[RandomInt(1, #chest_point)]
	local spawnLocation = GetGroundPosition(BirzhaGameMode.RandomGeneratePoint:GetAbsOrigin(), nil)
	CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ItemWillSpawn", icon = "item"} )
	EmitGlobalSound( "powerup_03" )
	CreateModifierThinker( nil, nil, "modifier_birzha_map_center_vision", { duration = 12, radius = 300 }, spawnLocation, DOTA_TEAM_NEUTRALS, false )
    for _, team in pairs(_G.GET_TEAM_LIST[GetMapName()]) do
        AddFOWViewer(team, spawnLocation, 300, 12, false)
        GameRules:ExecuteTeamPing(team, spawnLocation.x, spawnLocation.y, nil, 0)
    end
	local effect_spawn = ParticleManager:CreateParticle( "particles/particle_spawn_item_birzha.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( effect_spawn, 0, spawnLocation)
	ParticleManager:SetParticleControl( effect_spawn, 1, spawnLocation)
	Timers:CreateTimer(10, function()
		ParticleManager:DestroyParticle(effect_spawn, false)
    	ParticleManager:ReleaseParticleIndex( effect_spawn )
	end)
end

function BirzhaGameMode:SpawnItem()
	local spawnLocation = GetGroundPosition(BirzhaGameMode.RandomGeneratePoint:GetAbsOrigin(), nil) + Vector(0,0,800)
	local visual = GetGroundPosition(BirzhaGameMode.RandomGeneratePoint:GetAbsOrigin(), nil) + Vector(0,0,100)
	local end_pos = GetGroundPosition(BirzhaGameMode.RandomGeneratePoint:GetAbsOrigin(), nil)

	local particle_l = ParticleManager:CreateParticle("particles/spawn_chect_knockback.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_l, 0, visual)
    ParticleManager:SetParticleControl(particle_l, 60, Vector(255,140,0))
    ParticleManager:SetParticleControl(particle_l, 61, Vector(1,1,1))
    ParticleManager:ReleaseParticleIndex( particle_l )

	local newItem = CreateItem( "item_treasure_chest", nil, nil )
    newItem.is_cooldown_take = true
	local drop = CreateItemOnPositionForLaunch(spawnLocation, newItem )
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, spawnLocation )
    Timers:CreateTimer(0.3, function()
        newItem.is_cooldown_take = nil
    end)

	Timers:CreateTimer(0.25, function()
		CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ItemHasSpawned", icon = "item2"} )
		EmitGlobalSound( "chest_dropped" )

		local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, visual)
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 200, 200, 200 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )

        local targets = FindUnitsInRadius(DOTA_TEAM_NOTEAM, end_pos, nil, 300, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        for _,unit in pairs(targets) do
            local direction = unit:GetAbsOrigin() - visual
            direction.z = 0
            direction = direction:Normalized()
            local knockback = unit:AddNewModifier(unit, nil, "modifier_generic_knockback_lua", {direction_x = direction.x, direction_y = direction.y, distance = 400, height = 100, duration = 0.25, IsStun = true})
            local callback = function( bInterrupted )
                unit:Stop()
                FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            end
            knockback:SetEndCallback( callback )
        end
	end)
end

function BirzhaGameMode:SpecialItemAdd(event, duplicate, new_owner)
    -- Получаем предмет и владельца

    local owner = event.HeroEntityIndex and EntIndexToHScript(event.HeroEntityIndex) or event.UnitEntityIndex and EntIndexToHScript(event.UnitEntityIndex)
    if new_owner then
        owner = new_owner
    end
    if not owner then return end

    local ownerTeam = owner:GetTeamNumber()
    local gameScoreMax = CustomNetTables:GetTableValue("game_state", "scores_to_win").kills

    -- Сортируем команды по количеству убийств
    local sortedTeams = {}
    for _, team in pairs(self.m_GatheredShuffledTeams) do
        local teamScore = CustomNetTables:GetTableValue("game_state", tostring(team))
        if teamScore then
            table.insert(sortedTeams, { teamID = team, teamScore = teamScore.kills })
        end
    end

    table.sort(sortedTeams, function(a,b) return a.teamScore > b.teamScore end)

    local n = #sortedTeams
    local leader = sortedTeams[1].teamID
    local lastPlace = sortedTeams[n].teamID

    -- Определяем предметы по уровням (добавлен 5-й тир)
    local ITEM_TIERS = 
    {
        [1] = { -- Базовые предметы (ранняя игра)
            {"item_sisters_shroud", "neutral"},
            {"item_occult_bracelet", "neutral"},
            {"item_kobold_cup", "neutral"},
            {"item_chipped_vest", "neutral"},
            {"item_polliwog_charm", "neutral"},
            {"item_spark_of_courage", "neutral"},
            {"item_rippers_lash", "neutral"},

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
        },
        [2] = { -- Средние предметы (мидгейм)
            {"item_essence_ring", "neutral"},
			{"item_mana_draught", "neutral"},
			{"item_poor_mans_shield", "neutral"},
			{"item_searing_signet", "neutral"},
			{"item_misericorde", "neutral"},
			{"item_pogo_stick", "neutral"},

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
        },
        [3] = { -- Сильные предметы (поздний мидгейм)
            {"item_serrated_shiv", "neutral"},
			{"item_gale_guard", "neutral"},
			{"item_gunpowder_gauntlets", "neutral"},
			{"item_whisper_of_the_dread", "neutral"},
			{"item_jidi_pollen_bag", "neutral"},
			{"item_psychic_headband", "neutral"},

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
        },
        [4] = { -- Очень сильные предметы (лейтгейм)
            {"item_pyrrhic_cloak", "neutral"},
			{"item_crippling_crossbow", "neutral"},
			{"item_magnifying_monocle", "neutral"},
			{"item_dezun_bloodrite", "neutral"},
			{"item_giant_maul", "neutral"},
			{"item_outworld_staff", "neutral"},

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
        },
        [5] = { -- Легендарные предметы (ультра лейтгейм/финальная стадия)
            {"item_desolator_2", "neutral"},
			{"item_fallen_sky", "neutral"},
			{"item_demonicon", "neutral"},
			{"item_minotaur_horn", "neutral"},
			{"item_spider_legs", "neutral"},
			{"item_helm_of_the_undying", "neutral"},
			{"item_unrelenting_eye", "neutral"},
			{"item_divine_regalia", "neutral"},

            "item_magic_daedalus",
            "item_radiance_2",
            "item_butter2",
            "item_refresher_custom",
            "item_sheepstick",
            "item_butterfly",
            "item_abyssal_blade",
            "item_bloodstone",
            "item_satanic",
            "item_skadi",
            "item_mjollnir",
        }
    }

    local BONUS_TIERS =
    {
        [1] = { -- Базовые предметы (ранняя игра)
            {"item_enhancement_mystical", 1},
		    {"item_enhancement_brawny", 1},
		    {"item_enhancement_alert", 1},
		    {"item_enhancement_tough", 1},
		    {"item_enhancement_quickened", 1},
        },
        [2] = { -- Средние предметы (мидгейм)
            {"item_enhancement_mystical", 2},
			{"item_enhancement_brawny", 2},
			{"item_enhancement_alert", 2},
			{"item_enhancement_tough", 2},
			{"item_enhancement_quickened", 2},
			{"item_enhancement_keen_eyed", 1},
			{"item_enhancement_vast", 1},
			{"item_enhancement_greedy", 1},
			{"item_enhancement_vampiric", 1},
        },
        [3] = { -- Сильные предметы (поздний мидгейм)
            {"item_enhancement_mystical", 3},
			{"item_enhancement_brawny", 3},
			{"item_enhancement_alert", 3},
			{"item_enhancement_tough", 3},
			{"item_enhancement_quickened", 3},
			{"item_enhancement_keen_eyed", 2},
			{"item_enhancement_vast", 2},
			{"item_enhancement_greedy", 2},
			{"item_enhancement_vampiric", 2},
        },
        [4] = { -- Очень сильные предметы (лейтгейм)
            {"item_enhancement_mystical", 4},
			{"item_enhancement_brawny", 4},
			{"item_enhancement_alert", 4},
			{"item_enhancement_tough", 4},
			{"item_enhancement_quickened", 4},
			{"item_enhancement_vampiric", 3},
			{"item_enhancement_timeless", 1},
			{"item_enhancement_titanic", 1},
			{"item_enhancement_crude", 1},
        },
        [5] = { -- Легендарные предметы (ультра лейтгейм/финальная стадия)
            {"item_enhancement_timeless", 1},
            {"item_enhancement_titanic", 1},
            {"item_enhancement_crude", 1},
            {"item_enhancement_feverish", 1},
            {"item_enhancement_fleetfooted", 1},
            {"item_enhancement_audacious", 1},
            {"item_enhancement_evolved", 1},
            {"item_enhancement_boundless", 1},
            {"item_enhancement_wise", 1},
        }
    }

    -- Выбираем случайные предметы для каждого уровня
    local tiersListItems = {}
    for tier = 1, 5 do  -- Обновлено до 5 тиров
        if self["tier"..tier.."ItemBucket"] == nil then
            self["tier"..tier.."ItemBucket"] = {}
        end
        tiersListItems[tier] = PickRandomShuffle(ITEM_TIERS[tier], self["tier"..tier.."ItemBucket"])
    end

    -- Определяем текущий уровень предметов в зависимости от времени игры
    local currentTier = 1
    local gameTime = BIRZHA_GAME_ALL_TIMER
    
    -- Новая логика с 5 тирами:
    if gameTime > 1500 then       -- 25+ минут - 5й тир
        currentTier = 5
    elseif gameTime > 1080 then   -- 18-25 минут - 4й тир
        currentTier = 4
    elseif gameTime > 720 then    -- 12-18 минут - 3й тир
        currentTier = 3
    elseif gameTime > 360 then    -- 6-12 минут - 2й тир
        currentTier = 2
    end                           -- 0-6 минут - 1й тир

    -- Улучшенная логика балансировки для 5 тиров:
    if gameTime > 300 then  -- Корректировка начинается после 5 минут
        -- Команды в топе получают предметы на 1 уровень ниже
        if ownerTeam == leader and currentTier > 1 then
            currentTier = currentTier - 1
        -- Команды внизу таблицы получают предметы на 1 уровень выше (но не выше 5)
        elseif (ownerTeam == lastPlace or 
               (GetMapName() == "birzhamemov_solo" and ownerTeam == sortedTeams[n-1].teamID)) and 
               currentTier < 5 then
            currentTier = currentTier + 1
        end
        
        -- Дополнительная логика для 5го тира:
        -- Если разница между лидером и последним местом большая (более 50% от gameScoreMax)
        local scoreDifference = sortedTeams[1].teamScore - sortedTeams[n].teamScore
        if scoreDifference > gameScoreMax * 0.5 then
            -- Аутсайдеры получают шанс на предмет 5го тира даже раньше времени
            if ownerTeam == lastPlace and currentTier == 4 and RollPercentage(20) then
                currentTier = 5
            end
            -- Лидеры никогда не получают 5й тир
            if ownerTeam == leader and currentTier == 5 then
                currentTier = 4
            end
        end
    end
    if owner.current_tier and currentTier < owner.current_tier then
        currentTier = owner.current_tier
    end
    owner.current_tier = currentTier

    -- Создаем список из 3 случайных предметов выбранного тира
    local ItemsList = {}
    for i = 1, 3 do
        local item = PickRandomShuffle(ITEM_TIERS[currentTier], self["tier"..currentTier.."ItemBucket"])
        if item then
            if type(item) == "table" then
                table.insert(ItemsList, {item[1], BONUS_TIERS[currentTier][RandomInt(1, #BONUS_TIERS[currentTier])]})
            else
                table.insert(ItemsList, {item})
            end
        end
    end

    BirzhaGameMode:GivePlayerItemsList(owner, ItemsList, currentTier)

    if not duplicate then
        -- Воспроизводим звук и отправляем уведомление
        EmitGlobalSound("powerup_04")

        CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {
            text = "__",
            icon = "item2",
            hero_id = owner:GetUnitName(),
            dropped_item = true,
            tier = currentTier  -- Добавляем информацию о тире для клиента
        })

        owner.Chest_Counter = (owner.Chest_Counter or 0) + 1
    end
end

function BirzhaGameMode:GivePlayerItemsList(owner, ItemsList, currentTier)
    owner.CURRENT_ITEMS_NEUTRAL_LIST = ItemsList
    CustomGameEventManager:Send_ServerToPlayer(owner:GetPlayerOwner(), "birzha_create_items_neutral_list", 
    {
        items_list = ItemsList,
        tier = currentTier  -- Добавляем информацию о тире для клиента
    })
end

function BirzhaGameMode:birzha_neutral_item_choose(params)
    if params.PlayerID == nil then return end
    local player_id = params.PlayerID
    local hero = PlayerResource:GetSelectedHeroEntity(player_id)
    local item_choose = params.item_choose
    if hero and hero.CURRENT_ITEMS_NEUTRAL_LIST then
        local spawnedItem_info = hero.CURRENT_ITEMS_NEUTRAL_LIST[tonumber(item_choose)]
        if spawnedItem_info[2] then
            local old_item_passive = hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_PASSIVE_SLOT)
            if old_item_passive then
                UTIL_Remove(old_item_passive)
            end
            local old_item_active = hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_ACTIVE_SLOT)
            if old_item_active then
                UTIL_Remove(old_item_active)
            end
            local active_item = hero:AddItemByName(spawnedItem_info[1])
            if active_item then
                active_item:SetDroppable(false)
            end
            local passive_item = hero:AddItemByName(spawnedItem_info[2][1])
            if passive_item then
                passive_item:SetDroppable(false)
                passive_item:SetLevel(spawnedItem_info[2][2])
            end
        else
           local item = hero:AddItemByName(spawnedItem_info[1])
           	if item then 
		        item:SetPurchaseTime(0)
	        end
        end
        hero.CURRENT_ITEMS_NEUTRAL_LIST = nil
        hero.Chest_Counter = hero.Chest_Counter - 1
        if hero.Chest_Counter > 0 then
            BirzhaGameMode:SpecialItemAdd({}, true, hero)
        end
    end
end