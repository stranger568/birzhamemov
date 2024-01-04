LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Felix_WaterStream_scepter", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)

Felix_WaterStream = class({})

function Felix_WaterStream:GetCastRange()
	return self:GetSpecialValueFor( "radius" )
end

function Felix_WaterStream:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level )
end

function Felix_WaterStream:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Felix_WaterStream:GetIntrinsicModifierName()
	return "modifier_Felix_WaterStream_scepter"
end

function Felix_WaterStream:OnInventoryContentsChanged()
	if self:GetIntrinsicModifierName() and self:GetCaster():HasModifier(self:GetIntrinsicModifierName()) then
		if self:GetCaster():HasScepter() then
			self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):StartIntervalThink(self:GetSpecialValueFor("scepter_cooldown"))
		else
			self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):StartIntervalThink(-1)
		end
	end
end

function Felix_WaterStream:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function Felix_WaterStream:OnSpellStart()
	if not IsServer() then return end
	local radius = self:GetSpecialValueFor( "radius" )
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	self:GetCaster():EmitSound("FelixOne")    
	if #targets == 0 then return end
	self:GetCaster():EmitSound("Hero_Morphling.AdaptiveStrikeAgi.Cast")
	for _,unit in pairs(targets) do
		local WaterProj
		if self:GetCaster():GetTeamNumber() == unit:GetTeamNumber() then
			WaterProj = 
			{
				Target = unit,
				Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/units/heroes/hero_morphling/morphling_adaptive_strike_agi_proj.vpcf",
				iMoveSpeed = 800,
				bDodgeable = false, 
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,  
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,                        
			}
		else
			WaterProj = 
			{
				Target = unit,
				Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/units/heroes/hero_morphling/morphling_adaptive_strike_str_proj.vpcf",
				iMoveSpeed = 800,
				bDodgeable = true, 
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,  
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,                          
			}
		end
		ProjectileManager:CreateTrackingProjectile(WaterProj)
	end
end

function Felix_WaterStream:ScepterTarget(target)
	if not IsServer() then return end
	self:GetCaster():EmitSound("FelixOne")
	self:GetCaster():EmitSound("Hero_Morphling.AdaptiveStrikeAgi.Cast")
	local WaterProj
	if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() then
		WaterProj = 
		{
			Target = target,
		  	Source = self:GetCaster(),
		  	Ability = self,
		  	EffectName = "particles/units/heroes/hero_morphling/morphling_adaptive_strike_agi_proj.vpcf",
		  	iMoveSpeed = 800,
		  	bDodgeable = false, 
		  	bVisibleToEnemies = true,
		  	bReplaceExisting = false,
		  	bProvidesVision = false,  
		  	iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,                        
		}
	else
		WaterProj = 
		{
			Target = target,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_morphling/morphling_adaptive_strike_str_proj.vpcf",
			iMoveSpeed = 800,
			bDodgeable = true, 
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			bProvidesVision = false,  
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,                          
		}
	end
	ProjectileManager:CreateTrackingProjectile(WaterProj)
end


modifier_Felix_WaterStream_scepter = class({})

function modifier_Felix_WaterStream_scepter:IsHidden() return true end
function modifier_Felix_WaterStream_scepter:IsPurgable() return false end
function modifier_Felix_WaterStream_scepter:RemoveOnDeath()	return false end

