LinkLuaModifier( "modifier_mum_meat_hook", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_mum_meat_hook_debuff", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_HORIZONTAL  )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

mum_meat_hook = class({})

function mum_meat_hook:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function mum_meat_hook:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mum_meat_hook:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function mum_meat_hook:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
    return true
end

function mum_meat_hook:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function mum_meat_hook:OnSpellStart()
    self.bChainAttached = false
    if self.hVictim ~= nil then
        self.hVictim:InterruptMotionControllers( true )
    end
    self.hook_damage = self:GetSpecialValueFor( "damage" )
    if self:GetCaster():HasScepter() then
        self.hook_damage = self:GetSpecialValueFor( "damage_scepter" )  
    end  
    self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
    self.hook_width = self:GetSpecialValueFor( "hook_width" )
    self.hook_distance = self:GetSpecialValueFor( "hook_distance" )
    self.hook_followthrough_constant = 0.65

    self.vision_radius = self:GetSpecialValueFor( "vision_radius" )  
    self.vision_duration = self:GetSpecialValueFor( "vision_duration" )  
    
    if self:GetCaster() and self:GetCaster():IsHero() then
        local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
        if hHook ~= nil then
            hHook:AddEffects( EF_NODRAW )
        end
    end

    self.vStartPosition = self:GetCaster():GetOrigin()

    self.vProjectileLocation = vStartPosition

    local vDirection = self:GetCursorPosition() - self.vStartPosition
    vDirection.z = 0.0

    if self:GetCursorPosition() == self:GetCaster():GetOrigin() then
        vDirection = self:GetCaster():GetForwardVector()
    else
        vDirection = self:GetCursorPosition() - self.vStartPosition
    end

    vDirection.z = 0.0

    local vDirection = ( vDirection:Normalized() ) * self.hook_distance
    self.vTargetPosition = self.vStartPosition + vDirection

    local flFollowthroughDuration = ( self.hook_distance / self.hook_speed * self.hook_followthrough_constant )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_mum_meat_hook", { duration = flFollowthroughDuration } )

    self.vHookOffset = Vector( 0, 0, 96 )
    local vHookTarget = self.vTargetPosition + self.vHookOffset
    local vKillswitch = Vector( ( ( self.hook_distance / self.hook_speed ) * 2 ), 0, 0 )

    self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
    ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 1, vHookTarget )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 2, Vector( self.hook_speed, self.hook_distance, self.hook_width ) )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, vKillswitch )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

    EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )

    local info = {
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        vVelocity = vDirection:Normalized() * self.hook_speed,
        fDistance = self.hook_distance,
        fStartRadius = self.hook_width ,
        fEndRadius = self.hook_width ,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
    }

    ProjectileManager:CreateLinearProjectile( info )

    self.bRetracting = false
    self.hVictim = nil
    self.bDiedInHook = false
end

function mum_meat_hook:OnProjectileHit( hTarget, vLocation )
    if hTarget == self:GetCaster() then
        return false
    end

    if self.bRetracting == false then
        if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
            print( "Target was invalid")
            return false
        end

        local bTargetPulled = false
        if hTarget ~= nil then
            if hTarget:HasModifier("modifier_Daniil_LaughingRush_debuff") or hTarget:HasModifier("modifier_modifier_eul_cyclone_birzha") then
                return false
            end
            if hTarget:GetUnitName() == "npc_dota_zerkalo" then return false end
            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Pudge.AttackHookImpact", self:GetCaster())

            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_mum_meat_hook_debuff", nil )
            
            if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.hook_damage,
                        damage_type = DAMAGE_TYPE_PURE,     
                        ability = this
                    }

                ApplyDamage( damage )

                if not hTarget:IsAlive() then
                    self.bDiedInHook = true
                end

                if not hTarget:IsMagicImmune() then
                    hTarget:Interrupt()
                end
        
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
            end

            AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
            self.hVictim = hTarget
            bTargetPulled = true
        end

        local vHookPos = self.vTargetPosition
        local flPad = self:GetCaster():GetPaddedCollisionRadius()
        if hTarget ~= nil then
            vHookPos = hTarget:GetOrigin()
            flPad = flPad + hTarget:GetPaddedCollisionRadius()
        end

        local vVelocity = self.vStartPosition - vHookPos
        vVelocity.z = 0.0

        local flDistance = vVelocity:Length2D() - flPad
        vVelocity = vVelocity:Normalized() * self.hook_speed

        local info = {
            Ability = self,
            vSpawnOrigin = vHookPos,
            vVelocity = vVelocity,
            fDistance = flDistance,
            Source = self:GetCaster(),
        }

        ProjectileManager:CreateLinearProjectile( info )
        self.vProjectileLocation = vHookPos

        if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
            ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.vHookOffset, true )
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
        else
            ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true);
        end

        if hTarget ~= nil then
            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Pudge.AttackHookRetract", self:GetCaster())
        end

        if self:GetCaster():IsAlive() then
            self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
            self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
        end

        self.bRetracting = true
    else
        if self:GetCaster() and self:GetCaster():IsHero() then
            local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
            if hHook ~= nil then
                hHook:RemoveEffects( EF_NODRAW )
            end
        end

        if self.hVictim ~= nil then
            local vFinalHookPos = vLocation
            self.hVictim:InterruptMotionControllers( true )
            self.hVictim:RemoveModifierByName( "modifier_mum_meat_hook_debuff" )

            local vVictimPosCheck = self.hVictim:GetOrigin() - vFinalHookPos 
            local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hVictim:GetPaddedCollisionRadius()
            if vVictimPosCheck:Length2D() > flPad then
                FindClearSpaceForUnit( self.hVictim, self.vStartPosition, false )
            end
        end

        self.hVictim = nil
        ParticleManager:DestroyParticle( self.nChainParticleFXIndex, true )
        EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
    end

    return true
