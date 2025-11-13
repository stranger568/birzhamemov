_G.BirzhaData = class({})
BirzhaData.url = "data.strangerdev.ru"
-------------------------------------------------------------------------------
BirzhaData.PLAYERS_GLOBAL_INFORMATION = {}
BirzhaData.PARTY_NUMBER = 0
BirzhaData.PARTY_LIST = {}
BirzhaData.PARTY_NUMBER_LIST = {}
BirzhaData.current_season = 0
BirzhaData.SERVER_CONNECTION = true
BirzhaData.Localize_text = LoadKeyValues("scripts/hero_name_localize.txt")

BirzhaData.Coins_Table = 
{
    ['birzhamemov_solo'] = 
    {
        [1] = 10,
        [2] = 5,
        [3] = 2,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
    },
    ['birzhamemov_duo'] = 
    {
        [1] = 10,
        [2] = 5,
        [3] = 0,
        [4] = 0,
        [5] = 0,
    },
    ['birzhamemov_trio'] = 
    {
        [1] = 10,
        [2] = 5,
        [3] = 0,
        [4] = 0,
    },
    ['birzhamemov_5v5'] = 
    {
        [1] = 0,
        [2] = 0,
    },
    ['birzhamemov_zxc'] = 
    {
        [1] = 0,
        [2] = 0,
    },
    ['birzhamemov_5v5v5'] = 
    {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
}
-------------- Массив калибровки
BirzhaData.rating_table_calibrating = 
{
    ['birzhamemov_solo'] = {
        [1] =  300,
        [2] =  200,
        [3] =  100,
        [4] =  0,
        [5] =  0,
        [6] =  0,
        [7] =  0,
        [8] =  0,
    },
    ['birzhamemov_duo'] = {
        [1] = 300,
        [2] = 200,
        [3] = 100,
        [4] = 0,
        [5] = 0,
    },
    ['birzhamemov_trio'] = {
        [1] = 300,
        [2] = 200,
        [3] = 100,
        [4] = 0,
    },
    ['birzhamemov_5v5v5'] = 
    {
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
}

-- Cредний рейтинг выше 5000 и игрок имеет больше чем средний рейтинг
BirzhaData.rating_table_high_5000_player_high = 
{
    ['birzhamemov_solo'] = 
    {
        [1] =  30,
        [2] =  20,
        [3] =  10,
        [4] =  -10,
        [5] =  -20,
        [6] =  -30,
        [7] =  -40,
        [8] =  -50,
    },
    ['birzhamemov_duo'] = 
    {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -30,
        [5] = -45,
    },
    ['birzhamemov_trio'] = 
    {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -50,
    },
    ['birzhamemov_5v5v5'] = 
    {
        [1] = 30,
        [2] = -15,
        [3] = -30,
    },
    ['birzhamemov_5v5'] = 
    {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_zxc'] = 
    {
        [1] = 30,
        [2] = -50,
    },
}

-- Cредний рейтинг выше 5000 и игрок имеет меньше чем средний рейтинг
BirzhaData.rating_table_high_5000_player_low = 
{
    ['birzhamemov_solo'] = 
    {
        [1] =  50,
        [2] =  40,
        [3] =  30,
        [4] =  -5,
        [5] =  -10,
        [6] =  -15,
        [7] =  -20,
        [8] =  -25,
    },
    ['birzhamemov_duo'] = 
    {
        [1] = 50,
        [2] = 30,
        [3] = -10,
        [4] = -20,
        [5] = -30,
    },
    ['birzhamemov_trio'] = 
    {
        [1] = 50,
        [2] = 30,
        [3] = -10,
        [4] = -20,
    },
    ['birzhamemov_5v5v5'] = 
    {
        [1] = 40,
        [2] = -10,
        [3] = -20,
    },
    ['birzhamemov_5v5'] = 
    {
        [1] = 40,
        [2] = -20,
    },
    ['birzhamemov_zxc'] = 
    {
        [1] = 40,
        [2] = -20,
    },
}

-- Cредний рейтинг ниже 5000 и игрок имеет больше чем средний рейтинг
BirzhaData.rating_table_low_5000_player_high = {
    ['birzhamemov_solo'] = 
    {
        [1] =  40,
        [2] =  30,
        [3] =  20,
        [4] =  -10,
        [5] =  -20,
        [6] =  -30,
        [7] =  -40,
        [8] =  -50,
    },
    ['birzhamemov_duo'] = 
    {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -30,
        [5] = -50,
    },
    ['birzhamemov_trio'] = 
    {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -50,
    },
    ['birzhamemov_5v5v5'] = 
    {
        [1] = 30,
        [2] = -15,
        [3] = -30,
    },
    ['birzhamemov_5v5'] = 
    {
        [1] = 40,
        [2] = -60,
    },
    ['birzhamemov_zxc'] = 
    {
        [1] = 40,
        [2] = -60,
    },
}

-- Cредний рейтинг ниже 5000 и игрок имеет меньше чем средний рейтинг
BirzhaData.rating_table_low_5000_player_low = 
{
    ['birzhamemov_solo'] = 
    {
        [1] =  50,
        [2] =  40,
        [3] =  30,
        [4] =  -5,
        [5] =  -10,
        [6] =  -15,
        [7] =  -20,
        [8] =  -25,
    },
    ['birzhamemov_duo'] = 
    {
        [1] = 50,
        [2] = 30,
        [3] = -10,
        [4] = -20,
        [5] = -30,
    },
    ['birzhamemov_trio'] = 
    {
        [1] = 50,
        [2] = 30,
        [3] = -10,
        [4] = -20,
    },
    ['birzhamemov_5v5v5'] = 
    {
        [1] = 40,
        [2] = -10,
        [3] = -20,
    },
    ['birzhamemov_5v5'] =
    {
        [1] = 40,
        [2] = -20,
    },
    ['birzhamemov_zxc'] = 
    {
        [1] = 60,
        [2] = -45,
    },
}

BirzhaData.rating_hero_winrate = 
{
    ['birzhamemov_solo'] = 
    {
        [1] =  1,
        [2] =  1,
        [3] =  1,
        [4] =  -1,
        [5] =  -1,
        [6] =  -1,
        [7] =  -1,
        [8] =  -1,
    },
    ['birzhamemov_duo'] = 
    {
        [1] = 1,
        [2] = -1,
        [3] = -1,
        [4] = -1,
        [5] = -1,
    },
    ['birzhamemov_trio'] = 
    {
        [1] = 1,
        [2] = -1,
        [3] = -1,
        [4] = -1,
    },
    ['birzhamemov_5v5v5'] = 
    {
        [1] = 1,
        [2] = -1,
        [3] = -1,
    },
    ['birzhamemov_5v5'] = 
    {
        [1] = 1,
        [2] = -1,
    },
    ['birzhamemov_zxc'] = 
    {
        [1] = 1,
        [2] = -1,
    },
}

-- Прием данных

function BirzhaData:RegisterPlayer(player_id)
    if not IsInToolsMode() then
        if not PlayerResource:IsValidPlayerID(player_id) then return end
        if tostring( PlayerResource:GetSteamAccountID( player_id ) ) == nil then return end
        if PlayerResource:GetSteamAccountID( player_id ) == 0 then return end
        if PlayerResource:GetSteamAccountID( player_id ) == "0" then return end
    end

    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[ player_id ] or 
	{
        -- Общие данные
        steamid = PlayerResource:GetSteamAccountID( player_id ),
		partyid = tonumber(tostring(PlayerResource:GetPartyID(player_id))),
        has_report = 0,
        player_win_predict_active = 0,
        player_collect_candies = 0,
        players_repoted = {},

        -- Выбор героев
		bRegistred = false,
		bLoaded = false,
		ban_count = 1,
		picked_hero = nil,
		token_used = false,
        team = PlayerResource:GetTeam(player_id),
        selected_hero = nil,

        server_data = 
        {
            steamid = PlayerResource:GetSteamAccountID( player_id ),
            mmr = {},
            games_calibrating = {},
            token_used = 0,
            bp_days = 0,
            birzha_coin = 0,
            player_items = {},
            player_items_active = {},
            heroes_matches = {},
            pet_id = 0,
            border_id = 0,
            effect_id = 0,
            tip_id = 0,
            five_id = 0,
            vip = 0,
            premium = 0,
            gob = 0,
            dragonball = 0,
            leader = 0,
            chat_wheel = {0,0,0,0,0,0,0,0},
            win_predict = 0,
            reports = {},
            games = 0,
            candies_count = 0,
            connected = false
        }
	}

    BirzhaData.PLAYERS_GLOBAL_INFORMATION[ player_id ] = player_info
    CustomNetTables:SetTableValue('birzhainfo', tostring(player_id), player_info.server_data)

    if PlayerResource:GetPartyID(player_id) and tostring(PlayerResource:GetPartyID(player_id))~="0" then
        local sPartyID = tostring(PlayerResource:GetPartyID(player_id))
        if BirzhaData.PARTY_LIST[sPartyID]==nil then
            BirzhaData.PARTY_NUMBER = BirzhaData.PARTY_NUMBER + 1
            BirzhaData.PARTY_LIST[sPartyID] = BirzhaData.PARTY_NUMBER
        end     
        BirzhaData.PARTY_NUMBER_LIST[player_id] = BirzhaData.PARTY_LIST[sPartyID]
    end

    RequestData('https://' ..BirzhaData.url .. '/bmemov/get_player_info.php?steamid=' .. PlayerResource:GetSteamAccountID(player_id), function(data) BirzhaData:RegisterPlayerSiteInfo(data, player_id) end)
end

function BirzhaData:RegisterPlayerSiteInfo(data, player_id)
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[player_id]
    if player_info == nil then return end
    player_info.server_data = 
    {
        steamid = PlayerResource:GetSteamAccountID( player_id ),
        mmr = data.mmr[GetMapName()] or {},
        games_calibrating = data.games_calibrating[GetMapName()] or {},
        token_used = data.token_spended or 0,
        bp_days = tonumber(data.bp_days) or 0,
        birzha_coin = tonumber(data.bitcoin_currency) or 0,
        player_items = data.player_items or {},
        player_items_active = data.player_items_active or {},
        heroes_matches = data.heroes_matches or {},
        pet_id = tonumber(data.pet_default) or 0,
        border_id = tonumber(data.default_border) or 0,
        effect_id = tonumber(data.default_effect) or 0,
        tip_id = tonumber(data.default_tip) or 0,
        five_id = tonumber(data.default_five) or 0,
        vip = tonumber(data.vip) or 0,
        premium = tonumber(data.premium) or 0,
        gob = tonumber(data.gob) or 0,
        dragonball = tonumber(data.dragonball) or 0,
        leader = tonumber(data.leader) or 0,
        chat_wheel = data.chat_wheel or {0,0,0,0,0,0,0,0},
        win_predict = tonumber(data.win_predict) or 0,
        candies_count = tonumber(data.candies_count) or 0,
        reports = data.reports or {},
        games = data.games or 0,
        connected = true,
    }
    if IsInToolsMode() then
        player_info.server_data.birzha_coin = 999999
        player_info.server_data.bp_days = 0
    end
    CustomNetTables:SetTableValue("tip_cooldown", tostring(player_id), {cooldown = 0})
    CustomNetTables:SetTableValue("game_state", "party_map", BirzhaData.PARTY_NUMBER_LIST)
    CustomNetTables:SetTableValue("reported_info", tostring(player_id), {reported_info = player_info.players_repoted})
    CustomNetTables:SetTableValue('birzhainfo', tostring(player_id), player_info.server_data)
    CustomNetTables:SetTableValue('birzhashop', tostring(player_id), {birzha_coin = player_info.server_data.birzha_coin, player_items = player_info.server_data.player_items, player_items_active = player_info.server_data.player_items_active})
    CustomNetTables:SetTableValue('birzha_plus_data', tostring(player_id), {mmr = data.mmr})
end

function BirzhaData:RegisterSeasonInfo()
    local setup_gamedata = function(data)
        local d = 
        { 
            season = data.season,
            days_season = data.days
        }
        BirzhaData.current_season = tonumber(d["season"])
        CustomNetTables:SetTableValue('game_state', 'birzha_gameinfo', d)          
    end
    local setup_last_season = function(data)
        CustomNetTables:SetTableValue('game_state', 'birzha_top_last_season', data)          
    end
    local updateNotif = function(data)
        --CustomNetTables:SetTableValue('birzha_notification', 'birzha_notification', data)          
    end
    local SetFund = function(data)
        if data then
            CustomNetTables:SetTableValue('birzha_notification', 'fund_data', data)
        end      
    end
    RequestData('https://' .. BirzhaData.url .. '/bmemov/get_fund.php', function(data) SetFund(data) end)
    RequestData('https://' .. BirzhaData.url .. '/bmemov/get_top_15.php', function(data) BirzhaData.SetTopMmr(data) end)
    RequestData('https://' .. BirzhaData.url .. '/bmemov/get_donate_heroes.php', function(data) BirzhaData.SetDonateHeroes(data) end)
    RequestData('https://' .. BirzhaData.url .. '/bmemov/get_current_season.php', function(data) setup_gamedata(data) end) 
    RequestData('https://' .. BirzhaData.url .. '/bmemov/get_top_last_season.php', function(data) setup_last_season(data) end)
    RequestData('https://' .. BirzhaData.url .. '/bmemov/static_info/birzha_notification.json', function(data) updateNotif(data) end) 
end

function BirzhaData:GetHeroesWinrate()
    RequestData('https://' .. BirzhaData.url .. '/bmemov/get_heroes_stats.php', function(data)
        CustomNetTables:SetTableValue('game_state', 'heroes_winrate', data)
    end)
end

function BirzhaData.SetDonateHeroes(data)
    for _, info in pairs(data) do
        table.insert(birzha_hero_selection.BIRZHA_PLUS_HEROES, info.hero)
    end
    birzha_hero_selection:UpdateSubscribersHeroes()
end

function BirzhaData.SetTopMmr(list)
    CustomNetTables:SetTableValue('birzha_mmr', 'topmmr', list)        
end

function BirzhaData:CheckConnection()
    local no_connect_count = 0
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if not player_info.server_data.connected then
            no_connect_count = no_connect_count + 1
        end
    end
    if no_connect_count > 3 then
        BirzhaData.SERVER_CONNECTION = false
    end
    if BirzhaData.SERVER_CONNECTION then
        if BirzhaData:GetPlayerCount() <= 3 then
            CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "LowHumansInLobby", icon = "server_connect"} )
        end
    else
        CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ServerNoConnection", icon = "server_connect"} )
    end
end

-- Отправка данных
function BirzhaData.PostData()
    if not BirzhaData.SERVER_CONNECTION then return end
    local post_data = {players = {}}
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        local player_table = 
        {
            steamid = player_info.steamid,
            map_name = tostring(GetMapName()),
            mmr = BirzhaData.GetMmrByTeamPlace(id),
            bitcoin = BirzhaData.GetBitcoinPlus(id),
            candies_count = player_info.player_collect_candies or 0,
            win_predict = BirzhaData.GetPlayerWinPredict(id),
            games_calibrating = -1,
            token_spended = tostring(player_info.token_used),
            pet_default = tonumber(player_info.server_data.pet_id),
            default_border = tonumber(player_info.server_data.border_id),
            effect_id = tonumber(player_info.server_data.effect_id),
            tip_id = tonumber(player_info.server_data.tip_id),
            five_id = tonumber(player_info.server_data.five_id),
            chatwheel_1 = BirzhaData.GetChatWheel(id, 1),
            chatwheel_2 = BirzhaData.GetChatWheel(id, 2),
            chatwheel_3 = BirzhaData.GetChatWheel(id, 3),
            chatwheel_4 = BirzhaData.GetChatWheel(id, 4),
            chatwheel_5 = BirzhaData.GetChatWheel(id, 5),
            chatwheel_6 = BirzhaData.GetChatWheel(id, 6),
            chatwheel_7 = BirzhaData.GetChatWheel(id, 7),
            chatwheel_8 = BirzhaData.GetChatWheel(id, 8),
            games = 1,
            player_items_active = player_info.server_data.player_items_active,
        }
        table.insert(post_data.players, player_table)
    end
    SendData('https://' ..BirzhaData.url .. '/bmemov/bm_post_player_data.php', post_data, nil)
end

function BirzhaData.PostDataItemTest()
    if not BirzhaData.SERVER_CONNECTION then return end
    local post_data = {players = {}}
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        local player_table = 
        {
            steamid = player_info.steamid,
            player_items_active = player_info.server_data.player_items_active,
        }
        table.insert(post_data.players, player_table)
    end
    SendData('https://' ..BirzhaData.url .. '/bmemov/bm_post_player_data_test.php', post_data, nil)
end

function BirzhaData.PostHeroesInfo()
    if not BirzhaData.SERVER_CONNECTION then return end
    local post_heroes_data = {heroes = {}}
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        local deaths = 1
        local kills = 1
        if not IsPlayerDisconnected(id) then
            deaths = PlayerResource:GetDeaths(id)
            kills = PlayerResource:GetKills(id)
        end
        if player_info.picked_hero ~= nil then
            local name = tostring(player_info.picked_hero)
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
    SendData('https://' ..BirzhaData.url .. '/bmemov/post_hero_data.php', post_heroes_data, nil)
end

function BirzhaData.PostHeroPlayerHeroInfo()
    if not BirzhaData.SERVER_CONNECTION then return end
    local post_player_info = {heroes = {}}
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if player_info.picked_hero ~= nil then
            local steamid = player_info.steamid
            local name = tostring(player_info.picked_hero)
            local deaths = 1
            local kills = 1
            if not IsPlayerDisconnected(id) then
                deaths = PlayerResource:GetDeaths(id)
                kills = PlayerResource:GetKills(id)
            end
            local win = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 1 end return 0 end)(id))
            local experience = ((function(id) if BirzhaData.GetHeroWinPlace(id) >= 0 then return 250 end return 75 end)(id))
            if tonumber(player_info.server_data.bp_days) <= 0 and BirzhaData.GetHeroLevel(name, id) >= 5 then
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
    SendData('https://' ..BirzhaData.url .. '/bmemov/post_player_info.php', post_player_info, nil)
