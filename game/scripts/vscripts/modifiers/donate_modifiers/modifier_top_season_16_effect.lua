modifier_top_season_16_effect = class({})
function modifier_top_season_16_effect:IsHidden() return true end
function modifier_top_season_16_effect:IsPurgable() return false end
function modifier_top_season_16_effect:RemoveOnDeath() return false end
function modifier_top_season_16_effect:AllowIllusionDuplicate() return true end
function modifier_top_season_16_effect:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/fall_2021_emblem_game_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end