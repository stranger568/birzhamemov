modifier_bp_mum_arcana = class({})

function modifier_bp_mum_arcana:IsHidden()
	return true
end

function modifier_bp_mum_arcana:IsPurgable()
	return false
end

function modifier_bp_mum_arcana:IsPurgeException()
	return false
end

function modifier_bp_mum_arcana:RemoveOnDeath()
	return false
end

function modifier_bp_mum_arcana:AllowIllusionDuplicate()
	return true
end