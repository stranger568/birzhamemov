LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_homunculus_iborn", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_iborn_immortality", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_iborn_immortality_cooldown", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_iborn_immortality_active", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_iborn_aggres", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)

Homunculus_IBorn = class({})

function Homunculus_IBorn:Precache(context)
    local particle_list = 
    {
        "particles/homunculus_iborn_buff.vpcf",
        "particles/status_fx/status_effect_beserkers_call.vpcf",
        "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
        "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf",
        "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf",
        "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf",
        "particles/status_fx/status_effect_poison_venomancer.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Homunculus_IBorn:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_2")
end

function Homunculus_IBorn:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Homunculus_IBorn:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Homunculus_IBorn:GetIntrinsicModifierName()
    return "modifier_homunculus_iborn_immortality"
end

function Homunculus_IBorn:OnSpellStart(new_target)
    if not IsServer() then return end
    local target
    if new_target then
        target = new_target
    else
        target = self:GetCursorTarget()
    end
    local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(self:GetCaster(), self, "modifier_homunculus_iborn", { duration = duration })
    target:EmitSound("Hero_Winter_Wyvern.ColdEmbrace.Cast")
end

modifier_homunculus_iborn = class({})

function modifier_homunculus_iborn:IsPurgable()
    return true
end

function modifier_homunculus_iborn:OnCreated()
    if not IsServer() then return end
    local Homunculus_IBorn = self:GetParent():FindAbilityByName("Homunculus_IBorn")
    if Homunculus_IBorn then
        Homunculus_IBorn:SetActivated(false)
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_homunculus_6") then
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_6", "value2"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        for _,enemy in pairs(enemies) do
        if not enemy:IsDuel() then
                enemy:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_homunculus_iborn_aggres", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_6") } )
            end
        end
    end
end

function modifier_homunculus_iborn:OnDestroy()
    if not IsServer() then return end
    local Homunculus_IBorn = self:GetParent():FindAbilityByName("Homunculus_IBorn")
    if Homunculus_IBorn then
        Homunculus_IBorn:SetActivated(true)
    end
end

function modifier_homunculus_iborn:DeclareFunctions()
	local funcs = 
    {
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
    return "particles/homunculus_iborn_buff.vpcf"
end

function modifier_homunculus_iborn:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_homunculus_iborn_immortality = class({})

function modifier_homunculus_iborn_immortality:IsHidden()
    return true
end

function modifier_homunculus_iborn_immortality:IsPurgable()
    return false
end

function modifier_homunculus_iborn_immortality:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_homunculus_iborn_immortality:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetParent():HasTalent("special_bonus_birzha_homunculus_7") then return end
    if self:GetParent():HasModifier("modifier_homunculus_iborn_immortality_cooldown") then return end
    if not self:GetParent():HasModifier("modifier_homunculus_iborn_immortality_active") then
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_homunculus_iborn_immortality_active", {})
    end
end

modifier_homunculus_iborn_immortality_cooldown = class({})
function modifier_homunculus_iborn_immortality_cooldown:IsPurgable() return false end
function modifier_homunculus_iborn_immortality_cooldown:RemoveOnDeath() return false end
function modifier_homunculus_iborn_immortality_cooldown:IsDebuff() return true end

modifier_homunculus_iborn_immortality_active = class({})

function modifier_homunculus_iborn_immortality_active:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return decFuncs
end

function modifier_homunculus_iborn_immortality_active:OnIntervalThink()
    if not IsServer() then return end
    self:Destroy()
end

function modifier_homunculus_iborn_immortality_active:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.unit then return end
    if self:GetParent():IsIllusion() then return end

    if self:GetParent():HasModifier("modifier_item_uebator_active") then
        return
    end
    
    if self:GetParent():HasModifier("modifier_item_aeon_disk_buff") then
        return
    end

    if not self:GetParent():HasModifier("modifier_item_uebator_cooldown") and self:GetParent():HasModifier("modifier_item_uebator") then
        return
    end

    for i = 0, 5 do 
        local item = self:GetParent():GetItemInSlot(i)
        if item then
            if item:GetName() == "item_aeon_disk" then
                if item:IsFullyCastable() then
                    return
                end
            end
        end        
    end

    if self:GetParent():GetHealth() <= 1 then
        self:GetParent():SetHealth(1)
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_homunculus_iborn_immortality_cooldown", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_7")})
        local Homunculus_IBorn = self:GetCaster():FindAbilityByName("Homunculus_IBorn")
        if Homunculus_IBorn and Homunculus_IBorn:GetLevel() > 0 then
            Homunculus_IBorn:OnSpellStart(self:GetParent())
        end
        self:StartIntervalThink(0.25)
    end          
