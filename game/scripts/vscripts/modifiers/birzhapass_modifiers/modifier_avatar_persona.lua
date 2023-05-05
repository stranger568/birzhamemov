modifier_avatar_persona = class({})

function modifier_avatar_persona:IsHidden()
	return true
end

function modifier_avatar_persona:IsPurgable()
	return false
end

function modifier_avatar_persona:IsPurgeException()
	return false
end

function modifier_avatar_persona:RemoveOnDeath()
	return false
end

function modifier_avatar_persona:AllowIllusionDuplicate()
	return true
end