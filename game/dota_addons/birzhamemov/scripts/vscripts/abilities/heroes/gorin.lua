LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )

Gorin_TwinBrother = class({})

function Gorin_TwinBrother:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gorin_TwinBrother:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gorin_TwinBrother:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("illusion_duration")
    local damage_in = self:GetSpecialValueFor("illusion_incoming_damage")
    local damage_out = self:GetSpecialValueFor("illusion_outgoing_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_3")
    self:GetCaster():EmitSound("gitelmanbrat")
    local illusion = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=damage_out,incoming_damage=damage_in}, 1, 1, true, true ) 
end

  
Gorin_Resourcefulness = class({})

LinkLuaModifier( "modifier_gorin_resourcefulness", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_gorin_resourcefulness_stack", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)

function Gorin_Resourcefulness:GetIntrinsicModifierName()
    return "modifier_gorin_resourcefulness"
end

modifier_gorin_resourcefulness = class({})

function modifier_gorin_resourcefulness:IsHidden()
    return true
end

function modifier_gorin_resourcefulness:IsPurgable()
    return false
end

function modifier_gorin_resourcefulness:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_gorin_resourcefulness:GetModifierProcAttack_BonusDamage_Physical( params )
    if IsServer() then
        local target = params.target if target==nil then target = params.unit end
        if target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
            return 0
        end
        if target:IsOther() then
            return nil
        end
        if target:IsBoss() then return end
        local stack = 0
        local modifier = target:FindModifierByName("modifier_gorin_resourcefulness_stack")
        if modifier==nil then
            if self:GetParent():PassivesDisabled() then return end
            local _duration = self:GetAbility():GetSpecialValueFor("duration")
            target:AddNewModifier(
                self:GetAbility():GetCaster(),
                self:GetAbility(),
                "modifier_gorin_resourcefulness_stack",
                { duration = _duration }
            )
            stack = 1
        else
            modifier:IncrementStackCount()
            modifier:ForceRefresh()
            stack = modifier:GetStackCount()
        end
        return stack * self:GetAbility():GetSpecialValueFor("damage_per_stack")
    end
end

modifier_gorin_resourcefulness_stack = class({})

function modifier_gorin_resourcefulness_stack:IsPurgable()
    return false
end

function modifier_gorin_resourcefulness_stack:OnCreated( kv )
    self:SetStackCount(1)
end

function modifier_gorin_resourcefulness_stack:GetEffectName()
    return "particles/gorin/resor_debuff.vpcf"
end

function modifier_gorin_resourcefulness_stack:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier( "modifier_gorin_rabies_primary", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE )

Gorin_rabies = class({})

function Gorin_rabies:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gorin_rabies:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_1")
end

function Gorin_rabies:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gorin_rabies:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_2")
end

function Gorin_rabies:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_1")
    self.channel_start_time = GameRules:GetGameTime()
    caster:AddNewModifier(caster, self, "modifier_gorin_rabies_primary", {})
    EmitSoundOnLocationWithCaster(origin, "gorinult", caster)
    EmitSoundOn("Hero_Riki.TricksOfTheTrade", caster)
    local caster_loc = caster:GetAbsOrigin()
    self.TricksParticle = ParticleManager:CreateParticle("particles/gorin/gorin_rabits.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_cast.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.TricksParticle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.TricksParticle, 1, Vector(radius, 0, radius))
    ParticleManager:SetParticleControl(self.TricksParticle, 2, Vector(radius, 0, radius))
    caster:AddNoDraw()
end

function Gorin_rabies:OnChannelFinish()
    if not IsServer() then return end
    local caster = self:GetCaster()
    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
    caster:RemoveModifierByName("modifier_gorin_rabies_primary")
    StopSoundEvent("gorinult", caster)
    ParticleManager:DestroyParticle(self.TricksParticle, false)
    ParticleManager:ReleaseParticleIndex(self.TricksParticle)
    self.TricksParticle = nil
    caster:RemoveNoDraw()
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_riki/riki_tricks_end.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_gorin_rabies_primary = class({})

function modifier_gorin_rabies_primary:IsPurgable() return false end

function modifier_gorin_rabies_primary:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, }
    return funcs
end

function modifier_gorin_rabies_primary:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_1")
end

function modifier_gorin_rabies_primary:CheckState()
    local state = {   [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_OUT_OF_GAME] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
    return state
end

function modifier_gorin_rabies_primary:OnCreated()
    if IsServer() then
        local attack_per_second = self:GetParent():GetAttackSpeed() / self:GetParent():GetBaseAttackTime()
        local interval = 1 / attack_per_second
        print(interval)
        self:StartIntervalThink(interval)
    end
end

function modifier_gorin_rabies_primary:OnIntervalThink()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()
        local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_1")
        local targets = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER , false)
        for _,unit in pairs(targets) do
            if unit:IsAlive() and not unit:IsAttackImmune() and self:GetCaster():CanEntityBeSeenByMyTeam(unit) then
                caster:PerformAttack(unit, true, true, true, false, false, false, false)
            end
        end
    end
end





