LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dwayne_throw_stone", "abilities/heroes/dwayne.lua", LUA_MODIFIER_MOTION_NONE )

dwayne_throw_stone = class({})

function dwayne_throw_stone:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dwayne_4")
end

function dwayne_throw_stone:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function dwayne_throw_stone:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function dwayne_throw_stone:GetChannelTime()
    return self.BaseClass.GetChannelTime(self)
end

function dwayne_throw_stone:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetChannelTime()
    self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dwayne_throw_stone",  { duration = duration, target = target:entindex() } )
end

function dwayne_throw_stone:OnChannelFinish( bInterrupted )
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:Destroy()
    end
end

modifier_dwayne_throw_stone = class({})

function modifier_dwayne_throw_stone:IsHidden()
    return true
end

function modifier_dwayne_throw_stone:IsDebuff()
    return false
end

function modifier_dwayne_throw_stone:IsStunDebuff()
    return false
end

function modifier_dwayne_throw_stone:IsPurgable()
    return false
end

function modifier_dwayne_throw_stone:OnCreated( kv )
    if not IsServer() then return end
    self.max_count = self:GetAbility():GetSpecialValueFor( "max_count" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dwayne_1")
    self.min_count = self:GetAbility():GetSpecialValueFor( "min_count" )
    self.target =   EntIndexToHScript(kv.target)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
end

function modifier_dwayne_throw_stone:OnDestroy()
    if not IsServer() then return end
    if not self.target:IsAlive() then return end

    local pct = math.min( self:GetElapsedTime(), self:GetAbility():GetChannelTime() ) / self:GetAbility():GetChannelTime()

    local count = self.max_count * pct 

    if count < 1 then
        count = self.min_count
    end

    local info = {
        EffectName = "particles/dwayne/attack_proj.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 1950,
        Source = self:GetCaster(),
        Target = self.target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        ExtraData = {},
    }
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)

    for i=1,count do
        info.iMoveSpeed = 1950 - (i * 150)
        info.ExtraData = { count = i, }
        ProjectileManager:CreateTrackingProjectile( info )
        self:GetCaster():EmitSound("Brewmaster_Earth.Boulder.Cast")
    end
end

function dwayne_throw_stone:OnProjectileHit_ExtraData( target, location, ExtraData )
    if not IsServer() then return end
    if target ~= nil then
        if ExtraData.count == 1 then
            if target:TriggerSpellAbsorb( self ) then
                return
            end
        end
        local stun_duration = self:GetSpecialValueFor( "stun_duration" )
        local stun_damage = self:GetSpecialValueFor( "damage" )
        if self:GetCaster():HasTalent("special_bonus_birzha_dwayne_2") then
            stun_damage = stun_damage + ( self:GetCaster():GetStrength() * self:GetCaster():FindTalentValue("special_bonus_birzha_dwayne_2") )
        end
        local chance = self:GetSpecialValueFor( "chance" )
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = stun_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        if not target:IsMagicImmune() or self:GetCaster():HasTalent("special_bonus_birzha_dwayne_3") then
            ApplyDamage( damage )
        end
        if not target:IsMagicImmune() then
            if RollPercentage(chance) then
                target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration})
            end
        end
        target:EmitSound("Brewmaster_Earth.Boulder.Target")
    end
end

function modifier_dwayne_throw_stone:GetActivityTranslationModifiers()
    return "ultimate_scepter"
end

function modifier_dwayne_throw_stone:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
    }

    return decFuncs
end






dwayne_stone_strength = class({})

LinkLuaModifier( "modifier_dwayne_stone_strength", "abilities/heroes/dwayne.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_dwayne_stone_strength_arc_lua", "abilities/heroes/dwayne.lua", LUA_MODIFIER_MOTION_BOTH )

