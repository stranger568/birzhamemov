LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_monika_omniper_save", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )

monika_omniper = class({})

function monika_omniper:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_1")
end

function monika_omniper:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function monika_omniper:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_monika_omniper_save"
	end
end

function monika_omniper:GetCastRange(location, target)
	if IsClient() then
    	return self:GetSpecialValueFor("range") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_2")
    end
end


function monika_omniper:OnSpellStart()
	if not IsServer() then return end

	local damage = self:GetSpecialValueFor("damage")

	local point = self:GetCursorPosition()

	local origin = self:GetCaster():GetAbsOrigin()

	local stun_duration = self:GetSpecialValueFor("stun_duration")

	local range = self:GetSpecialValueFor("range") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_2")

    local distance = (point - origin)
    local direction = (point - origin)
    direction.z = 0
    direction = direction:Normalized()

    if distance:Length2D() > range then
        point = origin + direction * range
    end

	self:GetCaster():AddNoDraw()

	self:GetCaster():EmitSound("Hero_FacelessVoid.TimeWalk.Aeons")

	local blinkIndex = ParticleManager:CreateParticle("particles/monika/monika_blink.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	Timers:CreateTimer( 1, function()
		if blinkIndex then
			ParticleManager:DestroyParticle( blinkIndex, false )
		end
	end)

	local blinkIndex3 = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_jewel.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	Timers:CreateTimer( 0.15, function()
		if blinkIndex3 then
			ParticleManager:DestroyParticle( blinkIndex3, false )
		end
	end)

	local caster = self:GetCaster()

	Timers:CreateTimer(0.15,function()
		caster:RemoveNoDraw()
		ProjectileManager:ProjectileDodge(caster)
		FindClearSpaceForUnit(caster, point, true)
		if self:GetCaster():HasTalent("special_bonus_birzha_monika_7") then
			if caster.time_walk_damage_taken then
				caster:Heal(caster.time_walk_damage_taken, self)
			end
		end
	end)

	local heroes = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), point, self:GetCaster(), 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0)

	for k,enemy in pairs(heroes) do

		if self:GetCaster():HasScepter() then
			local modifier = self:GetCaster():FindModifierByName("modifier_monica_concept")
			if modifier then
				modifier:CreateIllusion(enemy)
			end
		end

		ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration * (1-enemy:GetStatusResistance()) })
		enemy:EmitSound("Hero_FacelessVoid.TimeLockImpact")
		local blinkIndex2 = ParticleManager:CreateParticle("particles/monika/monika_blink_flame.vpcf", PATTACH_ABSORIGIN, enemy)
		Timers:CreateTimer( 1, function()
			if blinkIndex2 then
				ParticleManager:DestroyParticle( blinkIndex2, false )
			end
		end)
	end
end

modifier_monika_omniper_save = class({})

function modifier_monika_omniper_save:IsPurgable()	return false end
function modifier_monika_omniper_save:IsDebuff()	return false end
function modifier_monika_omniper_save:IsHidden()	return true end

function modifier_monika_omniper_save:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_monika_omniper_save:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.damage_time = self.ability:GetSpecialValueFor("backtrack_duration")
	if IsServer() then
		if not self.caster.time_walk_damage_taken then
			self.caster.time_walk_damage_taken = 0
		end
	end
end

function modifier_monika_omniper_save:OnTakeDamage( keys )
	if IsServer() then
		local unit = keys.unit
		local damage_taken = keys.damage
		if unit == self.caster then
			self.caster.time_walk_damage_taken = self.caster.time_walk_damage_taken + damage_taken
			Timers:CreateTimer(self.damage_time, function()
				if self.caster.time_walk_damage_taken then
					self.caster.time_walk_damage_taken = self.caster.time_walk_damage_taken - damage_taken
				end
			end)
		end
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
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_monica_concept:OnCreated(params)
	if not IsServer() then return end
	self.proc = false
end

function modifier_monica_concept:OnAttack(params)
	if not IsServer() then return end
	if self:GetParent() ~= params.attacker then return end
	if params.target:IsWard() then return end
	if self:GetParent():PassivesDisabled() then return end

	local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_3")

	if not self:GetCaster():HasTalent("special_bonus_birzha_monika_8") then
		if self:GetParent():HasModifier("modifier_monika_concept_ill") then return end
		if self:GetParent():IsIllusion() then return end
	else
		if self:GetParent():IsIllusion() then
			chance = chance / 2
		end
	end

	if RollPseudoRandomPercentage(chance, 5, self:GetParent()) then
		self.proc = true
		self.record = params.record
	end
end

function modifier_monica_concept:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if self.proc == false then return end
	if self.record ~= params.record then return end
	self.proc = false
	self:CreateIllusion(params.target)
end

