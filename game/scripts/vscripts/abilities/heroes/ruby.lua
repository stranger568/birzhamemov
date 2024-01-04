LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_ruby_ranged_mode", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )

ruby_ranged_mode = class({})

function ruby_ranged_mode:OnVectorCastStart(vStartLocation, vDirection)
    if not IsServer() then return end
    local effects = self:PlayEffects()

    local vector = (vStartLocation-self:GetCaster():GetOrigin())
    local dist = vector:Length2D()
    vector.z = 0
    vector = vector:Normalized()

    local speed = self:GetSpecialValueFor( "dash_speed" )

    local knockback = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = vector.x,
            direction_y = vector.y,
            distance = dist,
            duration = dist/speed,
            IsStun = true,
            IsFlail = false,
        }
    )

    local callback = function( bInterrupted )
        ParticleManager:DestroyParticle( effects, false )
        ParticleManager:ReleaseParticleIndex( effects )
        if bInterrupted then return end
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ruby_ranged_mode", {dir_x = vDirection.x, dir_y = vDirection.y})
        FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true)
    end

    knockback:SetEndCallback( callback )
end

function ruby_ranged_mode:OnProjectileHit(target, vLocation)
    if target == nil then return end
    if target:IsInvulnerable() then return end

    local damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_1")

    ApplyDamage({ victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })

    if self:GetCaster():HasTalent("special_bonus_birzha_ruby_7") then
        self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
    else
        self:GetCaster():PerformAttack(target, true, true, true, false, false, true, true)
    end
end

function ruby_ranged_mode:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    self:GetCaster():EmitSound("DOTA_Item.Force_Boots.Cast")
    return effect_cast
end

modifier_ruby_ranged_mode = class({})

function modifier_ruby_ranged_mode:IsHidden()
    return true
end

function modifier_ruby_ranged_mode:IsPurgable()
    return false
end

function modifier_ruby_ranged_mode:OnCreated( kv )
    self.range = self:GetAbility():GetSpecialValueFor( "range" )
    self.speed = self:GetAbility():GetSpecialValueFor( "dash_speed" )
    self.radius = self:GetAbility():GetSpecialValueFor( "start_radius" )
    self.interval = self:GetAbility():GetSpecialValueFor( "attack_interval" )
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.strikes = self:GetAbility():GetSpecialValueFor( "strikes" )
    if not IsServer() then return end
    self.origin = self:GetParent():GetOrigin()
    self.direction = Vector( kv.dir_x, kv.dir_y, 0 )
    self.target = self.origin + self.direction * self.range

    local forward_t = (self.target - self:GetCaster():GetAbsOrigin())
    forward_t.z = 0
    local forward = forward_t:Normalized()

    self.forward = forward

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.2)

    self:GetParent():SetForwardVector(forward)
    self:GetParent():FaceTowards(self.target)

    self.count = 0

    Timers:CreateTimer(0.4, function()
        self:StartIntervalThink( self.interval )
        self:OnIntervalThink()
    end)
end

function modifier_ruby_ranged_mode:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
    }
    return state
end

function modifier_ruby_ranged_mode:OnIntervalThink()
    local info = 
    {
        EffectName = "particles/ruby_particle_ranged_mode.vpcf",
        Ability = self:GetAbility(),
        vSpawnOrigin = self.origin + Vector(0,0,120),
        fStartRadius = self.radius,
        fEndRadius = self.radius,
        vVelocity = self.forward * 1800,
        fDistance = self.range,
        Source = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        bProvidesVision     = false,
    }

    self:GetParent():EmitSound("Hero_Hoodwink.Sharpshooter.Cast")

    ProjectileManager:CreateLinearProjectile( info )

    self.count = self.count + 1

    if self.count>=self.strikes then
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_Ruby_RoseStrike", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ruby_RoseStrike_active", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )

Ruby_Fade = class({})

