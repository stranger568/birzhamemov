LinkLuaModifier("modifier_item_tar2", "items/item_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tar2_active", "items/item_heart", LUA_MODIFIER_MOTION_NONE)

item_tar2 = class({})

function item_tar2:GetIntrinsicModifierName()
    return "modifier_item_tar2"
end

modifier_item_tar2 = class({})

function modifier_item_tar2:IsHidden()
	return true
end

function modifier_item_tar2:IsPurgable()
    return false
end

function modifier_item_tar2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }

    return funcs
end

function modifier_item_tar2:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('str')
    end
end

function modifier_item_tar2:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_tar2:GetModifierHealthRegenPercentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second')
    end
end

--function modifier_item_tar2:OnIntervalThink()
--	if not IsServer() then return end
--	local heal_sec = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second') / 100
--	local interval = self:GetAbility():GetSpecialValueFor('heal_interval') 
--	local heal = self:GetParent():GetMaxHealth() * heal_sec * interval
--    if self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
--	   self:GetParent():Heal(heal, self:GetAbility())
--    end
--end