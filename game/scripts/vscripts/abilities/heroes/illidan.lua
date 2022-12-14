LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

LinkLuaModifier( "modifier_illidan_dive_shard", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier( "modifier_illidan_dive_movespeed", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illidan_dive_armor", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

illidan_dive = class({})

function illidan_dive:GetIntrinsicModifierName()
    return "modifier_illidan_dive_shard"
end

function illidan_dive:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()
    local target_origin = target:GetAbsOrigin()

    local damage = self:GetSpecialValueFor("damage")

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.7)

    local vector = (target_origin-self:GetCaster():GetOrigin())
    local dist = vector:Length2D() + 30
    vector.z = 0
    vector = vector:Normalized()

    local duration = 0.1

    if dist > 300 then
        duration = 0.3
    end

    print(dist)

    local knockback = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = vector.x,
            direction_y = vector.y,
            distance = dist,
            duration = duration,
            height = 30,
            IsStun = true,
            IsFlail = false,
        }
    )

    self:GetCaster():EmitSound("illidan_blink")

    local particle = ParticleManager:CreateParticle("particles/illidan_scepter_thirst_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    knockback:AddParticle(particle, false, false, -1, false, false)

    local callback = function( bInterrupted )
        if bInterrupted then return end
        target:EmitSound("Hero_Antimage.Attack")
        self:GetCaster():SetForwardVector(vector)
        self:GetCaster():FaceTowards(target:GetAbsOrigin())
        ApplyDamage({ victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })
        if self:GetCaster():HasTalent("special_bonus_birzha_illidan_2") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_illidan_dive_movespeed", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_2", "value2")})
        end
        if self:GetCaster():HasTalent("special_bonus_birzha_illidan_4") then
            target:AddNewModifier(self:GetCaster(), self, "modifier_illidan_dive_armor", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_4", "value2") * (1 - target:GetStatusResistance())})
        end
    end

    knockback:SetEndCallback( callback )
end

modifier_illidan_dive_movespeed = class({})

function modifier_illidan_dive_movespeed:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_illidan_dive_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_2")
end

modifier_illidan_dive_armor = class({})

function modifier_illidan_dive_armor:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_illidan_dive_armor:GetModifierPhysicalArmorBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_4")
end


modifier_illidan_dive_shard = class({})

function modifier_illidan_dive_shard:IsHidden() return true end
function modifier_illidan_dive_shard:IsPurgable() return false end

function modifier_illidan_dive_shard:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_illidan_dive_shard:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    if not params.attacker:HasShard() then return end
    if params.no_attack_cooldown then return end

    local cooldown_shard = self:GetAbility():GetSpecialValueFor("cooldown_shard")

    local cooldown = self:GetAbility():GetCooldownTimeRemaining()

    if cooldown - cooldown_shard <= 0 then
        self:GetAbility():EndCooldown()
    else
        self:GetAbility():EndCooldown()
        self:GetAbility():StartCooldown(cooldown - cooldown_shard)
    end

end

LinkLuaModifier( "modifier_illidan_KidsHit_scepter", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

illidan_sweeping_strike = class({})

function illidan_sweeping_strike:GetCastRange(location, target)
    if IsClient() then
        return self:GetSpecialValueFor("range") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_1")
    end
end

function illidan_sweeping_strike:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("illidan_force")

    local range = self:GetSpecialValueFor("range") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_1")
    local speed = 1200
    local point = self:GetCursorPosition()

    local distance = (point - self:GetCaster():GetAbsOrigin()):Length2D()
    local direction = (point - self:GetCaster():GetAbsOrigin()):Normalized()

    if distance > range then
        point = self:GetCaster():GetAbsOrigin() + (direction * range)
    end

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.7)
    
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_illidan_KidsHit_scepter", { duration = (point - self:GetCaster():GetAbsOrigin()):Length2D() / 1200, x = point.x, y = point.y, z = point.z })
    
    local vDirection = point - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()

    local info = 
    {
        EffectName = "",
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(), 
        fStartRadius = 150,
        fEndRadius = 150,
        vVelocity = vDirection * (speed - 200),
        fDistance = (point - self:GetCaster():GetAbsOrigin()):Length2D(),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
    }

    ProjectileManager:CreateLinearProjectile( info )
end

function illidan_sweeping_strike:OnProjectileHit(target, vLocation)
    if target == nil then return end
    local particle = ParticleManager:CreateParticle("particles/illidan_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
    self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
end 

modifier_illidan_KidsHit_scepter = class({})

function modifier_illidan_KidsHit_scepter:IsPurgable() return false end
function modifier_illidan_KidsHit_scepter:IsHidden() return true end
function modifier_illidan_KidsHit_scepter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_illidan_KidsHit_scepter:IgnoreTenacity() return true end
function modifier_illidan_KidsHit_scepter:IsMotionController() return true end
function modifier_illidan_KidsHit_scepter:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_illidan_KidsHit_scepter:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
end

function modifier_illidan_KidsHit_scepter:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        self.velocity = 1200
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_illidan_KidsHit_scepter:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_illidan_KidsHit_scepter:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_illidan_KidsHit_scepter:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
end

function modifier_illidan_KidsHit_scepter:GetEffectName()
    return "particles/illidan_scepter_thirst_owner.vpcf"
end

function modifier_illidan_KidsHit_scepter:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end





LinkLuaModifier( "modifier_illidan_abomination", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illidan_abomination_buff", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illidan_abomination_visible", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illidan_abomination_stack", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)

illidan_abomination = class({})

function illidan_abomination:OnUpgrade()
    if not IsServer() then return end
    local ability = self:GetCaster():FindAbilityByName("illidan_abomination_active")
    if ability and not ability:IsTrained() then
        ability:SetLevel(1)
    end
end

function illidan_abomination:GetIntrinsicModifierName()
    return "modifier_illidan_abomination"
end

modifier_illidan_abomination = class({})

function modifier_illidan_abomination:IsHidden() return self:GetStackCount() == 0 end
function modifier_illidan_abomination:IsPurgable() return false end

function modifier_illidan_abomination:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_illidan_abomination:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local max_effects = self:GetAbility():GetSpecialValueFor("max_effects")

    local modifiers = params.target:FindAllModifiersByName("modifier_illidan_abomination_stack")

    if #modifiers >= max_effects then
        local modifiers_old = {}
        for _, mod in pairs(modifiers) do
            table.insert(modifiers_old, mod)
        end
        table.sort( modifiers_old, function(x,y) return y:GetRemainingTime() < x:GetRemainingTime() end )
        if modifiers_old[#modifiers_old] and not modifiers_old[#modifiers_old]:IsNull() then
            modifiers_old[#modifiers_old]:Destroy()
        end
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_illidan_abomination_stack", {duration = duration * (1-params.target:GetStatusResistance())})
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_illidan_abomination_visible", {duration = duration * (1-params.target:GetStatusResistance())})
    else
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_illidan_abomination_stack", {duration = duration * (1-params.target:GetStatusResistance())})
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_illidan_abomination_visible", {duration = duration * (1-params.target:GetStatusResistance())})
    end      
end

modifier_illidan_abomination_visible = class({})

function modifier_illidan_abomination_visible:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.damage_think = 0
    self.particle = ParticleManager:CreateParticle("particles/illidan_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, false, true)
    self:StartIntervalThink(FrameTime())
end

function modifier_illidan_abomination_visible:OnIntervalThink()
    if not IsServer() then return end
    local modifiers = self:GetParent():FindAllModifiersByName("modifier_illidan_abomination_stack")
    self:SetStackCount(#modifiers)

    if self.particle then
        ParticleManager:SetParticleControl(self.particle, 1, Vector(0,#modifiers,0))
    end

    self.damage_think = self.damage_think + FrameTime()

    if self.damage_think >= 1 then
        self.damage_think = 0
        ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage * (self:GetStackCount()), damage_type = DAMAGE_TYPE_MAGICAL })
    end
end

function modifier_illidan_abomination_visible:RemoveCaster()
    if not IsServer() then return end

    local modifiers = self:GetParent():FindAllModifiersByName("modifier_illidan_abomination_stack")
    local damage = 0

    for _, mod in pairs(modifiers) do
        damage = damage + (mod:GetRemainingTime() * self.damage)
        mod:Destroy()
    end

    local particle = ParticleManager:CreateParticle("particles/illidan_explosion_ske.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

    self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Tick")

    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
    self:Destroy()
end

function modifier_illidan_abomination_visible:GetEffectName()
    return "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf"
end

function modifier_illidan_abomination_visible:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_illidan_abomination_stack = class({})

function modifier_illidan_abomination_stack:IsHidden() return true end
function modifier_illidan_abomination_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_illidan_abomination_stack:OnCreated()
    if not IsServer() then return end
    local modifier_illidan_abomination = self:GetCaster():FindModifierByName("modifier_illidan_abomination")
    if modifier_illidan_abomination then
        modifier_illidan_abomination:IncrementStackCount()
    end
end

function modifier_illidan_abomination_stack:OnDestroy()
    if not IsServer() then return end
    local modifier_illidan_abomination = self:GetCaster():FindModifierByName("modifier_illidan_abomination")
    if modifier_illidan_abomination then
        modifier_illidan_abomination:DecrementStackCount()
    end
end

illidan_abomination_active = class({})

function illidan_abomination_active:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_8")
end

function illidan_abomination_active:OnSpellStart()
    if not IsServer() then return end

    local stacks = 0

    local duration = self:GetSpecialValueFor("duration")

    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
    for _, unit in pairs(units) do
        local modifier_illidan_abomination_visible = unit:FindModifierByName("modifier_illidan_abomination_visible")
        if modifier_illidan_abomination_visible then
            stacks = stacks + modifier_illidan_abomination_visible:GetStackCount()
            modifier_illidan_abomination_visible:RemoveCaster()
        end
    end

    if stacks > 0 then
        local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_illidan_abomination_buff", {duration = duration, bonus_damage = stacks})
    end
end

modifier_illidan_abomination_buff = class({})

function modifier_illidan_abomination_buff:OnCreated(params)
    if not IsServer() then return end
    self.bonus_damage = params.bonus_damage * (self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_7"))
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_illidan_abomination_buff:AddCustomTransmitterData()
    return 
    {
        bonus_damage = self.bonus_damage,
    }
end

function modifier_illidan_abomination_buff:HandleCustomTransmitterData( data )
    self.bonus_damage = data.bonus_damage
end

function modifier_illidan_abomination_buff:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_illidan_abomination_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_illidan_abomination_buff:GetModifierDamageOutgoing_Percentage()
    return self.bonus_damage
end

function modifier_illidan_abomination_buff:GetEffectName()
    return "particles/illidan/illidan_ozverenie_buff.vpcf"
end

function modifier_illidan_abomination_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_illidan_fly_arc", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_illidan_metamorph", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illidan_metamorph_cast", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_illidan_metamorph_thinker", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_illidan_metamorph_fly", "abilities/heroes/illidan", LUA_MODIFIER_MOTION_BOTH)

illidan_metamorph = class({})

function illidan_metamorph:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function illidan_metamorph:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_3")
end

function illidan_metamorph:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local fly_duration = self:GetSpecialValueFor( "fly_duration" )
    local cast_duration = self:GetSpecialValueFor("cast_duration")
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("Hero_Terrorblade.Metamorphosis")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_illidan_metamorph", {duration = duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_illidan_metamorph_thinker", {duration = cast_duration + fly_duration, x = point.x, y = point.y})
    caster:AddNewModifier( caster, self, "modifier_illidan_metamorph_cast", { duration = cast_duration, x = point.x, y = point.y })
    self.point = point
end

modifier_illidan_metamorph_cast = class({})

function modifier_illidan_metamorph_cast:IsPurgable() return false end
function modifier_illidan_metamorph_cast:IsHidden() return true end

function modifier_illidan_metamorph_cast:OnCreated()
    if not IsServer() then return end
    Timers:CreateTimer(0.05, function()
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)
    end)
end

function modifier_illidan_metamorph_cast:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

function modifier_illidan_metamorph_cast:OnDestroy()
    if not IsServer() then return end
    local fly_duration = self:GetAbility():GetSpecialValueFor( "fly_duration" )
    self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_illidan_metamorph_fly", { duration = fly_duration, x = self:GetAbility().point.x, y = self:GetAbility().point.y })
end

modifier_illidan_metamorph = class({})

function modifier_illidan_metamorph:IsPurgable() return false end

function modifier_illidan_metamorph:OnCreated()
    self.scepter = self:GetCaster():HasScepter()
end

function modifier_illidan_metamorph:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
    }

    return funcs
end

function modifier_illidan_metamorph:GetModifierModelChange()
    return "models/heroes/terrorblade/terrorblade.vmdl"
end

function modifier_illidan_metamorph:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_illidan_metamorph:GetModifierExtraHealthPercentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_illidan_6")
end

function modifier_illidan_metamorph:CheckState()
    if not self.scepter then return end
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

modifier_illidan_metamorph_fly = class({})

function modifier_illidan_metamorph_fly:IsHidden()
    return true
end

function modifier_illidan_metamorph_fly:IsPurgable()
    return false
end

function modifier_illidan_metamorph_fly:OnCreated( kv )
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )

    if not IsServer() then return end

    self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

    local arc_height = 2000
    self.point = Vector( kv.x, kv.y, 0 )
    self.interrupted = false

    local arc = self.parent:AddNewModifier(
        self.parent, -- player source
        self:GetAbility(), -- ability source
        "modifier_illidan_fly_arc", -- modifier name
        {
            duration = kv.duration,
            height = arc_height,
            isStun = false,
            isForward = true,
        }
    )

    arc:SetEndCallback(function( interrupted )
        if interrupted then
            self.interrupted = interrupted
            self:Destroy()
        end
    end)

    self:StartIntervalThink( kv.duration/2 )
end

function modifier_illidan_metamorph_fly:OnDestroy()
    if not IsServer() then return end

    if self.interrupted then return end

    self:PlayEffects( self.point, self.radius )

    local enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), self.point, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

    for _,enemy in pairs(enemies) do
        self:TalentSkverna(enemy)
        enemy:AddNewModifier( self.parent, self.ability, "modifier_birzha_stunned", { duration = self.duration * (1-enemy:GetStatusResistance()) })
    end

    self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3_END)

    FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetOrigin(), false )

    GridNav:DestroyTreesAroundPoint( self.point, self.radius/2, false )
end


function modifier_illidan_metamorph_fly:TalentSkverna(target)
    local illidan_abomination = self:GetCaster():FindAbilityByName("illidan_abomination")
    if illidan_abomination and illidan_abomination:GetLevel() > 0 and self:GetCaster():HasTalent("special_bonus_birzha_illidan_5") then
        local duration = illidan_abomination:GetSpecialValueFor("duration")
        local max_effects = illidan_abomination:GetSpecialValueFor("max_effects")

        for i = 1, max_effects do
            local modifiers = target:FindAllModifiersByName("modifier_illidan_abomination_stack")
            if #modifiers >= max_effects then
                local modifiers_old = {}
                for _, mod in pairs(modifiers) do
                    table.insert(modifiers_old, mod)
                end
                table.sort( modifiers_old, function(x,y) return y:GetRemainingTime() < x:GetRemainingTime() end )
                if modifiers_old[#modifiers_old] and not modifiers_old[#modifiers_old]:IsNull() then
                    modifiers_old[#modifiers_old]:Destroy()
                end
                target:AddNewModifier(self:GetCaster(), illidan_abomination, "modifier_illidan_abomination_stack", {duration = duration * (1-target:GetStatusResistance())})
                target:AddNewModifier(self:GetCaster(), illidan_abomination, "modifier_illidan_abomination_visible", {duration = duration * (1-target:GetStatusResistance())})
            else
                target:AddNewModifier(self:GetCaster(), illidan_abomination, "modifier_illidan_abomination_stack", {duration = duration * (1-target:GetStatusResistance())})
                target:AddNewModifier(self:GetCaster(), illidan_abomination, "modifier_illidan_abomination_visible", {duration = duration * (1-target:GetStatusResistance())})
            end
        end
    end   
end

function modifier_illidan_metamorph_fly:PlayEffects( point, radius )
    point = GetGroundPosition( point, self.parent )
    local effect_cast = ParticleManager:CreateParticle( "particles/illidan_metamorph_landing.vpcf", PATTACH_WORLDORIGIN, self.parent )
    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, point )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( point, "Hero_Dawnbreaker.Solar_Guardian.Impact", self.parent )
end

function modifier_illidan_metamorph_fly:OnIntervalThink()
    self.point.z = self.parent:GetOrigin().z
    self.parent:SetOrigin( self.point )
end

modifier_illidan_fly_arc = class({})

function modifier_illidan_fly_arc:IsHidden()
    return true
end

function modifier_illidan_fly_arc:IsDebuff()
    return false
end

function modifier_illidan_fly_arc:IsStunDebuff()
    return false
end

function modifier_illidan_fly_arc:IsPurgable()
    return true
end

function modifier_illidan_fly_arc:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_illidan_fly_arc:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_illidan_fly_arc:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_illidan_fly_arc:OnRemoved()
end

function modifier_illidan_fly_arc:OnDestroy()
    if not IsServer() then return end

    -- preserve height
    local pos = self:GetParent():GetOrigin()

    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )

    -- preserve height if has end offset
    if self.end_offset~=0 then
        self:GetParent():SetOrigin( pos )
    end

    if self.endCallback then
        self.endCallback( self.interrupted )
    end

    FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetOrigin(), false )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_illidan_fly_arc:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    return funcs
end

function modifier_illidan_fly_arc:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_illidan_fly_arc:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = self.isStun or false,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_illidan_fly_arc:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    -- set relative position
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_illidan_fly_arc:UpdateVerticalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    local pos = me:GetOrigin()
    local time = self:GetElapsedTime()

    -- set relative position
    local height = pos.z
    local speed = self:GetVerticalSpeed( time )
    pos.z = height + speed * dt
    me:SetOrigin( pos )

    if not self.fix_duration then
        local ground = GetGroundHeight( pos, me ) + self.end_offset
        if pos.z <= ground then

            -- below ground, set height as ground then destroy
            pos.z = ground
            me:SetOrigin( pos )
            self:Destroy()
        end
    end
end

function modifier_illidan_fly_arc:OnHorizontalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_illidan_fly_arc:OnVerticalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

--------------------------------------------------------------------------------
-- Motion Helper
function modifier_illidan_fly_arc:SetJumpParameters( kv )
    self.parent = self:GetParent()

    -- load types
    self.fix_end = true
    self.fix_duration = true
    self.fix_height = true
    if kv.fix_end then
        self.fix_end = kv.fix_end==1
    end
    if kv.fix_duration then
        self.fix_duration = kv.fix_duration==1
    end
    if kv.fix_height then
        self.fix_height = kv.fix_height==1
    end

    -- load other types
    self.isStun = kv.isStun==1
    self.isRestricted = kv.isRestricted==1
    self.isForward = kv.isForward==1
    self.activity = kv.activity or 0
    self:SetStackCount( self.activity )

    -- load direction
    if kv.target_x and kv.target_y then
        local origin = self.parent:GetOrigin()
        local dir = Vector( kv.target_x, kv.target_y, 0 ) - origin
        dir.z = 0
        dir = dir:Normalized()
        self.direction = dir
    end
    if kv.dir_x and kv.dir_y then
        self.direction = Vector( kv.dir_x, kv.dir_y, 0 ):Normalized()
    end
    if not self.direction then
        self.direction = self.parent:GetForwardVector()
    end

    -- load horizontal data
    self.duration = kv.duration
    self.distance = kv.distance
    self.speed = kv.speed
    if not self.duration then
        self.duration = self.distance/self.speed
    end
    if not self.distance then
        self.speed = self.speed or 0
        self.distance = self.speed*self.duration
    end
    if not self.speed then
        self.distance = self.distance or 0
        self.speed = self.distance/self.duration
    end

    -- load vertical data
    self.height = kv.height or 0
    self.start_offset = kv.start_offset or 0
    self.end_offset = kv.end_offset or 0

    -- calculate height positions
    local pos_start = self.parent:GetOrigin()
    local pos_end = pos_start + self.direction * self.distance
    local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
    local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
    local height_max

    -- determine jumping height if not fixed
    if not self.fix_height then
    
        -- ideal height is proportional to max distance
        self.height = math.min( self.height, self.distance/4 )
    end

    -- determine height max
    if self.fix_end then
        height_end = height_start
        height_max = height_start + self.height
    else
        -- calculate height
        local tempmin, tempmax = height_start, height_end
        if tempmin>tempmax then
            tempmin,tempmax = tempmax, tempmin
        end
        local delta = (tempmax-tempmin)*2/3

        height_max = tempmin + delta + self.height
    end

    -- set duration
    if not self.fix_duration then
        self:SetDuration( -1, false )
    else
        self:SetDuration( self.duration, true )
    end

    -- calculate arc
    self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_illidan_fly_arc:Jump()
    -- apply horizontal motion
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end

    -- apply vertical motion
    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end
end

function modifier_illidan_fly_arc:InitVerticalArc( height_start, height_max, height_end, duration )
    local height_end = height_end - height_start
    local height_max = height_max - height_start

    -- fail-safe1: height_max cannot be smaller than height delta
    if height_max<height_end then
        height_max = height_end+0.01
    end

    -- fail-safe2: height-max must be positive
    if height_max<=0 then
        height_max = 0.01
    end

    -- math magic
    local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
    self.const1 = 4*height_max*duration_end/duration
    self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_illidan_fly_arc:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_illidan_fly_arc:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

--------------------------------------------------------------------------------
-- Helper
function modifier_illidan_fly_arc:SetEndCallback( func )
    self.endCallback = func
end

modifier_illidan_metamorph_thinker = class({})

function modifier_illidan_metamorph_thinker:IsPurgable() return false end

function modifier_illidan_metamorph_thinker:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    self.point = Vector( kv.x, kv.y, 0 )
    self:PlayEffects( self.point, self.radius )
end

function modifier_illidan_metamorph_thinker:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetOrigin(), false )
    StopSoundOn( "Hero_Dawnbreaker.Solar_Guardian.Channel", self:GetParent() )
    StopSoundOn( "Hero_Dawnbreaker.Solar_Guardian.Target", self:GetParent() )
end

function modifier_illidan_metamorph_thinker:PlayEffects( point, radius )
    point = GetGroundPosition( point, self.parent )
    local effect_cast = ParticleManager:CreateParticle( "particles/illidan_solar_guardian_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, point )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
    self:AddParticle( effect_cast, false, false, -1, false, false )
    self:GetParent():EmitSound("Hero_Dawnbreaker.Solar_Guardian.Channel")
    EmitSoundOnLocationWithCaster( point, "Hero_Dawnbreaker.Solar_Guardian.Target", self:GetParent() )
end

