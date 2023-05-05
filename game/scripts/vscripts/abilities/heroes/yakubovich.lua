LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Yakubovich_GiftsInTheStudio_vacuum", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_Yakubovich_GiftsInTheStudio_barier", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_NONE)

Yakubovich_GiftsInTheStudio = class({})

function Yakubovich_GiftsInTheStudio:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Yakubovich_GiftsInTheStudio:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Yakubovich_GiftsInTheStudio:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Yakubovich_GiftsInTheStudio:GetAOERadius()
    return self:GetSpecialValueFor("aoe_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_1")
end

function Yakubovich_GiftsInTheStudio:OnSpellStart()
    if not IsServer() then return end
    
    EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Dark_Seer.Vacuum", self:GetCaster())
    
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_POINT, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCursorPosition())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetSpecialValueFor("aoe_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_1"), 1, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("aoe_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)   
    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_Yakubovich_GiftsInTheStudio_vacuum", { duration = 0.5, x = self:GetCursorPosition().x, y = self:GetCursorPosition().y })
    end

    CreateModifierThinker( self:GetCaster(), self, "modifier_Yakubovich_GiftsInTheStudio_barier", {}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
    GridNav:DestroyTreesAroundPoint( self:GetCursorPosition(), self:GetSpecialValueFor("radius_barier"), true )
end

modifier_Yakubovich_GiftsInTheStudio_vacuum = class({})

function modifier_Yakubovich_GiftsInTheStudio_vacuum:IsDebuff() return true end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:OnCreated(params)
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.duration   = params.duration
    self.x          = params.x
    self.y          = params.y
    self.vacuum_pos = GetGroundPosition(Vector(self.x, self.y, 0), nil)
    self.distance   = self:GetParent():GetAbsOrigin() - self.vacuum_pos
    self.speed      = self.distance:Length2D() / self.duration
    if self:ApplyHorizontalMotionController() == false then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local distance = (self.vacuum_pos - me:GetAbsOrigin()):Normalized()
    me:SetOrigin( me:GetAbsOrigin() + distance * self.speed * dt )
end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():SetAbsOrigin(self.vacuum_pos)
    ResolveNPCPositions(self.vacuum_pos, 128)
    
    local damageTable = 
    {
        victim          = self:GetParent(),
        damage          = self.damage,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        attacker        = self.caster,
        ability         = self:GetAbility()
    }
    
    ApplyDamage(damageTable)
end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:CheckState()
    return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_Yakubovich_GiftsInTheStudio_vacuum:GetOverrideAnimation()
     return ACT_DOTA_FLAIL
end

modifier_Yakubovich_GiftsInTheStudio_barier = class({})

function modifier_Yakubovich_GiftsInTheStudio_barier:IsHidden()
    return true
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_Yakubovich_GiftsInTheStudio_barier:OnCreated( kv )
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor( "radius_barier" )
    self.owner = kv.isProvidedByAura~=1
    if self.owner then
        self.delay = 0.5
        self.duration = self:GetAbility():GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_3")
        self:SetDuration( self.delay + self.duration, false )
        self.formed = false
        self:StartIntervalThink( self.delay )
        self:PlayEffects1()
        EmitSoundOn( "Hero_Disruptor.KineticField", self:GetParent() )
    else
        self.aura_origin = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
        self.parent = self:GetParent()
        self.width = 100
        self.max_speed = 550
        self.min_speed = 0.1
        self.max_min = self.max_speed-self.min_speed
        self.inside = (self.parent:GetOrigin()-self.aura_origin):Length2D() < self.radius
    end
end

function modifier_Yakubovich_GiftsInTheStudio_barier:OnDestroy()
    if not IsServer() then return end
    if self.owner then
        StopSoundOn( "Hero_Disruptor.KineticField", self:GetParent() )
        EmitSoundOn( "Hero_Disruptor.KineticField.End", self:GetParent() )
        UTIL_Remove( self:GetParent() )
    end
end

function modifier_Yakubovich_GiftsInTheStudio_barier:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetModifierIncomingDamage_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_6")
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetModifierMoveSpeed_Limit( params )
    if not IsServer() then return end
    if self.owner then return 0 end
    local parent_vector = self.parent:GetOrigin()-self.aura_origin
    local parent_direction = parent_vector:Normalized()
    local actual_distance = parent_vector:Length2D()
    local wall_distance = actual_distance-self.radius
    local over_walls = false
    if self.inside ~= (wall_distance<0) then
        if math.abs( wall_distance )>self.width then
            -- flip
            self.inside = not self.inside
        else
            over_walls = true
        end
    end 

    wall_distance = math.abs(wall_distance)
    if wall_distance>self.width then return 0 end

    local parent_angle = 0
    if self.inside then
        parent_angle = VectorToAngles(parent_direction).y
    else
        parent_angle = VectorToAngles(-parent_direction).y
    end
    local unit_angle = self:GetParent():GetAnglesAsVector().y
    local wall_angle = math.abs( AngleDiff( parent_angle, unit_angle ) )

    local limit = 0
    if wall_angle<=90 then
        if over_walls then
            limit = self.min_speed
        else
            limit = (wall_distance/self.width)*self.max_min + self.min_speed
        end
    else
        limit = 0
    end
    return limit
end

function modifier_Yakubovich_GiftsInTheStudio_barier:OnIntervalThink()
    self:StartIntervalThink( -1 )
    self.formed = true
    self:PlayEffects2()
end

function modifier_Yakubovich_GiftsInTheStudio_barier:IsAura()
    return self.owner and self.formed
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetModifierAura()
    return "modifier_Yakubovich_GiftsInTheStudio_barier"
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetAuraRadius()
    return self.radius
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetAuraDuration()
    return 0.3
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_Yakubovich_GiftsInTheStudio_barier:GetAuraSearchFlags()
    return 0
end

function modifier_Yakubovich_GiftsInTheStudio_barier:PlayEffects1()
    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/disruptor/disruptor_resistive_pinfold/disruptor_ecage_formation.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_Yakubovich_GiftsInTheStudio_barier:PlayEffects2()
    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/disruptor/disruptor_resistive_pinfold/disruptor_ecage_kineticfield.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.duration, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

LinkLuaModifier( "modifier_yakubovich_roll_debuff", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_yakubovich_roll_thinker", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_NONE )

yakubovich_roll = class({})
yakubovich_roll.sub_name = "yakubovich_roll_return"

function yakubovich_roll:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function yakubovich_roll:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function yakubovich_roll:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level) + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_5")
end

function yakubovich_roll:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function yakubovich_roll:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local thinker = CreateModifierThinker( caster, self, "modifier_yakubovich_roll_thinker", { target_x = point.x, target_y = point.y, target_z = point.z}, caster:GetOrigin(), caster:GetTeamNumber(), false )
    local modifier = thinker:FindModifierByName( "modifier_yakubovich_roll_thinker" )
    local sub = caster:FindAbilityByName(self.sub_name)
    sub:SetLevel( 1 )
    caster:SwapAbilities(
        self:GetAbilityName(),
        self.sub_name,
        false,
        true
    )
    self.modifier = modifier
    self.sub = sub
    sub.modifier = modifier
    modifier.sub = sub
    caster:EmitSound("Hero_Shredder.Chakram.Cast")
end

yakubovich_roll_return = class({})

function yakubovich_roll_return:OnSpellStart()
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:ReturnChakram()
    end
end

modifier_yakubovich_roll_thinker = class({})

local MODE_LAUNCH = 0
local MODE_STAY = 1
local MODE_RETURN = 2

function modifier_yakubovich_roll_thinker:IsHidden()
    return true
end

function modifier_yakubovich_roll_thinker:IsPurgable()
    return false
end

function modifier_yakubovich_roll_thinker:OnCreated( kv )
    if not IsServer() then return end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.damage_pass = self:GetAbility():GetSpecialValueFor( "damage" )
    self.damage_stay = self:GetAbility():GetSpecialValueFor( "damage" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.speed = 900
    self.duration = self:GetAbility():GetSpecialValueFor( "pass_slow_duration" )
    self.manacost = self:GetAbility():GetSpecialValueFor( "mana_per_second" )
    self.max_range = self:GetAbility():GetSpecialValueFor( "break_distance" )
    self.interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )

    self.point = Vector( kv.target_x, kv.target_y, kv.target_z )
    self.mode = MODE_LAUNCH
    self.move_interval = FrameTime()
    self.proximity = 50
    self.caught_enemies = {}

    self.damageTable = 
    {
        attacker = self.caster,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }

    self.bonus_damage = 0

    self.parent:SetDayTimeVisionRange( 500 )
    self.parent:SetNightTimeVisionRange( 500 )
    self.damageTable.damage = self.damage_pass
    self:StartIntervalThink( self.move_interval )
    self:PlayEffects1()
end

function modifier_yakubovich_roll_thinker:OnDestroy()
    if not IsServer() then return end

    local main = self:GetAbility()
    if main and (not main:IsNull()) and (not self.sub:IsNull()) then
        local active = main:IsActivated()
        self.caster:SwapAbilities(
            main:GetAbilityName(),
            self.sub:GetAbilityName(),
            active,
            false
        )
    end
    self:StopEffects()
    UTIL_Remove( self.parent )
end

function modifier_yakubovich_roll_thinker:OnIntervalThink()
    if self.mode==MODE_LAUNCH then
        self:LaunchThink()
    elseif self.mode==MODE_STAY then
        self:StayThink()
    elseif self.mode==MODE_RETURN then
        self:ReturnThink()
    end
end

function modifier_yakubovich_roll_thinker:LaunchThink()
    local origin = self.parent:GetOrigin()
    self:PassLogic( origin )
    local close = self:MoveLogic( origin )
    if close then
        self.mode = MODE_STAY
        self.damageTable.damage = self.damage_stay*self.interval
        self:StartIntervalThink( self.interval )
        self:OnIntervalThink()
        self:PlayEffects2()
    end
end

function modifier_yakubovich_roll_thinker:StayThink()
    local origin = self.parent:GetOrigin()
    local mana = self.caster:GetMana()
    if (self.caster:GetOrigin()-origin):Length2D()>self.max_range or mana<self.manacost*self.interval or (not self.caster:IsAlive()) then
        self:ReturnChakram()
        return
    end
    self.caster:SpendMana( self.manacost*self.interval, self:GetAbility() )
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        origin,
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )
    local damage = self.bonus_damage + self.damage_stay
    self.damageTable.damage = damage * self.interval
    for _,enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        ApplyDamage( self.damageTable )
    end
    if #enemies>0 then
        self.bonus_damage = self.bonus_damage + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_8")
    end
    local sound_tree = "Hero_Shredder.Chakram.Tree"
    local trees = GridNav:GetAllTreesAroundPoint( origin, self.radius, true )
    for _,tree in pairs(trees) do
        EmitSoundOnLocationWithCaster( tree:GetOrigin(), sound_tree, self.parent )
    end
    GridNav:DestroyTreesAroundPoint( origin, self.radius, true )
end

function modifier_yakubovich_roll_thinker:ReturnThink()
    local origin = self.parent:GetOrigin()
    self:PassLogic( origin )
    self.point = self.caster:GetOrigin( )
    local close = self:MoveLogic( origin )
    if close then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_yakubovich_roll_thinker:PassLogic( origin )
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        origin,
        nil, 
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )

    for _,enemy in pairs(enemies) do
        if not self.caught_enemies[enemy] then
            self.caught_enemies[enemy] = true
            self.damageTable.victim = enemy
            ApplyDamage( self.damageTable )
            enemy:AddNewModifier(
                self.caster,
                self:GetAbility(),
                "modifier_yakubovich_roll_debuff",
                { duration = self.duration }
            )
            EmitSoundOn( "Hero_Shredder.Chakram.Target", enemy )
        end
    end
    local trees = GridNav:GetAllTreesAroundPoint( origin, self.radius, true )
    for _,tree in pairs(trees) do
        EmitSoundOnLocationWithCaster( tree:GetOrigin(), "Hero_Shredder.Chakram.Tree", self.parent )
    end
    GridNav:DestroyTreesAroundPoint( origin, self.radius, true )
