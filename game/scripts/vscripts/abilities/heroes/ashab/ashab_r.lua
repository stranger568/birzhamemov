LinkLuaModifier("modifier_ashab_r", "abilities/heroes/ashab/ashab_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ashab_r_launch", "abilities/heroes/ashab/ashab_r", LUA_MODIFIER_MOTION_NONE)

ashab_r = class({})

function ashab_r:Precache(context)
    PrecacheResource("particle", "particles/ashab/ashab_r_rollcounter.vpcf", context)
    PrecacheResource("particle", "particles/ashab/ashab_r_cross.vpcf", context)
    PrecacheResource("particle", "particles/ashab/ashab_rocket_start.vpcf", context)
    PrecacheResource("particle", "particles/ashab/rocket_end.vpcf", context)
    PrecacheResource("particle", "particles/ashab/rocket_explosion.vpcf", context)
end

function ashab_r:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function ashab_r:GetAOERadius()
    return self:GetSpecialValueFor("radius_explosion")
end

function ashab_r:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local point = self:GetCursorPosition()
    if target == nil then
        target = CreateModifierThinker(self:GetCaster(), self, "modifier_invulnerable", {duration = 10}, point, self:GetCaster():GetTeamNumber(), false)
    end
    local cast_time = self:GetSpecialValueFor("cast_time")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ashab_r", {duration = cast_time+0.1, target = target:entindex()})
end

function ashab_r:Explosion(position, is_multiplier)
    if not IsServer() then return end
    local radius_explosion = self:GetSpecialValueFor("radius_explosion")
    local damage = self:GetSpecialValueFor("explosion_damage") * is_multiplier
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), position, nil, radius_explosion, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
        ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self })
    end
    local particle = ParticleManager:CreateParticle("particles/ashab/rocket_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius_explosion*3, radius_explosion*3, radius_explosion*3))
    ParticleManager:ReleaseParticleIndex(particle)
    EmitSoundOnLocationWithCaster(position, "Hero_Gyrocopter.CallDown.Damage", self:GetCaster())
end

modifier_ashab_r = class({})
function modifier_ashab_r:IsPurgable() return false end
function modifier_ashab_r:IsPurgeException() return false end
function modifier_ashab_r:IsHidden() return true end
function modifier_ashab_r:OnCreated(params)
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target)
    self.modifier_ashab_r_launch = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ashab_r_launch", {target = params.target})
    self.randomize = 0
    self.random_x = 1
    self.max_mult = self:GetAbility():GetSpecialValueFor("max_mult")
    self.min_mult = self:GetAbility():GetSpecialValueFor("min_mult")
    EmitGlobalSound("ashab_rocket")
    self:StartIntervalThink(0.2)
end

function modifier_ashab_r:OnIntervalThink()
    if not IsServer() then return end
    if self.particle_random then
        ParticleManager:DestroyParticle(self.particle_random, true)
    end
    self.randomize = self.randomize + 1
    if self.randomize >= 5 then
        self.random_x = RandomInt(self.min_mult, self.max_mult)
        self.particle_random = ParticleManager:CreateParticle("particles/ashab/ashab_r_rollcounter.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.particle_random, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle_random, 1, Vector(self.random_x, 1, 0))
        ParticleManager:ReleaseParticleIndex(self.particle_random)
        self:StartIntervalThink(-1)
        return
    end
    self:GetParent():EmitSound("Hero_OgreMagi.Fireblast.x1")
    self.random_x = RandomInt(self.min_mult, self.max_mult)
    self.particle_random = ParticleManager:CreateParticle("particles/ashab/ashab_r_rollcounter.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle_random, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle_random, 1, Vector(self.random_x, 1, 0))
    self:AddParticle(self.particle_random, false, false, 1, true, false)
end

function modifier_ashab_r:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_ashab_r:OnDestroy()
    if not IsServer() then return end
    if self.modifier_ashab_r_launch then
        self.modifier_ashab_r_launch:Launch(self.random_x)
    end
end

modifier_ashab_r_launch = class({})
function modifier_ashab_r_launch:IsHidden() return true end
function modifier_ashab_r_launch:IsPurgable() return false end
function modifier_ashab_r_launch:IsPurgeException() return false end
function modifier_ashab_r_launch:RemoveOnDeath() return false end
function modifier_ashab_r_launch:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ashab_r_launch:OnCreated(params)
    if not IsServer() then return end
    self.radius_explosion = self:GetAbility():GetSpecialValueFor("radius_explosion")
    self.target = EntIndexToHScript(params.target)
    local particle = ParticleManager:CreateParticle("particles/ashab/ashab_r_cross.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
    ParticleManager:SetParticleControlEnt(particle, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.radius_explosion, 0, 0))
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())
end

function modifier_ashab_r_launch:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), self.radius_explosion, FrameTime(), false)
end

function modifier_ashab_r_launch:Launch(multiplier)
    if not IsServer() then return end
    local origin = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 250
    local particle = ParticleManager:CreateParticle("particles/ashab/ashab_rocket_start.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, origin + Vector(0,0,2000))
    ParticleManager:ReleaseParticleIndex(particle)
    local modifier = self
    local target = self.target
    local ability = self:GetAbility()
    local is_multiplier = multiplier
    Timers:CreateTimer(3, function()
        local position = target:GetAbsOrigin()
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        local particle = ParticleManager:CreateParticle("particles/ashab/rocket_end.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, position + Vector(0,0,2000))
        ParticleManager:SetParticleControl(particle, 1, position)
        ParticleManager:ReleaseParticleIndex(particle)
        Timers:CreateTimer(0.5, function()
            ability:Explosion(position, is_multiplier)
        end)
    end)
end