LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_sonic_dash", "abilities/heroes/sonic.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

sonic_dash = class({})

function sonic_dash:GetCooldown(level)
    return (self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_1")) / ( self:GetCaster():GetCooldownReduction())
end

function sonic_dash:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
    local point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * self:GetSpecialValueFor("range")
    local speed = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), false) + self:GetSpecialValueFor("bonus_movespeed_dash")

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sonic_dash", { x = point.x, y = point.y, z = point.z, speed = speed, })
    local vDirection = point - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()

    self:GetCaster():EmitSound("sonic_one")

    local flag = 0

    if self:GetCaster():HasShard() then
        if RollPercentage(self:GetSpecialValueFor("shard_chance")) then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end
    end

    local particle = "particles/sonic/one_skill.vpcf"

    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        particle = "particles/sonic_arcana/one_skill.vpcf"
    end

    local info = 
    {
        EffectName = particle,
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(), 
        fStartRadius = 100,
        fEndRadius = 100,
        vVelocity = vDirection * (speed - 200),
        fDistance = #(point - self:GetCaster():GetOrigin()),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = flag,
    }

    ProjectileManager:CreateLinearProjectile( info )
end

function sonic_dash:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if hTarget then 
        local damage_speed = self:GetSpecialValueFor("damage_from_movespeed") / 100
        local duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_5")
        local damage = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), false) * damage_speed
        ApplyDamage({victim = hTarget, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = duration * ( 1 - hTarget:GetStatusResistance())})
    end
end 

modifier_sonic_dash = class({})

function modifier_sonic_dash:IsPurgable() return false end
function modifier_sonic_dash:IsHidden() return true end
function modifier_sonic_dash:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_sonic_dash:IgnoreTenacity() return true end
function modifier_sonic_dash:IsMotionController() return true end
function modifier_sonic_dash:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_sonic_dash:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
end

function modifier_sonic_dash:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local distance = (caster:GetAbsOrigin() - position):Length2D()

        self.velocity = params.speed
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_sonic_dash:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
            self:Destroy()
        end
        return nil
    end
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, false)
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_sonic_dash:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
                self:Destroy()
            end
        end
    end
end

function modifier_sonic_dash:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
end

LinkLuaModifier( "modifier_sonic_crash_generic_arc_lua", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_BOTH )

sonic_crash = class({})

function sonic_crash:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_2")
end

function sonic_crash:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage_from_movespeed = self:GetSpecialValueFor( "damage_from_movespeed" ) / 100
    local damage = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), false) * damage_from_movespeed
    local radius = self:GetSpecialValueFor( "radius" )
    local distance = 225
    local duration = 0.4
    local height = 200

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)

    local arc = caster:AddNewModifier( caster, self, "modifier_sonic_crash_generic_arc_lua", { distance = distance, duration = duration, height = height, fix_duration = false, isForward = true, isStun = true } )

    arc:SetEndCallback(function()
        local enemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        local damageTable = { attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self, }

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
            self:PlayEffects4( enemy )
        end

        self:PlayEffects2(radius)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        Timers:CreateTimer(0.1, function()
            caster:FadeGesture(ACT_DOTA_CAST_ABILITY_6)
        end)
    end)

    self:PlayEffects1( arc )
end

function sonic_crash:PlayEffects1( modifier )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_tailthump_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    modifier:AddParticle( effect_cast, false, false, -1, false, false )
    self:GetCaster():EmitSound("Hero_Pangolier.TailThump.Cast")
end

