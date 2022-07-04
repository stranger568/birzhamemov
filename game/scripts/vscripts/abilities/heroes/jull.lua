LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_jull_crive_realy_thinker", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_crive_realy_thinker_debuff", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_jull_light_future_passive_charge", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_crive_realy_stack", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

jull_crive_realy = class({})

function jull_crive_realy:GetVectorTargetRange()
    return 500
end

function jull_crive_realy:GetIntrinsicModifierName()
    return "modifier_jull_crive_realy_stack"
end

modifier_jull_crive_realy_stack = class({})

function modifier_jull_crive_realy_stack:IsHidden()
    return false
end

function modifier_jull_crive_realy_stack:IsPurgable()
    return false
end

function modifier_jull_crive_realy_stack:DestroyOnExpire()
    return false
end

function modifier_jull_crive_realy_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_3")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_jull_crive_realy_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_3")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_jull_crive_realy_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_jull_crive_realy_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_jull_crive_realy_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_jull_crive_realy_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_3")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function jull_crive_realy:OnVectorCastStart(vStartLocation, vDirection)
    local vector_start = self:GetVectorPosition()
    local vector_end = self:GetVector2Position()
    local distance = (vector_end - vector_start):Length2D()
    local min_radius = self:GetSpecialValueFor("min_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_7", "value")
    local max_radius = self:GetSpecialValueFor("max_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_7", "value")
    local radius = min_radius

    if distance <= min_radius then
        radius = min_radius
    elseif distance >= max_radius then
        radius = max_radius
    else
        radius = distance
    end

    local min_duration = self:GetSpecialValueFor("min_duration")
    local max_duration = self:GetSpecialValueFor("max_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_7", "value2")

    local min_damage = self:GetSpecialValueFor("min_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_2")
    local max_damage = self:GetSpecialValueFor("max_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_2")

    local min_slow = self:GetSpecialValueFor("min_slow")
    local max_slow = self:GetSpecialValueFor("max_slow")

    local bonus_pct = math.min(1,radius/max_radius)
    local damage = math.max(min_damage, max_damage * (1 - bonus_pct) )
    local duration = math.max(min_duration, max_duration*bonus_pct)
    local slow = math.max(min_slow, max_slow*bonus_pct)

    self:GetCaster():EmitSound("jull_ring")

    CreateModifierThinker( self:GetCaster(), self, "modifier_jull_crive_realy_thinker", { damage = damage, duration = duration, slow = slow, radius = radius}, GetGroundPosition(vector_start, self:GetCaster()), self:GetCaster():GetTeamNumber(), false )
end

modifier_jull_crive_realy_thinker = class({})

function modifier_jull_crive_realy_thinker:IsPurgable() return false end
function modifier_jull_crive_realy_thinker:IsHidden() return true end

