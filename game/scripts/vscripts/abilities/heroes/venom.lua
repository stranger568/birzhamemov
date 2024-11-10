LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_venom_hunger_debuff",  "abilities/heroes/venom.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_venom_hunger_debuff_pull",  "abilities/heroes/venom.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_venom_hunger_visual_thinker",  "abilities/heroes/venom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_venom_hunger_visual_buff",  "abilities/heroes/venom.lua", LUA_MODIFIER_MOTION_NONE)

venom_hunger = class({})

function venom_hunger:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function venom_hunger:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / self:GetCaster():GetCooldownReduction()
end

function venom_hunger:GetIntrinsicModifierName()
	return "modifier_venom_hunger_visual_buff"
end

function venom_hunger:Spawn()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_venom_hunger_visual_thinker") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_hunger_visual_thinker", {})
	end
end

function venom_hunger:OnUpgrade()
	if not IsServer() then return end
	EmitGlobalSound("venom_ultimate_up")
end

function venom_hunger:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then self:GetCaster():Interrupt() return end
	self.target = target
	target:AddNewModifier(self:GetCaster(), self, "modifier_venom_hunger_debuff", {duration = self:GetChannelTime()  })
	EmitGlobalSound("venom_ultimate")
end

function venom_hunger:OnChannelFinish(bInterrupted)
	if self.target then
		local target_buff = self.target:FindModifierByName("modifier_venom_hunger_debuff")
		if target_buff then
			target_buff:Destroy()
		end
	end
	if bInterrupted then return end

	if self.target:IsMagicImmune() then return end

	local damage_type = DAMAGE_TYPE_MAGICAL

	if self:GetCaster():HasTalent("special_bonus_birzha_venom_8") then
		damage_type = DAMAGE_TYPE_PURE
	end

	local damage = self:GetSpecialValueFor("damage")
	local kill_threshold = self:GetSpecialValueFor("kill_threshold")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_shard_hunter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
	ParticleManager:SetParticleControl(particle, 0, self.target:GetAbsOrigin())

	if self.target:GetHealthPercent() <= kill_threshold and not self.target:IsBoss() then
		self.target:Kill(self, self:GetCaster())
	else
		ApplyDamage({victim = self.target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = damage_type })
	end

	if self.target and not self.target:IsAlive() and self.target:IsRealHero() then

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
		ParticleManager:SetParticleControlEnt(particle, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)

		local modifier = self:GetCaster():FindModifierByName("modifier_venom_hunger_visual_buff")
		if modifier then
			if (modifier:GetStackCount() < self:GetSpecialValueFor("max_stacks")) or self:GetCaster():HasTalent("special_bonus_birzha_venom_5") then
				modifier:IncrementStackCount()
				if IsInToolsMode() then
					modifier:SetStackCount(20)
				end
			end
		end
		self.target:SetAbsOrigin(self.target:GetAbsOrigin() + Vector(0,0,-2000))
	end
end

modifier_venom_hunger_debuff = class({})

function modifier_venom_hunger_debuff:IsDebuff() return true end

function modifier_venom_hunger_debuff:CheckState()
	return 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_venom_hunger_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_venom_hunger_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_venom_hunger_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_venom_hunger_debuff_pull", {duration = self:GetAbility():GetChannelTime()})
end

function modifier_venom_hunger_debuff:OnIntervalThink()
	if not IsServer() then return end
end

function modifier_venom_hunger_debuff:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveModifierByName("modifier_venom_hunger_debuff_pull")
	if self:GetCaster():IsChanneling() then
		self:GetAbility():EndChannel(false)
		self:GetCaster():MoveToPositionAggressive(self:GetParent():GetAbsOrigin())
	end
end

modifier_venom_hunger_debuff_pull = class({})

function modifier_venom_hunger_debuff_pull:IsHidden() return true end