end

function BirzhaData:SendDataPlayerReports()
    if not BirzhaData.SERVER_CONNECTION then return end
    local post_data = {players = {}}
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
    SendData('https://' ..BirzhaData.url .. '/bmemov/player_reports_upload.php', post_data, nil)
    return post_data
end

-- Запросы

function BirzhaData.GetHeroWinPlace(id)
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")
    
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]

    local get_team_place = function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7,8}
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
        return nil   
    end

    local place = get_team_place(data.team)
    if winer_table and data.team == winer_table.t then
        place = 1
    end

    if place ~= nil then
        local bonus_mmr = BirzhaData.rating_hero_winrate[GetMapName()][place]
        return bonus_mmr
    end

    return 0
end

function BirzhaData.GetPlayerWinPredict(id)
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]

    local get_team_place = function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7,8}
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
        return nil   
    end

    local place = get_team_place(data.team)
    if winer_table and data.team == winer_table.t then
        place = 1
    end

    if data.player_win_predict_active == 1 and place ~= nil then
        if place == 1 then
            return 2
        else
            return 1
        end
    end

    return 0
end

function BirzhaData.GetBitcoinPlus(id)
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if IsPlayerAbandoned(id) then
        CustomNetTables:SetTableValue('bonus_dogecoin', tostring(id), {coin = 0})
        return 0
    end
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")
    local get_team_place = function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7,8}
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
        return nil 
    end

    local place = get_team_place(data.team)
    if winer_table and data.team == winer_table.t then
        place = 1
    end

    local bonus_coin = 0
    if place ~= nil then
        local coin_table = BirzhaData.Coins_Table[GetMapName()]
        bonus_coin = (coin_table[place] or 0)
        local has_win = false
        if data.player_win_predict_active == 1 then
            if place == 1 then
                has_win = true
            end
        end
        if has_win then
            if data.server_data.win_predict ~= nil then
                if (data.server_data.win_predict + 1) % 10 == 0 then
                    bonus_coin = bonus_coin + 100
                end
            end
        end
        bonus_coin = bonus_coin * (function(id) if HasBirzhaPlus(id) then return 2 end return 1 end)(id)
        CustomNetTables:SetTableValue('bonus_dogecoin', tostring(id), {coin = bonus_coin})
        return bonus_coin
    end
    CustomNetTables:SetTableValue('bonus_dogecoin', tostring(id), {coin = 0})
    return 0