function modifier_jull_crive_realy_thinker:OnCreated(data)
    self.damage = data.damage
    self.slow = data.slow
    self.duration = data.duration
    self.radius = data.radius
    if not IsServer() then return end
    local items_cooldown = self:GetAbility():GetSpecialValueFor("items_cooldown")
    self.particle = ParticleManager:CreateParticle("particles/items4_fx/seer_stone.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.duration+0.5, self.radius, 0))
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
    for _,enemy in pairs(enemies) do
        for i = 0, 5 do 
            local item = enemy:GetItemInSlot(i)
            if item then
                if not item:IsCooldownReady() then
                    item:StartCooldown(item:GetCooldownTimeRemaining() + items_cooldown)
                end
            end        
        end
    end

end

function modifier_jull_crive_realy_thinker:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jull_crive_realy_thinker_debuff", {duration = 0.5, slow = self.slow})
    end
end

function modifier_jull_crive_realy_thinker:OnDestroy()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
        local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl( particle, 1, enemy:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( particle )

        enemy:EmitSound("jull_ring_damage")

        for i=1,2 do
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jull_light_future_passive_charge", {duration = 1.5})
        end
    end
end

modifier_jull_crive_realy_thinker_debuff = class({})

function modifier_jull_crive_realy_thinker_debuff:IsPurgable() return false end
function modifier_jull_crive_realy_thinker_debuff:IsPurgeException() return false end

function modifier_jull_crive_realy_thinker_debuff:OnCreated(data)
    if not IsServer() then return end
    if data.slow then
        self:SetStackCount(math.floor(data.slow))
    end
end

function modifier_jull_crive_realy_thinker_debuff:DeclareFunctions() return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE

} end

function modifier_jull_crive_realy_thinker_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * -1
end

function modifier_jull_crive_realy_thinker_debuff:GetModifierPercentageCasttime()
    return self:GetStackCount() * -1
end

function modifier_jull_crive_realy_thinker_debuff:GetModifierTurnRate_Percentage()
    return self:GetStackCount() * -1
end

LinkLuaModifier("modifier_jull_choronostasis_debuff", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_choronostasis_buff", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_choronostasis_stack", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

jull_choronostasis = class({})

function jull_choronostasis:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    if self:GetCaster():HasTalent("special_bonus_birzha_jull_8") then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return behavior
end

function jull_choronostasis:GetAOERadius()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_jull_8")
end

function jull_choronostasis:GetIntrinsicModifierName()
    return "modifier_jull_choronostasis_stack"
end

modifier_jull_choronostasis_stack = class({})

function modifier_jull_choronostasis_stack:IsHidden()
    return false
end

function modifier_jull_choronostasis_stack:IsPurgable()
    return false
end

function modifier_jull_choronostasis_stack:DestroyOnExpire()
    return false
end

function modifier_jull_choronostasis_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_1")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_jull_choronostasis_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_1")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_jull_choronostasis_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_jull_choronostasis_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_jull_choronostasis_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_jull_choronostasis_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_1")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end











function jull_choronostasis:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_4", "value")
end


function jull_choronostasis:OnSpellStart(new_target)
    if not IsServer() then return end
    local target = self:GetCursorTarget()



    if new_target then
        target = new_target
    end

    local teammate = target:GetTeamNumber() == self:GetCaster():GetTeamNumber()

    local stun_duration = self:GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_4", "value2")
    local shield_duration = self:GetSpecialValueFor("shield_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_jull_4", "value2")

    if teammate then
        target:AddNewModifier(self:GetCaster(), self, "modifier_jull_choronostasis_buff", {duration = shield_duration})
        if self:GetCaster():HasTalent("special_bonus_birzha_jull_8") then
            local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_jull_8"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
            for _, target_table in pairs(targets) do
                target_table:AddNewModifier(self:GetCaster(), self, "modifier_jull_choronostasis_buff", {duration = shield_duration})
            end
        end
    else
        if target:TriggerSpellAbsorb( self ) then
            return
        end
        target:AddNewModifier(self:GetCaster(), self, "modifier_jull_choronostasis_debuff", {duration = stun_duration * (1 - target:GetStatusResistance())})
        if self:GetCaster():HasTalent("special_bonus_birzha_jull_8") then
            local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_jull_8"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
            for _, target_table in pairs(targets) do
                target_table:AddNewModifier(self:GetCaster(), self, "modifier_jull_choronostasis_debuff", {duration = stun_duration * (1 - target:GetStatusResistance())})
            end
        end
    end

    if new_target == nil then
        for i=1,2 do
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jull_light_future_passive_charge", {duration = 1})
        end
    end

    self:GetCaster():EmitSound("jull_chronostasis")
end

modifier_jull_choronostasis_debuff = class({})

function modifier_jull_choronostasis_debuff:IsPurgable() return false end

function modifier_jull_choronostasis_debuff:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/jull/shield_chrono.vpcf", PATTACH_CENTER_FOLLOW , self:GetParent() )
    ParticleManager:SetParticleControlEnt(  self.particle, 0, self:GetParent(), PATTACH_CENTER_FOLLOW , nil, self:GetParent():GetOrigin(), true )
    ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControl( self.particle, 9, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.particle, 10, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.particle, 11, Vector( 1, 0, 0 ) )
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_jull_choronostasis_debuff:DeclareFunctions() return {
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
} end

function modifier_jull_choronostasis_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("resist_magic_debuff")
end

function modifier_jull_choronostasis_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
    }

    return state
end

function modifier_jull_choronostasis_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_DISABLED
end

function modifier_jull_choronostasis_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_jull_choronostasis_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_jull_choronostasis_buff = class({})

