LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_silenced", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morgen_muted", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)

morgenshtern_rift = class({})

function morgenshtern_rift:Precache(context)
    local particle_list = 
    {
        "particles/generic_gameplay/generic_muted.vpcf",
        "particles/econ/items/puck/puck_fairy_wing/puck_waning_rift_fairy_wing.vpcf",
        "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf",
        "particles/units/heroes/hero_monkey_king/monkey_king_jump_armor_debuff.vpcf",
        "particles/frost_morgen.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function morgenshtern_rift:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function morgenshtern_rift:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function morgenshtern_rift:GetAOERadius(level)
    return self:GetSpecialValueFor("radius")
end

function morgenshtern_rift:OnSpellStart()
    if not IsServer() then return end

    local point = self:GetCursorPosition()

    local origin = self:GetCaster():GetOrigin()

    local range = self:GetSpecialValueFor("blink_range")

    local radius = self:GetSpecialValueFor("radius")

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_morgenshtern_1")

    local duration = self:GetSpecialValueFor("silence_duration")

    local direction = (point - origin)

    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end

    local tochka = origin + direction

    if self:GetCaster():HasShard() then
    	self:PlayEffects( self:GetCaster():GetAbsOrigin(), radius )
    	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), tochka, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		local damageTable = { attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, damage_flags = DOTA_DAMAGE_FLAG_NONE}
		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			ApplyDamage(damageTable)
			enemy:AddNewModifier( self:GetCaster(), self, "modifier_birzha_silenced", { duration = duration * (1-enemy:GetStatusResistance()) } )
			if self:GetCaster():HasTalent("special_bonus_birzha_morgenshtern_7") then
				enemy:AddNewModifier( self:GetCaster(), self, "modifier_morgen_muted", { duration = duration * (1-enemy:GetStatusResistance()) } )
			end
		end
    end

    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )

    ProjectileManager:ProjectileDodge(self:GetCaster())

    self:PlayEffects( tochka, radius )

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), tochka, nil, radius,	 DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	local damageTable = { attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, damage_flags = DOTA_DAMAGE_FLAG_NONE}
	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
		enemy:AddNewModifier( self:GetCaster(), self, "modifier_birzha_silenced", { duration = duration * (1-enemy:GetStatusResistance()) } )
		if self:GetCaster():HasTalent("special_bonus_birzha_morgenshtern_7") then
			enemy:AddNewModifier( self:GetCaster(), self, "modifier_morgen_muted", { duration = duration * (1-enemy:GetStatusResistance()) } )
		end
	end
end

modifier_morgen_muted = class({})

function modifier_morgen_muted:IsHidden()
	return true
end

function modifier_morgen_muted:IsPurgable()
	return true
end

function modifier_morgen_muted:CheckState()
	return 
	{
		[MODIFIER_STATE_MUTED] = true,
	}
end

function modifier_morgen_muted:GetEffectName()
	return "particles/generic_gameplay/generic_muted.vpcf"
end

function modifier_morgen_muted:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function morgenshtern_rift:PlayEffects( point, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/puck/puck_fairy_wing/puck_waning_rift_fairy_wing.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "MorgenRift", self:GetCaster() )
end

LinkLuaModifier("modifier_morgenshtern_ratata", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)

morgenshtern_ratata = class({})

function morgenshtern_ratata:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level )
end

function morgenshtern_ratata:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function morgenshtern_ratata:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_morgenshtern_ratata", {duration = duration})
end

modifier_morgenshtern_ratata = class({})

function modifier_morgenshtern_ratata:IsPurgable()
	return true
end

function modifier_morgenshtern_ratata:OnCreated( kv )
	self.attacks = self:GetAbility():GetSpecialValueFor( "attacks" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_morgenshtern_2")
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	if not IsServer() then return end
	self:SetStackCount( self.attacks )
	self.records = {}
	self:PlayEffects()
	self:GetParent():EmitSound("MorgenRatata")
end

function modifier_morgenshtern_ratata:OnRefresh( kv )
	self.attacks = self:GetAbility():GetSpecialValueFor( "attacks" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_morgenshtern_2")
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	if not IsServer() then return end
	self:SetStackCount( self.attacks )
	self:GetParent():EmitSound("MorgenRatata")
end

function modifier_morgenshtern_ratata:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("MorgenRatata")
end

function modifier_morgenshtern_ratata:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	if self:GetCaster():HasTalent("special_bonus_birzha_morgenshtern_6") then
		funcs = 
		{
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
			MODIFIER_PROPERTY_PROJECTILE_NAME,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		}
	end

	return funcs
end

function modifier_morgenshtern_ratata:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if self:GetStackCount()<=0 then return end
	self.records[params.record] = true
	if params.no_attack_cooldown then return end
	self:GetParent():EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")

	if self:GetCaster():HasTalent("special_bonus_birzha_morgenshtern_8") then
		local attack = self:GetCaster():FindTalentValue("special_bonus_birzha_morgenshtern_8")
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetCaster():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, false )
		for _, enemy in pairs(enemies) do
			if attack <= 0 then break end
			if enemy ~= params.target then
				attack = attack - 1
				self:GetCaster():PerformAttack(enemy, true, true, true, false, true, false, false)
			end
		end
	end

	if self:GetStackCount()>0 then
		self:DecrementStackCount()
	end
end

function modifier_morgenshtern_ratata:OnAttackLanded( params )
	if params.attacker~=self:GetParent() then return end
	params.target:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Target")
end

function modifier_morgenshtern_ratata:OnAttackRecordDestroy( params )
	if self.records[params.record] then
		self.records[params.record] = nil
		if next(self.records)==nil and self:GetStackCount()<=0 then
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

function modifier_morgenshtern_ratata:GetModifierProjectileName()
	if self:GetStackCount()<=0 then return end
	return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
end

function modifier_morgenshtern_ratata:GetModifierOverrideAttackDamage()
	if self:GetStackCount()<=0 then return end
	return self.damage
end

function modifier_morgenshtern_ratata:GetModifierAttackRangeBonus()
	if self:GetStackCount()<=0 then return end
	return self.range_bonus
end

function modifier_morgenshtern_ratata:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount()<=0 then return end
	return 300
end

function modifier_morgenshtern_ratata:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false, false, -1, false, false  )
end

