LinkLuaModifier( "modifier_vape_smoke", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vape_smoke_debuff", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_Vape = class({})

function BigRussianBoss_Vape:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function BigRussianBoss_Vape:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function BigRussianBoss_Vape:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function BigRussianBoss_Vape:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function BigRussianBoss_Vape:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local thinker = CreateModifierThinker(caster, self, "modifier_vape_smoke", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("Hero_Riki.Smoke_Screen")
    local particle = ParticleManager:CreateParticle("particles/boss/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, thinker)
    ParticleManager:SetParticleControl(particle, 0, thinker:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))

    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

modifier_vape_smoke = class({})

function modifier_vape_smoke:IsPurgable() return false end
function modifier_vape_smoke:IsHidden() return true end
function modifier_vape_smoke:IsAura() return true end

function modifier_vape_smoke:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_vape_smoke:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_vape_smoke:GetModifierAura()
    return "modifier_vape_smoke_debuff"
end

function modifier_vape_smoke:GetAuraRadius()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    return radius
end

modifier_vape_smoke_debuff = class({})

function modifier_vape_smoke_debuff:IsPurgable() return false end
function modifier_vape_smoke_debuff:IsDebuff() return true end

function modifier_vape_smoke_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_vape_smoke_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW 
end

function modifier_vape_smoke_debuff:CheckState()
    local state = { [MODIFIER_STATE_SILENCED] = true}
    return state
end

function modifier_vape_smoke_debuff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
    return funcs
end

function modifier_vape_smoke_debuff:GetModifierMiss_Percentage()
    local miss_chance = self:GetAbility():GetSpecialValueFor("miss_chance")
    return miss_chance
end

function modifier_vape_smoke_debuff:GetModifierMoveSpeedBonus_Percentage()
    local slow = self:GetAbility():GetSpecialValueFor("move_slow")
    return slow
end

LinkLuaModifier( "modifier_bigrussianboss_prank", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_prank = class({})

function BigRussianBoss_prank:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function BigRussianBoss_prank:GetAOERadius()
    return 200
end

function BigRussianBoss_prank:GetAbilityTextureName()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_bigrussianboss_prank") then
        return "BigRussianBoss/PrankOnPempThrow"
    end
    return self.BaseClass.GetAbilityTextureName(self)
end

function BigRussianBoss_prank:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function BigRussianBoss_prank:GetManaCost(level)
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_bigrussianboss_prank") then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end


function BigRussianBoss_prank:GetCastTime()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_bigrussianboss_prank") then
        return self.BaseClass.GetCastTime(self)
    end
    return 0
end

function BigRussianBoss_prank:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_bigrussianboss_prank") then
        return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function BigRussianBoss_prank:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_bigrussianboss_prank") then
        local target = self:GetCursorTarget()
        local max_brew = self:GetSpecialValueFor( "brew_time" )
        local brew_time

        local modifier = caster:FindModifierByName( "modifier_bigrussianboss_prank" )
        if modifier then
            brew_time = math.min( GameRules:GetGameTime()-modifier:GetCreationTime(), max_brew )
            modifier:Destroy()
        elseif self.reflected_brew_time then
            brew_time = self.reflected_brew_time
        elseif self.stored_brew_time then
            brew_time = self.stored_brew_time
        else
            brew_time = 0
        end

        self.brew_time = brew_time

        local info = {
            Target = target,
            Source = caster,
            Ability = self, 
            EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
            iMoveSpeed = 900,
            bDodgeable = false,
            bVisibleToEnemies = true, 
            bProvidesVision = true,
            iVisionRadius = 300,
            iVisionTeamNumber = caster:GetTeamNumber(),
            ExtraData = { brew_time = brew_time, }
        }
        ProjectileManager:CreateTrackingProjectile(info)

        caster:EmitSound("Hero_Alchemist.UnstableConcoction.Throw")
        return
    end
    if caster:GetUnitName() == "npc_dota_hero_alchemist" then
        caster:AddNewModifier( caster, self, "modifier_bigrussianboss_prank", { duration = 5.5 } )
        self:EndCooldown()
    end
end

function BigRussianBoss_prank:OnProjectileHit_ExtraData( target, location, ExtraData )
    if not IsServer() then return end
    if not target then return end
    local brew_time = ExtraData.brew_time
    self.reflected_brew_time = brew_time
    self.reflected_brew_time = nil
    local max_brew = self:GetSpecialValueFor( "brew_time" )
    local min_stun = self:GetSpecialValueFor( "min_stun" )
    local max_stun = self:GetSpecialValueFor( "max_stun" )
    local min_damage = self:GetSpecialValueFor( "min_damage" )
    local max_damage = self:GetSpecialValueFor( "max_damage" )
    local radius = self:GetSpecialValueFor( "radius" )

    local stun = (brew_time/max_brew)*(max_stun-min_stun) + min_stun
    local damage = (brew_time/max_brew)*(max_damage-min_damage) + min_damage
    if target:TriggerSpellAbsorb(self) then return end
    local damageTable = {
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self,
    }

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        target:GetOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
        0,
        false
    )

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage( damageTable )
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun})
    end

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("bossstun")
end

