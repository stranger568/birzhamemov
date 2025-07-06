LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Poroshenko_slava_ukraine_hero", "abilities/heroes/poroshenko", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Poroshenko_slava_ukraine_sniper", "abilities/heroes/poroshenko", LUA_MODIFIER_MOTION_NONE)

Poroshenko_Slava_Ukraine = class({}) 

function Poroshenko_Slava_Ukraine:Precache(context)
    PrecacheResource("model", "models/omniknight_zelensky_head.vmdl", context)
    local particle_list = 
    {
        "particles/econ/items/razor/razor_ti6/razor_plasmafield_ti6.vpcf",
        "particles/polnaref/polnaref_sleep.vpcf",
        "particles/generic_gameplay/generic_sleep.vpcf",
        "particles/poroshenko/poroshenko_slava_ukraine.vpcf",
        "particles/poroshenko/status_effect_poroshenko_slava.vpcf",
        "particles/poroshenko/poroshenko_fat.vpcf",
        "particles/poroshenko/poroshenko_fat_debuff.vpcf",
        "particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf",
        "particles/poroshenko/flag_ukraine.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Poroshenko_Slava_Ukraine:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Poroshenko_Slava_Ukraine:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Poroshenko_Slava_Ukraine:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Poroshenko_Slava_Ukraine:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("slavaukraine")  
    local snipers = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Poroshenko_slava_ukraine_hero", {duration = duration} )

    local particle = ParticleManager:CreateParticle("particles/poroshenko/poroshenko_slava_ukraine.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    if self:GetCaster():HasShard() then
        for _,sniper in pairs(snipers) do
            if sniper:GetUnitName() == "npc_dota_uk_sniper_1" or sniper:GetUnitName() == "npc_dota_uk_sniper_2" or sniper:GetUnitName() == "npc_dota_uk_sniper_3" then
                sniper:AddNewModifier( self:GetCaster(), self, "modifier_Poroshenko_slava_ukraine_sniper", {duration = duration} )
                local particle_sniper = ParticleManager:CreateParticle("particles/poroshenko/poroshenko_slava_ukraine.vpcf", PATTACH_ABSORIGIN_FOLLOW, sniper)
                ParticleManager:SetParticleControlEnt(particle_sniper, 1, sniper, PATTACH_ABSORIGIN_FOLLOW, nil, sniper:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(particle_sniper)
            end
        end
    end
end

modifier_Poroshenko_slava_ukraine_hero = class({})

function modifier_Poroshenko_slava_ukraine_hero:IsPurgable() return false end
function modifier_Poroshenko_slava_ukraine_hero:IsPurgeException() return false end

function modifier_Poroshenko_slava_ukraine_hero:GetHeroEffectName()
    return "particles/poroshenko/status_effect_poroshenko_slava.vpcf"
end

function modifier_Poroshenko_slava_ukraine_hero:HeroEffectPriority()
    return 1000
end

function modifier_Poroshenko_slava_ukraine_hero:GetStatusEffectName()
    return "particles/poroshenko/status_effect_poroshenko_slava.vpcf"
end

function modifier_Poroshenko_slava_ukraine_hero:StatusEffectPriority()
    return 1000
end

function modifier_Poroshenko_slava_ukraine_hero:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_Poroshenko_slava_ukraine_hero:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_hero") + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_3")
end

modifier_Poroshenko_slava_ukraine_sniper = class({})

function modifier_Poroshenko_slava_ukraine_sniper:IsPurgable() return false end
function modifier_Poroshenko_slava_ukraine_sniper:IsPurgeException() return false end

function modifier_Poroshenko_slava_ukraine_sniper:GetHeroEffectName()
    return "particles/poroshenko/status_effect_poroshenko_slava.vpcf"
end

function modifier_Poroshenko_slava_ukraine_sniper:HeroEffectPriority()
    return 1000
end

function modifier_Poroshenko_slava_ukraine_sniper:GetStatusEffectName()
    return "particles/poroshenko/status_effect_poroshenko_slava.vpcf"
end

function modifier_Poroshenko_slava_ukraine_sniper:StatusEffectPriority()
    return 1000
end

function modifier_Poroshenko_slava_ukraine_sniper:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_Poroshenko_slava_ukraine_sniper:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_sniper")
end

LinkLuaModifier( "modifier_Poroshenko_fat", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Poroshenko_fat_debuff", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Poroshenko_fat_debuff_target", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )

Poroshenko_fat = class({})

function Poroshenko_fat:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_1")
end

function Poroshenko_fat:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Poroshenko_fat:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Poroshenko_fat:GetAOERadius()
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_5")
end

function Poroshenko_fat:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor( "duration" )

    CreateModifierThinker( caster, self, "modifier_Poroshenko_fat", { duration = duration }, point, caster:GetTeamNumber(), false )
    caster:EmitSound("hero_viper.PoisonAttack.Target")
    caster:EmitSound("porohsalo")
end

modifier_Poroshenko_fat = class({})

function modifier_Poroshenko_fat:IsPurgable()
    return false
end

function modifier_Poroshenko_fat:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_5")
    if not IsServer() then return end
    if self:GetCaster():HasTalent("special_bonus_birzha_poroshenko_5") then
        local r = self.radius / 2
        local c = math.sqrt( 2 ) * 0.5 * r 
        local x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
        local y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }
        for i=1, 8 do
            local particle = ParticleManager:CreateParticle( "particles/poroshenko/poroshenko_fat.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
            ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() + Vector( x_offset[i], y_offset[i], 0.0 ) )
            ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, self.radius, self.radius ) )
            self:AddParticle(particle, false, false, -1, false, false )
        end
    end
    local particle = ParticleManager:CreateParticle( "particles/poroshenko/poroshenko_fat.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, self.radius, self.radius ) )
    self:AddParticle(particle, false, false, -1, false, false )
end

function modifier_Poroshenko_fat:IsAura()
    return true
end

function modifier_Poroshenko_fat:GetModifierAura()
    return "modifier_Poroshenko_fat_debuff"
end

function modifier_Poroshenko_fat:GetAuraRadius()
    return self.radius
end

function modifier_Poroshenko_fat:GetAuraDuration()
    return 0.5
end

function modifier_Poroshenko_fat:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Poroshenko_fat:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_Poroshenko_fat:GetAuraSearchFlags()
    return 0
end

modifier_Poroshenko_fat_debuff = class({})

function modifier_Poroshenko_fat_debuff:IsPurgable()
    return false
end

function modifier_Poroshenko_fat_debuff:IsHidden()
    return true
end

function modifier_Poroshenko_fat_debuff:OnCreated()
    if not IsServer() then return end
    if self:GetParent():IsBoss() then return end
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_ice_slide", {} )
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Poroshenko_fat_debuff_target", {duration=self:GetAbility():GetSpecialValueFor( "silence_duration" ) * (1-self:GetParent():GetStatusResistance()) } )
end

function modifier_Poroshenko_fat_debuff:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():IsBoss() then return end
    self:GetParent():RemoveModifierByName("modifier_ice_slide")
end

modifier_Poroshenko_fat_debuff_target = class({})

function modifier_Poroshenko_fat_debuff_target:IsPurgable()
    return true
end

function modifier_Poroshenko_fat_debuff_target:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 0.5 )
end

