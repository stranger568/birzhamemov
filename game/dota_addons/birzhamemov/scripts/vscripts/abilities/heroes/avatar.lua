LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_silenced", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

aang_quas = class({})

LinkLuaModifier( "modifier_aang_quas", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_aang_quas_passive", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

function aang_quas:GetIntrinsicModifierName() 
    return "modifier_aang_quas_passive"
end

modifier_aang_quas_passive = class({})

function modifier_aang_quas_passive:IsHidden()
    return true
end

function modifier_aang_quas_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function modifier_aang_quas_passive:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor( "magic_resistance_per_instance" )
end

function aang_quas:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_aang_quas",
        {  }
    )
    self.invoke:AddOrb( modifier )
end

function aang_quas:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "aang_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_aang_quas", self:GetLevel())
    end
end

modifier_aang_quas = class({})

function modifier_aang_quas:IsHidden()
    return false
end

function modifier_aang_quas:IsDebuff()
    return false
end

function modifier_aang_quas:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_aang_quas:IsPurgable()
    return false
end

function modifier_aang_quas:OnCreated( kv )
    self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
end

function modifier_aang_quas:OnRefresh( kv )
    self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
end

function modifier_aang_quas:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_aang_quas:GetModifierConstantHealthRegen()
    return self.regen
end

aang_wex = class({})

LinkLuaModifier( "modifier_aang_wex", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_aang_wex_passive", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

function aang_wex:GetIntrinsicModifierName() 
    return "modifier_aang_wex_passive"
end

modifier_aang_wex_passive = class({})

function modifier_aang_wex_passive:IsHidden()
    return true
end

function modifier_aang_wex_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_aang_wex_passive:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "armor_per_instance" )
end

function aang_wex:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self, 
        "modifier_aang_wex",
        {  }
    )
    self.invoke:AddOrb( modifier )
end

function aang_wex:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "aang_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_aang_wex", self:GetLevel())
    end
end

modifier_aang_wex = class({})

function modifier_aang_wex:IsHidden()
    return false
end

function modifier_aang_wex:IsDebuff()
    return false
end

function modifier_aang_wex:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_aang_wex:IsPurgable()
    return false
end

function modifier_aang_wex:OnCreated( kv )
    self.mana_per_instance = self:GetAbility():GetSpecialValueFor( "mana_per_instance" )
end

function modifier_aang_wex:OnRefresh( kv )
    self.mana_per_instance = self:GetAbility():GetSpecialValueFor( "mana_per_instance" )
end

function modifier_aang_wex:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }

    return funcs
end

function modifier_aang_wex:GetModifierConstantManaRegen()
    return self.mana_per_instance
end

aang_exort = class({})

LinkLuaModifier( "modifier_aang_exort", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_aang_exort_passive", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

function aang_exort:GetIntrinsicModifierName() 
    return "modifier_aang_exort_passive"
end

modifier_aang_exort_passive = class({})

function modifier_aang_exort_passive:IsHidden()
    return true
end

function modifier_aang_exort_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }

    return funcs
end

function modifier_aang_exort_passive:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor( "spell_amplify_instance" )
end

function aang_exort:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_aang_exort",
        {  }
    )
    self.invoke:AddOrb( modifier )
end

function aang_exort:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "aang_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_aang_exort", self:GetLevel())
    end
end

modifier_aang_exort = class({})

function modifier_aang_exort:IsHidden()
    return false
end

function modifier_aang_exort:IsDebuff()
    return false
end

function modifier_aang_exort:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_aang_exort:IsPurgable()
    return false
end

function modifier_aang_exort:OnCreated( kv )
    self.cast_range_instance = self:GetAbility():GetSpecialValueFor( "cast_range_instance" )
end

function modifier_aang_exort:OnRefresh( kv )
    self.cast_range_instance = self:GetAbility():GetSpecialValueFor( "cast_range_instance" ) 
end

function modifier_aang_exort:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING
    }

    return funcs
end

function modifier_aang_exort:GetModifierCastRangeBonusStacking()
    return self.cast_range_instance
end



aang_invoke = class({})
aang_empty1 = class({})
aang_empty2 = class({})
orb_manager = {}
ability_manager = {}

orb_manager.orb_order = "qwe"
orb_manager.invoke_list = {
    ["qqq"] = "aang_lunge",
    ["qqw"] = "aang_ice_wall",
    ["qqe"] = "aang_vacuum",
    ["www"] = "aang_fast_hit",
    ["qww"] = "aang_jumping",
    ["wwe"] = "aang_agility",
    ["eee"] = "aang_fire_hit",
    ["qee"] = "aang_lightning",
    ["wee"] = "aang_firestone",
    ["qwe"] = "aang_avatar",
}

orb_manager.modifier_list = {
    ["q"] = "modifier_aang_quas",
    ["w"] = "modifier_aang_wex",
    ["e"] = "modifier_aang_exort",

    ["modifier_aang_quas"] = "q",
    ["modifier_aang_wex"] = "w",
    ["modifier_aang_exort"] = "e",
}


LinkLuaModifier( "modifier_aang_invoke_passive", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

function aang_invoke:GetIntrinsicModifierName() 
    return "modifier_aang_invoke_passive"
end

modifier_aang_invoke_passive = class({})

function modifier_aang_invoke_passive:GetTexture()
    return "aang/avatar"
end

function modifier_aang_invoke_passive:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
    if IsInToolsMode() then
        self:SetStackCount(20)
    end
end

function modifier_aang_invoke_passive:OnDeath( params )
    if not IsServer() then return end
    self:DeathLogic( params )
    self:KillLogic( params )
end

function modifier_aang_invoke_passive:DeathLogic( params )
    local unit = params.unit
    local pass = false
    if unit==self:GetParent() and params.reincarnate==false then
        pass = true
    end
    if pass then
    end
end

function modifier_aang_invoke_passive:KillLogic( params )
    local target = params.unit
    local attacker = params.attacker
    local pass = false
    if attacker==self:GetParent() and target~=self:GetParent() and attacker:IsAlive() then
        if (not target:IsIllusion()) and (not target:IsBuilding()) and (target:IsHero()) and (not target:IsOther()) then
            pass = true
        end
    end
    if pass and (not self:GetParent():PassivesDisabled()) then
        self:SetStackCount(self:GetStackCount()+1)
        self:PlayEffects( target )
    end
end

function modifier_aang_invoke_passive:PlayEffects( target )
    local info = {
        Target = self:GetParent(),
        Source = target,
        EffectName = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf",
        iMoveSpeed = 400,
        vSourceLoc= target:GetAbsOrigin(),         
        bDodgeable = false,                        
        bReplaceExisting = false,                  
        flExpireTime = GameRules:GetGameTime() + 5,
        bProvidesVision = false,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,                   
    }
    ProjectileManager:CreateTrackingProjectile(info)
end

function modifier_aang_invoke_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH
    }

    return funcs
end

function modifier_aang_invoke_passive:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "movespeed_persentage" )
end

function aang_invoke:GetCooldown(level)
    local cooldown = 7
    local quas = self:GetCaster():FindAbilityByName("aang_quas")
    local wex = self:GetCaster():FindAbilityByName("aang_wex")
    local exort = self:GetCaster():FindAbilityByName("aang_exort")
    local cd_red = 0
    if exort then
        cd_red = cd_red + exort:GetLevel() * 0.3333
    end
    if wex then
        cd_red = cd_red + wex:GetLevel() * 0.3333
    end
    if quas then
        cd_red = cd_red + quas:GetLevel() * 0.3333
    end
    cooldown = cooldown - cd_red
    if self:GetCaster():HasModifier("modifier_aang_avatar") then
        cooldown = 0
    end
    return cooldown
end

function aang_invoke:OnSpellStart()
    local caster = self:GetCaster()
    local ability_name = self.orb_manager:GetInvokedAbility()
    self.ability_manager:Invoke( ability_name )
    self:PlayEffects()