end

function mum_meat_hook:OnProjectileThink( vLocation )
    self.vProjectileLocation = vLocation
end

function mum_meat_hook:OnOwnerDied()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
    self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

modifier_mum_meat_hook = class({})

function modifier_mum_meat_hook:IsHidden()
    return true
end

function modifier_mum_meat_hook:IsPurgable()
    return false
end

function modifier_mum_meat_hook:CheckState()
    local state = {
    [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

modifier_mum_meat_hook_debuff = class({})

function modifier_mum_meat_hook_debuff:IsDebuff()
    return true
end

function modifier_mum_meat_hook_debuff:RemoveOnDeath()
    return false
end

function modifier_mum_meat_hook_debuff:IsPurgable()
    return false
end


function modifier_mum_meat_hook_debuff:OnCreated( kv )
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end

function modifier_mum_meat_hook_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_mum_meat_hook_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_mum_meat_hook_debuff:CheckState()
    if IsServer() then
        if self:GetCaster() ~= nil and self:GetParent() ~= nil then
            if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
                local state = {
                [MODIFIER_STATE_STUNNED] = true,
                }

                return state
            end
        end
    end

    local state = {}

    return state
end

function modifier_mum_meat_hook_debuff:UpdateHorizontalMotion( me, dt )
    if IsServer() then
        if self:GetAbility().hVictim ~= nil then
            self:GetAbility().hVictim:SetOrigin( self:GetAbility().vProjectileLocation )
            local vToCaster = self:GetAbility().vStartPosition - self:GetCaster():GetOrigin()
            local flDist = vToCaster:Length2D()
            if self:GetAbility().bChainAttached == false and flDist > 128.0 then 
                self:GetAbility().bChainAttached = true  
                ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetOrigin(), true )
                ParticleManager:SetParticleControl( self:GetAbility().nChainParticleFXIndex, 0, self:GetAbility().vStartPosition + self:GetAbility().vHookOffset )
            end                     
        end
    end
end

function modifier_mum_meat_hook_debuff:OnHorizontalMotionInterrupted()
    if IsServer() then
        if self:GetAbility().hVictim ~= nil then
            ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin() + self:GetAbility().vHookOffset, true )
            self:Destroy()
        end
    end
end

mum_arrows_of_death = class({})

function mum_arrows_of_death:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level )
end

function mum_arrows_of_death:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mum_arrows_of_death:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function mum_arrows_of_death:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
    return true
end

function mum_arrows_of_death:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
end

function mum_arrows_of_death:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local cast_direction = (point - caster_loc):Normalized()
    if point == caster_loc then
        cast_direction = caster:GetForwardVector()
    else
        cast_direction = (point - caster_loc):Normalized()
    end

    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        bDeleteOnHit = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
        fDistance = 1400,
        fStartRadius = 115,
        fEndRadius =115,
        vVelocity = cast_direction * 600,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = true,
        iVisionRadius = 650,
        iVisionTeamNumber = caster:GetTeamNumber(),
    }
    caster:EmitSound("Hero_Mirana.ArrowCast")

    local first_angle = -6 * (20 - 1) / 2
    for i = 1, 20 do
        local angle = first_angle + (i-1) * 6
        info.vVelocity = RotateVector2D(cast_direction,angle,true) * 600
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function mum_arrows_of_death:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) then
        local check_stun = target:FindModifierByName("modifier_birzha_stunned_purge")
        local stun_duration = self:GetSpecialValueFor( "arrow_stun" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_3")
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
        target:EmitSound("Hero_Mirana.ArrowImpact")
        if check_stun and (check_stun:GetAbility() and check_stun:GetAbility() == self) then return true end
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL })
    end
    return true
end

