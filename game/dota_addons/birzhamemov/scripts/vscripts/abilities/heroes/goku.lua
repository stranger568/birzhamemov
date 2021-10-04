LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_goku_kamehame", "abilities/heroes/goku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

goku_kamehame = class({})

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
    if self:GetCaster():HasScepter() then
        cast = cast - 0.5
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_goku_4") then
        cast = cast - 0.99
    end
    return cast
end

 --function goku_kamehame:GetBehavior()
 --    local caster = self:GetCaster()
 --    if self:GetCaster():HasTalent("special_bonus_birzha_goku_4") and self:GetCaster():HasScepter() then
 --        return DOTA_ABILITY_BEHAVIOR_POINT
 --    end
 --    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
 --end


--THANKS STAR BATTLE ANIME ♥♥♥
function goku_kamehame:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("GokuKamestart")
    self.point = self:GetCursorPosition()
    self.radius = self:GetSpecialValueFor( "radius" )
    self.cast_direction = (self.point - self:GetCaster():GetAbsOrigin()):Normalized()
    if self.point == self:GetCaster():GetAbsOrigin() then
        self.cast_direction = self:GetCaster():GetForwardVector()
    end
    self.particle = ParticleManager:CreateParticle("particles/goku_kamehameha.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
end

function goku_kamehame:OnChannelFinish( bInterrupted )
    self:GetCaster():StopSound("GokuKamestart")
    if bInterrupted then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        return
    end
    self:GetCaster():EmitSound("GokuKameend")
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_7)
    local width = self:GetSpecialValueFor( "radius" )
    local distance = self:GetSpecialValueFor( "range" )
    local speed = 1800
    local info = {
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
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function goku_kamehame:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_1")
        if self:GetCaster():HasModifier("modifier_goku_saiyan") then
            local bonus_damage = self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetSpecialValueFor("kame_bonus_damage")
            damage = damage + bonus_damage
        end
        local damageTable = {
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
    EmitSoundOn( "GokuTwo", self:GetCaster() )
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
    ProjectileManager:ProjectileDodge(self:GetParent())
    self:GetParent():AddNoDraw()
end

function modifier_goku_merni_attacks:OnDestroy()
    if not IsServer() then return end
    local point = self.points[self.selected]
    FindClearSpaceForUnit( self:GetParent(), point, true )

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(), 
        point,
        nil,  
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false  
    )
    local damageTable = {

        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
    }

    for _,enemy in pairs(enemies) do
        damageTable.damage = self.damage
        damageTable.victim = enemy
        if self:GetParent():HasModifier("modifier_goku_saiyan") then
            local bonus_damage = self:GetParent():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetSpecialValueFor("merni_attacks_damage")
            damageTable.damage = self.damage + bonus_damage
        end
        ApplyDamage(damageTable)  
        if self:GetCaster():HasTalent("special_bonus_birzha_goku_2") then
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_goku_2")})
        end
    end
    self:GetParent():RemoveNoDraw()
    self:PlayEffects2( point, #enemies )
end

function modifier_goku_merni_attacks:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER,
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
        self:Destroy()
    end
end

function modifier_goku_merni_attacks:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_goku_merni_attacks:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
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

    self:AddParticle(
        effect_cast,
        false,
        false,
        -1,
        false,
        false 
    )
    self:AddParticle(
        effect_cast2,
        false,
        false,
        -1,
        false,
        false 
    )

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

    EmitSoundOn( "Hero_VoidSpirit.Dissimilate.TeleportIn", self:GetParent() )
    if hit>0 then
        EmitSoundOn( "Hero_VoidSpirit.Dissimilate.Stun", self:GetParent() )
    end
end

LinkLuaModifier( "modifier_goku_dragon_punch", "abilities/heroes/goku.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

goku_dragon_punch = class({})

function goku_dragon_punch:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function goku_dragon_punch:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_dragon_punch:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function goku_dragon_punch:OnSpellStart()
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb(self) then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_goku_dragon_punch", { target = self.target } )
    self:GetCaster():EmitSound("GokuThree")
end

modifier_goku_dragon_punch = class({})

function modifier_goku_dragon_punch:IsPurgable() return false end
function modifier_goku_dragon_punch:IsHidden() return true end

function modifier_goku_dragon_punch:OnCreated( kv )
    self.target = self:GetAbility().target
    self.close_distance = 80
    self.far_distance = 900
    self.speed = 1000
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )

    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
    end
end

function modifier_goku_dragon_punch:OnDestroy()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers( true )
    if not self.success then return end

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target )
    ParticleManager:SetParticleControl( particle, 1, self.target:GetOrigin() )
    ParticleManager:ReleaseParticleIndex( particle )

    local damageTable = {
        victim = self.target,
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
    }
    local radius = 0
    if self:GetCaster():HasModifier("modifier_goku_saiyan") and self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetLevel() == 3 then
        radius = 200
    end
    if self:GetCaster():HasModifier("modifier_goku_saiyan") and self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetLevel() == 4 then
        radius = 300
    end
    if self:GetCaster():HasModifier("modifier_goku_saiyan") and self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetLevel() == 5 then
        radius = 400
    end

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(), 
        self.target:GetAbsOrigin(),
        nil,  
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false  
    )

    if self:GetCaster():HasModifier("modifier_goku_saiyan") and self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetLevel() > 2 then
        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
            enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", { duration = self.stun_duration } )
        end
    else
        ApplyDamage(damageTable)
        self.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", { duration = self.stun_duration } )
    end
    local particle = ParticleManager:CreateParticle( "particles/goku_dragon.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 0, self.target, PATTACH_ABSORIGIN_FOLLOW, nil, self.target:GetOrigin(), true  );
    ParticleManager:SetParticleControl( particle, 1, Vector( 200, 200, 200 ) );
    ParticleManager:ReleaseParticleIndex( particle );
end

function modifier_goku_dragon_punch:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }

    return state