function modifier_Felix_WaterStream_scepter:OnIntervalThink()
	local target = nil
	local friendly_25 = nil
	local friendly_50 = nil
	local friendly_75 = nil
	local friendly_90 = nil
	local enemy_25 = nil
	local enemy_50 = nil
	local enemy_75 = nil
	local enemy_90 = nil

	if self:GetParent():HasScepter() and not self:GetParent():IsOutOfGame() and not self:GetParent():IsInvisible() and not self:GetParent():PassivesDisabled() and self:GetParent():IsAlive() then
		for _, guy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)) do
			if guy:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 25 then
					friendly_25 = guy
				end
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 50 then
					friendly_50 = guy
				end
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 75 then
					friendly_75 = guy
				end
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 90 then
					friendly_90 = guy
				end
			else
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 25 then
					enemy_25 = guy
				end
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 50 then
					enemy_50 = guy
				end
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 75 then
					enemy_75 = guy
				end
				if guy:GetHealth() < guy:GetMaxHealth() / 100 * 90 then
					enemy_90 = guy
				end
			end	
		end
		if friendly_25 ~= nil then
			target = friendly_25
		elseif friendly_50 ~= nil then
			target = friendly_50
		elseif friendly_75 ~= nil then
			target = friendly_75
		elseif friendly_90 ~= nil then
			target = friendly_90
		elseif friendly_25 ~= nil then
			target = enemy_25
		elseif friendly_50 ~= nil then
			target = enemy_50
		elseif friendly_75 ~= nil then
			target = enemy_75
		elseif friendly_90 ~= nil then
			target = enemy_90
		end
		if target == nil then
			local mas = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
			target = mas[RandomInt(1, #mas)]
		end
		if target ~= nil then
			self:GetAbility():ScepterTarget(target)
		end
	end
end

function Felix_WaterStream:OnProjectileHit(target, location, extra_data)
	if not IsServer() then return end
	local intellect_perc = self:GetSpecialValueFor("intellect_perc") + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_4")
	local damage = self:GetSpecialValueFor("damage") + (self:GetCaster():GetIntellect() / 100 * intellect_perc)
	local heal = self:GetSpecialValueFor("heal") + (self:GetCaster():GetIntellect() / 100 * intellect_perc)

	target:EmitSound("Hero_Morphling.AdaptiveStrike") 
	   
	if target ~= nil then
		if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() then
			target:Heal(heal, self)
		else
			ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
			if self:GetCaster():HasTalent("special_bonus_birzha_felix_5") then
				self:GetCaster():PerformAttack(target, true, true, true, false, true, false, false)
			end
		end
	end
end

LinkLuaModifier("modifier_Felix_ItsATrap", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)

Felix_ItsATrap = class({})

function Felix_ItsATrap:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Felix_ItsATrap:GetCooldown(level)
	if self:GetCaster():HasShard() then
        return self:GetSpecialValueFor( "scepter_cd" )
    end
	return self.BaseClass.GetCooldown( self, level )
end

function Felix_ItsATrap:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Felix_ItsATrap:GetAOERadius()
    if self:GetCaster():HasShard() then
        return self:GetSpecialValueFor( "radius" )
    end
    return 0
end

function Felix_ItsATrap:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasShard()) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function Felix_ItsATrap:GetBehavior()
    local caster = self:GetCaster()
    local scepter = caster:HasShard()
    if scepter then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function Felix_ItsATrap:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_3")

	if self:GetCaster():HasShard() then
    	duration = self:GetSpecialValueFor("stun_duration_scepter") + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_3")
	end

	self:GetCaster():EmitSound("FelixTwo")

	if self:GetCaster():HasShard() then
        local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor( "radius" ), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false )
        for _,enemy in pairs(targets) do
        	enemy:AddNewModifier(self:GetCaster(), self, "modifier_Felix_ItsATrap", {duration = duration * (1 - enemy:GetStatusResistance())})
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration * (1 - enemy:GetStatusResistance())})
        end
    else
		if self:GetCursorTarget():TriggerSpellAbsorb( self ) then
	        return
	    end
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_Felix_ItsATrap", {duration = duration * (1 - self:GetCursorTarget():GetStatusResistance())})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration * (1 - self:GetCursorTarget():GetStatusResistance())})
	end
end

modifier_Felix_ItsATrap = class({})

function modifier_Felix_ItsATrap:IsPurgable() return false end
function modifier_Felix_ItsATrap:IsPurgeException() return false end

function modifier_Felix_ItsATrap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_Felix_ItsATrap:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("resist_minus") + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_1")
end

function modifier_Felix_ItsATrap:GetModifierStatusResistanceStacking()
	return self:GetAbility():GetSpecialValueFor("resist_minus") + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_1")
end

function modifier_Felix_ItsATrap:GetEffectName()
	return "particles/felix_itstrap.vpcf"
end

LinkLuaModifier("modifier_Felix_NyashaCat_aura", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Felix_NyashaCat", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Felix_NyashaCat_debuff", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Felix_NyashaCat_buff", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)

Felix_NyashaCat = class({})

function Felix_NyashaCat:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level )
end

function Felix_NyashaCat:GetManaCost(level)
    return self:GetCaster():GetMaxMana() / 100 * self:GetLevelSpecialValueFor("mana", level)
end

function Felix_NyashaCat:OnSpellStart()
	if IsServer() then
		self.targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 999999, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		if #self.targets == 0 then return end
		for _,unit in pairs(self.targets) do
			local duration = self:GetSpecialValueFor( "duration" )
			if unit:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
				unit:AddNewModifier(self:GetCaster(), self, "modifier_Felix_NyashaCat_buff", {duration = duration})
			else
				unit:AddNewModifier(self:GetCaster(), self, "modifier_Felix_NyashaCat_debuff", {duration = duration})
			end
		end
	end
