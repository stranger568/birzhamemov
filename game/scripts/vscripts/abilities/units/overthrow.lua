LinkLuaModifier( "modifier_dota_ability_treasure_courier", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dota_ability_vision_revealer", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dota_ability_reveal_invis", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invis_revealed", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dota_ability_xp_granter", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_get_xp", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dota_ability_xp_global", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_get_xp_global", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_donate_model_map", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_donate_model_birzha", "abilities/units/overthrow.lua", LUA_MODIFIER_MOTION_NONE )

dota_ability_treasure_courier = class({})
modifier_dota_ability_treasure_courier = class({})

function dota_ability_treasure_courier:GetIntrinsicModifierName()
	return "modifier_dota_ability_treasure_courier"
end

function modifier_dota_ability_treasure_courier:IsHidden()
    return true
end

function modifier_dota_ability_treasure_courier:IsPurgable()
    return false
end

function modifier_dota_ability_treasure_courier:CheckState()
return {[MODIFIER_STATE_UNSELECTABLE] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,}
end

dota_ability_vision_revealer = class({})
modifier_dota_ability_vision_revealer = class({})

function dota_ability_vision_revealer:GetIntrinsicModifierName()
	return "modifier_dota_ability_vision_revealer"
end

function modifier_dota_ability_vision_revealer:IsHidden()
    return true
end

function modifier_dota_ability_vision_revealer:IsPurgable()
    return false
end

function modifier_dota_ability_vision_revealer:CheckState()
return {[MODIFIER_STATE_PROVIDES_VISION] = true,
	[MODIFIER_STATE_UNSELECTABLE] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,}
end

dota_ability_reveal_invis = class({})
modifier_dota_ability_reveal_invis = class({})

function dota_ability_reveal_invis:GetIntrinsicModifierName()
	return "modifier_dota_ability_reveal_invis"
end

function modifier_dota_ability_reveal_invis:CheckState()
return {[MODIFIER_STATE_UNSELECTABLE] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,}
end

function modifier_dota_ability_reveal_invis:IsAura()
    return true
end

function modifier_dota_ability_reveal_invis:IsHidden()
    return true
end

function modifier_dota_ability_reveal_invis:IsPurgable()
    return false
end

function modifier_dota_ability_reveal_invis:GetAuraRadius()
    return 1500
end

function modifier_dota_ability_reveal_invis:GetModifierAura()
    return "modifier_invis_revealed"
end
   
function modifier_dota_ability_reveal_invis:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_dota_ability_reveal_invis:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_dota_ability_reveal_invis:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_dota_ability_reveal_invis:GetAuraDuration()
    return 0.1
end

modifier_invis_revealed = class({})

function modifier_invis_revealed:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = false,}
end

function modifier_invis_revealed:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_invis_revealed:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_invis_revealed:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_invis_revealed:GetTexture()
   return "item_gem"
end

dota_ability_xp_granter = {
	GetIntrinsicModifierName = function() return "modifier_dota_ability_xp_granter" end
}

dota_ability_xp_granter2 = {
	GetIntrinsicModifierName = function() return "modifier_dota_ability_xp_granter" end
}

modifier_dota_ability_xp_granter = {
	IsHidden = function() return true end,
	IsAura = function() return true end,
	GetModifierAura    = function() return "modifier_get_xp" end,
	GetAuraRadius = function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraDuration    = function() return 0.2 end,
	GetAuraSearchTeam = function() return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraSearchType = function() return DOTA_UNIT_TARGET_HERO end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end,
}

function modifier_dota_ability_xp_granter:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
end

modifier_get_xp = {
	IsHidden = function() return true end,
	IsDebuff = function() return false end,
	GetTexture = function() return "custom_games_xp_coin" end
}

if IsServer() then
	function modifier_get_xp:OnCreated(keys)
		self:StartIntervalThink(0.5)
	end

	function modifier_get_xp:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if CustomPick.pick_ended == nil then return end
		local xp = ability:GetSpecialValueFor("aura_xp")
		local gold = ability:GetSpecialValueFor("aura_gold")
		if not parent:IsRealHero() then return end
		parent:ModifyGold(gold, false, 0)
		parent:AddExperience(xp, 0, false, false)
	end
end

dota_ability_xp_global = {
	GetIntrinsicModifierName = function() return "modifier_dota_ability_xp_global" end
}

modifier_dota_ability_xp_global = {
	IsHidden = function() return true end,
	IsAura = function() return true end,
	GetModifierAura    = function() return "modifier_get_xp_global" end,
	GetAuraRadius = function() return FIND_UNITS_EVERYWHERE end,
	GetAuraDuration    = function() return 0.2 end,
	GetAuraSearchTeam = function() return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraSearchType = function() return DOTA_UNIT_TARGET_HERO end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD  end,
}

function modifier_dota_ability_xp_global:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
end

modifier_get_xp_global = {
	IsHidden = function() return true end,
	IsDebuff = function() return false end,
	GetTexture = function() return "alchemist_goblins_greed" end,
	GetEffectName = function() return "particles/econ/courier/courier_greevil_yellow/courier_greevil_yellow_ambient_3_b.vpcf" end,
}

if IsServer() then
	function modifier_get_xp_global:OnCreated()
		self:StartIntervalThink(0.5)
	end

	function modifier_get_xp_global:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if CustomPick.pick_ended == nil then return end
		local xp = ability:GetSpecialValueFor("aura_xp")
		local gold = ability:GetSpecialValueFor("aura_gold")
		if not parent:IsRealHero() then return end
		parent:ModifyGold(gold, false, 0)
		parent:AddExperience(xp, 0, false, false)
	end
end

donate_model_map = class({})
modifier_donate_model_birzha = class({})

function donate_model_map:GetIntrinsicModifierName()
	return "modifier_donate_model_birzha"
end

function modifier_donate_model_birzha:IsHidden()
    return true
end

function modifier_donate_model_birzha:IsPurgable()
    return false
end

function modifier_donate_model_birzha:CheckState()
return {[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,
[MODIFIER_STATE_DISARMED] = true,}
end

function modifier_donate_model_birzha:IsAura()
    return true
end

function modifier_donate_model_birzha:GetModifierAura()
    return "modifier_phased"
end

function modifier_donate_model_birzha:GetAuraRadius()
    return 75
end

function modifier_donate_model_birzha:GetAuraDuration()
    return 0.5
end

function modifier_donate_model_birzha:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_donate_model_birzha:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_donate_model_birzha:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

donate_model_map_top_season = class({})
modifier_donate_model_map = class({})

function donate_model_map_top_season:GetIntrinsicModifierName()
	return "modifier_donate_model_map"
end

function modifier_donate_model_map:IsHidden()
    return true
end

function modifier_donate_model_map:IsPurgable()
    return false
end

function modifier_donate_model_map:CheckState()
return {[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	[MODIFIER_STATE_ATTACK_IMMUNE] = true,}
end