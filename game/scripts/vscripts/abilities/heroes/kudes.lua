LinkLuaModifier( "modifier_Kudes_GoldHook", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_Kudes_GoldHook_debuff", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_HORIZONTAL  )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_Kudes_GoldHook_shard_thinker", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_Kudes_GoldHook_shard_debuff", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )

Kudes_GoldHook = class({})

Kudes_GoldHook.hooks = {}

function Kudes_GoldHook:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kudes_GoldHook:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_1")
end

function Kudes_GoldHook:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kudes_GoldHook:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
    return true
end

function Kudes_GoldHook:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function Kudes_GoldHook:OnSpellStart()
	if not IsServer() then return end

    local target = nil
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor( "hook_distance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	
    if #enemies <= 0 then return end

	target = enemies[1]

	if not target then return end

    local distance = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin())
    distance.z = 0
    local duration = distance:Length2D() / self:GetSpecialValueFor("hook_speed")
    local direction = distance:Normalized()

    local hook_particle = ParticleManager:CreateParticle( "particles/pudge_meathook_2.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleAlwaysSimulate( hook_particle )
    ParticleManager:SetParticleControlEnt( hook_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true )
    ParticleManager:SetParticleControlEnt( hook_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin() + Vector( 0, 0, 96 ), true )
    ParticleManager:SetParticleControl( hook_particle, 2, Vector( self:GetSpecialValueFor("hook_speed"), self:GetSpecialValueFor("hook_speed"), self:GetSpecialValueFor("hook_speed")) )
    ParticleManager:SetParticleControl( hook_particle, 3, Vector(20,20,20) )
    ParticleManager:SetParticleControl( hook_particle, 4, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( hook_particle, 5, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControlEnt( hook_particle, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

    local info = 
    {
        Ability = self,
        iMoveSpeed = self:GetSpecialValueFor("hook_speed"),
        Source = target,
        bDodgeable = false,
        Target = self:GetCaster(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    }

    local proj = ProjectileManager:CreateTrackingProjectile( info )

    self.hooks[proj] = true

    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Pudge.AttackHookImpact", self:GetCaster())
    --EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Pudge.AttackHookRetract", self:GetCaster())
    --self:GetCaster():EmitSound("Hero_Pudge.AttackHookExtend")

    local mod = target:AddNewModifier(self:GetCaster(), self, "modifier_Kudes_GoldHook", {particle = hook_particle, duration = duration })
    mod.proj = proj
end

function Kudes_GoldHook:OnProjectileHitHandle( hTarget, vLocation, index )
	if not IsServer() then return end
    self.hooks[index] = false
    return true
end

modifier_Kudes_GoldHook = class({})

function modifier_Kudes_GoldHook:IsPurgable() return false end
function modifier_Kudes_GoldHook:IsHidden() return true end

function modifier_Kudes_GoldHook:IsDebuff()
    return true
end

function modifier_Kudes_GoldHook:RemoveOnDeath()
    return false
end

function modifier_Kudes_GoldHook:IsPurgable()
    return false
end

function modifier_Kudes_GoldHook:OnCreated( params )
    if not IsServer() then return end
    self.origin = self:GetParent():GetAbsOrigin()
    self.distance_fire = 0
    self.particle = params.particle
    self:StartIntervalThink(FrameTime())
end

function modifier_Kudes_GoldHook:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_Kudes_GoldHook:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_Kudes_GoldHook:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_Kudes_GoldHook:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, true)
    end
    local damage = self:GetAbility():GetSpecialValueFor("hook_damage")
    ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

    if self:GetCaster():HasTalent("special_bonus_birzha_kudes_3") then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Kudes_GoldHook_debuff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_3", "value2") * (1-self:GetParent():GetStatusResistance()) })
    end

    if self:GetAbility().hooks[self.proj] == true then
        ProjectileManager:DestroyTrackingProjectile(self.proj)
    end
end

function modifier_Kudes_GoldHook:OnIntervalThink()
    if not IsServer() then return end
    if self.proj == nil then return end

    if self:GetCaster():HasShard() then
        local distance_new = (self:GetParent():GetAbsOrigin() - self.origin):Length2D()
        self.distance_fire = self.distance_fire + distance_new
        if self.distance_fire >= self:GetAbility():GetSpecialValueFor("shard_distance") then
            self.distance_fire = 0
            local direction = (self:GetParent():GetAbsOrigin() - self.origin)
            direction.z = 0
            direction = direction:Normalized()
            CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_Kudes_GoldHook_shard_thinker", {duration = self:GetAbility():GetSpecialValueFor("shard_fire_duration"), x = direction.x, y = direction.y}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
        end
        self.origin = self:GetParent():GetAbsOrigin()
    end

    if self:GetAbility().hooks[self.proj] ~= nil and self:GetAbility().hooks[self.proj] == true then
        local proj_loc = ProjectileManager:GetTrackingProjectileLocation(self.proj)
        if proj_loc ~= nil then
            proj_loc = GetGroundPosition(proj_loc, nil)
            self:GetParent():SetAbsOrigin(proj_loc)
        else
            self:Destroy()
        end
    else
        self:Destroy()
    end
end

modifier_Kudes_GoldHook_shard_thinker = class({})

function modifier_Kudes_GoldHook_shard_thinker:IsHidden() return true end
function modifier_Kudes_GoldHook_shard_thinker:IsPurgable() return false end

function modifier_Kudes_GoldHook_shard_thinker:OnCreated(table)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("shard_distance")
    self.duration = self:GetAbility():GetSpecialValueFor("shard_fire_duration")
    self.interval = 0.1
    self.duration_fire = self:GetAbility():GetSpecialValueFor("shard_debuff_duration")
    self.dir = Vector(table.x, table.y, z)
    self.start_pos = self:GetParent():GetAbsOrigin() - self.dir*self.radius/2
    self.end_pos = self:GetParent():GetAbsOrigin() + self.dir*self.radius/2

    self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_spear_burning_trail.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.pfx, 0, self.start_pos)
    ParticleManager:SetParticleControl(self.pfx, 1, self.end_pos)
    ParticleManager:SetParticleControl(self.pfx, 2, Vector(self.duration, 0, 0))
    ParticleManager:SetParticleControl(self.pfx, 3, Vector(self.radius, 0, 0))
    self:AddParticle( self.pfx, false, false, -1, false, false )
    
    self:StartIntervalThink(self.interval)
end

function modifier_Kudes_GoldHook_shard_thinker:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self.start_pos, self.end_pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Kudes_GoldHook_shard_debuff", {duration = self.duration_fire * (1-enemy:GetStatusResistance()) })
    end
end

modifier_Kudes_GoldHook_shard_debuff = class({})

function modifier_Kudes_GoldHook_shard_debuff:IsHidden() return false end

function modifier_Kudes_GoldHook_shard_debuff:OnCreated(table)
    self.interval = 0.5
    self.slow = self:GetAbility():GetSpecialValueFor("shard_slow")
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("shard_fire_damage") * 0.5
    self:StartIntervalThink(self.interval)
end

function modifier_Kudes_GoldHook_shard_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_Kudes_GoldHook_shard_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_Kudes_GoldHook_shard_debuff:OnIntervalThink()
    if not IsServer() then return end
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
end

function modifier_Kudes_GoldHook_shard_debuff:GetEffectName()
    return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_Kudes_GoldHook_shard_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_Kudes_GoldHook_debuff = class({})

function modifier_Kudes_GoldHook_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_Kudes_GoldHook_debuff:GetModifierIncomingDamage_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_3")
end

LinkLuaModifier("modifier_kudes_leap", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_JumpInHead_arena", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_JumpInHead_arena_wall", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_JumpInHead_arena_damage", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_JumpInHead_arena_magic_immune_aura", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_JumpInHead_arena_magic_immune", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_JumpInHead_arena_disarmed", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE )


Kudes_JumpInHead = class({})

function Kudes_JumpInHead:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_2")
end

function Kudes_JumpInHead:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Kudes_JumpInHead:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kudes_JumpInHead:GetAOERadius()
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
end

function Kudes_JumpInHead:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    self:GetCaster():SetForwardVector((point - self:GetCaster():GetAbsOrigin()):Normalized())
    self:GetCaster():FaceTowards(point)
    local duration = self:GetSpecialValueFor( "leap_duration" )
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
    local distance = (point - self:GetCaster():GetOrigin()):Length2D()
    local damage = self:GetSpecialValueFor("damage")
    local arc = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_kudes_leap",
        {
            target_x = point.x,
            target_y = point.y,
            distance = distance,
            duration = duration,
            height = 250,
            fix_end = false,
            isForward = true,
        }
    )

    arc:SetEndCallback(function()
        self:GetCaster():EmitSound("Hero_ElderTitan.EchoStomp")
        FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true)
        local duration = self:GetSpecialValueFor("duration")
        CreateModifierThinker( self:GetCaster(), self, "modifier_JumpInHead_arena", {duration = duration}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            ApplyDamage({attacker = self:GetCaster(), victim = enemy, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end)

	ProjectileManager:ProjectileDodge(self:GetCaster())
end

modifier_kudes_leap = class({})

function modifier_kudes_leap:IsHidden()
    return true
end

function modifier_kudes_leap:IsDebuff()
    return false
end

function modifier_kudes_leap:IsStunDebuff()
    return false
end

function modifier_kudes_leap:IsPurgable()
    return true
end

function modifier_kudes_leap:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kudes_leap:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_kudes_leap:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_kudes_leap:OnDestroy()
    if not IsServer() then return end

    local pos = self:GetParent():GetOrigin()

    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )

    if self.end_offset~=0 then
        self:GetParent():SetOrigin( pos )
    end

    if self.endCallback then
        self.endCallback( self.interrupted )
    end
end

function modifier_kudes_leap:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
    }
    return funcs
end

function modifier_kudes_leap:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end

function modifier_kudes_leap:GetActivityTranslationModifiers()
    return "ultimate_scepter"
end

function modifier_kudes_leap:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_kudes_leap:GetEffectName()
    return "particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_blur.vpcf"
end

function modifier_kudes_leap:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kudes_leap:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

function modifier_kudes_leap:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_kudes_leap:UpdateVerticalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    local pos = me:GetOrigin()
    local time = self:GetElapsedTime()

    local height = pos.z
    local speed = self:GetVerticalSpeed( time )
    pos.z = height + speed * dt
    me:SetOrigin( pos )

    if not self.fix_duration then
        local ground = GetGroundHeight( pos, me ) + self.end_offset
        if pos.z <= ground then
            pos.z = ground
            me:SetOrigin( pos )
            self:Destroy()
        end
    end
end

function modifier_kudes_leap:OnHorizontalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_kudes_leap:OnVerticalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_kudes_leap:SetJumpParameters( kv )
    self.parent = self:GetParent()

    self.fix_end = true
    self.fix_duration = true
    self.fix_height = true
    if kv.fix_end then
        self.fix_end = kv.fix_end==1
    end
    if kv.fix_duration then
        self.fix_duration = kv.fix_duration==1
    end
    if kv.fix_height then
        self.fix_height = kv.fix_height==1
    end

    self.isStun = kv.isStun==1
    self.isRestricted = kv.isRestricted==1
    self.isForward = kv.isForward==1
    self.activity = kv.activity or 0
    self:SetStackCount( self.activity )

    if kv.target_x and kv.target_y then
        local origin = self.parent:GetOrigin()
        local dir = Vector( kv.target_x, kv.target_y, 0 ) - origin
        dir.z = 0
        dir = dir:Normalized()
        self.direction = dir
    end
    if kv.dir_x and kv.dir_y then
        self.direction = Vector( kv.dir_x, kv.dir_y, 0 ):Normalized()
    end
    if not self.direction then
        self.direction = self.parent:GetForwardVector()
    end

    self.duration = kv.duration
    self.distance = kv.distance
    self.speed = kv.speed
    if not self.duration then
        self.duration = self.distance/self.speed
    end
    if not self.distance then
        self.speed = self.speed or 0
        self.distance = self.speed*self.duration
    end
    if not self.speed then
        self.distance = self.distance or 0
        self.speed = self.distance/self.duration
    end

    self.height = kv.height or 0
    self.start_offset = kv.start_offset or 0
    self.end_offset = kv.end_offset or 0

    local pos_start = self.parent:GetOrigin()
    local pos_end = pos_start + self.direction * self.distance
    local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
    local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
    local height_max

    if not self.fix_height then
        self.height = math.min( self.height, self.distance/4 )
    end

    if self.fix_end then
        height_end = height_start
        height_max = height_start + self.height
    else
        -- calculate height
        local tempmin, tempmax = height_start, height_end
        if tempmin>tempmax then
            tempmin,tempmax = tempmax, tempmin
        end
        local delta = (tempmax-tempmin)*2/3

        height_max = tempmin + delta + self.height
    end

    if not self.fix_duration then
        self:SetDuration( -1, false )
    else
        self:SetDuration( self.duration, true )
    end

    self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_kudes_leap:Jump()
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end

    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end
end

function modifier_kudes_leap:InitVerticalArc( height_start, height_max, height_end, duration )
    local height_end = height_end - height_start
    local height_max = height_max - height_start

    if height_max<height_end then
        height_max = height_end+0.01
    end

    if height_max<=0 then
        height_max = 0.01
    end

    local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
    self.const1 = 4*height_max*duration_end/duration
    self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_kudes_leap:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_kudes_leap:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

function modifier_kudes_leap:SetEndCallback( func )
    self.endCallback = func
end





modifier_JumpInHead_arena = class({})

function modifier_JumpInHead_arena:IsHidden()
    return true
end

function modifier_JumpInHead_arena:OnCreated( kv )
    self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
    if not IsServer() then return end
    self.thinkers = {}
    self.phase_delay = true
    self:StartIntervalThink( 0 )
    self:PlayEffects(self.radius)
end

function modifier_JumpInHead_arena:OnDestroy()
    if not IsServer() then return end
    local modifiers = {}
    for k,v in pairs(self:GetParent():FindAllModifiers()) do
        modifiers[k] = v
    end
    for k,v in pairs(modifiers) do
        v:Destroy()
    end
    UTIL_Remove( self:GetParent() ) 
end

function modifier_JumpInHead_arena:OnIntervalThink()
    if self.phase_delay then
        self.phase_delay = false
        AddFOWViewer( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.radius, self.duration, false)
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_JumpInHead_arena_wall", {} )
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_JumpInHead_arena_damage", {} )
        if self:GetCaster():HasTalent("special_bonus_birzha_kudes_5") then
            self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_JumpInHead_arena_magic_immune_aura", {} )
        end
        self:StartIntervalThink( self.duration )
        self.phase_duration = true
        return
    end
    if self.phase_duration then
        self:Destroy()
        return
    end
end

function modifier_JumpInHead_arena:PlayEffects(radius)
    local particle = ParticleManager:CreateParticle("particles/kudes/kudes_arena.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0))
    ParticleManager:SetParticleControl(particle, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 4, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 5, self:GetParent():GetAbsOrigin())

    local particle_damage = ParticleManager:CreateParticle("particles/kudes/arena_shard.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_damage, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_damage)
    self:GetParent():EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")

    self:AddParticle( particle, false, false, -1, false, false )
end

modifier_JumpInHead_arena_wall = class({})

function modifier_JumpInHead_arena_wall:IsHidden()
    return true
end

function modifier_JumpInHead_arena_wall:IsDebuff()
    return true
end

function modifier_JumpInHead_arena_wall:IsPurgable()
    return false
end

function modifier_JumpInHead_arena_wall:OnCreated( kv )
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
    self.width = 50
    self.parent = self:GetParent()
    self.twice_width = self.width*2
    self.aura_radius = self.radius + self.twice_width
    self.MAX_SPEED = 550
    self.MIN_SPEED = 1
    self.owner = kv.isProvidedByAura~=1
    if not self.owner then
        self.aura_origin = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
    else
        self.aura_origin = self:GetParent():GetOrigin()
    end
end

function modifier_JumpInHead_arena_wall:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
    return funcs
end

function modifier_JumpInHead_arena_wall:GetModifierMoveSpeed_Limit( params )
    if not IsServer() then return end
    if self.owner then return 0 end

    local parent_vector = self.parent:GetOrigin()-self.aura_origin
    local parent_direction = parent_vector:Normalized()

    local actual_distance = parent_vector:Length2D()
    local wall_distance = actual_distance-self.radius
    local isInside = (wall_distance)<0
    wall_distance = math.min( math.abs( wall_distance ), self.twice_width )
    wall_distance = math.max( wall_distance, self.width ) - self.width

    local parent_angle = 0
    if isInside then
        parent_angle = VectorToAngles(parent_direction).y
    else
        parent_angle = VectorToAngles(-parent_direction).y
    end
    local unit_angle = self:GetParent():GetAnglesAsVector().y
    local wall_angle = math.abs( AngleDiff( parent_angle, unit_angle ) )

    local limit = 0
    if wall_angle>90 then
        limit = 0
    else
        limit = self:Interpolate( wall_distance/self.width, self.MIN_SPEED, self.MAX_SPEED )
    end

    return limit
end

function modifier_JumpInHead_arena_wall:Interpolate( value, min, max )
    return value*(max-min) + min
end

function modifier_JumpInHead_arena_wall:IsAura()
    return self.owner
end

function modifier_JumpInHead_arena_wall:GetModifierAura()
    return "modifier_JumpInHead_arena_wall"
end

function modifier_JumpInHead_arena_wall:GetAuraRadius()
    return self.aura_radius
end

function modifier_JumpInHead_arena_wall:GetAuraDuration()
    return 0.3
end

function modifier_JumpInHead_arena_wall:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_JumpInHead_arena_wall:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_JumpInHead_arena_wall:GetAuraSearchFlags()
    return 0
end

function modifier_JumpInHead_arena_wall:GetAuraEntityReject( unit )
    if not IsServer() then return end
    return false
end

modifier_JumpInHead_arena_damage = class({})

function modifier_JumpInHead_arena_damage:IsHidden()
    return true
end

function modifier_JumpInHead_arena_damage:IsDebuff()
    return true
end

function modifier_JumpInHead_arena_damage:IsPurgable()
    return true
end

function modifier_JumpInHead_arena_damage:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
    self.width = 100
    self.duration = 0.05
    self.damage = self:GetAbility():GetSpecialValueFor( "damage_on_block" )
    self.knockback_duration = 0.2

    self.parent = self:GetParent()
    self.spear_radius = self.radius-self.width

    if not IsServer() then return end

    self.owner = kv.isProvidedByAura~=1
    self.aura_origin = self:GetParent():GetOrigin()

    if not self.owner then
        if self:GetParent():HasModifier("modifier_zema_cosmic_blindness_debuff") then return end
        self.aura_origin = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
        local direction = self.aura_origin-self:GetParent():GetOrigin()
        direction.z = 0
        ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility() })
        self:PlayEffects( self:GetParent() )
        if self:GetParent():HasModifier( "modifier_Kudes_GoldHook" ) then return end
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_generic_knockback_lua", { duration = self.knockback_duration, distance = self.width, height = 30, direction_x = direction.x, direction_y = direction.y})
        if self:GetCaster():HasTalent("special_bonus_birzha_kudes_6") then
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_JumpInHead_arena_disarmed", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_6") * (1-self:GetParent():GetStatusResistance()) })
        end
    end
