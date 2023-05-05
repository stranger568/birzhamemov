modifier_pyramide_persona = class({})

function modifier_pyramide_persona:IsHidden()
	return true
end

function modifier_pyramide_persona:IsPurgable()
	return false
end

function modifier_pyramide_persona:IsPurgeException()
	return false
end

function modifier_pyramide_persona:RemoveOnDeath()
	return false
end

function modifier_pyramide_persona:AllowIllusionDuplicate()
	return true
end

function modifier_pyramide_persona:OnCreated()
	if not IsServer() then return end
	local particle2 = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( particle2, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	ParticleManager:SetParticleControlEnt( particle2, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	self:AddParticle(particle2, false, false, -1, false, false)
end

function modifier_pyramide_persona:GetEffectName()
	return "particles/pyramide/pyramide_persona_rupture.vpcf"
end

function modifier_pyramide_persona:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end