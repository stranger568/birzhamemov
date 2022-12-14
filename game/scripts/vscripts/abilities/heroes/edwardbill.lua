LinkLuaModifier( "modifier_EdwardBil_Agression", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_EdwardBil_Agression_debuff", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

EdwardBil_Agression = class({}) 

function EdwardBil_Agression:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function EdwardBil_Agression:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function EdwardBil_Agression:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function EdwardBil_Agression:CastFilterResultTarget(target)
    if not IsServer() then return end
    if not self:GetCaster():HasScepter() then
        if target:IsMagicImmune() then
            return UF_FAIL_MAGIC_IMMUNE_ENEMY
        end
    end
    local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
    return nResult
end

function EdwardBil_Agression:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb(self) then return nil end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_EdwardBil_Agression", {duration = duration * (1 - self.target:GetStatusResistance())})
    self.target:AddNewModifier( self:GetCaster(), self, "modifier_EdwardBil_Agression_debuff", {duration = (duration + 1) * (1 - self.target:GetStatusResistance())})
    self:GetCaster():EmitSound("edwardcrazy")
end

modifier_EdwardBil_Agression = class({}) 

function modifier_EdwardBil_Agression:IsHidden()
    return false
end

function modifier_EdwardBil_Agression:IsPurgable()
    return false
end

function modifier_EdwardBil_Agression:OnCreated()
    self.phys_immunitet = self:GetAbility():GetSpecialValueFor("phys_immunitet") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_6")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    if not IsServer() then return end
    self.target = self:GetAbility().target
    self:GetCaster():SetRenderColor(255, 0, 0)
    local order =
    {
        UnitIndex = self:GetParent():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(order)
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(0.05)
end

function modifier_EdwardBil_Agression:OnDestroy()
   if not IsServer() then return end
    self:GetParent():Interrupt()
    self:GetParent():SetForceAttackTarget(nil)
    self:GetParent():SetForceAttackTargetAlly(nil)
    self:GetParent():Stop()
    self:GetParent():SetRenderColor(255, 255, 255)
end

function modifier_EdwardBil_Agression:OnIntervalThink()
    if not IsServer() then return end
    if self.target and self.target:IsAlive() then
        self:GetParent():MoveToTargetToAttack(self.target)
    end
    if self.target == nil or not self.target:IsAlive() or self.target:HasModifier("modifier_fountain_passive_invul") or ( self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target) ) then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_EdwardBil_Agression:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
    }
    return funcs
end

function modifier_EdwardBil_Agression:GetModifierIncomingPhysicalDamage_Percentage( params )
    return self.phys_immunitet
end

function modifier_EdwardBil_Agression:GetModifierAttackSpeedBonus_Constant( params )
    return self.bonus_attack_speed
end

function modifier_EdwardBil_Agression:GetModifierMoveSpeed_Absolute( params )
    return 550
end

function modifier_EdwardBil_Agression:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true
    }

    if self:GetCaster():HasShard() then
        state = {
            [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
            [MODIFIER_STATE_FAKE_ALLY] = true
        }       
    end

    return state
end

function modifier_EdwardBil_Agression:GetModifierIgnoreCastAngle()
    return 1
end

modifier_EdwardBil_Agression_debuff = class({}) 

function modifier_EdwardBil_Agression_debuff:IsPurgable()
    return false
end

function modifier_EdwardBil_Agression_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_EdwardBil_Agression_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }

    if not self:GetCaster():HasTalent("special_bonus_birzha_edwardbill_7") then
        return
    end

    return state
end

function modifier_EdwardBil_Agression_debuff:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("target_movespeed") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_2")
end

function modifier_EdwardBil_Agression_debuff:GetEffectName()
    return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf"
end

