LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

monika_omniper = class({})

function monika_omniper:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function monika_omniper:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function monika_omniper:GetCastRange()
	local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_4")
	return radius
end

function monika_omniper:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
    end
    return true;
end

function monika_omniper:OnSpellStart()
	if not IsServer() then return end
	local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_5")
	local point = self:GetCursorPosition()

	self:GetCaster():AddNoDraw()
	self:GetCaster():EmitSound("Hero_FacelessVoid.TimeWalk.Aeons")

	local blinkIndex = ParticleManager:CreateParticle("particles/monika/monika_blink.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)

	local blinkIndex3 = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_jewel.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	Timers:CreateTimer( 0.15, function()
		ParticleManager:DestroyParticle( blinkIndex3, false )
		return nil
		end
	)

	Timers:CreateTimer(0.15,function()
		self:GetCaster():RemoveNoDraw()
		ProjectileManager:ProjectileDodge(self:GetCaster())
		FindClearSpaceForUnit(self:GetCaster(), point, true)
	end)

	local heroes = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), point, self:GetCaster(), 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0)
	for k,enemy in pairs(heroes) do
		ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = 0.5})
		enemy:EmitSound("Hero_FacelessVoid.TimeLockImpact")
		local blinkIndex2 = ParticleManager:CreateParticle("particles/monika/monika_blink_flame.vpcf", PATTACH_ABSORIGIN, enemy)
		Timers:CreateTimer( 1, function()
			ParticleManager:DestroyParticle( blinkIndex2, false )
			return nil
			end
		)
	end
end

LinkLuaModifier( "modifier_monica_concept", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_monika_concept_ill", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )

monika_concept = class({})

function monika_concept:GetIntrinsicModifierName()
	return "modifier_monica_concept"
end

modifier_monica_concept = class({})

function modifier_monica_concept:IsPurgable() return false end
function modifier_monica_concept:IsHidden() return true end

function modifier_monica_concept:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_monica_concept:OnAttackLanded(t)
	if not IsServer() then return end
	if t.attacker == self:GetParent() then
		local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_6")
		if not self:GetCaster():HasTalent("special_bonus_birzha_monika_2") then
			if self:GetParent():IsIllusion() then return end
		end
		if t.target:IsOther() then
			return nil
		end
		if RandomInt(1, 100) <= chance then
			if self:GetParent():HasModifier("modifier_monika_concept_ill") then return end
			self:CreateIllusion(t)
		end
	end
end

function modifier_monica_concept:CreateIllusion(table)
	if not IsServer() then return end
	local monika_illusions = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=1.5,outgoing_damage=0,incoming_damage=0}, 3, 100, true, false )
	for k, illusion in pairs(monika_illusions) do
		illusion:RemoveDonate()
		illusion:SetAbsOrigin(table.target:GetAbsOrigin() + RandomVector(200))
		FindClearSpaceForUnit(illusion, table.target:GetAbsOrigin(), true)
		illusion:SetRenderColor(255,20,147)
		illusion:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_monika_concept_ill", {count = k, enemy_entindex = table.target:entindex()})
	end
end

modifier_monika_concept_ill = class({})

function modifier_monika_concept_ill:IsPurgable() return false end
function modifier_monika_concept_ill:IsHidden() return true end

function modifier_monika_concept_ill:OnCreated(keys)
	if not IsServer() then return end
	self.ill_count = keys.count
	local damage_type = {
		DAMAGE_TYPE_MAGICAL,
		DAMAGE_TYPE_PURE,
		DAMAGE_TYPE_PHYSICAL
	}
	self.damage_type = damage_type[self.ill_count]
	self.aggro_target = EntIndexToHScript(keys.enemy_entindex)	
	if self.aggro_target and self.aggro_target:IsAlive() then
		self:GetParent():SetForceAttackTarget( self.aggro_target )
		self:GetParent():MoveToTargetToAttack( self.aggro_target )
	else
		self:GetParent():ForceKill(false)
	end   
end

function modifier_monika_concept_ill:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_monika_concept_ill:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

function modifier_monika_concept_ill:OnAttackLanded(table)
	if not IsServer() then return end
	if table.attacker == self:GetParent() then
		local damage = self:GetAbility():GetSpecialValueFor("b_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_3")
		ApplyDamage({victim = table.target, attacker = self:GetCaster(), damage = table.damage + damage, damage_type = self.damage_type, ability = self:GetAbility()})
		self:GetParent():ForceKill(false)
	end
