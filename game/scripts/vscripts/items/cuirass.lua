LinkLuaModifier("modifier_item_cuirass_2", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_buff", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_buff_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_debuff", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cuirass_2_aura_debuff_armor", "items/cuirass", LUA_MODIFIER_MOTION_NONE)
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

function modifier_item_cuirass_2:IsHidden() return true end
function modifier_item_cuirass_2:IsPurgable() return false end
function modifier_item_cuirass_2:IsPurgeException() return false end
function modifier_item_cuirass_2:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

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
		MODIFIER_EVENT_ON_ATTACK_LANDED	
	}
end

function modifier_item_cuirass_2:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor_stats')
end

function modifier_item_cuirass_2:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_stats')
end

function modifier_item_cuirass_2:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_damage_stats')
end

function modifier_item_cuirass_2:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_int_stats')
end

function modifier_item_cuirass_2:OnAttackLanded(params)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if params.attacker ~= self:GetParent() and params.target == self:GetParent() then
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
		if self:GetParent():FindAllModifiersByName("modifier_item_cuirass_2")[1] ~= self then return end
		if self:GetParent():HasModifier("modifier_item_birzha_blade_mail") then return end
		if self:GetAbility():GetName() == "item_birzha_blade_mail" then
			if params.attacker:IsMagicImmune() then return end
		end
		local damage_return = self:GetAbility():GetSpecialValueFor("return_damage_passive_percentage") * params.original_damage / 100 + self:GetAbility():GetSpecialValueFor("return_damage_passive")
		ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = damage_return, damage_type = params.damage_type,  damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
	end
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

function modifier_item_cuirass_3:IsHidden() return true end
function modifier_item_cuirass_3:IsPurgable() return false end
function modifier_item_cuirass_3:IsPurgeException() return false end
function modifier_item_cuirass_3:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_cuirass_3:OnCreated()
	if not IsServer() then return end

	if not self:GetCaster():HasModifier("modifier_item_cuirass_3_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_buff", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_debuff", {})
	end
end

function modifier_item_cuirass_3:OnDestroy()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_cuirass_3") then
		self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_buff")
		self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_debuff")
	end
end

function modifier_item_cuirass_3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,	
	}
end

function modifier_item_cuirass_3:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_item_cuirass_3:GetModifierMagicalResistanceBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("magical_resistance")
end

modifier_item_cuirass_3_aura_buff = class({})

function modifier_item_cuirass_3_aura_buff:IsDebuff() return false end
function modifier_item_cuirass_3_aura_buff:AllowIllusionDuplicate() return true end
function modifier_item_cuirass_3_aura_buff:IsHidden() return true end
function modifier_item_cuirass_3_aura_buff:IsPurgable() return false end

function modifier_item_cuirass_3_aura_buff:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
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
	self.magical_resistance_aura = self:GetAbility():GetSpecialValueFor("magical_resistance_aura")
	self.health_regen_aura = self:GetAbility():GetSpecialValueFor("health_regen_aura")
end

function modifier_item_cuirass_3_aura_buff_armor:IsHidden() return false end
function modifier_item_cuirass_3_aura_buff_armor:IsPurgable() return false end
function modifier_item_cuirass_3_aura_buff_armor:IsDebuff() return false end

function modifier_item_cuirass_3_aura_buff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_item_cuirass_3_aura_buff_armor:GetModifierConstantHealthRegen()
	return self.health_regen_aura
end

function modifier_item_cuirass_3_aura_buff_armor:GetModifierMagicalResistanceBonus()
	return self.magical_resistance_aura
end

modifier_item_cuirass_3_aura_debuff = class({})

function modifier_item_cuirass_3_aura_debuff:IsDebuff() return false end
function modifier_item_cuirass_3_aura_debuff:AllowIllusionDuplicate() return true end
function modifier_item_cuirass_3_aura_debuff:IsHidden() return true end
function modifier_item_cuirass_3_aura_debuff:IsPurgable() return false end

function modifier_item_cuirass_3_aura_debuff:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
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
	self.spell_amplify_aura = self:GetAbility():GetSpecialValueFor("enemy_amplify_aura")
end

function modifier_item_cuirass_3_aura_debuff_armor:IsHidden() return false end
function modifier_item_cuirass_3_aura_debuff_armor:IsPurgable() return false end
function modifier_item_cuirass_3_aura_debuff_armor:IsDebuff() return true end

function modifier_item_cuirass_3_aura_debuff_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION
	}
end

function modifier_item_cuirass_3_aura_debuff_armor:GetModifierMagicalResistanceDirectModification()
	return self.spell_amplify_aura
end

modifier_item_magical_cuirass_active = class({})

function modifier_item_magical_cuirass_active:GetEffectName()
	return "particles/cuirass3/item_cuirass3_effect.vpcf"
end

function modifier_item_magical_cuirass_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_magical_cuirass_active:GetTexture()
	return "items/cuiras2"
end

function modifier_item_magical_cuirass_active:OnCreated(keys)
    if not IsServer() then return end
    local magical_resist_active = self:GetAbility():GetSpecialValueFor("magical_resist_active")
    self.remaining_health = magical_resist_active
    self:SetStackCount(self.remaining_health)
end