end

function BirzhaData.GetMmrByTeamPlace(id)
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]

    if IsPlayerAbandoned(id) then
        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = -50})
        return -50
    end

    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")

    local get_team_place = function(t)
        local team = {}
        local teams_table = {2,3,6,7,8,9,10,11,12,13}
        if GetMapName() == "birzhamemov_solo" then
            teams_table = {2,3,6,7,8,9,10,11}
        elseif GetMapName() == "birzhamemov_duo" then
            teams_table = {2,3,6,7,8}
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
        return nil 
    end

    local place = get_team_place(data.team)
    if winer_table and data.team == winer_table.t then
        place = 1
    end

    local bonus_mmr = 0
    local average_rating = 0
    local multiplier_rating = 1
    local difference_rating = 0
    local current_player_rating = (data.server_data.mmr[BirzhaData.current_season] or 2500)

    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        average_rating = average_rating + (player_info.server_data.mmr[BirzhaData.current_season] or 2500)
    end

    average_rating = average_rating / BirzhaData:GetPlayerCount()
    difference_rating = math.abs(average_rating - current_player_rating)

    if place ~= nil then
        --Калибровочные---------------------------------------------------------------------------------------------------------------
        if (BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].server_data.games_calibrating[BirzhaData.current_season] or 10) > 0 then
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
                        multiplier_rating = 1.3
                    else
                        multiplier_rating = 0.7
                    end    
                elseif difference_rating >= 2000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.2
                    else
                        multiplier_rating = 0.8
                    end
                elseif difference_rating >= 1000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.1
                    else
                        multiplier_rating = 0.9
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
                        multiplier_rating = 1.3
                    else
                        multiplier_rating = 0.7
                    end    
                elseif difference_rating >= 2000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.2
                    else
                        multiplier_rating = 0.8
                    end
                elseif difference_rating >= 1000 then
                    if bonus_mmr > 0 then
                        multiplier_rating = 1.1
                    else
                        multiplier_rating = 0.9
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