modifier_bigrussianboss_prank = class({})

function modifier_bigrussianboss_prank:IsPurgable()
    return false
end

function modifier_bigrussianboss_prank:IsHidden()
    return true
end

function modifier_bigrussianboss_prank:OnCreated(kv)
    self.max_stun = self:GetAbility():GetSpecialValueFor( "max_stun" )
    self.max_damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

    if not IsServer() then return end
    self.tick_interval = 0.5
    self.tick = kv.duration
    self.tick_halfway = true
    self:StartIntervalThink( self.tick_interval )
    self:GetParent():EmitSound("bossprank")
end

function modifier_bigrussianboss_prank:OnIntervalThink()
    self.tick = self.tick - self.tick_interval
    if self.tick>0 then
        self.tick_halfway = not self.tick_halfway
        self:PlayEffects2()
        return
    end

    local damageTable = {
        attacker = self:GetCaster(),
        damage = self.max_damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
        0,
        false
    )

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage( damageTable )
        enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self.max_stun } )
    end

    if not self:GetParent():IsInvulnerable() then
        damageTable.victim = self:GetParent()
        if not self:GetParent():IsMagicImmune() then
            ApplyDamage( damageTable )
            self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self.max_stun } )
        end
    end

    self:PlayEffects1( self:GetParent() )
    self:GetAbility():UseResources(false, false, true)
    self:Destroy()
end

function modifier_bigrussianboss_prank:PlayEffects1( target )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        0,
        target,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0),
        true
    )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("BossStun")
end

function modifier_bigrussianboss_prank:PlayEffects2()
    local time = math.floor( self.tick )
    local mid = 1
    if self.tick_halfway then mid = 8 end

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )

    if time<1 then
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
    end

    ParticleManager:ReleaseParticleIndex( effect_cast )
end

