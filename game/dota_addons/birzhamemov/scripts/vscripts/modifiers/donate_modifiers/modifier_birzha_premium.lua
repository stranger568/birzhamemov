modifier_birzha_premium = class({})

function modifier_birzha_premium:IsHidden()
	return true
end

function modifier_birzha_premium:IsPurgable()
	return false
end

function modifier_birzha_premium:IsPurgeException()
	return false
end

function modifier_birzha_premium:RemoveOnDeath()
	return false
end

function modifier_birzha_premium:AllowIllusionDuplicate()
	return true
end

function modifier_birzha_premium:OnCreated()
	if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/premium/premium_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.particle2 = ParticleManager:CreateParticle("particles/sponsor/sponsor_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.particle3 = ParticleManager:CreateParticle("particles/sponsor/templar_assassin_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle3, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle3, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle3, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_birzha_premium:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_birzha_premium:OnDestroy(params)
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
			ParticleManager:DestroyParticle(self.particle2, true)
			ParticleManager:DestroyParticle(self.particle3, true)
		end
	end
	return 0	
end

function modifier_birzha_premium:GetTexture()
	return "admin"
end