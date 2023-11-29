LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_armageddon_casting", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Megumin_armageddon = class ({})

function Megumin_armageddon:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function Megumin_armageddon:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Megumin_armageddon:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Megumin_armageddon:GetAOERadius()
	return self:GetSpecialValueFor("target_radius")
end

function Megumin_armageddon:OnAbilityPhaseStart()
	if not IsServer() then return end
	self.point = self:GetCursorPosition()
	return true
end

function Megumin_armageddon:OnSpellStart()
	if not IsServer() then return end
	self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_armageddon_casting", {duration = self:GetChannelTime()})
end

function Megumin_armageddon:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:Destroy()
    end
end

modifier_armageddon_casting = class ({})
function modifier_armageddon_casting:IsPurgable() return false end
function modifier_armageddon_casting:IsHidden() return true end

function modifier_armageddon_casting:OnCreated(kv)
	if not IsServer() then return end
	self:GetParent():InterruptChannel()
	self:OnIntervalThink()
	self:StartIntervalThink(self.interval)
end

function modifier_armageddon_casting:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():InterruptChannel()
end

function modifier_armageddon_casting:OnIntervalThink()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target_radius = self:GetAbility():GetSpecialValueFor("target_radius")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.multi = self:GetAbility():GetSpecialValueFor("int_multi") + self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_2")
	self.blasts = self:GetAbility():GetSpecialValueFor("blasts") + self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_6")
	self.interval = self:GetAbility():GetChannelTime() / self.blasts
	self.max_offset = self.target_radius - self.radius
	local _x = RandomInt(-self.max_offset, self.max_offset)
	local _y = RandomInt(-self.max_offset, self.max_offset)
	local point = self:GetAbility().point + Vector(_x, _y, 0)

	local particle = ParticleManager:CreateParticle("particles/booom/megumin/bolt.vpcf", PATTACH_WORLDORIGIN, self.caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
	
	local units = FindUnitsInRadius(self.caster:GetTeamNumber(), point, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				
	for _,unit in pairs(units) do
		local damageTable = { victim = unit, attacker = self.caster, damage = self.damage + (self.caster:GetIntellect() / 100 * self.multi), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()}
		ApplyDamage(damageTable)
	end

	EmitSoundOnLocationWithCaster(point, "Hero_Invoker.SunStrike.Ignite.Apex", self.caster)	
end

function modifier_armageddon_casting:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_armageddon_casting:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

LinkLuaModifier("modifier_meteor_fire", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)

megumin_meteor = class ({})

function megumin_meteor:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function megumin_meteor:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function megumin_meteor:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_megumin_1" )
end

function megumin_meteor:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local direction = (target_loc - caster_loc):Normalized()

    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/booom/megumin/meteor/megumin_meteor.vpcf",
		vSpawnOrigin		= caster_loc,
		fDistance			= 800,
		fStartRadius		= 120,
		fEndRadius			= 120,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting 	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit		= false,
		vVelocity			= Vector(direction.x, direction.y, 0) * 1000,
		bProvidesVision		= true,
		iVisionRadius		= 200,
		iVisionTeamNumber	= caster:GetTeamNumber(),
    }

    ProjectileManager:CreateLinearProjectile(projectile)

    caster:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
end

function megumin_meteor:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_5")
	local fire_duration = self:GetSpecialValueFor("fire_duration")
	
    if target then
		target:EmitSound("Hero_WarlockGolem.Attack")
		target:AddNewModifier(caster, self, "modifier_birzha_stunned_purge", {duration = stun_duration * (1-target:GetStatusResistance())})
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:AddNewModifier(caster, self, "modifier_meteor_fire", {duration = fire_duration * (1 - target:GetStatusResistance())})
    end
end

modifier_meteor_fire = class ({})

function modifier_meteor_fire:IsPurgable() return false end
function modifier_meteor_fire:IsPurgeException() return true end

function modifier_meteor_fire:OnCreated( kv )
	if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_meteor_fire:OnIntervalThink()
    if not IsServer() then return end
    local fire_damage = self:GetAbility():GetSpecialValueFor("fire_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_1")
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = fire_damage * 0.5, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_meteor_fire:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_meteor_fire:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_mana_aura_active_regeneration", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_megumin_mana_aura", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_megumin_aura_2", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)

Megumin_mana_aura = class ({})

function Megumin_mana_aura:GetIntrinsicModifierName()
    return "modifier_megumin_mana_aura"
end

function Megumin_mana_aura:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function Megumin_mana_aura:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Megumin_mana_aura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Megumin_mana_aura:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local caster_team = caster:GetTeamNumber()
	local radius = self:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius( caster_team, caster_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	self:GetCaster():EmitSound("meguminheal")	

	for _, unit in ipairs(targets) do
		unit:AddNewModifier(caster, self, "modifier_mana_aura_active_regeneration", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_mana_aura_active_regeneration = class ({})

function modifier_mana_aura_active_regeneration:IsPurgable() return false end

function modifier_mana_aura_active_regeneration:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
	}
	return funcs
end

function modifier_mana_aura_active_regeneration:GetModifierTotalPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen_active")
end

function modifier_mana_aura_active_regeneration:OnCreated()
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle("particles/econ/events/winter_major_2016/radiant_fountain_regen_wm_lvl3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(self.particle, false, false, -1, false, false)
end

modifier_megumin_mana_aura = class ({})

function modifier_megumin_mana_aura:IsAura() return true end
function modifier_megumin_mana_aura:IsAuraActiveOnDeath() return false end
function modifier_megumin_mana_aura:IsBuff() return true end
function modifier_megumin_mana_aura:IsHidden() return true end
function modifier_megumin_mana_aura:IsPermanent() return true end
function modifier_megumin_mana_aura:IsPurgable() return false end

function modifier_megumin_mana_aura:GetAuraRadius()
    return 999999
end

function modifier_megumin_mana_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_megumin_mana_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_megumin_mana_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_megumin_mana_aura:GetModifierAura()
    return "modifier_megumin_aura_2"
end

modifier_megumin_aura_2 = class ({})

function modifier_megumin_aura_2:IsHidden() return false end
function modifier_megumin_aura_2:IsPurgable() return false end

function modifier_megumin_aura_2:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function modifier_megumin_aura_2:GetModifierConstantManaRegen()
	local multi = 1
	if self:GetCaster():HasTalent("special_bonus_birzha_megumin_3") then
		multi = self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_3")
	end
	return self:GetAbility():GetSpecialValueFor("mana_regen_passive") * multi
end

function modifier_megumin_aura_2:GetModifierSpellAmplify_Percentage()
	local multi = 1
	if self:GetCaster():HasTalent("special_bonus_birzha_megumin_3") then
		multi = self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_3")
	end
	return self:GetAbility():GetSpecialValueFor("spell_damage") * multi
end

LinkLuaModifier("modifier_ExplosionMagic", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ExplosionMagic_immunity", "abilities/heroes/megumin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

Megumin_ExplosionMagic = class({})

function Megumin_ExplosionMagic:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level) + self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_4")
end

function Megumin_ExplosionMagic:GetCastRange(location, target)
    return self:GetSpecialValueFor( "effect_radius" )
end

function Megumin_ExplosionMagic:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Megumin_ExplosionMagic:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

function Megumin_ExplosionMagic:GetChannelTime()
    return self.BaseClass.GetChannelTime(self) + self:GetCaster():FindTalentValue("special_bonus_birzha_megumin_8")
end

function Megumin_ExplosionMagic:OnAbilityPhaseStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ExplosionMagic_immunity", { duration = self:GetChannelTime() } )
	local particle = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
	ParticleManager:SetParticleControl( particle, 1, Vector( 250, 250, 250 ) )
	ParticleManager:SetParticleControl( particle, 15, Vector( 176, 224, 230 ) )
	ParticleManager:ReleaseParticleIndex(particle)
	return true
end

function Megumin_ExplosionMagic:OnSpellStart()
	if not IsServer() then return end	
	self.effect_radius = self:GetSpecialValueFor("effect_radius")
	self.interval = self:GetSpecialValueFor("interval")
	self.mana = self:GetCaster():GetMana() / 100 * self:GetSpecialValueFor("scepter_manacost")
	self.mana_damage = self.mana / self:GetSpecialValueFor("scepter_damage")
	self.flNextCast = 0.0
	if self:GetCaster():HasScepter() then
		self:GetCaster():SetMana(self:GetCaster():GetMana() - self.mana)
	end
	self:GetCaster():EmitSound("megumin")
end

function Megumin_ExplosionMagic:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
	self:GetCaster():StopSound("megumin")
	self:GetCaster():RemoveModifierByName("modifier_ExplosionMagic_immunity")
	if not self:GetCaster():HasShard() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = self:GetSpecialValueFor("stun_duration") } )
	end 
end

function Megumin_ExplosionMagic:OnChannelThink( flInterval )
	if not IsServer() then return end

	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	if #targets >= 1 then	
		for _,unit in pairs(targets) do

			local debuff_duration = self:GetSpecialValueFor("debuff_duration")
			local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
			local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
			local distance_knockback = (self:GetSpecialValueFor("radius") - distance) + 150

			if not unit:HasModifier("modifier_generic_knockback_lua") then
				unit:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.3, distance = distance_knockback, height = 0, direction_x = direction.x, direction_y = direction.y})
				unit:AddNewModifier( self:GetCaster(), self, "modifier_disarmed", { duration = debuff_duration * (1-unit:GetStatusResistance()) } )
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
				ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
				ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( self:GetSpecialValueFor("radius")+100, self:GetSpecialValueFor("radius")+100, self:GetSpecialValueFor("radius")+100 ) )
			end
		end
	end
	
	self.flNextCast = self.flNextCast + flInterval

	if self.flNextCast >= self.interval  then
		local nMaxAttempts = 7
		local nAttempts = 0
		local vPos = nil
		repeat
			vPos = self:GetCaster():GetOrigin() + RandomVector( RandomInt( self:GetSpecialValueFor("radius"), self.effect_radius ) )
			local hThinkersNearby = Entities:FindAllByClassnameWithin( "npc_dota_thinker", vPos, 600 )
			local hOverlappingWrathThinkers = {}

			for _, hThinker in pairs( hThinkersNearby ) do
				if ( hThinker:HasModifier( "modifier_ExplosionMagic" ) ) then
					table.insert( hOverlappingWrathThinkers, hThinker )
				end
			end
			nAttempts = nAttempts + 1
			if nAttempts >= nMaxAttempts then
				break
			end
		until ( #hOverlappingWrathThinkers == 0 )

		CreateModifierThinker( self:GetCaster(), self, "modifier_ExplosionMagic", {}, vPos, self:GetCaster():GetTeamNumber(), false )
		self.flNextCast = self.flNextCast - self.interval
	end
end

modifier_ExplosionMagic = class({})

function modifier_ExplosionMagic:IsPurgable()
	return false
end

function modifier_ExplosionMagic:IsHidden()
	return true
end

function modifier_ExplosionMagic:OnCreated(kv)
	if not IsServer() then return end
	self.delay = self:GetAbility():GetSpecialValueFor( "delay" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if self:GetCaster():HasScepter() then
		self.blast_damage = self:GetAbility():GetSpecialValueFor( "blast_damage" ) + self:GetAbility().mana_damage
	else
		self.blast_damage = self:GetAbility():GetSpecialValueFor( "blast_damage" )
	end
	self:StartIntervalThink( self.delay )
	local nFXIndex = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.delay, 1.0 ) )
	ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
	ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

function modifier_ExplosionMagic:OnIntervalThink()
	if not IsServer() then return end

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( self.radius, self.radius, self.radius ) )
	ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
	ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	self:GetParent():EmitSound("Hero_Techies.Suicide")

	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
	for _,enemy in pairs( enemies ) do
		if enemy ~= nil then
			local damageInfo = { victim = enemy, attacker = self:GetCaster(), damage = self.blast_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() }
			ApplyDamage( damageInfo )
		end
	end

	UTIL_Remove( self:GetParent() )
end

modifier_ExplosionMagic_immunity = class({})

function modifier_ExplosionMagic_immunity:IsHidden()
	return true
end

function modifier_ExplosionMagic_immunity:IsPurgable()
	return false
end

function modifier_ExplosionMagic_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_ExplosionMagic_immunity:CheckState()
	local state = 
	{
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end