function modifier_jull_choronostasis_buff:IsPurgable() return false end

function modifier_jull_choronostasis_buff:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/jull/shield_chrono.vpcf", PATTACH_CENTER_FOLLOW , self:GetParent() )
    ParticleManager:SetParticleControlEnt(  self.particle, 0, self:GetParent(), PATTACH_CENTER_FOLLOW , nil, self:GetParent():GetOrigin(), true )
    ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControl( self.particle, 9, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.particle, 10, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.particle, 11, Vector( 1, 0, 0 ) )
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_jull_choronostasis_buff:DeclareFunctions() return {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
} end

function modifier_jull_choronostasis_buff:GetModifierIncomingDamage_Percentage()
    if self:GetCaster():HasShard() then
        return self:GetAbility():GetSpecialValueFor("resistance") - 20
    end
    return self:GetAbility():GetSpecialValueFor("resistance")
end

function modifier_jull_choronostasis_buff:GetModifierStatusResistanceStacking()
    return self:GetAbility():GetSpecialValueFor("status_resistance")
end

LinkLuaModifier("modifier_jull_in_time", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_in_time_buff", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

jull_in_time = class({})

function jull_in_time:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level) + (self:GetCaster():GetMaxMana() / 100 * self:GetSpecialValueFor("manacost_percentage"))
end

function jull_in_time:GetIntrinsicModifierName()
    return "modifier_jull_in_time_buff"
end

modifier_jull_in_time_buff = class({})

function modifier_jull_in_time_buff:IsHidden() return true end
function modifier_jull_in_time_buff:IsPurgable() return false end
function modifier_jull_in_time_buff:OnCreated()
    if not IsServer() then return end
    self.rotate = false
end
function modifier_jull_in_time_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_jull_in_time_buff:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:IsToggle() or hAbility:IsItem() then
            return 0
        end

        if self:GetAbility():GetLevel() >= 4 then
            if hAbility == self:GetAbility() then
                self.rotate = true
            else
                self.rotate = false
            end
        end
    end

    return 0
end

function modifier_jull_in_time_buff:GetModifierIgnoreCastAngle(params)
    if self.rotate then
        return 1
    else
        return 0
    end
end

function jull_in_time:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("blink_range")

    local direction = (point - origin)
    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end

    if self:GetLevel() >= 3 then
        self:AddMod()
    end

    local particle_one = ParticleManager:CreateParticle( "particles/econ/events/fall_2021/blink_dagger_fall_2021_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    EmitSoundOnLocationWithCaster( origin, "Blink_Layer.Overwhelming", self:GetCaster() )

    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )

    local particle_two = ParticleManager:CreateParticle( "particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Blink_Layer.Overwhelming", self:GetCaster() )

    self:AddMod()
end

function jull_in_time:AddMod()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local particle = ParticleManager:CreateParticle( "particles/jull/blink_damage_radius.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector(radius, radius, radius) )
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_jull_in_time", {duration = duration})
        for i=1,2 do
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jull_light_future_passive_charge", {duration = 1})
        end
    end
end

modifier_jull_in_time = class({})

function modifier_jull_in_time:IsPurgable() return true end

function modifier_jull_in_time:OnCreated()
    self.slow = self:GetAbility():GetSpecialValueFor("slow") 
    self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
    if not IsServer() then return end
    self:IncrementStackCount() 
end

function modifier_jull_in_time:OnRefresh()
    self:OnCreated()
end

function modifier_jull_in_time:DeclareFunctions() 
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    } 
end

function modifier_jull_in_time:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * self.slow
end

function modifier_jull_in_time:GetModifierMagicalResistanceBonus()
    return self:GetStackCount() * self.magic_resistance
end

LinkLuaModifier("modifier_jull_light_future_passive", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_light_future_laser", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_light_future_laser_debuff", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

jull_light_future = class({})

function jull_light_future:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level) + (self:GetCaster():GetMana() / 100 * self:GetSpecialValueFor("manacost_percentage"))
end

function jull_light_future:GetIntrinsicModifierName()
    return "modifier_jull_light_future_passive"
end

