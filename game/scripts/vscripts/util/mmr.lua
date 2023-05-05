BirzhaData = class({})
BirzhaData.url = 'data.strangerdev.ru'  -- сайт с бд

-------------------------------------------------------------------------------

BirzhaData.PLAYERS_GLOBAL_INFORMATION = {}
BirzhaData.PLAYERS_BATTLEPASS_INFROMATION = {}
BirzhaData.PARTY_NUMBER = 0
BirzhaData.PARTY_LIST = {}
BirzhaData.PARTY_NUMBER_LIST = {}
BirzhaData.Localize_text = LoadKeyValues("scripts/hero_name_localize.txt")

function BirzhaData:RegisterPlayerSiteInfo(player_id)
    if not PlayerResource:IsValidPlayerID(player_id) then return end
    if tostring( PlayerResource:GetSteamAccountID( player_id ) ) == nil then return end
    if PlayerResource:GetSteamAccountID( player_id ) == 0 then return end
    if PlayerResource:GetSteamAccountID( player_id ) == "0" then return end

    local set_data = function(data, id)
        local table_info = {
            mmr = data.mmr[GetMapName()] or {},
            games_calibrating = data.games_calibrating[GetMapName()] or {},
            token_used = data.token_spended or 0,
            bp_days = tonumber(data.bp_days) or 0,
            doge_coin = tonumber(data.dogecoin_currency) or 0,
            birzha_coin = tonumber(data.bitcoin_currency) or 0,
            player_items = data.player_items or {},
            heroes_matches = data.heroes_matches or {},
            steamid=PlayerResource:GetSteamAccountID(id),
            pet_id = tonumber(data.pet_default) or 0,
            reports_count = tonumber(data.reports_count) or 0,
            border_id = tonumber(data.default_border) or 0,
            vip = tonumber(data.vip) or 0,
            premium = tonumber(data.premium) or 0,
            gob = tonumber(data.gob) or 0,
            dragonball = tonumber(data.dragonball) or 0,
            leader = tonumber(data.leader) or 0,
            chat_wheel = data.chat_wheel or {0,0,0,0,0,0,0,0},
            has_battlepass = tonumber(data.has_battlepass) or 0,
            battlepass_level = tonumber(data.battlepass_level) or 0,
            win_predict = tonumber(data.win_predict) or 0,
            reports = data.reports or {},
        }

        local table_shop =
        {
            doge_coin = tonumber(data.dogecoin_currency) or 0,
            birzha_coin = tonumber(data.bitcoin_currency) or 0,
            player_items = data.player_items or {},
        }

        local new_player_information = 
        {
            steamid = table_info.steamid,
            pet_id = table_info.pet_id,
            border_id = table_info.border_id,
            bp_days = table_info.bp_days,
            mmr = table_info.mmr,
            games_calibrating = table_info.games_calibrating,
            team = PlayerResource:GetTeam(id),
            win_predict = table_info.win_predict,
            player_win_predict_active = 0,
            players_repoted = {},
            reports = table_info.reports or {},
            has_report = 0,
        }

        local table_birzha_plus_data = 
        {
            mmr = data.mmr or {}
        }

        local hero_challenge = data.hero_challenge or BirzhaData:CreateHeroChallenge(id)
        local current_hero_str = data.current_hero_str or hero_challenge.heroes_str[1]["hero_name"]
        local current_hero_agi = data.current_hero_agi or hero_challenge.heroes_agi[1]["hero_name"]
        local current_hero_int = data.current_hero_int or hero_challenge.heroes_int[1]["hero_name"]

        if hero_challenge and hero_challenge.heroes_str and #hero_challenge.heroes_str <= 0 then
            hero_challenge = BirzhaData:CreateHeroChallenge(id)
            current_hero_str = hero_challenge.heroes_str[1]["hero_name"]
            current_hero_agi = hero_challenge.heroes_agi[1]["hero_name"]
            current_hero_int = hero_challenge.heroes_int[1]["hero_name"]
        end

        local battlepass_info =
        {
            hero_challenge = hero_challenge,
            current_hero_str = current_hero_str,
            current_hero_agi = current_hero_agi,
            current_hero_int = current_hero_int,
            quests_list = data.quests_list or {},
            new_battlepass_exp = 0,
        }

        CustomNetTables:SetTableValue('battlepass_info', tostring(id), battlepass_info)
        CustomNetTables:SetTableValue("reported_info", tostring(id), {reported_info = new_player_information.players_repoted})

        BirzhaData.PLAYERS_GLOBAL_INFORMATION[id] = new_player_information

        BirzhaData.PLAYERS_BATTLEPASS_INFROMATION[id] = battlepass_info

        if PlayerResource:GetPartyID(player_id) and tostring(PlayerResource:GetPartyID(player_id))~="0" then
            local sPartyID = tostring(PlayerResource:GetPartyID(player_id))
            if BirzhaData.PARTY_LIST[sPartyID]==nil then
                BirzhaData.PARTY_NUMBER = BirzhaData.PARTY_NUMBER + 1
                BirzhaData.PARTY_LIST[sPartyID] = BirzhaData.PARTY_NUMBER
            end     
            BirzhaData.PARTY_NUMBER_LIST[player_id] = BirzhaData.PARTY_LIST[sPartyID]
        end

        CustomNetTables:SetTableValue("game_state", "party_map", BirzhaData.PARTY_NUMBER_LIST)

        if new_player_information and new_player_information.bp_days then
            if new_player_information.bp_days > 0 then
                CustomNetTables:SetTableValue("tip_cooldown", tostring(id), {cooldown = 0})
            end
        end

        CustomNetTables:SetTableValue('birzhainfo', tostring(id), table_info)
        CustomNetTables:SetTableValue('birzhashop', tostring(id), table_shop)
        CustomNetTables:SetTableValue('birzha_plus_data', tostring(id), table_birzha_plus_data)
    end 

    RequestData('https://' ..BirzhaData.url .. '/data/get_player_data.php?steamid=' .. PlayerResource:GetSteamAccountID(player_id), function(data) set_data(data, player_id) end)
