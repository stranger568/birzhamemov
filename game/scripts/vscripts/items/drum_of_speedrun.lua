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

function modifier_drum_of_speedrun:IsHidden() return true end
function modifier_drum_of_speedrun:IsPurgable() return false end
function modifier_drum_of_speedrun:IsPurgeException() return false end
function modifier_drum_of_speedrun:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_drum_of_speedrun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, 
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, 
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, 
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_drum_of_speedrun:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_drum_of_speedrun:GetModifierPreAttack_BonusDamage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_drum_of_speedrun:GetModifierConstantHealthRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_drum_of_speedrun:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_drum_of_speedrun:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_drum_of_speedrun:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_drum_of_speedrun:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_drum_of_speedrun:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_drum_of_speedrun:IsHidden()
	return true
end

function modifier_drum_of_speedrun:GetModifierAura()
	return "modifier_drum_of_speedrun_aura_buff"
end

modifier_drum_of_speedrun_aura_buff = class({})

function modifier_drum_of_speedrun_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_drum_of_speedrun_aura_buff:GetModifierMoveSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

modifier_rune_haste_birzha = class({})

function modifier_rune_haste_birzha:IsPurgable()
	return true
end

function modifier_rune_haste_birzha:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_rune_haste_birzha:GetModifierMoveSpeedBonus_Constant()
	if self:GetParent():HasModifier("modifier_klichko_charge_of_darkness") then return end
	return 99999999
end

function modifier_rune_haste_birzha:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("attack_speed_active")
end

function modifier_rune_haste_birzha:GetTexture()
  	return "items/DrumOfHaste"
end

function modifier_rune_haste_birzha:GetEffectName()
	return "particles/generic_gameplay/rune_haste.vpcf"
end


















