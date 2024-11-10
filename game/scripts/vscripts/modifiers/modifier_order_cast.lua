modifier_order_cast = class({})
function modifier_order_cast:IsHidden() return true end
function modifier_order_cast:IsPurgable() return false end
function modifier_order_cast:IsPurgeException() return false end
function modifier_order_cast:OnCreated(params)
    self.parent = self:GetParent()
    if not IsServer() then return end 
    self.ords = 
    {
        [DOTA_UNIT_ORDER_MOVE_ITEM] = true,
        [DOTA_UNIT_ORDER_SELL_ITEM] = true,
        [DOTA_UNIT_ORDER_PURCHASE_ITEM] = true,
    }
    self.range = 300
    self.cast = false
    self.target = EntIndexToHScript(params.target)
    self.parent:Stop()
    self.parent:Interrupt()
    self.parent:MoveToPosition(self.target:GetAbsOrigin())
    self.parent:MoveToPositionAggressive(self.parent:GetAbsOrigin())
    self.parent:MoveToNPC(self.target)
    self:StartIntervalThink(FrameTime())
end

function modifier_order_cast:OnIntervalThink()
    if not IsServer() then return end 
    if not self.target or self.target:IsNull() then 
        self:Destroy()
        return
    end
    if (self.parent:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() <= self.range then 
        self.cast = true
        self:Destroy()
        return
    end 
end 

function modifier_order_cast:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ORDER,
    }
end

function modifier_order_cast:OnOrder( params )
    if params.unit~=self.parent then return end
    if self.ords[params.order_type] then return end 
    self:Destroy()
end

function modifier_order_cast:OnDestroy()
    if not IsServer() then return end 
    self.parent:Stop()
    if not self.cast then return end
    if self.target:GetUnitName() == "npc_pumpkin_candies_custom" then
        self:SetChannelPumpkin()
    end
end 

function modifier_order_cast:SetChannelPumpkin()
    if not IsServer() then return end
    local ability = self.parent:FindAbilityByName("ability_custom_pumpkin_push")
    if ability then
        ability.target = self.target
        ability:SetLevel(1)
        self.parent:CastAbilityNoTarget(ability, self.parent:GetPlayerOwnerID())
    end
end