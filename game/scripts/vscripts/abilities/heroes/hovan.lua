LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Hovan_Pyramide",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)

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
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    self:StartProjectile(target)
end

function Hovan_Pyramide:GetIntrinsicModifierName()
    return "modifier_Hovan_Pyramide"
end

function Hovan_Pyramide:StartProjectile(target)
    if not IsServer() then return end
    local info = 
    {
        EffectName = "particles/hovansky/hovan_pyramide.vpcf",
        Ability = self,
        iMoveSpeed = 900,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    self:GetCaster():EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
    ProjectileManager:CreateTrackingProjectile( info )
end

function Hovan_Pyramide:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
        local stun_duration = self:GetSpecialValueFor( "duration" )
        local stun_damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_2")
        local gold = self:GetSpecialValueFor( "gold" )

        ApplyDamage( { victim = target, attacker = self:GetCaster(), damage = stun_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )

        self:GetCaster():ModifyGold( gold, true, 0 )
        target:ModifyGold( gold * -1, true, 0 )

        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration * (1-target:GetStatusResistance()) })

        target:EmitSound("lockjaw_Courier.gold")
    end
    return true
end

modifier_Hovan_Pyramide = class({})

function modifier_Hovan_Pyramide:IsHidden() return self:GetStackCount() == 0 end
function modifier_Hovan_Pyramide:IsPurgable() return false end
function modifier_Hovan_Pyramide:RemoveOnDeath() return false end

function modifier_Hovan_Pyramide:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_Hovan_Pyramide:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.target:IsBuilding() then return end
    if params.target == params.attacker then return end
    if params.attacker:IsIllusion() then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_hovan_3") then return end
    self:IncrementStackCount()
    if self:GetStackCount() >= self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_3") then
        self:SetStackCount(0)
        self:GetAbility():StartProjectile(params.target)
    end
end

LinkLuaModifier("modifier_beer_active",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beer_active_thinker",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beer_active_debuff",  "abilities/heroes/hovan.lua", LUA_MODIFIER_MOTION_NONE)

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

    if self:GetCaster():HasTalent("special_bonus_birzha_hovan_6") then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_invisible", { duration = duration } )
    end

    self:GetCaster():EmitSound("Hero_Brewmaster.CinderBrew.Cast")

    local particle = ParticleManager:CreateParticle("particles/hovansky/hovan_beer.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControl( particle, 1, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControl( particle, 2, self:GetCaster():GetAbsOrigin() )

    if self:GetCaster():HasTalent("special_bonus_birzha_hovan_1") then
        CreateModifierThinker(self:GetCaster(), self, "modifier_beer_active_thinker", {duration = duration}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
    end
end

modifier_beer_active_thinker = class({})

function modifier_beer_active_thinker:IsHidden() return true end

function modifier_beer_active_thinker:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/brew/hovan_beer_thinker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_1", "value2"), 1, 1 ) )
    self:AddParticle(particle, false, false, -1, false, false )
end

function modifier_beer_active_thinker:IsAura()
    return true
end

function modifier_beer_active_thinker:GetModifierAura()
    return "modifier_beer_active_debuff"
end

function modifier_beer_active_thinker:GetAuraRadius()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_1", "value2")
end

function modifier_beer_active_thinker:GetAuraDuration()
    return 0
end

function modifier_beer_active_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_beer_active_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

modifier_beer_active_debuff = class({})

function modifier_beer_active_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_beer_active_debuff:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_1")
end

function modifier_beer_active_debuff:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_debuff.vpcf"
end

function modifier_beer_active_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_beer_active = class({})

function modifier_beer_active:IsPurgable() return not self:GetCaster():HasTalent("special_bonus_birzha_hovan_5") end

function modifier_beer_active:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_beer_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_beer_active:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
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

function modifier_beer_active:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("active_evasion")
end

function modifier_beer_active:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
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
    local duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_hovan_8")
    self:GetCaster():EmitSound("hovanshaverma")
    if self:GetCaster():HasTalent("special_bonus_birzha_hovan_4") then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hovan_damage", { duration = duration } )
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hovan_speed", { duration = duration } )
    else
        if RollPercentage(50) then
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
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:AddParticle(self.particle2, false, false, -1, false, false)
end

function modifier_hovan_damage:DeclareFunctions()
    local funcs = 
    {
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
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:AddParticle(self.particle2, false, false, -1, false, false)
end

function modifier_hovan_speed:DeclareFunctions()
    local funcs = 
    {
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

    local direction = (point - self:GetCaster():GetAbsOrigin())
    direction.z = 0
    direction = direction:Normalized()

    CreateModifierThinker(caster, self, "modifier_hovan_boom", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)

    if self:GetCaster():HasTalent("special_bonus_birzha_hovan_7") then
        for i = 1, 2 do
            Timers:CreateTimer(0.2*i, function()
                local origin = point + direction * (self:GetSpecialValueFor("radius") / 2 * i)
                CreateModifierThinker(caster, self, "modifier_hovan_boom", {duration = duration, target_point_x = origin.x , target_point_y = origin.y}, origin, caster:GetTeamNumber(), false)
            end)
        end
    end

    caster:EmitSound("hovan")
end

modifier_hovan_boom = class({})

function modifier_hovan_boom:IsHidden() return true end

function modifier_hovan_boom:OnCreated()
    if not IsServer() then return end

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")

    self.boom = 1

    local particle = "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf"

    if self:GetCaster():HasShard() then
        particle = "particles/marker_hovan_shard.vpcf"
    end

    self.marker_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
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
    local damageTable = { attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() }

    local flag = 0
    if self:GetCaster():HasScepter() then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage( damageTable )

        if self.boom == 1 then
            enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_hovan_slow_first", { duration = self:GetAbility():GetSpecialValueFor("duration") * (1-enemy:GetStatusResistance()) } )
        elseif self.boom == 2 then
            enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_hovan_slow_second", { duration = self:GetAbility():GetSpecialValueFor("duration") * (1-enemy:GetStatusResistance()) } )
        end
    end

    self.boom = self.boom + 1
end

modifier_hovan_slow_first = class({})

function modifier_hovan_slow_first:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_hovan_slow_first:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_first")
end

modifier_hovan_slow_second = class({})

function modifier_hovan_slow_second:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_hovan_slow_second:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_second")
end