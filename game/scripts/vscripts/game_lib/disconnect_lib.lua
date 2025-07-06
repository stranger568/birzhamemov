BMConnections = class({})

function BMConnections:RegListeners()
    ListenToGameEvent( "player_disconnect", Dynamic_Wrap( self, 'OnDisconnect' ), self )
    ListenToGameEvent( "player_reconnected", Dynamic_Wrap( self, 'OnPlayerReconnect'), self)
    BMConnections.BIRZHA_PLAYER_CONNECT_INFO = {}
end

function BMConnections:OnDisconnect(params)
    local player_id = params.PlayerID
    local hero_player = PlayerResource:GetSelectedHeroEntity(player_id)
    BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id] = BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id] or {}
    BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "disconnected"
    local leave_timer_player = 60
    Timers:CreateTimer(0, function()
        local connection_state = PlayerResource:GetConnectionState(player_id)
        if IsInToolsMode() then
            connection_state = DOTA_CONNECTION_STATE_ABANDONED
        end
        if connection_state ~= nil and connection_state == DOTA_CONNECTION_STATE_CONNECTED then
            BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "connected"
            return nil
        end
        if leave_timer_player <= 0 then
            BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BMConnections:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil 
        end
        if connection_state == nil then
            BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaGameMode:PlayerLeaveUpdateMaxScore()
            BMConnections:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil
        end
        if connection_state ~= nil and (connection_state == DOTA_CONNECTION_STATE_NOT_YET_CONNECTED or connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_UNKNOWN ) then
            BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaGameMode:PlayerLeaveUpdateMaxScore()
            BMConnections:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil
        end
        BMConnections:AutoWin()
        leave_timer_player = leave_timer_player - 1
        return 1
    end)
    birzha_hero_selection:DisconnectPlayer(player_id)
end    

function BMConnections:AddPlayerFullDisconnectDebuff(hero, player_id)
    BMConnections:AutoWin()
    Timers:CreateTimer(0, function()
        if BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id] and BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection == "connected" then return nil end
        if birzha_hero_selection.pick_ended then
            if hero and not hero:IsNull() then
                print("modifier_added", hero)
                hero:AddNewModifier(hero, nil, "modifier_birzha_disconnect", {})
            end
        end
        BMConnections:AutoWin()
        if hero and not hero:IsNull() and not hero:IsAlive() and not hero:HasModifier("modifier_birzha_disconnect") then
            return 1
        end
    end)
end

function BMConnections:OnPlayerReconnect(params)
    local player_id = params.PlayerID
    BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id] = BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id] or {}
    BMConnections.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "connected"
    local hero_player = PlayerResource:GetSelectedHeroEntity(player_id)
    if hero_player and not hero_player:IsNull() then
        hero_player:RemoveModifierByName("modifier_birzha_disconnect")
        hero_player:SetControllableByPlayer(player_id, true)
        PlayerResource:GetPlayer(player_id):SetAssignedHeroEntity(hero_player)
        hero_player:SetOwner(PlayerResource:GetPlayer(player_id))
    end
end

function IsPlayerDisconnected(id)
    local table = BMConnections.BIRZHA_PLAYER_CONNECT_INFO[tonumber(id)] or {}
    return table.connection == "disconnected" or table.connection == "abandoned"
end

function IsPlayerAbandoned(id)
    local table = BMConnections.BIRZHA_PLAYER_CONNECT_INFO[tonumber(id)] or {}
    return table.connection == "abandoned"
end

function BMConnections:AutoWin()
    local nNewState = GameRules:State_Get()
    if nNewState ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        return
    end
    local winteam = nil
	local teams_table = table.deepcopy(_G.GET_TEAM_LIST[GetMapName()])
    DeepPrintTable(teams_table)
    for i=#teams_table, 1, -1 do
        if teams_table[i] ~= nil and self:GetPlayersInTeam(teams_table[i]) <= 0 then
            table.remove(teams_table, i)
        end
    end
    if #teams_table <= 1 then
        winteam = teams_table[1]
    end
    print("#teams_table", #teams_table)
    DeepPrintTable(teams_table)
	if winteam ~= nil then
		BirzhaGameMode:EndGame(winteam)
		GameRules:SetGameWinner(winteam)
	end
end

function BMConnections:GetPlayersInTeam(t)
	local count = 0
	for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		if not IsPlayerAbandoned(id) and (player_info.team ~= nil and player_info.team == t) then
			count = count + 1
		end
	end
	return count
end