LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_johncena_Wrestling", "abilities/heroes/johncena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

johncena_Wrestling = class({})

function johncena_Wrestling:GetIntrinsicModifierName()
    return "modifier_johncena_Wrestling"
end

function johncena_Wrestling:OnUpgrade()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local playerID = caster:GetPlayerID()
    if DonateShopIsItemBought(playerID, 30) then
        if self:GetLevel() == 1 then
            caster:SetOriginalModel("models/items/tiny/tiny_prestige/tiny_prestige_lvl_02.vmdl")
        elseif self:GetLevel() == 2 then
            caster:SetOriginalModel("models/items/tiny/tiny_prestige/tiny_prestige_lvl_03.vmdl")
        elseif self:GetLevel() == 3 then
            caster:SetOriginalModel("models/items/tiny/tiny_prestige/tiny_prestige_lvl_04.vmdl")
        end
    else
        if self:GetLevel() == 1 then
            caster:SetOriginalModel("models/items/tiny/burning_stone_giant/burning_stone_giant_02.vmdl")
        elseif self:GetLevel() == 2 then
            caster:SetOriginalModel("models/items/tiny/burning_stone_giant/burning_stone_giant_03.vmdl")
        elseif self:GetLevel() == 3 then
            caster:SetOriginalModel("models/items/tiny/burning_stone_giant/burning_stone_giant_04.vmdl")
        end
    end

    self:GetCaster():StartGesture(ACT_TINY_GROWL)
    self:GetCaster():EmitSound("Tiny.Grow")
    local grow = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_transform.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster()) 
    ParticleManager:SetParticleControl(grow, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(grow)
end

modifier_johncena_Wrestling = class({})

function modifier_johncena_Wrestling:IsHidden()
    return true
end

function modifier_johncena_Wrestling:RemoveOnDeath()
    return false
end

function modifier_johncena_Wrestling:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_johncena_Wrestling:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_johncena_Wrestling:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor") + self:GetCaster():FindTalentValue("special_bonus_birzha_johncena_2")
end

function modifier_johncena_Wrestling:GetModifierAttackSpeedBonus_Constant()
    if self:GetCaster():HasTalent("special_bonus_birzha_johncena_4") then return end
    return self:GetAbility():GetSpecialValueFor("minus_attack_speed")
end





LinkLuaModifier( "modifier_JohnCena_Chargehit", "abilities/heroes/johncena.lua", LUA_MODIFIER_MOTION_NONE )

JohnCena_Chargehit = class({})

function JohnCena_Chargehit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function JohnCena_Chargehit:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function JohnCena_Chargehit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function JohnCena_Chargehit:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Ability.TossThrow")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_JohnCena_Chargehit", {duration = 0.25 } )
end

function JohnCena_Chargehit:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName( "modifier_JohnCena_Chargehit" )
end

function JohnCena_Chargehit:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_bp_johncena") then
        return "JohnCena/Chargehit_item"
    end
    return "JohnCena/Chargehit"
end

modifier_JohnCena_Chargehit = class ({})

function modifier_JohnCena_Chargehit:IsHidden()
    return true
end

function modifier_JohnCena_Chargehit:IsPurgable()
    return false
end

