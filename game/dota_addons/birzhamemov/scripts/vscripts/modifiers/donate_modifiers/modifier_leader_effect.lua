modifier_leader_effect = class({})

function modifier_leader_effect:IsHidden()
	return true
end

function modifier_leader_effect:IsPurgable()
	return false
end

function modifier_leader_effect:IsPurgeException()
	return false
end

function modifier_leader_effect:RemoveOnDeath()
	return false
end

function modifier_leader_effect:AllowIllusionDuplicate()
	return true
end

function modifier_leader_effect:OnCreated()
	if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/birzha_memov_top1_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_leader_effect:OnDestroy(params)
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
	end
	return 0	
end