function Ruby_Fade:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ruby_Fade:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ruby_Fade:OnSpellStart()
    if not IsServer() then return end
    self.duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self.duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_phased", {duration = self.duration})
    self:GetCaster():EmitSound("Hero_PhantomLancer.PhantomEdge")

    local illusion_count = 1
    local check_shard_invis = true

    if self:GetCaster():HasShard() then
        illusion_count = 2
    end

    local illusion_inc = self:GetSpecialValueFor("illusion_inc")  - 100
    local damage_out = (self:GetSpecialValueFor("damage_out") + self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_4")) - 100

    local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=self.duration,outgoing_damage=0,incoming_damage=0}, illusion_count, 0, false, false ) 

    local ability = self:GetCaster():FindAbilityByName("Ruby_RoseStrike")

    for k, v in pairs(illusion) do
        if self:GetCaster():HasScepter() then
            v:AddNewModifier(self:GetCaster(), ability, "modifier_Ruby_RoseStrike", {})
        end
        if self:GetCaster():HasShard() then
            if check_shard_invis then
                v:AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self.duration})
                v:AddNewModifier(self:GetCaster(), self, "modifier_phased", {duration = self.duration})
                check_shard_invis = false
            end
        end
    end
end

LinkLuaModifier( "modifier_Ruby_SilverEyes", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ruby_SilverEyes_debuff", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ruby_SilverEyes_petrified", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )

Ruby_SilverEyes = class({})

function Ruby_SilverEyes:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():EmitSound("rubysilver")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Ruby_SilverEyes", { duration = duration } )
end

modifier_Ruby_SilverEyes = class({})

function modifier_Ruby_SilverEyes:IsPurgable()
    return false
end

function modifier_Ruby_SilverEyes:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.parent = self:GetParent()
    self.modifiers = {}
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", Vector(0,0,0), true )
    self:AddParticle( particle, false, false, -1, false, false )
    self:StartIntervalThink( 0.1 )
    self:OnIntervalThink()
end

function modifier_Ruby_SilverEyes:OnDestroy()
    if not IsServer() then return end
    for modifier,_ in pairs(self.modifiers) do
        if not modifier:IsNull() then
            modifier:Destroy()
        end
    end
    StopSoundOn( "rubysilver", self:GetParent() )
end

function modifier_Ruby_SilverEyes:OnIntervalThink()
    local enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,enemy in pairs(enemies) do
        local modifier1 = enemy:FindModifierByNameAndCaster( "modifier_Ruby_SilverEyes_debuff", self.parent )
        local modifier2 = enemy:FindModifierByNameAndCaster( "modifier_Ruby_SilverEyes_petrified", self.parent )
        if (not modifier1) and (not modifier2) then
            local modifier = enemy:AddNewModifier( self.parent, self:GetAbility(), "modifier_Ruby_SilverEyes_debuff", { center_unit = self.parent:entindex(), } )
            self.modifiers[modifier] = true
        end
    end
end

modifier_Ruby_SilverEyes_debuff = class({})

function modifier_Ruby_SilverEyes_debuff:IsPurgable()
    return false
end

function modifier_Ruby_SilverEyes_debuff:OnCreated( kv )
    self.stun_duration = self:GetAbility():GetSpecialValueFor( "stone_duration" )
    self.face_duration = self:GetAbility():GetSpecialValueFor( "face_duration" )
    self.physical_bonus = self:GetAbility():GetSpecialValueFor( "bonus_physical_damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_3")
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.stone_angle = 85
    self.parent = self:GetParent()
    self.facing = false
    self.counter = 0
    self.interval = 0.03
    if not IsServer() then return end
    self.damage_thinker = 0
    self.center_unit = EntIndexToHScript( kv.center_unit )
    self:PlayEffects1()
    self:PlayEffects2()
    self:StartIntervalThink( self.interval )
    self:OnIntervalThink()
    self.face_true = true
end

function modifier_Ruby_SilverEyes_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

    return funcs
end

function modifier_Ruby_SilverEyes_debuff:GetModifierMoveSpeedBonus_Percentage()
    if self.facing then
        return -50
    end
end

function modifier_Ruby_SilverEyes_debuff:GetModifierTurnRate_Percentage()
    if self.facing then
        return -50
    end
end

