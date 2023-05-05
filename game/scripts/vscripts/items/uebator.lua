LinkLuaModifier( "modifier_item_uebator", "items/uebator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_uebator_active", "items/uebator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_uebator_cooldown", "items/uebator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_uebator_satanic", "items/uebator", LUA_MODIFIER_MOTION_NONE )

item_uebator = class({})

function item_uebator:OnSpellStart() 
	if not IsServer() then return end
	local duration_satanic = self:GetSpecialValueFor("duration_satanic")
	self:GetCaster():EmitSound("DOTA_Item.Satanic.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_uebator_satanic", {duration = duration_satanic})
end

function item_uebator:GetIntrinsicModifierName() 
	return "modifier_item_uebator"
end

modifier_item_uebator = class({})

function modifier_item_uebator:IsHidden() return true end
function modifier_item_uebator:IsPurgable() return false end
function modifier_item_uebator:IsPurgeException() return false end
function modifier_item_uebator:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_uebator:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
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

function modifier_item_uebator:OnTakeDamage(params)
	if IsServer() then

		if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and not params.unit:IsWard() then
			if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
				local heal = self:GetAbility():GetSpecialValueFor("lifesteal_passive") / 100 * params.damage
		        self:GetParent():Heal(heal, self:GetAbility())
		        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
		        ParticleManager:ReleaseParticleIndex( effect_cast )
			end
		end

		if params.unit == self:GetParent() and params.attacker ~= self:GetParent() then
			if not self:GetParent():HasModifier("modifier_item_uebator_cooldown") then
				if self:GetParent():IsIllusion() then return end
				local duration = self:GetAbility():GetSpecialValueFor("duration")
				local hp_loss = self:GetAbility():GetSpecialValueFor("hp_loss")
				if self:GetParent():GetHealthPercent() <= 1 then
					if self:GetParent():GetHealth() <= 1 then
						self:GetParent():SetHealth(1)
					end
					self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_uebator_active", {duration = duration})
					ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_ABSORIGIN, self:GetParent())
					self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_uebator_cooldown", {duration = self:GetAbility():GetSpecialValueFor("cooldown_grave") * self:GetParent():GetCooldownReduction()})
					return
				end

				if self:GetParent():GetHealthPercent() <= hp_loss then
					self:GetParent():SetHealth(self:GetParent():GetMaxHealth() / 100 * hp_loss)
					self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_uebator_active", {duration = duration})
					ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_ABSORIGIN, self:GetParent())
					self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_uebator_cooldown", {duration = self:GetAbility():GetSpecialValueFor("cooldown_grave") * self:GetParent():GetCooldownReduction()})
				end
			end
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

		self:GetParent():Purge(false, true, false, true, true)

		self:GetParent():EmitSound("itemrapreward")

		if DonateShopIsItemBought(player, 49) then
			self.uebator_effect = ParticleManager:CreateParticle("particles/item_uebator_donate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		else
			self.uebator_effect = ParticleManager:CreateParticle("particles/item_uebator.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		end

		self:AddParticle(self.uebator_effect, false, false, -1, false, false)
	end
end

function modifier_item_uebator_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_uebator_active:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
	return funcs
end

function modifier_item_uebator_active:GetMinHealth()
	return 1 
end

function modifier_item_uebator_active:GetTexture()
	return "items/uebator"
end

function modifier_item_uebator_active:GetModifierStatusResistanceStacking()
	return self:GetAbility():GetSpecialValueFor("resist_effects")
end

modifier_item_uebator_satanic = class({})

function modifier_item_uebator_satanic:GetTexture()
	return "items/uebator"
end

function modifier_item_uebator_satanic:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_item_uebator_satanic:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_item_uebator_satanic:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

function modifier_item_uebator_satanic:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_item_uebator_cooldown = class({})

function modifier_item_uebator_cooldown:RemoveOnDeath() return false end
function modifier_item_uebator_cooldown:IsDebuff() return true end
function modifier_item_uebator_cooldown:IsPurgable() return false end
function modifier_item_uebator_cooldown:IsPurgeException() return false end
function modifier_item_uebator_cooldown:GetTexture()
	return "items/uebator"
end