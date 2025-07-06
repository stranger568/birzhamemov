LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blue_incision", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blue_incision_buff", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )

blue_incision = class({})

function blue_incision:Precache(context)
    PrecacheResource("model", "models/update_heroes/rin/rin.vmdl", context)
    local particle_list = 
    {
        "particles/rino/rino_shock.vpcf",
        "particles/rino/rino_shock_debuff.vpcf",
        "particles/rino/rino_flameguard2.vpcf",
        "particles/rino/rino.vpcf",
        "particles/rino/rino.vpcf",
        "particles/rino/rino_shock.vpcf",
        "particles/rino/rino_ultimate.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function blue_incision:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_3")
end

function blue_incision:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function blue_incision:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function blue_incision:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("Hero_Juggernaut.BladeDance")
    return true
end

function blue_incision:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Juggernaut.BladeDance")
    return true
end

function blue_incision:OnSpellStart()
    if not IsServer() then return end
    local target_loc = self:GetCursorPosition()
    local caster_loc = self:GetCaster():GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,self:GetCaster())

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
        fStartRadius        = 100,
        fEndRadius          = 100,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1500,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }

    ProjectileManager:CreateLinearProjectile(projectile)
end

function blue_incision:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local stun_duration = self:GetSpecialValueFor('stun_duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_2")
        local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_1")
        target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration * (1-target:GetStatusResistance()) })
        ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
        target:EmitSound("Hero_Jakiro.LiquidFire")
        local fire_pfx = ParticleManager:CreateParticle( "particles/rino/rino_shock_debuff.vpcf", PATTACH_ABSORIGIN, target )
        ParticleManager:SetParticleControl( fire_pfx, 0, target:GetAbsOrigin() )
        ParticleManager:SetParticleControl( fire_pfx, 1, Vector(200 * 2,0,0) )
        ParticleManager:ReleaseParticleIndex( fire_pfx )
        if self:GetCaster():HasTalent("special_bonus_birzha_rin_8") then
            self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
        end
        if self:GetCaster():HasShard() then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_blue_incision_buff", {duration = self:GetSpecialValueFor("bonus_shard_duration")})
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_blue_incision", {duration = self:GetSpecialValueFor("bonus_shard_duration")})
        end
    end
end

modifier_blue_incision = class({})

function modifier_blue_incision:IsPurgable() return false end
function modifier_blue_incision:IsHidden() return self:GetStackCount() == 0 end
function modifier_blue_incision:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end
function modifier_blue_incision:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetCaster():FindAllModifiersByName("modifier_blue_incision_buff")
    self:SetStackCount(#modifier)
end
function modifier_blue_incision:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end
function modifier_blue_incision:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_shard_damage") 
end

modifier_blue_incision_buff = class({})
function modifier_blue_incision_buff:IsHidden() return true end
function modifier_blue_incision_buff:IsPurgable() return false end
function modifier_blue_incision_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

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

function modifier_satan_son_aura:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function modifier_satan_son_aura:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
end

modifier_satan_son_debuff = class({})

function modifier_satan_son_debuff:IsPurgable()
    return false
end

function modifier_satan_son_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor('interval'))
end

function modifier_satan_son_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_6")
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_satan_son_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_satan_son_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('slow')
end


LinkLuaModifier( "modifier_rin_blackish_modifier", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rin_blackish_Mayta", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rin_blackish_critical", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )

rin_blackish = class({})

function rin_blackish:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_rin_4")
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
            self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetLevel(1)
        else
            self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetLevel(0)
            self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetActivated(false)
        end
        if self:GetLevel() == 4 then
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetLevel(1)
        else
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetLevel(0)
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetActivated(false)
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
            self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetLevel(1)
        else
            self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetLevel(0)
            self.blackish:FindAbilityByName("rin_blackish_Mayta"):SetActivated(false)
        end
        if self:GetLevel() == 4 then
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetLevel(1)
        else
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetLevel(0)
            self.blackish:FindAbilityByName("rin_blackish_critical"):SetActivated(false)
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
    self:GetParent():SetModelScale( self:GetParent():GetModelScale() + (self:GetAbility():GetLevel()*0.15) )
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
    self.mv = RandomInt(self:GetAbility():GetSpecialValueFor("move_slow"), self:GetAbility():GetSpecialValueFor("move_up"))
end

function modifier_rin_blackish_Mayta:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
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
    if not IsServer() then return end
    if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then  
        return self:GetAbility():GetSpecialValueFor("crit")
    end
end

LinkLuaModifier( "modifier_rin_satana_explosion", "abilities/heroes/rin.lua", LUA_MODIFIER_MOTION_NONE )

rin_satana_explosion = class({})

