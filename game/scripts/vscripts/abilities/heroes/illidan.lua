LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Illidan_ChaseTheDevil_debuff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Illidan_ChaseTheDevil_buff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Illidan_ChaseTheDevil = class({})

function Illidan_ChaseTheDevil:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Illidan_ChaseTheDevil:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Illidan_ChaseTheDevil:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Illidan_ChaseTheDevil:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
    target:EmitSound("Hero_LifeStealer.OpenWounds")
    target:AddNewModifier(caster, self, "modifier_Illidan_ChaseTheDevil_debuff", { duration = duration * (1 - target:GetStatusResistance()) } )
    caster:AddNewModifier(caster, self, "modifier_Illidan_ChaseTheDevil_buff", { duration = duration } )
end

modifier_Illidan_ChaseTheDevil_debuff = class({})

function modifier_Illidan_ChaseTheDevil_debuff:IsPurgable()
    return false
end

function modifier_Illidan_ChaseTheDevil_debuff:IsPurgeException()
    return true
end

function modifier_Illidan_ChaseTheDevil_debuff:OnCreated( kv )
    if not IsServer() then return end
    self.step = 1
    self:StartIntervalThink( 1 )
end

function modifier_Illidan_ChaseTheDevil_debuff:OnRefresh( kv )
    if not IsServer() then return end
    self.step = 1
end

function modifier_Illidan_ChaseTheDevil_debuff:OnIntervalThink()
    if not IsServer() then return end
    self.step = self.step + 1
end

function modifier_Illidan_ChaseTheDevil_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACKED,
    }

    return funcs
end

function modifier_Illidan_ChaseTheDevil_debuff:GetModifierMoveSpeedBonus_Percentage()
    if not IsServer() then return end
    return self:GetAbility():GetLevelSpecialValueFor( "move_slow", self.step )
end

function modifier_Illidan_ChaseTheDevil_debuff:GetModifierBaseDamageOutgoing_Percentage()
    return -self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_Illidan_ChaseTheDevil_debuff:OnAttacked( params )
    if IsServer() then
        if params.target~=self:GetParent() then return end
        if params.attacker:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then return end
        local heal = self:GetAbility():GetSpecialValueFor( "heal_percent" ) / 100
        params.attacker:Heal( heal * params.damage, self:GetAbility() )
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_Illidan_ChaseTheDevil_debuff:GetEffectName()
    return "particles/ilidan/life_stealer_open_wounds.vpcf"
end

function modifier_Illidan_ChaseTheDevil_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_Illidan_ChaseTheDevil_buff = class({})

function modifier_Illidan_ChaseTheDevil_buff:IsPurgable()
    return false
end

function modifier_Illidan_ChaseTheDevil_buff:IsPurgeException()
    return true
end

function modifier_Illidan_ChaseTheDevil_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }

    return funcs
end

function modifier_Illidan_ChaseTheDevil_buff:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

LinkLuaModifier("modifier_illidan_pepper", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

Illidan_DrinkSomePepper = class({})

function Illidan_DrinkSomePepper:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Illidan_DrinkSomePepper:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_3")
    local heal = self:GetSpecialValueFor("regen")
    caster:EmitSound("Hero_Terrorblade.Metamorphosis")
    caster:Heal( heal, self )
    caster:AddNewModifier(caster, self, "modifier_illidan_pepper", { duration = duration } )
end

modifier_illidan_pepper = class({})

function modifier_illidan_pepper:IsPurgable()
    return true
end

function modifier_illidan_pepper:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_illidan_pepper:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_illidan_pepper:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_illidan_pepper:GetEffectName()
    return "particles/illidan/illidan_pepper_buff.vpcf"
end

function modifier_illidan_pepper:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_illidan_pepper:GetStatusEffectName()
    return "particles/illidan/pepper_effect.vpcf" 
end

function modifier_illidan_pepper:StatusEffectPriority()
    return 5
end

LinkLuaModifier("modifier_illidan_KidsHit", "abilities/heroes/illidan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_illidan_KidsHit_debuff", "abilities/heroes/illidan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_illidan_KidsHit_scepter", "abilities/heroes/illidan.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

Illidan_KidsHit = class({})

function Illidan_KidsHit:GetIntrinsicModifierName()
    return "modifier_illidan_KidsHit"
end

function Illidan_KidsHit:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
    if self:GetCaster():HasScepter() then
        behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return behavior
end

function Illidan_KidsHit:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("illidan_force")
    local point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 600
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.7)
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_illidan_KidsHit_scepter", {
        duration    = math.min((point - self:GetCaster():GetAbsOrigin()):Length2D(), 600),
        x           = point.x,
        y           = point.y,
        z           = point.z
    })
    local vDirection = point - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()

    local info = {
        EffectName = "",
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(), 
        fStartRadius = 70,
        fEndRadius = 70,
        vVelocity = vDirection * 1200,
        fDistance = #(point - self:GetCaster():GetOrigin()),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_DAMAGE_FLAG_NONE,
    }

    ProjectileManager:CreateLinearProjectile( info )
end