end

function aang_invoke:OnUpgrade()
    local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "InitAbilityAang", {} )
    self.orb_manager = orb_manager:init()
    self.ability_manager = ability_manager:init()
    self.ability_manager.caster = self:GetCaster()
    self.ability_manager.ability = self
    local empty1 = self:GetCaster():FindAbilityByName( "aang_empty1" )
    local empty2 = self:GetCaster():FindAbilityByName( "aang_empty2" )
    table.insert(self.ability_manager.ability_slot,empty1)
    table.insert(self.ability_manager.ability_slot,empty2)
end

function aang_invoke:AddOrb( modifier )
    self.orb_manager:Add( modifier )
end

function aang_invoke:UpdateOrb( modifer_name, level )
    updates = self.orb_manager:UpdateOrb( modifer_name, level )
    self.ability_manager:UpgradeAbilities()
end

function aang_invoke:GetOrbLevel( orb_name )
    if not self.orb_manager.status[orb_name] then return 0 end
    return self.orb_manager.status[orb_name].level
end

function aang_invoke:GetOrbInstances( orb_name )
    if not self.orb_manager.status[orb_name] then return 0 end
    return self.orb_manager.status[orb_name].instances
end

function aang_invoke:GetOrbs()
    local ret = {}
    for k,v in pairs(self.orb_manager.status) do
        ret[k] = v.level
    end
    return ret
end

function aang_invoke:PlayEffects()
    local particle_cast = "particles/units/heroes/hero_invoker/invoker_invoke.vpcf"
    local sound_cast = "Hero_Invoker.Invoke"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        0,
        self:GetCaster(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0),
        true
    )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( sound_cast, self:GetCaster() )
end

function orb_manager:init()
    local ret = {}

    ret.MAX_ORB = 3
    ret.status = {}
    ret.modifiers = {}
    ret.names = {}

    for k,v in pairs(self) do
        ret[k] = v
    end
    return ret
end

function orb_manager:Add( modifier )
    local orb_name = self.modifier_list[modifier:GetName()]
    if not self.status[orb_name] then
        self.status[orb_name] = {
            ["instances"] = 0,
            ["level"] = modifier:GetAbility():GetLevel(),
        }
    end

    table.insert(self.modifiers,modifier)
    table.insert(self.names,orb_name)
    self.status[orb_name].instances = self.status[orb_name].instances + 1

    if #self.modifiers>self.MAX_ORB then
        self.status[self.names[1]].instances = self.status[self.names[1]].instances - 1
        self.modifiers[1]:Destroy()

        table.remove(self.modifiers,1)
        table.remove(self.names,1)
    end
    if modifier:GetCaster().orb_1 then
        ParticleManager:DestroyParticle( modifier:GetCaster().orb_1, false )
    end
    if modifier:GetCaster().orb_2 then
        ParticleManager:DestroyParticle( modifier:GetCaster().orb_2, false )
    end
    if modifier:GetCaster().orb_3 then
        ParticleManager:DestroyParticle( modifier:GetCaster().orb_3, false )
    end

    if self.modifiers[1] ~= nil then
        if self.modifiers[1]:GetName() == "modifier_aang_quas" then
            modifier:GetCaster().orb_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_1, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb1", modifier:GetCaster():GetAbsOrigin(), false)
        elseif self.modifiers[1]:GetName() == "modifier_aang_wex" then
            modifier:GetCaster().orb_1 = ParticleManager:CreateParticle("particles/avatar/aang_earth_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_1, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb1", modifier:GetCaster():GetAbsOrigin(), false)
        elseif self.modifiers[1]:GetName() == "modifier_aang_exort" then
            modifier:GetCaster().orb_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_1, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb1", modifier:GetCaster():GetAbsOrigin(), false)
        end
    end

    if self.modifiers[2] ~= nil then
        if self.modifiers[2]:GetName() == "modifier_aang_quas" then
            modifier:GetCaster().orb_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_2, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb2", modifier:GetCaster():GetAbsOrigin(), false)
        elseif self.modifiers[2]:GetName() == "modifier_aang_wex" then
            modifier:GetCaster().orb_2 = ParticleManager:CreateParticle("particles/avatar/aang_earth_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_2, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb2", modifier:GetCaster():GetAbsOrigin(), false)
        elseif self.modifiers[2]:GetName() == "modifier_aang_exort" then
            modifier:GetCaster().orb_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_2, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb2", modifier:GetCaster():GetAbsOrigin(), false)
        end
    end

    if self.modifiers[3] ~= nil then
        if self.modifiers[3]:GetName() == "modifier_aang_quas" then
            modifier:GetCaster().orb_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_3, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb3", modifier:GetCaster():GetAbsOrigin(), false)
        elseif self.modifiers[3]:GetName() == "modifier_aang_wex" then
            modifier:GetCaster().orb_3 = ParticleManager:CreateParticle("particles/avatar/aang_earth_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_3, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb3", modifier:GetCaster():GetAbsOrigin(), false)
        elseif self.modifiers[3]:GetName() == "modifier_aang_exort" then
            modifier:GetCaster().orb_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
            ParticleManager:SetParticleControlEnt(modifier:GetCaster().orb_3, 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, "attach_orb3", modifier:GetCaster():GetAbsOrigin(), false)
        end
    end
end

function orb_manager:GetInvokedAbility()
    local key = ""
    for i=1,string.len(self.orb_order) do
        k = string.sub(self.orb_order,i,i)

        if self.status[k] then 
            for i=1,self.status[k].instances do
                key = key .. k
            end
        end
    end
    return self.invoke_list[key]
end

function orb_manager:UpdateOrb( modifer_name, level )
    for _,modifier in pairs(self.modifiers) do
        if modifier:GetName()==modifer_name then
            modifier:ForceRefresh()
        end
    end

    local orb_name = self.modifier_list[modifer_name]
    if not self.status[orb_name] then
        self.status[orb_name] = {
            ["instances"] = 0,
            ["level"] = level,
        }
    else
        self.status[orb_name].level = level
    end
end

function ability_manager:init()
    local ret = {}

    ret.abilities = {}
    ret.ability_slot = {}
    ret.MAX_ABILITY = 2

    for k,v in pairs(self) do
        ret[k] = v
    end
    return ret
end

function ability_manager:Invoke( ability_name )
    if not ability_name then return end

    local ability = self:GetAbilityHandle( ability_name )
    ability.orbs = self.ability:GetOrbs()

    if self.ability_slot[1] and self.ability_slot[1]==ability then
        self.ability:RefundManaCost()
        self.ability:EndCooldown()
        return
    end

    local exist = 0
    for i=1,#self.ability_slot do
        if self.ability_slot[i]==ability then
            exist = i
        end
    end
    if exist>0 then
        self:InvokeExist( exist )
        self.ability:RefundManaCost()
        self.ability:EndCooldown()
        return
    end

    self:InvokeNew( ability )
end

function ability_manager:InvokeExist( slot )
    for i=slot,2,-1 do
        self.caster:SwapAbilities( 
            self.ability_slot[slot-1]:GetAbilityName(),
            self.ability_slot[slot]:GetAbilityName(),
            true,
            true
        )
        self.ability_slot[slot], self.ability_slot[slot-1] = self.ability_slot[slot-1], self.ability_slot[slot]
    end
end

