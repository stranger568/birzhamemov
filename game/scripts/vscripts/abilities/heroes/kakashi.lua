LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_quas = class({})

LinkLuaModifier( "modifier_kakashi_quas", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kakashi_quas_passive", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )

function kakashi_quas:GetIntrinsicModifierName() 
    return "modifier_kakashi_quas_passive"
end

modifier_kakashi_quas_passive = class({})

function modifier_kakashi_quas_passive:IsHidden()
    return true
end

function modifier_kakashi_quas_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function modifier_kakashi_quas_passive:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor( "passive_magic_resistance" )
end

function kakashi_quas:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_kakashi_quas",
        {  }
    )
    self.invoke:AddOrb( modifier, "particles/econ/items/invoker/invoker_ti6/invoker_ti6_quas_orb.vpcf" )
end

function kakashi_quas:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "kakashi_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_kakashi_quas", self:GetLevel())
    end
end

modifier_kakashi_quas = class({})

function modifier_kakashi_quas:IsHidden()
    return false
end

function modifier_kakashi_quas:IsDebuff()
    return false
end

function modifier_kakashi_quas:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_kakashi_quas:IsPurgable()
    return false
end

function modifier_kakashi_quas:OnCreated( kv )
    self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
end

function modifier_kakashi_quas:OnRefresh( kv )
    self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
end

function modifier_kakashi_quas:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_kakashi_quas:GetModifierConstantHealthRegen()
    return self.regen
end

kakashi_wex = class({})

LinkLuaModifier( "modifier_kakashi_wex", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kakashi_wex_passive", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )

function kakashi_wex:GetIntrinsicModifierName() 
    return "modifier_kakashi_wex_passive"
end

modifier_kakashi_wex_passive = class({})

function modifier_kakashi_wex_passive:IsHidden()
    return true
end

function modifier_kakashi_wex_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_kakashi_wex_passive:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "passive_armor" )
end


function kakashi_wex:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self, 
        "modifier_kakashi_wex",
        {  }
    )
    self.invoke:AddOrb( modifier, "particles/kakashi/earth_exort_orb.vpcf" )
end

function kakashi_wex:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "kakashi_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_kakashi_wex", self:GetLevel())
    end
end

modifier_kakashi_wex = class({})

function modifier_kakashi_wex:IsHidden()
    return false
end

function modifier_kakashi_wex:IsDebuff()
    return false
end

function modifier_kakashi_wex:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_kakashi_wex:IsPurgable()
    return false
end

function modifier_kakashi_wex:OnCreated( kv )
    self.mana_regen = self:GetAbility():GetSpecialValueFor( "bonus_regen_mana_regen" )
end

function modifier_kakashi_wex:OnRefresh( kv )
    self.mana_regen = self:GetAbility():GetSpecialValueFor( "bonus_regen_mana_regen" )
end

function modifier_kakashi_wex:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }

    return funcs
end

function modifier_kakashi_wex:GetModifierConstantManaRegen()
    return self.mana_regen
end

kakashi_exort = class({})

LinkLuaModifier( "modifier_kakashi_exort", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kakashi_exort_passive", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )


function kakashi_exort:GetIntrinsicModifierName() 
    return "modifier_kakashi_exort_passive"
end

modifier_kakashi_exort_passive = class({})

function modifier_kakashi_exort_passive:IsHidden()
    return true
end

--function modifier_kakashi_exort_passive:DeclareFunctions()
--    local funcs = {
--        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
--    }
--
--    return funcs
--end
--
--function modifier_kakashi_exort_passive:GetModifierSpellAmplify_Percentage()
--    return self:GetAbility():GetSpecialValueFor( "bonus_amplify" )
--end

function kakashi_exort:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_kakashi_exort",
        {  }
    )
    self.invoke:AddOrb( modifier, "particles/econ/items/invoker/invoker_ti6/invoker_ti6_wex_orb.vpcf" )
end

function kakashi_exort:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "kakashi_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_kakashi_exort", self:GetLevel())
    end
end

modifier_kakashi_exort = class({})

function modifier_kakashi_exort:IsHidden()
    return false
end

function modifier_kakashi_exort:IsDebuff()
    return false
end

function modifier_kakashi_exort:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_kakashi_exort:IsPurgable()
    return false
end

function modifier_kakashi_exort:OnCreated( kv )
    self.movespeed = self:GetAbility():GetSpecialValueFor( "movespeed_bonus" )
end

function modifier_kakashi_exort:OnRefresh( kv )
    self.movespeed = self:GetAbility():GetSpecialValueFor( "movespeed_bonus" ) 
end

function modifier_kakashi_exort:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_kakashi_exort:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

kakashi_invoke = class({})
kakashi_empty1 = class({})
kakashi_empty2 = class({})
orb_manager = {}
ability_manager = {}

orb_manager.orb_order = "qwe"
orb_manager.invoke_list = 
{
    ["qqq"] = "kakashi_raikiri",
    ["qqw"] = "kakashi_lightning_hit",
    ["qqe"] = "kakashi_shadow_clone",
    ["www"] = "kakashi_tornado",
    ["qww"] = "kakashi_graze_wave",
    ["wwe"] = "kakashi_susano",
    ["eee"] = "kakashi_lightning",
    ["qee"] = "kakashi_ligning_sphere",
    ["wee"] = "kakashi_meteor",
    ["qwe"] = "kakashi_sharingan",
}

orb_manager.modifier_list = {
    ["q"] = "modifier_kakashi_quas",
    ["w"] = "modifier_kakashi_wex",
    ["e"] = "modifier_kakashi_exort",

    ["modifier_kakashi_quas"] = "q",
    ["modifier_kakashi_wex"] = "w",
    ["modifier_kakashi_exort"] = "e",
}

LinkLuaModifier( "modifier_kakashi_invoke_passive", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )

modifier_kakashi_invoke_passive = class({})

function kakashi_invoke:GetIntrinsicModifierName() return "modifier_kakashi_invoke_passive" end
function modifier_kakashi_invoke_passive:IsHidden() return true end
function modifier_kakashi_invoke_passive:IsPurgable() return false end

function kakashi_invoke:GetCooldown(level)
    local cooldown = 7
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    local cd_red = 0
    if exort then
        cd_red = cd_red + exort:GetLevel() * self:GetSpecialValueFor("cooldown_per_sphere")
    end
    if wex then
        cd_red = cd_red + wex:GetLevel() * self:GetSpecialValueFor("cooldown_per_sphere")
    end
    if quas then
        cd_red = cd_red + quas:GetLevel() *self:GetSpecialValueFor("cooldown_per_sphere")
    end
    cooldown = cooldown - cd_red
    return cooldown / ( self:GetCaster():GetCooldownReduction())
end

function kakashi_invoke:OnSpellStart()
    local caster = self:GetCaster()
    local v1lat_Ability = caster:FindAbilityByName("kakashi_AiAiAi")
    local v1lat_ability_use = caster:FindAbilityByName("kakashi_AiAiAi_slam")
    if v1lat_Ability then
        if v1lat_Ability.ice_blast_dummy then
            if v1lat_ability_use then
                v1lat_ability_use:OnSpellStart()
            end
        end
    end
    local ability_name = self.orb_manager:GetInvokedAbility()
    self.ability_manager:Invoke( ability_name )
    self:PlayEffects()