function modifier_item_magical_cuirass_active:OnRefresh(keys)
    if not IsServer() then return end
    local magical_resist_active = self:GetAbility():GetSpecialValueFor("magical_resist_active")
    self.remaining_health = magical_resist_active
    self:SetStackCount(self.remaining_health)
end

function modifier_item_magical_cuirass_active:OnIntervalThink()
    if not IsServer() then return end
    if self.remaining_health <= 0 then
        self:Destroy()
    end
end

function modifier_item_magical_cuirass_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
    }
    return funcs
end

function modifier_item_magical_cuirass_active:OnTooltip()
	return self:GetStackCount()
end

function modifier_item_magical_cuirass_active:GetModifierTotal_ConstantBlock(kv)
    if not IsServer() then return end
    local original_shield_amount = self.remaining_health
    if kv.damage_type == DAMAGE_TYPE_MAGICAL then
	    if kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
	        if kv.damage < original_shield_amount then
	            SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, kv.damage, nil)
	            self.remaining_health = original_shield_amount - kv.damage
	            self:SetStackCount(self.remaining_health)
	            return kv.damage
	        else
	            SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
	            self:Destroy()
	            return original_shield_amount
	        end
	    end
	end
end

function modifier_item_magical_cuirass_active:GetModifierIncomingSpellDamageConstant()
    if (not IsServer()) then
        return self:GetStackCount()
    end
end

item_ship_magic_armor = class({})

function item_ship_magic_armor:GetIntrinsicModifierName()
    return "modifier_item_ship_magic_armor"
end

modifier_item_ship_magic_armor = class({})

function modifier_item_ship_magic_armor:IsHidden() return true end
function modifier_item_ship_magic_armor:IsPurgable() return false end
function modifier_item_ship_magic_armor:IsPurgeException() return false end
function modifier_item_ship_magic_armor:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_ship_magic_armor:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_cuirass_3_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_buff", {})
	end
	if not self:GetCaster():HasModifier("modifier_item_cuirass_3_aura_debuff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_debuff", {})
	end
	if not self:GetCaster():HasModifier("modifier_item_bristback_ship") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_bristback_ship", {})
	end
	self:StartIntervalThink(FrameTime())
end

function modifier_item_ship_magic_armor:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_cuirass_3_aura_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_buff", {})
	end
	if not self:GetCaster():HasModifier("modifier_item_cuirass_3_aura_debuff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cuirass_3_aura_debuff", {})
	end
	if not self:GetCaster():HasModifier("modifier_item_bristback_ship") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_bristback_ship", {})
	end
end

function modifier_item_ship_magic_armor:OnDestroy()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_ship_magic_armor") then
		self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_buff")
		self:GetCaster():RemoveModifierByName("modifier_item_cuirass_3_aura_debuff")
		self:GetCaster():RemoveModifierByName("modifier_item_bristback_ship")
	end
end

function modifier_item_ship_magic_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,	
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_item_ship_magic_armor:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_item_ship_magic_armor:GetModifierMagicalResistanceBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("magical_resistance")
end

function modifier_item_ship_magic_armor:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function item_ship_magic_armor:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_magical_cuirass_active", {duration = duration} )
    self:GetCaster():EmitSound("DOTA_Item.Pipe.Activate")
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

function modifier_item_birzha_blade_mail:IsHidden() return true end
function modifier_item_birzha_blade_mail:IsPurgable() return false end
function modifier_item_birzha_blade_mail:IsPurgeException() return false end
function modifier_item_birzha_blade_mail:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_birzha_blade_mail:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_birzha_blade_mail:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_item_birzha_blade_mail:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_intellect')
end

function modifier_item_birzha_blade_mail:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_damage')
end

function modifier_item_birzha_blade_mail:OnAttackLanded(params)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if params.attacker ~= self:GetParent() and params.target == self:GetParent() then
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
		if self:GetParent():FindAllModifiersByName("modifier_item_birzha_blade_mail")[1] ~= self then return end
		if self:GetAbility():GetName() == "item_birzha_blade_mail" then
			if params.attacker:IsMagicImmune() then return end
		end
		local damage_return = self:GetAbility():GetSpecialValueFor("return_damage_passive_percentage") * params.original_damage / 100 + self:GetAbility():GetSpecialValueFor("return_damage_passive")
		ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = damage_return, damage_type = params.damage_type,  damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
	end
end

modifier_item_birzha_blade_mail_active = class({})

function modifier_item_birzha_blade_mail_active:GetTexture()
	if self:GetAbility() then
		if self:GetAbility():GetName() == "item_birzha_blade_mail" then
	  		return "item_blade_mail"
	  	else
	  		return "items/cuiras"
	  	end
	end
	return "item_blade_mail"
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
		if self:GetAbility():GetName() == "item_birzha_blade_mail" then
			if keys.attacker:IsMagicImmune() then return end
		end
		EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
		donate_shop:QuestProgress(16, self:GetParent():GetPlayerOwnerID(), math.floor(keys.original_damage / 100 * self:GetAbility():GetSpecialValueFor("return_damage")))
		ApplyDamage({ victim = keys.attacker, damage = keys.original_damage / 100 * self:GetAbility():GetSpecialValueFor("return_damage"), damage_type = keys.damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, attacker = self:GetParent(), ability = self:GetAbility() })
	end
end



