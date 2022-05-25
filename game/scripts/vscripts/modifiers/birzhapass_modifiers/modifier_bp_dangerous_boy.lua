modifier_bp_dangerous_boy = class({})

function modifier_bp_dangerous_boy:IsHidden()
	return true
end

function modifier_bp_dangerous_boy:IsPurgable()
	return false
end

function modifier_bp_dangerous_boy:IsPurgeException()
	return false
end

function modifier_bp_dangerous_boy:RemoveOnDeath()
	return false
end

function modifier_bp_dangerous_boy:AllowIllusionDuplicate()
	return true
end
