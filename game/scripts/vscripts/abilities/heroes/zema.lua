LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Zema_MagicDamage_debuff", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)

Zema_CosmoTeleport = class({})

function Zema_CosmoTeleport:GetCooldown(level)
	return (self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_zema_8")) / ( self:GetCaster():GetCooldownReduction())
end

function Zema_CosmoTeleport:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Zema_CosmoTeleport:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Zema_CosmoTeleport:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    return true;
end

function Zema_CosmoTeleport:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("blink_range") + self:GetCaster():FindTalentValue("special_bonus_birzha_zema_1")
    local direction = (point - origin)
    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end
    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )
    ProjectileManager:ProjectileDodge(self:GetCaster())
    self:PlayEffects( origin, direction )

    if self:GetCaster():HasShard() then
    	local ability_magic = self:GetCaster():FindAbilityByName("Zema_MagicDamage")
    	if ability_magic and ability_magic:GetLevel() > 0 then
    		local radius = self:GetSpecialValueFor("shard_radius")
    		ability_magic:StartAbility(self:GetCaster():GetAbsOrigin(), radius)
    	end
    end
end

function Zema_CosmoTeleport:PlayEffects( origin, direction )
    local particle_one = ParticleManager:CreateParticle( "particles/zema/zema_cosmoteleport.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    EmitSoundOnLocationWithCaster( origin, "Hero_Antimage.Blink_out", self:GetCaster() )

    local particle_two = ParticleManager:CreateParticle( "particles/econ/events/ti8/blink_dagger_ti8_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Antimage.Blink_in", self:GetCaster() )
end

LinkLuaModifier("modifier_Zema_Cosmo_Ray_caster_dummy", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Zema_Cosmo_Ray_dummy_unit_thinker", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Zema_Cosmo_Ray_dummy_buff", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Zema_Cosmo_Ray_buff", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Zema_Cosmo_Ray_debuff", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)

Zema_Cosmo_Ray = class({})

function Zema_Cosmo_Ray:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Zema_Cosmo_Ray:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Zema_Cosmo_Ray:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Zema_Cosmo_Ray:OnUpgrade()
	if not IsServer() then return end
	local ray_stop = self:GetCaster():FindAbilityByName("Zema_cosmo_ray_stop")
	if ray_stop then
		ray_stop:SetLevel(1)
	end
end

function Zema_Cosmo_Ray:OnSpellStart()
	if not IsServer() then return end
	local caster	= self:GetCaster()
	local ability	= self
	local pathLength					= 1300
	local max_duration 					= self:GetSpecialValueFor("duration")
	local forwardMoveSpeed				= 250
	local turnRateInitial				= 250
	local turnRate						= 20
	if self:GetCaster():HasTalent("special_bonus_birzha_zema_4") then
		turnRate = 180
	end
	local initialTurnDuration			= 0.75
	local vision_radius					= 192 / 2
	local numVision						= math.ceil( pathLength / vision_radius )
	local casterOrigin	= caster:GetAbsOrigin()
	caster:AddNewModifier(caster, ability, "modifier_Zema_Cosmo_Ray_caster_dummy", { duration = max_duration })
	caster.sun_ray_hp_at_start = caster:GetHealth()
	local pfx = ParticleManager:CreateParticle( "particles/zema/phoenix_sunray.vpcf", PATTACH_WORLDORIGIN, nil )
	local attach_point = caster:ScriptLookupAttachment( "attach_head" )
	StartSoundEvent( "Hero_Phoenix.SunRay.Beam", endcap )
	StartSoundEvent("Hero_Phoenix.SunRay.Cast", caster)
	turnRateInitial	= turnRateInitial	/ (1/30) * 0.03
	turnRate		= turnRate			/ (1/30) * 0.03
	local deltaTime = 0.03
	local lastAngles = caster:GetAngles()
	local isInitialTurn = true
	local elapsedTime = 0.0

	caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )
			ParticleManager:SetParticleControl(pfx, 0, caster:GetAttachmentOrigin(attach_point))

			if not caster:HasModifier( "modifier_Zema_Cosmo_Ray_caster_dummy" ) then
				if pfx then
					ParticleManager:DestroyParticle( pfx, false )
				end
				StopSoundEvent( "Hero_Phoenix.SunRay.Beam", endcap )
				caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
				return nil
			end

			local pos = caster:GetAbsOrigin()
			GridNav:DestroyTreesAroundPoint(pos, 128, false)

			local deltaYawMax
			if isInitialTurn then
				deltaYawMax = turnRateInitial * deltaTime
			else
				deltaYawMax = turnRate * deltaTime
			end
			local currentAngles	= caster:GetAngles()
			local deltaYaw		= RotationDelta( lastAngles, currentAngles ).y
			local deltaYawAbs	= math.abs( deltaYaw )

			if deltaYawAbs > deltaYawMax then
				local yawSign = (deltaYaw < 0) and -1 or 1
				local yaw = lastAngles.y + deltaYawMax * yawSign

				currentAngles.y = yaw
				caster:SetAngles( currentAngles.x, currentAngles.y, currentAngles.z )
			end

			lastAngles = currentAngles
			elapsedTime = elapsedTime + deltaTime
			if isInitialTurn then
				if deltaYawAbs == 0 then
					isInitialTurn = false
				end
				if elapsedTime >= initialTurnDuration then
					isInitialTurn = false
				end
			end

			local casterOrigin	= caster:GetAbsOrigin()
			local casterForward	= caster:GetForwardVector()
			local endcapPos = casterOrigin + casterForward * pathLength
			endcapPos = GetGroundPosition( endcapPos, nil )
			endcapPos.z = endcapPos.z + 92
			ParticleManager:SetParticleControl( pfx, 1, endcapPos )

			local units = FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin() + caster:GetForwardVector() * 32 , endcapPos, nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
			for _,unit in pairs(units) do
				unit:AddNewModifier(caster, ability, "modifier_Zema_Cosmo_Ray_dummy_buff", { duration = ability:GetSpecialValueFor("tick_interval") } )
			end
			for i=1, numVision do
				AddFOWViewer(caster:GetTeamNumber(), ( casterOrigin + casterForward * ( vision_radius * 2 * (i-1) ) ), vision_radius, deltaTime, false)
			end
			return deltaTime

	end, 0.0 )
