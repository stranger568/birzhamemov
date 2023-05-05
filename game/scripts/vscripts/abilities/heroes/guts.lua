LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Guts_Hand = class({})

function Guts_Hand:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Guts_Hand:GetCastRange(location, target)
	if self:GetCaster():HasShard() then
		return self:GetSpecialValueFor("shard_cast_range")	
	end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Guts_Hand:GetBehavior()
	if self:GetCaster():HasShard() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST	
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function Guts_Hand:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Guts_Hand:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function Guts_Hand:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_7")
	local radius = self:GetSpecialValueFor("radius")
	local vision_radius = self:GetSpecialValueFor("vision_radius")
	local bolt_speed = self:GetSpecialValueFor("bolt_speed")
	self:GetCaster():EmitSound("Hero_Sven.StormBolt")
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)

	local projectile =
	{
		Target 				= target,
		Source 				= self:GetCaster(),
		Ability 			= self,
		EffectName 			= "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
		iMoveSpeed			= bolt_speed,
		vSpawnOrigin 		= self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10,
		bProvidesVision 	= true,
		iSourceAttachment 	= ATTACH_ATTACK1,
		iVisionRadius 		= vision_radius,
		iVisionTeamNumber 	= self:GetCaster():GetTeamNumber(),
		ExtraData			= {damage = damage, stun_duration = stun_duration, radius = radius}
	}

	ProjectileManager:CreateTrackingProjectile(projectile)
	self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
end

function Guts_Hand:OnProjectileHit_ExtraData(target, location, ExtraData)
	if not IsServer() then return end
	EmitSoundOnLocationWithCaster(location, "Hero_Sven.StormBoltImpact", self:GetCaster())
	if target == nil then return end

	if not target:IsMagicImmune() and not target:TriggerSpellAbsorb(self) then
		if self:GetCaster():HasShard() and not self:GetAutoCastState() then
			local point = SplineVectors( self:GetCaster():GetOrigin(), target:GetOrigin(), 1 )
			point.z = 0
			self:GetCaster():SetOrigin( point )
			FindClearSpaceForUnit( self:GetCaster(), point, true )
			local vec = target:GetOrigin()-self:GetCaster():GetOrigin()
			vec.z = 0
			self:GetCaster():SetForwardVector( vec:Normalized() )
			self:GetCaster():MoveToTargetToAttack( target )
		end
	end

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, ExtraData.radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,enemy in ipairs(enemies) do
		if enemy == target and target:TriggerSpellAbsorb(self) then
		else
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = ExtraData.stun_duration * (1-enemy:GetStatusResistance()) })
			if self:GetCaster():HasTalent("special_bonus_birzha_guts_3") then
				enemy:Purge(true, false, false, false, false)
			end
		end
	end
end

LinkLuaModifier( "modifier_guts_cannon_attack", "abilities/heroes/guts.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guts_cannon_debuff", "abilities/heroes/guts.lua", LUA_MODIFIER_MOTION_NONE )

guts_cannon = class({})

function guts_cannon:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_2")
end

function guts_cannon:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function guts_cannon:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function guts_cannon:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("bomb_speed"),
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = 450,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	ProjectileManager:CreateTrackingProjectile(info)

	if self:GetCaster():HasScepter() then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_UNITS_EVERYWHERE, false )
		local secondary_knives_thrown = 0
		for _, enemy in pairs(enemies) do
			if enemy ~= target then
				info.Target = enemy
				ProjectileManager:CreateTrackingProjectile(info)
				secondary_knives_thrown = secondary_knives_thrown + 1
			end
			if secondary_knives_thrown >= 2 then
				break
			end
		end
	end

	caster:EmitSound("Hero_Techies.Attack")
end

function guts_cannon:OnProjectileHit( hTarget, vLocation )
	local target = hTarget
	if target==nil then return end
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor("duration")
	local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_guts_cannon_attack", {} )
	self:GetCaster():PerformAttack ( hTarget, true, true, true, false, false, false, true )
	if modifier and not modifier:IsNull() then
		modifier:Destroy()
	end
	hTarget:AddNewModifier( self:GetCaster(), self, "modifier_guts_cannon_debuff", {duration = duration * (1 - hTarget:GetStatusResistance())} )
	hTarget:EmitSound("Hero_Techies.LandMine.Detonate")
end

modifier_guts_cannon_attack = class({})

function modifier_guts_cannon_attack:IsHidden()
	return true
end

function modifier_guts_cannon_attack:IsPurgable()
	return false
end

function modifier_guts_cannon_attack:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

function modifier_guts_cannon_attack:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "attack_factor" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_4")
	end
end