function modifier_venom_hunger_debuff_pull:OnCreated(params)
	if not IsServer() then return end

	self.effect_cast = ParticleManager:CreateParticle( "particles/venom/venom_hunger_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	local distance = self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	distance.z = 0

	self.pull_units_per_second = distance:Length2D() / 0.5

	if self:ApplyHorizontalMotionController() == false then 
		self:Destroy()
		return
	end
end

function modifier_venom_hunger_debuff_pull:GetEffectName()
	return "particles/bs_pull_target.vpcf"
end

function modifier_venom_hunger_debuff_pull:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_venom_hunger_debuff_pull:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end
	local distance = self:GetCaster():GetOrigin() - me:GetOrigin()

	if distance:Length2D() > 60 then
		me:SetOrigin( me:GetOrigin() + distance:Normalized() * self.pull_units_per_second * dt )
	else
		self:Destroy()
		self:GetParent():RemoveModifierByName("modifier_venom_hunger_debuff")
	end
end

function modifier_venom_hunger_debuff_pull:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

modifier_venom_hunger_visual_thinker = class({})

function modifier_venom_hunger_visual_thinker:IsPurgable() return false end
function modifier_venom_hunger_visual_thinker:IsHidden() return true end
function modifier_venom_hunger_visual_thinker:RemoveOnDeath() return false end

function modifier_venom_hunger_visual_thinker:OnCreated()
	if not IsServer() then return end
	self.particle_buff_fx = ParticleManager:CreateParticle("particles/venom/ambient_run.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())    
	ParticleManager:SetParticleControl(self.particle_buff_fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle_buff_fx, 1, Vector(1,0,0))
	self:AddParticle(self.particle_buff_fx, false, false, -1, false, false)
	self:StartIntervalThink(FrameTime())
end

function modifier_venom_hunger_visual_thinker:GetEffectName()
	return "particles/venom/effect_ambient_smokeunits/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_venom_hunger_visual_thinker:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_venom_hunger_visual_thinker:OnIntervalThink()
	if not IsServer() then return end
	if not GameRules:IsDaytime() then
		self:GetParent():AddActivityModifier("night")
	else
		self:GetParent():ClearActivityModifiers()
	end
end

modifier_venom_hunger_visual_buff = class({})

function modifier_venom_hunger_visual_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_venom_hunger_visual_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end

function modifier_venom_hunger_visual_buff:GetModifierStatusResistanceStacking()
	return self:GetAbility():GetSpecialValueFor("status_resistance_per_stack") * self:GetStackCount()
end

function modifier_venom_hunger_visual_buff:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magical_resistance_per_stack") * self:GetStackCount()
end

function modifier_venom_hunger_visual_buff:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("physical_resistance_per_stack") * self:GetStackCount()
end

function modifier_venom_hunger_visual_buff:GetModifierModelScale()
	return self:GetStackCount()
end

LinkLuaModifier("modifier_venom_sadist", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_sadist_debuff", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_sadist_buff", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)

venom_sadist = class({}) 

function venom_sadist:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("venom_sadist_up")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_sadist_buff", {duration = self:GetSpecialValueFor("active_buff_duration")})
end

modifier_venom_sadist_buff = class({})
function modifier_venom_sadist_buff:IsPurgable() return false end
function modifier_venom_sadist_buff:IsPurgeException() return false end

function venom_sadist:GetIntrinsicModifierName()
    return "modifier_venom_sadist"
end

function venom_sadist:OnUpgrade()
	if not IsServer() then return end
	EmitGlobalSound("venom_sadist_up")
end

function venom_sadist:GetCastRange(location, target)
    return self:GetSpecialValueFor("aura_radius")
end

modifier_venom_sadist = class({})

function modifier_venom_sadist:IsHidden()
    return true
end

function modifier_venom_sadist:IsPurgable()
    return false
end

function modifier_venom_sadist:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/venom/sadist_caster.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, false, false)
end   

function modifier_venom_sadist:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_venom_sadist:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_venom_sadist:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_venom_sadist:GetModifierAura()
    return "modifier_venom_sadist_debuff"
end

function modifier_venom_sadist:IsAura()
	if self:GetParent():PassivesDisabled() then return end
    return true
end

modifier_venom_sadist_debuff = class({})

function modifier_venom_sadist_debuff:IsHidden()
    return false
end

function modifier_venom_sadist_debuff:IsPurgable()
    return false
end

function modifier_venom_sadist_debuff:OnCreated()
    if not IsServer() then return end
    local aura_damage_interval = self:GetAbility():GetSpecialValueFor("aura_damage_interval") + self:GetCaster():FindTalentValue("special_bonus_birzha_venom_3")
    self:StartIntervalThink(aura_damage_interval)
    self.particle = ParticleManager:CreateParticle("particles/venom/sadist_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:GetParent():EmitSound("DOTA_Item.Radiance.Target.Loop")
end  

function modifier_venom_sadist_debuff:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("DOTA_Item.Radiance.Target.Loop")
end 

function modifier_venom_sadist_debuff:OnIntervalThink()
    local aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage")
	local aura_damage_lifesteal = self:GetAbility():GetSpecialValueFor("aura_damage_lifesteal") + self:GetCaster():FindTalentValue("special_bonus_birzha_venom_4")
	if self:GetCaster():HasScepter() then
		aura_damage = aura_damage + 60
	end
	if self:GetCaster():HasModifier("modifier_venom_sadist_buff") then
		aura_damage = aura_damage * self:GetAbility():GetSpecialValueFor("active_buff_multiple")
	end
	local damage_type = DAMAGE_TYPE_MAGICAL
	if self:GetCaster():HasTalent("special_bonus_birzha_venom_2") then
		damage_type = DAMAGE_TYPE_PURE
	end
    local damage_info = ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = aura_damage, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, damage_type = damage_type })
    local heal = damage_info / 100 * aura_damage_lifesteal
    self:GetCaster():Heal(heal, self:GetAbility())
