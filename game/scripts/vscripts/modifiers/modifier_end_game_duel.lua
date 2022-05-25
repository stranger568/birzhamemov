modifier_end_game_duel = class({})

function modifier_end_game_duel:IsHidden()
	return true
end

function modifier_end_game_duel:OnCreated(kv)
	if not IsServer() then return end
	self.radius = kv.radius
	self:StartIntervalThink(0.03)
end

function modifier_end_game_duel:OnIntervalThink()
	if not IsServer() then return end
	local entities = FindEntities(self:GetParent(),Vector(0,0,0),FIND_UNITS_EVERYWHERE)
	local buffer = 100
	local duration = self:GetRemainingTime()
	for k,v in pairs(entities) do
		if v:IsAlive() and not v:HasModifier("modifier_birzha_disconnect") and v:IsHero() then
			if ( v:GetRangeToUnit(self:GetParent()) > ( self.radius ) ) then
				local vpos = v:GetAbsOrigin()
				local ppos = self:GetParent():GetAbsOrigin()
				local dir = ( vpos - ppos ):Normalized()
				local rdir = ( ppos - vpos ):Normalized()
				FindClearSpaceForUnit(v,(dir*(self.radius-buffer))+self:GetParent():GetAbsOrigin(),true)
			end
		end
	end
end