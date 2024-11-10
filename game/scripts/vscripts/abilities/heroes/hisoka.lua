LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_cards_buff", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_cards_debuff", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_cards_stack", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )

hisoka_cards = class({})

function hisoka_cards:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level )
end

function hisoka_cards:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function hisoka_cards:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function hisoka_cards:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_1 )
    return true
end

function hisoka_cards:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
end

function hisoka_cards:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local card_count = 10

    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end

    local index = DoUniqueString("index")
    self[index] = {}

    local start_angle
    local interval_angle = 0

    if card_count == 1 then
        start_angle = 0
    else
        start_angle = 40 / 2 * (-1)
        interval_angle = 40 / (card_count - 1)
    end

    local range = self:GetSpecialValueFor("range")

    self:GetCaster():EmitSound("HisokaCard")

    for i = 1, card_count, 1 do
        local angle = start_angle + (i-1) * interval_angle
        local velocity = RotateVector2D(direction,angle,true) * 1000
        local projectile =
        {
            Ability             = self,
            EffectName          = "particles/hisoka/card_particle.vpcf",
            vSpawnOrigin        = caster_loc,
            fDistance           = range,
            fStartRadius        = 100,
            fEndRadius          = 100,
            Source              = caster,
            bHasFrontalCone     = false,
            bReplaceExisting    = false,
            iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime         = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit        = true,
            vVelocity           = Vector(velocity.x,velocity.y,0),
            bProvidesVision     = false,
            ExtraData           = {index = index, card_count = card_count}
        }
        ProjectileManager:CreateLinearProjectile(projectile)
        self:GetCaster():EmitSound("playercard.flip")
    end
end

function hisoka_cards:OnProjectileHit_ExtraData(target, location, ExtraData)
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local debuff_duration = self:GetSpecialValueFor("slow_duration")
    local buff_duration = self:GetSpecialValueFor("caster_movespeed_bonus_duration")
    local bonus_duration = self:GetSpecialValueFor("stack_duration")
    local bonus_damage = self:GetSpecialValueFor("bonus_damage_stack")
    local bonus_count = self:GetSpecialValueFor("stack_count") + self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_2")

    if target ~= nil then
        if target:IsMagicImmune() then return true end

        local was_hit = false
        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end

        if was_hit then
            return nil
        end

        table.insert(self[ExtraData.index],target)

        local stack_modifier = target:FindModifierByName("modifier_hisoka_cards_stack")

        if stack_modifier then
            damage = damage + (stack_modifier:GetStackCount() * bonus_damage)
        end

        if self:GetCaster():HasTalent("special_bonus_birzha_hisoka_5") then
            target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = (self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_5") * (1 - target:GetStatusResistance()))})
        end

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_hisoka_cards_buff", {duration = buff_duration})

        target:AddNewModifier(self:GetCaster(), self, "modifier_hisoka_cards_debuff", {duration = (debuff_duration * (1 - target:GetStatusResistance()))})

        ApplyDamage( { victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self } )

        target:EmitSound("playercard.flip")

        if stack_modifier then
            stack_modifier:SetDuration(bonus_duration, true)
            if stack_modifier:GetStackCount() < bonus_count then
                stack_modifier:SetStackCount(stack_modifier:GetStackCount()+1)
                ParticleManager:SetParticleControl(stack_modifier.pfx, 1, Vector(0, stack_modifier:GetStackCount(), 0))
            end
        else
            target:AddNewModifier(self:GetCaster(), self, "modifier_hisoka_cards_stack", {duration = bonus_duration})
        end

        return true
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.card_count then
            self[ExtraData.index] = nil
        end
    end
end

modifier_hisoka_cards_buff = class({})

function modifier_hisoka_cards_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_hisoka_cards_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("caster_movespeed_bonus") 
end

modifier_hisoka_cards_debuff = class({})

function modifier_hisoka_cards_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_hisoka_cards_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow") 
end

modifier_hisoka_cards_stack = class({})

function modifier_hisoka_cards_stack:IsHidden()
    return true
end

function modifier_hisoka_cards_stack:OnCreated()
    if not IsServer() then return end
    self.pfx = ParticleManager:CreateParticle("particles/hisoka/card_particle_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:SetStackCount(1)
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, 1, 0))
    self:AddParticle(self.pfx, false, false, -1, false, false)