end

function kakashi_invoke:OnUpgrade()
    if self.init_check == nil then
        self.init_check = true
    end
    if self.init_check then
        self.orb_manager = orb_manager:init()
        self.ability_manager = ability_manager:init()
        self.ability_manager.caster = self:GetCaster()
        self.ability_manager.ability = self
        local empty1 = self:GetCaster():FindAbilityByName( "kakashi_empty1" )
        local empty2 = self:GetCaster():FindAbilityByName( "kakashi_empty2" )
        table.insert(self.ability_manager.ability_slot,empty1)
        table.insert(self.ability_manager.ability_slot,empty2)
        self.init_check = false
    end
    self:GetCaster():FindAbilityByName("kakashi_lightning"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_raikiri"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_lightning_hit"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_shadow_clone"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_tornado"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_graze_wave"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_susano"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_ligning_sphere"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_meteor"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_sharingan"):SetLevel(self:GetLevel())
end

function kakashi_invoke:AddOrb( modifier, particle )
    self.orb_manager:Add( modifier, particle )
end

function kakashi_invoke:UpdateOrb( modifer_name, level )
    updates = self.orb_manager:UpdateOrb( modifer_name, level )
    self.ability_manager:UpgradeAbilities()
end

function kakashi_invoke:GetOrbLevel( orb_name )
    if not self.orb_manager.status[orb_name] then return 0 end
    return self.orb_manager.status[orb_name].level
end

function kakashi_invoke:GetOrbInstances( orb_name )
    if not self.orb_manager.status[orb_name] then return 0 end
    return self.orb_manager.status[orb_name].instances
end

function kakashi_invoke:GetOrbs()
    local ret = {}
    for k,v in pairs(self.orb_manager.status) do
        ret[k] = v.level
    end
    return ret
end

function kakashi_invoke:PlayEffects()
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
    self:GetCaster():EmitSound(sound_cast)
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

function orb_manager:Add( modifier, particle )
    local orb_name = self.modifier_list[modifier:GetName()]
    if not self.status[orb_name] then
        self.status[orb_name] = {
            ["instances"] = 0,
            ["level"] = modifier:GetAbility():GetLevel(),
        }
    end

    if self.foot_particle then
        ParticleManager:DestroyParticle(self.foot_particle, true)
    end

    if modifier:GetCaster().invoked_orbs_particle == nil then
        modifier:GetCaster().invoked_orbs_particle = {}
    end

    if modifier:GetCaster().invoked_orbs_particle_attach == nil then
        modifier:GetCaster().invoked_orbs_particle_attach = {}
        modifier:GetCaster().invoked_orbs_particle_attach[1] = "attach_orb1"
        modifier:GetCaster().invoked_orbs_particle_attach[2] = "attach_orb2"
        modifier:GetCaster().invoked_orbs_particle_attach[3] = "attach_orb3"
    end

    if modifier:GetCaster().invoked_orbs_particle[1] ~= nil then
        ParticleManager:DestroyParticle(modifier:GetCaster().invoked_orbs_particle[1], false)
        modifier:GetCaster().invoked_orbs_particle[1] = nil
    end

    modifier:GetCaster().invoked_orbs_particle[1] = modifier:GetCaster().invoked_orbs_particle[2]
    modifier:GetCaster().invoked_orbs_particle[2] = modifier:GetCaster().invoked_orbs_particle[3]
    modifier:GetCaster().invoked_orbs_particle[3] = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
    ParticleManager:SetParticleControlEnt(modifier:GetCaster().invoked_orbs_particle[3], 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, modifier:GetCaster().invoked_orbs_particle_attach[1], modifier:GetCaster():GetAbsOrigin(), false)


    local temp_attachment_point = modifier:GetCaster().invoked_orbs_particle_attach[1]
    modifier:GetCaster().invoked_orbs_particle_attach[1] = modifier:GetCaster().invoked_orbs_particle_attach[2]
    modifier:GetCaster().invoked_orbs_particle_attach[2] = modifier:GetCaster().invoked_orbs_particle_attach[3]
    modifier:GetCaster().invoked_orbs_particle_attach[3] = temp_attachment_point

    table.insert(self.modifiers,modifier)
    table.insert(self.names,orb_name)
    self.status[orb_name].instances = self.status[orb_name].instances + 1

    if #self.modifiers>self.MAX_ORB then
        self.status[self.names[1]].instances = self.status[self.names[1]].instances - 1
        if not self.modifiers[1]:IsNull() then
            self.modifiers[1]:Destroy()
        end

        table.remove(self.modifiers,1)
        table.remove(self.names,1)
    end

    if #modifier:GetCaster():FindAllModifiersByName("modifier_kakashi_quas") >= 3 then
        self.foot_particle = ParticleManager:CreateParticle("particles/kakashi/kakashi_feet_quas.vpcf", PATTACH_ABSORIGIN_FOLLOW, modifier:GetCaster())
    elseif #modifier:GetCaster():FindAllModifiersByName("modifier_kakashi_wex") >= 3 then
        self.foot_particle = ParticleManager:CreateParticle("particles/kakashi/kakashi_feet_wex.vpcf", PATTACH_ABSORIGIN_FOLLOW, modifier:GetCaster())
    elseif #modifier:GetCaster():FindAllModifiersByName("modifier_kakashi_exort") >= 3 then
        self.foot_particle = ParticleManager:CreateParticle("particles/kakashi/kakashi_feet_exort.vpcf", PATTACH_ABSORIGIN_FOLLOW, modifier:GetCaster())
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

        if self.ability_slot[slot-1]:GetAbilityName() == "kakashi_spit" or self.ability_slot[slot]:GetAbilityName() == "kakashi_spit" then
            if self.caster:FindModifierByName("modifier_kakashi_spit") then
                self.caster:FindModifierByName("modifier_kakashi_spit").active = true
            end
        elseif self.ability_slot[slot-1]:GetAbilityName() ~= "kakashi_spit" or self.ability_slot[slot]:GetAbilityName() ~= "kakashi_spit" then
            if self.caster:FindModifierByName("modifier_kakashi_spit") then
                self.caster:FindModifierByName("modifier_kakashi_spit").active = false
            end
        end
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
    local quas = caster:FindAbilityByName("kakashi_quas")
    if quas then
        local level = quas:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

function ability_manager:GetValueWex(ability, caster, value)
    local wex = caster:FindAbilityByName("kakashi_wex")
    if wex then
        local level = wex:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

function ability_manager:GetValueExort(ability, caster, value)
    local exort = caster:FindAbilityByName("kakashi_exort")
    if exort then
        local level = exort:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_kakashi_lightning", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kakashi_lightning_debuff", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

kakashi_lightning = class({})

function kakashi_lightning:GetCastRange(location, target)
    return ability_manager:GetValueExort(self, self:GetCaster(), "range")
end

function kakashi_lightning:GetCooldown(level)
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    if exort then
        local exort_level = exort:GetLevel()-1
        return self.BaseClass.GetCooldown( self, exort_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_lightning:GetManaCost(level)
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    if exort then
        local exort_level = exort:GetLevel()-1
        return self.BaseClass.GetManaCost(self, exort_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_lightning:OnSpellStart()
    if not IsServer() then return end

    local point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * ability_manager:GetValueExort(self, self:GetCaster(), "range")

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kakashi_lightning", {
        x           = point.x,
        y           = point.y,
        z           = point.z
    })
    local vDirection = point - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()

    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_7") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local info = {
        EffectName = "",
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(), 
        fStartRadius = 100,
        fEndRadius = 100,
        vVelocity = vDirection * 1200,
        fDistance = #(point - self:GetCaster():GetOrigin()),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = flag,
    }

    ProjectileManager:CreateLinearProjectile( info )
