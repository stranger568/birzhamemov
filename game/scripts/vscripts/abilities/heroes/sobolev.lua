LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sobolev_Bash_passive", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )

Sobolev_Bash = class({})

function Sobolev_Bash:GetIntrinsicModifierName() 
	return "modifier_sobolev_Bash_passive"
end

modifier_sobolev_Bash_passive = class({})

function modifier_sobolev_Bash_passive:IsHidden()
	return true
end

function modifier_sobolev_Bash_passive:IsPurgable()
	return false
end

function modifier_sobolev_Bash_passive:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_sobolev_Bash_passive:OnCreated( keys )
	if not IsServer() then return end
	self.attack_count = 0
end

function modifier_sobolev_Bash_passive:OnRefresh( keys )
	if not IsServer() then return end
	self.attack_count = 0
end

function modifier_sobolev_Bash_passive:OnAttackLanded( keys )
	if not IsServer() then return end
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

	self.attack_count = self.attack_count + 1
	local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_3")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	if self.attack_count >= 6 then
		self.attack_count = 0
		attacker:EmitSound("Hero_Slardar.Bash")
	    local damage = {
	        victim = target,
	        attacker = self:GetCaster(),
	        damage = damage,
	        damage_type = DAMAGE_TYPE_PHYSICAL,
	        ability = self:GetAbility()
        }
        ApplyDamage( damage )

        local knockback =
    	{
	        should_stun = 1,
	        knockback_duration = duration,
	        duration = duration,
	        knockback_distance = 25,
	        knockback_height = 350,
   		}
   		if target:HasModifier("modifier_knockback") then
   			target:RemoveModifierByName("modifier_knockback")
   		end
    	target:AddNewModifier(attacker, self:GetAbility(), "modifier_knockback", knockback)
	end
end

LinkLuaModifier( "modifier_sobolev_prank", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sobolev_unit", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )

sobolev_prank = class({})

function sobolev_prank:GetCooldown(level)
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_birzha_sobolev_1") then
        return 30 / self:GetCaster():GetCooldownReduction()
    end
    return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end







function sobolev_prank:GetManaCost(level)
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_birzha_sobolev_1") then
        return 120
    end
    return self.BaseClass.GetManaCost(self, level)
end

function sobolev_prank:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_birzha_sobolev_1") then
        return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function sobolev_prank:GetChannelTime()
	self.duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_4")
	return self.duration
end

function sobolev_prank:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_4")
	ProjectileManager:ProjectileDodge( caster )
	self.modifier = caster:AddNewModifier( caster, self, "modifier_sobolev_prank", { duration = duration } )
end

function sobolev_prank:OnChannelFinish( bInterrupted )
	if self.modifier and not self.modifier:IsNull() then
		self.modifier:Destroy()
	end
	StopSoundOn( "Hero_Puck.Phase_Shift", self:GetCaster() )
end

modifier_sobolev_prank = class({})

function modifier_sobolev_prank:IsPurgable()
	return false
end

function modifier_sobolev_prank:OnCreated( kv )
	if not IsServer() then return end
	if self:GetCaster():HasTalent("special_bonus_birzha_sobolev_1") then
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		local visual_unit = CreateUnitByName("npc_dummy_unit", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		visual_unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sobolev_unit", {})
		visual_unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration + 0.5})
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_ABSORIGIN_FOLLOW, visual_unit)
		ParticleManager:SetParticleControlEnt(self.particle, 1, visual_unit, PATTACH_POINT_FOLLOW, nil, visual_unit:GetAbsOrigin(), true)
		self:AddParticle(self.particle, false, false, -1, false, false)
		self:GetCaster():EmitSound("Hero_Slark.ShadowDance")
		return
	end
	EmitSoundOn( "Hero_Puck.Phase_Shift", self:GetCaster() )
	self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_puck/puck_phase_shift.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	self:GetParent():AddNoDraw()
	self.has_donate_items = false
    self.has_donate_items = true
	if self:GetCaster().BookLeft
	and self:GetCaster().BookRight then
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
	if self:GetCaster():HasTalent("special_bonus_birzha_sobolev_1") then return end
	self:GetParent():RemoveNoDraw()
	if self.effect_cast then
		ParticleManager:DestroyParticle( self.effect_cast, false )
		ParticleManager:ReleaseParticleIndex( self.effect_cast )
	end
end

function modifier_sobolev_prank:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	if self:GetCaster():HasTalent("special_bonus_birzha_sobolev_1") then
		state = {
			[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
		}
	end

	return state
end

function modifier_sobolev_prank:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}

	return funcs
end

function modifier_sobolev_prank:GetModifierInvisibilityLevel()
	if not self:GetParent():HasTalent("special_bonus_birzha_sobolev_1") then return end
	return 2
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
	return {
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

sobolev_biceps = class({})

LinkLuaModifier( "modifier_sobolev_biceps", "abilities/heroes/sobolev.lua", LUA_MODIFIER_MOTION_NONE )

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
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_strength')
end

function modifier_sobolev_biceps:GetModifierBonusStats_Agility()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_agility')
end

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

	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 34) then
		self:GetCaster():EmitSound( "SobolevArcana" )
	else
		self:GetCaster():EmitSound( "sobolevult" )
	end

	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Sobolev_Egoism", { duration = duration })
end

modifier_Sobolev_Egoism = class ({})

function modifier_Sobolev_Egoism:IsPurgable()
	return false
end 

function modifier_Sobolev_Egoism:OnDestroy()
    if not IsServer() then return end
	if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 34) then
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
	local funcs = {
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
	self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_attack") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_2")
	self.bonus_damage = 0
end

function modifier_Sobolev_Egoism:OnRefresh(params)
	if not IsServer() then return end
	self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_attack") + self:GetCaster():FindTalentValue("special_bonus_birzha_sobolev_2")
end

function modifier_Sobolev_Egoism:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker == self:GetParent() and not self:GetParent():IsIllusion() and params.target:GetTeamNumber() ~= params.attacker:GetTeamNumber() then
		if params.target:IsOther() then
			return nil
		end
		if params.target:IsBoss() then return end
		self.bonus_damage = self.bonus_damage + self.damage_per_stack
		self:SetStackCount(self.bonus_damage)
	end
end