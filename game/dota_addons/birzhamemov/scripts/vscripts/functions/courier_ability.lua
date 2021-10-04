LinkLuaModifier( "modifier_movespeed_courier", "functions/courier_ability.lua", LUA_MODIFIER_MOTION_NONE )

courier_ability = class({})

function courier_ability:GetIntrinsicModifierName()
    return "modifier_movespeed_courier"
end

modifier_movespeed_courier = class({})

function modifier_movespeed_courier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_movespeed_courier:GetModifierMoveSpeed_Max( params )
    return 1100
end

function modifier_movespeed_courier:GetModifierMoveSpeed_Limit( params )
    return 1100
end

function modifier_movespeed_courier:GetModifierIgnoreMovespeedLimit( params )
    return 1
end

function modifier_movespeed_courier:IsHidden()
    return true
end

function modifier_movespeed_courier:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_movespeed_courier:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():SetDayTimeVisionRange(0)
    self:GetParent():SetNightTimeVisionRange(0)
end


function modifier_movespeed_courier:GetModifierMoveSpeedBonus_Percentage()
	return 9999999999
end

function modifier_movespeed_courier:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
         [MODIFIER_STATE_NO_HEALTH_BAR] = true,
         [MODIFIER_STATE_MUTED] = true,
    }
    return state
end