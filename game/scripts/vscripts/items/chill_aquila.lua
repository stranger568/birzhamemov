LinkLuaModifier( "modifier_chill_aquila_aura", "items/chill_aquila", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chill_aquila_aura_buff", "items/chill_aquila", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chill_aquila", "items/chill_aquila", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chill_aquila_dd", "items/chill_aquila", LUA_MODIFIER_MOTION_NONE )

item_chill_aquila = class({})

function item_chill_aquila:GetIntrinsicModifierName() 
	return "modifier_chill_aquila"
end

function item_chill_aquila:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_doubledamage", {duration = 15})
	self:GetCaster():EmitSound("Rune.DD")
end


modifier_chill_aquila = class({})

function modifier_chill_aquila:IsHidden()
    return true
end

function modifier_chill_aquila:IsPurgable()
    return false
end

function modifier_chill_aquila:OnCreated()
	self.ag = self:GetAbility():GetSpecialValueFor("bonus_agility")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_int")
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.at = self:GetAbility():GetSpecialValueFor("bonus_at")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_chill_aquila_aura") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_chill_aquila_aura", {})
	end
end

function modifier_chill_aquila:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_chill_aquila") then
			self:GetCaster():RemoveModifierByName("modifier_chill_aquila_aura")
		end
	end
end

function modifier_chill_aquila:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS  }
end

function modifier_chill_aquila:GetModifierBonusStats_Agility()
	return self.ag
end

function modifier_chill_aquila:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_chill_aquila:GetModifierAttackSpeedBonus_Constant()
	return self.at
end

function modifier_chill_aquila:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_chill_aquila:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_chill_aquila:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

modifier_chill_aquila_aura = class({})

function modifier_chill_aquila_aura:IsAura()
	return true
end

function modifier_chill_aquila_aura:GetAuraRadius()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("radius")
	end
end

function modifier_chill_aquila_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_chill_aquila_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_chill_aquila_aura:IsHidden()
	return true
end

function modifier_chill_aquila_aura:GetModifierAura()
	return "modifier_chill_aquila_aura_buff"
end

modifier_chill_aquila_aura_buff = class({})

function modifier_chill_aquila_aura_buff:OnCreated()
	self.ar = self:GetAbility():GetSpecialValueFor("armor")
	self.mg = self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_chill_aquila_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_chill_aquila_aura_buff:GetModifierConstantManaRegen()
	return self.mg
end

function modifier_chill_aquila_aura_buff:GetModifierPhysicalArmorBonus()
	return self.ar 
end

modifier_chill_aquila_dd = class({})

function modifier_chill_aquila_dd:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_chill_aquila_dd:OnCreated()
	self.dmax = self:GetParent():GetBaseDamageMax()
end

function modifier_chill_aquila_dd:GetModifierBaseAttack_BonusDamage()
	return self.dmax
end

function modifier_chill_aquila_dd:GetEffectName()
	return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_chill_aquila_dd:GetTexture()
  	return "items/AetherLupa"
end





