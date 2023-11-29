LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tailer_burger_buff", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_tailer_burger_buff_counter", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)

tailer_burger = class({})

function tailer_burger:OnSpellStart()
	if not IsServer() then return end

	local target = self:GetCursorTarget()

	self:GetCaster():EmitSound("tailer_one")

	if target == self:GetCaster() then
		self:GetCaster():StartGesture(ACT_DOTA_UNDYING_SOUL_RIP)
    	local duration = self:GetSpecialValueFor("duration")
    	target:AddNewModifier(self:GetCaster(), self, "modifier_tailer_burger_buff", {duration = duration})
    	target:AddNewModifier(self:GetCaster(), self, "modifier_tailer_burger_buff_counter", {duration = duration})
    	target:EmitSound("item_burger")
    	return
	end

	self:GetCaster():StartGesture(ACT_DOTA_ATTACK)

	local info = 
	{
        Target = target,
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "particles/tailer/burger_kick_concoction_projectile.vpcf",
        iMoveSpeed = 1200,
        bReplaceExisting = false,
        bProvidesVision = false,
        bDodgeable = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

    self:GetCaster():EmitSound("SeasonalConsumable.TI9.Monkey.ProjectileThrow")
    ProjectileManager:CreateTrackingProjectile(info)
end

function tailer_burger:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target == nil then return end
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_tailer_burger_buff", {duration = duration})
    target:AddNewModifier(self:GetCaster(), self, "modifier_tailer_burger_buff_counter", {duration = duration})
    target:EmitSound("item_burger")
end

modifier_tailer_burger_buff = class({})

function modifier_tailer_burger_buff:IsPurgable() return false end
function modifier_tailer_burger_buff:IsHidden() return true end
function modifier_tailer_burger_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_tailer_burger_buff_counter = class({})

function modifier_tailer_burger_buff_counter:GetEffectName() return "particles/tailer/burger_effect.vpcf" end
function modifier_tailer_burger_buff_counter:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_tailer_burger_buff_counter:IsPurgable() return false end

function modifier_tailer_burger_buff_counter:OnCreated()
	self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.bonus_agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
	self.bonus_int = self:GetAbility():GetSpecialValueFor("bonus_int")
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_tailer_burger_buff_counter:OnIntervalThink()
	if not IsServer() then return end
	local modifiers = self:GetParent():FindAllModifiersByName("modifier_tailer_burger_buff")
	if #modifiers > 0 then
		self:SetStackCount(#modifiers)
	else
		self:Destroy()
	end
end

function modifier_tailer_burger_buff_counter:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end

function modifier_tailer_burger_buff_counter:GetModifierModelScale()
	return math.min(self:GetStackCount() * 5, 50)
end

function modifier_tailer_burger_buff_counter:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_tailer_burger_buff_counter:GetModifierBonusStats_Strength()
	return self.bonus_str * self:GetStackCount()
end

function modifier_tailer_burger_buff_counter:GetModifierBonusStats_Agility()
	return self.bonus_agi * self:GetStackCount()
end

function modifier_tailer_burger_buff_counter:GetModifierBonusStats_Intellect()
	return self.bonus_int * self:GetStackCount()
end

LinkLuaModifier("modifier_tailer_burgerking_buff", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tailer_burgerking_debuff", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tailer_burgerking_buff_hero", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)

tailer_burgerking = class({})

function tailer_burgerking:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_6")
	local point = self:GetCursorPosition()
	local burger_king = CreateUnitByName("npc_dota_tailer_burger_king", point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam())
	burger_king:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	burger_king:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
	burger_king:AddNewModifier(self:GetCaster(), self, "modifier_tailer_burgerking_buff", {duration = duration})
	self:GetCaster():EmitSound("Hero_Pugna.NetherWard")
end

modifier_tailer_burgerking_buff = class({})

function modifier_tailer_burgerking_buff:IsPurgable() return false end
function modifier_tailer_burgerking_buff:IsHidden() return true end

function modifier_tailer_burgerking_buff:OnCreated()
	if not IsServer() then return end
    self.destroy_attacks            = self:GetAbility():GetSpecialValueFor("attack_destroy") + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_5")
    if self:GetCaster():HasTalent("special_bonus_birzha_tailer_5") then
    	self:GetParent():SetBaseMaxHealth(10)
    	self:GetParent():SetHealth(10)
    end
    self.hero_attack_multiplier     = 1
    self.health_increments          = self:GetParent():GetMaxHealth() / self.destroy_attacks
    self:StartIntervalThink(FrameTime())

    self:GetParent():EmitSound("tailer_two")

    local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_tailer_burgerking_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS
	}
	return decFuncs
end

function modifier_tailer_burgerking_buff:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_tailer_burgerking_buff:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_tailer_burgerking_buff:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_tailer_burgerking_buff:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end

function modifier_tailer_burgerking_buff:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_tailer_burgerking_buff:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_tailer_burgerking_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - self.health_increments
        if keys.attacker:IsRealHero() then
            new_health = self:GetParent():GetHealth() - (self.health_increments * self.hero_attack_multiplier)
        end
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_tailer_burgerking_buff:OnIntervalThink()
	if not IsServer() then return end
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local caster_origin = self:GetCaster():GetAbsOrigin()
	local parent_origin = self:GetParent():GetAbsOrigin()

	if (caster_origin - parent_origin):Length2D() > (radius + 100) then
		self:GetCaster():RemoveModifierByName("modifier_tailer_burgerking_buff_hero")
		return
	end

	local flag = 0

	if self:GetCaster():HasScepter() then
		flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag, 0, false)

	if #targets <= 0 then
		self:GetCaster():RemoveModifierByName("modifier_tailer_burgerking_buff_hero")
		return
	end

    for _,target in pairs(targets) do
    	target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_tailer_burgerking_debuff", {})
    end

    self:GetCaster():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_tailer_burgerking_buff_hero", {})
