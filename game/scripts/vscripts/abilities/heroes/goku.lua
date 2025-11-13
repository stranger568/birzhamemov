LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_goku_kamehame", "abilities/heroes/goku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

goku_kamehame = class({})

function goku_kamehame:Precache(context)
    PrecacheResource("model", "models/update_heroes/goku/goku_base.vmdl", context)
    PrecacheResource("model", "models/update_heroes/goku/goku_form_1.vmdl", context)
    PrecacheResource("model", "models/update_heroes/goku/goku_form_2.vmdl", context)
    PrecacheResource("model", "models/update_heroes/goku/goku_form_3.vmdl", context)
    PrecacheResource("model", "models/update_heroes/goku/goku_form_4.vmdl", context)
    local particle_list = 
    {
        "particles/custom_particles/goku/goku_kamehameha_cast.vpcf",
        "particles/kamehameha.vpcf",
        "particles/goku_attacks.vpcf",
        "particles/red/goku_attacks.vpcf",
        "particles/blue/goku_attacks.vpcf",
        "particles/goku_attacks.vpcf",
        "particles/red/goku_attacks.vpcf",
        "particles/blue/goku_attacks.vpcf",
        "particles/goku_dmg.vpcf",
        "particles/red/goku_dmg.vpcf",
        "particles/blue/goku_dmg.vpcf",
        "particles/ki_blast.vpcf",
        "particles/ki_blast_exp.vpcf",
        "particles/goku_effect_blink_burst.vpcf",
        "particles/items_fx/blink_dagger_start.vpcf",
        "particles/items_fx/blink_dagger_end.vpcf",
        "particles/kamehameha.vpcf",
        "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_start.vpcf",
        "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_end.vpcf",
        "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_1.vpcf",
        "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_2.vpcf",
        "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_3.vpcf",
        "particles/goku_feet_yellow.vpcf",
        "particles/goku_feet_yellow.vpcf",
        "particles/goku_feet_yellow.vpcf",
        "particles/goku_feet_red.vpcf",
        "particles/goku_feet_blue.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function goku_kamehame:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function goku_kamehame:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_kamehame:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function goku_kamehame:GetChannelTime()
    local cast = 1.5
    if self:GetCaster():HasShard() then
        cast = self:GetSpecialValueFor("shard_cast_point")
    end
    return cast
end

function goku_kamehame:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("GokuKamestart")

    self.point = self:GetCursorPosition()

    self.radius = self:GetSpecialValueFor( "radius" )

    self.cast_direction = (self.point - self:GetCaster():GetAbsOrigin())
    self.cast_direction.z = 0
    self.cast_direction = self.cast_direction:Normalized()

    if self.point == self:GetCaster():GetAbsOrigin() then
        self.cast_direction = self:GetCaster():GetForwardVector()
    end

    self.particle = ParticleManager:CreateParticle("particles/custom_particles/goku/goku_kamehameha_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
end

function goku_kamehame:OnChannelFinish( bInterrupted )

    self:GetCaster():StopSound("GokuKamestart")

    if bInterrupted then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
            ParticleManager:ReleaseParticleIndex(self.particle)
            local cooldown = self:GetCooldownTimeRemaining()
            if cooldown > 0 then
                self:EndCooldown()
                self:StartCooldown(cooldown / 2)
            end
        end
        return
    end

    self:GetCaster():EmitSound("GokuKameend")

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_7)

    local width = self:GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_6", "value2")

    local distance = self:GetSpecialValueFor( "range" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_6")

    local speed = 1800

    local info = 
    {
        Source = self:GetCaster(),
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/kamehameha.vpcf",
        fDistance = distance,
        fStartRadius = width,
        fEndRadius = width,
        vVelocity = self.cast_direction * speed,
        bProvidesVision = true,
        iVisionRadius = width,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
    }

    local projectile = ProjectileManager:CreateLinearProjectile(info)

    if self.particle then
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

function goku_kamehame:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then

        local damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_1")

        if self:GetCaster():HasModifier("modifier_goku_saiyan") then
            local bonus_damage = self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetSpecialValueFor("kame_bonus_damage")
            damage = damage + bonus_damage
        end

        local damageTable = 
        {
            victim = target,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self,
        }

        ApplyDamage(damageTable)
    end
end

LinkLuaModifier( "modifier_goku_merni_attacks", "abilities/heroes/goku.lua", LUA_MODIFIER_MOTION_NONE )

goku_merni_attacks = class({})

function goku_merni_attacks:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function goku_merni_attacks:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_merni_attacks:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "phase_duration" )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_goku_merni_attacks", { duration = duration } )
    self:GetCaster():EmitSound("GokuTwo")
end

modifier_goku_merni_attacks = class({})

function modifier_goku_merni_attacks:IsHidden()
    return false
end

function modifier_goku_merni_attacks:IsDebuff()
    return false
end

function modifier_goku_merni_attacks:IsPurgable()
    return false
end

function modifier_goku_merni_attacks:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():Stop()
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.portals = self:GetAbility():GetSpecialValueFor( "portals_per_ring" )
    self.angle = self:GetAbility():GetSpecialValueFor( "angle_per_ring_portal" )
    self.radius = self:GetAbility():GetSpecialValueFor( "damage_radius" )
    self.distance = self:GetAbility():GetSpecialValueFor( "first_ring_distance_offset" )
    self.target_radius = self:GetAbility():GetSpecialValueFor( "destination_fx_radius" )
    if not IsServer() then return end
    local origin = self:GetParent():GetOrigin()
    local direction = self:GetParent():GetForwardVector()
    local zero = Vector(0,0,0)
    self.selected = 1
    self.points = {}
    self.effects = {}
    table.insert( self.points, origin )
    table.insert( self.effects, self:PlayEffects1( origin, true ) )
    for i=1,self.portals do
        local new_direction = RotatePosition( zero, QAngle( 0, self.angle*i, 0 ), direction )
        local point = GetGroundPosition( origin + new_direction * self.distance, nil )

        table.insert( self.points, point )
        table.insert( self.effects, self:PlayEffects1( point, false ) )
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_goku_7") then
        for i=1,self.portals do
            local new_direction = RotatePosition( zero, QAngle( 0, self.angle*i, 0 ), direction )
            local point = GetGroundPosition( origin + new_direction * self.distance*2, nil )
            table.insert( self.points, point )
            table.insert( self.effects, self:PlayEffects1( point, false ) )
        end
    end


    ProjectileManager:ProjectileDodge(self:GetParent())
    self:GetParent():AddNoDraw()
end

function modifier_goku_merni_attacks:OnDestroy()
    if not IsServer() then return end
    local point = self.points[self.selected]

    if self:GetCaster():HasTalent("special_bonus_birzha_goku_4") then
        local heal = self:GetCaster():GetMaxHealth() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_goku_4")
        self:GetCaster():Heal(heal, self:GetAbility())
    end

    FindClearSpaceForUnit( self:GetParent(), point, true )

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(),  point, nil,   self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false  )
    
    local damageTable = 
    {
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
    }

    local damage = self.damage

    if self:GetParent():HasModifier("modifier_goku_saiyan") then
        local bonus_damage = self:GetParent():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetSpecialValueFor("merni_attacks_damage")
        damage = damage + bonus_damage
    end

    for _,enemy in pairs(enemies) do
        damageTable.damage = damage
        damageTable.victim = enemy
        ApplyDamage(damageTable) 
        if self:GetCaster():HasTalent("special_bonus_birzha_goku_7") then
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_goku_7") * (1 - enemy:GetStatusResistance())})
        end
    end

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2_END)

    self:GetParent():RemoveNoDraw()
    self:PlayEffects2( point, #enemies )
end

function modifier_goku_merni_attacks:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
    return funcs
end

function modifier_goku_merni_attacks:OnOrder( params )
    if params.unit~=self:GetParent() then return end
    if  params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        self:SetValidTarget( params.new_pos )
    elseif 
        params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
        params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
    then
        self:SetValidTarget( params.target:GetOrigin() )
    end
    if params.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
        self:SetValidTarget( params.new_pos )
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_goku_merni_attacks:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_goku_merni_attacks:CheckState()
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
    return state
end

function modifier_goku_merni_attacks:SetValidTarget( location )
    local max_dist = (location-self.points[1]):Length2D()
    local max_point = 1
    for i,point in ipairs(self.points) do
        local dist = (location-point):Length2D()
        if dist<max_dist then
            max_dist = dist
            max_point = i
        end
    end

    local old_select = self.selected
    self.selected = max_point
    self:ChangeEffects( old_select, self.selected )
end

function modifier_goku_merni_attacks:PlayEffects1( point, main )
    local radius = self.radius + 25

    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() < 4 then
        effect_cast = ParticleManager:CreateParticleForTeam( "particles/goku_attacks.vpcf", PATTACH_WORLDORIGIN, self:GetParent(), self:GetParent():GetTeamNumber() )
    end
    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() == 4 then
        effect_cast = ParticleManager:CreateParticleForTeam( "particles/red/goku_attacks.vpcf", PATTACH_WORLDORIGIN, self:GetParent(), self:GetParent():GetTeamNumber() )
    end
    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() == 5 then
        effect_cast = ParticleManager:CreateParticleForTeam( "particles/blue/goku_attacks.vpcf", PATTACH_WORLDORIGIN, self:GetParent(), self:GetParent():GetTeamNumber() )
    end

    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 0, 1 ) )

    if main then
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
    end

    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() < 4 then
        effect_cast2 = ParticleManager:CreateParticle( "particles/goku_attacks.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    end

    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() == 4 then
        effect_cast2 = ParticleManager:CreateParticle( "particles/red/goku_attacks.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    end

    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() == 5 then
        effect_cast2 = ParticleManager:CreateParticle( "particles/blue/goku_attacks.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    end

    ParticleManager:SetParticleControl( effect_cast2, 0, point )
    ParticleManager:SetParticleControl( effect_cast2, 1, Vector( radius, 0, 1 ) )

    self:AddParticle( effect_cast, false, false, -1, false, false  )
    self:AddParticle( effect_cast2, false, false, -1, false, false  )

    EmitSoundOnLocationWithCaster( point, "Hero_VoidSpirit.Dissimilate.Portals", self:GetCaster() )

    return effect_cast
end

function modifier_goku_merni_attacks:ChangeEffects( old, new )
    ParticleManager:SetParticleControl( self.effects[old], 2, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControl( self.effects[new], 2, Vector( 1, 0, 0 ) )
end

function modifier_goku_merni_attacks:PlayEffects2( point, hit )
    local effect_cast
    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() < 4 then
        effect_cast = ParticleManager:CreateParticle( "particles/goku_dmg.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    end
    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() == 4 then
        effect_cast = ParticleManager:CreateParticle( "particles/red/goku_dmg.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    end
    if self:GetCaster():FindAbilityByName("goku_saiyan"):GetLevel() == 5 then
        effect_cast = ParticleManager:CreateParticle( "particles/blue/goku_dmg.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    end
    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.target_radius, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetParent():EmitSound("Hero_VoidSpirit.Dissimilate.TeleportIn")
    if hit>0 then
        self:GetParent():EmitSound("Hero_VoidSpirit.Dissimilate.Stun")
    end
end

LinkLuaModifier( "modifier_goku_ki_blast", "abilities/heroes/goku", LUA_MODIFIER_MOTION_NONE)

goku_ki_blast = class({})

function goku_ki_blast:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function goku_ki_blast:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AOE
end

function goku_ki_blast:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()

    point = point + Vector(0,0,120)

    local target = CreateModifierThinker(self:GetCaster(), self, "modifier_goku_ki_blast", nil, point, self:GetCaster():GetTeamNumber(), false)

    local info = 
    {
        EffectName = "particles/ki_blast.vpcf",
        Ability = self,
        iMoveSpeed = 1200,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    }

    ProjectileManager:CreateTrackingProjectile( info )

    self:GetCaster():EmitSound("GokuKi")
end

function goku_ki_blast:OnProjectileHit( target, vLocation )
    if not IsServer() then return end

    if target == nil then return end

    local effect_fx = ParticleManager:CreateParticle("particles/ki_blast_exp.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_fx, 0, vLocation + Vector(0,0,120))
    ParticleManager:SetParticleControl(effect_fx, 1, vLocation + Vector(0,0,120))
    ParticleManager:SetParticleControl(effect_fx, 2, vLocation + Vector(0,0,120))
    ParticleManager:SetParticleControl(effect_fx, 3, vLocation + Vector(0,0,120))
    ParticleManager:SetParticleControl(effect_fx, 4, vLocation + Vector(0,0,120))

    local nearby_targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for i, target in pairs(nearby_targets) do
        local damage = self:GetSpecialValueFor("damage") 
        local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_2")
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration * (1 - target:GetStatusResistance()) })
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self })  
    end

    UTIL_Remove(target)

    return true
end

modifier_goku_ki_blast = class ({})

function modifier_goku_ki_blast:IsHidden()
    return true
end

goku_blink_one = class({})

function goku_blink_one:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_3")
end

function goku_blink_one:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function goku_blink_one:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_blink_one:GetAOERadius()
    local goku_saiyan = self:GetCaster():FindAbilityByName("goku_saiyan")
    if goku_saiyan and goku_saiyan:GetLevel() > 0 then
        return goku_saiyan:GetSpecialValueFor("shunkan_radius")
    end
    return 0
end

function goku_blink_one:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("blink_range")

    local direction = (point - origin)

    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end

    self:PlayEffects( origin, direction )

    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )

    ProjectileManager:ProjectileDodge(self:GetCaster())

    local goku_saiyan = self:GetCaster():FindAbilityByName("goku_saiyan")
    if goku_saiyan and goku_saiyan:GetLevel() > 0 then

        local particle = ParticleManager:CreateParticle( "particles/goku_effect_blink_burst.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControl( particle, 0, origin + direction )
        ParticleManager:SetParticleControl( particle, 1, Vector(goku_saiyan:GetSpecialValueFor("shunkan_radius"),goku_saiyan:GetSpecialValueFor("shunkan_radius"),goku_saiyan:GetSpecialValueFor("shunkan_radius")) )

        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), origin + direction, nil, goku_saiyan:GetSpecialValueFor("shunkan_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        local damageTable = { attacker = self:GetCaster(), damage_type = DAMAGE_TYPE_MAGICAL, damage=goku_saiyan:GetSpecialValueFor("shunkan_damage"), ability = self, damage_flags = DOTA_UNIT_TARGET_FLAG_NONE }
        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end
    end
end

function goku_blink_one:PlayEffects( origin, direction )
    local particle_one = ParticleManager:CreateParticle( "particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    EmitSoundOnLocationWithCaster( origin, "GokuBlink", self:GetCaster() )

    local particle_two = ParticleManager:CreateParticle( "particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
end

goku_blink_two = class({})

function goku_blink_two:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function goku_blink_two:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function goku_blink_two:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_blink_two:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if self:GetCursorTarget() then
        if self:GetCursorTarget() == self:GetCaster() then
            return
        end
    end
    return true;
end

function goku_blink_two:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local origin = caster:GetOrigin()

    if target == nil then
        target = self:GetCursorPosition()
        caster:SetOrigin( target )
        FindClearSpaceForUnit( caster, target, true )
        self:PlayEffects( origin )
        return
    end

    if target:GetTeamNumber()~=caster:GetTeamNumber() then
        if target:TriggerSpellAbsorb( self ) then
            return
        end
    end

    local blinkDistance = 50


    local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized() * blinkDistance
    local blinkPosition = target:GetOrigin() + blinkDirection

    local duration = self:GetSpecialValueFor("stun_duration")

    caster:SetOrigin( blinkPosition )

    FindClearSpaceForUnit( caster, blinkPosition, true )

    if target:GetTeamNumber()~=caster:GetTeamNumber() then
        target:AddNewModifier( caster, self, "modifier_birzha_stunned", { duration = duration } )
        caster:MoveToTargetToAttack(target)

        local goku_kamehame = self:GetCaster():FindAbilityByName("goku_kamehame")
        if goku_kamehame and goku_kamehame:GetLevel() > 0 then
            if self:GetCaster():HasScepter() then
                self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_7, 1 )
                self:UseKameHameHame(blinkPosition)
            end
        end
    end

    self:PlayEffects( origin )
end

function goku_blink_two:UseKameHameHame( point )

    local direction = ((point - self:GetCaster():GetAbsOrigin())):Normalized()
    local width = self:GetCaster():FindAbilityByName("goku_kamehame"):GetSpecialValueFor( "radius" )
    local distance = self:GetCaster():FindAbilityByName("goku_kamehame"):GetSpecialValueFor( "range" )
    local speed = 1800

    if (point - self:GetCaster():GetAbsOrigin()) == self:GetCaster():GetAbsOrigin() then
        direction = self:GetCaster():GetForwardVector()
    end

    local info = {
        Source = self:GetCaster(),
        Ability = self:GetCaster():FindAbilityByName("goku_kamehame"),
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/kamehameha.vpcf",
        fDistance = distance,
        fStartRadius = width,
        fEndRadius = width,
        vVelocity = direction * speed,
        bProvidesVision = true,
        iVisionRadius = width,
        fExpireTime = GameRules:GetGameTime() + 1,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
    }
    local projectile = ProjectileManager:CreateLinearProjectile(info)
end

function goku_blink_two:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then

        local damage = self:GetCaster():FindAbilityByName("goku_kamehame"):GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_1")

        if self:GetCaster():HasModifier("modifier_goku_saiyan") then
            local bonus_damage = self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetSpecialValueFor("kame_bonus_damage")
            damage = damage + bonus_damage
        end

        local damageTable = 
        {
            victim = target,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetCaster():FindAbilityByName("goku_kamehame"),
        }

        ApplyDamage(damageTable)
    end
end


function goku_blink_two:PlayEffects( origin )
    local effect_cast_start = ParticleManager:CreateParticle( "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_start.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast_start, 0, origin )
    ParticleManager:ReleaseParticleIndex( effect_cast_start )

    local effect_cast_end = ParticleManager:CreateParticle( "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_end.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast_end, 0, self:GetCaster():GetOrigin() )
    ParticleManager:ReleaseParticleIndex( effect_cast_end )

    EmitSoundOnLocationWithCaster( origin, "GokuBlink", self:GetCaster() )
end

LinkLuaModifier("modifier_goku_saiyan", "abilities/heroes/goku", LUA_MODIFIER_MOTION_NONE)

goku_saiyan = class({})

function goku_saiyan:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function goku_saiyan:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_saiyan:GetAbilityTextureName()
    if self:GetLevel() == 2 then
        return "goku/saiyan2"
    end
    if self:GetLevel() == 3 then
        return "goku/saiyan3"
    end
    if self:GetLevel() == 4 then
        return "goku/saiyan4"
    end
    if self:GetLevel() == 5 then
        return "goku/saiyan5"
    end
    return "goku/saiyan"
end

function goku_saiyan:OnSpellStart()
    if not IsServer() then return end

    local duration = self:GetSpecialValueFor("duration")

    if self:GetCaster():HasModifier("modifier_goku_saiyan") then
        self:GetCaster():RemoveModifierByName("modifier_goku_saiyan")
    end

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_goku_saiyan", { duration = duration } )  

    self:GetCaster():EmitSound("GokuLoop")

    if self:GetLevel() == 1 then
        self:GetCaster():EmitSound("GokuUltimateOne")
    end

    if self:GetLevel() == 2 then
        self:GetCaster():EmitSound("GokuUltimateTwo")
    end

    if self:GetLevel() == 3 then
        self:GetCaster():EmitSound("GokuUltimateThree")
    end

    if self:GetLevel() == 4 then
        self:GetCaster():EmitSound("GokuUltimateFour")
    end

    if self:GetLevel() == 5 then
        self:GetCaster():EmitSound("GokuUltimateFive")
    end
end

modifier_goku_saiyan = class({})

function modifier_goku_saiyan:IsHidden()
    return false
end

function modifier_goku_saiyan:IsPurgable()
    return false
end

function modifier_goku_saiyan:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }

    return funcs
end

function modifier_goku_saiyan:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:IsToggle() or hAbility:IsItem() then
            return 0
        end

        local chance = self:GetAbility():GetSpecialValueFor("chance_refresh")

        if hAbility:GetAbilityName() == "goku_kamehame" or hAbility:GetAbilityName() == "goku_merni_attacks" or hAbility:GetAbilityName() == "goku_ki_blast" then
            if RollPercentage(chance) then
                local abilities = 
                {
                    "goku_kamehame",
                    "goku_merni_attacks",
                    "goku_ki_blast",
                    "goku_blink_one",
                    "goku_blink_two",
                }
                local parent = self:GetParent()
                Timers:CreateTimer(0.25, function() parent:FindAbilityByName(abilities[RandomInt(1, #abilities)]):EndCooldown() end)
            end
        end
    end 
end

function modifier_goku_saiyan:OnCreated()
    self.amp = self:GetAbility():GetSpecialValueFor("spell_amplify") + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_5")

    if not IsServer() then return end
    local bonus = (self:GetAbility():GetSpecialValueFor("bonus_attribute") + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_8") ) / 100

    self.str = self:GetParent():GetStrength() * bonus
    self.agi = self:GetParent():GetAgility() * bonus
    self.int = self:GetParent():GetIntellect(false) * bonus

    self.swapab = false

    local particle_name

    if self:GetAbility():GetLevel() > 2 then
        self.swapab = true
        self:GetParent():SwapAbilities("goku_blink_one", "goku_blink_two", false, true)
        self:GetParent():FindAbilityByName("goku_blink_two"):SetLevel(self:GetParent():FindAbilityByName("goku_saiyan"):GetLevel())
    end

    if self:GetAbility():GetLevel() == 3 or self:GetAbility():GetLevel() == 2 or self:GetAbility():GetLevel() == 1 then
        particle_name = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_1.vpcf"
    end

    if self:GetAbility():GetLevel() == 4 then
        particle_name = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_2.vpcf"
    end

    if self:GetAbility():GetLevel() == 5 then
        particle_name = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_3.vpcf"
    end

    self.particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())

    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(),  self:GetParent():GetAbsOrigin(), nil,   FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false   )
   
    for _,unit in pairs(units) do

        if unit:GetUnitName() == "donater_top6" then
            self.particle_pet = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControl(self.particle, 0, unit:GetAbsOrigin())
        end

        if PlayerResource:GetSteamAccountID( self:GetParent():GetPlayerID() ) == 113370083 then
            if unit:GetUnitName() == "unit_premium_pet" then
                self.particle_insane = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, unit)
                ParticleManager:SetParticleControl(self.particle_insane, 0, unit:GetAbsOrigin())
            end
        end

    end
end

function modifier_goku_saiyan:OnRefresh()
    self.amp = self:GetAbility():GetSpecialValueFor("spell_amplify") + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_5")
    self.speed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    if not IsServer() then return end
    local bonus = (self:GetAbility():GetSpecialValueFor("bonus_attribute") + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_8")) / 100
    self.str = self:GetParent():GetStrength() * bonus
    self.agi = self:GetParent():GetAgility() * bonus
    self.int = self:GetParent():GetIntellect(false) * bonus
end

function modifier_goku_saiyan:OnDestroy()
    if not IsServer() then return end

    if self:GetAbility():GetLevel() > 2 and self.swapab then
        self:GetParent():SwapAbilities("goku_blink_two", "goku_blink_one", false, true)
        self:GetParent():FindAbilityByName("goku_blink_one"):SetLevel(1)
    end

    if self.particle then
        ParticleManager:DestroyParticle(self.particle,true)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    if self.particle_pet then
        ParticleManager:DestroyParticle(self.particle_pet,true)
        ParticleManager:ReleaseParticleIndex(self.particle_pet)
    end

    if self.particle_insane then
        ParticleManager:DestroyParticle(self.particle_insane,true)
        ParticleManager:ReleaseParticleIndex(self.particle_insane)
    end

    self:GetCaster():StopSound("GokuLoop")
    StopSoundEvent( "GokuLoop", self:GetCaster() )
end

function modifier_goku_saiyan:GetModifierSpellAmplify_Percentage()
    return self.amp
end

function modifier_goku_saiyan:GetModifierBonusStats_Strength()
    return self.str
end

function modifier_goku_saiyan:GetModifierBonusStats_Agility()
    return self.agi
end

function modifier_goku_saiyan:GetModifierBonusStats_Intellect()
    return self.int
end

function modifier_goku_saiyan:GetEffectName()
    if self:GetAbility():GetLevel() == 1 then
        self.feet = "particles/goku_feet_yellow.vpcf"
    end
    if self:GetAbility():GetLevel() == 2 then
        self.feet = "particles/goku_feet_yellow.vpcf"
    end
    if self:GetAbility():GetLevel() == 3 then
        self.feet = "particles/goku_feet_yellow.vpcf"
    end
    if self:GetAbility():GetLevel() == 4 then
        self.feet = "particles/goku_feet_red.vpcf"
    end
    if self:GetAbility():GetLevel() == 5 then
        self.feet = "particles/goku_feet_blue.vpcf"
    end
    return self.feet
end

function modifier_goku_saiyan:GetModifierModelChange()
    if self:GetAbility():GetLevel() == 1 then
        self.model = "models/update_heroes/goku/goku_form_1.vmdl"
    end
    if self:GetAbility():GetLevel() == 2 then
        self.model = "models/update_heroes/goku/goku_form_1.vmdl"
    end
    if self:GetAbility():GetLevel() == 3 then
        self.model = "models/update_heroes/goku/goku_form_2.vmdl"
    end
    if self:GetAbility():GetLevel() == 4 then
        self.model = "models/update_heroes/goku/goku_form_3.vmdl"
    end
    if self:GetAbility():GetLevel() == 5 then
        self.model = "models/update_heroes/goku/goku_form_4.vmdl"
    end
    return self.model
end
























