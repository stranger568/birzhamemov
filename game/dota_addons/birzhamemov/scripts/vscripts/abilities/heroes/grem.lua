LinkLuaModifier( "modifier_grem_creepyappearance_debuff", "abilities/heroes/grem.lua", LUA_MODIFIER_MOTION_NONE )

Grem_CreepyAppearance = class({})

function Grem_CreepyAppearance:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    0,
    FIND_ANY_ORDER,
    false)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0))
    ParticleManager:ReleaseParticleIndex(particle)

    self:GetCaster():EmitSound( "Hero_Tidehunter.AnchorSmash" )
    
    for _,unit in pairs(targets) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_grem_creepyappearance_debuff", { duration = duration * (1 - unit:GetStatusResistance())} )
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
    self:StartIntervalThink(1)
end

function modifier_grem_creepyappearance_debuff:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_1")
    local damageInfo = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }

    ApplyDamage( damageInfo )
end

function modifier_grem_creepyappearance_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_grem_creepyappearance_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
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
    local max_stack = self:GetAbility():GetSpecialValueFor("stack_max")
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
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
    modifier:RemoveStack()
end

Grem_HardSkeleton = class({})

LinkLuaModifier( "modifier_Grem_HardSkeleton", "abilities/heroes/grem", LUA_MODIFIER_MOTION_NONE )

function Grem_HardSkeleton:GetIntrinsicModifierName()
    return "modifier_Grem_HardSkeleton"
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
        MODIFIER_EVENT_ON_ATTACKED,
    }

    return funcs
end

function modifier_Grem_HardSkeleton:OnAttacked( params )
    if not IsServer() then return end

    if params.target == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
            return
        end
        local base_damage = self:GetAbility():GetSpecialValueFor("return_damage")
        local strength_pct = self:GetAbility():GetSpecialValueFor("strength_pct") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_3")
        local damage = base_damage + self:GetParent():GetStrength() * ( strength_pct / 100)
        if params.attacker:HasModifier("modifier_item_birzha_blade_mail_active") then return end
        local damageTable = {
            victim = params.attacker,
            attacker = self:GetParent(),
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(),
        }
        ApplyDamage(damageTable)

        if params.attacker:IsConsideredHero() then
            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
            ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( particle, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetOrigin(), true )
        end
    end
end

LinkLuaModifier( "modifier_grem_donothing", "abilities/heroes/grem.lua", LUA_MODIFIER_MOTION_NONE )

Grem_DoNothing = class({})

function Grem_DoNothing:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Grem_DoNothing:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Grem_DoNothing:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_grem_2")
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
    local funcs = {
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
    return 45
end