-- Дополнительные функции

function BirzhaData:RegisterEndGameItems()
	for id, info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		local player_items = {}
		if info.selected_hero ~= nil then
			for i = 0, 18 do
				local item = info.selected_hero:GetItemInSlot(i)
				local name = ""
				if item then
					name = item:GetName()
				end
				player_items[i] = name
			end
		end
		CustomNetTables:SetTableValue("end_game_items", tostring(id), player_items)
	end
end

function BirzhaData:GetPlayerCount()
    local count = 0
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        count  = count + 1
    end
    return count
end

function HasBirzhaPlus(id)
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if data and data.server_data.bp_days > 0 then
        return true
    end
    return false
end

function HasToken(id)
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if data and data.token_used then
        return true
    end
    return false
end

function IsDonatorID(status, id)
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if data and data.server_data[status] == 1 then
        return true
    end
    return false
end

function BirzhaData.GetHeroLevel(hero, id)
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if data and data.server_data then
        for _, info in pairs(data.server_data.heroes_matches) do
            if info.hero == hero then
                return math.floor(info.experience / 1000)
            end
        end
    end
    return 0
end

function BirzhaData.GetChatWheel(id, number)
    local data = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    if data and data.server_data.chat_wheel then
        local player_chat_wheel_change = {}
        for k, v in pairs(data.server_data.chat_wheel) do
            player_chat_wheel_change[k] = v
        end
        return player_chat_wheel_change[number]
    end
    return 0
