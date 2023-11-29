LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ram_fura_lift", "abilities/heroes/ram.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ram_fura_combination", "abilities/heroes/ram.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

ram_fura = class({})

function ram_fura:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ram_4")
end

function ram_fura:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function ram_fura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ram_fura:OnSpellStart()
	if not IsServer() then return end
    local tornado = 
    {
        Ability = self,
        bDeleteOnHit   = false,
        EffectName =  "particles/tornado/invoker_tornado_ti6.vpcf",
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        fDistance = 1600,
        fStartRadius = 200,
        fEndRadius = 200,
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        bVisibleToEnemies = true,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
    }

    local target_point = self:GetCursorPosition()
	local caster_point = self:GetCaster():GetAbsOrigin() 
	local point_difference_normalized 	= (target_point - caster_point):Normalized()

    if target_point == caster_point then
        point_difference_normalized = self:GetCaster():GetForwardVector()
    else
        point_difference_normalized = (target_point - caster_point):Normalized()
    end

    local speed = 1000

	local projectile_vvelocity = point_difference_normalized * 1000
	projectile_vvelocity.z = 0
	tornado.vVelocity 	= projectile_vvelocity

	local tornado_projectile = ProjectileManager:CreateLinearProjectile(tornado)
	self:GetCaster():EmitSound("Hero_Invoker.Tornado.Cast")
end

function ram_fura:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local duration = self:GetSpecialValueFor( "duration" )
        target:EmitSound("Hero_Invoker.Tornado")
        target:AddNewModifier( self:GetCaster(), self, "modifier_ram_fura_lift", { duration = duration * (1-target:GetStatusResistance())  } )
        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = duration * (1-target:GetStatusResistance()), distance = 0, height = 500, IsStun = true})

        if self:GetCaster():HasTalent("special_bonus_birzha_ram_3") then
            target:Purge(true, false, false, false, false)
        end

        local callback = function()
            if self:GetCaster():HasTalent("special_bonus_birzha_ram_6") then
                target:AddNewModifier( self:GetCaster(), self, "modifier_ram_fura_combination", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_ram_6", "value2")  } )
            end
            local damage = self:GetSpecialValueFor( "damage" )
            ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
            if self:GetCaster():HasScepter() then
                ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetCaster():GetIntellect(), damage_type = DAMAGE_TYPE_PURE, ability = self})
            end
        end

        knockback:SetEndCallback( callback )
    end
end

modifier_ram_fura_combination = class({})
function modifier_ram_fura_combination:IsHidden() return true end
function modifier_ram_fura_combination:IsPurgable() return false end
function modifier_ram_fura_combination:RemoveOnDeath() return false end

modifier_ram_fura_lift = class({})

function modifier_ram_fura_lift:IsHidden() return true  end
function modifier_ram_fura_lift:IsPurgable() return false end

function modifier_ram_fura_lift:CheckState()
	local state = 
    {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
	return state
end

LinkLuaModifier( "modifier_elfura_debuff_disarm", "abilities/heroes/ram.lua",LUA_MODIFIER_MOTION_NONE )

ram_ElFura = class({})

function ram_ElFura:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function ram_ElFura:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function ram_ElFura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ram_ElFura:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_ram_8") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_POINT
end

function ram_ElFura:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_birzha_ram_2" )
end

function ram_ElFura:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction

    if target_loc == caster_loc or self:GetCaster():HasTalent("special_bonus_birzha_ram_8") then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end

    local index = DoUniqueString("ram_elfura")
    self[index] = {}

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = 1100,
        fStartRadius        = 175,
        fEndRadius          = 225,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 1.5,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1100,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }

    if caster:HasTalent("special_bonus_birzha_ram_8") then
        for i = 1, 12 do
            ProjectileManager:CreateLinearProjectile(projectile)
            projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,30*i,0), caster:GetForwardVector()) * 1000
        end
    else
        ProjectileManager:CreateLinearProjectile(projectile)
    end

    caster:EmitSound("Hero_Invoker.DeafeningBlast")
end

