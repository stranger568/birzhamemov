LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Panasenkov_catch",  "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_Panasenkov_catch_caster", "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

Panasenkov_catch = class({})

function Panasenkov_catch:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Panasenkov_catch:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Panasenkov_catch:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_4")
end

function Panasenkov_catch:OnSpellStart()
	if not IsServer() then return end
	self.target = self:GetCursorTarget()

	if self.target:TriggerSpellAbsorb( self ) then
        return
    end

	self:GetCaster():EmitSound("PasenkovDeshSetka")

	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_1")

	self.target:AddNewModifier(self:GetCaster(), self, "modifier_Panasenkov_catch", {duration = duration * (1 - self.target:GetStatusResistance())})

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Panasenkov_catch_caster", {})

	self.target:EmitSound("PasenkovDesh")
end

modifier_Panasenkov_catch	= class({})

function modifier_Panasenkov_catch:IsPurgable()
	return false
end

function modifier_Panasenkov_catch:IsPurgeException()
	return true
end

function modifier_Panasenkov_catch:OnCreated()
	if not IsServer() then return end
	local shackle_particle = ParticleManager:CreateParticle("particles/panasenkov/panasenkov_catch.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(shackle_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackle_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackle_particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackle_particle, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackle_particle, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(shackle_particle, true, false, -1, true, false)
end

function modifier_Panasenkov_catch:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_Panasenkov_catch:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
	return decFuncs
end

function modifier_Panasenkov_catch:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_Panasenkov_catch:OnDestroy()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

modifier_Panasenkov_catch_caster = class({})

function modifier_Panasenkov_catch_caster:IsHidden()
	return true
end

function modifier_Panasenkov_catch_caster:IsPurgable()
	return false
end

function modifier_Panasenkov_catch_caster:IsPurgeException()
	return true
end

function modifier_Panasenkov_catch_caster:OnCreated( kv )
	self.speed = 1100
	self.close_distance = 200
	self.far_distance = 1450

	if IsServer() then
		self.target = self:GetAbility().target
		if self:ApplyHorizontalMotionController() == false then
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

function modifier_Panasenkov_catch_caster:OnDestroy()
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
		if not self.success then return end

	end
end

function modifier_Panasenkov_catch_caster:CheckState()
	local state = 
	{
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_Panasenkov_catch_caster:UpdateHorizontalMotion( me, dt )
	local origin = self:GetParent():GetOrigin()

	if not self.target:IsAlive() then
		self:EndCharge( false )
	end

	local direction = self.target:GetOrigin() - origin
	direction.z = 0
	local distance = direction:Length2D()
	direction = direction:Normalized()

	if distance<self.close_distance then
		self:EndCharge( true )
	elseif distance>self.far_distance then
		self:EndCharge( false )
	end

	local target = origin + direction * self.speed * dt
	self:GetParent():SetOrigin( target )

	self:GetParent():FaceTowards( self.target:GetOrigin() )
end

function modifier_Panasenkov_catch_caster:OnHorizontalMotionInterrupted()
	if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_Panasenkov_catch_caster:EndCharge( success )
	if success and (not self.target:TriggerSpellAbsorb(self:GetAbility())) then
		self.success = true
	end
	if not self:IsNull() then
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_Panasenkov_rakom", "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_NONE )

Panasenkov_rakom = class({})

function Panasenkov_rakom:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_2")
end

function Panasenkov_rakom:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Panasenkov_rakom:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Panasenkov_rakom:GetAOERadius()
    if self:GetCaster():HasShard() then
        return self:GetSpecialValueFor("shard_radius")
    end

    return 0
end

function Panasenkov_rakom:GetBehavior()
    local caster = self:GetCaster()
    local scepter = caster:HasShard()
    if scepter then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function Panasenkov_rakom:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_3")

	if self:GetCaster():HasShard() then
		local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("shard_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	    for _,enemy in pairs(targets) do
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_Panasenkov_rakom", {duration = duration * (1 - enemy:GetStatusResistance())})
		end
		self:GetCaster():EmitSound("PasenkovRak")
	else
		self.target = self:GetCursorTarget()
		if self.target:TriggerSpellAbsorb( self ) then
	        return
	    end
		self.target:AddNewModifier(self:GetCaster(), self, "modifier_Panasenkov_rakom", {duration = duration * (1 - self.target:GetStatusResistance())})
		self.target:EmitSound("PasenkovRak")
	end
end

modifier_Panasenkov_rakom = class({})

function modifier_Panasenkov_rakom:IsPurgable()
	return true
end

function modifier_Panasenkov_rakom:OnCreated()
	if not IsServer() then return end
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	self:StartIntervalThink(0.5)
end

function modifier_Panasenkov_rakom:OnIntervalThink()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_Panasenkov_rakom:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_Panasenkov_rakom:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		if params.damage_type == 2 then
    		local damage = params.original_damage * self:GetAbility():GetSpecialValueFor("bonus_damage")
    		ApplyDamage({attacker = params.attacker, victim = self:GetParent(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flag = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR})
		end
	end
end

LinkLuaModifier( "modifier_Panasenkov_groza", "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Panasenkov_groza_debuff", "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_NONE )

Panasenkov_groza = class({})

function Panasenkov_groza:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_6")
end

function Panasenkov_groza:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Panasenkov_groza:GetCastRange(location, target)
    return self:GetSpecialValueFor( "radius" )
end

function Panasenkov_groza:GetIntrinsicModifierName()
	if self:GetCaster():IsIllusion() then return end
	return "modifier_Panasenkov_groza"
end

modifier_Panasenkov_groza = class({})

function modifier_Panasenkov_groza:IsHidden()
	return true
end

function modifier_Panasenkov_groza:IsPurgable()
	return false
end

function modifier_Panasenkov_groza:OnCreated( kv )
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_Panasenkov_groza:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():IsAlive() then return end
	if self:GetParent():PassivesDisabled() then return end
	if self:GetAbility():IsFullyCastable() then
		local damage = self:GetAbility():GetSpecialValueFor( "damage" )
		local radius = self:GetAbility():GetSpecialValueFor( "radius" )
		local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		if #targets <= 0 then return end
		local target = nil
		for _,enemy in pairs(targets) do
			target = enemy
			break
		end
		if not target then
			target = enemies[1]
		end
		self:GetAbility():UseResources( false, false, false, true )
		target:EmitSound("PasenkovGroza")
		self.purifying_particle = ParticleManager:CreateParticle("particles/panasenkov/panasenkov_groza.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(self.purifying_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(self.purifying_particle)
		self.purifying_cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.purifying_cast_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(self.purifying_particle)

		local modifier_Panasenkov_groza_debuff = target:FindModifierByName("modifier_Panasenkov_groza_debuff")
		if modifier_Panasenkov_groza_debuff then
			damage = damage + ( modifier_Panasenkov_groza_debuff:GetStackCount() * self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_8") )
		end

		ApplyDamage({victim = target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		if self:GetCaster():HasTalent("special_bonus_birzha_ponasenkov_8") then
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Panasenkov_groza_debuff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_8", "value2")})
		end
	end
end

modifier_Panasenkov_groza_debuff = class({})
function modifier_Panasenkov_groza_debuff:IsPurgable() return false end
function modifier_Panasenkov_groza_debuff:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(1)
end
function modifier_Panasenkov_groza_debuff:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

LinkLuaModifier( "modifier_Panasenkov_song", "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_NONE )

Panasenkov_song = class({})

function Panasenkov_song:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end
function Panasenkov_song:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Panasenkov_song:GetCastRange(location, target)
    return self:GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_7")
end

function Panasenkov_song:OnToggle()
	local caster = self:GetCaster()
	local toggle = self:GetToggleState()

	if toggle then
		self.modifier = caster:AddNewModifier( caster, self, "modifier_Panasenkov_song", {})
		self:EndCooldown()
	else
		if self.modifier and not self.modifier:IsNull() then
			self.modifier:Destroy()
		end
		self.modifier = nil
		self:UseResources(false, false, false, true)
	end
end

modifier_Panasenkov_song = class({})

function modifier_Panasenkov_song:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_Panasenkov_song:IsPurgable()
	return false
end

function modifier_Panasenkov_song:OnCreated( kv )
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_5")
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ponasenkov_7")
	self.manacost = self:GetAbility():GetSpecialValueFor( "mana_cost_per_second" )

	self.damageTable = 
	{
		attacker = self:GetParent(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}

	local interval = 1
	self.parent = self:GetParent()
	self:Burn()
	self:StartIntervalThink( interval )
	EmitSoundOn( "PasenkovUltimate", self.parent )
end

function modifier_Panasenkov_song:OnDestroy()
	if not IsServer() then return end
	StopSoundOn( "PasenkovUltimate", self.parent )
end

function modifier_Panasenkov_song:OnIntervalThink()
	local mana = self.parent:GetMana()
	if mana < self.manacost then
		if self:GetAbility():GetToggleState() then
			self:GetAbility():ToggleAbility()
		end
		return
	end
	self:Burn()
end

function modifier_Panasenkov_song:Burn()
	self.parent:SpendMana( self.manacost, self:GetAbility() )

	local enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
		self:PlayEffects( enemy )
	end
end

function modifier_Panasenkov_song:GetEffectName()
	return "particles/units/heroes/hero_leshrac/leshrac_pulse_nova_ambient.vpcf"
end

function modifier_Panasenkov_song:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Panasenkov_song:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf"
	local radius = 100
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius,0,0) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

LinkLuaModifier( "modifier_ponasenkov_ya_vas_killed", "abilities/heroes/panasenkov.lua", LUA_MODIFIER_MOTION_NONE )

ponasenkov_ya_vas_killed = class({})

function ponasenkov_ya_vas_killed:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function ponasenkov_ya_vas_killed:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function ponasenkov_ya_vas_killed:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor( "duration" )
	self:GetCaster():EmitSound("panasenkov_shard")
	target:AddNewModifier( caster, self, "modifier_ponasenkov_ya_vas_killed", { duration = duration * (1-target:GetStatusResistance()) } )
	self:PlayEffects( target )
end

function ponasenkov_ya_vas_killed:PlayEffects( target )
	local direction = target:GetOrigin()-self:GetCaster():GetOrigin()
	direction.z = 0
	direction = direction:Normalized()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_silencer/silencer_last_word_status_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_ponasenkov_ya_vas_killed = class({})

function modifier_ponasenkov_ya_vas_killed:IsPurgable()
	return true
end

function modifier_ponasenkov_ya_vas_killed:OnCreated( kv )
	if not IsServer() then return end
	self.silence = true
	self:StartIntervalThink( FrameTime() )
end

function modifier_ponasenkov_ya_vas_killed:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}

	return funcs
end

function modifier_ponasenkov_ya_vas_killed:OnAbilityFullyCast( params )
	if not IsServer() then return end
	if params.unit~=self:GetParent() then return end
	if params.ability:IsItem() then return end
	self:Silence()
end

function modifier_ponasenkov_ya_vas_killed:OnIntervalThink()
	if not IsServer() then return end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 50, FrameTime(), false)
end

function modifier_ponasenkov_ya_vas_killed:Silence()
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silence", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration") * (1-self:GetParent():GetStatusResistance())})
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
	ApplyDamage( damageTable )
	self:PlayEffects()
	self.silence = false
	self:Destroy()
end

function modifier_ponasenkov_ya_vas_killed:OnDestroy()
	if not IsServer() then return end
	if self.silence then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silence", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration") * (1-self:GetParent():GetStatusResistance())})
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		ApplyDamage( damageTable )	
		self:PlayEffects()	
	end
end

function modifier_ponasenkov_ya_vas_killed:GetEffectName()
	return "particles/econ/items/silencer/silencer_ti6/silencer_last_word_status_ti6.vpcf"
end

function modifier_ponasenkov_ya_vas_killed:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ponasenkov_ya_vas_killed:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/silencer/silencer_ti6/silencer_last_word_dmg_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "Hero_Silencer.LastWord.Damage", self:GetParent() )
end