end

function BirzhaData:RegisterSeasonInfo()
    local setup_gamedata = function(data)
        local d = { 
            mmr_season = data.mmr_season 
        }    
        CustomNetTables:SetTableValue('game_state', 'birzha_gameinfo', d)          
    end
    RequestData('https://' .. BirzhaData.url .. '/data/get_top_15.php', function(data) BirzhaData.SetTopMmr(data) end)
    RequestData('https://' .. BirzhaData.url .. '/data/get_top_bp.php', function(data) BirzhaData.SetTopBP(data) end)
    RequestData('https://' .. BirzhaData.url .. '/data/get_donate_heroes.php', function(data) BirzhaData.SetDonateHeroes(data) end)
    RequestData('https://' .. BirzhaData.url .. '/data/game_info.json', function(data) setup_gamedata(data) end) 
end

function BirzhaData.SetDonateHeroes(data)
    for _, info in pairs(data) do
        table.insert(BIRZHA_PLUS_HEROES, info.hero)
    end
    CustomPick:RegisterHeroes()
end

function BirzhaData:GetPlayerCount()
    local count = 0
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        count  = count + 1
    end
    return count
end

-----------------------------------------------------------------------------------------

function BirzhaData.PostData()
    local post_data = { 
        players = {}
    }

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do

        local player_table = {
            steamid = player_info.steamid,
            map_name = tostring(GetMapName()),
            mmr = BirzhaData.GetMmrByTeamPlace(id),
            win_predict = BirzhaData.GetPlayerWinPredict(id),
            games_calibrating = -1,
            dogecoin_currency = BirzhaData.GetDogeCoins(id),
            token_spended = false,
            pet_default = player_info.pet_id,
            default_border = player_info.border_id,
            chatwheel_1 = BirzhaData.GetChatWheel(id, "1"),
            chatwheel_2 = BirzhaData.GetChatWheel(id, "2"),
            chatwheel_3 = BirzhaData.GetChatWheel(id, "3"),
            chatwheel_4 = BirzhaData.GetChatWheel(id, "4"),
            chatwheel_5 = BirzhaData.GetChatWheel(id, "5"),
            chatwheel_6 = BirzhaData.GetChatWheel(id, "6"),
            chatwheel_7 = BirzhaData.GetChatWheel(id, "7"),
            chatwheel_8 = BirzhaData.GetChatWheel(id, "8"),
        }

        if PLAYERS[ id ] then
            player_table.token_spended = tostring(PLAYERS[ id ].token_used)
            player_table.pet_default = tonumber(PLAYERS[ id ].pet)
            player_table.default_border = tonumber(PLAYERS[ id ].border)         
        end

        table.insert(post_data.players, player_table)
    end

    SendData('https://' ..BirzhaData.url .. '/data/bm_post_player_data.php', post_data, nil)
