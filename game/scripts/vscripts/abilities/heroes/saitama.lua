LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_saitama_fast_attack", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_NONE)

saitama_fast_attack = class({})

function saitama_fast_attack:OnSpellStart()
	if not IsServer() then return end
	local point = self:GetCursorPosition()
	if point == self:GetCaster():GetAbsOrigin() then
		point = point + self:GetCaster():GetForwardVector()
	end
	local direction = point - self:GetCaster():GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()
	self:GetCaster():SetForwardVector(direction)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_saitama_fast_attack", {})
end

modifier_saitama_fast_attack = class({})

function modifier_saitama_fast_attack:IsHidden() return true end

function modifier_saitama_fast_attack:IsPurgable() return false end

function modifier_saitama_fast_attack:OnCreated()
	if not IsServer() then return end
	self.attack_count = self:GetAbility():GetSpecialValueFor("attack_count") + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_4")
	self.base_damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_1")
	self.damage_from_attack = self:GetAbility():GetSpecialValueFor("damage_from_attack")
	self.attack_current = 0
	self.anim = ACT_DOTA_ATTACK
	self:StartIntervalThink(0.15)
end

function modifier_saitama_fast_attack:OnIntervalThink()
	if not IsServer() then return end
	if self.attack_current == self.attack_count then self:Destroy() return end
	if self:GetParent():IsStunned() then self:Destroy() return end
	if self:GetParent():IsDisarmed() then self:Destroy() return end
	local damage = self.base_damage + (self:GetParent():GetAverageTrueAttackDamage(nil) / 100 * self.damage_from_attack)
	self.attack_current = self.attack_current + 1

	self:GetParent():StartGestureWithPlaybackRate(self.anim, 10)

	if self.anim == ACT_DOTA_ATTACK then
		self.anim = ACT_DOTA_ATTACK2
	else
		self.anim = ACT_DOTA_ATTACK
	end

	self:GetParent():EmitSound("saitama_attack")

	local particle = ParticleManager:CreateParticle( "particles/saitama/auto_attack_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 200)
	ParticleManager:ReleaseParticleIndex( particle )

	local units = FindUnitsInLine(self:GetParent():GetTeamNumber(), self:GetCaster():GetAbsOrigin() + self:GetParent():GetForwardVector(), (self:GetCaster():GetAbsOrigin() + self:GetParent():GetForwardVector() * self:GetParent():Script_GetAttackRange()), self:GetParent(), 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE)
	for _, unit in pairs(units) do
        ApplyDamage( { victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = nil } )
        if self:GetCaster():HasTalent("special_bonus_birzha_saitama_7") then
			self:GetCaster():PerformAttack(unit, true, true, true, false, false, true, true)
		end
	end
end

function modifier_saitama_fast_attack:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE
	}
	return funcs
end

function modifier_saitama_fast_attack:GetModifierDisableTurning()
	return 1
end

function modifier_saitama_fast_attack:GetModifierMoveSpeed_Absolute()
	return 20
end

function modifier_saitama_fast_attack:GetModifierFixedAttackRate( params )
    return 10
end

function modifier_saitama_fast_attack:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

LinkLuaModifier("modifier_saitama_jump", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH )

saitama_jump = class({})

function saitama_jump:GetAOERadius()
    return self:GetSpecialValueFor("radius") + (self:GetSpecialValueFor("limeter_radius") * self:GetCaster():GetModifierStackCount("modifier_saitama_lemiter", self:GetCaster()))
end

function saitama_jump:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level) + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_2")
end

function saitama_jump:OnSpellStart()
	local caster = self:GetCaster()
	local position_target = self:GetCursorPosition()
	local kv = {vLocX = position_target.x,vLocY = position_target.y,vLocZ = position_target.z}
	if not IsServer() then return end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_saitama_jump", kv )
	ProjectileManager:ProjectileDodge(caster)
end

modifier_saitama_jump = class({})

