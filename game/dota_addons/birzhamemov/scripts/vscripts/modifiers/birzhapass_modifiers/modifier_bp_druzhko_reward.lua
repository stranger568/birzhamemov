modifier_bp_druzhko_reward = class({})

function modifier_bp_druzhko_reward:IsHidden()
	return true
end

function modifier_bp_druzhko_reward:IsPurgable()
	return false
end

function modifier_bp_druzhko_reward:IsPurgeException()
	return false
end

function modifier_bp_druzhko_reward:RemoveOnDeath()
	return false
end

function modifier_bp_druzhko_reward:AllowIllusionDuplicate()
	return true
end

function modifier_bp_druzhko_reward:OnCreated()
	if IsServer() then
		self.orb_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker_kid/invoker_kid_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.orb_1, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb1", self:GetParent():GetAbsOrigin(), false)
        self.orb_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker_kid/invoker_kid_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.orb_2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb2", self:GetParent():GetAbsOrigin(), false)
        self.orb_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker_kid/invoker_kid_wex_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.orb_3, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb3", self:GetParent():GetAbsOrigin(), false)
	end
end

function modifier_bp_druzhko_reward:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_bp_druzhko_reward:OnDestroy(params)
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
	end
	return 0	
end

--------------------------------------------------------------------------------