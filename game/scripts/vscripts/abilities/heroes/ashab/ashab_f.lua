LinkLuaModifier("modifier_ashab_f", "abilities/heroes/ashab/ashab_f", LUA_MODIFIER_MOTION_NONE)

ashab_f = class({})

function ashab_f:GetIntrinsicModifierName()
    return "modifier_ashab_f"
end

modifier_ashab_f = class({})
function modifier_ashab_f:IsHidden() return true end
function modifier_ashab_f:IsPurgable() return false end
function modifier_ashab_f:IsPurgeException() return false end
function modifier_ashab_f:RemoveOnDeath() return false end
function modifier_ashab_f:CheckState()
    return
    {
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
    }
end