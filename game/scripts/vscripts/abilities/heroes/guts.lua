LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
Guts_Hand = class({})

function Guts_Hand:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Guts_Hand:GetCastRange(location, target)
	local bonus_range = 0
	if self:GetCaster():HasShard() then
		bonus_range = 200
	end
    return self.BaseClass.GetCastRange(self, location, target) + bonus_range
end

function Guts_Hand:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Guts_Hand:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function Guts_Hand:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		self.target = self:GetCursorTarget()

		local damage = self:GetSpecialValueFor("damage")
		local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_2")
		local radius = self:GetSpecialValueFor("radius")
		local vision_radius = self:GetSpecialValueFor("vision_radius")
		local bolt_speed = self:GetSpecialValueFor("bolt_speed")
		caster:EmitSound("Hero_Sven.StormBolt")
		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
		local projectile =
		{
			Target 				= self.target,
			Source 				= caster,
			Ability 			= self,
			EffectName 			= "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
			iMoveSpeed			= bolt_speed,
			vSpawnOrigin 		= caster:GetAbsOrigin(),
			bDrawsOnMinimap 	= false,
			bDodgeable 			= true,
			bIsAttack 			= false,
			bVisibleToEnemies 	= true,
			bReplaceExisting 	= false,
			flExpireTime 		= GameRules:GetGameTime() + 10,
			bProvidesVision 	= true,
			iSourceAttachment 	= ATTACH_ATTACK1,
			iVisionRadius 		= vision_radius,
			iVisionTeamNumber 	= caster:GetTeamNumber(),
			ExtraData			= {damage = damage, stun_duration = stun_duration, radius = radius}
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
	end
end

function Guts_Hand:OnProjectileHit_ExtraData(target, location, ExtraData)
	if IsServer() then
		local caster = self:GetCaster()
		EmitSoundOnLocationWithCaster(location, "Hero_Sven.StormBoltImpact", caster)
		if target then
			if self:GetCaster():HasShard() then
				local point = SplineVectors( caster:GetOrigin(), target:GetOrigin(), 1 )
				caster:SetOrigin( point )
    			FindClearSpaceForUnit( caster, point, true )
    			local vec = target:GetOrigin()-caster:GetOrigin()
    			vec.z = 0
    			caster:SetForwardVector( vec:Normalized() )
    			caster:MoveToTargetToAttack( target )
			end
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, ExtraData.radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for _,enemy in ipairs(enemies) do
				if enemy == target and target:TriggerSpellAbsorb(self) then
				else
					ApplyDamage({victim = enemy, attacker = caster, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
					enemy:AddNewModifier(caster, self, "modifier_birzha_stunned_purge", {duration = ExtraData.stun_duration})
				end
			end
		end
	end
end

LinkLuaModifier( "modifier_guts_cannon_attack", "abilities/heroes/guts.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_guts_cannon_debuff", "abilities/heroes/guts.lua", LUA_MODIFIER_MOTION_NONE )

guts_cannon = class({})

function guts_cannon:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function guts_cannon:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function guts_cannon:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function guts_cannon:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local info = {
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
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster()),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_UNITS_EVERYWHERE,
			false
		)

		local secondary_knives_thrown = 0
		
		for _, enemy in pairs(enemies) do
			print("da")

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
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

	}

	return funcs
end

function modifier_guts_cannon_attack:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "attack_factor" )
	end
end

function modifier_guts_cannon_attack:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "base_damage" ) * 100/(100+self:GetAbility():GetSpecialValueFor( "attack_factor" ))
	end
end

modifier_guts_cannon_debuff = class({})

function modifier_guts_cannon_debuff:IsPurgable()
	return true
end

function modifier_guts_cannon_debuff:DeclareFunctions()
	local funcs = {
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

Guts_InimitableTactician = class({})

function Guts_InimitableTactician:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Guts_InimitableTactician:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Guts_InimitableTactician:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Guts_InimitableTactician:GetIntrinsicModifierName()
    return "modifier_guts_InimitableTactician"
end

function Guts_InimitableTactician:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	local radius = 250
	local angle = 70
	local flag = 0

	if caster:HasTalent("special_bonus_birzha_guts_5") then
		flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		flag,
		0,
		false
	)
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
			caster:PerformAttack( enemy, true, true, true, true, true, false, true )
			enemy:AddNewModifier( caster, self, "modifier_knockback", { duration = 0.5, distance = 75, height = 0, direction_x = enemy_direction.x, direction_y = enemy_direction.y, } )
			enemy:AddNewModifier( caster, self, "modifier_disarmed", {duration = duration} )
		end
	end
	caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlForward( particle, 1, cast_direction )
	ParticleManager:ReleaseParticleIndex( particle )
	EmitSoundOn("Hero_Centaur.DoubleEdge", caster)
end

modifier_guts_InimitableTactician = class({})

function modifier_guts_InimitableTactician:IsPurgable() return false end
function modifier_guts_InimitableTactician:IsHidden() return true end

function modifier_guts_InimitableTactician:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_guts_InimitableTactician:OnAttackStart(keys)
    if keys.attacker == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        self.critProc = false
        self.chance = self:GetAbility():GetSpecialValueFor("chance")
        self.crit = self:GetAbility():GetSpecialValueFor("crit")
        self.mana_per_hit = self:GetAbility():GetSpecialValueFor("mana_per_hit") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_1")
        self.damage_per_burn = self:GetAbility():GetSpecialValueFor("damage_per_burn")
        self.reduce = self.mana_per_hit * self:GetParent():GetStrength()
        if self.chance >= RandomInt(1, 100) then
            self:GetParent():StartGesture(ACT_DOTA_ATTACK)
            self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Impact.Immortal")
            local crit_pfx = ParticleManager:CreateParticle("particles/guts/skeleton_king_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_pfx)
            self.critProc = true
            return self.crit
        end 
    end
end

function modifier_guts_InimitableTactician:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    if self.critProc == true then
        return self.crit
    else
        return nil
    end
end

function modifier_guts_InimitableTactician:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self.critProc == true then
			local damageTable = {}
			damageTable.attacker = self:GetParent()
			damageTable.victim = params.target
			damageTable.damage_type = DAMAGE_TYPE_MAGICAL
			damageTable.ability = self:GetAbility()
			
			if not params.target:IsMagicImmune() then
				if(params.target:GetMana() >= self.reduce) then
					damageTable.damage = self.reduce * self.damage_per_burn
					params.target:ReduceMana(self.reduce)
				else
					damageTable.damage = params.target:GetMana() * self.damage_per_burn
					params.target:ReduceMana(self.reduce)
				end
				ApplyDamage(damageTable)
			end
            self.critProc = false
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
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_3")
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
	return self:GetAbility():GetSpecialValueFor("bonus_armor") + self:GetCaster():FindTalentValue("special_bonus_birzha_guts_4")
end

function modifier_guts_DarkArmor:GetModifierModelChange()
	return "models/heroes/anime/berserk/berserk/berserk.vmdl"
end