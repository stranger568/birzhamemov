LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

haku_needle = class({})

function haku_needle:CastFilterResultTarget( hTarget )
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

function haku_needle:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function haku_needle:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function haku_needle:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function haku_needle:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/haku_dagger.vpcf",
		iMoveSpeed = 1400,
		bReplaceExisting = false,
		bProvidesVision = true,
	}

	local flag = 0

	if self:GetCaster():HasShard() then
		flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	ProjectileManager:CreateTrackingProjectile(info)

	if self:GetCaster():HasTalent("special_bonus_birzha_haku_4") then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_UNITS_EVERYWHERE, false )
		local secondary_knives_thrown = 0
		for _, enemy in pairs(enemies) do
			if enemy ~= target then
				info.Target = enemy
				ProjectileManager:CreateTrackingProjectile(info)
				secondary_knives_thrown = secondary_knives_thrown + 1
			end
			if secondary_knives_thrown >= 1 then
				break
			end
		end
	end
	
	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")
end

function haku_needle:OnProjectileHit( hTarget, vLocation )
	local target = hTarget
	if target==nil then return end
	if target:TriggerSpellAbsorb( self ) then return end
	if target:IsAttackImmune() then return end

	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local damage_base = self:GetSpecialValueFor("damage_base")
	local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetSpecialValueFor("damage")
	local end_damage = damage + damage_base

	local effect_cast = ParticleManager:CreateParticle( "particles/haku_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt(effect_cast,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, (self:GetCaster():GetOrigin()-target:GetOrigin()):Normalized() )
	ParticleManager:SetParticleControlEnt( effect_cast, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	self:GetCaster():PerformAttack( target, true, true, true, false, false, true, true )
	ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = end_damage, ability=nil, damage_type = DAMAGE_TYPE_PHYSICAL })
	target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
	target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration * (1-target:GetStatusResistance())} )
	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
end

LinkLuaModifier( "modifier_marci_companion_run_custom", "abilities/heroes/haku", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_arc_marci", "abilities/heroes/haku", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_marci_companion_run_custom_debuff_frost", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE )

haku_jump = class({})

function haku_jump:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_6")
end

function haku_jump:DealDamage()
	if not IsServer() then return end
	local damage = self:GetSpecialValueFor("impact_damage")
	local radius = self:GetSpecialValueFor("landing_radius")

	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local damageTable = { attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, }
		
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
		if self:GetCaster():HasModifier("modifier_haku_frost_attack") then
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_marci_companion_run_custom_debuff_frost", {duration = (self:GetSpecialValueFor("root_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_2") ) * (1-enemy:GetStatusResistance())})
		end
	end
	if self:GetCaster():HasModifier("modifier_haku_frost_attack") then
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden_persona/cm_persona_nova.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius, radius, radius) )
		EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin(), "Hero_Crystal.CrystalNova", self:GetCaster() )
	end

	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_rebound_bounce_impact.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 9, Vector(radius, radius, radius) )
	ParticleManager:SetParticleControl( effect_cast, 10, self:GetCaster():GetAbsOrigin() )
	ParticleManager:DestroyParticle(effect_cast, false)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin(), "Hero_Marci.Rebound.Impact", self:GetCaster() )
end

function haku_jump:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end
	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end
	self.targetcast = hTarget
	return UF_SUCCESS
end

function haku_jump:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return ""
end

function haku_jump:OnVectorCastStart(vStartLocation, vDirection)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self.targetcast
	local speed = self:GetSpecialValueFor( "move_speed" )
	local info = { Target = target, Source = caster, Ability = self, iMoveSpeed = speed, bDodgeable = false, }
	local proj = ProjectileManager:CreateTrackingProjectile(info)

	local point = self:GetVector2Position()
	local point_check = self:GetTargetPositionCheck()
	local jump_heh = false
	local sravnenie = ((point_check-point):Length2D())

	print("whgat")

	sravnenie = math.abs(sravnenie)

	if sravnenie<= 50 then
		jump_heh = true
	end

	self.modifier = caster:AddNewModifier( caster, self, "modifier_marci_companion_run_custom", { proj = tostring(proj), target = target:entindex(), point_x = point.x, point_y = point.y, point_z = point.z, jump_heh = jump_heh } )
end

function haku_jump:OnProjectileHit( target, location )
	if not self.modifier:IsNull() then
		if not target then
			self.modifier.interrupted = true
		end
		self.modifier:Destroy()
	end
end

-- модификатор полета до цели

modifier_marci_companion_run_custom = class({})

function modifier_marci_companion_run_custom:IsHidden()
	return true
end

function modifier_marci_companion_run_custom:IsDebuff()
	return false
end

function modifier_marci_companion_run_custom:IsPurgable()
	return false
