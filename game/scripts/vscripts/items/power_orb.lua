LinkLuaModifier( "modifier_power_orb", "items/power_orb", LUA_MODIFIER_MOTION_NONE )

item_power_orb = class({})

function item_power_orb:GetIntrinsicModifierName()
    return "modifier_power_orb"
end

function item_power_orb:GetAbilityTextureName()
    if IsClient() then
        if self:GetSecondaryCharges() == 1 then
            return "items/power_orb_1"
        elseif self:GetSecondaryCharges() == 2 then
            return "items/power_orb_2"
        elseif self:GetSecondaryCharges() == 3 then
            return "items/power_orb_3"
        end
    end
end

function item_power_orb:Spawn()
    if not IsServer() then return end
    if self and self:GetSecondaryCharges() == 0 then
        self:SetSecondaryCharges(1)
    end
end

function item_power_orb:OnSpellStart()
    if not IsServer() then return end

    if self:GetSecondaryCharges() == 1 then
        self:SetSecondaryCharges(2)
    elseif self:GetSecondaryCharges() == 2 then
        self:SetSecondaryCharges(3)
    elseif self:GetSecondaryCharges() == 3 then
        self:SetSecondaryCharges(1)
    end

    self:GetCaster():CalculateStatBonus(true)
    self:SetSellable(true)
end

modifier_power_orb = class({})

function modifier_power_orb:OnCreated()
    if not IsServer() then return end
    self.bonus_attributes = self:GetAbility():GetSpecialValueFor("bonus_attributes")
    self.unselect_attribute_pct = self:GetAbility():GetSpecialValueFor("unselect_attribute_pct")
    self.select_attribute_pct = self:GetAbility():GetSpecialValueFor("select_attribute_pct")
    self.str_perc = 0
    self.agi_perc = 0
    self.int_perc = 0
    self:GetParent():CalculateStatBonus(true)
    self:StartIntervalThink(0.1)
end

function modifier_power_orb:OnIntervalThink()
    if not IsServer() then return end
    self.str_perc = 0
    self.agi_perc = 0
    self.int_perc = 0
    if self:GetAbility():GetSecondaryCharges() == 1 then
        self.str_perc = self:GetParent():GetStrength() / 100 * self.select_attribute_pct
        self.agi_perc = self:GetParent():GetAgility() / 100 * self.unselect_attribute_pct
        self.int_perc = self:GetParent():GetIntellect(false) / 100 * self.unselect_attribute_pct
    elseif self:GetAbility():GetSecondaryCharges() == 2 then
        self.str_perc = self:GetParent():GetStrength() / 100 * self.unselect_attribute_pct
        self.agi_perc = self:GetParent():GetAgility() / 100 * self.select_attribute_pct
        self.int_perc = self:GetParent():GetIntellect(false) / 100 * self.unselect_attribute_pct
    elseif self:GetAbility():GetSecondaryCharges() == 3 then
        self.str_perc = self:GetParent():GetStrength() / 100 * self.unselect_attribute_pct
        self.agi_perc = self:GetParent():GetAgility() / 100 * self.unselect_attribute_pct
        self.int_perc = self:GetParent():GetIntellect(false) / 100 * self.select_attribute_pct
    end
    self:GetParent():CalculateStatBonus(true)
end

function modifier_power_orb:IsHidden() return true end
function modifier_power_orb:IsPurgable() return false end
function modifier_power_orb:IsPurgeException() return false end

function modifier_power_orb:DeclareFunctions() 
    return 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    } 
end

function modifier_power_orb:GetModifierBonusStats_Strength()
    return self.bonus_attributes + self.str_perc
end

function modifier_power_orb:GetModifierBonusStats_Agility()
    return self.bonus_attributes + self.agi_perc
end

function modifier_power_orb:GetModifierBonusStats_Intellect()
    return self.bonus_attributes + self.int_perc
end