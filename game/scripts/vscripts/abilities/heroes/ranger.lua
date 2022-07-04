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
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Ranger_NailGun_buff", {duration = duration})
end

modifier_Ranger_NailGun_buff = class({}) 

function modifier_Ranger_NailGun_buff:IsPurgable() return false end

function modifier_Ranger_NailGun_buff:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor('interval')
    self:StartIntervalThink(interval)
end

function modifier_Ranger_NailGun_buff:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

function modifier_Ranger_NailGun_buff:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
      self:GetParent():GetAbsOrigin(),
      nil,
      radius,
      DOTA_UNIT_TARGET_TEAM_ENEMY,
      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
      FIND_ANY_ORDER,
      false)

    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack2"))

    self.target = enemies[1]
    local info = {
        EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        Target = self.target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        vSpawnOrigin    = point
    }
    if self.target == nil then return end
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetParent():EmitSound("rangerone")
end

function Ranger_NailGun:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) then
        local multi = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_1")
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = self:GetCaster():GetAttackDamage() / 100 * multi,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self
        }
        if self:GetCaster():HasTalent("special_bonus_birzha_ranger_2") then damage.damage_type = DAMAGE_TYPE_PURE end
        ApplyDamage( damage )
        target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = 0.1 } )
    end
    return true
end

LinkLuaModifier( "modifier_Ranger_GrenadeLauncher_debuff" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_NONE)

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
    local info = {
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
        local multi = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_5")
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
            unit:AddNewModifier( self:GetCaster(), self, "modifier_Ranger_GrenadeLauncher_debuff", { duration = duration } )
        end 
    end
    return true
end

modifier_Ranger_GrenadeLauncher_debuff = class({}) 

function modifier_Ranger_GrenadeLauncher_debuff:IsPurgable() return true end

function modifier_Ranger_GrenadeLauncher_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ranger_GrenadeLauncher_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow") 
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
        local agi_mult = self:GetCaster():GetAgility() * self:GetSpecialValueFor("agi_mult")
        local damage = self:GetSpecialValueFor("base_dmg") + agi_mult
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = self:GetCaster():GetAttackDamage(), damage_type = DAMAGE_TYPE_PHYSICAL })
    end
    return true
end

modifier_Ranger_ShotGun_buff = class({})
    
function modifier_Ranger_ShotGun_buff:IsPurgable()
    return true
end

function modifier_Ranger_ShotGun_buff:OnCreated()
    if not IsServer() then return end
    local stacks = self:GetAbility():GetSpecialValueFor('max_attacks') + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_3")
    self:SetStackCount(stacks)
end

function modifier_Ranger_ShotGun_buff:OnRefresh()
    if not IsServer() then return end
    local stacks = self:GetAbility():GetSpecialValueFor('max_attacks') + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_3")
    self:SetStackCount(stacks)
end

function modifier_Ranger_ShotGun_buff:GetEffectName()
    return "particles/units/heroes/hero_gyrocopter/gyro_flak_cannon_overhead.vpcf"
end

function modifier_Ranger_ShotGun_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_Ranger_ShotGun_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK,
    }

    return funcs
end

function modifier_Ranger_ShotGun_buff:OnAttack( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        self:GetParent():EmitSound("rangerflak2")
        if self:GetStackCount() == 1 then
            self:GetParent():RemoveModifierByName("modifier_Ranger_ShotGun_buff")
        else
            self:SetStackCount(self:GetStackCount() - 1)
        end
        local radius = self:GetAbility():GetSpecialValueFor( "radius" )
        local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
          self:GetParent():GetAbsOrigin(),
          nil,
          radius,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          FIND_ANY_ORDER,
          false)
        local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack2"))
        for _,unit in pairs(enemies) do
            local info = {
                EffectName = "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",
                Ability = self:GetAbility(),
                iMoveSpeed = 1600,
                Source = self:GetCaster(),
                Target = unit,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
                vSpawnOrigin    = point
            }
            ProjectileManager:CreateTrackingProjectile( info )
        end
    end
end

LinkLuaModifier( "modifier_Ranger_Jump" , "abilities/heroes/ranger", LUA_MODIFIER_MOTION_BOTH )

Ranger_Jump = class({})