function modifier_JohnCena_Chargehit:OnCreated( kv )
   if not IsServer() then return end
    self.damage_radius = self:GetAbility():GetSpecialValueFor( "damage_radius" )
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.hHitTargets = {}
    self.bPlayedSound = false
    self.bInit = false

    if DonateShopIsItemBought(self:GetParent():GetPlayerID(), 30) then
        local particle = ParticleManager:CreateParticle("particles/econ/items/primal_beast/primal_beast_2022_prestige/primal_beast_2022_prestige_onslaught_charge_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
        self:AddParticle(particle, false, false, -1, false, false)
    end

    self:StartIntervalThink( 0.01 )
end

function modifier_JohnCena_Chargehit:OnIntervalThink()
    if not IsServer() then return end
    if self.bInit == false then
        self.szSequenceName = self:GetParent():GetSequence()
        self.attachAttack1 = nil
        self.attachAttack2 = nil
        self.vLocation1 = nil
        self.vLocation2 = nil
        self.attachAttack1 = self:GetParent():ScriptLookupAttachment( "attach_attack1" )
        self.bInit = true
    end

    local vForward = self:GetParent():GetForwardVector()
    self:GetParent():SetOrigin( self:GetParent():GetOrigin() + vForward * 20 ) 

    if self.bPlayedSound == false then
        self:GetParent():EmitSound("Roshan.PreAttack")
        self.bPlayedSound = true
    end

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    if #enemies > 0 then
        for _,enemy in pairs( enemies ) do
            if enemy ~= nil and enemy:IsInvulnerable() == false and self:HasHitTarget( enemy ) == false then
                self:TryToHitTarget( enemy )
            end
        end
    end
end

function modifier_JohnCena_Chargehit:TryToHitTarget( enemy )
    local vToTarget = enemy:GetOrigin() - self:GetCaster():GetOrigin()
    vToTarget = vToTarget:Normalized()
    local flDirectionDot = DotProduct( vToTarget, self:GetCaster():GetForwardVector() )
    local flAngle = 180 * math.acos( flDirectionDot ) / math.pi
    if flAngle < 90 then
        self:AddHitTarget( enemy )
        local damageInfo = 
        {
            victim = enemy,
            attacker = self:GetParent(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(),
        }

        ApplyDamage( damageInfo )

        if self:GetCaster():HasTalent("special_bonus_birzha_johncena_8") then
            local JohnCena_greater_bash = self:GetCaster():FindAbilityByName("JohnCena_greater_bash")
            if JohnCena_greater_bash and JohnCena_greater_bash:GetLevel() > 0 then
                JohnCena_greater_bash:Bash(enemy, self:GetParent())
            end
        end

        enemy:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_birzha_stunned_purge", { duration = self:GetAbility():GetSpecialValueFor( "stun_duration" ) * (1-enemy:GetStatusResistance()) } )
        enemy:EmitSound("Roshan.Attack.Post")
    end                 
end

function modifier_JohnCena_Chargehit:HasHitTarget( hTarget )
    for _, target in pairs( self.hHitTargets ) do
        if target == hTarget then
            return true
        end
    end
    
    return false
end

function modifier_JohnCena_Chargehit:AddHitTarget( hTarget )
    table.insert( self.hHitTargets, hTarget )
end

function modifier_JohnCena_Chargehit:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    return funcs
end

function modifier_JohnCena_Chargehit:GetModifierDisableTurning( params )
    return 1
end

function modifier_JohnCena_Chargehit:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetOrigin(), false )
end

LinkLuaModifier("modifier_JohnCena_greater_bash", "abilities/heroes/johncena.lua", LUA_MODIFIER_MOTION_NONE)

JohnCena_greater_bash = class({})

function JohnCena_greater_bash:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function JohnCena_greater_bash:GetIntrinsicModifierName()
    return "modifier_JohnCena_greater_bash"
end

function JohnCena_greater_bash:Bash(target, parent)
    if not IsServer() then return end

    target:EmitSound("Hero_Spirit_Breaker.GreaterBash")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(particle)

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_johncena_1")

    if not target:IsBoss() then
        local knockback_properties = 
        {
             center_x           = parent:GetAbsOrigin().x,
             center_y           = parent:GetAbsOrigin().y,
             center_z           = parent:GetAbsOrigin().z,
             duration           = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance()),
             knockback_duration = 0.5 * (1 - target:GetStatusResistance()),
             knockback_distance = 25,
             knockback_height   = 50,
        }
        target:RemoveModifierByName("modifier_knockback")
        target:AddNewModifier(parent, self, "modifier_knockback", knockback_properties)
    end
    
    local damageTable = 
    {
        victim          = target,
        damage          = parent:GetIdealSpeed() * damage * 0.01,
        damage_type     = self:GetAbilityDamageType(),
        damage_flags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        attacker        = parent,
        ability         = self
    }

    ApplyDamage(damageTable)
end

modifier_JohnCena_greater_bash = class({})

function modifier_JohnCena_greater_bash:IsHidden() return true end
function modifier_JohnCena_greater_bash:IsPurgable() return false end

function modifier_JohnCena_greater_bash:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return decFuncs
end

function modifier_JohnCena_greater_bash:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsWard() then return end
    if not self:GetAbility():IsFullyCastable() then return end

    local chance = self:GetAbility():GetSpecialValueFor( "chance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_johncena_5")

    if RollPercentage(chance) then 
        self:GetAbility():Bash(params.target, params.attacker)
        self:GetAbility():UseResources(false, false, true)
    end
end

