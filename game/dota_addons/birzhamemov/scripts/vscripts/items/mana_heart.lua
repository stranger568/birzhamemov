LinkLuaModifier( "modifier_item_mana_heart_stats", "items/mana_heart", LUA_MODIFIER_MOTION_NONE )

item_mana_heart = class({})

modifier_item_mana_heart_stats = class({})

function item_mana_heart:GetIntrinsicModifierName() 
	return "modifier_item_mana_heart_stats"
end

function modifier_item_mana_heart_stats:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mana_heart_stats:IsPurgable()
    return false
end

function modifier_item_mana_heart_stats:OnCreated()
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
	self.mana_regen_active = self:GetAbility():GetSpecialValueFor("mana_regen_from_mana")
	self.strength = self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_mana_heart_stats:IsHidden()
return true
end

function modifier_item_mana_heart_stats:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
		}
end

function modifier_item_mana_heart_stats:GetModifierHealthBonus()
	return self.bonus_health
end

function modifier_item_mana_heart_stats:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_mana_heart_stats:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_item_mana_heart_stats:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_item_mana_heart_stats:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_mana_heart_stats:GetModifierConstantManaRegen()
	return self.mana_regen + self:GetParent():GetMaxMana() / 100 * self.mana_regen_active
end

function modifier_item_mana_heart_stats:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('magic_resist')
end