end

function modifier_marci_companion_run_custom:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.duration = 0.5
	self.height = self:GetAbility():GetSpecialValueFor( "min_height_above_highest" )
	self.min_distance = self:GetAbility():GetSpecialValueFor( "min_jump_distance" )
	self.max_distance = self:GetAbility():GetSpecialValueFor( "max_jump_distance" )
	self.radius = self:GetAbility():GetSpecialValueFor( "landing_radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "impact_damage" )

	if not IsServer() then return end

	self.projectile = tonumber(kv.proj)
	self.target = EntIndexToHScript( kv.target )
	self.point = Vector( kv.point_x, kv.point_y, kv.point_z )
	self.targetpos = self.target:GetOrigin()
	self.distancethreshold = 1000
	self.jump_heh = kv.jump_heh
	self.start_direction = self.targetpos - self:GetParent():GetAbsOrigin()

	if not self:ApplyHorizontalMotionController() then
		self.interrupted = true
		self:Destroy()
	end

	local speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self:PlayEffects1( self.parent, speed )

	local origin =  self:GetParent():GetOrigin()
	self.direction = self.point - self.target:GetAbsOrigin()
	self.distance = self.direction:Length2D()

	if self.jump_heh == 1 then
		self.direction = self.start_direction
	end

	self.direction.z = 0
	self.direction = self.direction:Normalized()

	self.distance = math.min(math.max(self.distance,self.min_distance),self.max_distance)

	self:PlayEffects3( self.target:GetAbsOrigin() + self.distance * self.direction, self.radius )
end

function modifier_marci_companion_run_custom:OnDestroy()
	if not IsServer() then return end	
	self:GetParent():RemoveHorizontalMotionController( self )
	self:GetParent():FadeGesture(ACT_DOTA_RUN)
	self:GetParent():FadeGesture(ACT_DOTA_ATTACK)

	if self.interrupted then return end

	local origin =  self:GetParent():GetOrigin()

	self:GetParent():SetForwardVector( self.direction )


	local arc = self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_generic_arc_marci",{ dir_x = self.direction.x,dir_y = self.direction.y,duration = self.duration,distance = self.distance,height = self.height,fix_end = false,isStun = true,isForward = true,activity = ACT_DOTA_ATTACK})

	local caster = self:GetParent()

	arc:SetEndCallback( function( interrupted )
		self.ability:DealDamage()
	end)
	self:PlayEffects2( self.parent, arc, allied )
end

function modifier_marci_companion_run_custom:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_marci_companion_run_custom:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_marci_companion_run_custom:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_marci_companion_run_custom:UpdateHorizontalMotion( me, dt )
	local targetpos = self.target:GetOrigin()
	if (targetpos - self.targetpos):Length2D()>self.distancethreshold then
		self.dodged = true
		self.interrupted = true
		return
	end
	self.targetpos = targetpos
	local loc = ProjectileManager:GetTrackingProjectileLocation( self.projectile )
	me:SetOrigin( GetGroundPosition( loc, me ) )
	me:FaceTowards( self.target:GetOrigin() )
end

function modifier_marci_companion_run_custom:OnHorizontalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

function modifier_marci_companion_run_custom:PlayEffects1( caster, speed )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_rebound_charge_projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, 0, 0 ) )
	self:AddParticle( effect_cast, false, false, -1, false, false)
	caster:EmitSound("Hero_Marci.Rebound.Cast")
end

function modifier_marci_companion_run_custom:PlayEffects2( caster, buff )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_rebound_bounce.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	buff:AddParticle( effect_cast, false, false, -1, false, false )
	caster:EmitSound("Hero_Marci.Rebound.Leap")
end

function modifier_marci_companion_run_custom:PlayEffects3( center, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_rebound_landing_zone.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, center )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius, radius, radius) )
	ParticleManager:DestroyParticle(effect_cast, false)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_marci_companion_run_custom:PlayEffects4( center, origin, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_rebound_bounce_impact.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, center )
	ParticleManager:SetParticleControl( effect_cast, 1, origin )
	ParticleManager:SetParticleControl( effect_cast, 9, Vector(radius, radius, radius) )
	ParticleManager:SetParticleControl( effect_cast, 10, center )
	ParticleManager:DestroyParticle(effect_cast, false)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( center, "Hero_Marci.Rebound.Impact", self.parent )
end

modifier_generic_arc_marci = class({})

function modifier_generic_arc_marci:IsHidden()
	return true
end

function modifier_generic_arc_marci:IsDebuff()
	return false
end

function modifier_generic_arc_marci:IsStunDebuff()
	return false
end

function modifier_generic_arc_marci:IsPurgable()
	return false
end

