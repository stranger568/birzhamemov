LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_quas = class({})

LinkLuaModifier( "modifier_kakashi_quas", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )

function kakashi_quas:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_kakashi_quas",
        {  }
    )
    self.invoke:AddOrb( modifier )
end

function kakashi_quas:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "kakashi_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_kakashi_quas", self:GetLevel())
    end
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    local invoke = self:GetCaster():FindAbilityByName("kakashi_invoke")
    if quas and wex and exort and invoke then
        if quas:GetLevel() >= 6 and wex:GetLevel() >= 6 and exort:GetLevel() >= 6 then
            invoke:SetLevel(4)
            return
        end
        if quas:GetLevel() >= 4 and wex:GetLevel() >= 4 and exort:GetLevel() >= 4 then
            invoke:SetLevel(3)
            return
        end
        if quas:GetLevel() >= 2 and wex:GetLevel() >= 2 and exort:GetLevel() >= 2 then
            invoke:SetLevel(2)
            return
        end
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

function kakashi_wex:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self, 
        "modifier_kakashi_wex",
        {  }
    )
    self.invoke:AddOrb( modifier )
end

function kakashi_wex:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "kakashi_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_kakashi_wex", self:GetLevel())
    end
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    local invoke = self:GetCaster():FindAbilityByName("kakashi_invoke")
    if quas and wex and exort and invoke then
        if quas:GetLevel() >= 6 and wex:GetLevel() >= 6 and exort:GetLevel() >= 6 then
            invoke:SetLevel(4)
            return
        end
        if quas:GetLevel() >= 4 and wex:GetLevel() >= 4 and exort:GetLevel() >= 4 then
            invoke:SetLevel(3)
            return
        end
        if quas:GetLevel() >= 2 and wex:GetLevel() >= 2 and exort:GetLevel() >= 2 then
            invoke:SetLevel(2)
            return
        end
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
    self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
    self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
end

function modifier_kakashi_wex:OnRefresh( kv )
    self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
    self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
end

function modifier_kakashi_wex:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_kakashi_wex:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_bonus
end
function modifier_kakashi_wex:GetModifierAttackSpeedBonus_Constant()
    return self.as_bonus
end

kakashi_exort = class({})

LinkLuaModifier( "modifier_kakashi_exort", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )

function kakashi_exort:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_kakashi_exort",
        {  }
    )
    self.invoke:AddOrb( modifier )
end

function kakashi_exort:OnUpgrade()
    if not self.invoke then
        local invoke = self:GetCaster():FindAbilityByName( "kakashi_invoke" )
        if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
        self.invoke = invoke
    else
        self.invoke:UpdateOrb("modifier_kakashi_exort", self:GetLevel())
    end
    local quas = self:GetCaster():FindAbilityByName("kakashi_quas")
    local wex = self:GetCaster():FindAbilityByName("kakashi_wex")
    local exort = self:GetCaster():FindAbilityByName("kakashi_exort")
    local invoke = self:GetCaster():FindAbilityByName("kakashi_invoke")
    if quas and wex and exort and invoke then
        if quas:GetLevel() >= 6 and wex:GetLevel() >= 6 and exort:GetLevel() >= 6 then
            invoke:SetLevel(4)
            return
        end
        if quas:GetLevel() >= 4 and wex:GetLevel() >= 4 and exort:GetLevel() >= 4 then
            invoke:SetLevel(3)
            return
        end
        if quas:GetLevel() >= 2 and wex:GetLevel() >= 2 and exort:GetLevel() >= 2 then
            invoke:SetLevel(2)
            return
        end
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
    self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
end

function modifier_kakashi_exort:OnRefresh( kv )
    self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" ) 
end

function modifier_kakashi_exort:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end
function modifier_kakashi_exort:GetModifierPreAttack_BonusDamage()
    return self.damage
end



kakashi_invoke = class({})
kakashi_empty1 = class({})
kakashi_empty2 = class({})
orb_manager = {}
ability_manager = {}

orb_manager.orb_order = "qwe"
orb_manager.invoke_list = {
    ["qqq"] = "kakashi_taa",
    ["qqw"] = "kakashi_HUSTLE",
    ["qqe"] = "kakashi_ElFura",
    ["www"] = "kakashi_spit",
    ["qww"] = "kakashi_clubnogirls",
    ["wwe"] = "kakashi_DrinkSomePepper",
    ["eee"] = "kakashi_AiAiAi",
    ["qee"] = "kakashi_meat_hook",
    ["wee"] = "kakashi_Binding",
    ["qwe"] = "kakashi_sha",
}

