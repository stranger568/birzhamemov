LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier("modifier_serega_pirat_bike_cast", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_serega_pirat_bike_charge", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_serega_pirat_bike_debuff", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_BOTH)

serega_pirat_bike = class({})

function serega_pirat_bike:Precache(context)
    PrecacheResource("model", "models/pirat/serega.vmdl", context)
    PrecacheResource("model", "models/pirat/bike.vmdl", context)
    local particle_list = 
    {
        "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_strike_start.vpcf",
        "particles/pirat_bike_finder.vpcf",
        "particles/pirat/pirat_bike_chargeup.vpcf",
        "particles/pirat/pirat_bike_charge_active.vpcf",
        "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf",
        "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_strike_start.vpcf",
        "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_blur_active.vpcf",
        "particles/econ/events/fall_2021/radiance_owner_fall_2021.vpcf",
        "particles/generic_gameplay/generic_manaburn.vpcf",
        "particles/econ/events/fall_2021/radiance_fall_2021.vpcf",
        "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf",
        "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf",
        "particles/pirat/battlefuryeffect.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function serega_pirat_bike:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor( "chargeup_time" )
	local point = self:GetCursorPosition()
	
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_serega_pirat_bike_cast", { duration = duration } )
	
	local release_ability = self:GetCaster():FindAbilityByName( "serega_pirat_bike_release" )
	
	if release_ability then
		release_ability:UseResources( false, false, false, true )
	end

	self:GetCaster():EmitSound("pirat_bike")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_strike_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
end

function serega_pirat_bike:OnChargeFinish( interrupt, target )
	if not IsServer() then return end

	local caster = self:GetCaster()

	local max_duration = self:GetSpecialValueFor( "chargeup_time" )
	local max_distance = self:GetSpecialValueFor( "max_distance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_1")
	local speed = self:GetSpecialValueFor( "charge_speed" )

	local charge_duration = max_duration

	local mod = caster:FindModifierByName( "modifier_serega_pirat_bike_cast" )
	if mod then
		charge_duration = mod:GetElapsedTime()
		mod.charge_finish = true
		mod:Destroy()
	end

	local distance = max_distance * charge_duration/max_duration

	local duration = distance/speed

	if interrupt then return end

	caster:AddNewModifier( caster, self, "modifier_serega_pirat_bike_charge", { duration = duration } )
end

serega_pirat_bike_release = class({})

function serega_pirat_bike_release:OnSpellStart()
	local ability = self:GetCaster():FindAbilityByName("serega_pirat_bike")
	if ability then
		ability:OnChargeFinish( false )
	end
end

modifier_serega_pirat_bike_cast = class({})

function modifier_serega_pirat_bike_cast:IsPurgable()
	return false
end

function modifier_serega_pirat_bike_cast:OnCreated( kv )
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	self.max_time = self:GetAbility():GetSpecialValueFor( "chargeup_time" ) 

	if not IsServer() then return end
	self.anim_return = 0
	self.origin = self:GetParent():GetOrigin()
	self.charge_finish = false
	self.target_angle = self:GetParent():GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true

	self.time = (self:GetAbility():GetSpecialValueFor("max_distance") + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_1")) / self:GetAbility():GetSpecialValueFor( "charge_speed" ) 

	self:StartIntervalThink( FrameTime() )
	
	self:PlayEffects1()
	self:PlayEffects2()

	self:GetCaster():SwapAbilities( "serega_pirat_bike", "serega_pirat_bike_release", false, true )

	if self:GetParent().pirat_item_weapon and self:GetParent().pirat_item_offhand and self:GetParent().pirat_item_shoulder and self:GetParent().pirat_item_head and self:GetParent().pirat_item_belt and self:GetParent().pirat_item_arms and self:GetParent().pirat_item_armor then
		self:GetParent().pirat_item_weapon:Destroy()
		self:GetParent().pirat_item_offhand:Destroy()
		self:GetParent().pirat_item_shoulder:Destroy()
		self:GetParent().pirat_item_head:Destroy()
		self:GetParent().pirat_item_belt:Destroy()
		self:GetParent().pirat_item_arms:Destroy()
		self:GetParent().pirat_item_armor:Destroy()
	end
end

function modifier_serega_pirat_bike_cast:OnRemoved()
	if not IsServer() then return end

	self:GetParent().pirat_item_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_weapon/god_eater_weapon.vmdl" })
	self:GetParent().pirat_item_weapon:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_offhand = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_off_hand/god_eater_off_hand.vmdl" })
	self:GetParent().pirat_item_offhand:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_shoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_shoulder/god_eater_shoulder.vmdl" })
	self:GetParent().pirat_item_shoulder:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_head/god_eater_head.vmdl" })
	self:GetParent().pirat_item_head:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_belt/god_eater_belt.vmdl" })
	self:GetParent().pirat_item_belt:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_arms/god_eater_arms.vmdl" })
	self:GetParent().pirat_item_arms:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_armor/god_eater_armor.vmdl" })
	self:GetParent().pirat_item_armor:FollowEntity(self:GetParent(), true)

	self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)

	self:GetCaster():SwapAbilities( "serega_pirat_bike_release", "serega_pirat_bike", false, true )

	if not self.charge_finish then
		self:GetAbility():OnChargeFinish( false, self.target )
	end
end

function modifier_serega_pirat_bike_cast:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end

function modifier_serega_pirat_bike_cast:GetModifierModelChange()
	return "models/pirat/bike.vmdl"
end

function modifier_serega_pirat_bike_cast:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
		self:SetDirection( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetDirection( params.target:GetOrigin() )
	elseif
		params.order_type==DOTA_UNIT_ORDER_STOP or 
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:GetAbility():OnChargeFinish( false, self.target )
	end	
end

function modifier_serega_pirat_bike_cast:SetDirection( location )
	local dir = ((location-self:GetParent():GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_serega_pirat_bike_cast:GetModifierMoveSpeed_Limit()
	return 0.1
end

function modifier_serega_pirat_bike_cast:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end

function modifier_serega_pirat_bike_cast:OnIntervalThink()
	if IsServer() then
		self.anim_return = self.anim_return + FrameTime()
		if self.anim_return >= 1 then
			self.anim_return = 0
			self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
		end
	end

	if self.target and self.target:IsAlive() then 
		self:SetDirection(self.target:GetAbsOrigin())
	end

	if self:GetParent():IsRooted() or self:GetParent():IsStunned() or self:GetParent():IsSilenced() or
		self:GetParent():IsCurrentlyHorizontalMotionControlled() or self:GetParent():IsCurrentlyVerticalMotionControlled()
	then
		self:GetAbility():OnChargeFinish( true, self.target )
	end

	self:TurnLogic( FrameTime() )
	self:SetEffects()
end

function modifier_serega_pirat_bike_cast:TurnLogic( dt )
	if self.face_target then return end
	local angle_diff = AngleDiff( self.current_angle, self.target_angle )
	local turn_speed = self.turn_speed*dt

	local sign = -1
	if angle_diff<0 then sign = 1 end

	if math.abs( angle_diff )<1.1*turn_speed then
		self.current_angle = self.target_angle
		self.face_target = true
	else
		self.current_angle = self.current_angle + sign*turn_speed
	end

	local angles = self:GetParent():GetAnglesAsVector()
	self:GetParent():SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_serega_pirat_bike_cast:PlayEffects1()
	self.effect_cast = ParticleManager:CreateParticleForPlayer( "particles/pirat_bike_finder.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner() )
	
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	
	self:AddParticle( self.effect_cast, false, false, -1, false, false )
	
	self:SetEffects()
end

function modifier_serega_pirat_bike_cast:SetEffects()
	local time = self:GetElapsedTime()

	local k =  time/self.max_time

	local speed_time = k*self.time
	
	local target_pos = self.origin + self:GetParent():GetForwardVector() * self.speed * speed_time

	ParticleManager:SetParticleControl( self.effect_cast, 1, target_pos )
end

function modifier_serega_pirat_bike_cast:PlayEffects2()
	local effect_cast = ParticleManager:CreateParticle( "particles/pirat/pirat_bike_chargeup.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false, false, -1, false, false )
end

modifier_serega_pirat_bike_charge = class({})

function modifier_serega_pirat_bike_charge:IsPurgable()
	return false
end

function modifier_serega_pirat_bike_charge:CheckState()
	local state = 
	{
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_serega_pirat_bike_charge:OnCreated( kv )

	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )

	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )

	self.radius = self:GetAbility():GetSpecialValueFor( "knockback_radius" )

	self.distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" )

	self.duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" )

	self.stun = self:GetAbility():GetSpecialValueFor( "stun_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_2")

	local damage = self:GetAbility():GetSpecialValueFor( "knockback_damage" )

	self.tree_radius = 100
	self.height = 50
	self.duration = 0.3

	if not IsServer() then return end

	if self:GetParent().pirat_item_weapon and self:GetParent().pirat_item_offhand and self:GetParent().pirat_item_shoulder and self:GetParent().pirat_item_head and self:GetParent().pirat_item_belt and self:GetParent().pirat_item_arms and self:GetParent().pirat_item_armor then
		self:GetParent().pirat_item_weapon:Destroy()
		self:GetParent().pirat_item_offhand:Destroy()
		self:GetParent().pirat_item_shoulder:Destroy()
		self:GetParent().pirat_item_head:Destroy()
		self:GetParent().pirat_item_belt:Destroy()
		self:GetParent().pirat_item_arms:Destroy()
		self:GetParent().pirat_item_armor:Destroy()
	end

	self.damage = damage

	self.target_angle = self:GetParent():GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true
	self.knockback_units = {}
	self.knockback_units[self:GetParent()] = true

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

	self.distance_pass = 0

	self.damageTable = { attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility() }
end

function modifier_serega_pirat_bike_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end

function modifier_serega_pirat_bike_charge:GetModifierModelChange()
	return "models/pirat/bike.vmdl"
end

function modifier_serega_pirat_bike_charge:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		self:SetDirection( params.new_pos )
	elseif
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
		self:SetDirection( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetDirection( params.target:GetOrigin() )
	elseif
		params.order_type==DOTA_UNIT_ORDER_STOP or 
		params.order_type==DOTA_UNIT_ORDER_CAST_TARGET or
		params.order_type==DOTA_UNIT_ORDER_CAST_POSITION or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:Destroy()
	end	
end

function modifier_serega_pirat_bike_charge:GetModifierDisableTurning()
	return 1
end

function modifier_serega_pirat_bike_charge:SetDirection( location )
	local dir = ((location-self:GetParent():GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_serega_pirat_bike_charge:TurnLogic( dt )
	if self.face_target then return end
	local angle_diff = AngleDiff( self.current_angle, self.target_angle )
	local turn_speed = self.turn_speed*dt

	local sign = -1
	if angle_diff<0 then sign = 1 end

	if math.abs( angle_diff )<1.1*turn_speed then
		self.current_angle = self.target_angle
		self.face_target = true
	else
		self.current_angle = self.current_angle + sign*turn_speed
	end

	local angles = self:GetParent():GetAnglesAsVector()
	self:GetParent():SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_serega_pirat_bike_charge:HitLogic()
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree_radius, false )
	
	local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )

	for _,unit in pairs(units) do
		if not self.knockback_units[unit] then
			self.knockback_units[unit] = true
			self:PlayEffects( unit, self.radius )
		end
	end
end

function modifier_serega_pirat_bike_charge:UpdateHorizontalMotion( me, dt )
	if self:GetParent():IsRooted() then
		return
	end

	self:HitLogic()
	self:TurnLogic( dt )
	local nextpos = me:GetOrigin() + me:GetForwardVector() * self.speed * dt
	me:SetOrigin(nextpos)
end

function modifier_serega_pirat_bike_charge:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_serega_pirat_bike_charge:GetEffectName()
	return "particles/pirat/pirat_bike_charge_active.vpcf"
end

function modifier_serega_pirat_bike_charge:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_serega_pirat_bike_charge:PlayEffects( target, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	target:EmitSound("Hero_PrimalBeast.Onslaught.Hit")
end

function modifier_serega_pirat_bike_charge:OnDestroy()
	if not IsServer() then return end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_strike_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())

	self:GetParent().pirat_item_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_weapon/god_eater_weapon.vmdl" })
	self:GetParent().pirat_item_weapon:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_offhand = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_off_hand/god_eater_off_hand.vmdl" })
	self:GetParent().pirat_item_offhand:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_shoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_shoulder/god_eater_shoulder.vmdl" })
	self:GetParent().pirat_item_shoulder:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_head/god_eater_head.vmdl" })
	self:GetParent().pirat_item_head:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_belt/god_eater_belt.vmdl" })
	self:GetParent().pirat_item_belt:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_arms/god_eater_arms.vmdl" })
	self:GetParent().pirat_item_arms:FollowEntity(self:GetParent(), true)
		
	self:GetParent().pirat_item_armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_armor/god_eater_armor.vmdl" })
	self:GetParent().pirat_item_armor:FollowEntity(self:GetParent(), true)

	self:GetParent():RemoveHorizontalMotionController(self)
	FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetOrigin(), false )
end

function modifier_serega_pirat_bike_charge:IsAura()
	return true
end

function modifier_serega_pirat_bike_charge:GetModifierAura()
	return "modifier_serega_pirat_bike_debuff"
end

function modifier_serega_pirat_bike_charge:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("knockback_radius")
end

function modifier_serega_pirat_bike_charge:GetAuraDuration()
	return 0.1
end

function modifier_serega_pirat_bike_charge:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_serega_pirat_bike_charge:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_serega_pirat_bike_charge:GetAuraSearchFlags()
	return 0
end

function modifier_serega_pirat_bike_charge:GetAuraEntityReject(target)
	if target:IsBoss() then
		return true
	end
	return false
end

modifier_serega_pirat_bike_debuff = class({})

function modifier_serega_pirat_bike_debuff:IsPurgable()
	return false
end

function modifier_serega_pirat_bike_debuff:OnCreated( kv )
	if not IsServer() then return end
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end
end

function modifier_serega_pirat_bike_debuff:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	local damage = self:GetAbility():GetSpecialValueFor("knockback_damage")
	ApplyDamage({ attacker = self:GetCaster(), victim = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility() })
	self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self:GetAbility():GetSpecialValueFor("stun_duration") } )
end

function modifier_serega_pirat_bike_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_serega_pirat_bike_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_serega_pirat_bike_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_serega_pirat_bike_debuff:UpdateHorizontalMotion( me, dt )
	local caster = self:GetCaster()
	local target = caster:GetOrigin() + caster:GetForwardVector() * 190

	me:SetOrigin( target )
end

function modifier_serega_pirat_bike_debuff:OnHorizontalMotionInterrupted()
	self:Destroy()
end

LinkLuaModifier("modifier_serega_pirat_tilt", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_serega_pirat_tilt_rotate", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_NONE)

serega_pirat_tilt = class({})

function serega_pirat_tilt:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_serega_pirat_tilt", {duration = duration})
end

modifier_serega_pirat_tilt = class({})

function modifier_serega_pirat_tilt:IsPurgable()
	return false
end

function modifier_serega_pirat_tilt:AllowIllusionDuplicate()
	return true
end

function modifier_serega_pirat_tilt:OnCreated( kv )
	self.base_attacktime = self:GetAbility():GetSpecialValueFor( "base_attacktime" )
	self.bonus_attack_range = self:GetAbility():GetSpecialValueFor( "bonus_attack_range" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_8")

	if not IsServer() then return end

	for i=1, 3 do
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_blur_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle( particle, false, false, -1, false, false  )
	end

	if not self:GetParent():IsIllusion() then
		self:GetParent():EmitSound("pirat_tilt")
	end

	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_serega_pirat_tilt_rotate", {duration = self:GetRemainingTime()})

	local apm = self:GetCaster():GetAttacksPerSecond(true)
	self:StartIntervalThink(1/apm)
end

function modifier_serega_pirat_tilt:OnIntervalThink()
	if not IsServer() then return end

	local apm = self:GetCaster():GetAttacksPerSecond(true)

	self:StartIntervalThink(1/apm)

	if self:GetParent():HasModifier("modifier_serega_pirat_bike_cast") then return end
	if self:GetParent():HasModifier("modifier_serega_pirat_bike_charge") then return end

	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )

	if #enemies <= 0 then return end

	if self:GetParent():IsStunned() or self:GetParent():IsHexed() or (self:CheckDisarm(self:GetParent()) == true) or self:GetParent():IsChanneling() then return end

	local random_attack = RandomInt(1, 2)
	self:GetParent():FadeGesture(ACT_DOTA_ATTACK)
	self:GetParent():FadeGesture(ACT_DOTA_ATTACK2)
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, self:GetParent():GetDisplayAttackSpeed() / 100)
	self:GetParent():PerformAttack(enemies[1], false, true, true, false, false, false, false)
end

function modifier_serega_pirat_tilt:CheckState()
	return 
	{
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_serega_pirat_tilt:OnRefresh( kv )
	if not IsServer() then return end
	self:OnCreated()
end

function modifier_serega_pirat_tilt:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("pirat_tilt")
end

function modifier_serega_pirat_tilt:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    	MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}

	return funcs
end

function modifier_serega_pirat_tilt:GetModifierBaseAttackTimeConstant()
	return self.base_attacktime
end

function modifier_serega_pirat_tilt:GetModifierAttackRangeBonus()
	return self.bonus_attack_range
end

function modifier_serega_pirat_tilt:CheckDisarm( unit )
	if not IsServer() then return end
  	for _, mod in pairs(unit:FindAllModifiers()) do
        if mod:GetName() ~= "modifier_serega_pirat_tilt" then
            local tables = {}
            mod:CheckStateToTable(tables)
            for state_name, mod_table in pairs(tables) do
                if tostring(state_name) == '1' then
                     return true
                end
            end
        end
    end
	return false
end

--------------------------------------

modifier_serega_pirat_tilt_rotate = class({})

function modifier_serega_pirat_tilt_rotate:IsPurgable()
	return false
end

function modifier_serega_pirat_tilt_rotate:IsHidden()
	return true
end

function modifier_serega_pirat_tilt_rotate:OnCreated( kv )
	self.bonus_damage = 0
	self.bonus_damage_time = 0
	self.rotate = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_serega_pirat_tilt_rotate:OnIntervalThink()

	if self:GetCaster():HasScepter() then
		self.bonus_damage_time = self.bonus_damage_time + FrameTime()
		if self.bonus_damage_time >= self:GetAbility():GetSpecialValueFor("scepter_think") then
			self.bonus_damage = self.bonus_damage + self:GetAbility():GetSpecialValueFor("damage_think")
			self.bonus_damage_time = 0
		end
	end

	if not IsServer() then return end

	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	if #enemies <= 0 then self.rotate = 0 return end
	self.rotate = 1
	local direction = enemies[1]:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()

	if self:GetParent():HasModifier("modifier_serega_pirat_bike_cast") then return end
	if self:GetParent():HasModifier("modifier_serega_pirat_bike_charge") then return end
	
	if not self:GetParent():IsCurrentlyHorizontalMotionControlled() and not self:GetParent():IsCurrentlyVerticalMotionControlled() then
		self:GetParent():SetForwardVector(direction)
		self:GetParent():FaceTowards(enemies[1]:GetAbsOrigin())
	end
end

function modifier_serega_pirat_tilt_rotate:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_DISABLE_TURNING,
    	MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE 
	}

	return funcs
end

function modifier_serega_pirat_tilt_rotate:GetModifierDisableTurning()
	return self.rotate
end

function modifier_serega_pirat_tilt_rotate:GetModifierDamageOutgoing_Percentage()
	return self.bonus_damage
end

LinkLuaModifier("modifier_serega_pirat_radiance", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_serega_pirat_radiance_debuff", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_NONE)

serega_pirat_radiance = class({})

function serega_pirat_radiance:GetIntrinsicModifierName()
	return "modifier_serega_pirat_radiance"
end

function serega_pirat_radiance:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_3")
end

modifier_serega_pirat_radiance = class({})

function modifier_serega_pirat_radiance:IsHidden() return true end

function modifier_serega_pirat_radiance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
end

function modifier_serega_pirat_radiance:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_serega_pirat_radiance:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():IsIllusion() then return end
	if self:GetAbility():IsFullyCastable() and self.particle == nil then
		self.particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/radiance_owner_fall_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	elseif not self:GetAbility():IsFullyCastable() and self.particle ~= nil then
		if self.particle ~= nil then
			ParticleManager:DestroyParticle(self.particle, false)
		end
		self.particle = nil
	end
end

function modifier_serega_pirat_radiance:GetModifierProcAttack_BonusDamage_Physical(params)
	if not IsServer() then return end

	if self:GetParent():PassivesDisabled() then return end
	if params.target:IsWard() then return end
	if params.target:IsMagicImmune() then return end

	local target = params.target

	local mana_burn_passive = self:GetAbility():GetSpecialValueFor("mana_burn_passive")
	local mana_burn_damage = self:GetAbility():GetSpecialValueFor("mana_burn_damage")
	local radiance_burn_duration = self:GetAbility():GetSpecialValueFor("radiance_burn_duration")

	if self:GetParent():IsIllusion() then
		mana_burn_passive = mana_burn_passive / 2
		mana_burn_damage = mana_burn_damage / 2
	end

	local mana_burn =  target:GetMaxMana() / 100 * mana_burn_passive
	target:Script_ReduceMana( mana_burn, self:GetAbility() )

	local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	target:EmitSound("Hero_Antimage.ManaBreak")

	if self:GetAbility():IsFullyCastable() and not self:GetParent():IsIllusion() and target:IsHero() then
		self:GetCaster():EmitSound("pirat_radiance")
		params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_serega_pirat_radiance_debuff", {duration = radiance_burn_duration})
		self:GetAbility():UseResources(false, false, false, true)
	end

	return mana_burn * mana_burn_damage
end

modifier_serega_pirat_radiance_debuff = class({})

function modifier_serega_pirat_radiance_debuff:IsPurgable() return true end

function modifier_serega_pirat_radiance_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow") + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_6")
	self.rotate = self:GetAbility():GetSpecialValueFor("rotate")
	if not IsServer() then return end
	self.radiance_burn_damage = self:GetAbility():GetSpecialValueFor("radiance_burn_damage")
	local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/radiance_fall_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())	
	self:AddParticle(particle, false, false, -1, false, false)
	self:StartIntervalThink(1)
end

function modifier_serega_pirat_radiance_debuff:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.radiance_burn_damage, damage_type = DAMAGE_TYPE_PHYSICAL })
end

