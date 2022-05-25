LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Hovan_Pyramide = class({})

function Hovan_Pyramide:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Hovan_Pyramide:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Hovan_Pyramide:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Hovan_Pyramide:OnSpellStart()
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local info = {
        EffectName = "particles/hovansky/hovan_pyramide.vpcf",
        Ability = self,
        iMoveSpeed = 900,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    self:GetCaster():EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
    ProjectileManager:CreateTrackingProjectile( info )
end

function Hovan_Pyramide:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
        local stun_duration = self:GetSpecialValueFor( "duration" )
        local stun_damage = self:GetSpecialValueFor( "damage" )
        local gold = self:GetSpecialValueFor( "gold" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_1")
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = stun_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        ApplyDamage( damage )
        self:GetCaster():ModifyGold( gold, true, 0 )
        target:ModifyGold( gold * -1, true, 0 )
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
        target:EmitSound("lockjaw_Courier.gold")
    end
    return true
end

LinkLuaModifier("modifier_beer_active",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)

Hovan_DrinkBeer = class({})

function Hovan_DrinkBeer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Hovan_DrinkBeer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Hovan_DrinkBeer:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_beer_active", { duration = duration } )
    if self:GetCaster():HasTalent("special_bonus_birzha_hovan_2") then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_invisible", { duration = duration } )
    end
    self:GetCaster():EmitSound("Hero_Brewmaster.CinderBrew.Cast")
    local particle = ParticleManager:CreateParticle("particles/hovansky/hovan_beer.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControl( particle, 1, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControl( particle, 2, self:GetCaster():GetAbsOrigin() )
end

modifier_beer_active = class({})

function modifier_beer_active:IsPurgable() return true end

function modifier_beer_active:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_beer_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_beer_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
 
    return funcs
end

function modifier_beer_active:GetModifierPreAttack_CriticalStrike()
    self:GetParent():EmitSound("Hero_Brewmaster.Brawler.Crit")
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_brewmaster/brewmaster_drunken_brawler_crit.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle )
    return self:GetAbility():GetSpecialValueFor("crit_multiplier")
end

function modifier_beer_active:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("active_bonus_speed")
end

function modifier_beer_active:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("active_evasion")
end

LinkLuaModifier("modifier_hovan_damage",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hovan_speed",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)

Hovan_ShavermaPatrul = class({})

function Hovan_ShavermaPatrul:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Hovan_ShavermaPatrul:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Hovan_ShavermaPatrul:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():EmitSound("hovanshaverma")
    if self:GetCaster():HasTalent("special_bonus_birzha_hovan_3") then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hovan_damage", { duration = duration } )
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hovan_speed", { duration = duration } )
    else
        if RandomInt(1, 100) <= 50 then
            self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hovan_damage", { duration = duration } )
        else
            self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hovan_speed", { duration = duration } )
        end
    end
end

modifier_hovan_damage = class({})

function modifier_hovan_damage:IsPurgable() return true end

function modifier_hovan_damage:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/econ/items/lycan/ti9_immortal/lycan_ti9_immortal_howl_buff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true)
    self.particle2 = ParticleManager:CreateParticle( "particles/econ/items/lycan/ti9_immortal/lycan_ti9_immortal_howl_buff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.particle2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetOrigin(), true)
end

function modifier_hovan_damage:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle( self.particle, false )
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
    if self.particle2 then
        ParticleManager:DestroyParticle( self.particle2, false )
        ParticleManager:ReleaseParticleIndex(self.particle2)
    end
end

function modifier_hovan_damage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
 
    return funcs
end

function modifier_hovan_damage:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("damage")
end

modifier_hovan_speed = class({})

function modifier_hovan_speed:IsPurgable() return true end

function modifier_hovan_speed:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_dagger_debuff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true)
    self.particle2 = ParticleManager:CreateParticle( "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_dagger_debuff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.particle2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetOrigin(), true)
end

function modifier_hovan_speed:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle( self.particle, false )
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
    if self.particle2 then
        ParticleManager:DestroyParticle( self.particle2, false )
        ParticleManager:ReleaseParticleIndex(self.particle2)
    end
end

function modifier_hovan_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
 
    return funcs
end

function modifier_hovan_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("speed")
end

LinkLuaModifier("modifier_hovan_boom",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hovan_slow_first",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hovan_slow_second",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)

Hovan_GanstaBooms = class({})

function Hovan_GanstaBooms:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Hovan_GanstaBooms:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Hovan_GanstaBooms:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Hovan_GanstaBooms:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Hovan_GanstaBooms:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local duration = 4

    if self:GetCaster():HasShard() then
        duration = 6
    end

    CreateModifierThinker(caster, self, "modifier_hovan_boom", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("hovan")
end

modifier_hovan_boom = class({})

function modifier_hovan_boom:IsHidden() return true end

function modifier_hovan_boom:OnCreated()
    if not IsServer() then return end

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage_first = self:GetAbility():GetSpecialValueFor("damage_first") + self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_4")
    self.damage_second = self:GetAbility():GetSpecialValueFor("damage_second") + self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_4")
    self.damage_shard = 400

    self.boom = 1

    local particle = "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf"

    if self:GetCaster():HasShard() then
        particle = "particles/marker_hovan_shard.vpcf"
    end

    self.marker_particle        = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.marker_particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.marker_particle, 1, Vector(self.radius, 1, self.radius * (-1)))
    self:AddParticle(self.marker_particle, false, false, -1, false, false)
    
    local calldown_first_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(calldown_first_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(calldown_first_particle, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(calldown_first_particle, 5, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(calldown_first_particle)
    
    local calldown_second_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_second.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(calldown_second_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(calldown_second_particle, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(calldown_second_particle)

    if self:GetCaster():HasShard() then
        local calldown_three_particle = ParticleManager:CreateParticle("particles/gyro_calldown_tripple.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(calldown_three_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1")))
        ParticleManager:SetParticleControl(calldown_three_particle, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(calldown_three_particle, 5, Vector(self.radius, self.radius, self.radius))
        ParticleManager:ReleaseParticleIndex(calldown_three_particle)     
    end
    
    self:StartIntervalThink(2)
end

function modifier_hovan_boom:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Gyrocopter.CallDown.Damage")
    local damageTable = { attacker = self:GetCaster(), damage = 0, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() }
    local flag = 0
    if self:GetCaster():HasScepter() then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )

    print(self.boom)

    if self.boom == 1 then
        damageTable.damage = self.damage_first
    elseif self.boom == 2 then
        damageTable.damage = self.damage_second
    elseif self.boom == 3 then
        damageTable.damage = self.damage_shard
    end

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage( damageTable )

        if self.boom == 1 then
            enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_hovan_slow_first", { duration = 2 } )
        elseif self.boom == 2 then
            enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_hovan_slow_second", { duration = 4 } )
        end
    end

    self.boom = self.boom + 1
end

modifier_hovan_slow_first = class({})

function modifier_hovan_slow_first:IsHidden() return true end

function modifier_hovan_slow_first:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_hovan_slow_first:GetModifierMoveSpeedBonus_Percentage()
    return -60
end

modifier_hovan_slow_second = class({})

function modifier_hovan_slow_second:IsHidden() return true end

function modifier_hovan_slow_second:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_hovan_slow_second:GetModifierMoveSpeedBonus_Percentage()
    return -90
end