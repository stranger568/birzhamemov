LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

druzhko_unstable_magic = class({})

function druzhko_unstable_magic:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function druzhko_unstable_magic:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function druzhko_unstable_magic:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function druzhko_unstable_magic:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasScepter()) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function druzhko_unstable_magic:OnSpellStart()
    local target = self:GetCursorTarget()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( "Ability.LagunaBladeImpact", self:GetCaster() )
    self.damage = self:GetSpecialValueFor( "damage" )
    if self:GetCaster():HasScepter() then
        self.type = DAMAGE_TYPE_PURE
    else
        self.type = DAMAGE_TYPE_MAGICAL
    end
    if target:IsMagicImmune() and (not self:GetCaster():HasScepter()) then return end 
    if target:TriggerSpellAbsorb( self) then return end
    local damageTable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = self.type,
        ability = self,
    }
    ApplyDamage(damageTable)
end

druzhko_dark_magic = class({})

LinkLuaModifier( "modifier_druzhko_dark_magic_count", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_druzhko_dark_magic_debuff", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )

function druzhko_dark_magic:GetIntrinsicModifierName()
    if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
        return "modifier_druzhko_dark_magic_count"
    end
end

function druzhko_dark_magic:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "radius" )
    end

    return 0
end

function druzhko_dark_magic:GetCooldown( level )
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "cooldown_scepter" )
    end

    return self.BaseClass.GetCooldown( self, level )
end

function druzhko_dark_magic:GetManaCost( level )
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "mana_cost_scepter" )
    end

    return self.BaseClass.GetManaCost( self, level )
end

function druzhko_dark_magic:OnSpellStart()
    local target = self:GetCursorTarget()
    EmitSoundOn( "Hero_Lion.FingerOfDeath", self:GetCaster() )
    if target:TriggerSpellAbsorb(self) then
        self:PlayEffects( target )
        return 
    end
    local radius = self:GetSpecialValueFor("radius")
    if self:GetCaster():HasScepter() then
        self.damage = self:GetSpecialValueFor( "damage_scepter" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_2")
    else
        self.damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_2")
    end
    if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
        local modifier_bonus = self:GetCaster():FindModifierByName("modifier_druzhko_dark_magic_count")
        local bonus = modifier_bonus:GetStackCount()
        self.damage = self.damage + bonus
    end
    local damageTable = {
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }
    if self:GetCaster():HasScepter() then
        local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        for _,enemy in pairs(targets) do
            if enemy:IsRealHero() then
                enemy:AddNewModifier( self:GetCaster(), self, "modifier_druzhko_dark_magic_debuff", { duration = 3 } )
            end
            damageTable.victim = enemy
            ApplyDamage(damageTable)
            self:PlayEffects( enemy )
        end
    else
        if target:IsRealHero() then
            target:AddNewModifier( self:GetCaster(), self, "modifier_druzhko_dark_magic_debuff", { duration = 3 } )
        end
        damageTable.victim = target
        ApplyDamage(damageTable)
        self:PlayEffects( target )
    end
end

function druzhko_dark_magic:PlayEffects( target )
    local caster = self:GetCaster()
    local direction = (caster:GetOrigin()-target:GetOrigin()):Normalized()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_ABSORIGIN, caster )
    local attach = "attach_attack1"
    if caster:ScriptLookupAttachment( "attach_attack2" )~=0 then attach = "attach_attack2" end
    ParticleManager:SetParticleControlEnt(  effect_cast, 0, caster, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 2, target:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 3, target:GetOrigin() + direction )
    ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( "Hero_Lion.FingerOfDeathImpact", target )
end

modifier_druzhko_dark_magic_count = class({})

function modifier_druzhko_dark_magic_count:IsPurgable()
    return false
end

modifier_druzhko_dark_magic_debuff = class({})

function modifier_druzhko_dark_magic_debuff:IsPurgable()
    return false
end

function modifier_druzhko_dark_magic_debuff:IsHidden()
    return true
end

function modifier_druzhko_dark_magic_debuff:DeclareFunctions()
    local decfuncs = {
        MODIFIER_EVENT_ON_DEATH
    }

    return decfuncs
end
function modifier_druzhko_dark_magic_debuff:OnDeath(params)
    local caster = self:GetCaster()
    local target = params.unit

    if target:IsRealHero() and caster:GetTeamNumber() ~= target:GetTeamNumber() and caster:IsAlive() then     
        local modifier_bonus = self:GetCaster():FindModifierByName("modifier_druzhko_dark_magic_count")
        local bonus = modifier_bonus:GetStackCount()
        local bonus_damage = self:GetAbility():GetSpecialValueFor( "damage_per_kill" )
        modifier_bonus:SetStackCount(bonus + bonus_damage)
    end
end

LinkLuaModifier( "modifier_druzhko_ice_armor", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )

druzhko_ice_armor = class({})

function druzhko_ice_armor:GetCooldown( level )
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "scepter_cooldown" )
    end

    return self.BaseClass.GetCooldown( self, level )
end

function druzhko_ice_armor:GetIntrinsicModifierName()
    return "modifier_druzhko_ice_armor"
end

