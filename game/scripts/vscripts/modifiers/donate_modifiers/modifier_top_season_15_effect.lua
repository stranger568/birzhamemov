modifier_top_season_15_effect = class({})
function modifier_top_season_15_effect:IsHidden() return true end
function modifier_top_season_15_effect:IsPurgable() return false end
function modifier_top_season_15_effect:RemoveOnDeath() return false end
function modifier_top_season_15_effect:AllowIllusionDuplicate() return true end
function modifier_top_season_15_effect:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/ti10/emblem/ti10_emblem_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end