function ability_manager:InvokeNew( ability )
    if #self.ability_slot<self.MAX_ABILITY then
        table.insert(self.ability_slot,ability)
    else
        self.caster:SwapAbilities( 
            ability:GetAbilityName(),
            self.ability_slot[#self.ability_slot]:GetAbilityName(),
            true,
            false
        )
        self.ability_slot[#self.ability_slot] = ability
    end

    self:InvokeExist( #self.ability_slot )
end

function ability_manager:GetAbilityHandle( ability_name )
    local ability = self.abilities[ability_name]

    if not ability then
        ability = self.caster:FindAbilityByName( ability_name )
        self.abilities[ability_name] = ability
        
        if not ability then
            ability = self.caster:AddAbility( ability_name )
            self.abilities[ability_name] = ability
        end

        self:InitAbility( ability )
    end

    return ability
end

function ability_manager:InitAbility( ability )
    if IsInToolsMode() then
        ability:SetLevel(7)
    else
        ability:SetLevel(1)
    end
    ability.GetOrbSpecialValueFor = function( self, key_name, orb_name )
        if not IsServer() then return 0 end
        if not self.orbs[orb_name] then return 0 end
        return self:GetLevelSpecialValueFor( key_name, self.orbs[orb_name] )
    end
end 

function ability_manager:UpgradeAbilities()
    for _,ability in pairs(self.abilities) do
        ability.orbs = self.ability:GetOrbs()
    end
end

function ability_manager:GetValueQuas(ability, caster, value)
    local quas = caster:FindAbilityByName("aang_quas")
    if quas then
        local level = quas:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

function ability_manager:GetValueWex(ability, caster, value)
    local wex = caster:FindAbilityByName("aang_wex")
    if wex then
        local level = wex:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

function ability_manager:GetValueExort(ability, caster, value)
    local exort = caster:FindAbilityByName("aang_exort")
    if exort then
        local level = exort:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

LinkLuaModifier("modifier_aang_lunge", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_aang_lunge_damage", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aang_lunge_stack", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_NONE)

aang_lunge = class({})

function aang_lunge:GetIntrinsicModifierName()
    return "modifier_aang_lunge_stack"
end

modifier_aang_lunge_stack = class({})

function modifier_aang_lunge_stack:IsHidden()
    return false
end

function modifier_aang_lunge_stack:IsPurgable()
    return false
end

function modifier_aang_lunge_stack:DestroyOnExpire()
    return false
end

function modifier_aang_lunge_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_4")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_aang_lunge_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_4")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_aang_lunge_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_aang_lunge_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_aang_lunge_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_aang_lunge_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_4")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function aang_lunge:GetCastRange(location, target)
    return ability_manager:GetValueQuas(self, self:GetCaster(), "range")
end

function aang_lunge:GetCooldown(level)
    local quas = self:GetCaster():FindAbilityByName("aang_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetCooldown( self, quas_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function aang_lunge:GetManaCost(level)
    local quas = self:GetCaster():FindAbilityByName("aang_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetManaCost(self, quas_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function aang_lunge:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_aang_lunge", {
        duration    = math.min((point - self:GetCaster():GetAbsOrigin()):Length2D(), self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() )),
        x           = point.x,
        y           = point.y,
        z           = point.z
    })
    local vDirection = point - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()
    local flag = DOTA_DAMAGE_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_7") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local info = {
        EffectName = 'particles/units/heroes/hero_morphling/morphling_waveform.vpcf',
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(), 
        fStartRadius = 100,
        fEndRadius = 100,
        vVelocity = vDirection * 1200,
        fDistance = #(self:GetCursorPosition() - self:GetCaster():GetOrigin()),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = flag,
    }

    ProjectileManager:CreateLinearProjectile( info )
end

function aang_lunge:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if hTarget then 
        local damage = ability_manager:GetValueQuas(self, self:GetCaster(), "base_damage")
        ApplyDamage({victim = hTarget, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end
end 

modifier_aang_lunge = class({})

function modifier_aang_lunge:IsPurgable() return false end
function modifier_aang_lunge:IsHidden() return true end
function modifier_aang_lunge:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_aang_lunge:IgnoreTenacity() return true end
function modifier_aang_lunge:IsMotionController() return true end
function modifier_aang_lunge:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_aang_lunge:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
end

function modifier_aang_lunge:OnCreated(params)
    if IsServer() then
        self:GetCaster():EmitSound("AangLunge")
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        self.velocity = 1250
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_aang_lunge:OnDestroy()
    if IsServer() then
        self:GetCaster():StopSound("AangLunge")
    end
end

function modifier_aang_lunge:OnIntervalThink()
    if not self:CheckMotionControllers() then
        self:Destroy()
        return nil
    end
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_aang_lunge:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            self:Destroy()
        end
    end
end

aang_ice_wall = class({})

LinkLuaModifier( "modifier_aang_ice_wall", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aang_ice_wall_thinker", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_NONE )

function aang_ice_wall:GetCooldown(level)
    local wex = self:GetCaster():FindAbilityByName("aang_wex")
    if wex then
        local quas_level = wex:GetLevel()-1
        return self.BaseClass.GetCooldown( self, quas_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function aang_ice_wall:GetManaCost(level)
    local wex = self:GetCaster():FindAbilityByName("aang_wex")
    if wex then
        local quas_level = wex:GetLevel()-1
        return self.BaseClass.GetManaCost(self, quas_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function aang_ice_wall:GetCastRange(location, target)
    return ability_manager:GetValueQuas(self, self:GetCaster(), "range")
end

function aang_ice_wall:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local dir = point - caster:GetOrigin()
    dir.z = 0
    dir = dir:Normalized()

    CreateModifierThinker(
        caster,
        self,
        "modifier_aang_ice_wall_thinker",
        {
            x = dir.x,
            y = dir.y,
        },
        caster:GetOrigin(),
        caster:GetTeamNumber(),
        false
    )
end

modifier_aang_ice_wall_thinker = class({})

function modifier_aang_ice_wall_thinker:IsHidden()
    return false
end

function modifier_aang_ice_wall_thinker:IsDebuff()
    return false
end

function modifier_aang_ice_wall_thinker:IsStunDebuff()
    return false
end

function modifier_aang_ice_wall_thinker:IsPurgable()
    return false
end

function modifier_aang_ice_wall_thinker:OnCreated( kv )
    self.parent = self:GetParent()
    self.caster = self:GetCaster()

    local damage = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "damage")
    self.range = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "range") + self.caster:GetCastRangeBonus()
    self.delay = self:GetAbility():GetSpecialValueFor( "path_delay" )
    self.duration = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "duration")
    self.radius = self:GetAbility():GetSpecialValueFor( "path_radius" )

    if not IsServer() then return end
    self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
    self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
    self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
    self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()
    self.delayed = true
    self.targets = {}
    local start_range = 12

    self.direction = Vector( kv.x, kv.y, 0 )
    self.startpoint = self.parent:GetOrigin() + self.direction + start_range
    self.endpoint = self.startpoint + self.direction * self.range

    self.damageTable = {
        attacker = self.caster,
        damage = damage,
        damage_type = self.abilityDamageType,
        ability = self:GetAbility(),
    }

    self:StartIntervalThink( self.delay )
    self:PlayEffects1()
    --self:PlayEffects2()
    self:PlayEffects3()
end

function modifier_aang_ice_wall_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove( self:GetParent() )
end

function modifier_aang_ice_wall_thinker:OnIntervalThink()
    if self.delayed then
        self.delayed = false
        self:SetDuration( self.duration, false )
        self:StartIntervalThink( 0.03 )

        local step = 0
        while step < self.range do
            local loc = self.startpoint + self.direction * step
            AddFOWViewer(
                self.caster:GetTeamNumber(),
                loc,
                self.radius,
                self.duration,
                false
            )

            step = step + self.radius
        end
        return
    end

    local flag = DOTA_DAMAGE_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_7") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInLine(
        self.caster:GetTeamNumber(),
        self.startpoint,
        self.endpoint,
        nil,
        self.radius,
        self.abilityTargetTeam,
        self.abilityTargetType,
        flag
    )

    for _,enemy in pairs(enemies) do
        if not self.targets[enemy] then
            self.targets[enemy] = true
            self.damageTable.victim = enemy
            ApplyDamage( self.damageTable )
            local duration = self:GetRemainingTime()
            enemy:AddNewModifier(
                self.caster,
                self:GetAbility(),
                "modifier_aang_ice_wall",
                { duration = duration }
            )
        end
    end
end

function modifier_aang_ice_wall_thinker:PlayEffects1()
    local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
    ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
    ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( 0, 0, self.delay ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_aang_ice_wall_thinker:PlayEffects2()
    local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf"
    local sound_cast = "Hero_Jakiro.IcePath"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
    ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
    ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay + self.duration, 0, 0 ) )
    ParticleManager:SetParticleControl( effect_cast, 9, self.startpoint )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        9,
        self.caster,
        PATTACH_POINT_FOLLOW,
        "attach_attack1",
        Vector(0,0,0),
        true
    )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( sound_cast, self.parent )
