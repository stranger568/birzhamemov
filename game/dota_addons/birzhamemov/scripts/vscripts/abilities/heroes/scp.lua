LinkLuaModifier("modifier_Scp_fast_movement", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scp_fast_movement_invisibility", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Scp_fast_movement = class({}) 

function Scp_fast_movement:GetIntrinsicModifierName()
    return "modifier_Scp_fast_movement"
end

function Scp_fast_movement:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

modifier_Scp_fast_movement = class({})

function modifier_Scp_fast_movement:IsHidden()
    return true
end

function modifier_Scp_fast_movement:IsPurgable()
    return false
end

function modifier_Scp_fast_movement:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_Scp_fast_movement:OnIntervalThink()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local enemyHeroes = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    if #enemyHeroes>0 or self:GetParent():PassivesDisabled() then
        self:GetParent():RemoveModifierByName("modifier_movespeed_cap")
        self:GetParent():RemoveModifierByName("modifier_Scp_fast_movement_invisibility")
    else
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_movespeed_cap", {})
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Scp_fast_movement_invisibility", {})
    end
end

modifier_Scp_fast_movement_invisibility = class({})

function modifier_Scp_fast_movement_invisibility:IsHidden()
    return false
end

function modifier_Scp_fast_movement_invisibility:IsPurgable()
    return false
end

function modifier_Scp_fast_movement_invisibility:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    }

    return funcs
end

function modifier_Scp_fast_movement_invisibility:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_Scp_fast_movement_invisibility:GetModifierInvisibilityLevel()
    return 1
end

function modifier_Scp_fast_movement_invisibility:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = true,
    }

    return state
end

LinkLuaModifier("modifier_scp_screamer", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)

Scp173_Screamer = class({}) 

function Scp173_Screamer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Scp173_Screamer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Scp173_Screamer:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Scp173_Screamer:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local victim_angle = target:GetAnglesAsVector()
    local victim_forward_vector = target:GetForwardVector()
    local victim_angle_rad = victim_angle.y*math.pi/180
    local victim_position = target:GetAbsOrigin()
    local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_2")
    if target:TriggerSpellAbsorb( self ) then return end
    self:GetCaster():SetAbsOrigin(attacker_new)
    FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
    self:GetCaster():SetForwardVector(victim_forward_vector)
    self:GetCaster():MoveToTargetToAttack(target)
    target:AddNewModifier(self:GetCaster(), self, "modifier_scp_screamer", {duration = duration * (1 - target:GetStatusResistance())})
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
end

modifier_scp_screamer = class({})

function modifier_scp_screamer:IsHidden()
    return false
end

function modifier_scp_screamer:IsPurgable()
    return false
end

function modifier_scp_screamer:IsPurgeException()
    return true
end

function modifier_scp_screamer:OnCreated()
    if not IsServer() then return end
    if not self:GetParent():IsIllusion() then
        local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
        EmitSoundOnClient("ScpScreamer", Player)
        CustomGameEventManager:Send_ServerToPlayer(Player, "ScpScreamerTrue", {} )
    end
end

function modifier_scp_screamer:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():IsIllusion() then
        local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
        CustomGameEventManager:Send_ServerToPlayer(Player, "ScpScreamerFalse", {} )
    end
end

function modifier_scp_screamer:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_scp_screamer:GetEffectName()
    return "particles/generic_gameplay/generic_sleep.vpcf"
end

function modifier_scp_screamer:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier("modifier_Scp_DamageAura", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scp_DamageAura_debuff", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)

Scp_DamageAura = class({}) 

function Scp_DamageAura:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_Scp_DamageAura"
end

function Scp_DamageAura:GetCastRange(location, target)
    return self:GetSpecialValueFor("aura_radius")
end

modifier_Scp_DamageAura = class({})

function modifier_Scp_DamageAura:IsHidden()
    return true
end

function modifier_Scp_DamageAura:IsPurgable()
    return false
end

function modifier_Scp_DamageAura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_Scp_DamageAura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_Scp_DamageAura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Scp_DamageAura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_Scp_DamageAura:GetModifierAura()
    return "modifier_Scp_DamageAura_debuff"
end

function modifier_Scp_DamageAura:IsAura()
    return true
end

modifier_Scp_DamageAura_debuff = class({})

function modifier_Scp_DamageAura_debuff:IsHidden()
    return false
end

function modifier_Scp_DamageAura_debuff:IsPurgable()
    return false
end

function modifier_Scp_DamageAura_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
end   

function modifier_Scp_DamageAura_debuff:OnIntervalThink()
    local target_max_hp = self:GetParent():GetMaxHealth() / 100
    local aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_1")
    local aura_damage_interval = self:GetAbility():GetSpecialValueFor("aura_damage_interval")
    
    if not self:GetParent():IsAncient() then
        local damage_table = {}
        damage_table.attacker = self:GetCaster()
        damage_table.victim = self:GetParent()
        damage_table.damage_type = DAMAGE_TYPE_PURE
        damage_table.ability = self:GetAbility()
        damage_table.damage = target_max_hp * -aura_damage * aura_damage_interval
        damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
        ApplyDamage(damage_table)
    end
end   

LinkLuaModifier("modifier_Scp_FastKill", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scp_ultimate_vision", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)

Scp_FastKill = class({}) 

function Scp_FastKill:GetIntrinsicModifierName()
    return "modifier_Scp_FastKill"
end

modifier_Scp_FastKill = class({})

function modifier_Scp_FastKill:IsHidden()
    return true
end

function modifier_Scp_FastKill:IsPurgable()
    return false
end

function modifier_Scp_FastKill:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_Scp_FastKill:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if params.target:IsBoss() or self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if params.target:IsOther() then
            return nil
        end
        local chance = self:GetAbility():GetSpecialValueFor("chance")
        if RandomInt(1,100) <= chance then
            local victim_angle = params.target:GetAnglesAsVector().y
            local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()
            local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
            origin_difference_radian = origin_difference_radian * 180
            local attacker_angle = origin_difference_radian / math.pi
            attacker_angle = attacker_angle + 180.0
            local result_angle = attacker_angle - victim_angle
            result_angle = math.abs(result_angle)
            if result_angle >= (180 - (105 / 2)) and result_angle <= (180 + (105 / 2)) then 
                params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_scp_ultimate_vision", {})
                EmitGlobalSound( "Scp173Ultimate" )
            end
        end
        local victim_angle = params.target:GetAnglesAsVector().y
        local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()
        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
        origin_difference_radian = origin_difference_radian * 180
        local attacker_angle = origin_difference_radian / math.pi
        attacker_angle = attacker_angle + 180.0
        local result_angle = attacker_angle - victim_angle
        result_angle = math.abs(result_angle)
        if result_angle >= (180 - (105 / 2)) and result_angle <= (180 + (105 / 2)) then 
            EmitSoundOn("Hero_Riki.Backstab", params.target)
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target) 
            ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 
            local damagetype = DAMAGE_TYPE_PHYSICAL
            if self:GetAbility():GetLevel() == 3 then
                damagetype = DAMAGE_TYPE_PURE
            end
            ApplyDamage({victim = params.target, attacker = params.attacker, damage = self:GetParent():GetAttackDamage() * 2, ability = self:GetAbility(), damage_type = damagetype})
        end
    end
end

modifier_scp_ultimate_vision = modifier_scp_ultimate_vision or class({})

function modifier_scp_ultimate_vision:IsPurgable() return true end

function modifier_scp_ultimate_vision:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE, }
    return funcs
end

function modifier_scp_ultimate_vision:GetBonusVisionPercentage()
    return 1000 * -1
end