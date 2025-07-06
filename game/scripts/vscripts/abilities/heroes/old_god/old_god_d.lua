LinkLuaModifier("modifier_old_god_d", "abilities/heroes/old_god/old_god_d", LUA_MODIFIER_MOTION_NONE)

old_god_d = class({})

function old_god_d:Precache(context)
    PrecacheResource("particle", "particles/stariy_boh/wisp_taunt.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", context)
    PrecacheResource("particle", "particles/old_god/wisp_ambient.vpcf", context)
    PrecacheResource("model", "models/old_god/old_god.vmdl", context)
end

function old_god_d:OnSpellStart()
    if not IsServer() then return end
    local modifier_old_god_d = self:GetCaster():FindModifierByName("modifier_old_god_d")
    if modifier_old_god_d then
        modifier_old_god_d:Destroy()
    end
    if RollPercentage(10) then
        self:GetCaster():EmitSound("stariy_boh_unique")
    else
        self:GetCaster():EmitSound("stariy_boh")
    end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_old_god_d", {duration = duration})
end

modifier_old_god_d = class({})
function modifier_old_god_d:IsPurgable() return false end
function modifier_old_god_d:IsPurgeException() return false end
function modifier_old_god_d:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/stariy_boh/wisp_taunt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_old_god_d:OnDestroy()
    if not IsServer() then return end
    local explosion = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(explosion, 0, (self:GetParent():GetAbsOrigin() + self:GetParent():GetLeftVector() * 100) + Vector(0,0,100))
    ParticleManager:ReleaseParticleIndex(explosion)

    local explosion_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(explosion_2, 0, (self:GetParent():GetAbsOrigin() + self:GetParent():GetRightVector() * 100) + Vector(0,0,100))
    ParticleManager:ReleaseParticleIndex(explosion_2)
end

function modifier_old_god_d:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
end

function modifier_old_god_d:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("attack_range")
end