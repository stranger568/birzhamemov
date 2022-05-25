LinkLuaModifier("modifier_item_sharoeb", "items/sharoeb", LUA_MODIFIER_MOTION_NONE)

item_sharoeb = class({})

function item_sharoeb:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_arcane", {duration = 15})
    self:GetCaster():EmitSound("Rune.Arcane")
end

function item_sharoeb:GetIntrinsicModifierName()
    return "modifier_item_sharoeb"
end

modifier_item_sharoeb = class({})

function modifier_item_sharoeb:IsHidden()
	return true
end

function modifier_item_sharoeb:IsPurgable()
    return false
end

function modifier_item_sharoeb:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_item_sharoeb:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('dmg')
    end
end

function modifier_item_sharoeb:GetModifierPercentageCooldown()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('cd')
    end
end

function modifier_item_sharoeb:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mp')
    end
end

function modifier_item_sharoeb:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_sharoeb:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('int')
    end
end

function modifier_item_sharoeb:GetModifierCastRangeBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('castrange')
    end
end

function modifier_item_sharoeb:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('str')
    end
end

function modifier_item_sharoeb:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('agility')
    end
end

function modifier_item_sharoeb:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mana_regen')
    end
end