end

function BirzhaData:TokenSet(params) 
	if params.PlayerID == nil then return end
    local id = params.PlayerID
    local player_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id]
    local token_count_max = 10
    local items_token = {219, 220, 221, 222, 223, 224, 225, 226, 227, 228}
    for _, token_item in pairs(items_token) do
    	if DonateShopIsItemBought(id, token_item) then
    		token_count_max = token_count_max + 1
    	end
    end
    if token_count_max - (player_info.server_data.token_used or 0) <= 0 then 
        return 
    end
    if player_info and not player_info.token_used then   
    	CustomGameEventManager:Send_ServerToAllClients( 'double_rating_chat', { id = id })   
        BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].token_used = true
    end                    
end

function BirzhaData:win_condition_predict(data)
    if data.PlayerID == nil then return end
	if BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID] then
		CustomGameEventManager:Send_ServerToAllClients( 'win_predict_chat', { id = data.PlayerID, count = BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].server_data.win_predict })  
		BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].player_win_predict_active = 1 
	end
end

function BirzhaData:PlayVictoryPlayerSound(victoryTeam)
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		if not IsPlayerDisconnected(id) and player_info.team == victoryTeam then
			if player_info.picked_hero == "npc_dota_hero_skeleton_king" then
				EmitGlobalSound("papich_victory")
				break
			elseif player_info.picked_hero == "npc_dota_hero_treant" then
				EmitGlobalSound("overlord_win_sound")
				break
			elseif player_info.picked_hero == "npc_dota_hero_pyramide" then
				EmitGlobalSound("pyramide_win_sound")
				break
			elseif player_info.picked_hero == "npc_dota_hero_serega_pirat" and (DonateShopIsItemBought(id, 199) or IsInToolsMode()) then
				EmitGlobalSound("pirat_win")
				break
			end
		end
	end
