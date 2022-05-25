LinkLuaModifier("modifier_lava_damage","lava.lua", LUA_MODIFIER_MOTION_NONE)

function StartTouchDamage( trigger )
    local ent = trigger.activator

    ent:AddNewModifier(ent, self, "modifier_lava_damage", {})
end

function EndTouch( trigger )
    local ent = trigger.activator
    ent:RemoveModifierByName("modifier_lava_damage")
end

-----------------------------------------------------------------------------------------

modifier_lava_damage = modifier_lava_damage or class({})

function modifier_lava_damage:IsHidden()
    return true
end

function modifier_lava_damage:IsPassive()
    return false
end

function modifier_lava_damage:IsPurgable()
    return false
end

function modifier_lava_damage:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 0.3 )
end

function modifier_lava_damage:OnIntervalThink()
    if IsServer() then
        local buildings = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            Vector(0,0,0),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BUILDING,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            0,
            false
        )
        local fountain = nil
        for _,building in pairs(buildings) do
            if building:GetClassname()=="ent_dota_fountain" then
                fountain = building
                break
            end
        end
        if not fountain then return end
        FindClearSpaceForUnit( self:GetParent(), fountain:GetAbsOrigin(), true )
    end
end