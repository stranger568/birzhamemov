LinkLuaModifier( "modifier_grem_creepyappearance_debuff", "abilities/heroes/grem.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_grem_creepyappearance_buff_shard", "abilities/heroes/grem.lua", LUA_MODIFIER_MOTION_NONE )

Grem_CreepyAppearance = class({})

function Grem_CreepyAppearance:Precache(context)
    local particle_list = 
    {
        "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf",
        "particles/generic_gameplay/generic_silenced.vpcf",
        "particles/units/heroes/hero_centaur/centaur_shard_buff_strength.vpcf",
        "particles/units/heroes/hero_visage/visage_familiar_transform.vpcf",
        "particles/status_fx/status_effect_earth_spirit_petrify.vpcf",
        "particles/units/heroes/hero_centaur/centaur_return.vpcf",
        "particles/status_fx/status_effect_mjollnir_shield.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Grem_CreepyAppearance:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_3")
end

function Grem_CreepyAppearance:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Grem_CreepyAppearance:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Grem_CreepyAppearance:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0))
    ParticleManager:ReleaseParticleIndex(particle)

    self:GetCaster():EmitSound( "Hero_Tidehunter.AnchorSmash" )
    
    for _,unit in pairs(targets) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_grem_creepyappearance_debuff", { duration = duration * (1 - unit:GetStatusResistance())} )
    end

    if self:GetCaster():HasScepter() then
        if #targets > 0 then
            local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_grem_creepyappearance_buff_shard", {duration = duration, count = #targets})
            if modifier then
                modifier:SetStackCount(#targets)
            end
        end
    end
end

modifier_grem_creepyappearance_debuff = class({})

function modifier_grem_creepyappearance_debuff:IsPurgable()
    return true
end

function modifier_grem_creepyappearance_debuff:IsPurgeException()
    return true
end

function modifier_grem_creepyappearance_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_grem_creepyappearance_debuff:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    
    local damageInfo = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage * 0.5,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }

    ApplyDamage( damageInfo )
end

function modifier_grem_creepyappearance_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_grem_creepyappearance_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
    return state
end

function modifier_grem_creepyappearance_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_grem_creepyappearance_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_grem_creepyappearance_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW 
end

modifier_grem_creepyappearance_buff_shard = class({})

function modifier_grem_creepyappearance_buff_shard:OnCreated(kv)
    if not IsServer() then return end
    self.bonus_str = self:GetParent():GetStrength() * ( ( 25 * kv.count ) / 100 )
    self.shard_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_shard_buff_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.shard_pfx, 2, Vector(kv.count, 0, 0))
    ParticleManager:SetParticleControlEnt(self.shard_pfx, 3, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "follow_overhead", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.shard_pfx, false, false, -1, false, false)
    self:GetParent():CalculateStatBonus(true)
end

function modifier_grem_creepyappearance_buff_shard:OnRefresh(kv)
    if not IsServer() then return end
    if self.shard_pfx then
       ParticleManager:SetParticleControl(self.shard_pfx, 2, Vector(kv.count, 0, 0)) 
    end
    self.bonus_str = self:GetParent():GetStrength() * ( ( self:GetAbility():GetSpecialValueFor("str_scepter") * kv.count ) / 100 )
    self:GetParent():CalculateStatBonus(true)
end

function modifier_grem_creepyappearance_buff_shard:IsPurgable() return true end

function modifier_grem_creepyappearance_buff_shard:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_grem_creepyappearance_buff_shard:GetModifierBonusStats_Strength()
    return self.bonus_str
end

