LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_robbie_trap", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)

robbie_trap = class({})

function robbie_trap:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_1")
end

function robbie_trap:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function robbie_trap:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function robbie_trap:OnSpellStart(new_caster, new_target)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if new_caster then
        caster = new_caster
    end

    if new_target then
        target = new_target
    end

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local info = 
    {
        EffectName = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
        Ability = self,
        iMoveSpeed = 1500,
        Source = caster,
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }

    ProjectileManager:CreateTrackingProjectile( info )

    caster:EmitSound("Hero_NagaSiren.Ensnare.Cast")
end

function robbie_trap:OnProjectileHit_ExtraData(hTarget, vLocation, hExtraData)
    if hTarget then
        if not hTarget:HasModifier("modifier_robbie_trap") then
            hTarget:EmitSound("Hero_NagaSiren.Ensnare.Target")
        end
        local duration = self:GetSpecialValueFor("duration")
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_robbie_trap", {duration = duration * (1 - hTarget:GetStatusResistance())})
    end
end

modifier_robbie_trap = class({})

function modifier_robbie_trap:IsPurgable() return true end
function modifier_robbie_trap:GetEffectName() return "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf" end
function modifier_robbie_trap:GetEffectAttachType() return PATTACH_ABSORIGIN end

function modifier_robbie_trap:CheckState()
    if self:GetCaster():HasTalent("special_bonus_birzha_robbie_3") then
        return 
        {
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_PASSIVES_DISABLED] = true,
        } 
    end
    return 
    {
        [MODIFIER_STATE_ROOTED] = true,
    } 
end

function modifier_robbie_trap:OnCreated( kv )
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_robbie_trap:OnIntervalThink( kv )
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration = FrameTime()+FrameTime()})
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 50, FrameTime()+FrameTime(), false)
    end
end

LinkLuaModifier("modifier_roby_agility", "abilities/heroes/robbie.lua", LUA_MODIFIER_MOTION_NONE)

roby_agility = class({})

function roby_agility:GetIntrinsicModifierName()
    return "modifier_roby_agility"
end

modifier_roby_agility = class({})

function modifier_roby_agility:IsHidden()
    return true
end

function modifier_roby_agility:OnCreated()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_movespeed_cap", {})
end

function modifier_roby_agility:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
    return declfuncs
end

function modifier_roby_agility:GetModifierMoveSpeedBonus_Constant()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

function modifier_roby_agility:GetModifierConstantHealthRegen()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("hp_regen") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_2")
end

LinkLuaModifier("modifier_robbie_timeinvis", "abilities/heroes/robbie.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_robbie_timeinvis_invis", "abilities/heroes/robbie.lua", LUA_MODIFIER_MOTION_NONE)

robbie_timeinvis = class({})

function robbie_timeinvis:GetIntrinsicModifierName()
    return "modifier_robbie_timeinvis"
end

function robbie_timeinvis:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

modifier_robbie_timeinvis = class({})

function modifier_robbie_timeinvis:IsHidden()
    return true
end

function modifier_robbie_timeinvis:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_robbie_timeinvis:OnIntervalThink()
    if not self:GetCaster():HasShard() then
        if self:GetParent():IsIllusion() then return end
    end
    if self:GetAbility():IsFullyCastable() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_robbie_timeinvis_invis", {duration = duration})
    else
        self:GetParent():RemoveModifierByName("modifier_robbie_timeinvis_invis")
    end
end

function modifier_robbie_timeinvis:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
    return declfuncs
end

function modifier_robbie_timeinvis:GetModifierProcAttack_BonusDamage_Physical(params)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end

    if not self:GetCaster():HasShard() then
        if self:GetParent():IsIllusion() then return end
    end

    if not self:GetCaster():HasTalent("special_bonus_birzha_robbie_7") then
        self:GetAbility():UseResources(false,false,true)
    end

    local agility_damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_6")
    local victim_angle = params.target:GetAnglesAsVector().y
    local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()
    local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
    origin_difference_radian = origin_difference_radian * 180
    local attacker_angle = origin_difference_radian / math.pi
    attacker_angle = attacker_angle + 180.0
    local result_angle = attacker_angle - victim_angle
    result_angle = math.abs(result_angle)
    if result_angle >= (180 - (self:GetAbility():GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (self:GetAbility():GetSpecialValueFor("backstab_angle") / 2)) then 
        params.target:EmitSound("Hero_Riki.Backstab")
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target) 
        ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 
        return params.attacker:GetAgility() * agility_damage_multiplier
    end
end

modifier_robbie_timeinvis_invis = class({})

function modifier_robbie_timeinvis_invis:IsHidden()
    return true
end

function modifier_robbie_timeinvis_invis:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_robbie_timeinvis_invis:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_robbie_timeinvis_invis:GetModifierInvisibilityLevel()
    return 1
end

function modifier_robbie_timeinvis_invis:CheckState()
    local state = { [MODIFIER_STATE_INVISIBLE] = true}
    return state
end

LinkLuaModifier("modifier_robi_WeAreNumberOne", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_robi_WeAreNumberOne_buff", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_robi_WeAreNumberOne_ability", "abilities/heroes/robbie", LUA_MODIFIER_MOTION_NONE)

