LinkLuaModifier("modifier_item_globus", "items/globus", LUA_MODIFIER_MOTION_NONE)

item_globus = class({})

function item_globus:GetIntrinsicModifierName()
    return "modifier_item_globus"
end

modifier_item_globus = class({})

function modifier_item_globus:IsHidden()
	return true
end

function modifier_item_globus:IsPurgable()
    return false
end

function modifier_item_globus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE ,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_globus:GetModifierPercentageCooldown()
    if self:GetAbility() then
        if self:GetParent():HasItemInInventory("item_sharoeb") then self.cd = 0 return 0 end
        self.cd = self:GetAbility():GetSpecialValueFor('cd')
        return self.cd
    end
end

function modifier_item_globus:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mp')
    end
end

function modifier_item_globus:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_globus:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('int')
    end
end