function jull_light_future:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local direction = (point - self:GetCaster():GetAbsOrigin()):Normalized()
    local point_spawn = self:GetCaster():GetAbsOrigin() + direction * 150
    
    local modifiers = self:GetCaster():FindAllModifiersByName("modifier_jull_light_future_passive_charge")
    for id, mod in pairs(modifiers) do
        if id == #modifiers then
            mod:Destroy()
        end
    end

    self:CreateLaser(point_spawn, direction)
end

function jull_light_future:CreateLaser(point, direction)
    if not IsServer() then return end
    local laser = CreateUnitByName("npc_dota_companion", point, false, nil, nil, self:GetCaster():GetTeam())
    laser:SetAbsOrigin(laser:GetAbsOrigin() + Vector(0,0,125))
    local mod = laser:AddNewModifier(self:GetCaster(), self, "modifier_jull_light_future_laser", {})
    if mod then
        mod.direction = direction
    end
end

modifier_jull_light_future_laser = class({})

function modifier_jull_light_future_laser:IsHidden() return true end
function modifier_jull_light_future_laser:IsPurgable() return false end

function modifier_jull_light_future_laser:CheckState()
    local state = {
        [MODIFIER_STATE_NO_TEAM_MOVE_TO]    = true,
        [MODIFIER_STATE_NO_TEAM_SELECT]     = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE]      = true,
        [MODIFIER_STATE_MAGIC_IMMUNE]       = true,
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_UNSELECTABLE]       = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP]     = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
    }
    return state
end