orb_manager.modifier_list = {
    ["q"] = "modifier_kakashi_quas",
    ["w"] = "modifier_kakashi_wex",
    ["e"] = "modifier_kakashi_exort",

    ["modifier_kakashi_quas"] = "q",
    ["modifier_kakashi_wex"] = "w",
    ["modifier_kakashi_exort"] = "e",
}

function kakashi_invoke:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return 1
    end
    return 2
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
    print(self.init_check)
    if self.init_check == nil then
        self.init_check = true
    end
    print(self.init_check)
    if self.init_check then
        local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
        CustomGameEventManager:Send_ServerToPlayer(Player, "InitAbilityKakashi", {} )
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
    print(self.init_check)
    self:GetCaster():FindAbilityByName("kakashi_taa"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_HUSTLE"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_ElFura"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_spit"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_clubnogirls"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_DrinkSomePepper"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_AiAiAi"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_meat_hook"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_Binding"):SetLevel(self:GetLevel())
    self:GetCaster():FindAbilityByName("kakashi_sha"):SetLevel(self:GetLevel())
end

function kakashi_invoke:AddOrb( modifier )
    self.orb_manager:Add( modifier )
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

kakashi_sha = class({}) 

function kakashi_sha:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_sha:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_sha:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_sha:GetAOERadius()
    return self:GetSpecialValueFor( "aoe_radius" )
end

function kakashi_sha:OnSpellStart()
    if not IsServer() then return end
    local damage = self:GetSpecialValueFor("damage")
    local radius = self:GetSpecialValueFor("aoe_radius")
    local knockback_distance = self:GetSpecialValueFor("knockback_distance")
    local duration = self:GetSpecialValueFor("stun_duration")
    if self:GetCursorTarget():TriggerSpellAbsorb( self ) then return end
    self:GetCaster():EmitSound("bulletsha")  
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCursorTarget():GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy );
        ParticleManager:SetParticleControlEnt( particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true );

        local distance = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
        local direction = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + knockback_distance)
        local knockbackProperties =
        {
            center_x = bump_point.x,
            center_y = bump_point.y,
            center_z = bump_point.z,
            duration = 0.75,
            knockback_duration = 0.75,
            knockback_distance = knockback_distance,
            knockback_height = 150
        }
        enemy:RemoveModifierByName("modifier_knockback")
        enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )
        Timers:CreateTimer(0.75, function()
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration})
        end)
    end
end

kakashi_taa = class({}) 

function kakashi_taa:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_taa:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_taa:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_taa:GetAOERadius()
    return self:GetSpecialValueFor( "aoe_radius" )
end

function kakashi_taa:OnSpellStart()
    if not IsServer() then return end
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_2")
    local radius = self:GetSpecialValueFor("aoe_radius")
    local knockback_height = self:GetSpecialValueFor("knockback_height")
    if self:GetCursorTarget():TriggerSpellAbsorb( self ) then return end
    self:GetCaster():EmitSound("bullettaa")  
    local particle_start = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
    ParticleManager:SetParticleControlEnt( particle_start, 0, self:GetCursorTarget(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCursorTarget():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle_start, 1, self:GetCursorTarget(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( particle_start, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
    ParticleManager:ReleaseParticleIndex( particle_start )

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCursorTarget():GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy );
        ParticleManager:SetParticleControlEnt( particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true );

        local distance = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
        local direction = (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 50)
        local knockbackProperties =
        {
            center_x = bump_point.x,
            center_y = bump_point.y,
            center_z = bump_point.z,
            duration = 1 * (1 - enemy:GetStatusResistance()),
            knockback_duration = 1 * (1 - enemy:GetStatusResistance()),
            knockback_distance = 50,
            knockback_height = knockback_height
        }
        enemy:RemoveModifierByName("modifier_knockback")
        enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )
    end
end

LinkLuaModifier( "modifier_kakashi_HUSTLE", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE )

kakashi_HUSTLE = class({})

function kakashi_HUSTLE:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_HUSTLE:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_HUSTLE:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kakashi_HUSTLE", {duration = duration})
    self:GetCaster():EmitSound("botan2")
end

modifier_kakashi_HUSTLE = class({})

function modifier_kakashi_HUSTLE:IsPurgable()
    return false
end

function modifier_kakashi_HUSTLE:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("botan2")
end

function modifier_kakashi_HUSTLE:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_strafe.vpcf"
end

function modifier_kakashi_HUSTLE:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kakashi_HUSTLE:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }

    return decFuncs
end

function modifier_kakashi_HUSTLE:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_kakashi_HUSTLE:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }

    return state
end

function modifier_kakashi_HUSTLE:GetModifierPreAttack_CriticalStrike()
    if not IsServer() then return end    
    local chance = self:GetAbility():GetSpecialValueFor('chance')   
    local critical_damage = self:GetAbility():GetSpecialValueFor('critical_damage')           
    if RandomInt(1, 100) <= chance then        
        return critical_damage
    end
    return nil
