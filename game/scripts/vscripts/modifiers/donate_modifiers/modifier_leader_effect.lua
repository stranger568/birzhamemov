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
    if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/birzha_memov_top1_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
end