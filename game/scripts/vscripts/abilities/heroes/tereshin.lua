LinkLuaModifier( "modifier_kirill_GiantArms", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kirill_GiantArms_buff", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Kirill_GiantArms = class({})

function Kirill_GiantArms:Precache(context)
    local particle_list = 
    {
        "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf",
        "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf",
        "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf",
        "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_fissure_egset.vpcf",
        "particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf",
        "particles/tereshin/synthol.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Kirill_GiantArms:GetIntrinsicModifierName()
    return "modifier_kirill_GiantArms"
end

function Kirill_GiantArms:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
    if self:GetCaster():HasTalent("special_bonus_birzha_tereshin_5") then
        behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return behavior
end

function Kirill_GiantArms:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kirill_GiantArms_buff", {})
    self:GetCaster():EmitSound("tereshin_shard")
    self:GetCaster():EmitSound("tereshin_talent")
end

function Kirill_GiantArms:GetCooldown(iLevel)
    if self:GetCaster():HasTalent("special_bonus_birzha_tereshin_5") then
        return self:GetSpecialValueFor("talent_cooldown")
    end
end

modifier_kirill_GiantArms_buff = class({})

function modifier_kirill_GiantArms_buff:IsPurgable() return false end

function modifier_kirill_GiantArms_buff:OnCreated()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
    self:AddParticle( effect_cast, false, false, -1, false, false  )
end

function modifier_kirill_GiantArms_buff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_ATTACK_FINISHED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_CANCELLED
    }

    return decFuncs
end

function modifier_kirill_GiantArms_buff:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() and not target:IsWard() then
        self:Destroy() 
    end
end

function modifier_kirill_GiantArms_buff:GetActivityTranslationModifiers()
    return "punch"
end

function modifier_kirill_GiantArms_buff:GetModifierPreAttack_CriticalStrike()              
    return self:GetAbility():GetSpecialValueFor("critical_talent")
end

function modifier_kirill_GiantArms_buff:OnAttackStart(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() and not target:IsWard() then
        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, self:GetParent():GetAttackSpeed(true))
    end
end

function modifier_kirill_GiantArms_buff:OnAttackFinished(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() and not target:IsWard() then
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
    end
end

function modifier_kirill_GiantArms_buff:OnAttackCancelled(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() and not target:IsWard() then
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
    end
end

function modifier_kirill_GiantArms_buff:OnAttackFail(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() and not target:IsWard() then
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
    end
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

    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() and not target:IsWard() then
        if self:GetParent():PassivesDisabled() then return end

        local cleave = self:GetAbility():GetSpecialValueFor("cleave") + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_2")
        cleave = cleave / 100

        local particle = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf"

        if self:GetParent():HasModifier("modifier_kirill_GiantArms_buff") then
            particle = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf"
        end

        DoCleaveAttack( params.attacker, target, self:GetAbility(), (params.damage * cleave), self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), particle )  
    end
end

LinkLuaModifier( "modifier_Kirill_ShakeTheGround_thinker", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Kirill_ShakeTheGround_buff_scepter", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Kirill_ShakeTheGround_debuff", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )

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

function Kirill_ShakeTheGround:GetBehavior()
    if self:GetCaster():HasShard() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
end

function Kirill_ShakeTheGround:OnSpellStart()
    if not IsServer() then return end

    local fissure_range = self:GetSpecialValueFor("fissure_range")
    local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_1")
    local damage = self:GetSpecialValueFor("damage")
    local multi = self:GetSpecialValueFor("str_multi") + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_8")

    local direction = self:GetCaster():GetForwardVector()

    local startPos = self:GetCaster():GetAbsOrigin() + direction * 96

    local endPos = self:GetCaster():GetAbsOrigin() + direction * fissure_range

    if not IsServer() then return end

    self:GetCaster():EmitSound("Hero_EarthShaker.Fissure")

    local visual_duration = 1

    if self:GetCaster():HasScepter() then
        visual_duration = 5

        local block_width = 24
        local block_delta = 8.25

        local wall_vector = direction * (fissure_range - 150)

        local block_spacing = (block_delta+2*block_width)
        local blocks = fissure_range/block_spacing
        local block_pos = self:GetCaster():GetHullRadius() + block_delta + block_width
        local start_pos = self:GetCaster():GetOrigin() + direction*block_pos

        for i=1,blocks do
            local block_vec = self:GetCaster():GetOrigin() + direction*block_pos
            local blocker = CreateModifierThinker( self:GetCaster(), self, "modifier_Kirill_ShakeTheGround_thinker", { duration = self:GetSpecialValueFor("duration_scepter_fissure") }, block_vec, self:GetCaster():GetTeamNumber(), false )
            block_pos = block_pos + block_spacing
        end

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Kirill_ShakeTheGround_buff_scepter", {duration = self:GetSpecialValueFor("duration_scepter_fissure")})
    end

    local particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_fissure_egset.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, startPos)
    ParticleManager:SetParticleControl(particle, 1, endPos)
    ParticleManager:SetParticleControl(particle, 2, Vector(visual_duration, 0, 0 ))  

    local units = FindUnitsInLine(self:GetCaster():GetTeamNumber(), startPos, endPos, nil, 225, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
    
    for _,unit in ipairs(units) do
        if self:GetCaster():HasTalent("special_bonus_birzha_tereshin_6") then
            unit:AddNewModifier(self:GetCaster(), self, "modifier_Kirill_ShakeTheGround_debuff", {duration = stun_duration * ( 1 - unit:GetStatusResistance()) })
        end
        unit:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration * ( 1 - unit:GetStatusResistance()) })
        ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = damage + (self:GetCaster():GetStrength() * multi), ability = self, damage_type = DAMAGE_TYPE_PHYSICAL})
    end 

    if self:GetCaster():HasShard() and not self:GetAutoCastState() then
        local point = self:GetCursorPosition()
        local distance = (point - self:GetCaster():GetAbsOrigin()):Length2D()
        if distance > fissure_range then
            point = self:GetCaster():GetAbsOrigin() + direction * fissure_range
        end
        local end_pos_teleport = GetGroundPosition(point, nil)
        FindClearSpaceForUnit(self:GetCaster(), end_pos_teleport, true)
    end
