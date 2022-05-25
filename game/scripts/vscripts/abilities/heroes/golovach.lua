LinkLuaModifier("modifier_golovach_rocket", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

golovach_rocket = class({})

function golovach_rocket:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function golovach_rocket:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function golovach_rocket:OnSpellStart()
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_golovach_rocket", { duration = 4 } )
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
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_2")
    local agi_multi = self:GetAbility():GetSpecialValueFor("agi_bonus")
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
    if heroes[2] ~= nil then
        hero_projectile.Target = heroes[2]
        ProjectileManager:CreateTrackingProjectile(hero_projectile)
    end
end

function golovach_rocket:OnProjectileHit_ExtraData(target, location, ExtraData)
    local caster = self:GetCaster()
    if target and ( not target:IsMagicImmune() ) then
        local damage = ExtraData.damage             
        ApplyDamage({attacker = caster, victim = target, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
        local explosion_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_ABSORIGIN, caster)
        local stun = self:GetSpecialValueFor("stun_time") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_3")
        target:AddNewModifier(caster, self, "modifier_birzha_stunned", {duration = stun})
        ParticleManager:SetParticleControlEnt(explosion_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", location, true)
        ParticleManager:ReleaseParticleIndex(explosion_pfx)
        target:EmitSound("Hero_Tinker.Heat-Seeking_Missile.Impact")
    end
end


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
    local donatecaster = self:GetAbility():GetSpecialValueFor( "money" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_1")
    local donatetarget = -self:GetAbility():GetSpecialValueFor( "money" ) - self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_1")
    if not IsServer() then return end
    if self:GetParent():GetUnitName() == "npc_dota_hero_bounty_hunter" then return end
    if self:GetCaster():PassivesDisabled() then return end
    self:GetCaster():ModifyGold(donatecaster, false, 0)
    self:GetParent():ModifyGold(donatetarget, false, 0)
    if self:GetCaster():IsInvisible() then return end
    SendOverheadEventMessage(self:GetCaster(), OVERHEAD_ALERT_GOLD, self:GetCaster(), donatecaster, nil)
end


LenaGolovach_taunt = class({})

LinkLuaModifier( "modifier_taunt_golovach", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_taunt_golovach_target", "abilities/heroes/golovach.lua", LUA_MODIFIER_MOTION_NONE )

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
    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_4")
    local taunt = CreateUnitByName("npc_dota_golovach_taunt", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    local playerID = caster:GetPlayerID()
    taunt:SetControllableByPlayer(playerID, true)
    taunt:SetOwner(caster)
    taunt:AddNewModifier( self:GetCaster(), self, "modifier_taunt_golovach", {} )
    taunt:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    self.tauntspawn= ParticleManager:CreateParticle("particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_attack_blur_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, taunt)
    ParticleManager:SetParticleControl(self.tauntspawn, 0, taunt:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(self.tauntspawn)
    taunt:EmitSound("golovachtaunt")
    Timers:CreateTimer(duration-0.5, function()
        self.tauntdeath= ParticleManager:CreateParticle("particles/units/heroes/hero_shredder/shredder_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, taunt)
        ParticleManager:SetParticleControl(self.tauntdeath, 0, taunt:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(self.tauntdeath)
    end)
end

modifier_taunt_golovach = class({})

function modifier_taunt_golovach:OnCreated()
    self:StartIntervalThink(0.5)
end

function modifier_taunt_golovach:IsHidden()
    return true
end

function modifier_taunt_golovach:CheckState()
    return {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_OUT_OF_GAME] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
end

function modifier_taunt_golovach:OnIntervalThink()
    if not IsServer() then return end
    local caster_particle = ParticleManager:CreateParticle( "particles/golovach_taunt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(caster_particle, 2, Vector(0, 0, 0))
    ParticleManager:ReleaseParticleIndex(caster_particle)
    self:GetParent():EmitSound("Hero_Tinker.LaserImpact")

    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
    self:GetParent():GetAbsOrigin(),
    nil,
    300,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    0,
    FIND_ANY_ORDER,
    false)

    for _,unit in pairs(targets) do
        if not unit:IsDuel() then
            unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_taunt_golovach_target", {duration = 1})
        end
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
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_taunt_golovach_target:IsHidden()
    return true
end

function modifier_taunt_golovach_target:IsPurgable()
    return false
end

function modifier_taunt_golovach_target:CheckState()
    local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    [MODIFIER_STATE_TAUNTED] = true,}
    return state
end

function modifier_taunt_golovach_target:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_taunt_golovach_target:OnDeath(event)
    if event.unit == self:GetCaster() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_taunt_golovach_target:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget(nil)
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

function LenaGolovach_Radio:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_golovach_5")

    local modifiers = {
        "modifier_LenaGolovach_Radio_damage",
        "modifier_LenaGolovach_Radio_movespeed",
        "modifier_LenaGolovach_Radio_health",
        "modifier_LenaGolovach_Radio_baseattack",
        "modifier_LenaGolovach_Radio_god",
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
return {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
}
end

function modifier_LenaGolovach_Radio_damage:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_LenaGolovach_Radio_movespeed:DeclareFunctions()
return {
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
}
end

function modifier_LenaGolovach_Radio_movespeed:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_LenaGolovach_Radio_health:DeclareFunctions()
return {
    MODIFIER_PROPERTY_HEALTH_BONUS
}
end

function modifier_LenaGolovach_Radio_health:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("health")
end

function modifier_LenaGolovach_Radio_baseattack:DeclareFunctions()
return {
    MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
}
end

function modifier_LenaGolovach_Radio_baseattack:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("base_attack")
end
