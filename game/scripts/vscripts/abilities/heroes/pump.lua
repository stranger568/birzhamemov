LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pump_charm", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )

pump_charm = class({})

function pump_charm:Precache(context)
    PrecacheResource("model", "models/pump/pump.vmdl", context)
    local particle_list = 
    {
        "particles/pump/charm_effect.vpcf",
        "particles/pump_new_sugar.vpcf",
        "particles/pump/shield_pump.vpcf",
        "particles/pump/sphere_ultimate.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function pump_charm:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_1")
end

function pump_charm:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_6")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pump_charm", {duration = duration})
end

modifier_pump_charm = class({})

function modifier_pump_charm:IsPurgable() return false end

function modifier_pump_charm:OnCreated()
    if not IsServer() then return end

    self:StartIntervalThink(0.5)

    self.damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetParent():GetIntellect(false) / 100 * (self:GetAbility():GetSpecialValueFor("int_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_2")))
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_3")
    self.radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_1")

    local particle = ParticleManager:CreateParticle( "particles/pump/charm_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle( particle, false, false, -1, false, false )
end

function modifier_pump_charm:OnIntervalThink()
    if not IsServer() then return end
    local flag = 0

    if self:GetCaster():HasTalent("special_bonus_birzha_pump_8") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    self:GetParent():EmitSound("pump_charm_boom")

    local particle = ParticleManager:CreateParticle( "particles/pump_charm_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc2", Vector(0,0,0), true )
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(particle)

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    end

    self.damage = self.damage + (self.bonus_damage * 0.5)
end

LinkLuaModifier( "modifier_pump_sugar_cast", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

pump_sugar = class({})

function pump_sugar:GetChannelTime()
    if self:GetCaster():HasTalent("special_bonus_birzha_pump_5") then
        return 0.4
    end
    return 0
end

function pump_sugar:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_pump_5") then
        return DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
    end
    return DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT
end

function pump_sugar:OnChannelFinish( bInterrupted )
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
    if self:GetCaster():HasTalent("special_bonus_birzha_pump_5") then
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
    end
end

function pump_sugar:OnSpellStart()
    local caster = self:GetCaster()
    local origin = caster:GetOrigin()
    local point = self:GetCursorPosition()

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)

    if self:GetCaster():HasTalent("special_bonus_birzha_pump_5") then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pump_sugar_cast", {x=point.x, y=point.y, z=point.z})
        return
    end

    local projectile_name = "particles/pump_new_sugar.vpcf"
    local projectile_speed = 900
    local projectile_distance = self:GetSpecialValueFor("range")
    local projectile_start_radius = 100
    local projectile_end_radius = 100
    local projectile_vision = 100

    local min_damage = self:GetSpecialValueFor( "min_damage" )
    local max_damage = self:GetSpecialValueFor( "max_damage" )
    local min_stun = self:GetSpecialValueFor( "min_stun_duration" )
    local max_stun = self:GetSpecialValueFor( "max_stun_duration" )
    local max_distance = projectile_distance / 2

    local projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

    if point == origin then
        projectile_direction = caster:GetForwardVector()
    else
        projectile_direction = (point - origin):Normalized()
    end

    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        bDeleteOnHit = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = projectile_name,
        fDistance = projectile_distance,
        fStartRadius = projectile_start_radius,
        fEndRadius =projectile_end_radius,
        vVelocity = projectile_direction * projectile_speed,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = true,
        iVisionRadius = projectile_vision,
        iVisionTeamNumber = caster:GetTeamNumber(),

        ExtraData = {
            originX = origin.x,
            originY = origin.y,
            originZ = origin.z,
            max_distance = max_distance,
            min_stun = min_stun,
            max_stun = max_stun,
            min_damage = min_damage,
            max_damage = max_damage,
        }
    }
    self:GetCaster():EmitSound("pump_stun_cast")
    ProjectileManager:CreateLinearProjectile(info)

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
end

function pump_sugar:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
    if hTarget==nil then return end

    if hTarget:IsMagicImmune() then return end

    local origin = Vector( extraData.originX, extraData.originY, extraData.originZ )

    local distance = (hTarget:GetAbsOrigin()-origin):Length2D()

    local bonus_pct = math.min(1,distance/extraData.max_distance)

    local damage = math.max(extraData.min_damage, extraData.max_damage*bonus_pct)

    local damageTable = { victim = hTarget, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self }

    ApplyDamage(damageTable)

    hTarget:EmitSound("pump_stun_sugar")

    hTarget:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = (math.max(extraData.min_stun, extraData.max_stun*bonus_pct)) * (1-hTarget:GetStatusResistance()) } )

    if self:GetCaster():HasShard() then
        local direction = (hTarget:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.1, distance = self:GetSpecialValueFor("shard_knockback"), height = 0, direction_x = direction.x, direction_y = direction.y, IsStun = true})
    end

    return true
end

modifier_pump_sugar_cast = class({})

function modifier_pump_sugar_cast:IsPurgable() return false end

function modifier_pump_sugar_cast:OnCreated(kv)
    if not IsServer() then return end
    self.point = Vector(kv.x,kv.y,kv.z)
    self:StartIntervalThink(0.10)
    self:OnIntervalThink()
end

