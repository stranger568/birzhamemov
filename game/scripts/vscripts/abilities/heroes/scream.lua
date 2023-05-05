LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Scream_TelephoneCall_radius_leave", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scream_TelephoneCall_radius_leave_aura", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scream_TelephoneCall_leave", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)

Scream_TelephoneCall = class({})

function Scream_TelephoneCall:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Scream_TelephoneCall:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Scream_TelephoneCall:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return 25000
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Scream_TelephoneCall:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function Scream_TelephoneCall:OnSpellStart()
	if not IsServer() then return end
	local position = self:GetCursorPosition()
	local duration_leave = self:GetSpecialValueFor("duration_leave")
	local radius = self:GetSpecialValueFor("radius")

	CreateModifierThinker(self:GetCaster(), self, "modifier_Scream_TelephoneCall_radius_leave", {duration = duration_leave}, position, self:GetCaster():GetTeamNumber(), false)

	AddFOWViewer(self:GetCaster():GetTeamNumber(), position, radius, duration_leave, false)
end

modifier_Scream_TelephoneCall_radius_leave = class({})

function modifier_Scream_TelephoneCall_radius_leave:OnCreated()
	if not IsServer() then return end

	local radius = self:GetAbility():GetSpecialValueFor("radius")

	self:GetParent():EmitSound("ScreamTelephone")

	local particle = ParticleManager:CreateParticle("particles/scream/scream_call.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 5, Vector(radius+300, 0, 0))
	self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_Scream_TelephoneCall_radius_leave:OnDestroy()
	if not IsServer() then return end
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local duration_scream = self:GetAbility():GetSpecialValueFor("duration_scream") + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_3")

	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

	self:GetParent():RemoveSelf()

	if #targets == 0 then return end

	self:GetCaster():EmitSound("ScreamAllo")

	for _,unit in pairs(targets) do
		unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Scream_TelephoneCall_leave", {duration = duration_scream * (1-unit:GetStatusResistance())})
	end
end

function modifier_Scream_TelephoneCall_radius_leave:IsHidden()				return true end
function modifier_Scream_TelephoneCall_radius_leave:IsAura() 				return true end
function modifier_Scream_TelephoneCall_radius_leave:IsAuraActiveOnDeath() 	return false end
function modifier_Scream_TelephoneCall_radius_leave:GetAuraRadius()		return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_Scream_TelephoneCall_radius_leave:GetAuraSearchTeam()	return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_Scream_TelephoneCall_radius_leave:GetAuraSearchType()	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_Scream_TelephoneCall_radius_leave:GetModifierAura()		return "modifier_Scream_TelephoneCall_radius_leave_aura" end

modifier_Scream_TelephoneCall_radius_leave_aura = class({})

function modifier_Scream_TelephoneCall_radius_leave_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end

modifier_Scream_TelephoneCall_leave = class({})

function modifier_Scream_TelephoneCall_leave:OnCreated()
	if not IsServer() then return end

	local particle = ParticleManager:CreateParticle("particles/scream/scream_call_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	self:AddParticle(particle, false, false, -1, false, true)

	self:StartIntervalThink(0.5)

	local buildings = FindUnitsInRadius( self:GetParent():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false )

	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname()=="ent_dota_fountain" then
			fountain = building
			break
		end
	end

	if not fountain then return end

	self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

function modifier_Scream_TelephoneCall_leave:OnDestroy()
	if not IsServer() then return end
	self:GetParent():Stop()
end

function modifier_Scream_TelephoneCall_leave:CheckState()
	local state = 
	{
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FEARED] = true,
	}
	return state
end

function modifier_Scream_TelephoneCall_leave:GetEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf"
end

function modifier_Scream_TelephoneCall_leave:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Scream_TelephoneCall_leave:OnIntervalThink()
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * 0.5, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
	local buildings = FindUnitsInRadius( self:GetParent():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false )
	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname()=="ent_dota_fountain" then
			fountain = building
			break
		end
	end
	if not fountain then return end
	self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

LinkLuaModifier("modifier_scream_rush", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)

Scream_rush = class({})

function Scream_rush:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_1")
end

function Scream_rush:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Scream_rush:GetCastRange(location, target)
    return self:GetSpecialValueFor( "range_cast" )
end

function Scream_rush:OnSpellStart()
	if not IsServer() then return end

	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then
        return
    end

	local duration = self:GetSpecialValueFor( "duration" )

	target:AddNewModifier(self:GetCaster(), self, "modifier_scream_rush", { duration = duration * ( 1 - target:GetStatusResistance() ) })

	self:GetCaster():EmitSound("ScreamChuvak")

	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_cast_soulchain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )	
