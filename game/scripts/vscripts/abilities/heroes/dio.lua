LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_dio_kakyoin_debuff", "abilities/heroes/dio", LUA_MODIFIER_MOTION_HORIZONTAL )

Dio_Kakyoin = class({})

function Dio_Kakyoin:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Dio_Kakyoin:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Dio_Kakyoin:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Dio_Kakyoin:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local dirX = 0
	local dirY = 0
	local kicked = nil
    if target:TriggerSpellAbsorb( self ) then
        return
    end
	dirX = target:GetOrigin().x-caster:GetOrigin().x
	dirY = target:GetOrigin().y-caster:GetOrigin().y
	kicked = target
	self:Kick( kicked, dirX, dirY )
	target:EmitSound("dioboom")
    local damage = self:GetSpecialValueFor("damage")
    local damageTable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }
    ApplyDamage(damageTable)
end

function Dio_Kakyoin:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if not hTarget then return end
	local damageTable = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = extraData.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	ApplyDamage(damageTable)
    if not hTarget:HasModifier("modifier_dio_kakyoin_debuff") then
	   hTarget:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = extraData.stun, }  )
    end
	EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Damage", hTarget )
	return false
end

function Dio_Kakyoin:Kick( target, x, y )
	local damage = self:GetSpecialValueFor("damage")
	local stun = self:GetSpecialValueFor("stun_duration")
	local radius = self:GetSpecialValueFor("radius")
	local speed = 1500
	local distance = self:GetSpecialValueFor("distance")

	local mod = target:AddNewModifier( self:GetCaster(), self, "modifier_dio_kakyoin_debuff", { x = x, y = y, r = distance, } )

	local info = {
		Source = self:GetCaster(),
		Ability = self,
		vSpawnOrigin = target:GetOrigin(),
	    bDeleteOnHit = false,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    EffectName = "",
	    fDistance = distance,
	    fStartRadius = radius,
	    fEndRadius =radius,
		vVelocity = Vector(x,y,0):Normalized() * speed,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		ExtraData = {
			damage = damage,
			stun = stun,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)
	self:PlayEffects1( target )
	self:PlayEffects2( target, Vector(x,y,0):Normalized(), distance/speed )
end

function Dio_Kakyoin:PlayEffects1( target )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_caster.vpcf", PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Cast", self:GetCaster() )
end

function Dio_Kakyoin:PlayEffects2( target, direction, duration )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Target", target )
end

modifier_dio_kakyoin_debuff = class({})

function modifier_dio_kakyoin_debuff:IsDebuff()
	return true
end

function modifier_dio_kakyoin_debuff:IsHidden()
    return true
end

function modifier_dio_kakyoin_debuff:IsPurgable()
	return false
end

function modifier_dio_kakyoin_debuff:RemoveOnDeath()
    return false
end

function modifier_dio_kakyoin_debuff:OnCreated( kv )
	if IsServer() then
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = 1500
		self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
		self.origin = self:GetParent():GetOrigin()
		if self:ApplyHorizontalMotionController() == false then
            if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

function modifier_dio_kakyoin_debuff:OnRefresh( kv )
	if IsServer() then
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = 1500
		self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
		self.origin = self:GetParent():GetOrigin()
		if self:ApplyHorizontalMotionController() == false then 
            if not self:IsNull() then
                self:Destroy()
            end
		end
	end	
end

function modifier_dio_kakyoin_debuff:OnDestroy( kv )
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
	end
end

function modifier_dio_kakyoin_debuff:UpdateHorizontalMotion( me, dt )
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

function modifier_dio_kakyoin_debuff:OnHorizontalMotionInterrupted()
	if IsServer() then
        if not self:IsNull() then
            self:Destroy()
        end
	end
end

function modifier_dio_kakyoin_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_dio_kakyoin_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

Dio_Wry = class({})