function sonic_crash:PlayEffects2(radius)
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_tailthump.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        local effect_cast = ParticleManager:CreateParticle( "particles/sonic_arcana/thunder_clap.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 2, self:GetCaster():GetOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 4, self:GetCaster():GetOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 7, Vector(radius,radius,radius) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:GetCaster():EmitSound("Hero_Zuus.ArcLightning.Target")
    end
    
    self:GetCaster():EmitSound("Hero_Pangolier.TailThump")
end

function sonic_crash:PlayEffects3()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_tailthump_hero.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self:GetCaster():EmitSound("Hero_Pangolier.TailThump.Shield")
end

function sonic_crash:PlayEffects3()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_tailthump_hero.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
   self:GetCaster():EmitSound("Hero_Pangolier.TailThump.Shield")
end

function sonic_crash:PlayEffects4( target )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_tailthump_shield_impact.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_sonic_crash_generic_arc_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sonic_crash_generic_arc_lua:IsHidden()
    return true
end

function modifier_sonic_crash_generic_arc_lua:IsDebuff()
    return false
end

function modifier_sonic_crash_generic_arc_lua:IsStunDebuff()
    return false
end

function modifier_sonic_crash_generic_arc_lua:IsPurgable()
    return true
end

function modifier_sonic_crash_generic_arc_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sonic_crash_generic_arc_lua:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_sonic_crash_generic_arc_lua:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_sonic_crash_generic_arc_lua:OnRemoved()
end

function modifier_sonic_crash_generic_arc_lua:OnDestroy()
    if not IsServer() then return end

    -- preserve height
    local pos = self:GetParent():GetOrigin()

    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )

    -- preserve height if has end offset
    if self.end_offset~=0 then
        self:GetParent():SetOrigin( pos )
    end

    if self.endCallback then
        self.endCallback( self.interrupted )
    end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sonic_crash_generic_arc_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    if self:GetStackCount()>0 then
        table.insert( funcs, MODIFIER_PROPERTY_OVERRIDE_ANIMATION )
    end

    return funcs
end

function modifier_sonic_crash_generic_arc_lua:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end
function modifier_sonic_crash_generic_arc_lua:GetOverrideAnimation()
    return self:GetStackCount()
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_sonic_crash_generic_arc_lua:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = self.isStun or false,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_sonic_crash_generic_arc_lua:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    -- set relative position
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_sonic_crash_generic_arc_lua:UpdateVerticalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    local pos = me:GetOrigin()
    local time = self:GetElapsedTime()

    -- set relative position
    local height = pos.z
    local speed = self:GetVerticalSpeed( time )
    pos.z = height + speed * dt
    me:SetOrigin( pos )

    if not self.fix_duration then
        local ground = GetGroundHeight( pos, me ) + self.end_offset
        if pos.z <= ground then

            -- below ground, set height as ground then destroy
            pos.z = ground
            me:SetOrigin( pos )
            self:Destroy()
        end
    end
end

function modifier_sonic_crash_generic_arc_lua:OnHorizontalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_sonic_crash_generic_arc_lua:OnVerticalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

--------------------------------------------------------------------------------
-- Motion Helper
function modifier_sonic_crash_generic_arc_lua:SetJumpParameters( kv )
    self.parent = self:GetParent()

    -- load types
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

    -- load other types
    self.isStun = kv.isStun==1
    self.isRestricted = kv.isRestricted==1
    self.isForward = kv.isForward==1
    self.activity = kv.activity or 0
    self:SetStackCount( self.activity )

    -- load direction
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

    -- load horizontal data
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

    -- load vertical data
    self.height = kv.height or 0
    self.start_offset = kv.start_offset or 0
    self.end_offset = kv.end_offset or 0

    -- calculate height positions
    local pos_start = self.parent:GetOrigin()
    local pos_end = pos_start + self.direction * self.distance
    local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
    local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
    local height_max

    -- determine jumping height if not fixed
    if not self.fix_height then
    
        -- ideal height is proportional to max distance
        self.height = math.min( self.height, self.distance/4 )
    end

    -- determine height max
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

    -- set duration
    if not self.fix_duration then
        self:SetDuration( -1, false )
    else
        self:SetDuration( self.duration, true )
    end

    -- calculate arc
    self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_sonic_crash_generic_arc_lua:Jump()
    -- apply horizontal motion
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end

    -- apply vertical motion
    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end
end

