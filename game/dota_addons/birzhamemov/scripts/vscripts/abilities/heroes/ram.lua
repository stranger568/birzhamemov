LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ram_fura_lift", "abilities/heroes/ram.lua", LUA_MODIFIER_MOTION_NONE )

ram_fura = class({})

function ram_fura:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function ram_fura:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function ram_fura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ram_fura:OnSpellStart()
	if IsServer() then
	    self.tornado = 
	    {
	        Ability = self,
	        bDeleteOnHit   = false,
	        EffectName =  "particles/tornado/invoker_tornado_ti6.vpcf",
	        vSpawnOrigin = self:GetCaster():GetOrigin(),
	        fDistance = 1600,
	        fStartRadius = 175,
	        fEndRadius = 225,
	        iMoveSpeed 			= 1000,
	        Source = self:GetCaster(),
	        bHasFrontalCone = false,
	        bReplaceExisting = false,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	        bVisibleToEnemies = true,
	        bProvidesVision = true,
	        iVisionRadius = 250,
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

		local projectile_vvelocity 			= point_difference_normalized * 1000
		projectile_vvelocity.z = 0
		self.tornado.vVelocity 	= projectile_vvelocity
		local tornado_projectile = ProjectileManager:CreateLinearProjectile(self.tornado)
		self:GetCaster():EmitSound("Hero_Invoker.Tornado.Cast")
	end
end

function ram_fura:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local duration = self:GetSpecialValueFor( "duration" )
        target:EmitSound("Hero_Invoker.Tornado")
        target:AddNewModifier( self:GetCaster(), self, "modifier_ram_fura_lift", { duration = duration  } )

        local knockback =
        {
            knockback_duration = duration,
            duration = duration,
            knockback_distance = 0,
            knockback_height = 500,
        }
        target:RemoveModifierByName("modifier_knockback")
        target:AddNewModifier(caster, self, "modifier_knockback", knockback)
    end
end

modifier_ram_fura_lift = class({})

function modifier_ram_fura_lift:IsHidden() 	return true  end
function modifier_ram_fura_lift:IsPurgable() 	return false  end

function modifier_ram_fura_lift:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] 	= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] 			= true,
		[MODIFIER_STATE_STUNNED] 			= true,
		[MODIFIER_STATE_ROOTED] 			= true,
		[MODIFIER_STATE_DISARMED] 			= true,
		[MODIFIER_STATE_NO_HEALTH_BAR] 	= true,
		[MODIFIER_STATE_MAGIC_IMMUNE] 			= true,
		[MODIFIER_STATE_ATTACK_IMMUNE] 			= true,
		[MODIFIER_STATE_UNSELECTABLE] 			= true,
	}
	return state
end

function modifier_ram_fura_lift:OnDestroy()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ram_1")
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

LinkLuaModifier( "modifier_elfura_debuff", "abilities/heroes/ram.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elfura_debuff_disarm", "abilities/heroes/ram.lua",LUA_MODIFIER_MOTION_NONE )

ram_ElFura = class({})

function ram_ElFura:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function ram_ElFura:GetCastRange(location, target)
	if self:GetCaster():HasScepter() then
		self:GetSpecialValueFor("distance")
	end
    return self.BaseClass.GetCastRange(self, location, target)
end

function ram_ElFura:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ram_ElFura:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_POINT
end

function ram_ElFura:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local target_loc = self:GetCursorPosition()
        local caster_loc = caster:GetAbsOrigin()
        local distance = self:GetCastRange(caster_loc,caster)
        local direction

        if target_loc == caster_loc then
            direction = caster:GetForwardVector()
        else
            direction = (target_loc - caster_loc):Normalized()
        end

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
            if caster:HasScepter() then
                i = -30
                for var=1,13, 1 do
                    ProjectileManager:CreateLinearProjectile(projectile)
                    projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * 1000
                    i = i + 30
                end
            else
                ProjectileManager:CreateLinearProjectile(projectile)
            end
        caster:EmitSound("Hero_Invoker.DeafeningBlast")
    end
end

function ram_ElFura:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local caster = self:GetCaster()
        local distance = (target:GetAbsOrigin() - location):Length2D()
        local direction = (target:GetAbsOrigin() - location):Normalized()
        local bump_point = location - direction * (distance + 150)

        local knockbackProperties =
        {
             center_x = bump_point.x,
             center_y = bump_point.y,
             center_z = bump_point.z,
             duration = 0.75,
             knockback_duration = 0.75,
             knockback_distance = 700,
             knockback_height = 0
        }
        target:RemoveModifierByName("modifier_knockback")
        target:AddNewModifier(target, self, "modifier_knockback", knockbackProperties)
        if target:HasModifier("modifier_elfura_debuff") then return end
        target:AddNewModifier(caster, self, "modifier_elfura_debuff", {duration = 0.8})
    end
end

modifier_elfura_debuff = class({})

function modifier_elfura_debuff:IsHidden()
    return true
end

function modifier_elfura_debuff:IsPurgable()
    return false
end

function modifier_elfura_debuff:IsPurgeException()
    return true
end

function modifier_elfura_debuff:OnCreated( )
	if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_ram_2")
    local duration = self:GetAbility():GetSpecialValueFor('duration')
    if self:GetAbility():GetCaster():HasScepter() then
        damage = damage + self:GetAbility():GetCaster():GetIntellect()
    end
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        Timers:CreateTimer(0.75, function()
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_elfura_debuff_disarm", {duration = duration * (1 - self:GetParent():GetStatusResistance())})
    end)
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
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
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
	if self:GetToggleState() then
		if not modifier then
			caster:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_demonic_shield", -- modifier name
				{} -- kv
			)
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
	self.absorb_pct = self:GetAbility():GetSpecialValueFor( "absorption_tooltip" )/100
	if not IsServer() then return end
	EmitSoundOn( "Hero_Medusa.ManaShield.On", self:GetParent() )
end

function modifier_demonic_shield:OnRefresh( kv )
	self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
	self.absorb_pct = self:GetAbility():GetSpecialValueFor( "absorption_tooltip" )/100
end

function modifier_demonic_shield:OnDestroy()
	if not IsServer() then return end
	EmitSoundOn( "Hero_Medusa.ManaShield.Off", self:GetParent() )
end

function modifier_demonic_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_demonic_shield:GetModifierIncomingDamage_Percentage( params )
	local absorb = -100*self.absorb_pct
	local damage_absorbed = params.damage * self.absorb_pct
	local manacost = damage_absorbed/self.damage_per_mana
	local mana = self:GetParent():GetMana()
	if mana<manacost then
		damage_absorbed = mana * self.damage_per_mana
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

function modifier_ram_ult:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return declfuncs
end

function modifier_ram_ult:GetModifierMagicalResistanceBonus()
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