end

modifier_scream_rush = class({})

function modifier_scream_rush:IsPurgable()
	return true
end

function modifier_scream_rush:OnCreated( kv )
	if not IsServer() then return end
	self.limit = 550
	self:PlayEffects1()
	self:PlayEffects2(true)
	self:StartIntervalThink(0.1)
end

function modifier_scream_rush:OnDestroy( kv )
	if not IsServer() then return end
	self:PlayEffects2(false)
end

function modifier_scream_rush:OnIntervalThink()
	local range = self:GetAbility():GetSpecialValueFor( "range" )
	local vector_distance = self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local base_damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_5")
	local hptarget = self:GetAbility():GetSpecialValueFor("damage_fromhp")
	local damage = (base_damage + ( self:GetParent():GetHealth() / 100 * hptarget))*0.1
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
	local facingAngle = self:GetParent():GetAnglesAsVector().y
	local angleToPair = VectorToAngles(vector_distance).y
	local angleDifference = math.abs(AngleDiff( angleToPair, facingAngle ))
	if angleDifference > 90 then
		if distance >= range then
			self.limit = 0.01
		end
	else
		self.limit = 550
	end
end

function modifier_scream_rush:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_scream_rush:GetModifierMoveSpeed_Limit()
	return self.limit
end

function modifier_scream_rush:PlayEffects1()
	local effect_cast1 = ParticleManager:CreateParticle( "particles/scream/scream_rush_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast1, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	self:AddParticle( effect_cast1, false, false, -1, false, false )
	local effect_cast2 = ParticleManager:CreateParticle( "particles/scream/scream_rush_marker.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	self:AddParticle( effect_cast2, false, false, -1, false, true )
end

function modifier_scream_rush:PlayEffects2(connect)
	if connect then
		self.effect_cast = ParticleManager:CreateParticle( "particles/scream/scream_rush_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
		ParticleManager:SetParticleControlEnt( self.effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	else
		if self.effect_cast then
			ParticleManager:DestroyParticle( self.effect_cast, false )
			ParticleManager:ReleaseParticleIndex( self.effect_cast )
		end
	end
end

LinkLuaModifier("modifier_Scream_knife", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scream_knife_armor", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)

Scream_knife = class({})

function Scream_knife:GetIntrinsicModifierName()
	return "modifier_Scream_knife"
end

function Scream_knife:GetCooldown(level)
	if self:GetCaster():HasTalent("special_bonus_birzha_scream_4") then
		return 0
	end
	return self.BaseClass.GetCooldown( self, level )  / ( self:GetCaster():GetCooldownReduction())
end

modifier_Scream_knife = class({})

function modifier_Scream_knife:IsPurgable() return false end
function modifier_Scream_knife:IsHidden() return true end

function modifier_Scream_knife:DeclareFunctions()
	local decFunc = {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE}
	return decFunc
end

function modifier_Scream_knife:GetModifierProcAttack_BonusDamage_Pure(params)
	if not IsServer() then return end
	if params.target:IsWard() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if not self:GetAbility():IsFullyCastable() then return end

	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_2")
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )

	if RollPercentage(chance) then
		self:GetCaster():EmitSound("ScreamKill")

		local forward = (params.target:GetOrigin()-params.attacker:GetOrigin()):Normalized()

		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_spectre/spectre_desolate.vpcf", PATTACH_POINT_FOLLOW, params.target )
		ParticleManager:SetParticleControlEnt( effect_cast, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControl( effect_cast, 4, params.target:GetOrigin() )
		ParticleManager:SetParticleControlForward( effect_cast, 0, forward )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		self:GetAbility():UseResources(false, false, false, true)

		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_Scream_knife_armor", {duration = duration * ( 1 - params.target:GetStatusResistance()) })

		return damage
	end
end

modifier_Scream_knife_armor = class({})

function modifier_Scream_knife_armor:OnCreated()
	self.armor = 0
	self.armor = self:GetParent():GetPhysicalArmorValue(false) / 100 * (self:GetAbility():GetSpecialValueFor("armor_reduce") + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_6"))
end

function modifier_Scream_knife_armor:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return funcs
end

function modifier_Scream_knife_armor:GetModifierPhysicalArmorBonus()
	return self.armor * (-1)
end

function modifier_Scream_knife_armor:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf"
end

function modifier_Scream_knife_armor:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


LinkLuaModifier("modifier_Scream_night", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scream_night_vision", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Scream_night_smoke", "abilities/heroes/scream.lua", LUA_MODIFIER_MOTION_NONE)

Scream_night = class({})

function Scream_night:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_8")
end

function Scream_night:OnSpellStart()
	if not IsServer() then return end

	local duration = self:GetSpecialValueFor("duration")

	self:GetCaster():EmitSound("ScreamUltimate")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Scream_night", {duration = duration})
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Scream_night_smoke", {duration = duration})

	GameRules:BeginNightstalkerNight(duration)

	if not self:GetCaster():HasShard() then return end

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_Scream_night_vision", {duration = duration})
    end
end

modifier_Scream_night = class({})

function modifier_Scream_night:IsPurgable() return false end

function modifier_Scream_night:OnCreated()
	if not IsServer() then return end
	self:GetCaster():FindAbilityByName("Scream_night_two"):SetLevel(self:GetAbility():GetLevel())
end

function modifier_Scream_night:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():FindAbilityByName("Scream_night_two"):SetLevel(0)
end

modifier_Scream_night_vision = class({})

function modifier_Scream_night_vision:IsPurgable() return false end

function modifier_Scream_night_vision:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_Scream_night_vision:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetCaster():IsAlive() then self:Destroy() end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 50, FrameTime(), true)
end

modifier_Scream_night_smoke = class({})

function modifier_Scream_night_smoke:IsPurgable()
	return false
end

function modifier_Scream_night_smoke:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle( "particles/items2_fx/smoke_of_deceit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex(particle)
	self:StartIntervalThink(FrameTime())
end

function modifier_Scream_night_smoke:OnIntervalThink()
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	
	if #targets > 0 then
        self:Destroy()
	end
end

function modifier_Scream_night_smoke:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
    return funcs
end

function modifier_Scream_night_smoke:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
    return state
end

function modifier_Scream_night_smoke:GetModifierInvisibilityLevel()
    return 1
end

Scream_night_two = class({})

function Scream_night_two:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_scream_7")
end

function Scream_night_two:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function Scream_night_two:GetChannelTime()
	return self:GetSpecialValueFor( "tp_duration" )
end

function Scream_night_two:OnSpellStart()
	if IsServer() then
		self.target = self:GetCursorTarget()
		if self.target:TriggerSpellAbsorb(self) then
			self:GetCaster():Interrupt()
			return
		end
		self:EndCooldown()
	end
end

function Scream_night_two:OnChannelFinish(bInterrupted)
	if not IsServer() then return end

	if bInterrupted then
		return
	end

	self:UseResources(false, false, false, true)

	if not self:GetCaster():HasModifier("modifier_Scream_night") then return end

	local stun_duration = self:GetSpecialValueFor("stun_duration")

	self:GetCaster():EmitSound("ScreamUltimate")
	
	local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "set_camera_target", {id = self.target:entindex()} )
	end

	self:GetCaster():SetAbsOrigin(self.target:GetAbsOrigin())

	FindClearSpaceForUnit(self:GetCaster(), self.target:GetAbsOrigin(), false)

	self.target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})

	local damage = self:GetSpecialValueFor("damage")

	ApplyDamage({victim = self.target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})

	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 2, Vector(300, 300,300))

	if not self:GetCaster():HasTalent("special_bonus_birzha_scream_7") then
		self:GetCaster():FindAbilityByName("Scream_night_two"):SetLevel(0)
	end
end