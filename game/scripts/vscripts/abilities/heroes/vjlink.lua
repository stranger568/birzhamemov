LinkLuaModifier( "modifier_vjlink_sputum", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_sputum = class({})

function Vjlink_sputum:Precache(context)
    local particle_list = 
    {
        "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
        "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
        "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf",
        "particles/vjlink_blood_trail.vpcf",
        "particles/units/heroes/hero_huskar/huskar_life_break.vpcf",
        "particles/vjlink_ground_particleground.vpcf",
        "particles/vjlink_leash.vpcf",
        "particles/status_fx/status_effect_huskar_lifebreak.vpcf",
        "particles/units/heroes/hero_huskar/huskar_life_break.vpcf",
        "particles/vjlink/1.vpcf",
        "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf",
        "particles/generic_gameplay/generic_lifesteal.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Vjlink_sputum:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vjlink_sputum:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vjlink_sputum:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return 950
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vjlink_sputum:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function Vjlink_sputum:OnSpellStart()
    if not IsServer() then return end

    if self:GetCaster():HasScepter() then
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, 950, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
        for _,enemy in pairs(enemies) do
            local info = {
                EffectName = "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
                Ability = self,
                iMoveSpeed = 1000,
                Source = self:GetCaster(),
                Target = enemy,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
            }
            ProjectileManager:CreateTrackingProjectile( info )
        end
        self:GetCaster():EmitSound("Hero_Bristleback.ViscousGoo.Cast")
        return
    end

    local target = self:GetCursorTarget()
    local info = {
        EffectName = "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
        Ability = self,
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("Hero_Bristleback.ViscousGoo.Cast")
end

function Vjlink_sputum:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
        if self:GetCaster():HasScepter() then
            if target ~= nil and ( not target:IsMagicImmune() ) then
                local duration = self:GetSpecialValueFor("duration")
                target:AddNewModifier( self:GetCaster(), self, "modifier_vjlink_sputum", { duration = duration * (1 - target:GetStatusResistance()) } )
                target:EmitSound("Hero_Bristleback.ViscousGoo.Target")
                return true
            end
        end
        if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
            local duration = self:GetSpecialValueFor("duration")
            target:AddNewModifier( self:GetCaster(), self, "modifier_vjlink_sputum", { duration = duration * (1 - target:GetStatusResistance()) } )
            target:EmitSound("Hero_Bristleback.ViscousGoo.Target")
        end
    return true
end

modifier_vjlink_sputum = class({})

function modifier_vjlink_sputum:IsPurgable() return true end

function modifier_vjlink_sputum:OnCreated( kv )
    self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
    self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )

    if IsServer() then
        self:SetStackCount(1)
    end
end

function modifier_vjlink_sputum:OnRefresh( kv )
    self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
    self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )
    local max_stack = self:GetAbility():GetSpecialValueFor( "stack_limit" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_2")

    if IsServer() then
        if self:GetStackCount()<max_stack then
            self:IncrementStackCount()
        end
    end
end

function modifier_vjlink_sputum:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_vjlink_sputum:GetModifierPhysicalArmorBonus()
    return self.armor_stack * self:GetStackCount()
end
function modifier_vjlink_sputum:GetModifierMoveSpeedBonus_Percentage()
    return  self.slow_stack * self:GetStackCount()
end

function modifier_vjlink_sputum:GetEffectName()
    return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end

function modifier_vjlink_sputum:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_python_active", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_python_active_no_target", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_python_debuff", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_python = class({})

function Vjlink_python:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vjlink_python:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vjlink_python:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_vjlink_5" )
end

function Vjlink_python:GetCastRange(location, target)
    local bonus = 0
    if self:GetCaster():HasShard() then
        bonus = 450
    end
    return self.BaseClass.GetCastRange(self, location, target) + bonus
end

function Vjlink_python:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_vjlink_6") then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function Vjlink_python:OnSpellStart()
    if not IsServer() then return end

    if self:GetCaster():HasTalent("special_bonus_birzha_vjlink_6") then
        self.target = self:GetCursorTarget()
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_python_active", {} )
    else
        if not self:GetCaster():HasModifier("modifier_python_active_no_target") then
            local distance = self:GetSpecialValueFor("pounce_distance")
            local speed = self:GetSpecialValueFor("pounce_speed")

            if self:GetCaster():HasShard() then
                distance = distance + 450
                speed = speed + 550
            end
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_python_active_no_target", {duration = distance / speed})
        end
    end

    self:GetCaster():EmitSound("krik_new")
end

-- NO TARGET

modifier_python_active_no_target = class({})

function modifier_python_active_no_target:IsHidden()      return true end
function modifier_python_active_no_target:IsPurgable()    return false end

function modifier_python_active_no_target:GetEffectName()
    return "particles/vjlink_blood_trail.vpcf"
end

function modifier_python_active_no_target:OnCreated()
    if not IsServer() then return end

    
    self.pounce_radius  = self:GetAbility():GetSpecialValueFor("pounce_radius")
    self.leash_duration = self:GetAbility():GetSpecialValueFor("duration")
    self.leash_radius   = self:GetAbility():GetSpecialValueFor("leash_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_1")
    local distance = self:GetAbility():GetSpecialValueFor("pounce_distance")
    local speed = self:GetAbility():GetSpecialValueFor("pounce_speed")

    if self:GetCaster():HasShard() then
        distance = distance + 450
        speed = speed + 550
    end

    self.pounce_speed   = speed
    self.duration       = distance / self.pounce_speed
    self.direction      = self:GetParent():GetForwardVector()

    self.redirection_commands = 
    {
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION]  = true,
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET]    = true,
        [DOTA_UNIT_ORDER_ATTACK_MOVE]       = true,
        [DOTA_UNIT_ORDER_ATTACK_TARGET]     = true,
        [DOTA_UNIT_ORDER_CAST_POSITION]     = true,
        [DOTA_UNIT_ORDER_CAST_TARGET]       = true,
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE]  = true,
    }

    self:GetAbility():SetActivated(false)

    self.vertical_velocity      = 4 * 125 / self.duration
    self.vertical_acceleration  = -(8 * 125) / (self.duration * self.duration)
    if self:ApplyVerticalMotionController() == false then 
        self:Destroy()
    end
    if self:ApplyHorizontalMotionController() == false then 
        self:Destroy()
    end
