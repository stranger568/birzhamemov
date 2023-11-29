LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_freddy_scream_damage", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_heart_death", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_fear", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_screamer_effect_webm", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_screamer_effect_webm_cooldown", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_costume_launch", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_scream_fear", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )

freddy_scream = class({})

function freddy_scream:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown( self, iLevel ) + self:GetCaster():FindTalentValue("special_bonus_birzha_freddy_1")
end

function freddy_scream:OnSpellStart()
	if not IsServer() then return end

	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) then return nil end

	local damage_duration = self:GetSpecialValueFor("debuff_duration")
	local fear_duration = self:GetSpecialValueFor("fear_duration")
	local damage = self:GetSpecialValueFor("damage_interval")

	if target:HasModifier("modifier_freddy_heart_death") then
		damage = damage * self:GetSpecialValueFor("damage_multiple_2")
	elseif target:HasModifier("modifier_freddy_fear") then
		damage = damage * self:GetSpecialValueFor("damage_multiple")
	end

	self:GetCaster():EmitSound("freddy_screamer")

	Timers:CreateTimer(1.5, function()
		self:GetCaster():StopSound("freddy_screamer")
	end)

	if not target:HasModifier("modifier_freddy_screamer_effect_webm_cooldown") then
		target:AddNewModifier(self:GetCaster(), nil, "modifier_freddy_screamer_effect_webm", {duration = 1.5})
		target:AddNewModifier(self:GetCaster(), nil, "modifier_freddy_screamer_effect_webm_cooldown", {duration = 20})
	end

	ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	target:AddNewModifier(self:GetCaster(), self, "modifier_freddy_scream_damage", {duration = damage_duration * (1 - target:GetStatusResistance())})

	if target:HasModifier("modifier_freddy_heart_death") then
		local modifier = target:FindModifierByName("modifier_freddy_heart_death")
		if modifier then
			modifier:ForceRefresh()
		end
	else
		target:AddNewModifier(self:GetCaster(), self, "modifier_freddy_fear", {duration = fear_duration * (1-target:GetStatusResistance())})
	end
end

modifier_freddy_scream_fear = class({})

function modifier_freddy_scream_fear:IsPurgable()
    return false
end

function modifier_freddy_scream_fear:IsHidden()
    return true
end

function modifier_freddy_scream_fear:OnCreated()
    if not IsServer() then return end
    local pos = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin())
    pos.z = 0
    pos = pos:Normalized()
    self.position = self:GetParent():GetAbsOrigin() + pos * 3000
    self:GetParent():MoveToPosition( self.position )
end

function modifier_freddy_scream_fear:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():MoveToPosition( self.position )
end

function modifier_freddy_scream_fear:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
end

function modifier_freddy_scream_fear:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }
    return state
end

modifier_freddy_scream_damage = class({})

function modifier_freddy_scream_damage:IsPurgable() return true end
function modifier_freddy_scream_damage:IsPurgeException() return true end

function modifier_freddy_scream_damage:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_interval")
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end

function modifier_freddy_scream_damage:OnRefresh()
	self:OnCreated()
end

function modifier_freddy_scream_damage:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = self.damage * 0.5, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_freddy_scream_damage:CheckState()
	if not self:GetCaster():HasTalent("special_bonus_birzha_freddy_4") then return end
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
end

-- ОБЫЧНЫЙ ИСПУГ
modifier_freddy_fear = class({})
function modifier_freddy_fear:IsPurgable() return false end
function modifier_freddy_fear:GetTexture() return "freddy/screamer1" end

-- Сердечный приступ
modifier_freddy_heart_death = class({})
function modifier_freddy_heart_death:IsPurgable() return false end
function modifier_freddy_heart_death:GetTexture() return "freddy/screamer2" end

modifier_freddy_screamer_effect_webm_cooldown = class({})
function modifier_freddy_screamer_effect_webm_cooldown:IsHidden() return true end
function modifier_freddy_screamer_effect_webm_cooldown:IsPurgable() return false end

modifier_freddy_screamer_effect_webm = class({})
function modifier_freddy_screamer_effect_webm:IsPurgable() return false end
function modifier_freddy_screamer_effect_webm:IsHidden() return true end
function modifier_freddy_screamer_effect_webm:OnCreated()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
	CustomGameEventManager:Send_ServerToPlayer(Player, "FreddyScreamerTrue", {} )