end

function modifier_aang_ice_wall_thinker:PlayEffects3()
    local particle_cast = "particles/aang_ice.vpcf"
    local sound_cast = "Hero_Jakiro.IcePath"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
    ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
    ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay + self.duration, 0, 0 ) )
    ParticleManager:SetParticleControl( effect_cast, 9, self.startpoint )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        9,
        self.caster,
        PATTACH_POINT_FOLLOW,
        "attach_attack1",
        Vector(0,0,0),
        true
    )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( sound_cast, self.parent )
end

modifier_aang_ice_wall = class({})

function modifier_aang_ice_wall:IsHidden()
    return false
end

function modifier_aang_ice_wall:IsDebuff()
    return true
end

function modifier_aang_ice_wall:IsStunDebuff()
    return true
end

function modifier_aang_ice_wall:IsPurgable()
    return true
end

function modifier_aang_ice_wall:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
    }

    return state
end

function modifier_aang_ice_wall:GetEffectName()
    return "particles/units/heroes/hero_jakiro/jakiro_icepath_debuff.vpcf"
end

function modifier_aang_ice_wall:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


aang_vacuum = class({})

LinkLuaModifier( "modifier_aang_vacuum", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function aang_vacuum:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function aang_vacuum:GetCastRange(location, target)
    return ability_manager:GetValueQuas(self, self:GetCaster(), "range")
end

function aang_vacuum:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function aang_vacuum:GetManaCost(level)
    local quas = self:GetCaster():FindAbilityByName("aang_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetManaCost(self, quas_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function aang_vacuum:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = ability_manager:GetValueQuas(self, self:GetCaster(), "radius")
    local tree = self:GetSpecialValueFor( "radius_tree" )
    local duration = ability_manager:GetValueQuas(self, self:GetCaster(), "duration")
    local flag = DOTA_DAMAGE_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_7") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        point,
        nil,  
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        flag,
        0,
        false
    )

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(
            caster,
            self,
            "modifier_aang_vacuum",
            {
                duration = duration,
                x = point.x,
                y = point.y,
            } -- kv
        )
    end
    GridNav:DestroyTreesAroundPoint( point, tree, false )
    self:PlayEffects( point, radius )
end

function aang_vacuum:PlayEffects( point, radius )
    local particle_cast = "particles/avatar/avatar_vacuum.vpcf"
    local sound_cast = "Hero_Dark_Seer.Vacuum"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end

modifier_aang_vacuum = class({})

function modifier_aang_vacuum:IsHidden()
    return false
end

function modifier_aang_vacuum:IsDebuff()
    return true
end

function modifier_aang_vacuum:IsStunDebuff()
    return true
end

function modifier_aang_vacuum:IsPurgable()
    return true
end

function modifier_aang_vacuum:OnCreated( kv )
    self.damage = self:GetAbility():GetSpecialValueFor("damage")

    if not IsServer() then return end

    self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

    local center = Vector( kv.x, kv.y, 0 )
    self.direction = center - self:GetParent():GetOrigin()
    self.speed = self.direction:Length2D()/self:GetDuration()

    self.direction.z = 0
    self.direction = self.direction:Normalized()

    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
end

function modifier_aang_vacuum:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_aang_vacuum:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )

    local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = self.abilityDamageType,
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end

function modifier_aang_vacuum:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_aang_vacuum:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_aang_vacuum:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_aang_vacuum:UpdateHorizontalMotion( me, dt )
    local target = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( target )
end

function modifier_aang_vacuum:OnHorizontalMotionInterrupted()
    self:Destroy()
end


LinkLuaModifier("modifier_aang_fast_hit_stack", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_NONE)

aang_fast_hit = class({})

function aang_fast_hit:GetCastRange(location, target)
    return self:GetSpecialValueFor( "radius" )
end

function aang_fast_hit:GetIntrinsicModifierName()
    return "modifier_aang_fast_hit_stack"
end

modifier_aang_fast_hit_stack = class({})

function modifier_aang_fast_hit_stack:IsHidden()
    return false
end

function modifier_aang_fast_hit_stack:IsPurgable()
    return false
end

function modifier_aang_fast_hit_stack:DestroyOnExpire()
    return false
end

function modifier_aang_fast_hit_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_5")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_aang_fast_hit_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_5")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_aang_fast_hit_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_aang_fast_hit_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_aang_fast_hit_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_aang_fast_hit_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_5")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function aang_fast_hit:OnSpellStart()
    if not IsServer() then return end
     self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 4)
    local radius = self:GetSpecialValueFor( "radius" )
    local radius_hit = self:GetSpecialValueFor( "radius_hit" )
    local duration = ability_manager:GetValueWex(self, self:GetCaster(), "duration")
    local damage = ability_manager:GetValueWex(self, self:GetCaster(), "damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_1")
    local vector = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector()*200
    local target
    local flag = DOTA_DAMAGE_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_8") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag, FIND_CLOSEST, false )
    for _,enemy in pairs(enemies) do
        target = enemy
        break
    end
    if target then
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius_hit, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        EmitSoundOnLocationWithCaster( target:GetOrigin(), "AangFasthit", self:GetCaster() )
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, radius_hit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, flag, FIND_CLOSEST, false )
        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(
                self:GetCaster(),
                self,
                "modifier_birzha_stunned",
                { duration = duration }
            )
            self.damageTable = {
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            self.damageTable.victim = enemy
            ApplyDamage( self.damageTable )
        end
    end
end

aang_jumping = class({})

function aang_jumping:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function aang_jumping:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_3")
end

function aang_jumping:GetManaCost(level)
    local quas = self:GetCaster():FindAbilityByName("aang_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetManaCost(self, quas_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function aang_jumping:GetCastPoint()
    return ability_manager:GetValueWex(self, self:GetCaster(), "cast_point")
end

function aang_jumping:OnAbilityPhaseStart()
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_7, 1)
    self.effect = true
    self:GetCaster():EmitSound("Ability.Focusfire")
    Timers:CreateTimer(0.15, function()
        local effect_cast =  ParticleManager:CreateParticle("particles/avatar/aang_jumping.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( self:GetSpecialValueFor("radius")+ self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_3"), self:GetSpecialValueFor("radius")+ self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_3"), self:GetSpecialValueFor("radius")+ self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_3") ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        if self.effect then
            return 0.15
        end
    end)
    return true
end

function aang_jumping:OnAbilityPhaseInterrupted()
    self.effect = false
    self:GetCaster():StopSound("Ability.Focusfire")
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_7)
    return true
end

