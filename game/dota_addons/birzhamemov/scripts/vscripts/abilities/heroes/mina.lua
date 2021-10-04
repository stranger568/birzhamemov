LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

mina_explosive_wave = class({})

function mina_explosive_wave:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end

function mina_explosive_wave:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function mina_explosive_wave:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mina_explosive_wave:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function mina_explosive_wave:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_loc = self:GetCursorPosition()
		local caster_loc = caster:GetAbsOrigin()
		local radius = self:GetSpecialValueFor("aoe_radius")
		local cast_delay = self:GetSpecialValueFor("cast_delay")
		local stun_duration = self:GetSpecialValueFor("stun_duration")
		local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_mina_2")
		local secondary_delay = self:GetSpecialValueFor("secondary_delay")
		local array_count = self:GetSpecialValueFor("array_count")
		local array_rings_count = self:GetSpecialValueFor("array_rings_count")
		local rings_radius = self:GetSpecialValueFor("rings_radius")
		local rings_delay = self:GetSpecialValueFor("rings_delay")
		local rings_distance = self:GetSpecialValueFor("rings_distance")
		local direction = (target_loc - caster_loc):Normalized()
		caster:EmitSound("Hero_Techies.LandMine.Priming")
		if (math.random(1,5) < 2) and (caster:GetName() == "npc_dota_hero_techies") then
			caster:EmitSound("Hero_Techies.LandMine.Detonate"..math.random(1,6))
		end
		self:CreateStrike( target_loc, 0, cast_delay, radius, damage, stun_duration )
		for i=0, array_count-1, 1 do
			local distance = i
			local count = i
			local next_distance = i+1
			local array_strike = i+1
			distance = radius * (distance + rings_distance)
			next_distance = radius * (next_distance + rings_distance)
			local delay = math.abs(distance / (radius * 2)) * cast_delay
			local rings_direction = direction
			for j=1, array_rings_count, 1 do
				rings_direction = RotateVector2D(rings_direction,((360/array_rings_count)),true)
				local ring_distance = rings_radius * (array_strike + 1)
				local ring_delay = math.abs((radius * (i + cast_delay + rings_distance)) / (rings_radius * 2)) * cast_delay
				local ring_position = target_loc + ring_distance * rings_direction
				self:CreateStrike( ring_position, (cast_delay + ring_delay), (cast_delay + rings_delay), rings_radius, damage, stun_duration )
			end
		end
	end
end

function RotateVector2D(v,angle,bIsDegree)
    if bIsDegree then angle = math.rad(angle) end
    local xp = v.x * math.cos(angle) - v.y * math.sin(angle)
    local yp = v.x * math.sin(angle) + v.y * math.cos(angle)
    return Vector(xp,yp,v.z):Normalized()
end