end

function modifier_JumpInHead_arena_damage:IsAura()
    return self.owner
end

function modifier_JumpInHead_arena_damage:GetModifierAura()
    return "modifier_JumpInHead_arena_damage"
end

function modifier_JumpInHead_arena_damage:GetAuraRadius()
    return self.radius
end

function modifier_JumpInHead_arena_damage:GetAuraDuration()
    return self.duration
end

function modifier_JumpInHead_arena_damage:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_JumpInHead_arena_damage:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_JumpInHead_arena_damage:GetAuraSearchFlags()
    return 0
end
function modifier_JumpInHead_arena_damage:GetAuraEntityReject( unit )
    if not IsServer() then return end
    if unit:HasFlyMovementCapability() then return true end
    if unit:IsCurrentlyVerticalMotionControlled() then return true end
    if unit:FindModifierByNameAndCaster( "modifier_JumpInHead_arena_damage", self:GetCaster() ) then
        return true
    end
    local distance = (unit:GetOrigin()-self.aura_origin):Length2D()
    if (distance-self.spear_radius)<0 then
        return true
    end
    return false
end

function modifier_JumpInHead_arena_damage:PlayEffects( target )
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    target:EmitSound("Hero_Mars.Spear.Knockback")
end

modifier_JumpInHead_arena_disarmed = class({})