end

function kakashi_lightning:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if hTarget then 
        local damage = ability_manager:GetValueExort(self, self:GetCaster(), "base_damage")
        local duration = ability_manager:GetValueExort(self, self:GetCaster(), "debuff_duration")
        if not hTarget:IsMagicImmune() then
            ApplyDamage({victim = hTarget, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        end
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_kakashi_lightning_debuff", {duration = duration * (1-hTarget:GetStatusResistance())})
    end
end 

modifier_kakashi_lightning = class({})

function modifier_kakashi_lightning:IsPurgable() return false end
function modifier_kakashi_lightning:IsHidden() return true end
function modifier_kakashi_lightning:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_kakashi_lightning:IgnoreTenacity() return true end
function modifier_kakashi_lightning:IsMotionController() return true end
function modifier_kakashi_lightning:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_kakashi_lightning:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        --[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
end

function modifier_kakashi_lightning:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local distance = (caster:GetAbsOrigin() - position):Length2D()

        self.effect_cast = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControl( self.effect_cast, 1, self:GetParent():GetOrigin() )
        self:AddParticle( self.effect_cast, false, false, -1, false, false )

        self.velocity = 1200
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
        self:GetParent():EmitSound("Hero_StormSpirit.BallLightning")
        self:GetParent():EmitSound("Hero_StormSpirit.BallLightning.Loop")
    end
end

function modifier_kakashi_lightning:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_kakashi_lightning:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            ParticleManager:SetParticleControl( self.effect_cast, 1, self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled) )
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_kakashi_lightning:OnDestroy()
    if not IsServer() then return end
    StopSoundOn( "Hero_StormSpirit.BallLightning.Loop", self:GetParent() )
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_GHOST_WALK)
end

modifier_kakashi_lightning_debuff = class({})

function modifier_kakashi_lightning_debuff:IsPurgable() return true end

function modifier_kakashi_lightning_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_kakashi_lightning_debuff:GetModifierMagicalResistanceBonus()
    return ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "resistance_bonus")
end

------------------------------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_kakashi_raikiri", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kakashi_raikiri_damage", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE)

kakashi_raikiri = class({})

function kakashi_raikiri:GetAbilityChargeRestoreTime(level)
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetAbilityChargeRestoreTime( self, quas_level )
    end
end

function kakashi_raikiri:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_raikiri:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local direction = (point-self:GetCaster():GetOrigin())
    local dist = math.max( math.min( 1000, direction:Length2D() ), 200 )
    direction.z = 0
    direction = direction:Normalized()
    local target_pos = GetGroundPosition( self:GetCaster():GetOrigin() + direction*dist, nil )
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kakashi_raikiri", {
        duration    = math.min((point - self:GetCaster():GetAbsOrigin()):Length2D(), ability_manager:GetValueQuas(self, self:GetCaster(), "range")) / 3000,
        x           = point.x,
        y           = point.y,
        z           = point.z
    })
    self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_2, 3 )
    local effect_cast = ParticleManager:CreateParticle(  "particles/kakashi/astral_step.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, target_pos )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_VoidSpirit.AstralStep.Start", self:GetCaster() )
    EmitSoundOnLocationWithCaster( target_pos, "Hero_VoidSpirit.AstralStep.End", self:GetCaster() )
end

modifier_kakashi_raikiri = class({})

function modifier_kakashi_raikiri:IsPurgable() return false end
function modifier_kakashi_raikiri:IsHidden() return true end
function modifier_kakashi_raikiri:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_kakashi_raikiri:IgnoreTenacity() return true end
function modifier_kakashi_raikiri:IsMotionController() return true end
function modifier_kakashi_raikiri:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_kakashi_raikiri:IsAura() return true end

function modifier_kakashi_raikiri:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_kakashi_raikiri:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_kakashi_raikiri:GetAuraSearchFlags()
    return 0
end

function modifier_kakashi_raikiri:GetModifierAura()
    return "modifier_kakashi_raikiri_damage"
end

function modifier_kakashi_raikiri:GetAuraRadius()
    return 150
end

function modifier_kakashi_raikiri:GetEffectName()
    return "particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf" end

function modifier_kakashi_raikiri:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW end

function modifier_kakashi_raikiri:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end

function modifier_kakashi_raikiri:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local max_distance = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "range")
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        if distance > max_distance then distance = max_distance end
        self.velocity = 6000
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_kakashi_raikiri:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_kakashi_raikiri:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_kakashi_raikiri:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_GHOST_WALK)
end

modifier_kakashi_raikiri_damage = class({})

function modifier_kakashi_raikiri_damage:IsPurgable() return false end
function modifier_kakashi_raikiri_damage:IsHidden() return true end

function modifier_kakashi_raikiri_damage:OnCreated()
    if IsServer() then
        local damage = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "damage")
        local damageTable = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage,
            ability = self:GetAbility(),
            damage_type = DAMAGE_TYPE_MAGICAL,
        }
        ApplyDamage(damageTable)
    end
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_kakashi_lightning_hit", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_lightning_hit = class({})

function kakashi_lightning_hit:GetCastRange(location, target)
    return ability_manager:GetValueQuas(self, self:GetCaster(), "range")
end

function kakashi_lightning_hit:GetCooldown(level)
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetCooldown( self, quas_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_lightning_hit:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() then
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

function kakashi_lightning_hit:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier( caster, self, "modifier_kakashi_lightning_hit", { duration = duration * (1-target:GetStatusResistance()) } )
    local direction = target:GetOrigin()-self:GetCaster():GetOrigin()
    local effect_cast = ParticleManager:CreateParticle( "particles/kakashi/cold_snap.vpcf", PATTACH_POINT_FOLLOW, target )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetOrigin() + direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self:GetCaster():EmitSound("Hero_Invoker.ColdSnap.Cast")
    target:EmitSound("Hero_Invoker.ColdSnap")

    if target:HasModifier("modifier_kakashi_shadow_clone_pull") then
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #enemies <= 0 then return end
        for _, enemy in pairs(enemies) do
            if enemy:HasModifier("modifier_kakashi_shadow_clone_pull") then
                enemy:AddNewModifier( self:GetCaster(), self, "modifier_kakashi_lightning_hit", { duration = duration * (1-enemy:GetStatusResistance()) } )
            end
        end
    end
end

modifier_kakashi_lightning_hit = class({})

function modifier_kakashi_lightning_hit:IsPurgable()
    return false
end

function modifier_kakashi_lightning_hit:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kakashi_lightning_hit:OnCreated( kv )
    if IsServer() then
        self.damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "freeze_damage")
        self.duration = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "freeze_cooldown_one")
        self.freeze_bonus_cooldown = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "freeze_bonus_cooldown")
        self.max_ticks = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "max_ticks")
        self.ticks_current = 0
        self.threshold = 10
        self.onCooldown = false
        self:Freeze()
    end