function aang_jumping:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():StopSound("Ability.Focusfire")
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_7)
    self.effect = false
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_3")
    local flag = DOTA_DAMAGE_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_8") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        flag,
        0,
        false
    )
    local animation_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(animation_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(animation_pfx, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(animation_pfx, 2, Vector(self:GetCastPoint(), 0, 0))
    ParticleManager:SetParticleControl(animation_pfx, 3, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(animation_pfx)
    self:GetCaster():EmitSound("AangJumping")
    for _,enemy in pairs(enemies) do
        local stun_duration = ability_manager:GetValueWex(self, self:GetCaster(), "stun_duration")
        local damage = ability_manager:GetValueWex(self, self:GetCaster(), "damage")
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration})
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
    end
end

LinkLuaModifier( "modifier_agility_toss", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_HORIZONTAL  )
LinkLuaModifier( "modifier_generic_arc_lua",  "abilities/heroes/avatar", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_aang_agility_toss_stack", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_NONE)





aang_agility = {}

function aang_agility:GetIntrinsicModifierName()
    return "modifier_aang_agility_toss_stack"
end

modifier_aang_agility_toss_stack = class({})

function modifier_aang_agility_toss_stack:IsHidden()
    return false
end

function modifier_aang_agility_toss_stack:IsPurgable()
    return false
end

function modifier_aang_agility_toss_stack:DestroyOnExpire()
    return false
end

function modifier_aang_agility_toss_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_6")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_aang_agility_toss_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_6")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_aang_agility_toss_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_aang_agility_toss_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_aang_agility_toss_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_aang_agility_toss_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_6")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function aang_agility:GetCastRange(location, target)
    return ability_manager:GetValueExort(self, self:GetCaster(), "cast_range")
end

function aang_agility:FindEnemies()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor( "range_min" )

    local flag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_8") then
        flag = flag + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local units = FindUnitsInRadius(
        caster:GetTeamNumber(), -- int, your team number
        caster:GetOrigin(), -- point, center point
        nil,    -- handle, cacheUnit. (not known)
        radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        flag,  -- int, flag filter
        FIND_CLOSEST,   -- int, order filter
        false   -- bool, can grow cache
    )

    local target
    for _,unit in pairs(units) do
        local filter1 = (unit~=caster) and (not unit:IsBoss()) and (not unit:FindModifierByName( 'modifier_agility_toss' ))
        if filter1 then
            target = unit
            break
        end
    end

    return target
end

function aang_agility:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
    end
    return self:FindEnemies()
    -- return true -- if success
end

function aang_agility:OnSpellStart()
    local point = self:GetCursorPosition()
    local target = self:FindEnemies()
    target:AddNewModifier( self:GetCaster(), self, "modifier_agility_toss", {point_x = point.x, point_y = point.y, point_z = point.z} )
end

modifier_agility_toss = class({})

function modifier_agility_toss:IsHidden()
    return true
end

function modifier_agility_toss:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    if not IsServer() then return end
    local duration = 1.4
    self.point = Vector(kv.point_x, kv.point_y, kv.point_z)

    self.modifier = self.parent:AddNewModifier(
        self.caster,
        self:GetAbility(),
        "modifier_generic_arc_lua",
        {
            duration = duration,
            distance = 0,
            height = 850,
            fix_duration = false,
            isStun = true,
            activity = ACT_DOTA_FLAIL,
        }
    )

    self.modifier:SetEndCallback(function( interrupted )
        self:Destroy()
        if interrupted then return end
        local flag = 0
        if self:GetCaster():HasTalent("special_bonus_birzha_avatar_8") then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end
        local units = FindUnitsInRadius(
        self.caster:GetTeamNumber(), -- int, your team number
        self:GetParent():GetOrigin(), -- point, center point
        nil,    -- handle, cacheUnit. (not known)
        self:GetAbility():GetSpecialValueFor("radius"), -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        flag,  -- int, flag filter
        FIND_CLOSEST,   -- int, order filter
        false   -- bool, can grow cache
    )
    for _,unit in pairs(units) do
        local damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "damage")
        local damageTable = {victim = unit,
        attacker = self:GetCaster(),
        damage = damage,
        ability = self:GetAbility(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        }
        ApplyDamage(damageTable)
    end
        GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), 270, false )
        self.parent:EmitSound("Ability.TossImpact")
    end)

    local origin = self.point
    local direction = origin-self.parent:GetOrigin()
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    self.distance = distance
    if self.distance==0 then self.distance = 1 end
    self.duration = duration
    self.speed = distance/duration
    self.accel = 100
    self.max_speed = 3000
    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
    self.caster:EmitSound("Ability.TossThrow")
    self.parent:EmitSound("Hero_Tiny.Toss.Target")
end

function modifier_agility_toss:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_agility_toss:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_agility_toss:UpdateHorizontalMotion( me, dt )
    local target = self.point
    local parent = self.parent:GetOrigin()
    local duration = self:GetElapsedTime()
    local direction = target-parent
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    local original_distance = duration/self.duration * self.distance
    local expected_speed
    if self:GetElapsedTime()>=self.duration then
        expected_speed = self.speed
    else
        expected_speed = distance/(self.duration-self:GetElapsedTime())
    end
    if self.speed<expected_speed then
        self.speed = math.min(self.speed + self.accel, self.max_speed)
    elseif self.speed>expected_speed then
        self.speed = math.max(self.speed - self.accel, 0)
    end
    local pos = parent + direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_agility_toss:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_agility_toss:GetEffectName()
    return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_agility_toss:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end



modifier_generic_arc_lua = class({})

function modifier_generic_arc_lua:IsHidden()
    return true
end

function modifier_generic_arc_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_arc_lua:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_generic_arc_lua:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_generic_arc_lua:OnDestroy()
    if not IsServer() then return end
    local pos = self:GetParent():GetOrigin()
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )
    if self.end_offset~=0 then
        self:GetParent():SetOrigin( pos )
    end
    if self.endCallback then
        self.endCallback( self.interrupted )
    end
end

function modifier_generic_arc_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    if self:GetStackCount()>0 then
        table.insert( funcs, MODIFIER_PROPERTY_OVERRIDE_ANIMATION )
    end

    return funcs
end

function modifier_generic_arc_lua:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end

function modifier_generic_arc_lua:GetOverrideAnimation()
    return self:GetStackCount()
end

function modifier_generic_arc_lua:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = self.isStun or false,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

function modifier_generic_arc_lua:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_generic_arc_lua:UpdateVerticalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
    local pos = me:GetOrigin()
    local time = self:GetElapsedTime()
    local height = pos.z
    local speed = self:GetVerticalSpeed( time )
    pos.z = height + speed * dt
    me:SetOrigin( pos )

    if not self.fix_duration then
        local ground = GetGroundHeight( pos, me ) + self.end_offset
        if pos.z <= ground then
            pos.z = ground
            me:SetOrigin( pos )
            self:Destroy()
        end
    end
end

function modifier_generic_arc_lua:OnHorizontalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_generic_arc_lua:OnVerticalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_generic_arc_lua:SetJumpParameters( kv )
    self.parent = self:GetParent()
    self.fix_end = true
    self.fix_duration = true
    self.fix_height = true
    if kv.fix_end then
        self.fix_end = kv.fix_end==1
    end
    if kv.fix_duration then
        self.fix_duration = kv.fix_duration==1
    end
    if kv.fix_height then
        self.fix_height = kv.fix_height==1
    end

    self.isStun = kv.isStun==1
    self.isRestricted = kv.isRestricted==1
    self.isForward = kv.isForward==1
    self.activity = kv.activity or 0
    self:SetStackCount( self.activity )

    if kv.target_x and kv.target_y then
        local origin = self.parent:GetOrigin()
        local dir = Vector( kv.target_x, kv.target_y, 0 ) - origin
        dir.z = 0
        dir = dir:Normalized()
        self.direction = dir
    end
    if kv.dir_x and kv.dir_y then
        self.direction = Vector( kv.dir_x, kv.dir_y, 0 ):Normalized()
    end
    if not self.direction then
        self.direction = self.parent:GetForwardVector()
    end

    self.duration = kv.duration
    self.distance = kv.distance
    self.speed = kv.speed
    if not self.duration then
        self.duration = self.distance/self.speed
    end
    if not self.distance then
        self.speed = self.speed or 0
        self.distance = self.speed*self.duration
    end
    if not self.speed then
        self.distance = self.distance or 0
        self.speed = self.distance/self.duration
    end

    -- load vertical data
    self.height = kv.height or 0
    self.start_offset = kv.start_offset or 0
    self.end_offset = kv.end_offset or 0

    local pos_start = self.parent:GetOrigin()
    local pos_end = pos_start + self.direction * self.distance
    local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
    local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
    local height_max

    if not self.fix_height then
        self.height = math.min( self.height, self.distance/4 )
    end

    if self.fix_end then
        height_end = height_start
        height_max = height_start + self.height
    else
        local tempmin, tempmax = height_start, height_end
        if tempmin>tempmax then
            tempmin,tempmax = tempmax, tempmin
        end
        local delta = (tempmax-tempmin)*2/3

        height_max = tempmin + delta + self.height
    end

    if not self.fix_duration then
        self:SetDuration( -1, false )
    else
        self:SetDuration( self.duration, true )
    end

    self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_generic_arc_lua:Jump()
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end

    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end