end

modifier_Zema_Cosmo_Ray_caster_dummy = class({})

function modifier_Zema_Cosmo_Ray_caster_dummy:IsDebuff()			return false end
function modifier_Zema_Cosmo_Ray_caster_dummy:IsHidden() 			return true  end
function modifier_Zema_Cosmo_Ray_caster_dummy:IsPurgable() 		return false end
function modifier_Zema_Cosmo_Ray_caster_dummy:RemoveOnDeath() 	return true  end

function modifier_Zema_Cosmo_Ray_caster_dummy:CheckState()
	return
	{ 	
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true
	}
end

function modifier_Zema_Cosmo_Ray_caster_dummy:GetEffectName()
	return "particles/units/heroes/hero_phoenix/phoenix_sunray_mane.vpcf"
end

function modifier_Zema_Cosmo_Ray_caster_dummy:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	StartSoundEvent("Hero_Phoenix.SunRay.Loop", caster)
	self.pfx_sunray_flare = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_sunray_flare.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( self.pfx_sunray_flare, 9, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true )
	local main_ability_name	= "Zema_Cosmo_Ray"
	local sub_ability_name	= "Zema_cosmo_ray_stop"
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
	self:StartIntervalThink(ability:GetSpecialValueFor("tick_interval"))
end

function modifier_Zema_Cosmo_Ray_caster_dummy:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	caster:AddNewModifier(caster, ability, "modifier_Zema_Cosmo_Ray_dummy_unit_thinker", { duration = ability:GetSpecialValueFor("tick_interval") * 1.9 })
end

