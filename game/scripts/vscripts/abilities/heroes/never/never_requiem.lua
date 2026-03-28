LinkLuaModifier( "modifier_never_requiem", "abilities/heroes/never/never_requiem.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_requiem_scepter", "abilities/heroes/never/never_requiem.lua", LUA_MODIFIER_MOTION_NONE )

never_requiem = class({})
never_requiem.s = 0

function never_requiem:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", context)
	PrecacheResource("particle", "particles/never/never_requiem_cast.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", context)
	PrecacheResource("particle", "particles/never/never_requiem_wings.vpcf", context)
    PrecacheResource("particle", "particles/never/soul_requiemofsouls_line.vpcf", context)
    PrecacheResource("particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context)
	PrecacheResource("particle", "particles/never/never_requiemofsouls_line.vpcf", context)
	PrecacheResource("particle", "particles/never/never_requiem_arcanaofsouls_line.vpcf", context)
end

function never_requiem:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/UltimateArcana"
	end
	return "Never/Ultimate"
end

function never_requiem:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function never_requiem:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function never_requiem:OnAbilityPhaseStart()
    if self.s % 5 == 0 then
        self:GetCaster():EmitSound( "never_requiem_start_1")
    elseif self.s % 5 == 1 then
        self:GetCaster():EmitSound( "never_requiem_start_2")
    elseif self.s % 5 == 2 then
        self:GetCaster():EmitSound( "never_requiem_start_3")
    elseif self.s % 5 == 3 then
        self:GetCaster():EmitSound( "never_requiem_start_4")
    elseif self.s % 5 == 4 then
        self:GetCaster():EmitSound( "never_requiem_start_5")
    end
	self:PlayEffects1()
	return true
end

function never_requiem:OnAbilityPhaseInterrupted()
    if self.s % 5 == 0 then
        self:GetCaster():StopSound( "never_requiem_start_1")
    elseif self.s % 5 == 1 then
        self:GetCaster():StopSound( "never_requiem_start_2")
    elseif self.s % 5 == 2 then
        self:GetCaster():StopSound( "never_requiem_start_3")
    elseif self.s % 5 == 3 then
        self:GetCaster():StopSound( "never_requiem_start_4")
    elseif self.s % 5 == 4 then
        self:GetCaster():StopSound( "never_requiem_start_5")
    end
	self:StopEffects1( false )
end

function never_requiem:OnSpellStart()
    if self.s % 5 == 0 then
        EmitSoundOn( "never_requiem_1", self:GetCaster() )
        StopSoundOn( "never_requiem_start_1", self:GetCaster() )
    elseif self.s % 5 == 1 then
        EmitSoundOn( "never_requiem_2", self:GetCaster() )
        StopSoundOn( "never_requiem_start_2", self:GetCaster() )
    elseif self.s % 5 == 2 then
        EmitSoundOn( "never_requiem_3", self:GetCaster() )
        StopSoundOn( "never_requiem_start_3", self:GetCaster() )
    elseif self.s % 5 == 3 then
        EmitSoundOn( "never_requiem_4", self:GetCaster() )
        StopSoundOn( "never_requiem_start_4", self:GetCaster() )
    elseif self.s % 5 == 4 then
        EmitSoundOn( "never_requiem_5", self:GetCaster() )
        StopSoundOn( "never_requiem_start_5", self:GetCaster() )
    end
    self.s = self.s + 1

	local soul_per_line = self:GetSpecialValueFor("requiem_soul_conversion")
	local lines = 0
	local modifier = self:GetCaster():FindModifierByNameAndCaster( "modifier_never_innate", self:GetCaster() )
	if modifier~=nil then
		lines = math.floor(modifier:GetStackCount() / soul_per_line) 
	end

	self:Explode( lines )

	if self:GetCaster():HasScepter() then
		local explodeDuration = self:GetSpecialValueFor("requiem_radius") / self:GetSpecialValueFor("requiem_line_speed")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_never_requiem_scepter", {lineDuration = explodeDuration, lineNumber = lines})
	end
end

function never_requiem:OnProjectileHit_ExtraData( hTarget, vLocation, params )
	if hTarget ~= nil then
		pass = false
		if hTarget:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then
			pass = true
		end
		if pass then
			if params and params.scepter then

				damage = self.damage * (self.damage_pct/100)

				if hTarget:IsHero() then
					local modifier = self:RetATValue( params.modifier )
					modifier:AddTotalHeal( damage )
				end
			end

			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
			}
			ApplyDamage( damage )

			if self:GetCaster():IsAlive() then
            	local mod = hTarget:FindModifierByNameAndCaster("modifier_never_requiem", self:GetCaster())
            	if not mod then
				    hTarget:AddNewModifier(	self:GetCaster(), self,"modifier_never_requiem", { duration = self.min_duration })
            	else
            	    local mod_duration = mod:GetDuration()
            	    if mod_duration + self.min_duration < self.max_duration then 
            	        mod:SetDuration(mod_duration + self.min_duration, true)
            	    else
            	        mod:SetDuration(self.max_duration, true)
            	    end
            	end
			end
            hTarget:EmitSound("Hero_Nevermore.RequiemOfSouls.Damage")
		end
	end
	return false