end

function Felix_NyashaCat:GetIntrinsicModifierName() 
	return "modifier_Felix_NyashaCat_aura"
end

modifier_Felix_NyashaCat_aura = class({})

function modifier_Felix_NyashaCat_aura:IsAura() return true end
function modifier_Felix_NyashaCat_aura:IsAuraActiveOnDeath() return false end
function modifier_Felix_NyashaCat_aura:IsBuff() return true end
function modifier_Felix_NyashaCat_aura:IsHidden() return true end
function modifier_Felix_NyashaCat_aura:IsPermanent() return true end
function modifier_Felix_NyashaCat_aura:IsPurgable() return false end

function modifier_Felix_NyashaCat_aura:GetAuraRadius()
	return 9999999
end

function modifier_Felix_NyashaCat_aura:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_Felix_NyashaCat_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_Felix_NyashaCat_aura:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_Felix_NyashaCat_aura:GetModifierAura()
	return "modifier_Felix_NyashaCat"
end

modifier_Felix_NyashaCat = class({})

function modifier_Felix_NyashaCat:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function modifier_Felix_NyashaCat:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("heal_regeneration")
end

function modifier_Felix_NyashaCat:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regeneration")
end

modifier_Felix_NyashaCat_debuff = class({})

function modifier_Felix_NyashaCat_debuff:IsPurgable() 
	return true 
end

function modifier_Felix_NyashaCat_debuff:OnCreated()
	local intellect_math_2 = self:GetAbility():GetSpecialValueFor("intellect_math_2")
	self.heal_lose = self:GetAbility():GetSpecialValueFor("heal_lose") - (self:GetCaster():GetIntellect() / intellect_math_2)
	if not IsServer() then return end
	local NyashaCat_debuff_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:ReleaseParticleIndex(NyashaCat_debuff_particle)
end

function modifier_Felix_NyashaCat_debuff:OnRefresh()
	local intellect_math_2 = self:GetAbility():GetSpecialValueFor("intellect_math_2")
	self.heal_lose = self:GetAbility():GetSpecialValueFor("heal_lose") - (self:GetCaster():GetIntellect() / intellect_math_2)
end

function modifier_Felix_NyashaCat_debuff:Custom_HealAmplifyReduce()
	return self.heal_lose + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_6")
end

function modifier_Felix_NyashaCat_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
	}
	return funcs
end

function modifier_Felix_NyashaCat_debuff:GetModifierHPRegenAmplify_Percentage()
    return self.heal_lose + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_6")
end

function modifier_Felix_NyashaCat_debuff:GetEffectName()
	return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_Felix_NyashaCat_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_gush.vpcf"
end

modifier_Felix_NyashaCat_buff = class({})

function modifier_Felix_NyashaCat_buff:IsPurgable() 
	return true 
end

function modifier_Felix_NyashaCat_buff:OnCreated()
	local intellect_math = self:GetAbility():GetSpecialValueFor("intellect_math")
	self.percent = self:GetAbility():GetSpecialValueFor( "bonus_attribute" ) + (self:GetCaster():GetIntellect() / intellect_math)
	self.base_bonus = self:GetAbility():GetSpecialValueFor( "base_attribute" )
    self.str_bonus = self.base_bonus + (self:GetParent():GetStrength() / 100 * self.percent)
    self.agi_bonus = self.base_bonus + (self:GetParent():GetAgility() / 100 * self.percent)
    self.int_bonus = self.base_bonus + (self:GetParent():GetIntellect() / 100 * self.percent)
    if not IsServer() then return end
    local NyashaCat_debuff_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:ReleaseParticleIndex(NyashaCat_debuff_particle)
end

function modifier_Felix_NyashaCat_buff:OnRefresh()
	local intellect_math = self:GetAbility():GetSpecialValueFor("intellect_math")
	self.percent = self:GetAbility():GetSpecialValueFor( "bonus_attribute" ) + (self:GetCaster():GetIntellect() / intellect_math)
	self.base_bonus = self:GetAbility():GetSpecialValueFor( "base_attribute" )
    self.str_bonus = self.base_bonus + (self:GetParent():GetStrength() / 100 * self.percent)
    self.agi_bonus = self.base_bonus + (self:GetParent():GetAgility() / 100 * self.percent)
    self.int_bonus = self.base_bonus + (self:GetParent():GetIntellect() / 100 * self.percent)
end