end

function modifier_yakubovich_roll_thinker:MoveLogic( origin )
    local direction = (self.point-origin):Normalized()
    local target = origin + direction * self.speed * self.move_interval
    self.parent:SetOrigin( target )
    return (target-self.point):Length2D()<self.proximity
end

function modifier_yakubovich_roll_thinker:ReturnChakram()
    if self.mode == MODE_RETURN then return end
    self.mode = MODE_RETURN
    self.caught_enemies = {}
    self.damageTable.damage = self.damage_pass
    self:StartIntervalThink( self.move_interval )
    self:PlayEffects3()
end

function modifier_yakubovich_roll_thinker:IsAura()
    return self.mode==MODE_STAY
end

function modifier_yakubovich_roll_thinker:GetModifierAura()
    return "modifier_yakubovich_roll_debuff"
end

function modifier_yakubovich_roll_thinker:GetAuraRadius()
    return self.radius
end

function modifier_yakubovich_roll_thinker:GetAuraDuration()
    return 0.3
end

function modifier_yakubovich_roll_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_yakubovich_roll_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_yakubovich_roll_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_yakubovich_roll_thinker:PlayEffects1()
    local direction = self.point-self.parent:GetOrigin()
    direction.z = 0
    direction = direction:Normalized()
    self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    EmitSoundOn( "Hero_Shredder.Chakram", self.parent )
