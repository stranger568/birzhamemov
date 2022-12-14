LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
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
        return self.BaseClass.GetCastRange(self, location, target) + 150
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

        local point_blank_mult = self:GetSpecialValueFor( "dmg_bonus_pct" ) / 100
        local duration = self:GetSpecialValueFor( "duration" )
        local damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_1")

        if self:GetCaster():HasTalent("special_bonus_birzha_scp683_7") then
            damage = damage + self:GetCaster():GetAverageTrueAttackDamage(nil)
        end

        local length = (location-origin):Length2D()
        local point_blank = (length<=point_blank_range)
        if point_blank then damage = damage + point_blank_mult*damage end

        local damageTable = 
        {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }

        ApplyDamage(damageTable)

        if self:GetCaster():HasShard() then
            target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetSpecialValueFor("shard_stun_duration") * (1 - target:GetStatusResistance()) })
        end

        self:PlayEffects(target)
        target:AddNewModifier(self:GetCaster(), self, "modifier_scp682_bite_debuff", {duration = duration * (1 - target:GetStatusResistance()) })
    end

    self:GetCaster():EmitSound("Scp682bite")
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
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 5, target:GetAbsOrigin())
    target:EmitSound("Hero_LifeStealer.Consume")
end

LinkLuaModifier( "modifier_scp682_rage", "abilities/heroes/scp682.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_scp682_rage_magic_immune", "abilities/heroes/scp682.lua", LUA_MODIFIER_MOTION_NONE )

scp682_rage = class({}) 

function scp682_rage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function scp682_rage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function scp682_rage:GetCastRange(location, target)
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
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(FrameTime())
    if self:GetCaster():HasTalent("special_bonus_birzha_scp683_5") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_scp682_rage_magic_immune", {duration = self:GetDuration()})
    end
end

function modifier_scp682_rage:OnDestroy()
   if not IsServer() then return end
    self:GetParent():Interrupt()
    self:GetParent():SetForceAttackTarget(nil)
    self:GetParent():SetForceAttackTargetAlly(nil)
    self:GetParent():Stop()
    self:GetParent():SetRenderColor(255, 255, 255)
    self:GetAbility():UseResources(false, false, true)
    self:GetParent():RemoveModifierByName("modifier_scp682_rage_magic_immune")
end

function modifier_scp682_rage:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 100, 0.1, false)
    if self.target == nil or not self.target:IsAlive() or self.target:HasModifier("modifier_fountain_passive_invul") or ( self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target) ) then
        self:Destroy()
    end
end

function modifier_scp682_rage:DeclareFunctions()
    local funcs = 
    {
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
    local state = 
    {
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
    return state
end

modifier_scp682_rage_magic_immune = class({})

function modifier_scp682_rage_magic_immune:IsPurgable() return false end
function modifier_scp682_rage_magic_immune:IsHidden() return true end

function modifier_scp682_rage_magic_immune:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_scp682_rage_magic_immune:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_scp682_rage_magic_immune:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_scp682_rage_magic_immune:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
    }

    return decFuncs
end

function modifier_scp682_rage_magic_immune:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_scp682_rage_magic_immune:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_scp682_rage_magic_immune:StatusEffectPriority()
    return 99999
end

LinkLuaModifier("modifier_scp682_plot", "abilities/heroes/scp682", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scp682_plot_debuff", "abilities/heroes/scp682", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scp682_plot_thinker", "abilities/heroes/scp682", LUA_MODIFIER_MOTION_NONE)

scp682_plot = class({}) 

function scp682_plot:GetIntrinsicModifierName()
    return "modifier_scp682_plot"
end

modifier_scp682_plot = class({}) 

function modifier_scp682_plot:IsHidden() return true end
function modifier_scp682_plot:IsPurgable() return false end

function modifier_scp682_plot:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_scp682_plot:OnAttackLanded( params )
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.target then return end
    if params.target:IsBuilding() then return end
    if params.target:IsWard() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsBoss() then return end

    local duration = self:GetAbility():GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_3")
    local damage = self:GetAbility():GetSpecialValueFor('damage')   
    local max_stack = self:GetAbility():GetSpecialValueFor('max_stack')

    local modifier = params.target:FindModifierByNameAndCaster("modifier_scp682_plot_debuff", self:GetAbility():GetCaster())
    if modifier == nil then
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_scp682_plot_debuff", {duration = duration * (1 - params.target:GetStatusResistance()) })
    else
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_scp682_plot_debuff", {duration = duration * (1 - params.target:GetStatusResistance()) })
        if modifier:GetStackCount() < max_stack then
            modifier:IncrementStackCount()
        end
    end
end

modifier_scp682_plot_debuff = class({})

function modifier_scp682_plot_debuff:IsPurgable()
    if self:GetCaster():HasTalent("special_bonus_birzha_scp683_8") then
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
    local damage_base = self:GetAbility():GetSpecialValueFor("damage") * self:GetStackCount()
    local damage = (self:GetParent():GetMaxHealth() / 100 * damage_base) / 2
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_PURE})
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_scp682_plot_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_scp682_plot_debuff:OnDeath(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if self:GetCaster():HasScepter() then
        CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_scp682_plot_thinker", { duration = self:GetAbility():GetSpecialValueFor("scepter_duration") }, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
    end
end

modifier_scp682_plot_thinker = class({})

function modifier_scp682_plot_thinker:IsPurgable()
    return false
end

function modifier_scp682_plot_thinker:OnCreated( kv )
    local radius = self:GetAbility():GetSpecialValueFor( "scepter_radius" )
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/scp_plot_thinker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( radius, 1, 1 ) )
    self:AddParticle(particle, false, false, -1, false, false )
    self:GetParent():EmitSound("Hero_Alchemist.AcidSpray")
    self:StartIntervalThink(FrameTime())
end

function modifier_scp682_plot_thinker:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetCaster():IsAlive() then return end
    local radius = self:GetAbility():GetSpecialValueFor( "scepter_radius" )
    local distance = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
    if distance <= radius then
        local heal = self:GetCaster():GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("damage")
        heal = heal * FrameTime()
        self:GetCaster():Heal(heal, self:GetAbility())
    end
end

LinkLuaModifier( "modifier_scp682_ultimate", "abilities/heroes/scp682.lua", LUA_MODIFIER_MOTION_NONE )

scp682_ultimate = class({}) 

function scp682_ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_4")
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

function modifier_scp682_ultimate:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_scp682_ultimate:GetModifierModelScale( params )
    return 45
end

function modifier_scp682_ultimate:GetMinHealth()
    return 1
end

function modifier_scp682_ultimate:GetModifierStatusResistanceStacking()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_scp683_6")
end

function modifier_scp682_ultimate:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, nil)
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end