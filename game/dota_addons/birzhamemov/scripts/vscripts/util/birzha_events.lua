LinkLuaModifier( "modifier_birzha_disconnect", "modifiers/modifier_birzha_disconnect", LUA_MODIFIER_MOTION_NONE )

BirzhaEvents = class({})
BIRZHA_ABAN_PLAYERS_EVENTS = {}
BIRZHA_PLAYER_CONNECT_INFO = {}

function BirzhaEvents:RegListeners()
    ListenToGameEvent( "player_disconnect", Dynamic_Wrap( self, 'OnDisconnect' ), self )
    ListenToGameEvent("player_reconnected", Dynamic_Wrap( self, 'OnPlayerReconnect'), self)
end

function BirzhaEvents:OnDisconnect(table)
    BIRZHA_PLAYER_CONNECT_INFO[table.PlayerID] = BIRZHA_PLAYER_CONNECT_INFO[table.PlayerID] or {}
    BIRZHA_PLAYER_CONNECT_INFO[table.PlayerID].connection = "disconnected"
    local player = PlayerResource:GetPlayer(table.PlayerID)
    if player then
        local hero = player:GetAssignedHero()
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
    if _G.HEROES_ID_TABLE[table.PlayerID] then
        _G.HEROES_ID_TABLE[id][2] = false
    end
    local player = PlayerResource:GetPlayer(id)
    local hero = player:GetAssignedHero()
    if PLAYERS[ id ].picked_hero ~= nil and DISCONNECTED[id] then
        local new_hero = DISCONNECTED[id]
        DISCONNECTED[id] = nil
        CustomPick:GiveHeroPlayer(id, new_hero)
    end
    hero:RemoveModifierByName("modifier_birzha_disconnect")
end

function BirzhaEvents:SendJsEventAllClients(event_name, t)
    for id = 0, PlayerResource:GetPlayerCount() - 1 do
        if not IsPlayerDisconnected(id) then
            CustomGameEventManager:Send_ServerToAllClients(event_name, t)
        else
            BIRZHA_ABAN_PLAYERS_EVENTS[id] = BIRZHA_ABAN_PLAYERS_EVENTS[id] or {}
            table.insert(BIRZHA_ABAN_PLAYERS_EVENTS[id], {event_n = event_name, table = t})
        end    
    end
end

function IsPlayerDisconnected(id)
    local table = BIRZHA_PLAYER_CONNECT_INFO[tonumber(id)] or {}
    return table.connection == "disconnected"
end