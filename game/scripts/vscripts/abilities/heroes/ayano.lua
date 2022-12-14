LinkLuaModifier( "modifier_ayano_TakeACircularSaw", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_TakeACircularSaw = class({})

function Ayano_TakeACircularSaw:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_TakeACircularSaw:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()
    if not IsServer() then return end
    caster:EmitSound("ayanopila")
    if toggle then
        self.modifier = caster:AddNewModifier( caster, self, "modifier_ayano_TakeACircularSaw", {} )
    else
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
        self.modifier = nil
    end
end

modifier_ayano_TakeACircularSaw = class({})

function modifier_ayano_TakeACircularSaw:IsHidden()
    return true
end

function modifier_ayano_TakeACircularSaw:IsPurgable()
    return false
end

function modifier_ayano_TakeACircularSaw:OnCreated()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_bp_ayano") then
        local particle = ParticleManager:CreateParticle("particles/yano_ambient_skill.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self:AddParticle(particle, false, false, 1, false, false)
    end
end

function modifier_ayano_TakeACircularSaw:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_ayano_TakeACircularSaw:GetEffectName()
    return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_ayano_TakeACircularSaw:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_ayano_TakeACircularSaw:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then


        local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"

        if self:GetParent():HasModifier("modifier_bp_ayano") then
            particle_cast = "particles/ayano_critical_skill.vpcf"
        end

        local particle = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
        ParticleManager:SetParticleControl( particle, 1, target:GetOrigin() )
        ParticleManager:SetParticleControlForward( particle, 1, (self:GetParent():GetOrigin()-target:GetOrigin()):Normalized() )
        ParticleManager:SetParticleControlEnt( particle, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( particle )
        target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
    end
end

function modifier_ayano_TakeACircularSaw:GetModifierDamageOutgoing_Percentage()
    if self:GetCaster():HasShard() then
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("damage_reduced")
end

function modifier_ayano_TakeACircularSaw:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("base_attack_time") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_5")
end





LinkLuaModifier( "modifier_Ayano_Tranquilizer_1", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_Tranquilizer_2", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_Tranquilizer_3", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_Tranquilizer = class({})

function Ayano_Tranquilizer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_Tranquilizer:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ayano_Tranquilizer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ayano_Tranquilizer:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("radius_scepter")
    end
    return 0
end

function Ayano_Tranquilizer:GetBehavior()
    local caster = self:GetCaster()
    local scepter = caster:HasScepter()

    if scepter then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function Ayano_Tranquilizer:OnSpellStart()
    local caster = self:GetCaster()
    if not IsServer() then return end
    if not self:GetCaster():HasScepter() then
        local target = self:GetCursorTarget()
        local info = {
            Target = target,
            Source = caster,
            Ability = self, 
            EffectName = "particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_poison_touch.vpcf",
            iMoveSpeed = 1600,
            bReplaceExisting = false,
            bProvidesVision = true,
            iVisionRadius = 25,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        ProjectileManager:CreateTrackingProjectile(info)
    else
        local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_NONE, 0, false )
        for _,enemy in pairs(targets) do
            local info = {
                Target = enemy,
                Source = self:GetCaster(),
                Ability = self, 
                EffectName = "particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_poison_touch.vpcf",
                iMoveSpeed = 1600,
                bReplaceExisting = false,
                bProvidesVision = true,
                iVisionRadius = 25,
                iVisionTeamNumber = caster:GetTeamNumber()
            }
            ProjectileManager:CreateTrackingProjectile(info)
        end
    end
    caster:EmitSound("Hero_Dazzle.Poison_Cast")
end

function Ayano_Tranquilizer:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target:IsMagicImmune() then return end
    if target==nil then return end
    if target:TriggerSpellAbsorb( self ) then return end
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_1")
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    target:AddNewModifier( self:GetCaster(), self, "modifier_Ayano_Tranquilizer_3", {duration = 1} )
end

modifier_Ayano_Tranquilizer_3 = class({})

function modifier_Ayano_Tranquilizer_3:IsPurgable()
    return true
end

function modifier_Ayano_Tranquilizer_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ayano_Tranquilizer_3:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_speed_1") 
end

function modifier_Ayano_Tranquilizer_3:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Ayano_Tranquilizer_2", {duration = 0.5} )
end

modifier_Ayano_Tranquilizer_2 = class({})

function modifier_Ayano_Tranquilizer_2:IsPurgable()
    return true
end

function modifier_Ayano_Tranquilizer_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ayano_Tranquilizer_2:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_speed_2") 
end

function modifier_Ayano_Tranquilizer_2:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Ayano_Tranquilizer_1", {duration = 0.5} )
end

modifier_Ayano_Tranquilizer_1 = class({})

function modifier_Ayano_Tranquilizer_1:IsPurgable()
    return true
end

function modifier_Ayano_Tranquilizer_1:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ayano_Tranquilizer_1:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_speed_3") 
end

function modifier_Ayano_Tranquilizer_1:OnDestroy()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_2")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration * (1 - self:GetParent():GetStatusResistance()) })
end






















LinkLuaModifier( "modifier_Ayano_WeakMind_buff", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_WeakMind_passive", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_WeakMind = class({})

function Ayano_WeakMind:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_WeakMind:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ayano_WeakMind:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ayano_WeakMind:GetIntrinsicModifierName()
    return "modifier_Ayano_WeakMind_passive"
end

function Ayano_WeakMind:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") 
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Ayano_WeakMind_buff", {duration = duration} )
    self:GetCaster():EmitSound("hero_bloodseeker.rupture.cast")
end

modifier_Ayano_WeakMind_passive = class({})

function modifier_Ayano_WeakMind_passive:IsHidden()
    return true
end

function modifier_Ayano_WeakMind_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_Ayano_WeakMind_passive:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.unit == self:GetParent() then return end
    if params.unit:IsWard() then return end
    if self:GetParent():PassivesDisabled() then return end

    local heal_multiplier = (self:GetAbility():GetSpecialValueFor("heal_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_4")) / 100
    local active_multiple = self:GetAbility():GetSpecialValueFor("active_multiple") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_7")

    if self:GetCaster():HasModifier("modifier_Ayano_WeakMind_buff") then
        heal_multiplier = heal_multiplier * active_multiple
    end

    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        params.attacker:Heal(params.damage * heal_multiplier, nil)
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

modifier_Ayano_WeakMind_buff = class({})

function modifier_Ayano_WeakMind_buff:IsPurgable()
    return true
end

function modifier_Ayano_WeakMind_buff:GetEffectName()
    return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_Ayano_WeakMind_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW 
end













LinkLuaModifier( "modifier_SpotTheTarget", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_SpotTheTarget_aura", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_SpotTheTarget_talent_crit", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_SpotTheTarget = class({})

function Ayano_SpotTheTarget:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_SpotTheTarget:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ayano_SpotTheTarget:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ayano_SpotTheTarget:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

    if target:TriggerSpellAbsorb( self ) then return end

    target:AddNewModifier( caster, self, "modifier_SpotTheTarget_aura", {duration = duration} )

    local particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_CUSTOMORIGIN, caster, caster:GetTeamNumber())
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    caster:EmitSound("aynoult")
end

modifier_SpotTheTarget_aura = class({})

function modifier_SpotTheTarget_aura:IsPurgable()
    return true
end

function modifier_SpotTheTarget_aura:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_SpotTheTarget_aura:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    if not IsServer() then return end
    self.particle_shield_fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent, self.caster:GetTeamNumber())
    ParticleManager:SetParticleControl(self.particle_shield_fx, 0, self.parent:GetAbsOrigin())
    self:AddParticle(self.particle_shield_fx, false, false, -1, false, true)

    self.particle_trail_fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent, self.caster:GetTeamNumber())
    ParticleManager:SetParticleControl(self.particle_trail_fx, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.particle_trail_fx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.particle_trail_fx, 8, Vector(1,0,0))
    self:AddParticle(self.particle_trail_fx, false, false, -1, false, false)

    self.aura = false
    if self:GetCaster():HasTalent("special_bonus_birzha_ayano_3") then
        self.aura = true
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_SpotTheTarget_aura:OnIntervalThink()
    self:SetStackCount(self.parent:GetGold())
    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), 50, FrameTime(), false)
    self.parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration = 0.1})
