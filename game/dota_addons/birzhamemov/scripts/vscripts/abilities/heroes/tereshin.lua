LinkLuaModifier( "modifier_kirill_GiantArms", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Kirill_GiantArms = class({})

function Kirill_GiantArms:GetIntrinsicModifierName()
    return "modifier_kirill_GiantArms"
end

modifier_kirill_GiantArms = class({})

function modifier_kirill_GiantArms:IsHidden()
    return true
end

function modifier_kirill_GiantArms:IsPurgable() return false end

function modifier_kirill_GiantArms:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return decFuncs
end

function modifier_kirill_GiantArms:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():PassivesDisabled() then return end
        local cleave = self:GetAbility():GetSpecialValueFor("cleave") / 100
        DoCleaveAttack( params.attacker, target, self:GetAbility(), (params.damage * cleave), 600, 600, 600, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf" )  
    end
end

Kirill_ShakeTheGround = class({})

function Kirill_ShakeTheGround:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kirill_ShakeTheGround:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kirill_ShakeTheGround:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Kirill_ShakeTheGround:OnSpellStart()
    local caster = self:GetCaster()
    local fissure_range = self:GetSpecialValueFor("fissure_range")
    local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_2")
    local damage = self:GetSpecialValueFor("damage")
    local multi = self:GetSpecialValueFor("str_multi") + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_1")
    local direction = caster:GetForwardVector()
    local startPos = caster:GetAbsOrigin() + direction * 96
    local endPos = caster:GetAbsOrigin() + direction * fissure_range
    if not IsServer() then return end
    caster:EmitSound("Hero_EarthShaker.Fissure")
    self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_fissure_egset.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(self.particle, 0, startPos)
    ParticleManager:SetParticleControl(self.particle, 1, endPos)
    ParticleManager:SetParticleControl(self.particle, 2, Vector(1, 0, 0 ))  

    local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, 225, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
    
    for _,unit in ipairs(units) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
        ApplyDamage({ victim = unit, attacker = caster, damage = damage + (caster:GetStrength() * multi), damage_type = DAMAGE_TYPE_PHYSICAL})
    end 
end

LinkLuaModifier( "modifier_kirill_InjectSynthol", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )

Kirill_InjectSynthol = class({})

function Kirill_InjectSynthol:OnToggle()
    local caster = self:GetCaster()
    self.modifier = caster:FindModifierByName( "modifier_kirill_InjectSynthol" )

    if self:GetToggleState() then
        if not self.modifier then
            caster:AddNewModifier( caster, self, "modifier_kirill_InjectSynthol", {} )
        end
    else
        if self.modifier then
            self.modifier:Destroy()
        end
    end
end

function Kirill_InjectSynthol:OnUpgrade()
    self.modifier = self:GetCaster():FindModifierByName( "modifier_kirill_InjectSynthol" )
    if self.modifier then
        self.modifier:ForceRefresh()
    end
end

modifier_kirill_InjectSynthol = class({})

function modifier_kirill_InjectSynthol:IsPurgable()
    return false
end

function modifier_kirill_InjectSynthol:GetEffectName()
    return "particles/tereshin/synthol.vpcf"
end

function modifier_kirill_InjectSynthol:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kirill_InjectSynthol:OnCreated( kv )
    self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_3")
    self.minus_regen = self:GetAbility():GetSpecialValueFor( "reg" )
    self:StartIntervalThink(1)
end

function modifier_kirill_InjectSynthol:OnRefresh( kv )
    self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_3")
    self.minus_regen = self:GetAbility():GetSpecialValueFor( "reg" )
end

function modifier_kirill_InjectSynthol:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return funcs
end

function modifier_kirill_InjectSynthol:GetModifierBonusStats_Strength()
    return self.bonus_strength
end

function modifier_kirill_InjectSynthol:OnIntervalThink()
    if not IsServer() then return end
    local health = self:GetCaster():GetMaxHealth() / 100 * self.minus_regen
    local mana = self:GetCaster():GetMaxMana() / 100 * self.minus_regen
    if self:GetCaster():HasTalent("special_bonus_birzha_tereshin_4") then
        if self:GetCaster():GetMana() > mana then 
            self:GetCaster():ReduceMana( mana )
            return
        end 
    end


    local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = health,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }
    ApplyDamage(damageTable)
end

LinkLuaModifier( "modifier_kirill_SpecialDobbleHit", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kirill_SpecialDobbleHit_haste", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )

Kirill_SpecialDobbleHit = class({})

function Kirill_SpecialDobbleHit:GetIntrinsicModifierName()
    return "modifier_kirill_SpecialDobbleHit"
end

modifier_kirill_SpecialDobbleHit = class({})

function modifier_kirill_SpecialDobbleHit:IsHidden()
    return true
end

function modifier_kirill_SpecialDobbleHit:IsPurgable() return false end

function modifier_kirill_SpecialDobbleHit:DeclareFunctions()
    local decFuns =
        {
            MODIFIER_EVENT_ON_ATTACK
        }
    return decFuns
end

function modifier_kirill_SpecialDobbleHit:OnAttack(keys)
    local parent = self:GetParent()
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    if keys.attacker == parent then
        if parent:PassivesDisabled() then return end
        if RandomInt(1, 100) <= self.chance then 
            parent:AddNewModifier(parent, item, "modifier_kirill_SpecialDobbleHit_haste", {duration=2})
            parent:EmitSound("sintol4")
        end
    end
end

modifier_kirill_SpecialDobbleHit_haste = class({})

function modifier_kirill_SpecialDobbleHit_haste:IsHidden()
    return true
end

function modifier_kirill_SpecialDobbleHit_haste:IsPurgable() return false end

function modifier_kirill_SpecialDobbleHit_haste:DeclareFunctions()
    local decFuns =
        {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_EVENT_ON_ATTACK
        }
    return decFuns
end

function modifier_kirill_SpecialDobbleHit_haste:GetModifierAttackSpeedBonus_Constant()
    return 1000
end

function modifier_kirill_SpecialDobbleHit_haste:OnAttack(keys)
    local parent = self:GetParent()
    if keys.attacker == parent then
        self:Destroy()
    end
end