function modifier_JumpInHead_arena_disarmed:IsPurgable() return false end
function modifier_JumpInHead_arena_disarmed:GetEffectName() return "particles/units/heroes/hero_sniper/concussive_grenade_disarm.vpcf" end
function modifier_JumpInHead_arena_disarmed:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_JumpInHead_arena_disarmed:CheckState()
    return 
    {
        [MODIFIER_STATE_DISARMED] = true
    }
end

modifier_JumpInHead_arena_magic_immune_aura = class({})

function modifier_JumpInHead_arena_magic_immune_aura:IsHidden()
    return true
end

function modifier_JumpInHead_arena_magic_immune_aura:IsDebuff()
    return true
end

function modifier_JumpInHead_arena_magic_immune_aura:IsPurgable()
    return true
end

function modifier_JumpInHead_arena_magic_immune_aura:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
end

function modifier_JumpInHead_arena_magic_immune_aura:IsAura()
    return true
end

function modifier_JumpInHead_arena_magic_immune_aura:GetModifierAura()
    return "modifier_JumpInHead_arena_magic_immune"
end

function modifier_JumpInHead_arena_magic_immune_aura:GetAuraRadius()
    return self.radius
end

function modifier_JumpInHead_arena_magic_immune_aura:GetAuraDuration()
    return 0