function mina_explosive_wave:CreateStrike( position, delay, cast_delay, radius, damage, stun_duration )
	local caster = self:GetCaster()

	Timers:CreateTimer(delay, function()
		local cast_pfx = ParticleManager:CreateParticleForTeam("particles/heroes/hero_mina/explosionwave_start.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeam())
		ParticleManager:SetParticleControl(cast_pfx, 0, position)
		ParticleManager:SetParticleControl(cast_pfx, 1, Vector(radius * 2, 0, 0))
		ParticleManager:ReleaseParticleIndex(cast_pfx)
	end)

	Timers:CreateTimer((delay+cast_delay), function()
		local blast_pfx = ParticleManager:CreateParticle("particles/heroes/hero_mina/explosionwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, position)
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(blast_pfx)
		EmitSoundOnLocationWithCaster( position, "Hero_Techies.LandMine.Detonate", caster )
		GridNav:DestroyTreesAroundPoint(position, radius, false)

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in ipairs(enemies) do
			self:OnHit(enemy, damage, stun_duration)
		end
	end)
end

function mina_explosive_wave:OnHit( target, damage, stun_duration )
	local caster = self:GetCaster()
	ApplyDamage({attacker = caster, victim = target, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
    target:AddNewModifier(caster, self, "modifier_birzha_stunned_purge", {duration = stun_duration})
end

LinkLuaModifier("modifier_mina_explosion_jump", "abilities/heroes/mina.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_mina_explosive_jump_debuff", "abilities/heroes/mina.lua", LUA_MODIFIER_MOTION_NONE)

mina_explosion_jump = class({})

function mina_explosion_jump:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function mina_explosion_jump:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function mina_explosion_jump:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mina_explosion_jump:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function mina_explosion_jump:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_START)
    end
    return true
end

function mina_explosion_jump:OnSpellStart()
    if IsServer() then
        local vLocation = self:GetCursorPosition()
        local kv =
        {
            vLocX = vLocation.x,
            vLocY = vLocation.y,
            vLocZ = vLocation.z
        }
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_mina_explosion_jump", kv )
        EmitSoundOn( "Hero_MonkeyKing.TreeJump.Cast", self:GetCaster() )
        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_launch.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
end

modifier_mina_explosion_jump = class({})

local TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST = 800
local TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST = 400
local TECHIES_ACCELERATION_Z = 4000
local TECHIES_MAX_HORIZONTAL_ACCELERATION = 3000

function modifier_mina_explosion_jump:IsHidden()
    return true
end

function modifier_mina_explosion_jump:IsPurgable()
    return false
end

function modifier_mina_explosion_jump:RemoveOnDeath()
    return false
end

function modifier_mina_explosion_jump:OnCreated( kv )
    if IsServer() then
        self.bHorizontalMotionInterrupted = false
        self.bDamageApplied = false
        self.bTargetTeleported = false

        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_START)

        self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
        self.flCurrentTimeHoriz = 0.0
        self.flCurrentTimeVert = 0.0

        self.vLoc = Vector( kv.vLocX, kv.vLocY, kv.vLocZ )
        self.vLastKnownTargetPos = self.vLoc

        local duration = 0
        local flDesiredHeight = TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST * duration * duration
        local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST )

        local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
        self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * TECHIES_ACCELERATION_Z )

        local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
        local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * TECHIES_ACCELERATION_Z * flDeltaZ ) )
        self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / TECHIES_ACCELERATION_Z, ( self.flInitialVelocityZ - flSqrtDet) / TECHIES_ACCELERATION_Z )

        self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
        self.vHorizontalVelocity.z = 0.0

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, false )
    end
end

function modifier_mina_explosion_jump:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController( self )
        self:GetParent():RemoveVerticalMotionController( self )
		self.radius  = self:GetAbility():GetSpecialValueFor("radius")
		self.damage  = self:GetAbility():GetSpecialValueFor("damage")
		self.duration  = self:GetAbility():GetSpecialValueFor("duration")
        EmitSoundOn("Hero_Techies.Suicide", self:GetCaster())
        local particle_explosion_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_explosion_fx)
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for i,unit in ipairs(units) do
			ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE })
			unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mina_explosive_jump_debuff", {duration = self.duration * (1 - unit:GetStatusResistance())})
		end
    end
end