end

function modifier_kakashi_lightning_hit:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_kakashi_lightning_hit:OnTakeDamage( params )
    if IsServer() then
        if params.unit~=self:GetParent() then return end
        if params.damage<self.threshold then return end
        if params.attacker == self:GetParent() then return end
        if params.inflictor ~= nil and params.inflictor:GetAbilityName() == "kakashi_lightning_hit" then return end
        if params.inflictor ~= nil and params.inflictor:GetAbilityName() == "Panasenkov_rakom" then return end
        if params.inflictor ~= nil and params.inflictor:GetAbilityName() == "Ricardo_KokosMaslo" then return end


        if params.unit:IsMagicImmune() then 
            return 
        end 
        self:Freeze()
        local direction = self:GetParent():GetOrigin()-params.attacker:GetOrigin()
        local effect_cast = ParticleManager:CreateParticle( "particles/kakashi/cold_snap.vpcf", PATTACH_POINT_FOLLOW, params.unit )
        ParticleManager:SetParticleControlEnt( effect_cast, 0, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
        ParticleManager:SetParticleControl( effect_cast, 1,  self:GetParent():GetOrigin()+direction )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:GetParent():EmitSound("Hero_Invoker.ColdSnap.Freeze")
    end
end

function modifier_kakashi_lightning_hit:Freeze()
    self.ticks_current = self.ticks_current + 1
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self.duration * (1-self:GetParent():GetStatusResistance()) } )
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    if self.ticks_current >= self.max_ticks then
        if not self:IsNull() then
            self:Destroy()
        end
    end
    self.duration = self.duration + self.freeze_bonus_cooldown
end

function modifier_kakashi_lightning_hit:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
end

function modifier_kakashi_lightning_hit:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_kakashi_shadow_clone", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kakashi_shadow_clone_pull", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_shadow_clone = class({})


function kakashi_shadow_clone:GetCastRange(location, target)
    return ability_manager:GetValueQuas(self, self:GetCaster(), "range")
end

function kakashi_shadow_clone:GetAOERadius()
    return ability_manager:GetValueQuas(self, self:GetCaster(), "radius")
end

function kakashi_shadow_clone:GetCooldown(level)
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetCooldown( self, quas_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_shadow_clone:GetManaCost(level)
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    if quas then
        local quas_level = quas:GetLevel()-1
        return self.BaseClass.GetManaCost(self, quas_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

local STATE_RUN = 1
local STATE_DELAY = 2
local STATE_WATCH = 3
local STATE_PULL = 4

function kakashi_shadow_clone:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local direction = (point - caster:GetAbsOrigin())
    direction.z = 0
    direction = direction:Normalized()
    CreateModifierThinker( caster, self, "modifier_kakashi_shadow_clone", { dir_x = direction.x, dir_y = direction.y, }, point, caster:GetTeamNumber(), false )
    caster:EmitSound( "Hero_VoidSpirit.AetherRemnant.Cast")
end

modifier_kakashi_shadow_clone = class({})

function modifier_kakashi_shadow_clone:OnCreated( kv )
    self.speed = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "clone_speed")
    self.distance = 450
    self.watch_vision = 200
    self.radius = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "radius")
    self.duration = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_2")
    self.one_duration = self:GetAbility():GetSpecialValueFor("duration_clone")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.units_active = {}
    if not IsServer() then return end
    self.origin = self:GetParent():GetOrigin()
    self.direction = Vector( kv.dir_x, kv.dir_y, 0 )
    self.target = GetGroundPosition( self.origin + self.direction * self.distance, nil )
    self.particle_cd = 1
    local run_dist = (self.origin-self:GetCaster():GetOrigin()):Length2D()
    local run_delay = run_dist/self.speed

    self.state = STATE_RUN

    self:StartIntervalThink( run_delay )

    local direction = self.origin-self:GetCaster():GetOrigin()
    direction.z = 0
    direction = direction:Normalized()
    self.effect_cast = ParticleManager:CreateParticle( "particles/kakashi/clone_run.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControlForward( self.effect_cast, 0, -direction )
    ParticleManager:SetParticleShouldCheckFoW( self.effect_cast, false )
    self:GetParent():EmitSound("Hero_VoidSpirit.AetherRemnant")
end

function modifier_kakashi_shadow_clone:OnDestroy()
    if not IsServer() then return end
    StopSoundOn( "Hero_VoidSpirit.AetherRemnant.Spawn_lp", self:GetParent() )
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
    if self.particle_water then
        ParticleManager:DestroyParticle( self.particle_water, false )
        ParticleManager:ReleaseParticleIndex( self.particle_water )
    end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_void_spirit/aether_remnant/void_spirit_aether_remnant_flash.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 3, self:GetParent():GetOrigin() )
    ParticleManager:ReleaseParticleIndex( particle )
    self:GetParent():EmitSound("Hero_VoidSpirit.AetherRemnant.Destroy")
    UTIL_Remove( self:GetParent() )
end

--particles/econ/events/ti7/teleport_start_ti7_spin_water.vpcf
--particles/kunkka_spell_torrent_splash_water_base_fxset1.vpcf


