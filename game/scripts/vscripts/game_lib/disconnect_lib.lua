BirzhaEvents = class({})

function BirzhaEvents:RegListeners()
    ListenToGameEvent( "player_disconnect", Dynamic_Wrap( self, 'OnDisconnect' ), self )
    ListenToGameEvent( "player_reconnected", Dynamic_Wrap( self, 'OnPlayerReconnect'), self)
    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO = {}
end

function BirzhaEvents:OnDisconnect(params)
    local player_id = params.PlayerID
    local hero_player = PlayerResource:GetSelectedHeroEntity(player_id)
    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] = BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] or {}
    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "disconnected"
    local leave_timer_player = 60
    Timers:CreateTimer(0, function()
        if PlayerResource:GetConnectionState(player_id) ~= nil and PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_CONNECTED then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[id].connection = "connected"
            return nil
        end
        if leave_timer_player <= 0 then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaEvents:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil 
        end
        if PlayerResource:GetConnectionState(player_id) == nil then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaGameMode:PlayerLeaveUpdateMaxScore()
            BirzhaEvents:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil
        end
        if PlayerResource:GetConnectionState(player_id) ~= nil and (PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_NOT_YET_CONNECTED or PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_ABANDONED or PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_UNKNOWN ) then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaGameMode:PlayerLeaveUpdateMaxScore()
            BirzhaEvents:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil
        end
        BirzhaEvents:AutoWin()
        leave_timer_player = leave_timer_player - 1
        return 1
    end)
end    

function BirzhaEvents:AddPlayerFullDisconnectDebuff(hero, player_id)
    BirzhaEvents:AutoWin()
    Timers:CreateTimer(0, function()
        if BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] and BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection == "connected" then return nil end
        if birzha_hero_selection.pick_ended then
            if hero and not hero:IsNull() then
                hero:AddNewModifier(hero, nil, "modifier_birzha_disconnect", {})
            end
        end
        BirzhaEvents:AutoWin()
        if hero and not hero:IsNull() and not hero:IsAlive() and not hero:HasModifier("modifier_birzha_disconnect") then
            return 1
        end
    end)
end

function BirzhaEvents:OnPlayerReconnect(params)
    local player_id = params.PlayerID
    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] = BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] or {}
    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "connected"
    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[ player_id ] then
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[ player_id ].picked_hero ~= nil and birzha_hero_selection.DISCONNECTED[player_id] ~= nil then
            local new_hero = birzha_hero_selection.DISCONNECTED[player_id]
            birzha_hero_selection:GiveHeroPlayer(player_id, new_hero)
            birzha_hero_selection.DISCONNECTED[player_id] = nil
        end
    end
    local hero_player = PlayerResource:GetSelectedHeroEntity(player_id)
    if hero_player and not hero_player:IsNull() then
        hero_player:RemoveModifierByName("modifier_birzha_disconnect")
    end
end

function IsPlayerDisconnected(id)
    local table = BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[tonumber(id)] or {}
    return table.connection == "disconnected" or table.connection == "abandoned"
end

function IsPlayerAbandoned(id)
    local table = BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[tonumber(id)] or {}
    return table.connection == "abandoned"
end

function BirzhaEvents:AutoWin()
    local nNewState = GameRules:State_Get()
    if nNewState ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        return
    end
    local winteam = nil
	local teams_table = {2,3,6,7,8,9,10,11,12,13}
    for i=#teams_table, 1, -1 do
        if teams_table[i] ~= nil and self:GetPlayersInTeam(teams_table[i]) <= 0 then
            table.remove(teams_table, i)
        end
    end
    if #teams_table <= 1 then
        winteam = teams_table[1]
    end
	if winteam ~= nil then
		BirzhaGameMode:EndGame(winteam)
		GameRules:SetGameWinner(winteam)
	end
end

function BirzhaEvents:GetPlayersInTeam(t)
	local count = 0
	for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		if not IsPlayerAbandoned(id) and (player_info.team ~= nil and player_info.team == t) then
			count = count + 1
		end
	end
	return count
end