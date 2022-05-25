LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blue_incision", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )

blue_incision = class({})

function blue_incision:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function blue_incision:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function blue_incision:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function blue_incision:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("Hero_Magnataur.ShockWave.Cast")
    if self.swing_fx then
        ParticleManager:DestroyParticle(self.swing_fx, false)
    end
    return true
end

function blue_incision:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Juggernaut.BladeDance")
    self.swing_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(self.swing_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.swing_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    Timers:CreateTimer(0.2, function()
        if self.swing_fx then
            ParticleManager:DestroyParticle(self.swing_fx, false)
            ParticleManager:ReleaseParticleIndex(self.swing_fx)
        end
    end)
    return true
end

function blue_incision:OnSpellStart()
    if not IsServer() then return end
    local target_loc = self:GetCursorPosition()
    local caster_loc = self:GetCaster():GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,self:GetCaster())
    local speed = 1500
    local radius = 100
    if target_loc == caster_loc then
        direction = self:GetCaster():GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/rino/rino_shock.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = distance,
        fStartRadius        = radius,
        fEndRadius          = radius,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * speed,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }
    ProjectileManager:CreateLinearProjectile(projectile)
end

function blue_incision:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local stun_duration = self:GetSpecialValueFor('stun_duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_2")
        local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_1")
        local duration = self:GetSpecialValueFor('duration')
        target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration})
        ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:AddNewModifier(self:GetCaster(), self, "modifier_blue_incision", {duration = duration})
        target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
        target:EmitSound("Hero_Jakiro.LiquidFire")
        local fire_pfx = ParticleManager:CreateParticle( "particles/rino/rino_shock_debuff.vpcf", PATTACH_ABSORIGIN, target )
        ParticleManager:SetParticleControl( fire_pfx, 0, target:GetAbsOrigin() )
        ParticleManager:SetParticleControl( fire_pfx, 1, Vector(200 * 2,0,0) )
        ParticleManager:ReleaseParticleIndex( fire_pfx )
    end
end

modifier_blue_incision = class({})

function modifier_blue_incision:IsPurgable() return false end
function modifier_blue_incision:IsPurgeException() return true end

function modifier_blue_incision:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor('fire_interval')
    self:StartIntervalThink(interval)
end

function modifier_blue_incision:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor('fire_damage')
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_blue_incision:GetEffectName()
    return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_blue_incision:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

LinkLuaModifier( "modifier_satan_son_aura", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_satan_son_debuff", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )


satan_son_aura = class({})

function satan_son_aura:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function satan_son_aura:GetCastRange(location, target)
     self:GetSpecialValueFor('radius')
end

function satan_son_aura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function satan_son_aura:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_satan_son_aura', {duration = duration})
    self:GetCaster():EmitSound("Hero_EmberSpirit.FireRemnant.Create")
end

modifier_satan_son_aura = class({})

function modifier_satan_son_aura:IsPurgable()
    return false
end

function modifier_satan_son_aura:IsAura()
    return true
end

function modifier_satan_son_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor('radius')
end

function modifier_satan_son_aura:GetModifierAura()
    return "modifier_satan_son_debuff"
end

function modifier_satan_son_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_satan_son_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_satan_son_aura:GetEffectName() return "particles/rino/rino_flameguard2.vpcf" end
function modifier_satan_son_aura:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_satan_son_debuff = class({})

function modifier_satan_son_debuff:IsPurgable()
    return false
end

function modifier_satan_son_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor('interval'))
end

function modifier_satan_son_debuff:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor('damage')
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    self:GetParent():EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function modifier_satan_son_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function modifier_satan_son_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_satan_son_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('slow') + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_3")
end


