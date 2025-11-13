LinkLuaModifier("modifier_item_imba_phase_boots_2", "items/abibas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_phase_boots_2_active", "items/abibas", LUA_MODIFIER_MOTION_NONE)

item_imba_phase_boots_2 = class({})

function item_imba_phase_boots_2:GetIntrinsicModifierName()
    return "modifier_item_imba_phase_boots_2"
end

function item_imba_phase_boots_2:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end
    local player = caster:GetPlayerID()
    if DonateShopIsItemBought(player, 45) then
        local haste_pfx = ParticleManager:CreateParticle("particles/birzhapass/abibas_boots_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(haste_pfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(haste_pfx)
    else
        local haste_pfx = ParticleManager:CreateParticle("particles/abibas/phase_abibas_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(haste_pfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(haste_pfx)
    end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_imba_phase_boots_2_active", {duration = duration} )
    self:GetParent():EmitSound("DOTA_Item.PhaseBoots.Activate")
end

modifier_item_imba_phase_boots_2 = class({})

function modifier_item_imba_phase_boots_2:IsHidden() return true end
function modifier_item_imba_phase_boots_2:IsPurgable() return false end
function modifier_item_imba_phase_boots_2:IsPurgeException() return false end
function modifier_item_imba_phase_boots_2:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_imba_phase_boots_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_imba_phase_boots_2:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end

function modifier_item_imba_phase_boots_2:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_damage')
    end
end

function modifier_item_imba_phase_boots_2:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_armor')
    end
end

function modifier_item_imba_phase_boots_2:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_str')
    end
end

function modifier_item_imba_phase_boots_2:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_int')
    end
end

modifier_item_imba_phase_boots_2_active = class({})

function modifier_item_imba_phase_boots_2_active:IsPurgable()
    return false
end

function modifier_item_imba_phase_boots_2_active:GetTexture()
    return "items/abibas"
end

function modifier_item_imba_phase_boots_2_active:OnCreated()
    self.movespeed_bonus_range = self:GetAbility():GetSpecialValueFor("movespeed_bonus_range")
    self.movespeed_bonus_melee = self:GetAbility():GetSpecialValueFor("movespeed_bonus_melee")
    self.attack_speed_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end

function modifier_item_imba_phase_boots_2_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_item_imba_phase_boots_2_active:GetModifierMoveSpeedBonus_Percentage()
    if not self:GetParent():IsRangedAttacker() then
        return self.movespeed_bonus_melee
    else
        return self.movespeed_bonus_range
    end
end

function modifier_item_imba_phase_boots_2_active:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_bonus
end

function modifier_item_imba_phase_boots_2_active:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end
