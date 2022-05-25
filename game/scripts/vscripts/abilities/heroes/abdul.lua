LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Abdulov_DefenceFromMushrooms", "abilities/heroes/abdul", LUA_MODIFIER_MOTION_NONE)

Abdulov_DefenceFromMushrooms = class({}) 

function Abdulov_DefenceFromMushrooms:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Abdulov_DefenceFromMushrooms:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Abdulov_DefenceFromMushrooms:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_1")
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
    self.particle = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_fallen/legion_fallen_press_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.particle, 1, self:GetParent():GetAbsOrigin() )
end

function modifier_Abdulov_DefenceFromMushrooms:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex( self.particle )
    end
end

function modifier_Abdulov_DefenceFromMushrooms:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_Abdulov_DefenceFromMushrooms:StatusEffectPriority()
    return 10
end

function modifier_Abdulov_DefenceFromMushrooms:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_Abdulov_DefenceFromMushrooms:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end

function modifier_Abdulov_DefenceFromMushrooms:CheckState()
    local state = {
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
    local bonus_range = 0
    if self:GetCaster():HasShard() then
        bonus_range = 200
    end
    return self.BaseClass.GetCastRange(self, location, target) + bonus_range
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
    target:AddNewModifier(caster, self, "modifier_abdulov_OvertakingMushrooms_armor", { duration = duration } )
    caster:AddNewModifier(caster, self, "modifier_abdulov_OvertakingMushrooms_damage", { duration = duration_attack } )
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
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_abdulov_OvertakingMushrooms_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

modifier_abdulov_OvertakingMushrooms_damage = class({})

function modifier_abdulov_OvertakingMushrooms_damage:IsPurgable()
    return false
end

function modifier_abdulov_OvertakingMushrooms_damage:DeclareFunctions()
    local funcs = {
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
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

LinkLuaModifier( "modifier_Abdulov_TripToHell", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Abdulov_TripToHell_debuff", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "Abdulov_TripToHell_damage_rooted", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )

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
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
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
            local pso = SpawnEntityFromTableSynchronous("point_simple_obstruction", { origin = self:GetParent():GetOrigin() + offset, })
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
    return 0.5
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
    local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_2")
    local duration = self:GetAbility():GetSpecialValueFor( "rooted_duration" )
    if not IsServer() then return end
    self.damageTable = {
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
    return false
end

function Abdulov_TripToHell_damage_rooted:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
    }

    return state
end

Abdulov_CutMushrooms = class({})

LinkLuaModifier( "modifier_Abdulov_CutMushrooms", "abilities/heroes/abdul.lua", LUA_MODIFIER_MOTION_NONE )

modifier_Abdulov_CutMushrooms = class({})

function Abdulov_CutMushrooms:GetIntrinsicModifierName()
    return "modifier_Abdulov_CutMushrooms"
end

function modifier_Abdulov_CutMushrooms:IsHidden()
    return true
end

function modifier_Abdulov_CutMushrooms:IsPurgable()
    return false
end

function modifier_Abdulov_CutMushrooms:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK
    }

    return decFuncs
end

function modifier_Abdulov_CutMushrooms:OnAttack( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )
    local kill_threshold = self:GetAbility():GetSpecialValueFor( "kill_threshold" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_4")
    local chance = self:GetAbility():GetSpecialValueFor( "chance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_abdul_3")
    local damagetype = DAMAGE_TYPE_PHYSICAL
    if self:GetCaster():HasTalent("special_bonus_birzha_abdul_5") then
        damagetype = DAMAGE_TYPE_PURE
    end
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if not target:IsHero() then return end
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if target:IsBoss() then return end
        if target:GetHealth() <= target:GetMaxHealth() / 100 * kill_threshold then
            parent:EmitSound("Hero_Axe.Culling_Blade_Success")
            ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_ABSORIGIN, target)
            parent:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_4, 1 )
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, parent)
            ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)
            parent:EmitSound("abdulult")
            local damage_table = {}
            damage_table.victim = target
            damage_table.attacker = parent
            damage_table.ability = self:GetAbility()
            damage_table.damage_type = DAMAGE_TYPE_PURE
            damage_table.damage = 999999
            ApplyDamage(damage_table)
            return
        end
        if RandomInt(1, 100) <= chance then                 
            ApplyDamage({victim = target, attacker = parent, damage = target:GetMaxHealth() / 100 * damage, damage_type = damagetype, ability = self:GetAbility()})
            parent:EmitSound("Hero_Axe.Culling_Blade_Success")
            parent:EmitSound("abdulfail")
            ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_ABSORIGIN, target)
            parent:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_4, 1 )
        end
    end
end