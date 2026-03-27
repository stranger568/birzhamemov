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
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }

    return funcs
end

function modifier_item_tar2:OnCreated()
    if not IsServer() then return end
    self.str = self:GetAbility():GetSpecialValueFor('str')
    self.health_regen_percent_per_second = self:GetAbility():GetSpecialValueFor('health_regen_percent_per_second')
    self.missing_health_regen = self:GetAbility():GetSpecialValueFor('missing_health_regen')
    if self:GetParent():FindModifierByName("modifier_item_heart") and self:GetParent():FindAllModifiersByName("modifier_item_tar2")[1] ~= self then
        self.missing_health_regen = 0
    end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_tar2:OnIntervalThink()
    if not IsServer() then return end
    self.str = self:GetAbility():GetSpecialValueFor('str')
    if self:GetParent():HasModifier("modifier_item_heart") and self:GetParent():FindAllModifiersByName("modifier_item_tar2")[1] ~= self then
        self.missing_health_regen = 0
    else
        local base_regen = self.health_regen_percent_per_second
        local missing_hp_pct = (self:GetParent():GetMaxHealth() - self:GetParent():GetHealth()) / self:GetParent():GetMaxHealth()
        local extra_regen = missing_hp_pct * self.missing_health_regen
        self.hp_regen_perc = base_regen + extra_regen
    end
    self:SendBuffRefreshToClients()
end

function modifier_item_tar2:AddCustomTransmitterData()
    return 
    {
        str = self.str,
        hp_regen_perc = self.hp_regen_perc,
    }
end

function modifier_item_tar2:HandleCustomTransmitterData( data )
    self.str = data.str
    self.hp_regen_perc = data.hp_regen_perc
end

function modifier_item_tar2:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self.str
end

function modifier_item_tar2:GetModifierHealthRegenPercentage()
    if not self:GetAbility() then return end
    return self.hp_regen_perc
end