LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Daniil_StormBolt_target", "abilities/heroes/navat.lua", LUA_MODIFIER_MOTION_NONE )

Daniil_StormBolt = class({})

function Daniil_StormBolt:Precache(context)
    local particle_list = 
    {
        "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf",
        "particles/navat/laughingrush_effect.vpcf",
        "particles/navat/laughingrush_effect.vpcf",
        "particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf",
        "particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf",
        "particles/navat/vortexsilence_debuff.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Daniil_StormBolt:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Daniil_StormBolt:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Daniil_StormBolt:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Daniil_StormBolt:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		if target:TriggerSpellAbsorb(self) then return end
		self:GetCaster():EmitSound("danilone")
		self:GetCaster():EmitSound("Hero_Zuus.LightningBolt")
		local head_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(head_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(head_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(head_particle, 62, Vector(2, 0, 2))
		ParticleManager:ReleaseParticleIndex(head_particle)
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Daniil_StormBolt_target", { starting_unit_entindex = target:entindex() })
	end
end

modifier_Daniil_StormBolt_target = class({})

function modifier_Daniil_StormBolt_target:IsHidden()		return true end
function modifier_Daniil_StormBolt_target:IsPurgable()		return false end
function modifier_Daniil_StormBolt_target:RemoveOnDeath()	return false end
function modifier_Daniil_StormBolt_target:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_Daniil_StormBolt_target:OnCreated(keys)
	if not IsServer() or not self:GetAbility() then return end

	self.arc_damage			= self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_navat_1")
	self.radius				= 500
	self.jump_delay			= 0.25
	self.jump_count			= 10
	
	self.starting_unit_entindex	= keys.starting_unit_entindex
	self.units_affected			= {}
	
	if self.starting_unit_entindex and EntIndexToHScript(self.starting_unit_entindex) then
		self.current_unit						= EntIndexToHScript(self.starting_unit_entindex)
		self.units_affected[self.current_unit]	= 1
		
		ApplyDamage({
			victim 			= self.current_unit,
			damage 			= self.arc_damage,
			damage_type		= DAMAGE_TYPE_MAGICAL,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self:GetAbility()
		})
	else
		if not self:IsNull() then
            self:Destroy()
        end
		return
	end
	
	self.unit_counter			= 0
	self:StartIntervalThink(self.jump_delay)
end

function modifier_Daniil_StormBolt_target:OnIntervalThink()
	self.zapped = false
	
	if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
			if not self.units_affected[enemy] and enemy ~= self.current_unit and enemy ~= self.previous_unit then
				enemy:EmitSound("Hero_Zuus.ArcLightning.Target")
				
				self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(self.lightning_particle, 62, Vector(2, 0, 2))
				ParticleManager:ReleaseParticleIndex(self.lightning_particle)
				
				self.unit_counter						= self.unit_counter + 1
				self.previous_unit						= self.current_unit
				self.current_unit						= enemy
				
				if self.units_affected[self.current_unit] then
					self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
				else
					self.units_affected[self.current_unit]	= 1
				end
				
				self.zapped								= true
				
				ApplyDamage({
					victim 			= enemy,
					damage 			= self.arc_damage,
					damage_type		= DAMAGE_TYPE_MAGICAL,
					damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
					attacker 		= self:GetCaster(),
					ability 		= self:GetAbility()
				})
				break
			end
		end
		
		if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
			self:StartIntervalThink(-1)
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

LinkLuaModifier( "modifier_Daniil_LaughingRush_debuff", "abilities/heroes/navat.lua", LUA_MODIFIER_MOTION_NONE )

Daniil_LaughingRush = class({})

function Daniil_LaughingRush:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Daniil_LaughingRush:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Daniil_LaughingRush:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Daniil_LaughingRush:OnSpellStart()
	if IsServer() then
		self:GetCaster():EmitSound("Hero_Invoker.Tornado.Cast")
		self:GetCaster():EmitSound("danilfour")
	    local vDirection = self:GetCaster():GetForwardVector() - self:GetCaster():GetOrigin()
	    vDirection = vDirection:Normalized()
	    local radius = self:GetSpecialValueFor("radius")
	    self.tornado = 
	    {
	        Ability = self,
	        EffectName =  "particles/navat/laughingrush_effect.vpcf",
	        vSpawnOrigin = self:GetCaster():GetOrigin(),
	        fDistance = radius,
	        fStartRadius = 200,
	        fEndRadius = 200,
	        Source = self:GetCaster(),
	        bHasFrontalCone = false,
	        bReplaceExisting = false,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	        vVelocity = vDirection * 1500,
	        bVisibleToEnemies = true,
	        bProvidesVision = true,
	        iVisionRadius = 250,
	        bDeleteOnHit = true,
	        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
	    }
	    i = -30
	    for var=1,13, 1 do
	        ProjectileManager:CreateLinearProjectile(self.tornado)
	        self.tornado.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), self:GetCaster():GetForwardVector()) * 1500
	        i = i + 30
	    end
	end
end

function Daniil_LaughingRush:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) then
        local stun_duration = self:GetSpecialValueFor( "stun_duration" )
        if target:HasModifier("modifier_Daniil_LaughingRush_debuff") then return false end
        target:AddNewModifier( self:GetCaster(), self, "modifier_Daniil_LaughingRush_debuff", { duration = stun_duration * (1 - target:GetStatusResistance())  } )
    end
    return true
