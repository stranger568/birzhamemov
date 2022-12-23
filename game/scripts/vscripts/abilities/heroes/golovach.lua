LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_LenaGolovach_Donate_aura", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_LenaGolovach_Donate", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE )

LenaGolovach_Donate = class({})

function LenaGolovach_Donate:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function LenaGolovach_Donate:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_LenaGolovach_Donate_aura"
end

modifier_LenaGolovach_Donate_aura = class({})

function modifier_LenaGolovach_Donate_aura:IsAura()
    return true
end

function modifier_LenaGolovach_Donate_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor('radius')
end

function modifier_LenaGolovach_Donate_aura:IsHidden()
    return true
end

function modifier_LenaGolovach_Donate_aura:GetModifierAura()
    return "modifier_LenaGolovach_Donate"
end

function modifier_LenaGolovach_Donate_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_LenaGolovach_Donate_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_LenaGolovach_Donate_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_LenaGolovach_Donate = class({})

function modifier_LenaGolovach_Donate:OnCreated()
    self:StartIntervalThink(0.5)
end

function modifier_LenaGolovach_Donate:OnIntervalThink()
    local donatecaster = self:GetAbility():GetSpecialValueFor( "money" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_2")
    local donatetarget = -self:GetAbility():GetSpecialValueFor( "money" ) - self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_2")
    if not IsServer() then return end
    if self:GetCaster():PassivesDisabled() then return end
    if self:GetParent():IsRealHero() then
        self:GetCaster():ModifyGold(donatecaster, false, 0)
        self:GetParent():ModifyGold(donatetarget, false, 0)
    end
end

LinkLuaModifier( "modifier_taunt_golovach", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_taunt_golovach_target", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_golovach_rocket", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)

LenaGolovach_taunt = class({})

function LenaGolovach_taunt:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function LenaGolovach_taunt:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function LenaGolovach_taunt:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function LenaGolovach_taunt:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function LenaGolovach_taunt:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    local position = caster:GetAbsOrigin()

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_1")

    local taunt = CreateUnitByName("npc_dota_golovach_taunt", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())

    local playerID = caster:GetPlayerID()

    taunt:SetControllableByPlayer(playerID, true)
    taunt:SetOwner(caster)
    taunt:AddNewModifier( self:GetCaster(), self, "modifier_taunt_golovach", {} )
    taunt:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})

    if self:GetCaster():HasScepter() then
        local golovach_rocket = self:GetCaster():FindAbilityByName("golovach_rocket")
        if golovach_rocket and golovach_rocket:GetLevel() > 0 then
            taunt:AddNewModifier(self:GetCaster(), golovach_rocket, "modifier_golovach_rocket", {})
        end
    end

    local particle = ParticleManager:CreateParticle("particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_attack_blur_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, taunt)
    ParticleManager:SetParticleControl(particle, 0, taunt:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    taunt:EmitSound("golovachtaunt")
end

modifier_taunt_golovach = class({})

function modifier_taunt_golovach:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_taunt_golovach:IsHidden()
    return true
end

function modifier_taunt_golovach:IsPurgable() return false end

function modifier_taunt_golovach:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true, 
    }
end

function modifier_taunt_golovach:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,        
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return decFuncs
end

function modifier_taunt_golovach:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_taunt_golovach:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_taunt_golovach:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_taunt_golovach:GetDisableHealing()
    return 1
end

function modifier_taunt_golovach:OnIntervalThink()
    if not IsServer() then return end

    local radius = self:GetAbility():GetSpecialValueFor("radius")

    local caster_particle = ParticleManager:CreateParticle( "particles/golovach_taunt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(caster_particle, 2, Vector(0, 0, 0))
    ParticleManager:ReleaseParticleIndex(caster_particle)

    self:GetParent():EmitSound("Hero_Tinker.LaserImpact")

    local flag = 0

    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, flag, FIND_ANY_ORDER, false)

    for _,unit in pairs(targets) do
        if not unit:IsDuel() then
            unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_taunt_golovach_target", {duration = 1})
        end
    end
end

function modifier_taunt_golovach:OnDestroy()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")

    self.tauntdeath = ParticleManager:CreateParticle("particles/units/heroes/hero_shredder/shredder_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.tauntdeath, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(self.tauntdeath)

    if self:GetCaster():HasTalent("special_bonus_birzha_golovach_5") then
        local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
        for _,unit in pairs(targets) do
            local damage = self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_5") / 100 * unit:GetMaxHealth()
            ApplyDamage({attacker = self:GetCaster(), victim = unit, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end
end

function modifier_taunt_golovach:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.unit
    local original_damage = keys.original_damage
    local damage_type = keys.damage_type
    local damage_flags = keys.damage_flags
    if not self:GetCaster():HasTalent("special_bonus_birzha_golovach_7") then return end
    if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then  
        EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
        ApplyDamage({ victim = keys.attacker, damage = keys.original_damage / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_7"), damage_type = keys.damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, attacker = self:GetParent(), ability = self:GetAbility() })
    end
end


modifier_taunt_golovach_target = class({})

function modifier_taunt_golovach_target:OnCreated()
    if not IsServer() then return end
    self:GetParent():MoveToTargetToAttack(self:GetCaster())
    self:StartIntervalThink(FrameTime())
end

function modifier_taunt_golovach_target:OnIntervalThink( kv )
    if not IsServer() then return end
    self:GetParent():MoveToTargetToAttack(self:GetCaster())
    if self:GetCaster():HasModifier("modifier_fountain_passive_invul") or (not self:GetCaster():IsAlive()) then
        self:Destroy()
    end
end

function modifier_taunt_golovach_target:IsHidden()
    return true
end

function modifier_taunt_golovach_target:IsPurgable()
    return false
end

function modifier_taunt_golovach_target:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true
    }
    return state
end

function modifier_taunt_golovach_target:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_taunt_golovach_target:OnDeath(event)
    if not IsServer() then return end
    if event.unit == self:GetCaster() then
        self:Destroy()
    end
end

function modifier_taunt_golovach_target:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget(nil)
end

golovach_rocket = class({})

function golovach_rocket:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function golovach_rocket:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function golovach_rocket:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_golovach_rocket", { duration = duration } )
    self:GetCaster():EmitSound("golovachrocket")
end

modifier_golovach_rocket = class({})

function modifier_golovach_rocket:IsPurgable()
    return true
end

function modifier_golovach_rocket:OnCreated()
    self:StartIntervalThink(0.8)
end

function modifier_golovach_rocket:OnIntervalThink()
    local caster = self:GetParent()
    local caster_loc = caster:GetAbsOrigin()
    local damage = self:GetAbility():GetSpecialValueFor("damage") 
    local agi_multi = self:GetAbility():GetSpecialValueFor("agi_bonus") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_6")
    local full_damage = damage + (damage * ( self:GetCaster():GetAgility() /100 * agi_multi ) )
    local vision_radius = self:GetAbility():GetSpecialValueFor("vision_radius")
    local range = self:GetAbility():GetCastRange(caster_loc,caster)

    if not IsServer() then return end

    caster:EmitSound("hero_tinker.Heat-Seeking_Missile")

    local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, self:GetAbility():GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if #heroes == 0 then

        local dud_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missile_dud.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControlEnt(dud_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster_loc, true)
        ParticleManager:ReleaseParticleIndex(dud_pfx)
        caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile_Dud")
        return nil
    end

    local hero_projectile = 
    {
        Target              = heroes[1],
        Source              = caster,
        Ability             = self:GetAbility(),
        EffectName          = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
        bDodgeable          = true,
        bProvidesVision     = false,
        iMoveSpeed          = 900,
        iSourceAttachment   = caster:ScriptLookupAttachment("attach_attack2"),
        ExtraData           = {damage = full_damage, vision_radius = vision_radius, vision_duration = vision_duration, range = range, speed = 900, cast_origin_x = caster_loc.x, cast_origin_y = caster_loc.y}
    }

    ProjectileManager:CreateTrackingProjectile(hero_projectile)

    if self:GetCaster():HasTalent("special_bonus_birzha_golovach_3") then
        if heroes[2] ~= nil then
            hero_projectile.Target = heroes[2]
            ProjectileManager:CreateTrackingProjectile(hero_projectile)
        end
        if heroes[3] ~= nil then
            hero_projectile.Target = heroes[2]
            ProjectileManager:CreateTrackingProjectile(hero_projectile)
        end
    end
end

function golovach_rocket:OnProjectileHit_ExtraData(target, location, ExtraData)
    local caster = self:GetCaster()
    if target and ( not target:IsMagicImmune() ) then
        local damage = ExtraData.damage             
        ApplyDamage({attacker = caster, victim = target, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
        local explosion_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_ABSORIGIN, caster)

        local stun = self:GetSpecialValueFor("stun_time")

        if self:GetCaster():HasShard() then
            target:AddNewModifier(caster, self, "modifier_birzha_stunned", {duration = stun * (1-target:GetStatusResistance())})
        end

        ParticleManager:SetParticleControlEnt(explosion_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", location, true)
        ParticleManager:ReleaseParticleIndex(explosion_pfx)

        target:EmitSound("Hero_Tinker.Heat-Seeking_Missile.Impact")
    end
end


LinkLuaModifier("modifier_LenaGolovach_Radio_damage", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LenaGolovach_Radio_movespeed", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LenaGolovach_Radio_health", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LenaGolovach_Radio_baseattack", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_LenaGolovach_Radio_god", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)

LenaGolovach_Radio = class({})

modifier_LenaGolovach_Radio_damage = class({})
modifier_LenaGolovach_Radio_movespeed = class({})
modifier_LenaGolovach_Radio_health = class({})
modifier_LenaGolovach_Radio_baseattack = class({})
modifier_LenaGolovach_Radio_god = class({})

function LenaGolovach_Radio:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_4")
end

function LenaGolovach_Radio:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_8")

    local modifiers = 
    {
        "modifier_LenaGolovach_Radio_damage",
        "modifier_LenaGolovach_Radio_movespeed",
        "modifier_LenaGolovach_Radio_health",
        "modifier_LenaGolovach_Radio_baseattack",
    }

    for i = 0, 1 do
        caster:AddNewModifier( caster, self, table.remove(modifiers, RandomInt(1, #modifiers)), { duration = duration } )   
    end
    
    caster:EmitSound("golovachsmeh") 
end

function modifier_LenaGolovach_Radio_damage:IsPurgable() return false end
function modifier_LenaGolovach_Radio_movespeed:IsPurgable() return false end
function modifier_LenaGolovach_Radio_health:IsPurgable() return false end
function modifier_LenaGolovach_Radio_baseattack:IsPurgable() return false end
function modifier_LenaGolovach_Radio_god:IsPurgable() return false end

function modifier_LenaGolovach_Radio_damage:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_LenaGolovach_Radio_damage:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_LenaGolovach_Radio_movespeed:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }
end

function modifier_LenaGolovach_Radio_movespeed:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_LenaGolovach_Radio_health:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
end

function modifier_LenaGolovach_Radio_health:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("health")
end

function modifier_LenaGolovach_Radio_baseattack:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }
end

function modifier_LenaGolovach_Radio_baseattack:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("base_attack")
end