end

function modifier_goku_dragon_punch:UpdateHorizontalMotion( me, dt )
    local origin = self:GetParent():GetOrigin()
    if not self.target:IsAlive() or self.target:IsMagicImmune() then
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

function modifier_goku_dragon_punch:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_goku_dragon_punch:EndCharge( success )
    if success then
        self.success = true
    end
    self:Destroy()
end

goku_blink_one = class({})

function goku_blink_one:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function goku_blink_one:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function goku_blink_one:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function goku_blink_one:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
    end
    return true;
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
    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )
    ProjectileManager:ProjectileDodge(self:GetCaster())
    self:PlayEffects( origin, direction )

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(), 
        origin + direction,
        nil,  
        250,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false  
    )

    local damageTable = {
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
        damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
    }

    for _,enemy in pairs(enemies) do
        if self:GetCaster():HasModifier("modifier_goku_saiyan") then
            local bonus_damage = self:GetCaster():FindModifierByName("modifier_goku_saiyan"):GetAbility():GetSpecialValueFor("ability_ido_damage")
            damageTable.damage = bonus_damage
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
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
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
        if self:GetCaster():FindAbilityByName("goku_kamehame"):GetLevel() >= 1 then
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
        local damageTable = {
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
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_goku_3")
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
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
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

        local chance = 0

        if self:GetAbility():GetLevel() == 3 then
            chance = 3
        end
        if self:GetAbility():GetLevel() == 4 then
            chance = 4
        end
        if self:GetAbility():GetLevel() == 5 then
            chance = 5
        end

        if IsInToolsMode() then
            chance = 100
        end

        if hAbility:GetAbilityName() == "goku_kamehame" or hAbility:GetAbilityName() == "goku_merni_attacks" or hAbility:GetAbilityName() == "goku_ki_blast" then
            if RollPseudoRandomPercentage(chance, 3, self:GetParent()) then
                self:GetParent():FindAbilityByName("goku_kamehame"):EndCooldown()
                self:GetParent():FindAbilityByName("goku_merni_attacks"):EndCooldown()
                self:GetParent():FindAbilityByName("goku_ki_blast"):EndCooldown()
                Timers:CreateTimer(0.25, function() hAbility:EndCooldown() end)
            end
        end
    end
        
end

function modifier_goku_saiyan:OnCreated()
    self.amp = self:GetAbility():GetSpecialValueFor("spell_amplify")
    self.speed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    if not IsServer() then return end
    local bonus = self:GetAbility():GetSpecialValueFor("bonus_attribute") / 100
    self.str = self:GetParent():GetStrength() * bonus
    self.agi = self:GetParent():GetAgility() * bonus
    self.int = self:GetParent():GetIntellect() * bonus
    local particle_name
    if self:GetAbility():GetLevel() > 2 then
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

    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(), 
        self:GetParent():GetAbsOrigin(),
        nil,  
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        0,
        false  
    )
   
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
    self.amp = self:GetAbility():GetSpecialValueFor("spell_amplify")
    self.speed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    if not IsServer() then return end
    local bonus = self:GetAbility():GetSpecialValueFor("bonus_attribute") / 100
    self.str = self:GetParent():GetStrength() * bonus
    self.agi = self:GetParent():GetAgility() * bonus
    self.int = self:GetParent():GetIntellect() * bonus
