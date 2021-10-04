LinkLuaModifier( "modifier_item_nuts", "items/nuts", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_nuts_buff", "items/nuts", LUA_MODIFIER_MOTION_NONE )

item_nuts = class({})

function item_nuts:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_nuts_buff", {duration = self:GetSpecialValueFor("duration")})
end

function item_nuts:GetIntrinsicModifierName() 
    return "modifier_item_nuts"
end

modifier_item_nuts = class({})

function modifier_item_nuts:IsHidden()
    return true
end

function modifier_item_nuts:IsPurgable()
    return false
end

function modifier_item_nuts:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
end

function modifier_item_nuts:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_nuts:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_item_nuts:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
			self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
		end
	end
end

modifier_item_nuts_buff = class({})

function modifier_item_nuts_buff:IsPurgable()
    return false
end

function modifier_item_nuts_buff:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
end

function modifier_item_nuts_buff:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

function modifier_item_nuts_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_item_nuts_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_item_nuts_buff:GetEffectName()
    return "particles/nuts_effect.vpcf" 
end

function modifier_item_nuts_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end