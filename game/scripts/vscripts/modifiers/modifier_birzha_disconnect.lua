modifier_birzha_disconnect = class({})

function modifier_birzha_disconnect:IsHidden()
	return true
end

function modifier_birzha_disconnect:CheckState()
	local buildings = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		800,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		0,
		false
	)
	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname()=="ent_dota_fountain" then
			fountain = building
			break
		end
	end
	if not fountain then return end

	local state =
	{
		[MODIFIER_PROPERTY_DISABLE_HEALING] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

function modifier_birzha_disconnect:OnCreated()
	if not IsServer() then return end
	local buildings = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		Vector(0,0,0),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		0,
		false
	)

	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname()=="ent_dota_fountain" then
			fountain = building
			break
		end
	end

	if not fountain then return end

	self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

function modifier_birzha_disconnect:GetEffectName()
	return "particles/generic_gameplay/generic_sleep.vpcf"
end

function modifier_birzha_disconnect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