end

function BirzhaData.PostHeroesInfo()
    local post_heroes_data = 
    {
        heroes = {},
    }

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if PLAYERS[ id ] then
            local deaths = 1
            local kills = 1
            if not IsPlayerDisconnected(id) then
                deaths = PlayerResource:GetDeaths(id)
                kills = PlayerResource:GetKills(id)
            end
            if PLAYERS[ id ].picked_hero ~= nil then
                local name = tostring(PLAYERS[ id ].picked_hero)
                local win = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 1 end return 0 end)(id))
                local lose = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 0 end return 1 end)(id))
                local hero_name_rus = "error"
                if BirzhaData.Localize_text ~= nil and name ~= nil and BirzhaData.Localize_text[name] ~= nil then
                    hero_name_rus = BirzhaData.Localize_text[name]
                end
                local hero_table = 
                {
                    hero = name,
                    hero_name_rus = hero_name_rus,
                    games = 1,
                    deaths = deaths,
                    kills = kills,
                    win = win,
                    lose = lose,
                }
                table.insert(post_heroes_data.heroes, hero_table)
            end
        end
    end  

    SendData('https://' ..BirzhaData.url .. '/data/post_hero_data.php', post_heroes_data, nil)
end

function BirzhaData.PostHeroPlayerHeroInfo()
    local post_player_info = 
    {
        heroes = {},
    }

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if PLAYERS[ id ] then
            if PLAYERS[ id ].picked_hero ~= nil then
                local steamid = player_info.steamid
                local name = tostring(PLAYERS[ id ].picked_hero)
                local deaths = 1
                local kills = 1

                if not IsPlayerDisconnected(id) then
                    deaths = PlayerResource:GetDeaths(id)
                    kills = PlayerResource:GetKills(id)
                end

                local win = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 1 end return 0 end)(id))

                local experience = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 250 end return 75 end)(id))

                if tonumber(player_info.bp_days) <= 0 and BirzhaData.GetHeroLevel(name, id) >= 5 then
                    experience = 0
                end

                CustomNetTables:SetTableValue('exp_table', tostring(id), {exp = experience})

                local hero_table = 
                {
                    steamid = steamid,
                    games = 1,
                    hero = name,
                    win = win,
                    kills = kills,
                    deaths = deaths,
                    experience = experience,
                }

                table.insert(post_player_info.heroes, hero_table)
            end
        end
    end 

    DeepPrintTable(post_player_info)

    SendData('https://' ..BirzhaData.url .. '/data/post_player_info.php', post_player_info, nil)
end

function BirzhaData.GetHeroLevel(hero, id)
    local player_table = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
    if player_table then
        for hero_name, info in pairs(player_table.heroes_matches) do
            if info.hero == hero then
                return math.floor(info.experience / 1000)
            end
        end
    end
    return 0
end

-------------------------------------------------------------------------------------------------------------------

function BirzhaData.GetChatWheel(id, number)
    local player_table_for_chat_wheel = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
    if player_table_for_chat_wheel then
        if player_table_for_chat_wheel.chat_wheel then
            local player_chat_wheel_change = {}
            for k, v in pairs(player_table_for_chat_wheel.chat_wheel) do
                player_chat_wheel_change[k] = v
            end
            return player_chat_wheel_change[number]
        end
    end
    return 0
end   

------------------------------------------------------------------------------------------------------------------------------------------

-- Функции на проверку донатов

function HasToken(id)
    if PLAYERS[ id ] then
        return PLAYERS[ id ].token_used
    end
    return false
end

function IsDonatorID(status, id)
    local steamid = tostring(id)
    local table_info = CustomNetTables:GetTableValue("birzhainfo", steamid)
    if table_info then
        return table_info[status] == 1
    end
end

