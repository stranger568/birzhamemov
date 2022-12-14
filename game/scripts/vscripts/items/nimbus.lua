LinkLuaModifier("modifier_item_nimbus", "items/nimbus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_nimbus_active", "items/nimbus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_nimbus_debuff", "items/nimbus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

item_nimbus_lapteva = class({})

function item_nimbus_lapteva:GetIntrinsicModifierName()
    return "modifier_item_nimbus"
end

function item_nimbus_lapteva:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_nimbus_active", {duration = duration} )
end

item_nimbus_lapteva_2 = class({})

function item_nimbus_lapteva_2:GetIntrinsicModifierName()
    return "modifier_item_nimbus"
end

function item_nimbus_lapteva_2:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("nimbus_use")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_nimbus_active", {duration = duration} )
end

modifier_item_nimbus = class({})

function modifier_item_nimbus:IsHidden() return true end
function modifier_item_nimbus:IsPurgable() return false end
function modifier_item_nimbus:IsPurgeException() return false end
function modifier_item_nimbus:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_nimbus:DeclareFunctions()
    local funcs = 
    {
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
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_item_nimbus:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_health_regen')
end

function modifier_item_nimbus:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_nimbus:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_nimbus:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
     return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_nimbus:GetModifierPhysical_ConstantBlockSpecial()
    if self:GetParent():FindAllModifiersByName("modifier_item_nimbus")[1] ~= self then return end

	if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then
   		return self:GetAbility():GetSpecialValueFor("block")
   	end
end

modifier_item_nimbus_active = class({})

function modifier_item_nimbus_active:GetTexture()
  	return "items/nimbus"
end

function modifier_item_nimbus_active:GetEffectName()
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
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = 0.5})
		if self:GetAbility():GetAbilityName() == "item_nimbus_lapteva_2" then
			self:GetCaster():EmitSound("nimbus_fail")
		end
	end
end

function modifier_item_nimbus_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end

function modifier_item_nimbus_active:GetModifierTotal_ConstantBlock(params)
    if not IsServer() then return end
    if params.damage <= 0 then return end
    if params.attacker == self:GetParent() then return end
    if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end
    if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
	
    if params.inflictor then
		if params.inflictor:GetAbilityName() == "fut_mum_eat" then return end
	end

	if self:GetAbility():GetAbilityName() == "item_nimbus_lapteva" then
		if params.attacker:IsMagicImmune() then return end
	end

    if not self.carapaced_units[ params.attacker:entindex() ] then
        ApplyDamage({victim = params.attacker, damage = params.original_damage, damage_type = params.damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, attacker = self:GetParent(), ability = self:GetAbility()})
        
        self:GetParent():Purge( false, true, false, true, false)
        
        self.caster_stun = false

		local stun_duration = self:GetAbility():GetSpecialValueFor('stun_duration')
		params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = stun_duration})

		if self:GetAbility():GetAbilityName() == "item_nimbus_lapteva_2" then
			self:GetCaster():EmitSound("nimbus_active")
		end

        self.carapaced_units[ params.attacker:entindex() ] = params.attacker
		local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")

		if ability_pucci and ability_pucci:GetLevel() > 0 then
			if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_use_nimb" then
				ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
				local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
    			CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
				if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
					ability_pucci.current_quest[4] = true
					ability_pucci.word_count = ability_pucci.word_count + 1
					ability_pucci:SetActivated(true)
					ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_use_erase_disk"]
    				CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
				end
			end
		end

        self:Destroy()

        return params.damage
    end
end





























modifier_item_nimbus_debuff = class({})

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