function modifier_serega_pirat_radiance_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}
end

function modifier_serega_pirat_radiance_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_serega_pirat_radiance_debuff:GetModifierTurnRate_Percentage()
	return self.rotate
end

LinkLuaModifier("modifier_serega_pirat_tp_illusion", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_serega_pirat_tp_active", "abilities/heroes/serega_pirat", LUA_MODIFIER_MOTION_NONE)

serega_pirat_tp = class({})

function serega_pirat_tp:GetCooldown(level)
	if self:GetCaster():HasShard() then
		return self.BaseClass.GetCooldown( self, level ) - self:GetSpecialValueFor("shard_cooldown")
	end
    return self.BaseClass.GetCooldown( self, level )
end

function serega_pirat_tp:OnSpellStart()
	if not IsServer() then return end

	local point = self:GetCursorPosition()
	local cast_range = self:GetSpecialValueFor("cast_range")

	local direction = (point - self:GetCaster():GetAbsOrigin())
	direction.z = 0

	if direction:Length2D() > cast_range then
		direction = direction:Normalized() * cast_range
	end

	local particle_start = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( particle_start, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControlForward( particle_start, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( particle_start )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin(), "Hero_Antimage.Blink_out", self:GetCaster() )

	local illusion_damage = self:GetSpecialValueFor("illusion_damage") - 100
	local illusion_duration = self:GetSpecialValueFor("illusion_duration")
	local invis_duration = self:GetSpecialValueFor("invis_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_serega_pirat_4")

	local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=illusion_duration,outgoing_damage=illusion_damage,incoming_damage=0}, 1, 0, false, false ) 

    for k, v in pairs(illusion) do
    	v:MoveToPositionAggressive(self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 500)
    	v:AddNewModifier(self:GetCaster(), self, "modifier_serega_pirat_tp_illusion", {})
    	v:RemoveModifierByName("modifier_serega_pirat_tilt")
    	v:RemoveModifierByName("modifier_serega_pirat_tilt_rotate")
    end

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_serega_pirat_tp_active", {duration = invis_duration})

    if RollPercentage(self:GetSpecialValueFor("chance")) then
    	FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true)
		self:GetCaster():EmitSound("pirat_tp")
		return
	end

	ProjectileManager:ProjectileDodge(self:GetCaster())

	FindClearSpaceForUnit( self:GetCaster(), self:GetCaster():GetAbsOrigin() + direction, true )

	ProjectileManager:ProjectileDodge(self:GetCaster())

	if self:GetCaster():HasTalent("special_bonus_birzha_serega_pirat_5") then
		local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=illusion_duration,outgoing_damage=illusion_damage,incoming_damage=0}, 1, 0, true, true ) 

		for k, v in pairs(illusion) do
			v:MoveToPositionAggressive(self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 500)
	    	v:AddNewModifier(self:GetCaster(), self, "modifier_serega_pirat_tp_illusion", {})
	    	v:RemoveModifierByName("modifier_serega_pirat_tilt")
	    	v:RemoveModifierByName("modifier_serega_pirat_tilt_rotate")
	    end
	end

	local particle_end = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( particle_end, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControlForward( particle_end, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( particle_end )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin(), sound_cast_b, self:GetCaster() )
end

modifier_serega_pirat_tp_illusion = class({})

function modifier_serega_pirat_tp_illusion:IsPurgable() return false end

function modifier_serega_pirat_tp_illusion:IsHidden() return true end

function modifier_serega_pirat_tp_illusion:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_serega_pirat_tp_illusion:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true
	}