function Illidan_KidsHit:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if hTarget then 
        self:GetCaster():EmitSound("illidan_blink")
        local victim_angle = hTarget:GetAnglesAsVector()
        local victim_forward_vector = hTarget:GetForwardVector()
        local victim_angle_rad = victim_angle.y*math.pi/180
        local victim_position = hTarget:GetAbsOrigin()
        local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
        self:GetCaster():SetAbsOrigin(attacker_new)
        FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
        local particle_2 = ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_end_fm06.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle_2, 0, self:GetCaster():GetAbsOrigin())
        self:GetCaster():SetForwardVector(victim_forward_vector)
        self:GetCaster():MoveToTargetToAttack(hTarget)
        local modifier = self:GetCaster():FindModifierByName("modifier_illidan_KidsHit_scepter")
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        return
    end
end 

modifier_illidan_KidsHit_scepter = class({})

function modifier_illidan_KidsHit_scepter:IsPurgable() return false end
function modifier_illidan_KidsHit_scepter:IsHidden() return true end
function modifier_illidan_KidsHit_scepter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_illidan_KidsHit_scepter:IgnoreTenacity() return true end
function modifier_illidan_KidsHit_scepter:IsMotionController() return true end
function modifier_illidan_KidsHit_scepter:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_illidan_KidsHit_scepter:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
end

function modifier_illidan_KidsHit_scepter:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        self.velocity = 1250
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_illidan_KidsHit_scepter:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_illidan_KidsHit_scepter:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_illidan_KidsHit_scepter:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
end

function modifier_illidan_KidsHit_scepter:GetEffectName()
    return "particles/illidan_scepter_thirst_owner.vpcf"
end

function modifier_illidan_KidsHit_scepter:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end













































function Illidan_KidsHit:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return 20
    end
end

function Illidan_KidsHit:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
        return 175
    end
end

modifier_illidan_KidsHit = class({})

function modifier_illidan_KidsHit:IsPurgable() return false end
function modifier_illidan_KidsHit:IsHidden() return true end

function modifier_illidan_KidsHit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_illidan_KidsHit:OnAttackStart(keys)
    if keys.attacker == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if keys.target:IsOther() then
            return nil
        end
        self.critProc = false
        self.chance = self:GetAbility():GetSpecialValueFor("chance")
        self.crit = self:GetAbility():GetSpecialValueFor("crit")
        self.duration = self:GetAbility():GetSpecialValueFor("duration")
        if self.chance >= RandomInt(1, 100) then
            self:GetParent():StartGesture(ACT_DOTA_ATTACK_EVENT_BASH)
            self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Impact.Immortal")
            local crit_pfx = ParticleManager:CreateParticle("particles/guts/skeleton_king_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_pfx)
            self.critProc = true
            return self.crit
        end 
    end
end

function modifier_illidan_KidsHit:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    if self.critProc == true then
        return self.crit
    else
        return nil
    end
end

function modifier_illidan_KidsHit:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self.critProc == true then
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_illidan_KidsHit_debuff", {duration = self.duration * (1 - params.target:GetStatusResistance())})
            self.critProc = false
        end
    end
end

modifier_illidan_KidsHit_debuff = class({})

function modifier_illidan_KidsHit_debuff:IsPurgable() return true end
function modifier_illidan_KidsHit_debuff:IsPurgeException() return true end

function modifier_illidan_KidsHit_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

LinkLuaModifier("modifier_illidan_Brutality_buff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_illidan_Brutality_shard", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

Illidan_Brutality = class({})

function Illidan_Brutality:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function Illidan_Brutality:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Illidan_Brutality:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_1")
    caster:EmitSound("ilidanultimate")
    caster:AddNewModifier(caster, self, "modifier_illidan_Brutality_buff", { duration = duration } )
end

modifier_illidan_Brutality_buff = class({})

function modifier_illidan_Brutality_buff:IsPurgable()
    return false
end

function modifier_illidan_Brutality_buff:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/ilidan/warlock_shadow_word_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 2, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_illidan_Brutality_buff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("ilidanultimate")
end

function modifier_illidan_Brutality_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_illidan_Brutality_buff:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
        if params.target:IsOther() then
            return nil
        end
        if self:GetCaster():HasShard() then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_illidan_Brutality_shard", {duration = 5})
        end
        local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_2")
        local duration = self:GetAbility():GetSpecialValueFor("stun")
        if chance >= RandomInt(1, 100) then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_bashed", {duration = duration})
        end 
    end
end

function modifier_illidan_Brutality_buff:GetModifierModelChange()
    return "models/heroes/terrorblade/demon.vmdl"
end

function modifier_illidan_Brutality_buff:GetStatusEffectName()
    return "particles/illidan/illidan_ozverenie_buff.vpcf" 
end

function modifier_illidan_Brutality_buff:StatusEffectPriority()
    return 10
end

function modifier_illidan_Brutality_buff:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }

    return state
end

modifier_illidan_Brutality_shard = class({})

function modifier_illidan_Brutality_shard:IsPurgable() return true end

function modifier_illidan_Brutality_shard:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_illidan_Brutality_shard:OnIntervalThink()
    if not IsServer() then return end
    local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = 25,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end

function modifier_illidan_Brutality_shard:GetEffectName()
    return "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf"
end

function modifier_illidan_Brutality_shard:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end