function Dio_Wry:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Dio_Wry:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Dio_Wry:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Dio_Wry:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("diowry")
    local particle = ParticleManager:CreateParticle("particles/dio/dio_wry.vpcf", PATTACH_POINT, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
    ParticleManager:ReleaseParticleIndex(particle)
    local current_int = 0
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)   
    for _, enemy in pairs(enemies) do
		local current_mana = enemy:GetMana()
        if enemy:IsHero() then
		    current_int = enemy:GetIntellect()
        end
		local multiplier = self:GetSpecialValueFor("float_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_dio_1")
		local basicdamage = self:GetSpecialValueFor("damage")
		local mana_to_burn = math.min( current_mana, current_int * multiplier )
		local digits = string.len( math.floor( mana_to_burn ) ) + 1
		enemy:ReduceMana( mana_to_burn )
		local damageTable = {
			victim = enemy,
			attacker = self:GetCaster(),
			damage = mana_to_burn + basicdamage,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage( damageTable )
		local numberIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, enemy )
		ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
		ParticleManager:SetParticleControl( numberIndex, 2, Vector( 2.0, digits, 0 ) )
		local burnIndex = ParticleManager:CreateParticle( "particles/dio/dio_wry_debuff.vpcf", PATTACH_ABSORIGIN, enemy )
    end
end

Dio_Blink = class({})

function Dio_Blink:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dio_5")
end

function Dio_Blink:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Dio_Blink:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Dio_Blink:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    return true;
end

function Dio_Blink:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("blink_range") + self:GetCaster():FindTalentValue("special_bonus_birzha_dio_3")
    local direction = (point - origin)
    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end
    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )
    ProjectileManager:ProjectileDodge(self:GetCaster())
    self:PlayEffects( origin, direction )
end

