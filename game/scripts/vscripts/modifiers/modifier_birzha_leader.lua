modifier_birzha_leader = class({})

function modifier_birzha_leader:IsHidden()
	return true
end

function modifier_birzha_leader:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVISIBLE] = false,

	}
	return state
end

function modifier_birzha_leader:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_birzha_leader:OnIntervalThink()
	if not IsServer() then return end
	for i = 0, 12 do
		AddFOWViewer( i, self:GetParent():GetAbsOrigin(), 200, FrameTime(), false)
	end
end