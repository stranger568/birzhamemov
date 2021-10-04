LinkLuaModifier("modifier_item_spinner", "items/spinner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

item_spinner = class({})

function item_spinner:GetIntrinsicModifierName()
	return "modifier_item_spinner"
end

modifier_item_spinner = class({})

function modifier_item_spinner:IsHidden()		return true end
function modifier_item_spinner:IsPurgable()		return false end
function modifier_item_spinner:RemoveOnDeath()	return false end