function modifier_Zema_Cosmo_Ray_caster_dummy:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	StartSoundEvent("Hero_Phoenix.SunRay.Stop", caster)
	StopSoundEvent( "Hero_Phoenix.SunRay.Loop", caster)
	if self.pfx_sunray_flare then
		ParticleManager:DestroyParticle(self.pfx_sunray_flare, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_sunray_flare)
	end
	local main_ability_name	= "Zema_cosmo_ray_stop"
	local sub_ability_name	= "Zema_Cosmo_Ray"
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
	caster:SetContextThink( DoUniqueString("waitToFindClearSpace"), function ( )
			return 0.1
	end, 0 )
end

modifier_Zema_Cosmo_Ray_dummy_unit_thinker = class({})

function modifier_Zema_Cosmo_Ray_dummy_unit_thinker:IsDebuff()				return false end
function modifier_Zema_Cosmo_Ray_dummy_unit_thinker:IsHidden() 				return true end
function modifier_Zema_Cosmo_Ray_dummy_unit_thinker:IsPurgable() 				return false end
function modifier_Zema_Cosmo_Ray_dummy_unit_thinker:RemoveOnDeath() 			return true end

function modifier_Zema_Cosmo_Ray_dummy_unit_thinker:OnCreated()
	if not IsServer() then
		return
	end
	self:SetStackCount(1)
end

function modifier_Zema_Cosmo_Ray_dummy_unit_thinker:OnRefresh()
	if not IsServer() then
		return
	end
	self:IncrementStackCount()
end

modifier_Zema_Cosmo_Ray_dummy_buff = class({})

function modifier_Zema_Cosmo_Ray_dummy_buff:IsDebuff()				return false end
function modifier_Zema_Cosmo_Ray_dummy_buff:IsHidden() 				return true end
function modifier_Zema_Cosmo_Ray_dummy_buff:IsPurgable() 				return false end
function modifier_Zema_Cosmo_Ray_dummy_buff:RemoveOnDeath() 			return true end

function modifier_Zema_Cosmo_Ray_dummy_buff:OnCreated()
	self.tick_interval	= self:GetAbility():GetSpecialValueFor("tick_interval")
	if not IsServer() then
		return
	end
	self:StartIntervalThink( self.tick_interval )
end

function modifier_Zema_Cosmo_Ray_dummy_buff:OnIntervalThink()
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	target:AddNewModifier(caster, ability, "modifier_Zema_Cosmo_Ray_debuff", { duration = self.tick_interval * 1.9 } )
end

modifier_Zema_Cosmo_Ray_debuff = class({})

function modifier_Zema_Cosmo_Ray_debuff:IsDebuff()				return false end
function modifier_Zema_Cosmo_Ray_debuff:IsHidden() 				return true end
function modifier_Zema_Cosmo_Ray_debuff:IsPurgable() 				return false end
function modifier_Zema_Cosmo_Ray_debuff:IsPurgeException() 		return false end
function modifier_Zema_Cosmo_Ray_debuff:IsStunDebuff() 			return false end
function modifier_Zema_Cosmo_Ray_debuff:RemoveOnDeath() 			return true end

function modifier_Zema_Cosmo_Ray_debuff:GetEffectName() return "particles/zema/phoenix_sunray_debuff.vpcf" end

function modifier_Zema_Cosmo_Ray_debuff:OnCreated()
	self.tick_interval	= self:GetAbility():GetSpecialValueFor("tick_interval")
	self.duration		= self:GetAbility():GetSpecialValueFor("duration")
	self.base_damage	= self:GetAbility():GetSpecialValueFor("base_dmg")
	if not IsServer() then return end
	if self:GetStackCount() < 1 then
		self:SetStackCount(1)
	end
	local ability = self:GetAbility()
	self:StartIntervalThink( self.tick_interval )
end

