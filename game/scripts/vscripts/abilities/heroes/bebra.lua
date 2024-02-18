LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_thomas_ability_one_debuff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_shelby_debuff_dolgi", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_sound_cooldown", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

modifier_thomas_sound_cooldown = class({})
function modifier_thomas_sound_cooldown:IsPurgable() return false end
function modifier_thomas_sound_cooldown:IsHidden() return true end

thomas_ability_one = class({})

function thomas_ability_one:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function thomas_ability_one:GetCooldown(iLevel)
    local minus_cooldown = ((self:GetCaster():GetAttackSpeed(true) * 100) / self:GetSpecialValueFor("attack_speed_cooldown")) - (self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_7"))
    return self.BaseClass.GetCooldown( self, iLevel ) - minus_cooldown
end

function thomas_ability_one:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")

    if self:GetCaster():HasTalent("special_bonus_birzha_shelby_3") then
        local modifier_shelby_ultimate_passive = self:GetCaster():FindModifierByName("modifier_shelby_ultimate_passive")
        if modifier_shelby_ultimate_passive then
            damage = damage + (modifier_shelby_ultimate_passive:GetStackCount() * self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_3"))
        end
    end

    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

    local particle = ParticleManager:CreateParticle("particles/shelby/one.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius+125,radius+125,radius+125))

    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_thomas_ability_one_debuff", {duration = duration * (1-enemy:GetStatusResistance())})
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, ability = self, damage_type = DAMAGE_TYPE_MAGICAL})
    end

    if not self:GetCaster():HasModifier("modifier_thomas_sound_cooldown") then
        self:GetCaster():EmitSound("shelby_1")
    end

    EmitSoundOnLocationWithCaster( point, "Hero_Marci.Rebound.Impact", self:GetCaster() )

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_thomas_sound_cooldown", {duration = 5})
end

modifier_thomas_ability_one_debuff = class({})

function modifier_thomas_ability_one_debuff:IsPurgable() return true end

function modifier_thomas_ability_one_debuff:OnCreated()
    self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_1")
    self.magic_reduction = self:GetAbility():GetSpecialValueFor("magic_reduction") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_2")
    self.armor_minus = 0
    self.armor_minus = self:GetParent():GetPhysicalArmorValue(false) / 100 * self.armor_reduction
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_thomas_ability_one_debuff:OnRefresh()
    self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_1")
    self.magic_reduction = self:GetAbility():GetSpecialValueFor("magic_reduction") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_2")
    self.armor_minus = 0
    self.armor_minus = self:GetParent():GetPhysicalArmorValue(false) / 100 * self.armor_reduction
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_thomas_ability_one_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_thomas_ability_one_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_minus * self:GetStackCount()
end

function modifier_thomas_ability_one_debuff:GetModifierMagicalResistanceBonus()
    return self.magic_reduction * self:GetStackCount()
end

LinkLuaModifier( "modifier_thomas_ability_two_one", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_two_one_gypsy", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

thomas_ability_two_one = class({})

function thomas_ability_two_one:GetAOERadius() return 600 end

function thomas_ability_two_one:OnSpellStart()
    if not IsServer() then return end
    local duration_swap = self:GetSpecialValueFor("duration_swap")
    local math_cel = self:GetSpecialValueFor("math_cel")
    local max_count = self:GetSpecialValueFor("max_count")
    local kills = self:GetCaster():GetKills()
    local assists = self:GetCaster():GetAssists()
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)

    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")

    self:GetCaster():EmitSound("shelby_2_1")

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_thomas_ability_two_one", {duration = duration_swap})
    local count = (kills + assists) / math_cel
    count = math.floor(count)
    count = math.max(count, 1)
    count = math.min(count, max_count)
    for i = 1, count do
        local gypsy = CreateUnitByName( "npc_shelby_gypsy", point + RandomVector(RandomInt(300, 600)), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
        gypsy:SetOwner(self:GetCaster())
        gypsy:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration_swap})
        gypsy:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        gypsy:AddNewModifier(self:GetCaster(), self, "modifier_thomas_ability_two_one_gypsy", {})
    end
