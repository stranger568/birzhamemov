LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Ricardo_Zhopa = class({})

function Ricardo_Zhopa:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ricardo_Zhopa:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Ricardo_Zhopa:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ricardo_Zhopa:OnSpellStart()
    if not IsServer() then return end

    local base_damage = self:GetSpecialValueFor("base_damage")
    local damage_unit = self:GetSpecialValueFor("damage_unit") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_2")
    local radius = self:GetSpecialValueFor("radius")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    local damage = (#targets * damage_unit) + base_damage
        
    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})  
        local particle = ParticleManager:CreateParticle("particles/ricardo/ricardo_zhopa_effect.vpcf", PATTACH_POINT_FOLLOW, unit)
        ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, Vector(400,0,0))
        ParticleManager:ReleaseParticleIndex(particle)
        EmitGlobalSound( "Hero_ObsidianDestroyer.SanityEclipse.Cast" )
    end
end

LinkLuaModifier("modifier_Ricardo_shel", "abilities/heroes/ricardo", LUA_MODIFIER_MOTION_NONE)

Ricardo_shel = class({})

function Ricardo_shel:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Ricardo_shel:GetIntrinsicModifierName()
    return "modifier_Ricardo_shel"
end

modifier_Ricardo_shel = class({})

function modifier_Ricardo_shel:IsPurgable()
    return false
end

function modifier_Ricardo_shel:IsHidden()
    return true
end

function modifier_Ricardo_shel:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
    return funcs
end

function modifier_Ricardo_shel:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:IsToggle() or hAbility:IsItem() then
            return 0
        end

        if self:GetParent():PassivesDisabled() then return end

        local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_3")
        local damage = self:GetAbility():GetSpecialValueFor("damage")
        local radius = self:GetAbility():GetSpecialValueFor("radius")   

        local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #enemies > 0 then
            for _,enemy in pairs( enemies ) do
                enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration * (1-enemy:GetStatusResistance())})
                ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability=self:GetAbility()})
                enemy:EmitSound("Hero_Batrider.Projection")
            end
        end
    end
end 

LinkLuaModifier("modifier_Ricardo_KokosMaslo_debuff", "abilities/heroes/ricardo", LUA_MODIFIER_MOTION_NONE)

Ricardo_KokosMaslo = class({})

function Ricardo_KokosMaslo:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ricardo_KokosMaslo:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ricardo_KokosMaslo:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ricardo_KokosMaslo:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Ricardo_KokosMaslo:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local particle = ParticleManager:CreateParticle( "particles/ricardo/ricardo_maslo_kokosa.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, point )
    ParticleManager:SetParticleControl( particle, 1, Vector( 150, 150, 150 ) )
    ParticleManager:SetParticleControlEnt( particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle )

    self:GetCaster():EmitSound("Hero_Phoenix.FireSpirits.Target")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    for _,unit in pairs(targets) do
        if unit:HasModifier("modifier_Ricardo_KokosMaslo_debuff") then
            local modif = unit:FindModifierByName("modifier_Ricardo_KokosMaslo_debuff")
            unit:AddNewModifier( self:GetCaster(), self, "modifier_Ricardo_KokosMaslo_debuff", {duration = duration})
            unit:SetModifierStackCount("modifier_Ricardo_KokosMaslo_debuff", self, modif:GetStackCount() + 1)
        else
            unit:AddNewModifier( self:GetCaster(), self, "modifier_Ricardo_KokosMaslo_debuff", {duration = duration})
            unit:SetModifierStackCount("modifier_Ricardo_KokosMaslo_debuff", self, 1)
        end
    end
end

modifier_Ricardo_KokosMaslo_debuff = class({})

function modifier_Ricardo_KokosMaslo_debuff:IsPurgable()
    return false
end

function modifier_Ricardo_KokosMaslo_debuff:OnCreated()
    if not IsServer() then return end
    self.non_trigger_inflictors = 
    {
        ["Ricardo_KokosMaslo"] = true,
        ["Panasenkov_rakom"] = true,
        ["item_radiance"]          = true,
        ["item_radiance_2"]          = true,
        ["item_urn_of_shadows"]    = true,
        ["item_spirit_vessel"]     = true,
    }
end

function modifier_Ricardo_KokosMaslo_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_Ricardo_KokosMaslo_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow") * self:GetStackCount()
end

function modifier_Ricardo_KokosMaslo_debuff:GetModifierMagicalResistanceBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_6") * self:GetStackCount()
end

function modifier_Ricardo_KokosMaslo_debuff:GetEffectName()
    return "particles/ricardo/ricardo_maslo_kokosa_debuff.vpcf"
end

function modifier_Ricardo_KokosMaslo_debuff:GetStatusEffectName()
    return "particles/ricardo/status_effect_ricardo.vpcf"
end

function modifier_Ricardo_KokosMaslo_debuff:StatusEffectPriority()
    return 15
end

function modifier_Ricardo_KokosMaslo_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Ricardo_KokosMaslo_debuff:OnTakeDamage(keys)
    if keys.attacker == self:GetCaster() and keys.unit == self:GetParent() and (not keys.inflictor or not self.non_trigger_inflictors[keys.inflictor:GetName()]) then
        local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_7")
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * self:GetStackCount(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()}) 
    end