function modifier_mina_explosion_jump:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_mina_explosion_jump:CheckState()
    local state =
    {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_mina_explosion_jump:UpdateHorizontalMotion( me, dt )
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
        local flVelDelta = math.min( flVelDif, TECHIES_MAX_HORIZONTAL_ACCELERATION )

        self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
        local vNewPos = vOldPos + self.vHorizontalVelocity * dt
        me:SetOrigin( vNewPos )
    end
end

function modifier_mina_explosion_jump:UpdateVerticalMotion( me, dt )
    if IsServer() then
        self.flCurrentTimeVert = self.flCurrentTimeVert + dt
        local bGoingDown = ( -TECHIES_ACCELERATION_Z * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0

        local vNewPos = me:GetOrigin()
        vNewPos.z = self.vStartPosition.z + ( -0.5 * TECHIES_ACCELERATION_Z * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

        local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
        local bLanded = false
        if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
            vNewPos.z = flGroundHeight
            bLanded = true
        end

        me:SetOrigin( vNewPos )
        if bLanded == true then
            if self.bHorizontalMotionInterrupted == false then
               --- self:GetAbility():BlowUp()
            end

            self:GetParent():RemoveHorizontalMotionController( self )
            self:GetParent():RemoveVerticalMotionController( self )

            self:SetDuration( 0.15, false)
        end
    end
end


function modifier_mina_explosion_jump:OnHorizontalMotionInterrupted()
    if IsServer() then
        self.bHorizontalMotionInterrupted = true
    end
end

function modifier_mina_explosion_jump:OnVerticalMotionInterrupted()
    if IsServer() then
        self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2_END)
        self:Destroy()
    end
end

function modifier_mina_explosion_jump:GetOverrideAnimation( params )
    return ACT_DOTA_CAST_ABILITY_2
end

modifier_mina_explosive_jump_debuff = class({})

function modifier_mina_explosive_jump_debuff:IsPurgable() return true end

function modifier_mina_explosive_jump_debuff:CheckState()
    local state = {[MODIFIER_STATE_SILENCED] = true}
    if self:GetCaster():HasTalent("special_bonus_birzha_mina_4") then
	    state = {[MODIFIER_STATE_MUTED] = true,
	    [MODIFIER_STATE_SILENCED] = true}
	end
    return state
end

function modifier_mina_explosive_jump_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_mina_explosive_jump_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end



LinkLuaModifier("modifier_radiation_field", "abilities/heroes/mina.lua", LUA_MODIFIER_MOTION_NONE)

mina_radiation_field = class({})

function mina_radiation_field:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function mina_radiation_field:GetIntrinsicModifierName()
	return "modifier_radiation_field"
end

modifier_radiation_field = class({})

function modifier_radiation_field:IsPurgable()
	return false
end

function modifier_radiation_field:IsHidden()
	return true
end

function modifier_radiation_field:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,

	}

	return funcs
end

function modifier_radiation_field:OnAbilityExecuted( params )
	if IsServer() then
		local hAbility = params.ability
		if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
			return 0
		end

		if hAbility:IsToggle() or hAbility:IsItem() then
			return 0
		end

		local flDamagePct = self:GetAbility():GetSpecialValueFor("damage_health_pct") + self:GetCaster():FindTalentValue("special_bonus_birzha_mina_1")
		local radius = self:GetAbility():GetSpecialValueFor("radius")

		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs( enemies ) do
				if enemy ~= nil and not enemy:IsAncient() then
					local damage =
					{
						victim = enemy,
						attacker = self:GetParent(),
						damage = ( ( enemy:GetHealth() * flDamagePct ) / 100 ),
						damage_type = DAMAGE_TYPE_PURE,
						ability = self:GetAbility(),
						damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
					}
					ApplyDamage( damage )
					ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticle( "particles/heroes/hero_mina/radiation_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy ) )
					enemy:EmitSound("Hero_Zuus.StaticField")

				end
			end
		end
	end

	return 0
end

LinkLuaModifier("modifier_mina_nuclear_strike","abilities/heroes/mina.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mina_nuclear_strike_slow","abilities/heroes/mina.lua",LUA_MODIFIER_MOTION_NONE)

mina_nuclear_strike = class({})

function mina_nuclear_strike:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function mina_nuclear_strike:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function mina_nuclear_strike:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function mina_nuclear_strike:OnSpellStart()
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():EmitSound("minaepta")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mina_nuclear_strike", {duration=duration})
end

function mina_nuclear_strike:FastDummy(target, team, duration, vision)
	duration = duration or 0.03
	vision = vision or  250
	local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
	if dummy ~= nil then
	    dummy:SetAbsOrigin(target)
	    dummy:SetDayTimeVisionRange(vision)
	    dummy:SetNightTimeVisionRange(vision)
	    dummy:AddNewModifier(dummy, nil, "modifier_phased", {})
        dummy:AddInvul()
	    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration+0.03})
	    Timers:CreateTimer(duration,function()
	        if not dummy:IsNull() then
	          dummy:ForceKill(true)
	          UTIL_Remove(dummy)
	        end
	    end)  
 	end
  	return dummy
end