end


LinkLuaModifier( "modifier_kakashi_elfura_debuff", "abilities/heroes/kakashi.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kakashi_elfura_debuff_disarm", "abilities/heroes/kakashi.lua",LUA_MODIFIER_MOTION_NONE )

kakashi_ElFura = class({})

function kakashi_ElFura:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_ElFura:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_ElFura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_ElFura:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function kakashi_ElFura:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local target_loc = self:GetCursorPosition()
        local caster_loc = caster:GetAbsOrigin()
        local distance = self:GetCastRange(caster_loc,caster)
        local direction

        if target_loc == caster_loc then
            direction = caster:GetForwardVector()
        else
            direction = (target_loc - caster_loc):Normalized()
        end
        
        local projectile =
            {
                Ability             = self,
                EffectName          = "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6.vpcf",
                vSpawnOrigin        = caster_loc,
                fDistance           = 1100,
                fStartRadius        = 175,
                fEndRadius          = 225,
                Source              = caster,
                bHasFrontalCone     = false,
                bReplaceExisting    = false,
                iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime         = GameRules:GetGameTime() + 5.0,
                bDeleteOnHit        = false,
                vVelocity           = Vector(direction.x,direction.y,0) * 1100,
                bProvidesVision     = false,
                ExtraData           = {index = index, damage = damage}
            }
        ProjectileManager:CreateLinearProjectile(projectile)
        caster:EmitSound("Hero_Invoker.DeafeningBlast")
    end
end

function kakashi_ElFura:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local caster = self:GetCaster()
        local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
        local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        local bump_point = caster:GetAbsOrigin() - direction * (distance + 150)

        local knockbackProperties =
        {
             center_x = bump_point.x,
             center_y = bump_point.y,
             center_z = bump_point.z,
             duration = 0.75,
             knockback_duration = 0.75,
             knockback_distance = 700,
             knockback_height = 0
        }
        target:RemoveModifierByName("modifier_knockback")
        target:AddNewModifier(target, self, "modifier_knockback", knockbackProperties)
        if target:HasModifier("modifier_kakashi_elfura_debuff") then return end
        target:AddNewModifier(caster, self, "modifier_kakashi_elfura_debuff", {duration = 0.8})
    end
end

modifier_kakashi_elfura_debuff = class({})

function modifier_kakashi_elfura_debuff:IsHidden()
    return true
end

function modifier_kakashi_elfura_debuff:IsPurgable()
    return false
end

function modifier_kakashi_elfura_debuff:IsPurgeException()
    return true
end

function modifier_kakashi_elfura_debuff:OnCreated( )
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    local duration = self:GetAbility():GetSpecialValueFor('duration')
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        Timers:CreateTimer(0.75, function()
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kakashi_elfura_debuff_disarm", {duration = duration * (1 - self:GetParent():GetStatusResistance())})
    end)
end

modifier_kakashi_elfura_debuff_disarm = class({})

function modifier_kakashi_elfura_debuff_disarm:IsPurgable()
    return false
end

function modifier_kakashi_elfura_debuff_disarm:IsPurgeException()
    return true
end

function modifier_kakashi_elfura_debuff_disarm:GetEffectName() return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf" end
function modifier_kakashi_elfura_debuff_disarm:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_kakashi_elfura_debuff_disarm:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_kakashi_elfura_debuff_disarm:CheckState() 
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
  }

  return state
end

function modifier_kakashi_elfura_debuff_disarm:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('slow_pct')
end

