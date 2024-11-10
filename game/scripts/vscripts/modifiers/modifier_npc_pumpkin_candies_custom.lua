modifier_npc_pumpkin_candies_custom = class({})
function modifier_npc_pumpkin_candies_custom:IsHidden() return true end
function modifier_npc_pumpkin_candies_custom:IsPurgable() return false end
function modifier_npc_pumpkin_candies_custom:IsPurgeException() return false end
function modifier_npc_pumpkin_candies_custom:CheckState()
    return
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
        [MODIFIER_STATE_BLIND] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_npc_pumpkin_candies_custom:DeclareFunctions() 
    return 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    }
end

function modifier_npc_pumpkin_candies_custom:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_npc_pumpkin_candies_custom:GetAbsoluteNoDamageMagical() return 1 end
function modifier_npc_pumpkin_candies_custom:GetAbsoluteNoDamagePure() return 1 end
function modifier_npc_pumpkin_candies_custom:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end