function HasBirzhaPlus(id)
    local bp_table = CustomNetTables:GetTableValue('birzhainfo', tostring(id))
    if bp_table then
        if tonumber(bp_table.bp_days) > 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function BirzhaData.SetTopMmr(list)
    CustomNetTables:SetTableValue('birzha_mmr', 'topmmr', list)        
end

function BirzhaData.SetTopBP(list)
    CustomNetTables:SetTableValue('birzha_mmr', 'topbp', list)        
end

---------------------------------------------------------------------------

------------- Массивы рейтинга и догекоинов за игру

BirzhaData.Coins_Table = {
    ['birzhamemov_solo'] = {
        [1] = 10,
        [2] = 9,
        [3] = 8,
        [4] = 7,
        [5] = 6,
        [6] = 5,
        [7] = 4,
        [8] = 3,
    },
    ['birzhamemov_wtf'] = {
        [1] = 10,
        [2] = 9,
        [3] = 8,
        [4] = 7,
        [5] = 6,
        [6] = 5,
        [7] = 4,
        [8] = 3,
        [9] = 2,
        [10] = 1,
    },
    ['birzhamemov_duo'] = {
        [1] = 10,
        [2] = 7,
        [3] = 4,
        [4] = 1,
    },
    ['birzhamemov_trio'] = {
        [1] = 10,
        [2] = 7,
        [3] = 4,
        [4] = 1,
    },
    ['birzhamemov_5v5'] = {
        [1] = 10,
        [2] = 5,
    },
    ['birzhamemov_zxc'] = {
        [1] = 2,
        [2] = 0,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 10,
        [2] = 5,
        [3] = 1,
    }
}
-------------- Массив калибровки
BirzhaData.rating_table_calibrating = {
    ['birzhamemov_solo'] = {
        [1] =  300,
        [2] =  250,
        [3] =  200,
        [4] =  150,
        [5] =  100,
        [6] =  50,
        [7] =  0,
        [8] =  0,
    },
    ['birzhamemov_duo'] = {
        [1] = 300,
        [2] = 200,
        [3] = 100,
        [4] = 0,
    },
    ['birzhamemov_trio'] = {
        [1] = 300,
        [2] = 200,
        [3] = 100,
        [4] = 0,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 300,
        [2] = 150,
        [3] = 0,
    },
    ['birzhamemov_5v5'] = {
        [1] = 300,
        [2] = 0,
    },
    ['birzhamemov_zxc'] = {
        [1] = 300,
        [2] = 0,
    },
    ['birzhamemov_wtf'] = {
        [1] =  300,
        [2] =  250,
        [3] =  200,
        [4] =  150,
        [5] =  100,
        [6] =  50,
        [7] =  0,
        [8] =  0,
        [9] =  0,
        [10] = 0,
    },
}

-------------- Массив если средний рейтинг выше 5000
BirzhaData.rating_table_high_5000_player_high = {
    ['birzhamemov_solo'] = {
        [1] =  30,
        [2] =  20,
        [3] =  10,
        [4] =  0,
        [5] =  -10,
        [6] =  -20,
        [7] =  -30,
        [8] =  -40,
    },
    ['birzhamemov_duo'] = {
        [1] = 30,
        [2] = 15,
        [3] = 0,
        [4] = -30,
    },
    ['birzhamemov_trio'] = {
        [1] = 30,
        [2] = 15,
        [3] = 0,
        [4] = -30,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 30,
        [2] = 0,
        [3] = -30,
    },
    ['birzhamemov_5v5'] = {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_zxc'] = {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_wtf'] = {
        [1] =  30,
        [2] =  15,
        [3] =  8,
        [4] =  0,
        [5] =  -10,
        [6] =  -20,
        [7] =  -30,
        [8] =  -40,
        [9] =  -50,
        [10] = -60,
    },
}

