modifier_bp_ayano = class({})

function modifier_bp_ayano:IsHidden()
	return true
end

function modifier_bp_ayano:IsPurgable()
	return false
end

function modifier_bp_ayano:IsPurgeException()
	return false
end

function modifier_bp_ayano:RemoveOnDeath()
	return false
end

function modifier_bp_ayano:AllowIllusionDuplicate()
	return true
end