end

modifier_Daniil_LaughingRush_debuff = class({})

function modifier_Daniil_LaughingRush_debuff:IsHidden() 	return false  end
function modifier_Daniil_LaughingRush_debuff:IsPurgable() 	return false  end
function modifier_Daniil_LaughingRush_debuff:IsPurgeException() 	return true  end
function modifier_Daniil_LaughingRush_debuff:IsMotionController()  return true end
function modifier_Daniil_LaughingRush_debuff:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end

function modifier_Daniil_LaughingRush_debuff:OnCreated(kv)
	if not IsServer() then return end
	self.angle = self:GetParent():GetAngles()
	self.cyc_pos = self:GetParent():GetAbsOrigin()
	self.pfx = ParticleManager:CreateParticle("particles/navat/laughingrush_effect.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 0, self:GetParent():GetAbsOrigin())
	self:StartIntervalThink(FrameTime())
end

function modifier_Daniil_LaughingRush_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] 	= true,
		[MODIFIER_STATE_STUNNED] 			= true,
		[MODIFIER_STATE_ROOTED] 			= true,
		[MODIFIER_STATE_DISARMED] 			= true,
		[MODIFIER_STATE_FLYING] 			= true,
	}
	return state
end

function modifier_Daniil_LaughingRush_debuff:OnIntervalThink()
	if not self:CheckMotionControllers() then
		if not self:IsNull() then
            self:Destroy()
        end
		return
	end
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_Daniil_LaughingRush_debuff:HorizontalMotion(unit, time)
	if not IsServer() then return end
	local angle = self:GetParent():GetAngles()
	local new_angle = RotateOrientation(angle, QAngle(0,20,0))
	self:GetParent():SetAngles(angle.x, angle.y+20, angle.z)
	if self:GetElapsedTime() <= 0.3 then
		self.cyc_pos.z = self.cyc_pos.z + 25
		self:GetParent():SetAbsOrigin(self.cyc_pos)
	elseif self:GetDuration() - self:GetElapsedTime() < 0.3 then
		self.step = self.step or (self.cyc_pos.z - self:GetParent():GetAbsOrigin().z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
		self.cyc_pos.z = self.cyc_pos.z - self.step
		self:GetParent():SetAbsOrigin(self.cyc_pos)
	end
end

function modifier_Daniil_LaughingRush_debuff:OnDestroy()
	StopSoundOn("DOTA_Item.Cyclone.Activate", self:GetParent())
	if not IsServer() then return end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin())
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	self:GetParent():SetAngles(self.angle[1], self.angle[2], self.angle[3])
	local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_navat_2")
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

LinkLuaModifier( "modifier_StormCharge_passive", "abilities/heroes/navat.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_StormCharge_active", "abilities/heroes/navat.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_StormCharge_debuff", "abilities/heroes/navat.lua", LUA_MODIFIER_MOTION_NONE )

Daniil_StormCharge = class({})

function Daniil_StormCharge:GetIntrinsicModifierName() 
	return "modifier_StormCharge_passive"
end

function Daniil_StormCharge:GetManaCost(iLevel)
	if self:GetCaster():HasShard() then
		return 100
	end
end

function Daniil_StormCharge:GetCooldown(iLevel)
	if self:GetCaster():HasShard() then
		return 20
	end
end

function Daniil_StormCharge:GetBehavior()
	if self:GetCaster():HasShard() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Daniil_StormCharge:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_StormCharge_active", {shard = true, duration = 10})
end

modifier_StormCharge_passive = class({})

function modifier_StormCharge_passive:IsHidden()
	return true
end

function modifier_StormCharge_passive:IsPurgable()
	return false
end

function modifier_StormCharge_passive:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_StormCharge_passive:OnCreated( keys )
	if not IsServer() then return end
	self.attack_count = 0
end

function modifier_StormCharge_passive:OnRefresh( keys )
	if not IsServer() then return end
	self.attack_count = 0
end

