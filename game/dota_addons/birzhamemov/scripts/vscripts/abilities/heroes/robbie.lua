LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_robbie_trap", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)

robbie_trap = class({})

function robbie_trap:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function robbie_trap:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function robbie_trap:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function robbie_trap:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local info = {
        EffectName = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
        Ability = self,
        iMoveSpeed = 1500,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("Hero_NagaSiren.Ensnare.Cast")
end

function robbie_trap:OnProjectileHit_ExtraData(hTarget, vLocation, hExtraData)
    if hTarget then
        if not hTarget:HasModifier("modifier_robbie_trap") then
            hTarget:EmitSound("Hero_NagaSiren.Ensnare.Target")
        end
        local duration = self:GetSpecialValueFor("duration")
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_robbie_trap", {duration = duration * (1 - hTarget:GetStatusResistance())})
    end
end

modifier_robbie_trap = class({})

function modifier_robbie_trap:IsPurgable() return true end
function modifier_robbie_trap:GetEffectName() return "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf" end
function modifier_robbie_trap:GetEffectAttachType() return PATTACH_ABSORIGIN end

function modifier_robbie_trap:CheckState() return {
    [MODIFIER_STATE_ROOTED] = true,
} end

function modifier_robbie_trap:DeclareFunctions() return {
    MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
} end

function modifier_robbie_trap:GetModifierProvidesFOWVision()
    return 1
end

LinkLuaModifier("modifier_roby_agility", "abilities/heroes/robbie.lua", LUA_MODIFIER_MOTION_NONE)

roby_agility = class({})

function roby_agility:GetIntrinsicModifierName()
    return "modifier_roby_agility"
end

modifier_roby_agility = class({})

function modifier_roby_agility:IsHidden()
    return true
end

function modifier_roby_agility:OnCreated()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_movespeed_cap", {})
end

function modifier_roby_agility:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,}
    return declfuncs
end

function modifier_roby_agility:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

LinkLuaModifier("modifier_robbie_timeinvis", "abilities/heroes/robbie.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_robbie_timeinvis_invis", "abilities/heroes/robbie.lua", LUA_MODIFIER_MOTION_NONE)

robbie_timeinvis = class({})

function robbie_timeinvis:GetIntrinsicModifierName()
    return "modifier_robbie_timeinvis"
end

modifier_robbie_timeinvis = class({})

function modifier_robbie_timeinvis:IsHidden()
    return true
end

function modifier_robbie_timeinvis:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_robbie_timeinvis:OnIntervalThink()
    if self:GetParent():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_robbie_timeinvis_invis", {duration = duration})
    else
        self:GetParent():RemoveModifierByName("modifier_robbie_timeinvis_invis")
    end
end

function modifier_robbie_timeinvis:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_ATTACK_LANDED,}
    return declfuncs
end

function modifier_robbie_timeinvis:OnAttackLanded( keys )
    if not IsServer() then return end
    local target = keys.target
    local attacker = keys.attacker
    local parent = self:GetParent()
    if parent == attacker then
	    if attacker:GetTeam() == target:GetTeam() then
			return
		end 
        if target:IsOther() then
            return nil
        end
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if not self:GetCaster():HasTalent("special_bonus_birzha_robbie_4") then
            self:GetAbility():UseResources(false,false,true)
        end
        local agility_damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_1")
        local victim_angle = target:GetAnglesAsVector().y
        local origin_difference = target:GetAbsOrigin() - attacker:GetAbsOrigin()
        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
        origin_difference_radian = origin_difference_radian * 180
        local attacker_angle = origin_difference_radian / math.pi
        attacker_angle = attacker_angle + 180.0
        local result_angle = attacker_angle - victim_angle
        result_angle = math.abs(result_angle)
        if result_angle >= (180 - (self:GetAbility():GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (self:GetAbility():GetSpecialValueFor("backstab_angle") / 2)) then 
            EmitSoundOn("Hero_Riki.Backstab", target)
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) 
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
            ApplyDamage({victim = target, attacker = attacker, damage = attacker:GetAgility() * agility_damage_multiplier, damage_type = DAMAGE_TYPE_PHYSICAL})
        end
    end
end

function modifier_robbie_timeinvis:GetModifierConstantHealthRegen()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end


modifier_robbie_timeinvis_invis = class({})

function modifier_robbie_timeinvis_invis:IsHidden()
    return true
end

function modifier_robbie_timeinvis_invis:OnCreated()
    local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_robbie_timeinvis_invis:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_robbie_timeinvis_invis:GetModifierInvisibilityLevel()
    return 1
end

function modifier_robbie_timeinvis_invis:CheckState()
    local state = { [MODIFIER_STATE_INVISIBLE] = true}
    return state
end

LinkLuaModifier("modifier_robi_WeAreNumberOne", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_robi_WeAreNumberOne_buff", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_robi_WeAreNumberOne_illusion_debuff", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)

