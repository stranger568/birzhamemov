modifier_bp_dio = class({})

function modifier_bp_dio:IsHidden()
	return true
end

function modifier_bp_dio:IsPurgable()
	return false
end

function modifier_bp_dio:IsPurgeException()
	return false
end

function modifier_bp_dio:RemoveOnDeath()
	return false
end

function modifier_bp_dio:AllowIllusionDuplicate()
	return true
end

function modifier_bp_dio:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	ParticleManager:SetParticleControl(particle, 60, Vector(139,0,139))
	ParticleManager:SetParticleControl(particle, 61, Vector(1,1,1))
	self:AddParticle(particle, false, false, -1, false, false)

	local particle2 = ParticleManager:CreateParticle( "particles/dio_arcana/dio_ambient_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( particle2, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	self:AddParticle(particle2, false, false, -1, false, false)
end