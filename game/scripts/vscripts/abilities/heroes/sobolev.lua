LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sobolev_Bash_passive", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )

Sobolev_Bash = class({})

function Sobolev_Bash:GetIntrinsicModifierName() 
	return "modifier_sobolev_Bash_passive"
end

function Sobolev_Bash:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_sobolev") then
		return "Sobolev/bash_item"
	end
	return "Sobolev/bash"
end

modifier_sobolev_Bash_passive = class({})

function modifier_sobolev_Bash_passive:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_sobolev_Bash_passive:IsPurgable()
	return false
end

function modifier_sobolev_Bash_passive:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
	}
end

function modifier_sobolev_Bash_passive:GetModifierProcAttack_BonusDamage_Physical(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end
	if self:GetParent():HasTalent("special_bonus_birzha_sobolev_8") then return end

	self:IncrementStackCount()

	local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_3")
	local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_1")
	local attacks = self:GetAbility():GetSpecialValueFor("attacks")

	if self:GetStackCount() >= attacks then
		self:SetStackCount(0)

		params.attacker:EmitSound("Hero_Slardar.Bash")

        local knockback =
    	{
	        should_stun = 1,
	        knockback_duration = duration * (1-params.target:GetStatusResistance()),
	        duration = duration * (1-params.target:GetStatusResistance()),
	        knockback_distance = 0,
	        knockback_height = 120,
   		}

   		if params.target:HasModifier("modifier_knockback") then
   			params.target:RemoveModifierByName("modifier_knockback")
   		end

    	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_knockback", knockback)

    	return damage
	end
end

function modifier_sobolev_Bash_passive:GetModifierProcAttack_BonusDamage_Pure(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end
	if not self:GetParent():HasTalent("special_bonus_birzha_sobolev_8") then return end

	self:IncrementStackCount()

	local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_3")
	local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_1")
	local attacks = self:GetAbility():GetSpecialValueFor("attacks")

	if self:GetStackCount() >= attacks then
		self:SetStackCount(0)
		
		params.attacker:EmitSound("Hero_Slardar.Bash")

        local knockback =
    	{
	        should_stun = 1,
	        knockback_duration = duration * (1-params.target:GetStatusResistance()),
	        duration = duration * (1-params.target:GetStatusResistance()),
	        knockback_distance = 0,
	        knockback_height = 120,
   		}

   		if params.target:HasModifier("modifier_knockback") then
   			params.target:RemoveModifierByName("modifier_knockback")
   		end

    	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_knockback", knockback)

    	return damage
	end
end

LinkLuaModifier( "modifier_sobolev_prank", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sobolev_unit", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )

sobolev_prank = class({})

function sobolev_prank:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
    return self.BaseClass.GetCooldown(self, level)
end

function sobolev_prank:GetManaCost(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_manacost")
    end
    return self.BaseClass.GetManaCost(self, level)
end

function sobolev_prank:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function sobolev_prank:GetChannelTime()
	local duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_2")
	return duration
end

function sobolev_prank:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("sobolev_shift")
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_2")
	self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_sobolev_prank", { duration = duration } )
end

function sobolev_prank:OnChannelFinish( bInterrupted )
	if self.modifier and not self.modifier:IsNull() then
		self.modifier:Destroy()
	end
end

modifier_sobolev_prank = class({})

function modifier_sobolev_prank:IsPurgable()
	return false
end

function modifier_sobolev_prank:OnCreated( kv )
	if not IsServer() then return end

	if self:GetCaster():HasScepter() then
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		local visual_unit = CreateUnitByName("npc_dummy_unit", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		visual_unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sobolev_unit", {})
		visual_unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration + 0.5})
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_ABSORIGIN_FOLLOW, visual_unit)
		ParticleManager:SetParticleControlEnt(self.particle, 1, visual_unit, PATTACH_POINT_FOLLOW, nil, visual_unit:GetAbsOrigin(), true)
		self:AddParticle(self.particle, false, false, -1, false, false)
		self:GetCaster():EmitSound("Hero_Slark.ShadowDance")
		self.talent = true
		return
	end

	self.talent = false

	self:GetParent():EmitSound("Hero_Puck.Phase_Shift")

	ProjectileManager:ProjectileDodge(self:GetParent())
	
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_puck/puck_phase_shift.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_CUSTOMORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	self:AddParticle( nFXIndex, false, false, -1, false, false )

	local nStatusFX = ParticleManager:CreateParticle( "particles/status_fx/status_effect_phase_shift.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nStatusFX, 0, self:GetParent(), PATTACH_CUSTOMORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	self:AddParticle( nStatusFX, false, true, 75, false, false )

	self:GetParent():AddEffects( EF_NODRAW )

	self.has_donate_items = false

	if self:GetCaster().BookLeft and self:GetCaster().BookRight then
		self.has_donate_items = true
		self:GetCaster().BookLeft:Destroy()
		self:GetCaster().BookRight:Destroy()
	end
end

function modifier_sobolev_prank:OnDestroy( kv )
	if not IsServer() then return end

	if self.has_donate_items then
		self:GetParent().BookLeft = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/terrorblade_sobolev_book_left.vmdl"})
		self:GetParent().BookLeft:FollowEntity(self:GetParent(), true)
		self:GetParent().BookRight = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/terrorblade_sobolev_book_right.vmdl"})
		self:GetParent().BookRight:FollowEntity(self:GetParent(), true)
	end

	if not self.talent then
		self:GetParent():RemoveEffects( EF_NODRAW )
		self:GetParent():StopSound("Hero_Puck.Phase_Shift")
	end

	self:GetCaster():StopSound("Hero_Slark.ShadowDance")
end

function modifier_sobolev_prank:CheckState()
	local state = 
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	if self.talent then
		state = 
		{
			[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		}
	end

	return state
end

function modifier_sobolev_prank:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function modifier_sobolev_prank:GetModifierInvisibilityLevel()
	return 2
end

function modifier_sobolev_prank:GetModifierConstantHealthRegen()
	return self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_4")
end

modifier_sobolev_unit = class({})

function modifier_sobolev_unit:IsPurgable()	return false end

function modifier_sobolev_unit:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_sobolev_unit:OnIntervalThink()
	self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
end

function modifier_sobolev_unit:CheckState()
	return 
	{
		[MODIFIER_STATE_INVISIBLE]				= false,
		[MODIFIER_STATE_NO_HEALTH_BAR]			= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
		[MODIFIER_STATE_INVULNERABLE]			= true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY]	= true,
		[MODIFIER_STATE_UNSELECTABLE]			= true,
		[MODIFIER_STATE_UNTARGETABLE]			= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]			= true
	}
end

LinkLuaModifier( "modifier_sobolev_biceps", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sobolev_biceps_buff", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )

sobolev_biceps = class({})

function sobolev_biceps:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_birzha_sobolev_5") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function sobolev_biceps:GetCooldown(iLevel)
	if self:GetCaster():HasTalent("special_bonus_birzha_sobolev_5") then
		return self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_5", "value3")
	end
	return 0
end

function sobolev_biceps:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("sobolev_bic")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sobolev_biceps_buff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_5", "value2")})
end

modifier_sobolev_biceps = class({})

function sobolev_biceps:GetIntrinsicModifierName()
    return "modifier_sobolev_biceps"
end

function modifier_sobolev_biceps:IsHidden()
    return true
end

function modifier_sobolev_biceps:IsPurgable()
    return false
end

function modifier_sobolev_biceps:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return decFuncs
end

function modifier_sobolev_biceps:GetModifierBonusStats_Strength()
	if not self:GetCaster():HasShard() then
    	if self:GetParent():PassivesDisabled() then return end
    end
    local multiple = 1
    if self:GetParent():HasModifier("modifier_sobolev_biceps_buff") then
    	multiple = self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_5")
    end
    return self:GetAbility():GetSpecialValueFor('bonus_strength') * multiple
end

function modifier_sobolev_biceps:GetModifierBonusStats_Agility()
	if not self:GetCaster():HasShard() then
    	if self:GetParent():PassivesDisabled() then return end
    end
    local multiple = 1
    if self:GetParent():HasModifier("modifier_sobolev_biceps_buff") then
    	multiple = self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_5")
    end
    return self:GetAbility():GetSpecialValueFor('bonus_agility') * multiple
end

modifier_sobolev_biceps_buff = class({})

LinkLuaModifier("modifier_Sobolev_Egoism", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE)

Sobolev_Egoism = class ({})

function Sobolev_Egoism:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Sobolev_Egoism:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Sobolev_Egoism:OnSpellStart()
	if not IsServer() then return end

	if DonateShopIsItemActive(self:GetCaster():GetPlayerID(), 34) then
		self:GetCaster():EmitSound( "SobolevArcana" )
	else
		self:GetCaster():EmitSound( "sobolevult" )
	end

	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_6")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Sobolev_Egoism", { duration = duration })
end

modifier_Sobolev_Egoism = class ({})

function modifier_Sobolev_Egoism:IsPurgable()
	return false
end 

function modifier_Sobolev_Egoism:OnDestroy()
    if not IsServer() then return end
	if DonateShopIsItemActive(self:GetCaster():GetPlayerID(), 34) then
		self:GetCaster():StopSound("SobolevArcana")
	else
		self:GetCaster():StopSound("sobolevult")
	end
end

function modifier_Sobolev_Egoism:GetEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf"
end

function modifier_Sobolev_Egoism:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Sobolev_Egoism:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_Sobolev_Egoism:GetModifierMoveSpeedBonus_Percentage(params)
	return self:GetAbility():GetSpecialValueFor("bonus_move_speed")
end

function modifier_Sobolev_Egoism:GetModifierAttackSpeedBonus_Constant(params)
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_Sobolev_Egoism:GetModifierPreAttack_BonusDamage(params)
	return self:GetStackCount()
end

function modifier_Sobolev_Egoism:OnCreated(params)
	if not IsServer() then return end
	self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_attack") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_7")
end

function modifier_Sobolev_Egoism:OnRefresh(params)
	if not IsServer() then return end
	self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_attack") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_7")
end

function modifier_Sobolev_Egoism:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end
	if params.target:IsBoss() then return end
	self:SetStackCount(self:GetStackCount()+self.damage_per_stack)
end