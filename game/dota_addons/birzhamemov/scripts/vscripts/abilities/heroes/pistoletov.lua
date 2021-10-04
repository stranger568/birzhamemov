LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Pistoletov_dolphin_count", "abilities/heroes/pistoletov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Pistoletov_dolphin", "abilities/heroes/pistoletov", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Pistoletov_dolphin = class({}) 

function Pistoletov_dolphin:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pistoletov_dolphin:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Pistoletov_dolphin:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Pistoletov_dolphin:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier( caster, self, "modifier_Pistoletov_dolphin", {} )
    caster:EmitSound("PistoletovDolphin")
end

modifier_Pistoletov_dolphin_count = class({})

function modifier_Pistoletov_dolphin_count:IsHidden()
    return false
end

function modifier_Pistoletov_dolphin_count:IsPurgable()
    return false
end

function modifier_Pistoletov_dolphin_count:DestroyOnExpire()
    return false
end

modifier_Pistoletov_dolphin = class({})

function modifier_Pistoletov_dolphin:IsHidden()
    return true
end

function modifier_Pistoletov_dolphin:IsPurgable()
    return false
end

function modifier_Pistoletov_dolphin:OnCreated( kv )
    if IsServer() then
        self.distance = 500
        self.speed = 1600
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
            self:Destroy()
        end
        if self:ApplyHorizontalMotionController() == false then 
            self:Destroy()
        end
    end
end

function modifier_Pistoletov_dolphin:OnDestroy( kv )
    if IsServer() then
        self:GetAbility():SetActivated( true )
        self:GetParent():InterruptMotionControllers( true )
        local damage = self:GetAbility():GetSpecialValueFor( "damage" )
        local radius = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_pistoletov_3")
        local duration = self:GetAbility():GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_pistoletov_1")
        local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
        local particle_1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_slardar/slardar_crush.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( particle_1, 0, self:GetParent():GetOrigin() )
        ParticleManager:SetParticleControl( particle_1, 1, Vector(radius, radius, radius) )
        ParticleManager:ReleaseParticleIndex( particle_1 )
        local particle_2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( particle_2, 0, self:GetParent():GetOrigin() )
        ParticleManager:SetParticleControl( particle_2, 1, Vector(radius, radius, radius) )
        ParticleManager:ReleaseParticleIndex( particle_2 )
        for i = 1, 2 do
            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
            ParticleManager:ReleaseParticleIndex( particle )
        end
        self:GetParent():EmitSound("Ability.Torrent")
        for _,unit in pairs(targets) do
            ApplyDamage({victim = unit, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
            unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration})
        end
    end
end

function modifier_Pistoletov_dolphin:SyncTime( iDir, dt )
    if self.motionTick[1]==self.motionTick[2] then
        self.motionTick[0] = self.motionTick[0] + 1
        self.elapsedTime = self.elapsedTime + dt
    end
    self.motionTick[iDir] = self.motionTick[0]
    if self.elapsedTime > self.duration and self.motionTick[1]==self.motionTick[2] then
        self:Destroy()
    end
end

function modifier_Pistoletov_dolphin:UpdateHorizontalMotion( me, dt )
    self:SyncTime(1, dt)
    local parent = self:GetParent()
    local target = self.direction*self.hVelocity*self.elapsedTime
    parent:SetOrigin( self.origin + target )
end

function modifier_Pistoletov_dolphin:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

function modifier_Pistoletov_dolphin:UpdateVerticalMotion( me, dt )
    self:SyncTime(2, dt)
    local parent = self:GetParent()
    local target = self.vVelocity*self.elapsedTime + 0.5*self.gravity*self.elapsedTime*self.elapsedTime
    parent:SetOrigin( Vector( parent:GetOrigin().x, parent:GetOrigin().y, self.origin.z+target ) )
end

function modifier_Pistoletov_dolphin:OnVerticalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_pistoletov_deathfight", "abilities/heroes/pistoletov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_deathfight_atribute", "abilities/heroes/pistoletov.lua", LUA_MODIFIER_MOTION_NONE )

