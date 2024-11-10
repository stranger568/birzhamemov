LinkLuaModifier("modifier_item_ultimate_mem", "items/scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ultimate_mem_perm", "items/scepter", LUA_MODIFIER_MOTION_NONE)

item_ultimate_mem = class({})

function item_ultimate_mem:GetIntrinsicModifierName()
    return "modifier_item_ultimate_mem"
end

function item_ultimate_mem:CastFilterResultTarget(target)
    if target:HasModifier("modifier_item_ultimate_scepter_consumed") or target:HasModifier("modifier_item_ultimate_mem_perm") then
        return UF_FAIL_CUSTOM
    end
    if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
        return UF_FAIL_ENEMY
    end
    return UF_SUCCESS
end 

function item_ultimate_mem:GetCustomCastErrorTarget(target)
    if target:HasModifier("modifier_item_ultimate_scepter_consumed") or target:HasModifier("modifier_item_ultimate_mem_perm") then
        return "#dota_hud_error_cant_cast_on_other"
    end
end

function item_ultimate_mem:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    target:AddNewModifier( self:GetCaster(), self, "modifier_item_ultimate_scepter_consumed", {} )
    target:AddNewModifier( self:GetCaster(), self, "modifier_item_ultimate_mem_perm", {} )
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_scepter")
    end
    target:ConsumeItem(self)
end

modifier_item_ultimate_mem = class({})

function modifier_item_ultimate_mem:IsHidden()
    return true
end

function modifier_item_ultimate_mem:IsPurgable()
    return false
end

function modifier_item_ultimate_mem:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_ultimate_mem:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_hp')
    end
end

function modifier_item_ultimate_mem:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_mana')
    end
end

function modifier_item_ultimate_mem:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('all_stats')
    end
end

function modifier_item_ultimate_mem:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('all_stats')
    end
end

function modifier_item_ultimate_mem:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('all_stats')
    end
end

modifier_item_ultimate_mem_perm = class({})

function modifier_item_ultimate_mem_perm:IsHidden()
    return true
end

function modifier_item_ultimate_mem_perm:RemoveOnDeath()
    return false
end

function modifier_item_ultimate_mem_perm:IsPurgable()
    return false
end

function modifier_item_ultimate_mem_perm:OnCreated()
    if not IsServer() then return end
    self.hp = self:GetAbility():GetSpecialValueFor('bonus_hp')
    self.mana = self:GetAbility():GetSpecialValueFor('bonus_mana')
    self.stats = self:GetAbility():GetSpecialValueFor('all_stats')
end

function modifier_item_ultimate_mem_perm:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_ultimate_mem_perm:GetModifierHealthBonus()
    return self.hp
end

function modifier_item_ultimate_mem_perm:GetModifierManaBonus()
    return self.mana
end

function modifier_item_ultimate_mem_perm:GetModifierBonusStats_Strength()
    return self.stats
end

function modifier_item_ultimate_mem_perm:GetModifierBonusStats_Agility()
    return self.stats
end

function modifier_item_ultimate_mem_perm:GetModifierBonusStats_Intellect()
    return self.stats
end