end

function modifier_goku_saiyan:OnDestroy()
    if not IsServer() then return end
    if self:GetAbility():GetLevel() > 2 then
        self:GetParent():SwapAbilities("goku_blink_two", "goku_blink_one", false, true)
        self:GetParent():FindAbilityByName("goku_blink_one"):SetLevel(1)
    end
    ParticleManager:DestroyParticle(self.particle,true)
    ParticleManager:ReleaseParticleIndex(self.particle)
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

function modifier_goku_saiyan:GetModifierMoveSpeedBonus_Percentage()
    return self.speed
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
        self.model = "models/heroes/goku/goku_one.vmdl"
    end
    if self:GetAbility():GetLevel() == 2 then
        self.model = "models/heroes/goku/goku_one.vmdl"
    end
    if self:GetAbility():GetLevel() == 3 then
        self.model = "models/heroes/goku/goku_two.vmdl"
    end
    if self:GetAbility():GetLevel() == 4 then
        self.model = "models/heroes/goku/goku_four.vmdl"
    end
    if self:GetAbility():GetLevel() == 5 then
        self.model = "models/heroes/goku/goku_five.vmdl"
    end
    return self.model
end











goku_ki_blast = class({})

LinkLuaModifier( "modifier_goku_ki_blast", "abilities/heroes/goku", LUA_MODIFIER_MOTION_NONE)

function goku_ki_blast:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function goku_ki_blast:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AOE
end

function goku_ki_blast:OnSpellStart()
    if IsServer() then
        local target = CreateModifierThinker(self:GetCaster(), self, "modifier_goku_ki_blast", nil, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
        local info = {
            EffectName = "particles/ki_blast.vpcf",
            Ability = self,
            iMoveSpeed = 1200,
            Source = self:GetCaster(),
            Target = target,
            iSourceAttachment = self:GetCaster():ScriptLookupAttachment("attach_hitloc")
        }
        ProjectileManager:CreateTrackingProjectile( info )
        EmitSoundOn( "GokuKi", self:GetCaster() )
    end
end

function goku_ki_blast:OnProjectileHit( hTarget, vLocation )
    local caster = self:GetCaster()
    if hTarget ~= nil then
        if IsServer() then
            local effect_fx = ParticleManager:CreateParticle("particles/ki_blast_exp.vpcf", PATTACH_WORLDORIGIN, caster)
            ParticleManager:SetParticleControl(effect_fx, 0, vLocation)
            ParticleManager:SetParticleControl(effect_fx, 1, vLocation)
            ParticleManager:SetParticleControl(effect_fx, 2, vLocation)
            ParticleManager:SetParticleControl(effect_fx, 3, vLocation)
            ParticleManager:SetParticleControl(effect_fx, 4, vLocation)
            local nearby_targets = FindUnitsInRadius(caster:GetTeam(), vLocation, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for i, target in pairs(nearby_targets) do
                local damage = self:GetSpecialValueFor("damage") 
                local damage = {
                    victim = target,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                }
                target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
                ApplyDamage(damage)  
            end
        end
        UTIL_Remove(hTarget)
    end
    return true
end

modifier_goku_ki_blast = class ({})

function modifier_goku_ki_blast:IsHidden()
    return true
end














