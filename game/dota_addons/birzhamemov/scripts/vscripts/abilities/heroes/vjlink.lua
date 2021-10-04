LinkLuaModifier( "modifier_vjlink_sputum", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_sputum = class({})

function Vjlink_sputum:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vjlink_sputum:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vjlink_sputum:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return 950
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vjlink_sputum:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function Vjlink_sputum:OnSpellStart()
    if not IsServer() then return end

    if self:GetCaster():HasScepter() then
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, 950, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
        for _,enemy in pairs(enemies) do
            local info = {
                EffectName = "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
                Ability = self,
                iMoveSpeed = 1000,
                Source = self:GetCaster(),
                Target = enemy,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
            }
            ProjectileManager:CreateTrackingProjectile( info )
        end
        self:GetCaster():EmitSound("Hero_Bristleback.ViscousGoo.Cast")
        return
    end
    local target = self:GetCursorTarget()
    local info = {
        EffectName = "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
        Ability = self,
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("Hero_Bristleback.ViscousGoo.Cast")
end

function Vjlink_sputum:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
        if self:GetCaster():HasScepter() then
            if target ~= nil and ( not target:IsMagicImmune() ) then
                local duration = self:GetSpecialValueFor("duration")
                target:AddNewModifier( self:GetCaster(), self, "modifier_vjlink_sputum", { duration = duration * (1 - target:GetStatusResistance()) } )
                target:EmitSound("Hero_Bristleback.ViscousGoo.Target")
                return true
            end
        end
        if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
            local duration = self:GetSpecialValueFor("duration")
            target:AddNewModifier( self:GetCaster(), self, "modifier_vjlink_sputum", { duration = duration * (1 - target:GetStatusResistance()) } )
            target:EmitSound("Hero_Bristleback.ViscousGoo.Target")
        end
    return true
end

modifier_vjlink_sputum = class({})

function modifier_vjlink_sputum:IsPurgable() return true end

function modifier_vjlink_sputum:OnCreated( kv )
    self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
    self.slow_base = self:GetAbility():GetSpecialValueFor( "base_move_slow" )
    self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )

    if IsServer() then
        self:SetStackCount(1)
    end
end

function modifier_vjlink_sputum:OnRefresh( kv )
    self.armor_stack = self:GetAbility():GetSpecialValueFor( "armor_per_stack" )
    self.slow_base = self:GetAbility():GetSpecialValueFor( "base_move_slow" )
    self.slow_stack = self:GetAbility():GetSpecialValueFor( "move_slow_per_stack" )
    local max_stack = self:GetAbility():GetSpecialValueFor( "stack_limit" )

    if IsServer() then
        if self:GetStackCount()<max_stack then
            self:IncrementStackCount()
        end
    end
end

function modifier_vjlink_sputum:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_vjlink_sputum:GetModifierPhysicalArmorBonus()
    return self.armor_stack * self:GetStackCount()
end
function modifier_vjlink_sputum:GetModifierMoveSpeedBonus_Percentage()
    return (self.slow_base + self.slow_stack * self:GetStackCount())
end

function modifier_vjlink_sputum:GetEffectName()
    return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end

function modifier_vjlink_sputum:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_python_active", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_python_debuff", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_python = class({})

function Vjlink_python:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vjlink_python:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vjlink_python:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vjlink_python:OnSpellStart()
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb(self) then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_python_active", { target = self.target } )
    self:GetCaster():EmitSound("krik")
end

modifier_python_active = class({})

function modifier_python_active:IsPurgable() return false end
function modifier_python_active:IsHidden() return true end

function modifier_python_active:OnCreated( kv )
    self.target = self:GetAbility().target
    self.close_distance = 80
    self.far_distance = 1400
    self.speed = 1000
    self.damage = (self:GetAbility():GetSpecialValueFor( "health_damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_2")) / 100
    self.duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )

    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
    end
end

function modifier_python_active:OnDestroy()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers( true )
    if not self.success then return end

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target )
    ParticleManager:SetParticleControl( particle, 1, self.target:GetOrigin() )
    ParticleManager:ReleaseParticleIndex( particle )

    local damageTable = {
        victim = self.target,
        attacker = self:GetCaster(),
        damage = self.damage * self.target:GetHealth(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
    }
    if self.target:IsBoss() then return end
    ApplyDamage(damageTable)
    self.target:EmitSound("Hero_Huskar.Life_Break.Impact")
    self.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_python_debuff", { duration = self.duration } )
end

function modifier_python_active:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

function modifier_python_active:UpdateHorizontalMotion( me, dt )
    local origin = self:GetParent():GetOrigin()
    if not self.target:IsAlive() then
        self:EndCharge( false )
    end
    local direction = self.target:GetOrigin() - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()

    if distance<self.close_distance then
        self:EndCharge( true )
    elseif distance>self.far_distance then
        self:EndCharge( false )
    end

    local target = origin + direction * self.speed * dt
    self:GetParent():SetOrigin( target )
    self:GetParent():FaceTowards( self.target:GetOrigin() )
end

function modifier_python_active:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_python_active:EndCharge( success )
    if success then
        self.success = true
    end
    self:Destroy()
end

modifier_python_debuff = class({})

function modifier_python_debuff:IsPurgable() return true end

function modifier_python_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end
function modifier_python_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "movespeed_slow" )
end

function modifier_python_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_huskar_lifebreak.vpcf"
end

LinkLuaModifier( "modifier_Vjlink_teeth", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_teeth = class({})

function Vjlink_teeth:GetIntrinsicModifierName()
    return "modifier_Vjlink_teeth"
end

modifier_Vjlink_teeth = class({})

function modifier_Vjlink_teeth:IsPurgable() return false end
function modifier_Vjlink_teeth:IsHidden() return true end

function modifier_Vjlink_teeth:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_Vjlink_teeth:GetModifierProcAttack_BonusDamage_Physical( params )
    self.damage = (self:GetAbility():GetSpecialValueFor( "damage_percent" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_vjlink_1")) / 100
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsBoss() then return end
    local particle = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( particle )
    local damage = params.target:GetHealth() * self.damage
    self:GetParent():Heal( damage, self:GetAbility() )
    return damage
end

LinkLuaModifier( "modifier_vjlink_dudos", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_vjlink_dudos_effect", "abilities/heroes/vjlink.lua", LUA_MODIFIER_MOTION_NONE )

Vjlink_dudos = class({})

function Vjlink_dudos:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vjlink_dudos:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vjlink_dudos:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vjlink_dudos:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_vjlink_dudos", { duration = duration } )
    self:GetCaster():EmitSound("dudos")
end

modifier_vjlink_dudos = class({})

function modifier_vjlink_dudos:IsPurgable() return false end

function modifier_vjlink_dudos:OnCreated()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_vjlink_dudos_effect", {} )
end

function modifier_vjlink_dudos:OnDestroy()
    if not IsServer() then return end
    self.modifier = self:GetCaster():FindModifierByName( "modifier_vjlink_dudos_effect" )
    if self.modifier then
        self.modifier:Destroy()
    end
end


function modifier_vjlink_dudos:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_vjlink_dudos:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end

function modifier_vjlink_dudos:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_vjlink_dudos:GetEffectName()
    return "particles/vjlink/1.vpcf"
end

function modifier_vjlink_dudos:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_vjlink_dudos_effect = class({})

function modifier_vjlink_dudos_effect:IsHidden() return true end

function modifier_vjlink_dudos_effect:GetEffectName()
    return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf"
end

function modifier_vjlink_dudos_effect:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
















