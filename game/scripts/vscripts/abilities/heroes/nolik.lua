LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nolik_mostdel", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)

nolik_mostdel = class({})

function nolik_mostdel:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("nolik_wow")
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_nolik_2")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_mostdel", {duration = duration})
end

modifier_nolik_mostdel = class({})

function modifier_nolik_mostdel:IsPurgable() return false end

function modifier_nolik_mostdel:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_reduced") + self:GetCaster():FindTalentValue("special_bonus_birzha_nolik_1")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.energy_lose = self:GetAbility():GetSpecialValueFor("energy_lose")
end

function modifier_nolik_mostdel:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
	return funcs
end

function modifier_nolik_mostdel:GetModifierIncomingDamage_Percentage()
	return self.damage
end

function modifier_nolik_mostdel:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_nolik_mostdel:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_shard_buff.vpcf"
end

function modifier_nolik_mostdel:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_nolik_tech", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)

nolik_tech = class({})

function nolik_tech:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_nolik_4")
end

function nolik_tech:IsRefreshable() return false end

function nolik_tech:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_tech", {})
	self:EndCooldown()
	self:GetCaster():EmitSound("nolik_two")
end

modifier_nolik_tech = class({})

function modifier_nolik_tech:IsPurgable() return false end

function modifier_nolik_tech:OnCreated()
	if not IsServer() then return end
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	self:GetAbility():SetActivated(false)
end

function modifier_nolik_tech:OnDestroy()
	if not IsServer() then return end
	self:GetAbility():SetActivated(true)
	self:GetAbility():UseResources(false, false, false, true)
end

function modifier_nolik_tech:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,

	}

	return funcs
end

function modifier_nolik_tech:OnAbilityFullyCast( params )
	if IsServer() then
		local hAbility = params.ability
		if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
			return 0
		end

		if hAbility:IsToggle() then
			return 0
		end

		if not hAbility:IsItem() then 
			return 0
		end

		if not self:GetParent():HasTalent("special_bonus_birzha_nolik_7") then
			if hAbility:GetAbilityName() == "item_refresher" then
				return 0
			end
		end

		hAbility:EndCooldown()

		self:Destroy()
	end

	return 0
end