Robi_WeAreNumberOne = class({}) 

function Robi_WeAreNumberOne:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Robi_WeAreNumberOne:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Robi_WeAreNumberOne:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_3")
    
    local ability_reality = caster:FindAbilityByName("Robi_WeAreNumberOneTeleport")
    if ability_reality ~= nil then
        ability_reality:SetLevel(1)
    end
    Timers:CreateTimer(duration, function()
        if ability_reality ~= nil then
            ability_reality:SetLevel(0)
        end
    end)
    EmitGlobalSound("WeAreNumberOne")
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)
    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_robi_WeAreNumberOne", {duration = duration})
    end
end

modifier_robi_WeAreNumberOne = class({})

function modifier_robi_WeAreNumberOne:IsHidden()
    return true
end

function modifier_robi_WeAreNumberOne:OnCreated()
    if not IsServer() then return end
    local origin = self:GetParent():GetAbsOrigin() + RandomVector(100)
    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_3")
    local outgoingDamage = self:GetAbility():GetSpecialValueFor("illusion_damage_outgoing") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_2")
    print(outgoingDamage)
    local incomingDamage = self:GetAbility():GetSpecialValueFor("illusion_damage_incoming")

    local t = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=outgoingDamage,incoming_damage=incomingDamage}, 1, 1, true, true ) 
    for k, v in pairs(t) do
        v:RemoveModifierByName("modifier_birzha_premium")
        v:RemoveModifierByName("modifier_birzha_gob")
        v:RemoveModifierByName("modifier_birzha_vip")
        v:RemoveModifierByName("modifier_dragonball_effect")
        v:SetAbsOrigin(origin)
        v:SetForwardVector(self:GetParent():GetAbsOrigin() - v:GetAbsOrigin())
        v:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_robi_WeAreNumberOne_buff", {enemy_entindex = self:GetParent():entindex()})
        v:MoveToTargetToAttack(self:GetParent())
        v:SetAggroTarget(self:GetParent())
    end
end

function modifier_robi_WeAreNumberOne:OnRefresh()
    if not IsServer() then return end
    local origin = self:GetParent():GetAbsOrigin() + RandomVector(100)
    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_3")
    local outgoingDamage = self:GetAbility():GetSpecialValueFor("illusion_damage_outgoing") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_2")
    print(outgoingDamage)
    local incomingDamage = self:GetAbility():GetSpecialValueFor("illusion_damage_incoming")

    local t = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=outgoingDamage,incoming_damage=incomingDamage}, 1, 1, true, true ) 
    for k, v in pairs(t) do
        v:RemoveDonate()
        v:SetAbsOrigin(origin)
        v:SetForwardVector(self:GetParent():GetAbsOrigin() - v:GetAbsOrigin())
        v:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_robi_WeAreNumberOne_buff", {enemy_entindex = self:GetParent():entindex()})
        v:MoveToTargetToAttack(self:GetParent())
        v:SetAggroTarget(self:GetParent())
    end
end

modifier_robi_WeAreNumberOne_buff = class({})

function modifier_robi_WeAreNumberOne_buff:IsHidden()
    return true
end

function modifier_robi_WeAreNumberOne_buff:OnCreated(keys)
    if not IsServer() then return end
    self.aggro_target = EntIndexToHScript(keys.enemy_entindex)
end

function modifier_robi_WeAreNumberOne_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,}
    return declfuncs
end

function modifier_robi_WeAreNumberOne_buff:GetModifierMoveSpeed_Absolute()
    return 400
end

function modifier_robi_WeAreNumberOne_buff:CheckState()
    if not self.aggro_target:IsAlive() or self.aggro_target == nil then
        UTIL_Remove(self:GetParent())
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
    local state = { [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,[MODIFIER_STATE_COMMAND_RESTRICTED] = true,}
    return state
end

Robi_WeAreNumberOneTeleport = class({})

function Robi_WeAreNumberOneTeleport:OnSpellStart()
    if not IsServer() then return end
    local vPoint = self:GetCursorPosition()
    local target = Entities:FindByNameNearest(self:GetCaster():GetUnitName(), vPoint, 0)
    if target:IsIllusion() then
        local caster_forward_vector = self:GetCaster():GetForwardVector()
        local target_forward_vector = target:GetForwardVector()
        self:GetCaster():SetForwardVector(target_forward_vector)
        target:SetForwardVector(caster_forward_vector)
        local caster_current_position = self:GetCaster():GetAbsOrigin()
        local target_current_position = target:GetAbsOrigin()
        target:SetAbsOrigin(caster_current_position)    
        self:GetCaster():SetAbsOrigin(target_current_position)
        FindClearSpaceForUnit( self:GetCaster(), target_current_position, true )
        EmitSoundOn("Hero_Spectre.Reality", self:GetCaster())
    end
end