end

function never_requiem:OnOwnerDied()

	if self:GetLevel()<1 then return end

	local soul_per_line = self:GetSpecialValueFor("requiem_soul_conversion")

	local lines = 0
	local modifier = self:GetCaster():FindModifierByNameAndCaster( "modifier_never_innate", self:GetCaster() )
	if modifier~=nil then
		lines = math.floor(modifier:GetStackCount() / soul_per_line) 
	end

	self:Explode( lines/2 )
end

function never_requiem:Explode( lines )

	self.damage =  self:GetSpecialValueFor("requiem_damage")
    self.min_duration = self:GetSpecialValueFor("requiem_slow_duration")
	self.max_duration = self:GetSpecialValueFor("requiem_slow_duration_max")

	local projectile_name = "particles/never/never_requiemofsouls_line.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		projectile_name = "particles/never/never_requiem_arcanaofsouls_line.vpcf"
	end
	local line_length = self:GetSpecialValueFor("requiem_radius")
	local width_start = self:GetSpecialValueFor("requiem_line_width_start")
	local width_end = self:GetSpecialValueFor("requiem_line_width_end")
	local line_speed = self:GetSpecialValueFor("requiem_line_speed")

	local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
	local delta_angle = 360/lines
	for i=0,lines-1 do

		local facing_angle_deg = initial_angle_deg + delta_angle * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
		local velocity = facing_vector * line_speed

		local info = {
			Source = self:GetCaster(),
			Ability = self,
			EffectName = projectile_name,
			vSpawnOrigin = self:GetCaster():GetOrigin(),
			fDistance = line_length,
			vVelocity = velocity,
			fStartRadius = width_start,
			fEndRadius = width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bReplaceExisting = false,
			bProvidesVision = false,
		}
		ProjectileManager:CreateLinearProjectile( info )
	end

	self:StopEffects1( true )
	self:PlayEffects2( lines )
end

function never_requiem:Implode( lines, modifier )
	self.damage_pct = self:GetSpecialValueFor("requiem_damage_pct_scepter")
	self.damage_heal_pct = self:GetSpecialValueFor("requiem_heal_pct_scepter")

	local modifierAT = self:AddATValue( modifier )
	modifier.identifier = modifierAT

	local projectile_name = "particles/never/never_requiemofsouls_line.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		projectile_name = "particles/never/never_requiem_arcanaofsouls_line.vpcf"
	end
	local line_length = self:GetSpecialValueFor("requiem_radius")
	local width_start = self:GetSpecialValueFor("requiem_line_width_end")
	local width_end = self:GetSpecialValueFor("requiem_line_width_start")
	local line_speed = self:GetSpecialValueFor("requiem_line_speed")

	local initial_angle_deg = self:GetCaster():GetAnglesAsVector().y
	local delta_angle = 360/lines
	for i=0,lines-1 do

		local facing_angle_deg = initial_angle_deg + delta_angle * i
		if facing_angle_deg>360 then facing_angle_deg = facing_angle_deg - 360 end
		local facing_angle = math.rad(facing_angle_deg)
		local facing_vector = Vector( math.cos(facing_angle), math.sin(facing_angle), 0 ):Normalized()
		local velocity = facing_vector * line_speed

		local info = {
			Source = self:GetCaster(),
			Ability = self,
			EffectName = projectile_name,
			vSpawnOrigin = self:GetCaster():GetOrigin() + facing_vector * line_length,
			fDistance = line_length,
			vVelocity = -velocity,
			fStartRadius = width_start,
			fEndRadius = width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_SPELL_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bReplaceExisting = false,
			bProvidesVision = false,
			ExtraData = {
				scepter = true,
				modifier = modifierAT,
			}
		}
		ProjectileManager:CreateLinearProjectile( info )
	end
