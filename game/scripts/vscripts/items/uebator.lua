LinkLuaModifier( "modifier_item_uebator", "items/uebator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_uebator_active", "items/uebator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_uebator_satanic", "items/uebator", LUA_MODIFIER_MOTION_NONE )

item_uebator = class({})

function item_uebator:OnSpellStart() 
	if not IsServer() then return end
	local duration_satanic = self:GetSpecialValueFor("duration_satanic")
	EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_uebator_satanic", {duration = duration_satanic})
end

function item_uebator:GetIntrinsicModifierName() 
	return "modifier_item_uebator"
end

modifier_item_uebator = class({})

function modifier_item_uebator:IsHidden()
	return true
end

function modifier_item_uebator:IsPurgable()
    return false
end

function modifier_item_uebator:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MIN_HEALTH
		}
end

function modifier_item_uebator:GetModifierHealthBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_health")
	end
end

function modifier_item_uebator:GetModifierManaBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana")
	end
end

function modifier_item_uebator:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_strength")
	end
end

function modifier_item_uebator:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_uebator:GetModifierStatusResistanceStacking()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("resist_effects")
	end
end

function modifier_item_uebator:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() and params.attacker ~= self:GetParent() then
			if self:GetAbility():IsFullyCastable() then
				if self:GetParent():IsIllusion() then return end
				self.minhealth_check = true
				local duration = self:GetAbility():GetSpecialValueFor("duration")
				local hp_loss = self:GetAbility():GetSpecialValueFor("hp_loss")
				if self:GetParent():GetHealthPercent() <= 1 then
					self:GetParent():SetHealth(1)
					self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_uebator_active", {duration = duration})
					ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_ABSORIGIN, self:GetParent())
					self:GetAbility():UseResources(false,false,true)
					return
				end

				if self:GetParent():GetHealthPercent() <= hp_loss then
					self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_uebator_active", {duration = duration})
					ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_ABSORIGIN, self:GetParent())
					self:GetAbility():UseResources(false,false,true)
				end
			end
		end
	end
end

function modifier_item_uebator:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetParent():Heal(params.damage * 0.25, nil)
		end
	end
end

modifier_item_uebator_active = class({})

function modifier_item_uebator_active:IsPurgable() return false end
function modifier_item_uebator_active:IsPurgeException() return false end

function modifier_item_uebator_active:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()

	    if not self:GetCaster():IsHero() then
	        caster = caster:GetOwner()
	    end
		local player = caster:GetPlayerID()
		EmitSoundOn( "itemrapreward", self:GetParent() )
		if DonateShopIsItemBought(player, 49) then
			self.uebator_effect = ParticleManager:CreateParticle("particles/item_uebator_donate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		else
			self.uebator_effect = ParticleManager:CreateParticle("particles/item_uebator.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		end
	end
end

function modifier_item_uebator_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_uebator_active:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_MIN_HEALTH}
	return funcs
end

function modifier_item_uebator_active:GetMinHealth()
	return 1 
end

function modifier_item_uebator_active:OnDestroy()
	if not IsServer() then return end
	if self.uebator_effect then
		ParticleManager:DestroyParticle(self.uebator_effect, true)
	end
end

function modifier_item_uebator_active:GetTexture()
	return "items/uebator"
end

modifier_item_uebator_satanic = class({})

function modifier_item_uebator_satanic:GetTexture()
	return "items/uebator"
end

function modifier_item_uebator_satanic:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return funcs
end

function modifier_item_uebator_satanic:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
			self:GetParent():Heal(params.damage * lifesteal, nil)
		end
	end
end

function modifier_item_uebator_satanic:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

function modifier_item_uebator_satanic:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end