LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_yuno_rage", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)

Yuno_Rage = class({}) 

function Yuno_Rage:Precache(context)
    PrecacheResource("model", "models/update_heroes/yuno/yuno.vmdl", context)
    local particle_list = 
    {
        "particles/items2_fx/mask_of_madness.vpcf",
        "particles/generic_gameplay/generic_lifesteal.vpcf",
        "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",
        "particles/yuno_shapness_stack.vpcf",
        "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf",
        "particles/units/heroes/hero_queenofpain/queen_blink_end.vpcf",
        "particles/generic_gameplay/generic_silenced.vpcf",
        "particles/units/heroes/hero_weaver/weaver_timelapse.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Yuno_Rage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Yuno_Rage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Yuno_Rage:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("screamy")
    local duration = self:GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_3")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_yuno_rage", {duration = duration})
end

modifier_yuno_rage = class({}) 

function modifier_yuno_rage:IsPurgable() return false end

function modifier_yuno_rage:GetEffectName()
    return "particles/items2_fx/mask_of_madness.vpcf" 
end

function modifier_yuno_rage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_yuno_rage:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return decFuncs
end

function modifier_yuno_rage:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('speed_a')
end

function modifier_yuno_rage:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('bonus_dmg')
end

function modifier_yuno_rage:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_8")
end

function modifier_yuno_rage:GetModifierIncomingDamage_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_8")
end

function modifier_yuno_rage:CheckState()
    if self:GetCaster():HasTalent("special_bonus_birzha_yuno_4") then return end
    local state = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return state
end

function modifier_yuno_rage:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = (self:GetAbility():GetSpecialValueFor("lifesteal") + self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_1")) / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

LinkLuaModifier("modifier_yuno_sharpness_axe", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yuno_sharpness_axe_effect", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yuno_sharpness_axe_effect_stack", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)

Yuno_sharpness_axe = class({}) 

function Yuno_sharpness_axe:GetIntrinsicModifierName()
    return "modifier_yuno_sharpness_axe"
end

modifier_yuno_sharpness_axe = class({})

function modifier_yuno_sharpness_axe:IsHidden()
    return true
end

function modifier_yuno_sharpness_axe:IsPurgable()
    return false
end

function modifier_yuno_sharpness_axe:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE
    }
    return funcs
end