end

modifier_tailer_burgerking_debuff = class({})

function modifier_tailer_burgerking_debuff:IsPurgable() return true end

function modifier_tailer_burgerking_debuff:OnCreated()
	if not IsServer() then return end

	self.cooldown = 0

	self:GetParent():EmitSound("Hero_Pugna.LifeDrain.Target")

	local particle = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_gold.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)

	self:StartIntervalThink(FrameTime())
end

function modifier_tailer_burgerking_debuff:OnIntervalThink()
	if not IsServer() then return end

	local radius = self:GetAbility():GetSpecialValueFor("radius") + 100

	if self:GetCaster():IsNull() then
		self:Destroy()
		return
	end

	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end

	if (self:GetCaster():GetAbsOrigin() - self:GetCaster():GetOwner():GetAbsOrigin()):Length2D() > radius then
		self:Destroy()
		return
	end

	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > radius then
		self:Destroy()
		return
	end

	self.cooldown = self.cooldown + FrameTime()

	if self.cooldown >= 0.25 then
		local damage_perc = self:GetAbility():GetSpecialValueFor("damage")
		local damage = self:GetParent():GetMaxHealth() / 100 * damage_perc
		local heal = ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL})
		self:GetCaster():GetOwner():Heal(heal, self:GetAbility())
		self.cooldown = 0
	end
end

modifier_tailer_burgerking_buff_hero = class({})

function modifier_tailer_burgerking_buff_hero:IsPurgable() return true end

function modifier_tailer_burgerking_buff_hero:OnCreated()
	if not IsServer() then return end

	local particle = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_gold_shard.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)

	self:GetParent():EmitSound("Hero_Pugna.LifeDrain.Target")

	StopSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetCaster())
	EmitSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetCaster())
	
	self:StartIntervalThink(FrameTime())
end