end

function modifier_generic_arc_lua:InitVerticalArc( height_start, height_max, height_end, duration )
    local height_end = height_end - height_start
    local height_max = height_max - height_start

    if height_max<height_end then
        height_max = height_end+0.01
    end

    if height_max<=0 then
        height_max = 0.01
    end

    local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
    self.const1 = 4*height_max*duration_end/duration
    self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_generic_arc_lua:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_generic_arc_lua:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

function modifier_generic_arc_lua:SetEndCallback( func )
    self.endCallback = func
end

LinkLuaModifier( "modifier_aang_fire_hit_tp", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_BOTH )

aang_fire_hit = class({})

function aang_fire_hit:OnAbilityPhaseStart()
    if self:GetCursorTarget() == nil then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 3)
    end
    return true
end

function aang_fire_hit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function aang_fire_hit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function aang_fire_hit:GetCastRange(location, target)
    return ability_manager:GetValueExort(self, self:GetCaster(), "range")
end

function aang_fire_hit:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local target = self:GetCursorTarget()
    local caster_loc = caster:GetAbsOrigin()
    local distance = ability_manager:GetValueExort(self, self:GetCaster(), "distance_fire") + caster:GetCastRangeBonus()
    local direction
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))

    if target and target == self:GetCaster() then
        direction = caster:GetForwardVector() * -1
        point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_hitloc"))
        distance = distance / 2
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_aang_fire_hit_tp", {duration = 0.4})
    else
        if target_loc == caster_loc then
            direction = caster:GetForwardVector()
        else
            direction = (target_loc - caster_loc):Normalized()
        end
    end

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = distance,
        fStartRadius        = self:GetSpecialValueFor("radius"),
        fEndRadius          = self:GetSpecialValueFor("radius"),
        Source              = caster,
        bHasFrontalCone     = true,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1200,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("AangFirehit")
end

function aang_fire_hit:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = ability_manager:GetValueExort(self, self:GetCaster(), "damage")
    if target then
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

modifier_aang_fire_hit_tp = class({})

function modifier_aang_fire_hit_tp:IsHidden()
    return true
end

function modifier_aang_fire_hit_tp:IsDebuff()
    return true
end

function modifier_aang_fire_hit_tp:IsStunDebuff()
    return true
end

function modifier_aang_fire_hit_tp:IsPurgable()
    return true
end

function modifier_aang_fire_hit_tp:OnCreated( kv )
    self.damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage")
    if not IsServer() then return end
    self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
    local center = self:GetCaster():GetAbsOrigin()+self:GetCaster():GetForwardVector()*ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "distance_knockback")
    self.direction = center - self:GetParent():GetOrigin()
    self.speed = self.direction:Length2D()/self:GetDuration()
    self.direction.z = 0
    self.direction = self.direction:Normalized()
    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
end

function modifier_aang_fire_hit_tp:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_aang_fire_hit_tp:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end

function modifier_aang_fire_hit_tp:UpdateHorizontalMotion( me, dt )
    local target = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( target )
end

function modifier_aang_fire_hit_tp:OnHorizontalMotionInterrupted()
    self:Destroy()
end

aang_lightning = class({})

function aang_lightning:GetCastRange(location, target)
    return self:GetSpecialValueFor("range")
end

function aang_lightning:OnSpellStart()
    if not IsServer() then return end
    self.targets_table = {}
    local caster_vector = self:GetCaster():GetAbsOrigin()
    local vector = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,-90,0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * self:GetSpecialValueFor("range"))
    local vector_2_start = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,-65,0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * self:GetSpecialValueFor("range"))
    local vector_3_start = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,-115,0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * self:GetSpecialValueFor("range"))
    local hand = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))
    self:GetCaster():EmitSound("Hero_Zuus.GodsWrath.Target")
    local damage = ability_manager:GetValueExort(self, self:GetCaster(), "damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_2")
    local double_damage = (ability_manager:GetValueExort(self, self:GetCaster(), "damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_avatar_2")) * 2
    local velocity = (vector - self:GetCaster():GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("range")*15500)
    local velocity_2 = (vector_2_start - self:GetCaster():GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("range")*15500)
    local velocity_3 = (vector_3_start - self:GetCaster():GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("range")*15500)
    local flag = DOTA_DAMAGE_FLAG_NONE

    local info_1 = {
        Source = self:GetCaster(),
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        iUnitTargetFlags = flag,
        EffectName = "",
        fDistance = self:GetSpecialValueFor("range"),
        fStartRadius = 50,
        fEndRadius = 115,
        vVelocity = velocity_2,
        bProvidesVision = false,
        ExtraData = {
            damage = damage,
        }
    }
    local info_2 = {
        Source = self:GetCaster(),
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        iUnitTargetFlags = flag,
        EffectName = "",
        fDistance = self:GetSpecialValueFor("range"),
        fStartRadius = 50,
        fEndRadius = 275,
        vVelocity = velocity,
        bProvidesVision = false,
        ExtraData = {
            damage = double_damage,
        }
    }
    local info_3 = {
        Source = self:GetCaster(),
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        iUnitTargetFlags = flag,
        EffectName = "",
        fDistance = self:GetSpecialValueFor("range"),
        fStartRadius = 50,
        fEndRadius = 115,
        vVelocity = velocity_3,
        bProvidesVision = false,
        ExtraData = {
            damage = damage,
        }
    }
    ProjectileManager:CreateLinearProjectile(info_2) 
    Timers:CreateTimer(FrameTime(), function()
        ProjectileManager:CreateLinearProjectile(info_1) 
        ProjectileManager:CreateLinearProjectile(info_3) 
    end)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, hand)
    ParticleManager:SetParticleControl(particle, 1, Vector(vector.x, vector.y, vector.z+150)) 
    local particle_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_2, 0, hand)
    ParticleManager:SetParticleControl(particle_2, 1, Vector(vector_2_start.x, vector_2_start.y, vector_2_start .z+150)) 
    local particle_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_3, 0, hand)
    ParticleManager:SetParticleControl(particle_3, 1, Vector(vector_3_start.x, vector_3_start.y, vector_3_start.z+150)) 
end


function aang_lightning:OnProjectileHit_ExtraData( target, location, extraData )
    if not target then return end
    if not self.targets_table[ target:entindex() ] then
        self.targets_table[ target:entindex() ] = target
        local caster = self:GetCaster()
        print(extraData.damage)
        local damageTable = {
            victim = target,
            attacker = caster,
            damage = extraData.damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }
        ApplyDamage(damageTable)
    end
end

aang_avatar = class({})

LinkLuaModifier( "modifier_aang_avatar", "abilities/heroes/avatar", LUA_MODIFIER_MOTION_NONE )