end

LinkLuaModifier( "modifier_hisoka_shield_buff_attack", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_shield_buff_shield", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )

hisoka_shield = class({})

function hisoka_shield:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_hisoka_4") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function hisoka_shield:OnSpellStart()
    if not IsServer() then return end

    local duration = self:GetSpecialValueFor("duration")

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_hisoka_shield_buff_attack", {duration = duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_hisoka_shield_buff_shield", {duration = duration})

    self:GetCaster():EmitSound("HisokaShield")

    if self:GetCaster():HasTalent("special_bonus_birzha_hisoka_5") then
        self:GetCaster():Purge(false, true, false, true, true)
    end

    local hisoka_cards = self:GetCaster():FindAbilityByName("hisoka_cards")

    if self:GetCaster():HasScepter() and hisoka_cards and hisoka_cards:GetLevel() > 0 then
        local caster = self:GetCaster()

        local caster_loc = caster:GetAbsOrigin()

        local card_count = 40

        direction = caster:GetForwardVector()

        local index = DoUniqueString("index")

        hisoka_cards[index] = {}

        self.original_ability = self:GetCaster():FindAbilityByName("hisoka_cards")

        local range = self.original_ability:GetSpecialValueFor("range")

        self:GetCaster():EmitSound("HisokaCard")

        local projectile =
        {
            Ability             = hisoka_cards,
            EffectName          = "particles/hisoka/card_particle.vpcf",
            vSpawnOrigin        = caster_loc,
            fDistance           = range,
            fStartRadius        = 100,
            fEndRadius          = 100,
            Source              = caster,
            bHasFrontalCone     = false,
            bReplaceExisting    = false,
            iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime         = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit        = true,
            vVelocity           = Vector(direction.x,direction.y,0),
            bProvidesVision     = false,
            ExtraData           = {index = index, card_count = card_count}
        }

        i = -30

        for var=1,13, 1 do
            projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * 1000
            ProjectileManager:CreateLinearProjectile(projectile)
            i = i + 30
        end

        self:GetCaster():EmitSound("playercard.flip")
    end
end

modifier_hisoka_shield_buff_attack = class({})

function modifier_hisoka_shield_buff_attack:IsPurgable()
    return not self:GetCaster():HasScepter()
end

function modifier_hisoka_shield_buff_attack:OnCreated()
    self.bonus_damage   = self:GetAbility():GetSpecialValueFor("damage")
    if not IsServer() then return end
    self.stacks  = self:GetAbility():GetSpecialValueFor("stacks") + self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_7")
    self:SetStackCount(self.stacks)
end

function modifier_hisoka_shield_buff_attack:OnRefresh()
    self:OnCreated()
end

function modifier_hisoka_shield_buff_attack:OnStackCountChanged(iStackCount)
    if not IsServer() then return end
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end

function modifier_hisoka_shield_buff_attack:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_hisoka_shield_buff_attack:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_hisoka_shield_buff_attack:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if params.target:IsWard() then return end
        self:DecrementStackCount()
    end
end

modifier_hisoka_shield_buff_shield = class({})

function modifier_hisoka_shield_buff_shield:IsPurgable()
    return not self:GetCaster():HasScepter()
end

function modifier_hisoka_shield_buff_shield:GetPriority() return MODIFIER_PRIORITY_ULTRA end

