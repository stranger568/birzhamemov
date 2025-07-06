LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Abdulov_DefenceFromMushrooms", "abilities/heroes/abdul", LUA_MODIFIER_MOTION_NONE)

Abdulov_DefenceFromMushrooms = class({})

function Abdulov_DefenceFromMushrooms:Precache(context)
    PrecacheResource("particle", "particles/econ/items/legion/legion_fallen/legion_fallen_press_a.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_life_stealer_rage.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", context)
    PrecacheResource("particle", "particles/items2_fx/medallion_of_courage.vpcf", context)
    PrecacheResource("particle", "particles/abdul/underlord_pitofmalice_2.vpcf", context)
    PrecacheResource("particle", "particles/abdul_shard.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_culling_blade.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_culling_blade.vpcf", context)
end

function Abdulov_DefenceFromMushrooms:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Abdulov_DefenceFromMushrooms:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Abdulov_DefenceFromMushrooms:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_2")
    self:GetCaster():EmitSound("abdulrage")  
    self:GetCaster():EmitSound("Hero_LegionCommander.PressTheAttack")  
    self:GetCaster():Purge(false, true, false, true, false)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Abdulov_DefenceFromMushrooms", {duration = duration} )
end

modifier_Abdulov_DefenceFromMushrooms = class({})

function modifier_Abdulov_DefenceFromMushrooms:IsPurgable()
    return false
end

function modifier_Abdulov_DefenceFromMushrooms:OnCreated( kv )
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_fallen/legion_fallen_press_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() )
    ParticleManager:SetParticleControl( particle, 1, self:GetParent():GetAbsOrigin() )
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_Abdulov_DefenceFromMushrooms:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_Abdulov_DefenceFromMushrooms:StatusEffectPriority()
    return 10
end

function modifier_Abdulov_DefenceFromMushrooms:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_Abdulov_DefenceFromMushrooms:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_bonus") + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_1")
end

function modifier_Abdulov_DefenceFromMushrooms:CheckState()
    local state = 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }

    return state
end



