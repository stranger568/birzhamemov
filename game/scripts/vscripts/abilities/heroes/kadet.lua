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
    return self:GetSpecialValueFor("radius")
end

function Kadet_fuck_faggots:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius")
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
        local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_2")
        self.damage = self:GetSpecialValueFor("damage")
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,     
            ability = self
        }
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration})
        target:EmitSound("Hero_SkeletonKing.BlastImpact")
        if self:GetCaster():HasTalent("special_bonus_birzha_kadet_1") then
            damage.damage_type = DAMAGE_TYPE_PURE
        end
        ApplyDamage( damage )
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
    self.create_time = GameRules:GetGameTime()
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
    if self:GetParent():HasScepter() then
        self.attack_count_visual = 2
        self.attack_count = 2
    end
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
    self.attack_count_visual = self.attack_count_visual - 1
end

function modifier_kadet_army:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker~=self:GetParent() then return end
    local duration_target = self:GetAbility():GetSpecialValueFor( "duration_target" )
    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_kadet_army_debuff", { duration = duration_target * (1 - params.target:GetStatusResistance())} )
    self.attack_count = self.attack_count - 1
    if self.attack_count <= 0 then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_kadet_army:CheckState()
    local state = {
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
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
    }

    return funcs
end

function modifier_kadet_army_debuff:GetModifierPhysicalArmorBonus( params )
    return self:GetAbility():GetSpecialValueFor( "minus_armor" )
end

function modifier_kadet_army_debuff:GetModifierMiss_Percentage( params )
    return 100
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

function modifier_fast_attacks:OnCreated( kv )
    self:SetStackCount(1)
    self.currentTarget = {}
end

function modifier_fast_attacks:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK
    }

    return funcs
end

function modifier_fast_attacks:OnAttack( params )
    if not IsServer() then return end

    pass = false

    if params.attacker==self:GetParent() then
        pass = true
    end

    if params.target:IsOther() then
        return nil
    end

    if pass then
        if self.currentTarget==params.target then
            self:AddStack()
        else
            self:ResetStack()
            self.currentTarget = params.target
        end
    end
end

function modifier_fast_attacks:GetModifierAttackSpeedBonus_Constant( params )
    local passive = 1
    if self:GetParent():PassivesDisabled() then
        passive = 0
    end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("attack_speed") * passive
end

function modifier_fast_attacks:AddStack()
    if not self:GetParent():PassivesDisabled() then
        if self:GetStackCount() < (self:GetAbility():GetSpecialValueFor("max_stacks") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_4")) then
            self:IncrementStackCount()
        end
    end
end

function modifier_fast_attacks:ResetStack()
    if not self:GetParent():PassivesDisabled() then
        self:SetStackCount(1)
    end
end

LinkLuaModifier( "modifier_kadet_razogrev", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kadet_razogrev_caster", "abilities/heroes/kadet.lua", LUA_MODIFIER_MOTION_NONE )

kadet_razogrev = class({})

function kadet_razogrev:GetIntrinsicModifierName() 
    return "modifier_kadet_razogrev"
end

modifier_kadet_razogrev = class({})

function modifier_kadet_razogrev:IsHidden()
    return false
end

function modifier_kadet_razogrev:IsPurgable()
    return false
end

function modifier_kadet_razogrev:DeclareFunctions()
return  {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
end

function modifier_kadet_razogrev:OnCreated()
    if not IsServer() then return end
    self.target_attack = nil
end

function modifier_kadet_razogrev:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if parent:IsIllusion() then return end
        if target:IsOther() then
            return nil
        end
        local max_hits = ((self:GetAbility():GetSpecialValueFor("required_hits") + self:GetCaster():FindTalentValue("special_bonus_birzha_kadet_5")) - 1)
        local duration = self:GetAbility():GetSpecialValueFor("counter_duration")

        if not self.hits then
            self.hits = 0 
        end

        if self.target_attack ~= nil and self.target_attack ~= target then
            self.hits = 0
            if self.particle then
                ParticleManager:DestroyParticle(self.particle, true)
            end
            self.target_attack = target
            return
        end

        self.target_attack = target

        if parent:HasModifier("modifier_kadet_razogrev_caster") then return end
        if self.hits >= max_hits then
            parent:EmitSound("kadetultimate")
            ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, 5, 0) )
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_kadet_razogrev_caster", {duration = duration})
            self.hits = 0
            if self.particle then
                ParticleManager:DestroyParticle(self.particle, true)
            end
        else
            if self.hits == 0 then
                self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, parent )  
            end
            self.hits = self.hits + 1
            ParticleManager:SetParticleControl( self.particle, 0, parent:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, self.hits, 0) )
        end
    end
end

modifier_kadet_razogrev_caster = class({})

function modifier_kadet_razogrev_caster:IsPurgable()
    return false
end

function modifier_kadet_razogrev_caster:OnCreated()
    self.particle1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )    
    ParticleManager:SetParticleControl( self.particle1, 0, self:GetParent():GetAbsOrigin() )
    self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )   
    ParticleManager:SetParticleControl( self.particle, 0, self:GetParent():GetAbsOrigin() )
end

function modifier_kadet_razogrev_caster:OnDestroy()
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, true)
    end
    if self.particle1 then
        ParticleManager:DestroyParticle(self.particle1, true)
    end
end

function modifier_kadet_razogrev_caster:DeclareFunctions()
return  {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
end

function modifier_kadet_razogrev_caster:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if parent:IsIllusion() then return end
        self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
        local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,     
            ability = self:GetAbility()
        }
        if self:GetCaster():HasTalent("special_bonus_birzha_kadet_3") then
            damage.damage_type = DAMAGE_TYPE_PURE
        end
        ApplyDamage( damage )
        parent:Heal(params.damage+self.damage, self:GetAbility())
        if not self:IsNull() then
            self:Destroy()
        end
    end
end





