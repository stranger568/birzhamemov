LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Doljan_RapBattle_debuff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_Doljan_RapBattle_steal_debuff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_Doljan_RapBattle_steal_buff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)

Doljan_RapBattle = class({}) 

function Doljan_RapBattle:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Doljan_RapBattle:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Doljan_RapBattle:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Doljan_RapBattle:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("doljanrep")  
    self.modifier = target:AddNewModifier( self:GetCaster(), self, "modifier_Doljan_RapBattle_debuff", { duration = duration } )
end

function Doljan_RapBattle:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_doljan_1" )
end

modifier_Doljan_RapBattle_debuff = class({})

function modifier_Doljan_RapBattle_debuff:IsPurgable()
    return false
end

function modifier_Doljan_RapBattle_debuff:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor("interval")
    if self:GetCaster():HasShard() then
        interval = self:GetAbility():GetSpecialValueFor("shard_interval")
    end
    self:StartIntervalThink( interval )
    local particle = ParticleManager:CreateParticle( "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    self:AddParticle( particle, false, false, -1, false, false )
end

function modifier_Doljan_RapBattle_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("doljanrep")
end

function modifier_Doljan_RapBattle_debuff:OnIntervalThink()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local radius = self:GetAbility():GetSpecialValueFor("break_distance")
    local multi = self:GetAbility():GetSpecialValueFor("int_multi") + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_2")

    local current_stack_buff = self:GetCaster():GetModifierStackCount( "modifier_Doljan_RapBattle_steal_buff", self:GetCaster() )
    local current_stack_debuff = self:GetParent():GetModifierStackCount( "modifier_Doljan_RapBattle_steal_debuff", self:GetCaster() )

    local intellect_bonus = self:GetAbility():GetSpecialValueFor("intellect_bonus") + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_3")
    local damage = self:GetCaster():GetIntellect() / 100 * multi

    if self:GetParent():IsInvulnerable() or self:GetParent():IsIllusion() or ( not self:GetCaster():IsAlive()) then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>radius then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    if not self:GetParent():IsMagicImmune() then
        ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })

        if self:GetCaster():HasModifier("modifier_Doljan_RapBattle_steal_buff") then
            local mod = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_buff", { duration = duration } )
            if mod then
                mod:AddStack(intellect_bonus)
            end
        else
            local mod = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_buff", { duration = duration } )
            if mod then
                mod:AddStack(intellect_bonus)
            end
        end
        
        if self:GetParent():HasModifier("modifier_Doljan_RapBattle_steal_debuff") then
            local mod = self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_debuff", { duration = duration } )
            if mod then
                mod:AddStack(intellect_bonus)
            end
        else
            local mod = self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_debuff", { duration = duration } )
            if mod then
                mod:AddStack(intellect_bonus)
            end
        end

        if self:GetCaster():HasTalent("special_bonus_birzha_doljan_8") then
            self:GetCaster():PerformAttack(self:GetParent(), true, true, true, true, false, false, true)
        end

        self:GetCaster():CalculateStatBonus(true)
        self:GetParent():CalculateStatBonus(true)
    end
end

modifier_Doljan_RapBattle_steal_buff = class ({})

function modifier_Doljan_RapBattle_steal_buff:IsPurgable()
    return false
end

function modifier_Doljan_RapBattle_steal_buff:OnCreated()
    if not IsServer() then return end
    self.stack = 0
end

function modifier_Doljan_RapBattle_steal_buff:AddStack(stack)
    if not IsServer() then return end
    self.stack = self.stack + stack
    self:SetStackCount(self.stack)
end

function modifier_Doljan_RapBattle_steal_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
    return declfuncs
end

function modifier_Doljan_RapBattle_steal_buff:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("intellect_bonus")
end

modifier_Doljan_RapBattle_steal_debuff = class ({})

function modifier_Doljan_RapBattle_steal_debuff:OnCreated()
    if not IsServer() then return end
    self.stack = 0
end

function modifier_Doljan_RapBattle_steal_debuff:AddStack(stack)
    if not IsServer() then return end
    self.stack = self.stack + stack
    self:SetStackCount(self.stack)
end

function modifier_Doljan_RapBattle_steal_debuff:IsPurgable()
    return false
end

function modifier_Doljan_RapBattle_steal_debuff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
    return declfuncs
end

function modifier_Doljan_RapBattle_steal_debuff:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("intellect_bonus") * -1
end