end

function modifier_yakubovich_roll_thinker:PlayEffects2()
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram_stay.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
end

function modifier_yakubovich_roll_thinker:PlayEffects3()
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControlEnt( self.effect_cast, 1, self.caster, PATTACH_ABSORIGIN_FOLLOW, nil, self.caster:GetOrigin(), true )
    ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( self.speed, 0, 0 ) )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    EmitSoundOn( "Hero_Shredder.Chakram.Return", self.parent )
end

function modifier_yakubovich_roll_thinker:StopEffects()
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    StopSoundOn( "Hero_Shredder.Chakram", self.parent )
end

modifier_yakubovich_roll_debuff = class({})

function modifier_yakubovich_roll_debuff:IsPurgable()
    return false
end

function modifier_yakubovich_roll_debuff:OnCreated( kv )
    if self:GetAbility() and not self:GetAbility():IsNull() then
        self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
    else
        self.slow = 0
    end
    self.step = 5
end

function modifier_yakubovich_roll_debuff:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_yakubovich_roll_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_yakubovich_roll_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

function modifier_yakubovich_roll_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

LinkLuaModifier("modifier_yakubich_stun", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_NONE)

Yakubovich_Really = class({}) 

function Yakubovich_Really:GetIntrinsicModifierName()
    return "modifier_yakubich_stun"
