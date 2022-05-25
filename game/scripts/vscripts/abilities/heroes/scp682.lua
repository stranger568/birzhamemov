LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_custom_indicator", "abilities/heroes/scp682", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_scp682_bite_debuff", "abilities/heroes/scp682.lua", LUA_MODIFIER_MOTION_NONE )

scp682_bite = class({}) 

function scp682_bite:GetCooldown(level)
    if self:GetCaster():HasModifier("modifier_scp682_ultimate") then
        return self.BaseClass.GetCooldown( self, level ) / 2
    end
    return self.BaseClass.GetCooldown( self, level )
end

function scp682_bite:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function scp682_bite:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function scp682_bite:GetCastRange(location, target)
    if self:GetCaster():HasModifier("modifier_scp682_ultimate") then
        return 750
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function scp682_bite:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local origin = self:GetCaster():GetOrigin()
    local point = self:GetCursorPosition()
    local direction = ((point - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()
    local endpos = self:GetCaster():GetAbsOrigin() + direction * 600
    local units = FindUnitsInLine(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), endpos, self:GetCaster(), 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
    for _,target in pairs(units) do
        local location = target:GetOrigin()
        local point_blank_range = self:GetSpecialValueFor( "point_blank_range" )
        if self:GetCaster():HasModifier("modifier_scp682_ultimate") then
            point_blank_range = point_blank_range + 150
        end
        local point_blank_mult = (self:GetSpecialValueFor( "dmg_bonus_pct" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_6") )/100
        local duration = self:GetSpecialValueFor( "duration" )
        local damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_1")
        local length = (location-origin):Length2D()
        local point_blank = (length<=point_blank_range)
        if point_blank then damage = damage + point_blank_mult*damage end
        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }
        EmitSoundOn( "Scp682bite", self:GetCaster() )
        ApplyDamage(damageTable)

        if self:GetCaster():HasShard() then
            target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = 0.5})
        end

        self:PlayEffects(target)
        target:AddNewModifier(self:GetCaster(), self, "modifier_scp682_bite_debuff", {duration = duration})
    end
end

modifier_scp682_bite_debuff = class({})

function modifier_scp682_bite_debuff:IsPurgable()
    return true
end

function modifier_scp682_bite_debuff:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_scp682_bite_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_scp682_bite_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function scp682_bite:PlayEffects( target )
    local forward = (target:GetOrigin()-self:GetCaster():GetOrigin()):Normalized()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true  )
    ParticleManager:SetParticleControlForward( effect_cast, 2, forward )
    ParticleManager:SetParticleControlForward( effect_cast, 5, forward )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( "Hero_LifeStealer.Consume", target )
end

modifier_generic_custom_indicator = class({})

function modifier_generic_custom_indicator:IsHidden()
    return true
end

function modifier_generic_custom_indicator:IsPurgable()
    return true
end

function modifier_generic_custom_indicator:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_custom_indicator:OnCreated( kv )
    if IsServer() then return end
    self:GetAbility().custom_indicator = self
end

function modifier_generic_custom_indicator:OnIntervalThink()
    if IsClient() then
        self:StartIntervalThink(-1)
        local ability = self:GetAbility()
        if self.init and ability.DestroyCustomIndicator then
            self.init = nil
            ability:DestroyCustomIndicator()
        end
    end
end

function modifier_generic_custom_indicator:Register( loc )
    local ability = self:GetAbility()
    if (not self.init) and ability.CreateCustomIndicator then
        self.init = true
        ability:CreateCustomIndicator()
    end
    if ability.UpdateCustomIndicator then
        ability:UpdateCustomIndicator( loc )
    end
    self:StartIntervalThink( 0.1 )
end

LinkLuaModifier( "modifier_scp682_rage", "abilities/heroes/scp682.lua", LUA_MODIFIER_MOTION_NONE )

scp682_rage = class({}) 

function scp682_rage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function scp682_rage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function scp682_rage:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return 99999
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function scp682_rage:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_scp682_rage") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function scp682_rage:OnSpellStart()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_scp682_rage") then
        self:GetCaster():RemoveModifierByName("modifier_scp682_rage")
        return
    end
    local duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_2")
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb(self) then return nil end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_scp682_rage", {duration = duration})
    self:GetCaster():EmitSound("Scp682scream")
    self:EndCooldown()
end

modifier_scp682_rage = class({}) 

function modifier_scp682_rage:IsHidden()
    return false
end

function modifier_scp682_rage:IsPurgable()
    return false
end

