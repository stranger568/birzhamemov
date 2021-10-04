LinkLuaModifier( "modifier_hookah_aura", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hookah_regen", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hookah_passive", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )

item_hookah = class({})

modifier_hookah_passive = class({})
modifier_hookah_aura = class({})
modifier_hookah_regen = class({})

function item_hookah:OnSpellStart()
	if not IsServer() then return end
	self.hookah = CreateUnitByName("item_hookah", self:GetCaster():GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	self.hookah:AddNewModifier(self.hookah, self, "modifier_hookah_aura", {duration = 5})
	self.hookah:AddNewModifier(self.hookah, self, "modifier_kill", {duration = 5})
	self:GetParent():EmitSound("ui.tournament_open")
end

function modifier_hookah_aura:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_hookah_aura:IsAura()
	return true
end

function modifier_hookah_aura:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
[MODIFIER_STATE_ATTACK_IMMUNE] = true,
[MODIFIER_STATE_NO_HEALTH_BAR] = true,
[MODIFIER_STATE_UNSELECTABLE] = true,
[MODIFIER_STATE_INVULNERABLE] = true,}
    return state
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
	return self.radius
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

function modifier_hookah_regen:OnCreated()
	self.mana_regen = (self:GetAbility():GetSpecialValueFor("mana_regen") + self:GetParent():GetIntellect()) / 10
	self:StartIntervalThink(0.1)
	if not IsServer() then return end
	self:GetParent().particle_drain_fx = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon.vpcf", PATTACH_ABSORIGIN, self:GetAbility().hookah)
	ParticleManager:SetParticleControlEnt(self:GetParent().particle_drain_fx, 0, self:GetAbility().hookah, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbility().hookah:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self:GetParent().particle_drain_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
end

function modifier_hookah_regen:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_WitchDoctor_Ward.Attack")
	self:GetParent():SetMana(self:GetParent():GetMana() + self.mana_regen)
end

function modifier_hookah_regen:OnDestroy()
	if not IsServer() then return end
	if self:GetParent().particle_drain_fx then
		ParticleManager:DestroyParticle(self:GetParent().particle_drain_fx, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().particle_drain_fx)
	end
end

function item_hookah:GetIntrinsicModifierName() 
	return "modifier_hookah_passive"
end

modifier_hookah_passive = class({})

function modifier_hookah_passive:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_hookah_passive:IsPurgable()
    return false
end

function modifier_hookah_passive:OnCreated()
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.mag_damage = self:GetAbility():GetSpecialValueFor("mag_damage")
	self.str = self:GetAbility():GetSpecialValueFor("str")
	self.agi = self:GetAbility():GetSpecialValueFor("agi")
end

function modifier_hookah_passive:DeclareFunctions()
return {
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	MODIFIER_PROPERTY_MANA_BONUS
}
end

function modifier_hookah_passive:IsHidden()
	return true
end

function modifier_hookah_passive:GetModifierBonusStats_Intellect()
return self.bonus_intellect
end

function modifier_hookah_passive:GetModifierManaBonus()
return self.bonus_mana
end

function modifier_hookah_passive:GetModifierSpellAmplify_Percentage()
    return self.mag_damage
end

function modifier_hookah_passive:GetModifierBonusStats_Strength()
    return self.str
end

function modifier_hookah_passive:GetModifierBonusStats_Agility()
    return self.agi
end

function modifier_hookah_passive:GetTexture()
    return "item_hookah"
end