end

function modifier_JumpInHead_arena_magic_immune_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_JumpInHead_arena_magic_immune_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_JumpInHead_arena_magic_immune_aura:GetAuraSearchFlags()
    return 0
end

function modifier_JumpInHead_arena_magic_immune_aura:GetAuraEntityReject( unit )
    if not IsServer() then return end
    if unit ~= self:GetCaster() then return true end
    return false
end

modifier_JumpInHead_arena_magic_immune = class({})

function modifier_JumpInHead_arena_magic_immune:IsHidden()
    return true
end

function modifier_JumpInHead_arena_magic_immune:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_JumpInHead_arena_magic_immune:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_JumpInHead_arena_magic_immune:CheckState()
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_JumpInHead_arena_magic_immune:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
    }

    return decFuncs
end

function modifier_JumpInHead_arena_magic_immune:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_JumpInHead_arena_magic_immune:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_JumpInHead_arena_magic_immune:StatusEffectPriority()
    return 99999
end

LinkLuaModifier( "modifier_Kudes_Fat", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_Kudes_Fat_shard", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )

Kudes_Fat = class({})

function Kudes_Fat:GetCooldown(level)
    if self:GetCaster():HasScepter() then 
        return self:GetSpecialValueFor("scepter_cooldown")
    end
    return 0
end

function Kudes_Fat:GetBehavior()
    local caster = self:GetCaster()
    if self:GetCaster():HasScepter() then 
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Kudes_Fat:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Kudes_Fat_shard", {duration = self:GetSpecialValueFor("scepter_duration")})
    self:GetCaster():EmitSound("kudes_shard")
end

modifier_Kudes_Fat_shard = class({})

function modifier_Kudes_Fat_shard:IsPurgable() return true end

function modifier_Kudes_Fat_shard:OnCreated()
    if not IsServer() then return end
    self.particle_1 = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff.vpcf"
    self.particle_2 = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff_egg.vpcf"
    self.particle_3 = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff_streaks.vpcf"

    self.buff_particles = {}

    self.buff_particles[1] = ParticleManager:CreateParticle(self.particle_1, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.buff_particles[1], 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,0), false) 
    self:AddParticle(self.buff_particles[1], false, false, -1, true, false)
    ParticleManager:SetParticleControl( self.buff_particles[1], 3, Vector( 255, 255, 255 ) )

    self.buff_particles[2] = ParticleManager:CreateParticle(self.particle_2, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.buff_particles[2], 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,0), false) 
    self:AddParticle(self.buff_particles[2], false, false, -1, true, false)

    self.buff_particles[3] = ParticleManager:CreateParticle(self.particle_3, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.buff_particles[3], 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,0), false) 
    self:AddParticle(self.buff_particles[3], false, false, -1, true, false)