LinkLuaModifier( "modifier_rin_blackish_modifier", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rin_blackish_Mayta", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rin_blackish_critical", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rin_blackish_movespeed", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )

rin_blackish = class({})

function rin_blackish:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function rin_blackish:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function rin_blackish:OnSpellStart()
    local caster = self:GetCaster()
    local player = caster:GetPlayerID()
    local ability = self
    local level = self:GetLevel()
    local origin = caster:GetAbsOrigin() + RandomVector(100)

    if self.blackish and IsValidEntity(self.blackish) and self.blackish:IsAlive() then
        FindClearSpaceForUnit(self.blackish, origin, true)
        self.blackish:SetHealth(self.blackish:GetMaxHealth())
        self.blackish:EmitSound("Hero_Juggernaut.FortunesTout.Cast.Layer")
    else
        self.blackish = CreateUnitByName("npc_dota_blackkish", origin, true, caster, caster, caster:GetTeamNumber())
        self.blackish:SetControllableByPlayer(player, true)
        self.blackish:AddNewModifier(self:GetCaster(), self, 'modifier_rin_blackish_modifier', {})
        self.blackish:EmitSound("Hero_Juggernaut.FortunesTout.Cast.Layer")
        if self:GetLevel() >= 2 then
          self.blackish:AddAbility("rin_blackish_Mayta")
          self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetLevel(1)
        end
        if self:GetLevel() == 4 then
            self.blackish:AddAbility("rin_blackish_critical")
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetLevel(1)
        end
    end
end

function rin_blackish:OnUpgrade()
     if self.blackish and IsValidEntity(self.blackish) and self.blackish:IsAlive() then
        local caster = self:GetCaster()
        local player = caster:GetPlayerID()
        local ability = self
        local level = self:GetLevel()
        local origin_death = self.blackish:GetAbsOrigin()
        self.blackish:Destroy()
        self.blackish = CreateUnitByName("npc_dota_blackkish", origin_death, true, caster, caster, caster:GetTeamNumber())
        self.blackish:SetControllableByPlayer(player, true)
        self.blackish:AddNewModifier(self:GetCaster(), self, 'modifier_rin_blackish_modifier', {})
        self.blackish:EmitSound("Hero_Juggernaut.FortunesTout.Cast.Layer")
        if self:GetLevel() >= 2 then
          self.blackish:AddAbility("rin_blackish_Mayta")
          self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetLevel(1)
        end
        if self:GetLevel() == 4 then
            self.blackish:AddAbility("rin_blackish_critical")
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetLevel(1)
        end
    end
end

modifier_rin_blackish_modifier = class({})

function modifier_rin_blackish_modifier:IsHidden()
    return true
end

function modifier_rin_blackish_modifier:OnCreated(keys)
    if not IsServer() then return end
    self.b_damage = self:GetAbility():GetSpecialValueFor("base_damage")
    self.b_health = self:GetAbility():GetSpecialValueFor("bonus_health")
    self.b_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
    self.b_speed = self:GetAbility():GetSpecialValueFor("movement_speed")
    self.b_magic = self:GetAbility():GetSpecialValueFor("bonus_magicarmor")
    self.b_regen = self:GetAbility():GetSpecialValueFor("health_regen")
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
    self:GetParent():SetBaseMaxHealth(self.b_health)
    self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor) 
    self:GetParent():SetBaseMoveSpeed(self.b_speed)
    self:GetParent():SetBaseMagicalResistanceValue(self.b_magic)
    self:GetParent():SetBaseHealthRegen(self.b_regen)
    self:GetParent():SetModelScale( self:GetParent():GetModelScale() * (self:GetAbility():GetLevel()*0.5) )
end

function modifier_rin_blackish_modifier:DeclareFunctions()
    return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end

function modifier_rin_blackish_modifier:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_5")
    local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self.damage
    return damage
end

rin_blackish_Mayta = class({})

function rin_blackish_Mayta:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_rin_blackish_Mayta', {duration = self:GetSpecialValueFor('duration')})
end

modifier_rin_blackish_Mayta = class({})

function modifier_rin_blackish_Mayta:OnCreated()
    self:StartIntervalThink(1)
end

function modifier_rin_blackish_Mayta:OnIntervalThink()
    self.mv = RandomInt(-10, 50)
end

function modifier_rin_blackish_Mayta:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_rin_blackish_Mayta:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_rin_blackish_Mayta:GetModifierMoveSpeedBonus_Percentage()
    return self.mv
end

rin_blackish_critical = class({})

function rin_blackish_critical:GetIntrinsicModifierName()
    return "modifier_rin_blackish_critical"
end

modifier_rin_blackish_critical = class({})

function modifier_rin_blackish_critical:IsHidden()
    return true
end

function modifier_rin_blackish_critical:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_rin_blackish_critical:GetModifierPreAttack_CriticalStrike(keys)
    if IsServer() then
        local attacker = keys.attacker
        local target = keys.target
        if attacker == self:GetParent() then
            if target:GetTeamNumber() == self:GetParent():GetTeamNumber() then
                return nil
            end
            if RandomInt(1, 100) <= 15 then  
                target:AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_rin_blackish_movespeed', {duration = self:GetAbility():GetSpecialValueFor('duration')})
                return 200
            end
        end
    end