function modifier_jull_light_future_laser:OnCreated()
    if not IsServer() then return end
    self.direction = nil

    self.wisp_particle = ParticleManager:CreateParticle( "particles/jull/future_shpereambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    self:AddParticle(self.wisp_particle, false, false, -1, false, false)

    self.width = self:GetAbility():GetSpecialValueFor("width")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")

    self:StartIntervalThink(0.35)
end

function modifier_jull_light_future_laser:OnIntervalThink()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    if self.direction == nil then
        self:Destroy()
        return
    end

    local flag = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_jull_5") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_CLOSEST, false )
    if #enemies == 0 then
        self:Destroy()
        return
    end

    self.point_end = CreateUnitByName("npc_dota_companion", enemies[1]:GetAbsOrigin(), false, nil, nil, self:GetCaster():GetTeamNumber())
    self.point_end:AddNewModifier(self:GetCaster(), self, "modifier_phased", {})
    self.point_end:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {})
    self.point_end:AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {})
    self.point_end:SetAbsOrigin(self.point_end:GetAbsOrigin() + Vector(0,0,125))

    self:GetParent():EmitSound("jull_attack")

    local units = FindUnitsInLine(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), enemies[1]:GetAbsOrigin(), self:GetCaster(), self.width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag)
    for _, enemy in pairs(units) do

        local damage = self:GetAbility():GetSpecialValueFor("base_damage") + (self:GetCaster():GetIntellect() * 0.7)
        local modifier = self:GetCaster():FindModifierByName("modifier_jull_light_future_passive")
        if modifier then
            damage = damage + (self:GetAbility():GetLevelSpecialValueFor("damage_intellect", modifier:GetStackCount()) + (self:GetCaster():GetIntellect() / 100 * modifier:GetStackCount()) )
        end

        ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_jull_light_future_laser_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_slow")})

        local nDamageFX = ParticleManager:CreateParticle( "particles/creatures/boss_tinker/boss_tinker_laser_enemy.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nDamageFX, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nDamageFX )
    end

    self.particle = ParticleManager:CreateParticle( "particles/creatures/boss_tinker/boss_tinker_mega_laser.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.particle, 1, self.point_end, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.point_end:GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true )
    ParticleManager:SetParticleFoWProperties( self.particle, 0, 1, self.width * 1.5 )
    ParticleManager:SetParticleControlEnt( self.particle, 9, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
    self:AddParticle(self.particle, false, false, -1, false, false)

    self:SetDuration(0.2, true)
end

function modifier_jull_light_future_laser:OnDestroy()
    if not IsServer() then return end
    if self.point_end then
        if not self.point_end:IsNull() then
            self.point_end:Destroy()
        end
    end
    self:GetParent():Destroy()
end

modifier_jull_light_future_passive = class({})

function modifier_jull_light_future_passive:IsPurgable()
    return false
end

function modifier_jull_light_future_passive:OnCreated()
    if not IsServer() then return end
    local ability = self:GetCaster():FindAbilityByName("jull_light_future")
    if ability then
        ability:SetCurrentAbilityCharges(0)
    end
    self:StartIntervalThink(FrameTime())
end

function modifier_jull_light_future_passive:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetCaster():FindAbilityByName("jull_light_future")
    if ability then
        if ability:GetCurrentAbilityCharges() == 0 then
            ability:SetActivated(false)
        else
            ability:SetActivated(true)
        end
    end
end

function modifier_jull_light_future_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED

    }
    return funcs
end

function modifier_jull_light_future_passive:GetModifierDamageOutgoing_Percentage()
    --if IsClient() then return 0 end
    return -100
end

function modifier_jull_light_future_passive:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()

    if attacker ~= keys.attacker then
        return
    end

    local target = keys.target

    self:GetCaster():EmitSound("jull_attack")

    if self:GetParent():IsIllusion() then return end

    local damage = self:GetAbility():GetSpecialValueFor("base_damage") + (self:GetCaster():GetIntellect() * 0.7)
    damage = damage + (self:GetAbility():GetLevelSpecialValueFor("damage_intellect", self:GetStackCount()) + (self:GetCaster():GetIntellect() / 100 * self:GetStackCount()) )

    ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_jull_light_future_passive:OnAbilityFullyCast( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:GetAbilityName() == "item_refresher" or hAbility:GetAbilityName() == "item_refresher_shard" then
            local ability = self:GetCaster():FindAbilityByName("jull_light_future")
            if ability then
                ability:SetCurrentAbilityCharges(0)
            end
        end

        if hAbility:IsToggle() or hAbility:IsItem() then
            return 0
        end

        if hAbility:GetAbilityName() == "jull_light_future" then return end
        if hAbility:GetAbilityName() == "jull_steal_time" then return end

        local ability = self:GetCaster():FindAbilityByName("jull_light_future")
        if ability then
            ability:SetCurrentAbilityCharges(ability:GetCurrentAbilityCharges() + 1)
            Timers:CreateTimer(1, function()
                if (ability:GetCurrentAbilityCharges() ~= 0) then
                    ability:SetCurrentAbilityCharges(ability:GetCurrentAbilityCharges() - 1)
                end
            end)
        end

        local point = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,RandomInt(-360, 360),0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 150)
        local direction = (point - self:GetCaster():GetAbsOrigin()):Normalized()

        self:GetAbility():CreateLaser(point, direction)
    end

    return 0
end




















modifier_jull_light_future_laser_debuff = class({})

function modifier_jull_light_future_laser_debuff:IsPurgable() return false end
function modifier_jull_light_future_laser_debuff:IsPurgeException() return false end

function modifier_jull_light_future_laser_debuff:DeclareFunctions() return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
} end

function modifier_jull_light_future_laser_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -100
end

modifier_jull_light_future_passive_charge = class({})

function modifier_jull_light_future_passive_charge:IsHidden() return true end
function modifier_jull_light_future_passive_charge:IsPurgable() return false end
function modifier_jull_light_future_passive_charge:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

LinkLuaModifier("modifier_jull_steal_time", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jull_steal_time_stack", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

jull_steal_time = class({})

function jull_steal_time:GetIntrinsicModifierName()
    return "modifier_jull_steal_time_stack"
end

function jull_steal_time:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_jull_steal_time") then
        return "jull/steal_time"
    end
    return "jull/steal_time_off"
end

function jull_steal_time:OnSpellStart()
    if self:GetCaster():HasModifier("modifier_jull_steal_time") then
        self:GetCaster():RemoveModifierByName("modifier_jull_steal_time")
        return
    end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jull_steal_time", {})
end

modifier_jull_steal_time = class({})

function modifier_jull_steal_time:IsHidden() return true end
function modifier_jull_steal_time:RemoveOnDeath() return false end
function modifier_jull_steal_time:IsPurgable() return false end

modifier_jull_steal_time_stack = class({})

function modifier_jull_steal_time_stack:IsPurgable() return false end

function modifier_jull_steal_time_stack:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_HERO_KILLED,
    }

    return decFuncs
end

function modifier_jull_steal_time_stack:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        self:IncrementStackCount()
    end
end





LinkLuaModifier("modifier_jull_portal_backend_buff", "abilities/heroes/jull", LUA_MODIFIER_MOTION_NONE)

jull_portal_backend = class({})

function jull_portal_backend:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level) + (self:GetCaster():GetMaxMana() / 100 * self:GetSpecialValueFor("manacost_percentage"))
end