function modifier_sonic_crash_generic_arc_lua:InitVerticalArc( height_start, height_max, height_end, duration )
    local height_end = height_end - height_start
    local height_max = height_max - height_start

    -- fail-safe1: height_max cannot be smaller than height delta
    if height_max<height_end then
        height_max = height_end+0.01
    end

    -- fail-safe2: height-max must be positive
    if height_max<=0 then
        height_max = 0.01
    end

    -- math magic
    local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
    self.const1 = 4*height_max*duration_end/duration
    self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_sonic_crash_generic_arc_lua:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_sonic_crash_generic_arc_lua:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

--------------------------------------------------------------------------------
-- Helper
function modifier_sonic_crash_generic_arc_lua:SetEndCallback( func )
    self.endCallback = func
end

LinkLuaModifier( "modifier_sonic_gottagofast", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE )

sonic_gottagofast = class({})

function sonic_gottagofast:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_3")
end

function sonic_gottagofast:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("sonic_gotta")
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sonic_gottagofast", {duration = duration})
end

modifier_sonic_gottagofast = class({})

function modifier_sonic_gottagofast:IsPurgable() return false end

function modifier_sonic_gottagofast:OnCreated()
    if not IsServer() then return end

    local particle = "particles/sonic/sonic_gotta.vpcf"
    local particle_2 = "particles/sonic/sonic_gotta_ambient.vpcf"

    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        particle = "particles/sonic_arcana/sonic_gotta.vpcf"
        particle_2 = "particles/sonic_arcana/sonic_gotta_ambient.vpcf"
    end

    local particle = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(particle, false, false, -1, false, false)

    local particle_ambient = ParticleManager:CreateParticle(particle_2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particle_ambient, false, false, -1, false, false)
end

function modifier_sonic_gottagofast:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function modifier_sonic_gottagofast:GetModifierMoveSpeedBonus_Constant()
    if self:GetCaster():HasTalent("special_bonus_birzha_sonic_4") then
        return self:GetAbility():GetSpecialValueFor("bonus_movespeed") * self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_4")
    end
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_sonic_gottagofast:CheckState()
    if not self:GetCaster():HasTalent("special_bonus_birzha_sonic_8") then return end
    
    local state = 
    {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }

    return state
end

LinkLuaModifier("modifier_sonic_passive", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)

sonic_passive = class({})

function TangoCastFilterResult(ability, target)
    if not IsServer() then return end    

    if target:IsWard() then
        return UF_SUCCESS
    else
        return UF_FAIL_CUSTOM
    end

    local unitFilter = UnitFilter(target, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), ability:GetCaster():GetTeamNumber())
    return unitFilter
end

function sonic_passive:GetCustomCastErrorTarget(target)    
    return CastErrorTarget(self, target)
end

function CastErrorTarget(self, target)
    if not target:IsWard() then
        return "#sonic_no_ward"
    end
end

function sonic_passive:CastFilterResultTarget(target)    
    return TangoCastFilterResult(self, target)
end

function sonic_passive:GetIntrinsicModifierName()
    return "modifier_sonic_passive"
end

function sonic_passive:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:IsWard() then
        self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
    end
end

modifier_sonic_passive = class({})

function modifier_sonic_passive:IsHidden() return true end
function modifier_sonic_passive:IsPurgable() return false end

function modifier_sonic_passive:CheckState()
local state =
    {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true,
    }
    return state
end


function modifier_sonic_passive:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

    return decFuncs
end

function modifier_sonic_passive:GetModifierTurnRate_Percentage()
    return 1000
end

LinkLuaModifier("modifier_sonic_steal_speed", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_steal_speed_enemy", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_steal_speed_buff", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_steal_speed_debuff", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)

sonic_steal_speed = class({})

function sonic_steal_speed:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_sonic_steal_speed"
end

modifier_sonic_steal_speed = class({})

function modifier_sonic_steal_speed:IsHidden() return self:GetStackCount() == 0 end
function modifier_sonic_steal_speed:IsPurgable() return false end

function modifier_sonic_steal_speed:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
    if not IsServer() then return end
    self.maximum_stack_current = 0
    self.maximum_stack = self:GetAbility():GetSpecialValueFor("maximum_charges")
    self.duration = self:GetAbility():GetSpecialValueFor("duration")
    self:StartIntervalThink(FrameTime())
end

function modifier_sonic_steal_speed:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }

    return decFuncs
