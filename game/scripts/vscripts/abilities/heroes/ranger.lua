LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ranger_NailGun_buff" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_NONE)

Ranger_NailGun = class({}) 

function Ranger_NailGun:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ranger_NailGun:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ranger_NailGun:GetCastRange(location, target)
    return self:GetSpecialValueFor('radius')
end

function Ranger_NailGun:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration') + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_4")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Ranger_NailGun_buff", {duration = duration})
end

modifier_Ranger_NailGun_buff = class({}) 

function modifier_Ranger_NailGun_buff:IsPurgable() return false end

function modifier_Ranger_NailGun_buff:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor('interval')
    self:StartIntervalThink(interval)
end

function modifier_Ranger_NailGun_buff:OnIntervalThink()
    if not IsServer() then return end

    local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack2"))

    local target = enemies[1]

    local info = 
    {
        EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        vSpawnOrigin = point
    }

    if target == nil then return end

    ProjectileManager:CreateTrackingProjectile( info )

    self:GetParent():EmitSound("rangerone")
end

function Ranger_NailGun:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) then

        local multi = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_2")

        local damage_type = DAMAGE_TYPE_PHYSICAL

        if self:GetCaster():HasTalent("special_bonus_birzha_ranger_8") then
            damage_type = DAMAGE_TYPE_PURE
        end

        local damage = 
        {
            victim = target,
            attacker = self:GetCaster(),
            damage = self:GetCaster():GetAttackDamage() / 100 * multi,
            damage_type = damage_type,
            ability = self
        }

        ApplyDamage( damage )

        if self:GetCaster():HasShard() then
            target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = self:GetSpecialValueFor("shard_stun_duration") * (1-target:GetStatusResistance()) } )
        end
    end
    return true
end

LinkLuaModifier( "modifier_Ranger_GrenadeLauncher_debuff" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_Ranger_GrenadeLauncher_armor_debuff" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_NONE)

Ranger_GrenadeLauncher = class({})

function Ranger_GrenadeLauncher:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ranger_GrenadeLauncher:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ranger_GrenadeLauncher:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ranger_GrenadeLauncher:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Ranger_GrenadeLauncher:OnSpellStart()
    if not IsServer() then return end

    local point = self:GetCursorPosition()

    local caster_loc = self:GetCaster():GetAbsOrigin()

    local cast_direction = (point - self:GetCaster():GetOrigin()):Normalized()

    if point == caster_loc then
        cast_direction = self:GetCaster():GetForwardVector()
    else
        cast_direction = (point - caster_loc):Normalized()
    end

    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack2"))

    local info = 
    {
        Source = self:GetCaster(),
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        bDeleteOnHit = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/units/heroes/hero_gob_squad/rocket_blast.vpcf",
        fDistance = 3000,
        fStartRadius = 100,
        fEndRadius =150,
        vVelocity = cast_direction * 2500,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = true,
        iVisionRadius = 400,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        vSpawnOrigin    = point
    }

    self:GetCaster():EmitSound("rangerrocket")

    ProjectileManager:CreateLinearProjectile(info)
end

function Ranger_GrenadeLauncher:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local multi = self:GetSpecialValueFor("damage")
        local base_dmg = self:GetSpecialValueFor("base_damage")
        local radius = self:GetSpecialValueFor("radius")
        local duration = self:GetSpecialValueFor("duration")

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gob_squad/rocket_blast_explosion.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()+Vector(0,0,75))
        ParticleManager:SetParticleControl(particle, 1, Vector(300,0,0))

        target:EmitSound("rangerlauncher")

        AddFOWViewer( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), 300, 1, false )

        local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

        for i,unit in ipairs(units) do
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = (self:GetCaster():GetAttackDamage() / 100 * multi) + base_dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self })
            unit:AddNewModifier( self:GetCaster(), self, "modifier_Ranger_GrenadeLauncher_debuff", { duration = duration * (1-unit:GetStatusResistance()) } )
            if self:GetCaster():HasTalent("special_bonus_birzha_ranger_5") then
                unit:AddNewModifier( self:GetCaster(), self, "modifier_Ranger_GrenadeLauncher_armor_debuff", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_5", "value2") * (1-unit:GetStatusResistance()) } )
            end
        end
    end
    return true
end

modifier_Ranger_GrenadeLauncher_debuff = class({}) 

function modifier_Ranger_GrenadeLauncher_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ranger_GrenadeLauncher_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow") 
end


modifier_Ranger_GrenadeLauncher_armor_debuff = class({}) 

function modifier_Ranger_GrenadeLauncher_armor_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_Ranger_GrenadeLauncher_armor_debuff:GetModifierPhysicalArmorBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_5")
end

LinkLuaModifier( "modifier_Ranger_ShotGun_buff" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_NONE)

Ranger_ShotGun = class({}) 

function Ranger_ShotGun:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ranger_ShotGun:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ranger_ShotGun:GetCastRange(location, target)
    return self:GetSpecialValueFor('radius')
end

function Ranger_ShotGun:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Ranger_ShotGun_buff", {})
    self:GetCaster():EmitSound("rangerflak")
end

function Ranger_ShotGun:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local damage = self:GetSpecialValueFor("base_dmg") + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_6")
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = RandomInt(self:GetCaster():GetDamageMax(), self:GetCaster():GetDamageMin()) + damage, damage_type = DAMAGE_TYPE_PHYSICAL })
    end
    return true
