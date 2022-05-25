LinkLuaModifier("modifier_item_baldezh", "items/baldezh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_baldezh_active", "items/baldezh", LUA_MODIFIER_MOTION_NONE)

item_baldezh = class({})

function item_baldezh:GetIntrinsicModifierName()
    return "modifier_item_baldezh"
end

function item_baldezh:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("bkbitem")
    self:GetCaster():Purge( false, true, false, true, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_baldezh_active", {duration = duration})
    self:GetCaster():RemoveModifierByName("modifier_item_ethereal_blade_ethereal_custom")
end

item_superbaldezh = class({})

function item_superbaldezh:GetIntrinsicModifierName()
    return "modifier_item_baldezh"
end

function item_superbaldezh:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("vapebaldezh")
    self:GetCaster():Purge( false, true, false, true, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_baldezh_active", {duration = duration})
    self:GetCaster():RemoveModifierByName("modifier_item_ethereal_blade_ethereal_custom")
end

item_cosmobaldezh = class({})

function item_cosmobaldezh:GetIntrinsicModifierName()
    return "modifier_item_baldezh"
end

function item_cosmobaldezh:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("cosmobaldezh")
    self:GetCaster():Purge( false, true, false, true, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_baldezh_active", {duration = duration})
    self:GetCaster():RemoveModifierByName("modifier_item_ethereal_blade_ethereal_custom")
end

modifier_item_baldezh = class({})

function modifier_item_baldezh:IsHidden()
	return true
end

function modifier_item_baldezh:IsPurgable()
    return false
end

function modifier_item_baldezh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_item_baldezh:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('duration')
    end
end

function modifier_item_baldezh:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_damage')
    end
end

modifier_item_baldezh_active = class({})

function modifier_item_baldezh_active:IsPurgable()
    return false
end

function modifier_item_baldezh_active:OnCreated()
	if not IsServer() then return end

    local caster = self:GetCaster()

    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end

	local player = caster:GetPlayerID()
    if self:GetAbility():GetName() == "item_baldezh" then
		if DonateShopIsItemBought(player, 40) then
			self.effect = "particles/birzhapass/baldezh_donate.vpcf"
		else
			self.effect = "particles/items_fx/black_king_bar_avatar.vpcf"
		end
	end
	if self:GetAbility():GetName() == "item_cosmobaldezh" then
		if DonateShopIsItemBought(player, 42) then
			self.effect = "particles/birzhapass/baldezh2_donate.vpcf"
		else
			self.effect = "particles/cosmo/1.vpcf"
		end
	end
	if self:GetAbility():GetName() == "item_superbaldezh" then
		if DonateShopIsItemBought(player, 43) then
			self.effect = "particles/birzhapass/baldezh3_donate.vpcf"
		else
			self.effect = "particles/baldezhvape/bkb1.1.vpcf"
		end
	end
	local particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_item_baldezh_active:GetTexture()
    if not self:GetAbility() then
        return "items/baldezh"
    end
    if self:GetAbility():GetName() == "item_cosmobaldezh" then
        return "items/baldezh2"
    elseif self:GetAbility():GetName() == "item_superbaldezh" then
        return "items/baldezh3"
    else
        return "items/baldezh"
    end
end

function modifier_item_baldezh_active:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }

    return state
end