end

function modifier_python_active_no_target:OnDestroy()
    if not IsServer() then return end
    
    self:GetParent():RemoveHorizontalMotionController(self)
    self:GetParent():RemoveVerticalMotionController(self)

    if self:GetCaster():GetName() == "npc_dota_hero_slark" then
        self:GetCaster():FadeGesture(ACT_DOTA_SLARK_POUNCE)
    end

    self:GetAbility():SetActivated(true)

    GridNav:DestroyTreesAroundPoint( self:GetParent():GetAbsOrigin(), 100, true )
end

function modifier_python_active_no_target:UpdateHorizontalMotion(me, dt)
    if not IsServer() then return end
    for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.pounce_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)) do

        enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_python_debuff", { duration = self.leash_duration * (1 - enemy:GetStatusResistance()), leash_radius = self.leash_radius })
        
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
        ParticleManager:SetParticleControl( particle, 1, enemy:GetOrigin() )
        ParticleManager:ReleaseParticleIndex( particle )

        local damage = self:GetAbility():GetSpecialValueFor("pounce_from_health")
        damage = damage / 100

        local damageTable = { victim = enemy, attacker = self:GetCaster(), damage = damage * enemy:GetHealth(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() }
        ApplyDamage(damageTable)

        if self:GetCaster():HasTalent("special_bonus_birzha_vjlink_3") then
            self:GetCaster():PerformAttack(enemy, true, true, true, false, false, false, false)
        end

        enemy:EmitSound("Hero_Huskar.Life_Break.Impact")

        self:GetParent():MoveToTargetToAttack(enemy)
        self:Destroy()
        break
    end

    me:SetAbsOrigin( me:GetAbsOrigin() + self.pounce_speed * self.direction * dt )
end

function modifier_python_active_no_target:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_python_active_no_target:UpdateVerticalMotion(me, dt)
    if not IsServer() then return end
    me:SetAbsOrigin( me:GetAbsOrigin() + Vector(0, 0, self.vertical_velocity) * dt )
    self.vertical_velocity = self.vertical_velocity + (self.vertical_acceleration * dt)
end

function modifier_python_active_no_target:OnVerticalMotionInterrupted()
    self:Destroy()
end

function modifier_python_active_no_target:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true}
end