function ram_ElFura:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then

        local was_hit = false

        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end

        if was_hit then
            return false
        end

        table.insert(self[ExtraData.index],target)

        local distance_knock = self:GetSpecialValueFor("distance_knock")

        local direction = (target:GetAbsOrigin() - location):Normalized()

        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.75, distance = distance_knock, height = 0, direction_x = direction.x, direction_y = direction.y})
        
        local damage = self:GetSpecialValueFor("damage")

        if self:GetCaster():HasTalent("special_bonus_birzha_ram_6") then
            if target:HasModifier("modifier_ram_fura_combination") then
                target:RemoveModifierByName("modifier_ram_fura_combination")
                damage = damage + ( damage / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_ram_6"))
            end
        end

        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})

        if self:GetCaster():HasScepter() then
            ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetCaster():GetIntellect(), damage_type = DAMAGE_TYPE_PURE, ability = self})
        end

        local callback = function()
            local duration = self:GetSpecialValueFor('duration')
            target:AddNewModifier(self:GetCaster(), self, "modifier_elfura_debuff_disarm", {duration = duration * (1 - target:GetStatusResistance())})
        end

        knockback:SetEndCallback( callback )
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.arrows then
            self[ExtraData.index] = nil
        end
    end
end

modifier_elfura_debuff_disarm = class({})

function modifier_elfura_debuff_disarm:IsPurgable()
    return false
end

function modifier_elfura_debuff_disarm:IsPurgeException()
    return true
end

function modifier_elfura_debuff_disarm:GetEffectName() return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf" end
function modifier_elfura_debuff_disarm:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_elfura_debuff_disarm:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_elfura_debuff_disarm:CheckState() 
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

function modifier_elfura_debuff_disarm:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('slow_pct')
end

LinkLuaModifier( "modifier_demonic_shield", "abilities/heroes/ram.lua", LUA_MODIFIER_MOTION_NONE )

ram_DemonicShield = class({})

function ram_DemonicShield:OnToggle()
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName( "modifier_demonic_shield" )
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	if self:GetToggleState() then
		if not modifier then
			caster:AddNewModifier( caster, self, "modifier_demonic_shield", {} )
		end
	else
		if modifier then
			modifier:Destroy()
		end
	end
end

function ram_DemonicShield:OnUpgrade()
	local modifier = self:GetCaster():FindModifierByName( "modifier_demonic_shield" )
	if modifier then
		modifier:ForceRefresh()
	end
end

modifier_demonic_shield = class({})

function modifier_demonic_shield:IsPurgable()
	return false
end

function modifier_demonic_shield:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_demonic_shield:OnCreated( kv )
	self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
	self.absorb_pct = self:GetAbility():GetSpecialValueFor( "absorption_tooltip" )
	if not IsServer() then return end
	EmitSoundOn( "Hero_Medusa.ManaShield.On", self:GetParent() )
end

function modifier_demonic_shield:OnRefresh( kv )
	self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
	self.absorb_pct = self:GetAbility():GetSpecialValueFor( "absorption_tooltip" )
end

function modifier_demonic_shield:OnDestroy()
	if not IsServer() then return end
	EmitSoundOn( "Hero_Medusa.ManaShield.Off", self:GetParent() )
end

