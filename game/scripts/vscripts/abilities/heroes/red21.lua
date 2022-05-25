LinkLuaModifier( "modifier_red_Vomit", "abilities/heroes/red21.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_red_Vomit_shard_root", "abilities/heroes/red21.lua", LUA_MODIFIER_MOTION_NONE )

red_vomit = class({})

function red_vomit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function red_vomit:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function red_vomit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function red_vomit:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_hitloc"))
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
        vSpawnOrigin        = point,
        fDistance           = 800,
        fStartRadius        = 125,
        fEndRadius          = 125,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1200,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("botan3")
end

function red_vomit:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_red21_1")

    if target then
        target:EmitSound("Hero_Venomancer.VenomousGaleImpact")
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        local duration = self:GetSpecialValueFor('duration')
        local movement_slow = self:GetSpecialValueFor('movement_slow')
        local slow_per_second = movement_slow / duration
        local slow_rate = 1 / slow_per_second
        if target.venomous_gale_timer then
            Timers:RemoveTimer(target.venomous_gale_timer)
        end
        target:AddNewModifier( caster, self, "modifier_red_Vomit", {duration = duration * (1 - target:GetStatusResistance())})
        if self:GetCaster():HasShard() then
            target:AddNewModifier( caster, self, "modifier_red_Vomit_shard_root", {duration = 2 * (1 - target:GetStatusResistance())})
        end
        target:SetModifierStackCount("modifier_red_Vomit", caster, movement_slow)
        target.venomous_gale_timer = Timers:CreateTimer(slow_rate, function()
            if IsValidEntity(target) and target:HasModifier("modifier_red_Vomit") then
                local current_slow = target:GetModifierStackCount("modifier_red_Vomit", caster)
                target:SetModifierStackCount("modifier_red_Vomit", caster, current_slow - 1)
                return slow_rate
            else
                return nil
            end
        end)
    end
end

modifier_red_Vomit = class({})

function modifier_red_Vomit:IsPurgable()
    return true
end

function modifier_red_Vomit:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_red_Vomit:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_red_Vomit:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(2)
end

function modifier_red_Vomit:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor('tick_damage')
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_red_Vomit:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return decFuncs
end

function modifier_red_Vomit:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * -1
end

modifier_red_Vomit_shard_root = class({})

function modifier_red_Vomit_shard_root:IsPurgable() return true end

function modifier_red_Vomit_shard_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
    }
end

function modifier_red_Vomit_shard_root:GetEffectName()
    return "particles/red21_shardcepter_sticky_snare_root.vpcf"
end

function modifier_red_Vomit_shard_root:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end





LinkLuaModifier( "modifier_red_MakeAFeeder", "abilities/heroes/red21.lua", LUA_MODIFIER_MOTION_NONE )

Red_MakeAFeeder = class({})

function Red_MakeAFeeder:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Red_MakeAFeeder:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Red_MakeAFeeder:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_red21_2")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_red_MakeAFeeder", {duration = duration})
    self:GetCaster():EmitSound("botan1")
end

modifier_red_MakeAFeeder = class({})

function modifier_red_MakeAFeeder:IsPurgable()
    return true
end

function modifier_red_MakeAFeeder:GetEffectName()
    return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_red_MakeAFeeder:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_red_MakeAFeeder:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return decFuncs
end

function modifier_red_MakeAFeeder:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_red_MakeAFeeder:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
end

Red_GetMoreMass = class({})

LinkLuaModifier( "modifier_red_GetMoreMass", "abilities/heroes/red21.lua", LUA_MODIFIER_MOTION_NONE )

modifier_red_GetMoreMass = class({})

function Red_GetMoreMass:GetIntrinsicModifierName()
    return "modifier_red_GetMoreMass"
end

function modifier_red_GetMoreMass:IsHidden()
    return true
end

function modifier_red_GetMoreMass:IsPurgable()
    return false
end

function modifier_red_GetMoreMass:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }

    return decFuncs
end

function modifier_red_GetMoreMass:GetModifierAttackSpeedBonus_Constant()
    if self:GetCaster():HasScepter() then return end
    return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_red_GetMoreMass:GetModifierMoveSpeedBonus_Percentage()
    if self:GetCaster():HasScepter() then return end
    return self:GetAbility():GetSpecialValueFor('move_speed')
end

function modifier_red_GetMoreMass:GetModifierPhysicalArmorBonus()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor('armor')
end

function modifier_red_GetMoreMass:GetModifierHealthBonus()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor('health')
end

LinkLuaModifier( "modifier_red_HUSTLE", "abilities/heroes/red21.lua", LUA_MODIFIER_MOTION_NONE )

Red_HUSTLE = class({})

function Red_HUSTLE:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Red_HUSTLE:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Red_HUSTLE:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_red21_3")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_red_HUSTLE", {duration = duration})
    self:GetCaster():EmitSound("botan2")
end

modifier_red_HUSTLE = class({})

function modifier_red_HUSTLE:IsPurgable()
    return false
end

function modifier_red_HUSTLE:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("botan2")
end

function modifier_red_HUSTLE:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_strafe.vpcf"
end

function modifier_red_HUSTLE:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_red_HUSTLE:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }

    return decFuncs
end

function modifier_red_HUSTLE:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_red_HUSTLE:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }

    return state
end

function modifier_red_HUSTLE:GetModifierPreAttack_CriticalStrike()
    if not IsServer() then return end    
    local chance = self:GetAbility():GetSpecialValueFor('chance')   
    local critical_damage = self:GetAbility():GetSpecialValueFor('critical_damage')           
    if RandomInt(1, 100) <= chance then        
        return critical_damage
    end
    return nil
end