end

function Yakubovich_Really:GetCooldown(level)
    if self:GetCaster():HasShard() then return 0 end
    return self.BaseClass.GetCooldown( self, level )
end

modifier_yakubich_stun = class({}) 

function modifier_yakubich_stun:IsPurgable()
    return false
end

function modifier_yakubich_stun:IsHidden()
    return true
end

function modifier_yakubich_stun:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_yakubich_stun:OnAttackLanded( keys )
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        local chance = self:GetAbility():GetSpecialValueFor("chance")
        local damage = self:GetAbility():GetSpecialValueFor("damage")
        local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_2")
        if not self:GetAbility():IsFullyCastable() then return end
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if RollPercentage(chance) then
            if keys.attacker:IsMagicImmune() then return end
            self:GetAbility():UseResources(false, false, false, true)
            self:GetParent():EmitSound("daladno")
            keys.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration * (1-keys.attacker:GetStatusResistance()) })
            ApplyDamage({ victim = keys.attacker, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() })
            if self:GetCaster():HasTalent("special_bonus_birzha_yakubovich_4") then
                self:GetCaster():Purge(false, true, false, true, true)
            end
        end
    end
end

LinkLuaModifier( "modifier_yakubovich_car", "abilities/heroes/yakubovich.lua", LUA_MODIFIER_MOTION_NONE )

