LinkLuaModifier("modifier_Vernon_pogonya", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
Vernon_pogonya = class({})

function Vernon_pogonya:Precache(context)
    local particle_list = 
    {
        "particles/econ/events/new_bloom/pig_death.vpcf",
        "particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf",
        "particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient_blur.vpcf",
        "particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf",
        "particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf",
        "particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf",
        "particles/items_fx/black_king_bar_avatar.vpcf",
        "particles/status_fx/status_effect_avatar.vpcf",
        "particles/vernon/vernon_stomp.vpcf",
        "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf",
        "particles/units/heroes/hero_silencer/silencer_global_silence.vpcf",
        "particles/units/heroes/hero_silencer/silencer_global_silence_hero.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
    PrecacheResource("model", "models/props_gameplay/pig_balloon.vmdl", context)
end

function Vernon_pogonya:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_1")
end

function Vernon_pogonya:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vernon_pogonya:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vernon_pogonya:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    if not IsServer() then return end
    self.scale = caster:GetModelScale()
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb( self ) then return end
    caster:AddNewModifier(caster, ability, "modifier_Vernon_pogonya", {duration = 10})
    caster:EmitSound("VernonPogon")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_elder_titan" then
    	caster:SetModelScale(2.5)
    end
end

modifier_Vernon_pogonya = class({})

function modifier_Vernon_pogonya:IsPurgable() return false end
function modifier_Vernon_pogonya:IsHidden() return true end

function modifier_Vernon_pogonya:OnCreated()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not IsServer() then return end
    self.target = self:GetAbility().target
    self.targets_scepter = {}
    self:StartIntervalThink(0.1)
    if self:ApplyHorizontalMotionController() == false then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Vernon_pogonya:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility()
	local angles = parent:GetAngles()
    if not IsServer() then return end
    if self.target == nil or self.target:IsNull() then
        self:Destroy()
    end
    local vector_distance = parent:GetAbsOrigin() - self.target:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	if distance <= 75 then
		if not self:GetCaster():HasScepter() then
			self:TakeDamage()
			if not self:IsNull() then
	            self:Destroy()
	        end
		else
			self:TakeDamage()
			local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			local targets = {}

			for id, unit in pairs(units) do
				if self.targets_scepter[unit:entindex()] == nil then
					table.insert(targets, unit)
				end
			end

			if #targets <= 0 then
				if not self:IsNull() then
		            self:Destroy()
		        end
				return
			end
			self.target = targets[1]
		end
	end
end

function modifier_Vernon_pogonya:TakeDamage()
    local parent = self:GetParent()
    local ability = self:GetAbility()
   	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/events/new_bloom/pig_death.vpcf", PATTACH_ABSORIGIN, parent)
	ParticleManager:ReleaseParticleIndex(particle)
   	self:GetCaster():EmitSound("VernonPogonEnd")
   	local vector_distance = parent:GetAbsOrigin() - self.target:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
   	local duration = self:GetAbility():GetSpecialValueFor("stun_duration")
	local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_4")
	if distance <= 75 then

		self.targets_scepter[self.target:entindex()] = self.target
		if self.target:IsMagicImmune() then return end
   		ApplyDamage({victim = self.target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration * (1 - self.target:GetStatusResistance()) })
	end
end

function modifier_Vernon_pogonya:OnDestroy()
    local parent = self:GetParent()
    local ability = self:GetAbility()
   	if not IsServer() then return end
   	self:GetParent():InterruptMotionControllers( true )
   	if self:GetCaster():GetUnitName() == "npc_dota_hero_elder_titan" then
   		self:GetCaster():SetModelScale(self:GetAbility().scale)
   	end
end

function modifier_Vernon_pogonya:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
    }
    return funcs
end

function modifier_Vernon_pogonya:UpdateHorizontalMotion( me, dt )
    local origin = self:GetParent():GetOrigin()
    if self.target == nil then
        self:Destroy()
        return
    end
    if not self.target:IsAlive() then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    local direction = self.target:GetOrigin() - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()
    local speed = self:GetAbility():GetSpecialValueFor("speed")
    local target = origin + direction * speed * dt
    self:GetParent():SetOrigin( target )
    self:GetParent():FaceTowards( self.target:GetOrigin() )
end

function modifier_Vernon_pogonya:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_Vernon_pogonya:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end

function modifier_Vernon_pogonya:GetVisualZDelta()
    return 100
end

function modifier_Vernon_pogonya:GetModifierModelChange()
    return "models/props_gameplay/pig_balloon.vmdl"
end

function modifier_Vernon_pogonya:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_Vernon_pogonya:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_Vernon_pogonya:GetAbsoluteNoDamagePure()
	return 1
end

LinkLuaModifier("modifier_Vernon_power_cogs_power_cogs", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Vernon_power_cogs_cog_push", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_Vernon_power_cogs_cog_push_in", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

LinkLuaModifier("modifier_Vernon_power_cogs_power_cogs_thinker_immune", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Vernon_power_cogs_power_cogs_magic_immune_buff", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_NONE)

Vernon_power_cogs = class({})

function Vernon_power_cogs:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_2")
end

function Vernon_power_cogs:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vernon_power_cogs:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vernon_power_cogs:GetAOERadius()
    return self:GetSpecialValueFor("cogs_radius")
end

function Vernon_power_cogs:OnSpellStart()
	if not IsServer() then return end
	local caster_pos = self:GetCaster():GetAbsOrigin()
	local cogs_radius = self:GetSpecialValueFor("cogs_radius")
	local cog_vector = GetGroundPosition(caster_pos + Vector(0, cogs_radius, 0), nil)
	local second_cog_vector	= GetGroundPosition(caster_pos + Vector(0, cogs_radius * 1.5, 0), nil)

    local radius_thinker = cogs_radius
    if self:GetCaster():HasScepter() then
        --radius_thinker = cogs_radius * 1.6
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_vernon_6") then
        CreateModifierThinker( self:GetCaster(), self, "modifier_Vernon_power_cogs_power_cogs_thinker_immune", { duration = self:GetSpecialValueFor("duration"), radius = radius_thinker }, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
    end

	for cog = 1, 8 do
		local cog = CreateUnitByName("npc_dota_rattletrap_cog", cog_vector, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		cog:SetModel("models/items/rattletrap/the_seeker_of_the_lost_artifact_cogs/the_seeker_of_the_lost_artifact_cogs.vmdl")
		cog:SetOriginalModel("models/items/rattletrap/the_seeker_of_the_lost_artifact_cogs/the_seeker_of_the_lost_artifact_cogs.vmdl")
		self:GetCaster():EmitSound("VernonDrell")
		cog:AddNewModifier(self:GetCaster(), self, "modifier_Vernon_power_cogs_power_cogs",
		{
			duration 	= self:GetSpecialValueFor("duration"),
			x 			= (cog_vector - caster_pos).x,
			y 			= (cog_vector - caster_pos).y,
			
			center_x	= caster_pos.x,
			center_y	= caster_pos.y,
			center_z	= caster_pos.z
		})
		cog_vector = RotatePosition(caster_pos, QAngle(0, 360 / 8, 0), cog_vector)
	end
    
    --for cog = 1, 16 do
    --	if self:GetCaster():HasScepter() then
	--		local second_cog = CreateUnitByName("npc_dota_rattletrap_cog", second_cog_vector, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	--		second_cog:SetModel("models/items/rattletrap/the_seeker_of_the_lost_artifact_cogs/the_seeker_of_the_lost_artifact_cogs.vmdl")
	--		second_cog:SetOriginalModel("models/items/rattletrap/the_seeker_of_the_lost_artifact_cogs/the_seeker_of_the_lost_artifact_cogs.vmdl")
	--		self:GetCaster():EmitSound("VernonDrell")
	--		
	--		second_cog:AddNewModifier(self:GetCaster(), self, "modifier_Vernon_power_cogs_power_cogs",
	--		{
	--			duration 	= self:GetSpecialValueFor("duration"),
	--			x 			= (second_cog_vector - caster_pos).x,
	--			y 			= (second_cog_vector - caster_pos).y,
	--			
	--			center_x	= caster_pos.x,
	--			center_y	= caster_pos.y,
	--			center_z	= caster_pos.z,
	--			second_gear	= true
	--		})
	--		
	--		second_cog_vector = RotatePosition(caster_pos, QAngle(0, 360 / 16, 0), second_cog_vector)
	--	end
    --end
	
	local deploy_particle	= ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(deploy_particle)
	
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("cogs_radius") + 120, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		if (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() <= self:GetSpecialValueFor("cogs_radius") then
			if unit:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
				FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)
			else
				FindClearSpaceForUnit(unit, self:GetCaster():GetAbsOrigin() + RandomVector(self:GetSpecialValueFor("extra_pull_buffer")), false)
			end
		else
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)
		end
	end
end

modifier_Vernon_power_cogs_power_cogs = class({})

function modifier_Vernon_power_cogs_power_cogs:IsHidden()	return true end
function modifier_Vernon_power_cogs_power_cogs:IsPurgable()	return false end

function modifier_Vernon_power_cogs_power_cogs:GetEffectName()
	return "particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient_blur.vpcf"
end

function modifier_Vernon_power_cogs_power_cogs:OnCreated(params)
	if self:GetAbility() then
		self.damage					= self:GetAbility():GetSpecialValueFor("damage")
		self.mana_burn				= self:GetAbility():GetSpecialValueFor("mana_burn")
		self.attacks_to_destroy		= self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
		self.push_length			= self:GetAbility():GetSpecialValueFor("push_length")
		self.push_duration			= self:GetAbility():GetSpecialValueFor("push_duration")
		self.trigger_distance		= self:GetAbility():GetSpecialValueFor("trigger_distance")
		self.rotational_speed		= self:GetAbility():GetSpecialValueFor("rotational_speed")
		self.charge_coil_duration	= self:GetAbility():GetSpecialValueFor("charge_coil_duration")
		self.powered			= true
		self.health				= self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
	else
		if not self:IsNull() then
            self:Destroy()
        end
		return
	end
	
	if not IsServer() then return end
	self:GetParent():SetForwardVector(Vector(params.x, params.y, 0))
	self.center_loc		= Vector(params.center_x, params.center_y, params.center_z)
	self.second_gear	= params.second_gear
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 62, Vector(0, 0, 0))
	self:AddParticle(self.particle, false, false, -1, false, false)
	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
end

function modifier_Vernon_power_cogs_power_cogs:OnIntervalThink()
	if not IsServer() then return end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.trigger_distance, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_CLOSEST, false)
	
	for _, enemy in pairs(enemies) do
		if self.powered and not enemy:HasModifier("modifier_zema_cosmic_blindness_debuff") and not enemy:HasModifier("modifier_pangolier_gyroshell") and not enemy:HasModifier("modifier_Vernon_power_cogs_cog_push") and math.abs(AngleDiff(VectorToAngles(self:GetParent():GetForwardVector()).y, VectorToAngles(enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()).y)) <= 90 then
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_Vernon_power_cogs_cog_push", 
			{
				duration	= self.push_duration,
				
				damage		= self.damage,
				mana_burn	= self.mana_burn,
				push_length	= self.push_length
			})
			if self.particle then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:ReleaseParticleIndex(self.particle)
			end
			break
		end
		if self.powered and not enemy:HasModifier("modifier_zema_cosmic_blindness_debuff") and not enemy:HasModifier("modifier_pangolier_gyroshell") and not enemy:HasModifier("modifier_Vernon_power_cogs_cog_push_in") and math.abs(AngleDiff(VectorToAngles(self:GetParent():GetForwardVector()).y, VectorToAngles(enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()).y)) > 90 then
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_Vernon_power_cogs_cog_push_in", 
			{
				duration	= self.push_duration,
				damage		= self.damage,
				mana_burn	= self.mana_burn,
				push_length	= 0
			})
			if self:GetAbility():GetCaster():HasTalent("special_bonus_birzha_vernon_3") then
                print(self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_3"))
				enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_3")})
			end	
			if self.particle then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:ReleaseParticleIndex(self.particle)
			end
			break
		end
	end
end

function modifier_Vernon_power_cogs_power_cogs:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Rattletrap.Power_Cogs")
	self:GetParent():EmitSound("Hero_Rattletrap.Power_Cog.Destroy")
	
	if self:GetRemainingTime() <= 0 then
		self:GetParent():RemoveSelf()
	end
end

function modifier_Vernon_power_cogs_power_cogs:CheckState()
	return  
	{
		[MODIFIER_STATE_SPECIALLY_DENIABLE]	= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
	}
end

function modifier_Vernon_power_cogs_power_cogs:DeclareFunctions()
	local decFuncs = 
	{
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return decFuncs
end

function modifier_Vernon_power_cogs_power_cogs:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_Vernon_power_cogs_power_cogs:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_Vernon_power_cogs_power_cogs:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_Vernon_power_cogs_power_cogs:OnAttackLanded(keys)
    if not IsServer() then return end
	if keys.target == self:GetParent() then
        if keys.attacker == self:GetCaster() then
            self:GetParent():Kill(nil, self:GetCaster())
        else
            self.health = self.health - 1
            if self.health <= 0 then
                self:GetParent():Kill(nil, keys.attacker)
            end
        end
	end
end

modifier_Vernon_power_cogs_cog_push = class({})

function modifier_Vernon_power_cogs_cog_push:OnCreated(params)
	if not IsServer() then return end
	
	self.duration			= params.duration
	self.damage				= params.damage
	self.mana_burn			= params.mana_burn
	self.push_length		= params.push_length
	self.owner				= self:GetCaster():GetOwner() or self:GetCaster()
	self:GetCaster():EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
	
	local attack_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	
	if self:GetCaster():GetName() == "npc_dota_rattletrap_cog" then
		ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	else
		ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	end
	
	self.knockback_speed		= self.push_length / self.duration
	self.position	= self:GetCaster():GetAbsOrigin()
	if self:ApplyHorizontalMotionController() == false then 
		if not self:IsNull() then
            self:Destroy()
        end
		return
	end
end

function modifier_Vernon_power_cogs_cog_push:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end
	local distance = (me:GetOrigin() - self.position):Normalized()
	me:SetOrigin( me:GetOrigin() + distance * self.knockback_speed * dt )
end

function modifier_Vernon_power_cogs_cog_push:OnHorizontalMotionInterrupted()
	if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_Vernon_power_cogs_cog_push:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():RemoveHorizontalMotionController( self )
	
	local damageTable = {
		victim 			= self:GetParent(),
		damage 			= self.damage,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	}
	
	if not damageTable.attacker then
		damageTable.attacker = self.owner
	end
	
	ApplyDamage(damageTable)
	
	self:GetParent():Script_ReduceMana(self.mana_burn, self:GetAbility())
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)

	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, true )
end

function modifier_Vernon_power_cogs_cog_push:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function modifier_Vernon_power_cogs_cog_push:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return decFuncs
end

function modifier_Vernon_power_cogs_cog_push:GetOverrideAnimation()
	 return ACT_DOTA_FLAIL
end

modifier_Vernon_power_cogs_cog_push_in = class({})

function modifier_Vernon_power_cogs_cog_push_in:OnCreated(params)
	if not IsServer() then return end
	
	self.duration			= params.duration
	self.damage				= params.damage
	self.mana_burn			= params.mana_burn
	self.push_length		= params.push_length
	self.owner				= self:GetCaster():GetOwner() or self:GetCaster()
	self:GetCaster():EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
	
	local attack_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	
	if self:GetCaster():GetName() == "npc_dota_rattletrap_cog" then
		ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	else
		ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_Vernon_power_cogs_cog_push_in:OnDestroy()
	if not IsServer() then return end
	
	local damageTable = {
		victim 			= self:GetParent(),
		damage 			= self.damage,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	}
	
	if not damageTable.attacker then
		damageTable.attacker = self.owner
	end

	ApplyDamage(damageTable)
end

modifier_Vernon_power_cogs_power_cogs_thinker_immune = class({})
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:OnCreated(params)
    self.radius = params.radius
end
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:IsAura()
    return true
end
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:IsPurgable() return false end
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:IsPurgeException() return false end
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:IsHidden() return true end
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetModifierAura()
    return "modifier_Vernon_power_cogs_power_cogs_magic_immune_buff"
end

function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetAuraRadius()
    return self.radius
end

function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetAuraDuration()
    return 0
end

function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_Vernon_power_cogs_power_cogs_thinker_immune:GetAuraEntityReject(target)
    if target == self:GetCaster() then
        return false
    end
    return true
end
modifier_Vernon_power_cogs_power_cogs_magic_immune_buff = class({})
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:IsPurgable() return false end
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:IsHidden() return true end
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end
function modifier_Vernon_power_cogs_power_cogs_magic_immune_buff:StatusEffectPriority()
    return 99999
end

LinkLuaModifier("modifier_Vernon_uporstvo", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_NONE)

Vernon_uporstvo = class({})

function Vernon_uporstvo:GetIntrinsicModifierName() 
	return "modifier_Vernon_uporstvo"
end

function Vernon_uporstvo:GetCooldown(level)
	if not self:GetCaster():HasShard() then return 0 end
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

modifier_Vernon_uporstvo = class({})

function modifier_Vernon_uporstvo:IsPurgable()	return false end
function modifier_Vernon_uporstvo:IsHidden() return true end

function modifier_Vernon_uporstvo:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_Vernon_uporstvo:OnIntervalThink()
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_5")
	if not self:GetParent():HasModifier("modifier_Vernon_pogonya") then
		self:GetParent():SetModelScale(self:GetAbility():GetSpecialValueFor("scale"))
	end
	if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if self:GetParent():IsAlive() then
		for _,unit in pairs(targets) do
			self:GetParent():EmitSound("VernonStomp")
			local effect_cast = ParticleManager:CreateParticle( "particles/vernon/vernon_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ApplyDamage({victim = unit, attacker = self:GetParent(), damage = self.damage * 0.1, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
		end
	end
end

function modifier_Vernon_uporstvo:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

function modifier_Vernon_uporstvo:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_Vernon_uporstvo:GetAbsorbSpell( params )
	if not IsServer() then return end
	if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
	if not self:GetParent():HasShard() then return end

	if self:GetAbility():IsFullyCastable() then
		if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        	return nil
        end
		self:GetAbility():UseResources( false, false, false, true )
		self:GetParent():EmitSound("VernonSmeh")
			local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
			ParticleManager:ReleaseParticleIndex( effect_cast )
		return 1
	end
end

function modifier_Vernon_uporstvo:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
end

Vernon_silence = class({})

LinkLuaModifier("modifier_Vernon_silence", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_NONE)

function Vernon_silence:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Vernon_silence:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Vernon_silence:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Vernon_silence:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_birzha_vernon_8") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function Vernon_silence:GetAOERadius()
	return self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_8")
end

function Vernon_silence:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor( "duration" )

	self:GetCaster():EmitSound("VernonUltimate")

	if self:GetCaster():HasTalent("special_bonus_birzha_vernon_8") then
		local point = self:GetCursorPosition()
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, self:GetCaster():FindTalentValue("special_bonus_birzha_vernon_8"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for _, unit in pairs(units) do
			unit:AddNewModifier( self:GetCaster(), self, "modifier_Vernon_silence", { duration = duration * (1 - unit:GetStatusResistance()) } )
			self:PlayEffects2( unit )
		end
		self:PlayEffects1()
		return
	end

	target:AddNewModifier( self:GetCaster(), self, "modifier_Vernon_silence", { duration = duration * (1 - target:GetStatusResistance()) } )
	self:PlayEffects2( target )
	self:PlayEffects1()
end

function Vernon_silence:PlayEffects1()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_silencer/silencer_global_silence.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function Vernon_silence:PlayEffects2( target )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_silencer/silencer_global_silence_hero.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_Vernon_silence = class({})

function modifier_Vernon_silence:IsPurgable() return false end

function modifier_Vernon_silence:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }

    if self:GetCaster():HasTalent("special_bonus_birzha_vernon_7") then
    	funcs = {
        	[MODIFIER_STATE_SILENCED] = true,
        	[MODIFIER_STATE_MUTED] = true,
    	}
	end
    return funcs
end