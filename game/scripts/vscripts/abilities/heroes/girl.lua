LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )




LinkLuaModifier("modifier_girl_blood_wall_shield_thinker", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_girl_blood_wall_shield_debuff", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)




girl_blood_wall_shield = class({})

function girl_blood_wall_shield:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function girl_blood_wall_shield:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function girl_blood_wall_shield:OnSpellStart()
    if not IsServer() then return end
    local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = (self:GetSpecialValueFor("health_cost") / 100) * self:GetCaster():GetMaxHealth() ,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }
    ApplyDamage(damageTable)

    self:GetCaster():EmitSound("girl_shield_cast")
    if self:GetCaster():HasTalent("special_bonus_birzha_girl_6") then
        CreateModifierThinker( self:GetCaster(), self, "modifier_girl_blood_wall_shield_thinker", { duration = self:GetSpecialValueFor("duration"), talent = true }, self:GetCaster():GetAbsOrigin()-self:GetCaster():GetForwardVector()*150, self:GetCaster():GetTeamNumber(), false )
    end
    CreateModifierThinker( self:GetCaster(), self, "modifier_girl_blood_wall_shield_thinker", { duration = self:GetSpecialValueFor("duration"), talent = false }, self:GetCaster():GetAbsOrigin()+self:GetCaster():GetForwardVector()*150, self:GetCaster():GetTeamNumber(), false )
end

modifier_girl_blood_wall_shield_thinker = class({})

function modifier_girl_blood_wall_shield_thinker:OnCreated( kv )
    local length = 100
    if not IsServer() then return end
    self.talent = kv.talent
    local vector_1 = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0,-90,0), self:GetParent():GetAbsOrigin() + self:GetCaster():GetForwardVector() * length)
    local vector_2 = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0,90,0), self:GetParent():GetAbsOrigin() + self:GetCaster():GetForwardVector() * length)
    local direction = Vector( self:GetCaster():GetForwardVector().x, self:GetCaster():GetForwardVector().y, 0 ):Normalized()

    self.heroes = {}

    if self.talent == 1 then
        Vector( self:GetCaster():GetForwardVector().x * -1, self:GetCaster():GetForwardVector().y * -1, 0 ):Normalized()
    end
    self.origin = vector_1
    self.target = vector_2

    self.effect_cast = ParticleManager:CreateParticle( "particles/girl/shield_wall_of_replica.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.origin )
    ParticleManager:SetParticleControl( self.effect_cast, 1, self.target )
    ParticleManager:SetParticleControl( self.effect_cast, 60, Vector(21, 0, 255) )
    ParticleManager:SetParticleControl( self.effect_cast, 61, Vector(1,1,1) )
    self:StartIntervalThink(FrameTime())
end

function modifier_girl_blood_wall_shield_thinker:OnIntervalThink( kv )
    if not IsServer() then return end

    if self.effect_cast then
        ParticleManager:DestroyParticle(self.effect_cast, false)
    end

    print(self.talent)

    if self.talent == 1 then
        self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin()-self:GetCaster():GetForwardVector()*100)
    else
        self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin()+self:GetCaster():GetForwardVector()*100)
    end

    local vector_1 = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0,-90,0), self:GetParent():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100)
    local vector_2 = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0,90,0), self:GetParent():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100)
    local direction = Vector( self:GetCaster():GetForwardVector().x, self:GetCaster():GetForwardVector().y, 0 ):Normalized()
    if self.talent == 1 then
        Vector( self:GetCaster():GetForwardVector().x * -1, self:GetCaster():GetForwardVector().y * -1, 0 ):Normalized()
    end
    self.origin = vector_1
    self.target = vector_2

    self.effect_cast = ParticleManager:CreateParticle( "particles/girl/shield_wall_of_replica.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self.origin )
    ParticleManager:SetParticleControl( self.effect_cast, 1, self.target )
    ParticleManager:SetParticleControl( self.effect_cast, 60, Vector(21, 0, 255) )
    ParticleManager:SetParticleControl( self.effect_cast, 61, Vector(1,1,1) )

    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_girl_4") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local enemies = FindUnitsInLine(
        self:GetParent():GetTeamNumber(),
        self.origin,
        self.target,
        nil,
        50,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        flag
    )
    for _,enemy in pairs(enemies) do
        if not enemy:HasModifier("modifier_girl_blood_wall_shield_debuff") and not self.heroes[enemy:entindex()] then
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_girl_blood_wall_shield_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
            enemy:EmitSound("girl_shield_target")
            self.heroes[enemy:entindex()] = true
        end
    end
