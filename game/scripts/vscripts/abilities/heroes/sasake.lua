LinkLuaModifier("modifier_sasake_gem_aura", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

sasake_one_ability = class({})

function sasake_one_ability:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_4")
    self:GetCaster():EmitSound("DOTA_Item.DustOfAppearance.Activate")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sasake_gem_aura", {duration = duration})
end

modifier_sasake_gem_aura = class({})

function modifier_sasake_gem_aura:IsAura()
    return true
end

function modifier_sasake_gem_aura:IsHidden()
    return false
end

function modifier_sasake_gem_aura:IsPurgable()
    return false
end

function modifier_sasake_gem_aura:GetAuraDuration()
    return 0
end

function modifier_sasake_gem_aura:IsAuraActiveOnDeath() return false end

function modifier_sasake_gem_aura:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.pfx = ParticleManager:CreateParticleForTeam("particles/sasake_gem_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetTeam())
    ParticleManager:SetParticleControl(self.pfx, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.pfx, 2, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(self.pfx, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.pfx, false, false, -1, false, false)
end

function modifier_sasake_gem_aura:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
    return decFuncs
end

function modifier_sasake_gem_aura:GetAuraRadius()
    return self.radius
end

function modifier_sasake_gem_aura:GetModifierStatusResistanceStacking()
    return self:GetAbility():GetSpecialValueFor( "effect_resistance" )
end

function modifier_sasake_gem_aura:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_sasake_gem_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_sasake_gem_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_sasake_gem_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

LinkLuaModifier("modifier_sasake_invis", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasake_invis_talent", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasake_invis_magic_immune", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasake_invis_debuff_slow", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasake_invis_debuff", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)

sasake_two_ability = class({})

function sasake_two_ability:GetIntrinsicModifierName()
    return "modifier_sasake_invis_talent"
end

function sasake_two_ability:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local bkb_duration = self:GetSpecialValueFor("bkb_duration")
    local particle = ParticleManager:CreateParticle("particles/econ/taunts/void_spirit/void_spirit_taunt_dust_impact.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sasake_invis_magic_immune", {duration = bkb_duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sasake_invis", {duration = duration})
    self:GetCaster():EmitSound("DOTA_Item.InvisibilitySword.Activate")
end

modifier_sasake_invis_talent = class ({})

function modifier_sasake_invis_talent:IsPurgable() return false end
function modifier_sasake_invis_talent:IsHidden() return true end

function modifier_sasake_invis_talent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_HERO_KILLED
    }
    return funcs
end

function modifier_sasake_invis_talent:OnHeroKilled()
    if not IsServer() then return end
    if self:GetCaster():HasScepter() then
        self:GetAbility():EndCooldown()
    end
end

modifier_sasake_invis = class({})

function modifier_sasake_invis:IsPurgable()
    return false
end

function modifier_sasake_invis:IsHidden()
    return false
end

function modifier_sasake_invis:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED 
    }
    return decFuncs
end

function modifier_sasake_invis:GetModifierInvisibilityLevel()
    return 1
end

function modifier_sasake_invis:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_sasake_invis:OnAttack( params )
    if not IsServer() then return end
    if params.attacker~=self:GetParent() then return end
    params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_sasake_invis_debuff_slow", {duration = self:GetAbility():GetSpecialValueFor("movespeed_slow_duration") * (1 - params.target:GetStatusResistance())})
    if self:GetCaster():HasTalent("special_bonus_birzha_sasake_6") then
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_sasake_invis_debuff", {duration = self:GetAbility():GetSpecialValueFor("movespeed_slow_duration") * (1 - params.target:GetStatusResistance())})
    end
    self:Destroy()
end

function modifier_sasake_invis:OnAbilityExecuted(keys)
    if IsServer() then
        local ability = keys.ability
        local caster = keys.unit
        if caster == self:GetParent() then
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_sasake_invis:CheckState()
    return 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_sasake_invis:OnDestroy()
    if not IsServer() then return end
    local bkb_duration = self:GetAbility():GetSpecialValueFor("bkb_duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sasake_invis_magic_immune", {duration = bkb_duration})
end

modifier_sasake_invis_magic_immune = class({})

function modifier_sasake_invis_magic_immune:IsPurgable() return false end

function modifier_sasake_invis_magic_immune:CheckState()
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
end

function modifier_sasake_invis_magic_immune:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_sasake_invis_magic_immune:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sasake_invis_magic_immune:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_sasake_invis_magic_immune:StatusEffectPriority()
    return 99999
end

modifier_sasake_invis_debuff_slow = class({})

function modifier_sasake_invis_debuff_slow:IsPurgable() return true end

function modifier_sasake_invis_debuff_slow:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_sasake_invis_debuff_slow:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return decFuncs
end

function modifier_sasake_invis_debuff_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_sasake_invis_debuff_slow:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_2")
end

function modifier_sasake_invis_debuff_slow:GetEffectName()
    return "particles/econ/courier/courier_greevil_red/courier_greevil_red_ambient_1.vpcf"
end

function modifier_sasake_invis_debuff_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_sasake_invis_debuff = class({})

function modifier_sasake_invis_debuff:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return decFuncs
end

function modifier_sasake_invis_debuff:GetModifierPhysicalArmorBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_6")
end

function modifier_sasake_invis_debuff:CheckState()
    return 
    {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
end

LinkLuaModifier("modifier_sasake_agility_bonus", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasake_agility_bonus_talent", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)

sasake_three_ability = class({})

function sasake_three_ability:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("Hero_Warlock.ShadowWordCastBad")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sasake_agility_bonus", {duration = duration})
end

function sasake_three_ability:GetIntrinsicModifierName()
    return "modifier_sasake_agility_bonus_talent"
end

modifier_sasake_agility_bonus = class({})

function modifier_sasake_agility_bonus:IsPurgable()
    return false
end

function modifier_sasake_agility_bonus:GetEffectName()
    return "particles/sasake_agi_effect.vpcf"
end

function modifier_sasake_agility_bonus:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_EVENT_ON_HERO_KILLED
    }

    return decFuncs
end

function modifier_sasake_agility_bonus:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility") + self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_5")
end

modifier_sasake_agility_bonus_talent = class ({})

function modifier_sasake_agility_bonus_talent:IsPurgable() return false end
function modifier_sasake_agility_bonus_talent:IsHidden() return true end

function modifier_sasake_agility_bonus_talent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_sasake_agility_bonus_talent:GetModifierAvoidDamage(keys)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_sasake_8") then return end
    if RollPercentage(self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_8")) then
        return 1
    else
        return 0
    end
end

LinkLuaModifier("modifier_sasake_ultimate_attack", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasake_ultimate_scepter", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)

sasake_four_ability = class({})

function sasake_four_ability:GetCastRange(location, target)
    return self:GetCaster():Script_GetAttackRange()
end

function sasake_four_ability:GetIntrinsicModifierName()
    return "modifier_sasake_ultimate_scepter"
end

function sasake_four_ability:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    self:GetCaster():EmitSound("sasake_ultimate")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sasake_ultimate_attack", {target = target:entindex()})
end

modifier_sasake_ultimate_attack = class({})

function modifier_sasake_ultimate_attack:IsPurgable()
    return false
end

function modifier_sasake_ultimate_attack:IsHidden()
    return true
end

function modifier_sasake_ultimate_attack:OnCreated(table)
    if not IsServer() then return end
    self.attack = 0
    self.target = EntIndexToHScript(table.target)
    self.crit_one = self:GetAbility():GetSpecialValueFor("crit_one") + self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_7")
    self.crit_two = self:GetAbility():GetSpecialValueFor("crit_two") + self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_7")
    self.crit_three = self:GetAbility():GetSpecialValueFor("crit_three") + self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_7")
    self:CritAttack()
end

function modifier_sasake_ultimate_attack:CritAttack()
    if not IsServer() then return end
    if self.attack >= 3 then self:SetDuration(0.15, true) return end
    Timers:CreateTimer(0.15, function()
        if self:IsNull() then return end
        if not self.target:IsAlive() then
            if not self:IsNull() then
                self:Destroy()
                return
            end
        end
        self:GetCaster():SetForwardVector((self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized())
        self.attack = self.attack + 1
        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 5)
        self:GetCaster():PerformAttack( self.target, false, true, true, false, false, false, true )
        self:CritAttack()
    end)
end

function modifier_sasake_ultimate_attack:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_sasake_ultimate_attack:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_sasake_ultimate_attack:GetModifierPreAttack_CriticalStrike(params)
    if self.attack == 1 then
        return self.crit_one
    elseif self.attack == 2 then
        return self.crit_two
    elseif self.attack == 3 then
        local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_1")
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
        return self.crit_three
    end
end

modifier_sasake_ultimate_scepter = class({})

function modifier_sasake_ultimate_scepter:IsHidden() return true end

function modifier_sasake_ultimate_scepter:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return decFuncs
end

function modifier_sasake_ultimate_scepter:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if not self:GetCaster():HasShard() then return end

    local cd = self:GetAbility():GetCooldownTimeRemaining()

    if self:GetAbility():GetCooldownTimeRemaining() > 0 then
        if cd > 2 then
            self:GetAbility():EndCooldown()
            self:GetAbility():StartCooldown(cd-self:GetAbility():GetSpecialValueFor("scepter_cooldown"))
        else
            self:GetAbility():EndCooldown()
        end
    end
end

LinkLuaModifier("modifier_sasake_talent_ability", "abilities/heroes/sasake.lua", LUA_MODIFIER_MOTION_NONE)

sasake_talent_ability = class({})

function sasake_talent_ability:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_sasake_3") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function sasake_talent_ability:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function sasake_talent_ability:GetIntrinsicModifierName()
    return "modifier_sasake_talent_ability"
end

modifier_sasake_talent_ability = class({})

function modifier_sasake_talent_ability:IsPurgable() return false end

function modifier_sasake_talent_ability:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }

    return funcs
end

function modifier_sasake_talent_ability:GetModifierPreAttack_BonusDamage(params)
    return self:GetParent():GetAgility() * (self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_3") / 100)
end

function modifier_sasake_talent_ability:OnTooltip()
    return self:GetParent():GetAgility() * (self:GetCaster():FindTalentValue("special_bonus_birzha_sasake_3") / 100)
end