function Ranger_Jump:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function Ranger_Jump:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ranger_Jump:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Ranger_Jump", {} )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rotate", {} )
    EmitSoundOn( "rangerjump", self:GetCaster() )
end

modifier_Ranger_Jump = class({})

function modifier_Ranger_Jump:IsHidden()
    return true
end

function modifier_Ranger_Jump:IsPurgable()
    return false
end

function modifier_Ranger_Jump:OnCreated( kv )
    if IsServer() then
        self.distance = self:GetAbility():GetSpecialValueFor( "leap_distance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ranger_4")
        self.speed = self:GetAbility():GetSpecialValueFor( "leap_speed" )
        if self:GetCaster():HasTalent("special_bonus_birzha_ranger_4") then
            self.speed = 2000
        end
        self.origin = self:GetParent():GetOrigin()
        self.duration = self.distance/self.speed
        self.hVelocity = self.speed
        self.direction = self:GetParent():GetForwardVector()
        self.peak = 200
        self.elapsedTime = 0
        self.motionTick = {}
        self.motionTick[0] = 0
        self.motionTick[1] = 0
        self.motionTick[2] = 0
        self.gravity = -self.peak/(self.duration*self.duration*0.125)
        self.vVelocity = (-0.5)*self.gravity*self.duration
        self:GetAbility():SetActivated( false )
        if self:ApplyVerticalMotionController() == false then 
            if not self:IsNull() then
                self:Destroy()
            end
        end
        if self:ApplyHorizontalMotionController() == false then 
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_Ranger_Jump:OnDestroy( kv )
    if IsServer() then
        self:GetAbility():SetActivated( true )
        self:GetParent():InterruptMotionControllers( true )
    end
end

function modifier_Ranger_Jump:SyncTime( iDir, dt )
    if self.motionTick[1]==self.motionTick[2] then
        self.motionTick[0] = self.motionTick[0] + 1
        self.elapsedTime = self.elapsedTime + dt
    end
    self.motionTick[iDir] = self.motionTick[0]
    if self.elapsedTime > self.duration and self.motionTick[1]==self.motionTick[2] then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Ranger_Jump:UpdateHorizontalMotion( me, dt )
    self:SyncTime(1, dt)
    local parent = self:GetParent()
    local target = self.direction*self.hVelocity*self.elapsedTime
    parent:SetOrigin( self.origin + target )
end

function modifier_Ranger_Jump:OnHorizontalMotionInterrupted()
    if IsServer() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Ranger_Jump:UpdateVerticalMotion( me, dt )
    self:SyncTime(2, dt)
    local parent = self:GetParent()
    local target = self.vVelocity*self.elapsedTime + 0.5*self.gravity*self.elapsedTime*self.elapsedTime
    parent:SetOrigin( Vector( parent:GetOrigin().x, parent:GetOrigin().y, self.origin.z+target ) )
end

function modifier_Ranger_Jump:OnVerticalMotionInterrupted()
    if IsServer() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

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
    EmitSoundOn( "rangerultimate", self:GetCaster() )
    local particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
end

modifier_ranger_QuadDamage_buff = class({}) 

function modifier_ranger_QuadDamage_buff:IsPurgable() return false end

function modifier_ranger_QuadDamage_buff:OnCreated()
    if not IsServer() then return end
    self.talent = false
    if self:GetCaster():HasTalent("special_bonus_birzha_ranger_6") then
        self.talent = true
        self:SetStackCount(2)
    else
        self:SetStackCount(1)
    end
end

function modifier_ranger_QuadDamage_buff:OnRefresh()
    if not IsServer() then return end
    self.talent = false
    if self:GetCaster():HasTalent("special_bonus_birzha_ranger_6") then
        self.talent = true
        self:SetStackCount(2)
    else
        self:SetStackCount(1)
    end
end

function modifier_ranger_QuadDamage_buff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_buff.vpcf"
end

function modifier_ranger_QuadDamage_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ranger_QuadDamage_buff:DeclareFunctions()
    local funcs = {
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
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetStackCount() <= 1 then
            if not self:IsNull() then
                self:Destroy()
            end
        else
            self:SetStackCount(self:GetStackCount() - 1)
        end    
    end
end