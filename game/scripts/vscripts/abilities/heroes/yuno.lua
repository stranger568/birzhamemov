LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_yuno_rage", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)

Yuno_Rage = class({}) 

function Yuno_Rage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Yuno_Rage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Yuno_Rage:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("screamy")
    local duration = self:GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_2")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_yuno_rage", {duration = duration})
end

modifier_yuno_rage = class({}) 

function modifier_yuno_rage:IsPurgable() return false end

function modifier_yuno_rage:GetEffectName()
    return "particles/items2_fx/mask_of_madness.vpcf" 
end

function modifier_yuno_rage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_yuno_rage:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return decFuncs
end

function modifier_yuno_rage:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('speed_a')
end

function modifier_yuno_rage:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('bonus_dmg')
end

function modifier_yuno_rage:CheckState()
    if self:GetCaster():HasTalent("special_bonus_birzha_yuno_1") then return end
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

function modifier_yuno_rage:OnAttackLanded(kv)
    if not IsServer() then return end
    local attacker = kv.attacker
    local target = kv.target
    local damage = kv.damage
    if self:GetParent() == attacker then
	    if attacker:GetTeam() == target:GetTeam() then
			return
		end 
        if target:IsOther() then
            return nil
        end
        local lifesteal = self:GetAbility():GetSpecialValueFor('lifesteal')
        local heal_hp = damage / 100 * lifesteal
        self:GetParent():Heal(heal_hp, self:GetAbility())
    end
end

LinkLuaModifier("modifier_yuno_sharpness_axe", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yuno_sharpness_axe_effect", "abilities/heroes/yuno", LUA_MODIFIER_MOTION_NONE)

Yuno_sharpness_axe = class({}) 

function Yuno_sharpness_axe:GetIntrinsicModifierName()
    return "modifier_yuno_sharpness_axe"
end

modifier_yuno_sharpness_axe = class({})

function modifier_yuno_sharpness_axe:IsHidden()
    return (not self:GetCaster():HasShard() or self:GetStackCount() == 0)
end

function modifier_yuno_sharpness_axe:IsPurgable()
    return false
end

function modifier_yuno_sharpness_axe:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_yuno_sharpness_axe:OnCreated()
    if not IsServer() then return end
    self.current_target = nil
    self.particle = nil
end

function modifier_yuno_sharpness_axe:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if target:IsOther() then
            return nil
        end
        if target:IsBoss() then return end

        local shard_damage = 0

        if self:GetParent():HasShard() then
            if self.current_target ~= nil and self.current_target ~= params.target then
                self:SetStackCount(0)
                if self.particle and not self.particle:IsNull() then
                    self.particle:Destroy()
                    self.particle = nil
                end
            end

            if self.current_target == params.target then
                self:SetStackCount(self:GetStackCount() + 1)
                if (self.particle == nil or self.particle:IsNull()) and self:GetStackCount() >= 5 then
                    self.particle = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_yuno_sharpness_axe_effect", {})
                end
            end

            self.current_target = params.target

            shard_damage = self:GetStackCount()
        end

        local damage_bonus = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_yuno_3")
        local base_damage = self:GetAbility():GetSpecialValueFor("base_damage") + (self:GetAbility():GetSpecialValueFor("base_damage") * shard_damage)
        local damage = damage_bonus / 100 * params.original_damage
        damage = damage + base_damage
        target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
        ParticleManager:SetParticleControl( nFXIndex, 1, target:GetOrigin() )
        ParticleManager:SetParticleControlForward( nFXIndex, 1, self:GetParent():GetForwardVector() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        ApplyDamage({ victim = target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() })
    end
end

modifier_yuno_sharpness_axe_effect = class({})

function modifier_yuno_sharpness_axe_effect:IsHidden() return true end
function modifier_yuno_sharpness_axe_effect:IsPurgable() return false end

function modifier_yuno_sharpness_axe_effect:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_yuno_sharpness_axe_effect:StatusEffectPriority()
    return 10
end

yuno_omnipresence = class({})

function yuno_omnipresence:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function yuno_omnipresence:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function yuno_omnipresence:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function yuno_omnipresence:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    return true;
end

function yuno_omnipresence:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("blink_range")
    local direction = (point - origin)
    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end
    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )
    ProjectileManager:ProjectileDodge(self:GetCaster())
    self:PlayEffects( origin, direction )
end

function yuno_omnipresence:PlayEffects( origin, direction )
    local particle_one = ParticleManager:CreateParticle( "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    EmitSoundOnLocationWithCaster( origin, "Hero_QueenOfPain.Blink_out", self:GetCaster() )

    local particle_two = ParticleManager:CreateParticle( "particles/units/heroes/hero_queenofpain/queen_blink_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_QueenOfPain.Blink_in", self:GetCaster() )
end