function aang_avatar:OnAbilityPhaseStart()
    self:PlayEffects1()
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_REFRACTION, 1)
    return true
end
function aang_avatar:OnAbilityPhaseInterrupted()
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_REFRACTION)
    self:StopEffects1( false )
end

function aang_avatar:OnSpellStart()
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_REFRACTION)
    local lines = 0
    local modifier = self:GetCaster():FindModifierByNameAndCaster( "modifier_aang_invoke_passive", self:GetCaster() )
    if modifier~=nil then
        lines = math.floor(modifier:GetStackCount() / 1) 
    end
    if not self:GetCaster():HasScepter() then
        if lines > self:GetSpecialValueFor("max_wave") then
            lines = 20
        end
    end
    if IsInToolsMode() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_aang_avatar", {duration = 10})
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_aang_avatar", {duration = self:GetModifierDuration(self:GetCaster():GetLevel())})
    end
    self:Explode( lines )
end

function aang_avatar:GetModifierDuration(level)
    local duration = {0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5,2.75,3,3.25,3.5,3.75,4,4.25,4.5,4.75,5,5.25,5.5,5.75,6}
    if level > 25 then
        return duration[#duration]
    end
    return duration[level]
end

function aang_avatar:OnProjectileHit_ExtraData( hTarget, vLocation, params )
    if hTarget ~= nil then
        pass = false
        if hTarget:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then
            pass = true
        end
        if pass then
            if self:GetCaster():GetLevel() < 12 then
                self.damage = self:GetLevelSpecialValueFor("damage", 0)
            elseif self:GetCaster():GetLevel() <= 12 then
                self.damage = self:GetLevelSpecialValueFor("damage", 1)
            elseif self:GetCaster():GetLevel() >= 18 then
                self.damage = self:GetLevelSpecialValueFor("damage", 2)
            end
            local damage = {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self,
            }
            ApplyDamage( damage )
            hTarget:AddNewModifier(self:GetCaster(), self, "modifier_birzha_silenced", {duration = self:GetSpecialValueFor("silence_duration")})
        end
    end
    return false
end

function aang_avatar:OnOwnerDied()
    if self:GetLevel()<1 then return end
    local lines = 0
    local modifier = self:GetCaster():FindModifierByNameAndCaster( "modifier_aang_invoke_passive", self:GetCaster() )
    if modifier~=nil then
        lines = math.floor(modifier:GetStackCount() / 1) 
    end
    if lines > self:GetSpecialValueFor("max_wave") then
        lines = 20
    end
    if self:GetCaster():HasScepter() then
        if modifier~=nil then
            modifier:SetStackCount(modifier:GetStackCount() - 1)
        end
    end
    self:Explode( lines )
end

function aang_avatar:Explode( lines )
    local particle_line = "particles/avatar/aang_avatar_boom.vpcf"
    local line_length = 1000
    local width_start = 125
    local width_end = 350
    local line_speed = 700
    local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
    local delta_angle = 360/lines
    for i=0,lines-1 do
        local facing_angle_deg = initial_angle_deg + delta_angle * i
        if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
        local facing_angle = math.rad(facing_angle_deg)
        local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
        local velocity = facing_vector * line_speed

        local info = {
            Source = self:GetCaster(),
            Ability = self,
            EffectName = particle_line,
            vSpawnOrigin = self:GetCaster():GetOrigin(),
            fDistance = line_length,
            vVelocity = velocity,
            fStartRadius = width_start,
            fEndRadius = width_end,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bReplaceExisting = false,
            bProvidesVision = false,
        }
        ProjectileManager:CreateLinearProjectile( info )
    end
    self:StopEffects1( true )
    self:PlayEffects2( lines )
end

function aang_avatar:Implode( lines, modifier )
    local modifierAT = self:AddATValue( modifier )
    modifier.identifier = modifierAT
    local particle_line = "particles/avatar/aang_avatar_boom.vpcf"
    local line_length = 100
    local width_start = 125
    local width_end = 350
    local line_speed = 700
    local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
    local delta_angle = 360/lines
    for i=0,lines-1 do
        local facing_angle_deg = initial_angle_deg + delta_angle * i
        if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
        local facing_angle = math.rad(facing_angle_deg)
        local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
        local velocity = facing_vector * line_speed
        local info = {
            Source = self:GetCaster(),
            Ability = self,
            EffectName = particle_line,
            vSpawnOrigin = self:GetCaster():GetOrigin() + facing_vector * line_length,
            fDistance = line_length,
            vVelocity = -velocity,
            fStartRadius = width_start,
            fEndRadius = width_end,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bReplaceExisting = false,
            bProvidesVision = false,
            ExtraData = {
                modifier = modifierAT,
            }
        }
        ProjectileManager:CreateLinearProjectile( info )
    end
end

function aang_avatar:PlayEffects1()
    local particle_precast = "particles/avatar/aang_avatar_effect.vpcf"
    local sound_precast = "Hero_Nevermore.RequiemOfSoulsCast"
    self.effect_precast = ParticleManager:CreateParticle( particle_precast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )    
    EmitSoundOn(sound_precast, self:GetCaster())
end

function aang_avatar:StopEffects1( success )
    local sound_precast = "Hero_Nevermore.RequiemOfSoulsCast"
    if not success then
        ParticleManager:DestroyParticle( self.effect_precast, true )
        StopSoundOn(sound_precast, self:GetCaster())
    end
    if self.effect_precast then
        ParticleManager:ReleaseParticleIndex( self.effect_precast )
    end
end

function aang_avatar:PlayEffects2( lines )
    local particle_cast = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_debut_start.vpcf"
    local sound_cast = "Hero_Nevermore.RequiemOfSouls"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn(sound_cast, self:GetCaster())
end

function aang_avatar:GetAT()
    if self.abilityTable==nil then
        self.abilityTable = {}
    end
    return self.abilityTable
end

function aang_avatar:GetATEmptyKey()
    local table = self:GetAT()
    local i = 1
    while table[i]~=nil do
        i = i+1
    end
    return i
end

function aang_avatar:AddATValue( value )
    local table = self:GetAT()
    local i = self:GetATEmptyKey()
    table[i] = value
    return i
end

function aang_avatar:RetATValue( key )
    local table = self:GetAT()
    local ret = table[key]
    return ret
end

function aang_avatar:DelATValue( key )
    local table = self:GetAT()
    local ret = table[key]
    table[key] = nil
end

modifier_aang_avatar = class({})

function modifier_aang_avatar:OnCreated()
    if not IsServer() then return end
    EmitSoundOn("AangAvatar", self:GetParent())
    self:GetCaster():SetMaterialGroup("2")
    local ultimate = self:GetCaster():FindAbilityByName("aang_invoke")
    if ultimate then
        ultimate:EndCooldown()
    end
    self:StartIntervalThink(FrameTime())
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetCaster():GetCurrentVisionRange(), FrameTime(), false)
    self.particle = ParticleManager:CreateParticle("particles/avatar/aang_avatar_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_aang_avatar:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("AangAvatar", self:GetParent())
    self:GetCaster():SetMaterialGroup("1")
end

function modifier_aang_avatar:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetCaster():GetCurrentVisionRange(), FrameTime(), false)
end

function modifier_aang_avatar:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE
    }

    return funcs
end

function modifier_aang_avatar:GetBonusDayVision()
    return self:GetAbility():GetSpecialValueFor( "bonus_vision" )
end

function modifier_aang_avatar:GetBonusNightVision()
    return self:GetAbility():GetSpecialValueFor( "bonus_vision" )
end

function modifier_aang_avatar:GetModifierPercentageCasttime()
    return self:GetCastTimeLevel(self:GetCaster():GetLevel())
end

