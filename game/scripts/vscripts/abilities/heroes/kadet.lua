LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Kadet_fuck_faggots = class({})

function Kadet_fuck_faggots:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kadet_fuck_faggots:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kadet_fuck_faggots:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius_shard")
end

function Kadet_fuck_faggots:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius_shard")
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
    if self:GetCaster():HasShard() then
        for _,enemy in pairs(enemies) do
            local info = {
                EffectName = "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast.vpcf",
                Ability = self,
                iMoveSpeed = 850,
                Source = self:GetCaster(),
                Target = enemy,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
            }
            ProjectileManager:CreateTrackingProjectile( info )
        end
    else
        if #enemies > 0 then
            local info = {
                EffectName = "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast.vpcf",
                Ability = self,
                iMoveSpeed = 850,
                Source = self:GetCaster(),
                Target = enemies[1],
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
            }
            ProjectileManager:CreateTrackingProjectile( info )
        end
    end
    self:GetCaster():EmitSound("ebashnah")
end

function Kadet_fuck_faggots:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) then
        local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_4")
        local damage = self:GetSpecialValueFor("damage")
        local damage_table = { victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration * (1-target:GetStatusResistance()) })
        target:EmitSound("Hero_SkeletonKing.BlastImpact")
        if self:GetCaster():HasTalent("special_bonus_birzha_kadet_5") then
            damage_table.damage_type = DAMAGE_TYPE_PURE
        end
        ApplyDamage( damage_table )
    end
    return true
end

LinkLuaModifier( "modifier_kadet_army", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )              
LinkLuaModifier( "modifier_kadet_army_debuff", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )    

Kadet_Army = class({})

function Kadet_Army:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kadet_Army:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kadet_Army:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    caster:EmitSound("Kadetarmy")
    caster:AddNewModifier( caster, self, "modifier_kadet_army", { duration = duration } )
end

modifier_kadet_army = class({})

function modifier_kadet_army:IsPurgable()
    return true
end