function modifier_tailer_burgerking_buff_hero:OnDestroy()
	if not IsServer() then return end
	StopSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetCaster())
end

function modifier_tailer_burgerking_buff_hero:OnIntervalThink()
	if not IsServer() then return end

	local radius = self:GetAbility():GetSpecialValueFor("radius") + 100

	if self:GetCaster():IsNull() then
		self:Destroy()
		return
	end

	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end

	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > radius then
		self:Destroy()
		return
	end
end

LinkLuaModifier("modifier_tailer_damageblock", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)

tailer_damageblock = class({})

function tailer_damageblock:GetIntrinsicModifierName()
	return "modifier_tailer_damageblock"
end

modifier_tailer_damageblock = class({})

function modifier_tailer_damageblock:IsHidden()
	return false
end

function modifier_tailer_damageblock:IsDebuff()
	return false
end

function modifier_tailer_damageblock:IsPurgable()
	return false
end

function modifier_tailer_damageblock:OnCreated( kv )
	self.parent = self:GetParent()
	self.block = self:GetAbility():GetSpecialValueFor( "damage_reduction" )
	self.purge = self:GetAbility():GetSpecialValueFor( "damage_cleanse" )
	self.reset = self:GetAbility():GetSpecialValueFor( "damage_reset_interval" )
	if not IsServer() then return end
	self.damage = 0
end

function modifier_tailer_damageblock:OnRefresh( kv )
	self.block = self:GetAbility():GetSpecialValueFor( "damage_reduction" )
	self.purge = self:GetAbility():GetSpecialValueFor( "damage_cleanse" )
	self.reset = self:GetAbility():GetSpecialValueFor( "damage_reset_interval" )
end

function modifier_tailer_damageblock:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_tailer_damageblock:OnTakeDamage( params )
	if not IsServer() then return end
	if params.unit~=self.parent then return end
	if params.attacker == self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if not params.attacker:GetPlayerOwner() then return end
	if self.parent:IsIllusion() then return end
	if not self.parent:IsAlive() then return end
    if params.attacker:GetUnitName() == "dota_fountain" then return end
    if params.attacker:IsBoss() then return end
    if self:GetAbility():IsFullyCastable() then
		self:StartIntervalThink( self.reset + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_2") )
		self.damage = self.damage + params.damage
		if self.damage < (self.purge + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_4")) then return end
		self.damage = 0
		self:IncrementStackCount()
		self.parent:Purge( false, true, false, true, true )
		local effect_cast = ParticleManager:CreateParticle( "particles/tailer/damage_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		self:GetAbility():StartCooldown(self.reset + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_2"))
	end
end

function modifier_tailer_damageblock:GetModifierPhysical_ConstantBlock()
	if self.parent:PassivesDisabled() then return 0 end
	return self.block + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_3")
end

function modifier_tailer_damageblock:GetModifierPhysicalArmorBonus()
	if self.parent:PassivesDisabled() then return 0 end
	local multiple = 1
	if self:GetCaster():HasTalent("special_bonus_birzha_tailer_7") then
		multiple = 2
	end
	return (self:GetStackCount() * multiple) * (self:GetAbility():GetSpecialValueFor("bonus_armor") + self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_1"))
end

function modifier_tailer_damageblock:OnIntervalThink()
	self:StartIntervalThink( -1 )
	self.damage = 0
end

LinkLuaModifier("modifier_tailer_doubleform", "abilities/heroes/tailer.lua", LUA_MODIFIER_MOTION_NONE)

tailer_doubleform = class({})

function tailer_doubleform:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function tailer_doubleform:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_tailer_doubleform", {duration = duration})
end

modifier_tailer_doubleform = class({})

function modifier_tailer_doubleform:IsPurgable() return false end
function modifier_tailer_doubleform:AllowIllusionDuplicate() return true end

function modifier_tailer_doubleform:OnCreated()
	self.bonus_strength_kv = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.movespeed_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
	self.range = self:GetAbility():GetSpecialValueFor("range")
	self.strength_multiplier = self:GetAbility():GetSpecialValueFor("strength_multiplier")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end

	self.bonus_strength = self:GetParent():GetStrength() / 100 * self.bonus_strength_kv
	self:GetCaster():CalculateStatBonus(true)

	self.zhir_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/tidehunter/horror_from_the_deep_belt/horror_from_the_deep_belt.vmdl"})
	self.zhir_item:FollowEntity(self:GetParent(), true)
	self.distance = 0
	self.currentpos = self:GetParent():GetOrigin()

	if self:GetParent():IsIllusion() then return end

	Timers:CreateTimer(FrameTime(), function()
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4)
		self:GetParent():EmitSound("tailer_ultimate_scream")
	end)

	self:GetParent():EmitSound("tailer_ultimate")

	self:StartIntervalThink(FrameTime())
end

function modifier_tailer_doubleform:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("tailer_ultimate")
	if self.zhir_item then
		self.zhir_item:Destroy()
	end
end

function modifier_tailer_doubleform:OnRefresh()
	self.bonus_strength_kv = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.movespeed_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
	self.range = self:GetAbility():GetSpecialValueFor("range")
	self.strength_multiplier = self:GetAbility():GetSpecialValueFor("strength_multiplier")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	self.bonus_strength = self:GetParent():GetStrength() / 100 * self.bonus_strength_kv
	self:GetCaster():CalculateStatBonus(true)
	Timers:CreateTimer(FrameTime(), function()
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4)
		self:GetParent():EmitSound("tailer_ultimate_scream")
	end)