function modifier_Felix_NyashaCat_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_Felix_NyashaCat_buff:GetModifierBonusStats_Strength()
	return self.str_bonus
end

function modifier_Felix_NyashaCat_buff:GetModifierBonusStats_Agility()
	return self.agi_bonus
end

function modifier_Felix_NyashaCat_buff:GetModifierBonusStats_Intellect()
	return self.int_bonus
end

function modifier_Felix_NyashaCat_buff:GetEffectName()
	return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_Felix_NyashaCat_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_gush.vpcf"
end

LinkLuaModifier("modifier_Felix_WaterShield_aura", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Felix_WaterShield", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)

Felix_WaterShield = class({})

function Felix_WaterShield:GetCastRange()
	return self:GetSpecialValueFor( "radius" )
end

function Felix_WaterShield:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level )
end

function Felix_WaterShield:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Felix_WaterShield:OnSpellStart()
	if IsServer() then
		self:GetCaster():EmitSound("FelixUltimate")
		local duration = self:GetSpecialValueFor( "duration" )
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Felix_WaterShield_aura", {duration = duration})
	end
end

modifier_Felix_WaterShield_aura = class({})

function modifier_Felix_WaterShield_aura:IsAura() return true end
function modifier_Felix_WaterShield_aura:IsAuraActiveOnDeath() return false end
function modifier_Felix_WaterShield_aura:IsBuff() return true end
function modifier_Felix_WaterShield_aura:IsHidden() return false end
function modifier_Felix_WaterShield_aura:IsPermanent() return true end
function modifier_Felix_WaterShield_aura:IsPurgable() return false end

