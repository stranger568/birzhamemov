modifier_bp_mum_mask = class({})

function modifier_bp_mum_mask:IsHidden()
	return true
end

function modifier_bp_mum_mask:IsPurgable()
	return false
end

function modifier_bp_mum_mask:IsPurgeException()
	return false
end

function modifier_bp_mum_mask:RemoveOnDeath()
	return false
end

function modifier_bp_mum_mask:AllowIllusionDuplicate()
	return true
end