LinkLuaModifier( "modifier_steb_passive", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_steb_debuff", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_steb_buff", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_Steb = class({})

modifier_steb_passive = class({})

function BigRussianBoss_Steb:GetIntrinsicModifierName()
    return "modifier_steb_passive"
end

function modifier_steb_passive:IsHidden()
    return true
end

function modifier_steb_passive:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return decFuncs
end

function modifier_steb_passive:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if target:IsOther() then
            return nil
        end
        if self:GetParent():PassivesDisabled() then return end
        parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_steb_buff", { duration = duration } )
        target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_steb_debuff", { duration = duration } )
    end
end

modifier_steb_buff = class({})

function modifier_steb_buff:IsPurgable()
    return true
end

function modifier_steb_buff:OnCreated()
    self.move = self:GetAbility():GetSpecialValueFor("move_up")
    self.attack = self:GetAbility():GetSpecialValueFor("attack_up")
end

function modifier_steb_buff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return decFuncs
end

function modifier_steb_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end

function modifier_steb_buff:GetModifierAttackSpeedBonus_Constant()
    return self.attack
end

function modifier_steb_buff:GetEffectName()
    return "particles/boss/steb.vpcf"
end

function modifier_steb_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

modifier_steb_debuff = class({})

function modifier_steb_debuff:IsDebuff()
    return true
end

function modifier_steb_debuff:IsPurgable()
    return true
end

function modifier_steb_debuff:OnCreated()
    self.move = self:GetAbility():GetSpecialValueFor("move_slow")
    self.attack = self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_steb_debuff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return decFuncs
end

function modifier_steb_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end

function modifier_steb_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.attack
end

LinkLuaModifier( "modifier_brb_test", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_brb_test_damage", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_test_damage", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_test = class({})

function BigRussianBoss_test:CastFilterResultTarget(target)
    if target:HasModifier("modifier_pistoletov_deathfight") then
        return UF_FAIL_CUSTOM
    end
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end 

function BigRussianBoss_test:GetCustomCastErrorTarget(target)
    if target:HasModifier("modifier_pistoletov_deathfight") then
        return "#dota_hud_error_cant_cast_on_other"
    end
end

function BigRussianBoss_test:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function BigRussianBoss_test:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function BigRussianBoss_test:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function BigRussianBoss_test:OnSpellStart()
    if not IsServer() then return end
    self.target = self:GetCursorTarget()
    self.caster = self:GetCaster()
    local target_origin = self.target:GetAbsOrigin()
    local caster_origin = self.caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    if self.target:TriggerSpellAbsorb( self ) then return end
    if self.target:IsIllusion() then
        self.target:Kill( self:GetAbility(), self:GetCaster() )
    end
    self.caster:EmitSound("legend")
    if self:GetCaster().particle then
        ParticleManager:DestroyParticle(self:GetCaster().particle, false)
    end
    self:GetCaster().particle = ParticleManager:CreateParticle("particles/boss/test.vpcf", PATTACH_ABSORIGIN, self.caster)
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
    self.caster:AddNewModifier( self:GetCaster(), self, "modifier_brb_test", { duration = duration } )
    self.target:AddNewModifier( self:GetCaster(), self, "modifier_brb_test", { duration = duration } )
    self.caster:AddNewModifier( self:GetCaster(), self, "modifier_brb_test_damage", { duration = duration } )
    self.target:AddNewModifier( self:GetCaster(), self, "modifier_brb_test_damage", { duration = duration } )
end

modifier_brb_test = class({})

function modifier_brb_test:IsPurgable()
    return false
end

function modifier_brb_test:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        if caster:GetUnitName() == "npc_dota_hero_alchemist" then
            caster:StartGesture(ACT_DOTA_ALCHEMIST_CHEMICAL_RAGE_START)
        end
        self:GetAbility().target:SetForceAttackTarget(self:GetCaster())
        self:GetCaster():SetForceAttackTarget(self:GetAbility().target)
    end
end

function modifier_brb_test:GetActivityTranslationModifiers()
    return "chemical_rage"
end

function modifier_brb_test:GetAttackSound()
    return "Hero_Alchemist.ChemicalRage.Attack"
end

function modifier_brb_test:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_brb_test:OnDeath( params )
    local damage = self:GetAbility():GetSpecialValueFor("reward_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_1")
    if params.unit == self:GetParent() then
        if params.unit == self:GetCaster() then
            if not self:GetAbility().target:HasModifier("modifier_test_damage") then
                self:GetAbility().target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_test_damage", {} )
            end
            local duel_stacks = self:GetAbility().target:GetModifierStackCount("modifier_test_damage", self:GetAbility()) + damage
            self:GetAbility().target:SetModifierStackCount("modifier_test_damage", self:GetAbility(), duel_stacks)
            self:GetAbility().target:RemoveModifierByName("modifier_brb_test_damage")
            self:GetAbility().target:RemoveModifierByName("modifier_brb_test")
            self:GetAbility().target:EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetAbility().target)
        else
            if not self:GetCaster():HasModifier("modifier_test_damage") then
                self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_test_damage", {} )
            end
            local duel_stacks = self:GetCaster():GetModifierStackCount("modifier_test_damage", self:GetAbility()) + damage
            self:GetCaster():SetModifierStackCount("modifier_test_damage", self:GetAbility(), duel_stacks)
            self:GetCaster():RemoveModifierByName("modifier_brb_test_damage")
            self:GetCaster():RemoveModifierByName("modifier_brb_test")
            self:GetCaster():EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
        end
    end
end

function modifier_brb_test:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("legend")   
    
    if self:GetCaster().particle ~= nil then
        ParticleManager:DestroyParticle(self:GetCaster().particle, false)
    end

    self:GetAbility().target:SetForceAttackTarget(nil)
    self:GetCaster():SetForceAttackTarget(nil)
end

function modifier_brb_test:CheckState()
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

function modifier_brb_test:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,

    }

    return decFuncs
end

function modifier_brb_test:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_brb_test:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_brb_test:GetModifierIncomingDamage_Percentage()
    return self.damage
end

function modifier_brb_test:GetDisableHealing()
    return 1
end

modifier_test_damage = class({})

function modifier_test_damage:IsPurgable()
    return false
end

function modifier_test_damage:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_test_damage:IsDebuff()
    return false
end

function modifier_test_damage:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

    }

    return decFuncs
end

function modifier_test_damage:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

modifier_brb_test_damage = class({})

function modifier_brb_test_damage:IsHidden()
    return true
end

function modifier_brb_test_damage:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_brb_test_damage:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return decFuncs
end

function modifier_brb_test_damage:GetModifierIncomingDamage_Percentage()
    return self.damage
end




