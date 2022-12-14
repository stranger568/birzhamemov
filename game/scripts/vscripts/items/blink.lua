LinkLuaModifier("modifier_item_birzha_blink_boots", "items/blink", LUA_MODIFIER_MOTION_NONE)

item_blink_boots = class({})

function item_blink_boots:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end
    local player = caster:GetPlayerID()
    if DonateShopIsItemBought(player, 47) then
        ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf", PATTACH_ABSORIGIN, caster)
        local particle = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_start.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(100, 100, 0))
        Timers:CreateTimer(1, function()        
            if particle then
                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)    
            end
        end)
    end
    ParticleManager:CreateParticle("particles/blink/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    self:GetCaster():EmitSound("DOTA_Item.BlinkDagger.Activate")
    local origin_point = self:GetCaster():GetAbsOrigin()
    local target_point = self:GetCursorPosition()
    local difference_vector = target_point - origin_point
    if difference_vector:Length2D() > 1200 then
        target_point = origin_point + (target_point - origin_point):Normalized() * 1200
    end
    self:GetCaster():SetAbsOrigin(target_point)
    FindClearSpaceForUnit(self:GetCaster(), target_point, false)
    ProjectileManager:ProjectileDodge(self:GetCaster())
    ParticleManager:CreateParticle("particles/blink/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
end

function item_blink_boots:GetIntrinsicModifierName()
    return "modifier_item_birzha_blink_boots"
end

modifier_item_birzha_blink_boots = class({})

function modifier_item_birzha_blink_boots:IsHidden() return true end
function modifier_item_birzha_blink_boots:IsPurgable() return false end
function modifier_item_birzha_blink_boots:IsPurgeException() return false end
function modifier_item_birzha_blink_boots:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_birzha_blink_boots:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_item_birzha_blink_boots:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end

function modifier_item_birzha_blink_boots:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_int')
    end
end

function modifier_item_birzha_blink_boots:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_regen')
    end
end

function modifier_item_birzha_blink_boots:OnTakeDamage( params )
    if not IsServer() then return end
    if self:GetAbility() then
        if params.unit == self:GetParent() and params.attacker ~= self:GetParent() then
            self:GetAbility():StartCooldown(1)
        end
    end
end