end

function modifier_tailer_doubleform:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

function modifier_tailer_doubleform:CheckState()
	local state = 
	{
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

function modifier_tailer_doubleform:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():IsIllusion() then return end
	self.bonus_strength = 0
	self.bonus_strength = self:GetParent():GetStrength() / 100 * self.bonus_strength_kv
	self:GetCaster():CalculateStatBonus(true)

	local pos = self:GetParent():GetOrigin()
	local dist = (pos - self.currentpos):Length2D()
	self.currentpos = pos
	if dist > 500 then return end
	self.distance = self.distance + dist
	if self.distance > self.range then
		self:Pulse()
		self.distance = 0
	end
end

function modifier_tailer_doubleform:Pulse()
	local effect_cast = ParticleManager:CreateParticle( "particles/tailer/step_effect.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	self:GetParent():EmitSound("Hero_PrimalBeast.Trample")

	local damage = self:GetParent():GetStrength() * self.strength_multiplier


	if self:GetCaster():HasTalent("special_bonus_birzha_tailer_8") then
		damage = damage + (self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_tailer_8"))
	end

	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _, target in pairs(enemies) do
		ApplyDamage({victim = target, attacker = self:GetParent(), damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL})
		if self:GetCaster():HasShard() then
        	local distance = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
        	local direction = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        	local bump_point = target:GetAbsOrigin() + direction * (distance + 20)
	
        	local knockbackProperties =
        	{
        		should_stun = false,
        	    center_x = bump_point.x,
        	    center_y = bump_point.y,
        	    center_z = bump_point.z,
        	    duration = 0.25,
        	    knockback_duration = 0.25,
        	    knockback_distance = 40,
        	    knockback_height = 40
        	}
        	target:AddNewModifier( self:GetCaster(), nil, "modifier_knockback", knockbackProperties )
		end
	end
end

function modifier_tailer_doubleform:OnTooltip()
	return self.bonus_strength_kv
end

function modifier_tailer_doubleform:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_tailer_doubleform:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed_slow
end

function modifier_tailer_doubleform:GetModifierModelChange()
	return "models/heroes/tidehunter/tidehunter.vmdl"
end

function modifier_tailer_doubleform:GetModifierModelScale()
	return 50
end