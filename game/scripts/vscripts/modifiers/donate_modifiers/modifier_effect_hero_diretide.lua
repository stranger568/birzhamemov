modifier_effect_hero_diretide = class({})

function modifier_effect_hero_diretide:IsHidden() return true end
function modifier_effect_hero_diretide:IsPurgable() return false end
function modifier_effect_hero_diretide:RemoveOnDeath() return false end
function modifier_effect_hero_diretide:AllowIllusionDuplicate() return true end

function modifier_effect_hero_diretide:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/diretide_2020/emblem/fall20_emblem_v1_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)

    local particle_custom = ParticleManager:CreateParticle("particles/birzha_donate/effect_diretidetgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle_custom, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(particle_custom, false, false, -1, false, false)
end