function modifier_hisoka_shield_buff_shield:OnCreated()
    if not IsServer() then return end
    if self.refraction_particle == nil then
        self.refraction_particle = ParticleManager:CreateParticle("particles/hisoka/hisoka_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.refraction_particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControl( self.refraction_particle, 15, Vector( 255, 0, 255 ) )
        ParticleManager:SetParticleControl( self.refraction_particle, 16, Vector( 1, 0, 0 ) )
        self:AddParticle(self.refraction_particle, false, false, -1, true, false)
    end
    self.stacks  = self:GetAbility():GetSpecialValueFor("stacks") + self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_7")
    self:SetStackCount(self.stacks)
end

function modifier_hisoka_shield_buff_shield:OnRefresh()
    self:OnCreated()
end

function modifier_hisoka_shield_buff_shield:OnStackCountChanged(iStackCount)
    if not IsServer() then return end
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end

function modifier_hisoka_shield_buff_shield:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

function modifier_hisoka_shield_buff_shield:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then
        if kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
            self:DecrementStackCount()
            return kv.damage
        end
    end
end

LinkLuaModifier( "modifier_hisoka_bubble_counter", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_bubble_buff", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_bubble_debuff", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_bubble_passive", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_bubble_caster_active", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_hisoka_bubble_target_active", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_BOTH )

hisoka_bubble = class({})

function hisoka_bubble:CastFilterResultTarget(target)
    if not target:HasModifier("modifier_hisoka_bubble_debuff") then
        return UF_FAIL_CUSTOM
    else
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    end
end

function hisoka_bubble:GetCustomCastErrorTarget(target)
    if not target:HasModifier("modifier_hisoka_bubble_debuff") then
        return "dota_hud_error_hisoka_bubble"
    end
end

function hisoka_bubble:GetAOERadius()
    return self:GetSpecialValueFor("root_radius")
end

function hisoka_bubble:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    if caster:HasModifier("modifier_hisoka_bubble_caster_active") then
        local target_loc = self:GetCursorPosition()
        local maximum_distance = self:GetSpecialValueFor("root_radius")

        if self.telekinesis_marker_pfx then
            ParticleManager:DestroyParticle(self.telekinesis_marker_pfx, false)
            ParticleManager:ReleaseParticleIndex(self.telekinesis_marker_pfx)
        end

        local marked_distance = (target_loc - self.target_origin):Length2D()

        if marked_distance > maximum_distance then
            target_loc = self.target_origin + (target_loc - self.target_origin):Normalized() * maximum_distance
        end

        self.telekinesis_marker_pfx = ParticleManager:CreateParticleForTeam("particles/hisoka_active/hisoka_active_markermarker.vpcf", PATTACH_CUSTOMORIGIN, caster, caster:GetTeam())
        ParticleManager:SetParticleControl(self.telekinesis_marker_pfx, 0, target_loc)
        ParticleManager:SetParticleControl(self.telekinesis_marker_pfx, 1, Vector(3, 0, 0))
        ParticleManager:SetParticleControl(self.telekinesis_marker_pfx, 2, self.target_origin)
        ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 1, target_loc)

        self:GetCaster():EmitSound("hisoka_tripple")

        self.target_modifier.final_loc = target_loc

        self.target_modifier.changed_target = true

        self:EndCooldown()
    else
        self.target = self:GetCursorTarget()

        if self.target then
            self.target_origin = self.target:GetAbsOrigin()

            local duration = 1

            if self.target:TriggerSpellAbsorb(self) then
                return nil
            end

            self.target_modifier = self.target:AddNewModifier(caster, self, "modifier_hisoka_bubble_target_active", { duration = duration })

            self.target_modifier.tele_pfx = ParticleManager:CreateParticle("particles/hisoka_active/active_use.vpcf", PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(self.target_modifier.tele_pfx, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(self.target_modifier.tele_pfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 2, Vector(duration,0,0))
            self.target_modifier:AddParticle(self.target_modifier.tele_pfx, false, false, 1, false, false)

            caster:EmitSound("Hero_Rubick.Telekinesis.Cast")

            self.target:EmitSound("Hero_Rubick.Telekinesis.Target")


            self.target_modifier.final_loc = self.target_origin

            self.target_modifier.changed_target = false

            caster:AddNewModifier(caster, self, "modifier_hisoka_bubble_caster_active", { duration = duration - 0.3})

            self:GetCaster():EmitSound("hisoka_tripple")

            self:EndCooldown()
        end
    end
end

function hisoka_bubble:GetBehavior()
    if self:GetCaster():HasModifier("modifier_hisoka_bubble_caster_active") then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function hisoka_bubble:GetManaCost( target )
    if self:GetCaster():HasModifier("modifier_hisoka_bubble_caster_active") then
        return 0
    else
        return self.BaseClass.GetManaCost(self, target)
    end
end

function hisoka_bubble:GetCastRange( location , target)
    if self:GetCaster():HasModifier("modifier_hisoka_bubble_caster_active") then
        return 25000
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

modifier_hisoka_bubble_caster_active = class({})

function modifier_hisoka_bubble_caster_active:IsDebuff() return false end
function modifier_hisoka_bubble_caster_active:IsHidden() return true end
function modifier_hisoka_bubble_caster_active:IsPurgable() return false end
function modifier_hisoka_bubble_caster_active:IsPurgeException() return false end
function modifier_hisoka_bubble_caster_active:IsStunDebuff() return false end
function modifier_hisoka_bubble_caster_active:OnDestroy()
    local ability = self:GetAbility()
    if ability.telekinesis_marker_pfx then
        ParticleManager:DestroyParticle(ability.telekinesis_marker_pfx, false)
        ParticleManager:ReleaseParticleIndex(ability.telekinesis_marker_pfx)
    end
end

modifier_hisoka_bubble_target_active = class({})

function modifier_hisoka_bubble_target_active:IsHidden() return true end
function modifier_hisoka_bubble_target_active:IsPurgable() return false end
function modifier_hisoka_bubble_target_active:IsPurgeException() return false end
function modifier_hisoka_bubble_target_active:IsStunDebuff() return false end
function modifier_hisoka_bubble_target_active:IsMotionController() return true end
function modifier_hisoka_bubble_target_active:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_hisoka_bubble_target_active:OnCreated( params )
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        self.parent = self:GetParent()
        self.z_height = 0
        self.duration = params.duration
        self.lift_animation = 0.5
        self.fall_animation = 0.3
        self.current_time = 0

        -- Start thinking
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_hisoka_bubble_target_active:OnIntervalThink()
    if IsServer() then
        if not self:CheckMotionControllers() then
            if not self:IsNull() then
                self:Destroy()
            end
            return nil
        end
        self:VerticalMotion(self.parent, self.frametime)
        self:HorizontalMotion(self.parent, self.frametime)
    end
end

function modifier_hisoka_bubble_target_active:EndTransition()
    if IsServer() then
        if self.transition_end_commenced then
            return nil
        end
        self.transition_end_commenced = true

        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), false)
        ResolveNPCPositions(parent:GetAbsOrigin(), 64)
        local parent_pos = parent:GetAbsOrigin()
        local ability = self:GetAbility()
        local impact_radius = 400
        GridNav:DestroyTreesAroundPoint(parent_pos, impact_radius, true)

        local impact_stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
        local impact_root_duration = self:GetAbility():GetSpecialValueFor("root_duration")
        local impact_radius = 400

        parent:StopSound("Hero_Rubick.Telekinesis.Target")
        parent:EmitSound("Hero_Rubick.Telekinesis.Target.Land")
        ParticleManager:ReleaseParticleIndex(self.tele_pfx)

        local landing_pfx = ParticleManager:CreateParticle("particles/hisoka_active/active_land.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(landing_pfx, 0, parent_pos)
        ParticleManager:SetParticleControl(landing_pfx, 1, parent_pos)
        ParticleManager:ReleaseParticleIndex(landing_pfx)

        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), parent_pos, nil, impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _,enemy in ipairs(enemies) do
            if enemy ~= parent then
                enemy:AddNewModifier(caster, ability, "modifier_birzha_stunned_purge", {duration = impact_stun_duration * (1 - enemy:GetStatusResistance())})
            else
                enemy:AddNewModifier(caster, ability, "modifier_rooted", {duration = impact_root_duration * (1 - enemy:GetStatusResistance())})
            end
        end
        parent:EmitSound("Hero_Rubick.Telekinesis.Target.Stun")
        ability:UseResources(true, false, false, true)
    end
end

function modifier_hisoka_bubble_target_active:VerticalMotion(unit, dt)
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
            self:EndTransition()
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_hisoka_bubble_target_active:HorizontalMotion(unit, dt)
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
                self:EndTransition()
            else
                unit:SetAbsOrigin( unit:GetAbsOrigin() + ((self.final_loc - unit:GetAbsOrigin()):Normalized() * self.distance))
            end
        end
    end
end

function modifier_hisoka_bubble_target_active:OnDestroy()
    if IsServer() then
        if self.parent:IsAlive() then
            FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), false)
        end
    end