end   

LinkLuaModifier("modifier_venom_punishment", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_punishment_buff", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)

venom_punishment = class({})

function venom_punishment:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function venom_punishment:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return 0
    else
        return self.BaseClass.GetCooldown(self, level)
    end
end

function venom_punishment:GetIntrinsicModifierName()
	return "modifier_venom_punishment"
end

modifier_venom_punishment = class({})

function modifier_venom_punishment:IsHidden() return true end

function modifier_venom_punishment:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_venom_punishment:OnCreated()
	if not IsServer() then return end
	self.damage_threshold = 0
end

function modifier_venom_punishment:OnTakeDamage(params)
	if params.unit ~= self:GetParent() then return end
	if params.attacker == self:GetParent() then return end
	if params.attacker:GetUnitName() == "dota_fountain" then return end
    if params.attacker:IsBoss() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetParent():IsAlive() then return end
    if not self:GetAbility():IsFullyCastable() then return end
    if self:GetParent():PassivesDisabled() then return end

    self.damage_to_active = self:GetAbility():GetSpecialValueFor("damage_to_active")
	self.damage_threshold = self.damage_threshold + params.damage
	if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		if self.damage_threshold >= self.damage_to_active then
			local duration = self:GetAbility():GetSpecialValueFor("duration")
			local radius = self:GetAbility():GetSpecialValueFor("radius")
			local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_venom_6")
			local steal_str_kill = self:GetAbility():GetSpecialValueFor("steal_str_kill")
			local stacks = 0

			self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
			self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2)

			local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )

			for _, unit in pairs(units) do

				local modifier = unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_venom_punishment_buff", {duration = duration})

				if modifier then
					stacks = modifier:GetStackCount()
				end

				local particle = ParticleManager:CreateParticle( "particles/venom/venom_punishment.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
				ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( particle )

				ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = damage * stacks, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() })

				if not unit:IsAlive() and unit:IsRealHero() then
					unit:SetBaseStrength( math.max(1, unit:GetBaseStrength() - steal_str_kill) )
					self:GetCaster():SetBaseStrength( self:GetCaster():GetBaseStrength() + steal_str_kill )
				end
			end

			self:GetParent():EmitSound("venom_punish")

			self:GetAbility():UseResources(false, false, false, true)

			self.damage_threshold = 0
		end
	end