function modifier_generic_arc_marci:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_arc_marci:OnCreated( kv )
	if not IsServer() then return end
	self.interrupted = false
	self:SetJumpParameters( kv )
	self:Jump()
end

function modifier_generic_arc_marci:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_arc_marci:OnDestroy()
	if not IsServer() then return end

	local dir = self:GetParent():GetForwardVector()
    dir.z = 0
    self:GetParent():SetForwardVector(dir)
    self:GetParent():FaceTowards(self:GetParent():GetAbsOrigin() + dir*10)

    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)

	local pos = self:GetParent():GetOrigin()
	self:GetParent():RemoveHorizontalMotionController( self )
	self:GetParent():RemoveVerticalMotionController( self )
	if self.end_offset~=0 then
		self:GetParent():SetOrigin( pos )
	end
	if self.endCallback then
		self.endCallback( self.interrupted )
	end
end

function modifier_generic_arc_marci:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}
	if self:GetStackCount()>0 then
		table.insert( funcs, MODIFIER_PROPERTY_OVERRIDE_ANIMATION )
	end
	return funcs
end

function modifier_generic_arc_marci:GetModifierDisableTurning()
	if not self.isForward then return end
	return 1
end

function modifier_generic_arc_marci:GetOverrideAnimation()
	return self:GetStackCount()
end

function modifier_generic_arc_marci:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.isStun or false,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

function modifier_generic_arc_marci:UpdateHorizontalMotion( me, dt )
	if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
	local pos = me:GetOrigin() + self.direction * self.speed * 0.84 * dt 
	me:SetOrigin( pos )
end

function modifier_generic_arc_marci:UpdateVerticalMotion( me, dt )
	if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
	local pos = me:GetOrigin()
	local time = self:GetElapsedTime()
	local height = pos.z
	local speed = self:GetVerticalSpeed( time )
	pos.z = height + speed * dt
	me:SetOrigin( pos )
	if not self.fix_duration then
		local ground = GetGroundHeight( pos, me ) + self.end_offset
		if pos.z <= ground then
			pos.z = ground
			me:SetOrigin( pos )
			self:Destroy()
		end
	end
end

function modifier_generic_arc_marci:OnHorizontalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

function modifier_generic_arc_marci:OnVerticalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

function modifier_generic_arc_marci:SetJumpParameters( kv )
	self.parent = self:GetParent()
	self.fix_end = true
	self.fix_duration = true
	self.fix_height = true
	if kv.fix_end then
		self.fix_end = kv.fix_end==1
	end
	if kv.fix_duration then
		self.fix_duration = kv.fix_duration==1
	end
	if kv.fix_height then
		self.fix_height = kv.fix_height==1
	end
	self.isStun = kv.isStun==1
	self.isRestricted = kv.isRestricted==1
	self.isForward = kv.isForward==1
	self.activity = kv.activity or 0
	self:SetStackCount( self.activity )
	if kv.target_x and kv.target_y then
		local origin = self.parent:GetOrigin()
		local dir = Vector( kv.target_x, kv.target_y, 0 ) - origin
		dir.z = 0
		dir = dir:Normalized()
		self.direction = dir
	end
	if kv.dir_x and kv.dir_y then
		self.direction = Vector( kv.dir_x, kv.dir_y, 0 ):Normalized()
	end
	if not self.direction then
		self.direction = self.parent:GetForwardVector()
	end
	self.duration = kv.duration
	self.distance = kv.distance
	self.speed = kv.speed
	if not self.duration then
		self.duration = self.distance/self.speed
	end
	if not self.distance then
		self.speed = self.speed or 0
		self.distance = self.speed*self.duration
	end
	if not self.speed then
		self.distance = self.distance or 0
		self.speed = self.distance/self.duration
	end

	print(self.speed, self.distance, self.duration)

	self.height = kv.height or 0
	self.start_offset = kv.start_offset or 0
	self.end_offset = kv.end_offset or 0
	local pos_start = self.parent:GetOrigin()
	local pos_end = pos_start + self.direction * self.distance
	local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
	local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
	local height_max
	if not self.fix_height then
		self.height = math.min( self.height, self.distance/4 )
	end

	if self.fix_end then
		height_end = height_start
		height_max = height_start + self.height
	else
		local tempmin, tempmax = height_start, height_end
		if tempmin>tempmax then
			tempmin,tempmax = tempmax, tempmin
		end
		local delta = (tempmax-tempmin)*2/3

		height_max = tempmin + delta + self.height
	end

	if not self.fix_duration then
		self:SetDuration( -1, false )
	else
		self:SetDuration( self.duration, true )
	end

	self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_generic_arc_marci:Jump()
	if self.distance>0 then
		if not self:ApplyHorizontalMotionController() then
			self.interrupted = true
			self:Destroy()
		end
	end

	if self.height>0 then
		if not self:ApplyVerticalMotionController() then
			self.interrupted = true
			self:Destroy()
		end
	end