end

modifier_Kudes_Fat = class({})

function Kudes_Fat:GetIntrinsicModifierName()
    return "modifier_Kudes_Fat"
end

function modifier_Kudes_Fat:IsPurgable()
	return false
end

function modifier_Kudes_Fat:OnCreated()
    if not IsServer() then return end
	self:StartIntervalThink(0.1) 
end

function modifier_Kudes_Fat:OnIntervalThink()
	if not IsServer() then return end
		local caster = self:GetParent()
		local oldStackCount = self:GetStackCount()
		local health_one_percent = caster:GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor( "hp_stack" )
		local stack = math.floor(caster:GetHealth() / health_one_percent)

	if self:GetCaster():PassivesDisabled() then 
		self:SetStackCount( 0 )
		return
	end

	self:SetStackCount( stack )		
end

function modifier_Kudes_Fat:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function modifier_Kudes_Fat:GetModifierIncomingDamage_Percentage( params )
    local multi = 1

    if self:GetCaster():HasModifier('modifier_Kudes_Fat_shard') then
        multi = self:GetAbility():GetSpecialValueFor("scepter_multiple")
    end

	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor( "damage_min" ) * multi
end

LinkLuaModifier( "modifier_Kudes_Items", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )

Kudes_Items = class({})

modifier_Kudes_Items = class({})