LinkLuaModifier( "modifier_kakashi_spit", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_spit = class({})

modifier_kakashi_spit = class({})

function kakashi_spit:GetIntrinsicModifierName() 
return "modifier_kakashi_spit"
end

function kakashi_spit:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_bp_never_reward") then
        return "Never/SpitArcana"
    end
    return "Never/Spit"
end

function modifier_kakashi_spit:OnCreated()
    if not IsServer() then return end
    self.active = false
    self.particle_spit = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
    if IsUnlockedInPass(self:GetCaster():GetPlayerID(), "reward47") then
        self.particle_spit = "particles/never_arcana/sf_fire_arcana_shadowraze.vpcf"
    end
end

function modifier_kakashi_spit:IsHidden()
    return true
end

function modifier_kakashi_spit:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_kakashi_spit:OnAttackLanded( keys )
    if IsServer() then
        local attacker = self:GetParent()
        if self.active == false then return end
        if attacker ~= keys.attacker then
            return
        end

        if attacker:IsIllusion() or attacker:PassivesDisabled() then
            return
        end

        local target = keys.target
        if attacker:GetTeam() == target:GetTeam() then
            return
        end 
        if target:IsOther() then
            return nil
        end
        if not self:GetAbility():IsFullyCastable() then return end

        local duration = self:GetAbility():GetSpecialValueFor("duration")
        local chance = self:GetAbility():GetSpecialValueFor("chance")
        local random = RandomInt(1, 100)

        if random <= chance then    
            target:AddNewModifier(attacker, self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration})
            attacker:EmitSound("neverbash")
            local damage = self:GetAbility():GetSpecialValueFor("damage")
            local damage_table = {}
            damage_table.attacker = attacker
            damage_table.damage_type = self:GetAbility():GetAbilityDamageType()
            damage_table.ability = self:GetAbility()
            damage_table.victim = target
            damage_table.damage = damage
            ApplyDamage(damage_table)
            self:GetAbility():UseResources(false, false, true)
            local SpitEffect = ParticleManager:CreateParticle(self.particle_spit, PATTACH_ABSORIGIN, target)
            if IsUnlockedInPass(self:GetCaster():GetPlayerID(), "reward47") then
                ParticleManager:SetParticleControl(SpitEffect, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(SpitEffect, 1, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(SpitEffect, 3, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(SpitEffect, 5, target:GetAbsOrigin())
            end
        end
    end
end

kakashi_clubnogirls = class({})
LinkLuaModifier("modifier_kakashi_clubnogirls","abilities/heroes/kakashi.lua",LUA_MODIFIER_MOTION_NONE)

function kakashi_clubnogirls:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function kakashi_clubnogirls:GetAOERadius()
    return self:GetSpecialValueFor("radius") + 50
end

function kakashi_clubnogirls:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_clubnogirls:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_clubnogirls:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_clubnogirls:OnSpellStart()
    if not IsServer() then return end
    
    local cursor_pos = self:GetCaster():GetCursorPosition()
    local num = self:GetSpecialValueFor("count")
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage_script") + (self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_4")-100)
    local hero_vector = GetGroundPosition(cursor_pos + Vector(0, radius, 0), nil)

    self:GetCaster():EmitSound("bezbab")
    if self.particle ~= nil then
        ParticleManager:DestroyParticle(self.particle,false)
    end
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_POINT, self:GetCaster())
    ParticleManager:SetParticleControl(self.particle, 0, cursor_pos)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(radius+50,1,1))
    Timers:CreateTimer(duration,function()
        ParticleManager:DestroyParticle(self.particle,false)
    end)

    for hero = 1, num do
        local t = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=damage}, 1, 1, true, false ) 
        for k, v in pairs(t) do
            v:RemoveDonate()
            v:SetAbsOrigin(hero_vector)
            v:AddNewModifier(self:GetCaster(), self, "modifier_kakashi_clubnogirls", {})
        end
        hero_vector = RotatePosition(cursor_pos, QAngle(0, 360 / num, 0), hero_vector)
    end
end

modifier_kakashi_clubnogirls = class({})

function modifier_kakashi_clubnogirls:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_kakashi_clubnogirls:OnIntervalThink()
    if not IsServer() then return end

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        600,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        0,
        false
    )
    if #enemies > 0 then
        for enemy = 1, #enemies do
            if enemies[enemy] and enemies[enemy]:IsAlive() and not enemies[enemy]:IsAttackImmune() and not enemies[enemy]:IsInvulnerable() then
                self:GetParent():MoveToTargetToAttack(enemies[enemy])
            end
        end
    end
end

function modifier_kakashi_clubnogirls:IsHidden()
    return true
end

function modifier_kakashi_clubnogirls:CheckState()
    local state = {
    [MODIFIER_STATE_ROOTED] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_CANNOT_MISS] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }

    return state
end

LinkLuaModifier("modifier_kakashi_pepper", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE)

kakashi_DrinkSomePepper = class({})

function kakashi_DrinkSomePepper:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_DrinkSomePepper:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_1")
    local heal = self:GetSpecialValueFor("regen")
    caster:EmitSound("Hero_Terrorblade.Metamorphosis")
    caster:Heal( heal, self )
    caster:AddNewModifier(caster, self, "modifier_kakashi_pepper", { duration = duration } )
end

modifier_kakashi_pepper = class({})

function modifier_kakashi_pepper:IsPurgable()
    return true
end

function modifier_kakashi_pepper:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_kakashi_pepper:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_kakashi_pepper:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_kakashi_pepper:GetEffectName()
    return "particles/illidan/illidan_pepper_buff.vpcf"
end

function modifier_kakashi_pepper:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kakashi_pepper:GetStatusEffectName()
    return "particles/illidan/pepper_effect.vpcf" 
