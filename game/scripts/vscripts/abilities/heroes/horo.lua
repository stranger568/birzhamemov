LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier("modifier_horo_forest_girl_wolf", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_girl = class({}) 

function horo_forest_girl:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function horo_forest_girl:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function horo_forest_girl:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    local radius = self:GetSpecialValueFor( "radius" )
    local count = self:GetSpecialValueFor( "wolf_count" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_5")
    local hTarget = self:GetCursorTarget()

    if hTarget == nil or ( hTarget ~= nil and ( not hTarget:TriggerSpellAbsorb( self ) ) ) then
        
        local vTargetPosition = nil

        if hTarget ~= nil then 
            vTargetPosition = hTarget:GetOrigin()
        else
            vTargetPosition = self:GetCursorPosition()
        end

        local r = radius 
        local c = math.sqrt( 2 ) * 0.5 * r 
        local x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
        local y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, vTargetPosition )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 0.0, r, 0.0 ) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        for i = 1,8 do
            CreateTempTree( vTargetPosition + Vector( x_offset[i], y_offset[i], 0.0 ), duration )
        end

        for i = 1,8 do
            ResolveNPCPositions( vTargetPosition + Vector( x_offset[i], y_offset[i], 0.0 ), 64.0 )
        end

        for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
            if unit and unit.wolf_horo_die ~= nil and unit:GetOwner() == self:GetCaster() then
                unit:ForceKill(false)               
            end
        end

        for i = 1, count do
            r = 100
            c = math.sqrt( 2 ) * 0.5 * r 
            x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
            y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }

            local wolf = CreateUnitByName("npc_dota_horo_wolf_"..self:GetLevel(), vTargetPosition + Vector( x_offset[i*2], y_offset[i*2], 0.0 ), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
            wolf:SetOwner(self:GetCaster())

            wolf:SetBaseDamageMax(wolf:GetBaseDamageMax() + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_1") )
            wolf:SetBaseDamageMax(wolf:GetBaseDamageMax() + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_1") )
            wolf:SetBaseMaxHealth(wolf:GetMaxHealth() + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_3"))
            wolf:SetHealth(wolf:GetMaxHealth())

            wolf:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

            FindClearSpaceForUnit(wolf, wolf:GetAbsOrigin(), true)

            local wolves_spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, wolf)
            ParticleManager:ReleaseParticleIndex(wolves_spawn_particle)

            if self:GetCaster():HasTalent("special_bonus_birzha_horo_7") then
                wolf:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_girl_wolf", {} )
            end

            wolf.wolf_horo_die = true
        end

        AddFOWViewer( self:GetCaster():GetTeamNumber(), vTargetPosition, radius, duration, false )

        EmitSoundOnLocationWithCaster( vTargetPosition, "Hero_Furion.Sprout", self:GetCaster() )
        EmitSoundOnLocationWithCaster( vTargetPosition, "Hero_Lycan.SummonWolves", self:GetCaster() )
    end
end

modifier_horo_forest_girl_wolf = class({}) 

function modifier_horo_forest_girl_wolf:IsHidden()
    return true
end

function modifier_horo_forest_girl_wolf:IsPurgable()
    return false
end

function modifier_horo_forest_girl_wolf:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_horo_forest_girl_wolf:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_horo_7") * (1 - params.target:GetStatusResistance()) } )
end

LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

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
    if not IsServer() then return end
    local target = self:GetCursorTarget()

    if target == self:GetCaster() then
        self:GetCaster():EmitSound("Hero_Snapfire.FeedCookie.Cast")
        self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
        self:OnProjectileHit( self:GetCaster(), self:GetCaster():GetAbsOrigin() )
        return
    end

    local info = 
    {
        Target = target,
        Source = self:GetCaster(),
        Ability = self, 
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

    self:GetCaster():EmitSound("Hero_Snapfire.FeedCookie.Cast")

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
end

function horo_forest_apple:OnProjectileHit( target, location )
    if not target then return end
    if target:IsChanneling() or target:IsOutOfGame() then return end
    local duration = self:GetSpecialValueFor( "fly_duration" )
    local height = 125
    local distance = self:GetSpecialValueFor( "distance" )
    local stun = self:GetSpecialValueFor( "stun_duration" )
    local damage = self:GetSpecialValueFor( "damage" )
    local radius = self:GetSpecialValueFor( "radius" )
    local effect_cast = self:PlayEffects2( target )

    local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { distance = distance, height = height, duration = duration, direction_x = target:GetForwardVector().x, direction_y = target:GetForwardVector().y, IsStun = true} )

    local callback = function()
        local damageTable = { attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbilityDamageType(), ability = self }
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
            enemy:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = stun * (1-enemy:GetStatusResistance()) } )
        end

        if self:GetCaster():HasShard() then
            local shard_duration = self:GetSpecialValueFor("shard_duration")
            local horo_forest_girl = self:GetCaster():FindAbilityByName("horo_forest_girl")
            if horo_forest_girl and horo_forest_girl:GetLevel() > 0 then
                local wolf = CreateUnitByName("npc_dota_horo_wolf_"..horo_forest_girl:GetLevel(), target:GetOrigin(), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
                wolf:SetOwner(self:GetCaster())
                wolf:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
                FindClearSpaceForUnit(wolf, wolf:GetAbsOrigin(), true)
                local wolves_spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, wolf)
                ParticleManager:ReleaseParticleIndex(wolves_spawn_particle)
                wolf:SetBaseDamageMax(wolf:GetBaseDamageMax() + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_1") )
                wolf:SetBaseDamageMax(wolf:GetBaseDamageMax() + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_1") )
                wolf:SetBaseMaxHealth(wolf:GetMaxHealth() + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_3"))
                wolf:SetHealth(wolf:GetMaxHealth())
                if self:GetCaster():HasTalent("special_bonus_birzha_horo_7") then
                    wolf:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_girl_wolf", {} )
                end
                wolf:AddNewModifier( self:GetCaster(), self, "modifier_kill", {duration = shard_duration} )
                EmitSoundOnLocationWithCaster( target:GetOrigin(), "Hero_Lycan.SummonWolves", self:GetCaster() )
            end
        end

        if self:GetCaster():HasTalent("special_bonus_birzha_horo_4") then
            local heal = self:GetCaster():GetMaxHealth() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_horo_4")
            target:Heal(heal, self)
        end

        GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )
        ParticleManager:DestroyParticle( effect_cast, false )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:PlayEffects3( target, radius )
    end

    knockback:SetEndCallback( callback )
end

function horo_forest_apple:PlayEffects2( target )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    target:EmitSound("Hero_Snapfire.FeedCookie.Consume")
    return effect_cast
end

function horo_forest_apple:PlayEffects3( target, radius )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf", PATTACH_WORLDORIGIN, target )
    ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("Hero_Snapfire.FeedCookie.Impact")
end

LinkLuaModifier("modifier_horo_forest_wisdom", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_forest_wisdom_aura", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_forest_wisdom_buff_scepter", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_wisdom = class({}) 

function horo_forest_wisdom:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function horo_forest_wisdom:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function horo_forest_wisdom:GetManaCost(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_manacost")
    end
    return self.BaseClass.GetManaCost(self, level)
end

function horo_forest_wisdom:OnSpellStart()
    if not IsServer() then return end
    local scepter_damage = self:GetSpecialValueFor("scepter_damage")
    local scepter_radius = self:GetSpecialValueFor("scepter_radius")
    local scepter_duration = self:GetSpecialValueFor("scepter_duration")
    local trees = GridNav:GetAllTreesAroundPoint(self:GetCaster():GetAbsOrigin(), scepter_radius, false)
    local bonus_damage = scepter_damage * #trees
    local cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_curse_of_forest_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(cast_particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(cast_particle, 1, Vector(scepter_radius,scepter_radius,scepter_radius))
    self:GetCaster():EmitSound("Hero_Furion.CurseOfTheForest.Cast")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_horo_forest_wisdom_buff_scepter", {duration = scepter_duration, bonus_damage = bonus_damage})
end

modifier_horo_forest_wisdom_buff_scepter = class({})

function modifier_horo_forest_wisdom_buff_scepter:IsPurgable() return false end

function modifier_horo_forest_wisdom_buff_scepter:GetEffectName()
    return "particles/units/heroes/hero_furion/furion_curse_of_forest_debuff.vpcf"
end

function modifier_horo_forest_wisdom_buff_scepter:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_horo_forest_wisdom_buff_scepter:OnCreated(params)
    if not IsServer() then return end
    self.bonus_damage = params.bonus_damage
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_horo_forest_wisdom_buff_scepter:AddCustomTransmitterData()
    return 
    {
        bonus_damage = self.bonus_damage,
    }
end

function modifier_horo_forest_wisdom_buff_scepter:HandleCustomTransmitterData( data )
    self.bonus_damage = data.bonus_damage
end


function modifier_horo_forest_wisdom_buff_scepter:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()

end

function modifier_horo_forest_wisdom_buff_scepter:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_horo_forest_wisdom_buff_scepter:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function horo_forest_wisdom:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function horo_forest_wisdom:GetIntrinsicModifierName()
    return "modifier_horo_forest_wisdom"
end

modifier_horo_forest_wisdom = class({})

function modifier_horo_forest_wisdom:IsPurgable() return false end
function modifier_horo_forest_wisdom:IsPurgeException() return false end

function modifier_horo_forest_wisdom:IsHidden()
    return true
end

function modifier_horo_forest_wisdom:IsPurgable()
    return false
end

function modifier_horo_forest_wisdom:IsAura()
    return true
end

function modifier_horo_forest_wisdom:GetModifierAura()
    return "modifier_horo_forest_wisdom_aura"
end

function modifier_horo_forest_wisdom:GetAuraRadius()
    if self:GetParent():PassivesDisabled() then return 0 end
    return self.radius
end

function modifier_horo_forest_wisdom:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_horo_forest_wisdom:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_horo_forest_wisdom:GetAuraDuration()
    return 0
end

modifier_horo_forest_wisdom_aura = class({})

function modifier_horo_forest_wisdom_aura:IsPurgable() return false end
function modifier_horo_forest_wisdom_aura:IsPurgeException() return false end

function modifier_horo_forest_wisdom_aura:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.primary_attribute = self:GetAbility():GetSpecialValueFor( "bonus_attribute" )
    self.evasion = 0
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
        self:SetHasCustomTransmitterData(true)
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_horo_forest_wisdom_aura:AddCustomTransmitterData()
    return 
    {
        evasion = self.evasion,
    }
end

function modifier_horo_forest_wisdom_aura:HandleCustomTransmitterData( data )
    self.evasion = data.evasion
end

function modifier_horo_forest_wisdom_aura:OnIntervalThink()
    if not IsServer() then return end
    self.evasion = 0
    local trees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.radius, false)
    if #trees > 0 then
        self.evasion = self:GetAbility():GetSpecialValueFor('bonus_evasion')
    end
    self:SendBuffRefreshToClients()
end

function modifier_horo_forest_wisdom_aura:OnRefresh( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.primary_attribute = self:GetAbility():GetSpecialValueFor( "bonus_attribute" )
end

function modifier_horo_forest_wisdom_aura:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }

    return funcs
end

function modifier_horo_forest_wisdom_aura:GetModifierEvasion_Constant()
    return self.evasion
end

if IsServer() then
    function modifier_horo_forest_wisdom_aura:GetModifierBonusStats_Agility()
        if self:GetParent():PassivesDisabled() then return 0 end
        if self:GetParent():IsIllusion() then return 0 end
        return self.primary_attribute * self.agility
    end
    function modifier_horo_forest_wisdom_aura:GetModifierBonusStats_Intellect()
        if self:GetParent():PassivesDisabled() then return 0 end
        if self:GetParent():IsIllusion() then return 0 end
        return self.primary_attribute * self.intelligence
    end
    function modifier_horo_forest_wisdom_aura:GetModifierBonusStats_Strength()
        if self:GetParent():PassivesDisabled() then return 0 end
        if self:GetParent():IsIllusion() then return 0 end
        return self.primary_attribute * self.strength
    end
end

function modifier_horo_forest_wisdom_aura:CheckState()
    if not self:GetCaster():HasTalent("special_bonus_birzha_horo_2") then return end
    if self:GetParent() ~= self:GetCaster() then return end
    return 
    {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true
    }
end











     

LinkLuaModifier("modifier_horo_ultimate", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_ultimate_transform", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_ultimate = class({}) 

function horo_ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_6")
end

function horo_ultimate:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function horo_ultimate:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_horo_ultimate_transform", { duration = 1.9 } )
    local particle = ParticleManager:CreateParticle("particles/a_horo/horo_ultimate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, self:GetCaster():GetAbsOrigin())
    self:GetCaster():EmitSound("Hero_Ursa.Enrage")
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
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_horo_ultimate", {duration = duration} ) 
end

function modifier_horo_ultimate_transform:CheckState()
    return{ [MODIFIER_STATE_STUNNED] = true}
end

modifier_horo_ultimate = class({})

function modifier_horo_ultimate:OnCreated()
    self.health = self:GetAbility():GetSpecialValueFor("bonus_health")
    if not IsServer() then return end
    local horo_forest_howl = self:GetParent():FindAbilityByName("horo_forest_howl")
    if horo_forest_howl then
        horo_forest_howl:SetHidden(false)
    end
    local horo_forest_heart_beast = self:GetParent():FindAbilityByName("horo_forest_heart_beast")
    if horo_forest_heart_beast then
        horo_forest_heart_beast:SetHidden(false)
    end
end

function modifier_horo_ultimate:OnDestroy()
    if not IsServer() then return end
    local horo_forest_howl = self:GetParent():FindAbilityByName("horo_forest_howl")
    if horo_forest_howl then
        horo_forest_howl:SetHidden(true)
    end
    local horo_forest_heart_beast = self:GetParent():FindAbilityByName("horo_forest_heart_beast")
    if horo_forest_heart_beast then
        horo_forest_heart_beast:SetHidden(true)
    end
end

function modifier_horo_ultimate:IsHidden()
    return false
end

function modifier_horo_ultimate:IsPurgable()
    return false
end

function modifier_horo_ultimate:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }

    return funcs
end

function modifier_horo_ultimate:GetModifierHealthBonus()
    return self.health + self:GetCaster():FindTalentValue("special_bonus_birzha_horo_8")
end

function modifier_horo_ultimate:GetModifierModelChange()
    return "models/items/lycan/ultimate/sirius_curse/sirius_curse.vmdl"
end

function modifier_horo_ultimate:GetModifierModelScale()
    return 25
end

LinkLuaModifier("modifier_horo_forest_howl_debuff", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_horo_forest_howl_debuff_silence", "abilities/heroes/horo", LUA_MODIFIER_MOTION_NONE)

horo_forest_howl = class({}) 

function horo_forest_howl:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
        
    for _,unit in pairs(targets) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_howl_debuff", { duration = duration * (1 - unit:GetStatusResistance()) } )
    end

    local targets_silence = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius_silence, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    for _,unit in pairs(targets_silence) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_horo_forest_howl_debuff_silence", { duration = duration * (1 - unit:GetStatusResistance()) } )
    end

    self:GetCaster():EmitSound("Hero_Lycan.Howl")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())

    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

modifier_horo_forest_howl_debuff = class({})

function modifier_horo_forest_howl_debuff:DeclareFunctions()
    local funcs = 
    {
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

modifier_horo_forest_howl_debuff_silence = class({})

function modifier_horo_forest_howl_debuff_silence:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_horo_forest_howl_debuff_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_horo_forest_howl_debuff_silence:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return funcs
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
    local funcs = 
    {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
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
    
function modifier_horo_forest_heart_beast:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():PassivesDisabled() then return end
        if not self:GetParent():HasModifier("modifier_horo_ultimate") then return end
        local cleave = self:GetAbility():GetSpecialValueFor("bonus_cleave") / 100
        DoCleaveAttack( params.attacker, target, self:GetAbility(), (params.original_damage * cleave), 350, 350, 350, "particles/a_horo/horo_cleave.vpcf" )  
        self:GetParent():EmitSound("Hero_Ursa.Attack")
    end
end