LinkLuaModifier( "modifier_JohnCena_Grabbed_buff", "abilities/heroes/johncena.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_JohnCena_Grabbed_debuff", "abilities/heroes/johncena.lua", LUA_MODIFIER_MOTION_BOTH )

JohnCena_Grab = class({})

function JohnCena_Grab:GetCastRange(location, target)
    if self:GetCaster():HasModifier("modifier_JohnCena_Grabbed_buff") then
        return 1500
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function JohnCena_Grab:GetAOERadius()
    return self:GetSpecialValueFor( "radius_scepter" )
end

function JohnCena_Grab:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_JohnCena_Grabbed_buff") then
        return "JohnCena/ThrowTheEnemy"
    end
    return self.BaseClass.GetAbilityTextureName(self)
end

function JohnCena_Grab:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level) + self:GetCaster():FindTalentValue("special_bonus_birzha_johncena_6")
end

function JohnCena_Grab:GetManaCost(level)
    if self:GetCaster():HasModifier("modifier_JohnCena_Grabbed_buff") then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end

function JohnCena_Grab:GetBehavior()
    if self:GetCaster():HasModifier("modifier_JohnCena_Grabbed_buff") then
        return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function JohnCena_Grab:GetPlaybackRateOverride()
    return 0.35
end

function JohnCena_Grab:OnSpellStart()
    if not IsServer() then return end

    if self:GetCaster():HasModifier("modifier_JohnCena_Grabbed_buff") then
        self.throw_speed = 2500
        self.impact_radius = self:GetSpecialValueFor( "radius_scepter" )
        self.stun_duration = self:GetSpecialValueFor( "stun_duration" )
        self.knockback_duration = 1
        self.knockback_distance = 275
        self.knockback_damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_johncena_7")
        self.knockback_height = 150
        self.vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
        self.flDist = self.vDirection:Length2D()
        self.vDirection.z = 0.0
        self.vDirection = self.vDirection:Normalized()
        self.attach = self:GetCaster():ScriptLookupAttachment( "attach_attack2" )
        self.vSpawnLocation = self:GetCaster():GetAttachmentOrigin( self.attach )
        self.vEndPos = self:GetCaster():GetOrigin() + self.vDirection * self.flDist  
        local info = {
            EffectName = "",
            Ability = self,
            vSpawnOrigin = self.vSpawnLocation, 
            fStartRadius = self.impact_radius,
            fEndRadius = self.impact_radius,
            vVelocity = self.vDirection * self.throw_speed,
            fDistance = self.flDist,
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        }
        self.debuff:SetDuration(-1, true)
        self.debuff.nProjHandle = ProjectileManager:CreateLinearProjectile( info )
        self.debuff.flHeight = self.vSpawnLocation.z - GetGroundHeight( self:GetCaster():GetOrigin(), self:GetCaster() )
        self.debuff.flTime = self.flDist  / self.throw_speed
        self:GetCaster():RemoveModifierByName( "modifier_JohnCena_Grabbed_buff" )
        self:GetCaster():EmitSound("Hero_Tiny.Toss.Target")
        return
    end

    local duration = self:GetSpecialValueFor( "duration" )
    local particle = ParticleManager:CreateParticle( "particles/test_particle/generic_attack_crit_blur.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle )
    self.target = self:GetCursorTarget()
    self.buff = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_JohnCena_Grabbed_buff", { duration = duration } )
    self.debuff = self.target:AddNewModifier( self:GetCaster(), self, "modifier_JohnCena_Grabbed_debuff", {duration = duration} ) 
    self:GetCaster():EmitSound("sena")
    self:EndCooldown()
end

function JohnCena_Grab:OnProjectileHit( hTarget, vLocation )
    if not IsServer() then return end

    if hTarget ~= nil then
        return
    end

    EmitSoundOnLocationWithCaster( vLocation, "Ability.TossImpact", self:GetCaster() )
    EmitSoundOnLocationWithCaster( vLocation, "OgreTank.GroundSmash", self:GetCaster() )
    
    if self.target ~= nil then
        if self.debuff and not self.debuff:IsNull() then
            self.debuff:Destroy()
        end
        if self.target:IsRealHero() then
            local damageInfo =
            {
                victim = self.target,
                attacker = self:GetCaster(),
                damage = self.knockback_damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self,
            }

            ApplyDamage( damageInfo )
            if self.target:IsAlive() == false then
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetOrigin(), true )
                ParticleManager:SetParticleControl( nFXIndex, 1, self.target:GetOrigin() )
                ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
                ParticleManager:SetParticleControlEnt( nFXIndex, 10, self.target, PATTACH_ABSORIGIN_FOLLOW, nil, self.target:GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )

                self.target:EmitSound("Dungeon.BloodSplatterImpact")
            else
                self.target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = self.stun_duration * (1 - self.target:GetStatusResistance()) } )
            end
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN, self:GetCaster()  )
        ParticleManager:SetParticleControl( nFXIndex, 0, GetGroundPosition( vLocation, self.target ) )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.impact_radius, self.impact_radius, self.impact_radius ) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        if not self:GetCaster():HasScepter() then return end
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vLocation, self:GetCaster(), self.impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _,enemy in pairs( enemies ) do
            if enemy ~= nil and enemy:IsInvulnerable() == false and enemy ~= self.target then
                local damageInfo = 
                {
                    victim = enemy,
                    attacker = self:GetCaster(),
                    damage = self.knockback_damage,
                    damage_type = DAMAGE_TYPE_PURE,
                    ability = self,
                }

                ApplyDamage( damageInfo )

                if not enemy:IsAlive() then
                    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
                    ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
                    ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
                    enemy:EmitSound("Dungeon.BloodSplatterImpact")
                else
                    enemy:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = self.knockback_duration * (1 - enemy:GetStatusResistance()) } )
                end
            end
        end
    end
