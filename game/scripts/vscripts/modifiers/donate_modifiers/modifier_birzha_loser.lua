modifier_birzha_loser = class({})

function modifier_birzha_loser:IsPurgable()
	return false
end

function modifier_birzha_loser:IsPurgeException()
	return false
end

function modifier_birzha_loser:RemoveOnDeath()
	return false
end

function modifier_birzha_loser:GetTexture()
	return "ban"
end

function modifier_birzha_loser:IsHidden()
	return false
end

function modifier_birzha_loser:AllowIllusionDuplicate()
	return true
end