function modifier_Poroshenko_fat_debuff_target:OnIntervalThink()
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    if not IsServer() then return end
    local damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage * 0.5,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    ApplyDamage( damageTable )
end

function modifier_Poroshenko_fat_debuff_target:CheckState()
    local state = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return state
end

function modifier_Poroshenko_fat_debuff_target:GetEffectName()
    return "particles/poroshenko/poroshenko_fat_debuff.vpcf"
end

function modifier_Poroshenko_fat_debuff_target:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_Poroshenko_bunt", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )

Poroshenko_bunt = class({})

function Poroshenko_bunt:GetIntrinsicModifierName()
    return "modifier_Poroshenko_bunt"
end

modifier_Poroshenko_bunt = class({})

function modifier_Poroshenko_bunt:IsHidden()
    return true
end

function modifier_Poroshenko_bunt:IsPurgable()
    return false
end

function modifier_Poroshenko_bunt:OnCreated( kv )
    self.max_as = self:GetAbility():GetSpecialValueFor( "maximum_attack_speed" )
    self.max_hp_regen = self:GetAbility():GetSpecialValueFor( "maximum_health_regen" )
    self.max_threshold = self:GetAbility():GetSpecialValueFor( "hp_threshold_max" )
    self.range = 100-self.max_threshold
    self.max_size = 35
    self:PlayEffects()
end