end

modifier_thomas_ability_two_one_gypsy = class({})
function modifier_thomas_ability_two_one_gypsy:IsHidden() return true end
function modifier_thomas_ability_two_one_gypsy:IsPurgable() return false end

function modifier_thomas_ability_two_one_gypsy:OnCreated()
    if not IsServer() then return end
    self.damage = (self:GetParent():GetOwner():GetAverageTrueAttackDamage(nil) / 100) * self:GetAbility():GetSpecialValueFor("damage")
    self.attackspeed = (self:GetParent():GetOwner():GetAttackSpeed(true) * 100) / self:GetAbility():GetSpecialValueFor("attack_speed_mult")
    self.networth_steal = self:GetAbility():GetSpecialValueFor("gold_steal")
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_thomas_ability_two_one_gypsy:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_thomas_ability_two_one_gypsy:AddCustomTransmitterData()
    return 
    {
        damage = self.damage,
        attackspeed = self.attackspeed,
    }
end

function modifier_thomas_ability_two_one_gypsy:HandleCustomTransmitterData( data )
    self.damage = data.damage
    self.attackspeed = data.attackspeed
end

function modifier_thomas_ability_two_one_gypsy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_thomas_ability_two_one_gypsy:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_thomas_ability_two_one_gypsy:GetModifierAttackSpeedBonus_Constant()
    return self.attackspeed
end

function modifier_thomas_ability_two_one_gypsy:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    if params.attacker == params.target then return end
    local self_networth = PlayerResource:GetNetWorth(self:GetParent():GetPlayerOwnerID())
    local money_steal = self.networth_steal
    local modifier_dolgi = params.target:FindModifierByName("modifier_thomas_shelby_debuff_dolgi")
    if modifier_dolgi then
        modifier_dolgi:SetStackCount(modifier_dolgi:GetStackCount() + money_steal)
    else
        local modifier_dolgi = params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_thomas_shelby_debuff_dolgi", {})
        modifier_dolgi:SetStackCount(modifier_dolgi:GetStackCount() + money_steal)
    end
end

modifier_thomas_ability_two_one = class({})

function modifier_thomas_ability_two_one:IsPurgable() return false end
function modifier_thomas_ability_two_one:IsHidden() return true end

function modifier_thomas_ability_two_one:OnCreated()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("thomas_ability_two_one", "thomas_ability_two_two", false, true)
end

function modifier_thomas_ability_two_one:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("thomas_ability_two_two", "thomas_ability_two_one", false, true)
    local ability = self:GetCaster():FindAbilityByName("thomas_ability_two_one")
    if ability then
        ability:EndCooldown()
        ability:UseResources(false, false, false, true)
    end
end

thomas_ability_two_two = class({})

LinkLuaModifier( "modifier_thomas_ability_two_two", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_two_two_debuff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_two_two_telega", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

function thomas_ability_two_two:GetAOERadius() return 600 end

function thomas_ability_two_two:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local radius = 200
    local vector = GetGroundPosition(point + Vector(0, radius, 0), nil)
    local duration_debuff = self:GetSpecialValueFor("duration_debuff")
    local count = 10

    self:GetCaster():EmitSound("shelby_2_2")

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)

    self:GetCaster():RemoveModifierByName("modifier_thomas_ability_two_one")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_thomas_ability_two_two_telega", {duration = duration_debuff - 3})

    for i=1, 3 do
        vector = GetGroundPosition(point + Vector(0, radius * i, 0), nil)
        for tree = 1, count * i do
            local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_thomas_ability_two_two", {duration = duration_debuff}, vector, self:GetCaster():GetTeamNumber(), false)
            vector = RotatePosition(point, QAngle(0, 360 / tree, 0), vector)
            vector = GetGroundPosition(vector, nil)
        end
    end
