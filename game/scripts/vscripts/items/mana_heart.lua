LinkLuaModifier( "modifier_item_mana_heart_stats", "items/mana_heart", LUA_MODIFIER_MOTION_NONE )

item_mana_heart = class({})

function item_mana_heart:GetIntrinsicModifierName() 
	return "modifier_item_mana_heart_stats"
end

modifier_item_mana_heart_stats = class({})

function modifier_item_mana_heart_stats:IsHidden() return true end
function modifier_item_mana_heart_stats:IsPurgable() return false end
function modifier_item_mana_heart_stats:IsPurgeException() return false end

function modifier_item_mana_heart_stats:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE 
	}
end

function modifier_item_mana_heart_stats:GetModifierManaBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_mana_heart_stats:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_mana_heart_stats:GetModifierTotalPercentageManaRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen_from_mana")
end