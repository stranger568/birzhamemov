LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_attack", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_steal_target", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_steal_caster", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_steal_target_debuff", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_steal_caster_buff", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

never_stupid = class({})

function never_stupid:GetIntrinsicModifierName() 
	return "modifier_never_stupid_attack"
end

function never_stupid:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/Stupid_arcana"
	end
	return "Never/Stupid"
end

modifier_never_stupid_attack = class({})

function modifier_never_stupid_attack:IsHidden()
	return true
end

function modifier_never_stupid_attack:OnCreated()
	if not IsServer() then return end
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		self:GetCaster():SetRangedProjectileName("particles/never_arcana/never_arcana_attack.vpcf")
	end
end

function modifier_never_stupid_attack:IsPurgable() return false end

function modifier_never_stupid_attack:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
	}
end

function modifier_never_stupid_attack:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end

	local duration = self:GetAbility():GetSpecialValueFor("steal_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_never_8")

	params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_never_stupid_steal_caster", {duration = duration})
	params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_never_stupid_steal_caster_buff", {duration = duration})
	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_never_stupid_steal_target", {duration = duration * (1-params.target:GetStatusResistance())})
	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_never_stupid_steal_target_debuff", {duration = duration * (1-params.target:GetStatusResistance())})
end

function modifier_never_stupid_attack:GetModifierProcAttack_BonusDamage_Pure(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end
	if not self:GetCaster():HasTalent("special_bonus_birzha_never_6") then
		if params.target:IsMagicImmune() then return end
	end
	local bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_never_4")
	local damage = self:GetParent():GetAgility() / 100 * bonus_damage
	return damage
end

modifier_never_stupid_steal_caster_buff = class({})

function modifier_never_stupid_steal_caster_buff:IsPurgable() return false end
function modifier_never_stupid_steal_caster_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_never_stupid_steal_caster_buff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_never_stupid_steal_caster_buff:OnIntervalThink()
	if not IsServer() then return end
	local modifier = self:GetParent():FindAllModifiersByName("modifier_never_stupid_steal_caster")
	self:SetStackCount(#modifier)
end

function modifier_never_stupid_steal_caster_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
end

function modifier_never_stupid_steal_caster_buff:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("agility_gain") * self:GetStackCount()
end

modifier_never_stupid_steal_target_debuff = class({})

function modifier_never_stupid_steal_target_debuff:IsPurgable() return false end
function modifier_never_stupid_steal_target_debuff:IsHidden() return self:GetStackCount() == 0 end

function modifier_never_stupid_steal_target_debuff:OnCreated()
	if not IsServer() then return end
	donate_shop:QuestProgress(41, self:GetCaster():GetPlayerOwnerID(), 1)
	self:StartIntervalThink(FrameTime())
end

function modifier_never_stupid_steal_target_debuff:OnIntervalThink()
	if not IsServer() then return end
	local modifier = self:GetParent():FindAllModifiersByName("modifier_never_stupid_steal_target")
	self:SetStackCount(#modifier)
end

function modifier_never_stupid_steal_target_debuff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_never_stupid_steal_target_debuff:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("int_steal") * self:GetStackCount()
end

modifier_never_stupid_steal_caster = class({})

function modifier_never_stupid_steal_caster:IsHidden()
	return true
end
function modifier_never_stupid_steal_caster:IsPurgable() return false end

function modifier_never_stupid_steal_caster:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_never_stupid_steal_target = class({})

function modifier_never_stupid_steal_target:IsHidden()
	return true
end

function modifier_never_stupid_steal_target:IsPurgable() return false end

function modifier_never_stupid_steal_target:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_never_spit", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )

never_spit = class({})

function never_spit:GetCooldown(level)
	return (self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_never_3")) / ( self:GetCaster():GetCooldownReduction())
end

modifier_never_spit = class({})

function never_spit:GetIntrinsicModifierName() 
	return "modifier_never_spit"
end

function never_spit:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/SpitArcana"
	end
	return "Never/Spit"
end

function modifier_never_spit:OnCreated()
	if not IsServer() then return end
	self.particle_spit = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		self.particle_spit = "particles/never_arcana/sf_fire_arcana_shadowraze.vpcf"
	end
end

function modifier_never_spit:IsHidden()
	return true
end

function modifier_never_spit:IsPurgable() return false end

function modifier_never_spit:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
end

function modifier_never_spit:GetModifierProcAttack_BonusDamage_Physical( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end
	if not self:GetAbility():IsFullyCastable() then return end

	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_never_7")

	if IsInToolsMode() then
		chance = 100
	end

	if RollPercentage(chance) then	
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_birzha_bashed", {duration = duration * (1 - params.target:GetStatusResistance()) })

		params.target:EmitSound("neverbash")

		self:GetAbility():UseResources(false, false, false, true)

		local SpitEffect = ParticleManager:CreateParticle(self.particle_spit, PATTACH_ABSORIGIN, params.target)

		if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
			ParticleManager:SetParticleControl(SpitEffect, 0, params.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(SpitEffect, 1, params.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(SpitEffect, 3, params.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(SpitEffect, 5, params.target:GetAbsOrigin())
		end

		ParticleManager:ReleaseParticleIndex(SpitEffect)

		local damage = self:GetAbility():GetSpecialValueFor("damage")

		return damage
	end
end

LinkLuaModifier( "modifier_speed_caster", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_speed_friendly", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE)

never_speed = class({})

function never_speed:OnSpellStart() 
	if not IsServer() then return end

	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

	self:GetCaster():EmitSound("never")

	for _,unit in ipairs(units) do
		unit:AddNewModifier(self:GetCaster(), self, "modifier_speed_friendly", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_speed_caster = class({})

function never_speed:GetIntrinsicModifierName() 
	return "modifier_speed_caster"
end

function never_speed:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/SpeedArcana"
	end
	return "Never/Speed"
end

function modifier_speed_caster:IsHidden()
	return true
end

function modifier_speed_caster:IsPurgable() return false end

function modifier_speed_caster:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_speed_caster:GetModifierMoveSpeedBonus_Percentage( keys )
	return self:GetAbility():GetSpecialValueFor("movespeed_caster") + self:GetCaster():FindTalentValue("special_bonus_birzha_never_1")
end

modifier_speed_friendly = class({})

function modifier_speed_friendly:OnCreated()
	if not IsServer() then return end

	if self:GetCaster():HasScepter() and ( not self:GetParent():HasModifier("modifier_movespeed_cap") ) then
		self.modifier_speed = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_movespeed_cap", {})
	end

	self.movespeed_caster = self:GetAbility():GetSpecialValueFor("movespeed_friendly")

	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		local particle_never_speed = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particle_never_speed, false, false, -1, false, false)
	else
		local particle_never_speed = ParticleManager:CreateParticle("particles/never/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particle_never_speed, false, false, -1, false, false)
	end
end

function modifier_speed_friendly:OnDestroy()
	if not IsServer() then return end
	if self.modifier_speed and not self.modifier_speed:IsNull() then
		self.modifier_speed:Destroy()
	end
end

function modifier_speed_friendly:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}
end

function modifier_speed_friendly:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_friendly")
end

function modifier_speed_friendly:GetModifierStatusResistanceStacking()
	return self:GetCaster():FindTalentValue("special_bonus_birzha_never_5")
end

LinkLuaModifier( "modifier_never_damage", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_damage_team", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )

Never_ultimate = class({})

function Never_ultimate:GetIntrinsicModifierName() 
	return "modifier_never_damage"
end

function Never_ultimate:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/UltimateArcana"
	end
	return "Never/Ultimate"
end

function Never_ultimate:OnSpellStart() 
	if not IsServer() then return end
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for _,unit in ipairs(units) do
		if unit ~= self:GetCaster() then
			unit:AddNewModifier(self:GetCaster(), self, "modifier_never_damage_team", {duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_never_damage = class({})

function modifier_never_damage:IsHidden()
	return true
end

function modifier_never_damage:IsPurgable() return false end

function modifier_never_damage:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_never_damage:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_never_damage:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if not self:GetCaster():HasTalent("special_bonus_birzha_never_2") then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetCaster():FindTalentValue("special_bonus_birzha_never_2") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

modifier_never_damage_team = class({})

function modifier_never_damage:IsPurgable()
	return false
end

function modifier_never_damage_team:OnCreated()
	if not IsServer() then return end
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		local particle_never_damage = ParticleManager:CreateParticle("particles/never/ultimate_effect_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particle_never_damage, false, false, -1, false, false)
	else
		local particle_never_damage = ParticleManager:CreateParticle("particles/never/ultimate_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particle_never_damage, false, false, -1, false, false)
	end
end

function modifier_never_damage_team:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_never_damage_team:GetModifierPreAttack_BonusDamage( keys )
	return self:GetAbility():GetSpecialValueFor("bonus_damage_team")
end

never_zxc = class({})

function never_zxc:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/zxc_arcana"
	end
	return "Never/zxc"
end

function never_zxc:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function never_zxc:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function never_zxc:OnSpellStart( this )
	if not IsServer() then return end
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")
	local front = self:GetCaster():GetForwardVector():Normalized()
	local position = self:GetCaster():GetAbsOrigin()
	local distance = 200
	local end_position = position + front * distance

	self:Effect(end_position, radius)
	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), end_position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	for _,enemy in pairs(enemies) do
		ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )
		self:GetCaster():PerformAttack(enemy, true, true, true, false, true, false, false)
	end

	Timers:CreateTimer(0.1, function()
		end_position = position + front * 450
		self:Effect(end_position, radius)
		enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), end_position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		for _,enemy in pairs(enemies) do
			ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )
			self:GetCaster():PerformAttack(enemy, true, true, true, false, true, false, false)
		end
	end)

	Timers:CreateTimer(0.2, function()
		end_position = position + front * 700
		self:Effect(end_position, radius)
		enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), end_position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		for _,enemy in pairs(enemies) do
			ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )
			self:GetCaster():PerformAttack(enemy, true, true, true, false, true, false, false)
		end
	end)
end

function never_zxc:Effect(position, radius)
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( effect_cast, 0, position )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 1, 1 ) )
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		ParticleManager:SetParticleControl( effect_cast, 60, Vector( 0, 246, 255 ) )
		ParticleManager:SetParticleControl( effect_cast, 61, Vector( 1, 1, 1 ) )
	end
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( position, "Hero_Nevermore.Shadowraze", self:GetCaster() )
end