function jull_portal_backend:GetIntrinsicModifierName()
    return "modifier_jull_portal_backend_buff"
end

function jull_portal_backend:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local chronostasis = self:GetCaster():FindAbilityByName("jull_choronostasis")
    local bonus_intellect = self:GetSpecialValueFor("bonus_intellect")
    local damage_wave = self:GetSpecialValueFor("damage_wave")

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    if chronostasis then
        chronostasis:OnSpellStart(target)
    end

    local damage = self:GetSpecialValueFor("base_damage")

    local modifier = self:GetCaster():FindModifierByName("modifier_jull_steal_time_stack")
    if modifier then
        damage = damage + (modifier:GetStackCount() * self:GetSpecialValueFor("damage_per_charge"))
    end

    ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

    if not target:IsAlive() then
        local modifier = self:GetCaster():FindModifierByName("modifier_jull_portal_backend_buff")
        if modifier then
            modifier:SetStackCount(modifier:GetStackCount() + self:GetSpecialValueFor("bonus_intellect"))
        end
        damage_wave = damage_wave * 2

        if self:GetCaster():HasScepter() then
            local abilities = {
                "jull_crive_realy",
                "jull_choronostasis",
                "jull_in_time",
            }
            for _, abil in pairs(abilities) do
                local abilka = self:GetCaster():FindAbilityByName(abil)
                if abilka then
                    if abilka == "jull_crive_realy" then
                        local modifier_abilka = self:GetCaster():FindModifierByName("modifier_jull_crive_realy_stack")
                        if modifier_abilka then
                            modifier_abilka:SetStackCount(modifier_abilka.max_charges)
                            modifier_abilka:SetDuration( -1, true )
                            modifier_abilka:StartIntervalThink( -1 )
                        end
                    end
                    if abilka == "jull_choronostasis" then
                        local modifier_abilka = self:GetCaster():FindModifierByName("modifier_jull_choronostasis_stack")
                        if modifier_abilka then
                            modifier_abilka:SetStackCount(modifier_abilka.max_charges)
                            modifier_abilka:SetDuration( -1, true )
                            modifier_abilka:StartIntervalThink( -1 )
                        end
                    end
                    abilka:EndCooldown()
                end
            end
        end

    end

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jull_light_future_passive_charge", {duration = 1.5})

    local direction = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/jull/ultimate_effect.vpcf",
        vSpawnOrigin        = target:GetAbsOrigin(),
        fDistance           = 900,
        fStartRadius        = 175,
        fEndRadius          = 175,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 900,
        bProvidesVision     = false,
        ExtraData           = {
            damage = damage_wave,
            target_main = target:entindex()
        }
    }

    self:PlayProjectile( projectile, target )
    target:EmitSound("jull_ultimate_damage")
    ProjectileManager:CreateLinearProjectile(projectile)
end

function jull_portal_backend:PlayProjectile( info, target )
    local particle_start_fx = ParticleManager:CreateParticle("particles/jull/ultimate_effect_2_2021_earth_splitter.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_start_fx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_start_fx, 1, target:GetAbsOrigin() + info.vVelocity)
    ParticleManager:SetParticleControl(particle_start_fx, 3, Vector(0, 0.25, 0))
end

function jull_portal_backend:OnProjectileHit_ExtraData(target, vLocation, table)
    if not IsServer() then return end
    local target_name = EntIndexToHScript(table.target_main)
    print(table.damage)
    if target ~= nil and target ~= target_name then
        for i=1,3 do
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jull_light_future_passive_charge", {duration = 1.5})
        end
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = table.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}) 
    end
end

modifier_jull_portal_backend_buff = class({})

function modifier_jull_portal_backend_buff:IsPurgable() return false end

function modifier_jull_portal_backend_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_jull_portal_backend_buff:GetModifierBonusStats_Intellect()
    return self:GetStackCount()
end