function modifier_guts_cannon_attack:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "base_damage" ) * 100/(100+self:GetAbility():GetSpecialValueFor( "attack_factor" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_4"))
	end
end

modifier_guts_cannon_debuff = class({})

function modifier_guts_cannon_debuff:IsPurgable()
	return true
end

function modifier_guts_cannon_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_guts_cannon_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "move_slow" )
end

function modifier_guts_cannon_debuff:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end

function modifier_guts_cannon_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_guts_InimitableTactician", "abilities/heroes/guts.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

Guts_InimitableTactician = class({})

function Guts_InimitableTactician:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Guts_InimitableTactician:GetCastRange(location, target)
	if self:GetCaster():HasTalent("special_bonus_birzha_guts_8") then
		return self:GetCaster():FindTalentValue("special_bonus_birzha_guts_8")
	end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Guts_InimitableTactician:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Guts_InimitableTactician:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_birzha_guts_8") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return DOTA_ABILITY_BEHAVIOR_POINT
end

function Guts_InimitableTactician:GetIntrinsicModifierName()
    return "modifier_guts_InimitableTactician"
end

function Guts_InimitableTactician:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_1")

	if self:GetCaster():HasTalent("special_bonus_birzha_guts_8") then

		self:GetCaster():EmitSound("Hero_Axe.CounterHelix_Blood_Chaser")

		local particle = ParticleManager:CreateParticle( "particles/guts_helix.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    	ParticleManager:ReleaseParticleIndex( particle )

    	local origin = caster:GetOrigin()

		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_guts_8"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,enemy in pairs(enemies) do
			local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
			caster:PerformAttack( enemy, true, true, true, false, false, false, true)
			enemy:AddNewModifier( caster, self, "modifier_generic_knockback_lua", { duration = 0.1, distance = 75, height = 0, direction_x = enemy_direction.x, direction_y = enemy_direction.y})
			enemy:AddNewModifier( caster, self, "modifier_disarmed", {duration = duration * (1-enemy:GetStatusResistance()) } )
		end

		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_1, 1.4)
	    local parent = self:GetCaster()
	    Timers:CreateTimer(0.4, function()
	        parent:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	    end)

		return
	end

	local radius = 250

	local angle = 70

	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

	local origin = caster:GetOrigin()

	local cast_direction = (point-origin):Normalized()

	local cast_angle = VectorToAngles( cast_direction ).y

	for _,enemy in pairs(enemies) do
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles( enemy_direction ).y
		local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
		if angle_diff<=angle then
			local particle_edge_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particle_edge_fx, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_edge_fx, 1, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_edge_fx, 2, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_edge_fx, 4, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_edge_fx, 5, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_edge_fx)
			caster:PerformAttack( enemy, true, true, true, false, false, false, true)
			enemy:AddNewModifier( caster, self, "modifier_generic_knockback_lua", { duration = 0.1, distance = 75, height = 0, direction_x = enemy_direction.x, direction_y = enemy_direction.y})
			enemy:AddNewModifier( caster, self, "modifier_disarmed", {duration = duration * (1-enemy:GetStatusResistance()) } )
		end
	end

	caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlForward( particle, 1, cast_direction )
	ParticleManager:ReleaseParticleIndex( particle )

	caster:EmitSound("Hero_Centaur.DoubleEdge")
end

modifier_guts_InimitableTactician = class({})

function modifier_guts_InimitableTactician:IsPurgable() return false end
function modifier_guts_InimitableTactician:IsHidden() return true end

function modifier_guts_InimitableTactician:OnCreated()
    if not IsServer() then return end
    self.attack_record = nil
end

function modifier_guts_InimitableTactician:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    }
    return funcs
end

function modifier_guts_InimitableTactician:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    local chance = self:GetAbility():GetSpecialValueFor("chance")
    if RollPercentage(chance) then

    	self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Impact.Immortal")

    	local crit_pfx = ParticleManager:CreateParticle("particles/guts/skeleton_king_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(crit_pfx)

    	self.attack_record = params.record
        return self:GetAbility():GetSpecialValueFor("crit")
   	end
end

function modifier_guts_InimitableTactician:GetModifierProcAttack_Feedback( params )
    if not IsServer() then return end

    local pass = false

    if self.attack_record and params.record==self.attack_record then
        pass = true
        self.attack_record = nil
    end

    if pass then
		local damageTable = {attacker = self:GetParent(), victim = params.target, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()}
		if not params.target:IsMagicImmune() then
			local reduce = self:GetCaster():GetStrength() / 100 * self:GetAbility():GetSpecialValueFor("mana_per_hit")
			local damage = self:GetAbility():GetSpecialValueFor("damage_per_burn")
			if (params.target:GetMana() >= reduce) then
				damageTable.damage = reduce * damage
				params.target:Script_ReduceMana(reduce, self:GetAbility())
			else
				damageTable.damage = params.target:GetMana() * damage
				params.target:Script_ReduceMana(reduce, self:GetAbility())
			end
			ApplyDamage(damageTable)
		end
    end
end

LinkLuaModifier("modifier_guts_DarkArmor", "abilities/heroes/guts", LUA_MODIFIER_MOTION_NONE)

Guts_DarkArmor = class({})

function Guts_DarkArmor:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Guts_DarkArmor:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Guts_DarkArmor:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_6")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_guts_DarkArmor", {duration = duration})
end

modifier_guts_DarkArmor = class({})

function modifier_guts_DarkArmor:IsPurgable()
	return false
end

function modifier_guts_DarkArmor:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MODEL_CHANGE }
end

function modifier_guts_DarkArmor:GetModifierBaseDamageOutgoing_Percentage()
	return  self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_guts_DarkArmor:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magic")
end

function modifier_guts_DarkArmor:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_5")
end

function modifier_guts_DarkArmor:GetModifierModelChange()
	return "models/heroes/anime/berserk/berserk/berserk.vmdl"
end