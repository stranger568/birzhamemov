LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Doljan_RapBattle_debuff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Doljan_RapBattle_steal_debuff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Doljan_RapBattle_steal_buff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)

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

modifier_Doljan_RapBattle_debuff = class({})

function modifier_Doljan_RapBattle_debuff:IsPurgable()
    return false
end

function modifier_Doljan_RapBattle_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 1 )
    local particle = ParticleManager:CreateParticle( "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    self:AddParticle( particle, false, false, -1, false, false )
end

function modifier_Doljan_RapBattle_debuff:OnDestroy()
    if not IsServer() then return end
    StopSoundOn( "doljanrep", self:GetCaster() )
end

function modifier_Doljan_RapBattle_debuff:OnIntervalThink()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local radius = self:GetAbility():GetSpecialValueFor("break_distance")
    local multi = self:GetAbility():GetSpecialValueFor("int_multi") + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_3")
    local current_stack_buff = self:GetCaster():GetModifierStackCount( "modifier_Doljan_RapBattle_steal_buff", self:GetCaster() )
    local current_stack_debuff = self:GetParent():GetModifierStackCount( "modifier_Doljan_RapBattle_steal_debuff", self:GetCaster() )
    local attackspeed_steal = self:GetAbility():GetSpecialValueFor("attack_speed")
    local damage = self:GetCaster():GetIntellect() * multi

    if self:GetParent():IsInvulnerable() or self:GetParent():IsIllusion() or ( not self:GetCaster():IsAlive()) then
        self:Destroy()
        return
    end

    if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>radius then
        self:Destroy()
        return
    end

    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() })
    if self:GetCaster():HasTalent("special_bonus_birzha_doljan_2") then attackspeed_steal = attackspeed_steal * 3 end
    if self:GetCaster():HasModifier("modifier_Doljan_RapBattle_steal_buff") then
        self:GetCaster():SetModifierStackCount( "modifier_Doljan_RapBattle_steal_buff", self:GetAbility(), current_stack_buff + attackspeed_steal )
        self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_buff", { duration = duration } )
    else
        self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_buff", { duration = duration } )
        self:GetCaster():SetModifierStackCount( "modifier_Doljan_RapBattle_steal_buff", self:GetAbility(), attackspeed_steal )
    end
    
    if self:GetParent():HasModifier("modifier_Doljan_RapBattle_steal_debuff") then
        self:GetParent():SetModifierStackCount( "modifier_Doljan_RapBattle_steal_debuff", self:GetAbility(), current_stack_debuff + attackspeed_steal )
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_debuff", { duration = duration } )
    else
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Doljan_RapBattle_steal_debuff", { duration = duration } )
        self:GetParent():SetModifierStackCount( "modifier_Doljan_RapBattle_steal_debuff", self:GetAbility(), attackspeed_steal )
    end
end

modifier_Doljan_RapBattle_steal_buff = class ({})

function modifier_Doljan_RapBattle_steal_buff:IsPurgable()
    return false
end

function modifier_Doljan_RapBattle_steal_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return declfuncs
end

function modifier_Doljan_RapBattle_steal_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * 1
end

modifier_Doljan_RapBattle_steal_debuff = class ({})

function modifier_Doljan_RapBattle_steal_debuff:IsPurgable()
    return false
end

function modifier_Doljan_RapBattle_steal_debuff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return declfuncs
end

function modifier_Doljan_RapBattle_steal_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * -1
end

LinkLuaModifier("modifier_doljan_trolling_buff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doljan_trolling_buff_counter", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doljan_trolling_debuff", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doljan_trolling_debuff_counter", "abilities/heroes/doljan", LUA_MODIFIER_MOTION_NONE)
        
doljan_trolling = class({}) 