function modifier_python_active_no_target:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_EVENT_ON_ORDER
    }
end

function modifier_python_active_no_target:GetActivityTranslationModifiers()
    return "leash"
end

function modifier_python_active_no_target:GetOverrideAnimation()
    return ACT_DOTA_SLARK_POUNCE
end

function modifier_python_active_no_target:OnOrder(keys)
    if keys.unit == self:GetParent() then
        if self.redirection_commands[keys.order_type] then
            if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION and keys.new_pos then
                self.redirect_pos = keys.new_pos
            elseif keys.target then
                self.redirect_pos = keys.target:GetAbsOrigin()
            end
        end
    end
end

modifier_python_debuff = class({})

function modifier_python_debuff:IsPurgable() return true end

function modifier_python_debuff:OnCreated(params)
    if not IsServer() then return end
    self.leash_radius   = params.leash_radius
    self.begin_slow_radius  = params.leash_radius * 80 * 0.01
    self.leash_position     = self:GetParent():GetAbsOrigin()

    self.ground_particle = ParticleManager:CreateParticle("particles/vjlink_ground_particleground.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.ground_particle, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.ground_particle, 4, Vector(self.leash_radius))
    self:AddParticle(self.ground_particle, false, false, -1, false, false)

    self.leash_particle = ParticleManager:CreateParticle("particles/vjlink_leash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.leash_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.leash_particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.leash_particle, false, false, -1, false, false)

    self:StartIntervalThink(FrameTime())
end

function modifier_python_debuff:OnIntervalThink()
    self.limit      = 0
    self.move_speed = self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), false)
    self.limit      = ((self.leash_radius - (self:GetParent():GetAbsOrigin() - self.leash_position):Length2D()) / self.leash_radius) * self.move_speed

    if self.limit == 0 then
        self.limit = -0.01
    end
end

function modifier_python_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers(true)
end

function modifier_python_debuff:CheckState()
    return {[MODIFIER_STATE_TETHERED] = true}
end

function modifier_python_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_LIMIT}
end

function modifier_python_debuff:GetModifierMoveSpeed_Limit()
    if not IsServer() then return end

    if (self:GetParent():GetAbsOrigin() - self.leash_position):Length2D() >= self.begin_slow_radius and math.abs(AngleDiff(VectorToAngles(self:GetParent():GetAbsOrigin() - self.leash_position).y, VectorToAngles(self:GetParent():GetForwardVector() ).y)) <= 85 then
        return self.limit
    end
end

function modifier_python_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_huskar_lifebreak.vpcf"
end

--- TARGET

modifier_python_active = class({})

function modifier_python_active:IsPurgable() return false end
function modifier_python_active:IsHidden() return true end

