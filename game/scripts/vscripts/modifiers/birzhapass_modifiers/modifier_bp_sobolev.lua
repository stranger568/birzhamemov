modifier_bp_sobolev = class({})

function modifier_bp_sobolev:IsHidden()
	return true
end

function modifier_bp_sobolev:IsPurgable()
	return false
end

function modifier_bp_sobolev:IsPurgeException()
	return false
end

function modifier_bp_sobolev:RemoveOnDeath()
	return false
end

function modifier_bp_sobolev:AllowIllusionDuplicate()
	return true
end