end

function modifier_kakashi_pepper:StatusEffectPriority()
    return 5
end

LinkLuaModifier( "modifier_kakashi_binding", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE )

kakashi_Binding = class({})

function kakashi_Binding:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_Binding:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_Binding:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_Binding:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    if target:TriggerSpellAbsorb( self ) then
        return
    end
    target:AddNewModifier(self:GetCaster(), self, "modifier_kakashi_binding", {duration = duration * (1 - target:GetStatusResistance())})
    target:EmitSound("gachifuck")
end

modifier_kakashi_binding = class({})

function modifier_kakashi_binding:IsPurgable()
    return true
end

function modifier_kakashi_binding:IsPurgeException()
    return true
end

function modifier_kakashi_binding:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
end

function modifier_kakashi_binding:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
    }

    return state
end

LinkLuaModifier( "modifier_kakashi_meat_hook", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_kakashi_meat_hook_debuff", "abilities/heroes/kakashi.lua", LUA_MODIFIER_MOTION_HORIZONTAL  )

kakashi_meat_hook = class({})

function kakashi_meat_hook:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "cooldown_scepter" )  
    end  
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_meat_hook:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_meat_hook:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_meat_hook:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_2 )
    return true
end

function kakashi_meat_hook:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_2 )
end

function kakashi_meat_hook:OnSpellStart()
    self.bChainAttached = false
    if self.hVictim ~= nil then
        self.hVictim:InterruptMotionControllers( true )
    end
    self.hook_damage = self:GetSpecialValueFor( "damage" )
    if self:GetCaster():HasScepter() then
        self.hook_damage = self:GetSpecialValueFor( "damage_scepter" )  
    end  
    self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
    self.hook_width = self:GetSpecialValueFor( "hook_width" )
    self.hook_distance = self:GetSpecialValueFor( "hook_distance" )
    self.hook_followthrough_constant = 0.65

    self.vision_radius = self:GetSpecialValueFor( "vision_radius" )  
    self.vision_duration = self:GetSpecialValueFor( "vision_duration" )  
    
    if self:GetCaster() and self:GetCaster():IsHero() then
        local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
        if hHook ~= nil then
            hHook:AddEffects( EF_NODRAW )
        end
    end

    self.vStartPosition = self:GetCaster():GetOrigin()
    self.vProjectileLocation = vStartPosition

    local vDirection = self:GetCursorPosition() - self.vStartPosition
    vDirection.z = 0.0

    if self:GetCursorPosition() == self:GetCaster():GetOrigin() then
        vDirection = self:GetCaster():GetForwardVector()
    else
        vDirection = self:GetCursorPosition() - self.vStartPosition
    end

    vDirection.z = 0.0

    local vDirection = ( vDirection:Normalized() ) * self.hook_distance
    self.vTargetPosition = self.vStartPosition + vDirection

    local flFollowthroughDuration = ( self.hook_distance / self.hook_speed * self.hook_followthrough_constant )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kakashi_meat_hook", { duration = flFollowthroughDuration } )

    self.vHookOffset = Vector( 0, 0, 96 )
    local vHookTarget = self.vTargetPosition + self.vHookOffset
    local vKillswitch = Vector( ( ( self.hook_distance / self.hook_speed ) * 2 ), 0, 0 )

    self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
    ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin() + self.vHookOffset, true )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 1, vHookTarget )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 2, Vector( self.hook_speed, self.hook_distance, self.hook_width ) )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, vKillswitch )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

    EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )

    local info = {
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        vVelocity = vDirection:Normalized() * self.hook_speed,
        fDistance = self.hook_distance,
        fStartRadius = self.hook_width ,
        fEndRadius = self.hook_width ,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
    }

    ProjectileManager:CreateLinearProjectile( info )

    self.bRetracting = false
    self.hVictim = nil
    self.bDiedInHook = false
end

