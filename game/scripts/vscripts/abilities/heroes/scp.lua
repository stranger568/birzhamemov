LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )













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
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
    }
    return funcs
end

function modifier_Scp_FastKill:GetModifierProcAttack_BonusDamage_Physical(params)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if self:GetParent():HasTalent("special_bonus_birzha_scp_8") then return end
    local victim_angle = params.target:GetAnglesAsVector().y
    local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()
    local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
    origin_difference_radian = origin_difference_radian * 180
    local attacker_angle = origin_difference_radian / math.pi
    attacker_angle = attacker_angle + 180.0
    local result_angle = attacker_angle - victim_angle
    result_angle = math.abs(result_angle)

    if result_angle >= (180 - (105 / 2)) and result_angle <= (180 + (105 / 2)) then 

        if self:GetCaster():HasTalent("special_bonus_birzha_scp_3") then
           params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_scp_ultimate_vision", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_scp_3", "value2") * ( 1 - params.target:GetStatusResistance()) }) 
        end

        params.target:EmitSound("Hero_Riki.Backstab")

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target) 
        ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 

        return (self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_5")) / 100 * self:GetParent():GetAverageTrueAttackDamage(nil)
    end
end

function modifier_Scp_FastKill:GetModifierProcAttack_BonusDamage_Pure(params)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_scp_8") then return end
    local victim_angle = params.target:GetAnglesAsVector().y
    local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()
    local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
    origin_difference_radian = origin_difference_radian * 180
    local attacker_angle = origin_difference_radian / math.pi
    attacker_angle = attacker_angle + 180.0
    local result_angle = attacker_angle - victim_angle
    result_angle = math.abs(result_angle)

    if result_angle >= (180 - (105 / 2)) and result_angle <= (180 + (105 / 2)) then 

        if self:GetCaster():HasTalent("special_bonus_birzha_scp_3") then
           params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_scp_ultimate_vision", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_scp_3", "value2") * ( 1 - params.target:GetStatusResistance()) }) 
        end

        params.target:EmitSound("Hero_Riki.Backstab")

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target) 
        ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 

        return (self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_5")) / 100 * self:GetParent():GetAverageTrueAttackDamage(nil)
    end
end

modifier_scp_ultimate_vision = class({})

function modifier_scp_ultimate_vision:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("Scp173Ultimate")
    --self.vision = (self:GetParent():GetCurrentVisionRange() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_scp_3")) * -1
end

function modifier_scp_ultimate_vision:IsPurgable() return true end

function modifier_scp_ultimate_vision:DeclareFunctions()
    local funcs = 
    { 
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE
    }
    return funcs
end

function modifier_scp_ultimate_vision:GetBonusVisionPercentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_scp_3")
end

LinkLuaModifier("modifier_scp_screamer", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)

Scp173_Screamer = class({}) 

function Scp173_Screamer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_1")
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
    local damage = self:GetSpecialValueFor("damage")

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

        if PlayerResource:GetSteamAccountID( self:GetParent():GetPlayerID() ) == 113370083 then
            CustomGameEventManager:Send_ServerToPlayer(Player, "ScpScreamerTrueBonus", {} )
            return
        end

        CustomGameEventManager:Send_ServerToPlayer(Player, "ScpScreamerTrue", {} )
    end
end

function modifier_scp_screamer:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():IsIllusion() then
        local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
        if PlayerResource:GetSteamAccountID( self:GetParent():GetPlayerID() ) == 113370083 then
            CustomGameEventManager:Send_ServerToPlayer(Player, "ScpScreamerFalseBonus", {} )
            return
        end
        CustomGameEventManager:Send_ServerToPlayer(Player, "ScpScreamerFalse", {} )
    end
end

function modifier_scp_screamer:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
    }
    if self:GetCaster():HasTalent("special_bonus_birzha_scp_6") then
        state = 
        {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_PASSIVES_DISABLED] = true,
        }
    end

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
    return self:GetSpecialValueFor("aura_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_2")
end

modifier_Scp_DamageAura = class({})

function modifier_Scp_DamageAura:IsHidden()
    return true
end

function modifier_Scp_DamageAura:IsPurgable()
    return false
end

function modifier_Scp_DamageAura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_2")
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

function modifier_Scp_DamageAura:IsAuraActiveOnDeath() 
    return false 
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
    local aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp_7")
    local aura_damage_interval = self:GetAbility():GetSpecialValueFor("aura_damage_interval")
    
    if not self:GetParent():IsBoss() then
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

LinkLuaModifier("modifier_Scp_fast_movement", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scp_fast_movement_invisibility", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)

Scp_fast_movement = class({}) 

function Scp_fast_movement:GetIntrinsicModifierName()
    return "modifier_Scp_fast_movement"
end

function Scp_fast_movement:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_scp_4") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Scp_fast_movement:GetCooldown(iLevel)
    if self:GetCaster():HasTalent("special_bonus_birzha_scp_4") then
        return self:GetCaster():FindTalentValue("special_bonus_birzha_scp_4", "value3")
    end
    return 0
end

function Scp_fast_movement:OnSpellStart()
    if not IsServer() then return end
    local random = self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(self:GetCaster():FindTalentValue("special_bonus_birzha_scp_4"), self:GetCaster():FindTalentValue("special_bonus_birzha_scp_4", "value2")))

    local particle_1 = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_start.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_1, 0, self:GetCaster():GetAbsOrigin())

    FindClearSpaceForUnit(self:GetCaster(), random, true)

    self:GetCaster():EmitSound("scp_scepter")
    local particle_2 = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_2, 0, self:GetCaster():GetAbsOrigin())
end