LinkLuaModifier( "modifier_mum_fart", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fart_aura", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE )

mum_fart = class({})

function mum_fart:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function mum_fart:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mum_fart:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")

    local thinker = CreateModifierThinker(caster, self, "modifier_mum_fart", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("pudgepuk")
    local particle = ParticleManager:CreateParticle("particles/perdezh/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, thinker)
    ParticleManager:SetParticleControl(particle, 0, thinker:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))

    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

modifier_mum_fart = class({})

function modifier_mum_fart:IsPurgable() return false end
function modifier_mum_fart:IsHidden() return true end
function modifier_mum_fart:IsAura() return true end

function modifier_mum_fart:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_mum_fart:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_mum_fart:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_mum_fart:GetModifierAura()
    return "modifier_fart_aura"
end

function modifier_mum_fart:GetAuraRadius()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    return radius
end

modifier_fart_aura = class({})

function modifier_fart_aura:IsPurgable() return false end
function modifier_fart_aura:IsDebuff() return true end

function modifier_fart_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 1 )
end

function modifier_fart_aura:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_2")
    if not IsServer() then return end
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
    if IsUnlockedInPass(self:GetCaster():GetPlayerID(), "reward61") then
        self:GetParent().FartEffect = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_dismember_default.vpcf", PATTACH_ABSORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(self:GetParent().FartEffect, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self:GetParent().FartEffect, 8, Vector(1, 1, 1))
        ParticleManager:SetParticleControl(self:GetParent().FartEffect, 15, Vector(255, 140, 1))
        Timers:CreateTimer(0.5, function()
            if self:GetParent().FartEffect then
                ParticleManager:DestroyParticle(self:GetParent().FartEffect, false)
                ParticleManager:ReleaseParticleIndex(self:GetParent().FartEffect)
            end
        end)
    end
end

function modifier_fart_aura:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
    return funcs
end

function modifier_fart_aura:GetModifierMoveSpeedBonus_Percentage()
    local slow = self:GetAbility():GetSpecialValueFor("movespeed")
    return slow
end

fut_mum_eat = class({})
LinkLuaModifier( "modifier_fut_mum_eat_caster", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fut_mum_eat_target", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silence_item", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------
function fut_mum_eat:OnSpellStart()
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_fut_mum_eat_caster", { duration = duration } )
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_silence_item", {duration=duration})
    self:EmitSound("pudgemeat")
end

modifier_fut_mum_eat_caster = class({})

function modifier_fut_mum_eat_caster:IsHidden()
    return false
end

function modifier_fut_mum_eat_caster:IsPurgable()
    return false
end

function modifier_fut_mum_eat_caster:OnCreated()
    if not IsServer() then return end
    self:GetAbility():SetActivated(false)
    self.eat_bool = true
    self.stack_particle = ParticleManager:CreateParticle("particles/mum/pudge_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( self.stack_particle, 0, self:GetParent():GetAbsOrigin())         
    self:AddParticle( self.stack_particle, false, false, -1, false, true )
    self.victims = 0
end

function modifier_fut_mum_eat_caster:OnDestroy()
    if not IsServer() then return end
    self.model_scale = 1
    self:GetAbility():SetActivated(true)
    self:GetCaster():SetModelScale(self.model_scale)
    self:GetCaster():SetRenderColor(255, 255, 255)
    self:GetCaster():EmitSound("mumend")
    local caster_pos = self:GetCaster():GetAbsOrigin()
    self.victims = nil
    ParticleManager:DestroyParticle(self.stack_particle, true)
end

function modifier_fut_mum_eat_caster:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }

    return state
end

function modifier_fut_mum_eat_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START,
    }
    return funcs
end

function modifier_fut_mum_eat_caster:OnAttackStart( params )
    if not IsServer() then return end
    if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
        local target = params.target
        local duration = self:GetRemainingTime()
        if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            if not target:IsRealHero() or params.target:HasModifier("modifier_fut_mum_eat_caster") then
                return nil
            else
              self:GetCaster():SetModelScale(self:GetCaster():GetModelScale() + 0.1)
              if self.stack_particle then
               ParticleManager:DestroyParticle(self.stack_particle, true)
              end
              target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_fut_mum_eat_target", { duration = duration } )
              local caster = self:GetParent() 
              self.stack_particle = ParticleManager:CreateParticle("particles/mum/pudge_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())            
              self.victims = self.victims + 1
              self:GetCaster():SetModifierStackCount("modifier_fut_mum_eat_caster", self:GetAbility(), self.victims)
              ParticleManager:SetParticleControl( self.stack_particle, 1, Vector(1, self.victims, 0))
              self:AddParticle( self.stack_particle, false, false, -1, false, true )
              if self.victims > 9 then
                 ParticleManager:SetParticleControl( self.stack_particle, 2, Vector(2, 1, 0))
              else
                 ParticleManager:SetParticleControl( self.stack_particle, 2, Vector(1, 1, 0))
              end
              self:GetCaster():Stop()
            end
        end
    end
    return 0
end

modifier_fut_mum_eat_target = class({})

function modifier_fut_mum_eat_target:IsPurgable()
    return false
end

function modifier_fut_mum_eat_target:OnCreated( kv )
    self:StartIntervalThink(0.03)
    self.kill_chance = self:GetAbility():GetSpecialValueFor( "kill_chance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_1")
    if not IsServer() then return end
    self.model_scale = self:GetParent():GetModelScale()
    self:StartIntervalThink(0.1)
    self:GetParent():AddNoDraw()
    self.particle = ParticleManager:CreateParticleForPlayer("particles/pudge/pudgerage.vpcf", PATTACH_EYES_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
    self:AddParticle( self.particle, false, false, -1, false, true )        
    self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
     Timers:CreateTimer(self.duration,function()
        ParticleManager:DestroyParticle (self.particle, false)
        return nil
    end)
end

function modifier_fut_mum_eat_target:OnIntervalThink()
    if not IsServer() then return end
    local target = self:GetParent ()
    local target_pos = target:GetAbsOrigin ()
    local caster = self:GetAbility ():GetCaster ()
    target:SetAbsOrigin (self:GetCaster ():GetAbsOrigin ())
    if not caster:IsAlive() then
        target:RemoveModifierByName ("modifier_fut_mum_eat_target")
    end
end

function modifier_fut_mum_eat_target:OnDestroy( kv )
self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
if not IsServer() then return end
local point = self:GetCaster():GetAbsOrigin()
local bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
if self:GetCaster():HasScepter() then
    bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength_scepter" )
end
FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin(), true)
    local chance = math.random(100)
    local npcName = self:GetParent():GetUnitName()
    
    self:GetParent():RemoveNoDraw()
    
    local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    local direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    local bump_point = self:GetCaster():GetAbsOrigin() - direction * distance
    local knockbackProperties =
    {
        center_x = bump_point.x,
        center_y = bump_point.y,
        center_z = bump_point.z,
        duration = 0.5,
        knockback_duration = 0.5,
        knockback_distance = 400,
        knockback_height = 350
    }
    self:GetParent():RemoveModifierByName("modifier_knockback")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    
    if chance <= self.kill_chance then
        local caster = self:GetCaster()
        if self:EasyKill(self:GetParent()) then
            caster:SetBaseStrength(caster:GetBaseStrength() + bonus_strength)
            self:GetParent():SetBaseStrength(self:GetParent():GetBaseStrength() - self:GetAbility():GetSpecialValueFor( "bonus_strength" ))
        end
        self:GetParent():Kill(self:GetAbility(), self:GetCaster())
    else
        local caster = self:GetCaster()
        if self:GetCaster():HasScepter() then
            if self:GetParent():GetHealth() - self.damage <= 0 then
                if self:EasyKill(self:GetParent()) then
                    self:GetCaster():SetBaseStrength(self:GetCaster():GetBaseStrength() + bonus_strength)
                    self:GetParent():SetBaseStrength(self:GetParent():GetBaseStrength() - self:GetAbility():GetSpecialValueFor( "bonus_strength" ))
                end
            end
        end
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(),ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE})
    end