function modifier_kadet_army:OnCreated( kv )
    if not IsServer() then return end

    ProjectileManager:ProjectileDodge( self:GetParent() )

    if self:GetParent():GetAggroTarget() then
        local order = {
            UnitIndex = self:GetParent():entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP,
        }
        ExecuteOrderFromTable( order )
    end

    local effect_cast = ParticleManager:CreateParticle( "particles/kadet/kadet_army.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true ) 
    self:AddParticle( effect_cast, false, false, -1, false, false )

    self.attack_count_visual = 1
    self.attack_count = 1
end

function modifier_kadet_army:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_kadet_army:GetModifierProjectileName()
    if self.attack_count_visual <= 0 then return end
    return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_attack.vpcf"
end

function modifier_kadet_army:OnAttack( params )
    if not IsServer() then return end
    if params.attacker~=self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():HasScepter() then
        return
    end
    self.attack_count_visual = self.attack_count_visual - 1
end

function modifier_kadet_army:OnAttackLanded( params )
    if not IsServer() then return end

    if params.attacker~=self:GetParent() then return end
    if params.target:IsWard() then return end

    local duration_target = self:GetAbility():GetSpecialValueFor( "duration_target" )

    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_kadet_army_debuff", { duration = duration_target * (1 - params.target:GetStatusResistance())} )

    if self:GetParent():HasScepter() then
        return
    end

    self.attack_count = self.attack_count - 1
    if self.attack_count <= 0 then
        self:Destroy()
    end
end

function modifier_kadet_army:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

function modifier_kadet_army:GetStatusEffectName()
    return "particles/kadet/kadet_army_status.vpcf"
end

modifier_kadet_army_debuff = class({})

function modifier_kadet_army_debuff:IsPurgable()
    return true
end

function modifier_kadet_army_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_kadet_army_debuff:GetModifierPhysicalArmorBonus( params )
    return self:GetAbility():GetSpecialValueFor( "minus_armor" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_2")
end

function modifier_kadet_army_debuff:GetEffectName()
    return "particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm.vpcf"
end

function modifier_kadet_army_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_fast_attacks", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )      

Kadet_fast_attacks = class({})

function Kadet_fast_attacks:GetIntrinsicModifierName()
    return "modifier_fast_attacks"
end

modifier_fast_attacks = class({})

function modifier_fast_attacks:IsPurgable( kv )
    return false
end

function modifier_fast_attacks:IsHidden() return self:GetStackCount() == 0 end

function modifier_fast_attacks:OnCreated( kv )
    if not IsServer() then return end
    self:SetStackCount(0)
    self.current_target = nil
end

function modifier_fast_attacks:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK
    }
    return funcs
end

function modifier_fast_attacks:OnAttack( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end
    if self:GetParent():PassivesDisabled() then return end

    if self.current_target ~= nil and self.current_target ~= params.target then
        if self:GetCaster():HasTalent("special_bonus_birzha_kadet_3") then
            self:SetStackCount(self:GetStackCount() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_3"))
        else
            self:SetStackCount(0)
        end
    end

    local max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")

    if self.current_target == params.target then
        if self:GetStackCount() < max_stacks then
            self:SetStackCount(self:GetStackCount() + 1)
        end
    end

    self.current_target = params.target
end

function modifier_fast_attacks:GetModifierAttackSpeedBonus_Constant( params )
    if self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("attack_speed") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_6"))
end

LinkLuaModifier( "modifier_kadet_razogrev", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kadet_razogrev_caster", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )

kadet_razogrev = class({})

function kadet_razogrev:GetIntrinsicModifierName() 
    return "modifier_kadet_razogrev"
end

modifier_kadet_razogrev = class({})

function modifier_kadet_razogrev:IsHidden()
    return self:GetStackCount() == 0
end

function modifier_kadet_razogrev:IsPurgable()
    return false
end

function modifier_kadet_razogrev:DeclareFunctions()
    return  
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_kadet_razogrev:OnCreated()
    if not IsServer() then return end
    self.target_attack = nil
end

function modifier_kadet_razogrev:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetParent():HasModifier("modifier_kadet_razogrev_caster") then return end

    local max_hits = ((self:GetAbility():GetSpecialValueFor("required_hits") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_8")) - 1)
    local duration = self:GetAbility():GetSpecialValueFor("counter_duration")

    if self.target_attack ~= nil and self.target_attack ~= target then
        self:SetStackCount(0)
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
        end
        self.target_attack = target
        return
    end

    self.target_attack = target

    if self:GetStackCount() >= max_hits then
        self:GetParent():EmitSound("kadetultimate")
        ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, 5, 0) )
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kadet_razogrev_caster", {duration = duration})
        self:SetStackCount(0)
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
        end
    else
        if self:GetStackCount() == 0 then
            self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )  
        end
        self:IncrementStackCount()
        ParticleManager:SetParticleControl( self.particle, 0, self:GetParent():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, self:GetStackCount(), 0) )
    end
end

modifier_kadet_razogrev_caster = class({})

function modifier_kadet_razogrev_caster:IsPurgable()
    return false
end

function modifier_kadet_razogrev_caster:OnCreated()
    if not IsServer() then return end
    self.particle1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )    
    ParticleManager:SetParticleControl( self.particle1, 0, self:GetParent():GetAbsOrigin() )
    self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )   
    ParticleManager:SetParticleControl( self.particle, 0, self:GetParent():GetAbsOrigin() )
    self:AddParticle(self.particle1, false, false, -1, false, false)
    self:AddParticle(self.particle, false, false, -1, false, true)
    self.record = nil
end

function modifier_kadet_razogrev_caster:DeclareFunctions()
    return  
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
    }
end

function modifier_kadet_razogrev_caster:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    if params.target:IsWard() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetParent():HasTalent("special_bonus_birzha_kadet_7") then return end
    local damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.record = params.record
    return damage
end

function modifier_kadet_razogrev_caster:GetModifierProcAttack_BonusDamage_Pure( params )
    if not IsServer() then return end
    if params.target:IsWard() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_kadet_7") then return end
    local damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.record = params.record
    return damage
end

function modifier_kadet_razogrev_caster:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if (params.inflictor == nil or params.inflictor:GetAbilityName() == "item_revenants_brooch") and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        if params.record ~= self.record then return end
        local heal = (self:GetAbility():GetSpecialValueFor("lifesteal") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_1")) / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:Destroy()
    end
end