function Scp_fast_movement:GetCastRange(location, target)
    local minus_radius = 0
    if self:GetCaster():HasShard() then
        minus_radius = self:GetSpecialValueFor("shard_radius")
    end
    return self:GetSpecialValueFor("radius") + minus_radius
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
    if self:GetCaster():HasShard() then
        radius = radius + self:GetAbility():GetSpecialValueFor("shard_radius")
    end
    local enemyHeroes = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    if #enemyHeroes>0 or self:GetParent():PassivesDisabled() then
        self:GetParent():RemoveModifierByName("modifier_Scp_fast_movement_invisibility")
    else
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
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_Scp_fast_movement_invisibility:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_Scp_fast_movement_invisibility:GetModifierInvisibilityLevel()
    return 1
end

function modifier_Scp_fast_movement_invisibility:GetModifierMoveSpeed_Max( params )
    return self:GetAbility():GetSpecialValueFor("movespeed_limit")
end

function modifier_Scp_fast_movement_invisibility:GetModifierMoveSpeed_Limit( params )
    return self:GetAbility():GetSpecialValueFor("movespeed_limit")
end

function modifier_Scp_fast_movement_invisibility:GetModifierIgnoreMovespeedLimit( params )
    return 1
end

function modifier_Scp_fast_movement_invisibility:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
    return state
end

LinkLuaModifier("modifier_scp173_statue_aghanim_origin", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scp173_statue_aghanim_statue", "abilities/heroes/scp", LUA_MODIFIER_MOTION_NONE)

scp173_statue_aghanim = class({})

function scp173_statue_aghanim:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function scp173_statue_aghanim:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function scp173_statue_aghanim:GetIntrinsicModifierName()
    return "modifier_scp173_statue_aghanim_origin"
end

function scp173_statue_aghanim:OnSpellStart()
    if not IsServer() then return end
    local modifier = self:GetCaster():FindModifierByName("modifier_scp173_statue_aghanim_origin")
    if modifier then
        if self.dummy then
            UTIL_Remove(self.dummy)
        end
        local origin = modifier.origin
        local duration = self:GetSpecialValueFor("duration")
        self.dummy = CreateUnitByName("npc_dota_companion", origin, false, nil, nil, self:GetCaster():GetTeamNumber())
        self.dummy:SetModelScale(1.7)
        self.dummy:SetForwardVector(self:GetCaster():GetForwardVector())
        self.dummy:SetOriginalModel("models/update_heroes/scp173/scp173.vmdl")
        self.dummy:SetModel("models/update_heroes/scp173/scp173.vmdl")
        self.dummy:AddNewModifier(self:GetCaster(), self, "modifier_scp173_statue_aghanim_statue", {})
    end
end

modifier_scp173_statue_aghanim_origin = class({})

function modifier_scp173_statue_aghanim_origin:IsPurgable() return false end
function modifier_scp173_statue_aghanim_origin:IsHidden() return true end

function modifier_scp173_statue_aghanim_origin:OnCreated()
    if not IsServer() then return end
    self.origin = self:GetParent():GetAbsOrigin()
    self:StartIntervalThink(1)
end

function modifier_scp173_statue_aghanim_origin:OnIntervalThink()
    if not IsServer() then return end
    self.origin = self:GetParent():GetAbsOrigin()
end

modifier_scp173_statue_aghanim_statue = class({})

function modifier_scp173_statue_aghanim_statue:IsHidden() return true end
function modifier_scp173_statue_aghanim_statue:IsPurgable() return false end

function modifier_scp173_statue_aghanim_statue:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetDayTimeVisionRange(self:GetAbility():GetSpecialValueFor("vision_radius"))
    self:GetParent():SetNightTimeVisionRange(self:GetAbility():GetSpecialValueFor("vision_radius"))
    self:StartIntervalThink(FrameTime())
end

function modifier_scp173_statue_aghanim_statue:GetStatusEffectName()
    return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_scp173_statue_aghanim_statue:StatusEffectPriority(  )
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_scp173_statue_aghanim_statue:OnIntervalThink()
    if not IsServer() then return end
    local heroes = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    local ability = self:GetCaster():FindAbilityByName("scp173_statue_aghanim_teleport")
    if #heroes > 0 then
        if ability then
            ability:SetActivated(true)
        end
    else
        if ability then
            ability:SetActivated(false)
        end
    end
end

function modifier_scp173_statue_aghanim_statue:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end

function modifier_scp173_statue_aghanim_statue:OnDestroy()
    if not IsServer() then return end
    local ability = self:GetCaster():FindAbilityByName("scp173_statue_aghanim_teleport")
    if ability then
        ability:SetActivated(false)
    end
end

scp173_statue_aghanim_teleport = class({})

function scp173_statue_aghanim_teleport:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function scp173_statue_aghanim_teleport:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function scp173_statue_aghanim_teleport:Spawn()
    if not IsServer() then return end
    self:SetActivated(false)
end

function scp173_statue_aghanim_teleport:OnSpellStart()
    if not IsServer() then return end
    local ability = self:GetCaster():FindAbilityByName("scp173_statue_aghanim")
    if ability then
        if ability.dummy and not ability.dummy:IsNull() then
            ability:UseResources(false, false, false, true)
            local particle_1 = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_start.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(particle_1, 0, self:GetCaster():GetAbsOrigin())
            FindClearSpaceForUnit(self:GetCaster(), ability.dummy:GetAbsOrigin(), true)
            self:GetCaster():EmitSound("scp_scepter")
            local particle_2 = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(particle_2, 0, self:GetCaster():GetAbsOrigin())
            ability:SetActivated(true)        
            UTIL_Remove(ability.dummy)
        end
    end
end