LinkLuaModifier( "modifier_dzhin_quite_walk", "abilities/heroes/dzhin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

dzhin_quite_walk = class({})

function dzhin_quite_walk:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function dzhin_quite_walk:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function dzhin_quite_walk:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dzhin_quite_walk", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():EmitSound("Hero_Invoker.GhostWalk")
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_dzhin_quite_walk = class({})

function modifier_dzhin_quite_walk:IsPurgable()
    return false
end

function modifier_dzhin_quite_walk:IsHidden()
    return false
end

function modifier_dzhin_quite_walk:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED 

    }

    return decFuncs
end

function modifier_dzhin_quite_walk:GetModifierInvisibilityLevel()
    return 1
end

function modifier_dzhin_quite_walk:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_dzhin_quite_walk:GetBonusVisionPercentage()
    return self:GetAbility():GetSpecialValueFor("bonus_vision")
end

function modifier_dzhin_quite_walk:OnAttack( params )
    if IsServer() then
        if params.attacker~=self:GetParent() then return end
        self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_bashed", {duration = self.stun_duration})
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_dzhin_quite_walk:OnAbilityExecuted(keys)
    if IsServer() then
        local ability = keys.ability
        local caster = keys.unit
        if caster == self:GetParent() then
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_dzhin_quite_walk:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end

LinkLuaModifier("modifier_dzhin_im_not_die", "abilities/heroes/dzhin", LUA_MODIFIER_MOTION_NONE)

dzhin_im_not_die = class({}) 

function dzhin_im_not_die:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function dzhin_im_not_die:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function dzhin_im_not_die:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_dzhin_3")
end

function dzhin_im_not_die:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local victim_angle = target:GetAnglesAsVector()
    local victim_forward_vector = target:GetForwardVector()
    local victim_angle_rad = victim_angle.y*math.pi/180
    local victim_position = target:GetAbsOrigin()
    local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
    local damage = self:GetSpecialValueFor("damage") / 100
    if target:TriggerSpellAbsorb( self ) then return end
    local effect_cast_a = ParticleManager:CreateParticle( "particles/dzin/blink.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast_a, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( effect_cast_a, 0, attacker_new:Normalized() )
    ParticleManager:ReleaseParticleIndex( effect_cast_a )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Antimage.Blink_out", self:GetCaster() )
    self:GetCaster():SetAbsOrigin(attacker_new)
    FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
    self:GetCaster():SetForwardVector(victim_forward_vector)
    self:GetCaster():MoveToTargetToAttack(target)
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = target:GetMaxHealth() * damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
    self:GetCaster():Heal(target:GetMaxHealth() * damage, self)
    local effect_cast_b = ParticleManager:CreateParticle( "particles/econ/items/antimage/antimage_ti7/antimage_blink_ti7_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( effect_cast_b, 0, attacker_new:Normalized() )
    ParticleManager:ReleaseParticleIndex( effect_cast_b )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Antimage.Blink_in", self:GetCaster() )
end

LinkLuaModifier("modifier_dzhin_call_of_shadows_wolf", "abilities/heroes/dzhin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dzhin_call_of_shadows_slow", "abilities/heroes/dzhin", LUA_MODIFIER_MOTION_NONE)

dzhin_call_of_shadows = class({}) 

function dzhin_call_of_shadows:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function dzhin_call_of_shadows:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function dzhin_call_of_shadows:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function dzhin_call_of_shadows:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    self.count = self:GetSpecialValueFor( "wolf_count" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dzhin_2")
    local invul_duration = self:GetSpecialValueFor( "invul_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dzhin_1")
    for i = 1, self.count do
        local wolf = CreateUnitByName("npc_dota_dzhin_wolf", self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300) + (self:GetCaster():GetRightVector() * 60 * i), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
        wolf:SetOwner(self:GetCaster())
        FindClearSpaceForUnit(wolf, wolf:GetAbsOrigin(), true)
        wolves_spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, wolf)
        ParticleManager:ReleaseParticleIndex(wolves_spawn_particle)
        wolf:SetForwardVector(self:GetCaster():GetForwardVector())
        wolf:MoveToTargetToAttack(target)
        wolf:SetAggroTarget(target)
        wolf:SetRenderColor(128, 0, 255)
        wolf:AddNewModifier( self:GetCaster(), self, "modifier_dzhin_call_of_shadows_wolf", {enemy_entindex = target:entindex()})
        wolf:AddInvul(invul_duration)
    end
    EmitSoundOn("Hero_Lycan.SummonWolves", self:GetCaster())
end

modifier_dzhin_call_of_shadows_wolf = class({}) 

function modifier_dzhin_call_of_shadows_wolf:IsPurgable()
    return false
end

function modifier_dzhin_call_of_shadows_wolf:IsHidden()
    return true
end

function modifier_dzhin_call_of_shadows_wolf:DeclareFunctions()
    local decFuncs = {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }

    return decFuncs
end

function modifier_dzhin_call_of_shadows_wolf:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self.damage
    self:GetParent():Kill(nil, self:GetParent())
    return damage
end

function modifier_dzhin_call_of_shadows_wolf:OnAttack( params )
    if IsServer() then
        if params.attacker~=self:GetParent() then return end
        local duration = self:GetAbility():GetSpecialValueFor( "duration" )
        params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_dzhin_call_of_shadows_slow", {duration = duration})
    end
end

function modifier_dzhin_call_of_shadows_wolf:OnCreated(keys)
    if not IsServer() then return end
    self.aggro_target = EntIndexToHScript(keys.enemy_entindex)
end

function modifier_dzhin_call_of_shadows_wolf:CheckState()
    if self:GetParent():IsNull() then
        return
    end
    if self.aggro_target:IsNull() or self.aggro_target == nil then
        self:GetParent():Kill(nil, self:GetParent())
        return
    end
    if not self.aggro_target:IsAlive() or self.aggro_target == nil then
        self:GetParent():Kill(nil, self:GetParent())
        return
    end
    if not self:GetParent():CanEntityBeSeenByMyTeam(self.aggro_target) then
        ExecuteOrderFromTable({
            UnitIndex   = self:GetParent():entindex(),
            OrderType   = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position    = self.aggro_target:GetAbsOrigin()
        })
    elseif self:GetParent():GetAggroTarget() ~= self.aggro_target then
        ExecuteOrderFromTable({
            UnitIndex   = self:GetParent():entindex(),
            OrderType   = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = self.aggro_target
        })
    end
    self:GetParent():MoveToTargetToAttack(self.aggro_target)
    self:GetParent():SetAggroTarget(self.aggro_target)
    local state = { [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,[MODIFIER_STATE_COMMAND_RESTRICTED] = true,}
    return state
end

function modifier_dzhin_call_of_shadows_wolf:GetEffectName()
    return "particles/dzin/blocking_buff.vpcf"
end

function modifier_dzhin_call_of_shadows_wolf:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_dzhin_call_of_shadows_slow = class({}) 

function modifier_dzhin_call_of_shadows_slow:IsPurgable()
    return true
end

function modifier_dzhin_call_of_shadows_slow:IsHidden()
    return false
end

function modifier_dzhin_call_of_shadows_slow:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return decFuncs
end

function modifier_dzhin_call_of_shadows_slow:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "move_slow" )
end

LinkLuaModifier( "modifier_dzhin_knifes_attack", "abilities/heroes/dzhin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dzhin_knifes_debuff", "abilities/heroes/dzhin.lua", LUA_MODIFIER_MOTION_NONE )

dzhin_knifes = class({})

function dzhin_knifes:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dzhin_5")
end

function dzhin_knifes:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function dzhin_knifes:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function dzhin_knifes:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_4 )
    return true
end

function dzhin_knifes:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_4 )
end