BirzhaData.rating_table_high_5000_player_low = {
    ['birzhamemov_solo'] = {
        [1] =  30,
        [2] =  20,
        [3] =  10,
        [4] =  0,
        [5] =  -10,
        [6] =  -20,
        [7] =  -30,
        [8] =  -40,
    },
    ['birzhamemov_duo'] = {
        [1] = 30,
        [2] = 20,
        [3] = 0,
        [4] = -30,
    },
    ['birzhamemov_trio'] = {
        [1] = 30,
        [2] = 20,
        [3] = 0,
        [4] = -30,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 30,
        [2] = 0,
        [3] = -30,
    },
    ['birzhamemov_5v5'] = {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_zxc'] = {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_wtf'] = {
        [1] =  30,
        [2] =  20,
        [3] =  10,
        [4] =  0,
        [5] =  -10,
        [6] =  -20,
        [7] =  -30,
        [8] =  -40,
        [9] =  -50,
        [10] = -60,
    },
}

-------------- Массив если средний рейтинг ниже 5000
BirzhaData.rating_table_low_5000_player_high = {
    ['birzhamemov_solo'] = {
        [1] =  60,
        [2] =  40,
        [3] =  20,
        [4] =  0,
        [5] =  -15,
        [6] =  -30,
        [7] =  -45,
        [8] =  -60,
    },
    ['birzhamemov_duo'] = {
        [1] = 60,
        [2] = 30,
        [3] = 0,
        [4] = -45,
    },
    ['birzhamemov_trio'] = {
        [1] = 60,
        [2] = 30,
        [3] = 0,
        [4] = -45,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 60,
        [2] = 0,
        [3] = -45,
    },
    ['birzhamemov_5v5'] = {
        [1] = 60,
        [2] = -45,
    },
    ['birzhamemov_zxc'] = {
        [1] = 60,
        [2] = -45,
    },
    ['birzhamemov_wtf'] = {
        [1] =  60,
        [2] =  30,
        [3] =  16,
        [4] =  0,
        [5] =  -15,
        [6] =  -30,
        [7] =  -45,
        [8] =  -60,
        [9] =  -75,
        [10] = -90,
    },
}

BirzhaData.rating_table_low_5000_player_low = {
    ['birzhamemov_solo'] = {
        [1] =  60,
        [2] =  40,
        [3] =  20,
        [4] =  0,
        [5] =  -15,
        [6] =  -30,
        [7] =  -45,
        [8] =  -60,
    },
    ['birzhamemov_duo'] = {
        [1] = 60,
        [2] = 40,
        [3] = 0,
        [4] = -45,
    },
    ['birzhamemov_trio'] = {
        [1] = 60,
        [2] = 40,
        [3] = 0,
        [4] = -45,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 60,
        [2] = 0,
        [3] = -45,
    },
    ['birzhamemov_5v5'] = {
        [1] = 60,
        [2] = -45,
    },
    ['birzhamemov_zxc'] = {
        [1] = 60,
        [2] = -45,
    },
    ['birzhamemov_wtf'] = {
        [1] =  60,
        [2] =  40,
        [3] =  20,
        [4] =  0,
        [5] =  -15,
        [6] =  -30,
        [7] =  -45,
        [8] =  -60,
        [9] =  -75,
        [10] = -90,
    },
}

BirzhaData.rating_hero_winrate = 
{
    ['birzhamemov_solo'] = 
    {
        [1] =  1,
        [2] =  1,
        [3] =  1,
        [4] =  1,
        [5] =  -1,
        [6] =  -1,
        [7] =  -1,
        [8] =  -1,
    },
    ['birzhamemov_duo'] = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = -1,
    },
    ['birzhamemov_trio'] = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = -1,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 1,
        [2] = 1,
        [3] = -1,
    },
    ['birzhamemov_5v5'] = {
        [1] = 1,
        [2] = -1,
    },
    ['birzhamemov_zxc'] = {
        [1] = 1,
        [2] = -1,
    },
    ['birzhamemov_wtf'] = 
    {
        [1] =  1,
        [2] =  1,
        [3] =  1,
        [4] =  1,
        [5] =  -1,
        [6] =  -1,
        [7] =  -1,
        [8] =  -1,
    },
}

-- Функции вычисления рейтинга и догекоинсов для челиков ------------------------------

