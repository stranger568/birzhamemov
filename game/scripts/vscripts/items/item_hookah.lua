LinkLuaModifier( "modifier_hookah_aura", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hookah_regen", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hookah_passive", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )

item_hookah = class({})

function item_hookah:OnSpellStart()
	if not IsServer() then return end
	local hookah = CreateUnitByName("item_hookah", self:GetCaster():GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	hookah:AddNewModifier(hookah, self, "modifier_hookah_aura", {duration = 5})
	hookah:AddNewModifier(hookah, self, "modifier_kill", {duration = 5})
	hookah:SetDayTimeVisionRange(0)
	hookah:SetNightTimeVisionRange(0)
	self:GetParent():EmitSound("ui.tournament_open")
end

function item_hookah:GetIntrinsicModifierName() 
	return "modifier_hookah_passive"
end

modifier_hookah_passive = class({})

function modifier_hookah_passive:IsHidden() return true end
function modifier_hookah_passive:IsPurgable() return false end
function modifier_hookah_passive:IsPurgeException() return false end
function modifier_hookah_passive:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_hookah_passive:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE,
	}
end

function modifier_hookah_passive:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_hookah_passive:GetModifierManaBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_hookah_passive:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("str")
end

function modifier_hookah_passive:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("agi")
end

function modifier_hookah_passive:GetModifierExtraManaPercentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana_percentage")
end

function modifier_hookah_passive:GetModifierConstantManaRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen_passive")
end

modifier_hookah_aura = class({})

function modifier_hookah_aura:IsAura()
	return true
end

function modifier_hookah_aura:CheckState()
    return 
    { 
    	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

function modifier_hookah_aura:GetAuraEntityReject(target)
	if IsServer() then
		if target == self:GetCaster() then
			return true
		else
			return false
		end

		if target:HasModifier("modifier_hookah_regen") then
			return true
		else
			return false
		end
	end
end

function modifier_hookah_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_hookah_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_hookah_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_hookah_aura:IsHidden()
	return true
end

function modifier_hookah_aura:GetModifierAura()
	return "modifier_hookah_regen"
end

modifier_hookah_regen = class({})

function modifier_hookah_regen:OnCreated()
	local intellect_reg = self:GetAbility():GetSpecialValueFor("intellect_reg") / 100
	self.mana_regen = (self:GetAbility():GetSpecialValueFor("mana_regen") + (self:GetParent():GetIntellect(false) * intellect_reg)) * 0.1
	
	if not IsServer() then return end

	local particle_drain_fx = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControlEnt(particle_drain_fx, 0, self:GetAuraOwner(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAuraOwner():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_drain_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle_drain_fx, false, false, -1, false, false)

	self:StartIntervalThink(0.1)
end

function modifier_hookah_regen:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_WitchDoctor_Ward.Attack")
	self:GetParent():GiveMana(self.mana_regen)
end

function modifier_hookah_regen:GetTexture()
    return "item_hookah"
end