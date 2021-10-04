LinkLuaModifier( "modifier_radiance_2_stats", "items/item_radiance_2.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_radiance_2_aura", "items/item_radiance_2.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_radiance_2_burn", "items/item_radiance_2.lua", LUA_MODIFIER_MOTION_NONE )

item_radiance_2 = class({})

function item_radiance_2:GetIntrinsicModifierName()
	return "modifier_radiance_2_stats" end

function item_radiance_2:OnSpellStart()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_radiance_2_aura") then
			self:GetCaster():RemoveModifierByName("modifier_radiance_2_aura")
		else
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_radiance_2_aura", {})
		end
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
function modifier_radiance_2_stats:IsDebuff() return false end
function modifier_radiance_2_stats:IsPurgable() return false end
function modifier_radiance_2_stats:IsPermanent() return true end
function modifier_radiance_2_stats:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_radiance_2_stats:OnCreated(keys)
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_radiance_2_aura") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_radiance_2_aura", {})
		end
	end

	self:StartIntervalThink(1)
end

function modifier_radiance_2_stats:OnIntervalThink()

	if IsServer() then
		if self:GetParent():GetOwnerEntity().radiance_icon then
			self:SetStackCount(self:GetParent():GetOwnerEntity().radiance_icon)
		elseif self:GetCaster().radiance_icon then
			self:SetStackCount(self:GetCaster().radiance_icon)
		end
	end

	if IsClient() then
		local icon = self:GetStackCount()
		if icon == 0 then
			self:GetCaster().radiance_icon_client = nil
		else
			self:GetCaster().radiance_icon_client = icon
		end
	end
end

function modifier_radiance_2_stats:OnDestroy(keys)
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_radiance_2_stats") then
			self:GetParent():RemoveModifierByName("modifier_radiance_2_aura")
		end
	end
end

function modifier_radiance_2_stats:DeclareFunctions()
	return { 
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
				MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
				MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			 }
end

function modifier_radiance_2_stats:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_radiance_2_stats:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_radiance_2_stats:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_radiance_2_stats:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_radiance_2_stats:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

if modifier_radiance_2_aura == nil then modifier_radiance_2_aura = class({}) end
function modifier_radiance_2_aura:IsAura() return true end
function modifier_radiance_2_aura:IsHidden() return true end
function modifier_radiance_2_aura:IsDebuff() return false end
function modifier_radiance_2_aura:IsPurgable() return false end

function modifier_radiance_2_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY end

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
	if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_owner_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_radiance_2_aura:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end

if modifier_radiance_2_burn == nil then modifier_radiance_2_burn = class({}) end
function modifier_radiance_2_burn:IsHidden() return false end
function modifier_radiance_2_burn:IsDebuff() return true end
function modifier_radiance_2_burn:IsPurgable() return false end

function modifier_radiance_2_burn:DeclareFunctions()
	return { MODIFIER_PROPERTY_MISS_PERCENTAGE,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, } end

function modifier_radiance_2_burn:OnCreated()
	if IsServer() then
		if not self:GetCaster():HasItemInInventory("item_radiance") then 
			self.particle = ParticleManager:CreateParticle("particles/radiance_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		end
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))

		local ability = self:GetAbility()
		self.base_damage = ability:GetSpecialValueFor("base_damage")
		self.aura_radius = ability:GetSpecialValueFor("aura_radius")
		self.miss_chance = ability:GetSpecialValueFor("miss_chance")
	end
	self.magical_armor = self:GetAbility():GetSpecialValueFor("magic_armor")
end

function modifier_radiance_2_burn:OnDestroy()
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, false)
			ParticleManager:ReleaseParticleIndex(self.particle)
		end
	end
end

function modifier_radiance_2_burn:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local damage = self.base_damage
		if self:GetCaster():HasItemInInventory("item_radiance") then return end
		ApplyDamage({victim = self:GetParent(), attacker = caster, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

function modifier_radiance_2_burn:GetModifierMiss_Percentage()
	return self.miss_chance
end

function modifier_radiance_2_burn:GetModifierMagicalResistanceBonus()
	return self.magical_armor
 end
