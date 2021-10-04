--[[
Cheat lobby commands
 -defaultplayer     	-- RemoveEffects.
 -lakadmatatag     	-- LAKAAAAD MATATAG NORMALIN NORMALIN.
]]
LinkLuaModifier( "modifier_disconnect_debuff", "modifiers/modifier_disconnect_debuff", LUA_MODIFIER_MOTION_NONE )

Commands = Commands or class({})

function Commands:is_cheats( player, arg )
	if GameRules:IsCheatMode() then else end
end 