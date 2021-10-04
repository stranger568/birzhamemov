LinkLuaModifier("modifier_burger_strength", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burger_agility", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burger_intellect", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)

item_burger_sobolev = class({})

function item_burger_sobolev:OnSpellStart()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_burger_strength") then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_burger_strength", {})
        self.modifier:IncrementStackCount()
    else
    	self.modifier = self:GetCaster():FindModifierByName( "modifier_burger_strength" )
        self.modifier:IncrementStackCount()
    end
    self:GetCaster():EmitSound("item_burger")
    self:GetCaster():CalculateStatBonus(true)
    self:SpendCharge()
end

item_burger_oblomoff = class({})

function item_burger_oblomoff:OnSpellStart()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_burger_agility") then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_burger_agility", {})
        self.modifier:IncrementStackCount()
    else
    	self.modifier = self:GetCaster():FindModifierByName( "modifier_burger_agility" )
        self.modifier:IncrementStackCount()
    end
    self:GetCaster():EmitSound("item_burger")
    self:GetCaster():CalculateStatBonus(true)
    self:SpendCharge()
end

item_burger_larin = class({})

function item_burger_larin:OnSpellStart()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_burger_intellect") then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_burger_intellect", {})
        self.modifier:IncrementStackCount()
    else
    	self.modifier = self:GetCaster():FindModifierByName( "modifier_burger_intellect" )
        self.modifier:IncrementStackCount()
    end
    self:GetCaster():EmitSound("item_burger")
    self:GetCaster():CalculateStatBonus(true)
    self:SpendCharge()
end

modifier_burger_strength = class({})

function modifier_burger_strength:IsPurgable()
    return false
end

function modifier_burger_strength:GetTexture()
  	return "items/Burger1"
end

function modifier_burger_strength:OnCreated()
    self.bonus = self:GetAbility():GetSpecialValueFor('bonus_str')
end

function modifier_burger_strength:RemoveOnDeath()
    return false
end

function modifier_burger_strength:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return funcs
end

function modifier_burger_strength:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self.bonus
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
    self.bonus = self:GetAbility():GetSpecialValueFor('bonus_agi')
end

function modifier_burger_agility:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_burger_agility:GetModifierBonusStats_Agility()
    return self:GetStackCount() * self.bonus
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
    self.bonus = self:GetAbility():GetSpecialValueFor('bonus_int')
end

function modifier_burger_intellect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_burger_intellect:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self.bonus
end