end

modifier_venom_punishment_buff = class({})

function modifier_venom_punishment_buff:IsPurgable() return false end

function modifier_venom_punishment_buff:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(1)
end

function modifier_venom_punishment_buff:OnRefresh()
	if not IsServer() then return end
	local max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	if self:GetStackCount() < max_stacks then
		self:IncrementStackCount()
	end
end

LinkLuaModifier( "modifier_venom_tentacle",  "abilities/heroes/venom.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_venom_tentacle_damage",  "abilities/heroes/venom.lua", LUA_MODIFIER_MOTION_BOTH)

venom_tentacle = class({})

function venom_tentacle:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_venom_1" )
end

function venom_tentacle:OnSpellStart()
	if not IsServer() then return end
	local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = self:GetCaster():GetAbsOrigin() * self:GetCaster():GetForwardVector()
    end
	local direction = point - self:GetCaster():GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local hookshot_duration	= ((self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed"))
	local hookshot_particle = ParticleManager:CreateParticle("particles/venom/tentacle.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(hookshot_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(hookshot_particle, 1, self:GetCaster():GetAbsOrigin() + direction * (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()))
	ParticleManager:SetParticleControl(hookshot_particle, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0))
	ParticleManager:SetParticleControl(hookshot_particle, 3, Vector(hookshot_duration*5, 0, 0))

	local hookshot_particle_2 = ParticleManager:CreateParticle("particles/venom/tentacle.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(hookshot_particle_2, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(hookshot_particle_2, 1, self:GetCaster():GetAbsOrigin() + direction * (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()))
	ParticleManager:SetParticleControl(hookshot_particle_2, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0))
	ParticleManager:SetParticleControl(hookshot_particle_2, 3, Vector(hookshot_duration*5, 0, 0))

	self.projectile = ProjectileManager:CreateLinearProjectile(
	{
		Ability = self,
		EffectName = "",
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = direction * self:GetSpecialValueFor("speed") * Vector(1, 1, 0),
		fDistance = self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus(),
		fStartRadius = self:GetSpecialValueFor("latch_radius"),
		fEndRadius = self:GetSpecialValueFor("latch_radius"),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		fExpireTime 		= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		ExtraData			= {hookshot_particle = hookshot_particle, hookshot_particle_2 = hookshot_particle_2}
	})

	EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin() + direction * (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()), "venom_tentacle", self:GetCaster() )

	self:GetCaster():EmitSound("venom_tentacle")
end

function venom_tentacle:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if not IsServer() then return end

	if hTarget then
		if hTarget ~= self:GetCaster() then
			hTarget:Interrupt()
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_tentacle", {ent_index = hTarget:GetEntityIndex(), particle1 = ExtraData.hookshot_particle, particle2 = ExtraData.hookshot_particle_2})
			if ExtraData.hookshot_particle and ExtraData.hookshot_particle_2 then
				ParticleManager:SetParticleControlEnt(ExtraData.hookshot_particle, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(ExtraData.hookshot_particle_2, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
				ProjectileManager:DestroyLinearProjectile(self.projectile)
			end
		end
	end

	if hTarget == nil then
		ParticleManager:DestroyParticle(ExtraData.hookshot_particle, true)
		ParticleManager:ReleaseParticleIndex(ExtraData.hookshot_particle)
		ParticleManager:DestroyParticle(ExtraData.hookshot_particle_2, true)
		ParticleManager:ReleaseParticleIndex(ExtraData.hookshot_particle_2)
	end
end

modifier_venom_tentacle = {}

function modifier_venom_tentacle:IsHidden() 		return true end
function modifier_venom_tentacle:IsPurgable()		return true end
function modifier_venom_tentacle:RemoveOnDeath() 	return true end
function modifier_venom_tentacle:IsDebuff()		return false end

function modifier_venom_tentacle:OnCreated(params)
	if not IsServer() then return end

	self.target = EntIndexToHScript(params.ent_index)
	self.true_speed = 3000
	self:StartIntervalThink(FrameTime())

	if params.particle1 then
		self:AddParticle(params.particle1, false, false, -1, false, false)
	end

	if params.particle2 then
		self:AddParticle(params.particle2, false, false, -1, false, false)
	end

	local vec = (self.target:GetOrigin() - self:GetCaster():GetAbsOrigin())
	local hookshot_duration	= vec:Length2D() / 1000
end

function modifier_venom_tentacle:CheckState()
	return 
	{
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_venom_tentacle:OnIntervalThink()
	if not IsServer() then return end

	if self:GetParent():HasModifier("modifier_knockback") then self:Destroy() return end
	if self:GetParent():HasModifier("modifier_generic_knockback_lua") then self:Destroy() return end
	if self:GetParent():IsStunned() then self:Destroy() return end
	if self.target:IsNull() then self:Destroy() return end
	if not self.target:IsAlive() then self:Destroy() return end

	local vec = (self.target:GetOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()

	if (self:GetCaster():GetOrigin() - self.target:GetOrigin()):Length2D() <= 120 then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self:GetParent():MoveToPositionAggressive(self:GetParent():GetAbsOrigin())
		self:Destroy()
	else
		self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + vec * (self.true_speed * FrameTime()))
	end
end

function modifier_venom_tentacle:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_venom_tentacle:IsAura() return true end

function modifier_venom_tentacle:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_venom_tentacle:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_venom_tentacle:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_venom_tentacle:GetModifierAura()
    return "modifier_venom_tentacle_damage"
end

function modifier_venom_tentacle:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("stun_radius")+75
end

modifier_venom_tentacle_damage = class({})

function modifier_venom_tentacle_damage:IsPurgable() return false end
function modifier_venom_tentacle_damage:IsHidden() return true end

function modifier_venom_tentacle_damage:OnCreated()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local duration = self:GetAbility() :GetSpecialValueFor("duration")
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL })
	if not self:GetParent():IsMagicImmune() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = duration * (1 - self:GetParent():GetStatusResistance()) })
	end
