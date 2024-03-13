LinkLuaModifier( "modifier_item_overheal_trank", "items/tranquil", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_overheal_trank_active", "items/tranquil", LUA_MODIFIER_MOTION_NONE )

item_overheal_trank = class({})

modifier_item_overheal_trank = class({})

function item_overheal_trank:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_item_overheal_trank_active", {duration = duration})
    target:EmitSound("Rune.Regen")
end

function item_overheal_trank:GetIntrinsicModifierName() 
    return "modifier_item_overheal_trank"
end

modifier_item_overheal_trank = class({})

function modifier_item_overheal_trank:IsHidden() return true end
function modifier_item_overheal_trank:IsPurgable() return false end
function modifier_item_overheal_trank:IsPurgeException() return false end
function modifier_item_overheal_trank:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_overheal_trank:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS
    }

    return funcs
end

function modifier_item_overheal_trank:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
    end
end

function modifier_item_overheal_trank:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_regen")
    end
end

function modifier_item_overheal_trank:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_health")
    end
end

modifier_item_overheal_trank_active = class({})

function modifier_item_overheal_trank_active:GetTexture() return "rune_regen" end
function modifier_item_overheal_trank_active:IsPurgable() return false end

function modifier_item_overheal_trank_active:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_item_overheal_trank_active:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():GetHealthPercent() >= 100 and self:GetParent():GetManaPercent() >= 100 then
        self:Destroy()
    end
end

function modifier_item_overheal_trank_active:DeclareFunctions()
	return 
    {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, 
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_item_overheal_trank_active:GetModifierTotalPercentageManaRegen() return 6 end
function modifier_item_overheal_trank_active:GetModifierHealthRegenPercentage() return 6 end

function modifier_item_overheal_trank_active:GetEffectName()
	return "particles/generic_gameplay/rune_regen_owner.vpcf"
end

function modifier_item_overheal_trank_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_overheal_trank_active:OnTakeDamage(params)
	if params.unit ~= self:GetParent() then return end
    if params.attacker == self:GetParent() then return end
    if params.damage > 0 then
        self:Destroy()
    end
end