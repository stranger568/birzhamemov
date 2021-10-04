BirzhaData = class({})
BirzhaData.url = 'www.bmemov.ru'  

function BirzhaData.GetAllPlayersData()
    local set_data = function(data, id)
        local table = {
            bp_xp = tonumber(data.birzhapass_xp or 0),
            mmr = data.mmr or {},
            bp_owner = data.hasbp,
            token_used = data.token_spended or 0,
            bp_days = data.bp_days or 0,
            ban_days = tonumber(data.ban_days) or 0,
            steamid=PlayerResource:GetSteamAccountID(id),
        }
        table.bp_lvl = GetLvlByXP(table.bp_xp)
        CustomNetTables:SetTableValue('birzhainfo', tostring(id), table)
    end

    local setup_gamedata = function(data)
        local d = {
            mmr_season = data.mmr_season or 9,  
        }    
        CustomNetTables:SetTableValue('game_state', 'birzha_gameinfo', d)          
    end

    for i = 0, PlayerResource:GetPlayerCount() - 1 do
        if i == PlayerResource:GetPlayerCount() - 1 then
            RequestData('https://' ..BirzhaData.url .. '/data/get_player_data.php?steamid=' .. PlayerResource:GetSteamAccountID(i), function(data) set_data(data, i) server_activated = true end)
        else
            RequestData('https://' ..BirzhaData.url .. '/data/get_player_data.php?steamid=' .. PlayerResource:GetSteamAccountID(i), function(data) set_data(data, i) end)
        end
    end 
    RequestData('https://' .. BirzhaData.url .. '/data/donators.json', function(data)  ChangeDonatorInfo(data) end)
    RequestData('https://' .. BirzhaData.url .. '/data/get_top_15.php', function(data) BirzhaData.SetTopMmr(data) end)
    RequestData('https://' .. BirzhaData.url .. '/data/game_info.json', function(data) setup_gamedata(data) end)
end    

function BirzhaData.PostData()
local post_data = {
players = {},
}
    for id = 0, PlayerResource:GetPlayerCount() - 1 do
        if not PlayerResource:IsFakeClient(id) then
            if PlayerResource:GetSelectedHeroEntity(id) ~= nil and PlayerResource:GetSelectedHeroEntity(id):GetUnitName() ~= "npc_dota_hero_wisp" then
                local steamid = PlayerResource:GetSteamAccountID(id)
                local player_table = {
                steamid = steamid,
                mmr = BirzhaData.GetMmrByTeamPlace(id) * (function(id) if HasToken(id) then return 2 end return 1 end)(id),
                birzhapass_xp = BirzhaData.GetPlusXp(id),
                token_spended = tostring(PLAYERS[ id ].token_used),
                }
                table.insert(post_data.players, player_table)
            end
        end
    end   
    SendData('https://bmemov.ru/data/post_new_data.php', post_data, nil)
end

function BirzhaData.PostHeroesInfo()
local post_heroes_data = {
heroes = {},
}
    for id = 0, PlayerResource:GetPlayerCount() - 1 do
        if not PlayerResource:IsFakeClient(id) then
            local hero = PlayerResource:GetSelectedHeroEntity(id)
            if hero ~= nil and hero:GetUnitName() ~= "npc_dota_hero_wisp" then
                local name = hero:GetUnitName()
                local deaths = PlayerResource:GetDeaths(id)
                local kills = PlayerResource:GetKills(id)
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
    for id = 0, PlayerResource:GetPlayerCount() - 1 do
        if not PlayerResource:IsFakeClient(id) then
            local hero = PlayerResource:GetSelectedHeroEntity(id)
            if hero ~= nil and hero:GetUnitName() ~= "npc_dota_hero_wisp" then
                local steamid = PlayerResource:GetSteamAccountID(id)
                local name = hero:GetUnitName()
                local deaths = PlayerResource:GetDeaths(id)
                local kills = PlayerResource:GetKills(id)
                local win = ((function(id) if BirzhaData.GetMmrByTeamPlace(id) >= 0 then return 1 end return 0 end)(id))
                local kd = 0
                
                if death == 0 then
                    kd = kills
                else
                    kd = kills / deaths
                end

                local hero_table = {
                    steamid = steamid,
                    games = 1,
                    hero = name,
                    win = win,
                    kills = kills,
                    deaths = deaths,
                }
                table.insert(post_player_info.heroes, hero_table)
            end
        end
    end   
    SendData('https://bmemov.ru/data/post_player_info.php', post_player_info, nil)