function modifier_monica_concept:CreateIllusion(target)
	if not IsServer() then return end

	local count = 1

	if self:GetCaster():HasShard() then
		count = 3
	end

	local monika_illusions = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=1.5,outgoing_damage=0,incoming_damage=0}, count, 100, false, false )
	for k, illusion in pairs(monika_illusions) do
		illusion:RemoveDonate()
		illusion:SetAbsOrigin(target:GetAbsOrigin() + RandomVector(400))
		FindClearSpaceForUnit(illusion, target:GetAbsOrigin(), true)
		illusion:SetRenderColor(255,20,147)
		illusion:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_monika_concept_ill", {count = k, enemy_entindex = target:entindex()})
	end
end

modifier_monika_concept_ill = class({})

function modifier_monika_concept_ill:IsPurgable() return false end
function modifier_monika_concept_ill:IsHidden() return true end

function modifier_monika_concept_ill:OnCreated(keys)
	if not IsServer() then return end
	self.ill_count = keys.count
	self.aggro_target = EntIndexToHScript(keys.enemy_entindex)	

	if self.aggro_target and self.aggro_target:IsAlive() then
		self:GetParent():SetForceAttackTarget( self.aggro_target )
		self:GetParent():MoveToTargetToAttack( self.aggro_target )
	else
		self:GetParent():ForceKill(false)
		return
	end   

	self:StartIntervalThink(FrameTime())
end

function modifier_monika_concept_ill:OnIntervalThink()
	if not IsServer() then return end
	if self.aggro_target and not self.aggro_target:IsAlive() then
		self:GetParent():ForceKill(false)
	end
end

function modifier_monika_concept_ill:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
    }
    return decFuncs
end

function modifier_monika_concept_ill:OnDestroy()
	if not IsServer() then return end
	self:GetParent():ForceKill(false)
end

function modifier_monika_concept_ill:CheckState()
	local state = 
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

function modifier_monika_concept_ill:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    if self.ill_count == 1 then return end
    local illusion_damage = self:GetAbility():GetSpecialValueFor("illusion_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_5")
    self:Destroy()
    return illusion_damage
end

function modifier_monika_concept_ill:GetModifierProcAttack_BonusDamage_Magical( params )
    if not IsServer() then return end
    if self.ill_count == 2 then return end
    local illusion_damage = self:GetAbility():GetSpecialValueFor("illusion_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_5")
    self:Destroy()
    return illusion_damage
end

function modifier_monika_concept_ill:GetModifierProcAttack_BonusDamage_Pure( params )
    if not IsServer() then return end
    if self.ill_count == 3 then return end
    local illusion_damage = self:GetAbility():GetSpecialValueFor("illusion_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_monika_5")
    self:Destroy()
    return illusion_damage
end

LinkLuaModifier( "modifier_fourtwall_agility_boost", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_fourthwall_boost_ag_interval", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_fourtwall_str_boost", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_fourthwall_boost_str_interval", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )

monika_fourthwall = class({})

function monika_fourthwall:GetIntrinsicModifierName()
	return "modifier_fourtwall_agility_boost"
end

function monika_fourthwall:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_birzha_monika_4") then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	end
	return DOTA_ABILITY_BEHAVIOR_TOGGLE
end

function monika_fourthwall:OnUpgrade()
	local str_ability = self:GetCaster():FindAbilityByName("monika_fourthwall_two")
	if str_ability then
		str_ability:SetLevel(self:GetLevel())	
	end
end

function monika_fourthwall:OnToggle()
	if not IsServer() then return end
	local ability_two = self:GetCaster():FindAbilityByName("monika_fourthwall_two")
	local agi_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_ag_interval")
	local str_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_str_interval")

	if self:GetToggleState() and ability_two:GetToggleState() then
		ability_two:ToggleAbility()
		if str_modifier and not str_modifier:IsNull() then
			str_modifier:Destroy()
		end
	end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fourthwall_boost_ag_interval", {})
	else
		if agi_modifier and not agi_modifier:IsNull() then
			agi_modifier:Destroy()
		end
	end
end

modifier_fourtwall_agility_boost = class({})

function modifier_fourtwall_agility_boost:IsPurgable() return false end
function modifier_fourtwall_agility_boost:IsHidden() return true end

function modifier_fourtwall_agility_boost:RemoveOnDeath()
	return false
end

function modifier_fourtwall_agility_boost:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetBaseAgility()+1)
	self:StartIntervalThink(FrameTime())
end

function modifier_fourtwall_agility_boost:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetBaseAgility()+1)
end

function modifier_fourtwall_agility_boost:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_fourtwall_agility_boost:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end 

modifier_fourthwall_boost_ag_interval = class({})

function modifier_fourthwall_boost_ag_interval:IsPurgable() return false end
function modifier_fourthwall_boost_ag_interval:IsHidden() return true end

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
		self:GetParent():ModifyStrength(-1)
		self:GetParent():ModifyAgility(1)
	end
end

function modifier_fourthwall_boost_ag_interval:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf"
end

monika_fourthwall_two = class({})

function monika_fourthwall_two:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_birzha_monika_4") then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	end
	return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function monika_fourthwall_two:GetIntrinsicModifierName()
	return "modifier_fourtwall_str_boost"
end