function Kudes_Items:GetIntrinsicModifierName()
    return "modifier_Kudes_Items"
end

function modifier_Kudes_Items:IsPurgable()
	return false
end

function modifier_Kudes_Items:OnCreated()
    if not IsServer() then return end
	self:StartIntervalThink(0.1) 
end

function modifier_Kudes_Items:OnIntervalThink()
	if not IsServer() then return end

    local item_stack = 
    {
        ["item_ward_observer"] = true,
        ["item_ward_sentry"] = true,
        ["item_ward_dispenser"] = true,
        ["item_tango"] = true,
        ["item_dust"] = true,
        ["item_clarity"] = true,
        ["item_flask"] = true,
        ["item_bond"] = true,
        ["item_burger_sobolev"] = true,
        ["item_burger_oblomoff"] = true,
        ["item_burger_larin"] = true
    }

	local gold = self:GetAbility():GetSpecialValueFor( "gold" ) 
    local price = 0

    for i = 0, 5 do 
        local item = self:GetCaster():GetItemInSlot(i)
        if item then
            local item_price = item:GetCost()

            if item_stack[item:GetName()] then
                item_price = 0
            end

            price = price + item_price
       	end        
    end

	local stack = price / gold

    self:SetStackCount( stack )

    self:GetCaster():CalculateStatBonus(true)	
end

function modifier_Kudes_Items:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

function modifier_Kudes_Items:GetModifierBonusStats_Strength ( params )
	return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor( "attribute" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_8"))
end

function modifier_Kudes_Items:GetModifierBonusStats_Agility ( params )
	return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor( "attribute" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_8"))
end

function modifier_Kudes_Items:GetModifierBonusStats_Intellect ( params )
	return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor( "attribute" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_8"))
end