function dwayne_stone_strength:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function dwayne_stone_strength:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then return end

    target:AddNewModifier(caster, self, "modifier_dwayne_stone_strength", {} )


    local vPos = self:GetCursorPosition()
    local delay = 0.03
    local casterPos = caster:GetAbsOrigin()
    local distance = (vPos - casterPos):Length2D()
    self.direction = (vPos - casterPos):Normalized()
    local velocity = distance / delay * self.direction
    local ticks = 1 / 0.3
    velocity.z = 0

    local info = {
        EffectName = "particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf",
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        fStartRadius = 0,
        fEndRadius = 0,
        vVelocity = velocity,
        fDistance = distance,
        Source = self:GetCaster(),
        iUnitTargetTeam = 0,
        iUnitTargetType = 0,
        ExtraData = {ticks = ticks, tick_count = 5}
    }
    ProjectileManager:CreateLinearProjectile( info )
    EmitSoundOnLocationWithCaster(vPos, "Ability.Avalanche", caster)
end

function dwayne_stone_strength:OnProjectileHit_ExtraData(hTarget, vLocation, extradata)
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("stun_duration")
    local radius = self:GetSpecialValueFor("radius")
    local interval = 0.3
    local avalanche = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(avalanche, 0, vLocation)
    ParticleManager:SetParticleControl(avalanche, 1, Vector(radius, 1, radius))
    ParticleManager:SetParticleControlForward( avalanche, 0, self.direction or self:GetCaster():GetForwardVector())
    local offset = 0
    local ticks = extradata.ticks
    local hitLoc = vLocation
    Timers:CreateTimer(function()
        local damage = self:GetSpecialValueFor("avalanche_damage") / 5
        local enemies_tick = FindUnitsInRadius(caster:GetTeamNumber(), hitLoc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for _,enemy in pairs(enemies_tick) do
            ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
            
            if enemy:IsAlive() then
                enemy:AddNewModifier(caster, self, "modifier_birzha_stunned", {duration = duration})
            end
        end
        hitLoc = hitLoc + offset / ticks
        extradata.tick_count = extradata.tick_count - 1
        if extradata.tick_count > 0 then
            return interval
        else
            if avalanche then
                ParticleManager:DestroyParticle(avalanche, false)
                ParticleManager:ReleaseParticleIndex(avalanche)
            end
        end
    end)
end

modifier_dwayne_stone_strength = class({})

function modifier_dwayne_stone_strength:IsHidden()
    return true
end

function modifier_dwayne_stone_strength:IsStunDebuff()
    return true
end

function modifier_dwayne_stone_strength:IsPurgable()
    return true
end

function modifier_dwayne_stone_strength:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.damage = self:GetAbility():GetSpecialValueFor( "toss_damage" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor( "duration" )
    if self:GetCaster():HasShard() then
        duration = duration + 2
    end
    local height = 400
    self.target = self.parent

    -- add arc modifier for vertical only
    self.arc = self.parent:AddNewModifier(
        self.caster, -- player source
        self:GetAbility(), -- ability source
        "modifier_dwayne_stone_strength_arc_lua", -- modifier name
        {
            duration = duration,
            distance = 0,
            height = height,
            -- fix_end = true,
            fix_duration = false,
            isStun = true,
            activity = ACT_DOTA_FLAIL,
        } -- kv
    )
    self.arc:SetEndCallback(function( interrupted )
        if not self:IsNull() then
            self:Destroy()
        end
        if interrupted then return end

        local damageTable = {
            victim = self.parent,
            attacker = self.caster,
            damage = self.damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility(), --Optional.
        }
        ApplyDamage(damageTable)
        EmitSoundOn( "Ability.TossImpact", self.parent )
    end)

    local origin = self.target:GetOrigin()
    local direction = origin-self.parent:GetOrigin()
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()

    -- init speed
    self.distance = distance
    if self.distance==0 then self.distance = 1 end
    self.duration = duration
    self.speed = distance/duration
    self.accel = 100
    self.max_speed = 3000

    -- apply motion
    if not self:ApplyHorizontalMotionController() then
        if not self:IsNull() then
            self:Destroy()
        end
    end

    -- emit sound
    local sound_cast = "Ability.TossThrow"
    local sound_target = "Hero_Tiny.Toss.Target"
    EmitSoundOn( sound_cast, self.caster )
    EmitSoundOn( sound_target, self.parent )
end

function modifier_dwayne_stone_strength:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_dwayne_stone_strength:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_dwayne_stone_strength:UpdateHorizontalMotion( me, dt )
    local target = self.target:GetOrigin()
    local parent = self.parent:GetOrigin()

    -- get current states
    local duration = self:GetElapsedTime()
    local direction = target-parent
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()

    -- change speed if target farther/closer
    local original_distance = duration/self.duration * self.distance
    local expected_speed
    if self:GetElapsedTime()>=self.duration then
        expected_speed = self.speed
    else
        expected_speed = distance/(self.duration-self:GetElapsedTime())
    end

    -- accel/deccel speed
    if self.speed<expected_speed then
        self.speed = math.min(self.speed + self.accel, self.max_speed)
    elseif self.speed>expected_speed then
        self.speed = math.max(self.speed - self.accel, 0)
    end

    -- set relative position
    local pos = parent + direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_dwayne_stone_strength:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_dwayne_stone_strength:GetEffectName()
    return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_dwayne_stone_strength:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_dwayne_stone_strength_arc_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dwayne_stone_strength_arc_lua:IsHidden()
    return true
end

function modifier_dwayne_stone_strength_arc_lua:IsDebuff()
    return false
end

function modifier_dwayne_stone_strength_arc_lua:IsStunDebuff()
    return false
end

function modifier_dwayne_stone_strength_arc_lua:IsPurgable()
    return true
end

function modifier_dwayne_stone_strength_arc_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dwayne_stone_strength_arc_lua:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_dwayne_stone_strength_arc_lua:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_dwayne_stone_strength_arc_lua:OnRemoved()
end

function modifier_dwayne_stone_strength_arc_lua:OnDestroy()
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
function modifier_dwayne_stone_strength_arc_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    if self:GetStackCount()>0 then
        table.insert( funcs, MODIFIER_PROPERTY_OVERRIDE_ANIMATION )
    end

    return funcs
end

function modifier_dwayne_stone_strength_arc_lua:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end
function modifier_dwayne_stone_strength_arc_lua:GetOverrideAnimation()
    return self:GetStackCount()
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_dwayne_stone_strength_arc_lua:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = self.isStun or false,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_dwayne_stone_strength_arc_lua:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    -- set relative position
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_dwayne_stone_strength_arc_lua:UpdateVerticalMotion( me, dt )
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
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_dwayne_stone_strength_arc_lua:OnHorizontalMotionInterrupted()
    self.interrupted = true
    if not self:IsNull() then
            self:Destroy()
        end
end

function modifier_dwayne_stone_strength_arc_lua:OnVerticalMotionInterrupted()
    self.interrupted = true
    if not self:IsNull() then
        self:Destroy()
    end
end

--------------------------------------------------------------------------------
-- Motion Helper
function modifier_dwayne_stone_strength_arc_lua:SetJumpParameters( kv )
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

function modifier_dwayne_stone_strength_arc_lua:Jump()
    -- apply horizontal motion
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end

    -- apply vertical motion
    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_dwayne_stone_strength_arc_lua:InitVerticalArc( height_start, height_max, height_end, duration )
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

function modifier_dwayne_stone_strength_arc_lua:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_dwayne_stone_strength_arc_lua:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

--------------------------------------------------------------------------------
-- Helper
function modifier_dwayne_stone_strength_arc_lua:SetEndCallback( func )
    self.endCallback = func
end




LinkLuaModifier( "modifier_dwayne_fight_of_death", "abilities/heroes/dwayne.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

dwayne_fight_of_death = class({})



function dwayne_fight_of_death:OnInventoryContentsChanged()
    print(self:GetCaster():GetAbilityByIndex(5):GetAbilityName())
    if self:GetCaster():HasScepter() then
        if self:GetCaster():GetAbilityByIndex(5) then
            if self:GetCaster():GetAbilityByIndex(5):GetAbilityName() == "dwayne_fight_of_death" then
                self:GetCaster():SwapAbilities("dwayne_fight_of_death", "dwayne_fight_of_death_charge", false, true)
            end
        end
    else
        if self:GetCaster():GetAbilityByIndex(5) then
            if self:GetCaster():GetAbilityByIndex(5):GetAbilityName() == "dwayne_fight_of_death_charge" then
                self:GetCaster():SwapAbilities("dwayne_fight_of_death_charge", "dwayne_fight_of_death", false, true)
            end
        end
    end
end

function dwayne_fight_of_death:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_birzha_dwayne_6") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function dwayne_fight_of_death:OnSpellStart()
    if not IsServer() then return end


    local duration = self:GetSpecialValueFor("duration")

    local charge_ability = self:GetCaster():FindAbilityByName("dwayne_fight_of_death_charge")

    if self:GetAbilityName() == "dwayne_fight_of_death_charge" then
        charge_ability = self:GetCaster():FindAbilityByName("dwayne_fight_of_death")
    end

    if charge_ability then
        local charges = charge_ability:GetCurrentAbilityCharges()
        if charges > 0 then
            charge_ability:SetCurrentAbilityCharges(charges - 1)
        end 
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_dwayne_6") then
        local enemies_tick = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for _,enemy in pairs(enemies_tick) do
            self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dwayne_fight_of_death",  { duration = duration, target = enemy:entindex(), } )
        end
        return
    end

    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dwayne_fight_of_death",  { duration = duration, target = target:entindex(), } )
end

modifier_dwayne_fight_of_death = class({})

function modifier_dwayne_fight_of_death:IsHidden()
    return false
end

function modifier_dwayne_fight_of_death:IsDebuff()
    return false
end

function modifier_dwayne_fight_of_death:IsPurgable()
    return false
end

function modifier_dwayne_fight_of_death:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dwayne_fight_of_death:OnCreated( kv )
    if not IsServer() then return end
    self.target = EntIndexToHScript( kv.target )
    self.count = self:GetAbility():GetSpecialValueFor("stoun_count")
    self.kills = 0
    self.info = {
        EffectName = "particles/dwayne/attack_proj.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 1950,
        Source = self:GetCaster(),
        Target = self.target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        ExtraData = {},
    }
    self:StartIntervalThink( self:GetAbility():GetSpecialValueFor("interval") )
    self:OnIntervalThink()
end

function modifier_dwayne_fight_of_death:OnIntervalThink()
    if not IsServer() then return end
    local distance = (self.target:GetOrigin()-self:GetParent():GetOrigin()):Length2D()
    local range = self:GetAbility():GetSpecialValueFor( "range" )

    self.inRange = distance<=range

    local ability_one = self:GetParent():FindAbilityByName("dwayne_throw_stone")
    if ability_one and ability_one:GetLevel() < 1 then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    if self.inRange and self:GetParent():CanEntityBeSeenByMyTeam(self.target) and self.target:IsAlive() then
        self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)
        local stone_ability = self:GetParent():FindAbilityByName("dwayne_throw_stone")
        if stone_ability and stone_ability:GetLevel() > 0 then
            local info = {
                EffectName = "particles/dwayne/attack_proj.vpcf",
                Ability = stone_ability,
                iMoveSpeed = 1950,
                Source = self:GetCaster(),
                Target = self.target,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
                ExtraData = {},
            }
            for i=1,self:GetAbility():GetSpecialValueFor("stoun_count") do
                info.iMoveSpeed = 1950 - (i * 150)
                info.ExtraData = { count = i, }
                ProjectileManager:CreateTrackingProjectile( info )
                self:GetCaster():EmitSound("Brewmaster_Earth.Boulder.Cast")
            end
        end
    end
    if not self.target:IsAlive() then
        self.kills = self.kills + 1
        if self:GetCaster():HasTalent("special_bonus_birzha_dwayne_7") then
            print(self.kills)
            if self.kills >= 2 then
                print("dada")
                self:GetAbility():RefreshCharges()
                self:GetAbility():EndCooldown()
                self.kills = 0
            end
        end
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_dwayne_fight_of_death:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }

    return funcs
end

function modifier_dwayne_fight_of_death:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self.target and params.attacker == self:GetParent() then
        self.kills = self.kills + 1
        if self:GetCaster():HasTalent("special_bonus_birzha_dwayne_7") then
            print(self.kills)
            if self.kills >= 2 then
                print("dada")
                self:GetAbility():RefreshCharges()
                self:GetAbility():EndCooldown()
                self.kills = 0
            end
        end
    end
end












dwayne_fight_of_death_charge = class({})

function dwayne_fight_of_death_charge:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_birzha_dwayne_6") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function dwayne_fight_of_death_charge:OnSpellStart()
    if not IsServer() then return end


    local duration = self:GetSpecialValueFor("duration")

    local charge_ability = self:GetCaster():FindAbilityByName("dwayne_fight_of_death_charge")

    if self:GetAbilityName() == "dwayne_fight_of_death_charge" then
        charge_ability = self:GetCaster():FindAbilityByName("dwayne_fight_of_death")
    end

    if charge_ability then
        local charges = charge_ability:GetCurrentAbilityCharges()
        if charges > 0 then
            charge_ability:SetCurrentAbilityCharges(charges - 1)
        end 
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_dwayne_6") then
        local enemies_tick = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for _,enemy in pairs(enemies_tick) do
            self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dwayne_fight_of_death",  { duration = duration, target = enemy:entindex(), } )
        end
        return
    end

    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dwayne_fight_of_death",  { duration = duration, target = target:entindex(), } )
end


















LinkLuaModifier( "modifier_dwayne_stone_passive", "abilities/heroes/dwayne.lua", LUA_MODIFIER_MOTION_NONE )

dwayne_stone_passive = class({})

function dwayne_stone_passive:GetCooldown(level)
    return (self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dwayne_5")) / self:GetCaster():GetCooldownReduction()
end

function dwayne_stone_passive:GetIntrinsicModifierName()
    return "modifier_dwayne_stone_passive"
end

modifier_dwayne_stone_passive = class({})

function modifier_dwayne_stone_passive:IsHidden()
    return true
end

function modifier_dwayne_stone_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK,
    }

    return funcs
end

function modifier_dwayne_stone_passive:OnAttack( params )
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        if params.attacker:IsIllusion() then return end
        if params.target:IsOther() then return end
        if self:GetParent():PassivesDisabled() then return end
        local stone_ability = self:GetParent():FindAbilityByName("dwayne_throw_stone")
        if stone_ability and stone_ability:GetLevel() > 0 then
            if self:GetAbility():IsFullyCastable() then
                local info = {
                    EffectName = "particles/dwayne/attack_proj.vpcf",
                    Ability = stone_ability,
                    iMoveSpeed = 1950,
                    Source = self:GetCaster(),
                    Target = params.target,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
                    ExtraData = {},
                }
                for i=1,self:GetAbility():GetSpecialValueFor("stone_count") do
                    info.iMoveSpeed = 1950 - (i * 150)
                    info.ExtraData = { count = i, }
                    ProjectileManager:CreateTrackingProjectile( info )
                    self:GetCaster():EmitSound("Brewmaster_Earth.Boulder.Cast")
                end
                self:GetAbility():UseResources(false, false, true)
            end
        end
    end
end

function modifier_dwayne_stone_passive:OnAttackLanded( params )
    if not IsServer() then return end
    if params.target == self:GetParent() then
        if self:GetParent():IsIllusion() then return end
        if self:GetParent():PassivesDisabled() then return end
        local stone_ability = self:GetParent():FindAbilityByName("dwayne_throw_stone")
        if stone_ability and stone_ability:GetLevel() > 0 then
            if self:GetAbility():IsFullyCastable() then
                local info = {
                    EffectName = "particles/dwayne/attack_proj.vpcf",
                    Ability = stone_ability,
                    iMoveSpeed = 1950,
                    Source = self:GetCaster(),
                    Target = params.attacker,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
                    ExtraData = {},
                }
                self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
                self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)
                for i=1,self:GetAbility():GetSpecialValueFor("stone_count") do
                    info.iMoveSpeed = 1950 - (i * 150)
                    info.ExtraData = { count = i, }
                    ProjectileManager:CreateTrackingProjectile( info )
                    self:GetCaster():EmitSound("Brewmaster_Earth.Boulder.Cast")
                end
                self:GetAbility():UseResources(false, false, true)
            end
        end
    end
end