end

modifier_rin_blackish_movespeed = class({})

function modifier_rin_blackish_movespeed:IsHidden()
    return true
end

function modifier_rin_blackish_movespeed:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_rin_blackish_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

LinkLuaModifier( "modifier_rin_satana_explosion", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )

rin_satana_explosion = class({})

function rin_satana_explosion:GetChannelTime()
    return self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_4")
end

function rin_satana_explosion:OnAbilityPhaseStart()
    if IsServer() then
        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_sandking/sandking_epicenter_tell.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_tail", self:GetCaster():GetOrigin(), true )
        EmitSoundOn( "SandKingBoss.Epicenter.spell", self:GetCaster() )
        self.particle_caster_souls_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl( self.particle_caster_souls_fx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl( self.particle_caster_souls_fx, 1, Vector(lines, 0, 0))
        ParticleManager:SetParticleControl( self.particle_caster_souls_fx, 2, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex( self.particle_caster_souls_fx)
    end
    return true
end

function rin_satana_explosion:OnAbilityPhaseInterrupted()
    if IsServer() then
        if self.nPreviewFX then
            ParticleManager:DestroyParticle( self.nPreviewFX, false )
        end
    end
end

function rin_satana_explosion:GetPlaybackRateOverride()
    return 1
end

function rin_satana_explosion:OnSpellStart()
    if IsServer() then
        self.Projectiles = {}
        if self.nPreviewFX then
            ParticleManager:DestroyParticle( self.nPreviewFX, false )
        end
        local ability = self:GetCaster():FindAbilityByName( "blue_incision" )
        if ability and ability:GetLevel()>0 then
        else
            return
        end
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rin_satana_explosion", {} )
    end
end

function rin_satana_explosion:OnChannelFinish( bInterrupted )
    if IsServer() then
        self:GetCaster():RemoveModifierByName( "modifier_rin_satana_explosion" )
    end
end

function rin_satana_explosion:OnProjectileThinkHandle( nProjectileHandle )
    if IsServer() then
        local projectile = nil
        for _,proj in pairs( self.Projectiles ) do
            if proj ~= nil and proj.handle == nProjectileHandle then
                projectile = proj
            end
        end
        if projectile ~= nil then
            local flRadius = ProjectileManager:GetLinearProjectileRadius( nProjectileHandle )
            ParticleManager:SetParticleControl( projectile.nFXIndex, 2, Vector( flRadius, flRadius, 0 ) )
        end 
    end
end

function rin_satana_explosion:OnProjectileHitHandle( hTarget, vLocation, nProjectileHandle )
    if IsServer() then
        if hTarget ~= nil then
            local blocker_radius = self:GetSpecialValueFor( "blocker_radius" )


            local vFromCaster = vLocation - self:GetCaster():GetOrigin()
            vFromCaster = vFromCaster:Normalized()
            local vToCasterPerp  = Vector( -vFromCaster.y, vFromCaster.x, 0 )
            

            local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self:GetCaster(), blocker_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
            for _,enemy in pairs( enemies ) do
                if enemy ~= nil and enemy:IsInvulnerable() == false and enemy:IsMagicImmune() == false then
                    local nFXIndex = ParticleManager:CreateParticle( "particles/rino/rino_ultimate.vpcf", PATTACH_CUSTOMORIGIN, nil )
                    ParticleManager:SetParticleControl( nFXIndex, 0, enemy:GetOrigin() )
                    ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 300, 0.0, 1.0 ) )
                    ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 300, 0.0, 1.0 ) )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
                    enemy:EmitSound( "Hero_DoomBringer.InfernalBlade.Target" )
                    enemy:EmitSound( "Hero_Techies.LandMine.Detonate" )

                    local stun_duration = 0
                    local damage = 0
                    local ability = self:GetCaster():FindAbilityByName( "blue_incision" )
                    if ability and ability:GetLevel()>0 then
                        damage = ability:GetSpecialValueFor( "damage" )
                        stun_duration = ability:GetSpecialValueFor( "stun_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_2")
                    end
                    enemy:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration})
                    ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
                    enemy:AddNewModifier(self:GetCaster(), ability, "modifier_blue_incision", {duration = 3})
                    enemy:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
                    enemy:EmitSound("Hero_Jakiro.LiquidFire")
                    local fire_pfx = ParticleManager:CreateParticle( "particles/rino/rino_shock_debuff.vpcf", PATTACH_ABSORIGIN, enemy )
                    ParticleManager:SetParticleControl( fire_pfx, 0, enemy:GetAbsOrigin() )
                    ParticleManager:SetParticleControl( fire_pfx, 1, Vector(200 * 2,0,0) )
                    ParticleManager:ReleaseParticleIndex( fire_pfx )
                end
            end
        end

        local projectile = nil
        for _,proj in pairs( self.Projectiles ) do
            if proj ~= nil and proj.handle == nProjectileHandle then
                projectile = proj
            end
        end
        if projectile ~= nil then
            if projectile.nFXIndex then
                ParticleManager:DestroyParticle( projectile.nFXIndex, false )
            end
        end 
    end

    return true