function modifier_kakashi_shadow_clone:OnIntervalThink()
    if self.state == STATE_RUN then
        self.state = STATE_WATCH
        self:StartIntervalThink( 0.1 )
        self:SetDuration( self.one_duration, false )
        if self.effect_cast then
            ParticleManager:DestroyParticle( self.effect_cast, false )
            ParticleManager:ReleaseParticleIndex( self.effect_cast )
        end
        self.effect_cast = ParticleManager:CreateParticle( "particles/kakashi/shadow_clone_watch.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self.origin )
        ParticleManager:SetParticleControl( self.effect_cast, 1, self.target )
        ParticleManager:SetParticleControlEnt( self.effect_cast, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc",self:GetParent():GetAbsOrigin(), true )
        ParticleManager:SetParticleControlForward( self.effect_cast, 0, self.direction )
        ParticleManager:SetParticleControlForward( self.effect_cast, 2, self.direction )
        self:GetParent():EmitSound("Hero_VoidSpirit.AetherRemnant.Spawn_lp")
        return
    elseif self.state == STATE_WATCH then
        self.particle_cd = self.particle_cd + 0.1
        if self.particle_cd >= 1 then
            self.particle_water = ParticleManager:CreateParticle( "particles/econ/items/monkey_king/arcana/water/monkey_king_spring_cast_arcana_water.vpcf", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( self.particle_water, 0, self:GetParent():GetOrigin() )
            self.particle_cd = 0
        end
        self:WatchLogic()
    else
        self:StartIntervalThink( -1 )
    end
end

function modifier_kakashi_shadow_clone:WatchLogic()
    AddFOWViewer( self:GetParent():GetTeamNumber(), self.origin, self.radius, 0.1, true)
    local flag = 0
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self.origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
    if #enemies <= 0 then return end
    for _, enemy in pairs(enemies) do
        if not self.units_active[enemy:entindex()] then
            self.units_active[enemy:entindex()] = enemy
            self:SetDuration( self.duration + 0.1, false )
            if not enemy:IsMagicImmune() then
                ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
            end
            enemy:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_kakashi_shadow_clone_pull", { duration = self.duration, pos_x = self.origin.x, pos_y = self.origin.y, pull = 60, } )
        end
    end
end

modifier_kakashi_shadow_clone_pull = class({})

function modifier_kakashi_shadow_clone_pull:OnCreated( kv )
    if not IsServer() then return end
    self.target = Vector( kv.pos_x, kv.pos_y, 0 )
    local dist = (self:GetParent():GetOrigin()-self.target):Length2D()
    self.speed = kv.pull/100*dist/kv.duration
    self:GetParent():MoveToPosition( self.target )

    
    self.particle_drain_fx = ParticleManager:CreateParticle("particles/kakashi/clone_pull_life_drain.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)


end

function modifier_kakashi_shadow_clone_pull:OnRefresh( kv )
    if not IsServer() then return end
    self.target = Vector( kv.pos_x, kv.pos_y, 0 )
    local dist = (self:GetParent():GetOrigin()-self.target):Length2D()
    self.speed = kv.pull/100*dist/kv.duration
    self:GetParent():MoveToPosition( self.target )
end

function modifier_kakashi_shadow_clone_pull:OnDestroy()
    if not IsServer() then return end
    if self.particle_drain_fx then
        ParticleManager:DestroyParticle(self.particle_drain_fx, true)
    end
end

function modifier_kakashi_shadow_clone_pull:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }

    return funcs
end

function modifier_kakashi_shadow_clone_pull:GetModifierMoveSpeed_Absolute()
    if IsServer() then return self.speed end
end

function modifier_kakashi_shadow_clone_pull:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }

    return state
end

function modifier_kakashi_shadow_clone_pull:GetStatusEffectName()
    return "particles/status_fx/status_effect_void_spirit_aether_remnant.vpcf"
end

function modifier_kakashi_shadow_clone_pull:StatusEffectPriority()
    return MODIFIER_PRIORITY_NORMAL
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_kakashi_tornado_debuff_resist", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kakashi_tornado_debuff_movespeed", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_tornado = class({})

function kakashi_tornado:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_tornado:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_tornado:GetManaCost(level)
    local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
    if wex then
        local wex_level = wex:GetLevel()-1
        return self.BaseClass.GetManaCost(self, wex_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_tornado:OnSpellStart()
    if not IsServer() then return end

    local distance = ability_manager:GetValueWex(self, self:GetCaster(), "range")
    local radius = self:GetSpecialValueFor("radius")
    local target
    local target
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
    for _,enemy in pairs(enemies) do
        target = enemy
        break
    end
    if target then
        self.tornado = 
        {
            Ability = self,
            bDeleteOnHit   = false,
            EffectName =  "particles/kakashi/tornado_tornado_ti6.vpcf",
            vSpawnOrigin = self:GetCaster():GetOrigin(),
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            iMoveSpeed          = 1000,
            Source = self:GetCaster(),
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            bVisibleToEnemies = true,
            bProvidesVision = false,
        }
        local target_point = target:GetAbsOrigin()
        local caster_point = self:GetCaster():GetAbsOrigin() 
        local point_difference_normalized   = (target_point - caster_point):Normalized()

        if target_point == caster_point then
            point_difference_normalized = self:GetCaster():GetForwardVector()
        else
            point_difference_normalized = (target_point - caster_point):Normalized()
        end

        local projectile_vvelocity          = point_difference_normalized * 1000
        projectile_vvelocity.z = 0
        self.tornado.vVelocity  = projectile_vvelocity
        local tornado_projectile = ProjectileManager:CreateLinearProjectile(self.tornado)
        self:GetCaster():EmitSound("Hero_Invoker.Tornado.Cast")
    end
end

function kakashi_tornado:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        if not self:GetCaster():HasTalent("special_bonus_birzha_kakashi_8") then
            if target:IsMagicImmune() then return end
        end
        local duration = self:GetSpecialValueFor( "duration" )
        local damage = ability_manager:GetValueWex(self, self:GetCaster(), "damage")

        if not target:IsMagicImmune() then
            ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        end

        target:EmitSound("Hero_Invoker.Tornado")

        if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_5") then
            target:AddNewModifier( self:GetCaster(), self, "modifier_kakashi_tornado_debuff_resist", { duration = duration * (1 - target:GetStatusResistance()) } )
            target:AddNewModifier( self:GetCaster(), self, "modifier_kakashi_tornado_debuff_movespeed", { duration = duration * (1 - target:GetStatusResistance()) } )
            return
        end

        local modifier = target:FindModifierByName("modifier_kakashi_tornado_debuff_resist")
        if not modifier or modifier:GetStackCount() < self:GetSpecialValueFor("max_effects") then
            target:AddNewModifier( self:GetCaster(), self, "modifier_kakashi_tornado_debuff_resist", { duration = duration * (1 - target:GetStatusResistance()) } )
        elseif modifier then
            modifier:SetDuration(duration, true)
        end

        local modifier_2 = target:FindModifierByName("modifier_kakashi_tornado_debuff_movespeed")
        if not modifier_2 or modifier_2:GetStackCount() < self:GetSpecialValueFor("max_effects") then
            target:AddNewModifier( self:GetCaster(), self, "modifier_kakashi_tornado_debuff_movespeed", { duration = duration * (1 - target:GetStatusResistance()) } )
        elseif modifier_2 then
            modifier_2:SetDuration(duration, true)
        end
    end
end

modifier_kakashi_tornado_debuff_resist = class({})

function modifier_kakashi_tornado_debuff_resist:OnCreated()
    self.magical_resistance = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "magic_resistance_minus")
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_kakashi_tornado_debuff_resist:OnRefresh()
    self.magical_resistance = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "magic_resistance_minus")
    if not IsServer() then return end
    self:SetStackCount(self:GetStackCount() + 1)
end

function modifier_kakashi_tornado_debuff_resist:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }

    return funcs
end

function modifier_kakashi_tornado_debuff_resist:GetModifierMagicalResistanceBonus()
    return self.magical_resistance * self:GetStackCount()
end

modifier_kakashi_tornado_debuff_movespeed = class({})

function modifier_kakashi_tornado_debuff_movespeed:IsPurgable() return true end

function modifier_kakashi_tornado_debuff_movespeed:OnCreated()
    self.movespeed = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "movespeed_slow")
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_kakashi_tornado_debuff_movespeed:OnRefresh()
    self.magical_resistance = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "magic_resistance_minus")
    if not IsServer() then return end
    self:SetStackCount(self:GetStackCount() + 1)
end

function modifier_kakashi_tornado_debuff_movespeed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_kakashi_tornado_debuff_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed * self:GetStackCount()
end
------------------------------------------------------------------------------------------------------------------
kakashi_graze_wave = class({})

LinkLuaModifier( "modifier_kakashi_graze_wave", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_kakashi_graze_wave_passive", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function kakashi_graze_wave:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_graze_wave:GetIntrinsicModifierName()
    return "modifier_kakashi_graze_wave_passive"
end

modifier_kakashi_graze_wave_passive = class({})

function modifier_kakashi_graze_wave_passive:IsHidden() return true end
function modifier_kakashi_graze_wave_passive:IsPurgable() return false end


function modifier_kakashi_graze_wave_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
        MODIFIER_PROPERTY_DISABLE_TURNING
    }

    return funcs
end