LinkLuaModifier("modifier_EdwardBil_Chi_Yes_passive", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_EdwardBil_Chi_Yes_slow", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE)

EdwardBil_Chi_Yes = class({})

function EdwardBil_Chi_Yes:GetIntrinsicModifierName()
    return "modifier_EdwardBil_Chi_Yes_passive"
end

modifier_EdwardBil_Chi_Yes_passive = class ({})

function modifier_EdwardBil_Chi_Yes_passive:IsHidden()
    return true
end

function modifier_EdwardBil_Chi_Yes_passive:IsPurgable()
    return false
end

function modifier_EdwardBil_Chi_Yes_passive:DeclareFunctions()
    local declfuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}

    return declfuncs
end

function modifier_EdwardBil_Chi_Yes_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():PassivesDisabled() then return end
    if params.attacker:IsIllusion() then return end

    local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_4")
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_1")

    if RollPercentage( chance ) then
        params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_EdwardBil_Chi_Yes_slow", {duration = duration * (1 - params.target:GetStatusResistance()) })
        ApplyDamage({victim = params.target, attacker = params.attacker, damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_PHYSICAL})
        if RollPercentage(10) then
            params.attacker:EmitSound("edwardchidadouble")
        else
            params.attacker:EmitSound("edwardchida")
        end
    end
end

modifier_EdwardBil_Chi_Yes_slow = class({})

function modifier_EdwardBil_Chi_Yes_slow:IsPurgable()
    return false
end

function modifier_EdwardBil_Chi_Yes_slow:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_EdwardBil_Chi_Yes_slow:GetModifierMoveSpeedBonus_Percentage( params )
    return -100
end

function modifier_EdwardBil_Chi_Yes_slow:GetModifierAttackSpeedBonus_Constant( params )
    return -100
end

LinkLuaModifier("modifier_edwardbill_ebasosina", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE)

EdwardBil_V_EBASOS = class({})

function EdwardBil_V_EBASOS:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function EdwardBil_V_EBASOS:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function EdwardBil_V_EBASOS:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function EdwardBil_V_EBASOS:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_edwardbill_8") then
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function EdwardBil_V_EBASOS:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return nil end

    local damage_crit = self:GetSpecialValueFor("damage_crit")
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * damage_crit

    target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = duration * (1 - target:GetStatusResistance()) })
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, ability = self, damage_type = self:GetAbilityDamageType()})

    local distance = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    local direction = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 50)

    local knockbackProperties =
    {
        center_x = bump_point.x,
        center_y = bump_point.y,
        center_z = bump_point.z,
        duration = 0.5 * (1 - target:GetStatusResistance()),
        knockback_duration = 0.5 * (1 - target:GetStatusResistance()),
        knockback_distance = 100,
        knockback_height = 300
    }

    target:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )

    self:GetCaster():EmitSound("billstun") 

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
    ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle, 1, target, PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
    ParticleManager:ReleaseParticleIndex( particle )

    local particle_2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_hand.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
    ParticleManager:SetParticleControlEnt( particle_2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle_2, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
    ParticleManager:ReleaseParticleIndex( particle_2 )

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
end

function EdwardBil_V_EBASOS:GetIntrinsicModifierName()
    return "modifier_edwardbill_ebasosina"
end

modifier_edwardbill_ebasosina = class ({})

function modifier_edwardbill_ebasosina:IsHidden()
    return true
end

function modifier_edwardbill_ebasosina:IsPurgable()
    return false
end

function modifier_edwardbill_ebasosina:DeclareFunctions()
    local declfuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}

    return declfuncs
end