function BirzhaData.GetDogeCoins(id)

    if IsPlayerAbandoned(id) then
        CustomNetTables:SetTableValue('bonus_dogecoin', tostring(id), {coin = 0})
        return 0
    end

    local get_team_place = 
    function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_trio" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_5v5v5" then
            teams_table = {2,3,6}
        elseif GetMapName() == "birzhamemov_5v5" then
            teams_table = {2,3}
        elseif GetMapName() == "birzhamemov_zxc" then
            teams_table = {2,3}
        end
        for _, i in ipairs(teams_table) do
            local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
            if table_team_score then
                table.insert(team, {id = i, kills = table_team_score.kills} )
            end
        end    
        table.sort( team, function(x,y) return y.kills < x.kills end )
        for i = 1, #team do
            if team[i].id == t then
                return i
            end    
        end    
    end

    local place = get_team_place(PlayerResource:GetTeam(id))
    local coin = 0

    if place and place ~= nil then
        local coin_table = BirzhaData.Coins_Table[GetMapName()]
        coin = (coin_table[place] or 0)
    end

    coin = coin * (function(id) if HasBirzhaPlus(id) then return 2 end return 1 end)(id)
    CustomNetTables:SetTableValue('bonus_dogecoin', tostring(id), {coin = coin})
    return coin
end

function BirzhaData.GetPlayerWinPredict(id)
    if IsPlayerAbandoned(id) then
        return 1
    end

    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local get_team_place = 
    function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_trio" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_5v5v5" then
            teams_table = {2,3,6}
        elseif GetMapName() == "birzhamemov_5v5" then
            teams_table = {2,3}
        elseif GetMapName() == "birzhamemov_zxc" then
            teams_table = {2,3}
        end
        for _, i in ipairs(teams_table) do
            local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
            if table_team_score then
                table.insert(team, {id = i, kills = table_team_score.kills} )
            end
        end    
        table.sort( team, function(x,y) return y.kills < x.kills end )
        for i = 1, #team do
            if team[i].id == t then
                return i
            end    
        end    
    end

    local place = get_team_place(PlayerResource:GetTeam(id))

    if winer_table then
        if PlayerResource:GetTeam(id) == winer_table.t then
            place = 1
        end
    end

    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[id] and BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].player_win_predict_active == 1 then
        if place == 1 then
            return 2
        else
            return 1
        end
    end

    return 0
end

