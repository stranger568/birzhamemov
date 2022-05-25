LinkLuaModifier( "modifier_item_overheal_trank", "items/tranquil", LUA_MODIFIER_MOTION_NONE )

item_overheal_trank = class({})

modifier_item_overheal_trank = class({})

function item_overheal_trank:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = duration})
    target:EmitSound("Rune.Regen")
end

function item_overheal_trank:GetIntrinsicModifierName() 
    return "modifier_item_overheal_trank"
end

modifier_item_overheal_trank = class({})

function modifier_item_overheal_trank:IsHidden()
    return true
end

function modifier_item_overheal_trank:IsPurgable()
    return false
end

function modifier_item_overheal_trank:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS
    }

    return funcs
end

function modifier_item_overheal_trank:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
    end
end

function modifier_item_overheal_trank:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_regen")
    end
end

function modifier_item_overheal_trank:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_health")
    end
end