end


LinkLuaModifier("modifier_venom_reproduction", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_reproduction_buff", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_reproduction_debuff", "abilities/heroes/venom", LUA_MODIFIER_MOTION_NONE)

venom_reproduction = class({})

function venom_reproduction:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		return UF_FAIL_CUSTOM
	end
    if not target:IsHero() and target:IsConsideredHero() then
        return UF_FAIL_CREEP
    end
	return UF_SUCCESS
end	

function venom_reproduction:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	end
end

function venom_reproduction:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function venom_reproduction:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function venom_reproduction:GetIntrinsicModifierName()
	return "modifier_venom_reproduction"
end

function venom_reproduction:OnSpellStart()
	if not IsServer() then return end

	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		target:AddNewModifier(self:GetCaster(), self, "modifier_venom_reproduction_buff", {duration = duration})
	else
		if target:TriggerSpellAbsorb(self) then return end
		target:AddNewModifier(self:GetCaster(), self, "modifier_venom_reproduction_debuff", {duration = duration * (1 - target:GetStatusResistance()) })
	end

	self:GetCaster():EmitSound("Hero_Terrorblade.Sunder.Target")

	local sunder_particle_1 = ParticleManager:CreateParticle("particles/venom/venom_reproduction.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(sunder_particle_1, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(sunder_particle_1, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(sunder_particle_1, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(sunder_particle_1, 15, Vector(0,0,0))
	ParticleManager:SetParticleControl(sunder_particle_1, 16, Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(sunder_particle_1)

	local sunder_particle_2 = ParticleManager:CreateParticle("particles/venom/venom_reproduction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(sunder_particle_2, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(sunder_particle_2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(sunder_particle_2, 2, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(sunder_particle_2, 15, Vector(0,0,0))
	ParticleManager:SetParticleControl(sunder_particle_2, 16, Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(sunder_particle_2)
end

modifier_venom_reproduction = class({})

function modifier_venom_reproduction:IsHidden() return true end
function modifier_venom_reproduction:IsPurgable() return false end

function modifier_venom_reproduction:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_venom_reproduction:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("hp_regen_passive")
end

modifier_venom_reproduction_buff = class({})

function modifier_venom_reproduction_buff:IsHidden() return false end
function modifier_venom_reproduction_buff:IsPurgable() return false end

function modifier_venom_reproduction_buff:OnCreated()
	if not IsServer() then return end
	self.hp_regen_passive = self:GetAbility():GetSpecialValueFor("hp_regen_passive")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.status_resistance = 0
	self.magical_resistance = 0
	self.physical_resistance = 0
	self.bonus_movespeed = 0

	local ultimate_stack = self:GetCaster():FindModifierByName("modifier_venom_hunger_visual_buff")
	if ultimate_stack then
		self.status_resistance = (ultimate_stack:GetAbility():GetSpecialValueFor("status_resistance_per_stack") * ultimate_stack:GetStackCount()) / 100 * self:GetAbility():GetSpecialValueFor("effect_tooltop")
		self.magical_resistance = (ultimate_stack:GetAbility():GetSpecialValueFor("magical_resistance_per_stack") * ultimate_stack:GetStackCount()) / 100 * self:GetAbility():GetSpecialValueFor("effect_tooltop")
		self.physical_resistance = (ultimate_stack:GetAbility():GetSpecialValueFor("physical_resistance_per_stack") * ultimate_stack:GetStackCount()) / 100 * self:GetAbility():GetSpecialValueFor("effect_tooltop")
	end

	local movespeed_check = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), true) - self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), true)
	if movespeed_check > 0 then
		self.bonus_movespeed = movespeed_check / 2
	end

	self:SetHasCustomTransmitterData(true)
	self:StartIntervalThink(0.1)
