LinkLuaModifier( "modifier_item_magic_crystalis", "items/magic_crit", LUA_MODIFIER_MOTION_NONE )

item_magic_crystalis = class({})

function item_magic_crystalis:GetIntrinsicModifierName() 
    return "modifier_item_magic_crystalis"
end

modifier_item_magic_crystalis = class({})

function modifier_item_magic_crystalis:IsHidden() return true end
function modifier_item_magic_crystalis:IsPurgable() return false end
function modifier_item_magic_crystalis:IsPurgeException() return false end
function modifier_item_magic_crystalis:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_magic_crystalis:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_item_magic_crystalis:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_magic_crystalis:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_magic_crystalis:GetModifierConstantManaRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_magic_crystalis:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_magic_crystalis:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then 
        if params.inflictor ~= nil and params.inflictor:GetName() == "Ricardo_KokosMaslo" then return end
        --if params.original_damage < 100 then return end
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) ~= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS) ~= DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS then
            if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then
                params.target:EmitSound("DOTA_Item.HotD.Activate")
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, params.original_damage + (params.original_damage / 100 * (self:GetAbility():GetSpecialValueFor("crit") - 100)), nil)
                return self:GetAbility():GetSpecialValueFor("crit") - 100
            end
        end
    end
end

LinkLuaModifier( "modifier_item_magic_daedalus", "items/magic_crit", LUA_MODIFIER_MOTION_NONE )

item_magic_daedalus = class({})

function item_magic_daedalus:GetIntrinsicModifierName() 
    return "modifier_item_magic_daedalus"
end

modifier_item_magic_daedalus = class({})

function modifier_item_magic_daedalus:IsHidden() return true end
function modifier_item_magic_daedalus:IsPurgable() return false end
function modifier_item_magic_daedalus:IsPurgeException() return false end
function modifier_item_magic_daedalus:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_magic_daedalus:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, 
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_item_magic_daedalus:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_damage")

end

function modifier_item_magic_daedalus:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_magic_daedalus:GetModifierConstantManaRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_magic_daedalus:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then 
        --if params.original_damage < 100 then return end
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) ~= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS) ~= DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS then
            if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then
                params.target:EmitSound("DOTA_Item.HotD.Activate")
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, params.original_damage + (params.original_damage / 100 * (self:GetAbility():GetSpecialValueFor("crit") - 100)), nil)
                return self:GetAbility():GetSpecialValueFor("crit") - 100
            end
        end
    end
end