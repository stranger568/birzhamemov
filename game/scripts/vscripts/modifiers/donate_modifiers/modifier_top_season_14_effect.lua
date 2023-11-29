modifier_top_season_14_effect = class({})
function modifier_top_season_14_effect:IsHidden() return true end
function modifier_top_season_14_effect:IsPurgable() return false end
function modifier_top_season_14_effect:RemoveOnDeath() return false end
function modifier_top_season_14_effect:AllowIllusionDuplicate() return true end
function modifier_top_season_14_effect:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/ti9/ti9_emblem_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end