end

function modifier_girl_blood_wall_shield_thinker:OnDestroy( kv )
    if not IsServer() then return end
    if self.effect_cast then
        ParticleManager:DestroyParticle(self.effect_cast, true)
    end
end




modifier_girl_blood_wall_shield_debuff = class({})

function modifier_girl_blood_wall_shield_debuff:OnCreated( kv )
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
    self.damage_reduced = self:GetAbility():GetSpecialValueFor("damage_reduced")
    if not IsServer() then return end
    local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_girl_2"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end

function modifier_girl_blood_wall_shield_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }

    return funcs
end

function modifier_girl_blood_wall_shield_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_girl_blood_wall_shield_debuff:GetModifierDamageOutgoing_Percentage()
    return self.damage_reduced
end










LinkLuaModifier("modifier_girl_charge_of_attack", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_girl_charge_of_attack_caster", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_girl_charge_of_attack_debuff", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)

girl_charge_of_attack = class({})

function girl_charge_of_attack:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function girl_charge_of_attack:GetCastRange(location, target)
    return self:GetSpecialValueFor("range") + self:GetCaster():FindTalentValue("special_bonus_birzha_girl_1")
end

function girl_charge_of_attack:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function girl_charge_of_attack:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()

    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector() * 80
    end

    local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = (self:GetSpecialValueFor("health_cost") / 100) * self:GetCaster():GetMaxHealth() ,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }
    ApplyDamage(damageTable)
    self:GetCaster():EmitSound("girl_vtorii")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_girl_charge_of_attack", {
        x           = point.x,
        y           = point.y,
        z           = point.z
    })


    local enemies = FindUnitsInLine(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        point,
        nil,
        (self:GetCaster():Script_GetAttackRange() / 2),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    )
    for _,enemy in pairs(enemies) do
        point = enemy:GetAbsOrigin()
        break
    end

    local effect_cast = ParticleManager:CreateParticle(  "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        0,
        self:GetCaster(),
        PATTACH_POINT_FOLLOW,
        "attach_attack1",
        self:GetCaster():GetAbsOrigin(),
        true
    )
    ParticleManager:SetParticleControl( effect_cast, 1, point )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_2, 2 )
end

modifier_girl_charge_of_attack = class({})

function modifier_girl_charge_of_attack:IsPurgable() return false end
function modifier_girl_charge_of_attack:IsHidden() return true end

function modifier_girl_charge_of_attack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_girl_charge_of_attack:IgnoreTenacity() return true end
function modifier_girl_charge_of_attack:IsMotionController() return true end
function modifier_girl_charge_of_attack:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_girl_charge_of_attack:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end

function modifier_girl_charge_of_attack:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local max_distance = self:GetAbility():GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() )
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        if distance > max_distance then distance = max_distance end
        self.velocity = 2500
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_girl_charge_of_attack:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end
    self:HorizontalMotion(self:GetParent(), self.frametime)
    local enemies = FindUnitsInLine(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * (self:GetParent():Script_GetAttackRange() / 2),
        nil,
        (self:GetParent():Script_GetAttackRange() / 2),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    )
    for _,enemy in pairs(enemies) do
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_girl_charge_of_attack_caster", {target = enemy:entindex()})
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_girl_charge_of_attack_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
        if not self:IsNull() then
            self:Destroy()
        end
        break
    end
end

function modifier_girl_charge_of_attack:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

modifier_girl_charge_of_attack_caster = class({})

function modifier_girl_charge_of_attack_caster:IsPurgable()
    return false
end

function modifier_girl_charge_of_attack_caster:IsHidden()
    return true
end

function modifier_girl_charge_of_attack_caster:OnCreated(table)
    if not IsServer() then return end
    self.attack = 0
    self.max_attack = self:GetAbility():GetSpecialValueFor("attack_count") + self:GetCaster():FindTalentValue("special_bonus_birzha_girl_3")
    self.target = EntIndexToHScript(table.target)
    self:CritAttack()
end

