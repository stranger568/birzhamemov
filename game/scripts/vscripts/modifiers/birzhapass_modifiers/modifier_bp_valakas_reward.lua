modifier_bp_valakas_reward = class({})

function modifier_bp_valakas_reward:IsHidden()
	return true
end

function modifier_bp_valakas_reward:IsPurgable()
	return false
end

function modifier_bp_valakas_reward:IsPurgeException()
	return false
end

function modifier_bp_valakas_reward:RemoveOnDeath()
	return false
end

function modifier_bp_valakas_reward:AllowIllusionDuplicate()
	return true
end