function modifier_Ruby_SilverEyes_debuff:GetModifierAttackSpeedBonus_Constant()
    if self.facing then
        return -50
    end
end

function modifier_Ruby_SilverEyes_debuff:OnIntervalThink()
    local vector = self.center_unit:GetOrigin()-self.parent:GetOrigin()
    local center_angle = VectorToAngles( vector ).y
    local facing_angle = VectorToAngles( self.parent:GetForwardVector() ).y
    local distance = vector:Length2D()
    local prev_facing = self.facing
    local damage = self:GetAbility():GetSpecialValueFor( "damage" ) 
    self.facing = ( math.abs( AngleDiff(center_angle,facing_angle) ) < self.stone_angle ) and (distance < self.radius )
    if self.facing~=prev_facing then
        self:ChangeEffects( self.facing )
    end
    if self.facing then
        self.counter = self.counter + self.interval
        self.damage_thinker = self.damage_thinker + self.interval
        if self.damage_thinker >= 0.5 then
            self.damage_thinker = 0
            ApplyDamage({ victim = self.parent, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage * 0.5, damage_type = DAMAGE_TYPE_MAGICAL })
        end
    end
    if self.counter>=self.face_duration then
        if self.face_true then
            self.parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Ruby_SilverEyes_petrified", { duration = self.stun_duration * (1 - self.parent:GetStatusResistance()), physical_bonus = self.physical_bonus, center_unit = self.center_unit:entindex(), }  )
            self.face_true = false
        end
    end
end

function modifier_Ruby_SilverEyes_debuff:PlayEffects1()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self.center_unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_Ruby_SilverEyes_debuff:PlayEffects2()
    self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_facing.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle( self.effect_cast, false, false, -1, false, false )
end

function modifier_Ruby_SilverEyes_debuff:ChangeEffects( IsNowFacing )
    local target = self.parent
    if IsNowFacing then
        target = self.center_unit
        self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Target")
    end
    ParticleManager:SetParticleControlEnt( self.effect_cast, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
end

modifier_Ruby_SilverEyes_petrified = class({})

function modifier_Ruby_SilverEyes_petrified:OnCreated( kv )
    if not IsServer() then return end
    self.physical_bonus = kv.physical_bonus
    self.center_unit = EntIndexToHScript( kv.center_unit )
    self:PlayEffects()
end

function modifier_Ruby_SilverEyes_petrified:OnRefresh( kv )
    if not IsServer() then return end
    self.physical_bonus = kv.physical_bonus
    self.center_unit = EntIndexToHScript( kv.center_unit )
    self:PlayEffects()
end

function modifier_Ruby_SilverEyes_petrified:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_Ruby_SilverEyes_petrified:GetModifierIncomingDamage_Percentage( params )
    if params.damage_type==DAMAGE_TYPE_PHYSICAL then
        return self.physical_bonus
    end
end

function modifier_Ruby_SilverEyes_petrified:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
    }

    return state
end

function modifier_Ruby_SilverEyes_petrified:GetStatusEffectName()
    return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_Ruby_SilverEyes_petrified:StatusEffectPriority(  )
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_Ruby_SilverEyes_petrified:PlayEffects()
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 1, self.center_unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector( 0,0,0 ), true )
    self:AddParticle( particle, false, false, -1, false, false )
    self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Stun")
end

LinkLuaModifier( "modifier_Ruby_RoseStrike_cooldown", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )

Ruby_RoseStrike = class({})

