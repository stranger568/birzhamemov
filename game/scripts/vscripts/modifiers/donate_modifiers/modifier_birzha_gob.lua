modifier_birzha_gob = class({})

function modifier_birzha_gob:IsHidden()
	return true
end

function modifier_birzha_gob:IsPurgable()
	return false
end

function modifier_birzha_gob:IsPurgeException()
	return false
end

function modifier_birzha_gob:RemoveOnDeath()
	return false
end

function modifier_birzha_gob:AllowIllusionDuplicate()
	return true
end

function modifier_birzha_gob:OnCreated()
	if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/gob/gob_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_birzha_gob:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_birzha_gob:OnDestroy(params)
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
	end
	return 0	
end

function modifier_birzha_gob:GetTexture()
  return "gob"
end