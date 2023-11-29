modifier_birzha_vip = class({})

function modifier_birzha_vip:IsHidden()
	return true
end

function modifier_birzha_vip:IsPurgable()
	return false
end

function modifier_birzha_vip:IsPurgeException()
	return false
end

function modifier_birzha_vip:RemoveOnDeath()
	return false
end

function modifier_birzha_vip:AllowIllusionDuplicate()
	return true
end

function modifier_birzha_vip:OnCreated()
	if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/vip/vip_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.particle2 = ParticleManager:CreateParticle("particles/vip_gold.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	end
end


function modifier_birzha_vip:OnDestroy(params)
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
			ParticleManager:DestroyParticle(self.particle2, true)
		end
	end
	return 0	
end

function modifier_birzha_vip:GetTexture()
  return "vip"
end