LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

bullet_taa = class({}) 

function bullet_taa:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function bullet_taa:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bullet_taa:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function bullet_taa:GetAOERadius()
    return self:GetSpecialValueFor( "aoe_radius" )
end

function bullet_taa:OnSpellStart()
    if not IsServer() then return end

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")

    local radius = self:GetSpecialValueFor("aoe_radius")

    local knockback_height = self:GetSpecialValueFor("knockback_height")

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then return end

    self:GetCaster():EmitSound("bullettaa")  

    local particle_start = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle_start, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( particle_start, 1, target, PATTACH_POINT_FOLLOW, "attach_attack2", target:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( particle_start, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle_start )

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do

        local damage_type = DAMAGE_TYPE_MAGICAL

        if self:GetCaster():HasTalent("special_bonus_birzha_bullet_1") then
            damage_type = DAMAGE_TYPE_PHYSICAL
        end

        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = damage_type, ability = self})
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
        ParticleManager:SetParticleControlEnt( particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )

        local distance = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()

        local direction = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()

        local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 50)

        local knockbackProperties =
        {
            center_x = bump_point.x,
            center_y = bump_point.y,
            center_z = bump_point.z,
            duration = 1 * (1 - enemy:GetStatusResistance()),
            knockback_duration = 1 * (1 - enemy:GetStatusResistance()),
            knockback_distance = 50,
            knockback_height = knockback_height
        }

        enemy:RemoveModifierByName("modifier_knockback")

        enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )
    end
end

bullet_sha = class({}) 

function bullet_sha:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_4")
end

function bullet_sha:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bullet_sha:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function bullet_sha:GetAOERadius()
    return self:GetSpecialValueFor( "aoe_radius" )
end

function bullet_sha:OnSpellStart()
    if not IsServer() then return end

    local damage = self:GetSpecialValueFor("damage")

    local radius = self:GetSpecialValueFor("aoe_radius")

    local knockback_distance = self:GetSpecialValueFor("knockback_distance")

    local duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_2")

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then return end

    self:GetCaster():EmitSound("bulletsha")  
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do

        local damage_type = DAMAGE_TYPE_MAGICAL
        
        if self:GetCaster():HasTalent("special_bonus_birzha_bullet_1") then
            damage_type = DAMAGE_TYPE_PHYSICAL
        end

        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = damage_type, ability = self})

        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
        ParticleManager:SetParticleControlEnt( particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )

        local distance = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
        local direction = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + knockback_distance)

        local knockbackProperties =
        {
            center_x = bump_point.x,
            center_y = bump_point.y,
            center_z = bump_point.z,
            duration = 0.75,
            knockback_duration = 0.75,
            knockback_distance = knockback_distance,
            knockback_height = 150
        }

        enemy:RemoveModifierByName("modifier_knockback")

        enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )

        Timers:CreateTimer(0.75, function()
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration * (1 - enemy:GetStatusResistance()) })
        end)
    end
end

LinkLuaModifier("modifier_Bullet_Stats_aura", "abilities/heroes/bullet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Bullet_Stats_aura_debuff", "abilities/heroes/bullet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Bullet_Stats", "abilities/heroes/bullet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Bullet_Stats_debuff", "abilities/heroes/bullet", LUA_MODIFIER_MOTION_NONE)

Bullet_Stats = class({})

function Bullet_Stats:GetIntrinsicModifierName()
    local debuff = self:GetCaster():HasModifier("modifier_Bullet_Stats_aura_debuff")
    if debuff then
        return "modifier_Bullet_Stats_aura_debuff"
    end
    return "modifier_Bullet_Stats_aura"
end

function Bullet_Stats:GetCastRange()
    return self:GetSpecialValueFor("radius")
end

function Bullet_Stats:OnSpellStart()
    if IsServer() then
        if self:GetCaster():HasModifier("modifier_Bullet_Stats_aura") then
            self:GetCaster():RemoveModifierByName("modifier_Bullet_Stats_aura")
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Bullet_Stats_aura_debuff", {})
            self:GetCaster():EmitSound("Hero_Rubick.NullField.Offense")
        elseif self:GetCaster():HasModifier("modifier_Bullet_Stats_aura_debuff") then
            self:GetCaster():RemoveModifierByName("modifier_Bullet_Stats_aura_debuff")
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Bullet_Stats_aura", {})
            self:GetCaster():EmitSound("Hero_Rubick.NullField.Defense")
        end
    end
end

function Bullet_Stats:GetAbilityTextureName()
    local debuff = self:GetCaster():HasModifier("modifier_Bullet_Stats_aura_debuff")
    if debuff then
        return "Bullet/stats"
    end
    return "Bullet/stats_friendly"
end

modifier_Bullet_Stats_aura = modifier_Bullet_Stats_aura or class({})

function modifier_Bullet_Stats_aura:IsAura() return true end
function modifier_Bullet_Stats_aura:IsAuraActiveOnDeath() return false end
function modifier_Bullet_Stats_aura:IsBuff() return false end
function modifier_Bullet_Stats_aura:IsHidden() return true end
function modifier_Bullet_Stats_aura:IsPermanent() return true end
function modifier_Bullet_Stats_aura:IsPurgable() return false end

function modifier_Bullet_Stats_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_Bullet_Stats_aura:GetAuraSearchFlags()
    return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_Bullet_Stats_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_Bullet_Stats_aura:GetAuraSearchType()
    return self:GetAbility():GetAbilityTargetType()
end

function modifier_Bullet_Stats_aura:GetModifierAura()
    return "modifier_Bullet_Stats"
end

function modifier_Bullet_Stats_aura:GetAuraDuration()
    return 0
end

modifier_Bullet_Stats_aura_debuff = class({})