function kakashi_meat_hook:OnProjectileHit( hTarget, vLocation )
    if hTarget == self:GetCaster() then
        return false
    end

    if self.bRetracting == false then
        if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
            return false
        end

        local bTargetPulled = false
        if hTarget ~= nil then
            if hTarget:HasModifier("modifier_Daniil_LaughingRush_debuff") or hTarget:HasModifier("modifier_modifier_eul_cyclone_birzha") then
                return false
            end
            if hTarget:GetUnitName() == "npc_dota_zerkalo" then return false end
            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Pudge.AttackHookImpact", self:GetCaster())

            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_kakashi_meat_hook_debuff", nil )
            
            if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.hook_damage,
                        damage_type = DAMAGE_TYPE_PURE,     
                        ability = this
                    }

                ApplyDamage( damage )

                if not hTarget:IsAlive() then
                    self.bDiedInHook = true
                end

                if not hTarget:IsMagicImmune() then
                    hTarget:Interrupt()
                end
        
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
            end

            AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
            self.hVictim = hTarget
            bTargetPulled = true
        end

        local vHookPos = self.vTargetPosition
        local flPad = self:GetCaster():GetPaddedCollisionRadius()
        if hTarget ~= nil then
            vHookPos = hTarget:GetOrigin()
            flPad = flPad + hTarget:GetPaddedCollisionRadius()
        end

        local vVelocity = self.vStartPosition - vHookPos
        vVelocity.z = 0.0

        local flDistance = vVelocity:Length2D() - flPad
        vVelocity = vVelocity:Normalized() * self.hook_speed

        local info = {
            Ability = self,
            vSpawnOrigin = vHookPos,
            vVelocity = vVelocity,
            fDistance = flDistance,
            Source = self:GetCaster(),
        }

        ProjectileManager:CreateLinearProjectile( info )
        self.vProjectileLocation = vHookPos

        if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
            ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.vHookOffset, true )
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
        else
            ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true);
        end

        if hTarget ~= nil then
            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Pudge.AttackHookRetract", self:GetCaster())
        end

        self.bRetracting = true
    else
        if self:GetCaster() and self:GetCaster():IsHero() then
            local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
            if hHook ~= nil then
                hHook:RemoveEffects( EF_NODRAW )
            end
        end

        if self.hVictim ~= nil then
            local vFinalHookPos = vLocation
            self.hVictim:InterruptMotionControllers( true )
            self.hVictim:RemoveModifierByName( "modifier_kakashi_meat_hook_debuff" )

            local vVictimPosCheck = self.hVictim:GetOrigin() - vFinalHookPos 
            local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hVictim:GetPaddedCollisionRadius()
            if vVictimPosCheck:Length2D() > flPad then
                FindClearSpaceForUnit( self.hVictim, self.vStartPosition, false )
            end
        end

        self.hVictim = nil
        ParticleManager:DestroyParticle( self.nChainParticleFXIndex, true )
        EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
    end

    return true
end

function kakashi_meat_hook:OnProjectileThink( vLocation )
    self.vProjectileLocation = vLocation
end

modifier_kakashi_meat_hook = class({})

function modifier_kakashi_meat_hook:IsHidden()
    return true
end

function modifier_kakashi_meat_hook:IsPurgable()
    return false
end

function modifier_kakashi_meat_hook:CheckState()
    local state = {
    [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

modifier_kakashi_meat_hook_debuff = class({})

function modifier_kakashi_meat_hook_debuff:IsDebuff()
    return true
end

function modifier_kakashi_meat_hook_debuff:RemoveOnDeath()
    return false
end

function modifier_kakashi_meat_hook_debuff:IsPurgable()
    return false
end


function modifier_kakashi_meat_hook_debuff:OnCreated( kv )
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end

function modifier_kakashi_meat_hook_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_kakashi_meat_hook_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_kakashi_meat_hook_debuff:CheckState()
    if IsServer() then
        if self:GetCaster() ~= nil and self:GetParent() ~= nil then
            if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
                local state = {
                [MODIFIER_STATE_STUNNED] = true,
                }

                return state
            end
        end
    end

    local state = {}

    return state
end

function modifier_kakashi_meat_hook_debuff:UpdateHorizontalMotion( me, dt )
    if IsServer() then
        if self:GetAbility().hVictim ~= nil then
            self:GetAbility().hVictim:SetOrigin( self:GetAbility().vProjectileLocation )
            local vToCaster = self:GetAbility().vStartPosition - self:GetCaster():GetOrigin()
            local flDist = vToCaster:Length2D()
            if self:GetAbility().bChainAttached == false and flDist > 128.0 then 
                self:GetAbility().bChainAttached = true  
                ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetOrigin(), true )
                ParticleManager:SetParticleControl( self:GetAbility().nChainParticleFXIndex, 0, self:GetAbility().vStartPosition + self:GetAbility().vHookOffset )
            end                     
        end
    end
end

function modifier_kakashi_meat_hook_debuff:OnHorizontalMotionInterrupted()
    if IsServer() then
        if self:GetAbility().hVictim ~= nil then
            ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin() + self:GetAbility().vHookOffset, true )
            self:Destroy()
        end
    end
end