end

modifier_JohnCena_Grabbed_buff = class({})

function modifier_JohnCena_Grabbed_buff:IsHidden()
    return true
end

function modifier_JohnCena_Grabbed_buff:IsPurgable()
    return false
end

function modifier_JohnCena_Grabbed_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_JohnCena_Grabbed_buff:GetActivityTranslationModifiers( params )
    return "tree"
end

function modifier_JohnCena_Grabbed_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_johncena_3")
end

function modifier_JohnCena_Grabbed_buff:GetModifierTurnRate_Percentage( params )
    if self:GetCaster():HasShard() then return end
    return -90
end

function modifier_JohnCena_Grabbed_buff:GetModifierMoveSpeedBonus_Percentage( params )
    if self:GetCaster():HasShard() then return end
    return self:GetAbility():GetSpecialValueFor( "slow_pct" )
end

modifier_JohnCena_Grabbed_debuff = class({})

function modifier_JohnCena_Grabbed_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_JohnCena_Grabbed_debuff:IsPurgable()
    return false
end

function modifier_JohnCena_Grabbed_debuff:OnCreated( kv )
    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    self.nProjHandle = -1
    self.flTime = 0.0
    self.flHeight = 0.0
end

function modifier_JohnCena_Grabbed_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_JohnCena_Grabbed_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
    return state
end

function modifier_JohnCena_Grabbed_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )
    self:GetAbility():UseResources(false, false, true)
end

function modifier_JohnCena_Grabbed_debuff:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local vLocation = nil
    if self.nProjHandle == -1 then
        local attach = self:GetCaster():ScriptLookupAttachment( "attach_attack2" )
        vLocation = self:GetCaster():GetAttachmentOrigin( attach )
    else
        vLocation = ProjectileManager:GetLinearProjectileLocation( self.nProjHandle )
    end
    vLocation.z = 0.0
    me:SetOrigin( vLocation )
end

function modifier_JohnCena_Grabbed_debuff:UpdateVerticalMotion( me, dt )
    if not IsServer() then return end
    local vMyPos = me:GetOrigin()
    if self.nProjHandle == -1 then
        local attach = self:GetCaster():ScriptLookupAttachment( "attach_attack2" )
        local vLocation = self:GetCaster():GetAttachmentOrigin( attach )
        vMyPos.z = vLocation.z
    else
        local flGroundHeight = GetGroundHeight( vMyPos, me )
        local flHeightChange = dt * self.flTime * self.flHeight * 1.3
        vMyPos.z = math.max( vMyPos.z - flHeightChange, flGroundHeight )
    end
    me:SetOrigin( vMyPos )
end

function modifier_JohnCena_Grabbed_debuff:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_JohnCena_Grabbed_debuff:OnVerticalMotionInterrupted()
    if not IsServer() then return end
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_JohnCena_Grabbed_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_JohnCena_Grabbed_debuff:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetCaster() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
    return 0
end