function mina_nuclear_strike:CreateBomb(caster)
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local pos = caster:GetAbsOrigin()
	local bomb_pos = pos+RandomVector(RandomInt(200,475))
	local ability = self
	local unit = self:FastDummy(pos,caster:GetTeam(),2.4,250)
	local dunit = self:FastDummy(bomb_pos,caster:GetTeam(),0.1,0)

	local r = RandomInt(1, 10)

	unit.bomb_type = DAMAGE_TYPE_MAGICAL
	unit.bomb_particle = "particles/units/heroes/hero_gob_squad/clearance_sale_bomb.vpcf"
	unit.explosion_particle = "particles/units/heroes/hero_gob_squad/clearance_sale_explosion.vpcf"
	unit.explosion_sound = "Hero_TemplarAssassin.Trap.Explode"

	if r <= 3 then
		unit.bomb_type = DAMAGE_TYPE_PHYSICAL
		unit.bomb_particle = "particles/units/heroes/hero_gob_squad/clearance_sale_bomb_physical.vpcf"
		unit.explosion_particle = "particles/units/heroes/hero_gob_squad/clearance_sale_explosion_physical.vpcf"
		unit.explosion_sound = "Hero_Techies.RemoteMine.Detonate"
	end
	if r >= 9 then
		unit.bomb_type = DAMAGE_TYPE_PURE
		unit.bomb_particle = "particles/units/heroes/hero_gob_squad/clearance_sale_bomb_pure.vpcf"
		unit.explosion_particle = "particles/units/heroes/hero_gob_squad/clearance_sale_explosion_pure.vpcf"
		unit.explosion_sound = "Hero_Techies.StasisTrap.Stun"
	end

	local bp = ParticleManager:CreateParticle(unit.bomb_particle, PATTACH_ABSORIGIN_FOLLOW, unit)

	local distance = unit:GetRangeToUnit(dunit)
	local direction = (unit:GetAbsOrigin() - bomb_pos):Normalized()

	Physics:Unit(unit)
  	unit:SetPhysicsFriction(0)
  	unit:PreventDI(true)
  	unit:FollowNavMesh(false)
  	unit:SetAutoUnstuck(false)
  	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
  	unit:SetPhysicsVelocity(direction * distance)
  	unit:AddPhysicsVelocity(Vector(0,0,725))
  	unit:SetPhysicsAcceleration(Vector(0,0,-(1800)))
  	unit:EmitSound("Hero_ChaosKnight.idle_throw")

	Timers:CreateTimer(1,function()
		local p = ParticleManager:CreateParticle(unit.explosion_particle, PATTACH_ABSORIGIN_FOLLOW, unit)
		ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0))
		ParticleManager:DestroyParticle(bp,false)
		unit:EmitSound(unit.explosion_sound)
		ScreenShake(unit:GetCenter(), 1000, 3, 0.50, 1500, 0, true)

		local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
      	unit:GetCenter(),
     	 nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

		for k,v in pairs(enemy_found) do
			ApplyDamage({ victim = v, attacker = caster, damage = damage, damage_type = unit.bomb_type })
			if unit.bomb_type == DAMAGE_TYPE_PURE then
				v:AddNewModifier(caster, self, "modifier_birzha_stunned", {Duration=0.60})
			end
			if unit.bomb_type == DAMAGE_TYPE_PHYSICAL then
				v:AddNewModifier(caster, ability, "modifier_mina_nuclear_strike_slow", {Duration=2})
			end
		end
	end)
end

modifier_mina_nuclear_strike = class({})

function modifier_mina_nuclear_strike:IsPurgable()
	return false
end

function modifier_mina_nuclear_strike:OnCreated()
	if IsServer() then
		local interval = self:GetAbility():GetSpecialValueFor("interval") + self:GetCaster():FindTalentValue("special_bonus_birzha_mina_3")
		self:StartIntervalThink(interval)
        self:OnIntervalThink()
	end
end

function modifier_mina_nuclear_strike:OnIntervalThink()
	if IsServer() then
		self:GetAbility():CreateBomb(self:GetParent())
	end
end

modifier_mina_nuclear_strike_slow = class({})

function modifier_mina_nuclear_strike_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_mina_nuclear_strike_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_mina_nuclear_strike_slow:IsPurgable()
	return false
end



















