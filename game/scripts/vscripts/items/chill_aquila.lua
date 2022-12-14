LinkLuaModifier( "modifier_chill_aquila_aura_buff", "items/chill_aquila", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chill_aquila", "items/chill_aquila", LUA_MODIFIER_MOTION_NONE )

item_chill_aquila = class({})

function item_chill_aquila:GetIntrinsicModifierName() 
	return "modifier_chill_aquila"
end

function item_chill_aquila:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_doubledamage", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("Rune.DD")
end

modifier_chill_aquila = class({})

function modifier_chill_aquila:IsHidden() return true end
function modifier_chill_aquila:IsPurgable() return false end
function modifier_chill_aquila:IsPurgeException() return false end
function modifier_chill_aquila:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_chill_aquila:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS  }
end

function modifier_chill_aquila:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_chill_aquila:GetModifierPreAttack_BonusDamage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_chill_aquila:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_at")
end

function modifier_chill_aquila:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_chill_aquila:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_chill_aquila:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_chill_aquila:IsAura()
	return true
end

function modifier_chill_aquila:GetAuraRadius()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("radius")
	end
end

function modifier_chill_aquila:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_chill_aquila:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_chill_aquila:IsHidden()
	return true
end

function modifier_chill_aquila:GetModifierAura()
	return "modifier_chill_aquila_aura_buff"
end

modifier_chill_aquila_aura_buff = class({})

function modifier_chill_aquila_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_chill_aquila_aura_buff:GetModifierConstantManaRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_chill_aquila_aura_buff:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("armor")
end