function modifier_yuno_sharpness_axe:GetModifierProcAttack_BonusDamage_Pure(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end

    local damage = 0
    local base_damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_2")

    local shard_modifier = params.target:FindModifierByName("modifier_yuno_sharpness_axe_effect")
    if shard_modifier then
        base_damage = base_damage * (shard_modifier:GetStackCount() + 1)
    end

    damage = base_damage

    if self:GetCaster():HasTalent("special_bonus_birzha_yuno_7") then
        damage = damage + (params.original_damage / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_7"))
    end

    if self:GetCaster():HasScepter() then
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_yuno_sharpness_axe_effect_stack", {duration = self:GetAbility():GetSpecialValueFor("shard_duration") * (1-params.target:GetStatusResistance())})
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_yuno_sharpness_axe_effect", {duration = self:GetAbility():GetSpecialValueFor("shard_duration") * (1-params.target:GetStatusResistance())})
    end

    params.target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")

    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, params.target )
    ParticleManager:SetParticleControlEnt( nFXIndex, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetOrigin(), true )
    ParticleManager:SetParticleControl( nFXIndex, 1, params.target:GetOrigin() )
    ParticleManager:SetParticleControlForward( nFXIndex, 1, self:GetParent():GetForwardVector() )
    ParticleManager:SetParticleControlEnt( nFXIndex, 10, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( nFXIndex )

    return damage
end

modifier_yuno_sharpness_axe_effect = class({})

function modifier_yuno_sharpness_axe_effect:IsPurgable() return true end

function modifier_yuno_sharpness_axe_effect:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_yuno_sharpness_axe_effect:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_yuno_sharpness_axe_effect_stack")
    self:SetStackCount(#modifier)
end

function modifier_yuno_sharpness_axe_effect:GetEffectName() return "particles/yuno_shapness_stack.vpcf" end
function modifier_yuno_sharpness_axe_effect:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

modifier_yuno_sharpness_axe_effect_stack = class({})
function modifier_yuno_sharpness_axe_effect_stack:IsHidden() return true end
function modifier_yuno_sharpness_axe_effect_stack:IsPurgable() return true end
function modifier_yuno_sharpness_axe_effect_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

LinkLuaModifier("modifier_yuno_omnipresence_silenced", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)

yuno_omnipresence = class({})

function yuno_omnipresence:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function yuno_omnipresence:GetCastRange(location, target)
    if IsClient() then
        return self:GetSpecialValueFor("blink_range")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function yuno_omnipresence:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function yuno_omnipresence:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("blink_range")

    local direction = (point - origin)

    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_yuno_6") then
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_6"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
        for _,unit in pairs(units) do
            unit:AddNewModifier(self:GetCaster(), self, "modifier_yuno_omnipresence_silenced", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_6","value2") * ( 1 - unit:GetStatusResistance())})
        end
    end

    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )

    ProjectileManager:ProjectileDodge(self:GetCaster())

    if self:GetCaster():HasTalent("special_bonus_birzha_yuno_6") then
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_6"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
        for _,unit in pairs(units) do
            unit:AddNewModifier(self:GetCaster(), self, "modifier_yuno_omnipresence_silenced", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_6","value2") * ( 1 - unit:GetStatusResistance())})
        end
    end

    self:PlayEffects( origin, direction )
end

function yuno_omnipresence:PlayEffects( origin, direction )
    local particle_one = ParticleManager:CreateParticle( "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    EmitSoundOnLocationWithCaster( origin, "Hero_QueenOfPain.Blink_out", self:GetCaster() )

    local particle_two = ParticleManager:CreateParticle( "particles/units/heroes/hero_queenofpain/queen_blink_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_QueenOfPain.Blink_in", self:GetCaster() )
end

modifier_yuno_omnipresence_silenced = class({})

function modifier_yuno_omnipresence_silenced:CheckState()
    return 
    {
        [MODIFIER_STATE_SILENCED] = true
    }
end

function modifier_yuno_omnipresence_silenced:GetEffectName() return "particles/generic_gameplay/generic_silenced.vpcf" end
function modifier_yuno_omnipresence_silenced:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

LinkLuaModifier( "modifier_yuno_time_lapse", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)

yuno_time_lapse = class({})

function yuno_time_lapse:GetCooldown(level)
    if self:GetCaster():HasShard() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function yuno_time_lapse:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function yuno_time_lapse:GetIntrinsicModifierName()
    if not self:GetCaster():IsIllusion() then
        return "modifier_yuno_time_lapse"
    end
end

function yuno_time_lapse:OnSpellStart()
    if not IsServer() then return end
    self.intrinsic_modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
        
    if self.intrinsic_modifier and self.intrinsic_modifier.instances_health and self.intrinsic_modifier.instances_health[1] and self.intrinsic_modifier.instances_mana and self.intrinsic_modifier.instances_mana[1] and self.intrinsic_modifier.instances_position and self.intrinsic_modifier.instances_position[1] then
        self:GetCaster():EmitSound("Hero_Weaver.TimeLapse")

        local time_lapse_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(time_lapse_particle, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(time_lapse_particle, 2, self.intrinsic_modifier.instances_position[1])
        ParticleManager:ReleaseParticleIndex(time_lapse_particle)

        ProjectileManager:ProjectileDodge(self:GetCaster())

        self:GetCaster():Purge(false, true, false, true, true)

        self:GetCaster():Stop()
    
        self:GetCaster():SetHealth(math.max(self.intrinsic_modifier.instances_health[1], 1))

        self:GetCaster():SetMana(self.intrinsic_modifier.instances_mana[1])

        if self:GetCaster():HasTalent("special_bonus_birzha_yuno_5") then
            local illusions = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_5"),outgoing_damage=0,incoming_damage=0}, 1, 200, false, false ) 
            for k, illusion in pairs(illusions) do
                illusion:AddNewModifier(self:GetCaster(), self, "modifier_phased", {duration = FrameTime()})
            end
        end

        FindClearSpaceForUnit(self:GetCaster(), self.intrinsic_modifier.instances_position[1], true)
    end 
end

modifier_yuno_time_lapse = class({})

function modifier_yuno_time_lapse:IsPurgable()  return false end
function modifier_yuno_time_lapse:IsDebuff()    return false end
function modifier_yuno_time_lapse:IsHidden()    return true end

function modifier_yuno_time_lapse:OnCreated()
    if not IsServer() then return end
    self.lapsed_time        = 5
    self.instances_health   = {}
    self.instances_mana     = {}
    self.instances_position = {}
    self.interval           = 0.1
    self.total_saved_points = self.lapsed_time / self.interval
    self:OnIntervalThink()
    self:StartIntervalThink(self.interval)
end

function modifier_yuno_time_lapse:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsAlive() then
        table.insert(self.instances_health, self:GetParent():GetHealth())
        table.insert(self.instances_mana, self:GetParent():GetMana())
        table.insert(self.instances_position, self:GetParent():GetAbsOrigin())

        if #self.instances_health >= self.total_saved_points then
            table.remove(self.instances_health, 1)
            table.remove(self.instances_mana, 1)
            table.remove(self.instances_position, 1)
        end
    end
end