end


function modifier_hisoka_bubble_target_active:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_hisoka_bubble_target_active:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_hisoka_bubble_target_active:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function hisoka_bubble:GetIntrinsicModifierName()
    return "modifier_hisoka_bubble_passive"
end

modifier_hisoka_bubble_passive = class({})

function modifier_hisoka_bubble_passive:IsHidden()
    return true
end

function modifier_hisoka_bubble_passive:IsPurgable()
    return false
end

function modifier_hisoka_bubble_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_hisoka_bubble_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsWard() then return end
    if params.target:HasModifier("modifier_hisoka_bubble_debuff") then return end

    local slow_duration = self:GetAbility():GetSpecialValueFor("duration_attack")

    local modifier = params.target:FindModifierByName("modifier_hisoka_bubble_counter")

    self:GetCaster():EmitSound("HisokaBubble")

    if modifier then
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_bubble_counter", { duration = slow_duration * (1 - params.target:GetStatusResistance())})
        modifier:IncrementStackCount()
    else
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_bubble_counter", { duration = slow_duration * (1 - params.target:GetStatusResistance())})
    end
end

modifier_hisoka_bubble_counter = class({})

function modifier_hisoka_bubble_counter:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_hisoka_bubble_counter:OnStackCountChanged(iStackCount)
    if not IsServer() then return end

    if not self.pfx then
        self.pfx = ParticleManager:CreateParticle("particles/hisoka/hisoka_bubble_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    end

    ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))

    if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("max_stack") then
        self:GetParent():EmitSound("Hero_Snapfire.MortimerBlob.Projectile")
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_bubble_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_debuff")})
        self:Destroy()
    end
