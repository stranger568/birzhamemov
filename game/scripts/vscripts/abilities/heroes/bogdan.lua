LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_orb_effect_lua", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_bogdan_cower", "abilities/heroes/bogdan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Bogdan_Cower = class({}) 

function Bogdan_Cower:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_ambient.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_base_attack.vpcf", context)
    PrecacheResource("particle", "particles/bogdan/wrench.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_viper/viper_poison_attack.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf", context)
    PrecacheResource("model", "models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl", context)
end

function Bogdan_Cower:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_3")
end

function Bogdan_Cower:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bogdan_Cower:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("bogdan")
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bogdan_cower", {duration = duration})
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
end

modifier_bogdan_cower = class({}) 

function modifier_bogdan_cower:IsPurgable() return true end

function modifier_bogdan_cower:AllowIllusionDuplicate()
    return true
end

function modifier_bogdan_cower:GetEffectName()
    return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf"
end

function modifier_bogdan_cower:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_bogdan_cower:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_ambient.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_bogdan_cower:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("bogdan")
end

function modifier_bogdan_cower:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }
    return decFuncs
end

function modifier_bogdan_cower:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_range') + self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_6")
end

function modifier_bogdan_cower:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_bogdan_cower:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack_speed') + self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_4")
end

function modifier_bogdan_cower:GetVisualZDelta()
    return 125
end

function modifier_bogdan_cower:GetModifierModelChange()
    return "models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl"
end

function modifier_bogdan_cower:GetModifierProjectileName()
    return "particles/units/heroes/hero_warlock/warlock_base_attack.vpcf"
end

function modifier_bogdan_cower:CheckState()
    if not self:GetCaster():HasTalent("special_bonus_birzha_bogdan_7") then return end
    local state = 
    {
        [MODIFIER_STATE_FORCED_FLYING_VISION ] = true
    }
    return state
end

Bogdan_key = class({})

function Bogdan_key:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Bogdan_key:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bogdan_key:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Bogdan_key:OnSpellStart()
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local info = 
    {
        EffectName = "particles/bogdan/wrench.vpcf",
        Ability = self,
        iMoveSpeed = 1200,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("Brewmaster_Earth.Boulder.Cast")
end

function Bogdan_key:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
        local stun_duration = self:GetSpecialValueFor( "stun_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_2")
        local stun_damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_1")
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = stun_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        ApplyDamage( damage )
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration * (1-target:GetStatusResistance()) })
        target:EmitSound("Brewmaster_Earth.Boulder.Target")
    end
    return true
end

LinkLuaModifier("modifier_bogdan_aids_debuff", "abilities/heroes/bogdan", LUA_MODIFIER_MOTION_NONE)

bogdan_aids = class({}) 

function bogdan_aids:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return 0
    end
    return self.BaseClass.GetCooldown( self, level )
end

function bogdan_aids:GetIntrinsicModifierName()
    return "modifier_birzha_orb_effect_lua"
end

function bogdan_aids:GetProjectileName()
    return "particles/units/heroes/hero_viper/viper_poison_attack.vpcf"
end

function bogdan_aids:OnOrbFire( params )
    if not IsServer() then return end
    self:GetCaster():EmitSound("hero_viper.poisonAttack.Cast")
end

function bogdan_aids:OnOrbImpact( params )
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    params.target:AddNewModifier( self:GetCaster(), self, "modifier_bogdan_aids_debuff", { duration = duration * (1-params.target:GetStatusResistance()) } )
    params.target:EmitSound("hero_viper.poisonAttack.Target")
end

function bogdan_aids:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()  
        if target:IsWard() then return end       
        caster:MoveToTargetToAttack(target)
    end
end

modifier_bogdan_aids_debuff = class({})

function modifier_bogdan_aids_debuff:IsHidden()
    return false
end

function modifier_bogdan_aids_debuff:IsPurgable()
    return true
end

function modifier_bogdan_aids_debuff:OnCreated( kv )
    if not IsServer() then return end

    if self:GetCaster():HasShard() then
        self:IncrementStackCount()
    end

    self.damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
    }

    self:StartIntervalThink( 1 )
end

function modifier_bogdan_aids_debuff:OnRefresh()
    if not IsServer() then return end
    if self:GetCaster():HasShard() then
        self:IncrementStackCount()
    end
end

function modifier_bogdan_aids_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_bogdan_aids_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
end

function modifier_bogdan_aids_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_bogdan_aids_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("shard_armor") * self:GetStackCount()
end

function modifier_bogdan_aids_debuff:OnIntervalThink()
    self.damage_pct = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_5")
    local miss_health = 100-self:GetParent():GetHealthPercent()
    self.damageTable.damage = miss_health*self.damage_pct
    ApplyDamage( self.damageTable )
end

function modifier_bogdan_aids_debuff:GetEffectName()
    return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

function modifier_bogdan_aids_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_Bogdan_Ultimate", "abilities/heroes/bogdan", LUA_MODIFIER_MOTION_NONE)

Bogdan_Ultimate = class({}) 

function Bogdan_Ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Bogdan_Ultimate:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bogdan_Ultimate:OnSpellStart()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_Bogdan_Ultimate") then
        self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Bogdan_Ultimate", {})
        self.modifier:IncrementStackCount()
    else
        self.modifier:IncrementStackCount()
    end
    self:GetCaster():CalculateStatBonus(true)
end

modifier_Bogdan_Ultimate = class({})

function modifier_Bogdan_Ultimate:IsPurgable()
    return false
end

function modifier_Bogdan_Ultimate:RemoveOnDeath()
    return false
end

function modifier_Bogdan_Ultimate:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_Bogdan_Ultimate:GetModifierBonusStats_Strength()
    local multiple = 1
    if self:GetCaster():HasTalent("special_bonus_birzha_bogdan_8") then
        multiple = self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_8")
    end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor('str') * multiple
end

function modifier_Bogdan_Ultimate:GetModifierBonusStats_Agility()
    local multiple = 1
    if self:GetCaster():HasTalent("special_bonus_birzha_bogdan_8") then
        multiple = self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_8")
    end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor('agi') * multiple
end

function modifier_Bogdan_Ultimate:GetModifierBonusStats_Intellect()
    local multiple = 1
    if self:GetCaster():HasTalent("special_bonus_birzha_bogdan_8") then
        multiple = self:GetCaster():FindTalentValue("special_bonus_birzha_bogdan_8")
    end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor('int') * multiple
end

function modifier_Bogdan_Ultimate:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then  
        if self:GetStackCount() > 0 then        
            self:DecrementStackCount()
        end
    end
end