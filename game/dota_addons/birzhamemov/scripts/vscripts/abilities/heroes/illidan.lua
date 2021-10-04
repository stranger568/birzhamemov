LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Illidan_ChaseTheDevil_debuff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Illidan_ChaseTheDevil_buff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Illidan_ChaseTheDevil = class({})

function Illidan_ChaseTheDevil:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Illidan_ChaseTheDevil:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Illidan_ChaseTheDevil:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Illidan_ChaseTheDevil:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
    target:EmitSound("Hero_LifeStealer.OpenWounds")
    target:AddNewModifier(caster, self, "modifier_Illidan_ChaseTheDevil_debuff", { duration = duration * (1 - target:GetStatusResistance()) } )
    caster:AddNewModifier(caster, self, "modifier_Illidan_ChaseTheDevil_buff", { duration = duration } )
end

modifier_Illidan_ChaseTheDevil_debuff = class({})

function modifier_Illidan_ChaseTheDevil_debuff:IsPurgable()
    return false
end

function modifier_Illidan_ChaseTheDevil_debuff:IsPurgeException()
    return true
end

function modifier_Illidan_ChaseTheDevil_debuff:OnCreated( kv )
    if not IsServer() then return end
    self.step = 1
    self:StartIntervalThink( 1 )
end

function modifier_Illidan_ChaseTheDevil_debuff:OnRefresh( kv )
    if not IsServer() then return end
    self.step = 1
end

function modifier_Illidan_ChaseTheDevil_debuff:OnIntervalThink()
    if not IsServer() then return end
    self.step = self.step + 1
end

function modifier_Illidan_ChaseTheDevil_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACKED,
    }

    return funcs
end

function modifier_Illidan_ChaseTheDevil_debuff:GetModifierMoveSpeedBonus_Percentage()
    if not IsServer() then return end
    return self:GetAbility():GetLevelSpecialValueFor( "move_slow", self.step )
end

function modifier_Illidan_ChaseTheDevil_debuff:GetModifierBaseDamageOutgoing_Percentage()
    return -self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_Illidan_ChaseTheDevil_debuff:OnAttacked( params )
    if IsServer() then
        if params.target~=self:GetParent() then return end
        if params.attacker:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then return end
        local heal = self:GetAbility():GetSpecialValueFor( "heal_percent" ) / 100
        params.attacker:Heal( heal * params.damage, self:GetAbility() )
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_Illidan_ChaseTheDevil_debuff:GetEffectName()
    return "particles/ilidan/life_stealer_open_wounds.vpcf"
end

function modifier_Illidan_ChaseTheDevil_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_Illidan_ChaseTheDevil_buff = class({})

function modifier_Illidan_ChaseTheDevil_buff:IsPurgable()
    return false
end

function modifier_Illidan_ChaseTheDevil_buff:IsPurgeException()
    return true
end

function modifier_Illidan_ChaseTheDevil_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }

    return funcs
end

function modifier_Illidan_ChaseTheDevil_buff:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

LinkLuaModifier("modifier_illidan_pepper", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

Illidan_DrinkSomePepper = class({})

function Illidan_DrinkSomePepper:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Illidan_DrinkSomePepper:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_3")
    local heal = self:GetSpecialValueFor("regen")
    caster:EmitSound("Hero_Terrorblade.Metamorphosis")
    caster:Heal( heal, self )
    caster:AddNewModifier(caster, self, "modifier_illidan_pepper", { duration = duration } )
end

modifier_illidan_pepper = class({})

function modifier_illidan_pepper:IsPurgable()
    return true
end

function modifier_illidan_pepper:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_illidan_pepper:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_illidan_pepper:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_illidan_pepper:GetEffectName()
    return "particles/illidan/illidan_pepper_buff.vpcf"
end

function modifier_illidan_pepper:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_illidan_pepper:GetStatusEffectName()
    return "particles/illidan/pepper_effect.vpcf" 
end

function modifier_illidan_pepper:StatusEffectPriority()
    return 5
end

LinkLuaModifier("modifier_illidan_KidsHit", "abilities/heroes/illidan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_illidan_KidsHit_debuff", "abilities/heroes/illidan.lua", LUA_MODIFIER_MOTION_NONE)

Illidan_KidsHit = class({})

function Illidan_KidsHit:GetIntrinsicModifierName()
    return "modifier_illidan_KidsHit"
end

modifier_illidan_KidsHit = class({})

function modifier_illidan_KidsHit:IsPurgable() return false end
function modifier_illidan_KidsHit:IsHidden() return true end

function modifier_illidan_KidsHit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_illidan_KidsHit:OnAttackStart(keys)
    if keys.attacker == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if keys.target:IsOther() then
            return nil
        end
        self.critProc = false
        self.chance = self:GetAbility():GetSpecialValueFor("chance")
        self.crit = self:GetAbility():GetSpecialValueFor("crit")
        self.duration = self:GetAbility():GetSpecialValueFor("duration")
        if self.chance >= RandomInt(1, 100) then
            self:GetParent():StartGesture(ACT_DOTA_ATTACK_EVENT_BASH)
            self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Impact.Immortal")
            local crit_pfx = ParticleManager:CreateParticle("particles/guts/skeleton_king_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_pfx)
            self.critProc = true
            return self.crit
        end 
    end
end

function modifier_illidan_KidsHit:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    if self.critProc == true then
        return self.crit
    else
        return nil
    end
end

function modifier_illidan_KidsHit:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self.critProc == true then
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_illidan_KidsHit_debuff", {duration = self.duration * (1 - params.target:GetStatusResistance())})
            self.critProc = false
        end
    end
end

modifier_illidan_KidsHit_debuff = class({})

function modifier_illidan_KidsHit_debuff:IsPurgable() return false end
function modifier_illidan_KidsHit_debuff:IsPurgeException() return true end

function modifier_illidan_KidsHit_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

LinkLuaModifier("modifier_illidan_Brutality_buff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

Illidan_Brutality = class({})

function Illidan_Brutality:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Illidan_Brutality:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Illidan_Brutality:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_1")
    caster:EmitSound("ilidanultimate")
    caster:AddNewModifier(caster, self, "modifier_illidan_Brutality_buff", { duration = duration } )
end

modifier_illidan_Brutality_buff = class({})

function modifier_illidan_Brutality_buff:IsPurgable()
    return false
end

function modifier_illidan_Brutality_buff:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/ilidan/warlock_shadow_word_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 2, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_illidan_Brutality_buff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("ilidanultimate")
end

function modifier_illidan_Brutality_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_illidan_Brutality_buff:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
        if params.target:IsOther() then
            return nil
        end
        local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_2")
        local duration = self:GetAbility():GetSpecialValueFor("stun")
        if chance >= RandomInt(1, 100) then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_bashed", {duration = duration})
        end 
    end
end

function modifier_illidan_Brutality_buff:GetModifierModelChange()
    return "models/heroes/terrorblade/demon.vmdl"
end

function modifier_illidan_Brutality_buff:GetStatusEffectName()
    return "particles/illidan/illidan_ozverenie_buff.vpcf" 
end

function modifier_illidan_Brutality_buff:StatusEffectPriority()
    return 10
end

function modifier_illidan_Brutality_buff:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }

    return state
end