end
function modifier_freddy_screamer_effect_webm:OnDestroy()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
	CustomGameEventManager:Send_ServerToPlayer(Player, "FreddyScreamerFalse", {} )
end

LinkLuaModifier( "modifier_freddy_surprice", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )

freddy_surprice = class({})

function freddy_surprice:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_freddy_1" )
end

function freddy_surprice:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local point = self:GetCursorPosition()
    local surprice = CreateUnitByName( "npc_dota_companion", point, true, nil, nil, self:GetCaster():GetTeamNumber() )
    surprice:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    surprice:EmitSound("freddy_surprice_set")
    surprice:SetOwner(self:GetCaster())
    surprice:AddNewModifier(self:GetCaster(), self, "modifier_freddy_surprice", {})
    surprice:SetModel("models/freddy/box.vmdl")
    surprice:SetOriginalModel("models/freddy/box.vmdl")
    surprice:SetModelScale(4)
end

modifier_freddy_surprice = class({})

function modifier_freddy_surprice:IsHidden() return true end
function modifier_freddy_surprice:IsPurgable() return false end

function modifier_freddy_surprice:OnCreated()
	if not IsServer() then return end
	self.active = true
	self.duration = self:GetAbility():GetSpecialValueFor("heart_debuff_duration")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self:StartIntervalThink(FrameTime())
end