Yakubovich_Car = class({})

function Yakubovich_Car:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Yakubovich_Car:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Yakubovich_Car:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_yakubovich_car", {duration = duration})
    self:GetCaster():EmitSound("zuuscar")
end

modifier_yakubovich_car = class({})

function modifier_yakubovich_car:IsPurgable()  return false end
function modifier_yakubovich_car:AllowIllusionDuplicate() return true end

function modifier_yakubovich_car:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true,}
end

function modifier_yakubovich_car:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }

    return decFuncs
end

function modifier_yakubovich_car:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor('speed')
end

function modifier_yakubovich_car:GetModifierPercentageCooldown()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_yakubovich_7")
end

function modifier_yakubovich_car:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('bonus_intellect')
end

function modifier_yakubovich_car:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor('spell_amp')
end

function modifier_yakubovich_car:GetModifierModelChange()
    return "models/yakub_car.vmdl"
end

function modifier_yakubovich_car:GetModifierModelScale( params )
    return 10
end

LinkLuaModifier( "modifier_yakubovich_roll_debuff_scepter", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_yakubovich_roll_thinker_scepter", "abilities/heroes/yakubovich", LUA_MODIFIER_MOTION_NONE )

yakubovich_roll_scepter = class({})
yakubovich_roll_scepter.sub_name = "yakubovich_roll_return_scepter"

function yakubovich_roll_scepter:OnInventoryContentsChanged()
    for i=0, 8 do
        local item = self:GetCaster():GetItemInSlot(i)
        if item then
            if item.scepter then return end
            if self:GetCaster():HasScepter() then     
                if not self:IsTrained() then
                    self:SetLevel(1)
                    self:SetHidden(false)
                end
            else
                self:SetHidden(true)
            end
            if (item:GetName() == "item_ultimate_scepter" or item:GetName() == "item_ultimate_mem" ) and not item.scepter then
                if self:GetCaster():IsRealHero() then
                    item.scepter = true
                    item:SetSellable(false)
                    item:SetDroppable(false)
                end
            end
        end
    end
end

function yakubovich_roll_scepter:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function yakubovich_roll_scepter:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function yakubovich_roll_scepter:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function yakubovich_roll_scepter:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function yakubovich_roll_scepter:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function yakubovich_roll_scepter:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local thinker = CreateModifierThinker( caster, self, "modifier_yakubovich_roll_thinker_scepter", { target_x = point.x, target_y = point.y, target_z = point.z}, caster:GetOrigin(), caster:GetTeamNumber(), false )
    local modifier = thinker:FindModifierByName( "modifier_yakubovich_roll_thinker_scepter" )
    local sub = caster:FindAbilityByName(self.sub_name)
    sub:SetLevel( 1 )
    caster:SwapAbilities(
        self:GetAbilityName(),
        self.sub_name,
        false,
        true
    )
    self.modifier = modifier
    self.sub = sub
    sub.modifier = modifier
    modifier.sub = sub
    EmitSoundOn( "Hero_Shredder.Chakram.Cast", caster )
end

yakubovich_roll_return_scepter = class({})

function yakubovich_roll_return_scepter:OnSpellStart()
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:ReturnChakram()
    end
end

modifier_yakubovich_roll_thinker_scepter = class({})

local MODE_LAUNCH = 0
local MODE_STAY = 1
local MODE_RETURN = 2

function modifier_yakubovich_roll_thinker_scepter:IsHidden()
    return true
end

function modifier_yakubovich_roll_thinker_scepter:IsPurgable()
    return false
end

function modifier_yakubovich_roll_thinker_scepter:OnCreated( kv )
    if not IsServer() then return end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.damage_pass = self:GetAbility():GetSpecialValueFor( "damage" )
    self.damage_stay = self:GetAbility():GetSpecialValueFor( "damage" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.speed = 900
    self.duration = self:GetAbility():GetSpecialValueFor( "pass_slow_duration" )
    self.manacost = self:GetAbility():GetSpecialValueFor( "mana_per_second" )
    self.max_range = self:GetAbility():GetSpecialValueFor( "break_distance" )
    self.interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )

    self.point = Vector( kv.target_x, kv.target_y, kv.target_z )
    self.mode = MODE_LAUNCH
    self.move_interval = FrameTime()
    self.proximity = 50
    self.caught_enemies = {}
    self.damageTable = {
        attacker = self.caster,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }

    self.parent:SetDayTimeVisionRange( 500 )
    self.parent:SetNightTimeVisionRange( 500 )
    self.damageTable.damage = self.damage_pass
    self:StartIntervalThink( self.move_interval )
    self:PlayEffects1()
end

function modifier_yakubovich_roll_thinker_scepter:OnDestroy()
    if not IsServer() then return end

    local main = self:GetAbility()
    if main and (not main:IsNull()) and (not self.sub:IsNull()) then
        local active = main:IsActivated()
        self.caster:SwapAbilities(
            main:GetAbilityName(),
            self.sub:GetAbilityName(),
            active,
            false
        )
    end
    self:StopEffects()
    UTIL_Remove( self.parent )
end

function modifier_yakubovich_roll_thinker_scepter:OnIntervalThink()
    if self.mode==MODE_LAUNCH then
        self:LaunchThink()
    elseif self.mode==MODE_STAY then
        self:StayThink()
    elseif self.mode==MODE_RETURN then
        self:ReturnThink()
    end
end

function modifier_yakubovich_roll_thinker_scepter:LaunchThink()
    local origin = self.parent:GetOrigin()
    self:PassLogic( origin )
    local close = self:MoveLogic( origin )
    if close then
        self.mode = MODE_STAY
        self.damageTable.damage = self.damage_stay*self.interval
        self:StartIntervalThink( self.interval )
        self:OnIntervalThink()
        self:PlayEffects2()
    end
end

function modifier_yakubovich_roll_thinker_scepter:StayThink()
    local origin = self.parent:GetOrigin()
    local mana = self.caster:GetMana()
    if (self.caster:GetOrigin()-origin):Length2D()>self.max_range or mana<self.manacost*self.interval or (not self.caster:IsAlive()) then
        self:ReturnChakram()
        return
    end
    self.caster:SpendMana( self.manacost*self.interval, self:GetAbility() )
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        origin,
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )
    for _,enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        ApplyDamage( self.damageTable )
    end
    local sound_tree = "Hero_Shredder.Chakram.Tree"
    local trees = GridNav:GetAllTreesAroundPoint( origin, self.radius, true )
    for _,tree in pairs(trees) do
        EmitSoundOnLocationWithCaster( tree:GetOrigin(), sound_tree, self.parent )
    end
    GridNav:DestroyTreesAroundPoint( origin, self.radius, true )