modifier_druzhko_ice_armor = class({})

function modifier_druzhko_ice_armor:OnCreated()
    if IsServer() then
        self:GetParent().tOldSpells = {}
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_druzhko_ice_armor:OnIntervalThink()
    if IsServer() then
        local caster = self:GetParent()
        for i=#caster.tOldSpells,1,-1 do
            local hSpell = caster.tOldSpells[i]
            if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
                hSpell:RemoveSelf()
                table.remove(caster.tOldSpells,i)
            end
        end
    end
end

function modifier_druzhko_ice_armor:IsHidden()
    return true
end

function modifier_druzhko_ice_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_REFLECT_SPELL,
    }

    return funcs
end

function modifier_druzhko_ice_armor:GetModifierMagicalResistanceBonus( params )
    if not self:GetParent():PassivesDisabled() then
        return self:GetAbility():GetSpecialValueFor("spell_shield_resistance") + self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_3")
    end
end

function modifier_druzhko_ice_armor:GetAbsorbSpell( params )
    if IsServer() then
        if self:GetParent():HasScepter() and (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() then
            if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
                return nil
            end
            self:GetAbility():UseResources( false, false, true )
            self:PlayEffects( true )
            return 1
        end
    end
end

local function SpellReflect(parent, params)
    local reflected_spell_name = params.ability:GetAbilityName()
    local target = params.ability:GetCaster()

    if target:GetTeamNumber() == parent:GetTeamNumber() then
        return nil
    end

    if target:HasModifier("modifier_item_lotus_orb_active") then
        return nil
    end

    if params.ability.spell_shield_reflect then
        return nil
    end
    local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(reflect_pfx)
    local old_spell = false
    for _,hSpell in pairs(parent.tOldSpells) do
        if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
            old_spell = true
            break
        end
    end
    if old_spell then
        ability = parent:FindAbilityByName(reflected_spell_name)
    else
        ability = parent:AddAbility(reflected_spell_name)
        ability:SetStolen(true)
        ability:SetHidden(true)
        ability.spell_shield_reflect = true
        ability:SetRefCountsModifiers(true)
        table.insert(parent.tOldSpells, ability)
    end
    ability:SetLevel(params.ability:GetLevel())
    parent:SetCursorCastTarget(target)
    ability:OnSpellStart()
    target:EmitSound("Hero_Antimage.Counterspell.Target")
    if ability.OnChannelFinish then
        ability:OnChannelFinish(false)
    end 

    return false
end

function modifier_druzhko_ice_armor:GetReflectSpell( params )
    if self:GetParent():HasScepter() and (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources( false, false, true )
        return SpellReflect(self:GetParent(), params)
    end
end

function modifier_druzhko_ice_armor:PlayEffects( bBlock )
    if bBlock then
        particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf"
        sound_cast = "Hero_Antimage.SpellShield.Block"
    else
        particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
        sound_cast = "Hero_Antimage.SpellShield.Reflect"
    end
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( sound_cast, self:GetParent() )
end

LinkLuaModifier( "modifier_druzhko_hype", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )

Druzhko_Hype = class({})

function Druzhko_Hype:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Druzhko_Hype:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Druzhko_Hype:OnSpellStart()
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():EmitSound("druzhkoXaip")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_druzhko_hype", { duration = duration } )
end

modifier_druzhko_hype = class({})

function modifier_druzhko_hype:IsPurgable()
    return false
end

function modifier_druzhko_hype:OnCreated( kv )
    if IsServer() then
        self.nHealTicks = 0
        self:StartIntervalThink( 0.05 )
    end
end

function modifier_druzhko_hype:OnRemoved()
    if IsServer() then
        local flHealth = self:GetParent():GetHealth() 
        local flMaxHealth = self:GetParent():GetMaxHealth()
        local flHealthPct = flHealth / flMaxHealth
        self:GetCaster():StopSound("druzhkoXaip")
        self:GetParent():CalculateStatBonus(true)

        local flNewHealth = self:GetParent():GetHealth()  
        local flNewMaxHealth = self:GetParent():GetMaxHealth()

        local flNewDesiredHealth = flNewMaxHealth * flHealthPct
        if flNewHealth ~= flNewDesiredHealth then
            self:GetParent():ModifyHealth( flNewDesiredHealth, self:GetAbility(), false, 0 )
        end 
    end
end

function modifier_druzhko_hype:OnIntervalThink()
    if IsServer() then
        self:GetParent():Heal( ( self:GetAbility():GetSpecialValueFor( "bonus_strength" ) * 20 ) * 0.05, self:GetAbility() )
        self.nHealTicks = self.nHealTicks + 1
        if self.nHealTicks >= 20 then
            self:StartIntervalThink( -1 )
        end
    end
end

function modifier_druzhko_hype:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_druzhko_hype:GetModifierModelScale( params )
    return self:GetAbility():GetSpecialValueFor( "model_scale" )
end

function modifier_druzhko_hype:GetModifierExtraStrengthBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_strength" )
end

function modifier_druzhko_hype:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_druzhko_hype:GetModifierBonusStats_Agility( params )
    return self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_1")
end