function modifier_saitama_jump:IsHidden()
	return true
end

function modifier_saitama_jump:IsPurgable()
	return false
end

function modifier_saitama_jump:RemoveOnDeath()
	return false
end

function modifier_saitama_jump:OnCreated( kv )
	if IsServer() then
		self.bHorizontalMotionInterrupted = false
		self.bDamageApplied = false
		self.bTargetTeleported = false
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			if not self:IsNull() then
                self:Destroy()
            end
			return
		end
		self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
		self.flCurrentTimeHoriz = 0.0
		self.flCurrentTimeVert = 0.0
		self.vLoc = Vector( kv.vLocX, kv.vLocY, kv.vLocZ )
		self.vLastKnownTargetPos = self.vLoc
		local duration = 0.3
		local flDesiredHeight = 200 * duration * duration
		local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + 200 )
		local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
		self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * 10000 )
		local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
		local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * 10000 * flDeltaZ ) )
		self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / 10000, ( self.flInitialVelocityZ - flSqrtDet) / 10000 )
		self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
		self.vHorizontalVelocity.z = 0.0
	end
end

function modifier_saitama_jump:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
	end
end

function modifier_saitama_jump:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_saitama_jump:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_saitama_jump:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeHoriz = math.min( self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime )
		local t = self.flCurrentTimeHoriz / self.flPredictedTotalTime
		local vStartToTarget = self.vLastKnownTargetPos - self.vStartPosition
		local vDesiredPos = self.vStartPosition + t * vStartToTarget

		local vOldPos = me:GetOrigin()
		local vToDesired = vDesiredPos - vOldPos
		vToDesired.z = 0.0
		local vDesiredVel = vToDesired / dt
		local vVelDif = vDesiredVel - self.vHorizontalVelocity
		local flVelDif = vVelDif:Length2D()
		vVelDif = vVelDif:Normalized()
		local flVelDelta = math.min( flVelDif, 3000 )

		self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
		local vNewPos = vOldPos + self.vHorizontalVelocity * dt
		me:SetOrigin( vNewPos )
	end
end

