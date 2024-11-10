LinkLuaModifier("modifier_burger_strength", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burger_agility", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burger_intellect", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)

item_burger_sobolev = class({})

function item_burger_sobolev:OnAbilityPhaseStart()
    if not self:GetCaster():IsHero() then
        return false
    end
    return true
end

function item_burger_sobolev:OnSpellStart()
    if not IsServer() then return end
    local original_modifier = "modifier_burger_strength"
    local item_stack_count = self:GetCurrentCharges()
    local find_modifier = self:GetCaster():FindModifierByName( original_modifier )
    if not find_modifier then
        find_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, original_modifier, {})
    end
    for i=1, item_stack_count do
        find_modifier:IncrementStackCount()
    end
    self:GetCaster():EmitSound("item_burger")
    self:GetCaster():CalculateStatBonus(true)
    self:GetCaster():ConsumeItem(self)
end

item_burger_oblomoff = class({})

function item_burger_oblomoff:OnAbilityPhaseStart()
    if not self:GetCaster():IsHero() then
        return false
    end
    return true
end

function item_burger_oblomoff:OnSpellStart()
    if not IsServer() then return end
    local original_modifier = "modifier_burger_agility"
    local item_stack_count = self:GetCurrentCharges()
    local find_modifier = self:GetCaster():FindModifierByName( original_modifier )
    if not find_modifier then
        find_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, original_modifier, {})
    end
    for i=1, item_stack_count do
        find_modifier:IncrementStackCount()
    end
    self:GetCaster():EmitSound("item_burger")
    self:GetCaster():CalculateStatBonus(true)
    self:GetCaster():ConsumeItem(self)
end

item_burger_larin = class({})

function item_burger_larin:OnAbilityPhaseStart()
    if not self:GetCaster():IsHero() then
        return false
    end
    return true
end

function item_burger_larin:OnSpellStart()
    if not IsServer() then return end
    local original_modifier = "modifier_burger_intellect"
    local item_stack_count = self:GetCurrentCharges()
    local find_modifier = self:GetCaster():FindModifierByName( original_modifier )
    if not find_modifier then
        find_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, original_modifier, {})
    end
    for i=1, item_stack_count do
        find_modifier:IncrementStackCount()
    end
    self:GetCaster():EmitSound("item_burger")
    self:GetCaster():CalculateStatBonus(true)
    self:GetCaster():ConsumeItem(self)
end

modifier_burger_strength = class({})

function modifier_burger_strength:IsPurgable()
    return false
end

function modifier_burger_strength:GetTexture()
  	return "items/Burger1"
end

function modifier_burger_strength:OnCreated()
    self.bonus = self:GetAbility():GetSpecialValueFor("bonus_str")
    self.resist = self:GetAbility():GetSpecialValueFor("resist")
end

function modifier_burger_strength:RemoveOnDeath()
    return false
end

function modifier_burger_strength:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }

    return funcs
end

function modifier_burger_strength:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self.bonus
end

function modifier_burger_strength:GetModifierStatusResistanceStacking()
    return self:GetStackCount() * self.resist
end

modifier_burger_agility = class({})

function modifier_burger_agility:IsPurgable()
    return false
end

function modifier_burger_agility:RemoveOnDeath()
    return false
end

function modifier_burger_agility:GetTexture()
  	return "items/Burger2"
end

function modifier_burger_agility:OnCreated()
    self.bonus = self:GetAbility():GetSpecialValueFor("bonus_agi")
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_burger_agility:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_burger_agility:GetModifierBonusStats_Agility()
    return self:GetStackCount() * self.bonus
end

function modifier_burger_agility:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * self.movespeed
end

modifier_burger_intellect = class({})

function modifier_burger_intellect:IsPurgable()
    return false
end

function modifier_burger_intellect:RemoveOnDeath()
    return false
end

function modifier_burger_intellect:GetTexture()
  	return "items/Burger3"
end

function modifier_burger_intellect:OnCreated()
    self.bonus = self:GetAbility():GetSpecialValueFor("bonus_int")
    self.amplify = self:GetAbility():GetSpecialValueFor("spell_amplify")
end

function modifier_burger_intellect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }

    return funcs
end

function modifier_burger_intellect:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self.bonus
end

function modifier_burger_intellect:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount() * self.amplify
end