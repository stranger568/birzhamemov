modifier_bp_johncena = class({})

function modifier_bp_johncena:IsHidden()
	return true
end

function modifier_bp_johncena:IsPurgable()
	return false
end

function modifier_bp_johncena:IsPurgeException()
	return false
end

function modifier_bp_johncena:RemoveOnDeath()
	return false
end

function modifier_bp_johncena:AllowIllusionDuplicate()
	return true
end