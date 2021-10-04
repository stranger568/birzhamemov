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

function modifier_item_tar2:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_tar2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }

    return funcs
end

function modifier_item_tar2:OnCreated()
	if not IsServer() then return end
	self.attacked = false
	self:StartIntervalThink(FrameTime())
end

function modifier_item_tar2:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor('str')
end

function modifier_item_tar2:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('hp')
end

function modifier_item_tar2:OnIntervalThink()
	if not IsServer() then return end
	local heal_sec = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second') / 100
	local interval = self:GetAbility():GetSpecialValueFor('heal_interval') 
	local heal = self:GetParent():GetMaxHealth() * heal_sec * interval
    if self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
	   self:GetParent():Heal(heal, self:GetAbility())
    end
end