end

modifier_Ranger_ShotGun_buff = class({})
    
function modifier_Ranger_ShotGun_buff:IsPurgable()
    return true
end

function modifier_Ranger_ShotGun_buff:OnCreated()
    if not IsServer() then return end
    local stacks = self:GetAbility():GetSpecialValueFor('max_attacks') + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_1")
    self:SetStackCount(stacks)
end

function modifier_Ranger_ShotGun_buff:OnRefresh()
    if not IsServer() then return end
    local stacks = self:GetAbility():GetSpecialValueFor('max_attacks') + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_1")
    self:SetStackCount(stacks)
end

function modifier_Ranger_ShotGun_buff:GetEffectName()
    return "particles/units/heroes/hero_gyrocopter/gyro_flak_cannon_overhead.vpcf"
end

function modifier_Ranger_ShotGun_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_Ranger_ShotGun_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK,
    }
    return funcs
end

function modifier_Ranger_ShotGun_buff:OnAttack( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end
    self:DecrementStackCount()
    self:GetParent():EmitSound("rangerflak2")
    local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack2"))
    
    for _,unit in pairs(enemies) do
        local info = 
        {
            EffectName = "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",
            Ability = self:GetAbility(),
            iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
            Source = self:GetCaster(),
            Target = unit,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
            vSpawnOrigin = point
        }
        ProjectileManager:CreateTrackingProjectile( info )
    end

    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_Ranger_Jump_shard" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

Ranger_Jump = class({})

function Ranger_Jump:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ranger_Jump:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ranger_Jump:GetIntrinsicModifierName()
    return "modifier_Ranger_Jump_shard"
end

function Ranger_Jump:OnSpellStart()
    if not IsServer() then return end
    local leap_distance = self:GetSpecialValueFor("leap_distance") + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_3")
    local effect_cast = ParticleManager:CreateParticle( "particles/ranger_jump_receive.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    local knockback = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { distance = leap_distance, height = 200, duration = 0.3, direction_x = self:GetCaster():GetForwardVector().x, direction_y = self:GetCaster():GetForwardVector().y, IsStun = false} )
    self:GetCaster():EmitSound("rangerjump")

    local callback = function()
        GridNav:DestroyTreesAroundPoint( self:GetCaster():GetOrigin(), 150, true )
        ParticleManager:DestroyParticle( effect_cast, false )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end

    if self:GetCaster():HasScepter() then
        local modifier_Ranger_Jump_shard = self:GetCaster():FindModifierByName("modifier_Ranger_Jump_shard")
        if modifier_Ranger_Jump_shard then
            modifier_Ranger_Jump_shard:IncrementStackCount()
            if modifier_Ranger_Jump_shard:GetStackCount() >= self:GetSpecialValueFor("scepter_jump") then
                local Ranger_ShotGun = self:GetCaster():FindAbilityByName("Ranger_ShotGun")
                if Ranger_ShotGun and Ranger_ShotGun:GetLevel() > 0 then
                    Ranger_ShotGun:OnSpellStart()
                    modifier_Ranger_Jump_shard:SetStackCount(0)
                end
            end
        end
    end

    knockback:SetEndCallback( callback )
end

modifier_Ranger_Jump_shard = class({})
function modifier_Ranger_Jump_shard:IsPurgable() return false end
function modifier_Ranger_Jump_shard:IsHidden() return self:GetStackCount() == 0 end

LinkLuaModifier( "modifier_ranger_QuadDamage_buff" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_BOTH )

Ranger_QuadDamage = class({})

function Ranger_QuadDamage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ranger_QuadDamage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ranger_QuadDamage:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ranger_QuadDamage_buff", {} )
    self:GetCaster():EmitSound("rangerultimate")
    local particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_cast_v2.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_ranger_QuadDamage_buff = class({}) 

function modifier_ranger_QuadDamage_buff:IsPurgable() return false end

function modifier_ranger_QuadDamage_buff:OnCreated()
    if not IsServer() then return end
    local charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_7")
    self:SetStackCount(charges)
end

function modifier_ranger_QuadDamage_buff:OnRefresh()
    if not IsServer() then return end
    local charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_7")
    self:SetStackCount(charges)
end

function modifier_ranger_QuadDamage_buff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_buff.vpcf"
end

function modifier_ranger_QuadDamage_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ranger_QuadDamage_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_ranger_QuadDamage_buff:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_percentage") 
end

function modifier_ranger_QuadDamage_buff:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end
    self:MinusCharge()
end

function modifier_ranger_QuadDamage_buff:MinusCharge()
    if not IsServer() then return end
    self:DecrementStackCount()
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end