end

modifier_thomas_ability_two_two = class({})

function modifier_thomas_ability_two_two:OnCreated()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 250, self:GetDuration(), true)
    self:GetParent():SetModel("models/heroes/hoodwink/hoodwink_tree_model.vmdl")
    self:GetParent():SetOriginalModel("models/heroes/hoodwink/hoodwink_tree_model.vmdl")
end

function modifier_thomas_ability_two_two:IsAura() return true end

function modifier_thomas_ability_two_two:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_thomas_ability_two_two:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_thomas_ability_two_two:GetModifierAura()
    return "modifier_thomas_ability_two_two_debuff"
end

function modifier_thomas_ability_two_two:GetAuraRadius()
    return 200
end

function modifier_thomas_ability_two_two:GetAuraDuration() return 0 end

modifier_thomas_ability_two_two_telega = class({})

function modifier_thomas_ability_two_two_telega:IsHidden() return true end
function modifier_thomas_ability_two_two_telega:IsPurgable() return false end
function modifier_thomas_ability_two_two_telega:RemoveOnDeath() return false end

function modifier_thomas_ability_two_two_telega:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))
end

function modifier_thomas_ability_two_two_telega:OnIntervalThink()
    if not IsServer() then return end
    local thinkers = Entities:FindAllByClassname("npc_dota_thinker")

    local random_tree = nil

    local trees_count = {}
    for _, thinker in pairs(thinkers) do
        if thinker and not thinker:IsNull() and thinker:HasModifier("modifier_thomas_ability_two_two") and thinker:GetOwner() == self:GetParent() then
            table.insert(trees_count, thinker)
        end
    end

    random_tree = trees_count[RandomInt(1, #trees_count)]

    if random_tree ~= nil and not random_tree:IsNull() then

        local direction = (Vector(0,0,0) - random_tree:GetAbsOrigin())
        direction.z = 0
        direction = direction:Normalized()

        local origin_damage = random_tree:GetAbsOrigin() + direction * RandomInt(0, 400)

        local effect_cast = ParticleManager:CreateParticle("particles/shelby/telega_fly.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl( effect_cast, 0, origin_damage + Vector( 0, 0, 1000 ) )
        ParticleManager:SetParticleControl( effect_cast, 1, origin_damage)
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        local caster = self:GetCaster()
        local ability = self:GetAbility()

        self:GetParent():EmitSound("DOTA_Item.MeteorHammer.Cast")

        Timers:CreateTimer(1.2, function()
            local telega_particle = ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_spell_ground_impact.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl( telega_particle, 0, origin_damage)
            ParticleManager:SetParticleControl( telega_particle, 3, origin_damage)
            EmitSoundOnLocationWithCaster( origin_damage, "Hero_Tidehunter.ArmsOfTheDeep.Stun", caster )
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), origin_damage, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
            for _, enemy in pairs(enemies) do
                local stun_duration = ability:GetSpecialValueFor("stun_duration")
                local damage = ability:GetSpecialValueFor("damage")
                local end_damage = enemy:GetMaxHealth() / 100 * damage
                enemy:AddNewModifier(caster, ability, "modifier_birzha_stunned", {duration = stun_duration * (1 - enemy:GetStatusResistance())})
                ApplyDamage({victim = enemy, attacker = caster, damage = end_damage, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL})
            end
        end)
    end
end

modifier_thomas_ability_two_two_debuff = class({})

function modifier_thomas_ability_two_two_debuff:IsHidden() return true end
function modifier_thomas_ability_two_two_debuff:IsPurgable() return false end

function modifier_thomas_ability_two_two_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end

function modifier_thomas_ability_two_two_debuff:OnCreated()
    if not IsServer() then return end
    self.vision = (self:GetParent():GetCurrentVisionRange() - 100 ) * -1
end

function modifier_thomas_ability_two_two_debuff:GetBonusVisionPercentage()
    return -95
end

function modifier_thomas_ability_two_two_debuff:GetBonusDayVision( params )
    return self.vision
end

function modifier_thomas_ability_two_two_debuff:GetBonusNightVision( params )
    return self.vision
end

-- МОДИФИКАТОР ДОЛГИ

modifier_thomas_shelby_debuff_dolgi = class({})

function modifier_thomas_shelby_debuff_dolgi:IsPurgable() return false end
function modifier_thomas_shelby_debuff_dolgi:RemoveOnDeath() return false end

function modifier_thomas_shelby_debuff_dolgi:OnCreated()
    if not IsServer() then return end

    if not self:GetParent():IsRealHero() then
        self:Destroy()
        return
    end

    self:StartIntervalThink(0.1)
end

function modifier_thomas_shelby_debuff_dolgi:OnIntervalThink()
    if not IsServer() then return end

    local steal_gold = self:GetStackCount()

    local minus_dolg = self:GetParent():ModifyGold(-steal_gold, false, 0)
    
    if minus_dolg ~= 0 then
        self:GetCaster():ModifyGold(math.abs(minus_dolg), false, 0)
        self:SetStackCount(self:GetStackCount() + minus_dolg)
    end
    
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_shelby_ultimate", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shelby_ultimate_passive", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shelby_ultimate_stack", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shelby_ultimate_damage_buff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

shelby_ultimate = class({})

function shelby_ultimate:GetCooldown(iLevel)
    return self.BaseClass.GetCooldown( self, iLevel ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_5")
end

function shelby_ultimate:GetIntrinsicModifierName()
    return "modifier_shelby_ultimate_passive"
end

function shelby_ultimate:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_4")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shelby_ultimate", {duration = duration})
end

modifier_shelby_ultimate = class({})

function modifier_shelby_ultimate:IsPurgable() return false end

function modifier_shelby_ultimate:OnCreated()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")
    self:GetCaster():EmitSound("shelby_4")
    self.radius = self:GetAbility():GetSpecialValueFor("attack_radius")
    self.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/tailer/weapon_test.vmdl"})
    self.weapon:FollowEntity(self:GetParent(), true)
    local attack_per_second = self:GetParent():GetAttackSpeed(true) / self:GetParent():GetBaseAttackTime()
    local interval = 1 / attack_per_second
    self:StartIntervalThink(interval)
end

function modifier_shelby_ultimate:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_weapon"))

    local info = 
    {
        EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 2000,
        Source = self:GetCaster(),
        Target = nil,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        vSpawnOrigin = point
    }

    for _, target in pairs(enemies) do
        local vector = target:GetOrigin()-self:GetParent():GetOrigin()
        local center_angle = VectorToAngles( vector ).y
        local facing_angle = VectorToAngles( self:GetParent():GetForwardVector() ).y
        local distance = vector:Length2D()
        local facing = ( math.abs( AngleDiff(center_angle,facing_angle) ) < 90 )
        if facing then
            info.Target = target
            ProjectileManager:CreateTrackingProjectile( info )
            self:GetParent():EmitSound("Hero_Sniper.MKG_attack")
        end
    end
end

function shelby_ultimate:OnProjectileHit_ExtraData( target, location, ExtraData )
    if target == nil then return end
    if not self:GetCaster():IsAlive() then return end
    local modifier_damage = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_shelby_ultimate_damage_buff", {} )
    self:GetCaster():PerformAttack( target, true, true, true, false, false, false, true )
    if modifier_damage then
        modifier_damage:Destroy()
    end
end

function modifier_shelby_ultimate:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
    }
end

function modifier_shelby_ultimate:CheckState()
    return 
    {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_shelby_ultimate:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_shelby_ultimate:GetActivityTranslationModifiers()
    return "ultimate"
end

function modifier_shelby_ultimate:GetAttackSound()
    return "Hero_Sniper.AssassinateDamage"
end

function modifier_shelby_ultimate:OnDestroy()
    if not IsServer() then return end

    if self.weapon then
        self.weapon:Destroy()
    end

    local unique_modifier = self:GetParent():FindModifierByName("modifier_shelby_ultimate_passive")
    if unique_modifier then
        unique_modifier.unique_damage_list = {}
    end

    local unique_modifier_stack = self:GetParent():FindAllModifiersByName("modifier_shelby_ultimate_stack")
    for _, modifier in pairs(unique_modifier_stack) do
        if modifier then
            modifier:Destroy()
        end
    end
end

modifier_shelby_ultimate_damage_buff = class({})

function modifier_shelby_ultimate_damage_buff:IsHidden()
    return true
end

function modifier_shelby_ultimate_damage_buff:IsHidden() return true end

function modifier_shelby_ultimate_damage_buff:IsPurgable()
    return false
end

function modifier_shelby_ultimate_damage_buff:OnCreated( kv )
    self.damage_percentage = (100 - (self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_6")) ) * -1
end

function modifier_shelby_ultimate_damage_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_shelby_ultimate_damage_buff:GetModifierDamageOutgoing_Percentage()
    if not IsServer() then return end
    return self.damage_percentage
end

modifier_shelby_ultimate_stack = class({})

function modifier_shelby_ultimate_stack:RemoveOnDeath() return false end
function modifier_shelby_ultimate_stack:IsPurgable() return false end
function modifier_shelby_ultimate_stack:IsHidden() return true end
function modifier_shelby_ultimate_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_shelby_ultimate_stack:OnCreated(params)
    if not IsServer() then return end
    self.ability_name = params.ability_name
    local modifier = self:GetCaster():FindModifierByName("modifier_shelby_ultimate_passive")
    if modifier then
        CustomGameEventManager:Send_ServerToAllClients( 'thomas_shelby_buff_update', { abilities = modifier.unique_damage_list })
    end
end

function modifier_shelby_ultimate_stack:OnDestroy()
    if not IsServer() then return end
    local modifier = self:GetCaster():FindModifierByName("modifier_shelby_ultimate_passive")
    if modifier then
        modifier.unique_damage_list[self.ability_name] = nil
        CustomGameEventManager:Send_ServerToAllClients( 'thomas_shelby_buff_update', { abilities = modifier.unique_damage_list })
    end
end

modifier_shelby_ultimate_passive = class({})

function modifier_shelby_ultimate_passive:IsPurgable() return false end
function modifier_shelby_ultimate_passive:IsHidden() return self:GetStackCount() == 0 end

function modifier_shelby_ultimate_passive:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
    self.stack_for_active = self:GetAbility():GetSpecialValueFor("stack_for_active")
    self.unique_damage_list = {}
end

function modifier_shelby_ultimate_passive:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():HasModifier("modifier_shelby_ultimate") then return end

    local modifiers = self:GetParent():FindAllModifiersByName("modifier_shelby_ultimate_stack")
    self:SetStackCount(#modifiers)

    if #modifiers >= self.stack_for_active or IsInToolsMode() then
        self:GetAbility():SetActivated(true)
    else
        self:GetAbility():SetActivated(false)
    end
end

function modifier_shelby_ultimate_passive:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
end

function modifier_shelby_ultimate_passive:GetModifierAttackSpeedBonus_Constant() 
    return self:GetAbility():GetSpecialValueFor("attackspeed_stack") * self:GetStackCount()
end

function modifier_shelby_ultimate_passive:GetModifierPreAttack_BonusDamage() 
    return self:GetAbility():GetSpecialValueFor("damage_stack") * self:GetStackCount()
end

function modifier_shelby_ultimate_passive:GetModifierMoveSpeedBonus_Percentage() 
    return self:GetAbility():GetSpecialValueFor("movespeed_stack") * self:GetStackCount()
end

function modifier_shelby_ultimate_passive:GetBonusDayVision() 
    return self:GetAbility():GetSpecialValueFor("vision_stack") * self:GetStackCount()
end

function modifier_shelby_ultimate_passive:GetBonusNightVision() 
    return self:GetAbility():GetSpecialValueFor("vision_stack") * self:GetStackCount()
end

function modifier_shelby_ultimate_passive:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then return end
    if params.attacker ~= self:GetParent() then return end
    if self:GetParent():HasModifier("modifier_shelby_ultimate") then return end

    local ability_name = nil

    if params.inflictor ~= nil then
        ability_name = params.inflictor:GetAbilityName()
    else
        ability_name = "attack"
    end

    if self.unique_damage_list[ability_name] == nil then
        self.unique_damage_list[ability_name] = true
        local stacks = self:GetCaster():FindAllModifiersByName("modifier_shelby_ultimate_stack")
        local max_charges = self:GetAbility():GetSpecialValueFor("max_charges") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_8")
        if #stacks >= max_charges then
            local modifier_delete = nil
            local lose_time = self:GetAbility():GetSpecialValueFor("charge_duration" )
            for _, mod in pairs(stacks) do
                if lose_time > mod:GetRemainingTime() then
                    modifier_delete = mod
                    lose_time = mod:GetRemainingTime()
                end
            end
            if modifier_delete ~= nil then
                modifier_delete:Destroy()
            end
        end

        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shelby_ultimate_stack", { duration = self:GetAbility():GetSpecialValueFor("charge_duration" ), ability_name = ability_name}) 

        if (#stacks + 1) < 6 and (#stacks + 1) > 0 then
            self:GetParent():EmitSound("shelby_stack_" .. tostring(#stacks + 1))
        end
    end
end

thomas_ability_three = class({})

LinkLuaModifier( "modifier_thomas_ability_three_buff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_three_debuff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

function thomas_ability_three:OnVectorCastStart(vStartLocation, vDirection)
    if not IsServer() then return end
    local distance = 900
    local speed = 1200

    local caster_origin = self:GetCaster():GetAbsOrigin()
    if caster_origin.x == vStartLocation.x and caster_origin.y == vStartLocation.y then
        vStartLocation = caster_origin + self:GetCaster():GetForwardVector() * 50
        vDirection = self:GetCaster():GetForwardVector()
    end

    CreateModifierThinker(self:GetCaster(), self, "modifier_thomas_ability_three_buff", {
        duration        = distance / speed,
        direction_x     = vDirection.x,
        direction_y     = vDirection.y,
    }, vStartLocation, self:GetCaster():GetTeamNumber(), false)
end

modifier_thomas_ability_three_buff = class({})

function modifier_thomas_ability_three_buff:OnCreated( params )
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.speed = 1200
    self.total_damage = self.ability:GetSpecialValueFor("damage")
    self.duration           = params.duration
    self.direction          = Vector(params.direction_x, params.direction_y, 0)
    self.direction_angle    = math.deg(math.atan2(self.direction.x, self.direction.y))

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/kotl_illuminate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle, 1, self.direction * self.speed)
    ParticleManager:SetParticleControl(self.particle, 3, self.parent:GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self.hit_targets = {}
    self:OnIntervalThink()
    self:StartIntervalThink(FrameTime())
end

function modifier_thomas_ability_three_buff:OnIntervalThink()
    if not IsServer() then return end
    local targets = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    local damage = self.total_damage
    local valid_targets =   {}

    for _, target in pairs(targets) do
        local target_pos    = target:GetAbsOrigin()
        local target_angle  = math.deg(math.atan2((target_pos.x - self.parent:GetAbsOrigin().x), target_pos.y - self.parent:GetAbsOrigin().y))
        local difference = math.abs(self.direction_angle - target_angle)
        if difference <= 90 or difference >= 270 then
            table.insert(valid_targets, target)
        end
    end

    for _, target in pairs(valid_targets) do
        local hit_already = false
        for _, hit_target in pairs(self.hit_targets) do
            if hit_target == target then
                hit_already = true
                break
            end
        end
        if not hit_already then

            local damageTable = 
            {
                victim          = target,
                damage          = damage,
                damage_type     = DAMAGE_TYPE_MAGICAL,
                damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                attacker        = self.caster,
                ability         = self.ability
            }
            
            ApplyDamage(damageTable)

            target:AddNewModifier(self.caster, self.ability, "modifier_thomas_ability_three_debuff", {duration = self.ability:GetSpecialValueFor("duration") * (1-target:GetStatusResistance())})

            target:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target")
            target:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target.Secondary")

            local particle_name = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact_small.vpcf"
            if target:IsHero() then
                particle_name = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact.vpcf"
            end

            local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            table.insert(self.hit_targets, target)
        end
    end

    self.parent:SetAbsOrigin(self.parent:GetAbsOrigin() + (self.direction * self.speed * FrameTime()))
end

function modifier_thomas_ability_three_buff:OnDestroy()
    if not IsServer() then return end
    self.parent:RemoveSelf()
end

modifier_thomas_ability_three_debuff = class({})

function modifier_thomas_ability_three_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_thomas_ability_three_debuff:CheckState()
    if not self:GetCaster():HasShard() then return end
    return 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_thomas_ability_three_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

LinkLuaModifier( "modifier_shelby_shard", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shelby_shard_buff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

shelby_shard = class({})

function shelby_shard:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function shelby_shard:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function shelby_shard:GetIntrinsicModifierName()
    return "modifier_shelby_shard"
end

modifier_shelby_shard = class({})

function modifier_shelby_shard:IsPurgable() return false end
function modifier_shelby_shard:IsHidden() return self:GetStackCount() == 0 end

function modifier_shelby_shard:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
    self.unique_damage_list = {}
end

function modifier_shelby_shard:OnIntervalThink()
    if not IsServer() then return end
    local modifiers = self:GetParent():FindAllModifiersByName("modifier_shelby_shard_buff")
    self:SetStackCount(#modifiers)
end

function modifier_shelby_shard:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_shelby_shard:GetModifierIncomingDamage_Percentage()
    if not self:GetParent():HasScepter() then return end
    return self:GetAbility():GetSpecialValueFor("resist") * self:GetStackCount()
end

function modifier_shelby_shard:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then return end
    if params.attacker ~= self:GetParent() then return end
    if not self:GetParent():HasScepter() then return end

    local ability_name = nil

    if params.inflictor ~= nil then
        ability_name = params.inflictor:GetAbilityName()
    else
        ability_name = "attack"
    end

    self:AddCharge(ability_name)
end

function modifier_shelby_shard:AddCharge(ability_name)
    if self.unique_damage_list[ability_name] == nil then
        self.unique_damage_list[ability_name] = true
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shelby_shard_buff", {duration = self:GetAbility():GetSpecialValueFor("duration"), name = ability_name}) 
        if ability_name == "item_bond" then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shelby_shard_buff", {duration = self:GetAbility():GetSpecialValueFor("duration"), name = ability_name}) 
        end
    end
end

modifier_shelby_shard_buff = class({})

function modifier_shelby_shard_buff:IsHidden() return true end
function modifier_shelby_shard_buff:IsPurgable() return false end
function modifier_shelby_shard_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_shelby_shard_buff:OnCreated(params)
    if not IsServer() then return end
    self.name = params.name
end

function modifier_shelby_shard_buff:OnDestroy()
    if not IsServer() then return end
    local original = self:GetParent():FindModifierByName("modifier_shelby_shard")
    if original then
        original.unique_damage_list[self.name] = nil
    end
end