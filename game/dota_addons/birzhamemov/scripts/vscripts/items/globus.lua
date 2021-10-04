LinkLuaModifier("modifier_item_globus", "items/globus", LUA_MODIFIER_MOTION_NONE)

item_globus = class({})

function item_globus:GetIntrinsicModifierName()
    return "modifier_item_globus"
end

modifier_item_globus = class({})

function modifier_item_globus:IsHidden()
	return true
end

function modifier_item_globus:AllowIllusionDuplicate()
	return true
end

function modifier_item_globus:IsPurgable()
    return false
end

function modifier_item_globus:IsDebuff()
    return false
end

function modifier_item_globus:IsBuff()
    return true
end

function modifier_item_globus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_globus:GetModifierPercentageCooldown()
    if self:GetParent():HasItemInInventory("item_sharoeb") then self.cd = 0 return 0 end
    self.cd = self:GetAbility():GetSpecialValueFor('cd')
    return self.cd
end

function modifier_item_globus:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor('mp')
end

function modifier_item_globus:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('hp')
end

function modifier_item_globus:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('int')
end