end

function modifier_sonic_steal_speed:OnIntervalThink()
    if not IsServer() then return end
    local modifiers = #self:GetParent():FindAllModifiersByName("modifier_sonic_steal_speed_buff") + self.maximum_stack_current
    if modifiers > self.maximum_stack then
        modifiers = self.maximum_stack
    end
    self:SetStackCount(modifiers)
end

function modifier_sonic_steal_speed:OnTakeDamage(params)
    if not IsServer() then return end

    if self:GetStackCount() >= self.maximum_stack then return end

    if params.attacker == self:GetParent() then
        if params.unit:IsMagicImmune() then return end
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sonic_steal_speed_buff", {duration = self.duration * (1 - params.unit:GetStatusResistance())})
        params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sonic_steal_speed_debuff", {duration = self.duration * (1 - params.unit:GetStatusResistance())})
        params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sonic_steal_speed_enemy", {duration = self.duration * (1 - params.unit:GetStatusResistance())})
        if self:GetCaster():HasTalent("special_bonus_birzha_sonic_6") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sonic_steal_speed_buff", {duration = self.duration * (1 - params.unit:GetStatusResistance())})
            params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sonic_steal_speed_debuff", {duration = self.duration * (1 - params.unit:GetStatusResistance())})
        end
    end
end

function modifier_sonic_steal_speed:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount() * self.movespeed
end

function modifier_sonic_steal_speed:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        self.maximum_stack_current = self.maximum_stack_current + 1
    end
end

modifier_sonic_steal_speed_buff = class({})
function modifier_sonic_steal_speed_buff:IsHidden() return true end
function modifier_sonic_steal_speed_buff:IsPurgable() return false end
function modifier_sonic_steal_speed_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_sonic_steal_speed_debuff = class({})
function modifier_sonic_steal_speed_debuff:IsHidden() return true end
function modifier_sonic_steal_speed_debuff:IsPurgable() return true end
function modifier_sonic_steal_speed_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_sonic_steal_speed_enemy = class({})

function modifier_sonic_steal_speed_enemy:IsHidden() return false end
function modifier_sonic_steal_speed_enemy:IsPurgable() return true end

function modifier_sonic_steal_speed_enemy:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed") * -1
    if not IsServer() then return end
    self.maximum_stack = self:GetAbility():GetSpecialValueFor("maximum_charges")
    self:StartIntervalThink(FrameTime())
end

function modifier_sonic_steal_speed_enemy:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }

    return decFuncs
end

function modifier_sonic_steal_speed_enemy:OnIntervalThink()
    if not IsServer() then return end
    local modifiers = #self:GetParent():FindAllModifiersByName("modifier_sonic_steal_speed_debuff")
    if modifiers > self.maximum_stack then
        modifiers = self.maximum_stack
    end
    self:SetStackCount(modifiers)
    if modifiers <= 0 then
        self:Destroy() 
    end
end

function modifier_sonic_steal_speed_enemy:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount() * self.movespeed
end



LinkLuaModifier("modifier_sonic_fast_sound", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_fast_sound_active", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_fast_sound_active_scepter", "abilities/heroes/sonic", LUA_MODIFIER_MOTION_BOTH)

sonic_fast_sound = class({})

function sonic_fast_sound:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
    if self:GetCaster():HasScepter() then
        behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return behavior
end

function sonic_fast_sound:OnSpellStart()
    if not IsServer() then return end
    self.target = self:GetCursorTarget()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sonic_fast_sound_active_scepter", {duration = self:GetSpecialValueFor("scepter_duration")})
end

function sonic_fast_sound:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
end

function sonic_fast_sound:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("manacost_scepter")
    end
end

function sonic_fast_sound:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_sonic_fast_sound"
end

modifier_sonic_fast_sound_active_scepter = class({})

function modifier_sonic_fast_sound_active_scepter:IsPurgable() return false end
function modifier_sonic_fast_sound_active_scepter:IsHidden() return true end