function modifier_Bullet_Stats_aura_debuff:IsAura() return true end
function modifier_Bullet_Stats_aura_debuff:IsAuraActiveOnDeath() return false end
function modifier_Bullet_Stats_aura_debuff:IsBuff() return true end
function modifier_Bullet_Stats_aura_debuff:IsHidden() return true end
function modifier_Bullet_Stats_aura_debuff:IsPermanent() return true end
function modifier_Bullet_Stats_aura_debuff:IsPurgable() return false end

function modifier_Bullet_Stats_aura_debuff:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_Bullet_Stats_aura_debuff:GetAuraSearchFlags()
    return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_Bullet_Stats_aura_debuff:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Bullet_Stats_aura_debuff:GetAuraSearchType()
    return self:GetAbility():GetAbilityTargetType()
end

function modifier_Bullet_Stats_aura_debuff:GetModifierAura()
    return "modifier_Bullet_Stats_debuff"
end

function modifier_Bullet_Stats_aura_debuff:GetAuraDuration()
    return 0
end

modifier_Bullet_Stats = class({})

function modifier_Bullet_Stats:IsHidden() return false end
function modifier_Bullet_Stats:IsPurgable() return false end

function modifier_Bullet_Stats:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_Bullet_Stats:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_6")
end

function modifier_Bullet_Stats:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_6")
end

function modifier_Bullet_Stats:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_6")
end

modifier_Bullet_Stats_debuff = class({})

function modifier_Bullet_Stats_debuff:IsHidden() return false end
function modifier_Bullet_Stats_debuff:IsPurgable() return false end

function modifier_Bullet_Stats_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_Bullet_Stats_debuff:GetModifierBonusStats_Strength()
    return (self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_5")) * -1
end

function modifier_Bullet_Stats_debuff:GetModifierBonusStats_Agility()
    return (self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_5")) * -1
end

function modifier_Bullet_Stats_debuff:GetModifierBonusStats_Intellect()
    return (self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_5")) * -1
end

LinkLuaModifier("modifier_Bullet_BulletInTheHead", "abilities/heroes/bullet", LUA_MODIFIER_MOTION_NONE)

Bullet_BulletInTheHead = class({})

function Bullet_BulletInTheHead:GetBehavior()
    if self:GetCaster():HasShard() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function Bullet_BulletInTheHead:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Bullet_BulletInTheHead:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bullet_BulletInTheHead:GetCastPoint()
    if self:GetCaster():HasScepter() then
        return 0
    else 
        return self.BaseClass.GetCastPoint( self )
    end
end

function Bullet_BulletInTheHead:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Bullet_BulletInTheHead:GetAOERadius()
    if self:GetCaster():HasShard() then
        return self:GetSpecialValueFor("scepter_radius")
    end
    return 0
end

function Bullet_BulletInTheHead:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasTalent("special_bonus_birzha_bullet_7")) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function Bullet_BulletInTheHead:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
    for _,enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_Bullet_BulletInTheHead") then
            enemy:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
        end
    end
end

function Bullet_BulletInTheHead:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)

    if self:GetCaster():HasShard() then
        local point = self:GetCursorPosition()
        self.targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, self:GetSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

        for _, target in pairs(self.targets) do
            target:AddNewModifier(self:GetCaster(), self, "modifier_Bullet_BulletInTheHead", {duration = 4})
        end
        return true
    end

    self.target = self:GetCursorTarget()
    self.target:AddNewModifier(self:GetCaster(), self, "modifier_Bullet_BulletInTheHead", {duration = 4})
    return true
end

function Bullet_BulletInTheHead:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("Ability.Assassinate")

    local info = 
    {
        Source = self:GetCaster(),
        Ability = self, 
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
        iMoveSpeed = 2500,
        bDodgeable = true,
    }

    if self:GetCaster():HasShard() then
        for _,target in pairs(self.targets) do
            info.Target = target
            ProjectileManager:CreateTrackingProjectile(info)
            target:EmitSound("Hero_Sniper.AssassinateProjectile")
        end
        return
    end

    info.Target = self.target
    ProjectileManager:CreateTrackingProjectile(info)
    self.target:EmitSound("Hero_Sniper.AssassinateProjectile")
end

function Bullet_BulletInTheHead:OnProjectileHit_ExtraData( target, location, extradata )
    if target == nil then return end

    if target:HasModifier("modifier_Bullet_BulletInTheHead") then
        target:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
    end

    if target:IsInvulnerable() then return end

    if not self:GetCaster():HasTalent("special_bonus_birzha_bullet_7") then
        if target:IsMagicImmune() then return end
    end

    if target:TriggerSpellAbsorb(self) then return end

    target:EmitSound("Hero_Sniper.AssassinateDamage")

    local damage = self:GetSpecialValueFor("damage")

    if self:GetCaster():HasTalent("special_bonus_birzha_bullet_8") then
        print(target:GetHealthPercent())
        if target:GetHealthPercent() <= self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_8") then
            target:Kill(self, self:GetCaster())
            return
        end
    end

    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})

    if self:GetCaster():HasScepter() then
        local scepter_stun_duration = self:GetSpecialValueFor("scepter_stun_duration")
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = scepter_stun_duration * (1-target:GetStatusResistance())})
    end
end

modifier_Bullet_BulletInTheHead = class({})

function modifier_Bullet_BulletInTheHead:IsPurgable()
    return false
end

function modifier_Bullet_BulletInTheHead:OnCreated( kv )
    if IsServer() then
        local particle = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )
        self:AddParticle(particle, false, false, -1, false, true )
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_Bullet_BulletInTheHead:OnIntervalThink( kv )
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration = FrameTime()+FrameTime()})
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 50, FrameTime()+FrameTime(), false)
    end
end