end

function modifier_venom_reproduction_buff:OnRefresh()
	self:OnCreated()
end

function modifier_venom_reproduction_buff:OnIntervalThink()
	if not IsServer() then return end
	self:SendBuffRefreshToClients()
end

function modifier_venom_reproduction_buff:AddCustomTransmitterData()
    return 
    {
        hp_regen_passive = self.hp_regen_passive,
		bonus_health = self.bonus_health,
		bonus_movespeed = self.bonus_movespeed,
		status_resistance = self.status_resistance,
		magical_resistance = self.magical_resistance,
		physical_resistance = self.physical_resistance,
    }
end

function modifier_venom_reproduction_buff:HandleCustomTransmitterData( data )
    self.hp_regen_passive = data.hp_regen_passive
	self.bonus_health = data.bonus_health
	self.bonus_movespeed = data.bonus_movespeed
	self.status_resistance = data.status_resistance
	self.magical_resistance = data.magical_resistance
	self.physical_resistance = data.physical_resistance
end

function modifier_venom_reproduction_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_venom_reproduction_buff:GetModifierConstantHealthRegen()
	return self.hp_regen_passive
end

function modifier_venom_reproduction_buff:GetModifierHealthBonus()
	return self.bonus_health
end

function modifier_venom_reproduction_buff:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed
end

function modifier_venom_reproduction_buff:GetModifierStatusResistanceStacking()
	return self.status_resistance
end

function modifier_venom_reproduction_buff:GetModifierMagicalResistanceBonus()
	return self.magical_resistance
end

function modifier_venom_reproduction_buff:GetModifierPhysicalArmorBonus()
	return self.physical_resistance
end

function modifier_venom_reproduction_buff:GetEffectName()
	return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_ambient.vpcf"
end

function modifier_venom_reproduction_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_venom_reproduction_debuff = class({})

function modifier_venom_reproduction_debuff:IsHidden() return false end
function modifier_venom_reproduction_debuff:IsPurgable() return false end