end

modifier_Kirill_ShakeTheGround_thinker = class({})
function modifier_Kirill_ShakeTheGround_thinker:IsHidden() return true end
function modifier_Kirill_ShakeTheGround_thinker:IsPurgable() return false end

modifier_Kirill_ShakeTheGround_debuff = class({})

function modifier_Kirill_ShakeTheGround_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_Kirill_ShakeTheGround_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("talent_armor")
end

modifier_Kirill_ShakeTheGround_buff_scepter = class({})

function modifier_Kirill_ShakeTheGround_buff_scepter:IsHidden() return true end
function modifier_Kirill_ShakeTheGround_buff_scepter:IsPurgable() return false end
function modifier_Kirill_ShakeTheGround_buff_scepter:RemoveOnDeath() return false end

function modifier_Kirill_ShakeTheGround_buff_scepter:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_EVENT_ON_ATTACK
    }
    return decFuns
end

function modifier_Kirill_ShakeTheGround_buff_scepter:OnAttack(params)
    if params.attacker == self:GetParent() then
        if not self:GetParent():HasScepter() then return end
        local heroes_check = {}
        for k, v in pairs(Entities:FindAllInSphere(self:GetCaster():GetAbsOrigin(), 99999)) do
            if v:GetName() == "npc_dota_thinker" and v:FindModifierByName("modifier_Kirill_ShakeTheGround_thinker") then
                local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), v:GetOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius_scepter_fissure"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
                for _,enemy in pairs(enemies) do
                    if heroes_check[enemy:entindex()] == nil then
                        heroes_check[enemy:entindex()] = enemy
                        enemy:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_birzha_stunned_purge", { duration = self:GetAbility():GetSpecialValueFor("duration_scepter_stun") * ( 1 - enemy:GetStatusResistance()) } )
                    end
                end
                local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf", PATTACH_ABSORIGIN_FOLLOW, v )
                ParticleManager:SetParticleControl( effect_cast, 1, Vector( self:GetAbility():GetSpecialValueFor("radius_scepter_fissure"), self:GetAbility():GetSpecialValueFor("radius_scepter_fissure"), self:GetAbility():GetSpecialValueFor("radius_scepter_fissure") ) )
                ParticleManager:ReleaseParticleIndex( effect_cast )
            end
        end
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
        if self.modifier and not self.modifier:IsNull() then
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
    self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_tereshin_7")
    self.minus_regen = self:GetAbility():GetSpecialValueFor( "reg" )
    self.activated_strenth = 0
    self.stacks = 0
    self:StartIntervalThink(0.1)
end

function modifier_kirill_InjectSynthol:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return funcs
end

function modifier_kirill_InjectSynthol:GetModifierBonusStats_Strength()
    return self.activated_strenth
end

function modifier_kirill_InjectSynthol:OnIntervalThink()
    if not IsServer() then return end

    if self.stacks < 0.6 then
        self.stacks = self.stacks + 0.1
        self.activated_strenth = self.activated_strenth + (self.bonus_strength / 6)
        if self.stacks >= 0.6 then
            self.activated_strenth = self.bonus_strength
        end
        if IsServer() then
            self:GetCaster():CalculateStatBonus(true)
        end
    end

    if not IsServer() then return end
    local health = (self:GetCaster():GetMaxHealth() / 100 * self.minus_regen) * 0.1
    local mana = ((self:GetCaster():GetMaxMana() / 100 * self.minus_regen) * 2) * 0.1 

    if self:GetCaster():HasTalent("special_bonus_birzha_tereshin_3") then
        if self:GetCaster():GetMana() > mana then 
            self:GetCaster():Script_ReduceMana( mana, self:GetAbility() )
            return
        end 
    end

    self:GetParent():SetHealth(math.max( self:GetParent():GetHealth() - health, 1))
end

LinkLuaModifier( "modifier_kirill_SpecialDobbleHit", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kirill_SpecialDobbleHit_haste", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kirill_SpecialDobbleHit_debuff", "abilities/heroes/tereshin.lua", LUA_MODIFIER_MOTION_NONE )

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

function modifier_kirill_SpecialDobbleHit:OnAttack(params)
    if params.attacker == self:GetParent() then
        if self:GetParent():PassivesDisabled() then return end
        if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then
            self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kirill_SpecialDobbleHit_haste", {duration = 2})
            self:GetParent():EmitSound("sintol4")
            self:GetParent():AttackNoEarlierThan(0, 100)
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
    if IsClient() then return 0 end
    return 1000
end

function modifier_kirill_SpecialDobbleHit_haste:OnAttack(params)
    if params.attacker == self:GetParent() then
        if self:GetCaster():HasTalent("special_bonus_birzha_tereshin_4") then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kirill_SpecialDobbleHit_debuff", {duration = 0.5 * ( 1 - params.target:GetStatusResistance()) })
        end
        self:Destroy()
    end
end

modifier_kirill_SpecialDobbleHit_debuff = class({})

function modifier_kirill_SpecialDobbleHit_debuff:IsPurgable() return false end
function modifier_kirill_SpecialDobbleHit_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_kirill_SpecialDobbleHit_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_talent")
end