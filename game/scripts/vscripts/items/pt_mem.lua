LinkLuaModifier("modifier_item_pt_stats", "items/pt_mem", LUA_MODIFIER_MOTION_NONE)

item_pt_mem = class({})

function item_pt_mem:GetIntrinsicModifierName()
    return "modifier_item_pt_stats"
end

modifier_item_pt_stats = class({})

function modifier_item_pt_stats:IsHidden() return true end
function modifier_item_pt_stats:IsPurgable() return false end
function modifier_item_pt_stats:IsPurgeException() return false end
function modifier_item_pt_stats:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_pt_stats:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_pt_stats:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end

function modifier_item_pt_stats:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
    end
end

function modifier_item_pt_stats:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_stats')
    end
end

function modifier_item_pt_stats:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_stats')
    end
end

function modifier_item_pt_stats:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_stats')
    end
end