function modifier_kakashi_graze_wave_passive:OnOrder(keys)
    if not IsServer() or keys.unit ~= self:GetParent() then return end
    
    if keys.ability == self:GetAbility() then
        if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION and (keys.new_pos - self:GetCaster():GetAbsOrigin()):Length2D() <= self:GetAbility():GetCastRange(self:GetCaster():GetCursorPosition(), self:GetCaster()) then
            self.bActive = true
        else
            self.bActive = false
        end
    else
        self.bActive = false
    end
end

function modifier_kakashi_graze_wave_passive:GetModifierIgnoreCastAngle()
    if not IsServer() or self.bActive == false then return end
    return 1
end

function modifier_kakashi_graze_wave_passive:GetModifierDisableTurning()
    if not IsServer() or self.bActive == false then return end
    return 1
end

function kakashi_graze_wave:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local origin = self:GetCaster():GetOrigin()
    local point = self:GetCursorPosition()
    local direction = ((point - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()
    local endpos = self:GetCaster():GetAbsOrigin() + direction * 340
    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_8") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    self:GetCaster():SetForwardVector(direction)
    local units = FindUnitsInLine(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), endpos, self:GetCaster(), 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag)
    local duration = ability_manager:GetValueQuas(self, self:GetCaster(), "stun_duration")
    local damage = ability_manager:GetValueWex(self, self:GetCaster(), "damage")
    for _,target in pairs(units) do

        local direction = self:GetCaster():GetAbsOrigin() - target:GetAbsOrigin()
        local length = direction:Length2D() * 2
        direction.z = 0
        direction = direction:Normalized()

        local new_origin = target:GetAbsOrigin() + direction * length

        --target:AddNewModifier( caster, self, "modifier_kakashi_graze_wave", { duration = duration, x = new_origin.x, y = new_origin.y, } )

        local effect_cast = ParticleManager:CreateParticle("particles/kakashi_graze_wave.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 1, new_origin )
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        if not target:IsMagicImmune() then
            ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbilityDamageType(), ability = self, })
        end
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = duration * (1-target:GetStatusResistance())})
        FindClearSpaceForUnit(target, new_origin, true)
    end
    if #units > 0 then
        self:GetCaster():EmitSound("kakashi_graze")
    end
end

modifier_kakashi_graze_wave = class({})

function modifier_kakashi_graze_wave:IsHidden()
    return false
end

function modifier_kakashi_graze_wave:IsDebuff()
    return true
end

function modifier_kakashi_graze_wave:IsStunDebuff()
    return true
end

function modifier_kakashi_graze_wave:IsPurgable()
    return true
end

function modifier_kakashi_graze_wave:OnCreated( kv )
    self.damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "damage")

    if not IsServer() then return end

    self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

    local center = Vector( kv.x, kv.y, 0 )
    self.direction = center - self:GetParent():GetOrigin()
    self.speed = self.direction:Length2D()/self:GetDuration()

    self.direction.z = 0
    self.direction = self.direction:Normalized()

    if not self:ApplyHorizontalMotionController() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_kakashi_graze_wave:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_kakashi_graze_wave:OnDestroy()
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

function modifier_kakashi_graze_wave:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_kakashi_graze_wave:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_kakashi_graze_wave:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_kakashi_graze_wave:UpdateHorizontalMotion( me, dt )
    local target = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( target )
end

function modifier_kakashi_graze_wave:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_kakashi_susano_ally", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kakashi_susano_enemy", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

kakashi_susano = class({})

function kakashi_susano:GetManaCost(level)
    local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
    if wex then
        local wex_level = wex:GetLevel()-1
        return self.BaseClass.GetManaCost(self, wex_level)
    end  
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_susano:GetCooldown(level)
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    if exort then
        local exort_level = exort:GetLevel()-1
        return self.BaseClass.GetCooldown( self, exort_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_susano:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and (not self:GetCaster():HasTalent("special_bonus_birzha_kakashi_8")) then
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

function kakashi_susano:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        local shield_duration_ally = self:GetSpecialValueFor("shield_duration_ally")
        local health_restore = self:GetSpecialValueFor("health_restore")
        local magic_immune = self:GetSpecialValueFor("magic_immune")
        target:Heal(health_restore, self)
        target:AddNewModifier(self:GetCaster(), self, "modifier_kakashi_susano_ally", {duration = shield_duration_ally})
        target:AddNewModifier(self:GetCaster(), self, "modifier_magic_immune", {duration = magic_immune})
        local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
        if wex then
            local wex_level = wex:GetLevel()
            if wex_level >= 5 then
                target:Purge(false, true, false, true, true)
            end
        end  
    else
        local shield_duration_enemy = self:GetSpecialValueFor("shield_duration_enemy")
        target:AddNewModifier(self:GetCaster(), self, "modifier_kakashi_susano_enemy", {duration = shield_duration_enemy * (1-target:GetStatusResistance())})
    end
    self:GetCaster():EmitSound("kakashi_sasuno")
end

modifier_kakashi_susano_ally = class({})

function modifier_kakashi_susano_ally:IsPurgable() return false end

function modifier_kakashi_susano_ally:OnCreated()
    self.ally_movespeed = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "ally_movespeed")
    self.ally_damage_out = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "ally_damage_out")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.stun_duration = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "stun_duration")
    self.damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "damage")
    if not IsServer() then return end
    self.targets = {}
    local particle = ParticleManager:CreateParticle( "particles/kakashi_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( particle, 1, Vector( 80, 80, 0 ) )
    self:AddParticle( particle, false, false, -1, false, false )
    self:StartIntervalThink(FrameTime())
end

function modifier_kakashi_susano_ally:OnRefresh()
    self.ally_movespeed = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "ally_movespeed")
    self.ally_damage_out = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "ally_damage_out")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.stun_duration = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "stun_duration")
    self.damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "damage")
    if not IsServer() then return end
end

function modifier_kakashi_susano_ally:OnIntervalThink()
    if not IsServer() then return end
    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_8") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
    for _, enemy in pairs(enemies) do
        if enemy ~= self:GetParent() and not self.targets[enemy:entindex()] then
            self.targets[enemy:entindex()] = true
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self.stun_duration * (1-enemy:GetStatusResistance())})
            if not enemy:IsMagicImmune() then
                ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
            end
        end
    end
end

function modifier_kakashi_susano_ally:GetEffectName()
    return "particles/kakashi/susano_buff.vpcf"
end

function modifier_kakashi_susano_ally:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_kakashi_susano_ally:GetModifierDamageOutgoing_Percentage()
    return self.ally_damage_out
end

function modifier_kakashi_susano_ally:GetModifierMoveSpeedBonus_Percentage()
    return self.ally_movespeed
end

modifier_kakashi_susano_enemy = class({})

function modifier_kakashi_susano_enemy:IsPurgable() return false end

function modifier_kakashi_susano_enemy:OnCreated()
    self.enemy_movespeed = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "enemy_movespeed")
    self.damage_incoming = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage_incoming")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.stun_duration = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "stun_duration")
    self.damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "damage")
    if not IsServer() then return end
    self.targets = {}
    local particle = ParticleManager:CreateParticle( "particles/kakashi_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( particle, 1, Vector( 80, 80, 0 ) )
    self:AddParticle( particle, false, false, -1, false, false )
    self:StartIntervalThink(FrameTime())
end

function modifier_kakashi_susano_enemy:OnRefresh()
    self:OnCreated()
end

function modifier_kakashi_susano_enemy:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _, enemy in pairs(enemies) do
        if enemy ~= self:GetParent() and not self.targets[enemy:entindex()] then
            self.targets[enemy:entindex()] = true
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self.stun_duration * (1-enemy:GetStatusResistance())})
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        end
    end
