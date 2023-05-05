modifier_papich_hand_effect = class({})

function modifier_papich_hand_effect:IsHidden()
	return true
end

function modifier_papich_hand_effect:IsPurgable()
	return false
end

function modifier_papich_hand_effect:IsPurgeException()
	return false
end

function modifier_papich_hand_effect:RemoveOnDeath()
	return false
end

function modifier_papich_hand_effect:AllowIllusionDuplicate()
	return true
end