end

function BirzhaData:birzha_update_check_birzha_plus(params)
    if params.PlayerID == nil then return end
    local player =	PlayerResource:GetPlayer(params.PlayerID)
    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[params.PlayerID] then
        local birzha_plus_updated = function(data, id)
            if data ~= nil then
                if tonumber(data.bp_days) > 0 then
                    BirzhaData.PLAYERS_GLOBAL_INFORMATION[params.PlayerID].server_data.bp_days = tonumber(data.bp_days)
                    CustomNetTables:SetTableValue('birzhainfo', tostring(params.PlayerID), BirzhaData.PLAYERS_GLOBAL_INFORMATION[params.PlayerID].server_data)
                    CustomGameEventManager:Send_ServerToPlayer(player, "shop_accept_notification", {} )
                else
                    CustomGameEventManager:Send_ServerToPlayer(player, "shop_error_notification", {} )
                end
            end
        end
        RequestData('https://' ..BirzhaData.url .. '/bmemov/get_player_info.php?steamid=' .. PlayerResource:GetSteamAccountID(params.PlayerID), function(data) birzha_plus_updated(data, player_id) end)
    end
end

function BirzhaData:birzha_contract_target_selected(data)
    if data.PlayerID == nil then return end
    local hero_name = data.hero_name
    local info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID]
    local hero = info.selected_hero
    local target = nil
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if player_info.selected_hero ~= nil and player_info.selected_hero:GetUnitName() == hero_name then
            target = player_info.selected_hero
        end
    end
    if hero and target ~= nil then
        local modifier_item_birzha_contract_caster = hero:FindModifierByName("modifier_item_birzha_contract_caster")
        if modifier_item_birzha_contract_caster then
            modifier_item_birzha_contract_caster.target = target
            modifier_item_birzha_contract_caster:Destroy()
        end
    end
end

function BirzhaData:AddCandyes(id)
    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[id] == nil then return end
    BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].player_collect_candies = BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].player_collect_candies + 1
end