end

function modifier_kakashi_susano_enemy:GetEffectName()
    return "particles/kakashi/susano_buff.vpcf"
end

function modifier_kakashi_susano_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_kakashi_susano_enemy:GetModifierIncomingDamage_Percentage()
    return self.damage_incoming
end

function modifier_kakashi_susano_enemy:GetModifierMoveSpeedBonus_Percentage()
    return self.enemy_movespeed
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_kakashi_ligning_sphere", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kakashi_ligning_sphere_debuff", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

kakashi_ligning_sphere = class({})

function kakashi_ligning_sphere:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_ligning_sphere:GetCastRange(location, target)
    return ability_manager:GetValueExort(self, self:GetCaster(), "range")
end

function kakashi_ligning_sphere:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and not self:GetCaster():HasTalent("special_bonus_birzha_kakashi_7") then
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

function kakashi_ligning_sphere:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    target:AddNewModifier(self:GetCaster(), self, "modifier_kakashi_ligning_sphere", {})
end

modifier_kakashi_ligning_sphere = class({})

function modifier_kakashi_ligning_sphere:IsPurgable() return true end
function modifier_kakashi_ligning_sphere:IsHidden() return true end

function modifier_kakashi_ligning_sphere:OnCreated()
    if not IsServer() then return end
    self.delay = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "delay")
    self.damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage")
    self.duration = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_1")
    self.delay_tick = self.delay / 3

    self.particle = ParticleManager:CreateParticle("particles/kakashi_timerstack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(0,3,0))
    self:AddParticle(self.particle, false, false, -1, false, true)

    self:StartIntervalThink(0.1)
end

function modifier_kakashi_ligning_sphere:OnIntervalThink()
    if not IsServer() then return end

    self.delay = self.delay - 0.1

    if self.delay <= self.delay_tick then
       ParticleManager:SetParticleControl(self.particle, 1, Vector(0,1,0)) 
    elseif self.delay <= self.delay_tick * 2 then
        ParticleManager:SetParticleControl(self.particle, 1, Vector(0,2,0))
    elseif self.delay <= self.delay_tick * 3 then
        ParticleManager:SetParticleControl(self.particle, 1, Vector(0,3,0))
    end

    if self.delay <= 0 then
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle, 0, Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, self:GetParent():GetAbsOrigin().z))
        ParticleManager:SetParticleControl(particle, 1, Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, 2000))
        ParticleManager:SetParticleControl(particle, 2, Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, self:GetParent():GetAbsOrigin().z))
        if not self:GetParent():IsMagicImmune() or self:GetCaster():HasTalent("special_bonus_birzha_kakashi_7") then
            self:GetParent():EmitSound("Hero_Zuus.LightningBolt")
            if not self:GetParent():IsMagicImmune() then
                ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
            end
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kakashi_ligning_sphere_debuff", {duration = self.duration * (1-self:GetParent():GetStatusResistance())})
        end
        self:Destroy()
    end
end

modifier_kakashi_ligning_sphere_debuff = class({})

function modifier_kakashi_ligning_sphere_debuff:IsHidden() return false end

function modifier_kakashi_ligning_sphere_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_kakashi_ligning_sphere_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -100
end

function modifier_kakashi_ligning_sphere_debuff:CheckState()
    return {
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_SILENCED] = true,
    }
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_kakashi_meteor_thinker", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

kakashi_meteor = class({})

function kakashi_meteor:GetCastRange(location, target)
    return ability_manager:GetValueWex(self, self:GetCaster(), "range")
end

function kakashi_meteor:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function kakashi_meteor:GetCooldown(level)
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    if exort then
        local exort_level = exort:GetLevel()-1
        return self.BaseClass.GetCooldown( self, exort_level )
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_meteor:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local bonus_count = 1
    if self:GetCaster():HasShard() then
        bonus_count = bonus_count + 1
    end
    CreateModifierThinker(self:GetCaster(), self, "modifier_kakashi_meteor_thinker", {creator = self:GetCaster():entindex(), bonus_count = bonus_count}, point, self:GetCaster():GetTeamNumber(), false)
end

modifier_kakashi_meteor_thinker = class({})

function modifier_kakashi_meteor_thinker:IsHidden() return true end

function modifier_kakashi_meteor_thinker:OnCreated(params)
    if not IsServer() then return end
    self.creator = EntIndexToHScript(params.creator)
    self.bonus_count = params.bonus_count
    if self.creator then
        self.start_origin = self:GetParent():GetAbsOrigin()
        local delay = self:GetAbility():GetSpecialValueFor("delay") - 0.5
        self.direction = self:GetParent():GetAbsOrigin() - self.creator:GetAbsOrigin()
        self.direction.z = 0
        self.direction = self.direction:Normalized()
        self:StartIntervalThink(delay)
        local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl( effect_cast, 0, self.creator:GetAbsOrigin() + Vector( 0, 0, 1000 ) )
        ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( delay, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        for i=0, 4 do
            local thunder = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_shard.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl( thunder, 0, self.creator:GetAbsOrigin() + Vector( 0, 0, 1000 ) )
            ParticleManager:SetParticleControl( thunder, 1, self:GetParent():GetAbsOrigin() + RandomVector(i*25))
        end

        EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "Hero_Invoker.ChaosMeteor.Cast", self:GetCaster() )
    else
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_kakashi_meteor_thinker:OnIntervalThink()
    if not IsServer() then return end
    EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "Hero_Invoker.ChaosMeteor.Impact", self:GetCaster() )
    self:MeteorDamage()
    if self.bonus_count > 0 then
        self:CheckUnitsInRadius()
    end
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_kakashi_meteor_thinker:CheckUnitsInRadius()
    if not IsServer() then return end
    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_7") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
    if #enemies <= 0 then return end
    CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_kakashi_meteor_thinker", {creator = self:GetParent():entindex(), bonus_count = self.bonus_count - 1}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end

function modifier_kakashi_meteor_thinker:MeteorDamage()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_7") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
    if #enemies <= 0 then return end

    local duration = 0
    local damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage")
    local stun_duration = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "stun_duration_main")
    local stun_duration_second = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "stun_duration_second")
    if self.original == 1 then
        duration = stun_duration
    else
        duration = stun_duration_second
    end

    for _, enemy in pairs(enemies) do
        if not enemy:HasModifier("modifier_fountain_passive_invul") then
            local thunder = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_shard.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl( thunder, 0, enemy:GetAbsOrigin() + Vector( 0, 0, 1000 ) )
            ParticleManager:SetParticleControl( thunder, 1, enemy:GetAbsOrigin())
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = duration * (1-enemy:GetStatusResistance())})
            if not enemy:IsMagicImmune() then
                ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
            end
        end
    end
end
------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_kakashi_sharingan", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

kakashi_sharingan = class({})

function kakashi_sharingan:IsRefreshable() return false end

function kakashi_sharingan:GetIntrinsicModifierName()
    return "modifier_kakashi_sharingan"
