LinkLuaModifier( "modifier_item_orchid_custom", "items/orchid", LUA_MODIFIER_MOTION_NONE )

item_orchid_custom = class({})

function item_orchid_custom:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("silence_duration")
	local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_orchid_malevolence_debuff", {duration = duration * (1 - target:GetStatusResistance())})
end

function item_orchid_custom:GetIntrinsicModifierName() 
    return "modifier_item_orchid_custom"
end

modifier_item_orchid_custom = class({})

function modifier_item_orchid_custom:IsHidden() return true end
function modifier_item_orchid_custom:IsPurgable() return false end
function modifier_item_orchid_custom:IsPurgeException() return false end
function modifier_item_orchid_custom:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_orchid_custom:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        }
end

function modifier_item_orchid_custom:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_orchid_custom:GetModifierConstantManaRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
	end
end

function modifier_item_orchid_custom:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
	end
end

function modifier_item_orchid_custom:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

LinkLuaModifier( "modifier_item_bloodthorn_custom", "items/orchid", LUA_MODIFIER_MOTION_NONE )

item_bloodthorn_custom = class({})

function item_bloodthorn_custom:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("silence_duration")
	local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_bloodthorn_debuff", {duration = duration * (1 - target:GetStatusResistance())})
end

function item_bloodthorn_custom:GetIntrinsicModifierName() 
    return "modifier_item_bloodthorn_custom"
end

modifier_item_bloodthorn_custom = class({})

function modifier_item_bloodthorn_custom:IsHidden() return true end
function modifier_item_bloodthorn_custom:IsPurgable() return false end
function modifier_item_bloodthorn_custom:IsPurgeException() return false end
function modifier_item_bloodthorn_custom:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bloodthorn_custom:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_bloodthorn_custom:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_bloodthorn_custom:GetModifierConstantManaRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
	end
end

function modifier_item_bloodthorn_custom:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
	end
end

function modifier_item_bloodthorn_custom:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end