function modifier_pump_sugar_cast:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local origin = caster:GetOrigin()

    local projectile_name = "particles/pump_new_sugar.vpcf"
    local projectile_speed = 900
    local projectile_distance = self:GetAbility():GetSpecialValueFor("range")
    local projectile_start_radius = 75
    local projectile_end_radius = 75
    local projectile_vision = 75

    local min_damage = self:GetAbility():GetSpecialValueFor( "min_damage" )
    local max_damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
    local min_stun = self:GetAbility():GetSpecialValueFor( "min_stun_duration" )
    local max_stun = self:GetAbility():GetSpecialValueFor( "max_stun_duration" )
    local max_distance = projectile_distance / 2

    local projectile_direction = (Vector( self.point.x-origin.x, self.point.y-origin.y, 0 )):Normalized()

    if self.point == origin then
        projectile_direction = caster:GetForwardVector()
    else
        projectile_direction = (self.point - origin):Normalized()
    end

    local info = {
        Source = caster,
        Ability = self:GetAbility(),
        vSpawnOrigin = caster:GetOrigin(),
        bDeleteOnHit = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = projectile_name,
        fDistance = projectile_distance,
        fStartRadius = projectile_start_radius,
        fEndRadius =projectile_end_radius,
        vVelocity = projectile_direction * projectile_speed,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = true,
        iVisionRadius = projectile_vision,
        iVisionTeamNumber = caster:GetTeamNumber(),

        ExtraData = {
            originX = origin.x,
            originY = origin.y,
            originZ = origin.z,
            max_distance = max_distance,
            min_stun = min_stun,
            max_stun = max_stun,
            min_damage = min_damage,
            max_damage = max_damage,
        }
    }
    self:GetCaster():EmitSound("pump_stun_cast")
    ProjectileManager:CreateLinearProjectile(info)
end

LinkLuaModifier( "modifier_pump_skid", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pump_skid_active", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pump_skid_resist_active", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )

pump_skid = class({})

function pump_skid:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_4")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pump_skid_active", {duration = duration})
    local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
    local count = 0
    for _, hero in pairs(heroes) do
        if count >= 2 then break end
        count = count + 1
        hero:AddNewModifier(self:GetCaster(), self, "modifier_pump_skid_resist_active", {duration = duration})
    end
end

modifier_pump_skid_resist_active = class({})

function modifier_pump_skid_resist_active:OnCreated()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle( "particles/pump/shield_pump.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
    self:AddParticle(effect_cast, false, false, -1, false, false)
end

function modifier_pump_skid_resist_active:IsPurgable() return false end

function modifier_pump_skid_resist_active:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
    return funcs
end

function modifier_pump_skid_resist_active:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("spell_resist")
end

function modifier_pump_skid_resist_active:GetModifierStatusResistanceStacking()
    return self:GetAbility():GetSpecialValueFor("effect_resist")
end

modifier_pump_skid_active = class({})

function modifier_pump_skid_active:IsHidden() return true end

function modifier_pump_skid_active:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("pump_shield")
    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_pump_4")
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_lotus_orb_active", {duration = duration})
end

function modifier_pump_skid_active:IsPurgable() return false end

LinkLuaModifier( "modifier_pump_spooky_aura", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pump_spooky", "abilities/heroes/pump.lua", LUA_MODIFIER_MOTION_NONE )

pump_spooky = class({})

function pump_spooky:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pump_spooky_aura", {duration = duration})
end

modifier_pump_spooky_aura = class({})

function modifier_pump_spooky_aura:RemoveOnDeath() return true end

function modifier_pump_spooky_aura:OnCreated()
    if not IsServer() then return end

    self.flag = 0

    if self:GetCaster():HasTalent("special_bonus_birzha_pump_7") then
         self.flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)

    EmitSoundOn("pump_dance", self:GetParent())

    self.origin = self:GetCaster():GetAbsOrigin()

    self.particle = ParticleManager:CreateParticle("particles/pump/sphere_ultimate.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 0, self.origin)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), 1))
    self:AddParticle(self.particle, false, false, -1, false, false)

    self:StartIntervalThink(0.5)
end

function modifier_pump_spooky_aura:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }

    return decFuncs
end

function modifier_pump_spooky_aura:OnDeath( params )
    if params.unit == self:GetParent() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_pump_spooky_aura:GetModifierMoveSpeed_Absolute()
    return 100
end

function modifier_pump_spooky_aura:OnIntervalThink()
    if not IsServer() then return end
    if self.origin ~= self:GetCaster():GetAbsOrigin() then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
            self.origin = self:GetCaster():GetAbsOrigin()
            self.particle = ParticleManager:CreateParticle("particles/pump/sphere_ultimate.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(self.particle, 0, self.origin)
            ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), 1))
            self:AddParticle(self.particle, false, false, -1, false, false)
        end     
    end
end

function modifier_pump_spooky_aura:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("pump_dance", self:GetParent())
    self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_6)
end

function modifier_pump_spooky_aura:CheckState()
    if self:GetCaster():HasScepter() then 
        return 
        {
            [MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_MUTED] = true,
        } 
    end
    local state = { [MODIFIER_STATE_STUNNED] = true}
    return state
end

function modifier_pump_spooky_aura:IsAura()
    return true
end

function modifier_pump_spooky_aura:GetModifierAura()
    return "modifier_pump_spooky"
end

function modifier_pump_spooky_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_pump_spooky_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_pump_spooky_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_pump_spooky_aura:GetAuraSearchFlags()
    return self.flag
end

modifier_pump_spooky = class({})

function modifier_pump_spooky:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_pump_spooky:CheckState()
    local state = { [MODIFIER_STATE_STUNNED] = true}
    return state
end

function modifier_pump_spooky:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * FrameTime(), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
    local angle = self:GetParent():GetAngles()
    self:GetParent():SetAngles(angle.x, angle.y+(360 * FrameTime()), angle.z)
end