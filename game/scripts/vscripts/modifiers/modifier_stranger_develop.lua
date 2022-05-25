
modifier_stranger_develop = class({})

function modifier_stranger_develop:IsHidden()
	return false
end

function modifier_stranger_develop:CheckState()
	return {[MODIFIER_STATE_FEARED] = true, }
end