LinkLuaModifier("modifier_grem_impenetrability", "abilities/heroes/grem", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grem_impenetrability_stack", "abilities/heroes/grem", LUA_MODIFIER_MOTION_NONE )

Grem_Impenetrability = class({}) 

function Grem_Impenetrability:GetIntrinsicModifierName()
    return "modifier_grem_impenetrability"
end

modifier_grem_impenetrability = class({}) 

function modifier_grem_impenetrability:IsPurgable()
    return false
end

function modifier_grem_impenetrability:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_grem_impenetrability:OnAttackLanded( keys )
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        local max_stack = self:GetAbility():GetSpecialValueFor("stack_max") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_2")
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        if self:GetStackCount() < max_stack then
            if not self:GetParent():IsAlive() then return end
            self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_grem_impenetrability_stack", { duration = duration } )
            self:IncrementStackCount()
        end
    end
end

function modifier_grem_impenetrability:GetModifierPhysicalArmorBonus()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_grem_impenetrability:GetModifierConstantHealthRegen()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("regen")
end

function modifier_grem_impenetrability:RemoveStack()
    self:DecrementStackCount()
end

modifier_grem_impenetrability_stack = class({})

function modifier_grem_impenetrability_stack:IsHidden()
    return true
end

function modifier_grem_impenetrability_stack:IsPurgable()
    return false
end

function modifier_grem_impenetrability_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_grem_impenetrability_stack:OnDestroy()
    if not IsServer() then return end
    local modifier = self:GetParent():FindModifierByName( "modifier_grem_impenetrability" )
    if modifier then
        modifier:RemoveStack()
    end
end

Grem_HardSkeleton = class({})

LinkLuaModifier( "modifier_Grem_HardSkeleton", "abilities/heroes/grem", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Grem_HardSkeleton_buff", "abilities/heroes/grem", LUA_MODIFIER_MOTION_NONE )

function Grem_HardSkeleton:GetIntrinsicModifierName()
    return "modifier_Grem_HardSkeleton"
end

function Grem_HardSkeleton:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_grem_8") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Grem_HardSkeleton:GetCooldown(iLevel)
    if self:GetCaster():HasTalent("special_bonus_birzha_grem_8") then
        return self:GetCaster():FindTalentValue("special_bonus_birzha_grem_8", "value3")
    end
    return 0
end

function Grem_HardSkeleton:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetCaster():FindTalentValue("special_bonus_birzha_grem_8", "value2")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Grem_HardSkeleton_buff", {duration = duration})
    self:GetCaster():EmitSound("Visage_Familar.StoneForm.Cast")
end

modifier_Grem_HardSkeleton_buff = class({})

function modifier_Grem_HardSkeleton_buff:IsPurgable() return false end

function modifier_Grem_HardSkeleton_buff:OnCreated()
    self.regen = (self:GetParent():GetMaxHealth() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_grem_8")) / self:GetDuration()
end

function modifier_Grem_HardSkeleton_buff:OnDestroy()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_familiar_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
end

function modifier_Grem_HardSkeleton_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_Grem_HardSkeleton_buff:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

function modifier_Grem_HardSkeleton_buff:GetModifierConstantHealthRegen()
    return self.regen
end

function modifier_Grem_HardSkeleton_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
end

function modifier_Grem_HardSkeleton_buff:StatusEffectPriority()
    return 10
end

modifier_Grem_HardSkeleton = class({})

function modifier_Grem_HardSkeleton:IsHidden()
    return true
end

function modifier_Grem_HardSkeleton:IsPurgable()
    return false
end

function modifier_Grem_HardSkeleton:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_Grem_HardSkeleton:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() == params.attacker then return end
    if self:GetParent() ~= params.unit then return end
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
        return
    end

    local base_damage = self:GetAbility():GetSpecialValueFor("return_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_1")
    local strength_pct = self:GetAbility():GetSpecialValueFor("strength_pct") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_6")
    local damage = base_damage + self:GetParent():GetStrength() * ( strength_pct / 100)

    local damageTable = 
    {
        victim = params.attacker,
        attacker = self:GetParent(),
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
    }

    if not self:GetCaster():HasTalent("special_bonus_birzha_grem_5") then
        if params.attacker:IsMagicImmune() then return end
    end

    if params.inflictor == nil then 
        ApplyDamage(damageTable) 
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( particle, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetOrigin(), true )      
    elseif params.inflictor ~= nil and params.damage > 100 then
        if self:GetParent():HasShard() then
            ApplyDamage(damageTable)
            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
            ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( particle, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetOrigin(), true ) 
        end 
    end
end

LinkLuaModifier( "modifier_grem_donothing", "abilities/heroes/grem.lua", LUA_MODIFIER_MOTION_NONE )

Grem_DoNothing = class({})

function Grem_DoNothing:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_7")
end

function Grem_DoNothing:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Grem_DoNothing:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_4")
    self:GetCaster():Purge( false, true, false, true, false )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_grem_donothing", { duration = duration } )
    self:GetCaster():EmitSound( "Hero_Terrorblade.Sunder.Target" )
end

modifier_grem_donothing = class({})

function modifier_grem_donothing:IsPurgable()
    return false
end

function modifier_grem_donothing:StatusEffectPriority()
    return 10
end

function modifier_grem_donothing:GetStatusEffectName()
    return "particles/status_fx/status_effect_mjollnir_shield.vpcf"
end

function modifier_grem_donothing:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetRenderColor(255, 0, 0)
end

function modifier_grem_donothing:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetRenderColor(255, 255, 255)
end

function modifier_grem_donothing:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
    return funcs
end

function modifier_grem_donothing:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_grem_donothing:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_grem_donothing:GetModifierModelScale()
    return 25
end