function modifier_Zema_Cosmo_Ray_debuff:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_Zema_Cosmo_Ray_debuff:OnIntervalThink()
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_Zema_Cosmo_Ray_dummy_unit_thinker") then
		return
	end
	local num_stack = caster:FindModifierByName("modifier_Zema_Cosmo_Ray_dummy_unit_thinker"):GetStackCount()
	local taker = self:GetParent()
	local tick_sum = self.duration / self.tick_interval
	local base_dmg = self.base_damage * self.tick_interval

	if self:GetCaster():HasTalent("special_bonus_birzha_zema_5") then
		base_dmg = base_dmg + ((self:GetCaster():FindTalentValue("special_bonus_birzha_zema_5") / 100 * self:GetParent():GetMaxHealth()) * self.tick_interval)
	end

	ApplyDamage({ victim = taker, attacker = self:GetCaster(), damage = base_dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })

	local pfx = ParticleManager:CreateParticle( "particles/zema/phoenix_sunray_debuff.vpcf", PATTACH_ABSORIGIN, taker )
	ParticleManager:SetParticleControlEnt( pfx, 1, taker, PATTACH_POINT_FOLLOW, "attach_hitloc", taker:GetAbsOrigin(), true )
	ParticleManager:DestroyParticle( pfx, false )
	ParticleManager:ReleaseParticleIndex( pfx )
end

Zema_cosmo_ray_stop = class({})

function Zema_cosmo_ray_stop:OnSpellStart()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_Zema_Cosmo_Ray_caster_dummy")
end

Zema_MagicDamage = class({})

function Zema_MagicDamage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Zema_MagicDamage:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Zema_MagicDamage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Zema_MagicDamage:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Zema_MagicDamage:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    self:StartAbility(point, radius)
end

function Zema_MagicDamage:StartAbility(point, radius)
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_zema_2")
    local units = FindUnitsInRadius( self:GetCaster():GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
    self:GetCaster():EmitSound("DOTA_Item.EtherealBlade.Activate")

    local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( pfx, 0, point )
	ParticleManager:SetParticleControl( pfx, 1, Vector( radius, 0, 0 ) )

	for _,target in pairs (units) do
		target:AddNewModifier(self:GetCaster(), self, "modifier_Zema_MagicDamage_debuff", {duration = duration * (1-target:GetStatusResistance())})
		ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self })
	end
end

modifier_Zema_MagicDamage_debuff = class({})

function modifier_Zema_MagicDamage_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_Zema_MagicDamage_debuff:CheckState()
	return
	{ 
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_Zema_MagicDamage_debuff:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("resist_debuff") + self:GetCaster():FindTalentValue("special_bonus_birzha_zema_3")
end

function modifier_Zema_MagicDamage_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_Zema_MagicDamage_debuff:StatusEffectPriority()
    return 10
end

function modifier_Zema_MagicDamage_debuff:GetEffectName()
    return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end

function modifier_Zema_MagicDamage_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_zema_cosmic_blindness_hole", "abilities/heroes/zema", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zema_cosmic_blindness_debuff", "abilities/heroes/zema", LUA_MODIFIER_MOTION_HORIZONTAL )

Zema_cosmic_blindness = class({})

function Zema_cosmic_blindness:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Zema_cosmic_blindness:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Zema_cosmic_blindness:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Zema_cosmic_blindness:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Zema_cosmic_blindness:GetBehavior()
    if self:GetCaster():HasScepter() then
    	return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
    end
    return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function Zema_cosmic_blindness:GetChannelTime()
	if self:GetCaster():HasScepter() then
		return 0
	end
    return self.BaseClass.GetChannelTime(self)
end

function Zema_cosmic_blindness:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	if self:GetCaster():HasScepter() then
		duration = self:GetSpecialValueFor("scepter_duration")
	end
	self.thinker = CreateModifierThinker( caster, self, "modifier_zema_cosmic_blindness_hole", { duration = duration }, point, caster:GetTeamNumber(), false )
end

function Zema_cosmic_blindness:OnChannelFinish( bInterrupted )
	if self:GetCaster():HasScepter() then return end
	if self.thinker and not self.thinker:IsNull() then
		self.thinker:Destroy()
	end
