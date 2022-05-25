LinkLuaModifier( "modifier_drum_of_speedrun_aura", "items/drum_of_speedrun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_drum_of_speedrun_aura_buff", "items/drum_of_speedrun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_drum_of_speedrun", "items/drum_of_speedrun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_haste_birzha", "items/drum_of_speedrun", LUA_MODIFIER_MOTION_NONE )

item_drum_of_speedrun = class({})

function item_drum_of_speedrun:GetIntrinsicModifierName() 
	return "modifier_drum_of_speedrun"
end

function item_drum_of_speedrun:OnSpellStart()
	if not IsServer() then return end
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,unit in pairs(targets) do
		unit:AddNewModifier(self:GetCaster(), self, "modifier_rune_haste_birzha", {duration = 20})
	end
	self:GetCaster():EmitSound("Rune.Haste")
end

modifier_drum_of_speedrun = class({})

function modifier_drum_of_speedrun:IsHidden()
    return true
end

function modifier_drum_of_speedrun:IsPurgable()
    return false
end

function modifier_drum_of_speedrun:OnCreated()
	self.ag = self:GetAbility():GetSpecialValueFor("bonus_agility")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_int")
	self.resist = self:GetAbility():GetSpecialValueFor("mag_resist")
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_drum_of_speedrun_aura") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_drum_of_speedrun_aura", {})
	end
end

function modifier_drum_of_speedrun:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_drum_of_speedrun") then
			self:GetCaster():RemoveModifierByName("modifier_drum_of_speedrun_aura")
		end
	end
end

function modifier_drum_of_speedrun:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS  }
end

function modifier_drum_of_speedrun:GetModifierBonusStats_Agility()
	return self.ag
end

function modifier_drum_of_speedrun:GetModifierMagicalResistanceBonus()
	return self.resist
end

function modifier_drum_of_speedrun:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_drum_of_speedrun:GetModifierBonusStats_Strength()
	return self.str
end

modifier_drum_of_speedrun_aura = class({})

function modifier_drum_of_speedrun_aura:IsAura()
	return true
end

function modifier_drum_of_speedrun_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_drum_of_speedrun_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_drum_of_speedrun_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_drum_of_speedrun_aura:IsHidden()
	return true
end

function modifier_drum_of_speedrun_aura:GetModifierAura()
	return "modifier_drum_of_speedrun_aura_buff"
end

modifier_drum_of_speedrun_aura_buff = class({})

function modifier_drum_of_speedrun_aura_buff:OnCreated()
	self.mv = self:GetAbility():GetSpecialValueFor("movespeed")
	self.mg = self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_drum_of_speedrun_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_drum_of_speedrun_aura_buff:GetModifierConstantManaRegen()
	return self.mg
end

function modifier_drum_of_speedrun_aura_buff:GetModifierMoveSpeedBonus_Constant()
	return self.mv 
end

modifier_rune_haste_birzha = class({})

function modifier_rune_haste_birzha:IsPurgable()
	return true
end

function modifier_rune_haste_birzha:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE }
end

function modifier_rune_haste_birzha:GetModifierMoveSpeed_Absolute()
	return 550
end

function modifier_rune_haste_birzha:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("attack_speed_active")
	end
end

function modifier_rune_haste_birzha:GetTexture()
  	return "items/DrumOfHaste"
end

function modifier_rune_haste_birzha:GetEffectName()
	return "particles/generic_gameplay/rune_haste.vpcf"
end


















