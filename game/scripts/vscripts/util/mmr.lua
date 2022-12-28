BirzhaData = class({})
BirzhaData.url = '91.219.192.6'  -- сайт с бд

-------------------------------------------------------------------------------

BirzhaData.PLAYERS_GLOBAL_INFORMATION = {}
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
            ban_days = tonumber(data.ban_days) or 0,
            border_id = tonumber(data.default_border) or 0,
            vip = tonumber(data.vip) or 0,
            premium = tonumber(data.premium) or 0,
            gob = tonumber(data.gob) or 0,
            dragonball = tonumber(data.dragonball) or 0,
            leader = tonumber(data.leader) or 0,
            chat_wheel = data.chat_wheel or {0,0,0,0,0,0,0,0},
            has_battlepass = tonumber(data.has_battlepass) or 0,
            battlepass_level = tonumber(data.battlepass_level) or 0,
        }

        local table_shop = {
            doge_coin = tonumber(data.dogecoin_currency) or 0,
            birzha_coin = tonumber(data.bitcoin_currency) or 0,
            player_items = data.player_items or {},
        }

        local new_player_information = {
            steamid = table_info.steamid,
            pet_id = table_info.pet_id,
            border_id = table_info.border_id,
            bp_days = table_info.bp_days,
            mmr = table_info.mmr,
            games_calibrating = table_info.games_calibrating,
            team = PlayerResource:GetTeam(id),
        }

        local table_birzha_plus_data = {
            mmr = data.mmr or {}
        }

        BirzhaData.PLAYERS_GLOBAL_INFORMATION[id] = new_player_information

        if PlayerResource:GetPartyID(player_id) and tostring(PlayerResource:GetPartyID(player_id))~="0" then
            local sPartyID = tostring(PlayerResource:GetPartyID(player_id))
            if BirzhaData.PARTY_LIST[sPartyID]==nil then
                BirzhaData.PARTY_NUMBER = BirzhaData.PARTY_NUMBER + 1
                BirzhaData.PARTY_LIST[sPartyID] = BirzhaData.PARTY_NUMBER
            end     
            BirzhaData.PARTY_NUMBER_LIST[player_id] = BirzhaData.PARTY_LIST[sPartyID]
        end

        CustomNetTables:SetTableValue("game_state", "party_map", BirzhaData.PARTY_NUMBER_LIST)

       -- Фейк игрок
       --BirzhaData.PLAYERS_GLOBAL_INFORMATION[1] = {
       --    steamid = table_info.steamid,
       --    pet_id = table_info.pet_id,
       --    border_id = table_info.border_id,
       --    bp_days = table_info.bp_days,
       --    mmr = {1,2,3,4,5,6,7,8,9,10,11,15000},
       --    games_calibrating = {1,2,3,4,5,6,7,8,9,10,11,0},
       --    team = 3,
       --}

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
    RequestData('https://' .. BirzhaData.url .. '/data/game_info.json', function(data) setup_gamedata(data) end) 
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
                local experience = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 100 end return 10 end)(id))

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

function BirzhaData.GetMmrByTeamPlace(id)
    if IsPlayerAbandoned(id) then
        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = -50})
        return -50
    end

    local player_information = CustomNetTables:GetTableValue("birzhainfo", tostring(id))
    if player_information then
        if player_information.ban_days and player_information.ban_days > 0 then
            CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = 0})
            return 0
        end
    end

    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local get_team_place = 
    function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
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

    if place and place ~= nil then
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

    if place and place ~= nil then
        return bonus_mmr
    end

    return 0
end