end

function modifier_SpotTheTarget_aura:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP, 
        MODIFIER_EVENT_ON_ATTACK_START
    }
    return decFuncs
end

function modifier_SpotTheTarget_aura:OnDeath(keys)
    if not IsServer() then return end
    local target = keys.unit
    if target == self.parent then
        local money = self:GetAbility():GetSpecialValueFor("money")
        if self:GetParent():IsIllusion() then return end
        self:GetCaster():ModifyGold( money, true, 0 )
        self:Destroy()
    end
end

function modifier_SpotTheTarget_aura:OnAttackStart(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    if params.attacker ~= self:GetCaster() then return end
    params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_SpotTheTarget_talent_crit", {duration = 3})
end

function modifier_SpotTheTarget_aura:OnTooltip()
    return self:GetStackCount()
end

function modifier_SpotTheTarget_aura:IsAura() return self.aura end

function modifier_SpotTheTarget_aura:GetAuraRadius()
    return 999999
end

function modifier_SpotTheTarget_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_SpotTheTarget_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_SpotTheTarget_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_SpotTheTarget_aura:GetModifierAura()
    return "modifier_SpotTheTarget"
end

function modifier_SpotTheTarget_aura:GetAuraEntityReject(target)
    if not IsServer() then return end
    if target == self:GetCaster() then
        return false
    else
        return true
    end
end

modifier_SpotTheTarget = class({})

function modifier_SpotTheTarget:IsPurgable()
    return true
end

function modifier_SpotTheTarget:GetEffectName()
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_haste.vpcf"
end

function modifier_SpotTheTarget:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_SpotTheTarget:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
    return decFuncs
end

function modifier_SpotTheTarget:GetModifierMoveSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_3")
end

modifier_SpotTheTarget_talent_crit = class({})

function modifier_SpotTheTarget_talent_crit:IsHidden() return true end
function modifier_SpotTheTarget_talent_crit:IsPurgable() return false end

function modifier_SpotTheTarget_talent_crit:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_SpotTheTarget_talent_crit:GetModifierPreAttack_CriticalStrike(params)
    if params.target == self:GetCaster() and params.target:HasModifier("modifier_SpotTheTarget_aura") then
        return self:GetParent():FindTalentValue("special_bonus_birzha_ayano_6")
    else
        self:Destroy()
    end
end

function modifier_SpotTheTarget_talent_crit:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    self:Destroy()
end








LinkLuaModifier( "modifier_Ayano_LaunchACircularSaw_thinker", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_LaunchACircularSaw_thinker_disarm", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_LaunchACircularSaw = class({})

function Ayano_LaunchACircularSaw:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_ayano_8") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function Ayano_LaunchACircularSaw:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function Ayano_LaunchACircularSaw:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Ayano_LaunchACircularSaw:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    self:GetCaster():EmitSound("Hero_Shredder.Chakram.Cast")

    local duration = (point - self:GetCaster():GetAbsOrigin()):Length2D() / self:GetSpecialValueFor( "speed" )

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Ayano_LaunchACircularSaw_thinker_disarm", {duration = duration})
    CreateModifierThinker( self:GetCaster(), self, "modifier_Ayano_LaunchACircularSaw_thinker", { target_x = point.x, target_y = point.y, target_z = point.z}, self:GetCaster():GetOrigin(), self:GetCaster():GetTeamNumber(), false )
end

modifier_Ayano_LaunchACircularSaw_thinker = class({})

function modifier_Ayano_LaunchACircularSaw_thinker:IsHidden()
    return true
end

function modifier_Ayano_LaunchACircularSaw_thinker:IsPurgable()
    return false
end

function modifier_Ayano_LaunchACircularSaw_thinker:OnCreated( kv )
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
    self.point = Vector( kv.target_x, kv.target_y, kv.target_z )
    self.move_interval = FrameTime()
    self.proximity = 50
    self.caught_enemies = {}
    self:StartIntervalThink( self.move_interval )
    self:PlayEffects1()
    self:GetParent():EmitSound("Hero_Shredder.Chakram")
end

function modifier_Ayano_LaunchACircularSaw_thinker:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_Shredder.Chakram")
    self:GetParent():RemoveModifierByName("modifier_Ayano_LaunchACircularSaw_thinker_disarm")
    UTIL_Remove( self:GetParent() )
end

function modifier_Ayano_LaunchACircularSaw_thinker:OnIntervalThink()
    self:LaunchThink()
end

function modifier_Ayano_LaunchACircularSaw_thinker:LaunchThink()
    local origin = self:GetParent():GetOrigin()
    self:PassLogic( origin )
    local close = self:MoveLogic( origin )
    if close then
        self:Destroy()
    end
end

function modifier_Ayano_LaunchACircularSaw_thinker:PassLogic( origin )
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _,enemy in pairs(enemies) do
        if not self.caught_enemies[enemy] then
            self.caught_enemies[enemy] = true
            self:GetCaster():PerformAttack(enemy, true, true, true, false, false, false, true)
            --PerformAttack(hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss)
        end
    end
end

function modifier_Ayano_LaunchACircularSaw_thinker:MoveLogic( origin )
    local direction = (self.point-origin):Normalized()
    local target = origin + direction * self.speed * self.move_interval
    self:GetParent():SetOrigin( target )
    return (target-self.point):Length2D()<self.proximity
end

function modifier_Ayano_LaunchACircularSaw_thinker:PlayEffects1()
    local direction = self.point-self:GetParent():GetOrigin()
    direction.z = 0
    direction = direction:Normalized()
    self.effect_cast = ParticleManager:CreateParticle( "particles/ayano/pila_launch.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, direction * self.speed )
    ParticleManager:SetParticleControl( self.effect_cast, 15, Vector( 255, 0, 0 ) )
    ParticleManager:SetParticleControl( self.effect_cast, 16, Vector( 1, 1, 1 ) )
    ParticleManager:SetParticleControl( self.effect_cast, 60, Vector( 255, 0, 0 ) )
    ParticleManager:SetParticleControl( self.effect_cast, 61, Vector( 0, 0, 0 ) )
end

modifier_Ayano_LaunchACircularSaw_thinker_disarm = class({})

function modifier_Ayano_LaunchACircularSaw_thinker_disarm:IsHidden() return true end
function modifier_Ayano_LaunchACircularSaw_thinker_disarm:IsPurgable() return false end
function modifier_Ayano_LaunchACircularSaw_thinker_disarm:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

















--local model_list = {
--    "models/courier/baby_rosh/babyroshan.vmdl",
--    "models/courier/donkey_trio/mesh/donkey_trio.vmdl",
--    "models/courier/mechjaw/mechjaw.vmdl",
--    "models/courier/huntling/huntling.vmdl",
--    "models/items/courier/devourling/devourling.vmdl",
--    "models/courier/seekling/seekling.vmdl",
--    "models/courier/venoling/venoling.vmdl",
--    "models/items/courier/amaterasu/amaterasu.vmdl",
--    "models/items/courier/beaverknight_s2/beaverknight_s2.vmdl",
--    "models/items/courier/nian_courier/nian_courier.vmdl",
--    "models/items/courier/faceless_rex/faceless_rex.vmdl",
--    "models/pets/icewrack_wolf/icewrack_wolf.vmdl",
--    "models/props_gameplay/chicken.vmdl",
--}
--
--local selection = "models/courier/baby_rosh/babyroshan.vmdl"
--
--LinkLuaModifier("modifier_ayano_mischief", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_ayano_mischie_invul", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE)
--
--Ayano_Mischief = class({})
--
--function Ayano_Mischief:OnSpellStart()
--    if self:GetCaster():HasModifier("modifier_ayano_mischief") then
--        self:GetCaster():RemoveModifierByName("modifier_ayano_mischief")
--    else
--        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ayano_mischief", {} )
--        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ayano_mischie_invul", {duration = 0.2} )
--        self:GetCaster():EmitSound("aynoinvis")
--        self:EndCooldown()
--    end
--end
--
--modifier_ayano_mischief = class({})
--
--function modifier_ayano_mischief:DeclareFunctions()
--    local funcs = {
--        MODIFIER_EVENT_ON_ATTACK_START,
--        MODIFIER_EVENT_ON_TAKEDAMAGE,
--        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
--        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
--        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
--        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
--        MODIFIER_PROPERTY_MODEL_CHANGE,
--        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
--    }
--
--    return funcs
--end
--
--function modifier_ayano_mischief:Exposed()
--    if self:GetParent():HasModifier("modifier_ayano_mischief") then
--        self:GetParent():RemoveModifierByName("modifier_ayano_mischief")
--        self:GetAbility():UseResources(false, false, true)
--    end
--end
--
--function modifier_ayano_mischief:IsHidden() return true end
--
--function modifier_ayano_mischief:OnAttackStart( keys )
--    if keys.attacker == self:GetParent() then
--        self:Exposed()
--    end
--end
--
--function modifier_ayano_mischief:OnTakeDamage( keys )   
--    if keys.unit == self:GetParent() or keys.attacker == self:GetParent() then
--        self:Exposed()
--    end
--end
--
--function modifier_ayano_mischief:OnAbilityExecuted( params )
--    if IsServer() then
--        local hAbility = params.ability
--        if hAbility == self:GetAbility() then return end
--
--        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
--            return 0
--        end
--
--        self:Exposed()
--    end
--        
--end
--
--function modifier_ayano_mischief:GetEffectName()
--    return "particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf"
--end
--
--function modifier_ayano_mischief:CheckState()
--    local state = {
--    [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
--    [MODIFIER_STATE_NO_HEALTH_BAR]              = true,
--    [MODIFIER_STATE_LOW_ATTACK_PRIORITY]        = true  }
--    
--    return state
--end
--
--function modifier_ayano_mischief:OnCreated()
--    if not IsServer() then return end
--
--    self.search_range   = 350
--    self.particle       = ""
--    self.model_found    = false
--    self:SetStackCount(200)
--
--    self:GetParent():RemoveDonate()
--    
--    if self:GetParent():HasModifier("modifier_get_xp") then
--        selection = "models/props_gameplay/gold_coin001.vmdl"
--        return
--    end
--
--    local trees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.search_range, false)
--    if #trees > 0 then
--        selection = "maps/ti10_assets/trees/ti10_goldenbirch001.vmdl"
--        return
--    end
--    
--    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
--    self:GetParent():GetAbsOrigin(),
--    nil,
--    self.search_range,
--    DOTA_UNIT_TARGET_TEAM_BOTH,
--    DOTA_UNIT_TARGET_HERO,
--    DOTA_UNIT_TARGET_FLAG_NONE,
--    FIND_ANY_ORDER,
--    false)
--    if (#units > 0) then
--        selection = model_list[RandomInt(1, #model_list)]
--        self:SetStackCount(380)
--        return
--    end
--end
--
--function modifier_ayano_mischief:OnRemoved()
--    if not IsServer() then return end
--    local poof = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
--    ParticleManager:SetParticleControl(poof, 0, self:GetParent():GetAbsOrigin())
--    ParticleManager:ReleaseParticleIndex(poof)
--    if PLAYERS[ self:GetParent():GetPlayerID() ] then
--        self:GetParent():AddDonate(PLAYERS[ self:GetParent():GetPlayerID() ].effect)
--    end
--end
--
--function modifier_ayano_mischief:GetModifierModelChange()
--    return selection
--end
--
--function modifier_ayano_mischief:GetModifierMoveSpeed_Absolute()
--    return self:GetStackCount()
--end
--
--function modifier_ayano_mischief:GetModifierMoveSpeed_AbsoluteMin()
--    return self:GetStackCount()
--end
--
--function modifier_ayano_mischief:GetModifierMoveSpeed_Limit()
--    return self:GetStackCount()
--end
--
--modifier_ayano_mischie_invul = class({})
--
--function modifier_ayano_mischie_invul:IsHidden()
--    return true
--end
--
--function modifier_ayano_mischie_invul:CheckState()
--    local state = {
--    [MODIFIER_STATE_INVULNERABLE] = true,}
--    
--    return state
--end