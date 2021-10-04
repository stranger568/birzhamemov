LinkLuaModifier("modifier_item_cuirass_2", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_buff", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_buff_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_debuff", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_debuff_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ship_magic_armor_slow", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ship_magic_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bristback_ship", "items/boss_items", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_blade_mail", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_blade_mail_active", "items/cuirass", LUA_MODIFIER_MOTION_NONE)

item_cuirass_2 = class({})

function item_cuirass_2:GetIntrinsicModifierName()
    return "modifier_item_cuirass_2"
end

function item_cuirass_2:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_birzha_blade_mail_active", {duration = duration} )
    self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_blade_mail")
    end
end

modifier_item_cuirass_2 = class({})

function modifier_item_cuirass_2:IsHidden()
    return true
end

function modifier_item_cuirass_2:IsPurgable()
    return false
end

function modifier_item_cuirass_2:OnCreated()
	if not IsServer() then return end

	if not self:GetCaster():HasModifier("modifier_item_cuirass_2_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_2_aura_buff", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_2_aura_debuff", {})
	end
end

function modifier_item_cuirass_2:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_item_cuirass_2") then
			self:GetCaster():RemoveModifierByName("modifier_item_cuirass_2_aura_buff")
			self:GetCaster():RemoveModifierByName("modifier_item_cuirass_2_aura_debuff")
		end
	end
end

function modifier_item_cuirass_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,	
	}
end

function modifier_item_cuirass_2:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_armor_stats')
end

function modifier_item_cuirass_2:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_stats')
end

function modifier_item_cuirass_2:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('bonus_damage_stats')
end

function modifier_item_cuirass_2:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('bonus_int_stats')
end

modifier_item_cuirass_2_aura_buff = class({})

function modifier_item_cuirass_2_aura_buff:IsDebuff() return false end
function modifier_item_cuirass_2_aura_buff:AllowIllusionDuplicate() return true end
function modifier_item_cuirass_2_aura_buff:IsHidden() return true end
function modifier_item_cuirass_2_aura_buff:IsPurgable() return false end

function modifier_item_cuirass_2_aura_buff:GetAuraRadius()
	return 1200
end

function modifier_item_cuirass_2_aura_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_cuirass_2_aura_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_cuirass_2_aura_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_cuirass_2_aura_buff:GetModifierAura()
	return "modifier_item_cuirass_2_aura_buff_armor"
end

function modifier_item_cuirass_2_aura_buff:IsAura()
	return true
end

modifier_item_cuirass_2_aura_buff_armor = class({})

function modifier_item_cuirass_2_aura_buff_armor:GetTexture()
  	return "items/cuiras"
end

function modifier_item_cuirass_2_aura_buff_armor:OnCreated()
	self.aura_as_ally = self:GetAbility():GetSpecialValueFor("bonus_attack_speed_aura")
	self.aura_armor_ally = self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
end

function modifier_item_cuirass_2_aura_buff_armor:IsHidden() return false end
function modifier_item_cuirass_2_aura_buff_armor:IsPurgable() return false end
function modifier_item_cuirass_2_aura_buff_armor:IsDebuff() return false end

function modifier_item_cuirass_2_aura_buff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_cuirass_2_aura_buff_armor:GetModifierAttackSpeedBonus_Constant()
	return self.aura_as_ally
end

function modifier_item_cuirass_2_aura_buff_armor:GetModifierPhysicalArmorBonus()
	return self.aura_armor_ally
end

function modifier_item_cuirass_2_aura_buff_armor:GetEffectName()
	return "particles/items_fx/aura_assault.vpcf"
end

function modifier_item_cuirass_2_aura_buff_armor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_item_cuirass_2_aura_debuff = class({})

function modifier_item_cuirass_2_aura_debuff:IsDebuff() return false end
function modifier_item_cuirass_2_aura_debuff:AllowIllusionDuplicate() return true end
function modifier_item_cuirass_2_aura_debuff:IsHidden() return true end
function modifier_item_cuirass_2_aura_debuff:IsPurgable() return false end

function modifier_item_cuirass_2_aura_debuff:GetAuraRadius()
	return 1200
end

function modifier_item_cuirass_2_aura_debuff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_cuirass_2_aura_debuff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_cuirass_2_aura_debuff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_cuirass_2_aura_debuff:GetModifierAura()
	return "modifier_item_cuirass_2_aura_debuff_armor"
end

function modifier_item_cuirass_2_aura_debuff:IsAura()
	return true
end

modifier_item_cuirass_2_aura_debuff_armor = class({})

function modifier_item_cuirass_2_aura_debuff_armor:GetTexture()
  	return "items/cuiras"
end

function modifier_item_cuirass_2_aura_debuff_armor:OnCreated()
	self.aura_armor_enemy = self:GetAbility():GetSpecialValueFor("minus_armor_aura")
end