function modifier_freddy_surprice:OnIntervalThink()
	if not IsServer() then return end
	if not self.active then return end
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #units <= 0 then return end

	local particle = ParticleManager:CreateParticle("particles/freddy/toy_screamstart.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	self:GetParent():EmitSound("freddy_surprice")

	self:GetParent():EmitSound("freddy_screamer")

	self.active = false

	self:GetParent():SetModel("models/freddy/box_open.vmdl")
    self:GetParent():SetOriginalModel("models/freddy/box_open.vmdl")

	for _, unit in pairs(units) do
		if self:GetCaster():HasShard() then
			local ability_ultimate = self:GetCaster():FindAbilityByName("freddy_costume_launch")
			if ability_ultimate and ability_ultimate:GetLevel() > 0 then
				local duration = ability_ultimate:GetSpecialValueFor("duration")
				unit:AddNewModifier(self:GetCaster(), ability_ultimate, "modifier_freddy_costume_launch", {duration = duration * (1-unit:GetStatusResistance())})
			end
		end

		if not unit:HasModifier("modifier_freddy_screamer_effect_webm_cooldown") then
			unit:AddNewModifier(self:GetCaster(), nil, "modifier_freddy_screamer_effect_webm", {duration = 1.5})
			unit:AddNewModifier(self:GetCaster(), nil, "modifier_freddy_screamer_effect_webm_cooldown", {duration = 20})
		end

		if self:GetCaster():HasTalent("special_bonus_birzha_freddy_3") then
			unit:AddNewModifier(self:GetParent(), nil, "modifier_freddy_scream_fear", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_freddy_3") * (1 - unit:GetStatusResistance())})
		end

		if unit:HasModifier("modifier_freddy_heart_death") then
			ApplyDamage({attacker = self:GetCaster(), victim = unit, ability = self:GetAbility(), damage = self.damage * self:GetAbility():GetSpecialValueFor("damage_multiple"), damage_type = DAMAGE_TYPE_MAGICAL})
		else
			ApplyDamage({attacker = self:GetCaster(), victim = unit, ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
		end

		if unit:HasModifier("modifier_freddy_fear") or unit:HasModifier("modifier_freddy_heart_death") then
			unit:RemoveModifierByName("modifier_freddy_fear")
			unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_freddy_heart_death", {duration = self.duration * (1-unit:GetStatusResistance())})
		end
	end

	self:GetParent():RemoveModifierByName("modifier_kill")
end

function modifier_freddy_surprice:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }
    return state
end

LinkLuaModifier( "modifier_freddy_toreador", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_toreador_visual", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )

freddy_toreador = class({})

function freddy_toreador:GetIntrinsicModifierName()
	return "modifier_freddy_toreador_visual"
end

function freddy_toreador:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_freddy_2")
	local bonus_damage = self:GetSpecialValueFor("bonus_damage")

	local modifier_freddy_toreador_visual = self:GetCaster():FindModifierByName("modifier_freddy_toreador_visual")
	if modifier_freddy_toreador_visual then
		modifier_freddy_toreador_visual:SetStackCount(modifier_freddy_toreador_visual:GetStackCount() + bonus_damage)
	end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_freddy_toreador", {duration = duration})
end

modifier_freddy_toreador_visual = class({})

function modifier_freddy_toreador_visual:IsPurgable() return false end
function modifier_freddy_toreador_visual:IsHidden() return self:GetStackCount() == 0 end

modifier_freddy_toreador = class({})

function modifier_freddy_toreador:IsPurgable() return false end

function modifier_freddy_toreador:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.clicker_fix = false
	if not IsServer() then return end
	EmitGlobalSound("freddy_tor")
end

function modifier_freddy_toreador:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
    return funcs
end

function modifier_freddy_toreador:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_freddy_toreador:OnOrder( params )
    if params.unit~=self:GetParent() then return end
    if  params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        self:ChangePoint( params.new_pos )
    elseif 
        params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
        params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
    then
        self:ChangePoint( params.target:GetOrigin() )
    end
    if params.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
        self:ChangePoint( params.new_pos )
    end
end

function modifier_freddy_toreador:ChangePoint( point )
	if not IsServer() then return end

	if self.clicker_fix then return end

	self.clicker_fix = true
	Timers:CreateTimer(0.12, function()
		self.clicker_fix = false
	end)

    local direction = (point - self:GetParent():GetAbsOrigin())

    if direction:Length2D() > 120 then
        direction = direction:Normalized() * 120
    end

    FindClearSpaceForUnit( self:GetCaster(), self:GetParent():GetAbsOrigin() + direction, true )
end

function modifier_freddy_toreador:GetModifierInvisibilityLevel()
    return 1
end

function modifier_freddy_toreador:OnAttack( params )
    if IsServer() then
        if params.attacker~=self:GetParent() then return end
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_freddy_toreador:OnAbilityExecuted(keys)
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

function modifier_freddy_toreador:CheckState()
    return 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end

function modifier_freddy_toreador:OnDestroy()
	if not IsServer() then return end

	StopGlobalSound("freddy_tor")

	local particle = ParticleManager:CreateParticle("particles/freddy/freddy_aoe_fear.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(self.radius,1,1))

	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "freddy_screamer", self:GetCaster() )

	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	local bonus_damage = 0
	local modifier_freddy_toreador_visual = self:GetCaster():FindModifierByName("modifier_freddy_toreador_visual")
	if modifier_freddy_toreador_visual then
		bonus_damage = modifier_freddy_toreador_visual:GetStackCount()
		if self:GetCaster():HasTalent("special_bonus_birzha_freddy_6") then
			bonus_damage = bonus_damage * self:GetCaster():FindTalentValue("special_bonus_birzha_freddy_6")
		end
	end

	for _, unit in pairs(units) do
		if not unit:HasModifier("modifier_freddy_screamer_effect_webm_cooldown") then
			unit:AddNewModifier(self:GetCaster(), nil, "modifier_freddy_screamer_effect_webm", {duration = 1.5})
			unit:AddNewModifier(self:GetCaster(), nil, "modifier_freddy_screamer_effect_webm_cooldown", {duration = 20})
		end

		ApplyDamage({attacker = self:GetCaster(), victim = unit, ability = self:GetAbility(), damage = self.damage + bonus_damage, damage_type = DAMAGE_TYPE_MAGICAL})

		if unit:HasModifier("modifier_freddy_heart_death") then
			local modifier = unit:FindModifierByName("modifier_freddy_heart_death")
			if modifier then
				modifier:ForceRefresh()
			end
		else
			unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_freddy_fear", {duration = 10 * (1-unit:GetStatusResistance())})
		end
	end
end

freddy_costume_launch = class({})

function freddy_costume_launch:OnSpellStart()
	if not IsServer() then return end

	self:GetCaster():EmitSound("freddy_costume_cast")

	local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
	local direction = (point - self:GetCaster():GetAbsOrigin())
	direction.z = 0
	direction = direction:Normalized()

	local info = 
	{
		Source = self:GetCaster(),
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
	    bDeleteOnHit = false,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = 0,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		EffectName = "particles/freddy/costume_launch_testice_shards_projectile_stout.vpcf",
	    fDistance = 1200,
	    fStartRadius = 100,
	    fEndRadius =100,
		vVelocity = direction * 1500,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		bDeleteOnHit = true,
	}

	ProjectileManager:CreateLinearProjectile(info)
end

function freddy_costume_launch:OnProjectileHit(hTarget, vLocation)
	if not hTarget then return end
	if hTarget:HasModifier("modifier_freddy_costume_active") then return end
	local duration = self:GetSpecialValueFor("duration")
	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_freddy_costume_launch", {duration = duration * (1-hTarget:GetStatusResistance())})
	return true
end

modifier_freddy_costume_launch = class({})

function modifier_freddy_costume_launch:IsPurgable() return false end

function modifier_freddy_costume_launch:GetEffectName()
    return "particles/freddy_prikol_effectmigi_infected.vpcf"
end

function modifier_freddy_costume_launch:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier( "modifier_freddy_costume_active", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_freddy_costume_active_bunny", "abilities/heroes/freddy.lua", LUA_MODIFIER_MOTION_BOTH )

freddy_costume_active = class({})

function freddy_costume_active:OnAbilityPhaseStart()
	local use = false

	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
    for _, unit in pairs(units) do
    	local mod = unit:FindModifierByName("modifier_freddy_costume_launch")
        if mod and not mod:IsNull() then
        	use = true
        end
    end

	return use
end

function freddy_costume_active:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_freddy_8")
	local damage_per_health = self:GetSpecialValueFor("damage_per_health") + self:GetCaster():FindTalentValue("special_bonus_birzha_freddy_7")
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
    for _, unit in pairs(units) do
        local mod = unit:FindModifierByName("modifier_freddy_costume_launch")
        if mod and not mod:IsNull() then
        	local particle = ParticleManager:CreateParticle("particles/freddy/spring_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
        	ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
        	ParticleManager:ReleaseParticleIndex(particle)
        	mod:Destroy()
        	unit:EmitSound("freddy_costume_active")
        	local damage = unit:GetMaxHealth() / 100 * damage_per_health
        	unit:AddNewModifier(self:GetCaster(), self, "modifier_freddy_costume_active", {duration = duration})
        	ApplyDamage({attacker = self:GetCaster(), victim = unit, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PURE})
        end
    end 
end

modifier_freddy_costume_active = class({})

function modifier_freddy_costume_active:IsPurgable() return false end

function modifier_freddy_costume_active:GetEffectName()
    return "particles/freddy_prikol_2freddy_prikol_effectmigi_infected.vpcf"
end

function modifier_freddy_costume_active:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_freddy_costume_active:OnCreated()
    self.move = self:GetAbility():GetSpecialValueFor("slow")
    self.attack = self:GetAbility():GetSpecialValueFor("slow_attackspeed")
end

function modifier_freddy_costume_active:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_DEATH
    }

    return decFuncs
end

function modifier_freddy_costume_active:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end

function modifier_freddy_costume_active:GetModifierAttackSpeedBonus_Constant()
    return self.attack
end

function modifier_freddy_costume_active:OnDeath(params)
	if params.unit == self:GetParent() and self:GetCaster():HasScepter() then
		local bunny = CreateUnitByName( "npc_freddy_bunny", self:GetParent():GetAbsOrigin(), true, nil, nil, self:GetCaster():GetTeamNumber() )
		bunny:SetOwner(self:GetCaster())
		bunny:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_freddy_costume_active_bunny", {})
	end
end

modifier_freddy_costume_active_bunny = class({})

function modifier_freddy_costume_active_bunny:IsHidden() return true end
function modifier_freddy_costume_active_bunny:IsPurgable() return false end

function modifier_freddy_costume_active_bunny:OnCreated()
	if IsServer() then
		self.leash_distance = self:GetAbility():GetSpecialValueFor("radius_scepter_2")
		self.ForwardVector = self:GetParent():GetForwardVector()
		self.returningToLeash = false
		self:StartIntervalThink(1.0)
		self.start_point = self:GetParent():GetAbsOrigin()
	end
end

function modifier_freddy_costume_active_bunny:OnIntervalThink()
	if (self:GetParent():GetAbsOrigin() - self.start_point):Length2D() >= self.leash_distance then
		self.returningToLeash = true
		self:GetParent():MoveToPosition(self.start_point)
	end
end

function modifier_freddy_costume_active_bunny:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return decFuncs
end

function modifier_freddy_costume_active_bunny:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local damage = params.target:GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("scepter_damage")
		ApplyDamage({attacker = self:GetCaster(), victim = params.target, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end
end