LinkLuaModifier( "modifier_nolik_chill", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nolik_chill_aura", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)

nolik_chill = class({})

function nolik_chill:GetChannelTime() return self:GetSpecialValueFor("duration") end

function nolik_chill:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self.modifier_caster = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_chill", {duration = duration})
end

function nolik_chill:OnChannelFinish( bInterrupted )
	if self.modifier_caster and not self.modifier_caster:IsNull() then
    	self.modifier_caster:Destroy()
	end
end

modifier_nolik_chill = class({})

function modifier_nolik_chill:IsPurgable() return true end

function modifier_nolik_chill:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_nolik_3")
	self.origin = self:GetCaster():GetAbsOrigin()
	self.energy_heal = self:GetAbility():GetSpecialValueFor("energy_heal")
	if not IsServer() then return end
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_ROT)
	self.particle = ParticleManager:CreateParticle("particles/nolik/effect_radius.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, 1))
	self:AddParticle(self.particle, false, false, -1, false, false)
	self:GetParent():EmitSound("nolik_chill_effect")
	self:GetParent():EmitSound("nolik_sleep")
	self:StartIntervalThink(0.5)
end

function modifier_nolik_chill:OnIntervalThink()
    if not IsServer() then return end

    if self.origin ~= self:GetCaster():GetAbsOrigin() then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
            self.origin = self:GetCaster():GetAbsOrigin()
            self.particle = ParticleManager:CreateParticle("particles/nolik/effect_radius.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, 1))
			self:AddParticle(self.particle, false, false, -1, false, false)
        end     
    end

    local modifier_nolik_energy = self:GetParent():FindModifierByName("modifier_nolik_energy")
    if modifier_nolik_energy then
        local energy = (modifier_nolik_energy.max_energy + (modifier_nolik_energy.energy_per_level * self:GetParent():GetLevel())) * (self.energy_heal / 100)
    	modifier_nolik_energy:EnergyAdded( energy * 0.5 )
    end
end

function modifier_nolik_chill:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_ROT)
	self:GetCaster():StopSound("nolik_chill_effect")
end

function modifier_nolik_chill:IsAura() return true end

function modifier_nolik_chill:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_nolik_chill:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_nolik_chill:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_nolik_chill:GetModifierAura()
    return "modifier_nolik_chill_aura"
end

function modifier_nolik_chill:GetAuraRadius()
    return self.radius
end

modifier_nolik_chill_aura = class({})

function modifier_nolik_chill_aura:IsPurgable() return false end

function modifier_nolik_chill_aura:OnCreated()
	self.movement_speed_slow = self:GetAbility():GetSpecialValueFor("movement_speed_slow")
	self.energy_damage = self:GetAbility():GetSpecialValueFor("energy_damage")
	self:StartIntervalThink(1)
end

function modifier_nolik_chill_aura:OnIntervalThink()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/nolik_energy_attack.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

    local modifier_nolik_energy = self:GetCaster():FindModifierByName("modifier_nolik_energy")
    if modifier_nolik_energy then
    	local damage = modifier_nolik_energy:GetStackCount() * ( self.energy_damage / 100 )
    	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    	self:GetParent():EmitSound("nolik_chill_attack")
    end
end

function modifier_nolik_chill_aura:DeclareFunctions()
	local decFuncs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return decFuncs
end

function modifier_nolik_chill_aura:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed_slow
end

LinkLuaModifier( "modifier_nolik_energizer", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)

nolik_energizer = class({})

function nolik_energizer:OnHeroCalculateStatBonus()
	if self:GetCaster():GetLevel() == 1 and self:GetLevel() == 0 then
    	self:SetLevel(1)
    end
    if self:GetCaster():GetLevel() == 6 and self:GetLevel() == 1 then
    	self:SetLevel(2)
    end
    if self:GetCaster():GetLevel() == 12 and self:GetLevel() == 2 then
    	self:SetLevel(3)
    end
    if self:GetCaster():GetLevel() == 18 and self:GetLevel() == 3 then
    	self:SetLevel(4)
    end
    if self:GetCaster():GetLevel() == 24 and self:GetLevel() == 4 then
    	self:SetLevel(5)
    end
end

function nolik_energizer:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasShard()) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function nolik_energizer:OnAbilityPhaseStart()
	local modifier_nolik_energy = self:GetCaster():FindModifierByName("modifier_nolik_energy")
    if modifier_nolik_energy then
    	if modifier_nolik_energy:GetStackCount() < (modifier_nolik_energy.max_energy + (modifier_nolik_energy.energy_per_level * self:GetCaster():GetLevel())) * 0.1 then
        	DisplayError(self:GetCaster():GetPlayerOwnerID(), "#nolik_error_small_energy")
        	return false
    	end
    end
    return true
end

