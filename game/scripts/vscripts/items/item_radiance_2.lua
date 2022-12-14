LinkLuaModifier( "modifier_radiance_2_stats", "items/item_radiance_2.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_radiance_2_aura", "items/item_radiance_2.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_radiance_2_burn", "items/item_radiance_2.lua", LUA_MODIFIER_MOTION_NONE )

item_radiance_2 = class({})

function item_radiance_2:GetIntrinsicModifierName()
	return "modifier_radiance_2_stats" 
end

function item_radiance_2:OnSpellStart()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_radiance_2_aura") then
		self:GetCaster():RemoveModifierByName("modifier_radiance_2_aura")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_radiance_2_aura", {})
	end
end

function item_radiance_2:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_radiance_2_aura") then
		return "items/radiance_2_on"
	else
		return "items/radiance_2_off"
	end
end

modifier_radiance_2_stats = class({})

function modifier_radiance_2_stats:IsHidden() return true end
function modifier_radiance_2_stats:IsPurgable() return false end
function modifier_radiance_2_stats:IsPurgeException() return false end
function modifier_radiance_2_stats:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_radiance_2_stats:OnCreated(keys)
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_radiance_2_aura") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_radiance_2_aura", {})
	end
end

function modifier_radiance_2_stats:OnDestroy(keys)
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_radiance_2_stats") then
		self:GetParent():RemoveModifierByName("modifier_radiance_2_aura")
	end
end

function modifier_radiance_2_stats:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
end

function modifier_radiance_2_stats:GetModifierPreAttack_BonusDamage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_radiance_2_stats:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_radiance_2_stats:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_radiance_2_stats:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_radiance_2_stats:GetModifierEvasion_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("evasion")
end

modifier_radiance_2_aura = class({})

function modifier_radiance_2_aura:IsAura() return true end
function modifier_radiance_2_aura:IsHidden() return true end
function modifier_radiance_2_aura:IsPurgable() return false end

function modifier_radiance_2_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_radiance_2_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_radiance_2_aura:GetModifierAura()
	return "modifier_radiance_2_burn"
end

function modifier_radiance_2_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_radiance_2_aura:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_owner_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(particle, false, false, -1, false, false)
end

modifier_radiance_2_burn = class({})

function modifier_radiance_2_burn:IsPurgable() return false end

function modifier_radiance_2_burn:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	} 
end

function modifier_radiance_2_burn:GetModifierIncomingDamage_Percentage(keys)
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		return self:GetAbility():GetSpecialValueFor("bonus_damage_magical")
	end
end

function modifier_radiance_2_burn:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/radiance_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(particle, false, false, -1, false, false)
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
end

function modifier_radiance_2_burn:OnIntervalThink()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor("base_damage")
	if self:GetCaster():IsIllusion() then
		damage = self:GetAbility():GetSpecialValueFor("base_damage_illsuion")
	end
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end