end

function modifier_hisoka_bubble_counter:OnRemoved()
    if not IsServer() then return end

    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
    end
end

modifier_hisoka_bubble_debuff = modifier_hisoka_bubble_debuff or class({
    IsHidden                = function(self) return false end,
    IsDebuff                = function(self) return true end,
    GetEffectName           = function(self) return "particles/hisoka/hisoka_bubble_debuff.vpcf" end,
    GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_hisoka_bubble_debuff:IsPurgable()
    return true
end

function modifier_hisoka_bubble_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_hisoka_bubble_debuff:CheckState() 
    return 
    {
        [MODIFIER_STATE_SILENCED] = true,
    } 
end

function modifier_hisoka_bubble_debuff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    local buff_duration = self:GetAbility():GetSpecialValueFor("duration_debuff")
    params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_bubble_buff", { duration = buff_duration })
end

modifier_hisoka_bubble_buff = modifier_hisoka_bubble_buff or class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    GetEffectName           = function(self) return "particles/hisoka/hisoka_bubble_buff.vpcf" end,
    GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_hisoka_bubble_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_hisoka_bubble_buff:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") + self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_3") end

LinkLuaModifier( "modifier_hisoka_trap_counter", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_trap", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_trap_debuff", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_trap_debuff_movespeed", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hisoka_trap_debuff_attackspeed", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bubble_unit", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bubble_unit_debuff", "abilities/heroes/hisoka.lua", LUA_MODIFIER_MOTION_NONE )

hisoka_trap = class({})

function hisoka_trap:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_8")
end

function hisoka_trap:GetIntrinsicModifierName()
    return "modifier_hisoka_trap_counter"
end

function hisoka_trap:OnSpellStart()
    if not self.counter_modifier or self.counter_modifier:IsNull() then
        self.counter_modifier = self:GetCaster():FindModifierByName("modifier_hisoka_trap_counter")
    end
    if self.counter_modifier and self.counter_modifier.trap_table then
        local trap = CreateUnitByName("npc_dota_templar_assassin_psionic_trap", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        FindClearSpaceForUnit(trap, trap:GetAbsOrigin(), false)
        local trap_modifier = trap:AddNewModifier(self:GetCaster(), self, "modifier_hisoka_trap", {})
        trap:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        self:GetCaster():EmitSound("Hero_TemplarAssassin.Trap.Cast")
        EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_TemplarAssassin.Trap", self:GetCaster())
        if trap:HasAbility("hisoka_trap_trap") then
            trap:FindAbilityByName("hisoka_trap_trap"):SetHidden(false)
            trap:FindAbilityByName("hisoka_trap_trap"):SetLevel(self:GetLevel())
        end
        table.insert(self.counter_modifier.trap_table, trap_modifier)
        if #self.counter_modifier.trap_table > self:GetSpecialValueFor("max_traps") then
            if self.counter_modifier.trap_table[1]:GetParent() then
                self.counter_modifier.trap_table[1]:GetParent():ForceKill(false)
            end
        end
        self.counter_modifier:SetStackCount(#self.counter_modifier.trap_table)
    end
end

modifier_hisoka_trap = class({})

function modifier_hisoka_trap:IsHidden() return true end
function modifier_hisoka_trap:IsPurgable() return false end

function modifier_hisoka_trap:OnCreated()
    if not IsServer() then return end
    self.self_particle      = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.self_particle, 60, Vector(255, 0, 255))
    ParticleManager:SetParticleControl(self.self_particle, 61, Vector(1, 0, 0))
    self:AddParticle(self.self_particle, false, false, -1, false, false)
    self.trap_counter_modifier = self:GetCaster():FindModifierByName("modifier_hisoka_trap_counter")
end

function modifier_hisoka_trap:OnDestroy()
    if not IsServer() then return end
    if self.trap_counter_modifier and self.trap_counter_modifier.trap_table then
        for trap_modifier = 1, #self.trap_counter_modifier.trap_table do
            if self.trap_counter_modifier.trap_table[trap_modifier] == self then
                table.remove(self.trap_counter_modifier.trap_table, trap_modifier)
                if self:GetCaster():HasModifier("modifier_hisoka_trap_counter") then
                    self:GetCaster():FindModifierByName("modifier_hisoka_trap_counter"):DecrementStackCount()
                end
                break
            end
        end
    end
end

function modifier_hisoka_trap:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE]          = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end

function modifier_hisoka_trap:Explode(ability, radius)
    self.explode_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.self_particle, 60, Vector(255, 0, 255))
    ParticleManager:SetParticleControl(self.self_particle, 61, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(self.explode_particle)
    self:GetParent():EmitSound("Hero_TemplarAssassin.Trap.Explode")
    self:GetCaster():EmitSound("HisokaActivated")
    if self:GetParent():GetOwner() then
        for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
            local damage = self:GetAbility():GetSpecialValueFor("damage")
            local duration = self:GetAbility():GetSpecialValueFor("movespeed_slow_duration")
            local damage_table = {
            victim = enemy,
            attacker = self:GetCaster(),
            damage = damage + self:GetCaster():FindTalentValue("special_bonus_birzha_hisoka_1"),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
            }
            ApplyDamage( damage_table )
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_trap_debuff", {duration = duration * (1 - enemy:GetStatusResistance())})
        end
    end
    self:GetParent():ForceKill(false)
    if not self:IsNull() then
        self:Destroy()
    end
end

modifier_hisoka_trap_counter = class({})

function modifier_hisoka_trap_counter:OnCreated()
    if not IsServer() then return end
    self.trap_table = {}
end

hisoka_trap_trap = class({})

function hisoka_trap_trap:OnSpellStart()
    if self:GetCaster():GetOwner() then
        self.trap_counter_modifier = self:GetCaster():GetOwner():FindModifierByName("modifier_hisoka_trap_counter")
        if self:GetCaster():HasModifier("modifier_hisoka_trap") then
            self:GetCaster():FindModifierByName("modifier_hisoka_trap"):Explode(self, self:GetSpecialValueFor("radius"))
        end
    end
end

hisoka_trap_destroy  = class({})

function hisoka_trap_destroy:OnSpellStart()
    if not self.trap_ability then
        self.trap_ability = self:GetCaster():FindAbilityByName("hisoka_trap")
    end
    
    if not self.counter_modifier or self.counter_modifier:IsNull() then
        self.counter_modifier = self:GetCaster():FindModifierByName("modifier_hisoka_trap_counter")
    end
    
    if self.trap_ability and self.counter_modifier and self.counter_modifier.trap_table and #self.counter_modifier.trap_table > 0 then
        local distance  = nil
        local index     = nil
        for trap_number = 1, #self.counter_modifier.trap_table do
            if self.counter_modifier.trap_table[trap_number] and not self.counter_modifier.trap_table[trap_number]:IsNull() then
                if not distance then
                    index       = trap_number
                    distance    = (self:GetCaster():GetAbsOrigin() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
                elseif ((self:GetCaster():GetAbsOrigin() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D() < distance) then
                    index       = trap_number
                    distance    = (self:GetCaster():GetAbsOrigin() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
                end
            end
        end
        
        if index then
            self.counter_modifier.trap_table[index]:Explode(self.trap_ability, self:GetSpecialValueFor("radius"))
        end
    else
        DisplayError(self:GetCaster():GetPlayerOwnerID(), "#notraps")
    end
end

hisoka_trap_teleport = class({})

function hisoka_trap_teleport:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)
    else
        self:SetHidden(true)
    end
end

function hisoka_trap_teleport:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function hisoka_trap_teleport:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function hisoka_trap_teleport:GetChannelTime()
    return self.BaseClass.GetChannelTime(self)
end





function hisoka_trap_teleport:OnChannelFinish(bInterrupted)
    if not bInterrupted then
        if not self.trap_ability then
            self.trap_ability = self:GetCaster():FindAbilityByName("hisoka_trap")
        end
        
        if not self.counter_modifier or self.counter_modifier:IsNull() then
            self.counter_modifier = self:GetCaster():FindModifierByName("modifier_hisoka_trap_counter")
        end
        
        if self.trap_ability and self.counter_modifier and self.counter_modifier.trap_table and #self.counter_modifier.trap_table > 0 then
            local distance  = nil
            local index     = nil
            for trap_number = 1, #self.counter_modifier.trap_table do
                if self.counter_modifier.trap_table[trap_number] and not self.counter_modifier.trap_table[trap_number]:IsNull() then
                    if not distance then
                        index       = trap_number
                        distance    = (self:GetCursorPosition() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
                    elseif ((self:GetCursorPosition() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D() < distance) then
                        index       = trap_number
                        distance    = (self:GetCursorPosition() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
                    end
                end
            end
            if index then
                FindClearSpaceForUnit(self:GetCaster(), self.counter_modifier.trap_table[index]:GetParent():GetAbsOrigin(), false)
                self.counter_modifier.trap_table[index]:Explode(self.trap_ability, self:GetSpecialValueFor("radius"))
                self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
            end
        end
    end
end

modifier_hisoka_trap_debuff = class({})

function modifier_hisoka_trap_debuff:IsHidden()
    return true
end

function modifier_hisoka_trap_debuff:IsPurgable()
    return true
end

function modifier_hisoka_trap_debuff:OnCreated()
    if not IsServer() then return end
    local duration_m = self:GetAbility():GetSpecialValueFor("movespeed_slow_duration")
    local duration_a = self:GetAbility():GetSpecialValueFor("attackspeed_slow_duration")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_trap_debuff_movespeed", {duration = duration_m})
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hisoka_trap_debuff_attackspeed", {duration = duration_a})
    self:GetParent():EmitSound("Hero_Snapfire.MortimerBlob.Projectile")
    if not self:GetParent():HasModifier("modifier_bubble_unit_debuff") then
        local bubble = CreateUnitByName("npc_dota_bubble", self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 64, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        bubble:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_bubble_unit",  { destroy_attacks = self:GetAbility():GetSpecialValueFor("health_bubble"), target_entindex = self:GetParent():entindex() })
        bubble:SetForwardVector((self:GetParent():GetAbsOrigin() - bubble:GetAbsOrigin()):Normalized())
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_bubble_unit_debuff",
        {
            duration            = self:GetAbility():GetSpecialValueFor("duration_bubble"),
            damage              = self:GetAbility():GetSpecialValueFor("damage_bubble"),
            attack_rate         = self:GetAbility():GetSpecialValueFor("attack_rate"),
            armor_reduction     = self:GetAbility():GetSpecialValueFor("armor_reduction"),
            damage_type         = DAMAGE_TYPE_MAGICAL,
            beetle_entindex     = bubble:entindex()
        })
    end
end

function modifier_hisoka_trap_debuff:OnRefresh()
    if not IsServer() then return end
    self:OnCreated()
end

function modifier_hisoka_trap_debuff:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_hisoka_trap_debuff_movespeed") then
        self:GetParent():RemoveModifierByName("modifier_hisoka_trap_debuff_movespeed")
    end
    if self:GetParent():HasModifier("modifier_hisoka_trap_debuff_attackspeed") then
        self:GetParent():RemoveModifierByName("modifier_hisoka_trap_debuff_attackspeed")
    end
end

function modifier_hisoka_trap_debuff:GetEffectName() return "particles/hisoka/hisoka_bubble_ultimate.vpcf" end
function modifier_hisoka_trap_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_bubble_unit = class({})

function modifier_bubble_unit:IsHidden()     return true end
function modifier_bubble_unit:IsPurgable()   return false end

function modifier_bubble_unit:OnCreated(params)
    if not IsServer() then return end
    self.destroy_attacks            = params.destroy_attacks
    self.target                     = EntIndexToHScript(params.target_entindex)
    self:StartIntervalThink(FrameTime())
end

function modifier_bubble_unit:OnIntervalThink()
    if self.target and not self.target:IsNull() then
        if (self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target)) then
            self:GetParent():ForceKill(false)
            if not self:IsNull() then
                self:Destroy()
            end
        elseif self.target:IsAlive() then
            self:GetParent():SetAbsOrigin(self.target:GetAbsOrigin() + self.target:GetForwardVector() * 64)
            self:GetParent():SetForwardVector((self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
        end
    end
end

function modifier_bubble_unit:OnDestroy()
    if not IsServer() then return end
    if self.target and not self.target:IsNull() and self.target:HasModifier("modifier_bubble_unit_debuff") then
        self.target:RemoveModifierByName("modifier_bubble_unit_debuff")
    end
end

function modifier_bubble_unit:CheckState()
    return
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_MAGIC_IMMUNE]       = true,
    }
end

function modifier_bubble_unit:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }

    return decFuncs
end

function modifier_bubble_unit:GetDisableHealing()
    return 1
end

function modifier_bubble_unit:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end

function modifier_bubble_unit:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_bubble_unit:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_bubble_unit:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_bubble_unit:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_bubble_unit:OnAttacked(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        local new_health = self:GetParent():GetHealth() - 1
        if new_health <= 0 then
            self:GetParent():EmitSound("Hero_Grimstroke.InkCreature.Death")
            self:GetParent():ForceKill(false)
            if not self:IsNull() then
                self:Destroy()
            end
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

modifier_bubble_unit_debuff = class({})

function modifier_bubble_unit_debuff:IsPurgable()     return true end

function modifier_bubble_unit_debuff:OnCreated(params)
    if self:GetAbility() then
        self.armor_reduction    = self:GetAbility():GetSpecialValueFor("armor_reduction")
    else
        self.armor_reduction    = 1
    end

    if not IsServer() then return end
    
    self.damage         = params.damage
    self.attack_rate    = params.attack_rate
    self.damage_type    = params.damage_type
    self.beetle         = EntIndexToHScript(params.beetle_entindex)
    
    self:OnIntervalThink()
    self:StartIntervalThink(self.attack_rate)
end

function modifier_bubble_unit_debuff:OnIntervalThink()
    self:IncrementStackCount()
end

function modifier_bubble_unit_debuff:OnDestroy()
    if not IsServer() then return end
    if self.beetle and not self.beetle:IsNull() and self.beetle:IsAlive() then
        self.beetle:ForceKill(false)
    end
end

function modifier_bubble_unit_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_bubble_unit_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_reduction * self:GetStackCount() * (-1)
end

modifier_hisoka_trap_debuff_movespeed = class({})

function modifier_hisoka_trap_debuff_movespeed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_hisoka_trap_debuff_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end


modifier_hisoka_trap_debuff_attackspeed = class({})

function modifier_hisoka_trap_debuff_attackspeed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_hisoka_trap_debuff_attackspeed:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attackspeed_slow")
end