function modifier_girl_charge_of_attack_caster:CritAttack()
    if not IsServer() then return end
    if self.attack >= self.max_attack then self:SetDuration(0.1, true) return end
    Timers:CreateTimer(0.05, function()
        if self:IsNull() then return end
        if not self.target:IsAlive() then
            if not self:IsNull() then
                self:Destroy()
                return
            end
        end
        self:GetCaster():SetForwardVector((self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized())
        self.attack = self.attack + 1
        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK2, 4)
        local particle = ParticleManager:CreateParticle( "particles/girl/critical_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() )
        ParticleManager:SetParticleControlForward( particle, 1, (self:GetParent():GetAbsOrigin()-self.target:GetAbsOrigin()):Normalized() )
        ParticleManager:ReleaseParticleIndex( particle )
        self:GetCaster():PerformAttack( self.target, false, true, true, false, false, false, true )
        self:CritAttack()
    end)
end

function modifier_girl_charge_of_attack_caster:CheckState()
    if self:GetCaster():HasScepter() then
         return {[MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_DISARMED] = true,}
    end
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end




modifier_girl_charge_of_attack_debuff = class({})

function modifier_girl_charge_of_attack_debuff:IsPurgable()
    return false
end

function modifier_girl_charge_of_attack_debuff:OnCreated( kv )
    self.slow = self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_girl_charge_of_attack_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_girl_charge_of_attack_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

































LinkLuaModifier("modifier_girl_blood_of_blades", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_girl_blood_of_blades_movespeed", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)

girl_blood_of_blades = class({}) 

function girl_blood_of_blades:GetCooldown(level)
    local cooldwn = 0
    if self:GetCaster():HasShard() then
        cooldwn = -4
    end
    return self.BaseClass.GetCooldown( self, level ) + cooldwn
end

function girl_blood_of_blades:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function girl_blood_of_blades:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function girl_blood_of_blades:OnSpellStart()
    if not IsServer() then return end

    local radius_max = self:GetSpecialValueFor("radius_max")
    local radius = self:GetSpecialValueFor("radius")
    if self:GetCaster():HasShard() then
        radius = 600
        radius_max = 600
    end
    self.particle = ParticleManager:CreateParticle("particles/girl/girl_blades_of_blood.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 3, self:GetCaster():GetAbsOrigin())

    local particle = ParticleManager:CreateParticle("particles/girl/girl_three_sphere1.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius_max, radius_max, 1))
    Timers:CreateTimer(4, function ()
        ParticleManager:DestroyParticle(particle, true)
    end)

    self:GetCaster():EmitSound("girl_blades")

    local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = (self:GetSpecialValueFor("health_cost") / 100) * self:GetCaster():GetMaxHealth() ,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }
    ApplyDamage(damageTable)

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        radius_max+100,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )

    local info = {
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "",
        iMoveSpeed = 5000,
        vSourceLoc= self:GetCaster():GetAbsOrigin(), 
        bDodgeable = false,                             
        bVisibleToEnemies = true,                       
        bReplaceExisting = false,                   
        bProvidesVision = false,   
        ExtraData = {
            x = self:GetCaster():GetAbsOrigin().x,
            y = self:GetCaster():GetAbsOrigin().y,
            z = self:GetCaster():GetAbsOrigin().z,
        }                     
    }
    for _,enemy in pairs(enemies) do
        info.Target = enemy
        ProjectileManager:CreateTrackingProjectile(info)
    end
end

function girl_blood_of_blades:OnProjectileHit_ExtraData( target, location, extraData )
    if not target then return end
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_girl_blood_of_blades", {duration = 3, x = extraData.x, y = extraData.y, z = extraData.z,})
end


modifier_girl_blood_of_blades = class({})

function modifier_girl_blood_of_blades:IsPurgable()
    return false
end

function modifier_girl_blood_of_blades:OnCreated( kv )
    self.slow = self:GetAbility():GetSpecialValueFor("slow")
    if not IsServer() then return end
    self.max_damage = self:GetAbility():GetSpecialValueFor("damage")
    self.max_tick_count = 3
    self.damage_tick = self:GetAbility():GetSpecialValueFor("damage") / self.max_tick_count
    self.tick_time = 0
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_tick,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
    }
    self:GetParent():EmitSound("girl_blades_target")
    self.origin = Vector(kv.x,kv.y,kv.z)
    self:StartIntervalThink(FrameTime())
    local effect_cast = ParticleManager:CreateParticle( "particles/girl/debuff_blades_of_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
    self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_girl_blood_of_blades:OnIntervalThink()
    self.tick_time = self.tick_time + FrameTime()

    if self.tick_time >= 1 then
        if self.max_tick_count > 0 then
            self.tick_time = 0
            self.max_tick_count = self.max_tick_count - 1
            self.max_damage = self.max_damage - self.damage_tick
            ApplyDamage( self.damageTable )
        end
    end

    local radius = 500
    if self:GetCaster():HasShard() then
        radius = 600
    end

    if (self.origin - self:GetParent():GetAbsOrigin()):Length2D() >= radius then
        self.damageTable.damage = self.max_damage / 2
        ApplyDamage( self.damageTable )
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        self:GetCaster():Heal(self.max_damage / 2, self:GetAbility())
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_girl_blood_of_blades_movespeed", {duration = duration})
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

modifier_girl_blood_of_blades_movespeed = class({})

function modifier_girl_blood_of_blades_movespeed:IsPurgable()
    return false
end

function modifier_girl_blood_of_blades_movespeed:OnCreated( kv )
    self.slow = self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_girl_blood_of_blades_movespeed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_girl_blood_of_blades_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end



























LinkLuaModifier("modifier_girl_berserkers_mod", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_girl_berserkers_mod_passive", "abilities/heroes/girl.lua", LUA_MODIFIER_MOTION_NONE)

girl_berserkers_mod = class({}) 

function girl_berserkers_mod:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function girl_berserkers_mod:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function girl_berserkers_mod:GetIntrinsicModifierName()
    return "modifier_girl_berserkers_mod_passive"
end

modifier_girl_berserkers_mod_passive = class({})

function modifier_girl_berserkers_mod_passive:IsHidden()
    return false
end

function modifier_girl_berserkers_mod_passive:IsPurgable()
    return false
end

function modifier_girl_berserkers_mod_passive:DestroyOnExpire()
    return false
end

function modifier_girl_berserkers_mod_passive:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return decFuncs
end

function modifier_girl_berserkers_mod_passive:GetModifierPreAttack_BonusDamage()
    local modifier_damage = self:GetStackCount() * ( self:GetAbility():GetSpecialValueFor("bonus_damage_stack") + self:GetCaster():FindTalentValue("special_bonus_birzha_girl_5") )
    return modifier_damage
end




















function girl_berserkers_mod:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_girl_berserkers_mod", {duration = duration})
end

modifier_girl_berserkers_mod = class({})

function modifier_girl_berserkers_mod:IsPurgable()
    return false
end

function modifier_girl_berserkers_mod:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage_base")
    self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    self.health_damage_bonus = self:GetAbility():GetSpecialValueFor("health_damage_bonus")
    if not IsServer() then return end
    self.damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = ((self:GetAbility():GetSpecialValueFor("health_cost") / 100) * self:GetCaster():GetMaxHealth()) * 0.2,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }
    EmitSoundOn("girl_ultimate", self:GetParent())
    self:StartIntervalThink(0.2)
end

function modifier_girl_berserkers_mod:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("girl_ultimate", self:GetParent())
end

function modifier_girl_berserkers_mod:OnIntervalThink()
    if not IsServer() then return end
    ApplyDamage(self.damageTable)
end
    

function modifier_girl_berserkers_mod:CheckState()
    if self:GetCaster():HasTalent("special_bonus_birzha_girl_8") then
        return {}
    end
    return {
        [MODIFIER_STATE_SILENCED] = true,
    }
end
    
function modifier_girl_berserkers_mod:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return decFuncs
end

function modifier_girl_berserkers_mod:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        local mod = self:GetParent():FindModifierByName("modifier_girl_berserkers_mod_passive")
        if mod then
            mod:IncrementStackCount()
        end
    end
end

function modifier_girl_berserkers_mod:GetModifierPreAttack_BonusDamage()
    local bonus_damage = self.damage
    local dmg_health_percent = (math.ceil((100 - self:GetParent():GetHealthPercent()) / self:GetAbility():GetSpecialValueFor("health_perc_bonus"))) * self.health_damage_bonus
    bonus_damage = bonus_damage + dmg_health_percent
    return bonus_damage
end

function modifier_girl_berserkers_mod:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_girl_berserkers_mod:GetEffectName()
    return "particles/girl/berserk_mod_buff.vpcf"
end

function modifier_girl_berserkers_mod:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_girl_berserkers_mod:GetModifierAttackSpeedBonus_Constant()
    if self:GetCaster():HasTalent("special_bonus_birzha_girl_7") then
        local bonus_attackspeed = (math.ceil((100 - self:GetParent():GetHealthPercent()) / self:GetAbility():GetSpecialValueFor("health_perc_bonus"))) * 10
        return bonus_attackspeed
    end
    return 0
end