Pistoletov_DeathFight = class({})

function Pistoletov_DeathFight:CastFilterResultTarget(target)
    if target:HasModifier("modifier_brb_test") then
        return UF_FAIL_CUSTOM
    end
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end 

function Pistoletov_DeathFight:GetCustomCastErrorTarget(target)
    if target:HasModifier("modifier_brb_test") then
        return "#dota_hud_error_cant_cast_on_other"
    end
end

function Pistoletov_DeathFight:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pistoletov_DeathFight:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Pistoletov_DeathFight:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Pistoletov_DeathFight:OnSpellStart()
    if not IsServer() then return end
    self.target = self:GetCursorTarget()
    self.caster = self:GetCaster()
    local target_origin = self.target:GetAbsOrigin()
    local caster_origin = self.caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_pistoletov_5")
    if self.target:TriggerSpellAbsorb( self ) then return end
    if self.target:IsIllusion() then
        self.target:Kill( self:GetAbility(), self:GetCaster() )
    end
    self.caster:EmitSound("PistoletovDeathfight")
    if self:GetCaster().particle then
        ParticleManager:DestroyParticle(self:GetCaster().particle, false)
    end
    self:GetCaster().particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_start_ring_arcana.vpcf", PATTACH_ABSORIGIN, self.caster)
    local center_point = target_origin + ((caster_origin - target_origin) / 1)
    ParticleManager:SetParticleControl(self:GetCaster().particle, 0, center_point)
    ParticleManager:SetParticleControl(self:GetCaster().particle, 7, center_point)
    self.order_target = 
    {
        UnitIndex = self.target:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        TargetIndex = self.caster:entindex()
    }
    self.order_caster =
    {
        UnitIndex = self.caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(self.order_target)
    ExecuteOrderFromTable(self.order_caster)
    self.caster:MoveToTargetToAttack(self.target)
    self.target:MoveToTargetToAttack(self.caster)
    self.caster:AddNewModifier( self:GetCaster(), self, "modifier_pistoletov_deathfight", { duration = duration } )
    self.target:AddNewModifier( self:GetCaster(), self, "modifier_pistoletov_deathfight", { duration = duration } )
end

modifier_pistoletov_deathfight = class({})

function modifier_pistoletov_deathfight:IsPurgable()
    return false
end

function modifier_pistoletov_deathfight:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_pistoletov_deathfight:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        self:GetAbility().target:SetForceAttackTarget(self:GetCaster())
        self:GetCaster():SetForceAttackTarget(self:GetAbility().target)
    end
end

function modifier_pistoletov_deathfight:OnDeath( params )
    local attribute = self:GetAbility():GetSpecialValueFor("atribute")
    if params.unit == self:GetParent() then
        if params.unit == self:GetCaster() then
            if not self:GetAbility().target:HasModifier("modifier_deathfight_atribute") then
                self:GetAbility().target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_deathfight_atribute", {} )
            end
            local duel_stacks = self:GetAbility().target:GetModifierStackCount("modifier_deathfight_atribute", self:GetAbility()) + attribute
            self:GetAbility().target:SetModifierStackCount("modifier_deathfight_atribute", self:GetAbility(), duel_stacks)
            self:GetAbility().target:RemoveModifierByName("modifier_pistoletov_deathfight")
            self:GetAbility().target:EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetAbility().target)
        else
            if not self:GetCaster():HasModifier("modifier_deathfight_atribute") then
                self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_deathfight_atribute", {} )
            end
            local duel_stacks = self:GetCaster():GetModifierStackCount("modifier_deathfight_atribute", self:GetAbility()) + attribute
            self:GetCaster():SetModifierStackCount("modifier_deathfight_atribute", self:GetAbility(), duel_stacks)
            self:GetCaster():RemoveModifierByName("modifier_pistoletov_deathfight")
            self:GetCaster():EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
        end
    end
end