function modifier_venom_reproduction_debuff:OnCreated()
	if not IsServer() then return end
	self.hp_regen_passive = 0
	self.bonus_health = 0

	if self:GetParent():GetMaxHealth() - self:GetAbility():GetSpecialValueFor("bonus_health") >= 1 then
		self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health") * -1
	else
		self.bonus_health = ((self:GetAbility():GetSpecialValueFor("bonus_health") - self:GetParent():GetMaxHealth())*-1) + 1
	end

	if self:GetParent():GetHealthRegen() - self:GetAbility():GetSpecialValueFor("hp_regen_passive") >= 0 then
		self.hp_regen_passive = self:GetAbility():GetSpecialValueFor("hp_regen_passive") * -1
	else
		self.hp_regen_passive = (self:GetAbility():GetSpecialValueFor("hp_regen_passive") - self:GetParent():GetHealthRegen()) * -1
	end

	self.status_resistance = 0
	self.magical_resistance = 0
	self.physical_resistance = 0
	self.bonus_movespeed = 0

	local ultimate_stack = self:GetCaster():FindModifierByName("modifier_venom_hunger_visual_buff")
	if ultimate_stack then
		self.status_resistance = ((ultimate_stack:GetAbility():GetSpecialValueFor("status_resistance_per_stack") * ultimate_stack:GetStackCount())  / 100 * self:GetAbility():GetSpecialValueFor("effect_tooltop") ) * -1
		self.magical_resistance = ((ultimate_stack:GetAbility():GetSpecialValueFor("magical_resistance_per_stack") * ultimate_stack:GetStackCount())  / 100 * self:GetAbility():GetSpecialValueFor("effect_tooltop") ) * -1
		self.physical_resistance = ((ultimate_stack:GetAbility():GetSpecialValueFor("physical_resistance_per_stack") * ultimate_stack:GetStackCount())  / 100 * self:GetAbility():GetSpecialValueFor("effect_tooltop") ) * -1
	end

	local movespeed_check = self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), true) - self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), true)
	if movespeed_check > 0 then
		self.bonus_movespeed = (movespeed_check / 2) * -1
	end

	self:SetHasCustomTransmitterData(true)
	self:StartIntervalThink(0.1)
end

function modifier_venom_reproduction_debuff:OnRefresh()
	self:OnCreated()
end

function modifier_venom_reproduction_debuff:OnIntervalThink()
	if not IsServer() then return end
	self:SendBuffRefreshToClients()
end

function modifier_venom_reproduction_debuff:AddCustomTransmitterData()
    return {
        hp_regen_passive = self.hp_regen_passive,
		bonus_health = self.bonus_health,
		bonus_movespeed = self.bonus_movespeed,
		status_resistance = self.status_resistance,
		magical_resistance = self.magical_resistance,
		physical_resistance = self.physical_resistance,
    }
end

function modifier_venom_reproduction_debuff:HandleCustomTransmitterData( data )
    self.hp_regen_passive = data.hp_regen_passive
	self.bonus_health = data.bonus_health
	self.bonus_movespeed = data.bonus_movespeed
	self.status_resistance = data.status_resistance
	self.magical_resistance = data.magical_resistance
	self.physical_resistance = data.physical_resistance
end

function modifier_venom_reproduction_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_venom_reproduction_debuff:GetModifierConstantHealthRegen()
	return self.hp_regen_passive
end

function modifier_venom_reproduction_debuff:GetModifierHealthBonus()
	return self.bonus_health
end

function modifier_venom_reproduction_debuff:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed
end

function modifier_venom_reproduction_debuff:GetModifierStatusResistanceStacking()
	return self.status_resistance
end

function modifier_venom_reproduction_debuff:GetModifierMagicalResistanceBonus()
	return self.magical_resistance
end

function modifier_venom_reproduction_debuff:GetModifierPhysicalArmorBonus()
	return self.physical_resistance
end

function modifier_venom_reproduction_debuff:GetEffectName()
	return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_ambient.vpcf"
end

function modifier_venom_reproduction_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