function modifier_demonic_shield:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_demonic_shield:GetModifierIncomingDamage_Percentage( params )
    self.absorb_pct = (self:GetAbility():GetSpecialValueFor( "absorption_tooltip" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ram_7")) / 100
	local absorb = -100*self.absorb_pct
	local damage_absorbed = params.damage * self.absorb_pct
	local manacost = damage_absorbed/(self.damage_per_mana + self:GetCaster():FindTalentValue("special_bonus_birzha_ram_1"))
	local mana = self:GetParent():GetMana()
	if mana<manacost then
		damage_absorbed = mana * (self.damage_per_mana + self:GetCaster():FindTalentValue("special_bonus_birzha_ram_1"))
		absorb = -damage_absorbed/params.damage*100

		manacost = mana
	end
	self:GetParent():SpendMana( manacost, self:GetAbility() )
	self:PlayEffects( damage_absorbed )
	return absorb
end

function modifier_demonic_shield:GetEffectName()
	return "particles/ram/medusa_mana_shield.vpcf"
end

function modifier_demonic_shield:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_demonic_shield:PlayEffects( damage )
	local effect_cast = ParticleManager:CreateParticle( "particles/ram/medusa_mana_shield_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( damage, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "Hero_Medusa.ManaShield.Proc", self:GetParent() )
end

LinkLuaModifier("modifier_ram_ult", "abilities/heroes/ram.lua", LUA_MODIFIER_MOTION_NONE)

ram_ultimate = class({})

function ram_ultimate:GetIntrinsicModifierName()
    return "modifier_ram_ult"
end

modifier_ram_ult = class({})

function modifier_ram_ult:IsHidden()
    return true
end

function modifier_ram_ult:IsPurgable() return false end

function modifier_ram_ult:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return declfuncs
end

function modifier_ram_ult:GetModifierMagicalResistanceBonus()
    if not self:GetParent():HasShard() then return end
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_resist")
end

function modifier_ram_ult:GetModifierConstantHealthRegen()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_healt_regen")
end

function modifier_ram_ult:GetModifierConstantManaRegen()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_ram_ult:GetModifierPhysicalArmorBonus()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

LinkLuaModifier("modifier_ram_wind_thinker", "abilities/heroes/ram", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ram_wind_thinker_pull", "abilities/heroes/ram", LUA_MODIFIER_MOTION_NONE)

ram_wind = class({})

function ram_wind:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_ram_5") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function ram_wind:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function ram_wind:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function ram_wind:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("delay")
    local thinker = CreateModifierThinker( self:GetCaster(), self, "modifier_ram_wind_thinker", { duration = delay, x = point.x, y = point.y, z = point.z }, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
    thinker:EmitSound("Hero_Invoker.EMP.Cast")
end

modifier_ram_wind_thinker = class({})

function modifier_ram_wind_thinker:IsHidden()
    return true
end

function modifier_ram_wind_thinker:IsPurgable()
    return false
end

function modifier_ram_wind_thinker:IsAura() return true end

function modifier_ram_wind_thinker:GetModifierAura()
	return "modifier_ram_wind_thinker_pull"
end

function modifier_ram_wind_thinker:GetAuraRadius()
	return 200
end

function modifier_ram_wind_thinker:GetAuraDuration()
	return 0
end

function modifier_ram_wind_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ram_wind_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_ram_wind_thinker:OnCreated( kv )
    if not IsServer() then return end
    self.end_point = Vector(kv.x,kv.y,kv.z)
    self.direction = self.end_point - self:GetParent():GetAbsOrigin()
    self.direction.z = 0
    self.direction = self.direction:Normalized()

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.effect_cast = ParticleManager:CreateParticle( "particles/ram_emp.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, 0 ) )
    self:AddParticle(self.effect_cast, false, false, -1, false, false)
    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Invoker.EMP.Charge", self:GetCaster() )
    self.mana_burned = self:GetAbility():GetSpecialValueFor("mana_burn")
    self:StartIntervalThink(0.01)
end

function modifier_ram_wind_thinker:OnIntervalThink()
    if not IsServer() then return end
    local new_point = self:GetParent():GetAbsOrigin() + self.direction * (self:GetAbility():GetSpecialValueFor("speed") * 0.01)
    local length = (self.end_point - new_point):Length2D()
    if length <= 15 then return end
    self:GetParent():SetAbsOrigin(new_point)
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
end

function modifier_ram_wind_thinker:OnDestroy( kv )
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, 0, false )

    for _,enemy in pairs(enemies) do
        local mana_burn = math.min( enemy:GetMana(), enemy:GetMana() / 100 * self.mana_burned )
        enemy:Script_ReduceMana( mana_burn, self:GetAbility() )
        self:GetCaster():GiveMana(mana_burn * self:GetAbility():GetSpecialValueFor("mana_add"))
        local damageTable = { attacker = self:GetCaster(), victim = enemy, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility(), damage = (self:GetAbility():GetSpecialValueFor("damage") * #enemies) + mana_burn }
        ApplyDamage(damageTable)
    end

    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Invoker.EMP.Discharge", self:GetCaster() )
    UTIL_Remove( self:GetParent() )
end

modifier_ram_wind_thinker_pull = class({})

function modifier_ram_wind_thinker_pull:IsPurgable() return false end
function modifier_ram_wind_thinker_pull:IsHidden() return true end
function modifier_ram_wind_thinker_pull:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ram_wind_thinker_pull:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.01)
end

function modifier_ram_wind_thinker_pull:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():IsCurrentlyHorizontalMotionControlled() and not self:GetParent():IsCurrentlyVerticalMotionControlled() then
        if self:GetAuraOwner() and not self:GetAuraOwner():IsNull() then
            local speed = self:GetAbility():GetSpecialValueFor("pull_speed")
            local vect = (self:GetParent():GetAbsOrigin() - self:GetAuraOwner():GetAbsOrigin()):Normalized()
            if (self:GetParent():GetAbsOrigin() - self:GetAuraOwner():GetAbsOrigin()):Length2D() >= 100 then 
                self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin() - vect* (speed * 0.01))
            end
        end
	end
end

function modifier_ram_wind_thinker_pull:CheckState()
    return
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_ram_wind_thinker_pull:OnDestroy()
	if not IsServer() then return end
	if not self:GetParent():IsCurrentlyHorizontalMotionControlled() and not self:GetParent():IsCurrentlyVerticalMotionControlled() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end