function modifier_item_cuirass_2_aura_debuff_armor:IsHidden() return false end
function modifier_item_cuirass_2_aura_debuff_armor:IsPurgable() return false end
function modifier_item_cuirass_2_aura_debuff_armor:IsDebuff() return true end

function modifier_item_cuirass_2_aura_debuff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_cuirass_2_aura_debuff_armor:GetModifierPhysicalArmorBonus()
	return self.aura_armor_enemy
end

LinkLuaModifier("modifier_item_cuirass_3", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_3_aura_buff", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_3_aura_buff_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_3_aura_debuff", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_3_aura_debuff_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_magical_cuirass_active", "items/cuirass", LUA_MODIFIER_MOTION_NONE)


item_cuirass_3 = class({})

function item_cuirass_3:GetIntrinsicModifierName()
    return "modifier_item_cuirass_3"
end

function item_cuirass_3:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_magical_cuirass_active", {duration = duration} )
    self:GetCaster():EmitSound("DOTA_Item.Pipe.Activate")
end

modifier_item_cuirass_3 = class({})

function modifier_item_cuirass_3:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_cuirass_3:IsHidden()
    return true
end

function modifier_item_cuirass_3:IsPurgable()
    return false
end

function modifier_item_cuirass_3:OnCreated()
	if not IsServer() then return end

	if not self:GetCaster():HasModifier("modifier_item_cuirass_3_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_buff", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_debuff", {})
	end
end

function modifier_item_cuirass_3:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_item_cuirass_3") then
			self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_buff")
			self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_debuff")
		end
	end
end

function modifier_item_cuirass_3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,	
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_cuirass_3:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_item_cuirass_3:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_item_cuirass_3:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor('hpregen')
end

function modifier_item_cuirass_3:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('magical_resist_passive')
end

function modifier_item_cuirass_3:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_cuirass_3:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_cuirass_3:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('atribute')
end

modifier_item_cuirass_3_aura_buff = class({})

function modifier_item_cuirass_3_aura_buff:IsDebuff() return false end
function modifier_item_cuirass_3_aura_buff:AllowIllusionDuplicate() return true end
function modifier_item_cuirass_3_aura_buff:IsHidden() return true end
function modifier_item_cuirass_3_aura_buff:IsPurgable() return false end

function modifier_item_cuirass_3_aura_buff:GetAuraRadius()
	return 1200
end

function modifier_item_cuirass_3_aura_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_cuirass_3_aura_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_cuirass_3_aura_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_cuirass_3_aura_buff:GetModifierAura()
	return "modifier_item_cuirass_3_aura_buff_armor"
end

function modifier_item_cuirass_3_aura_buff:IsAura()
	return true
end

modifier_item_cuirass_3_aura_buff_armor = class({})

function modifier_item_cuirass_3_aura_buff_armor:GetTexture()
  	return "items/cuiras2"
end

function modifier_item_cuirass_3_aura_buff_armor:OnCreated()
	self.aura_as_ally = self:GetAbility():GetSpecialValueFor("attack_speed_aura")
	self.aura_armor_ally = self:GetAbility():GetSpecialValueFor("magical_resist_aura")
end

function modifier_item_cuirass_3_aura_buff_armor:IsHidden() return false end
function modifier_item_cuirass_3_aura_buff_armor:IsPurgable() return false end
function modifier_item_cuirass_3_aura_buff_armor:IsDebuff() return false end

function modifier_item_cuirass_3_aura_buff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_item_cuirass_3_aura_buff_armor:GetModifierAttackSpeedBonus_Constant()
	return self.aura_as_ally
end

function modifier_item_cuirass_3_aura_buff_armor:GetModifierMagicalResistanceBonus()
	return self.aura_armor_ally
end

modifier_item_cuirass_3_aura_debuff = class({})

function modifier_item_cuirass_3_aura_debuff:IsDebuff() return false end
function modifier_item_cuirass_3_aura_debuff:AllowIllusionDuplicate() return true end
function modifier_item_cuirass_3_aura_debuff:IsHidden() return true end
function modifier_item_cuirass_3_aura_debuff:IsPurgable() return false end

function modifier_item_cuirass_3_aura_debuff:GetAuraRadius()
	return 1200
end

function modifier_item_cuirass_3_aura_debuff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_cuirass_3_aura_debuff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_cuirass_3_aura_debuff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_item_cuirass_3_aura_debuff:GetModifierAura()
	return "modifier_item_cuirass_3_aura_debuff_armor"
end

function modifier_item_cuirass_3_aura_debuff:IsAura()
	return true
end

modifier_item_cuirass_3_aura_debuff_armor = class({})

function modifier_item_cuirass_3_aura_debuff_armor:GetTexture()
  	return "items/cuiras2"
end

function modifier_item_cuirass_3_aura_debuff_armor:OnCreated()
	self.aura_armor_enemy = self:GetAbility():GetSpecialValueFor("magical_resist_aura_debuff")
end

function modifier_item_cuirass_3_aura_debuff_armor:IsHidden() return false end
function modifier_item_cuirass_3_aura_debuff_armor:IsPurgable() return false end
function modifier_item_cuirass_3_aura_debuff_armor:IsDebuff() return true end

function modifier_item_cuirass_3_aura_debuff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_item_cuirass_3_aura_debuff_armor:GetModifierMagicalResistanceBonus()
	return self.aura_armor_enemy
end

modifier_item_magical_cuirass_active = class({})

function modifier_item_magical_cuirass_active:GetEffectName()
	return "particles/cuirass3/item_cuirass3_effect.vpcf"
end

function modifier_item_magical_cuirass_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_magical_cuirass_active:OnCreated()
	self.magical_resist_active = self:GetAbility():GetSpecialValueFor("magical_resist_active")
end

function modifier_item_magical_cuirass_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_item_magical_cuirass_active:GetModifierMagicalResistanceBonus()
	return self.magical_resist_active
end

item_ship_magic_armor = class({})

function item_ship_magic_armor:GetIntrinsicModifierName()
    return "modifier_item_ship_magic_armor"
end

modifier_item_ship_magic_armor = class({})

function modifier_item_ship_magic_armor:IsHidden()
    return true
end

function modifier_item_ship_magic_armor:IsPurgable()
    return false
end

function modifier_item_ship_magic_armor:OnCreated()
	if not IsServer() then return end

	if not self:GetCaster():HasModifier("modifier_item_cuirass_2_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_buff", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_debuff", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_bristback_ship", {})
	end
end

function modifier_item_ship_magic_armor:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_item_ship_magic_armor") then
			self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_buff")
			self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_debuff")
			self:GetCaster():RemoveModifierByName("modifier_item_bristback_ship")
		end
	end
end

function modifier_item_ship_magic_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,	
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_ship_magic_armor:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_item_ship_magic_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_item_ship_magic_armor:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor('hpregen')
end

function modifier_item_ship_magic_armor:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('magical_resist_passive')
end

function modifier_item_ship_magic_armor:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_ship_magic_armor:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_ship_magic_armor:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function item_ship_magic_armor:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_magical_cuirass_active", {duration = duration} )
    self:GetCaster():EmitSound("DOTA_Item.Pipe.Activate")
    local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER, false)
	self:GetCaster():EmitSound("Hero_Bristleback.ViscousGoo.Cast")
	
	for _,hero in pairs(heroes) do
		local goo = {
			Target = hero,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_proj.vpcf",
			iMoveSpeed = 1500,
			bDodgeable = false, 
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			bProvidesVision = false,
			iVisionTeamNumber = self:GetCaster():GetTeamNumber()
		}
		ProjectileManager:CreateTrackingProjectile(goo) 
	end 
end

function item_ship_magic_armor:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
		target:EmitSound("Hero_Bristleback.ViscousGoo.Target")
		target:AddNewModifier(self:GetCaster(), self, "modifier_item_ship_magic_armor_slow", {duration = 3})
    end
    return true
end

modifier_item_ship_magic_armor_slow = class({})

function modifier_item_ship_magic_armor_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_item_ship_magic_armor_slow:GetModifierMoveSpeedBonus_Percentage()
	return -100
end

item_birzha_blade_mail = class({})

function item_birzha_blade_mail:GetIntrinsicModifierName()
    return "modifier_item_birzha_blade_mail"
end

function item_birzha_blade_mail:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_birzha_blade_mail_active", {duration = duration} )
    self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
	if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_blade_mail")
    end
end

modifier_item_birzha_blade_mail = class({})

function modifier_item_birzha_blade_mail:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_birzha_blade_mail:IsHidden()
    return true
end

function modifier_item_birzha_blade_mail:IsPurgable()
    return false
end

function modifier_item_birzha_blade_mail:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,	
	}
end

function modifier_item_birzha_blade_mail:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_item_birzha_blade_mail:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('bonus_intellect')
end

function modifier_item_birzha_blade_mail:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('bonus_damage')
end

modifier_item_birzha_blade_mail_active = class({})

function modifier_item_birzha_blade_mail_active:GetTexture()
	if self:GetAbility():GetName() == "item_birzha_blade_mail" then
  		return "item_blade_mail"
  	else
  		return "items/cuiras"
  	end
end

function modifier_item_birzha_blade_mail_active:IsPurgable()
	return false
end

function modifier_item_birzha_blade_mail_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_item_birzha_blade_mail_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_item_birzha_blade_mail_active:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_item_birzha_blade_mail_active:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():EmitSound("DOTA_Item.BladeMail.Deactivate")
end

function modifier_item_birzha_blade_mail_active:OnTakeDamage(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags
	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if not keys.unit:IsOther() then
			EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
			local damageTable = {
				victim			= keys.attacker,
				damage			= keys.original_damage,
				damage_type		= keys.damage_type,
				damage_flags 	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
			}
			ApplyDamage(damageTable)
		end
	end
end