function Dio_Blink:PlayEffects( origin, direction )
    local particle_one = ParticleManager:CreateParticle( "particles/dio/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    EmitSoundOnLocationWithCaster( origin, "Hero_Antimage.Blink_out", self:GetCaster() )

    local particle_two = ParticleManager:CreateParticle( "particles/dio/end/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Antimage.Blink_in", self:GetCaster() )
end

LinkLuaModifier("modifier_dio_vampire", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dio_vampire_stats", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)

dio_vampire = class({})

function dio_vampire:GetBehavior()
    if self:GetCaster():HasShard() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function dio_vampire:GetManaCost(iLevel)
    return 100
end

function dio_vampire:GetCooldown(iLevel)
    return 60
end

function dio_vampire:OnSpellStart()
    if not IsServer() then return end
    GameRules:BeginNightstalkerNight(20)
end

function dio_vampire:GetIntrinsicModifierName()
    return "modifier_dio_vampire"
end

modifier_dio_vampire = class({})

function modifier_dio_vampire:IsHidden()
    return true
end

function modifier_dio_vampire:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_dio_vampire:OnIntervalThink()
    if not IsServer() then return end
    if not GameRules:IsDaytime() then
    	if not self:GetParent():HasModifier("modifier_dio_vampire_stats") then
    		self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_dio_vampire_stats", {}  )
    	end
    else
    	if self:GetParent():HasModifier("modifier_dio_vampire_stats") then
    		self:GetParent():RemoveModifierByName("modifier_dio_vampire_stats")
    	end
    end
end

modifier_dio_vampire_stats = class({})

function modifier_dio_vampire:IsPurgable()
    return false
end

function modifier_dio_vampire_stats:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
    return declfuncs
end

function modifier_dio_vampire_stats:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_dio_vampire_stats:GetModifierMoveSpeedBonus_Percentage()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_dio_vampire_stats:GetModifierHealthBonus()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("health")
end

function modifier_dio_vampire_stats:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()
    if attacker ~= keys.attacker then
        return
    end
    if attacker:PassivesDisabled() or attacker:IsIllusion() then
        return
    end
    local target = keys.target
    if attacker:GetTeam() == target:GetTeam() then
        return
    end 
    local particle = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( particle )
    self.damage = self:GetAbility():GetSpecialValueFor( "lifesteal" ) / 100
    local damage = keys.damage * self.damage
    self:GetParent():Heal( damage, self:GetAbility() )
end

LinkLuaModifier("modifier_dio_TheWorld", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dio_silence", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)

Dio_TheWorld = class({})

function Dio_TheWorld:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_dio_4")
end

function Dio_TheWorld:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Dio_TheWorld:OnUpgrade()
     if not IsServer() then return end
     if self.the_world and IsValidEntity(self.the_world) and self.the_world:IsAlive() then
        local caster = self:GetCaster()
        local player = caster:GetPlayerID()
        local ability = self
        local level = self:GetLevel()
        local origin_death = self.the_world:GetAbsOrigin()
        local one_ability = self.the_world:FindAbilityByName("Dio_MudaMudaMuda")
        local two_ability = self.the_world:FindAbilityByName("Dio_Za_Warudo")
        local cooldown_one = 0
        local cooldown_two = 0


        if one_ability then
            cooldown_one = one_ability:GetCooldownTimeRemaining()
        end

        if two_ability then
            cooldown_two = two_ability:GetCooldownTimeRemaining()
        end

        self.the_world:Destroy()
        self.the_world = CreateUnitByName("npc_dio_theworld_"..level, origin_death, true, caster, nil, caster:GetTeamNumber())
        self.the_world:SetControllableByPlayer(player, true)
        self.the_world:SetOwner(caster)
        self.the_world:AddNewModifier(self:GetCaster(), self, 'modifier_dio_TheWorld', {})
        self.the_world:AddNewModifier(self:GetCaster(), self, 'modifier_disarmed', {})

        one_ability = self.the_world:FindAbilityByName("Dio_MudaMudaMuda")
        two_ability = self.the_world:FindAbilityByName("Dio_Za_Warudo")

        if one_ability then
            one_ability:StartCooldown(cooldown_one)
        end

        if two_ability then
            two_ability:SetLevel(level)
            two_ability:StartCooldown(cooldown_two)
        end
    end
end

function Dio_TheWorld:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerID()
    local ability = self
    local level = self:GetLevel()
    local origin = caster:GetAbsOrigin() + RandomVector(100)

    if self.the_world and IsValidEntity(self.the_world) and self.the_world:IsAlive() then
        FindClearSpaceForUnit(self.the_world, origin, true)
        self.the_world:SetHealth(self.the_world:GetMaxHealth())
        self.the_world:EmitSound("StandSpawn")
        self.the_world:FindAbilityByName("Dio_Za_Warudo"):SetLevel(level)
    else
        self.the_world = CreateUnitByName("npc_dio_theworld_"..level, origin, true, caster, nil, caster:GetTeamNumber())
        self.the_world:SetControllableByPlayer(player, true)
        self.the_world:SetOwner(self:GetCaster())
        self.the_world:AddNewModifier(self:GetCaster(), self, 'modifier_dio_TheWorld', {})
        self.the_world:AddNewModifier(self:GetCaster(), self, 'modifier_disarmed', {})  
        self.the_world:EmitSound("StandSpawn")
        self.the_world:FindAbilityByName("Dio_Za_Warudo"):SetLevel(level)
    end
end

modifier_dio_TheWorld = class({})

function modifier_dio_TheWorld:IsHidden()
    return true
end

function modifier_dio_TheWorld:IsPurgable()
    return false
end

function modifier_dio_TheWorld:OnCreated(keys)
    self.b_damage = self:GetAbility():GetSpecialValueFor("stand_damage") + ( self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("bonus_damage") )
    self.b_health = self:GetAbility():GetSpecialValueFor("stand_hp")
    self.b_armor = self:GetAbility():GetSpecialValueFor("stand_armor")
    if not IsServer() then return end
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
    self:GetParent():SetBaseMaxHealth(self.b_health)
    self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor)
    self:StartIntervalThink(FrameTime())
end

function modifier_dio_TheWorld:OnRefresh(keys)
    self.b_damage = self:GetAbility():GetSpecialValueFor("stand_damage") + ( self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("bonus_damage") )
    self.b_armor = self:GetAbility():GetSpecialValueFor("stand_armor")
    if not IsServer() then return end
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor)
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
end

function modifier_dio_TheWorld:OnIntervalThink()
    if not IsServer() then return end
    self:OnRefresh()
    local friends = FindUnitsInRadius(
	    self:GetCaster():GetTeamNumber(),
	    self:GetParent():GetOrigin(),
	    nil,
	    900,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_HERO,
	    0,
	    FIND_CLOSEST,
	    false
    )
    for _,target in pairs(friends) do
    	if self:GetParent():GetOwner() == target then
    		self:GetParent():RemoveModifierByName("modifier_dio_silence")
    		return
    	end
    end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_dio_silence', {})
end

function modifier_dio_TheWorld:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }

    return funcs