end

function modifier_generic_arc_marci:InitVerticalArc( height_start, height_max, height_end, duration )
	local height_end = height_end - height_start
	local height_max = height_max - height_start

	if height_max<height_end then
		height_max = height_end+0.01
	end

	if height_max<=0 then
		height_max = 0.01
	end

	local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
	self.const1 = 4*height_max*duration_end/duration
	self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_generic_arc_marci:GetVerticalPos( time )
	return self.const1*time - self.const2*time*time
end

function modifier_generic_arc_marci:GetVerticalSpeed( time )
	return self.const1 - 2*self.const2*time
end

function modifier_generic_arc_marci:SetEndCallback( func )
	self.endCallback = func
end

modifier_marci_companion_run_custom_debuff_frost = class({})

function modifier_marci_companion_run_custom_debuff_frost:CheckState()
	return 
	{
		[MODIFIER_STATE_ROOTED] = true
	}
end

function modifier_marci_companion_run_custom_debuff_frost:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_marci_companion_run_custom_debuff_frost:GetEffectAttachType() 
	return PATTACH_ABSORIGIN_FOLLOW 
end

LinkLuaModifier( "modifier_haku_frost_attack", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_haku_frost_attack_buff", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_haku_frost_attack_debuff", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE )

haku_frost_attack = class({})

function haku_frost_attack:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_haku_frost_attack", {duration = duration})
	self:GetCaster():EmitSound("Hero_Ancient_Apparition.ColdFeetCast")
end

modifier_haku_frost_attack = class({})

function modifier_haku_frost_attack:AllowIllusionDuplicate() return true end
function modifier_haku_frost_attack:IsPurgable() return false end

function modifier_haku_frost_attack:OnCreated()
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
	if not IsServer() then return end
	self.attack_count = 0
	self.every_attack = self:GetAbility():GetSpecialValueFor("every_attack")
	self.bonus_attack = self:GetAbility():GetSpecialValueFor("bonus_attack")
	self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function modifier_haku_frost_attack:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveModifierByName("modifier_haku_frost_attack_buff")
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function modifier_haku_frost_attack:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_haku_frost_attack:GetModifierAttackRangeOverride()
	return 150
end

function modifier_haku_frost_attack:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_haku_frost_attack:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end

	params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_haku_frost_attack_debuff", {duration = self.slow_duration * (1-params.target:GetStatusResistance()) })

	if params.attacker:IsIllusion() then return end

	if not params.attacker:HasModifier("modifier_haku_frost_attack_buff") then
		self.attack_count = self.attack_count + 1
	end

	if self.attack_count >= self.every_attack then
		self.attack_count = 0
		self:GetParent():EmitSound("Hero_Ancient_Apparition.ColdFeetTick")
		local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_haku_frost_attack_buff", {})
		if modifier then
			modifier:SetStackCount(self.bonus_attack)
		end
	end
end

function modifier_haku_frost_attack:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_haku_frost_attack:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_haku_frost_attack_debuff = class({})

function modifier_haku_frost_attack_debuff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_haku_frost_attack_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_slow")
end

function modifier_haku_frost_attack_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_cold_embrace.vpcf"
end

function modifier_haku_frost_attack_debuff:StatusEffectPriority()
	return 10
end

function modifier_haku_frost_attack_debuff:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch.vpcf"
end

function modifier_haku_frost_attack_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_haku_frost_attack_buff = class({})

function modifier_haku_frost_attack_buff:IsPurgable() return false end

function modifier_haku_frost_attack_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_haku_frost_attack_buff:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_haku_frost_attack_buff:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	self:GetParent():EmitSound("Hero_Ancient_Apparition.ProjectileImpact")
	self:SetStackCount(self:GetStackCount() - 1)
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_haku_frost_attack_buff:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end

function modifier_haku_frost_attack_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_haku_mask", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_mask = class({}) 

function haku_mask:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function haku_mask:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function haku_mask:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("ui.inv_equip_jug")
end

function haku_mask:OnChannelFinish( bInterrupted )
	if bInterrupted then
		return
	end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_haku_mask", {} )
end

modifier_haku_mask = class({})

function modifier_haku_mask:IsHidden()
    return true
end

function modifier_haku_mask:IsPurgable()
    return false
end

function modifier_haku_mask:RemoveOnDeath()
    return false
end