Robi_WeAreNumberOne = class({}) 

function Robi_WeAreNumberOne:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Robi_WeAreNumberOne:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Robi_WeAreNumberOne:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_5")
    local outgoingDamage = self:GetSpecialValueFor("illusion_damage_outgoing") + self:GetCaster():FindTalentValue("special_bonus_birzha_robbie_8")
    local incomingDamage = self:GetSpecialValueFor("illusion_damage_incoming")
    outgoingDamage = outgoingDamage - 100
    incomingDamage = incomingDamage - 100

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_robi_WeAreNumberOne_ability", {duration = duration})

    EmitGlobalSound("WeAreNumberOne")

    local all = FindUnitsInRadius(caster:GetTeam(),  caster:GetOrigin(),  nil,  99999, DOTA_UNIT_TARGET_TEAM_ENEMY,  DOTA_UNIT_TARGET_HERO,  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER,  false)
    local ability_trap = self:GetCaster():FindAbilityByName("robbie_trap")

    for _, unit in ipairs(all) do
        local illusions = BirzhaCreateIllusion(caster, caster, { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage }, 1, 0, false, true )
        for k,v in ipairs(illusions) do
            v:SetAbsOrigin(unit:GetAbsOrigin() + RandomVector(100))
            FindClearSpaceForUnit(v, v:GetAbsOrigin(), false)
            v:SetForwardVector(unit:GetAbsOrigin() - v:GetAbsOrigin())
            Timers:CreateTimer(0.25, function()
                ExecuteOrderFromTable({
                    UnitIndex = v:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    TargetIndex = unit:entindex(),
                    Queue = false,
                })
                v:SetForceAttackTarget(unit)
                if self:GetCaster():HasScepter() then
                    if ability_trap then
                        ability_trap:OnSpellStart(v, unit)
                    end
                end
            end)
            v:AddNewModifier(caster, self, "modifier_robi_WeAreNumberOne_buff", {})
            v.ISSPECTRE_ILLUSION_HAUNT = true
        end
    end
end

modifier_robi_WeAreNumberOne_ability = class({})
function modifier_robi_WeAreNumberOne_ability:IsPurgable() return false end
function modifier_robi_WeAreNumberOne_ability:RemoveOnDeath() return false end
function modifier_robi_WeAreNumberOne_ability:IsPurgeException() return false end
function modifier_robi_WeAreNumberOne_ability:IsHidden() return true end

function modifier_robi_WeAreNumberOne_ability:OnCreated()
    if not IsServer() then return end
    local ability_reality = self:GetParent():FindAbilityByName("Robi_WeAreNumberOneTeleport")
    if ability_reality ~= nil then
        ability_reality:SetLevel(1)
        ability_reality:SetActivated(true)
    end
end

function modifier_robi_WeAreNumberOne_ability:OnDestroy()
    if not IsServer() then return end
    local ability_reality = self:GetParent():FindAbilityByName("Robi_WeAreNumberOneTeleport")
    if ability_reality ~= nil then
        ability_reality:SetActivated(false)
    end
end

modifier_robi_WeAreNumberOne_buff = class({})

function modifier_robi_WeAreNumberOne_buff:IsHidden()
    return true
end

function modifier_robi_WeAreNumberOne_buff:OnCreated()
    self:StartIntervalThink(0.1)
end

function modifier_robi_WeAreNumberOne_buff:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent:GetForceAttackTarget() and not parent:GetForceAttackTarget():IsAlive() then
        UTIL_Remove(self:GetParent())
    end
end

function modifier_robi_WeAreNumberOne_buff:GetDisableAutoAttack() return 1 end

function modifier_robi_WeAreNumberOne_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,MODIFIER_PROPERTY_DISABLE_AUTOATTACK}
    return declfuncs
end

function modifier_robi_WeAreNumberOne_buff:GetModifierMoveSpeed_Absolute()
    return 400
end

function modifier_robi_WeAreNumberOne_buff:CheckState()
    local state = 
    { 
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
    return state
end

Robi_WeAreNumberOneTeleport = class({})

function Robi_WeAreNumberOneTeleport:OnSpellStart()
    if not IsServer() then return end
    local vPoint = self:GetCursorPosition()
    local target = Entities:FindByNameNearest(self:GetCaster():GetUnitName(), vPoint, 0)
    if target:IsIllusion() and target.ISSPECTRE_ILLUSION_HAUNT and target:IsAlive() then
        local caster_forward_vector = self:GetCaster():GetForwardVector()
        local target_forward_vector = target:GetForwardVector()
        self:GetCaster():SetForwardVector(target_forward_vector)
        target:SetForwardVector(caster_forward_vector)
        local caster_current_position = self:GetCaster():GetAbsOrigin()
        local target_current_position = target:GetAbsOrigin()
        target:SetAbsOrigin(caster_current_position)    
        self:GetCaster():SetAbsOrigin(target_current_position)
        FindClearSpaceForUnit( self:GetCaster(), target_current_position, true )
        self:GetCaster():EmitSound("Hero_Spectre.Reality")
        if self:GetCaster():HasTalent("special_bonus_birzha_robbie_4") then
            self:GetCaster():Purge(false, true, false, false, false)
        end
    end
end