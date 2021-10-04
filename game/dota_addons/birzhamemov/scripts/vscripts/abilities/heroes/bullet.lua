LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

bullet_sha = class({}) 

function bullet_sha:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_1")
    local radius = self:GetSpecialValueFor("aoe_radius")
    local knockback_distance = self:GetSpecialValueFor("knockback_distance")
    local duration = self:GetSpecialValueFor("stun_duration")
    if self:GetCursorTarget():TriggerSpellAbsorb( self ) then return end
    self:GetCaster():EmitSound("bulletsha")  
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCursorTarget():GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy );
        ParticleManager:SetParticleControlEnt( particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true );

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
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration})
        end)
    end
end

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
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_2")
    local radius = self:GetSpecialValueFor("aoe_radius")
    local knockback_height = self:GetSpecialValueFor("knockback_height")
    if self:GetCursorTarget():TriggerSpellAbsorb( self ) then return end
    self:GetCaster():EmitSound("bullettaa")  
    local particle_start = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
    ParticleManager:SetParticleControlEnt( particle_start, 0, self:GetCursorTarget(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCursorTarget():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle_start, 1, self:GetCursorTarget(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle_start, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
    ParticleManager:ReleaseParticleIndex( particle_start )

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCursorTarget():GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy );
        ParticleManager:SetParticleControlEnt( particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true );

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
    return 600
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
    return 600
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

modifier_Bullet_Stats_aura_debuff = class({})

function modifier_Bullet_Stats_aura_debuff:IsAura() return true end
function modifier_Bullet_Stats_aura_debuff:IsAuraActiveOnDeath() return false end
function modifier_Bullet_Stats_aura_debuff:IsBuff() return true end
function modifier_Bullet_Stats_aura_debuff:IsHidden() return true end
function modifier_Bullet_Stats_aura_debuff:IsPermanent() return true end
function modifier_Bullet_Stats_aura_debuff:IsPurgable() return false end

function modifier_Bullet_Stats_aura_debuff:GetAuraRadius()
    return 600
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

modifier_Bullet_Stats = class({})

function modifier_Bullet_Stats:IsHidden() return false end
function modifier_Bullet_Stats:IsPurgable() return false end

function modifier_Bullet_Stats:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_Bullet_Stats:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")
end

function modifier_Bullet_Stats:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")
end

function modifier_Bullet_Stats:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")
end

modifier_Bullet_Stats_debuff = class({})

function modifier_Bullet_Stats_debuff:IsHidden() return false end
function modifier_Bullet_Stats_debuff:IsPurgable() return false end

function modifier_Bullet_Stats_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_Bullet_Stats_debuff:GetModifierBonusStats_Strength()
    return (self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")) * (-1)
end

function modifier_Bullet_Stats_debuff:GetModifierBonusStats_Agility()
    return (self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")) * (-1)
end

function modifier_Bullet_Stats_debuff:GetModifierBonusStats_Intellect()
    return (self:GetAbility():GetSpecialValueFor("stat") + self:GetCaster():FindTalentValue("special_bonus_birzha_bullet_3")) * (-1)
end

LinkLuaModifier("modifier_Bullet_BulletInTheHead", "abilities/heroes/bullet", LUA_MODIFIER_MOTION_NONE)

Bullet_BulletInTheHead = class({})

function Bullet_BulletInTheHead:GetBehavior()
    local caster = self:GetCaster()
    local scepter = caster:HasScepter()

    if scepter then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function Bullet_BulletInTheHead:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Bullet_BulletInTheHead:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bullet_BulletInTheHead:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Bullet_BulletInTheHead:GetAOERadius()
    local caster = self:GetCaster()
    local ability = self
    local scepter = caster:HasScepter()
    local scepter_radius = ability:GetSpecialValueFor("scepter_radius")

    if scepter then
        return scepter_radius
    end

    return 0
end

function Bullet_BulletInTheHead:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    local ability = self

    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_Bullet_BulletInTheHead") then
            enemy:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
        end
    end
end

function Bullet_BulletInTheHead:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local ability = self
    local scepter = caster:HasScepter()
    local radius = ability:GetSpecialValueFor("scepter_radius")
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

    if not scepter then
        self.target = self:GetCursorTarget()
        self.target:AddNewModifier(caster, ability, "modifier_Bullet_BulletInTheHead", {duration = 4})
    else
        self.target_point = self:GetCursorPosition()
        self.targets = FindUnitsInRadius(caster:GetTeamNumber(),
            self.target_point,
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false)

        for _,target in pairs(self.targets) do
            target:AddNewModifier(caster, ability, "modifier_Bullet_BulletInTheHead", {duration = 4})
        end
    end

    return true
end

function Bullet_BulletInTheHead:OnSpellStart()
    local caster = self:GetCaster()
    local scepter = caster:HasScepter()
    caster:EmitSound("Ability.Assassinate")

    if not scepter then
        local info = {
            Target = self.target,
            Source = caster,
            Ability = self, 
            bVisibleToEnemies = true,
            bReplaceExisting = false,
            bProvidesVision = false,
            EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
            iMoveSpeed = 2500,
            bDodgeable = true,
            ExtraData = { modifier = "modifier_Bullet_BulletInTheHead" }
        }

        ProjectileManager:CreateTrackingProjectile(info)
        self.target:EmitSound("Hero_Sniper.AssassinateProjectile")
    else
        for _,target in pairs(self.targets) do
            local info = {
                Target = target,
                Source = caster,
                Ability = self, 
                bVisibleToEnemies = true,
                bReplaceExisting = false,
                bProvidesVision = false,
                EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
                iMoveSpeed = 2500,
                bDodgeable = true,
                ExtraData = { modifier = "modifier_Bullet_BulletInTheHead" }
            }

            ProjectileManager:CreateTrackingProjectile(info)
            target:EmitSound("Hero_Sniper.AssassinateProjectile")
        end
    end
end

function Bullet_BulletInTheHead:OnProjectileHit_ExtraData( target, location, extradata )
    if (not target) or target:IsInvulnerable() or target:IsOutOfGame() or target:TriggerSpellAbsorb( self ) then
        if target:HasModifier("modifier_Bullet_BulletInTheHead") then
            target:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
        end
        return
    end
    local scepter = self:GetCaster():HasScepter()
    local damage = self:GetSpecialValueFor("damage")
    if not scepter then
        if not target:IsMagicImmune() then
            local damageTable = {victim = target,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self
            }

            ApplyDamage(damageTable)
        end
    else
        local hptargetfull = target:GetMaxHealth() / 100 * 50 
        local hptarget = target:GetHealth()
        if  hptarget < hptargetfull then
            local damageTable = {victim = target,
                attacker = self:GetCaster(),
                damage = 1000000,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                ability = self
            }

            ApplyDamage(damageTable)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)
        end
        if  hptarget > hptargetfull then
            local damageTable = {victim = target,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                ability = self
            }
            ApplyDamage(damageTable)
        end
    end

    target:EmitSound("Hero_Sniper.AssassinateDamage")
    target:Interrupt()
    if target:HasModifier("modifier_Bullet_BulletInTheHead") then
        target:RemoveModifierByName("modifier_Bullet_BulletInTheHead")
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
    end
end

function modifier_Bullet_BulletInTheHead:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    }

    return funcs
end

function modifier_Bullet_BulletInTheHead:GetModifierProvidesFOWVision()
    return true
end

function modifier_Bullet_BulletInTheHead:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }

    return state
end
