LinkLuaModifier( "modifier_birzha_map_center_vision_aura", "modifiers/modifier_birzha_map_center_vision.lua", LUA_MODIFIER_MOTION_NONE )

modifier_birzha_map_center_vision = class({})

function modifier_birzha_map_center_vision:OnCreated(kv)
	self.radius = kv.radius
end

function modifier_birzha_map_center_vision:IsAura()
    return true
end

function modifier_birzha_map_center_vision:IsHidden()
    return true
end

function modifier_birzha_map_center_vision:IsPurgable()
    return false
end

function modifier_birzha_map_center_vision:GetAuraRadius()
    return self.radius
end

function modifier_birzha_map_center_vision:GetModifierAura()
    return "modifier_birzha_map_center_vision_aura"
end
   
function modifier_birzha_map_center_vision:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_birzha_map_center_vision:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_birzha_map_center_vision:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

modifier_birzha_map_center_vision_aura = class({})

function modifier_birzha_map_center_vision_aura:CheckState()
    if self:GetParent():HasModifier("modifier_travoman_minefield_sign_aura") then return end
	return {[MODIFIER_STATE_INVISIBLE] = false,}
end

function modifier_birzha_map_center_vision_aura:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_birzha_map_center_vision_aura:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_birzha_map_center_vision_aura:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_birzha_map_center_vision_aura:GetTexture()
   return "item_gem"
end