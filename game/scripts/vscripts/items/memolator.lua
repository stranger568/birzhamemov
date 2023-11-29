LinkLuaModifier("modifier_item_memolator", "items/memolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_memolator_debuff", "items/memolator", LUA_MODIFIER_MOTION_NONE)

item_memolator = class({})

function item_memolator:GetIntrinsicModifierName()
	return "modifier_item_memolator"
end

modifier_item_memolator = class({})

function modifier_item_memolator:IsHidden() return true end
function modifier_item_memolator:IsPurgable() return false end
function modifier_item_memolator:IsPurgeException() return false end

function modifier_item_memolator:DeclareFunctions()
	return 
    {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_item_memolator:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage") + (self:GetAbility():GetCurrentCharges() * self:GetAbility():GetSpecialValueFor("damage_per_stack"))
    end
end

function modifier_item_memolator:GetModifierProjectileName()
    return "particles/items_fx/desolator_projectile.vpcf"
end

function modifier_item_memolator:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():IsIllusion() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    
    if self:GetAbility() and self:GetAbility():GetName() == "item_memolator3" then
        local target_health = (100 - params.target:GetHealthPercent()) / self:GetAbility():GetSpecialValueFor("health_percent_per_corruption")
        local new_armor = params.target:GetPhysicalArmorBaseValue() / 100 * (self:GetAbility():GetSpecialValueFor("bonus_corruption_armor_percent") * target_health)
        print("new_armor", new_armor)
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff", {duration = duration, new_armor = new_armor})
    else
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff", {duration = duration})
    end
    params.target:EmitSound("Item_Desolator.Target")
end

function modifier_item_memolator:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then return end
    if params.attacker ~= self:GetParent() then return end
    if not params.unit:IsRealHero() then return end
    if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("damage_stack_max") then
        self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + self:GetAbility():GetSpecialValueFor("damage_per_kill"))
        self:SetStackCount(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("damage_per_kill"))
    end
end

item_memolator2 = item_memolator
item_memolator3 = item_memolator

modifier_item_memolator_debuff = class({})

function modifier_item_memolator_debuff:IsPurgable() return false end

function modifier_item_memolator_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff:OnCreated(params)
    if not IsServer() then return end
    self.base_coruprion_armor = self:GetAbility():GetSpecialValueFor("base_coruprion_armor")
    if params.new_armor then
        self.base_coruprion_armor = self.base_coruprion_armor - params.new_armor
    end
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_memolator_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_item_memolator_debuff:GetModifierPhysicalArmorBonus()
    return self.base_coruprion_armor
end

function modifier_item_memolator_debuff:GetTexture()
    return "Items/memolator"
end

function modifier_item_memolator_debuff:AddCustomTransmitterData()
    return 
    {
        base_coruprion_armor = self.base_coruprion_armor,
    }
end

function modifier_item_memolator_debuff:HandleCustomTransmitterData( data )
    self.base_coruprion_armor = data.base_coruprion_armor
end

function modifier_item_memolator_debuff:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end