function modifier_pistoletov_deathfight:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("PistoletovDeathfight")  
    
    if self:GetCaster().particle ~= nil then
        ParticleManager:DestroyParticle(self:GetCaster().particle, false)
    end

    self:GetAbility().target:SetForceAttackTarget(nil)
    self:GetCaster():SetForceAttackTarget(nil)
end

function modifier_pistoletov_deathfight:CheckState()
local state =
    {[MODIFIER_STATE_SILENCED] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_MUTED] = true,
    [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
[MODIFIER_STATE_INVISIBLE] = false,
[MODIFIER_STATE_TAUNTED] = true,}
    return state
end

function modifier_pistoletov_deathfight:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return decFuncs
end

function modifier_pistoletov_deathfight:GetModifierPhysicalArmorBonus()
    if self:GetParent() ~= self:GetCaster() then return end
    if self:GetCaster():HasTalent("special_bonus_birzha_pistoletov_4") then return 40 end
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_pistoletov_deathfight:GetModifierBonusStats_Strength()
    if self:GetParent() ~= self:GetCaster() then return end
    if self:GetCaster():HasTalent("special_bonus_birzha_pistoletov_4") then return 30 end
    return self:GetAbility():GetSpecialValueFor("strength")
end

modifier_deathfight_atribute = class({})

function modifier_deathfight_atribute:IsPurgable()
    return false
end

function modifier_deathfight_atribute:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_deathfight_atribute:IsDebuff()
    return false
end

function modifier_deathfight_atribute:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return decFuncs
end

function modifier_deathfight_atribute:GetModifierBonusStats_Agility()
    return self:GetStackCount()
end

function modifier_deathfight_atribute:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end

LinkLuaModifier("modifier_pistoletov_TrahTibidoh", "abilities/heroes/pistoletov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistoletov_TrahTibidoh_armor", "abilities/heroes/pistoletov", LUA_MODIFIER_MOTION_NONE )

Pistoletov_TrahTibidoh = class({}) 

function Pistoletov_TrahTibidoh:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pistoletov_TrahTibidoh:GetIntrinsicModifierName()
    return "modifier_pistoletov_TrahTibidoh"
end

modifier_pistoletov_TrahTibidoh = class({}) 

function modifier_pistoletov_TrahTibidoh:IsPurgable()
    return false
end

function modifier_pistoletov_TrahTibidoh:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_pistoletov_TrahTibidoh:OnAttackLanded( keys )
    local chance = self:GetAbility():GetSpecialValueFor("chance")
    local persentage = self:GetAbility():GetSpecialValueFor("healpersentage") + self:GetCaster():FindTalentValue("special_bonus_birzha_pistoletov_2")
    local healbasic = self:GetAbility():GetSpecialValueFor("heal")
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local heal = self:GetParent():GetMaxHealth() / 100 * persentage
    local fullheal = healbasic + heal
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if self:GetAbility():IsFullyCastable() then
            if RandomInt(1, 100) <= chance then
                if not self:GetParent():IsAlive() then return end
                self:GetParent():EmitSound("PistoletovTrah")
                self:GetAbility():UseResources(false,false,true)
                self:GetParent():Heal(fullheal, self:GetAbility())
                self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_pistoletov_TrahTibidoh_armor", { duration = duration } )
                self:IncrementStackCount()
            end
        end
    end
end

function modifier_pistoletov_TrahTibidoh:GetModifierPhysicalArmorBonus()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_pistoletov_TrahTibidoh:RemoveStack()
    self:DecrementStackCount()
end

modifier_pistoletov_TrahTibidoh_armor = class({})

function modifier_pistoletov_TrahTibidoh_armor:IsHidden()
    return true
end

function modifier_pistoletov_TrahTibidoh_armor:IsPurgable()
    return false
end

function modifier_pistoletov_TrahTibidoh_armor:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_pistoletov_TrahTibidoh_armor:OnDestroy()
    if not IsServer() then return end
    local modifier = self:GetParent():FindModifierByName( "modifier_pistoletov_TrahTibidoh" )
    modifier:RemoveStack()