function modifier_edwardbill_ebasosina:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():PassivesDisabled() then return end
    
    local damage_percent = self:GetAbility():GetSpecialValueFor("damage")
    local damage = params.attacker:GetAverageTrueAttackDamage(nil) / 100 * damage_percent

    local vision_cone = 85
    local caster_location = params.attacker:GetAbsOrigin()
    local target_location = params.target:GetAbsOrigin()
    local direction = (caster_location - target_location):Normalized()
    local forward_vector = params.target:GetForwardVector()
    local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)

    if angle <= vision_cone/2 then
        ApplyDamage({victim = params.target, attacker = params.attacker, damage = damage, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
        params.attacker:EmitSound("edwardebasos")
    end

    if params.attacker:IsIllusion() then return end

    if params.attacker:HasTalent("special_bonus_birzha_edwardbill_8") then
        if RollPercentage(self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_8")) then

            local damage_crit = self:GetAbility():GetSpecialValueFor("damage_crit")
            local duration = self:GetAbility():GetSpecialValueFor("duration")
            local damage = params.attacker:GetAverageTrueAttackDamage(nil) / 100 * damage_crit

            params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_birzha_stunned", {duration = duration * (1 - params.target:GetStatusResistance()) })

            ApplyDamage({victim = params.target, attacker = params.attacker, damage = damage, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})

            params.attacker:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Stun")  

            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
            ParticleManager:SetParticleControlEnt( particle, 0, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetOrigin(), true );
            ParticleManager:SetParticleControlEnt( particle, 1, target, PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
            ParticleManager:SetParticleControlEnt( particle, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
            ParticleManager:ReleaseParticleIndex( particle )

            local particle_2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_hand.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
            ParticleManager:SetParticleControlEnt( particle_2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
            ParticleManager:SetParticleControlEnt( particle_2, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
            ParticleManager:ReleaseParticleIndex( particle_2 )

            local distance = (params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()):Length2D()

            local direction = (params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()):Normalized()

            local bump_point = params.attacker:GetAbsOrigin() - direction * (distance + 50)

            local knockbackProperties =
            {
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = 0.5 * (1 - params.target:GetStatusResistance()),
                knockback_duration = 0.5 * (1 - params.target:GetStatusResistance()),
                knockback_distance = 100,
                knockback_height = 300
            }
            params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackProperties )
        end
    end
end

LinkLuaModifier( "modifier_edward_bil_prank_invis", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE )

edward_bil_prank = class({})

function edward_bil_prank:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function edward_bil_prank:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function edward_bil_prank:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_edwardbill_3") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function edward_bil_prank:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function edward_bil_prank:OnSpellStart()
    if not IsServer() then return end
    self.duration = self:GetSpecialValueFor("invis_duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_edward_bil_prank_invis", {duration = self.duration})
end

modifier_edward_bil_prank_invis = class({})

function modifier_edward_bil_prank_invis:IsPurgable()
    return false
end

function modifier_edward_bil_prank_invis:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED 

    }
    return decFuncs
end

function modifier_edward_bil_prank_invis:GetModifierInvisibilityLevel()
    return 1
end

function modifier_edward_bil_prank_invis:OnAttack( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    local EdwardBil_Chi_Yes = self:GetCaster():FindAbilityByName("EdwardBil_Chi_Yes")
    if EdwardBil_Chi_Yes and EdwardBil_Chi_Yes:GetLevel() > 0 then
        local duration = EdwardBil_Chi_Yes:GetSpecialValueFor("duration")
        local damage = EdwardBil_Chi_Yes:GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_1")
        params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_EdwardBil_Chi_Yes_slow", {duration = duration * (1 - params.target:GetStatusResistance()) })
        ApplyDamage({victim = params.target, attacker = params.attacker, damage = damage, ability = EdwardBil_Chi_Yes, damage_type = DAMAGE_TYPE_PHYSICAL})
        params.attacker:EmitSound("edwardchida")
    end
    self:Destroy()
end

function modifier_edward_bil_prank_invis:OnAbilityExecuted(keys)
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

function modifier_edward_bil_prank_invis:CheckState()
    return 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end

LinkLuaModifier("modifier_edward_gopnik_aura", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_edward_gopnik", "abilities/heroes/edwardbill.lua", LUA_MODIFIER_MOTION_NONE)

edward_gopnik = class({})

function edward_gopnik:GetIntrinsicModifierName()
    return "modifier_edward_gopnik_aura"
end

function edward_gopnik:OnUpgrade()
    local caster = self:GetCaster()
    if self:GetLevel() == 1 then
        self.Wmotka1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/dosa_back/dosa_back.vmdl"})
        self.Wmotka2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/dosa_hat/dosa_hat.vmdl"})
        self.Wmotka3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/dosa_shoulder/dosa_shoulder.vmdl"})
        self.Wmotka4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/dosa_tail/dosa_tail.vmdl"})
        self.Wmotka1:FollowEntity(caster, true)
        self.Wmotka2:FollowEntity(caster, true)
        self.Wmotka3:FollowEntity(caster, true)
        self.Wmotka4:FollowEntity(caster, true)
    elseif self:GetLevel() == 2 then
        UTIL_Remove(self.Wmotka1)
        UTIL_Remove(self.Wmotka2)
        UTIL_Remove(self.Wmotka3)
        UTIL_Remove(self.Wmotka4)
        self.Wmotka1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/sir_meepalot_arms/sir_meepalot_arms.vmdl"})
        self.Wmotka2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/sir_meepalot_back/sir_meepalot_back.vmdl"})
        self.Wmotka3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/sir_meepalot_head/sir_meepalot_head.vmdl"})
        self.Wmotka4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/sir_meepalot_shoulder/sir_meepalot_shoulder.vmdl"})
        self.Wmotka1:FollowEntity(caster, true)
        self.Wmotka2:FollowEntity(caster, true)
        self.Wmotka3:FollowEntity(caster, true)
        self.Wmotka4:FollowEntity(caster, true)
    elseif self:GetLevel() == 3 then
        UTIL_Remove(self.Wmotka1)
        UTIL_Remove(self.Wmotka2)
        UTIL_Remove(self.Wmotka3)
        UTIL_Remove(self.Wmotka4)
        self.Wmotka1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/meepo_skeletonkey_bandana/meepo_skeletonkey_bandana.vmdl"})
        self.Wmotka2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/colossal_crystal_chorus/colossal_crystal_chorus.vmdl"})
        self.Wmotka3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/riftshadow_roamer_hat/riftshadow_roamer_hat.vmdl"})
        self.Wmotka4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/sir_meepalot_shoulder/sir_meepalot_shoulder.vmdl"})
        self.Wmotka1:FollowEntity(caster, true)
        self.Wmotka2:FollowEntity(caster, true)
        self.Wmotka3:FollowEntity(caster, true)
        self.Wmotka4:FollowEntity(caster, true)
    end
end

function edward_gopnik:GetCastRange()
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_5")
end

modifier_edward_gopnik_aura = class({})

function modifier_edward_gopnik_aura:IsPurgable() return false end
function modifier_edward_gopnik_aura:IsHidden() return true end
function modifier_edward_gopnik_aura:IsAura() return true end
function modifier_edward_gopnik_aura:IsPermanent() return true end

function modifier_edward_gopnik_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_5")
end

function modifier_edward_gopnik_aura:GetAuraSearchFlags()
    return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_edward_gopnik_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY + DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_edward_gopnik_aura:GetAuraSearchType()
    return self:GetAbility():GetAbilityTargetType()
end

function modifier_edward_gopnik_aura:GetModifierAura()
    return "modifier_edward_gopnik"
end

modifier_edward_gopnik = class({})

function modifier_edward_gopnik:IsHidden() return false end
function modifier_edward_gopnik:IsPurgable() return false end

function modifier_edward_gopnik:IsDebuff()
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        return false
    end
    return true
end

function modifier_edward_gopnik:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_edward_gopnik:GetModifierBaseDamageOutgoing_Percentage()
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        return self:GetAbility():GetSpecialValueFor("friendly_damage")
    end
    return self:GetAbility():GetSpecialValueFor("enemy_damage")
end

function modifier_edward_gopnik:GetModifierPhysicalArmorBonus()
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        return self:GetAbility():GetSpecialValueFor("friendly_armor")
    end
    return 0
end

function modifier_edward_gopnik:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        return self:GetAbility():GetSpecialValueFor("friendly_at")
    end
    return self:GetAbility():GetSpecialValueFor("enemy_at")
end