end

LinkLuaModifier( "modifier_fourtwall_agility_boost", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_fourthwall_boost_ag_interval", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_fourtwall_str_boost", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_fourthwall_boost_str_interval", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "monika_fourthwall_attribute_bonus", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )

monika_fourthwall = class({})

function monika_fourthwall:GetIntrinsicModifierName()
	return "modifier_fourtwall_agility_boost"
end

function monika_fourthwall:OnUpgrade()
	local str_ability = self:GetCaster():FindAbilityByName("monika_fourthwall_two") 
	if self:GetLevel() == 1 then
		str_ability:SetHidden(false)	
		if not self:GetCaster():HasModifier("monika_fourthwall_attribute_bonus") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "monika_fourthwall_attribute_bonus", {})
		end
	end
	str_ability:SetLevel(self:GetLevel())	
end

function monika_fourthwall:OnToggle()
	local ability_two = self:GetCaster():FindAbilityByName("monika_fourthwall_two")
	local agi_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_ag_interval")
	local str_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_str_interval")

	if self:GetToggleState() and ability_two:GetToggleState() then
		ability_two:ToggleAbility()
		str_modifier:Destroy()
	end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fourthwall_boost_ag_interval", {})
	else
		agi_modifier:Destroy()
	end
end

modifier_fourtwall_agility_boost = class({})

function modifier_fourtwall_agility_boost:IsPurgable() return false end
function modifier_fourtwall_agility_boost:IsHidden() return false end

function modifier_fourtwall_agility_boost:RemoveOnDeath()
	return false
end

function modifier_fourtwall_agility_boost:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetBaseAgility())
	self:StartIntervalThink(FrameTime())
end

function modifier_fourtwall_agility_boost:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetBaseAgility())
end

modifier_fourthwall_boost_ag_interval = class({})

function modifier_fourthwall_boost_ag_interval:IsPurgable() return false end
function modifier_fourthwall_boost_ag_interval:IsHidden() return false end

function modifier_fourthwall_boost_ag_interval:OnCreated()
	if not IsServer() then return end
	local interval = self:GetAbility():GetSpecialValueFor("interval")
	self:StartIntervalThink(interval)
end

function modifier_fourthwall_boost_ag_interval:OnIntervalThink()
	if not IsServer() then return end
	local str_stacks = self:GetCaster():FindModifierByName("modifier_fourtwall_str_boost")
	local ag_stacks = self:GetCaster():FindModifierByName("modifier_fourtwall_agility_boost")

	if self:GetCaster():GetBaseStrength() > 1 then
		self:GetCaster():SetBaseStrength(self:GetCaster():GetBaseStrength() - 1)
		self:GetCaster():SetBaseAgility(self:GetCaster():GetBaseAgility() + 1)
		self:GetCaster():CalculateStatBonus(true)
	end
end

function modifier_fourthwall_boost_ag_interval:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf"
end

monika_fourthwall_two = class({})

function monika_fourthwall_two:GetIntrinsicModifierName()
	return "modifier_fourtwall_str_boost"
end

function monika_fourthwall_two:OnToggle()
	local ability_one = self:GetCaster():FindAbilityByName("monika_fourthwall")
	local agi_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_ag_interval")
	local str_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_str_interval")

	if self:GetToggleState() and ability_one:GetToggleState() then
		ability_one:ToggleAbility()
		agi_modifier:Destroy()
	end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fourthwall_boost_str_interval", {})
	else
		str_modifier:Destroy()
	end
end

modifier_fourtwall_str_boost = class({})

function modifier_fourtwall_str_boost:IsPurgable() return false end
function modifier_fourtwall_str_boost:IsHidden() return false end

function modifier_fourtwall_str_boost:RemoveOnDeath()
	return false
end

function modifier_fourtwall_str_boost:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetBaseStrength() + 1)
	self:StartIntervalThink(FrameTime())
end

function modifier_fourtwall_str_boost:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetBaseStrength() + 1)
end

modifier_fourthwall_boost_str_interval = class({})

function modifier_fourthwall_boost_str_interval:IsPurgable() return false end
function modifier_fourthwall_boost_str_interval:IsHidden() return false end

function modifier_fourthwall_boost_str_interval:OnCreated()
	if not IsServer() then return end
	local interval = self:GetAbility():GetSpecialValueFor("interval")
	self:StartIntervalThink(interval)
end