function modifier_Felix_WaterShield_aura:OnCreated()
	if not IsServer() then return end
	self.particle_1 = ParticleManager:CreateParticle("particles/act_2/siltbreaker_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle_1, 0, self:GetParent():GetAbsOrigin())
	self.particle_2 = ParticleManager:CreateParticle("particles/act_2/ice_boss_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle_2, 0, self:GetParent():GetAbsOrigin())
end

function modifier_Felix_WaterShield_aura:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("FelixUltimate")
end

function modifier_Felix_WaterShield_aura:OnDestroy()
	if not IsServer() then return end
	if self.particle_1 then
		ParticleManager:DestroyParticle(self.particle_1,true)
	end
	if self.particle_2 then
		ParticleManager:DestroyParticle(self.particle_2,true)
	end
end

function modifier_Felix_WaterShield_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_Felix_WaterShield_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_Felix_WaterShield_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_Felix_WaterShield_aura:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_Felix_WaterShield_aura:GetModifierAura()
	return "modifier_Felix_WaterShield"
end

modifier_Felix_WaterShield = class({})

function modifier_Felix_WaterShield:IsPurgable() return false end

function modifier_Felix_WaterShield:GetStatusEffectName()
	return "particles/status_fx/status_effect_morphling_morph_target.vpcf"
end

function modifier_Felix_WaterShield:CheckState()
	if self:GetCaster():HasTalent("special_bonus_birzha_felix_7") then return end
	local state = 
	{
		[MODIFIER_STATE_DISARMED] = true
	}
	return state
end

function modifier_Felix_WaterShield:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_Felix_WaterShield:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.unit
		if not self:GetCaster():HasTalent("special_bonus_birzha_felix_8") then
			return
		end
		if attacker:GetTeamNumber() ~= parent:GetTeamNumber() and parent == target and not attacker:IsWard() then
			if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
				local GushReturn = 
				{
					Target = attacker,
				 	Source = target,
				 	Ability = self:GetAbility(),
				 	EffectName = "particles/units/heroes/hero_tidehunter/tidehunter_gush.vpcf",
				 	iMoveSpeed = 1200,
				 	bDodgeable = true, 
				  	bVisibleToEnemies = true,
				 	bReplaceExisting = false,
				 	bProvidesVision = false,  
				  	iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
				 	ExtraData			= 
					{
						damage 	= keys.original_damage,
						damagefrom = parent,
						damage_type = keys.damage_type
					}                        
				}
                if attacker:IsHero() then
				    ProjectileManager:CreateTrackingProjectile(GushReturn)
                else
                    if target:GetUnitName() ~= "dota_fountain" then
                        ApplyDamage({victim = target, attacker = caster, damage = keys.original_damage, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = keys.damage_type, ability = self:GetAbility()})
                    end
                end
			end
		end
	end
end

function Felix_WaterShield:OnProjectileHit_ExtraData(target, location, extra_data)
	local caster = self:GetCaster()
	local ability = self
	target:EmitSound("Ability.GushImpact") 
	ApplyDamage({victim = target, attacker = caster, damage = extra_data.damage, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = extra_data.damage_type, ability = self})
end

LinkLuaModifier("modifier_Felix_water_block", "abilities/heroes/felix.lua", LUA_MODIFIER_MOTION_NONE)

Felix_water_block = class({})

function Felix_water_block:GetCastRange()
	return self:GetSpecialValueFor( "radius" )
end

function Felix_water_block:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_felix_2")
end

function Felix_water_block:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Felix_water_block:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("Hero_Dark_Seer.Ion_Shield_Start")
	local duration = self:GetSpecialValueFor( "duration" )
	local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, self:GetSpecialValueFor( "radius" ), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    for _,target in pairs(targets) do
		target:AddNewModifier(self:GetCaster(), self, "modifier_Felix_water_block", {duration = duration})
	end
end

modifier_Felix_water_block = class({})

function modifier_Felix_water_block:OnCreated()
	if not IsServer() then return end
	self.heal_b = 0
	self.damage_absorb = self:GetAbility():GetSpecialValueFor( "base_dmg" ) + ( self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor( "perc_dmg" ))
	local Felix_NyashaCat = self:GetCaster():FindAbilityByName("Felix_NyashaCat")
	if Felix_NyashaCat and Felix_NyashaCat:GetLevel() > 0 then
		self.damage_absorb = self.damage_absorb + (self.damage_absorb/100*Felix_NyashaCat:GetSpecialValueFor( "bonus_heal" ))
		self.heal_b = Felix_NyashaCat:GetSpecialValueFor( "bonus_heal" )
	end
	self:SetStackCount(self.damage_absorb)
	self.particle = ParticleManager:CreateParticle("particles/felix_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	if self:GetParent():ScriptLookupAttachment( "attach_hitloc" ) == 0 then
		ParticleManager:SetParticleControl(self.particle, 1, self:GetParent():GetAbsOrigin() + Vector(0,0,120))
	else
		ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	end
	self:AddParticle(self.particle, false, false, -1, false, false)
    self.start_shield = self.damage_absorb
    self:SetHasCustomTransmitterData( true )
	self:StartIntervalThink(FrameTime())
end

function modifier_Felix_water_block:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():ScriptLookupAttachment( "attach_hitloc" ) == 0 then
		if self.particle then
			ParticleManager:SetParticleControl(self.particle, 1, self:GetParent():GetAbsOrigin() + Vector(0,0,120))
		end
	end
    self:SendBuffRefreshToClients()
end

function modifier_Felix_water_block:AddCustomTransmitterData()
    local data = 
    {
        start_shield = self.start_shield,
    }
    return data
end

function modifier_Felix_water_block:HandleCustomTransmitterData( data )
    self.start_shield = data.start_shield
end

function modifier_Felix_water_block:OnRefresh()
	if not IsServer() then return end
	self.heal_b = 0
	self.damage_absorb = self:GetAbility():GetSpecialValueFor( "base_dmg" ) + ( self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor( "perc_dmg" ))
	local Felix_NyashaCat = self:GetCaster():FindAbilityByName("Felix_NyashaCat")
	if Felix_NyashaCat and Felix_NyashaCat:GetLevel() > 0 then
		self.damage_absorb = self.damage_absorb + (self.damage_absorb/100*Felix_NyashaCat:GetSpecialValueFor( "bonus_heal" ))
		self.heal_b = Felix_NyashaCat:GetSpecialValueFor( "bonus_heal" )
	end
    self.start_shield = self.damage_absorb
	self:SetStackCount(self.damage_absorb)
end

function modifier_Felix_water_block:IsPurgable() return false end

function modifier_Felix_water_block:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
	}
end

function modifier_Felix_water_block:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then
        local target                    = self:GetParent()
        local original_shield_amount    = self.damage_absorb
        if kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
            if kv.damage < self.damage_absorb then
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, kv.damage, nil)
                self.damage_absorb = self.damage_absorb - kv.damage
                self:SetStackCount(self.damage_absorb)
                return kv.damage
            else
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
                if not self:IsNull() then
                	self:Destroy()
                end
                return original_shield_amount
            end
        end
    end
end

function modifier_Felix_water_block:GetModifierHealAmplify_PercentageTarget()
	return self.heal_b
end

function modifier_Felix_water_block:GetModifierIncomingDamageConstant(params)
    if (not IsServer()) then
        if params.report_max then
            return self.start_shield
        end
        return self:GetStackCount()
    end
end