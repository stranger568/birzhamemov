LinkLuaModifier( "modifier_item_aether_lupa", "items/aether_lupa", LUA_MODIFIER_MOTION_NONE )

item_aether_lupa = class({})

modifier_item_aether_lupa = class({})

function item_aether_lupa:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_arcane", {duration = 15})
	self:GetCaster():EmitSound("Rune.Arcane")
end

function item_aether_lupa:GetIntrinsicModifierName() 
	return "modifier_item_aether_lupa"
end

modifier_item_aether_lupa = class({})

function modifier_item_aether_lupa:OnCreated()
	self.int = self:GetAbility():GetSpecialValueFor("bonus_int")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.manaregen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_aether_lupa:IsHidden()
	return true
end

function modifier_item_aether_lupa:IsPurgable()
    return false
end

function modifier_item_aether_lupa:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_CAST_RANGE_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_item_aether_lupa:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_aether_lupa:GetModifierSpellAmplify_Percentage()
	return 8
end

function modifier_item_aether_lupa:GetModifierBonusStats_Agility()
	return 6
end

function modifier_item_aether_lupa:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_aether_lupa:GetModifierManaBonus()
	return self.mana
end

function modifier_item_aether_lupa:GetModifierConstantManaRegen()
	return self.manaregen
end

function modifier_item_aether_lupa:GetModifierCastRangeBonus()
	return 225
end