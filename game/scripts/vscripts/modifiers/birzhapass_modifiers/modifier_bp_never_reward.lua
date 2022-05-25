modifier_bp_never_reward = class({})

function modifier_bp_never_reward:IsHidden()
	return true
end

function modifier_bp_never_reward:IsPurgable()
	return false
end

function modifier_bp_never_reward:IsPurgeException()
	return false
end

function modifier_bp_never_reward:RemoveOnDeath()
	return false
end

function modifier_bp_never_reward:AllowIllusionDuplicate()
	return true
end

function modifier_bp_never_reward:OnCreated()
	if IsServer() then
		self.particle1 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_ambient_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.particle2 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_ambient_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.particle4 = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_bp_never_reward:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_bp_never_reward:OnDeath(params)
	if IsServer() then
		local hAttacker = params.attacker
		local hVictim = params.unit
		if hVictim == self:GetParent() and self:GetParent():IsRealHero() then
			local sEffect = "particles/never_arcana/sf_fire_arcana_death.vpcf"
			local nFXIndex = ParticleManager:CreateParticle(sEffect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
			ParticleManager:ReleaseParticleIndex( nFXIndex )	
		end
	end	
	return 0	
end