function rin_satana_explosion:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self.BaseClass.GetCooldown( self, level ) + self:GetSpecialValueFor("scepter_cooldown")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function rin_satana_explosion:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    if self:GetCaster():HasScepter() then
        duration = duration + self:GetSpecialValueFor("scepter_duration")
    end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rin_satana_explosion", {duration = duration + 0.1} )
end

modifier_rin_satana_explosion = class({})

function modifier_rin_satana_explosion:IsPurgable()
    return false
end

function modifier_rin_satana_explosion:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():Stop()
    self:GetParent():EmitSound( "rinultimate" )
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.interval = self:GetAbility():GetSpecialValueFor("interval")
    local particle_caster_ground_fx2 = ParticleManager:CreateParticle("particles/rino/rino.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_caster_ground_fx2, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx2)
    self:StartIntervalThink( self.interval )
    self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_6)
end

function modifier_rin_satana_explosion:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("rinultimate")
    self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_6)
end

function modifier_rin_satana_explosion:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ORDER,
    }
end

function modifier_rin_satana_explosion:CheckState()
    return 
    {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_rin_satana_explosion:OnOrder(keys)
    if not IsServer() then return end
    if keys.unit == self:GetParent() then
        local cancel_commands = 
        {
            [DOTA_UNIT_ORDER_MOVE_TO_POSITION]  = true,
            [DOTA_UNIT_ORDER_MOVE_TO_TARGET]    = true,
            [DOTA_UNIT_ORDER_ATTACK_MOVE]       = true,
            [DOTA_UNIT_ORDER_ATTACK_TARGET]     = true,
            [DOTA_UNIT_ORDER_CAST_POSITION]     = true,
            [DOTA_UNIT_ORDER_CAST_TARGET]       = true,
            [DOTA_UNIT_ORDER_CAST_TARGET_TREE]  = true,
            [DOTA_UNIT_ORDER_HOLD_POSITION]     = true,
            [DOTA_UNIT_ORDER_STOP]              = true
        }
        
        if cancel_commands[keys.order_type] and self:GetElapsedTime() >= 0.4 then
            self:Destroy()
        end
    end
end

function modifier_rin_satana_explosion:OnIntervalThink()
    if not IsServer() then return end

    local ability = self:GetCaster():FindAbilityByName( "blue_incision" )

    if ability and ability:GetLevel() > 0 then
        local particle_caster_ground_fx2 = ParticleManager:CreateParticle("particles/rino/rino.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle_caster_ground_fx2, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx2)

        local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )

        local streak = 0

        for _,enemy in pairs( enemies ) do
            if enemy ~= nil and not enemy:HasModifier("modifier_fountain_passive_invul") then
                local vDirection = enemy:GetAbsOrigin() - self:GetCaster():GetOrigin()
                local range = vDirection:Length2D()
                vDirection.z = 0.0
                vDirection = vDirection:Normalized()

                local info = 
                {
                    EffectName = "particles/rino/rino_shock.vpcf",
                    Ability = self:GetAbility(),
                    vSpawnOrigin = self:GetCaster():GetOrigin(), 
                    fStartRadius = 100,
                    fEndRadius = 100,
                    vVelocity = vDirection * 2000,
                    fDistance = range+500,
                    Source = self:GetCaster(),
                    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                }

                self:GetParent():EmitSound( "Hero_DoomBringer.InfernalBlade.PreAttack" )

                ProjectileManager:CreateLinearProjectile( info )

                streak = streak + 1
                
                if streak >= 2 then
                    break
                end
            end
        end
    end
end

function rin_satana_explosion:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target == nil then return end
    if target:IsInvulnerable() then return end
    if target:IsMagicImmune() then return end

    local nFXIndex = ParticleManager:CreateParticle( "particles/rino/rino_ultimate.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( nFXIndex, 0, target:GetOrigin() )
    ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 300, 0.0, 1.0 ) )
    ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 300, 0.0, 1.0 ) )
    ParticleManager:ReleaseParticleIndex( nFXIndex )

    target:EmitSound( "Hero_DoomBringer.InfernalBlade.Target" )
    target:EmitSound( "Hero_Techies.LandMine.Detonate" )

    local ability = self:GetCaster():FindAbilityByName( "blue_incision" )

    if ability and ability:GetLevel()>0 then
        local damage = ability:GetSpecialValueFor("damage")
        local stun_duration = ability:GetSpecialValueFor("stun_duration")
        if self:GetCaster():HasTalent("special_bonus_birzha_rin_7") then
            target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_rin_7") * (1 - target:GetStatusResistance())})
        end
        ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
        target:EmitSound("Hero_Jakiro.LiquidFire")
    end

    return false
end