function modifier_sonic_fast_sound_active_scepter:OnCreated()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not IsServer() then return end
    Timers:CreateTimer(0, function()
        if self:GetParent():HasModifier("modifier_sonic_arcana") then
            self:GetCaster():SetMaterialGroup("arcana")
        end
    end)
    self.target = self:GetAbility().target
    self.targets = self:GetAbility():GetSpecialValueFor("max_jumps") - 1
    self.damage = self:GetAbility():GetSpecialValueFor( "active_damage" )
    self.targets_scepter = {}

    local particle = "particles/sonic/sonic_gotta.vpcf"

    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        particle = "particles/sonic_arcana/sonic_gotta.vpcf"
    end

    local particle = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())
    if self:ApplyHorizontalMotionController() == false then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_sonic_fast_sound_active_scepter:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local angles = parent:GetAngles()
    if not IsServer() then return end
    local vector_distance = parent:GetAbsOrigin() - self.target:GetAbsOrigin()
    local distance = (vector_distance):Length2D()

    if distance <= 75 then
        self:TakeDamage()
        local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
        local targets = {}

        for id, unit in pairs(units) do
            if self.targets_scepter[unit:entindex()] == nil then
                table.insert(targets, unit)
            end
        end

        if #targets <= 0 then
            if not self:IsNull() then
                self:Destroy()
            end
            return
        end

        if self.targets <= 0 then
            if not self:IsNull() then
                self:Destroy()
            end
            return
        end

        self.target = targets[1]
    end
end

function modifier_sonic_fast_sound_active_scepter:TakeDamage()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Pangolier.TailThump")
    local vector_distance = parent:GetAbsOrigin() - self.target:GetAbsOrigin()
    local distance = (vector_distance):Length2D()
    local damage_from_movespeed = self.damage / 100
    local dmg = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), false) * damage_from_movespeed
    if distance <= 75 then
        self.targets_scepter[self.target:entindex()] = self.target
        ApplyDamage({victim = self.target, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
    end
    self.damage = self.damage - 15
end

function modifier_sonic_fast_sound_active_scepter:OnDestroy()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers( true )
end

function modifier_sonic_fast_sound_active_scepter:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
    return funcs
end

function modifier_sonic_fast_sound_active_scepter:UpdateHorizontalMotion( me, dt )
    local origin = self:GetParent():GetOrigin()
    if not self.target:IsAlive() then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    local direction = self.target:GetOrigin() - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()

    local target = origin + direction * 1500 * dt
    self:GetParent():SetOrigin( target )
    self:GetParent():FaceTowards( self.target:GetOrigin() )
end

function modifier_sonic_fast_sound_active_scepter:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_sonic_fast_sound_active_scepter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }

    return funcs
end

function modifier_sonic_fast_sound_active_scepter:GetVisualZDelta()
    return 100
end

function modifier_sonic_fast_sound_active_scepter:GetModifierModelChange()
    return "models/sonic/sonic_ball.vmdl"
end

function modifier_sonic_fast_sound_active_scepter:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_sonic_fast_sound_active_scepter:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_sonic_fast_sound_active_scepter:GetAbsoluteNoDamagePure()
    return 1
end

modifier_sonic_fast_sound = class({})

function modifier_sonic_fast_sound:IsHidden() return true end
function modifier_sonic_fast_sound:IsPurgable() return false end

function modifier_sonic_fast_sound:OnCreated()
    if not IsServer() then return end
    self.prevLoc = self:GetParent():GetAbsOrigin()
    self.move_duration = 0
    self.duration_move = self:GetAbility():GetSpecialValueFor("duration_move")
    self:StartIntervalThink(0.1)
end

function modifier_sonic_fast_sound:OnIntervalThink()
    if not IsServer() then return end

    local move = CalculateDistance(self.prevLoc, self:GetParent())

    if move > 0 then
        self.move_duration = self.move_duration + 0.1
    else
        self.move_duration = 0
    end

    self.prevLoc = self:GetParent():GetAbsOrigin()

    if self.move_duration == self.duration_move - 0.3 then
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_6)
    end

    if self.move_duration >= self.duration_move then
        if not self:GetParent():HasModifier("modifier_sonic_fast_sound_active") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sonic_fast_sound_active", {})
        end
    else
        self:GetParent():RemoveModifierByName("modifier_sonic_fast_sound_active")
    end
