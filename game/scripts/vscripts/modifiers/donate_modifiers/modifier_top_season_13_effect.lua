modifier_top_season_13_effect = class({})

function modifier_top_season_13_effect:IsHidden() return true end
function modifier_top_season_13_effect:IsPurgable() return false end
function modifier_top_season_13_effect:RemoveOnDeath() return false end
function modifier_top_season_13_effect:AllowIllusionDuplicate() return true end

function modifier_top_season_13_effect:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2022/player/fall_2022_emblem_effect_player_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end