function modifier_scp682_rage:OnCreated()
    if not IsServer() then return end
    self.target = self:GetAbility().target
    self:GetCaster():SetRenderColor(255, 0, 0)
    local order =
    {
        UnitIndex = self:GetParent():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(order)
    if self:GetParent():FindAbilityByName("scp682_bite") then
        self:GetParent():FindAbilityByName("scp682_bite"):SetActivated(false)
    end
    if self:GetParent():FindAbilityByName("scp682_ultimate") then
        self:GetParent():FindAbilityByName("scp682_ultimate"):SetActivated(false)
    end
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(FrameTime())
end

function modifier_scp682_rage:OnDestroy()
   if not IsServer() then return end
    if self:GetParent():FindAbilityByName("scp682_bite") then
        self:GetParent():FindAbilityByName("scp682_bite"):SetActivated(true)
    end
    if self:GetParent():FindAbilityByName("scp682_ultimate") then
        self:GetParent():FindAbilityByName("scp682_ultimate"):SetActivated(true)
    end
    self:GetParent():Interrupt()
    self:GetParent():SetForceAttackTarget(nil)
    self:GetParent():SetForceAttackTargetAlly(nil)
    self:GetParent():Stop()
    self:GetParent():SetRenderColor(255, 255, 255)
    self:GetAbility():UseResources(false, false, true)
end

function modifier_scp682_rage:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 50, FrameTime(), false)
    if self.target == nil or self.target:IsAlive() == false or self.target:IsInvulnerable() or ( not self:GetParent():CanEntityBeSeenByMyTeam(self.target) ) then 
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_scp682_rage:DeclareFunctions()
    local funcs = {

        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end


function modifier_scp682_rage:GetBonusDayVision( params )
    return -9999999
end

function modifier_scp682_rage:GetBonusNightVision( params )
    return -9999999
end

function modifier_scp682_rage:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_scp682_rage:GetModifierMoveSpeed_Absolute( params )
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_scp682_rage:CheckState()
    local state = {
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    if self:GetCaster():HasTalent("special_bonus_birzha_scp683_7") then
        state = {
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
    end

    return state
end

LinkLuaModifier("modifier_scp682_plot", "abilities/heroes/scp682", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scp682_plot_debuff", "abilities/heroes/scp682", LUA_MODIFIER_MOTION_NONE)

scp682_plot = class({}) 

function scp682_plot:GetIntrinsicModifierName()
    return "modifier_scp682_plot"
end

modifier_scp682_plot = class({}) 

function modifier_scp682_plot:IsHidden()      return true end
function modifier_scp682_plot:IsPurgable()    return false end

function modifier_scp682_plot:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_scp682_plot:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()
    if attacker ~= keys.attacker then
        return
    end
    if attacker:PassivesDisabled() or attacker:IsIllusion() then
        return
    end
    local target = keys.target
    if attacker:GetTeam() == target:GetTeam() then
        return
    end 
    if target:IsOther() then
        return nil
    end
    if target:IsBoss() then return end
    local duration = self:GetAbility():GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_3")
    local damage = self:GetAbility():GetSpecialValueFor('damage')   
    local max_stack = self:GetAbility():GetSpecialValueFor('max_stack')

    local modifier = target:FindModifierByNameAndCaster("modifier_scp682_plot_debuff", self:GetAbility():GetCaster())
    if modifier == nil then
        target:AddNewModifier(attacker, self:GetAbility(), "modifier_scp682_plot_debuff", {duration = duration})
    else
        target:AddNewModifier(attacker, self:GetAbility(), "modifier_scp682_plot_debuff", {duration = duration})
        if modifier:GetStackCount() < max_stack then
            modifier:IncrementStackCount()
        end
    end
end

modifier_scp682_plot_debuff = class({})

function modifier_scp682_plot_debuff:IsPurgable()
    if self:GetCaster():HasTalent("special_bonus_birzha_scp683_5") then
        return false
    end
    return true
end

function modifier_scp682_plot_debuff:OnCreated( kv )
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(0.5)          
end

function modifier_scp682_plot_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage_base = (self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_4")) * self:GetStackCount()
    local damage = (self:GetParent():GetMaxHealth() / 100 * damage_base) / 2
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_PURE})
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end



LinkLuaModifier( "modifier_scp682_ultimate", "abilities/heroes/scp682.lua", LUA_MODIFIER_MOTION_NONE )

scp682_ultimate = class({}) 

function scp682_ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function scp682_ultimate:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function scp682_ultimate:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_scp682_ultimate", {duration = duration})
    self:GetCaster():EmitSound("Scp682ultimate")
    self:GetCaster():Purge(false, true, false, true, true)
end

modifier_scp682_ultimate = class({})

function modifier_scp682_ultimate:IsPurgable()
    return false
end

function modifier_scp682_ultimate:OnCreated()
    self.bonus_hp_regen = self:GetAbility():GetSpecialValueFor( "bonus_hp_regen" )
    self.resist = self:GetAbility():GetSpecialValueFor("resist")
end

function modifier_scp682_ultimate:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
    return funcs
end

function modifier_scp682_ultimate:ReincarnateTime( params )
    if IsServer() then
        --self:PlayEffects()
        --return 1
    end
end

function modifier_scp682_ultimate:PlayEffects()
    local particle_cast = "particles/scp_rein.vpcf"
    local sound_cast = "Hero_SkeletonKing.Reincarnate"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_scp682_ultimate:GetModifierModelScale( params )
    return 45
end

function modifier_scp682_ultimate:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end

function modifier_scp682_ultimate:GetModifierStatusResistanceStacking()
    return self.resist
end