function modifier_python_active:OnCreated( kv )
    self.target = self:GetAbility().target
    self.close_distance = 80
    self.far_distance = 1400
    self.speed = 1000

    self.leash_duration = self:GetAbility():GetSpecialValueFor("duration")
    self.leash_radius   = self:GetAbility():GetSpecialValueFor("leash_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_1")

    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_python_active:OnDestroy()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers( true )
    if not self.success then return end

    self.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_python_debuff", { duration = self.leash_duration * (1 - self.target:GetStatusResistance()), leash_radius = self.leash_radius })

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target )
    ParticleManager:SetParticleControl( particle, 1, self.target:GetOrigin() )
    ParticleManager:ReleaseParticleIndex( particle )

    local damage = self:GetAbility():GetSpecialValueFor("pounce_from_health")
    damage = damage / 100

    if self:GetCaster():HasTalent("special_bonus_birzha_vjlink_3") then
        self:GetCaster():PerformAttack(self.target, true, true, true, false, false, false, false)
    end

    local damageTable = { victim = self.target, attacker = self:GetCaster(), damage = damage * self.target:GetHealth(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() }
    
    ApplyDamage(damageTable)
    self.target:EmitSound("Hero_Huskar.Life_Break.Impact")
end

function modifier_python_active:CheckState()
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

function modifier_python_active:UpdateHorizontalMotion( me, dt )
    local origin = self:GetParent():GetOrigin()
    if not self.target:IsAlive() then
        self:EndCharge( false )
    end
    local direction = self.target:GetOrigin() - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()

    if distance<self.close_distance then
        self:EndCharge( true )
    elseif distance>self.far_distance then
        self:EndCharge( false )
    end

    local target = origin + direction * self.speed * dt
    self:GetParent():SetOrigin( target )
    self:GetParent():FaceTowards( self.target:GetOrigin() )
end

function modifier_python_active:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_python_active:EndCharge( success )
    if success then
        self.success = true
    end
    if not self:IsNull() then
        self:Destroy()
    end
end


LinkLuaModifier( "modifier_vjlink_dudos", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vjlink_dudos_buff", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vjlink_dudos_effect", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_dudos = class({})

function Vjlink_dudos:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vjlink_dudos:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vjlink_dudos:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vjlink_dudos:GetAbilityTextureName(  )
    local stack = self:GetCaster():GetModifierStackCount( "modifier_vjlink_dudos", self:GetCaster() )
    if stack==0 then
        return "vjlink/dudos_1"
    elseif stack == self:GetSpecialValueFor("maximum_stack") then
        return "Vjlink/dudos_2"
    elseif stack >= 3 then
        return "vjlink/dudos"
    end
    return "vjlink/dudos_1"
end

function Vjlink_dudos:GetIntrinsicModifierName()
    return "modifier_vjlink_dudos"
end

function Vjlink_dudos:IsRefreshable()
    return false
end

function Vjlink_dudos:CastFilterResult()
    if self:GetCaster():GetModifierStackCount( "modifier_vjlink_dudos", self:GetCaster() ) < 1 then
        return UF_FAIL_CUSTOM
    end
    if self:GetCaster():HasModifier("modifier_vjlink_dudos_buff") then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

function Vjlink_dudos:GetCustomCastError( hTarget )
    if self:GetCaster():GetModifierStackCount( "modifier_vjlink_dudos", self:GetCaster() ) < 1 then
        return "#dota_hud_error_vjlink_dudos_stacks"
    end
    if self:GetCaster():HasModifier("modifier_vjlink_dudos_buff") then
        return "#dota_hud_error_already_vjlink_dudos"
    end
    return ""
end

modifier_vjlink_dudos = class({})

function modifier_vjlink_dudos:IsHidden()
    return self:GetStackCount() < 1
end

function modifier_vjlink_dudos:IsPurgable()
    return false
end

function modifier_vjlink_dudos:RemoveOnDeath()
    return false
end

function modifier_vjlink_dudos:DestroyOnExpire()
    return false
end

function modifier_vjlink_dudos:OnCreated( kv )
    if not IsServer() then return end
    self.damage_count = 0
    self.damage_limit = 150
    self.stack_limit = self:GetAbility():GetSpecialValueFor( "maximum_stack" )
    self.duration = 20
end

function modifier_vjlink_dudos:OnRefresh( kv )
    if not IsServer() then return end
    self.damage_limit = 150
    self.stack_limit = self:GetAbility():GetSpecialValueFor( "maximum_stack" )
    self.duration = 20  
end

function modifier_vjlink_dudos:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_vjlink_dudos:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.attacker == self:GetParent() then return end
    local damage = params.damage
    if self:GetParent():HasModifier( "modifier_vjlink_dudos_buff" ) then return end

    local max = self.damage_limit
    local stack_limit = self.stack_limit

    while damage > 0 do 
        self.damage_count = damage + self.damage_count

        if self.damage_count < max then 
            damage = 0
        else 
            damage =  self.damage_count - max
            self.damage_count = 0

            if self:GetStackCount() < stack_limit then
                self:IncrementStackCount()
                if self:GetStackCount() == self.stack_limit then
                    self:GetParent():EmitSound("")
                end
            end

            self:SetDuration( self.duration, true )
            self:StartIntervalThink(self.duration)
        end
    end
end

function modifier_vjlink_dudos:OnIntervalThink()
    self:ResetStack()
end

function modifier_vjlink_dudos:ResetStack()
    self:SetStackCount(0)
end

function Vjlink_dudos:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )

    local stack = 0

    local modifier = self:GetCaster():FindModifierByName( "modifier_vjlink_dudos" )

    if modifier then
        stack = modifier:GetStackCount()
        modifier:ResetStack()
    end

    self:StartCooldown(duration)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_vjlink_dudos_buff", { duration = duration, stack = stack } )
    self:GetCaster():EmitSound("vjlink_dudos_new")
end

modifier_vjlink_dudos_buff = class({})

function modifier_vjlink_dudos_buff:GetTexture() return "Vjlink/dudos_2" end

function modifier_vjlink_dudos_buff:IsPurgable() return false end

function modifier_vjlink_dudos_buff:OnCreated(params)
    self.armor_per_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
    self.attack_speed_per_stack = self:GetAbility():GetSpecialValueFor( "attack_speed_per_stack" )
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_vjlink_dudos_effect", {} )
    self:SetStackCount(params.stack)
end

function modifier_vjlink_dudos_buff:OnDestroy()
    if not IsServer() then return end
    self.modifier = self:GetCaster():FindModifierByName( "modifier_vjlink_dudos_effect" )
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:Destroy()
    end
    self:GetParent():StopSound("vjlink_dudos_new")
end


function modifier_vjlink_dudos_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_vjlink_dudos_buff:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_per_stack * self:GetStackCount()
end

function modifier_vjlink_dudos_buff:GetModifierPhysicalArmorBonus()
    return self.armor_per_stack * self:GetStackCount()
end

function modifier_vjlink_dudos_buff:GetModifierMagicalResistanceBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_4") * self:GetStackCount()
end

function modifier_vjlink_dudos_buff:GetEffectName()
    return "particles/vjlink/1.vpcf"
end

function modifier_vjlink_dudos_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_vjlink_dudos_effect = class({})

function modifier_vjlink_dudos_effect:IsHidden() return true end

function modifier_vjlink_dudos_effect:GetEffectName()
    return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf"
end

function modifier_vjlink_dudos_effect:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_Vjlink_teeth", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_teeth = class({})

function Vjlink_teeth:GetIntrinsicModifierName()
    return "modifier_Vjlink_teeth"
end

modifier_Vjlink_teeth = class({})

function modifier_Vjlink_teeth:IsPurgable() return false end
function modifier_Vjlink_teeth:IsHidden() return true end

function modifier_Vjlink_teeth:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_Vjlink_teeth:GetModifierProcAttack_BonusDamage_Physical( params )
    self.damage = (self:GetAbility():GetSpecialValueFor( "damage_percent" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_7")) / 100
    if not IsServer() then return end
    if params.target:IsWard() then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsBoss() then return end
    local particle = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( particle )
    local damage = params.target:GetHealth() * self.damage
    self:GetParent():Heal( damage, self:GetAbility() )
    return damage
end

function modifier_Vjlink_teeth:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_8")
end


