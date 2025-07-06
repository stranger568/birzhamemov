LinkLuaModifier("modifier_kaneki_ghoul_stacks", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kaneki_ghoul_slow", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

kaneki_ghoul = class({})

function kaneki_ghoul:Precache(context)
    PrecacheResource("model", "models/update_heroes/kaneki/kaneki.vmdl", context)
    local particle_list = 
    {
        "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff_ground.vpcf",
        "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf",
        "particles/units/heroes/hero_visage/visage_grave_chill_tgt.vpcf",
        "particles/kaneki_cup2.vpcf",
        "particles/kaneki/cup_buff.vpcf",
        "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf",
        "particles/econ/events/ti4/teleport_end_ground_flash_ti4.vpcf",
        "particles/kaneki_helix.vpcf",
        "particles/items2_fx/soul_ring_blood.vpcf",
        "particles/kaneki_kagune.vpcf",
        "particles/kaneki_kagune_rope.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
    PrecacheResource("model", "models/update_heroes/kaneki/kaneki_form.vmdl", context)
end

function kaneki_ghoul:GetCooldown(level)
	if self:GetCaster():HasTalent("special_bonus_birzha_kaneki_7") then
		return 0
	end
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function kaneki_ghoul:GetIntrinsicModifierName()
	return "modifier_kaneki_ghoul_stacks"
end

modifier_kaneki_ghoul_stacks = class({})

function modifier_kaneki_ghoul_stacks:IsPurgable()
	return false
end

function modifier_kaneki_ghoul_stacks:IsHidden() return self:GetStackCount() == 0 end

function modifier_kaneki_ghoul_stacks:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_kaneki_ghoul_stacks:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.target:IsBuilding() then return end
	if params.target == params.attacker then return end
	if params.attacker:IsIllusion() then return end
	if not self:GetAbility():IsFullyCastable() then return end

	local max_stack = self:GetAbility():GetSpecialValueFor("max_stack") + self:GetCaster():FindTalentValue("special_bonus_birzha_kaneki_5")
	local duration = self:GetAbility():GetSpecialValueFor("duration")

	params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kaneki_ghoul_slow", { duration = duration * (1 - params.target:GetStatusResistance()) })

	local particle = ParticleManager:CreateParticle( "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target )
	ParticleManager:SetParticleControlEnt( particle, 1, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( particle )

	if self:GetStackCount() < max_stack then
		self:SetStackCount(self:GetStackCount() + 1)
	end

	if self:GetStackCount() == max_stack then
		if not self:GetCaster():HasTalent("special_bonus_birzha_kaneki_7") then
			self:GetAbility():UseResources(false, false, false, true)
		end
		self:SetStackCount(0)
	end
end

function modifier_kaneki_ghoul_stacks:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if not self:GetAbility():IsFullyCastable() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("heal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    	ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_kaneki_ghoul_stacks:GetModifierPreAttack_BonusDamage()
	if self:GetParent():PassivesDisabled() then return end
	return (self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_kaneki_1")) * self:GetStackCount()
end

function modifier_kaneki_ghoul_stacks:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():PassivesDisabled() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") * self:GetStackCount()
end

modifier_kaneki_ghoul_slow = class({})

function modifier_kaneki_ghoul_slow:IsPurgable()
	return false
end

function modifier_kaneki_ghoul_slow:OnCreated()
    if not IsServer() then return end
    self.movespeed_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
    self.attack_speed_slow = self:GetAbility():GetSpecialValueFor("attack_speed_slow")
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_kaneki_ghoul_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_kaneki_ghoul_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed_slow
end

function modifier_kaneki_ghoul_slow:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_slow
end

LinkLuaModifier("modifier_cup_buff", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)

kaneki_coffee = class({})

function kaneki_coffee:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kaneki_coffee:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kaneki_coffee:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function kaneki_coffee:OnSpellStart()
	if not IsServer() then return end

	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local target = nil

	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_cup_buff", {duration = duration})

	self:GetCaster():EmitSound("kanekidrink")

	local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("ATTACH_hEAD"))

	if #units == 0 then return end

	target = units[1]

	local info = 
	{
		EffectName = "particles/kaneki_cup2.vpcf",
		Dodgeable = true,
		Ability = self,
		ProvidesVision = true,
		VisionRadius = 0,
		bVisibleToEnemies = true,
		iMoveSpeed = 1000,
		Source = self:GetCaster(),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		Target = target,
		bReplaceExisting = false,
		vSpawnOrigin = point
	}

	local cup = ProjectileManager:CreateTrackingProjectile(info)
end

function kaneki_coffee:OnProjectileHit(target,_)
	if not IsServer() then return end

	local damage = self:GetSpecialValueFor("damage")

	if target ~= nil and ( not target:IsMagicImmune() ) then
		ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

modifier_cup_buff = class({})

function modifier_cup_buff:IsPurgable()
	return false
end

function modifier_cup_buff:OnCreated()
	self.resist = self:GetAbility():GetSpecialValueFor("damage_resist")
    self.spell_resist = self:GetAbility():GetSpecialValueFor("spell_resist") + self:GetCaster():FindTalentValue("special_bonus_birzha_kaneki_4")
end

function modifier_cup_buff:DeclareFunctions()
return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function modifier_cup_buff:GetModifierIncomingDamage_Percentage()
	return self.resist
end

function modifier_cup_buff:GetModifierStatusResistanceStacking()
	return self.spell_resist
end

function modifier_cup_buff:GetEffectName()
	return "particles/kaneki/cup_buff.vpcf"
end

LinkLuaModifier("modifier_kaneki_feeling_aura", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kaneki_feeling_debuff", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kaneki_feeling_debuff_vision", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)

kaneki_feeling = class({})

function kaneki_feeling:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function kaneki_feeling:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function kaneki_feeling:GetIntrinsicModifierName()
	return "modifier_kaneki_feeling_aura"
end

modifier_kaneki_feeling_aura = class({})

function modifier_kaneki_feeling_aura:IsPurgable()
	return false
end

function modifier_kaneki_feeling_aura:IsAura()
	return not self:GetParent():IsIllusion()
end

function modifier_kaneki_feeling_aura:GetModifierAura()
	return "modifier_kaneki_feeling_debuff"
end

function modifier_kaneki_feeling_aura:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_kaneki_feeling_aura:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, 
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
	}
end

function modifier_kaneki_feeling_aura:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") * self:GetStackCount()
end

function modifier_kaneki_feeling_aura:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus") * self:GetStackCount()
end

function modifier_kaneki_feeling_aura:OnIntervalThink()
	local stack = 0
	for _,hero in pairs (HeroList:GetAllHeroes()) do
		if hero:IsRealHero() then
			if hero:HasModifier("modifier_kaneki_feeling_debuff_vision") then
				stack = stack + 1
			end
		end
	end
	self:SetStackCount(stack)
end

function modifier_kaneki_feeling_aura:GetAuraRadius()
	return 999999
end

function modifier_kaneki_feeling_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_kaneki_feeling_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_kaneki_feeling_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_kaneki_feeling_debuff = class({})

function modifier_kaneki_feeling_debuff:IsHidden()
	return true
end

function modifier_kaneki_feeling_debuff:IsPurgable()
	return false
end

function modifier_kaneki_feeling_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_kaneki_feeling_debuff:OnIntervalThink()
	if not IsServer() then return end
	local hp_need = self:GetAbility():GetSpecialValueFor("hp_need")
	if self:GetParent():HasModifier("modifier_fountain_passive_invul") then self:GetParent():RemoveModifierByName("modifier_kaneki_feeling_debuff_vision") end
	if self:GetParent():GetHealth() <= self:GetParent():GetMaxHealth() / 100 * hp_need then
		if not self:GetParent():HasModifier("modifier_kaneki_feeling_debuff_vision") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kaneki_feeling_debuff_vision", {})
		end
	else
		if self:GetParent():HasModifier("modifier_kaneki_feeling_debuff_vision") then
			self:GetParent():RemoveModifierByName("modifier_kaneki_feeling_debuff_vision")
		end
	end
end

modifier_kaneki_feeling_debuff_vision = class({})

function modifier_kaneki_feeling_debuff_vision:IsHidden()
	return false
end

function modifier_kaneki_feeling_debuff_vision:IsPurgable()
	return false
end

function modifier_kaneki_feeling_debuff_vision:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_kaneki_feeling_debuff_vision:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration = 0.1})
	AddFOWViewer(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), 50, FrameTime(), false)
end

function modifier_kaneki_feeling_debuff_vision:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

LinkLuaModifier("modifier_kaneki_rage", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_NONE)

kaneki_rage = class({})

function kaneki_rage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kaneki_rage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kaneki_rage:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function kaneki_rage:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("kanekiunravel")
	return true
end

function kaneki_rage:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("kanekiunravel")
end

function kaneki_rage:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local particle = ParticleManager:CreateParticle( "particles/econ/events/ti4/teleport_end_ground_flash_ti4.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( particle )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kaneki_rage", {duration = duration})
end

modifier_kaneki_rage = class({})

function modifier_kaneki_rage:AllowIllusionDuplicate() return true end

function modifier_kaneki_rage:OnCreated()
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_kaneki_rage:IsPurgable()
	return false
end

function modifier_kaneki_rage:OnIntervalThink()
	if not IsServer() then return end
	local stack = 100 - ( self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() * 100 )
	self:SetStackCount(stack)
end

function modifier_kaneki_rage:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_MODEL_CHANGE }
end