end

function modifier_fut_mum_eat_target:EasyKill(target)
    if target:FindAbilityByName("Papich_reincarnation") then
        if target:FindAbilityByName("Papich_reincarnation"):IsFullyCastable() or target:FindAbilityByName("scp682_ultimate"):IsFullyCastable() then
            return false
        end
    end

    if target:HasModifier("modifier_haku_help") or target:HasModifier("modifier_item_aeon_disk_buff") or target:HasModifier("modifier_item_uebator_active") or target:HasModifier("modifier_Felix_WaterShield") or target:HasModifier("modifier_Dio_Za_Warudo") or target:HasModifier("modifier_kurumi_zafkiel") or target:HasModifier("modifier_LenaGolovach_Radio_god") or target:HasModifier("modifier_pistoletov_deathfight") then
        return false
    end

    for i = 0, 5 do 
        local item = target:GetItemInSlot(i)
        if item then
            if item:GetName() == "item_uebator" or item:GetName() == "item_aeon_disk" then
                if item:IsFullyCastable() then
                    return false
                end
            end
        end        
    end
    return true
end

function modifier_fut_mum_eat_target:CheckState()
    local state = {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

modifier_silence_item = class({})

function modifier_silence_item:CheckState() 
    if self:GetParent():HasScepter() then return end
  local state =
      {
   [MODIFIER_STATE_MUTED] = true
      }
  return state
end

function modifier_silence_item:IsPurgable()
    return false
end

function modifier_silence_item:IsHidden()
    return true
end