end

modifier_rin_satana_explosion = class({})

function modifier_rin_satana_explosion:IsHidden()
    return true
end

function modifier_rin_satana_explosion:IsPurgable()
    return false
end

function modifier_rin_satana_explosion:OnCreated( kv )
    if IsServer() then
        if self:GetAbility().nCastCount == nil then
            self:GetAbility().nCastCount = 1 
        else
            self:GetAbility().nCastCount = self:GetAbility().nCastCount + 1 
        end
        self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
        self.interval = 0.75
        self.pulse_width = 110
        self.pulse_end_width = 110
        self.pulse_speed = math.min( 1550 + 100 * self:GetAbility().nCastCount, 2000 )
        self.pulse_distance = 5000
        self.random_pulses_step = 3
        self.random_pulses = math.min( 3 + ( self:GetAbility().nCastCount * self.random_pulses_step ), 15 )
        self:StartIntervalThink( self.interval )
        self:GetParent():EmitSound( "rinultimate" )
    end
end

function modifier_rin_satana_explosion:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("rinultimate")
end

function modifier_rin_satana_explosion:CheckState()
    if not self:GetCaster():HasShard() then return end
    local state = {
    [MODIFIER_STATE_MAGIC_IMMUNE] = true}
    
    return state
end

function modifier_rin_satana_explosion:OnIntervalThink()
    if IsServer() then
        local particle_caster_ground_fx2 = ParticleManager:CreateParticle("particles/rino/rino.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle_caster_ground_fx2, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx2)
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        if self:GetCaster():HasScepter() then
            radius = radius + 1500
        end
        local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _,enemy in pairs( enemies ) do
            if enemy ~= nil and not enemy:HasModifier("modifier_fountain_passive_invul") then
                local vDirection = ( enemy:GetOrigin() + RandomVector( 1 ) * self.pulse_width ) - self:GetCaster():GetOrigin()
                vDirection.z = 0.0
                vDirection = vDirection:Normalized()
                local info = 
                {
                    Ability = self:GetAbility(),
                    vSpawnOrigin = self:GetCaster():GetOrigin(), 
                    fStartRadius = self.pulse_width,
                    fEndRadius = self.pulse_end_width,
                    vVelocity = vDirection * self.pulse_speed,
                    fDistance = self.pulse_distance,
                    Source = self:GetCaster(),
                    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                }
                self:GetParent():EmitSound( "Hero_DoomBringer.InfernalBlade.PreAttack" )
                local proj = {}
                proj.handle = ProjectileManager:CreateLinearProjectile( info )
                proj.nFXIndex = ParticleManager:CreateParticle( "particles/rino/rino_shock.vpcf", PATTACH_CUSTOMORIGIN, nil )
                ParticleManager:SetParticleControl( proj.nFXIndex, 0, self:GetParent():GetOrigin() )
                ParticleManager:SetParticleControl( proj.nFXIndex, 1, vDirection * self.pulse_speed )
                ParticleManager:SetParticleControl( proj.nFXIndex, 2, Vector( self.pulse_width, self.pulse_width, 0 ) )
                ParticleManager:SetParticleControl( proj.nFXIndex, 4, Vector( self.pulse_distance / self.pulse_speed + 1, 0, 0 ) )

                table.insert( self:GetAbility().Projectiles, proj )
            end
        end
    end
end