end

function HasBirzhaPass(id)
    local bp_table = (CustomNetTables:GetTableValue('birzhainfo', tostring(id)) or {}).bp_owner
    if bp_table == 1 then
        return true
    else
        return false
    end
end

function HasToken(id)
    return PLAYERS[ id ].token_used
end

function IsDonatorID(status, id)
    local steamid = tostring(id)
    local table = CustomNetTables:GetTableValue("birzhainfo", "donators_table")
    if table then
        if table[status] then
            return table[status][steamid] == 1
        end
    end
end

function ChangeDonatorInfo(data)
    local don_table = {}
    for key,value in pairs (data) do
        if type(value) == "table" then
            don_table[key] = {}
            for k,v in pairs(value) do
                don_table[key][tostring(v)] = true
            end
        end
    end
    CustomNetTables:SetTableValue("birzhainfo", "donators_table", don_table)
end

function BirzhaData.GetPlusXp(id)
    local player_table = CustomNetTables:GetTableValue('birzhainfo', tostring(id)) or {}
    local percent = 0
    for lvl = 1, (player_table.bp_lvl or 0) do 
        if string.find(MEMESPASS_REWARD_TABLE_FREE[lvl] or "", 'bp_xp_boost_') then
            percent = percent + 25
        end
    end    
    local xp =  250 + ( (function(id) if (CustomNetTables:GetTableValue('birzha_mmr', 'game_winner') or {}).t == PlayerResource:GetTeam(id) then return 500 end  end)(id)  or  0)
    return xp + xp * percent / 100
end

function BirzhaData.SetTopMmr(list)
    CustomNetTables:SetTableValue('birzha_mmr', 'topmmr', list)        
end

BirzhaData.Mmr_Table = {
    ['birzhamemov_solo'] = {
        [1] = 30,
        [2] = 25,
        [3] = 20,
        [4] = 15,
        [5] = 10,
        [6] = -10,
        [7] = -15,
        [8] = -20,
        [9] = -25,
        [10] = -30,
    },
    ['birzhamemov_duo'] = {
        [1] = 30,
        [2] = 15,
        [3] = -15,
        [4] = -30,
    },
    ['birzhamemov_trio'] = {
        [1] = 25,
        [2] = 0,
        [3] = -25,
    },
    ['birzhamemov_5v5'] = {
        [1] = 30,
        [2] = -30,
    },
    ['birzhamemov_5v5v5'] = {
        [1] = 20,
        [2] = 0,
        [3] = -20,
    }
}

function BirzhaData.GetMmrByTeamPlace(id)
    local winer_table = CustomNetTables:GetTableValue("birzha_mmr", "game_winner")
    local get_team_place = 
    function(t)
        local team = {}
            local teams_table = {2,3,6,7,8,9,10,11,12,13}
            for _, i in ipairs(teams_table) do
                table.insert(team, {id =i, kills = PlayerResource:GetTeamKills(i)} )
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
        if IsPlayerDisconnected(id) then 
            bonus_mmr = -30
        end
        if _G.HEROES_ID_TABLE[id] then
            if _G.HEROES_ID_TABLE[id][2] == true then
                bonus_mmr = 0
            end
        end
        CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = bonus_mmr})
        return bonus_mmr
    end
    CustomNetTables:SetTableValue('bonus_rating', tostring(id), {mmr = 0})
    return 0
end   