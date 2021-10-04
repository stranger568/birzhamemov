LinkLuaModifier("modifier_item_sharoeb", "items/sharoeb", LUA_MODIFIER_MOTION_NONE)

item_sharoeb = class({})

function item_sharoeb:GetIntrinsicModifierName()
    return "modifier_item_sharoeb"
end

modifier_item_sharoeb = class({})

function modifier_item_sharoeb:IsHidden()
	return true
end

function modifier_item_sharoeb:AllowIllusionDuplicate()
	return true
end

function modifier_item_sharoeb:IsPurgable()
    return false
end

function modifier_item_sharoeb:IsDebuff()
    return false
end

function modifier_item_sharoeb:IsBuff()
    return true
end

function modifier_item_sharoeb:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }

    return funcs
end

function modifier_item_sharoeb:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_item_sharoeb:GetModifierPercentageCooldown()
    if self:GetParent():HasItemInInventory("item_octarine_core") then self.cd = 0 return end
    self.cd = self:GetAbility():GetSpecialValueFor('cd')
    return self.cd
end

function modifier_item_sharoeb:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor('mp')
end

function modifier_item_sharoeb:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('hp')
end

function modifier_item_sharoeb:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('int')
end

function modifier_item_sharoeb:GetModifierPercentageManacost()
    return self:GetAbility():GetSpecialValueFor('reduce_mana')
end

function modifier_item_sharoeb:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('magic_resist')
end