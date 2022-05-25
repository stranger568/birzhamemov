LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_attack", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_steal_target", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_stupid_steal_caster", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

never_stupid = class({})

modifier_never_stupid_attack = class({})
modifier_never_stupid_steal_target = class({})
modifier_never_stupid_steal_caster = class({})

function never_stupid:GetIntrinsicModifierName() 
	return "modifier_never_stupid_attack"
end

function modifier_never_stupid_attack:OnCreated()
	if not IsServer() then return end
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		self:GetCaster():SetRangedProjectileName("particles/never_arcana/never_arcana_attack.vpcf")
	end
end

function never_stupid:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/Stupid_arcana"
	end
	return "Never/Stupid"
end

function modifier_never_stupid_attack:IsHidden()
	return true
end

function modifier_never_stupid_attack:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_never_stupid_attack:OnAttackLanded( keys )
	if not IsServer() then return end
	local attacker = self:GetParent()
	local duration = self:GetAbility():GetSpecialValueFor("steal_duration")
	if attacker ~= keys.attacker then
		return
	end

	if attacker:IsIllusion() or attacker:PassivesDisabled() then
		return
	end

	local target = keys.target
	if attacker:GetTeam() == target:GetTeam() then
		return
	end	

	if target:IsOther() or (not target:IsRealHero()) then
		return nil
	end

	attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_never_stupid_steal_caster", {duration = duration})
	target:AddNewModifier(attacker, self:GetAbility(), "modifier_never_stupid_steal_target", {duration = duration})
	local bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage") / 100

	local damage_table = {}

	damage_table.attacker = attacker
	damage_table.damage_type = self:GetAbility():GetAbilityDamageType()
	damage_table.ability = self:GetAbility()
	damage_table.victim = target
	damage_table.damage = attacker:GetAgility() * bonus_damage

	ApplyDamage(damage_table)
end

function modifier_never_stupid_steal_caster:IsHidden()
	return true
end

function modifier_never_stupid_steal_caster:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_never_stupid_steal_caster:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_never_stupid_steal_caster:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("agility_gain")
end

function modifier_never_stupid_steal_target:IsHidden()
	return true
end

function modifier_never_stupid_steal_target:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_never_stupid_steal_target:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_never_stupid_steal_target:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("int_steal")
end

LinkLuaModifier( "modifier_never_spit", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )

never_spit = class({})

function never_spit:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
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

function modifier_never_spit:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_never_spit:OnAttackLanded( keys )
	if IsServer() then
		local attacker = self:GetParent()

		if attacker ~= keys.attacker then
			return
		end

		if attacker:IsIllusion() or attacker:PassivesDisabled() then
			return
		end

		local target = keys.target
		if attacker:GetTeam() == target:GetTeam() then
			return
		end	
		if target:IsOther() then
			return nil
		end
		if not self:GetAbility():IsFullyCastable() then return end

		local duration = self:GetAbility():GetSpecialValueFor("duration")
		local chance = self:GetAbility():GetSpecialValueFor("chance")
		local random = RandomInt(1, 100)

		if IsInToolsMode() then
			chance = 100
		end

		if random <= chance then	
			target:AddNewModifier(attacker, self:GetAbility(), "modifier_birzha_bashed", {duration = duration})
			attacker:EmitSound("neverbash")
			local damage = self:GetAbility():GetSpecialValueFor("damage")
			local damage_table = {}
			damage_table.attacker = attacker
			damage_table.damage_type = self:GetAbility():GetAbilityDamageType()
			damage_table.ability = self:GetAbility()
			damage_table.victim = target
			damage_table.damage = damage
			ApplyDamage(damage_table)
			self:GetAbility():UseResources(false, false, true)
			local SpitEffect = ParticleManager:CreateParticle(self.particle_spit, PATTACH_ABSORIGIN, target)
			if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
				ParticleManager:SetParticleControl(SpitEffect, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(SpitEffect, 1, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(SpitEffect, 3, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(SpitEffect, 5, target:GetAbsOrigin())
			end
		end
	end
end

LinkLuaModifier( "modifier_speed_caster", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_speed_friendly", "abilities/heroes/never.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE)

never_speed = class({})

function never_speed:OnSpellStart() 
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	self:GetCaster():EmitSound("never")
	for _,unit in ipairs(units) do
		unit:AddNewModifier(self:GetCaster(), self, "modifier_speed_friendly", {duration = 5})
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

function modifier_speed_caster:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_speed_caster:GetModifierMoveSpeedBonus_Percentage( keys )
	return self:GetAbility():GetSpecialValueFor("movespeed_caster")
end

modifier_speed_friendly = class({})

function modifier_speed_friendly:OnCreated()
	if not IsServer() then return end
	if self:GetCaster():HasScepter() and ( not self:GetParent():HasModifier("modifier_movespeed_cap") ) then
		self.modifier_speed = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_movespeed_cap", {})
	end
	self.movespeed_caster = self:GetAbility():GetSpecialValueFor("movespeed_friendly")
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		self:GetParent().particle_never_speed = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	else
		self:GetParent().particle_never_speed = ParticleManager:CreateParticle("particles/never/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_speed_friendly:OnDestroy()
	if self.modifier_speed and not self.modifier_speed:IsNull() then
		self.modifier_speed:Destroy()
	end
	if self:GetParent().particle_never_speed then
		ParticleManager:DestroyParticle(self:GetParent().particle_never_speed, false)
	end
end

function modifier_speed_friendly:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_speed_friendly:GetModifierMoveSpeedBonus_Percentage( keys )
	return self:GetAbility():GetSpecialValueFor("movespeed_friendly")
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
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for _,unit in ipairs(units) do
		if unit ~= self:GetCaster() then
			unit:AddNewModifier(self:GetCaster(), self, "modifier_never_damage_team", {duration = 15})
		end
	end
end

modifier_never_damage = class({})

function modifier_never_damage:IsHidden()
	return true
end

function modifier_never_damage:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_never_damage:GetModifierPreAttack_BonusDamage( keys )
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

modifier_never_damage_team = class({})

function modifier_never_damage:IsPurgable()
	return false
end

function modifier_never_damage_team:OnCreated()
	if not IsServer() then return end
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage_team")
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 27) then
		self:GetParent().particle_never_damage = ParticleManager:CreateParticle("particles/never/ultimate_effect_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	else
		self:GetParent().particle_never_damage = ParticleManager:CreateParticle("particles/never/ultimate_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_never_damage_team:OnDestroy()
	if self:GetParent().particle_never_damage then
		ParticleManager:DestroyParticle(self:GetParent().particle_never_damage, false)
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
		ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, } )
	end

	Timers:CreateTimer(0.1, function()
		end_position = position + front * 450
		self:Effect(end_position, radius)
		enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), end_position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		for _,enemy in pairs(enemies) do
			ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, } )
		end
	end)

	Timers:CreateTimer(0.2, function()
		end_position = position + front * 700
		self:Effect(end_position, radius)
		enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), end_position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
		for _,enemy in pairs(enemies) do
			ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, } )
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

