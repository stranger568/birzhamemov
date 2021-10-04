LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Knuckles_Spit", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knuckles_spit_debuff", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

Knuckles_Spit = class({}) 

function Knuckles_Spit:GetIntrinsicModifierName()
    return "modifier_Knuckles_Spit"
end

modifier_Knuckles_Spit = class({}) 

function modifier_Knuckles_Spit:IsHidden()      return true end
function modifier_Knuckles_Spit:IsPurgable()    return false end

function modifier_Knuckles_Spit:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_Knuckles_Spit:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()

    if attacker ~= keys.attacker then
        return
    end

    if attacker:PassivesDisabled() then
        return
    end

    local target = keys.target

    if attacker:GetTeam() == target:GetTeam() then
        return
    end 

    if target:IsOther() then
        return nil
    end

    local chance = self:GetAbility():GetSpecialValueFor('chance')
    local duration = self:GetAbility():GetSpecialValueFor('duration')    

    if RandomInt(1, 100) <= chance then        
        attacker:EmitSound("ugandaplevok")
        target:AddNewModifier(attacker, self:GetAbility(), "modifier_knuckles_spit_debuff", {duration = duration})
    end
end

modifier_knuckles_spit_debuff = class({}) 

function modifier_knuckles_spit_debuff:OnCreated()
   if not IsServer() then return end
   self:StartIntervalThink(1)
end

function modifier_knuckles_spit_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_1")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_knuckles_spit_debuff:IsPurgable() return true end

function modifier_knuckles_spit_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_knuckles_spit_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('movespeed_slow')
end

Knuckles_queens = class({}) 