end

function modifier_serega_pirat_tp_illusion:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end

	local splash = self:GetAbility():GetSpecialValueFor("splash")
	
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), params.target:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	
	for _,enemy in ipairs(enemies) do
		if enemy ~= params.target then
			ApplyDamage({victim = enemy, attacker = self:GetParent(), ability = self:GetAbility(), damage = params.original_damage / 100 * splash, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	end
	
	local particle = ParticleManager:CreateParticle("particles/pirat/battlefuryeffect.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
	ParticleManager:SetParticleControl(particle, 0, params.target:GetAbsOrigin())

	if not self:GetCaster():HasTalent("special_bonus_birzha_serega_pirat_7") then
		self:GetParent():ForceKill(false)
	end
end

modifier_serega_pirat_tp_active = class({})

function modifier_serega_pirat_tp_active:IsPurgable() return false end

function modifier_serega_pirat_tp_active:IsHidden() return false end

function modifier_serega_pirat_tp_active:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
end

function modifier_serega_pirat_tp_active:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	self:Destroy()
end

function modifier_serega_pirat_tp_active:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_serega_pirat_tp_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_serega_pirat_tp_active:OnAbilityExecuted(keys)
    if IsServer() then
        local ability = keys.ability
        local caster = keys.unit
        if caster == self:GetParent() then
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_serega_pirat_tp_active:CheckState()
    return 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