function modifier_saitama_jump:UpdateVerticalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeVert = self.flCurrentTimeVert + dt
		local bGoingDown = ( -10000 * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0
		
		local vNewPos = me:GetOrigin()
		vNewPos.z = self.vStartPosition.z + ( -0.5 * 10000 * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

		local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
		local bLanded = false
		if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
			vNewPos.z = flGroundHeight
			bLanded = true
		end

		me:SetOrigin( vNewPos )
		if bLanded == true then
			if self.bHorizontalMotionInterrupted == false then
				local radius = self:GetAbility():GetSpecialValueFor("radius") + (self:GetAbility():GetSpecialValueFor("limeter_radius") * self:GetCaster():GetModifierStackCount("modifier_saitama_lemiter", self:GetCaster()))
				local damage = self:GetAbility():GetSpecialValueFor("damage")
				local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
				local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_rebound_bounce_impact.vpcf", PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
				ParticleManager:SetParticleControl( effect_cast, 1, self.vStartPosition )
				ParticleManager:SetParticleControl( effect_cast, 9, Vector(radius+200, radius+200, radius+200) )
				ParticleManager:SetParticleControl( effect_cast, 10, self:GetParent():GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( effect_cast )
				EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "Hero_Marci.Rebound.Impact", self:GetParent() )
				local units = FindUnitsInRadius( self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
				for _, unit in pairs(units) do
					unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_stunned", {duration = stun_duration * (1 - unit:GetStatusResistance()) })
					ApplyDamage({ victim = unit, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
				end
			end

			self:GetParent():RemoveHorizontalMotionController( self )
			self:GetParent():RemoveVerticalMotionController( self )

			self:SetDuration( 0.15, false)
		end
	end
end

function modifier_saitama_jump:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.bHorizontalMotionInterrupted = true
	end
end

function modifier_saitama_jump:OnVerticalMotionInterrupted()
	if IsServer() then
		if not self:IsNull() then
            self:Destroy()
        end
	end
end

LinkLuaModifier("modifier_saitama_kick", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_saitama_kick_debuff", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_saitama_buff", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH )

saitama_kick = class({})

function saitama_kick:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level) + (self:GetCaster():GetModifierStackCount("modifier_saitama_lemiter", self:GetCaster()) * self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_3"))
end

function saitama_kick:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	local dirX = target:GetOrigin().x-self:GetCaster():GetOrigin().x
	local dirY = target:GetOrigin().y-self:GetCaster():GetOrigin().y
	local modifier_saitama_kick = self:GetCaster():FindModifierByName("modifier_saitama_kick")
	if modifier_saitama_kick then
		modifier_saitama_kick:Kick( target, dirX, dirY )
	end
end

modifier_saitama_buff = class({})

function modifier_saitama_buff:IsPurgable() return false end
function modifier_saitama_buff:RemoveOnDeath() return false end

function saitama_kick:GetIntrinsicModifierName()
    if self:GetCaster():GetUnitName() ~= "npc_dota_hero_saitama" then return end
	return "modifier_saitama_kick"
end

modifier_saitama_kick = class({})

function modifier_saitama_kick:IsHidden() return true end
function modifier_saitama_kick:IsPurgable() return false end

function modifier_saitama_kick:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_saitama_kick:OnAttackLanded(params)
	if not IsServer() then return end
	if params.target ~= self:GetParent() then return end
	if not self:GetAbility():IsFullyCastable() then return end
	if params.attacker:IsBoss() then return end
	local distance_min = self:GetAbility():GetSpecialValueFor("radius_damage")
	if self:GetAbility():GetAutoCastState() then return end
	if params.attacker:IsMagicImmune() then return end
	local distance = (self:GetParent():GetAbsOrigin() - params.attacker:GetAbsOrigin()):Length2D()
	if distance <= distance_min then
		self:GetAbility():UseResources(false, false, false, true)
		local dirX = params.attacker:GetOrigin().x-self:GetParent():GetOrigin().x
		local dirY = params.attacker:GetOrigin().y-self:GetParent():GetOrigin().y
		self:Kick( params.attacker, dirX, dirY )
	end
end

function modifier_saitama_kick:Kick( target, x, y )
	local distance = self:GetAbility():GetSpecialValueFor("radius_kick")
	local base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
	local damage_from_attack = self:GetAbility():GetSpecialValueFor("damage_from_attack")
	local damage = base_damage + (self:GetParent():GetAverageTrueAttackDamage(nil) / 100 * damage_from_attack)
	local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")

	local mod = target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_saitama_kick_debuff", { x = x, y = y, r = distance, } )

	local info = {
		Source = self:GetCaster(),
		Ability = self:GetAbility(),
		vSpawnOrigin = target:GetOrigin(),
	    bDeleteOnHit = false,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = 0,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    EffectName = "",
	    fDistance = distance,
	    fStartRadius = 100,
	    fEndRadius =100,
		vVelocity = Vector(x,y,0):Normalized() * 1500,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		ExtraData = {
			damage = damage,
			stun = stun_duration,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)
	self:PlayEffects2( target, Vector(x,y,0):Normalized(), distance/1500 )
end

function saitama_kick:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if not hTarget then return end
	local damageTable = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = extraData.damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self,
	}
	ApplyDamage(damageTable)
    if not hTarget:HasModifier("modifier_saitama_kick_debuff") then
	   hTarget:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = extraData.stun * ( 1 - hTarget:GetStatusResistance()) }  )
    end
	hTarget:EmitSound("Hero_EarthSpirit.BoulderSmash.Damage")
	return false
end

function modifier_saitama_kick:PlayEffects2( target, direction, duration )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	target:EmitSound("saitama_kick")
end

modifier_saitama_kick_debuff = class({})

function modifier_saitama_kick_debuff:IsDebuff()
	return true
end

function modifier_saitama_kick_debuff:IsHidden()
    return true
end

function modifier_saitama_kick_debuff:IsPurgable()
	return false
end

function modifier_saitama_kick_debuff:RemoveOnDeath()
    return false
end

function modifier_saitama_kick_debuff:OnCreated( kv )
	if IsServer() then
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = 1500
		self.origin = self:GetParent():GetOrigin()
		if self:ApplyHorizontalMotionController() == false then
            if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

function modifier_saitama_kick_debuff:OnRefresh( kv )
	if IsServer() then
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = 1500
		self.origin = self:GetParent():GetOrigin()
		if self:ApplyHorizontalMotionController() == false then 
            if not self:IsNull() then
                self:Destroy()
            end
		end
	end	
end

function modifier_saitama_kick_debuff:OnDestroy( kv )
	if IsServer() then
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = stun_duration * ( 1 - self:GetParent():GetStatusResistance()) }  )
		self:GetParent():InterruptMotionControllers( true )
	end
end

function modifier_saitama_kick_debuff:UpdateHorizontalMotion( me, dt )
	local pos = self:GetParent():GetOrigin()
	if (pos-self.origin):Length2D()>=self.distance then
        if not self:IsNull() then
            self:Destroy()
        end
		return
	end
	local target = pos + self.direction * (self.speed*dt)
	self:GetParent():SetOrigin( target )
end

function modifier_saitama_kick_debuff:OnHorizontalMotionInterrupted()
	if IsServer() then
        if not self:IsNull() then
            self:Destroy()
        end
	end
end

function modifier_saitama_kick_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_saitama_kick_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end







LinkLuaModifier("modifier_saitama_react", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH )

saitama_react = class({})

function saitama_react:GetIntrinsicModifierName()
	return "modifier_saitama_react"
end

function saitama_react:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function saitama_react:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

modifier_saitama_react = class({})

function modifier_saitama_react:IsHidden() return true end
function modifier_saitama_react:IsPurgable() return false end

function modifier_saitama_react:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_saitama_react:GetModifierAvoidDamage(keys)
    if not IsServer() then return end
    if not self:GetCaster():HasScepter() then return 0 end
    if self:GetParent():PassivesDisabled() then return end
    local chance = self:GetAbility():GetSpecialValueFor( "chance" )
    if IsInToolsMode() then
    	chance = 100
    end
    if RandomInt(1, 100) <= chance then
    	local particle = ParticleManager:CreateParticle("particles/saitama/avoid.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    	ParticleManager:SetParticleControl(particle, 1, Vector(5,5,5))
    	return 1
    else
    	return 0
    end
end

LinkLuaModifier("modifier_saitama_lemiter", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH )

saitama_lemiter = class({})

function saitama_lemiter:Spawn()
    if not IsServer() then return end
    if self and not self:IsTrained() then
        self:SetLevel(1)
    end
end

function saitama_lemiter:GetIntrinsicModifierName()
	return "modifier_saitama_lemiter"
end

modifier_saitama_lemiter = class({})

function modifier_saitama_lemiter:IsPurgable() return false end

function modifier_saitama_lemiter:OnCreated()
	if not IsServer() then return end
	self.damage = 0
	self.damage_for_stack = self:GetAbility():GetSpecialValueFor("damage_for_stack")
	self.max_charges = self:GetAbility():GetSpecialValueFor("max_charges")
end

function modifier_saitama_lemiter:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_saitama_lemiter:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
	if params.attacker:GetUnitName() == "dota_fountain" then return end
	if params.attacker:IsBoss() then return end
	if self:GetParent():IsIllusion() then return end
	if not self:GetParent():IsAlive() then return end
	if self:GetParent():HasModifier("modifier_item_uebator_active") then return end
	if self:GetParent():HasModifier("modifier_item_aeon_disk_buff") then return end
	if self:GetStackCount() >= self.max_charges then return end

    self.damage = self.damage + params.damage
    if self.damage >= self.damage_for_stack then
    	self.damage = 0
    	self:IncrementStackCount()
    end
end

function modifier_saitama_lemiter:GetModifierDamageOutgoing_Percentage()
	return (self:GetAbility():GetSpecialValueFor("damage_per_stack")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_5") ) * self:GetStackCount()
end

function modifier_saitama_lemiter:GetModifierIncomingDamage_Percentage()
	return (self:GetAbility():GetSpecialValueFor("resist_per_stack")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_6") ) * self:GetStackCount()
end

LinkLuaModifier("modifier_saitama_punch", "abilities/heroes/saitama.lua", LUA_MODIFIER_MOTION_BOTH)

saitama_punch = class({})

function saitama_punch:GetCastPoint()
    if self:GetCaster():HasShard() then
        return 0.5
    end
    return self.BaseClass.GetCastPoint( self )
end

function saitama_punch:OnAbilityPhaseStart()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
	self.particle = ParticleManager:CreateParticle("particles/saitama/ultimate_effect_start.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "ATTACH_ATTACK1", self:GetCaster():GetAbsOrigin(), true)

    local cast_point = 1.55
    if self:GetCaster():HasShard() then
    	cast_point = 6.5
    end
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_6, cast_point / self:GetCastPointModifier() )
    return true
end

function saitama_punch:OnAbilityPhaseInterrupted()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
	self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
end

function saitama_punch:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local target_loc = self:GetCursorPosition()
	local caster_loc = caster:GetAbsOrigin()
	local projectile_speed = 1500

	local direction
	if target_loc == caster_loc then
		direction = caster:GetForwardVector()
	else
		direction = (target_loc - caster_loc):Normalized()
	end

	local range = self:GetSpecialValueFor("range") + self:GetSpecialValueFor("limeter_range") * self:GetCaster():GetModifierStackCount("modifier_saitama_lemiter", self:GetCaster())

	local projectile =
	{
		Ability				= self,
		EffectName			= "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_sonic_wave.vpcf",
		vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
		fDistance			= range,
		fStartRadius		= 175,
		fEndRadius			= 175,
		Source				= self:GetCaster(),
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x,direction.y,0) * projectile_speed,
		bProvidesVision		= false,
		ExtraData			= {x = caster_loc.x, y = caster_loc.y, z = caster_loc.z}
	}

	self:GetCaster():EmitSound("saitama_ultimate_punch")
	self:GetCaster():EmitSound("saitama_ultimate_punch_2")
	self:GetCaster():EmitSound("saitama_ultimate_punch_3")

	ProjectileManager:CreateLinearProjectile(projectile)

	self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_6)

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end

function saitama_punch:OnProjectileHit_ExtraData(target, location, ExtraData)
	if not target then return end

	if target:IsHero() then
		local Player = PlayerResource:GetPlayer(target:GetPlayerID())

		CustomGameEventManager:Send_ServerToPlayer(Player, "SaitamaPunchTrue", {} )

		Timers:CreateTimer(0.30, function()
			CustomGameEventManager:Send_ServerToPlayer(Player, "SaitamaPunchFalse", {} )
		end)
	end

	local range = self:GetSpecialValueFor("range") + self:GetSpecialValueFor("limeter_range") * self:GetCaster():GetModifierStackCount("modifier_saitama_lemiter", self:GetCaster())
	local direction = (target:GetAbsOrigin() - Vector(ExtraData.x, ExtraData.y, ExtraData.z)):Normalized()
	local end_distance = Vector(ExtraData.x, ExtraData.y, ExtraData.z) + direction * range
	local distance = (target:GetAbsOrigin() - end_distance):Length2D()
	local duration = self:GetSpecialValueFor("knockback_duration") *  (distance / range)
	local critical_damage = (self:GetSpecialValueFor("damage")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_8") ) *  (distance / range)

	if distance / range <= 1 and distance / range >= 0.8 then
		critical_damage = (self:GetSpecialValueFor("damage")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_8") ) * 1
	end

	if distance / range <= 0.8 and distance / range >= 0.6 then
		critical_damage = (self:GetSpecialValueFor("damage")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_8") ) * 0.8
	end

	if distance / range <= 0.6 and distance / range >= 0.4 then
		critical_damage = (self:GetSpecialValueFor("damage")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_8") ) * 0.6
	end

	if distance / range < 0.4 then
		critical_damage = (self:GetSpecialValueFor("damage")  + self:GetCaster():FindTalentValue("special_bonus_birzha_saitama_8") ) * 0.4
	end

	local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * critical_damage
	ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PURE})
	local speed = distance / duration
	local distance_knock = speed*duration
	target:EmitSound("saitama_ultimate_punch_4")
	target:AddNewModifier(self:GetCaster(), self, "modifier_saitama_punch", 
	{
		distance		= distance_knock,
		direction_x 	= target:GetAbsOrigin().x - ExtraData.x,
		direction_y 	= target:GetAbsOrigin().y - ExtraData.y,
		direction_z 	= target:GetAbsOrigin().z - ExtraData.z,
		duration 		= duration,
		bGroundStop 	= true,
		bDecelerate 	= false,
		bInterruptible 	= false,
		bIgnoreTenacity	= false,
		bDestroyTreesAlongPath	= true
	})
end

modifier_saitama_punch = class({})

function modifier_saitama_punch:IgnoreTenacity()	return self.bIgnoreTenacity == 1 end
function modifier_saitama_punch:IsHidden() return true end
function modifier_saitama_punch:IsPurgable()		return self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() end
function modifier_saitama_punch:GetAttributes()		return MODIFIER_ATTRIBUTE_MULTIPLE end -- This seems to allow proper interruption of stacking modifiers or something

function modifier_saitama_punch:OnCreated(params)
	if not IsServer() then return end
	
	self.distance			= params.distance
	self.direction			= Vector(params.direction_x, params.direction_y, params.direction_z):Normalized()
	self.duration			= params.duration
	self.height				= params.height
	self.bInterruptible		= params.bInterruptible
	self.bGroundStop		= params.bGroundStop
	self.bDecelerate		= params.bDecelerate
	self.bIgnoreTenacity	= params.bIgnoreTenacity
	self.treeRadius			= params.treeRadius
	self.bStun				= params.bStun
	self.bDestroyTreesAlongPath	= params.bDestroyTreesAlongPath
	
	-- Velocity = Displacement/Time
	self.velocity		= self.direction * self.distance / self.duration
	
	-- If decelerating...
	-- Horizontal Starting Velocity
	-- Rationale: distance = (initial_velocity + final_velocity) * time / 2
	
	-- Final_velocity is 0, so:
	-- distance = (initial_velocity) * time / 2
	
	-- Solve for initial_velocity:
	-- initial_velocity = 2 * distance / time
	
	-- Using this for self.horizontal_velocity
	
	
	
	-- Horizontal Acceleration (if applicable)
	-- Rationale: acceleration = (final_velocity - initial_velocity) / time
	
	-- Final_velocity is 0, so:
	-- acceleration = -initial_velocity / * time
	
	-- Substitute for initial_velocity solved above:
	-- acceleration = -(2 * distance / time) / time
	-- acceleration = -(2 * distance) / time^2
	
	-- Using this for self.horizontal_acceleration
	if self.bDecelerate and self.bDecelerate == 1 then
		self.horizontal_velocity		= (2 * self.distance / self.duration) * self.direction
		self.horizontal_acceleration 	= -(2 * self.distance) / (self.duration * self.duration)
	end
	
	-- Vertical Starting Velocity (if applicable)
	-- Rationale: distance = (initial_velocity + final_velocity) * time / 2
	
	-- At half (0.5) time, final_velocity is 0, so:
	-- distance = (initial_velocity) * 0.5 * time / 2
	
	-- Solve for initial_velocity:
	-- initial_velocity = distance * 2 / (0.5 * time)
	-- initial_velocity = 4 * distance / time
	
	-- Using this for self.vertical_velocity (more like distance cause no directional but w/e)
	
	
	
	-- Vertical Acceleration (if applicable)
	-- Rationale: acceleration = (final_velocity - initial_velocity) / time
	
	-- At half (0.5) time, final_velocity is 0, so:
	-- acceleration = -initial_velocity / (0.5 * time)
	
	-- Substitute for initial_velocity solved above:
	-- acceleration = -(4 * distance / time) / (0.5 * time)
	-- acceleration = -(8 * distance) / time^2
	
	-- Using this for self.vertical_acceleration
	
	if self.height then
		self.vertical_velocity		= 4 * self.height / self.duration
		self.vertical_acceleration	= -(8 * self.height) / (self.duration * self.duration)
	end
	
	if self:ApplyHorizontalMotionController() == false then 
		self:Destroy()
	end
	
	-- What is this Tusk stuff crashing the game...
	if self:GetParent():HasModifier("modifier_tusk_walrus_punch_air_time") or self:GetParent():HasModifier("modifier_tusk_walrus_kick_air_time") or self:ApplyVerticalMotionController() == false then 
		self:Destroy()
	end
end

function modifier_saitama_punch:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():RemoveHorizontalMotionController(self)
	self:GetParent():RemoveVerticalMotionController(self)
	
	if self:GetRemainingTime() <= 0 and self.treeRadius then
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.treeRadius, true )
	end
end

function modifier_saitama_punch:UpdateHorizontalMotion(me, dt)
	if not IsServer() then return end
	
	if not self.bDecelerate or self.bDecelerate == 0 then
		me:SetOrigin( me:GetOrigin() + self.velocity * dt )
	else
		me:SetOrigin( me:GetOrigin() + (self.horizontal_velocity * dt) )
		self.horizontal_velocity = self.horizontal_velocity + (self.direction * self.horizontal_acceleration * dt)
	end
	
	if self.bDestroyTreesAlongPath and self.bDestroyTreesAlongPath == 1 then
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self:GetParent():GetHullRadius(), true )
	end
	
	if self.bInterruptible == 1 and self:GetParent():IsStunned() then
		self:Destroy()
	end
end

-- This typically gets called if the caster uses a position breaking tool (ex. Blink Dagger) while in mid-motion
function modifier_saitama_punch:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_saitama_punch:UpdateVerticalMotion(me, dt)
	if not IsServer() then return end
	
	if self.height then
		me:SetOrigin( me:GetOrigin() + Vector(0, 0, self.vertical_velocity) * dt )
		
		if self.bGroundStop == 1 and GetGroundHeight(self:GetParent():GetAbsOrigin(), nil) > self:GetParent():GetAbsOrigin().z then
			self:Destroy()
		else
			self.vertical_velocity = self.vertical_velocity + (self.vertical_acceleration * dt)
		end
	else
		me:SetOrigin( GetGroundPosition(me:GetOrigin(), nil) )
	end
end

-- -- This typically gets called if the caster uses a position breaking tool (ex. Earth Spike) while in mid-motion
function modifier_saitama_punch:OnVerticalMotionInterrupted()
	self:Destroy()
end

function modifier_saitama_punch:CheckState()
	local state = {}
	
	if self.bStun and self.bStun == 1 then
		state[MODIFIER_STATE_STUNNED] = true
	end
	
	return state
end

function modifier_saitama_punch:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_saitama_punch:GetOverrideAnimation( params )
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return ACT_DOTA_FLAIL
	end
end





















