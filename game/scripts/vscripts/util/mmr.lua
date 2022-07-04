BirzhaData = class({})
BirzhaData.url = 'bmemov.ru'  -- сайт с бд

------------- Массивы рейтинга и догекоинов за игру

BirzhaData.Mmr_Table = {
    ['birzhamemov_solo'] = {
        [1] = 30,
        [2] = 20,
        [3] = 10,
        [4] = -5,
        [5] = -10,
        [6] = -15,
        [7] = -20,
        [8] = -25,
        [9] = -25,
        [10] = -25,
    },
    ['birzhamemov_duo'] = {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -30,
    },
    ['birzhamemov_trio'] = {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -30,
    },
    ['birzhamemov_5v5'] = {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 30,
        [2] = -15,
        [3] = -30,
    }
}

BirzhaData.Coins_Table = {
    ['birzhamemov_solo'] = {
        [1] = 10,
        [2] = 8,
        [3] = 6,
        [4] = 4,
        [5] = 2,
        [6] = 1,
        [7] = 1,
        [8] = 1,
        [9] = 1,
        [10] = 1,
    },
    ['birzhamemov_duo'] = {
        [1] = 10,
        [2] = 6,
        [3] = 2,
        [4] = 1,
    },
    ['birzhamemov_trio'] = {
        [1] = 10,
        [2] = 6,
        [3] = 2,
        [4] = 1,
    },
    ['birzhamemov_5v5'] = {
        [1] = 10,
        [2] = 5,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 10,
        [2] = 6,
        [3] = 1,
    }
}

-------------------------------------------------------------------------------


BirzhaData.PLAYERS_GLOBAL_INFORMATION = {}

function BirzhaData:RegisterPlayerSiteInfo(player_id)
    if not PlayerResource:IsValidPlayerID(player_id) then return end
    if tostring( PlayerResource:GetSteamAccountID( player_id ) ) == nil then return end
    if PlayerResource:GetSteamAccountID( player_id ) == 0 then return end
    if PlayerResource:GetSteamAccountID( player_id ) == "0" then return end

    local set_data = function(data, id)
        local table_info = {
            mmr = data.mmr or {},
            token_used = data.token_spended or 0,
            bp_days = data.bp_days or 0,
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
            chat_wheel = data.chat_wheel or {},
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
        }
        BirzhaData.PLAYERS_GLOBAL_INFORMATION[id] = new_player_information

        CustomNetTables:SetTableValue('birzhainfo', tostring(id), table_info)
        CustomNetTables:SetTableValue('birzhashop', tostring(id), table_shop)
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
            mmr = BirzhaData.GetMmrByTeamPlace(id),
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

    SendData('https://bmemov.ru/data/post_new_data.php', post_data, nil)
end

function BirzhaData.PostHeroesInfo()
    local post_heroes_data = {
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
                local win = ((function(id) if BirzhaData.GetMmrByTeamPlace(id) >= 0 then return 1 end return 0 end)(id))
                local lose = ((function(id) if BirzhaData.GetMmrByTeamPlace(id) >= 0 then return 0 end return 1 end)(id))
                local hero_table = {
                    hero = name,
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

    SendData('https://bmemov.ru/data/post_hero_data.php', post_heroes_data, nil)
end

function BirzhaData.PostHeroPlayerHeroInfo()
    local post_player_info = {
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
                local win = ((function(id) if BirzhaData.GetMmrByTeamPlace(id) >= 0 then return 1 end return 0 end)(id))
                local experience = ((function(id) if BirzhaData.GetMmrByTeamPlace(id) >= 0 then return 100 end return 0 end)(id))

                if tonumber(player_info.bp_days) <= 0 then
                    experience = 0
                end

                local hero_table = {
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

    SendData('https://bmemov.ru/data/post_player_info.php', post_player_info, nil)
end

-------------------------------------------------------------------------------------------------------------------

-- Функции вычисления рейтинга и догекоинсов для челиков ------------------------------

function BirzhaData.GetDogeCoins(id)
    if IsPlayerDisconnected(id) then
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
    if IsPlayerDisconnected(id) then
        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = -50})
        return -50
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
    if place and place ~= nil then
        local bonus_kda = (PlayerResource:GetKills(id)) / (function(id) if PlayerResource:GetDeaths(id) == 0 then return 1 end return PlayerResource:GetDeaths(id) end)(id)
        if PlayerResource:GetKills(id) <= 0 then
            bonus_kda = 0
        end
        local mmr_table = BirzhaData.Mmr_Table[GetMapName()]
        local bonus_mmr = (mmr_table[place] or 0)
        if bonus_mmr <= 0 then
            bonus_mmr = math.floor(bonus_mmr + bonus_kda)
        end
        if winer_table then
            if PlayerResource:GetTeam(id) == winer_table.t then
                bonus_mmr = mmr_table[1]
            end
        end

        local player_information = CustomNetTables:GetTableValue("birzhainfo", tostring(id))
        if player_information then
            if player_information.ban_days and player_information.ban_days > 0 then
                bonus_mmr = 0
            end
        end

        bonus_mmr = bonus_mmr * (function(id) if HasToken(id) then return 2 end return 1 end)(id)
        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = bonus_mmr})
        return bonus_mmr
    end
    CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = 0})
    return 0
end

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