LinkLuaModifier("modifier_kakashi_AiAiAi_thinker", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kakashi_AiAiAi_debuff", "abilities/heroes/kakashi", LUA_MODIFIER_MOTION_NONE)

kakashi_AiAiAi = class({})

function kakashi_AiAiAi:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kakashi_AiAiAi:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kakashi_AiAiAi:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kakashi_AiAiAi:OnUpgrade()
    if not self.release_ability then
        self.release_ability = self:GetCaster():FindAbilityByName("kakashi_AiAiAi_slam")
    end
    
    if self.release_ability and not self.release_ability:IsTrained() then
        self.release_ability:SetLevel(1)
    end
end

function kakashi_AiAiAi:OnSpellStart()
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end
    EmitSoundOnClient("Hero_Ancient_Apparition.IceBlast.Tracker", self:GetCaster():GetPlayerOwner())
    local velocity  = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * 1500
    self.ice_blast_dummy = CreateModifierThinker(self:GetCaster(), self, "modifier_kakashi_AiAiAi_thinker", {x = velocity.x, y = velocity.y}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)

    local linear_projectile = {
        Ability             = self,
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = math.huge,
        fStartRadius        = 0,
        fEndRadius          = 0,
        Source              = self:GetCaster(),
        bDrawsOnMinimap     = true,
        bVisibleToEnemies   = false,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 30.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(velocity.x, velocity.y, 0),
        bProvidesVision     = true,
        iVisionRadius       = 650,
        iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
        
        ExtraData           =
        {
            direction_x     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).x,
            direction_y     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).y,
            direction_z     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).z,
            ice_blast_dummy = self.ice_blast_dummy:entindex(),
        }
    }

    self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
    
    if not self.release_ability then
        self.release_ability = self:GetCaster():FindAbilityByName("kakashi_AiAiAi_slam")
    end 
    
    if self.release_ability then
        self:GetCaster():SwapAbilities(self:GetName(), self.release_ability:GetName(), false, true)
    end
end

function kakashi_AiAiAi:OnProjectileThink_ExtraData(location, data)
    if data.ice_blast_dummy then
        EntIndexToHScript(data.ice_blast_dummy):SetAbsOrigin(location)
    end
    
    if not self:GetCaster():IsAlive() and self.release_ability then
        self.release_ability:OnSpellStart()
    end
end

function kakashi_AiAiAi:OnProjectileHit_ExtraData(target, location, data)
    if not target and data.ice_blast_dummy then
        local ice_blast_thinker_modifier = EntIndexToHScript(data.ice_blast_dummy):FindModifierByNameAndCaster("modifier_kakashi_AiAiAi_thinker", self:GetCaster())
        
        if ice_blast_thinker_modifier then
            ice_blast_thinker_modifier:Destroy()
        end
    end
end

modifier_kakashi_AiAiAi_thinker = class({})

function modifier_kakashi_AiAiAi_thinker:IsPurgable()    return false end

function modifier_kakashi_AiAiAi_thinker:OnCreated(params)
    if not IsServer() then return end
    local ice_blast_particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_initial.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
    ParticleManager:SetParticleControl(ice_blast_particle, 1, Vector(params.x, params.y, 0))
    self:AddParticle(ice_blast_particle, false, false, -1, false, false)
end

function modifier_kakashi_AiAiAi_thinker:OnDestroy()
    if not IsServer() then return end
    self.release_ability    = self:GetCaster():FindAbilityByName("kakashi_AiAiAi_slam")
    if self:GetAbility() and self:GetAbility():IsHidden() and self.release_ability then 
        self:GetCaster():SwapAbilities("kakashi_AiAiAi_slam", "kakashi_AiAiAi", false, true)
    end
    self:GetParent():RemoveSelf()
end

kakashi_AiAiAi_slam = class({})

function kakashi_AiAiAi_slam:OnSpellStart()
    if not self.ice_blast_ability then
        self.ice_blast_ability  = self:GetCaster():FindAbilityByName("kakashi_AiAiAi")
    end
    
    if self.ice_blast_ability then
        if self.ice_blast_ability.ice_blast_dummy and self.ice_blast_ability.initial_projectile then
            local vector    = self.ice_blast_ability.ice_blast_dummy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
            local velocity  = vector:Normalized() * math.max(vector:Length2D() / 2, 25000)
            local final_radius  = math.min(400 + ((vector:Length2D() / 1500) * 50), 1200)
            self:GetCaster():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast")
            AddFOWViewer(self:GetCaster():GetTeamNumber(), self.ice_blast_ability.ice_blast_dummy:GetAbsOrigin(), 650, 4, false)

            local linear_projectile = {
                Ability             = self,
                vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
                fDistance           = vector:Length2D(),
                fStartRadius        = 300,
                fEndRadius          = 300,
                Source              = self:GetCaster(),
                bHasFrontalCone     = false,
                bReplaceExisting    = false,
                iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
                iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime         = GameRules:GetGameTime() + 10.0,
                bDeleteOnHit        = true,
                vVelocity           = velocity,
                bProvidesVision     = true,
                iVisionRadius       = 500,
                iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
                
                ExtraData           =
                {
                    marker_particle = marker_particle,
                    final_radius    = final_radius
                }
            }

            self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
            self.ice_blast_ability.ice_blast_dummy:Destroy()
            ProjectileManager:DestroyLinearProjectile(self.ice_blast_ability.initial_projectile)
            self.ice_blast_ability.ice_blast_dummy      = nil
            self.ice_blast_ability.initial_projectile   = nil
        end
        --self:GetCaster():SwapAbilities("kakashi_AiAiAi_slam", "kakashi_AiAiAi", false, true)
    end