function modifier_haku_mask:OnCreated()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("haku_needle", "haku_needle_heal", false, true)
    self:GetParent():SwapAbilities("haku_jump", "haku_eyes", false, true)
    self:GetParent():SwapAbilities("haku_frost_attack", "haku_aura", false, true)
    self:GetParent():SwapAbilities("haku_zerkala", "haku_help", false, true)
    self:GetParent():FindAbilityByName("haku_zerkalo"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(true)
    self:GetAbility():SetActivated(false)
    self:GetParent():SetPrimaryAttribute(2)
    self:GetCaster():SetModel("models/haku/haku.vmdl")
    self:GetCaster():SetOriginalModel("models/haku/haku.vmdl")
end

function modifier_haku_mask:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("haku_needle_heal", "haku_needle", false, true)
    self:GetParent():SwapAbilities("haku_eyes", "haku_jump", false, true)
    self:GetParent():SwapAbilities("haku_aura", "haku_frost_attack", false, true)
    self:GetParent():SwapAbilities("haku_help", "haku_zerkala", false, true)
    self:GetParent():FindAbilityByName("haku_zerkalo"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(false)
    self:GetAbility():SetActivated(true)
    self:GetParent():SetPrimaryAttribute(1)
    self:GetCaster():SetModel("models/haku/haku_mask.vmdl")
    self:GetCaster():SetOriginalModel("models/haku/haku_mask.vmdl")
end

LinkLuaModifier("modifier_haku_zerkala_damage", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_zerkala_radius", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_zerkala_wall", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_zerkala_parent", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_zerkala = class({}) 

function haku_zerkala:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
	self.modifier = CreateModifierThinker( self:GetCaster(), self, "modifier_haku_zerkala_radius", {duration = duration}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
	self:GetCaster():EmitSound("HakuMirror")
end

modifier_haku_zerkala_radius = class({})

function modifier_haku_zerkala_radius:IsHidden()
    return true
end

function modifier_haku_zerkala_radius:OnCreated( kv )
    self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    self.thinkers = {}
    self.phase_delay = true
    self:StartIntervalThink( 0 )
end

function modifier_haku_zerkala_radius:OnDestroy()
    if not IsServer() then return end
    local modifiers = {}
    for k,v in pairs(self:GetParent():FindAllModifiers()) do
        modifiers[k] = v
    end
    for k,v in pairs(modifiers) do
        v:Destroy()
    end
    UTIL_Remove( self:GetParent() ) 
end

function modifier_haku_zerkala_radius:OnIntervalThink()
    if self.phase_delay then
        self.phase_delay = false
        AddFOWViewer( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.radius, self.duration, false)
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_haku_zerkala_wall", {} )
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_haku_zerkala_damage", {} )
        self:StartIntervalThink( self.duration )
        self.phase_duration = true
        return
    end
    if self.phase_duration then
        self:Destroy()
        return
    end
end

modifier_haku_zerkala_wall = class({})

function modifier_haku_zerkala_wall:IsHidden()
    return true
end

function modifier_haku_zerkala_wall:IsDebuff()
    return true
end

function modifier_haku_zerkala_wall:IsPurgable()
    return false
end

function modifier_haku_zerkala_wall:OnCreated( kv )
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.width = 50
    self.parent = self:GetParent()
    self.twice_width = self.width*2
    self.aura_radius = self.radius + self.twice_width
    self.MAX_SPEED = 550
    self.MIN_SPEED = 1
    self.owner = kv.isProvidedByAura~=1
    if not self.owner then
        self.aura_origin = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
    else
        self.aura_origin = self:GetParent():GetOrigin()
    end
end

function modifier_haku_zerkala_wall:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
    return funcs
end

function modifier_haku_zerkala_wall:CheckState()
	return 
	{
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true
	}
end

function modifier_haku_zerkala_wall:GetModifierMoveSpeed_Limit( params )
    if not IsServer() then return end
    if self.owner then return 0 end

    local parent_vector = self.parent:GetOrigin()-self.aura_origin
    local parent_direction = parent_vector:Normalized()

    local actual_distance = parent_vector:Length2D()
    local wall_distance = actual_distance-self.radius
    local isInside = (wall_distance)<0
    wall_distance = math.min( math.abs( wall_distance ), self.twice_width )
    wall_distance = math.max( wall_distance, self.width ) - self.width

    local parent_angle = 0
    if isInside then
        parent_angle = VectorToAngles(parent_direction).y
    else
        parent_angle = VectorToAngles(-parent_direction).y
    end
    local unit_angle = self:GetParent():GetAnglesAsVector().y
    local wall_angle = math.abs( AngleDiff( parent_angle, unit_angle ) )

    local limit = 0
    if wall_angle>90 then
        limit = 0
    else
        limit = self:Interpolate( wall_distance/self.width, self.MIN_SPEED, self.MAX_SPEED )
    end

    return limit
end

function modifier_haku_zerkala_wall:Interpolate( value, min, max )
    return value*(max-min) + min
end

function modifier_haku_zerkala_wall:IsAura()
    return self.owner
end

function modifier_haku_zerkala_wall:GetModifierAura()
    return "modifier_haku_zerkala_wall"
end

function modifier_haku_zerkala_wall:GetAuraRadius()
    return self.aura_radius
end

function modifier_haku_zerkala_wall:GetAuraDuration()
    return 0.3
end

function modifier_haku_zerkala_wall:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_haku_zerkala_wall:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_haku_zerkala_wall:GetAuraSearchFlags()
    return 0
end

function modifier_haku_zerkala_wall:GetAuraEntityReject( unit )
    if not IsServer() then return end
    return false
end

modifier_haku_zerkala_damage = class({})

function modifier_haku_zerkala_damage:IsHidden() return true end
function modifier_haku_zerkala_damage:IsPurgable() return false end

function modifier_haku_zerkala_damage:OnCreated()
	if not IsServer() then return end
	self.mirrors = {}
	local caster = self:GetAbility():GetCaster()
	local pos = self:GetParent():GetAbsOrigin()
	local duration = self:GetDuration()-0.05
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local origin = self:GetParent():GetOrigin()
	local angle = 0
	local vector = origin + Vector(600,0,0)
	local zero = Vector(0,0,0)
	local one = Vector(1,0,0)
	local count = 18
	local angle_diff = 360/count

	for i=0, 17 do
		local location = RotatePosition( origin, QAngle( 0, angle_diff*i, 0 ), vector )
		local facing = RotatePosition( zero, QAngle( 0, 200+angle_diff*i, 0 ), one )
        local zerkalo = CreateUnitByName( "npc_dota_zerkalo", location, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
        zerkalo:SetForwardVector( facing )
        zerkalo:FaceTowards(self:GetParent():GetAbsOrigin())
        zerkalo:AddNewModifier(self:GetCaster(), self, "modifier_haku_zerkala_parent", {})
        ResolveNPCPositions( location, 64.0 )
        table.insert(self.mirrors, zerkalo)
	end
	if self:GetCaster():HasScepter() then
		self:StartIntervalThink(0.25)
		return
	end
	self:StartIntervalThink(0.5)
end

function modifier_haku_zerkala_damage:OnIntervalThink()
	if not IsServer() then return end
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,enemy in pairs(enemies) do
		local from_zerkalo = self.mirrors[RandomInt(1, #self.mirrors)]
		if from_zerkalo and not from_zerkalo:IsNull() then
			local info = 
			{
				Target = enemy,
				Source = from_zerkalo,
				Ability = self:GetAbility(),	
				EffectName = "particles/haku_dagger.vpcf",
				iMoveSpeed = 1200,
				bReplaceExisting = false,
				bProvidesVision = true,
			}
			ProjectileManager:CreateTrackingProjectile(info)
		end
	end
end

function modifier_haku_zerkala_damage:OnDestroy()
    if not IsServer() then return end
    for k,v in pairs(self.mirrors) do
       	UTIL_Remove( v ) 
    end
end

modifier_haku_zerkala_parent = class({})

function modifier_haku_zerkala_parent:IsHidden()
    return true
end

function modifier_haku_zerkala_parent:RemoveOnDeath() return false end
function modifier_haku_zerkala_parent:IsPurgable() return false end

function modifier_haku_zerkala_parent:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
    return decFuncs
end

function modifier_haku_zerkala_parent:GetModifierInvisibilityLevel()
	return 1
end

function modifier_haku_zerkala_parent:GetVisualZDelta()
    return 150
end

function modifier_haku_zerkala_parent:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
    }
end

function modifier_haku_zerkala_parent:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_haku_zerkala_parent:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_haku_zerkala_parent:GetAbsoluteNoDamagePhysical()
    return 1
end

LinkLuaModifier("modifier_haku_zerkalo_parent", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_zerkalo = class({}) 

function haku_zerkalo:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    if self:GetCaster():HasModifier("modifier_haku_zerkalo_parent") then
    	behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end
    return behavior
end

function haku_zerkalo:GetCastRange(location, target)
	if self:GetCaster():FindAbilityByName("haku_zerkala") then
    	if self:GetCaster():HasModifier("modifier_haku_zerkalo_parent") then
        	return 9999999
        end
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function haku_zerkalo:OnAbilityPhaseStart()
    self.target = self:GetCursorTarget()
    if self.target:GetUnitName() == "npc_dota_zerkalo" then return true end
    return false
end

function haku_zerkalo:OnSpellStart()
    if not IsServer() then return end
    local modifier_ls = self:GetCaster():FindModifierByName("modifier_haku_zerkalo_parent")
	if self:GetCaster():HasModifier("modifier_haku_zerkalo_parent") then
	    if modifier_ls and self.effect then
	    	ParticleManager:DestroyParticle(self.effect, true)
	    end
	    if self.target then
	    	if self.target == modifier_ls.target_ent then
	    		if modifier_ls and not modifier_ls:IsNull() then
	    			modifier_ls:Destroy()
	    		end
	    	else
	    		modifier_ls.target_ent = self.target
    			self.effect = ParticleManager:CreateParticleForTeam(
				"particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf",
				PATTACH_RENDERORIGIN_FOLLOW,
				self.target,
				self:GetCaster():GetTeamNumber()
				)

				ParticleManager:SetParticleControl( self.effect, 15, Vector( 35, 168, 192 ) )
				ParticleManager:SetParticleControl( self.effect, 16, Vector( 1, 0, 0 ) )
	    	end
	    end
	    return
	end
    if not self.target then
        return
    end
    local target = self.target
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_haku_zerkalo_parent", {target_ent = target:entindex()})
	self.effect = ParticleManager:CreateParticleForTeam(
	"particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf",
	PATTACH_RENDERORIGIN_FOLLOW,
	target,
	self:GetCaster():GetTeamNumber()
	)

	ParticleManager:SetParticleControl( self.effect, 15, Vector( 35, 168, 192 ) )
	ParticleManager:SetParticleControl( self.effect, 16, Vector( 1, 0, 0 ) )
end

modifier_haku_zerkalo_parent = class({})

function modifier_haku_zerkalo_parent:IsPurgable() return false end

function modifier_haku_zerkalo_parent:OnCreated(params)
    if not IsServer() then return end
    self.target_ent = EntIndexToHScript(params.target_ent)
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(FrameTime())
    self:GetCaster():FindAbilityByName("haku_needle"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_jump"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_frost_attack"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_zerkala"):SetHidden(true)
end

function modifier_haku_zerkalo_parent:OnIntervalThink()
    if not IsServer() then return end
    if self.target_ent:IsNull() then
		if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    self:GetParent():SetAbsOrigin(self.target_ent:GetAbsOrigin())
end

function modifier_haku_zerkalo_parent:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("HakuQiut")
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
    self:GetParent():RemoveNoDraw()
    self:GetCaster():FindAbilityByName("haku_needle"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_jump"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_frost_attack"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_zerkala"):SetHidden(false)
end

function modifier_haku_zerkalo_parent:CheckState(keys)
    if not IsServer() then return end
    return 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
end

function haku_zerkala:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target==nil then return end
    if target:IsAttackImmune() then return end
    local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * (self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_8"))
    self:GetCaster():PerformAttack( target, true, true, true, false, false, true, true )
	ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage, ability=nil, damage_type = DAMAGE_TYPE_PHYSICAL })
	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
end

LinkLuaModifier("modifier_haku_needle_heal", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_needle_heal = class({}) 

function haku_needle_heal:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_7")
end

function haku_needle_heal:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function haku_needle_heal:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function haku_needle_heal:GetChannelTime()
    return self:GetSpecialValueFor("duration")
end

function haku_needle_heal:OnSpellStart() 
	if not IsServer() then return end
    self.target = self:GetCursorTarget()
    local duration = self:GetChannelTime()
    if self.target == nil then
        return
    end
    self:GetCaster():SetForwardVector(self.target:GetForwardVector())
    self.modifier_caster = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_haku_needle_heal", { duration = self:GetChannelTime() } )
end

function haku_needle_heal:OnChannelFinish( bInterrupted )
	if self.modifier_caster and not self.modifier_caster:IsNull() then
    	self.modifier_caster:Destroy()
	end
end

modifier_haku_needle_heal = class({}) 

function modifier_haku_needle_heal:OnCreated()
    if not IsServer() then return end
    self:OnIntervalThink()
    self:StartIntervalThink(0.5)
end

function modifier_haku_needle_heal:IsHidden()
    return true
end

function modifier_haku_needle_heal:IsPurgable()
    return false
end

function modifier_haku_needle_heal:OnIntervalThink()
	if not IsServer() then return end
	self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
    local info = 
    {
        Target = self:GetAbility().target,
        Source = self:GetCaster(),
        Ability = self:GetAbility(), 
        EffectName = "particles/haku_dagger.vpcf",
        iMoveSpeed = 1600,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionRadius = 25,
        bDodgeable = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()
    }
    ProjectileManager:CreateTrackingProjectile(info)
    self:GetCaster():EmitSound("HakuNeedleheal")
    self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
end

function haku_needle_heal:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target==nil then return end
    local heal = self:GetSpecialValueFor( "heal" )
    if self:GetCaster():HasTalent("special_bonus_birzha_haku_1") then
    	heal = heal + self:GetCaster():GetIntellect()
    end
    target:Heal(heal, self)
    target:Purge(false, true, false, false, false)
    target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
end

haku_eyes = class({})

function haku_eyes:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function haku_eyes:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

	local flag = 0
	if self:GetCaster():HasScepter() then
		flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, self:GetSpecialValueFor( "radius" ), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_CLOSEST, false )

    for _,enemy in pairs(enemies) do
	    local vector = self:GetCaster():GetOrigin()-enemy:GetOrigin()
	    local center_angle = VectorToAngles( vector ).y
	    local facing_angle = VectorToAngles( enemy:GetForwardVector() ).y
	    local distance = vector:Length2D()
		local facing = ( math.abs( AngleDiff(center_angle,facing_angle) ) < 85 )
		if facing then
			enemy:AddNewModifier( caster, self, "modifier_birzha_stunned_purge", {duration = (  self:GetSpecialValueFor( "stun_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_3"  )  ) * (1-enemy:GetStatusResistance()) } )
			ApplyDamage({ victim = enemy, attacker = self:GetCaster(), damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():GetIntellect(), ability=self, damage_type = DAMAGE_TYPE_MAGICAL })
		end
	end

	caster:EmitSound("HakuStun")
end

LinkLuaModifier("modifier_haku_aura", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_aura_hero", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_aura = class({})

function haku_aura:GetIntrinsicModifierName() 
	return "modifier_haku_aura"
end

modifier_haku_aura = class({})

function modifier_haku_aura:IsAura() return true end
function modifier_haku_aura:IsAuraActiveOnDeath() return false end
function modifier_haku_aura:IsBuff() return true end
function modifier_haku_aura:IsHidden() return true end
function modifier_haku_aura:IsPermanent() return true end
function modifier_haku_aura:IsPurgable() return false end

function modifier_haku_aura:GetAuraRadius()
	if self:GetCaster():HasShard() then
		return -1
	end
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_haku_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_haku_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_haku_aura:GetModifierAura()
	if not self:GetParent():HasModifier("modifier_haku_mask") then return end
	return "modifier_haku_aura_hero"
end

modifier_haku_aura_hero = class({})

function modifier_haku_aura_hero:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_haku_aura_hero:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_haku_aura_hero:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, nil)
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

LinkLuaModifier("modifier_haku_help", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_help = class({}) 

function haku_help:OnSpellStart() 
	if not IsServer() then return end
    self.target = self:GetCursorTarget()
    self.target:AddNewModifier( self:GetCaster(), self, "modifier_haku_help", { duration = self:GetSpecialValueFor("duration") } )
    self:GetCaster():EmitSound("HakuHelp")
end

modifier_haku_help = class({})

function modifier_haku_help:IsPurgable()
    return false
end

function modifier_haku_help:DeclareFunctions()
    local decFuncs = 
    {
    	MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return decFuncs
end

function modifier_haku_help:OnCreated()
    if not IsServer() then return end
    self:PlayEffects()
end

function modifier_haku_help:OnTakeDamage( params )
    if not IsServer() then return end
    if params.attacker == self:GetParent() then return end
    if params.unit ~= self:GetParent() then return end

    if self:GetParent():IsIllusion() then return end

    if self:GetParent():HasModifier("modifier_item_uebator_active") then
        return
    end
    
    if self:GetParent():HasModifier("modifier_item_aeon_disk_buff") then
        return
    end

    if not self:GetParent():HasModifier("modifier_item_uebator_cooldown") and self:GetParent():HasModifier("modifier_item_uebator") then
        return
    end

    for i = 0, 5 do 
        local item = self:GetParent():GetItemInSlot(i)
        if item then
            if item:GetName() == "item_aeon_disk" then
                if item:IsFullyCastable() then
                    return
                end
            end
        end        
    end

    if self:GetParent():GetHealth() <= 1 then
    	local heal = self:GetParent():GetMaxHealth() / 100 * (self:GetAbility():GetSpecialValueFor("heal") + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_5"))
        self:GetCaster():BirzhaTrueKill( self:GetAbility(), params.attacker )
        self:GetParent():Heal(heal, self:GetAbility())
        self:Destroy()         
    end
end

function modifier_haku_help:GetMinHealth()
    return 1
end

function modifier_haku_help:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/emperor_time.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(effect_cast,false,false, -1,false,false)
	local effect_cast_2 = ParticleManager:CreateParticle( "particles/devil_trigger22.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
	ParticleManager:SetParticleControlEnt(effect_cast_2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(effect_cast_2,false,false, -1,false,false)
end