function Knuckles_queens:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Knuckles_queens:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Knuckles_queens:OnSpellStart()
    if not IsServer() then return end
    local Quuens = {
        "npc_knuckles_crystal_maiden",
        "npc_knuckles_lina",
        "npc_knuckles_windrunner"
    }
    local duration = self:GetSpecialValueFor('duration')
    local quuen_random = Quuens[RandomInt(1, #Quuens)]
    self:GetCaster():EmitSound("queen")
    local queen = CreateUnitByName(quuen_random, self:GetCaster():GetAbsOrigin() + RandomVector(600), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    queen:SetControllableByPlayer( self:GetCaster():GetPlayerOwnerID(), true )
    queen:SetOwner(self:GetCaster())
    queen:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
end

LinkLuaModifier("modifier_heal_uganda_aura", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

modifier_heal_uganda_aura = class({})

function modifier_heal_uganda_aura:IsHidden()
    return true
end

function modifier_heal_uganda_aura:OnDeath(keys)
    if not IsServer() then return end
    local target = keys.unit
    if target == self:GetParent() then
        local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        5000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false)

        for _,unit in pairs(units) do
            unit:Heal(500, self:GetAbility())
        end
    end
end

powershot_uganda = class({})

function powershot_uganda:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function powershot_uganda:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function powershot_uganda:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function powershot_uganda:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition() + 5
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("bow_mid"))
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/econ/items/windrunner/windrunner_weapon_rainmaker/windrunner_spell_powershot_rainmaker.vpcf",
        vSpawnOrigin        = point,
        fDistance           = 1300,
        fStartRadius        = 125,
        fEndRadius          = 250,
        Source              = caster,
        bHasFrontalCone     = true,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1600,
        iVisionRadius =     100,
        bProvidesVision     = true,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    projectile.vVelocity = Vector(direction.x,direction.y,0) * 1200
    projectile.EffectName = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6.vpcf"
    ProjectileManager:CreateLinearProjectile(projectile)
    projectile.vVelocity = Vector(direction.x,direction.y,0) * 800
    projectile.EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Ability.Powershot")
end

function powershot_uganda:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage')
    if target then
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

lina_dragon_slave_uganda = class({})

function lina_dragon_slave_uganda:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function lina_dragon_slave_uganda:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function lina_dragon_slave_uganda:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function lina_dragon_slave_uganda:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition() + 5
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
        vSpawnOrigin        = point,
        fDistance           = 1300,
        fStartRadius        = 300,
        fEndRadius          = 500,
        Source              = caster,
        bHasFrontalCone     = true,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1200,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Hero_Lina.DragonSlave")
end

function lina_dragon_slave_uganda:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage')
    if target then
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

LinkLuaModifier("modifier_knuckles_crystal_maiden_aura", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knuckles_crystal_maiden", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

CrystalQueen_Damage = class({})

function CrystalQueen_Damage:GetIntrinsicModifierName()
    return "modifier_knuckles_crystal_maiden_aura"
end

modifier_knuckles_crystal_maiden_aura = class({})

function modifier_knuckles_crystal_maiden_aura:IsPurgable() return false end
function modifier_knuckles_crystal_maiden_aura:IsHidden() return true end
function modifier_knuckles_crystal_maiden_aura:IsAura() return true end

function modifier_knuckles_crystal_maiden_aura:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.particle, 1, Vector( 750, 750, 1 ) )
    self:AddParticle( self.particle,  false, false, -1,  false, false )
    EmitSoundOn( "hero_Crystal.freezingField.wind", self:GetParent() )
end

function modifier_knuckles_crystal_maiden_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_knuckles_crystal_maiden_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_knuckles_crystal_maiden_aura:GetModifierAura()
    return "modifier_knuckles_crystal_maiden"
end

function modifier_knuckles_crystal_maiden_aura:GetAuraRadius()
    return 750
end

modifier_knuckles_crystal_maiden = class({})

function modifier_knuckles_crystal_maiden:IsPurgable() return false end

function modifier_knuckles_crystal_maiden:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_knuckles_crystal_maiden:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_knuckles_crystal_maiden:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_knuckles_crystal_maiden:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_knuckles_crystal_maiden:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_knuckles_crystal_maiden:StatusEffectPriority()
    return 1000
end

function modifier_knuckles_crystal_maiden:DeclareFunctions()
    return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        }
end

function modifier_knuckles_crystal_maiden:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

LinkLuaModifier("modifier_Knuckles_GetInTheTank", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

Knuckles_GetInTheTank = class({}) 

function Knuckles_GetInTheTank:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Knuckles_GetInTheTank:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Knuckles_GetInTheTank:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("tank")
    local duration = self:GetSpecialValueFor('duration')  + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_2")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Knuckles_GetInTheTank", {duration = duration})
end

modifier_Knuckles_GetInTheTank = class({}) 

function modifier_Knuckles_GetInTheTank:IsPurgable() return false end

function modifier_Knuckles_GetInTheTank:OnCreated()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerID()
    self:GetParent():SetModelScale(6)
    if IsUnlockedInPassFree(playerID, "free_reward15") then
        self:GetParent():SetMaterialGroup("event")
    end
end

function modifier_Knuckles_GetInTheTank:OnDestroy()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerID()
    self:GetCaster():StopSound("tank")
    self:GetParent():SetModelScale(4)
    if IsUnlockedInPassFree(playerID, "free_reward15") then
        if self:GetParent():GetUnitName() == "npc_dota_hero_winter_wyvern" then
            self:GetParent():SetMaterialGroup("event")
        end
    end
end

function modifier_Knuckles_GetInTheTank:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }

    return decFuncs
end

function modifier_Knuckles_GetInTheTank:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('mv')
end

function modifier_Knuckles_GetInTheTank:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('armor')
end

function modifier_Knuckles_GetInTheTank:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_Knuckles_GetInTheTank:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor('range')
end

function modifier_Knuckles_GetInTheTank:GetModifierModelChange()
    return "models/knuckles_tank.vmdl"
end

function modifier_Knuckles_GetInTheTank:GetModifierProjectileName()
    return "particles/units/heroes/hero_techies/techies_base_attack.vpcf"
end