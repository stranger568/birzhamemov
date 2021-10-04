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
    if self.target == nil or self.target:IsAlive() == false or self.target:IsInvulnerable() then 
        self:Destroy()
    end
end

function modifier_EdwardBil_Agression:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }

    return funcs
end

function modifier_EdwardBil_Agression:GetModifierIncomingPhysicalDamage_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("phys_immunitet")
end

function modifier_EdwardBil_Agression:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_EdwardBil_Agression:GetModifierMoveSpeed_Absolute( params )
    return 550
end

function modifier_EdwardBil_Agression:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true
    }

    return state
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
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    if not self:GetCaster():HasTalent("special_bonus_birzha_edwardbill_1") then
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

function modifier_EdwardBil_Chi_Yes_passive:OnAttackLanded(kv)
    if not IsServer() then return end
    local attacker = kv.attacker
    local target = kv.target
    local chanceproc = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_3")
    local chance = RandomInt(1, 100)
    self.duration = self:GetAbility():GetSpecialValueFor("duration")
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_4")
    if self:GetParent() == attacker then
        if target:IsOther() then
            return nil
        end
        if self:GetParent():PassivesDisabled() then return end
        if attacker:IsIllusion() then return end
        if RandomInt(1, 100) <= chanceproc then
            target:AddNewModifier( attacker, self:GetAbility(), "modifier_EdwardBil_Chi_Yes_slow", {duration = self.duration})
            ApplyDamage({victim = target, attacker = attacker, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})
            if chance < 10 then
                attacker:EmitSound("edwardchidadouble")
            else
                attacker:EmitSound("edwardchida")
            end
        end
    end
end

modifier_EdwardBil_Chi_Yes_slow = class({})

function modifier_EdwardBil_Chi_Yes_slow:IsPurgable()
    return false
end

function modifier_EdwardBil_Chi_Yes_slow:DeclareFunctions()
    local funcs = {
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

function EdwardBil_V_EBASOS:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return nil end
    local damage_crit = self:GetSpecialValueFor("damage_crit") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_5")
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetCaster():GetAverageTrueAttackDamage(target) / 100 * damage_crit
    target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = duration})
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbilityDamageType()})
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

function modifier_edwardbill_ebasosina:OnAttackLanded(kv)
    if not IsServer() then return end
    local attacker = kv.attacker
    local target = kv.target
    local damage_percent = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_5")

    if self:GetParent() == attacker then
		if attacker:GetTeam() == target:GetTeam() then
			return
		end 
        if target:IsOther() then
            return nil
        end
        local damage = attacker:GetAverageTrueAttackDamage(target) / 100 * damage_percent
        local vision_cone = 85
        local caster_location = attacker:GetAbsOrigin()
        local target_location = target:GetAbsOrigin()
        local direction = (caster_location - target_location):Normalized()
        local forward_vector = target:GetForwardVector()
        local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)
        if attacker:PassivesDisabled() then return end
        if attacker:IsIllusion() then return end
        if angle <= vision_cone/2 then
            ApplyDamage({victim = target, attacker = attacker, damage = damage, damage_type = self:GetAbility():GetAbilityDamageType()})
            attacker:EmitSound("edwardebasos")
        end
        if attacker:HasTalent("special_bonus_birzha_edwardbill_7") then
            local chance = RandomInt(1, 100)
            if chance <= 8 then
                local damage_crit = self:GetAbility():GetSpecialValueFor("damage_crit") + self:GetCaster():FindTalentValue("special_bonus_birzha_edwardbill_5")
                local duration = self:GetAbility():GetSpecialValueFor("duration")
                local damage = attacker:GetAverageTrueAttackDamage(target) / 100 * damage_crit
                target:AddNewModifier(attacker, self:GetAbility(), "modifier_birzha_bashed", {duration = duration})
                ApplyDamage({victim = target, attacker = attacker, damage = damage, damage_type = self:GetAbility():GetAbilityDamageType()})
                attacker:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Stun")  
                local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
                ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true );
                ParticleManager:SetParticleControlEnt( particle, 1, target, PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
                ParticleManager:SetParticleControlEnt( particle, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
                ParticleManager:ReleaseParticleIndex( particle )
                local particle_2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_hand.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
                ParticleManager:SetParticleControlEnt( particle_2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
                ParticleManager:SetParticleControlEnt( particle_2, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
                ParticleManager:ReleaseParticleIndex( particle_2 )
                local distance = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D()
                local direction = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
                local bump_point = attacker:GetAbsOrigin() - direction * (distance + 50)
                local knockbackProperties =
                {
                    center_x = bump_point.x,
                    center_y = bump_point.y,
                    center_z = bump_point.z,
                    duration = 0.5,
                    knockback_duration = 0.5,
                    knockback_distance = 100,
                    knockback_height = 300
                }
                target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackProperties )
            end
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

function edward_bil_prank:OnSpellStart()
    if not IsServer() then return end
    self.duration = self:GetSpecialValueFor("invis_duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self.duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_edward_bil_prank_invis", {duration = self.duration})
end

modifier_edward_bil_prank_invis = class({})

function modifier_edward_bil_prank_invis:CheckState()
if self:GetCaster():HasTalent("special_bonus_birzha_edwardbill_6") then
    return {[MODIFIER_STATE_INVISIBLE] = true,[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,}
end   
return {[MODIFIER_STATE_INVISIBLE] = true,}
end

function modifier_edward_bil_prank_invis:DeclareFunctions()
return {MODIFIER_EVENT_ON_ATTACK_LANDED,
MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_edward_bil_prank_invis:IsPurgable()
    return false
end

function modifier_edward_bil_prank_invis:OnAttackLanded(kv)
    if not IsServer() then return end

    local EdwardBil_Chi_Yes = self:GetCaster():FindAbilityByName("EdwardBil_Chi_Yes")
    if EdwardBil_Chi_Yes ~= nil then
        self.damage = EdwardBil_Chi_Yes:GetSpecialValueFor("bonus_damage")
    else
        self.damage = 0
    end
    
    if kv.attacker == self:GetParent() then
		if kv.attacker:GetTeam() == kv.target:GetTeam() then
			return
		end 
        self:Destroy()
        kv.target:AddNewModifier( kv.attacker, EdwardBil_Chi_Yes, "modifier_EdwardBil_Chi_Yes_slow", {duration = 0.5})
        ApplyDamage({victim = kv.target, attacker = kv.attacker, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})
        kv.attacker:EmitSound("edwardchida")
    end
end 

function modifier_edward_bil_prank_invis:GetModifierMoveSpeedBonus_Percentage()
    return 15
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
    return self:GetSpecialValueFor("radius")
end

modifier_edward_gopnik_aura = class({})

function modifier_edward_gopnik_aura:IsPurgable() return false end
function modifier_edward_gopnik_aura:IsHidden() return true end
function modifier_edward_gopnik_aura:IsAura() return true end
function modifier_edward_gopnik_aura:IsPermanent() return true end

function modifier_edward_gopnik_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
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
    local funcs = {
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