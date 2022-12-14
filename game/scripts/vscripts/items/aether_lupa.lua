LinkLuaModifier( "modifier_item_aether_lupa", "items/aether_lupa", LUA_MODIFIER_MOTION_NONE )

item_aether_lupa = class({})

modifier_item_aether_lupa = class({})

function item_aether_lupa:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_arcane", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("Rune.Arcane")
end

function item_aether_lupa:GetIntrinsicModifierName() 
	return "modifier_item_aether_lupa"
end

modifier_item_aether_lupa = class({})

function modifier_item_aether_lupa:IsHidden() return true end
function modifier_item_aether_lupa:IsPurgable() return false end
function modifier_item_aether_lupa:IsPurgeException() return false end
function modifier_item_aether_lupa:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_aether_lupa:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE
	}
end

function modifier_item_aether_lupa:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_aether_lupa:GetModifierSpellAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("lupa_damage")
end

function modifier_item_aether_lupa:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_aether_lupa:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_aether_lupa:GetModifierConstantManaRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_aether_lupa:GetModifierCastRangeBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("castrange")
end

function modifier_item_aether_lupa:GetModifierExtraManaPercentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end