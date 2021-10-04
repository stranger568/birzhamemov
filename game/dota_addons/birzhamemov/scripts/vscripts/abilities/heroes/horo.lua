LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_horo_forest_girl_passive", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_forest_girl_wolf", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_girl = class({}) 

function horo_forest_girl:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function horo_forest_girl:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function horo_forest_girl:GetIntrinsicModifierName()
    return "modifier_horo_forest_girl_passive"
end

function horo_forest_girl:OnSpellStart()
    if not IsServer() then return end
    self.count = self:GetSpecialValueFor( "wolf_count" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_1")
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
        for i = 1, 4 do
            if unit:GetUnitName() == "npc_dota_horo_wolf_"..i and unit:GetOwner() == self:GetCaster() then
                unit:ForceKill(false)               
            end
        end
    end
    for i = 1, self.count do
        local wolf = CreateUnitByName("npc_dota_horo_wolf_"..self:GetLevel(), self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300) + (self:GetCaster():GetRightVector() * 60 * i), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
        wolf:SetOwner(self:GetCaster())
        wolf:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(wolf, wolf:GetAbsOrigin(), true)
        wolves_spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, wolf)
        ParticleManager:ReleaseParticleIndex(wolves_spawn_particle)
        wolf:SetForwardVector(self:GetCaster():GetForwardVector())
        wolf:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_girl_wolf", {} )
    end
    EmitSoundOn("Hero_Lycan.SummonWolves", self:GetCaster())
end

modifier_horo_forest_girl_passive = class({})

function modifier_horo_forest_girl_passive:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_horo_forest_girl_passive:IsHidden()
    return true
end

function modifier_horo_forest_girl_passive:IsPurgable()
    return false
end

function modifier_horo_forest_girl_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    } 
    return funcs
end

function modifier_horo_forest_girl_passive:OnIntervalThink()
    self.evasion = 0
    local trees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetAbsOrigin(), 500, false)
    if #trees > 0 then
        self.evasion = self:GetAbility():GetSpecialValueFor('bonus_evasion')
    end
end

function modifier_horo_forest_girl_passive:GetModifierEvasion_Constant()
    if self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
    return self.evasion
end

horo_forest_girl_form = class({}) 

function horo_forest_girl_form:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function horo_forest_girl_form:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function horo_forest_girl_form:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function horo_forest_girl_form:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function horo_forest_girl_form:OnSpellStart()
    if not IsServer() then return end
    self.duration = self:GetSpecialValueFor( "duration" )
    self.radius = self:GetSpecialValueFor( "radius" )
    self.count = self:GetSpecialValueFor( "wolf_count" )
    local hTarget = self:GetCursorTarget()
    if hTarget == nil or ( hTarget ~= nil and ( not hTarget:TriggerSpellAbsorb( self ) ) ) then
        local vTargetPosition = nil
        if hTarget ~= nil then 
            vTargetPosition = hTarget:GetOrigin()
        else
            vTargetPosition = self:GetCursorPosition()
        end

        local r = self.radius 
        local c = math.sqrt( 2 ) * 0.5 * r 
        local x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
        local y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, vTargetPosition )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 0.0, r, 0.0 ) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        for i = 1,8 do
            CreateTempTree( vTargetPosition + Vector( x_offset[i], y_offset[i], 0.0 ), self.duration )
        end

        for i = 1,8 do
            ResolveNPCPositions( vTargetPosition + Vector( x_offset[i], y_offset[i], 0.0 ), 64.0 )
        end

        for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
            for i = 1, 4 do
                if unit:GetUnitName() == "npc_dota_horo_wolf_"..i and unit:GetOwner() == self:GetCaster() then
                    unit:ForceKill(false)               
                end
            end
        end

        for i = 1, self.count do
            r = 100
            c = math.sqrt( 2 ) * 0.5 * r 
            x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
            y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }
            local wolf = CreateUnitByName("npc_dota_horo_wolf_"..self:GetLevel(), vTargetPosition + Vector( x_offset[i*2], y_offset[i*2], 0.0 ), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
            wolf:SetOwner(self:GetCaster())
            wolf:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
            FindClearSpaceForUnit(wolf, wolf:GetAbsOrigin(), true)
            wolves_spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, wolf)
            ParticleManager:ReleaseParticleIndex(wolves_spawn_particle)
            wolf:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_girl_wolf", {} )
        end

        AddFOWViewer( self:GetCaster():GetTeamNumber(), vTargetPosition, self.radius, self.duration, false )
        EmitSoundOnLocationWithCaster( vTargetPosition, "Hero_Furion.Sprout", self:GetCaster() )
        EmitSoundOn("Hero_Lycan.SummonWolves", self:GetCaster())
    end
