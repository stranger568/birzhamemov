LinkLuaModifier("modifier_item_magical_rapier", "items/magical_rapier", LUA_MODIFIER_MOTION_NONE)

item_magical_rapier = class({})

function item_magical_rapier:GetIntrinsicModifierName()
	return "modifier_item_magical_rapier"
end

function item_magical_rapier:Spawn()
    if not IsServer() then return end
    local item = self
    if item and item.itembuydisabled == nil and item.timerscreated == nil then
        item.timerscreated = false
        Timers:CreateTimer(10, function()
            if item and not item:IsNull() then
                item.itembuydisabled = false
                item:SetSellable(false)
            end
        end)
    end
end

function item_magical_rapier:OnOwnerDied(params)
    local hOwner = self:GetOwner()
    if not hOwner:IsReincarnating() and hOwner:IsRealHero() then
    	self:DropItem(self, false)
    end
end

function item_magical_rapier:DropItem(hItem)
    local vLocation = GetGroundPosition(self:GetCaster():GetAbsOrigin(), self:GetCaster())
    local sName
    local vRandomVector = RandomVector(100)

    if hItem then
        sName = hItem:GetName()
        hItem:SetPurchaser(nil)
        hItem:SetPurchaseTime(0)
        self:GetCaster():DropItemAtPositionImmediate(hItem, vLocation)
    end
end

modifier_item_magical_rapier = class({})
function modifier_item_magical_rapier:IsHidden() return true end
function modifier_item_magical_rapier:IsPurgable() return false end
function modifier_item_magical_rapier:IsPurgeException() return false end
function modifier_item_magical_rapier:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_magical_rapier:DeclareFunctions() 
    return 
    {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    } 
end

function modifier_item_magical_rapier:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_damage")
end