end

function modifier_yakubovich_roll_thinker_scepter:ReturnThink()
    local origin = self.parent:GetOrigin()
    self:PassLogic( origin )
    self.point = self.caster:GetOrigin( )
    local close = self:MoveLogic( origin )
    if close then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_yakubovich_roll_thinker_scepter:PassLogic( origin )
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        origin,
        nil, 
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )

    for _,enemy in pairs(enemies) do
        if not self.caught_enemies[enemy] then
            self.caught_enemies[enemy] = true
            self.damageTable.victim = enemy
            ApplyDamage( self.damageTable )
            enemy:AddNewModifier(
                self.caster,
                self:GetAbility(),
                "modifier_yakubovich_roll_debuff_scepter",
                { duration = self.duration }
            )
            EmitSoundOn( "Hero_Shredder.Chakram.Target", enemy )
        end
    end
    local trees = GridNav:GetAllTreesAroundPoint( origin, self.radius, true )
    for _,tree in pairs(trees) do
        EmitSoundOnLocationWithCaster( tree:GetOrigin(), "Hero_Shredder.Chakram.Tree", self.parent )
    end
    GridNav:DestroyTreesAroundPoint( origin, self.radius, true )
end

function modifier_yakubovich_roll_thinker_scepter:MoveLogic( origin )
    local direction = (self.point-origin):Normalized()
    local target = origin + direction * self.speed * self.move_interval
    self.parent:SetOrigin( target )
    return (target-self.point):Length2D()<self.proximity