function modifier_fourthwall_boost_str_interval:OnIntervalThink()
	if not IsServer() then return end
	local str_stacks = self:GetCaster():FindModifierByName("modifier_fourtwall_str_boost")
	local ag_stacks = self:GetCaster():FindModifierByName("modifier_fourtwall_agility_boost")
	if self:GetCaster():GetBaseAgility() > 1 then
		self:GetCaster():SetBaseStrength(self:GetCaster():GetBaseStrength() + 1)
		self:GetCaster():SetBaseAgility(self:GetCaster():GetBaseAgility() - 1)
		self:GetCaster():CalculateStatBonus(true)
		--self:GetCaster():SetHealth(self:GetCaster():GetHealth() + 20)
	end
end

function modifier_fourthwall_boost_str_interval:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end

monika_fourthwall_attribute_bonus = class({})

function  monika_fourthwall_attribute_bonus:IsHidden()
	return true
end

function monika_fourthwall_attribute_bonus:DeclareFunctions()
return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		 MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,}
end

function monika_fourthwall_attribute_bonus:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end 

function monika_fourthwall_attribute_bonus:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magic_resist")
end 

function monika_fourthwall_attribute_bonus:RemoveOnDeath()
	return false
end

LinkLuaModifier( "modifier_monika_ult_casted", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )

monika_perception = class({})

function monika_perception:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_1")
end

function monika_perception:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function monika_perception:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function monika_perception:CastFilterResultTarget(target)
	if target:GetUnitName() == "npc_dota_bristlekek" or target:GetUnitName() == "npc_dota_LolBlade" or (not target:IsRealHero()) then
		return UF_FAIL_CUSTOM
	end
	if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
	return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end	

function monika_perception:GetCustomCastErrorTarget(target)
	if target:GetUnitName() == "npc_dota_bristlekek" or target:GetUnitName() == "npc_dota_LolBlade" or (not target:IsRealHero()) then
		return "#dota_hud_error_cant_cast_on_other"
	end
	if target:GetTeamNumber() ~= self:GetCaster() then
	return "#dota_hud_error_cant_cast_on_self"
	end
end

function monika_perception:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if self:GetCaster():HasModifier("modifier_monika_ult_casted") then return end
	self:GetCaster().swap_ended = nil
	self:GetCaster():EmitSound("monikaultimate")
	self.second_ab = self:GetCaster():FindAbilityByName("monika_perception_teleport")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_monika_ult_casted", {duration = 5})
	self:GetCaster().teleport_unit = target
	self:GetCaster().teleport_unit:AddNewModifier(self:GetCaster(), self, "modifier_monika_ult_casted", {duration = 5})
	if self.second_ab then self.second_ab:SetLevel(1) end
	self:GetCaster():SwapAbilities("monika_perception", "monika_perception_teleport", false, true)
end

monika_perception_teleport = class({})

function monika_perception_teleport:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
    end
    return true;
end

function monika_perception_teleport:OnSpellStart()
	if not IsServer() then return end
	if self:GetCaster().teleport_unit then
		self:GetCaster().teleport_unit:SetAbsOrigin(self:GetCursorPosition())
		ProjectileManager:ProjectileDodge(self:GetCaster().teleport_unit)
		FindClearSpaceForUnit(self:GetCaster().teleport_unit, self:GetCursorPosition(), true)
		self:GetCaster().teleport_unit:RemoveModifierByName("modifier_monika_ult_casted")
	end
end

modifier_monika_ult_casted = class({})

function  modifier_monika_ult_casted:IsPurgable()
	return false
end

function modifier_monika_ult_casted:OnDestroy()
if not IsServer() then return end
	if not self:GetCaster().swap_ended then
		self:GetCaster().swap_ended = true
		self:GetCaster():RemoveModifierByName("modifier_monika_ult_casted")
		self:GetCaster().teleport_unit:RemoveModifierByName("modifier_monika_ult_casted")
		self:GetCaster().teleport_unit:EmitSound("Hero_AbyssalUnderlord.DarkRift.Complete")
		self:GetCaster().teleport_unit = nil
		self.second_ab = self:GetCaster():FindAbilityByName("monika_perception_teleport")
		if self.second_ab then self.second_ab:SetLevel(0) end
		self:GetCaster():SwapAbilities("monika_perception_teleport", "monika_perception", false, true)
	end
end

function modifier_monika_ult_casted:GetEffectName()
	return "particles/monika/monika_ultimate_target.vpcf"
end

function modifier_monika_ult_casted:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