end

function kakashi_AiAiAi_slam:OnProjectileThink_ExtraData(location, data)
    if self.ice_blast_ability then
        AddFOWViewer(self:GetCaster():GetTeamNumber(), location, 500, 3, false)
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        local duration      = self.ice_blast_ability:GetSpecialValueFor("frostbite_duration")
        local stun_duration      = self.ice_blast_ability:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_3")
        for _, enemy in pairs(enemies) do
            local ice_blast_modifier = nil
            
            if enemy:IsInvulnerable() then
                ice_blast_modifier = enemy:AddNewModifier(enemy, self.ice_blast_ability, "modifier_kakashi_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                        caster_entindex = self:GetCaster():entindex()
                    }
                )
            else
                ice_blast_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_kakashi_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                    }
                )
            end
        end
    end
end

function kakashi_AiAiAi_slam:OnProjectileHit_ExtraData(target, location, data)
    if not target and self.ice_blast_ability then
        EmitSoundOnLocationWithCaster(location, "V1latAiaiai", self:GetCaster())

        local particle = ParticleManager:CreateParticle("particles/v1lat/v1lat_aiaiai.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle, 0, location)
        ParticleManager:ReleaseParticleIndex(particle)
    
        if data.marker_particle then
            ParticleManager:DestroyParticle(data.marker_particle, false)
            ParticleManager:ReleaseParticleIndex(data.marker_particle)
        end

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, data.final_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    
        local damageTable = {
            victim          = nil,
            damage          = self.ice_blast_ability:GetSpecialValueFor("damage"),
            damage_type     = self.ice_blast_ability:GetAbilityDamageType(),
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            attacker        = self:GetCaster(),
            ability         = self
        }
        
        local duration      = self.ice_blast_ability:GetSpecialValueFor("frostbite_duration")
        local stun_duration      = self.ice_blast_ability:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kakashi_3")
    
        for _, enemy in pairs(enemies) do
            local ice_blast_modifier = nil
            
            if enemy:IsInvulnerable() then
                ice_blast_modifier = enemy:AddNewModifier(enemy, self.ice_blast_ability, "modifier_kakashi_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                        caster_entindex = self:GetCaster():entindex()
                    }
                )
            else
                ice_blast_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_kakashi_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                    }
                )
            end

            if not enemy:IsMagicImmune() then
                damageTable.victim = enemy
                ApplyDamage(damageTable)
                enemy:AddNewModifier( self:GetCaster(), self.ice_blast_ability, "modifier_birzha_stunned_purge", { duration = stun_duration } )
            end
        end
    end
end

modifier_kakashi_AiAiAi_debuff = class({})

function modifier_kakashi_AiAiAi_debuff:IsDebuff()      return true end
function modifier_kakashi_AiAiAi_debuff:IsPurgable()    return false end
function modifier_kakashi_AiAiAi_debuff:IsPurgeException()    return true end

function modifier_kakashi_AiAiAi_debuff:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_kakashi_AiAiAi_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_kakashi_AiAiAi_debuff:OnCreated(params)
    if not IsServer() then return end
    self.dot_damage = self:GetAbility():GetSpecialValueFor("dot_damage")
    if params.caster_entindex then
        self.caster = EntIndexToHScript(params.caster_entindex)
    else
        self.caster = self:GetCaster()
    end
    
    self.damage_table   = {
        victim          = self:GetParent(),
        damage          = self.dot_damage,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        damage_flags    = DOTA_DAMAGE_FLAG_NONE,
        attacker        = self.caster,
        ability         = self:GetAbility()
    }
    
    self:StartIntervalThink(1)
end

function modifier_kakashi_AiAiAi_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_kakashi_AiAiAi_debuff:OnIntervalThink()
    self:GetParent():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Tick")
    ApplyDamage(self.damage_table)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.dot_damage, nil)
end

function modifier_kakashi_AiAiAi_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_HEALING,
    }
end

function modifier_kakashi_AiAiAi_debuff:GetDisableHealing()
    return 1
end