end

LinkLuaModifier( "modifier_Pistoletov_NewPirat_boat", "abilities/heroes/pistoletov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Boat_damage_debuff", "abilities/heroes/pistoletov.lua", LUA_MODIFIER_MOTION_NONE )

Pistoletov_NewPirat = class({})

function Pistoletov_NewPirat:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pistoletov_NewPirat:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Pistoletov_NewPirat:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Pistoletov_NewPirat:GetAOERadius()
    return 600
end

function Pistoletov_NewPirat:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("PistoletovPirat")
    GridNav:DestroyTreesAroundPoint(point, 600, false)
    self.boat = CreateUnitByName("npc_boat_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.boat:SetOwner(caster)
    FindClearSpaceForUnit(self.boat, self.boat:GetAbsOrigin(), true)
    self.boat:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    self.boat:AddNewModifier(self:GetCaster(), self, "modifier_Pistoletov_NewPirat_boat", {})
end

function Pistoletov_NewPirat:OnProjectileHit( target, location )
    if not target then return end
    self.split_shot_attack = true
    self.boat:PerformAttack( target, true, true, true, false, false, false, false )
    self.split_shot_attack = false
end

modifier_Pistoletov_NewPirat_boat = class({})

function modifier_Pistoletov_NewPirat_boat:IsHidden()
    return true
end

function modifier_Pistoletov_NewPirat_boat:IsPurgable()
    return false
end

function modifier_Pistoletov_NewPirat_boat:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_Pistoletov_NewPirat_boat:OnCreated( kv )
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_Pistoletov_NewPirat_boat:OnIntervalThink()
    if not IsServer() then return end
    local targets = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    for _,target in pairs(targets) do
        local projectile_info = 
        {
            EffectName = "particles/units/heroes/hero_morphling/morphling_base_attack.vpcf",
            Ability = self:GetAbility(),
            vSpawnOrigin = self:GetParent():GetAbsOrigin(),
            Target = target,
            Source = self:GetParent(),
            bHasFrontalCone = false,
            iMoveSpeed = 500,
            bReplaceExisting = false,
            bProvidesVision = false
        }
        ProjectileManager:CreateTrackingProjectile(projectile_info)
    end
end

function modifier_Pistoletov_NewPirat_boat:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
    return state
end

function modifier_Pistoletov_NewPirat_boat:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }
    return funcs
end

function modifier_Pistoletov_NewPirat_boat:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    local stack = 0
    local modifier = params.target:FindModifierByName( "modifier_Boat_damage_debuff" )
    if modifier==nil then
        if not self:GetParent():PassivesDisabled() then
            if params.target:IsBoss() then return end
            params.target:AddNewModifier(
                self:GetParent(),
                self:GetAbility(),
                "modifier_Boat_damage_debuff",
                { duration = 30 }
            )
            stack = 1
        end
    else
        modifier:IncrementStackCount()
        modifier:ForceRefresh()
        stack = modifier:GetStackCount()
    end
    return stack * self:GetParent():GetAttackDamage() / 100 * 25
end

modifier_Boat_damage_debuff = class({})

function modifier_Boat_damage_debuff:IsHidden()
    return true
end

function modifier_Boat_damage_debuff:IsPurgable()
    return false
end

function Spawn( entityKeyValues )
    if not IsServer() then
        return
    end
    if thisEntity == nil then
        return
    end

    thisEntity:SetContextThink( "BoatThink", BoatThink, 0.5 )
end

function BoatThink()
    if ( not thisEntity:IsAlive() ) then
        return -1 
    end
  
    if GameRules:IsGamePaused() == true then
        return 1 
    end


    local OWNER = thisEntity:GetOwner()
    local Owner_location = OWNER:GetAbsOrigin()
    local order = 
    {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
        TargetIndex = OWNER:entindex()
    }   
    ExecuteOrderFromTable(order)
    return 1  
end