end

LinkLuaModifier("modifier_Rikardo_Fire", "abilities/heroes/ricardo.lua", LUA_MODIFIER_MOTION_NONE)

Rikardo_Fire = class({})

function Rikardo_Fire:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_1")
end

function Rikardo_Fire:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_Rikardo_Fire"
end

modifier_Rikardo_Fire = class({})

function modifier_Rikardo_Fire:IsHidden()
    return true
end

function modifier_Rikardo_Fire:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor("interval")
    self:StartIntervalThink(interval)
end

function modifier_Rikardo_Fire:OnRefresh()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor("interval")
    self:StartIntervalThink(interval)
end

function modifier_Rikardo_Fire:GetEffectName()
    return "particles/ricardo_fire.vpcf"
end

function modifier_Rikardo_Fire:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Rikardo_Fire:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_1")
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    if not self:GetParent():IsAlive() then return end
    for _,unit in pairs(targets) do
        local damage_type = DAMAGE_TYPE_MAGICAL
        if self:GetCaster():HasShard() then
            damage_type = DAMAGE_TYPE_PURE
        end 
        local damage = self:GetAbility():GetSpecialValueFor("damage")   
        if self:GetCaster():HasTalent("special_bonus_birzha_ricardo_5") then
            print("wtf")
            damage = unit:GetMaxHealth() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_5")
        end
        print("damage", damage)
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage * self:GetAbility():GetSpecialValueFor("interval"), damage_type = damage_type, ability = self:GetAbility()})
    end
end

LinkLuaModifier("modifier_Ricardo_Golosovanie", "abilities/heroes/ricardo.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Ricardo_Golosovanie_bonus_amplify", "abilities/heroes/ricardo.lua", LUA_MODIFIER_MOTION_NONE)

Ricardo_Golosovanie = class({})

function Ricardo_Golosovanie:GetIntrinsicModifierName()
    return "modifier_Ricardo_Golosovanie_bonus_amplify"
end

function Ricardo_Golosovanie:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ricardo_Golosovanie:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_4")
end

function Ricardo_Golosovanie:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ricardo_Golosovanie:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Ricardo_Golosovanie", {duration = duration})
    self:GetCaster():EmitSound("ricardoultimate")
end

modifier_Ricardo_Golosovanie = class({})

function modifier_Ricardo_Golosovanie:IsPurgable()
    return false
end

function modifier_Ricardo_Golosovanie:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.25)
end

function modifier_Ricardo_Golosovanie:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("ricardoultimate")
end

function modifier_Ricardo_Golosovanie:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_8")
    local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_ricardo_4")
    local flag = DOTA_UNIT_TARGET_FLAG_NONE
    local damagetype = DAMAGE_TYPE_MAGICAL
    local angles = self:GetCaster():GetAngles()
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_3 )

    if self:GetCaster():HasScepter() then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        damagetype = DAMAGE_TYPE_PURE
    end

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag, FIND_ANY_ORDER, false)
    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = damagetype, ability = self:GetAbility()})
        if RandomInt(1, 2) == 1 then
            local nFXIndex = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_red_timedialate.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
            ParticleManager:SetParticleControl (nFXIndex, 0, Vector (0, 0, 0))
            ParticleManager:SetParticleControl (nFXIndex, 1, Vector (50, 50, 50))
            unit:EmitSound("Hero_FacelessVoid.TimeDilation.Cast.ti7_layer")
        elseif RandomInt(1, 2) == 2 then
            local nFXIndex = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_timedialate.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
            ParticleManager:SetParticleControl (nFXIndex, 0, Vector (0, 0, 0))
            ParticleManager:SetParticleControl (nFXIndex, 1, Vector (50, 50, 50))
            unit:EmitSound("Hero_FacelessVoid.TimeDilation.Cast.ti7_layer")
        end
    end
end

modifier_Ricardo_Golosovanie_bonus_amplify = class({})

function modifier_Ricardo_Golosovanie_bonus_amplify:IsHidden()
    return true
end

function modifier_Ricardo_Golosovanie_bonus_amplify:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_Ricardo_Golosovanie_bonus_amplify:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    self:SetStackCount(#targets)
end

function modifier_Ricardo_Golosovanie_bonus_amplify:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_Ricardo_Golosovanie_bonus_amplify:GetModifierSpellAmplify_Percentage()
    if not self:GetCaster():HasModifier("modifier_Ricardo_Golosovanie") then return end
    return self:GetAbility():GetSpecialValueFor("magic_damage") * self:GetStackCount()
end









