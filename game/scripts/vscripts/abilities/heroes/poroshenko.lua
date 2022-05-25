LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Poroshenko_slava_ukraine_hero", "abilities/heroes/poroshenko", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Poroshenko_slava_ukraine_sniper", "abilities/heroes/poroshenko", LUA_MODIFIER_MOTION_NONE)

Poroshenko_Slava_Ukraine = class({}) 

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
    local snipers = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false)

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
    return {
            MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        }
end

function modifier_Poroshenko_slava_ukraine_hero:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_hero")
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
    return {
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
    return self.BaseClass.GetCooldown( self, level )
end

function Poroshenko_fat:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Poroshenko_fat:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Poroshenko_fat:GetAOERadius()
    return self:GetSpecialValueFor("radius")
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
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/poroshenko/poroshenko_fat.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, 1, 1 ) )
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
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Poroshenko_fat_debuff_target", {duration=self:GetAbility():GetSpecialValueFor( "duration" )} )
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
    self:StartIntervalThink( 1 )
end

function modifier_Poroshenko_fat_debuff_target:OnIntervalThink()
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    if not IsServer() then return end
    local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    ApplyDamage( damageTable )
end

function modifier_Poroshenko_fat_debuff_target:CheckState()
    local state = {
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
    local pct = math.max((self:GetParent():GetHealthPercent()-self.max_threshold)/self.range,0)
    local health_regen = ((1-pct)*self.max_hp_regen) * (self:GetParent():GetStrength() / 100)
    return health_regen
end

function modifier_Poroshenko_bunt:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
    local pct = math.max((self:GetParent():GetHealthPercent()-self.max_threshold)/self.range,0)
    return (1-pct)*self.max_as
end


function modifier_Poroshenko_bunt:GetModifierModelScale()
    if IsServer() then
        if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
        local pct = math.max((self:GetParent():GetHealthPercent()-self.max_threshold)/self.range,0)
        ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( (1-pct)*100,0,0 ) )
        return (1-pct)*self.max_size
    end
end

function modifier_Poroshenko_bunt:PlayEffects()
    self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    self:AddParticle(self.effect_cast, false, false, -1, false, false )
end

LinkLuaModifier( "poroshenko_donbass_talent", "abilities/heroes/poroshenko.lua", LUA_MODIFIER_MOTION_NONE )

poroshenko_donbass = class({})

function poroshenko_donbass:GetIntrinsicModifierName()
    return "poroshenko_donbass_talent"
end

function poroshenko_donbass:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        if self:GetCaster():HasScepter() then
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = 3})
        end
    end
    for i = 1, count do
        self.sniper = CreateUnitByName("npc_dota_uk_sniper_"..self:GetLevel(), point + RandomVector(150), true, caster, nil, caster:GetTeamNumber())
        self.sniper:SetOwner(caster)
        self.sniper:SetControllableByPlayer(caster:GetPlayerID(), true)
        FindClearSpaceForUnit(self.sniper, self.sniper:GetAbsOrigin(), true)
        self.sniper:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = snipers_duration})
    end
end

poroshenko_donbass_talent = class({})

function poroshenko_donbass_talent:IsHidden()
    return true
end

function poroshenko_donbass_talent:IsPurgable()
    return false
end
function poroshenko_donbass_talent:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }

    return funcs
end

function poroshenko_donbass_talent:OnDeath( params )
    if not IsServer() then return end
    local count = self:GetAbility():GetSpecialValueFor('snipers_count')
    local snipers_duration = self:GetAbility():GetSpecialValueFor('snipers_duration')
    if params.unit == self:GetParent() then
        if self:GetCaster():HasTalent("special_bonus_birzha_poroshenko_1") then
            if self:GetCaster():IsIllusion() then return end
            self:GetParent():EmitSound("gimnukraine")
            for i = 1, count do
                self.sniper = CreateUnitByName("npc_dota_uk_sniper_"..self:GetAbility():GetLevel(), self:GetParent():GetAbsOrigin() + RandomVector(150), true, self:GetParent(), nil, self:GetParent():GetTeamNumber())
                self.sniper:SetOwner(self:GetParent())
                self.sniper:SetControllableByPlayer(self:GetParent():GetPlayerID(), true)
                FindClearSpaceForUnit(self.sniper, self.sniper:GetAbsOrigin(), true)
                self.sniper:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kill", {duration = snipers_duration})
            end
        end
    end
end