function monika_fourthwall_two:OnToggle()
	if not IsServer() then return end
	local ability_one = self:GetCaster():FindAbilityByName("monika_fourthwall")
	local agi_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_ag_interval")
	local str_modifier = self:GetCaster():FindModifierByName("modifier_fourthwall_boost_str_interval")

	if self:GetToggleState() and ability_one:GetToggleState() then
		ability_one:ToggleAbility()
		if agi_modifier and not agi_modifier:IsNull() then
			agi_modifier:Destroy()
		end
	end

	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fourthwall_boost_str_interval", {})
	else
		if str_modifier and not str_modifier:IsNull() then
			str_modifier:Destroy()
		end
	end
end

modifier_fourtwall_str_boost = class({})

function modifier_fourtwall_str_boost:IsPurgable() return false end
function modifier_fourtwall_str_boost:IsHidden() return true end

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
function modifier_fourthwall_boost_str_interval:IsHidden() return true end

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
		local morph_check = self:GetParent():GetHealth()
		self:GetParent():ModifyAgility(-1)
		self:GetParent():ModifyStrength(1)
		morph_check = self:GetParent():GetHealth() - morph_check
		self:GetParent():SetHealth(self:GetParent():GetHealth() + (20 - morph_check))
	end
end

function modifier_fourthwall_boost_str_interval:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end

LinkLuaModifier( "modifier_monika_ult_casted", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_monika_ult_casted_debuff", "abilities/heroes/monika.lua", LUA_MODIFIER_MOTION_NONE  )

monika_perception = class({})

function monika_perception:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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

	self:GetCaster():EmitSound("monikaultimate")

	local monika_perception_teleport = self:GetCaster():FindAbilityByName("monika_perception_teleport")
	if monika_perception_teleport then
		monika_perception_teleport:SetLevel(1)
	end

	local duration = self:GetSpecialValueFor("duration")

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_monika_ult_casted", {duration = duration})

	self:GetCaster().teleport_unit = target

	self:GetCaster().teleport_unit:AddNewModifier(self:GetCaster(), self, "modifier_monika_ult_casted", {duration = duration})
end

monika_perception_teleport = class({})

function monika_perception_teleport:OnSpellStart()
	if not IsServer() then return end

	if self:GetCaster().teleport_unit then
		self:GetCaster().teleport_unit:SetAbsOrigin(self:GetCursorPosition())
		ProjectileManager:ProjectileDodge(self:GetCaster().teleport_unit)
		FindClearSpaceForUnit(self:GetCaster().teleport_unit, self:GetCursorPosition(), true)

		local ability = self:GetCaster():FindAbilityByName("monika_perception")

		local radius = ability:GetSpecialValueFor("radius")
		local damage = ability:GetSpecialValueFor("damage")

	    local damageTable = 
	    {
	        attacker = self:GetCaster(),
	        damage = damage,
	        damage_type = DAMAGE_TYPE_MAGICAL,
	        ability = ability,
	    }

	    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

	    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_blink_shard_end.vpcf", PATTACH_WORLDORIGIN, nil)
	    ParticleManager:SetParticleControl(particle, 0, self:GetCursorPosition())
	    ParticleManager:SetParticleControl(particle, 2, Vector(radius, radius, radius))
	    ParticleManager:ReleaseParticleIndex(particle)

	    for _,enemy in pairs(enemies) do
	        damageTable.victim = enemy
	        if self:GetCaster():HasTalent("special_bonus_birzha_monika_6") then
	        	enemy:AddNewModifier(self:GetCaster(), ability, "modifier_monika_ult_casted_debuff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_monika_6") * (1-enemy:GetStatusResistance())})
	        end
	        ApplyDamage( damageTable )
	    end

	    ability:EndCooldown()

	    ability:UseResources(false, false, true)

		self:GetCaster().teleport_unit:RemoveModifierByName("modifier_monika_ult_casted")
	end
end

modifier_monika_ult_casted = class({})

function  modifier_monika_ult_casted:IsPurgable()
	return false
end

function modifier_monika_ult_casted:OnCreated()
	if not IsServer() then return end
	if self:GetParent() == self:GetCaster() then
		self:GetCaster():SwapAbilities("monika_perception", "monika_perception_teleport", false, true)
	end
end

function modifier_monika_ult_casted:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_monika_ult_casted")
	self:GetCaster().teleport_unit:RemoveModifierByName("modifier_monika_ult_casted")
	self:GetCaster().teleport_unit:EmitSound("Hero_AbyssalUnderlord.DarkRift.Complete")
	self:GetCaster().teleport_unit = nil
	if self:GetParent() == self:GetCaster() then
		self:GetCaster():SwapAbilities("monika_perception_teleport", "monika_perception", false, true)
	end
end

function modifier_monika_ult_casted:GetEffectName()
	return "particles/monika/monika_ultimate_target.vpcf"
end

function modifier_monika_ult_casted:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


modifier_monika_ult_casted_debuff = class({})

function modifier_monika_ult_casted_debuff:CheckState()
	return 
	{
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_monika_ult_casted_debuff:GetEffectName()
	return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf"
end

function modifier_monika_ult_casted_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end