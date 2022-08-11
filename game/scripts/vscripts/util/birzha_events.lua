LinkLuaModifier( "modifier_birzha_disconnect", "modifiers/modifier_birzha_disconnect", LUA_MODIFIER_MOTION_NONE )

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
        if leave_timer_player <= 0 then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaEvents:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil 
        end

        if PlayerResource:GetConnectionState(player_id) == nil then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaEvents:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil
        end

        if PlayerResource:GetConnectionState(player_id) ~= nil and (PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_NOT_YET_CONNECTED or PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_ABANDONED or PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_UNKNOWN ) then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "abandoned"
            BirzhaEvents:AddPlayerFullDisconnectDebuff(hero_player, player_id)
            return nil
        end

        if PlayerResource:GetConnectionState(player_id) ~= nil and PlayerResource:GetConnectionState(player_id) == DOTA_CONNECTION_STATE_CONNECTED then
            BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[id].connection = "connected"
            return nil
        end

        BirzhaDisconnectFunction:AutoWin()

        leave_timer_player = leave_timer_player - 1

        return 1
    end)
end    

function BirzhaEvents:AddPlayerFullDisconnectDebuff(hero, player_id)
    BirzhaDisconnectFunction:AutoWin()
    Timers:CreateTimer(0, function()
        if BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection == "connected" then return nil end
        local table_pick_state = CustomNetTables:GetTableValue("game_state", "pickstate")
        if table_pick_state and table_pick_state.v and table_pick_state.v == "ended" then
            if hero then
                if hero:IsIllusion() then 
                    hero:ForceKill(false)
                    return 
                end
                hero:AddNewModifier(hero, nil, "modifier_birzha_disconnect", {})
            end
        end
        if not hero:IsAlive() and not hero:HasModifier("modifier_birzha_disconnect") then
            return 1
        end
    end)
end

function BirzhaEvents:OnPlayerReconnect(params)
    local player_id = params.PlayerID
    local hero_player = PlayerResource:GetSelectedHeroEntity(player_id)

    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] = BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id] or {}
    BirzhaEvents.BIRZHA_PLAYER_CONNECT_INFO[player_id].connection = "connected"

    if PLAYERS[ player_id ] then
        if PLAYERS[ player_id ].picked_hero ~= nil and CustomPick.DISCONNECTED[player_id] ~= nil then
            local new_hero = CustomPick.DISCONNECTED[player_id]
            CustomPick:GiveHeroPlayer(player_id, new_hero)
            CustomPick.DISCONNECTED[player_id] = nil
        end
    end

    local table_pick_state = CustomNetTables:GetTableValue("game_state", "pickstate")
    if table_pick_state and table_pick_state.v and table_pick_state.v == "ended" then
        if hero_player and hero_player ~= nil then
            hero_player:RemoveModifierByName("modifier_birzha_disconnect")
        end
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