end

modifier_horo_forest_girl_wolf = class({}) 

function modifier_horo_forest_girl_wolf:OnCreated()
    self.stun_time = self:GetAbility():GetSpecialValueFor( "stun_duration" )
end

function modifier_horo_forest_girl_wolf:IsHidden()
    return true
end

function modifier_horo_forest_girl_wolf:IsPurgable()
    return false
end

function modifier_horo_forest_girl_wolf:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_horo_forest_girl_wolf:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_bashed", {duration = self.stun_time})
    end
end

LinkLuaModifier("modifier_horo_forest_apple_caster", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_forest_apple_target", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_apple = class({}) 

function horo_forest_apple:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function horo_forest_apple:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function horo_forest_apple:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function horo_forest_apple:GetChannelTime()
    return self.BaseClass.GetChannelTime(self)
end

function horo_forest_apple:OnSpellStart() 
    self.target = self:GetCursorTarget()
    local duration = self:GetChannelTime()
    if self.target == nil then
        return
    end
    self:GetCaster():SetForwardVector(self.target:GetForwardVector())
    self.modifier_caster = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_apple_caster", { duration = self:GetChannelTime() } )
end

function horo_forest_apple:OnChannelFinish( bInterrupted )
    self.modifier_caster:Destroy()
end

modifier_horo_forest_apple_caster = class({}) 

function modifier_horo_forest_apple_caster:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_horo_forest_apple_caster:IsHidden()
    return true
end

function modifier_horo_forest_apple_caster:IsPurgable()
    return false
end

function modifier_horo_forest_apple_caster:OnIntervalThink()
    local info = {
        Target = self:GetAbility().target,
        Source = self:GetCaster(),
        Ability = self:GetAbility(), 
        EffectName = "particles/a_horo/apple_horo.vpcf",
        iMoveSpeed = 1600,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionRadius = 25,
        bDodgeable = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()
    }
    ProjectileManager:CreateTrackingProjectile(info)
    EmitSoundOn("Hero_Snapfire.FeedCookie.Cast", self:GetCaster())
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
end

function horo_forest_apple:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target==nil then return end
    local heal_percent = (self:GetSpecialValueFor( "hp_regen" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_2")) / 100
    local fullheal = target:GetMaxHealth() * heal_percent
    target:Heal(fullheal, self)
    EmitSoundOn("Hero_Snapfire.FeedCookie.Consume", target)
end

function modifier_horo_forest_apple_caster:CheckState()
    return{ [MODIFIER_STATE_ROOTED] = true,}
end

LinkLuaModifier("modifier_horo_forest_howl_debuff", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_howl = class({}) 

function horo_forest_howl:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_3")
end

function horo_forest_howl:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function horo_forest_howl:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function horo_forest_howl:OnSpellStart()
    if not IsServer() then return end
    local radius_silence = self:GetSpecialValueFor("radius_silence")
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    0,
    FIND_ANY_ORDER,
    false)
        
    for _,unit in pairs(targets) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_howl_debuff", { duration = duration * (1 - unit:GetStatusResistance()) } )
    end

    local targets_silence = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius_silence,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    0,
    FIND_ANY_ORDER,
    false)

    for _,unit in pairs(targets_silence) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_silence", { duration = duration * (1 - unit:GetStatusResistance()) } )
    end
    EmitSoundOn("Hero_Lycan.Howl", self:GetCaster())
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

modifier_horo_forest_howl_debuff = class({})

function modifier_horo_forest_howl_debuff:IsPurgable()
    return false
end

function modifier_horo_forest_howl_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_horo_forest_howl_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("reduce_movement_speed")
end

function modifier_horo_forest_howl_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("reduce_attack_speed")
end

function modifier_horo_forest_howl_debuff:GetEffectName()
    return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf"
end

function modifier_horo_forest_howl_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier("modifier_horo_forest_wisdom", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_wisdom = class({}) 

function horo_forest_wisdom:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_4")
end

function horo_forest_wisdom:GetIntrinsicModifierName()
    return "modifier_horo_forest_wisdom"
end

modifier_horo_forest_wisdom = class({})

function modifier_horo_forest_wisdom:IsHidden()
    if self:GetParent():PassivesDisabled() then return true end
    if self:GetParent():IsIllusion() then return true end
    if self:GetParent():HasModifier("modifier_horo_ultimate") then return true end
    return false
end

function modifier_horo_forest_wisdom:IsPurgable()
    return false
end

function modifier_horo_forest_wisdom:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.primary_attribute = self:GetAbility():GetSpecialValueFor( "bonus_attribute" )
    self.bonus_xp = self:GetAbility():GetSpecialValueFor( "bonus_xp" )
    self.bonus_gold = self:GetAbility():GetSpecialValueFor( "bonus_gold" )
    if IsServer() then
        local primary = self:GetParent():GetPrimaryAttribute()
        if primary==DOTA_ATTRIBUTE_STRENGTH then
            self.strength = 1
            self.agility = 0
            self.intelligence = 0
        elseif primary==DOTA_ATTRIBUTE_AGILITY then
            self.strength = 0
            self.agility = 1
            self.intelligence = 0
        elseif primary==DOTA_ATTRIBUTE_INTELLECT then
            self.strength = 0
            self.agility = 0
            self.intelligence = 1
        end
        self:StartIntervalThink(0.7)
    end
end

function modifier_horo_forest_wisdom:OnRefresh( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.primary_attribute = self:GetAbility():GetSpecialValueFor( "bonus_attribute" )
    self.bonus_xp = self:GetAbility():GetSpecialValueFor( "bonus_xp" )
    self.bonus_gold = self:GetAbility():GetSpecialValueFor( "bonus_gold" )  
end

function modifier_horo_forest_wisdom:OnIntervalThink()
    if self:GetParent():HasModifier("modifier_horo_ultimate") then return end
    if self:GetParent():IsIllusion() then return end
    self:GetParent():ModifyGold(self.bonus_gold, false, 0)
    self:GetParent():AddExperience(self.bonus_xp, 0, false, false)
end

function modifier_horo_forest_wisdom:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return funcs
end

if IsServer() then
    function modifier_horo_forest_wisdom:GetModifierBonusStats_Agility()
        if self:GetParent():PassivesDisabled() then return 0 end
        if self:GetParent():IsIllusion() then return 0 end
        if self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
        return self.primary_attribute * self.agility
    end
    function modifier_horo_forest_wisdom:GetModifierBonusStats_Intellect()
        if self:GetParent():PassivesDisabled() then return 0 end
        if self:GetParent():IsIllusion() then return 0 end
        if self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
        return self.primary_attribute * self.intelligence
    end
    function modifier_horo_forest_wisdom:GetModifierBonusStats_Strength()
        if self:GetParent():PassivesDisabled() then return 0 end
        if self:GetParent():IsIllusion() then return 0 end
        if self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
        return self.primary_attribute * self.strength
    end
end

function modifier_horo_forest_wisdom:IsAura()
    if self:GetParent():IsIllusion() then return false end
    return self:GetParent()==self:GetCaster()
end

function modifier_horo_forest_wisdom:GetModifierAura()
    return "modifier_horo_forest_wisdom"
end

function modifier_horo_forest_wisdom:GetAuraRadius()
    if self:GetParent():PassivesDisabled() then return 0 end
    if self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
    return self.radius + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_4")
end

function modifier_horo_forest_wisdom:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_horo_forest_wisdom:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

LinkLuaModifier("modifier_horo_forest_heart_beast", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_heart_beast = class({}) 

function horo_forest_heart_beast:GetIntrinsicModifierName()
    return "modifier_horo_forest_heart_beast"
end

modifier_horo_forest_heart_beast = class({})

function modifier_horo_forest_heart_beast:IsHidden()
    return true
end

function modifier_horo_forest_heart_beast:IsPurgable()
    return false
end

function modifier_horo_forest_heart_beast:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_horo_forest_heart_beast:GetModifierConstantHealthRegen()
    if self:GetParent():PassivesDisabled() then return 0 end
    if not self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
    return self:GetAbility():GetSpecialValueFor("bonus_regeneration")
end

function modifier_horo_forest_heart_beast:GetModifierPhysicalArmorBonus()
    if self:GetParent():PassivesDisabled() then return 0 end
    if not self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_horo_forest_heart_beast:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():PassivesDisabled() then return 0 end
    if not self:GetParent():HasModifier("modifier_horo_ultimate") then return 0 end
    return self:GetAbility():GetSpecialValueFor("reduce_attack_speed")
end
    
function modifier_horo_forest_heart_beast:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():PassivesDisabled() then return end
        if not self:GetParent():HasModifier("modifier_horo_ultimate") then return end
        local cleave = self:GetAbility():GetSpecialValueFor("bonus_cleave") / 100
        DoCleaveAttack( params.attacker, target, self:GetAbility(), (params.damage * cleave), 350, 350, 350, "particles/a_horo/horo_cleave.vpcf" )  
        self:GetParent():EmitSound("Hero_Ursa.Attack")
    end
end

LinkLuaModifier("modifier_horo_ultimate", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_ultimate_transform", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_ultimate = class({}) 

function horo_ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function horo_ultimate:GetManaCost(level)
    if self:GetCaster():HasTalent("special_bonus_birzha_horo_6") then return 0 end
    return self.BaseClass.GetManaCost(self, level)
end

function horo_ultimate:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_horo_ultimate_transform", { duration = 1.9 } )
    local particle = ParticleManager:CreateParticle("particles/a_horo/horo_ultimate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, self:GetCaster():GetAbsOrigin())
    EmitSoundOn("Hero_Ursa.Enrage", self:GetCaster())
end

modifier_horo_ultimate_transform = class({})

function modifier_horo_ultimate_transform:IsHidden()
    return false
end

function modifier_horo_ultimate_transform:IsPurgable()
    return false
end

function modifier_horo_ultimate_transform:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_horo_ultimate") then
        self:GetParent():RemoveModifierByName("modifier_horo_ultimate")
    else
        self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_horo_ultimate", {} )
    end   
end

function modifier_horo_ultimate_transform:CheckState()
    return{ [MODIFIER_STATE_STUNNED] = true,}
end

modifier_horo_ultimate = class({})

function modifier_horo_ultimate:OnCreated()
    self.health = self:GetAbility():GetSpecialValueFor("bonus_health")
    if not IsServer() then return end
    self:GetParent():SwapAbilities("horo_forest_girl", "horo_forest_girl_form", false, true)
    self:GetParent():SwapAbilities("horo_forest_apple", "horo_forest_howl", false, true)
    self:GetParent():SwapAbilities("horo_forest_wisdom", "horo_forest_heart_beast", false, true)
end

function modifier_horo_ultimate:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("horo_forest_girl_form", "horo_forest_girl", false, true)
    self:GetParent():SwapAbilities("horo_forest_howl", "horo_forest_apple", false, true)
    self:GetParent():SwapAbilities("horo_forest_heart_beast", "horo_forest_wisdom", false, true)
end

function modifier_horo_ultimate:IsHidden()
    return false
end

function modifier_horo_ultimate:IsPurgable()
    return false
end

function modifier_horo_ultimate:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }

    return funcs
end

function modifier_horo_ultimate:GetModifierHealthBonus()
    return self.health + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_5")
end

function modifier_horo_ultimate:GetModifierModelChange()
    return "models/items/lycan/ultimate/sirius_curse/sirius_curse.vmdl"
end

function modifier_horo_ultimate:GetModifierModelScale()
    return 75
end