end

modifier_zema_cosmic_blindness_hole = class({})

function modifier_zema_cosmic_blindness_hole:IsHidden()
	return true
end

function modifier_zema_cosmic_blindness_hole:IsPurgable()
	return false
end

function modifier_zema_cosmic_blindness_hole:OnCreated( kv )
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.interval = 1
	self.ticks = math.floor(self:GetDuration()/self.interval+0.5)
	self.tick = 0
	self.quest_tick = true
	local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_zema_6")
	self.damageTable = { attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() }
	self:StartIntervalThink( self.interval )
	local pfx = ParticleManager:CreateParticle( "particles/bluehole/enigma_blackhole_ti5.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( pfx, 0, self:GetParent():GetOrigin() )
	self:AddParticle( pfx, false, false, -1, false, false )
	self:GetParent():EmitSound("zema")
end

function modifier_zema_cosmic_blindness_hole:OnRemoved()
	if not IsServer() then return end
	if self:GetRemainingTime()<0.01 and self.tick<self.ticks then
		self:OnIntervalThink()
	end
	self:GetParent():StopSound("zema")
end

function modifier_zema_cosmic_blindness_hole:OnIntervalThink()
	if not IsServer() then return end
	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

	if self:GetCaster():HasTalent("special_bonus_birzha_zema_7") then
		enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	end

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end

	self.tick = self.tick+1

	if #enemies >= 2 then
		if self.quest_tick then
			self.quest_tick = false
			donate_shop:QuestProgress(44, self:GetCaster():GetPlayerOwnerID(), 1)
		end
	end
end

function modifier_zema_cosmic_blindness_hole:IsAura()
	return true
end

function modifier_zema_cosmic_blindness_hole:GetModifierAura()
	return "modifier_zema_cosmic_blindness_debuff"
end

function modifier_zema_cosmic_blindness_hole:GetAuraRadius()
	return self.radius
end

function modifier_zema_cosmic_blindness_hole:GetAuraDuration()
	return 0.1
end

function modifier_zema_cosmic_blindness_hole:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_zema_cosmic_blindness_hole:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_zema_cosmic_blindness_hole:GetAuraSearchFlags()
	if not self:GetCaster():HasTalent("special_bonus_birzha_zema_7") then
		return 0
	end
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_zema_cosmic_blindness_debuff = class({})

function modifier_zema_cosmic_blindness_debuff:IsDebuff()
	return true
end

function modifier_zema_cosmic_blindness_debuff:IsStunDebuff()
	return true
end

function modifier_zema_cosmic_blindness_debuff:OnCreated( kv )
	self.rate = 0.2
	self.pull_speed =  40
	self.rotate_speed = 0.5

	if IsServer() then
		self.center = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
		if self:ApplyHorizontalMotionController() == false then
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

function modifier_zema_cosmic_blindness_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_zema_cosmic_blindness_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}

	return funcs
end

function modifier_zema_cosmic_blindness_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_zema_cosmic_blindness_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_zema_cosmic_blindness_debuff:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_zema_cosmic_blindness_debuff:UpdateHorizontalMotion( me, dt )
	if self:GetParent():HasModifier("modifier_item_force_staff_2_pull") then
		if not self:IsNull() then
	        self:Destroy()
	    end
	    return
	end
	local target = self:GetParent():GetOrigin()-self.center
	target.z = 0
	local targetL = target:Length2D()-self.pull_speed*dt
	local targetN = target:Normalized()
	local deg = math.atan2( targetN.y, targetN.x )
	local targetN = Vector( math.cos(deg+self.rotate_speed*dt), math.sin(deg+self.rotate_speed*dt), 0 );
	self:GetParent():SetOrigin( self.center + targetN * targetL )
end

function modifier_zema_cosmic_blindness_debuff:OnHorizontalMotionInterrupted()
	if not self:IsNull() then
        self:Destroy()
    end
end



