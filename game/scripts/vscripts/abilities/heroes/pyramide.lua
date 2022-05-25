LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_silenced", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_pyramide_wires_thinker", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_wires_damage", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )

pyramide_wires = class({})


function pyramide_wires:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_2")
end

function pyramide_wires:OnSpellStart()
    if not IsServer() then return end
    local origin     = self:GetCaster():GetAbsOrigin()
    local point   = self:GetCursorPosition()
    local new_origin = point - origin
    new_origin.z = 0
    local direction = new_origin:Normalized()
    local end_point = origin + direction * 1500
    local end_point_2d = end_point:Length2D()
    local interval = self:GetSpecialValueFor("vine_spawn_interval")
    local count = math.floor(1500 / interval)
    local creatin_time = self:GetSpecialValueFor("creation_interval")
    local duration = self:GetSpecialValueFor("vines_duration")
    local ability = self
    local caster = self:GetCaster()


    self:GetCaster():EmitSound("pyramide_wires_cast")

    for i=1,count do
        Timers:CreateTimer(i*creatin_time, function()
            local next_point = GetGroundPosition(origin + direction * (interval * i), nil)
            local thicket_thinker = CreateModifierThinker(caster, ability, "modifier_pyramide_wires_thinker", { duration = duration }, next_point, caster:GetTeamNumber(), false)
            thicket_thinker:EmitSound("pyramide_wires_spawn")
        end)
    end

    if self:GetCaster():HasShard() then
        for d = 1, 2 do
            local newAngle = 10 * math.ceil(d / 2) * (-1)^d
            local newDir = RotateVector2DPyramide( direction, ToRadiansPyramide( newAngle ) )
            for i=1,count do
                Timers:CreateTimer(i*creatin_time, function()
                    local next_point = GetGroundPosition(origin + newDir * (interval * i), nil)
                    local thicket_thinker = CreateModifierThinker(caster, ability, "modifier_pyramide_wires_thinker", { duration = duration }, next_point, caster:GetTeamNumber(), false)
                end)
            end
        end
    end
end