end

function kakashi_sharingan:GetBehavior()
    local modifier_stacks = self:GetCaster():GetModifierStackCount("modifier_kakashi_sharingan", self:GetCaster())
    if modifier_stacks == 1 or modifier_stacks == 5 then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
    elseif modifier_stacks == 2 or modifier_stacks == 4 or modifier_stacks == 6 or modifier_stacks == 9 then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
    elseif modifier_stacks == 3 or modifier_stacks == 7 or modifier_stacks == 8 then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
    else
        return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
    end
end

function kakashi_sharingan:GetManaCost(iLevel)
    local abilities_copy = {
        [1] = "kakashi_lightning",
        [2] = "kakashi_raikiri",
        [3] = "kakashi_lightning_hit",
        [4] = "kakashi_shadow_clone",
        [5] = "kakashi_tornado",
        [6] = "kakashi_graze_wave",
        [7] = "kakashi_susano",
        [8] = "kakashi_ligning_sphere",
        [9] = "kakashi_meteor",
    } 
    local manacost = 0
    local modifier_stacks = self:GetCaster():GetModifierStackCount("modifier_kakashi_sharingan", self:GetCaster())
    for id, abiliti_name in pairs(abilities_copy) do
        if id == modifier_stacks then
            local ability = self:GetCaster():FindAbilityByName(abiliti_name)
            if ability then
                manacost = ability:GetManaCost(iLevel)
                break
            end
        end
    end
    return manacost
end

function kakashi_sharingan:GetCastRange(location, target)
    local abilities_copy = {
        [1] = "kakashi_lightning",
        [2] = "kakashi_raikiri",
        [3] = "kakashi_lightning_hit",
        [4] = "kakashi_shadow_clone",
        [5] = "kakashi_tornado",
        [6] = "kakashi_graze_wave",
        [7] = "kakashi_susano",
        [8] = "kakashi_ligning_sphere",
        [9] = "kakashi_meteor",
    } 
    local cast_range = 0
    local modifier_stacks = self:GetCaster():GetModifierStackCount("modifier_kakashi_sharingan", self:GetCaster())
    for id, abiliti_name in pairs(abilities_copy) do
        if id == modifier_stacks then
            local ability = self:GetCaster():FindAbilityByName(abiliti_name)
            if ability then
                cast_range = ability:GetCastRange(location, target)
                break
            end
        end
    end
    return cast_range
end

function kakashi_sharingan:CastFilterResultTarget( hTarget )
    if not IsServer() then return UF_SUCCESS end
        local abilities_copy = {
        [1] = "kakashi_lightning",
        [2] = "kakashi_raikiri",
        [3] = "kakashi_lightning_hit",
        [4] = "kakashi_shadow_clone",
        [5] = "kakashi_tornado",
        [6] = "kakashi_graze_wave",
        [7] = "kakashi_susano",
        [8] = "kakashi_ligning_sphere",
        [9] = "kakashi_meteor",
    } 
    local ability_head = self
    local modifier_stacks = self:GetCaster():GetModifierStackCount("modifier_kakashi_sharingan", self:GetCaster())
    for id, abiliti_name in pairs(abilities_copy) do
        if id == modifier_stacks then
            local ability = self:GetCaster():FindAbilityByName(abiliti_name)
            if ability then
                ability_head = ability
                break
            end
        end
    end

    local nResult = UnitFilter(
        hTarget,
        ability_head:GetAbilityTargetTeam(),
        ability_head:GetAbilityTargetType(),
        ability_head:GetAbilityTargetFlags(),
        ability_head:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function kakashi_sharingan:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return 30
end

function kakashi_sharingan:OnSpellStart()
    if not IsServer() then return end
    if self.ability_name == nil then return end
    local ability = self:GetCaster():FindAbilityByName(self.ability_name)
    if ability == nil then return end
    local point = self:GetCursorPosition()
    local target = self:GetCursorTarget()
    ability:OnSpellStart()
    local caster = self:GetCaster()
    caster:EmitSound("kakashi_sharingan")
    caster:SetMaterialGroup("event")

    if self.ability_name == "kakashi_ligning_sphere" then
        local sphere = self:GetCaster():FindAbilityByName("kakashi_ligning_sphere")
        if sphere then
            sphere:UseResources(false, false, false, true)
        end
    end

    self.ability_name = nil
    local modifier = self:GetCaster():FindModifierByName("modifier_kakashi_sharingan")
    if modifier then
        modifier:SetStackCount(0)
    end

    local particle = ParticleManager:CreateParticle("particles/kakashi_sharingan.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())

    Timers:CreateTimer(3, function()
        caster:SetMaterialGroup("default")
    end)
end

modifier_kakashi_sharingan = class({})

function modifier_kakashi_sharingan:IsHidden() return self:GetStackCount() == 0 end

function modifier_kakashi_sharingan:GetTexture()
    if self:GetStackCount() == 1 then return "kakashi/lightning" end
    if self:GetStackCount() == 2 then return "kakashi/raikiri" end
    if self:GetStackCount() == 3 then return "kakashi/lightning_hit" end
    if self:GetStackCount() == 4 then return "kakashi/shadow_clone" end
    if self:GetStackCount() == 5 then return "kakashi/tornado" end
    if self:GetStackCount() == 6 then return "kakashi/graze_wave" end
    if self:GetStackCount() == 7 then return "kakashi/susano" end
    if self:GetStackCount() == 8 then return "kakashi/ligning_sphere" end
    if self:GetStackCount() == 9 then return "kakashi/meteor" end
end

function modifier_kakashi_sharingan:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }

    return funcs
end

function modifier_kakashi_sharingan:OnAbilityExecuted( params )
    local hAbility = params.ability
    if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
        return 0
    end

    if hAbility:IsToggle() or hAbility:IsItem() then
        return 0
    end

    local abilities_copy = {
        [1] = "kakashi_lightning",
        [2] = "kakashi_raikiri",
        [3] = "kakashi_lightning_hit",
        [4] = "kakashi_shadow_clone",
        [5] = "kakashi_tornado",
        [6] = "kakashi_graze_wave",
        [7] = "kakashi_susano",
        [8] = "kakashi_ligning_sphere",
        [9] = "kakashi_meteor",
    }

    for _, ability_name in pairs(abilities_copy) do
        if ability_name == hAbility:GetAbilityName() then
            self:GetAbility().ability_name = ability_name
            self:SetStackCount(_)
        end
    end

    if IsServer() then
        if self:GetCaster():HasTalent("special_bonus_birzha_kakashi_6") then
            local ability = self:GetCaster():FindAbilityByName("kakashi_tornado")
            if ability then
                if hAbility ~= ability and hAbility:GetAbilityName() ~= "kakashi_quas" and hAbility:GetAbilityName() ~= "kakashi_sharingan"and hAbility:GetAbilityName() ~= "kakashi_invoke" and hAbility:GetAbilityName() ~= "kakashi_wex" and hAbility:GetAbilityName() ~= "kakashi_exort" then
                    if ability:GetCurrentAbilityCharges() < ability:GetMaxAbilityCharges(1) then
                        ability:SetCurrentAbilityCharges(ability:GetCurrentAbilityCharges() + 1)
                    end
                end
            end
        end
    end

    return 0
end