end

function modifier_yakubovich_roll_thinker_scepter:ReturnChakram()
    if self.mode == MODE_RETURN then return end
    self.mode = MODE_RETURN
    self.caught_enemies = {}
    self.damageTable.damage = self.damage_pass
    self:StartIntervalThink( self.move_interval )
    self:PlayEffects3()
end

function modifier_yakubovich_roll_thinker_scepter:IsAura()
    return self.mode==MODE_STAY
end

function modifier_yakubovich_roll_thinker_scepter:GetModifierAura()
    return "modifier_yakubovich_roll_debuff_scepter"
end

function modifier_yakubovich_roll_thinker_scepter:GetAuraRadius()
    return self.radius
end

function modifier_yakubovich_roll_thinker_scepter:GetAuraDuration()
    return 0.3
end

function modifier_yakubovich_roll_thinker_scepter:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_yakubovich_roll_thinker_scepter:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_yakubovich_roll_thinker_scepter:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_yakubovich_roll_thinker_scepter:PlayEffects1()
    local direction = self.point-self.parent:GetOrigin()
    direction.z = 0
    direction = direction:Normalized()
    self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/timbersaw/timbersaw_ti9_gold/timbersaw_ti9_chakram_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    EmitSoundOn( "Hero_Shredder.Chakram", self.parent )
end

function modifier_yakubovich_roll_thinker_scepter:PlayEffects2()
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/timbersaw/timbersaw_ti9_gold/timbersaw_ti9_chakram_gold_stay.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
end

function modifier_yakubovich_roll_thinker_scepter:PlayEffects3()
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/timbersaw/timbersaw_ti9_gold/timbersaw_ti9_chakram_gold_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControlEnt( self.effect_cast, 1, self.caster, PATTACH_ABSORIGIN_FOLLOW, nil, self.caster:GetOrigin(), true )
    ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( self.speed, 0, 0 ) )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 0, 0, 0 ) )
    EmitSoundOn( "Hero_Shredder.Chakram.Return", self.parent )
end

function modifier_yakubovich_roll_thinker_scepter:StopEffects()
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    StopSoundOn( "Hero_Shredder.Chakram", self.parent )
end

modifier_yakubovich_roll_debuff_scepter = class({})

function modifier_yakubovich_roll_debuff_scepter:IsPurgable()
    return false
end

function modifier_yakubovich_roll_debuff_scepter:OnCreated( kv )
    if self:GetAbility() and not self:GetAbility():IsNull() then
        self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
    else
        self.slow = 0
    end
    self.step = 5
end

function modifier_yakubovich_roll_debuff_scepter:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_yakubovich_roll_debuff_scepter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_yakubovich_roll_debuff_scepter:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

function modifier_yakubovich_roll_debuff_scepter:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end