end

function never_requiem:PlayEffects1()

	local particle_precast = "particles/units/heroes/hero_nevermore/nevermore_wings.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		particle_precast = "particles/never/never_requiem_wings.vpcf"
	end
	local sound_precast = "Hero_Nevermore.RequiemOfSoulsCast"

	self.effect_precast = ParticleManager:CreateParticle( particle_precast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )	

	self:GetCaster():EmitSound(sound_precast)
	self:GetCaster():StartGesture("ACT_DOTA_CAST_ABILITY_6")
end
function never_requiem:StopEffects1( success )
	local sound_precast = "Hero_Nevermore.RequiemOfSoulsCast"

	if not success then
		ParticleManager:DestroyParticle( self.effect_precast, true )
		StopSoundOn(sound_precast, self:GetCaster())
	end

	ParticleManager:ReleaseParticleIndex( self.effect_precast )

	self:GetCaster():FadeGesture("ACT_DOTA_CAST_ABILITY_6")
end

function never_requiem:PlayEffects2( lines )
	local particle_cast = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		particle_cast = "particles/never/never_requiem_cast.vpcf"
	end
	local sound_cast = "Hero_Nevermore.RequiemOfSouls"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( lines, 0, 0 ) )
	ParticleManager:SetParticleControlForward( effect_cast, 2, self:GetCaster():GetForwardVector() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn(sound_cast, self:GetCaster())
end

function never_requiem:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end

function never_requiem:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end

function never_requiem:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end

function never_requiem:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	return ret
end

function never_requiem:DelATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
end

modifier_never_requiem = class({})

function modifier_never_requiem:IsDebuff() return true end
function modifier_never_requiem:IsPurgable() return true end

function modifier_never_requiem:OnCreated()
    if not IsServer() then return end
    self.cpos = self:GetCaster():GetAbsOrigin()
    self:StartIntervalThink(0.05)
end

function modifier_never_requiem:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent() or self:GetParent():IsNull() or not self:GetParent():IsAlive() then return end
    if not self:GetCaster() or self:GetCaster():IsNull() or not self:GetCaster():IsAlive() then return end

    local ppos = self:GetParent():GetAbsOrigin()

    local dir = ppos - self.cpos
    dir.z = 0
    local len = dir:Length2D()
    if len < 1 then
        dir = self:GetParent():GetForwardVector()
		dir.z = 0
    else
        dir = dir / len
    end

    local dest = ppos + dir * 300

    if not self:GetParent():IsDebuffImmune() then
        self:GetParent():MoveToPosition(dest)
    end
end

function modifier_never_requiem:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
end

function modifier_never_requiem:CheckState()
    return {
        [MODIFIER_STATE_FEARED]              = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED]  = true,
    }
end

function modifier_never_requiem:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_never_requiem:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("requiem_reduction_mres")
end

function modifier_never_requiem:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("requiem_reduction_ms")
end

modifier_never_requiem_scepter = class({})


function modifier_never_requiem_scepter:IsHidden() return true end
function modifier_never_requiem_scepter:IsPurgable() return false end
function modifier_never_requiem_scepter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_never_requiem_scepter:OnCreated( kv )
	self.lines = kv.lineNumber
	self.duration = kv.lineDuration

	self.heal = 0

	if IsServer() then
		self:StartIntervalThink( self.duration )
	end
end

function modifier_never_requiem_scepter:OnRefresh( kv )
end

function modifier_never_requiem_scepter:OnDestroy()
	if IsServer() then
		if self.identifier then
			self:GetAbility():DelATValue( self.identifier )
		end
	end
end
function modifier_never_requiem_scepter:OnIntervalThink()
	if not self.afterImplode then
		self.afterImplode = true
		self:GetAbility():Implode( self.lines, self )
		local sound_cast = "Hero_Nevermore.RequiemOfSouls"
		EmitSoundOn(sound_cast, self:GetParent())
	else
		self:GetParent():Heal( self.heal, self:GetAbility() )
		if self.heal > 0 then
			self:PlayEffects()
		end
		self:Destroy()
	end
end

function modifier_never_requiem_scepter:AddTotalHeal( value )
	self.heal = self.heal + value
end

function modifier_never_requiem_scepter:PlayEffects()
	local particle_cast = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end