function modifier_Poroshenko_bunt:OnRefresh( kv )
    self.max_as = self:GetAbility():GetSpecialValueFor( "maximum_attack_speed" )
    self.max_hp_regen = self:GetAbility():GetSpecialValueFor( "maximum_health_regen" )
    self.max_threshold = self:GetAbility():GetSpecialValueFor( "hp_threshold_max" ) 
    self.range = 100-self.max_threshold
end

function modifier_Poroshenko_bunt:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }

    return funcs
end

function modifier_Poroshenko_bunt:GetModifierConstantHealthRegen()
    if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
    local pct = math.max((self:GetParent():GetHealthPercent()- ( self.max_threshold + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_6")) )/  (self.range - self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_6")) ,0)
    local health_regen = ((1-pct)* (self.max_hp_regen+ self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_2"))  ) * (self:GetParent():GetStrength() / 100)
    return health_regen
end

function modifier_Poroshenko_bunt:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
    local pct = math.max((self:GetParent():GetHealthPercent()- ( self.max_threshold + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_6")) )/  (self.range - self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_6")) ,0)
    return (1-pct)*self.max_as
end


function modifier_Poroshenko_bunt:GetModifierModelScale()
    if IsServer() then
        if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
        local pct = math.max((self:GetParent():GetHealthPercent()- ( self.max_threshold + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_6")) )/  (self.range - self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_6")) ,0)
        ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( (1-pct)*100,0,0 ) )
        return (1-pct)*self.max_size
    end
end

function modifier_Poroshenko_bunt:PlayEffects()
    self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    self:AddParticle(self.effect_cast, false, false, -1, false, false )
end

LinkLuaModifier( "modifer_poroshenko_donbass_talent", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_poroshenko_donbass_unit", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )

poroshenko_donbass = class({})

function poroshenko_donbass:GetIntrinsicModifierName()
    return "modifer_poroshenko_donbass_talent"
end

function poroshenko_donbass:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_poroshenko_4")
end

function poroshenko_donbass:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function poroshenko_donbass:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function poroshenko_donbass:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function poroshenko_donbass:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor( "radius" )
    local count = self:GetSpecialValueFor('snipers_count')
    local snipers_duration = self:GetSpecialValueFor('snipers_duration')
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    caster:EmitSound("gimnukraine")
    GridNav:DestroyTreesAroundPoint(point, radius, false)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do
        if self:GetCaster():HasScepter() then
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetSpecialValueFor("stun_duration_scepter") * (1-enemy:GetStatusResistance()) })
        end
    end

    for i = 1, count do
        self.sniper = CreateUnitByName("npc_dota_uk_sniper_"..self:GetLevel(), point + RandomVector(150), true, caster, nil, caster:GetTeamNumber())
        self.sniper:SetOwner(caster)
        self.sniper:SetControllableByPlayer(caster:GetPlayerID(), true)
        FindClearSpaceForUnit(self.sniper, self.sniper:GetAbsOrigin(), true)
        self.sniper:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = snipers_duration})
        self.sniper:AddNewModifier(self:GetCaster(), self, "modifier_poroshenko_donbass_unit", {})
    end
end

modifer_poroshenko_donbass_talent = class({})

function modifer_poroshenko_donbass_talent:IsHidden()
    return true
end

function modifer_poroshenko_donbass_talent:IsPurgable()
    return false
end
function modifer_poroshenko_donbass_talent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_DEATH,
    }

    return funcs
end

function modifer_poroshenko_donbass_talent:OnDeath( params )
    if not IsServer() then return end
    local count = self:GetAbility():GetSpecialValueFor('snipers_count')
    local snipers_duration = self:GetAbility():GetSpecialValueFor('snipers_duration')
    if params.unit == self:GetParent() then
        if self:GetCaster():HasTalent("special_bonus_birzha_poroshenko_8") then
            if self:GetCaster():IsIllusion() then return end
            self:GetParent():EmitSound("gimnukraine")
            for i = 1, count do
                self.sniper = CreateUnitByName("npc_dota_uk_sniper_"..self:GetAbility():GetLevel(), self:GetParent():GetAbsOrigin() + RandomVector(150), true, self:GetParent(), nil, self:GetParent():GetTeamNumber())
                self.sniper:SetOwner(self:GetParent())
                self.sniper:SetControllableByPlayer(self:GetParent():GetPlayerID(), true)
                FindClearSpaceForUnit(self.sniper, self.sniper:GetAbsOrigin(), true)
                self.sniper:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kill", {duration = snipers_duration})
                self.sniper:AddNewModifier(self:GetCaster(), self, "modifier_poroshenko_donbass_unit", {})
            end
        end
    end