end

function modifier_homunculus_iborn_immortality_active:GetMinHealth()
    return 1
end

modifier_homunculus_iborn_aggres = class({})

function modifier_homunculus_iborn_aggres:IsHidden()
    return false
end

function modifier_homunculus_iborn_aggres:IsPurgable()
    return false
end

function modifier_homunculus_iborn_aggres:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetCaster() )
    self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    self:StartIntervalThink(FrameTime())
end

function modifier_homunculus_iborn_aggres:OnIntervalThink( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetCaster() )
    self:GetParent():MoveToTargetToAttack( self:GetCaster() )
end

function modifier_homunculus_iborn_aggres:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( nil )
end

function modifier_homunculus_iborn_aggres:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
    }

    return state
end

function modifier_homunculus_iborn_aggres:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

LinkLuaModifier( "modifier_homunculus_Spit_debuff", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_Spit_debuff_fountain", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_homunculus_Spit_debuff_talent", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)

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

function Homunculus_Spit:OnSpellStart(point_new)
    if not IsServer() then return end
    local caster = self:GetCaster()

    local target_loc = point_new

    if point_new == nil then
        target_loc = self:GetCursorPosition()
    end

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
        fDistance           = 800,
        fStartRadius        = 150,
        fEndRadius          = 150,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
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

    local damage = self:GetSpecialValueFor('damage')

    local duration = self:GetSpecialValueFor('duration')

    if target == nil then return end

    if not self:GetCaster():HasTalent("special_bonus_birzha_homunculus_5") then
        if target:IsMagicImmune() then return end
    end

    target:EmitSound("Hero_Venomancer.VenomousGaleImpact")
    ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    target:AddNewModifier( caster, self, "modifier_homunculus_Spit_debuff", {duration = duration * (1 - target:GetStatusResistance())})
    if self:GetCaster():HasTalent("special_bonus_birzha_homunculus_3") then
        local Homunculus_Damn = self:GetCaster():FindAbilityByName("Homunculus_Damn")
        if Homunculus_Damn and Homunculus_Damn:GetLevel() > 0 then
            target:AddNewModifier( caster, self, "modifier_homunculus_Spit_debuff_fountain", {duration = Homunculus_Damn:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
        end
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
    local pos = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin())
    pos.z = 0
    pos = pos:Normalized()
    self.position = self:GetParent():GetAbsOrigin() + pos * 3000
    self:GetParent():MoveToPosition( self.position )
end

function modifier_homunculus_Spit_debuff_fountain:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():MoveToPosition( self.position )
end

function modifier_homunculus_Spit_debuff_fountain:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
end

function modifier_homunculus_Spit_debuff_fountain:CheckState()
    local state = 
    {
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
    self:StartIntervalThink(0.5)
end

function modifier_homunculus_Spit_debuff:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_homunculus_Spit_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_homunculus_Spit_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * 0.35, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_homunculus_Spit_debuff:DeclareFunctions()
    local funcs = 
    {
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
        local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_1")
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if RollPercentage(chance) then
            if keys.attacker:IsMagicImmune() then return end
            if not keys.attacker:HasModifier("modifier_homunculus_iborn_aggres") then
                keys.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_homunculus_Spit_debuff_fountain", { duration = duration * (1 - keys.attacker:GetStatusResistance()) } )
                keys.attacker:EmitSound("gomunkul3")
            end
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
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_4")
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
    local damage = self:GetSpecialValueFor("damage")
    self:GetCaster():EmitSound("gomunkul4")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

    for _,unit in pairs(targets) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_Dictionary_debuff", { duration = duration * (1 - unit:GetStatusResistance()) } )
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, (radius - 255) / 1500, 1500))

    local talent_damage = self:GetCaster():GetHealth() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_homunculus_8")

    local new_health = self:GetCaster():GetHealth() - talent_damage
    if self:GetCaster():HasTalent("special_bonus_birzha_homunculus_8") then
        self:GetCaster():ModifyHealth(new_health, self, false, 0)
    else
        self:GetCaster():Kill(self, self:GetCaster())
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
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * 0.25, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_Dictionary_debuff:DeclareFunctions()
    local funcs = 
    {
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