function RotateVector2DPyramide(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadiansPyramide(degrees)
    return degrees * math.pi / 180
end

modifier_pyramide_wires_thinker = class({})

function modifier_pyramide_wires_thinker:IsHidden()     return true end
function modifier_pyramide_wires_thinker:IsPurgable()   return false end
function modifier_pyramide_wires_thinker:IsPurgeException() return false end

function modifier_pyramide_wires_thinker:OnCreated(keys)
    if not IsServer() then return end
    self.wire_particle = ParticleManager:CreateParticle("particles/pyramide/ability_wire_thinker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.wire_particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.wire_particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())
end

function modifier_pyramide_wires_thinker:OnIntervalThink()
    if not IsServer() then return end
    local debuff_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 135, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,enemy in ipairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pyramide_wires_damage", {duration = debuff_duration})
    end
end

modifier_pyramide_wires_damage = class({})

function modifier_pyramide_wires_damage:IsPurgable()   return false end
function modifier_pyramide_wires_damage:IsPurgeException() return false end

function modifier_pyramide_wires_damage:OnCreated()
    if not IsServer() then return end
    self.damage_per_second  = self:GetAbility():GetSpecialValueFor("damage_per_second")
    self.movement_slow      = self:GetAbility():GetSpecialValueFor("movement_slow_base")
    self.interval           = 0.25
    self.damage_per_tick    = self.damage_per_second * self.interval
    self:SetStackCount(self.movement_slow)
    self:StartIntervalThink(self.interval)
end

function modifier_pyramide_wires_damage:OnIntervalThink()
    if not IsServer() then return end
    local damage = self.damage_per_second
    local modifier_damage = self:GetParent():FindModifierByName("modifier_pyramide_fault_stack")
    if modifier_damage then
        damage = damage + ( (self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_3") ) * modifier_damage:GetStackCount())
    end
    ApplyDamage({ victim = self:GetParent(), damage = self.damage_per_tick, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags= DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self:GetAbility() })
end

function modifier_pyramide_wires_damage:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_UNIT_MOVED}
end

function modifier_pyramide_wires_damage:OnUnitMoved( params )
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("movement_slow_bonus") then return end
    self:SetStackCount(self:GetStackCount() + 1)
end

function modifier_pyramide_wires_damage:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * -1
end

function modifier_pyramide_wires_damage:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end


            










LinkLuaModifier( "modifier_pyramide_sud_debuff", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_sud", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )

pyramide_sud = class({})

function pyramide_sud:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_4")
end

function pyramide_sud:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_4")
    local duration_in = self:GetSpecialValueFor("duration_in")
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _,enemy in ipairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_pyramide_sud", {duration = duration_in})
    end
    local particle = ParticleManager:CreateParticle("particles/pyramide/pyramide_effect_picture.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    local caster = self:GetCaster()
    caster:EmitSound("pyramide_box")
    Timers:CreateTimer(duration_in, function()
        if particle then
            ParticleManager:DestroyParticle(particle, true)
        end
    end)
    Timers:CreateTimer(duration_in+2, function()
        if caster and not caster:IsNull() then
            caster:StopSound("pyramide_box")
        end
    end)
end

modifier_pyramide_sud = class({})

function modifier_pyramide_sud:IsPurgable() return true end
function modifier_pyramide_sud:IsMotionController() return true end
function modifier_pyramide_sud:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_pyramide_sud:OnCreated(params)
    if not IsServer() then return end

    self.duration = params.duration
    self.lift_animation = 0.2
    self.z_height = 0
    self.fall_animation = 0.3
    self.current_time = 0
    self.final_loc = self:GetParent():GetAbsOrigin()

    --Timers:CreateTimer(FrameTime(), function()
    --    if not self:IsNull() then
    --        self.duration = self:GetRemainingTime()
    --    end
    --end)

    self:StartIntervalThink(FrameTime())

    self.box = CreateUnitByName("npc_dota_companion", self:GetParent():GetAbsOrigin(), true, nil, nil, self:GetCaster():GetTeamNumber())
    self.box:SetModel("models/pyramide/pyramide_box.vmdl")
    self.box:SetOriginalModel("models/pyramide/pyramide_box.vmdl")
    self.box:AddNewModifier(self:GetAbility(), nil, "modifier_phased", {})
    self.box:AddNewModifier(self:GetAbility(), nil, "modifier_no_healthbar", {})
    self.box:AddNewModifier(self:GetAbility(), nil, "modifier_invulnerable", {})

    self.particle = ParticleManager:CreateParticle("particles/pyramide/box_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 2, Vector(self.duration, self.duration, self.duration))
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_pyramide_sud:OnIntervalThink()
    if not IsServer() then return end
    self.box:SetAbsOrigin(self:GetParent():GetAbsOrigin())
    self.box:SetForwardVector(self:GetParent():GetForwardVector())
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end

    local modifier_damage = self:GetParent():FindModifierByName("modifier_pyramide_fault_stack")
    if modifier_damage then
        local damage = (self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_3") ) * modifier_damage:GetStackCount()
        ApplyDamage({ victim = self:GetParent(), damage = damage * FrameTime(), damage_type = DAMAGE_TYPE_MAGICAL, damage_flags= DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self:GetAbility() })
    end

    self:VerticalMotion(self:GetParent(), FrameTime())
    self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_pyramide_sud:OnDestroy()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration_out")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pyramide_sud_debuff", {duration = duration})
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
    if self.box then
        UTIL_Remove(self.box)
    end
end

function modifier_pyramide_sud:VerticalMotion(unit, dt)
    if IsServer() then
        self.current_time = self.current_time + dt

        local max_height = 300
        if self.current_time <= self.lift_animation  then
            self.z_height = self.z_height + ((dt / self.lift_animation) * max_height)
            unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
        elseif self.current_time > (self.duration - self.fall_animation) then
            self.z_height = self.z_height - ((dt / self.fall_animation) * max_height)
            if self.z_height < 0 then self.z_height = 0 end
            unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
        else
            max_height = self.z_height
        end

        if self.current_time >= self.duration then
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_pyramide_sud:HorizontalMotion(unit, dt)
    if IsServer() then

        self.distance = self.distance or 0
        if (self.current_time > (self.duration - self.fall_animation)) then
            if self.changed_target then
                local frames_to_end = math.ceil((self.duration - self.current_time) / dt)
                self.distance = (unit:GetAbsOrigin() - self.final_loc):Length2D() / frames_to_end
                self.changed_target = false
            end
            if (self.current_time + dt) >= self.duration then
                unit:SetAbsOrigin(self.final_loc)
            else
                unit:SetAbsOrigin( unit:GetAbsOrigin() + ((self.final_loc - unit:GetAbsOrigin()):Normalized() * self.distance))
            end
        end
    end
end

function modifier_pyramide_sud:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

modifier_pyramide_sud_debuff = class({})

function modifier_pyramide_sud_debuff:IsPurgable() return true end

function modifier_pyramide_sud_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end

function modifier_pyramide_sud_debuff:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end




















LinkLuaModifier( "modifier_pyramide_passive", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_aghanim_thinker", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_aghanim_fog", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )

pyramide_passive = class({})

function pyramide_passive:GetIntrinsicModifierName()
    return "modifier_pyramide_passive"
end

function pyramide_passive:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function pyramide_passive:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return 90
    end
    return 0
end

function pyramide_passive:GetManaCost(level)
    if self:GetCaster():HasScepter() then
        return 200
    end
    return 0
end


function pyramide_passive:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pyramide_aghanim_thinker", {duration = 30})
end

modifier_pyramide_passive = class({})

function modifier_pyramide_passive:IsHidden() return true end
function modifier_pyramide_passive:IsPurgable() return false end

function modifier_pyramide_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_MODIFIER_ADDED,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }

    return funcs
end

function modifier_pyramide_passive:GetModifierPreAttack_CriticalStrike( params )
    if not IsServer() then return end
    if not self:GetCaster():HasTalent("special_bonus_birzha_pyramide_7") then return end
    if params.target:IsOther() then return end
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return 300
end

function modifier_pyramide_passive:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_1")
    local modifier_damage = params.target:FindModifierByName("modifier_pyramide_fault_stack")
    if modifier_damage then
        damage = damage * modifier_damage:GetStackCount()
    end
    return damage
end


function modifier_pyramide_passive:GetModifierIncomingDamage_Percentage( params )
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("damage_resist")
end

function modifier_pyramide_passive:GetModifierMoveSpeed_Absolute( params )
    return self:GetAbility():GetSpecialValueFor("movespeed") + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_5")
end

function modifier_pyramide_passive:GetModifierTurnRate_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("rotate_speed")
end

function modifier_pyramide_passive:GetModifierFixedAttackRate( params )
    return self:GetAbility():GetSpecialValueFor("bat_speed") + self:GetCaster():FindTalentValue("special_bonus_birzha_pyramide_6")
end

function modifier_pyramide_passive:OnAttackLanded( params )
    if self:GetParent() ~= params.attacker then return end
    local cleave = self:GetAbility():GetSpecialValueFor("cleave_damage") / 100
    DoCleaveAttack( params.attacker, params.target, self:GetAbility(), (params.damage * cleave), 150, 360, 650, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" ) 
end

function modifier_pyramide_passive:OnModifierAdded( params )
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.added_buff:GetName() == "modifier_item_forcestaff_active" or params.added_buff:GetName() == "modifier_rune_haste_birzha" then
        if not params.added_buff:IsNull() then
            params.added_buff:Destroy()
        end
    end
end


LinkLuaModifier( "modifier_pyramide_aghanim_pyramide_1", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_aghanim_pyramide_2", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_aghanim_pyramide_3", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_aghanim_pyramide_4", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )

modifier_pyramide_aghanim_thinker = class({})

function modifier_pyramide_aghanim_thinker:OnCreated()
    if not IsServer() then return end
    self.pyramide_1 = CreateUnitByName("npc_pyramide_unit_aghanim", Vector(0,0,0) + RandomVector(RandomInt(-1500, 1500)), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    self.pyramide_1:SetOwner(self:GetCaster())
    self.pyramide_1:AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_pyramide_aghanim_pyramide_1', {})

    self.pyramide_2 = CreateUnitByName("npc_pyramide_unit_aghanim_2", Vector(0,0,0) + RandomVector(RandomInt(-1500, 1500)), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    self.pyramide_2:SetOwner(self:GetCaster())
    self.pyramide_2:AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_pyramide_aghanim_pyramide_2', {})

    self.pyramide_3 = CreateUnitByName("npc_pyramide_unit_aghanim_3", Vector(0,0,0) + RandomVector(RandomInt(-1500, 1500)), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    self.pyramide_3:SetOwner(self:GetCaster())
    self.pyramide_3:AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_pyramide_aghanim_pyramide_3', {})

    self.pyramide_4 = CreateUnitByName("npc_pyramide_unit_aghanim_4", Vector(0,0,0) + RandomVector(RandomInt(-1500, 1500)), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    self.pyramide_4:SetOwner(self:GetCaster())
    self.pyramide_4:AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_pyramide_aghanim_pyramide_4', {})

    local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/spectre/spectre_arcana/spectre_arcana_head.vmdl"})
    head:FollowEntity(self.pyramide_3, true)
    local misc = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/spectre/spectre_arcana/spectre_arcana_misc.vmdl"})
    misc:FollowEntity(self.pyramide_3, true)
    local shoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/spectre/spectre_arcana/spectre_arcana_shoulder.vmdl"})
    shoulder:FollowEntity(self.pyramide_3, true)
    local skirt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/spectre/spectre_arcana/spectre_arcana_skirt.vmdl"})
    skirt:FollowEntity(self.pyramide_3, true)
    local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/spectre/spectre_arcana/spectre_arcana_weapon.vmdl"})
    weapon:FollowEntity(self.pyramide_3, true)

    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        hero.fog_pyramide = ParticleManager:CreateParticleForPlayer("particles/pyramide/fog_fx_aghanim.vpcf", PATTACH_EYES_FOLLOW, hero, hero:GetPlayerOwner())
    end

    EmitGlobalSound("pyramide_fog")

    self:StartIntervalThink(FrameTime())
end

function modifier_pyramide_aghanim_thinker:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsAlive() then return end
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_pyramide_aghanim_thinker:OnDestroy()
    if not IsServer() then return end
    StopGlobalSound("pyramide_fog")
    if self.pyramide_1 then
        UTIL_Remove(self.pyramide_1)
    end
    if self.pyramide_2 then
        UTIL_Remove(self.pyramide_2)
    end
    if self.pyramide_3 then
        UTIL_Remove(self.pyramide_3)
    end
    if self.pyramide_4 then
        UTIL_Remove(self.pyramide_4)
    end
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if hero.fog_pyramide then
            ParticleManager:DestroyParticle(hero.fog_pyramide, true)
        end
    end
end

function modifier_pyramide_aghanim_thinker:IsAura() return true end

function modifier_pyramide_aghanim_thinker:GetAuraRadius()
    return 999999
end

function modifier_pyramide_aghanim_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_pyramide_aghanim_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_pyramide_aghanim_thinker:GetModifierAura()
    return "modifier_pyramide_aghanim_fog"
end


modifier_pyramide_aghanim_fog = class({})

function modifier_pyramide_aghanim_fog:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end

function modifier_pyramide_aghanim_fog:OnCreated()
    if not IsServer() then return end
    self.vision = (self:GetParent():GetCurrentVisionRange() - 100 ) * -1
    self:StartIntervalThink(FrameTime())
end

function modifier_pyramide_aghanim_fog:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 100, FrameTime(), true)
end

function modifier_pyramide_aghanim_fog:GetBonusVisionPercentage()
    return -95
end

function modifier_pyramide_aghanim_fog:GetBonusDayVision( params )
    return self.vision
end

function modifier_pyramide_aghanim_fog:GetBonusNightVision( params )
    return self.vision
end


modifier_pyramide_aghanim_pyramide_1 = class({})

function modifier_pyramide_aghanim_pyramide_1:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    UpdateTarget(self:GetParent())
end

function modifier_pyramide_aghanim_pyramide_1:OnIntervalThink()
    if not IsServer() then return end
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetCaster():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    for _,unit in pairs(targets) do
        local ability = self:GetCaster():FindAbilityByName("pyramide_fault")
        if ability then
            local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) * 0.1
            local modifier_damage = unit:FindModifierByName("modifier_pyramide_fault_stack")
            if modifier_damage then
                damage = damage * modifier_damage:GetStackCount()
            end
            ApplyDamage({ victim = unit, damage = damage, ability = ability, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags= DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster() })
        end
    end
    self:GetParent():StartGesture(ACT_DOTA_ATTACK)
    local particle = ParticleManager:CreateParticle("particles/pyramide/explosion_aghanim.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetCaster():Script_GetAttackRange(),self:GetCaster():Script_GetAttackRange(),self:GetCaster():Script_GetAttackRange()))
    if self:GetParent():GetForceAttackTarget() == nil or (self:GetParent():GetForceAttackTarget() and not self:GetParent():GetForceAttackTarget():IsNull() and not self:GetParent():GetForceAttackTarget():IsAlive()) then
        UpdateTarget(self:GetParent())
    end
end

function modifier_pyramide_aghanim_pyramide_1:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end


modifier_pyramide_aghanim_pyramide_2 = class({})

function modifier_pyramide_aghanim_pyramide_2:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(2)
    UpdateTarget(self:GetParent())
end

function modifier_pyramide_aghanim_pyramide_2:OnIntervalThink()
    if not IsServer() then return end
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetCaster():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    self:GetParent():StartGesture(ACT_DOTA_ATTACK)
    for _,unit in pairs(targets) do
        local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) * 2
        ApplyDamage({ victim = unit, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags= DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster() })
    end
    local particle = ParticleManager:CreateParticle("particles/pyramide/explosion_aghanim.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetCaster():Script_GetAttackRange(),self:GetCaster():Script_GetAttackRange(),self:GetCaster():Script_GetAttackRange()))
    if self:GetParent():GetForceAttackTarget() == nil or (self:GetParent():GetForceAttackTarget() and not self:GetParent():GetForceAttackTarget():IsNull() and not self:GetParent():GetForceAttackTarget():IsAlive()) then
        UpdateTarget(self:GetParent())
    end
end

function modifier_pyramide_aghanim_pyramide_2:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

modifier_pyramide_aghanim_pyramide_3 = class({})

function modifier_pyramide_aghanim_pyramide_3:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    UpdateTarget(self:GetParent())
end

function modifier_pyramide_aghanim_pyramide_3:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():GetForceAttackTarget() == nil or (self:GetParent():GetForceAttackTarget() and not self:GetParent():GetForceAttackTarget():IsNull() and not self:GetParent():GetForceAttackTarget():IsAlive()) then
        UpdateTarget(self:GetParent())
    end
end

function modifier_pyramide_aghanim_pyramide_3:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }

    return state
end

function modifier_pyramide_aghanim_pyramide_3:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_pyramide_aghanim_pyramide_3:OnAttackLanded(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    local ability = self:GetCaster():FindAbilityByName("pyramide_wires")
    if ability then
        params.target:AddNewModifier(self:GetCaster(), ability, "modifier_pyramide_wires_damage", {duration = 3})
    end
end


modifier_pyramide_aghanim_pyramide_4 = class({})

function modifier_pyramide_aghanim_pyramide_4:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    UpdateTargetLeader(self:GetParent())
end

function modifier_pyramide_aghanim_pyramide_4:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():GetForceAttackTarget() == nil or (self:GetParent():GetForceAttackTarget() and not self:GetParent():GetForceAttackTarget():IsNull() and not self:GetParent():GetForceAttackTarget():IsAlive()) then
        UpdateTarget(self:GetParent())
    end
end

function modifier_pyramide_aghanim_pyramide_4:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }

    return state
end

function modifier_pyramide_aghanim_pyramide_4:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_pyramide_aghanim_pyramide_4:OnAttackLanded(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    local base_damage = 5
    local streak_damage = params.target:GetKills()
    local damage = base_damage * streak_damage
    print(damage, streak_damage)
    ApplyDamage({ victim = params.target, damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags= DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster() })
end


function UpdateTarget(parent)
    local targets = {}
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if hero:IsRealHero() then
            if hero:GetTeamNumber() ~= parent:GetTeamNumber() and hero:IsAlive() and not hero:IsAttackImmune() then
                table.insert(targets, hero)
            end
        end
    end

    table.sort( targets, function(x,y) return (parent:GetAbsOrigin()-y:GetAbsOrigin()):Length2D() > (parent:GetAbsOrigin()-x:GetAbsOrigin()):Length2D() end )

    for _, hero in pairs(targets) do
        parent:SetForceAttackTarget(hero)
        break
    end 
end

function UpdateTargetLeader(parent)
    local team = {}
    local teams_table = {2,3,6,7,8,9,10,11,12,13}
    for _, i in ipairs(teams_table) do
        local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
        if table_team_score then
            table.insert(team, {id = i, kills = table_team_score.kills} )
        end
    end    
    table.sort( team, function(x,y) return y.kills < x.kills end )
    local team_number = 1
    if team[team_number].id == parent:GetTeamNumber() then
        team_number = team_number + 1
    end
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if hero:IsRealHero() then
            if hero:GetTeamNumber() == team[team_number].id and hero:IsAlive() and not hero:IsAttackImmune() then
                parent:SetForceAttackTarget(hero)
                break
            end
        end
    end
end









LinkLuaModifier( "modifier_pyramide_fault", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_fault_radius", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pyramide_fault_stack", "abilities/heroes/pyramide", LUA_MODIFIER_MOTION_NONE )

pyramide_fault = class({})

function pyramide_fault:GetIntrinsicModifierName()
    return "modifier_pyramide_fault"
end

modifier_pyramide_fault = class({})

function modifier_pyramide_fault:IsHidden() return true end
function modifier_pyramide_fault:IsPurgable() return false end

function modifier_pyramide_fault:IsAura() return true end

function modifier_pyramide_fault:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_pyramide_fault:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_pyramide_fault:GetModifierAura()
    return "modifier_pyramide_fault_radius"
end

function modifier_pyramide_fault:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

modifier_pyramide_fault_radius = class({})

function modifier_pyramide_fault_radius:IsHidden() return true end

function modifier_pyramide_fault_radius:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_pyramide_fault_radius:OnIntervalThink()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pyramide_fault_stack", {duration = duration})
end

modifier_pyramide_fault_stack = class({})

function modifier_pyramide_fault_stack:IsPurgable() return false end

function modifier_pyramide_fault_stack:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_pyramide_fault_stack:OnRefresh()
    if not IsServer() then return end
    if self:GetStackCount() < 10 then
        self:SetStackCount(self:GetStackCount() + 1)
    end
end

function modifier_pyramide_fault_stack:DeclareFunctions()
    return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_pyramide_fault_stack:GetModifierDamageOutgoing_Percentage()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_reduced") * -1
end

pyramide_ultimate = class({})

function pyramide_ultimate:GetCastRange(vLocation, hTarget)
    return self:GetCaster():Script_GetAttackRange()
end

function pyramide_ultimate:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("pyramide_ultimate_preattack")
    self.timer_pfx = Timers:CreateTimer(1 - FrameTime(), function()
        self.crit_pfx = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(self.crit_pfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.crit_pfx, 1, Vector(1.4, 1.4, 1.4) )
        ParticleManager:ReleaseParticleIndex(self.crit_pfx)
    end)
    return true
end

function pyramide_ultimate:OnAbilityPhaseInterrupted()
    if self.timer_pfx then
        Timers:RemoveTimer(self.timer_pfx)
    end
    if self.crit_pfx then
        ParticleManager:DestroyParticle(self.crit_pfx, true)
    end
    self:GetCaster():StopSound("pyramide_ultimate_preattack")
end

function pyramide_ultimate:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local base_damage = self:GetSpecialValueFor("base_damage")
    local streak_damage = self:GetSpecialValueFor("streak_damage") * PlayerResource:GetStreak(target:GetPlayerID())
    local damage = base_damage + streak_damage
    ApplyDamage({ victim = target, damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags= DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self })

    self:GetCaster():EmitSound("pyramide_ultimate_attack")
    target:EmitSound("pyramide_ultimate_attack_blood")

    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
    ParticleManager:SetParticleControl( nFXIndex, 1, target:GetOrigin() )
    ParticleManager:SetParticleControlForward( nFXIndex, 1, self:GetCaster():GetForwardVector() )
    ParticleManager:SetParticleControlEnt( nFXIndex, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( nFXIndex )
end












