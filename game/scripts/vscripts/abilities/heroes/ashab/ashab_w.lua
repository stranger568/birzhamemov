LinkLuaModifier("modifier_ashab_w", "abilities/heroes/ashab/ashab_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ashab_w_debuff", "abilities/heroes/ashab/ashab_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

ashab_w = class({})

function ashab_w:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_death_explosion.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_start.vpcf", context)
    PrecacheResource("particle", "particles/ashab/car_radius.vpcf", context)
    PrecacheResource("model", "models/ashab/car.vmdl", context)
    PrecacheResource("model", "models/ashab/ashab.vmdl", context)
end

function ashab_w:GetBehavior()
    if self:GetCaster():HasShard() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function ashab_w:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ashab_w:OnSpellStart()
    if not IsServer() then return end
    if self:GetCaster():HasShard() then
        local point = self:GetCursorPosition()
        local particle_start = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_start.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle_start, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_start)
        FindClearSpaceForUnit(self:GetCaster(), point, true)
        local particle_start = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_start.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle_start, 0, point)
        ParticleManager:ReleaseParticleIndex(particle_start)
    end
    local duration_to_explosion = self:GetSpecialValueFor("duration_to_explosion")
    EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "ashab_car", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ashab_w", {duration = duration_to_explosion})
end

modifier_ashab_w = class({})
function modifier_ashab_w:IsPurgable() return false end
function modifier_ashab_w:IsPurgeException() return false end
function modifier_ashab_w:RemoveOnDeath() return false end
function modifier_ashab_w:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/ashab/car_radius.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(0.1)
end

function modifier_ashab_w:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    for _, unit in pairs(units) do
        if not unit:HasModifier("modifier_ashab_w_debuff") then
            unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ashab_w_debuff", {duration = self:GetRemainingTime()})
        end
    end
end

function modifier_ashab_w:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_ashab_w:GetModifierModelChange()
    return "models/ashab/car.vmdl"
end

function modifier_ashab_w:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("incoming_damage")
end

function modifier_ashab_w:OnDestroy()
    if not IsServer() then return end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    for _, unit in pairs(units) do
        ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
        unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = stun_duration * (1 - unit:GetStatusResistance())})
    end

    self:GetParent():EmitSound("Hero_Shredder.Bomb")

    local particle_death = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_death_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_death, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_death)

    local particle_radius = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_radius, 0, self:GetParent():GetAbsOrigin())
    --ParticleManager:SetParticleControl(particle_radius, 1, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(particle_radius) 
end

function modifier_ashab_w:CheckState()
    return
    {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

modifier_ashab_w_debuff = class({})

function modifier_ashab_w_debuff:OnCreated( kv )
    if not IsServer() then return end
    self.target = self:GetCaster():GetAbsOrigin() + RandomVector(100)
    if not self:GetParent():IsDebuffImmune() then 
        self:GetParent():MoveToPosition( self.target)
    end
    self:StartIntervalThink(0.1)
end

function modifier_ashab_w_debuff:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsDebuffImmune() and not self:GetParent():IsMoving() then 
        self:GetParent():MoveToPosition( self.target )
    end
end

function modifier_ashab_w_debuff:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_ashab_w_debuff:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():IsDebuffImmune() then 
        self:GetParent():Stop()
    end 
end

function modifier_ashab_w_debuff:CheckState()
    return
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_TAUNTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_DISARMED] = true
    }
end