LinkLuaModifier("modifier_abdulov_OvertakingMushrooms_damage", "abilities/heroes/abdul", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abdulov_OvertakingMushrooms_armor", "abilities/heroes/abdul", LUA_MODIFIER_MOTION_NONE)

Abdulov_OvertakingMushrooms = class({})

function Abdulov_OvertakingMushrooms:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Abdulov_OvertakingMushrooms:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Abdulov_OvertakingMushrooms:GetCastRange(location, target)
    if self:GetCaster():HasShard() then
        return self.BaseClass.GetCastRange(self, location, target) + self:GetSpecialValueFor("shard_range")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Abdulov_OvertakingMushrooms:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local min_loc = 50
    local max_loc = 55
    self.point = SplineVectors( caster:GetOrigin(), target:GetOrigin(), RandomInt(min_loc,max_loc)/100 )
    self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControlEnt( self.particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt(self.particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
    ParticleManager:SetParticleControl( self.particle, 2, self.point )
    ParticleManager:SetParticleControlForward( self.particle, 2, (target:GetOrigin()-caster:GetOrigin()):Normalized() )
    ParticleManager:ReleaseParticleIndex( self.particle )
    caster:EmitSound("Hero_ChaosKnight.RealityRift")
    return true
end

function Abdulov_OvertakingMushrooms:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local point = self.point

    local duration = self:GetSpecialValueFor("duration")

    local duration_attack = self:GetSpecialValueFor("bonus_duration")

    local distance = 64

    self.point = nil

    local relative = (point - caster:GetOrigin()):Normalized() * distance

    local selfLoc = point + relative

    caster:EmitSound("Hero_ChaosKnight.RealityRift.Target")

    caster:EmitSound("abdulstoi")

    target:SetOrigin( point )

    FindClearSpaceForUnit( target, point, true )

    caster:SetOrigin( selfLoc )

    FindClearSpaceForUnit( caster, selfLoc, true )

    caster:SetForwardVector( (target:GetOrigin()-caster:GetOrigin()):Normalized() )

    caster:MoveToTargetToAttack( target )

    caster:RemoveModifierByName("modifier_abdulov_OvertakingMushrooms_damage")

    target:AddNewModifier(caster, self, "modifier_abdulov_OvertakingMushrooms_armor", { duration = duration * (1 - target:GetStatusResistance()) } )

    caster:AddNewModifier(caster, self, "modifier_abdulov_OvertakingMushrooms_damage", {} )
end

modifier_abdulov_OvertakingMushrooms_armor = class({})

function modifier_abdulov_OvertakingMushrooms_armor:IsPurgable()
    return true
end

function modifier_abdulov_OvertakingMushrooms_armor:GetEffectName()
    return "particles/items2_fx/medallion_of_courage.vpcf"
end

function modifier_abdulov_OvertakingMushrooms_armor:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_abdulov_OvertakingMushrooms_armor:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_abdulov_OvertakingMushrooms_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

modifier_abdulov_OvertakingMushrooms_damage = class({})

function modifier_abdulov_OvertakingMushrooms_damage:OnCreated()
    if not IsServer() then return end
    local attack_count = 1
    if self:GetCaster():HasTalent("special_bonus_birzha_abdul_3") then
        attack_count = self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_3")
    end
    self:SetStackCount(attack_count)
end

function modifier_abdulov_OvertakingMushrooms_damage:IsPurgable()
    return false
end

function modifier_abdulov_OvertakingMushrooms_damage:IsHidden() return self:GetStackCount() == 0 end

function modifier_abdulov_OvertakingMushrooms_damage:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_abdulov_OvertakingMushrooms_damage:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_abdulov_OvertakingMushrooms_damage:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end

    if self:GetStackCount() > 0 then
        self:DecrementStackCount()
    end

    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_Abdulov_TripToHell", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Abdulov_TripToHell_debuff", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "Abdulov_TripToHell_damage_rooted", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Abdulov_TripToHell_thinker_move", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Abdulov_TripToHell_thinker_move_buff", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )

Abdulov_TripToHell = class({})

function Abdulov_TripToHell:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Abdulov_TripToHell:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Abdulov_TripToHell:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Abdulov_TripToHell:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Abdulov_TripToHell:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local duration = self:GetSpecialValueFor( "duration" )
    CreateModifierThinker( caster, self, "modifier_Abdulov_TripToHell", { duration = duration }, point, caster:GetTeamNumber(), false )
    caster:EmitSound("Hero_AbyssalUnderlord.PitOfMalice")
    caster:EmitSound("abdulad")
end

modifier_Abdulov_TripToHell = class({})

function modifier_Abdulov_TripToHell:IsPurgable()
    return false
end

function modifier_Abdulov_TripToHell:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local duration = self:GetAbility():GetSpecialValueFor( "duration" )

    if not IsServer() then return end

    local particle = ParticleManager:CreateParticle( "particles/abdul/underlord_pitofmalice_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, 0, 0 ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, 0, 0 ) )
    self:AddParticle(particle, false, false, -1, false, false )
    self.blockers = {}

    if self:GetCaster():HasScepter() then
        local amount = 20
        local particle2 = ParticleManager:CreateParticle("particles/abdul_shard.vpcf",PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle2,0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle2,2, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle2,1, Vector(self.radius, 0 , 0))
        self:AddParticle(particle2, false, false, -1, false, false )
        for i = 0, amount - 1 do
            local angle = math.rad(360 / amount * i)
            local offset = Vector(math.cos(angle), math.sin(angle), 0) * self.radius
            local origin = self:GetParent():GetOrigin() + offset
            local pso = SpawnEntityFromTableSynchronous("point_simple_obstruction", { origin = origin })
            CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_Abdulov_TripToHell_thinker_move", {duration = self:GetRemainingTime()}, origin, self:GetCaster():GetTeamNumber(), false)
            table.insert(self.blockers, pso)
        end
    end
end

function modifier_Abdulov_TripToHell:OnDestroy( kv )
    if not IsServer() then return end
    for _, blocker in pairs(self.blockers) do
        UTIL_Remove(blocker)
    end
end

function modifier_Abdulov_TripToHell:IsAura()
    return true
end

function modifier_Abdulov_TripToHell:GetModifierAura()
    return "modifier_Abdulov_TripToHell_debuff"
end

function modifier_Abdulov_TripToHell:GetAuraRadius()
    return self.radius
end

function modifier_Abdulov_TripToHell:GetAuraDuration()
    return 0
end

function modifier_Abdulov_TripToHell:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Abdulov_TripToHell:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_Abdulov_TripToHell:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_Abdulov_TripToHell_debuff = class({})

function modifier_Abdulov_TripToHell_debuff:IsPurgable()
    return false
end

function modifier_Abdulov_TripToHell_debuff:IsHidden()
    return true
end

function modifier_Abdulov_TripToHell_debuff:OnCreated()
    local interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
    local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_4")
    local duration = self:GetAbility():GetSpecialValueFor( "rooted_duration" )
    if not IsServer() then return end
    self.damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "Abdulov_TripToHell_damage_rooted", { duration = duration } )
    local particle = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() )
    self:AddParticle(particle, false, false, -1, false, false)
    self:GetParent():EmitSound("Hero_AbyssalUnderlord.Pit.TargetHero")
    self:StartIntervalThink( interval )
end

function modifier_Abdulov_TripToHell_debuff:OnIntervalThink()
    ApplyDamage( self.damageTable )
end

function modifier_Abdulov_TripToHell_debuff:GetEffectName()
    return "particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf"
end

function modifier_Abdulov_TripToHell_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

Abdulov_TripToHell_damage_rooted = class({})

function Abdulov_TripToHell_damage_rooted:IsPurgable()
    return true
end

function Abdulov_TripToHell_damage_rooted:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end

modifier_Abdulov_TripToHell_thinker_move = class({})
function modifier_Abdulov_TripToHell_thinker_move:IsHidden() return true end
function modifier_Abdulov_TripToHell_thinker_move:IsPurgeException() return false end
function modifier_Abdulov_TripToHell_thinker_move:IsPurgable() return false end
function modifier_Abdulov_TripToHell_thinker_move:IsAura()
    return true
end
function modifier_Abdulov_TripToHell_thinker_move:GetModifierAura()
    return "modifier_Abdulov_TripToHell_thinker_move_buff"
end
function modifier_Abdulov_TripToHell_thinker_move:GetAuraRadius()
    return 100
end
function modifier_Abdulov_TripToHell_thinker_move:GetAuraDuration()
    return 0
end
function modifier_Abdulov_TripToHell_thinker_move:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_Abdulov_TripToHell_thinker_move:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_Abdulov_TripToHell_thinker_move:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
modifier_Abdulov_TripToHell_thinker_move_buff = class({})
function modifier_Abdulov_TripToHell_thinker_move_buff:IsHidden() return true end
function modifier_Abdulov_TripToHell_thinker_move_buff:IsPurgeException() return false end
function modifier_Abdulov_TripToHell_thinker_move_buff:IsPurgable() return false end
function modifier_Abdulov_TripToHell_thinker_move_buff:CheckState()
    return
    {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_BASE_BLOCKER] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

LinkLuaModifier( "modifier_Abdulov_CutMushrooms", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )

Abdulov_CutMushrooms = class({})

function Abdulov_CutMushrooms:GetIntrinsicModifierName()
    return "modifier_Abdulov_CutMushrooms"
end

modifier_Abdulov_CutMushrooms = class({})

function modifier_Abdulov_CutMushrooms:IsHidden()
    return true
end

function modifier_Abdulov_CutMushrooms:IsPurgable()
    return false
end

function modifier_Abdulov_CutMushrooms:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return decFuncs
end

function modifier_Abdulov_CutMushrooms:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsBoss() then return end
    if params.attacker:IsIllusion() then return end

    local damage = self:GetAbility():GetSpecialValueFor( "damage" )
    local kill_threshold = self:GetAbility():GetSpecialValueFor( "kill_threshold" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_6")
    local chance = self:GetAbility():GetSpecialValueFor( "chance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_5")

    local damagetype = DAMAGE_TYPE_PHYSICAL

    if self:GetCaster():HasTalent("special_bonus_birzha_abdul_7") then
        damagetype = DAMAGE_TYPE_PURE
    end

    if params.target:GetHealth() <= params.target:GetMaxHealth() / 100 * kill_threshold then
        params.attacker:EmitSound("Hero_Axe.Culling_Blade_Success")
        ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_ABSORIGIN, params.target)
        params.attacker:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_4, 1 )
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, params.attacker)
        ParticleManager:SetParticleControlEnt(particle, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 2, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 4, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 8, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)
        params.attacker:EmitSound("abdulult")
        if self:GetCaster():HasTalent("special_bonus_birzha_abdul_8") then
            params.target:BirzhaTrueKill(self:GetAbility(), self:GetCaster())
        else
            ApplyDamage({victim = params.target, attacker = params.attacker, damage = params.target:GetHealth(), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
        end
        return
    end

    if RollPercentage(chance) then  
        local damage = params.target:GetMaxHealth() / 100 * damage              
        ApplyDamage({victim = params.target, attacker = params.attacker, damage = damage, damage_type = damagetype, ability = self:GetAbility()})
        params.attacker:EmitSound("Hero_Axe.Culling_Blade_Success")
        params.attacker:EmitSound("abdulfail")
        ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_ABSORIGIN, params.target)
        params.attacker:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_4, 1 )
    end
end