function modifier_kaneki_rage:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsIllusion() then return end
	return self.bonus_armor * self:GetStackCount()
end

function modifier_kaneki_rage:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():IsIllusion() then return end
	return self.bonus_attack_speed * self:GetStackCount()
end

function modifier_kaneki_rage:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.target:IsBuilding() then return end
	if params.target == params.attacker then return end
	if params.attacker:IsIllusion() then return end

	local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_kaneki_6")
	local multiplier = self:GetAbility():GetSpecialValueFor("multi_str")
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local multiplier_damage = damage + (self:GetParent():GetStrength() * multiplier)

	if RollPercentage(chance) then
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_1)

		local particle = ParticleManager:CreateParticle( "particles/kaneki_helix.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
		ParticleManager:ReleaseParticleIndex( particle )

		local units = FindUnitsInRadius( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
		for _,target in pairs (units) do
			ApplyDamage({attacker = self:GetParent(), victim = target, damage = multiplier_damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_PURE})
		end
	end
end

function modifier_kaneki_rage:GetModifierModelChange()
	return "models/update_heroes/kaneki/kaneki_form.vmdl"
end

function modifier_kaneki_rage:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():StopSound("kanekiunravel")
end

kaneki_pull = class({})
kaneki_pull.projectiles = {}

LinkLuaModifier("modifier_kaneki_pull_debuff", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_kaneki_pull_movespeed", "abilities/heroes/kaneki", LUA_MODIFIER_MOTION_BOTH)

function kaneki_pull:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_birzha_kaneki_8") then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function kaneki_pull:GetAOERadius()
    return 200
end

function kaneki_pull:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_birzha_kaneki_8" )
end

function kaneki_pull:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
    self:PullTarget(target)
    if self:GetCaster():HasTalent("special_bonus_unique_birzha_kaneki_8") then
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )
        for _, unit in pairs(units) do
            if unit and unit ~= target then
                self:PullTarget(unit)
            end
        end
    end
end

function kaneki_pull:PullTarget(target)
    local point = target:GetAbsOrigin()
	local projectile_direction = point-self:GetCaster():GetOrigin()
	projectile_direction.z = 0
	local length = projectile_direction:Length2D()
	projectile_direction = projectile_direction:Normalized()
	local effect = self:PlayEffects( target, 1200, length/1200 )
    local info = 
    {
        Target = target,
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "",
        iMoveSpeed = 1200,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionRadius = 25,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()
    }
    local projectile = ProjectileManager:CreateTrackingProjectile(info)
	self.projectiles[ projectile ] = effect
	self:GetCaster():EmitSound("kaneki_shard")
end

function kaneki_pull:OnProjectileHitHandle( target, location, handle )
	local ExtraData = self.projectiles[ handle ]
	if not ExtraData then return end
	ParticleManager:DestroyParticle( ExtraData, false )
	ParticleManager:ReleaseParticleIndex( ExtraData )
	if target == nil then return end
	local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_kaneki_2")
	target:EmitSound("kaneki_shard_target")

	if not target:IsMagicImmune() then
		ParticleManager:CreateParticle("particles/items2_fx/soul_ring_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
		target:AddNewModifier(self:GetCaster(), self, "modifier_kaneki_pull_debuff", {})
		if self:GetCaster():HasTalent("special_bonus_birzha_kaneki_3") then
			self:GetCaster():PerformAttack(target, false, true, true, false, false, false, true)
		end
	end

	self.projectiles[ handle ] = nil
end

function kaneki_pull:PlayEffects( target, speed, duration )
	local effect_cast = ParticleManager:CreateParticle( "particles/kaneki_kagune.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( duration*2 + 0.3, 0, 0 ) )
	return effect_cast
end

modifier_kaneki_pull_debuff = class({})

function modifier_kaneki_pull_debuff:IsPurgable() return false end

function modifier_kaneki_pull_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())

	local effect_cast = ParticleManager:CreateParticle( "particles/kaneki_kagune_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )

	self:AddParticle(effect_cast, false, false, -1, false, false)
end

function modifier_kaneki_pull_debuff:OnDestroy()
	if not IsServer() then return end
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
end

function modifier_kaneki_pull_debuff:OnIntervalThink()
	if not IsServer() then return end
    local unit_location = self:GetParent():GetAbsOrigin()
    local vector_distance = self:GetCaster():GetAbsOrigin() - unit_location
    local distance = (vector_distance):Length2D()
    local direction = (vector_distance):Normalized()

    if not self:GetCaster():IsAlive() then self:Destroy() return end

    local pull = 100

    if distance >= 1000 then
    	self:Destroy()
    	return
    end

    if distance >= 150 then
        self:GetParent():SetAbsOrigin(unit_location + direction * pull)
    else
        self:Destroy()

        local duration = self:GetAbility():GetSpecialValueFor("duration")

        if self:GetCaster():HasShard() then
        	local shard_stun_duration = self:GetAbility():GetSpecialValueFor("shard_stun_duration")
        	duration = duration + shard_stun_duration
        	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = shard_stun_duration * (1 - self:GetParent():GetStatusResistance()) })
        end

        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kaneki_pull_movespeed", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 - self:GetParent():GetStatusResistance()) })
    end
end


modifier_kaneki_pull_movespeed = class({})

function modifier_kaneki_pull_movespeed:IsPurgable() return true end

function modifier_kaneki_pull_movespeed:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_kaneki_pull_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end