function modifier_aang_avatar:GetCastTimeLevel(level)
    local cast_time = {0,2.5,5,7.5,10,12.5,15,17.5,20,22.5,25,27.5,30,32.5,35,37.5,40,42.5,45,47.5,50,50,50,50,50}
    if level > 25 then
        return cast_time[#cast_time]
    end
    return cast_time[level]
end

function modifier_aang_avatar:CheckState()
    return {
        [MODIFIER_STATE_FLYING]       = true,
    }
end

aang_firestone = class({})

LinkLuaModifier( "modifier_aang_firestone_motion", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_aang_firestone_stun", "abilities/heroes/avatar.lua", LUA_MODIFIER_MOTION_BOTH )

function aang_firestone:OnAbilityPhaseStart()
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_6, 1)
    return true
end

function aang_firestone:OnSpellStart()
    if not IsServer() then return end
    local start_point = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,-135,0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 200)
    start_point.z = 600
    local end_point = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,45,0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 200)
    self.stone_one = CreateUnitByName("npc_dummy_unit", start_point, false, nil, nil, self:GetCaster():GetTeam())
    self.stone_one:SetModel("models/particle/meteor.vmdl")
    self.stone_one:SetOriginalModel("models/particle/meteor.vmdl")
    self.stone_one:SetModelScale(0.5)
    self.stone_one:SetMaterialGroup("2")
    self.stone_one:SetForwardVector(end_point-start_point:Normalized())
    self.stone_one:EmitSound("DOTA_Item.MeteorHammer.Cast")
    EmitSoundOn( "DOTA_Item.MeteorHammer.Channel", self.stone_one )
    local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_exit.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(nFXIndex, 0, self.stone_one:GetOrigin())
    local nFXIndex2 = ParticleManager:CreateParticle("particles/avatar/avatar_meteor_ground.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(nFXIndex2, 0, self.stone_one:GetOrigin())

    local flag = DOTA_DAMAGE_FLAG_NONE

    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self.stone_one:GetAbsOrigin(),
        nil,
        self:GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        flag,
        FIND_ANY_ORDER,
        false
    )
    local duration = ability_manager:GetValueWex(self, self:GetCaster(), "stun_duration")
    local damage = ability_manager:GetValueExort(self, self:GetCaster(), "damage")
    for _,unit in pairs(units) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = duration})
        local damageTable = {victim = unit,
            attacker = self:GetCaster(),
            damage = damage,
            ability = self,
            damage_type = DAMAGE_TYPE_MAGICAL,
        }
        ApplyDamage(damageTable)
    end

    self.buff = self.stone_one:AddNewModifier(self:GetCaster(), self, "modifier_aang_firestone_motion", {})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_aang_firestone_stun", {duration = 0.4})

    Timers:CreateTimer(0.3, function()
        self.vDirection = end_point - start_point
        self.flDist = self.vDirection:Length2D()
        self.vDirection.z = 0.0
        self.vDirection = self.vDirection:Normalized()
        local info = {
            EffectName = "",
            Ability = self,
            vSpawnOrigin = start_point, 
            fStartRadius = 0,
            fEndRadius = 0,
            vVelocity = self.vDirection * 1200,
            fDistance = self.flDist,
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        }
        self.buff.last_effect_x = end_point.x
        self.buff.last_effect_y = end_point.y
        self.buff.last_effect_z = end_point.z
        self.buff.first_effect_x = start_point.x
        self.buff.first_effect_y = start_point.y
        self.buff.first_effect_z = start_point.z
        self.buff.nProjHandle = ProjectileManager:CreateLinearProjectile( info )
        self.buff.flHeight = start_point.z - GetGroundHeight( self.stone_one:GetOrigin(), self.stone_one )
        self.buff.flTime = (self.flDist  / 1200)+FrameTime()
        self.buff:SetDuration(self.buff.flTime-FrameTime(), true)
    end)
end

modifier_aang_firestone_stun = class({})

function modifier_aang_firestone_stun:IsHidden()
    return true
end

function modifier_aang_firestone_stun:IsPurgable()
    return false
end

function modifier_aang_firestone_stun:CheckState()
    local state = {
    [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

modifier_aang_firestone_motion = class({})

function modifier_aang_firestone_motion:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_aang_firestone_motion:IsPurgable()
    return false
end

function modifier_aang_firestone_motion:OnCreated( kv )
    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
        self:Destroy()
        return
    end
    self.nProjHandle = -1
    self.flTime = 0.0
    self.flHeight = 0.0
    self.last_effect_x = 0
    self.last_effect_y = 0
    self.last_effect_z = 0
    self.first_effect_x = 0
    self.first_effect_y = 0
    self.first_effect_z = 0





    self.pfx = ParticleManager:CreateParticle( "particles/avatar/avatar_meteor_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
end

function modifier_aang_firestone_motion:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_aang_firestone_motion:OnDestroy()
    if not IsServer() then return end
    StopSoundOn( "DOTA_Item.MeteorHammer.Channel", self:GetParent() )
    self:GetParent():EmitSound("Hero_Invoker.ChaosMeteor.Impact")
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )
    local vforward = ( Vector(self.last_effect_x,self.last_effect_y,self.last_effect_z+50) - Vector(self.first_effect_x,self.first_effect_y,self.first_effect_z)):Normalized()
    self.particle_destroy = ParticleManager:CreateParticle( "particles/avatar/meteor_crush.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.particle_destroy, 1, Vector(self.last_effect_x,self.last_effect_y,self.last_effect_z+50) )
    ParticleManager:SetParticleControlForward( self.particle_destroy, 2, vforward )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, Vector(self.last_effect_x,self.last_effect_y,self.last_effect_z+50) )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 300, 300, 300 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast ) 
    local nFXIndex = ParticleManager:CreateParticle( "particles/neutral_fx/ursa_thunderclap.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( nFXIndex, 0, Vector(self.last_effect_x,self.last_effect_y,self.last_effect_z+50) )
    ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 300, 300, 300 ) )
    ParticleManager:ReleaseParticleIndex( nFXIndex )
    local flag = DOTA_DAMAGE_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_avatar_2") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        Vector(self.last_effect_x,self.last_effect_y,self.last_effect_z),
        nil,
        self:GetAbility():GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        flag,
        FIND_ANY_ORDER,
        false
    )
    local duration = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "stun_duration")
    local damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage")
    for _,unit in pairs(units) do
        unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = duration})
        local damageTable = {victim = unit,
            attacker = self:GetCaster(),
            damage = damage,
            ability = self:GetAbility(),
            damage_type = DAMAGE_TYPE_MAGICAL,
        }
        ApplyDamage(damageTable)
    end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, true)
        ParticleManager:ReleaseParticleIndex( self.pfx )
    end
    self:GetParent():Destroy()
end

function modifier_aang_firestone_motion:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local vLocation = nil
    if self.nProjHandle == -1 then
    else
        vLocation = ProjectileManager:GetLinearProjectileLocation( self.nProjHandle )
        vLocation.z = 0.0
        me:SetOrigin( vLocation )
    end
end

function modifier_aang_firestone_motion:UpdateVerticalMotion( me, dt )
    if not IsServer() then return end
    local vMyPos = me:GetOrigin()
    if self.nProjHandle == -1 then
        local flHeightChange = dt * 0.5 * 1100 * 3
        vMyPos.z = vMyPos.z + flHeightChange
        me:SetOrigin( vMyPos )
    else
        local flGroundHeight = GetGroundHeight( vMyPos, me )
        local flHeightChange = dt * self.flTime * self.flHeight * 2
        vMyPos.z = math.max( vMyPos.z - flHeightChange, flGroundHeight )
        self.flHeight = self.flHeight + vMyPos.z
        me:SetOrigin( vMyPos )
    end
end

function modifier_aang_firestone_motion:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    self:Destroy()
end

function modifier_aang_firestone_motion:OnVerticalMotionInterrupted()
    if not IsServer() then return end
    self:Destroy()
end