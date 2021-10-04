LinkLuaModifier("modifier_item_butter2", "items/butter2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_butter2_active", "items/butter2", LUA_MODIFIER_MOTION_NONE)

item_butter2 = class({})

function item_butter2:GetIntrinsicModifierName()
    return "modifier_item_butter2"
end

function item_butter2:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("item_gaybut")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_butter2_active", {duration = duration})
end

modifier_item_butter2 = class({})

function modifier_item_butter2:IsHidden()
	return true
end

function modifier_item_butter2:IsPurgable()
    return false
end

function modifier_item_butter2:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_butter2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_item_butter2:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor('agi')
end

function modifier_item_butter2:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_item_butter2:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor('ev')
end

function modifier_item_butter2:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('attack')
end

modifier_item_butter2_active = class({})

function modifier_item_butter2_active:OnCreated()
	if not IsServer() then return end
	local player = self:GetCaster():GetPlayerID()
	if IsUnlockedInPass(player, "reward52") then
		self.effect = "particles/birzhapass/butter2_donate.vpcf"
	else
		self.effect = "particles/items2_fx/butterfly_buff.vpcf"
	end
	local particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_item_butter2_active:GetTexture()
  	return "items/bf2"
end

function modifier_item_butter2_active:CheckState()
    local state = {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
         [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end