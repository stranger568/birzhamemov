LinkLuaModifier("modifier_birzha_pet", "modifiers/modifier_birzha_pet.lua", LUA_MODIFIER_MOTION_NONE)
modifier_bp_effects_reward = class({})
function modifier_bp_effects_reward:IsHidden()
	return true
end
function modifier_bp_effects_reward:IsPurgable()
	return false
end
function modifier_bp_effects_reward:IsPurgeException()
	return false
end
function modifier_bp_effects_reward:RemoveOnDeath()
	return false
end
function modifier_bp_effects_reward:DeclareFunctions()
	local funcs = 
    {
	    MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end
function modifier_bp_effects_reward:OnDeath(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if not self:GetParent():IsRealHero() then return end
    if not DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 41) then return end
    local tombstone = CreateUnitByName("npc_dota_tombstone", self:GetParent():GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
    local modifier_birzha_pet = tombstone:AddNewModifier(tombstone, nil, "modifier_birzha_pet", {duration = 11})
    tombstone:AddNewModifier(tombstone, nil, "modifier_kill", {duration = 10})
    local storm = ParticleManager:CreateParticle( "particles/birzhapass/bp_death_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, tombstone )
    ParticleManager:SetParticleControl(storm, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(storm, 1, self:GetParent():GetAbsOrigin())
    if modifier_birzha_pet then
        modifier_birzha_pet:AddParticle(storm, false, false, -1, false, false)
    end
end