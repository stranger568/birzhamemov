LinkLuaModifier("modifier_item_nimbus", "items/nimbus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_nimbus_active", "items/nimbus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_nimbus_debuff", "items/nimbus", LUA_MODIFIER_MOTION_NONE)

item_nimbus_lapteva = class({})

function item_nimbus_lapteva:GetIntrinsicModifierName()
    return "modifier_item_nimbus"
end

function item_nimbus_lapteva:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():Purge(false, true, false, true, true)
    self:GetCaster():EmitSound("nimbus_use")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_nimbus_active", {duration = duration} )
end

modifier_item_nimbus = class({})

function modifier_item_nimbus:IsHidden()
	return true
end

function modifier_item_nimbus:IsPurgable()
    return false
end

function modifier_item_nimbus:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_nimbus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL,
    }

    return funcs
end

function modifier_item_nimbus:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_item_nimbus:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor('bonus_health_regen')
end

function modifier_item_nimbus:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_nimbus:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_nimbus:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_nimbus:GetModifierPhysical_ConstantBlockSpecial()
	if RandomInt(1, 100) <= 50 then
   		return 70
   	end
end

modifier_item_nimbus_active = class({})

function modifier_item_nimbus_active:GetTexture()
  	return "items/nimbus"
end

function modifier_item_nimbus_active:GetStatusEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"
end

function modifier_item_nimbus_active:OnCreated()
    if not IsServer() then return end
    self.carapaced_units = {}
    self.caster_stun = true
end

function modifier_item_nimbus_active:OnDestroy()
    if not IsServer() then return end
	if self.caster_stun then
		self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_item_nimbus_debuff", {duration = 0.5})
		self:GetCaster():EmitSound("nimbus_fail")
	end
end

function modifier_item_nimbus_active:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_item_nimbus_active:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
    	if params.inflictor then
    		if params.inflictor:GetAbilityName() == "fut_mum_eat" then return end
    	end
	    local damageTaken = params.original_damage
		if params.attacker == self:GetParent() then return end
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
			if not self.carapaced_units[ params.attacker:entindex() ] then
		        local damageTable = {
		            victim = params.attacker,
		            attacker = self:GetCaster(),
		            damage = damageTaken,
		            damage_type = params.damage_type,
		            ability = self:GetAbility(),
		            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		        }
		        ApplyDamage(damageTable)
				self:GetParent():Purge( false, true, false, true, false)
			end
			local stun_duration = self:GetAbility():GetSpecialValueFor('stun_duration')
			params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_nimbus_debuff", {duration = stun_duration * (1 - params.attacker:GetStatusResistance())})
			self:GetCaster():EmitSound("nimbus_active")
			self.caster_stun = false
			self:GetParent():Purge( false, true, false, true, false)
			self:Destroy()
			self.carapaced_units[ params.attacker:entindex() ] = params.attacker
		end
    end
end

modifier_item_nimbus_debuff = class({})

function modifier_item_nimbus_debuff:GetTexture()
  	return "items/nimbus"
end

function modifier_item_nimbus_debuff:IsDebuff()
	return true
end

function modifier_item_nimbus_debuff:IsStunDebuff()
	return true
end

function modifier_item_nimbus_debuff:IsPurgable()
	return false
end

function modifier_item_nimbus_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_item_nimbus_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_item_nimbus_debuff:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_item_nimbus_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_item_nimbus_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end