function dzhin_knifes:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local cast_direction = (point - caster_loc):Normalized()
    if point == caster_loc then
        cast_direction = caster:GetForwardVector()
    else
        cast_direction = (point - caster_loc):Normalized()
    end
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_hitloc"))
    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = point,
        bDeleteOnHit = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/dzin/ultimate_knife.vpcf",
        fDistance = 800,
        fStartRadius = 115,
        fEndRadius =115,
        vVelocity = cast_direction * 900,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = false,
    }

    for i = 1, 6 do
        caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")
        local angle = -50 + (i-1) * 20
        info.vVelocity = RotateVector2D(cast_direction,angle,true) * 900
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function dzhin_knifes:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dzhin_knifes_attack", {} )
        self:GetCaster():PerformAttack ( target, true, true, true, false, false, false, true )
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
    end
    return true
end

modifier_dzhin_knifes_attack = class({})

function modifier_dzhin_knifes_attack:IsHidden()
    return true
end

function modifier_dzhin_knifes_attack:IsPurgable()
    return false
end

function modifier_dzhin_knifes_attack:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

    }

    return funcs
end

function modifier_dzhin_knifes_attack:GetModifierDamageOutgoing_Percentage( params )
    if IsServer() then
        return self:GetAbility():GetSpecialValueFor( "damage_from_attack" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dzhin_4")
    end
end

function modifier_dzhin_knifes_attack:GetModifierPreAttack_BonusDamage( params )
    if IsServer() then
        return self:GetAbility():GetSpecialValueFor( "damage" ) * 100/(100+(self:GetAbility():GetSpecialValueFor( "damage_from_attack" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dzhin_4")))
    end
end

modifier_dzhin_knifes_debuff = class({})

function modifier_dzhin_knifes_debuff:IsHidden()
    return true
end

function modifier_dzhin_knifes_debuff:IsPurgable()
    return false
end