end

function modifier_sonic_fast_sound:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_sonic_fast_sound:GetModifierMoveSpeed_Max( params )
    return self:GetAbility():GetSpecialValueFor("movespeed_limit") + self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_7")
end

function modifier_sonic_fast_sound:GetModifierMoveSpeed_Limit( params )
    return self:GetAbility():GetSpecialValueFor("movespeed_limit") + self:GetCaster():FindTalentValue("special_bonus_birzha_sonic_7")
end

function modifier_sonic_fast_sound:GetModifierIgnoreMovespeedLimit( params )
    return 1
end

modifier_sonic_fast_sound_active = class({})

function modifier_sonic_fast_sound_active:IsPurgable() return false end
function modifier_sonic_fast_sound_active:IsHidden() return true end

function modifier_sonic_fast_sound_active:OnCreated()
    if not IsServer() then return end
    Timers:CreateTimer(0, function()
        if self:GetParent():HasModifier("modifier_sonic_arcana") then
            self:GetCaster():SetMaterialGroup("arcana")
        end
    end)

    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( effect_cast, 60, Vector(255,255,0) )
        ParticleManager:SetParticleControl( effect_cast, 61, Vector(1,1,1) )
        self:AddParticle(effect_cast, false, false, -1, false, false)
    end

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage_units = {}
    self:StartIntervalThink(0.1)
    self:GetParent():EmitSound("Hero_Pangolier.Gyroshell.Loop")
end

function modifier_sonic_fast_sound_active:OnIntervalThink()
    if not IsServer() then return end
    for id, damage_unit in pairs(self.damage_units) do
        if CalculateDistance(self:GetParent():GetAbsOrigin(), damage_unit) >= self.radius then
            table.remove(self.damage_units, id)
        end
    end
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    local damageTable = { attacker = self:GetParent(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility(), }
    local damage_from_movespeed = self:GetAbility():GetSpecialValueFor( "damage" ) / 100
    self.damage = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), false) * damage_from_movespeed

    for _,enemy in pairs(enemies) do
        local damage_true = true
        for id, damage_unit in pairs(self.damage_units) do
            if enemy == damage_unit then
                damage_true = false
            end
        end
        if damage_true then
            table.insert(self.damage_units, enemy)
            damageTable.victim = enemy
            ApplyDamage(damageTable)
            enemy:EmitSound("Hero_Pangolier.Gyroshell.Carom")
            local particle = "particles/sonic/sound_damage.vpcf"

            if self:GetCaster():HasModifier("modifier_sonic_arcana") then
                particle = "particles/sonic_arcana/sound_damage.vpcf"
            end

            local particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControl(particle, 0, enemy:GetAbsOrigin())
        end
    end
end

function modifier_sonic_fast_sound_active:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("Hero_Pangolier.Gyroshell.Loop", self:GetParent())
end

function modifier_sonic_fast_sound_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_sonic_fast_sound_active:GetModifierModelChange()
    return "models/sonic/sonic_ball.vmdl"
end

function sonic_dash:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        return "sonic/dash_new"
    end
    return "sonic/dash"
end
function sonic_crash:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        return "sonic/crash_new"
    end
    return "sonic/crash"
end
function sonic_gottagofast:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        return "sonic/gottagofast_new"
    end
    return "sonic/gottagofast"
end
function sonic_steal_speed:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        return "sonic/steal_speed_new"
    end
    return "sonic/steal_speed"
end
function sonic_passive:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        return "sonic/passive_new"
    end
    return "sonic/passive"
end
function sonic_fast_sound:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_sonic_arcana") then
        return "sonic/fast_sound_new"
    end
    return "sonic/fast_sound"
end