LinkLuaModifier("modifier_doljan_trolling_buff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doljan_trolling_buff_counter", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doljan_trolling_debuff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doljan_trolling_debuff_counter", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
        
doljan_trolling = class({}) 

function doljan_trolling:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_6")
end

function doljan_trolling:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function doljan_trolling:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function doljan_trolling:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")
    return radius
end

function doljan_trolling:OnSpellStart()
    if not IsServer() then return end

    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("decay_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_1")
    local duration = self:GetSpecialValueFor("decay_duration")

    self:GetCaster():EmitSound("Hero_Undying.Decay.Cast")
    
    local decay_particle = ParticleManager:CreateParticle("particles/econ/items/undying/undying_pale_augur/undying_pale_augur_decay.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(decay_particle, 0, self:GetCursorPosition())
    ParticleManager:SetParticleControl(decay_particle, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(decay_particle, 2, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(decay_particle)
    
    
    for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
        if enemy:IsHero() and not enemy:IsIllusion() then
            enemy:EmitSound("Hero_Undying.Decay.Target")
            self:GetCaster():EmitSound("Hero_Undying.Decay.Transfer")

            local strength_transfer_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControlEnt(strength_transfer_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(strength_transfer_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(strength_transfer_particle)

            enemy:AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_debuff_counter", {duration = duration * (1-enemy:GetStatusResistance()) })
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_debuff", {duration = duration * (1-enemy:GetStatusResistance()) })
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_buff_counter", {duration = duration })
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_buff", {duration = duration })
            
            self:GetCaster():CalculateStatBonus(true)
            enemy:CalculateStatBonus(true)

            ApplyDamage({ victim = enemy, damage = damage, damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self})
        end
    end
end

modifier_doljan_trolling_buff = class({})

function modifier_doljan_trolling_buff:IsHidden() return true end
function modifier_doljan_trolling_buff:IsPurgable() return false end
function modifier_doljan_trolling_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_doljan_trolling_debuff = class({})

function modifier_doljan_trolling_debuff:IsHidden() return true end
function modifier_doljan_trolling_debuff:IsPurgable() return false end
function modifier_doljan_trolling_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end


modifier_doljan_trolling_buff_counter = class({})

function modifier_doljan_trolling_buff_counter:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
end

function modifier_doljan_trolling_buff_counter:OnIntervalThink()
    if not IsServer() then return end
    local stack = self:GetParent():FindAllModifiersByName("modifier_doljan_trolling_buff")
    self:SetStackCount(#stack)
end

function modifier_doljan_trolling_buff_counter:IsPurgable()  return false end

function modifier_doljan_trolling_buff_counter:GetEffectName()
    return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end

function modifier_doljan_trolling_buff_counter:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_doljan_trolling_buff_counter:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("str_steal")
end

function modifier_doljan_trolling_buff_counter:GetModifierModelScale()
    return self:GetStackCount() * 2
end

modifier_doljan_trolling_debuff_counter = class({})

function modifier_doljan_trolling_debuff_counter:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
end

function modifier_doljan_trolling_debuff_counter:OnIntervalThink()
    if not IsServer() then return end
    local stack = self:GetParent():FindAllModifiersByName("modifier_doljan_trolling_debuff")
    self:SetStackCount(#stack)
end

function modifier_doljan_trolling_debuff_counter:IsPurgable() return false end

function modifier_doljan_trolling_debuff_counter:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_doljan_trolling_debuff_counter:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("str_steal") * (-1)
end

LinkLuaModifier("modifier_Doljan_DrinkSomeVodka_stack", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Doljan_DrinkSomeVodka", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)

Doljan_DrinkSomeVodka = class({}) 

function Doljan_DrinkSomeVodka:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Doljan_DrinkSomeVodka:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Doljan_DrinkSomeVodka:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Doljan_DrinkSomeVodka:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor( "duration" )
    target:AddNewModifier( self:GetCaster(), self, "modifier_Doljan_DrinkSomeVodka", {duration = duration} )
    target:AddNewModifier( self:GetCaster(), self, "modifier_Doljan_DrinkSomeVodka_stack", {duration = duration} )
end

modifier_Doljan_DrinkSomeVodka = class ({})
function modifier_Doljan_DrinkSomeVodka:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_Doljan_DrinkSomeVodka:IsHidden() return true end

modifier_Doljan_DrinkSomeVodka_stack = class({})

function modifier_Doljan_DrinkSomeVodka_stack:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
end

function modifier_Doljan_DrinkSomeVodka_stack:OnIntervalThink()
    if not IsServer() then return end
    local stack = self:GetParent():FindAllModifiersByName("modifier_Doljan_DrinkSomeVodka")
    self:SetStackCount(#stack)
end

function modifier_Doljan_DrinkSomeVodka_stack:DeclareFunctions()
    local declfuncs = 
    {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return declfuncs
end

function modifier_Doljan_DrinkSomeVodka_stack:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor( "atributes" ) * self:GetStackCount()
end

function modifier_Doljan_DrinkSomeVodka_stack:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor( "atributes" ) * self:GetStackCount()
end

function modifier_Doljan_DrinkSomeVodka_stack:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor( "atributes" ) * self:GetStackCount()
end

LinkLuaModifier("modifier_Doljan_Intellect_stacks","abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Doljan_Intellect_handler","abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)

Doljan_Intellect = class({})

function Doljan_Intellect:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Doljan_Intellect:Spawn()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_Doljan_Intellect_handler") then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Doljan_Intellect_handler", {})
end

function Doljan_Intellect:GetAbilityDamageType()
    if self:GetCaster():HasScepter() then
        return DAMAGE_TYPE_MAGICAL
    end
end

function Doljan_Intellect:GetCooldown( nLevel )
    if self:GetCaster():HasScepter() then
        return 50
    end
end

function Doljan_Intellect:GetManaCost(nLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("manacost")
    end
end

function Doljan_Intellect:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Doljan_Intellect:OnSpellStart()
    if not IsServer() then return end

    local radius = self:GetSpecialValueFor("radius")

    local manaburn_percent = self:GetSpecialValueFor("mana_burn") / 100

    local enemyHeroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

    for k,enemy in pairs(enemyHeroes) do
        local manaburn = enemy:GetMaxMana() * manaburn_percent
        local manaburn_damage = self:GetSpecialValueFor("damage_burn") + (self:GetCaster():GetIntellect() * self:GetSpecialValueFor("scepter_int_multiple"))
        enemy:Script_ReduceMana(manaburn, self)
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self, damage = manaburn_damage, damage_type = DAMAGE_TYPE_MAGICAL})
        local particle = ParticleManager:CreateParticle("particles/doljan_scepter.vpcf", PATTACH_POINT_FOLLOW, enemy)
        ParticleManager:SetParticleControlEnt(particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, Vector(100,0,0))
        ParticleManager:ReleaseParticleIndex(particle)
        enemy:EmitSound("Hero_StormSpirit.StaticRemnantExplode")
    end
end

modifier_Doljan_Intellect_handler = class({})

function modifier_Doljan_Intellect_handler:IsDebuff() return false end
function modifier_Doljan_Intellect_handler:IsHidden() return true end
function modifier_Doljan_Intellect_handler:IsPurgable() return false end
function modifier_Doljan_Intellect_handler:RemoveOnDeath() return false end

function modifier_Doljan_Intellect_handler:DeclareFunctions()
    local decfuncs = 
    {
        MODIFIER_EVENT_ON_DEATH
    }
    return decfuncs
end

function modifier_Doljan_Intellect_handler:OnDeath(params)
    local caster = self:GetCaster()
    local target = params.unit
    if target:IsRealHero() and caster:GetTeamNumber() ~= target:GetTeamNumber() and caster:IsAlive() then     
        if (self:GetAbility():GetCaster():GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= 900 then
            self:IncrementStackCount()
            local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:ReleaseParticleIndex(pfx)
        end
    end
end

function Doljan_Intellect:GetIntrinsicModifierName()
    return "modifier_Doljan_Intellect_stacks"
end

modifier_Doljan_Intellect_stacks = class({})

function modifier_Doljan_Intellect_stacks:IsDebuff() return false end
function modifier_Doljan_Intellect_stacks:IsHidden() return false end
function modifier_Doljan_Intellect_stacks:IsPurgable() return false end
function modifier_Doljan_Intellect_stacks:IsStunDebuff() return false end
function modifier_Doljan_Intellect_stacks:RemoveOnDeath() return false end

function modifier_Doljan_Intellect_stacks:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_Doljan_Intellect_stacks:OnIntervalThink()
    if not IsServer() then return end
    local buff = self:GetCaster():FindModifierByName("modifier_Doljan_Intellect_handler")
    if not buff then return end
    self:SetStackCount(buff:GetStackCount())
end

function modifier_Doljan_Intellect_stacks:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_Doljan_Intellect_stacks:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("intellect") + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))
end