function modifier_StormCharge_passive:OnAttackLanded( keys )
	if not IsServer() then return end
	local attacker = self:GetParent()

	if attacker ~= keys.attacker then
		return
	end

	if attacker:IsIllusion() or attacker:PassivesDisabled() then
		return
	end

	local target = keys.target
	if attacker:GetTeam() == target:GetTeam() then
		return
	end	
	if self:GetParent():HasModifier("modifier_StormCharge_active") then return end
	self.attack_count = self.attack_count + 1
	if self.attack_count >= 3 then
		self.attack_count = 0
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_StormCharge_active", {})
	end
end

modifier_StormCharge_active = class({})

function modifier_StormCharge_active:IsPurgable()
	return false
end

function modifier_StormCharge_active:OnCreated(kv)
	if IsServer() then
		if self.particle_fx then
			ParticleManager:DestroyParticle(self.particle_fx, false)
			ParticleManager:ReleaseParticleIndex(self.particle_fx)
		end
		self:GetParent():EmitSound("danilthee")
		self.particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		if kv.shard ~= nil then
			self:SetStackCount(2)
		else
			self:SetStackCount(1)
		end
	end
end

function modifier_StormCharge_active:OnRefresh(kv)
	if not IsServer() then return end
	self:OnCreated(kv)
end

function modifier_StormCharge_active:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end

function modifier_StormCharge_active:GetActivityTranslationModifiers()
	if self:GetParent():GetName() == "npc_dota_hero_storm_spirit" then
		return "overload"
	end
	return 0
end

function modifier_StormCharge_active:OnDestroy()
	if IsServer() then
		if self.particle_fx then
			ParticleManager:DestroyParticle(self.particle_fx, false)
			ParticleManager:ReleaseParticleIndex(self.particle_fx)
		end
	end
end

function modifier_StormCharge_active:OnAttackLanded( keys )
	if not IsServer() then return end
	local attacker = self:GetParent()

	if attacker ~= keys.attacker then
		return
	end

	if attacker:IsIllusion() or attacker:PassivesDisabled() then
		return
	end

	local target = keys.target
	if attacker:GetTeam() == target:GetTeam() then
		return
	end
	if target:IsOther() then return end
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	target:EmitSound("Hero_StormSpirit.Overload")
	local particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_fx)
	target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_StormCharge_debuff", {duration = duration * (1 - target:GetStatusResistance())})
	ApplyDamage({
		victim 			= target,
		damage 			= damage,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	})
	self:DecrementStackCount()
	if self:GetStackCount() <= 0 then
		if not self:IsNull() then
	        self:Destroy()
	    end
	end
end

modifier_StormCharge_debuff = class({})

function modifier_StormCharge_debuff:IsHidden()
    return false
end

function modifier_StormCharge_debuff:IsPurgable()
    return true
end

function modifier_StormCharge_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_StormCharge_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "move_slow" )
end

function modifier_StormCharge_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor( "attack_slow" )
end

LinkLuaModifier( "modifier_vortex_silence", "abilities/heroes/navat.lua", LUA_MODIFIER_MOTION_NONE )

Daniil_VortexSilence = class({})

function Daniil_VortexSilence:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Daniil_VortexSilence:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Daniil_VortexSilence:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Daniil_VortexSilence:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function Daniil_VortexSilence:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	self:GetCaster():EmitSound("daniltwo")
	target:AddNewModifier(self:GetCaster(), self, "modifier_vortex_silence", {duration = duration})
end

modifier_vortex_silence = class({})	

function modifier_vortex_silence:IsPurgable()
	return false
end

function modifier_vortex_silence:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_navat_3")
	self.interval = self:GetAbility():GetSpecialValueFor("interval")
	self.luchi = self:GetAbility():GetSpecialValueFor("max_luchi")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.counter = 0
	self:StartIntervalThink(self.interval)
	self:OnIntervalThink()
end

function modifier_vortex_silence:CheckState() 
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
	  local state =
      {
		[MODIFIER_STATE_SILENCED] = true
      }
      if self:GetCaster():HasScepter() then
      	state =
	      {
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	      }
      end
	  return state
  end
  return
end

function modifier_vortex_silence:GetEffectName()
	return "particles/navat/vortexsilence_debuff.vpcf"
end

function modifier_vortex_silence:OnIntervalThink()
	if not IsServer() then return end
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false )

	local unit = nil
	if #units>0 then
		unit = units[1]
	end
	
	if unit ~= nil then
		ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, unit)
		ParticleManager:SetParticleControl(particle, 0, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z))
		ParticleManager:SetParticleControl(particle, 1, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, 2000))
		ParticleManager:SetParticleControl(particle, 2, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z))
		unit:EmitSound("Hero_Zuus.LightningBolt")
		self.counter = self.counter + 1
		if self.counter>=self.luchi then
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end