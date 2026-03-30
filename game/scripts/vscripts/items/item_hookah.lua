LinkLuaModifier( "modifier_hookah_aura", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hookah_regen", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hookah_passive", "items/item_hookah", LUA_MODIFIER_MOTION_NONE )

item_hookah = class({})

function item_hookah:OnSpellStart()
	if not IsServer() then return end
	local hookah = CreateUnitByName("item_hookah", self:GetCaster():GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	hookah:AddNewModifier(hookah, self, "modifier_hookah_aura", {duration = self:GetSpecialValueFor("duration")})
	hookah:AddNewModifier(hookah, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	hookah:SetDayTimeVisionRange(300)
	hookah:SetNightTimeVisionRange(300)
	self:GetCaster():EmitSound("ui.tournament_open")
end

function item_hookah:GetIntrinsicModifierName() 
	return "modifier_hookah_passive"
end

modifier_hookah_passive = class({})

function modifier_hookah_passive:IsHidden() return true end
function modifier_hookah_passive:IsPurgable() return false end
function modifier_hookah_passive:IsPurgeException() return false end
function modifier_hookah_passive:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_hookah_passive:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() or self:GetAbility():IsNull() then return end
	self.mod = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_chasm_stone", {})
end

function modifier_hookah_passive:OnDestroy()
	if not IsServer() then return end
	if not self.mod or self.mod:IsNull() then return end
	self.mod:Destroy()
end

function modifier_hookah_passive:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE,
		MODIFIER_PROPERTY_AOE_BONUS_CONSTANT_STACKING ,
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

function modifier_hookah_passive:GetModifierAoEBonusConstantStacking()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('aoe')
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
	return DOTA_UNIT_TARGET_TEAM_BOTH  
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

	local particle_drain_fx = "particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon.vpcf"
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		particle_drain_fx = "particles/hookah/hookah_enemy.vpcf"
	end
	local particle = ParticleManager:CreateParticle(particle_drain_fx, PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetAuraOwner(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAuraOwner():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)

	self:StartIntervalThink(0.1)
end

function modifier_hookah_regen:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_WitchDoctor_Ward.Attack")
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		self:GetParent():SpendMana(self.mana_regen, self:GetAbility())
	else
		self:GetParent():GiveMana(self.mana_regen)
	end
end

function modifier_hookah_regen:GetTexture()
    return "item_hookah"
end