end

modifier_poroshenko_donbass_unit = class({})
function modifier_poroshenko_donbass_unit:IsHidden() return true end
function modifier_poroshenko_donbass_unit:IsPurgable() return false end
function modifier_poroshenko_donbass_unit:IsPurgeException() return false end
function modifier_poroshenko_donbass_unit:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_poroshenko_donbass_unit:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_poroshenko_donbass_unit:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_poroshenko_donbass_unit:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    local new_health = self:GetParent():GetHealth() - 1
    if new_health <= 0 then
        self:GetParent():Kill(nil, params.attacker)
    else
        self:GetParent():SetHealth(new_health)
    end
end

function modifier_poroshenko_donbass_unit:GetModifierHealthBarPips()
    return self:GetAbility():GetSpecialValueFor("attack_to_die")
end

function modifier_poroshenko_donbass_unit:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return funcs
end

function modifier_poroshenko_donbass_unit:GetDisableHealing()
    return 1
end

LinkLuaModifier("modifier_Poroshenko_flag_ukraine", "abilities/heroes/poroshenko", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Poroshenko_flag_ukraine_buff", "abilities/heroes/poroshenko", LUA_MODIFIER_MOTION_NONE)

Poroshenko_flag_ukraine = class({})

function Poroshenko_flag_ukraine:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local unit = CreateUnitByName("npc_dota_flag_ukraine_unit", point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    unit.invul = true
    unit:SetForwardVector(self:GetCaster():GetForwardVector() * -1)
    unit:AddNewModifier(self:GetCaster(), self, "modifier_Poroshenko_flag_ukraine", {duration = duration})
    unit:EmitSound("DOTA_Item.ObserverWard.Activate")
end

function Poroshenko_flag_ukraine:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_poroshenko_7") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function Poroshenko_flag_ukraine:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

modifier_Poroshenko_flag_ukraine = class({})

function modifier_Poroshenko_flag_ukraine:IsHidden() return true end

function modifier_Poroshenko_flag_ukraine:IsAuraActiveOnDeath() return false end

function modifier_Poroshenko_flag_ukraine:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

function modifier_Poroshenko_flag_ukraine:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end

function modifier_Poroshenko_flag_ukraine:OnCreated(params)
    self.destroy_attacks = self:GetAbility():GetSpecialValueFor("attack_destroy") * 2
    if not IsServer() then return end
    self.hero_attack_multiplier = 2
    self.health_increments = self:GetParent():GetMaxHealth() / self.destroy_attacks
    local particle = ParticleManager:CreateParticle("particles/poroshenko/flag_ukraine.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
end

function modifier_Poroshenko_flag_ukraine:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
    }
    return decFuncs
end

function modifier_Poroshenko_flag_ukraine:GetModifierHealthBarPips()
    return self:GetAbility():GetSpecialValueFor("attack_destroy")
end

function modifier_Poroshenko_flag_ukraine:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_Poroshenko_flag_ukraine:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_Poroshenko_flag_ukraine:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_Poroshenko_flag_ukraine:GetDisableHealing()
    return 1
end

function modifier_Poroshenko_flag_ukraine:OnAttacked(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        local new_health = self:GetParent():GetHealth() - self.health_increments
        if keys.attacker:IsRealHero() then
            new_health = self:GetParent():GetHealth() - (self.health_increments * self.hero_attack_multiplier)
        end
        if new_health <= 0 then
            UTIL_Remove(self:GetParent())
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_Poroshenko_flag_ukraine:IsAura()
    return true
end

function modifier_Poroshenko_flag_ukraine:GetModifierAura()
    return "modifier_Poroshenko_flag_ukraine_buff"
end

function modifier_Poroshenko_flag_ukraine:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_Poroshenko_flag_ukraine:GetAuraDuration()
    return 0
end

function modifier_Poroshenko_flag_ukraine:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_Poroshenko_flag_ukraine:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_Poroshenko_flag_ukraine:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_Poroshenko_flag_ukraine_buff = class({})

function modifier_Poroshenko_flag_ukraine_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_Poroshenko_flag_ukraine_buff:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduce")
end