function Ruby_RoseStrike:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_ruby_5") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Ruby_RoseStrike:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Ruby_RoseStrike_active", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_5")})
    if self:GetCaster():HasScepter() then
        local illusions = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 0, false )
        for _, illusion in pairs(illusions) do
            if illusion:IsIllusion() then
                local mod = illusion:FindModifierByName("modifier_illusion")
                if mod and mod:GetCaster() == self:GetCaster() then
                    illusion:AddNewModifier(self:GetCaster(), self, "modifier_Ruby_RoseStrike_active", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_5")})
                end
            end
        end
    end
end

function Ruby_RoseStrike:GetCooldown(level)
    if self:GetCaster():HasTalent("special_bonus_birzha_ruby_5") then
        return self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_5", "value2")
    end
    return self.BaseClass.GetCooldown( self, level ) / self:GetCaster():GetCooldownReduction()
end

function Ruby_RoseStrike:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_Ruby_RoseStrike"
end

function Ruby_RoseStrike:StartWheel(attacker)
    local radius = self:GetSpecialValueFor( "radius" )
    local damage = self:GetSpecialValueFor( "damage" )
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), attacker:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    for _,enemy in pairs(enemies) do
        ApplyDamage( { victim = enemy, attacker = attacker, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self, damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES } )
    end

    if not self:GetCaster():HasTalent("special_bonus_birzha_ruby_5") then
        if not attacker:IsIllusion() then
            self:UseResources( false, false, false, true )
        end
    end

    local particle = ParticleManager:CreateParticle( "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker )
    ParticleManager:ReleaseParticleIndex( particle )

    attacker:EmitSound("rubyaxe")

    attacker:StartGesture(ACT_DOTA_CAST_ABILITY_6)

    local parent = attacker

    Timers:CreateTimer(0.5, function()
        parent:RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
    end)
end

modifier_Ruby_RoseStrike = class({})

function modifier_Ruby_RoseStrike:IsHidden()
    return true
end

function modifier_Ruby_RoseStrike:IsPurgable()
    return false
end

function modifier_Ruby_RoseStrike:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_Ruby_RoseStrike:OnAttackLanded( params )
    if not IsServer() then return end
    if params.target == self:GetParent() then
        if self:GetCaster():PassivesDisabled() then return end
        if not self:GetAbility():IsFullyCastable() then return end
        local chance = self:GetAbility():GetSpecialValueFor("trigger_chance2")
        if self:GetParent():HasModifier("modifier_Ruby_RoseStrike_active") then return end
        if self:GetCaster():HasTalent("special_bonus_birzha_ruby_5") then
            if self:GetParent():HasModifier("modifier_Ruby_RoseStrike_cooldown") then return end
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Ruby_RoseStrike_cooldown", {duration = 1})
        end
        if RollPercentage(chance) then
            self:GetAbility():StartWheel(self:GetParent())
        end
    end
    if params.attacker == self:GetParent() then
        if params.target:IsWard() then return end
        if self:GetCaster():PassivesDisabled() then return end
        if not self:GetAbility():IsFullyCastable() then return end
        local chance = self:GetAbility():GetSpecialValueFor("trigger_chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_6")
        if self:GetParent():HasModifier("modifier_Ruby_RoseStrike_active") then return end
        if self:GetCaster():HasTalent("special_bonus_birzha_ruby_5") then
            if self:GetParent():HasModifier("modifier_Ruby_RoseStrike_cooldown") then return end
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Ruby_RoseStrike_cooldown", {duration = 1})
        end
        if RollPercentage(chance) then
            self:GetAbility():StartWheel(self:GetParent())
        end
    end
end

modifier_Ruby_RoseStrike_active = class({})

function modifier_Ruby_RoseStrike_active:AllowIllusionDuplicate() return true end

function modifier_Ruby_RoseStrike_active:IsPurgable() return false end

function modifier_Ruby_RoseStrike_active:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.4)
end

function modifier_Ruby_RoseStrike_active:OnIntervalThink()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( particle )

    self:GetParent():EmitSound("rubyaxe")

    local radius = self:GetAbility():GetSpecialValueFor( "radius" )

    local damage = self:GetAbility():GetSpecialValueFor( "damage" )

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    for _,enemy in pairs(enemies) do
        ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility(), damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES } )
    end
end

function modifier_Ruby_RoseStrike_active:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_Ruby_RoseStrike_active:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_6
end

modifier_Ruby_RoseStrike_cooldown = class({})
function modifier_Ruby_RoseStrike_cooldown:IsHidden() return true end
function modifier_Ruby_RoseStrike_cooldown:IsPurgable() return false end
function modifier_Ruby_RoseStrike_cooldown:IsPurgeException() return false end