function BirzhaData.GetMmrByTeamPlace(id)

    if IsPlayerAbandoned(id) then
        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = -50})
        return -50
    end

    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local get_team_place = 
    function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}

        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_trio" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_5v5v5" then
            teams_table = {2,3,6}
        elseif GetMapName() == "birzhamemov_5v5" then
            teams_table = {2,3}
        elseif GetMapName() == "birzhamemov_zxc" then
            teams_table = {2,3}
        end

        for _, i in ipairs(teams_table) do
            local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
            if table_team_score then
                table.insert(team, {id = i, kills = table_team_score.kills} )
            end
        end    
        table.sort( team, function(x,y) return y.kills < x.kills end )
        for i = 1, #team do
            if team[i].id == t then
                return i
            end    
        end    
    end

    local place = get_team_place(PlayerResource:GetTeam(id))

    if winer_table then
        if PlayerResource:GetTeam(id) == winer_table.t then
            place = 1
            donate_shop:QuestProgress(4, id, 1)
            donate_shop:QuestProgress(5, id, 1)
            donate_shop:QuestProgress(6, id, 1)
        end
    end

    local bonus_mmr = 0
    local average_rating = 0
    local multiplier_rating = 1
    local difference_rating = 0
    local current_player_rating = (BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].mmr[13] or 2500)

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        average_rating = average_rating + (player_info.mmr[13] or 2500)
    end

    average_rating = average_rating / BirzhaData:GetPlayerCount()
    difference_rating = math.abs(average_rating - current_player_rating)

    if place ~= nil then
        --Калибровочные---------------------------------------------------------------------------------------------------------------
        if (BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].games_calibrating[13] or 10) > 0 then
            bonus_mmr = BirzhaData.rating_table_calibrating[GetMapName()][place]
            CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = bonus_mmr})      
            return bonus_mmr
        end
        ------------------------------------------------------------------------------------------------------------------------------

        if average_rating > 5000 then
            if current_player_rating >= average_rating then
                bonus_mmr = BirzhaData.rating_table_high_5000_player_high[GetMapName()][place]
                if difference_rating >= 3000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 0.7
                    else
                        multiplier_rating = 1.3
                    end
                elseif difference_rating >= 2000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 0.8
                    else
                        multiplier_rating = 1.2
                    end
                elseif difference_rating >= 1000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 0.9
                    else
                        multiplier_rating = 1.1
                    end
                elseif difference_rating >= 0 then
                    multiplier_rating = 1
                end
            else
                bonus_mmr = BirzhaData.rating_table_high_5000_player_low[GetMapName()][place]
                if difference_rating >= 3000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 2
                    else
                        multiplier_rating = 0
                    end    
                elseif difference_rating >= 2000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.8
                    else
                        multiplier_rating = 0.4
                    end
                elseif difference_rating >= 1000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.4
                    else
                        multiplier_rating = 0.8
                    end        
                elseif difference_rating >= 0 then
                    multiplier_rating = 1
                end
            end
        else
            if current_player_rating >= average_rating then
                bonus_mmr = BirzhaData.rating_table_low_5000_player_high[GetMapName()][place]
                if difference_rating >= 3000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 0.7
                    else
                        multiplier_rating = 1.3
                    end
                elseif difference_rating >= 2000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 0.8
                    else
                        multiplier_rating = 1.2
                    end
                elseif difference_rating >= 1000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 0.9
                    else
                        multiplier_rating = 1.1
                    end
                elseif difference_rating >= 0 then
                    multiplier_rating = 1
                end
            else
                bonus_mmr = BirzhaData.rating_table_low_5000_player_low[GetMapName()][place]
                if difference_rating >= 3000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 2
                    else
                        multiplier_rating = 0
                    end    
                elseif difference_rating >= 2000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.8
                    else
                        multiplier_rating = 0.4
                    end
                elseif difference_rating >= 1000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.4
                    else
                        multiplier_rating = 0.8
                    end        
                elseif difference_rating >= 0 then
                    multiplier_rating = 1
                end
            end
        end

        ---Конечный рассчет рейтинга--------------------------------------------------------------------------------------------------
        bonus_mmr = math.floor(bonus_mmr * multiplier_rating)

        if bonus_mmr > 0 then
            donate_shop:QuestProgress(1, id, 1)
            donate_shop:QuestProgress(2, id, 1)
            donate_shop:QuestProgress(3, id, 1)
            if HasToken(id) then
                donate_shop:QuestProgress(20, id, 1)
            end
        end

        bonus_mmr = bonus_mmr * (function(id) if HasToken(id) then return 2 end return 1 end)(id)

        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = bonus_mmr})
        
        return bonus_mmr
    end

    --Если будут проблемы с местом вообще выдать 0------------------------------------------------------------------------------------
    CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = 0})
    return 0
end

function BirzhaData.GetHeroWinPlace(id)
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local get_team_place = 
    function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_trio" then
            teams_table = {2,3,6,7}
        elseif GetMapName() == "birzhamemov_5v5v5" then
            teams_table = {2,3,6}
        elseif GetMapName() == "birzhamemov_5v5" then
            teams_table = {2,3}
        elseif GetMapName() == "birzhamemov_zxc" then
            teams_table = {2,3}
        end
        for _, i in ipairs(teams_table) do
            local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
            if table_team_score then
                table.insert(team, {id = i, kills = table_team_score.kills} )
            end
        end    
        table.sort( team, function(x,y) return y.kills < x.kills end )
        for i = 1, #team do
            if team[i].id == t then
                return i
            end    
        end    
    end

    local place = get_team_place(PlayerResource:GetTeam(id))

    if winer_table then
        if PlayerResource:GetTeam(id) == winer_table.t then
            place = 1
        end
    end

    local bonus_mmr = BirzhaData.rating_hero_winrate[GetMapName()][place]

    if place ~= nil then
        return bonus_mmr
    end

    return 0
end

--------- BattlePass