LinkLuaModifier("modifier_morgenshtern_rich_passive", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morgenshtern_rich_slow", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)

morgenshtern_rich = class({})

function morgenshtern_rich:GetIntrinsicModifierName()
    return "modifier_morgenshtern_rich_passive"
end

function morgenshtern_rich:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_morgenshtern_4")
end

modifier_morgenshtern_rich_passive = class({})

function modifier_morgenshtern_rich_passive:IsPurgable() return false end
function modifier_morgenshtern_rich_passive:IsHidden() return true end

function modifier_morgenshtern_rich_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_morgenshtern_rich_passive:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end
    if not self:GetAbility():IsFullyCastable() then return end

    local chance = self:GetAbility():GetSpecialValueFor("chance")
    local money = self:GetAbility():GetSpecialValueFor("money")
    local duration = self:GetAbility():GetSpecialValueFor("duration")

    if RollPseudoRandomPercentage(chance, 1, self:GetParent()) then
		self:GetParent():EmitSound("MorgenRich")
        self:GetParent():ModifyGold( money, true, 0 )
        self:GetAbility():UseResources(false, false, false, true)
        if not params.target:IsMagicImmune() then
    		params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_morgenshtern_rich_slow", {duration = duration * (1-params.target:GetStatusResistance()) })
    	end
    end
end

modifier_morgenshtern_rich_slow = class({})

function modifier_morgenshtern_rich_slow:GetEffectName()
    return "particles/units/heroes/hero_monkey_king/monkey_king_jump_armor_debuff.vpcf"
end

function modifier_morgenshtern_rich_slow:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_morgenshtern_rich_slow:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_morgenshtern_rich_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_morgenshtern_rich_slow:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

LinkLuaModifier("modifier_pango_bonus", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morgenshtern_car_swap", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)

morgenshtern_car = class({})

function morgenshtern_car:GetIntrinsicModifierName()
    return "modifier_pango_bonus"
end

function morgenshtern_car:GetCooldown(level)
	return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_morgenshtern_5")
end

function morgenshtern_car:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function morgenshtern_car:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():EmitSound("MorgenCar")

	local vDir = self:GetCaster():GetForwardVector()
	local vTargetPos = self:GetCaster():GetAbsOrigin() + vDir
	local kv = {}
	kv[ "duration" ] = duration
	kv[ "vTargetX" ] = vTargetPos.x
	kv[ "vTargetY" ] = vTargetPos.y
	kv[ "vTargetZ" ] = vTargetPos.z

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pangolier_gyroshell", kv)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_morgenshtern_car_swap", {duration = duration})
end

morgenshtern_car_stop = class({})

function morgenshtern_car_stop:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_pangolier_gyroshell")
	self:GetCaster():RemoveModifierByName("modifier_morgenshtern_car_swap")
end

modifier_morgenshtern_car_swap = class({})

function modifier_morgenshtern_car_swap:IsPurgable() return false end
function modifier_morgenshtern_car_swap:IsHidden() return true end
function modifier_morgenshtern_car_swap:OnCreated()
	if not IsServer() then return end
	self:GetParent():SwapAbilities("morgenshtern_car", "morgenshtern_car_stop", false, true)
	self:StartIntervalThink(FrameTime())
end

function modifier_morgenshtern_car_swap:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_pangolier_gyroshell") then
		self:Destroy()
	end
end

function modifier_morgenshtern_car_swap:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SwapAbilities("morgenshtern_car_stop", "morgenshtern_car", false, true)
end

modifier_pango_bonus = class({})

function modifier_pango_bonus:IsHidden()
	return true
end

function modifier_pango_bonus:IsPurgable()
	return false
end

function modifier_pango_bonus:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 10001
end

function modifier_pango_bonus:CheckState()
	if self:GetParent():HasModifier("modifier_pangolier_gyroshell") then
		if self:GetParent():HasTalent("special_bonus_birzha_morgenshtern_3") then			
		    local state = 
		    {
		    	[MODIFIER_STATE_DISARMED] = false,
		    }
    		return state
    	end
    end
    return
end

LinkLuaModifier("modifier_morgenshtern_ice", "abilities/heroes/morgenshtern.lua", LUA_MODIFIER_MOTION_NONE)

morgenshtern_ice = class({})

function morgenshtern_ice:OnInventoryContentsChanged()
	if self:GetCaster():HasScepter() then
		self:SetHidden(false)		
		if not self:IsTrained() then
			self:SetLevel(1)
		end
	else
		self:SetHidden(true)
	end
end

function morgenshtern_ice:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function morgenshtern_ice:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_morgenshtern_ice", { duration = duration })
    self:GetCaster():EmitSound("MorgenIce")
end

modifier_morgenshtern_ice = class({})

function modifier_morgenshtern_ice:IsPurgable()
    return false
end

function modifier_morgenshtern_ice:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_morgenshtern_ice:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end

function modifier_morgenshtern_ice:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor( "damage_incoming" )
end

function modifier_morgenshtern_ice:GetEffectName()
    return "particles/frost_morgen.vpcf"
end

function modifier_morgenshtern_ice:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end