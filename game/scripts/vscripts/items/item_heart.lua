LinkLuaModifier("modifier_item_tar2", "items/item_heart", LUA_MODIFIER_MOTION_NONE)

item_tar2 = class({})

function item_tar2:GetIntrinsicModifierName()
    return "modifier_item_tar2"
end

modifier_item_tar2 = class({})

function modifier_item_tar2:IsHidden() return true end
function modifier_item_tar2:IsPurgable() return false end
function modifier_item_tar2:IsPurgeException() return false end
function modifier_item_tar2:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_tar2:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }

    return funcs
end

function modifier_item_tar2:OnCreated()
    if not IsServer() then return end
    self.health = self:GetAbility():GetSpecialValueFor('hp')
    self.str = self:GetAbility():GetSpecialValueFor('str')
    self.health_regen_percent_per_second = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second')
    if self:GetParent():FindAllModifiersByName("modifier_item_tar2")[1] ~= self then
        self.health_regen_percent_per_second = 0
    end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_tar2:OnIntervalThink()
    if not IsServer() then return end
    self.health = self:GetAbility():GetSpecialValueFor('hp')
    self.str = self:GetAbility():GetSpecialValueFor('str')
    if self:GetParent():FindAllModifiersByName("modifier_item_tar2")[1] ~= self then
        self.health_regen_percent_per_second = 0
    else
        self.health_regen_percent_per_second = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second')
    end
    self:SendBuffRefreshToClients()
end

function modifier_item_tar2:AddCustomTransmitterData()
    return 
    {
        health = self.health,
        str = self.str,
        health_regen_percent_per_second = self.health_regen_percent_per_second,
    }
end

function modifier_item_tar2:HandleCustomTransmitterData( data )
    self.health = data.health
    self.str = data.str
    self.health_regen_percent_per_second = data.health_regen_percent_per_second
end

function modifier_item_tar2:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self.str
end

function modifier_item_tar2:GetModifierHealthBonus()
    if not self:GetAbility() then return end
    return self.health
end

function modifier_item_tar2:GetModifierHealthRegenPercentage()
    if not self:GetAbility() then return end
    return self.health_regen_percent_per_second
end