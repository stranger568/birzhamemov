LinkLuaModifier( "modifier_vape_smoke", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vape_smoke_debuff", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_Vape = class({})

function BigRussianBoss_Vape:Precache(context)
    PrecacheResource("particle", "particles/boss/riki_smokebomb.vpcf", context)
    PrecacheResource("particle", "particles/generic_gameplay/generic_silenced.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", context)
    PrecacheResource("particle", "particles/boss/steb.vpcf", context)
    PrecacheResource("particle", "particles/boss/test.vpcf", context)
    PrecacheResource("particle", "particles/items_fx/black_king_bar_avatar.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_avatar.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf", context)
    PrecacheResource("particle", "particles/brb_spice_effect.vpcf", context)
end

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
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local thinker = CreateModifierThinker(caster, self, "modifier_vape_smoke", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    thinker:EmitSound("Hero_Riki.Smoke_Screen")
    thinker:EmitSound("brb_vaper")
end

modifier_vape_smoke = class({})

function modifier_vape_smoke:IsPurgable() return false end
function modifier_vape_smoke:IsHidden() return true end
function modifier_vape_smoke:IsAura() return true end

function modifier_vape_smoke:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.particle = ParticleManager:CreateParticle("particles/boss/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_vape_smoke:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_vape_smoke:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_vape_smoke:GetModifierAura()
    return "modifier_vape_smoke_debuff"
end

function modifier_vape_smoke:GetAuraRadius()
    return self.radius
end

function modifier_vape_smoke:GetAuraDuration() return 0 end

modifier_vape_smoke_debuff = class({})

function modifier_vape_smoke_debuff:IsPurgable() return false end
function modifier_vape_smoke_debuff:IsDebuff() return true end

function modifier_vape_smoke_debuff:OnCreated()
    self.miss_chance = self:GetAbility():GetSpecialValueFor("miss_chance")
    self.slow = self:GetAbility():GetSpecialValueFor("move_slow")
end

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
    return self.miss_chance
end

function modifier_vape_smoke_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

LinkLuaModifier( "modifier_bigrussianboss_prank", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_prank = class({})

function BigRussianBoss_prank:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function BigRussianBoss_prank:GetAOERadius()
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_5")
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
        local max_brew = self:GetSpecialValueFor( "brew_time" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_6")
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
            iMoveSpeed = 900 + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_2"),
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
        caster:AddNewModifier( caster, self, "modifier_bigrussianboss_prank", { duration = 5.5 + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_6") } )
        self:EndCooldown()
    end
end

function BigRussianBoss_prank:OnProjectileHit_ExtraData( target, location, ExtraData )
    if not IsServer() then return end
    if not target then return end
    local brew_time = ExtraData.brew_time
    self.reflected_brew_time = brew_time
    self.reflected_brew_time = nil
    local max_brew = self:GetSpecialValueFor( "brew_time" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_6")
    local min_stun = self:GetSpecialValueFor( "min_stun" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_7")
    local max_stun = self:GetSpecialValueFor( "max_stun" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_7")
    local min_damage = self:GetSpecialValueFor( "min_damage" )
    local max_damage = self:GetSpecialValueFor( "max_damage" )
    local radius = self:GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_5")

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
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun * (1 - enemy:GetStatusResistance())})
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
    self.max_stun = self:GetAbility():GetSpecialValueFor( "max_stun" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_7")
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
        enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self.max_stun * (1 - enemy:GetStatusResistance()) } )
    end

    if not self:GetParent():IsInvulnerable() then
        damageTable.victim = self:GetParent()
        if not self:GetParent():IsMagicImmune() then
            ApplyDamage( damageTable )
            self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self.max_stun * (1 - self:GetParent():GetStatusResistance()) } )
        end
    end

    self:PlayEffects1( self:GetParent() )
    self:GetAbility():UseResources(false, false, false, true)
    if not self:IsNull() then
        self:Destroy()
    end
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
LinkLuaModifier( "modifier_steb_debuff_silenced", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

BigRussianBoss_Steb = class({})

modifier_steb_passive = class({})

function BigRussianBoss_Steb:GetIntrinsicModifierName()
    return "modifier_steb_passive"
end

function modifier_steb_passive:IsHidden()
    return self:GetStackCount() == 0
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
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.attacker:PassivesDisabled() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_steb_buff", { duration = duration } )
    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_steb_debuff", { duration = duration * (1 - params.target:GetStatusResistance()) } )
    if self:GetCaster():HasTalent("special_bonus_birzha_brb_8") then
        self:IncrementStackCount()
        if self:GetStackCount() >= self:GetCaster():FindTalentValue("special_bonus_birzha_brb_8") then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silence", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_brb_8", "value2") * (1 - params.target:GetStatusResistance())})
            self:SetStackCount(0)
        end
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
    return self.attack + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_4")
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
LinkLuaModifier( "modifier_brb_test_magical_immune", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

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
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_3")
end

function BigRussianBoss_test:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function BigRussianBoss_test:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function BigRussianBoss_test:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local target_origin = target:GetAbsOrigin()
    local caster_origin = self:GetCaster():GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())
    local duration_immune = self:GetSpecialValueFor("duration_immune")
    if target:TriggerSpellAbsorb( self ) then return end
    if target:IsIllusion() then
        target:Kill( self, self:GetCaster() )
        return
    end
    self:GetCaster():EmitSound("legend")
    if self:GetCaster().particle_duel then
        ParticleManager:DestroyParticle(self:GetCaster().particle_duel, false)
    end
    self:GetCaster().particle_duel = ParticleManager:CreateParticle("particles/boss/test.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    local center_point = target_origin + ((caster_origin - target_origin) / 1)
    ParticleManager:SetParticleControl(self:GetCaster().particle_duel, 0, center_point)
    ParticleManager:SetParticleControl(self:GetCaster().particle_duel, 7, center_point)

    target:AddNewModifier( self:GetCaster(), self, "modifier_brb_test", { duration = duration, target = self:GetCaster():entindex() } )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_brb_test", { duration = duration, target = target:entindex() } )
    target:AddNewModifier( self:GetCaster(), self, "modifier_brb_test_damage", { duration = duration } )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_brb_test_damage", { duration = duration } )
    
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_brb_test_magical_immune", { duration = duration_immune })
end

modifier_brb_test_magical_immune = class({})

function modifier_brb_test_magical_immune:IsPurgable() return false end
function modifier_brb_test_magical_immune:IsHidden() return true end

function modifier_brb_test_magical_immune:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_brb_test_magical_immune:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_brb_test_magical_immune:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_brb_test_magical_immune:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_brb_test_magical_immune:StatusEffectPriority()
    return 99999
end

modifier_brb_test = class({})

function modifier_brb_test:IsPurgable()
    return false
end

function modifier_brb_test:OnCreated(params)
    if IsServer() then
        if self:GetCaster():GetUnitName() == "npc_dota_hero_alchemist" then
            self:GetCaster():StartGesture(ACT_DOTA_ALCHEMIST_CHEMICAL_RAGE_START)
        end
        self.target = EntIndexToHScript(params.target)
        self:GetParent():SetForceAttackTarget(self.target)
        self:GetParent():MoveToTargetToAttack(self.target)
        self:StartIntervalThink(0.1)
    end
end

function modifier_brb_test:OnIntervalThink()
    if IsServer() then
        self:GetParent():SetForceAttackTarget(self.target)
        self:GetParent():MoveToTargetToAttack(self.target)
    end
end

function modifier_brb_test:GetActivityTranslationModifiers()
    if self:GetCaster():GetUnitName() == "npc_dota_hero_alchemist" then
        return "chemical_rage"
    end
end

function modifier_brb_test:GetAttackSound()
    if self:GetCaster():GetUnitName() == "npc_dota_hero_alchemist" then
        return "Hero_Alchemist.ChemicalRage.Attack"
    end
end

function modifier_brb_test:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_brb_test:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("legend")   
    if self:GetCaster().particle_duel ~= nil then
        ParticleManager:DestroyParticle(self:GetCaster().particle_duel, false)
    end
    self:GetParent():SetForceAttackTarget(nil)
end

function modifier_brb_test:CheckState()
local state =
    {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_TAUNTED] = true,
    }
    return state
end

function modifier_brb_test:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,

    }

    return decFuncs
end

function modifier_brb_test:GetDisableHealing()
    return 1
end

function modifier_brb_test:OnDeath( params )
    local damage = self:GetAbility():GetSpecialValueFor("reward_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_brb_1")
    if params.unit == self:GetParent() then
        if params.unit == self:GetCaster() then
            if not self.target:HasModifier("modifier_test_damage") then
                self.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_test_damage", {} )
            end
            local duel_stacks = self.target:GetModifierStackCount("modifier_test_damage", self:GetAbility()) + damage
            self.target:SetModifierStackCount("modifier_test_damage", self:GetAbility(), duel_stacks)
            self.target:RemoveModifierByName("modifier_brb_test_damage")
            self.target:RemoveModifierByName("modifier_brb_test")
            self.target:RemoveModifierByName("modifier_brb_test_magical_immune")
            self.target:EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
        else
            if not self:GetCaster():HasModifier("modifier_test_damage") then
                self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_test_damage", {} )
            end
            local duel_stacks = self:GetCaster():GetModifierStackCount("modifier_test_damage", self:GetAbility()) + damage
            self:GetCaster():SetModifierStackCount("modifier_test_damage", self:GetAbility(), duel_stacks)
            self:GetCaster():RemoveModifierByName("modifier_brb_test_damage")
            self:GetCaster():RemoveModifierByName("modifier_brb_test")
            self:GetCaster():RemoveModifierByName("modifier_brb_test_magical_immune")
            self:GetCaster():EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
        end
    end
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
    if self:GetParent() ~= self:GetCaster() and self:GetCaster():HasScepter() then
        return self.damage / 2
    end
    return self.damage
end

LinkLuaModifier( "modifier_brb_spice_buff", "abilities/heroes/bigrussianboss.lua", LUA_MODIFIER_MOTION_NONE )

bigrussianboss_spise = class({})

function bigrussianboss_spise:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function bigrussianboss_spise:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function bigrussianboss_spise:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local info = {
        Target = target,
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf",
        iMoveSpeed = 900,
        bDodgeable = false,
        bVisibleToEnemies = true, 
    }
    ProjectileManager:CreateTrackingProjectile(info)
    self:GetCaster():EmitSound("brb_shard_cast")

end

function bigrussianboss_spise:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target then
        local duration = self:GetSpecialValueFor("duration")
        target:AddNewModifier(self:GetCaster(), self, "modifier_brb_spice_buff", {duration = duration})
        target:EmitSound("brb_shard_target")
    end
    return true
end

modifier_brb_spice_buff = class({})

function modifier_brb_spice_buff:IsPurgable() return true end

function modifier_brb_spice_buff:GetEffectName()
    return "particles/brb_spice_effect.vpcf"
end

function modifier_brb_spice_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_brb_spice_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end

function modifier_brb_spice_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_brb_spice_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_brb_spice_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("move_speed")
end