LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_homunculus_iborn", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)

Homunculus_IBorn = class({})

function Homunculus_IBorn:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Homunculus_IBorn:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Homunculus_IBorn:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Homunculus_IBorn:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local target = self:GetCursorTarget()
	target:AddNewModifier(self:GetCaster(), self, "modifier_homunculus_iborn", { duration = duration })
    target:EmitSound("Hero_Winter_Wyvern.ColdEmbrace.Cast")
end

modifier_homunculus_iborn = class({})

function modifier_homunculus_iborn:IsPurgable()
    return true
end

function modifier_homunculus_iborn:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_homunculus_iborn:CheckState()
    local state = 
    {
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
    if self:GetCaster():HasScepter() then
        state = 
        {
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_SILENCED] = true,
        }        
    end
    return state
end

function modifier_homunculus_iborn:GetModifierHealthRegenPercentage()
    return self:GetAbility():GetSpecialValueFor( "health_regen" )
end

function modifier_homunculus_iborn:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor( "damage_incoming" )
end

function modifier_homunculus_iborn:GetEffectName()
    return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function modifier_homunculus_iborn:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_homunculus_Spit_debuff", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_Spit_debuff_fountain", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)

Homunculus_Spit = class({})

function Homunculus_Spit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Homunculus_Spit:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Homunculus_Spit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Homunculus_Spit:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_mouth"))
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
        vSpawnOrigin        = point,
        fDistance           = 1500,
        fStartRadius        = 150,
        fEndRadius          = 150,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1500,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Hero_Venomancer.VenomousGale")
end

function Homunculus_Spit:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_1")
    local duration = self:GetSpecialValueFor('duration')

    if target then
        target:EmitSound("Hero_Venomancer.VenomousGaleImpact")
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        local duration = self:GetSpecialValueFor('duration')
        target:AddNewModifier( caster, self, "modifier_homunculus_Spit_debuff", {duration = duration * (1 - target:GetStatusResistance())})
        target:AddNewModifier( caster, self, "modifier_homunculus_Spit_debuff_fountain", {duration = 1})
    end
end

modifier_homunculus_Spit_debuff_fountain = class({})

function modifier_homunculus_Spit_debuff_fountain:IsPurgable()
    return false
end

function modifier_homunculus_Spit_debuff_fountain:IsHidden()
    return true
end

function modifier_homunculus_Spit_debuff_fountain:OnCreated()
    if not IsServer() then return end
    local buildings = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        Vector(0,0,0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        0,
        false
    )
    local fountain = nil
    for _,building in pairs(buildings) do
        if building:GetClassname()=="ent_dota_fountain" then
            fountain = building
            break
        end
    end
    if not fountain then return end
    self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

function modifier_homunculus_Spit_debuff_fountain:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
end

function modifier_homunculus_Spit_debuff_fountain:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }

    return state
end

modifier_homunculus_Spit_debuff = class({})

function modifier_homunculus_Spit_debuff:IsPurgable()
    return true
end

function modifier_homunculus_Spit_debuff:IsPurgeException()
    return true
end

function modifier_homunculus_Spit_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(2)
end

function modifier_homunculus_Spit_debuff:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_homunculus_Spit_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_homunculus_Spit_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_1")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_homunculus_Spit_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_homunculus_Spit_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "movement_speed" )
end

LinkLuaModifier("modifier_homunculus_damn", "abilities/heroes/homunculus", LUA_MODIFIER_MOTION_NONE)

Homunculus_Damn = class({}) 

function Homunculus_Damn:GetIntrinsicModifierName()
    return "modifier_homunculus_damn"
end

modifier_homunculus_damn = class({}) 

function modifier_homunculus_damn:IsPurgable()
    return false
end

function modifier_homunculus_damn:IsHidden()
    return true
end

function modifier_homunculus_damn:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_homunculus_damn:OnAttackLanded( keys )
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        local chance = self:GetAbility():GetSpecialValueFor("chance")
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if RandomInt(1, 100) <= chance then
            if keys.attacker:IsMagicImmune() then return end
            keys.attacker:EmitSound("gomunkul3")
            keys.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_homunculus_Spit_debuff_fountain", { duration = duration * (1 - keys.attacker:GetStatusResistance()) } )
            if self:GetParent():HasShard() then
                local ability = self:GetParent():FindAbilityByName("Homunculus_Spit")
                if ability then
                    local duration = ability:GetSpecialValueFor("duration")
                    keys.attacker:AddNewModifier( self:GetParent(), ability, "modifier_homunculus_Spit_debuff", {duration = duration * (1 - keys.attacker:GetStatusResistance())})
                end
            end
        end
    end
end


LinkLuaModifier( "modifier_Dictionary_debuff", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)

Homunculus_Dictionary = class({})

function Homunculus_Dictionary:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Homunculus_Dictionary:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Homunculus_Dictionary:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Homunculus_Dictionary:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_3")
    self:GetCaster():EmitSound("gomunkul4")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    0,
    FIND_ANY_ORDER,
    false)

    for _,unit in pairs(targets) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_Dictionary_debuff", { duration = duration * (1 - unit:GetStatusResistance()) } )
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, (radius - 255) / 1500, 1500))

    local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = 100000000,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }

    local talent_damage = self:GetCaster():GetHealth() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_2")
    local new_health = self:GetCaster():GetHealth() - talent_damage
    if self:GetCaster():HasTalent("special_bonus_birzha_homunculus_2") then
        self:GetCaster():ModifyHealth(new_health, self, false, 0)
    else
        ApplyDamage(damageTable)
    end
end

modifier_Dictionary_debuff = class({})

function modifier_Dictionary_debuff:IsPurgable()
    return false
end

function modifier_Dictionary_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.25)
    self:OnIntervalThink()
end

function modifier_Dictionary_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("per_damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_Dictionary_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Dictionary_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor( "magical_resistance" )
end

function modifier_Dictionary_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "movement_speed" )
end

function modifier_Dictionary_debuff:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_Dictionary_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function modifier_Dictionary_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function modifier_Dictionary_debuff:StatusEffectPriority()
    return 10
end
