LinkLuaModifier( "modifier_birzha_disconnect", "modifiers/modifier_birzha_disconnect", LUA_MODIFIER_MOTION_NONE )

BirzhaEvents = class({})
BIRZHA_PLAYER_CONNECT_INFO = {}

function BirzhaEvents:RegListeners()
    ListenToGameEvent( "player_disconnect", Dynamic_Wrap( self, 'OnDisconnect' ), self )
    ListenToGameEvent( "player_reconnected", Dynamic_Wrap( self, 'OnPlayerReconnect'), self)
end

function BirzhaEvents:OnDisconnect(table)
    BIRZHA_PLAYER_CONNECT_INFO[table.PlayerID] = BIRZHA_PLAYER_CONNECT_INFO[table.PlayerID] or {}
    BIRZHA_PLAYER_CONNECT_INFO[table.PlayerID].connection = "disconnected"

    local table_pick_state = CustomNetTables:GetTableValue("game_state", "pickstate")
    if table_pick_state and table_pick_state.v and table_pick_state.v == "ended" then
        local hero = PlayerResource:GetSelectedHeroEntity(table.PlayerID)
        if hero then
            if hero:IsIllusion() then return end
            hero:AddNewModifier(hero, nil, "modifier_birzha_disconnect", {})
        end
    end
end     

function BirzhaEvents:OnPlayerReconnect(table)
    local id = tonumber(table.PlayerID)

    BIRZHA_PLAYER_CONNECT_INFO[id] = BIRZHA_PLAYER_CONNECT_INFO[id] or {}
    BIRZHA_PLAYER_CONNECT_INFO[id].connection = "connected"

    if PLAYERS[ id ] then
        if PLAYERS[ id ].picked_hero ~= nil and DISCONNECTED[id] then
            local new_hero = DISCONNECTED[id]
            CustomPick:GiveHeroPlayer(id, new_hero)
            DISCONNECTED[id] = nil
        end
    end

    local table_pick_state = CustomNetTables:GetTableValue("game_state", "pickstate")
    if table_pick_state and table_pick_state.v and table_pick_state.v == "ended" then
        local hero = PlayerResource:GetSelectedHeroEntity(table.PlayerID)
        if hero and hero ~= nil then
            hero:RemoveModifierByName("modifier_birzha_disconnect")
        end
    end
end

function IsPlayerDisconnected(id)
    local table = BIRZHA_PLAYER_CONNECT_INFO[tonumber(id)] or {}
    return table.connection == "disconnected"
end