end

function modifier_dio_TheWorld:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
		if self:GetCaster():HasTalent("special_bonus_birzha_dio_2") then return end
		ApplyDamage({ victim = self:GetCaster(), attacker = params.attacker, damage = 1000000, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
    end
end

modifier_dio_silence = class({})

function modifier_dio_silence:IsHidden()
    return true
end

function modifier_dio_silence:IsPurgable()
    return false
end

function modifier_dio_silence:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

LinkLuaModifier ("modifier_dio_mudamudamuda", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)

Dio_MudaMudaMuda = class({})

function Dio_MudaMudaMuda:GetAbilityTextureName() 
	return "Dio/MudaMudaMuda"
end 

function Dio_MudaMudaMuda:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function Dio_MudaMudaMuda:GetChannelTime()
	return self.BaseClass.GetChannelTime(self)
end

function Dio_MudaMudaMuda:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end
	return true
end

function Dio_MudaMudaMuda:OnSpellStart() 
	local caster = self:GetCaster() 
	local ability = self 
	local target = self:GetCursorTarget()
	local dur = self:GetChannelTime()
	caster:SetAbsOrigin(target:DioMudaMudaMuda())
	FindClearSpaceForUnit(caster, target:DioMudaMudaMuda(), true)
	caster:SetForwardVector(target:GetForwardVector())
	if self.hVictim == nil then
		return
	end
	self.hVictim:AddNewModifier( caster, self, "modifier_dio_mudamudamuda", { duration = self:GetChannelTime() } )
	self.hVictim:Interrupt()
	EmitSoundOn("mudamuda",self:GetCaster())
end

function Dio_MudaMudaMuda:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName( "modifier_dio_mudamudamuda" )
	end
end

modifier_dio_mudamudamuda = class({})

function modifier_dio_mudamudamuda:IsHidden()
	return true
end

function modifier_dio_mudamudamuda:IsPurgable()
    return false
end

function modifier_dio_mudamudamuda:OnCreated( kv )
	self.tick_rate = self:GetAbility():GetSpecialValueFor( "interval_attack" )
	if IsServer() then
		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink( self.tick_rate )
	end
end

function modifier_dio_mudamudamuda:OnDestroy()
	if IsServer() then
		self:GetCaster():InterruptChannel()
		StopSoundOn("mudamuda",self:GetCaster())
	end
end

function modifier_dio_mudamudamuda:OnIntervalThink()
	if IsServer() then
		self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self:GetCaster():GetAttackDamage(),
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
	end
end

function modifier_dio_mudamudamuda:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end


LinkLuaModifier("modifier_Dio_Za_Warudo", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Dio_Za_Warudo_aura", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_NONE)

Dio_Za_Warudo = Dio_Za_Warudo or class({})

function Dio_Za_Warudo:OnSpellStart()
	if IsServer() then
		self:SetLevel(self:GetCaster():GetOwner():FindAbilityByName("Dio_TheWorld"):GetLevel())
		local duration = self:GetSpecialValueFor("duration")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Dio_Za_Warudo_aura", {duration = duration})
		self:GetCaster():EmitSound("dioult")
	end
end

modifier_Dio_Za_Warudo_aura = class({})

function modifier_Dio_Za_Warudo_aura:OnCreated()
	self.parent = self:GetParent()
	self:StartIntervalThink(FrameTime())
	self.radius_effect = 0
	self.particle = ParticleManager:CreateParticle("particles/dio/dio_sphere_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(450, 450, 1))
	self.particle_sphere = ParticleManager:CreateParticle("particles/dio/dio_stand.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle_sphere, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle_sphere, 1, Vector(0, 0, 1))
end

function modifier_Dio_Za_Warudo_aura:OnIntervalThink()
	self.radius_effect = self.radius_effect + 75
    if self.radius_effect >= 450 then
        self.radius_effect = 450
    end
	ParticleManager:SetParticleControl(self.particle_sphere, 1, Vector(self.radius_effect, self.radius_effect, 1))
end

function modifier_Dio_Za_Warudo_aura:OnDestroy()
	ParticleManager:DestroyParticle(self.particle_sphere,true)
	ParticleManager:DestroyParticle(self.particle,true)
	ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_Dio_Za_Warudo_aura:IsAura() return true end
function modifier_Dio_Za_Warudo_aura:IsBuff() return true end

function modifier_Dio_Za_Warudo_aura:GetAuraRadius()
	return self.radius_effect
end

function modifier_Dio_Za_Warudo_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_Dio_Za_Warudo_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end


function modifier_Dio_Za_Warudo_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_Dio_Za_Warudo_aura:GetModifierAura()
	return "modifier_Dio_Za_Warudo"
end

function modifier_Dio_Za_Warudo_aura:GetAuraEntityReject(target)
	if IsServer() then
		if target == self:GetCaster() or target == self:GetCaster():GetOwner() then
			return true
		else
			return false
		end
	end
end

modifier_Dio_Za_Warudo = class({})

function modifier_Dio_Za_Warudo:OnCreated()
	self.parent = self:GetParent()

    if not self.parent.damagetaken then
	    self.parent.damagetaken = 0 
	end
end

function modifier_Dio_Za_Warudo:GetStatusEffectName()
	return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
end

function modifier_Dio_Za_Warudo:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_Dio_Za_Warudo:OnTakeDamage(keys)
    local unit = keys.unit
    local parent = self:GetParent()

    if unit == parent then
        local damage = keys.damage
        self.parent.damagetaken = self.parent.damagetaken + damage
    end
end

function modifier_Dio_Za_Warudo:OnDestroy()
	if IsServer() then
        self:GetParent():AddNewModifier( self:GetAbility():GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = 0.1 }  )
		if self:GetParent():GetHealth() - self.parent.damagetaken <=0 then 
			ApplyDamage({victim = self:GetParent(), attacker = self:GetAbility():GetCaster(), damage = self.parent.damagetaken, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			self.parent.damagetaken = 0 
			return
		end
		ApplyDamage({victim = self:GetParent(), attacker = self:GetAbility():GetCaster(), ability = self:GetAbility(), damage = self.parent.damagetaken, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
		self.parent.damagetaken = 0 
	end
end

function modifier_Dio_Za_Warudo:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true, }
end






LinkLuaModifier("modifier_dio_roller", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_dio_roller_caster", "abilities/heroes/dio.lua", LUA_MODIFIER_MOTION_BOTH)

dio_roller = class({})

function dio_roller:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function dio_roller:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function dio_roller:GetAOERadius()
    return 200
end

function dio_roller:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    self:GetCaster():EmitSound("dio_roda")
    self:GetCaster():SetForwardVector((point - self:GetCaster():GetAbsOrigin()):Normalized())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dio_roller_caster", {x=point.x, y=point.y, z=point.z})
end

modifier_dio_roller_caster = class({})

function modifier_dio_roller_caster:IsHidden() return true end
function modifier_dio_roller_caster:IsPurgable() return false end

function modifier_dio_roller_caster:OnCreated(kv)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.parent = self:GetParent()
    self.z_height = 0
    self.current_time = 0
    self.max_time = 0.4
    self.max_time_fall = 0.3
    self.frametime = FrameTime()
    self.fly = true
    self.x = kv.x
    self.y = kv.y
    self.z = kv.z
    self:StartIntervalThink(FrameTime())
end

function modifier_dio_roller_caster:OnIntervalThink()
    if IsServer() then
        self:VerticalMotion(self.parent, self.frametime)
    end
end

function modifier_dio_roller_caster:EndTransition()
    if IsServer() then
        local origin = self:GetCaster():GetAbsOrigin()
        local dummy = CreateUnitByName("npc_dota_companion", origin, false, nil, nil, self:GetCaster():GetTeamNumber())
        dummy:SetModelScale(0.7)
        dummy:SetForwardVector(self:GetCaster():GetForwardVector())
        dummy:SetAbsOrigin(self:GetParent():GetAbsOrigin())
        dummy:SetOriginalModel("models/roda/roda.vmdl")
        dummy:SetModel("models/roda/roda.vmdl")
        dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_phased", {})
        dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_no_healthbar", {})
        dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invulnerable", {})
        dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_dio_roller", {x=self.x,y=self.y,z=self.z})
    end
end

function modifier_dio_roller_caster:VerticalMotion(unit, dt)
    if IsServer() then
        self.current_time = self.current_time + dt

        local max_height = 300

        if self.current_time <= self.max_time  then
            self.z_height = self.z_height + ((dt / self.max_time) * max_height)
            unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
        end

        if self.fly then
            if self.current_time >= self.max_time then
                self.fly = false
                self:EndTransition()
                self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
            end
        end

        if self.current_time >= self.max_time + 0.2 then
            self.z_height = self.z_height - ((dt / self.max_time) * max_height)
            unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
        end

        if self.current_time >= self.max_time + 0.6 then
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_dio_roller_caster:OnDestroy()
    if IsServer() then
        if self.parent:IsAlive() then
            FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), false)
        end
    end
end

function modifier_dio_roller_caster:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

modifier_dio_roller = class({})

function modifier_dio_roller:IsPurgable() return false end
function modifier_dio_roller:IsHidden() return true end

function modifier_dio_roller:OnCreated( kv )
    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    local position = Vector(kv.x,kv.y,kv.z)
    self.start_h = self:GetParent():GetAbsOrigin().z
    self.pos_end = position
    self.throw_speed = 2500
    self.impact_radius = 200
    self.stun_duration = 0.5
    self.knockback_duration = 1
    self.knockback_distance = 275
    self.knockback_damage = 300
    self.knockback_height = 150
    self.vDirection = position - self:GetCaster():GetOrigin()
    self.flDist = self.vDirection:Length2D()
    self.vDirection.z = 0.0
    self.vDirection = self.vDirection:Normalized()
    self.attach = self:GetCaster():ScriptLookupAttachment( "attach_attack2" )
    self.vSpawnLocation = self:GetCaster():GetAttachmentOrigin( self.attach )
    self.vEndPos = self:GetCaster():GetOrigin() + self.vDirection * self.flDist
    self.nProjHandle = ProjectileManager:CreateLinearProjectile( info )
    self.flTime = self.flDist  / self.throw_speed
    self.flHeight = self.vSpawnLocation.z - GetGroundHeight( self:GetCaster():GetOrigin(), self:GetCaster() )
end

function modifier_dio_roller:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )
    self:GetParent():EmitSound("dio_scepter_stomp")
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for i,enemy in ipairs(units) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = 300, damage_type = DAMAGE_TYPE_MAGICAL})
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = 0.5})
    end
    local particle = ParticleManager:CreateParticle("particles/neutral_fx/ogre_bruiser_smash.vpcf", PATTACH_WORLDORIGIN, nil)
    local origin = self:GetParent():GetAbsOrigin()
    origin = GetGroundPosition(origin, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, Vector(200,200,200))
    self:GetParent():Kill(nil, nil)
end

function modifier_dio_roller:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local origin = self:GetParent():GetAbsOrigin()
    local new_origin = origin + self.vDirection * 2500 * dt
    if ( origin - self.pos_end ):Length2D() <= 2500 * dt then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    me:SetOrigin( new_origin )
end

function modifier_dio_roller:UpdateVerticalMotion( me, dt )
    if not IsServer() then return end
    local vMyPos = me:GetOrigin()
    local flGroundHeight = GetGroundHeight( vMyPos, me )

    


    
    local flHeightChange = (self.flHeight / self.flTime) * dt
    vMyPos.z = math.max( vMyPos.z - flHeightChange, flGroundHeight )
    me:SetOrigin( vMyPos )
end

function modifier_dio_roller:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_dio_roller:OnVerticalMotionInterrupted()
    if not IsServer() then return end
    if not self:IsNull() then
        self:Destroy()
    end
end