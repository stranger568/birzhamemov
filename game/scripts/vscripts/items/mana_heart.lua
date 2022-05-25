LinkLuaModifier( "modifier_item_mana_heart_stats", "items/mana_heart", LUA_MODIFIER_MOTION_NONE )

item_mana_heart = class({})

modifier_item_mana_heart_stats = class({})

function item_mana_heart:GetIntrinsicModifierName() 
	return "modifier_item_mana_heart_stats"
end

function modifier_item_mana_heart_stats:IsPurgable()
    return false
end

function modifier_item_mana_heart_stats:OnCreated()
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen_from_mana") / 100
end

function modifier_item_mana_heart_stats:IsHidden()
return true
end

function modifier_item_mana_heart_stats:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		}
end

function modifier_item_mana_heart_stats:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_mana_heart_stats:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_item_mana_heart_stats:GetModifierConstantManaRegen()
	return self.mana_regen * self:GetParent():GetMaxMana()
end
