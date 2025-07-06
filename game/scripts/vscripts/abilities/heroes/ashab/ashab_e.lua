LinkLuaModifier("modifier_ashab_e", "abilities/heroes/ashab/ashab_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ashab_e_debuff_hand", "abilities/heroes/ashab/ashab_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ashab_e_debuff_legs", "abilities/heroes/ashab/ashab_e", LUA_MODIFIER_MOTION_NONE)

ashab_e = class({})

function ashab_e:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf", context)
end

function ashab_e:GetIntrinsicModifierName()
    return "modifier_ashab_e"
end

modifier_ashab_e = class({})
function modifier_ashab_e:IsHidden() return true end
function modifier_ashab_e:IsPurgable() return false end
function modifier_ashab_e:IsPurgeException() return false end
function modifier_ashab_e:RemoveOnDeath() return false end
function modifier_ashab_e:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
    }
end
function modifier_ashab_e:GetModifierPreAttack_BonusDamage()
    return self:GetCaster():GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("max_health_to_damage")
end
function modifier_ashab_e:GetModifierAttackSpeedPercentage()
    return self:GetAbility():GetSpecialValueFor("attack_speed_slow_self")
end

function modifier_ashab_e:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    if params.attacker == params.target then return end
    local chance = self:GetAbility():GetSpecialValueFor("chance")
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    if RollPercentage(chance) then
        if RollPercentage(50) then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ashab_e_debuff_legs", {duration = duration})
        else
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ashab_e_debuff_hand", {duration = duration})
        end
    end
end

modifier_ashab_e_debuff_legs = class({})

function modifier_ashab_e_debuff_legs:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_ashab_e_debuff_legs:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_ashab_e_debuff_legs:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end

function modifier_ashab_e_debuff_legs:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_ashab_e_debuff_hand = class({})

function modifier_ashab_e_debuff_hand:OnCreated()
    if not IsServer() then return end
    self.attack_speed = self:GetParent():GetDisplayAttackSpeed() / 100 * self:GetAbility():GetSpecialValueFor("attack_speed_slow")
end

function modifier_ashab_e_debuff_hand:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_ashab_e_debuff_hand:GetModifierAttackSpeedBonus_Constant()
    if not IsServer() then return end
    if self.attack_speed then
        return self.attack_speed * (-1)
    end
end

function modifier_ashab_e_debuff_hand:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end

function modifier_ashab_e_debuff_hand:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end