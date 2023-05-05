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

function druzhko_unstable_magic:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_druzhko_7") then
        return DOTA_ABILITY_BEHAVIOR_POINT
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
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
    if not IsServer() then return end

    if self:GetCaster():HasTalent("special_bonus_birzha_druzhko_7") then
        local point = self:GetCursorPosition()
        local direction = point-self:GetCaster():GetAbsOrigin()
        direction.z = 0
        local projectile_normalized = direction:Normalized()
        local range = 600 + self:GetCaster():GetCastRangeBonus()

        local end_point = self:GetCaster():GetAbsOrigin() + projectile_normalized * range
        end_point = GetGroundPosition(end_point, nil)

        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
        ParticleManager:SetParticleControl(particle, 1, end_point)
        ParticleManager:ReleaseParticleIndex( particle )

        local particle_smoke = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade_shard_scorch.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( particle_smoke, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
        ParticleManager:SetParticleControl(particle_smoke, 1, end_point)
        ParticleManager:ReleaseParticleIndex( particle_smoke )

        self:GetCaster():EmitSound("Ability.LagunaBlade")

        local flag_type = 0
        local damage_type = DAMAGE_TYPE_MAGICAL
        local damage = self:GetSpecialValueFor( "damage" )

        if self:GetCaster():HasScepter() then
            flag_type = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        if self:GetCaster():HasScepter() then
            damage_type = DAMAGE_TYPE_PURE
        end

        local units = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(),end_point, nil, 125, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, flag_type)
        for _, unit in pairs(units) do
            unit:EmitSound("Ability.LagunaBladeImpact")
            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade_shard_units_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
            ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
            Timers:CreateTimer(0.25, function()
                if not unit:IsMagicImmune() or self:GetCaster():HasScepter() then
                    local damageTable = 
                    {
                        victim = unit,
                        attacker = self:GetCaster(),
                        damage = damage,
                        damage_type = damage_type,
                        ability = self,
                    }
                    ApplyDamage(damageTable)
                    if self:GetCaster():HasTalent("special_bonus_birzha_druzhko_2") then
                        unit:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_2") * (1-unit:GetStatusResistance()) } )
                    end
                end
            end)
        end
        return
    end

    local target = self:GetCursorTarget()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("Ability.LagunaBladeImpact")
    local damage = self:GetSpecialValueFor( "damage" )
    local damage_type = DAMAGE_TYPE_MAGICAL
    local ability = self
    local caster = self:GetCaster()
    if self:GetCaster():HasScepter() then
        damage_type = DAMAGE_TYPE_PURE
    end
    Timers:CreateTimer(0.25, function()
        if target:IsMagicImmune() and (not self:GetCaster():HasScepter()) then return end 
        if target:TriggerSpellAbsorb( self) then return end
        local damageTable = 
        {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = damage_type,
            ability = ability,
        }
        ApplyDamage(damageTable)
        if self:GetCaster():HasTalent("special_bonus_birzha_druzhko_2") then
            target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_2") * (1-target:GetStatusResistance()) } )
        end
    end)
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
    return self.BaseClass.GetCooldown( self, level )
end

function druzhko_dark_magic:GetManaCost( level )
    return self.BaseClass.GetManaCost( self, level )
end

