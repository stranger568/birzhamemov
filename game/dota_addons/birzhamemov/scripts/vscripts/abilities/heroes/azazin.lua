azazin_teama = class({})

function azazin_teama:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function azazin_teama:OnSpellStart()
    if not IsServer() then return end

    local image_count = self:GetSpecialValueFor("illusion_count")
    local image_out_dmg = self:GetSpecialValueFor("outgoing_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_azazin_1")
    local incoming_damage = self:GetSpecialValueFor("incoming_damage")
    local duration = self:GetSpecialValueFor("illusion_duration")

    local vRandomSpawnPos = {
        Vector(108, 0, 0),
        Vector(108, 108, 0),
        Vector(108, 0, 0),
        Vector(0, 108, 0),
        Vector(-108, 0, 0),
        Vector(-108, 108, 0),
        Vector(-108, -108, 0),
        Vector(0, -108, 0),
    }

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_ABSORIGIN, self:GetCaster())

    for i = 1, image_count do
        local illusions = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=image_out_dmg,incoming_damage=incoming_damage}, 1, 1, true, true ) 
        for k, illusion in pairs(illusions) do
            local pos = self:GetCaster():GetAbsOrigin() + vRandomSpawnPos[i]
            FindClearSpaceForUnit(illusion, pos, true)
            local particle_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide_foam.vpcf", PATTACH_ABSORIGIN, illusion)
            ParticleManager:ReleaseParticleIndex(particle_2)
        end
    end
    ParticleManager:DestroyParticle(particle, false)
    ParticleManager:ReleaseParticleIndex(particle)
    self:GetCaster():Stop()
    self:GetCaster():EmitSound("azazinfriends")
end

LinkLuaModifier("modifier_azazin_gayaura", "abilities/heroes/azazin", LUA_MODIFIER_MOTION_NONE)

azazin_gayaura = class({}) 

function azazin_gayaura:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function azazin_gayaura:GetIntrinsicModifierName()
    return "modifier_azazin_gayaura"
end

modifier_azazin_gayaura = class({})

function modifier_azazin_gayaura:IsHidden()
    return true
end

function modifier_azazin_gayaura:IsPurgable()
    return false
end

function modifier_azazin_gayaura:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_azazin_gayaura:OnTakeDamage (event)
    if event.unit == self:GetParent() then
        local caster = self:GetParent()
        local post_damage = event.damage
        local original_damage = event.original_damage
        local ability = self:GetAbility()
        local damage_reflect_pct = (ability:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_azazin_5")) * 0.01
        local radius = ability:GetSpecialValueFor("radius")
        if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
        if caster:IsAlive() then
            caster:SetHealth(caster:GetHealth() + (post_damage * damage_reflect_pct) )
        end

        local units = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false
        )
        for _,unit in pairs(units) do
            if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
                local vCaster = caster:GetAbsOrigin()
                local vUnit = unit:GetAbsOrigin()
                local distance = (vUnit - vCaster):Length2D()
                local damage = original_damage * damage_reflect_pct
                local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf", PATTACH_POINT_FOLLOW, caster )
                ParticleManager:SetParticleControl(particle, 0, vCaster)
                ParticleManager:SetParticleControl(particle, 1, vUnit)
                ParticleManager:SetParticleControl(particle, 2, vCaster)
                if damage > 10000 then
                    ApplyDamage({victim = event.attacker, attacker = caster, ability = self:GetAbility(), damage = damage, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })   
                    return
                end
                ApplyDamage({victim = unit, attacker = caster, ability = self:GetAbility(), damage = damage, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
            end
        end
    end
end

LinkLuaModifier( "modifier_azazin_agressive", "abilities/heroes/azazin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_azazin_agressive_debuff", "abilities/heroes/azazin.lua", LUA_MODIFIER_MOTION_NONE )

azazin_agressive = class({})

function azazin_agressive:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function azazin_agressive:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function azazin_agressive:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_azazin_2")
end


function azazin_agressive:OnAbilityPhaseInterrupted()
    StopSoundOn( "Hero_Axe.BerserkersCall.Start", self:GetCaster() )
end
function azazin_agressive:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Hero_Axe.BerserkersCall.Start")
    return true
end

function azazin_agressive:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetOrigin()
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_azazin_2")
    local duration = self:GetSpecialValueFor("duration")
    local enemies = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    caster:AddNewModifier( caster, self, "modifier_azazin_agressive", { duration = duration } )

    for _,enemy in pairs(enemies) do
        if not enemy:IsDuel() then
            enemy:AddNewModifier( caster, self, "modifier_azazin_agressive_debuff", { duration = duration } )
        end
    end

    self:GetCaster():EmitSound("Hero_Axe.Berserkers_Call")
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( particle )
end

modifier_azazin_agressive = class({})

function modifier_azazin_agressive:IsHidden()
    return false
end

function modifier_azazin_agressive:IsPurgable()
    return true
end

function modifier_azazin_agressive:GetEffectName()
    return "particles/units/heroes/hero_axe/axe_beserkers_call.vpcf"
end

function modifier_azazin_agressive:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_azazin_agressive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_azazin_agressive:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end

modifier_azazin_agressive_debuff = class({})

function modifier_azazin_agressive_debuff:IsHidden()
    return false
end

function modifier_azazin_agressive_debuff:IsPurgable()
    return false
end

function modifier_azazin_agressive_debuff:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetCaster() )
    self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    self:StartIntervalThink(FrameTime())
end

function modifier_azazin_agressive_debuff:OnIntervalThink( kv )
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_fountain_passive_invul") or (not self:GetCaster():IsAlive()) then
        self:Destroy()
    end
end

function modifier_azazin_agressive_debuff:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( nil )
end

function modifier_azazin_agressive_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
    }

    return state
end

function modifier_azazin_agressive_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

LinkLuaModifier( "modifier_azazin_spinner", "abilities/heroes/azazin.lua", LUA_MODIFIER_MOTION_NONE )

Azazin_Spinner = class({})

function Azazin_Spinner:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Azazin_Spinner:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Azazin_Spinner:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Azazin_Spinner:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_azazin_4")
    caster:EmitSound("azazin")
    caster:AddNewModifier( caster, self, "modifier_azazin_spinner", { duration = duration } )
end

modifier_azazin_spinner = class({})

function modifier_azazin_spinner:IsHidden()
    return false
end

function modifier_azazin_spinner:IsPurgable()
    return false
end

function modifier_azazin_spinner:OnCreated( kv )
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_azazin_3")
    local radius = self:GetAbility():GetSpecialValueFor("spinner_radius")
    local spinner_damage_tick = self:GetAbility():GetSpecialValueFor("spinner_damage_tick")
    damage = damage * spinner_damage_tick
    self.damageTable = {
        attacker = self:GetParent(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    local particle = ParticleManager:CreateParticle( "particles/blue_fury/juggernaut_blade_fury.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 5, Vector( radius, 0, 0 ) )
    self:AddParticle( particle, false, false, -1, false, false )
    self:StartIntervalThink(spinner_damage_tick)
end

function modifier_azazin_spinner:OnDestroy( kv )
    StopSoundOn( "azazin", self:GetParent() )
end

function modifier_azazin_spinner:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("spinner_radius")
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
    for _,enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        ApplyDamage( self.damageTable )
        local particle = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
        ParticleManager:SetParticleControl( particle, 0, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 1, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 2, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 3, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 4, enemy:GetAbsOrigin() )
        ParticleManager:SetParticleControl( particle, 5, enemy:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( particle )
    end
end

function modifier_azazin_spinner:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end