function nolik_energizer:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return nil end
	local caster = self:GetCaster()
    local direction = (caster:GetOrigin()-target:GetOrigin()):Normalized()
    local effect_cast = ParticleManager:CreateParticle( "particles/nolik/energy_kill.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControlEnt(  effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt(  effect_cast, 6, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt(  effect_cast, 5, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 2, target:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 3, target:GetOrigin() + direction )
    ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    local energy_cost = self:GetSpecialValueFor("energy_cost") / 100

    self:GetCaster():EmitSound("nolik_energizer")

    local modifier_nolik_energy = self:GetCaster():FindModifierByName("modifier_nolik_energy")
    if modifier_nolik_energy then
    	local damage = (modifier_nolik_energy:GetStackCount() * energy_cost)
    	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    	modifier_nolik_energy:EnergyRemove(modifier_nolik_energy:GetStackCount() * energy_cost)
    	if self:GetCaster():HasTalent("special_bonus_birzha_nolik_6") then
	    	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_energizer", { starting_unit_entindex = target:entindex(), damage = damage })
	    end
    end

    if self:GetCaster():HasModifier("modifier_nolik_mostdel") then
    	self:EndCooldown()
    	self:GetCaster():RemoveModifierByName("modifier_nolik_mostdel")
    end
end

modifier_nolik_energizer = class({})

function modifier_nolik_energizer:IsHidden()		return true end
function modifier_nolik_energizer:IsPurgable()		return false end
function modifier_nolik_energizer:RemoveOnDeath()	return false end
function modifier_nolik_energizer:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_nolik_energizer:OnCreated(keys)
	if not IsServer() or not self:GetAbility() then return end
	self.radius				= 400
	self.jump_delay			= 0.25
	self.jump_count			= 5
	self.damage = keys.damage * 0.75
	self.starting_unit_entindex	= keys.starting_unit_entindex
	self.units_affected			= {}
	if self.starting_unit_entindex and EntIndexToHScript(self.starting_unit_entindex) then
		self.current_unit						= EntIndexToHScript(self.starting_unit_entindex)
		self.units_affected[self.current_unit]	= 1
		---
	else
        self:Destroy()
		return
	end
	
	self.unit_counter			= 0
	self:StartIntervalThink(self.jump_delay)
end

function modifier_nolik_energizer:OnIntervalThink()
	self.zapped = false
	
	if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
			if not self.units_affected[enemy] and enemy ~= self.current_unit and enemy ~= self.previous_unit then
				
				local direction = (self.current_unit:GetOrigin()-enemy:GetOrigin()):Normalized()
				local effect_cast = ParticleManager:CreateParticle( "particles/nolik/energy_kill.vpcf", PATTACH_ABSORIGIN, self.current_unit )
				ParticleManager:SetParticleControlEnt(  effect_cast, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
				ParticleManager:SetParticleControlEnt(  effect_cast, 6, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
				ParticleManager:SetParticleControlEnt(  effect_cast, 5, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
				ParticleManager:SetParticleControlEnt( effect_cast, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
				ParticleManager:SetParticleControl( effect_cast, 2, enemy:GetOrigin() )
				ParticleManager:SetParticleControl( effect_cast, 3, enemy:GetOrigin() + direction )
				ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
				ParticleManager:ReleaseParticleIndex( effect_cast )

				self:GetCaster():EmitSound("nolik_energizer")
				
				self.unit_counter						= self.unit_counter + 1
				self.previous_unit						= self.current_unit
				self.current_unit						= enemy
				
				if self.units_affected[self.current_unit] then
					self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
				else
					self.units_affected[self.current_unit]	= 1
				end
				
				self.zapped								= true
				ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
				self.damage = self.damage * 0.75
			end
		end
		
		if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
			self:StartIntervalThink(-1)
            self:Destroy()
		end
	end
end

LinkLuaModifier( "modifier_nolik_energy", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)

nolik_energy = class({})

function nolik_energy:Spawn()
    if not IsServer() then return end
    if self and not self:IsTrained() then
        self:SetLevel(1)
    end
end

function nolik_energy:GetIntrinsicModifierName()
	return "modifier_nolik_energy"
end

modifier_nolik_energy = class({})

function modifier_nolik_energy:IsPurgable() return false end
function modifier_nolik_energy:IsHidden() return true end

function modifier_nolik_energy:OnCreated()
	self.max_energy = self:GetAbility():GetSpecialValueFor("max_energy")
	self.energy_per_level = self:GetAbility():GetSpecialValueFor("energy_per_level")
	self.energy_cost = self:GetAbility():GetSpecialValueFor("energy_cost")
	self.energy_heal_attack = self:GetAbility():GetSpecialValueFor("energy_heal_attack")

	self.bonus_move_energy = self:GetAbility():GetSpecialValueFor("bonus_move_energy")
	self.bonus_agility_energy = self:GetAbility():GetSpecialValueFor("bonus_agility_energy")
	self.bonus_str_energy = self:GetAbility():GetSpecialValueFor("bonus_str_energy")

	if not IsServer() then return end

	self:SetStackCount(0)

	self:StartIntervalThink(1)
end

function modifier_nolik_energy:OnIntervalThink()
	if not IsServer() then return end
	self:EnergyRemove(self.energy_cost)
end

function modifier_nolik_energy:OnStackCountChanged(iStackCount)
    if not IsServer() then return end
    self:GetParent():CalculateStatBonus(true)
end

function modifier_nolik_energy:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_RESPAWN,
	}

	return decFuncs
end

function modifier_nolik_energy:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount() * self.bonus_move_energy
end

function modifier_nolik_energy:GetModifierBonusStats_Agility()
	return self:GetStackCount() * self.bonus_agility_energy
end

function modifier_nolik_energy:GetModifierBonusStats_Strength()
	return self:GetStackCount() * self.bonus_str_energy
end

function modifier_nolik_energy:OnAttack(params)
	if not IsServer() then return end
	if params.attacker == self:GetParent() then
		self:EnergyAdded(self.energy_heal_attack + self:GetCaster():FindTalentValue("special_bonus_birzha_nolik_5"))
	end
end

function modifier_nolik_energy:OnRespawn(params)
    if params.unit == self:GetParent() then                  
        if self:GetParent():HasScepter() then
        	self:EnergyAdded(self.max_energy + (self.energy_per_level * self:GetParent():GetLevel()))
        end
    end
end

function modifier_nolik_energy:EnergyAdded(count)
	if not IsServer() then return end
	local maximum = self.max_energy + (self.energy_per_level * self:GetParent():GetLevel())
	
	if self:GetParent():HasModifier("modifier_nolik_helper_energy") then
		maximum = maximum * 2
	end

	if self:GetStackCount() + count < maximum then
		self:SetStackCount(self:GetStackCount() + count)
	else
		self:SetStackCount(maximum)
	end
end

function modifier_nolik_energy:EnergyRemove(count)
	if not IsServer() then return end

	if not self:GetParent():IsAlive() then return end

	local modifier_nolik_mostdel = self:GetParent():FindModifierByName("modifier_nolik_mostdel")
	if modifier_nolik_mostdel then
		count = count * (1 - (modifier_nolik_mostdel.energy_lose / 100))
	end

	if self:GetStackCount() - count < 0 then
		self:SetStackCount(0)
	else
		self:SetStackCount(self:GetStackCount() - count)
	end
end

LinkLuaModifier( "modifier_nolik_helper_1", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nolik_helper_2", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nolik_helper_3", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nolik_helper_energy", "abilities/heroes/nolik.lua", LUA_MODIFIER_MOTION_NONE)

nolik_helper = class({})

function nolik_helper:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("nolik_pomogator")
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_nolik_8")
	self:GetCaster():RemoveModifierByName("modifier_nolik_helper_1")
	self:GetCaster():RemoveModifierByName("modifier_nolik_helper_2")
	self:GetCaster():RemoveModifierByName("modifier_nolik_helper_3")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_energy", {duration = duration})

	if self:GetLevel() == 1 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_1", {duration = duration})
	elseif self:GetLevel() == 2 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_1", {duration = duration})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_2", {duration = duration})
	elseif self:GetLevel() == 3 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_1", {duration = duration})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_2", {duration = duration})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nolik_helper_3", {duration = duration})
	end
end

modifier_nolik_helper_energy = class({})
function modifier_nolik_helper_energy:IsHidden() return true end
function modifier_nolik_helper_energy:IsPurgable() return false end

function modifier_nolik_helper_energy:OnDestroy()
	if not IsServer() then return end
	local modifier_nolik_energy = self:GetParent():FindModifierByName("modifier_nolik_energy")
    if modifier_nolik_energy then
    	if modifier_nolik_energy:GetStackCount() > modifier_nolik_energy.max_energy + (modifier_nolik_energy.energy_per_level * modifier_nolik_energy:GetParent():GetLevel()) then
    		modifier_nolik_energy:EnergyAdded(0)
    	end
    end
end

function modifier_nolik_helper_energy:GetEffectName() return "particles/nolik/ultimate_effect.vpcf" end
function modifier_nolik_helper_energy:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_nolik_helper_1 = class({})

function modifier_nolik_helper_1:IsPurgable() return false end

function modifier_nolik_helper_1:DeclareFunctions()
	local decFuncs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}

	return decFuncs
end

function modifier_nolik_helper_1:GetModifierAttackSpeedPercentage()
	return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end

modifier_nolik_helper_2 = class({})

function modifier_nolik_helper_2:IsPurgable() return false end

function modifier_nolik_helper_2:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return decFuncs
end

function modifier_nolik_helper_2:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end

function modifier_nolik_helper_2:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_range")
end

function modifier_nolik_helper_2:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.target:IsBuilding() then return end
	if params.target == params.attacker then return end
	if params.attacker:IsIllusion() then return end
    DoCleaveAttack( params.attacker, params.target, self:GetAbility(), params.original_damage, 150, 150, 150, "particles/nolik/nolik_splash.vpcf" )  
end

modifier_nolik_helper_3 = class({})

function modifier_nolik_helper_3:IsPurgable() return false end

function modifier_nolik_helper_3:DeclareFunctions()
	local decFuncs = 
	{
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}

	return decFuncs
end

function modifier_nolik_helper_3:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_increase")
end



