function doljan_trolling:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function doljan_trolling:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function doljan_trolling:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function doljan_trolling:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function doljan_trolling:OnSpellStart()
    self.scepter_updated = self:GetCaster():HasScepter()
    self:GetCaster():EmitSound("Hero_Undying.Decay.Cast")
    
    local decay_particle = ParticleManager:CreateParticle("particles/econ/items/undying/undying_pale_augur/undying_pale_augur_decay.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(decay_particle, 0, self:GetCursorPosition())
    ParticleManager:SetParticleControl(decay_particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
    ParticleManager:SetParticleControl(decay_particle, 2, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(decay_particle)
    
    local clone_owner_units = {}
    local strength_transfer_particle    = nil
    local flies_transfer_particle       = nil
    local buff_modifier                 = nil
    local debuff_modifier               = nil
    
    if not self.debuff_modifier_table then
        self.debuff_modifier_table = {}
    end
    
    for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
        if enemy:IsClone() or enemy:IsTempestDouble() then
            if enemy.GetPlayerOwner and enemy:GetPlayerOwner().GetAssignedHero and enemy:GetPlayerOwner():GetAssignedHero():entindex() then
                if not clone_owner_units[enemy:GetPlayerOwner():GetAssignedHero():entindex()] then
                    clone_owner_units[enemy:GetPlayerOwner():GetAssignedHero():entindex()] = {}
                end
                table.insert(clone_owner_units[enemy:GetPlayerOwner():GetAssignedHero():entindex()], enemy:entindex())
            end
        else
            if enemy:IsHero() and not enemy:IsIllusion() then
                enemy:EmitSound("Hero_Undying.Decay.Target")
                self:GetCaster():EmitSound("Hero_Undying.Decay.Transfer")
                
                strength_transfer_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                ParticleManager:SetParticleControlEnt(strength_transfer_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(strength_transfer_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(strength_transfer_particle)
                enemy:AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_debuff_counter", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
                debuff_modifier = enemy:AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_debuff", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
                table.insert(self.debuff_modifier_table, debuff_modifier)
                self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_buff_counter", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
                buff_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_buff", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
                
                ApplyDamage({
                    victim          = enemy,
                    damage          = self:GetSpecialValueFor("decay_damage"),
                    damage_type     = self:GetAbilityDamageType(),
                    damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                    attacker        = self:GetCaster(),
                    ability         = self
                })
            end
        end
    end

    local selected_unit = nil
    
    if #clone_owner_units > 0 then
        for tables in clone_owner_units do
            enemy:EmitSound("Hero_Undying.Decay.Target")
            self:GetCaster():EmitSound("Hero_Undying.Decay.Transfer")
            
            selected_unit =  EntIndexToHScript(tables[RandomInt(1, #tables)])
        
            enemy:AddNewModifier(selected_unit, self, "modifier_doljan_trolling_debuff_counter", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
            debuff_modifier = enemy:AddNewModifier(selected_unit, self, "modifier_doljan_trolling_debuff", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
            table.insert(self.debuff_modifier_table, debuff_modifier)
            
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_buff_counter", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doljan_trolling_buff", {duration = (self:GetSpecialValueFor("decay_duration")+self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_4"))})
            
            for enemy_entindex in tables do
                ApplyDamage({
                    victim          = EntIndexToHScript(enemy_entindex),
                    damage          = self:GetSpecialValueFor("decay_damage"),
                    damage_type     = self:GetAbilityDamageType(),
                    damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                    attacker        = self:GetCaster(),
                    ability         = self
                })
            end
        end
    end
end

modifier_doljan_trolling_buff = class({})

function modifier_doljan_trolling_buff:IsHidden()        return true end
function modifier_doljan_trolling_buff:IsPurgable()      return false end
function modifier_doljan_trolling_buff:GetAttributes()   return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_doljan_trolling_buff:OnCreated()
    self.str_steal          = self:GetAbility():GetSpecialValueFor("str_steal")
    self.str_steal_scepter  = self:GetAbility():GetSpecialValueFor("str_steal_scepter")
    
    if not IsServer() then return end
    
    if not self:GetCaster():HasScepter() then
        self:SetStackCount(self:GetStackCount() + self.str_steal)
    else
        self:SetStackCount(self:GetStackCount() + self.str_steal_scepter)
    end
end

function modifier_doljan_trolling_buff:OnDestroy()
    if not IsServer() then return end
    
    if self:GetParent():HasModifier("modifier_doljan_trolling_buff_counter") then
        self:GetParent():FindModifierByName("modifier_doljan_trolling_buff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_doljan_trolling_buff_counter"):GetStackCount() - self:GetStackCount())
    end
end

function modifier_doljan_trolling_buff:OnStackCountChanged(stackCount)
    if not IsServer() then return end

    if self:GetParent():HasModifier("modifier_doljan_trolling_buff_counter") then
        self:GetParent():FindModifierByName("modifier_doljan_trolling_buff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_doljan_trolling_buff_counter"):GetStackCount() + (self:GetStackCount() - stackCount))
    end
end

function modifier_doljan_trolling_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_doljan_trolling_buff:GetModifierModelScale()
    return 2
end

modifier_doljan_trolling_buff_counter = class({})

function modifier_doljan_trolling_buff_counter:IsPurgable()  return false end

function modifier_doljan_trolling_buff_counter:GetEffectName()
    return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end

function modifier_doljan_trolling_buff_counter:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_doljan_trolling_buff_counter:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end

modifier_doljan_trolling_debuff = class({})

function modifier_doljan_trolling_debuff:IsHidden()      return true end
function modifier_doljan_trolling_debuff:IsPurgable()    return false end
function modifier_doljan_trolling_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_doljan_trolling_debuff:OnCreated()
    self.str_steal          = self:GetAbility():GetSpecialValueFor("str_steal")
    self.str_steal_scepter  = self:GetAbility():GetSpecialValueFor("str_steal_scepter")

    if not IsServer() then return end
    
    if not self:GetCaster():HasScepter() then
        self:SetStackCount(self:GetStackCount() + self.str_steal)
    else
        self:SetStackCount(self:GetStackCount() + self.str_steal_scepter)
    end
end

function modifier_doljan_trolling_debuff:OnDestroy()
    if not IsServer() then return end
    
    if self:GetParent():HasModifier("modifier_doljan_trolling_buff_counter") then
        self:GetParent():FindModifierByName("modifier_doljan_trolling_buff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_doljan_trolling_buff_counter"):GetStackCount() - self:GetStackCount())
    end
end

function modifier_doljan_trolling_debuff:OnStackCountChanged(stackCount)
    if not IsServer() then return end

    if self:GetParent():HasModifier("modifier_doljan_trolling_debuff_counter") then
        self:GetParent():FindModifierByName("modifier_doljan_trolling_debuff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_doljan_trolling_debuff_counter"):GetStackCount() + (self:GetStackCount() - stackCount))
    end
end

modifier_doljan_trolling_debuff_counter = class({})

function modifier_doljan_trolling_debuff_counter:IsPurgable()    return false end

function modifier_doljan_trolling_debuff_counter:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_doljan_trolling_debuff_counter:GetModifierBonusStats_Strength()
    return self:GetStackCount() * (-1)
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

function Doljan_DrinkSomeVodka:GetIntrinsicModifierName()
    return "modifier_Doljan_DrinkSomeVodka_stack"
end

function Doljan_DrinkSomeVodka:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor( "duration" )
    target:AddNewModifier( self:GetCaster(), self, "modifier_Doljan_DrinkSomeVodka", {duration = duration} )
end

modifier_Doljan_DrinkSomeVodka_stack = class({})

function modifier_Doljan_DrinkSomeVodka_stack:IsHidden()
    return false
end

function modifier_Doljan_DrinkSomeVodka_stack:IsPurgable()
    return false
end

function modifier_Doljan_DrinkSomeVodka_stack:DestroyOnExpire()
    return false
end

function modifier_Doljan_DrinkSomeVodka_stack:OnCreated( kv )
    self.max_charges = self:GetAbility():GetSpecialValueFor( "maximum_charges" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_1")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_Doljan_DrinkSomeVodka_stack:OnRefresh( kv )
    self.max_charges = self:GetAbility():GetSpecialValueFor( "maximum_charges" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_1")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_Doljan_DrinkSomeVodka_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_Doljan_DrinkSomeVodka_stack:OnAbilityFullyCast( params )
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

function modifier_Doljan_DrinkSomeVodka_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_Doljan_DrinkSomeVodka_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = self:GetAbility():GetSpecialValueFor( "maximum_charges" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_doljan_1")
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

modifier_Doljan_DrinkSomeVodka = class ({})

function modifier_Doljan_DrinkSomeVodka:GetAttributes()   return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_Doljan_DrinkSomeVodka:IsPurgable()
    return true
end

function modifier_Doljan_DrinkSomeVodka:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
    return declfuncs
end

function modifier_Doljan_DrinkSomeVodka:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor( "atributes" )
end

function modifier_Doljan_DrinkSomeVodka:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor( "atributes" )
end

function modifier_Doljan_DrinkSomeVodka:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor( "atributes" )
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
    if IsServer() then
        local radius = self:GetSpecialValueFor("radius")
        local manaburn_percent = self:GetSpecialValueFor("mana_burn") / 100
        local enemyHeroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
        for k,enemy in pairs(enemyHeroes) do
            local manaburn = enemy:GetMaxMana() * manaburn_percent
            local manaburn_damage = self:GetSpecialValueFor("damage_burn") + (self:GetCaster():GetIntellect() * 2)
            enemy:ReduceMana(manaburn)
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self, damage = manaburn_damage, damage_type = DAMAGE_TYPE_MAGICAL})
            local particle = ParticleManager:CreateParticle("particles/doljan_scepter.vpcf", PATTACH_POINT_FOLLOW, enemy)
            ParticleManager:SetParticleControlEnt(particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true)
            ParticleManager:SetParticleControl(particle, 1, Vector(100,0,0))
            ParticleManager:ReleaseParticleIndex(particle)
            enemy:EmitSound("Hero_StormSpirit.StaticRemnantExplode")
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
    if IsServer() then
        local ability = self:GetCaster():FindAbilityByName("Doljan_Intellect") 
        if not self:GetCaster():HasModifier("modifier_Doljan_Intellect_handler") then
            self:GetCaster():AddNewModifier(self:GetCaster(), ability, "modifier_Doljan_Intellect_handler", {})
        end
    end

    self:StartIntervalThink(0.1)
end

function modifier_Doljan_Intellect_stacks:OnIntervalThink()
    if not IsServer() then return end
    local buff = self:GetCaster():FindModifierByName("modifier_Doljan_Intellect_handler")
    if not buff then return end
    self:SetStackCount(buff:GetStackCount())
end

function modifier_Doljan_Intellect_stacks:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_Doljan_Intellect_stacks:GetModifierBonusStats_Intellect()
    if self:GetCaster():PassivesDisabled() then return end
    local stacks = self:GetStackCount()
    local intellect = self:GetAbility():GetSpecialValueFor("intellect")
    return stacks * intellect
end

modifier_Doljan_Intellect_handler = class({})

function modifier_Doljan_Intellect_handler:IsDebuff() return false end
function modifier_Doljan_Intellect_handler:IsHidden() return true end
function modifier_Doljan_Intellect_handler:IsPurgable() return false end
function modifier_Doljan_Intellect_handler:RemoveOnDeath() return false end

function modifier_Doljan_Intellect_handler:DeclareFunctions()
    local decfuncs = {
        MODIFIER_EVENT_ON_DEATH
    }

    return decfuncs
end

function modifier_Doljan_Intellect_handler:OnDeath(params)
    local caster = self:GetCaster()
    local target = params.unit

    if target:IsRealHero() and caster:GetTeamNumber() ~= target:GetTeamNumber() and caster:IsAlive() then     
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        if radius == 0 then
            radius = 1600
        end

        if (self:GetAbility():GetCaster():GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= radius then
            self:SetStackCount(self:GetStackCount() + 1)
            local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:ReleaseParticleIndex(pfx)
        end
    end
end

