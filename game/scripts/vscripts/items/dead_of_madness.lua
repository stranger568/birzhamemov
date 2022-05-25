LinkLuaModifier( "modifier_item_dead_of_madness", "items/dead_of_madness", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_dead_of_madness_aura", "items/dead_of_madness", LUA_MODIFIER_MOTION_NONE )

item_dead_of_madness = class({})

function item_dead_of_madness:GetIntrinsicModifierName() 
	return "modifier_item_dead_of_madness"
end

modifier_item_dead_of_madness = class({})

function modifier_item_dead_of_madness:IsHidden()
	return true
end

function modifier_item_dead_of_madness:IsPurgable()
    return false
end

function modifier_item_dead_of_madness:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
		}
end

function modifier_item_dead_of_madness:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_magical_resistance")
	end
end

function modifier_item_dead_of_madness:GetModifierConstantHealthRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
	end
end

function modifier_item_dead_of_madness:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_armor")
	end
end

function modifier_item_dead_of_madness:IsAura() return true end

function modifier_item_dead_of_madness:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_dead_of_madness:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end

function modifier_item_dead_of_madness:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifier_item_dead_of_madness:GetAuraEntityReject(hTarget)
    if not IsServer() then return end

    if hTarget:GetOwner() == self:GetCaster() then
        return false
    end

    return true
end

function modifier_item_dead_of_madness:GetModifierAura()
    return "modifier_item_dead_of_madness_aura"
end

function modifier_item_dead_of_madness:GetAuraRadius()
    return -1
end

modifier_item_dead_of_madness_aura = class({})

function modifier_item_dead_of_madness_aura:OnCreated()
	if not IsServer() then return end
	self:SetHasCustomTransmitterData(true)
	self.armor =  self:GetAuraOwner():GetLevel() * self:GetAbility():GetSpecialValueFor("armor_per_level")
	self.attackspeed = self:GetAuraOwner():GetLevel() * self:GetAbility():GetSpecialValueFor("attack_speed_per_level")
	self.damage =  self:GetAuraOwner():GetLevel() * self:GetAbility():GetSpecialValueFor("damage_per_level")
	self:StartIntervalThink(1)
end

function modifier_item_dead_of_madness_aura:OnIntervalThink()
	if not IsServer() then return end
	self:OnCreated()
end

function modifier_item_dead_of_madness_aura:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
		}
end

function modifier_item_dead_of_madness_aura:AddCustomTransmitterData() return {
    armor = self.armor,
    attackspeed = self.attackspeed,
    damage = self.damage,

} end

function modifier_item_dead_of_madness_aura:HandleCustomTransmitterData(data)
    self.armor = data.armor
    self.attackspeed = data.attackspeed
    self.damage = data.damage
end

function modifier_item_dead_of_madness_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_dead_of_madness_aura:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_dead_of_madness_aura:GetModifierPreAttack_BonusDamage()
	return self.damage
end