function BirzhaData:CreateHeroChallenge(id)
    local heroes_str = {}
    local heroes_agi = {}
    local heroes_int = {}
    local strength_heroes_base = 
    {
        "npc_dota_hero_huskar",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_slardar",
        "npc_dota_hero_lycan",
        "npc_dota_hero_tusk",
        "npc_dota_hero_saitama",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_slark",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_migi",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_pudge",
        "npc_dota_hero_venom",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_tailer",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_nolik",
        "npc_dota_hero_pyramide",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_stone_dwayne",
        "npc_dota_hero_mars",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_axe",
        "npc_dota_hero_treant",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_spectre",
        "npc_dota_hero_centaur",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_ursa",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_tiny",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_sven",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_chaos_knight",
    }
    local agility_heroes_base = 
    {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_antimage",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_serega_pirat",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_marci",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_furion",
        "npc_dota_hero_sonic",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_sasake",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_batrider",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_luna",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_warlock",
        "npc_dota_hero_rat",
        "npc_dota_hero_sniper",
        "npc_dota_hero_thomas_bebra",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_troll_warlord",
    }
    local intellect_heroes_base = 
    {
        "npc_dota_hero_jull",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_morphling",
        "npc_dota_hero_enigma",
        "npc_dota_hero_oracle",
        "npc_dota_hero_shredder",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_lina",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_pump",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_freddy",
        "npc_dota_hero_travoman",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_silencer",
        "npc_dota_hero_overlord",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_puck",
        "npc_dota_hero_invoker",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_zuus",
        "npc_dota_hero_visage",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_rubick",
        "npc_dota_hero_techies",
        "npc_dota_hero_leshrac",
    }

    strength_heroes_base = table.shuffle(strength_heroes_base)
    agility_heroes_base = table.shuffle(agility_heroes_base)
    intellect_heroes_base = table.shuffle(intellect_heroes_base)

    for id, hero_name in pairs(strength_heroes_base) do
        local hero_info = {}
        hero_info["hero_name"] = hero_name
        hero_info["hero_win"] = 0
        hero_info["id"] = id 
        hero_info["attr"] = 1 
        table.insert(heroes_str, hero_info)
    end

    for id, hero_name in pairs(agility_heroes_base) do
        local hero_info = {}
        hero_info["hero_name"] = hero_name
        hero_info["hero_win"] = 0
        hero_info["id"] = id 
        hero_info["attr"] = 2
        table.insert(heroes_agi, hero_info)
    end

    for id, hero_name in pairs(intellect_heroes_base) do
        local hero_info = {}
        hero_info["hero_name"] = hero_name
        hero_info["hero_win"] = 0
        hero_info["id"] = id 
        hero_info["attr"] = 3
        table.insert(heroes_int, hero_info)
    end

    local challenge = 
    {
        ["heroes_str"] = heroes_str,
        ["heroes_agi"] = heroes_agi,
        ["heroes_int"] = heroes_int
    }

    BirzhaData.SendToServerHeroChallengeList(id, challenge)

    return challenge
end

function BirzhaData.SendToServerHeroChallengeList(id, array_list)

    local post_data = 
    {
        players = {
            {
                steamid = PlayerResource:GetSteamAccountID(id),
                challenge = array_list,
            }
        },
    }

    SendData('https://' ..BirzhaData.url .. '/data/bm_post_hero_challenge.php', post_data, nil)
end

function BirzhaData:SendBattlePassInformation()
    local post_data = 
    { 
        players = {}
    }

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        local player_table_info = BirzhaData.PLAYERS_BATTLEPASS_INFROMATION[id]
        if player_table_info then
            local player_table = 
            {
                steamid = player_info.steamid,
                quests = player_table_info.quests_list,
                new_exp = player_table_info.new_battlepass_exp,
            }

            table.insert(post_data.players, player_table)
        end
    end
    
    SendData('https://' ..BirzhaData.url .. '/data/bm_post_player_battlepass_info.php', post_data, nil)
end

function BirzhaData:SendDataPlayerReports()
    local post_data = 
    { 
        players = {}
    }

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if player_info.players_repoted and #player_info.players_repoted >= 2 then
            local player_1 = BirzhaData.PLAYERS_GLOBAL_INFORMATION[player_info.players_repoted[1]].steamid
            local player_2 = BirzhaData.PLAYERS_GLOBAL_INFORMATION[player_info.players_repoted[2]].steamid
            local player_table = 
            {
                steamid = player_info.steamid,
                player_1 = player_1,
                player_2 = player_2,
            }
            table.insert(post_data.players, player_table)
        end
    end

    SendData('https://' ..BirzhaData.url .. '/data/player_reports_upload.php', post_data, nil)

    return post_data
end