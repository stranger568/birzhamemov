modifier_birzha_pet = class({})

function modifier_birzha_pet:IsHidden()
	return true
end

function modifier_birzha_pet:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end


modifier_birzha_donater = class({})

function modifier_birzha_donater:IsHidden()
	return true
end

function modifier_birzha_donater:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,
[MODIFIER_STATE_DISARMED] = true,}
end

modifier_birzha_collision = class({})

function modifier_birzha_collision:IsHidden()
	return false
end

function modifier_birzha_collision:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end