function druzhko_dark_magic:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()

    self:GetCaster():EmitSound("Hero_Lion.FingerOfDeath")

    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local damage_per_kill = self:GetSpecialValueFor( "damage_per_kill" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_4")
    local ability = self
    local caster = self:GetCaster()

    local modifier_bonus = self:GetCaster():FindModifierByName("modifier_druzhko_dark_magic_count")
    if modifier_bonus then
        local bonus = modifier_bonus:GetStackCount()
        damage = damage + (bonus * damage_per_kill)
    end

    local damageTable = { attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability }

    if self:GetCaster():HasScepter() then
        local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        for _,enemy in pairs(targets) do
            self:PlayEffects( enemy )
            Timers:CreateTimer(0.25, function()
                if not enemy:IsMagicImmune() then
                    if enemy:IsRealHero() then
                        enemy:AddNewModifier( self:GetCaster(), self, "modifier_druzhko_dark_magic_debuff", { duration = 3 } )
                    end
                    damageTable.victim = enemy
                    ApplyDamage(damageTable)
                end
            end)
        end
    else
        self:PlayEffects( target )
        Timers:CreateTimer(0.25, function()
            if target:TriggerSpellAbsorb(self) then return end
            if target:IsMagicImmune() then return end
            if target:IsRealHero() then
                target:AddNewModifier( self:GetCaster(), self, "modifier_druzhko_dark_magic_debuff", { duration = 3 } )
            end
            damageTable.victim = target
            ApplyDamage(damageTable)
        end)
    end
end

function druzhko_dark_magic:PlayEffects( target )
    local caster = self:GetCaster()
    local direction = (caster:GetOrigin()-target:GetOrigin()):Normalized()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControlEnt(  effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 2, target:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 3, target:GetOrigin() + direction )
    ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("Hero_Lion.FingerOfDeathImpact")
end

modifier_druzhko_dark_magic_count = class({})

function modifier_druzhko_dark_magic_count:IsPurgable()
    return false
end

function modifier_druzhko_dark_magic_count:IsHidden() return self:GetStackCount() == 0 end

function modifier_druzhko_dark_magic_count:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_druzhko_dark_magic_count:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount() * self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_1")
end

function modifier_druzhko_dark_magic_count:OnTooltip()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor( "damage_per_kill" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_4"))
end



modifier_druzhko_dark_magic_debuff = class({})

function modifier_druzhko_dark_magic_debuff:IsPurgable()
    return false
end

function modifier_druzhko_dark_magic_debuff:IsHidden()
    return true
end

function modifier_druzhko_dark_magic_debuff:DeclareFunctions()
    local decfuncs = 
    {
        MODIFIER_EVENT_ON_DEATH
    }

    return decfuncs
end

function modifier_druzhko_dark_magic_debuff:OnDeath(params)
    local caster = self:GetCaster()
    local target = params.unit
    if target:IsRealHero() and caster:GetTeamNumber() ~= target:GetTeamNumber() and caster:IsAlive() and target == self:GetParent() then     
        local modifier_bonus = self:GetCaster():FindModifierByName("modifier_druzhko_dark_magic_count")
        if modifier_bonus then
            modifier_bonus:IncrementStackCount()
        end
    end
end

LinkLuaModifier( "modifier_druzhko_ice_armor", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_druzhko_ice_armor_rooted", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_druzhko_ice_armor_cooldown", "abilities/heroes/druzhko.lua", LUA_MODIFIER_MOTION_NONE )

druzhko_ice_armor = class({})

function druzhko_ice_armor:GetCooldown( level )
    if self:GetCaster():HasShard() then
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
            if hSpell:NumModifiersUsingAbility() <= -1 and not hSpell:IsChanneling() then
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
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_druzhko_ice_armor:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.damage_type ~= DAMAGE_TYPE_MAGICAL then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_druzhko_5") then return end
    if self:GetParent():HasModifier("modifier_druzhko_ice_armor_cooldown") then return end
    if (params.attacker:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > 800 then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_druzhko_ice_armor_cooldown", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_5", "value2")})
    params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_druzhko_ice_armor_rooted", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_5")})
    self:PlayEffects2( self:GetParent(), params.attacker )
end

function modifier_druzhko_ice_armor:PlayEffects2( caster, target )
    local projectile_name = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf"
    local projectile_speed = 1000
    local info = {Target = target,Source = caster,Ability = self,EffectName = projectile_name,iMoveSpeed = projectile_speed,vSourceLoc= caster:GetAbsOrigin(),bDodgeable = false}
    ProjectileManager:CreateTrackingProjectile(info)
end

function modifier_druzhko_ice_armor:GetModifierMagicalResistanceBonus( params )
    if not self:GetParent():PassivesDisabled() then
        return self:GetAbility():GetSpecialValueFor("spell_shield_resistance") + self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_6")
    end
end

function modifier_druzhko_ice_armor:GetAbsorbSpell( params )
    if IsServer() then
        if self:GetParent():HasShard() and (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() then
            if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
                return nil
            end
            self:GetAbility():UseResources( false, false, false, true )
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

    if ability:GetIntrinsicModifierName() ~= nil then
        local modifier_intrinsic = parent:FindModifierByName(ability:GetIntrinsicModifierName())
        if modifier_intrinsic then
            parent:RemoveModifierByName(modifier_intrinsic:GetName())
        end
    end

    return false
end

function modifier_druzhko_ice_armor:GetReflectSpell( params )
    if self:GetParent():HasShard() and (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources( false, false, false, true )
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
    self:GetParent():EmitSound(sound_cast)
end

modifier_druzhko_ice_armor_cooldown = class({})
function modifier_druzhko_ice_armor_cooldown:IsDebuff() return true end
function modifier_druzhko_ice_armor_cooldown:IsPurgable() return false end
function modifier_druzhko_ice_armor_cooldown:RemoveOnDeath() return false end

modifier_druzhko_ice_armor_rooted = class({})

function modifier_druzhko_ice_armor_rooted:OnCreated( kv )
    if IsServer() then
        self:GetParent():EmitSound("hero_Crystal.frostbite")
    end
end

function modifier_druzhko_ice_armor_rooted:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("hero_Crystal.frostbite")
end

function modifier_druzhko_ice_armor_rooted:CheckState()
    local state = {[MODIFIER_STATE_DISARMED] = true,[MODIFIER_STATE_ROOTED] = true,[MODIFIER_STATE_INVISIBLE] = false}
    return state
end

function modifier_druzhko_ice_armor_rooted:GetEffectName()
    return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_druzhko_ice_armor_rooted:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
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
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_druzhko_hype:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_druzhko_8") then return end
    local druzhko_dark_magic = self:GetCaster():FindAbilityByName("druzhko_dark_magic")
    if druzhko_dark_magic then
        local cooldown = druzhko_dark_magic:GetCooldownTimeRemaining()
        if cooldown - self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_8") <= 0 then
            druzhko_dark_magic:EndCooldown()
        else
            druzhko_dark_magic:EndCooldown()
            druzhko_dark_magic:StartCooldown(cooldown - self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_8"))
        end
    end
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
    return self:GetCaster():FindTalentValue("special_bonus_birzha_druzhko_3")
end
