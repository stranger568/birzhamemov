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
    local minus_cooldown = ((self:GetCaster():GetAttackSpeed() * 100) / self:GetSpecialValueFor("attack_speed_cooldown")) + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_2")
    return self.BaseClass.GetCooldown( self, iLevel ) - minus_cooldown
end

function thomas_ability_one:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")

    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

    local particle = ParticleManager:CreateParticle("particles/shelby/one.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius+125,radius+125,radius+125))

    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_thomas_ability_one_debuff", {duration = duration})
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
    self.armor_reduction = (self:GetAbility():GetSpecialValueFor("armor_reduction") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_1")) * self:GetStackCount()
    self.magic_reduction = self:GetAbility():GetSpecialValueFor("magic_reduction")
    self.armor_minus = 0
    self.armor_minus = self:GetParent():GetPhysicalArmorValue(false) / 100 * self.armor_reduction
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_thomas_ability_one_debuff:OnRefresh()
    self.armor_reduction = (self:GetAbility():GetSpecialValueFor("armor_reduction") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_1")) * self:GetStackCount()
    self.magic_reduction = self:GetAbility():GetSpecialValueFor("magic_reduction")
    self.armor_minus = 0
    self.armor_minus = self:GetParent():GetPhysicalArmorValue(false) / 100 * self.armor_reduction
    if not IsServer() then return end
    self:IncrementStackCount()
end

function modifier_thomas_ability_one_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_thomas_ability_one_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_minus
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
    self.attackspeed = (self:GetParent():GetOwner():GetAttackSpeed() * 100) / self:GetAbility():GetSpecialValueFor("attack_speed_mult")
    self.networth_steal = self:GetAbility():GetSpecialValueFor("gold_steal")
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
end

function modifier_thomas_ability_two_one_gypsy:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_thomas_ability_two_one_gypsy:AddCustomTransmitterData()
    return {
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
    print(money_steal)
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
        ability:UseResources(false, false, true)
    end
end

thomas_ability_two_two = class({})

LinkLuaModifier( "modifier_thomas_ability_two_two", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_two_two_debuff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_two_two_telega", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

function thomas_ability_two_two:GetAOERadius() return 750 end

function thomas_ability_two_two:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local radius = 250
    local vector = GetGroundPosition(point + Vector(0, radius, 0), nil)
    local duration_debuff = self:GetSpecialValueFor("duration_debuff") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_8")
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
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 250, 30, true)
    self:GetParent():SetModel("models/heroes/hoodwink/hoodwink_tree_model.vmdl")
    self:GetParent():SetOriginalModel("models/heroes/hoodwink/hoodwink_tree_model.vmdl")
end

function modifier_thomas_ability_two_two:IsAura() return true end

function modifier_thomas_ability_two_two:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_thomas_ability_two_two:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_thomas_ability_two_two:GetModifierAura()
    return "modifier_thomas_ability_two_two_debuff"
end

function modifier_thomas_ability_two_two:GetAuraRadius()
    return 250
end

function modifier_thomas_ability_two_two:GetAuraDuration() return 0 end


modifier_thomas_ability_two_two_telega = class({})

function modifier_thomas_ability_two_two_telega:IsHidden() return true end
function modifier_thomas_ability_two_two_telega:IsPurgable() return false end
function modifier_thomas_ability_two_two_telega:RemoveOnDeath() return false end

function modifier_thomas_ability_two_two_telega:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(3)
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
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), origin_damage, nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
            for _, enemy in pairs(enemies) do
                local stun_duration = ability:GetSpecialValueFor("stun_duration")
                local damage = ability:GetSpecialValueFor("damage")
                enemy:AddNewModifier(caster, ability, "modifier_birzha_stunned", {duration = stun_duration})
                ApplyDamage({victim = enemy, attacker = caster, damage = damage, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL})
            end
        end)
    end
end

modifier_thomas_ability_two_two_debuff = class({})

function modifier_thomas_ability_two_two_debuff:IsHidden() return true end
function modifier_thomas_ability_two_two_debuff:IsPurgable() return false end

function modifier_thomas_ability_two_two_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end

function modifier_thomas_ability_two_two_debuff:OnCreated()
    if not IsServer() then return end
    self.vision = (self:GetParent():GetCurrentVisionRange() - 100 ) * -1
    self:StartIntervalThink(FrameTime())
end

function modifier_thomas_ability_two_two_debuff:OnIntervalThink()
    if not IsServer() then return end
    local persentage_kill = self:GetAbility():GetSpecialValueFor("health_threshold")
    if self:GetParent():GetHealthPercent() <= persentage_kill then
        self:GetParent():Kill(self:GetAbility(), self:GetCaster())
    end
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

function shelby_ultimate:GetIntrinsicModifierName()
    return "modifier_shelby_ultimate_passive"
end

function shelby_ultimate:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shelby_ultimate", {duration = duration})
end

modifier_shelby_ultimate = class({})

function modifier_shelby_ultimate:IsPurgable() return false end

function modifier_shelby_ultimate:OnCreated()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_item_echo_sabre")
    self:GetCaster():EmitSound("shelby_4")
    self.radius = self:GetAbility():GetSpecialValueFor("attack_radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_7")
    self.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/tailer/weapon_test.vmdl"})
    self.weapon:FollowEntity(self:GetParent(), true)
    local attack_per_second = self:GetParent():GetAttackSpeed() / self:GetParent():GetBaseAttackTime()
    local interval = 1 / attack_per_second
    self:StartIntervalThink(interval)
end

function modifier_shelby_ultimate:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_weapon"))

    local info = {
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
    return {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }
end

function modifier_shelby_ultimate:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_shelby_ultimate:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if parent:IsIllusion() then return end
        local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
        parent:Heal(params.damage, self:GetAbility())
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
    self.damage_percentage = (100 - self:GetAbility():GetSpecialValueFor("damage")) * -1
end

function modifier_shelby_ultimate_damage_buff:DeclareFunctions()
    local funcs = {
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

function modifier_shelby_ultimate_stack:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
    }
end

function modifier_shelby_ultimate_stack:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attackspeed_stack") + ( self:GetAbility():GetSpecialValueFor("attackspeed_stack") / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_5") ) end
function modifier_shelby_ultimate_stack:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage_stack") + ( self:GetAbility():GetSpecialValueFor("damage_stack") / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_5") ) end
function modifier_shelby_ultimate_stack:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("movespeed_stack") + ( self:GetAbility():GetSpecialValueFor("movespeed_stack") / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_5") ) end
function modifier_shelby_ultimate_stack:GetBonusDayVision() return self:GetAbility():GetSpecialValueFor("vision_stack") + ( self:GetAbility():GetSpecialValueFor("vision_stack") / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_5") ) end
function modifier_shelby_ultimate_stack:GetBonusNightVision() return self:GetAbility():GetSpecialValueFor("vision_stack") + ( self:GetAbility():GetSpecialValueFor("vision_stack") / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_shelby_5") ) end
function modifier_shelby_ultimate_stack:GetModifierMoveSpeed_Max() return 1000 end
function modifier_shelby_ultimate_stack:GetModifierMoveSpeed_Limit() return 1000 end
function modifier_shelby_ultimate_stack:GetModifierIgnoreMovespeedLimit() return 1 end

modifier_shelby_ultimate_passive = class({})

function modifier_shelby_ultimate_passive:IsPurgable() return false end

function modifier_shelby_ultimate_passive:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
    self.stack_for_active = self:GetAbility():GetSpecialValueFor("stack_for_active")
    self.unique_damage_list = {}
end

function modifier_shelby_ultimate_passive:OnIntervalThink()
    if not IsServer() then return end
    local modifiers = self:GetParent():FindAllModifiersByName("modifier_shelby_ultimate_stack")
    self:SetStackCount(#modifiers)

    if #modifiers >= self.stack_for_active then
        self:GetAbility():SetActivated(true)
    else
        self:GetAbility():SetActivated(false)
    end
end

function modifier_shelby_ultimate_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
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
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shelby_ultimate_stack", {}) 
        if (#stacks + 1) < 6 and (#stacks + 1) > 0 then
            print(#stacks)
            self:GetParent():EmitSound("shelby_stack_" .. tostring(#stacks + 1))
        end
    end
end

thomas_ability_three = class({})

LinkLuaModifier( "modifier_thomas_ability_three_bet_caster", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_three_bet_target", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

function thomas_ability_three:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()

    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "shelby_3", self:GetCaster())

    target:AddNewModifier(self:GetCaster(), self, "modifier_thomas_ability_three_bet_target", {})
    self:GetCaster():AddNewModifier(target, self, "modifier_thomas_ability_three_bet_caster", {})
end

modifier_thomas_ability_three_bet_caster = class({})

function modifier_thomas_ability_three_bet_caster:IsHidden() return true end
function modifier_thomas_ability_three_bet_caster:IsPurgable() return false end
function modifier_thomas_ability_three_bet_caster:RemoveOnDeath() return false end

function modifier_thomas_ability_three_bet_caster:OnCreated()
    if not IsServer() then return end
    self:GetAbility():SetActivated(false)
    self:GetAbility():EndCooldown()
    local bet = self:GetAbility():GetSpecialValueFor("money_bet") + self:GetParent():FindTalentValue("special_bonus_birzha_shelby_6")
    bet = math.min(bet, self:GetParent():GetGold())
    print(bet)
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( self:GetParent():GetPlayerID() ), 'bebra_event_activate_caster', {max = bet})
    self.bet_current = nil
    self.bet_pick = nil
    self.win = nil
end

function modifier_thomas_ability_three_bet_caster:Win()
    if not IsServer() then return end
    self.win = true
end
    
function modifier_thomas_ability_three_bet_caster:Lose()
    if not IsServer() then return end
    self.win = false
end

function modifier_thomas_ability_three_bet_caster:OnDestroy()
    if not IsServer() then return end
    local player = PlayerResource:GetPlayer( self:GetParent():GetPlayerID() )
    if player then
        CustomGameEventManager:Send_ServerToPlayer( player, 'bebra_event_close', {} )
    end
    self:GetAbility():UseResources(false, false, true)
    self:GetAbility():SetActivated(true)
end

modifier_thomas_ability_three_bet_target = class({})

function modifier_thomas_ability_three_bet_target:IsHidden() return true end
function modifier_thomas_ability_three_bet_target:IsPurgable() return false end
function modifier_thomas_ability_three_bet_target:RemoveOnDeath() return false end
function modifier_thomas_ability_three_bet_target:OnCreated()
    if not IsServer() then return end
    self.bet_current = nil
    self.bet_pick = nil
    self.win = nil
    self:StartIntervalThink(0.1)
end

function modifier_thomas_ability_three_bet_target:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    if not self:GetCaster():IsAlive() then return end
    if self.win == nil then return end
    local enemy_modifier = self:GetCaster():FindModifierByName("modifier_thomas_ability_three_bet_caster")
    if enemy_modifier == nil then return end
    if enemy_modifier.win == nil then return end

    if self.win == true and enemy_modifier.win == true then
        enemy_modifier:Destroy()
        self:Destroy()
    elseif self.win == false and enemy_modifier.win == false then
        enemy_modifier:Destroy()
        self:Destroy()
    elseif self.win == false and enemy_modifier.win == true then
        local mod = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_thomas_shelby_debuff_dolgi", {})
        mod:SetStackCount(self.bet_current)
        self:GetCaster():ModifyGold(self.bet_current, true, 0)
        enemy_modifier:Destroy()
        self:Destroy()
    elseif self.win == true and enemy_modifier.win == false then
        local mod = self:GetCaster():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_thomas_shelby_debuff_dolgi", {})
        mod:SetStackCount(self.bet_current )
        self:GetParent():ModifyGold(self.bet_current, true, 0)
        enemy_modifier:Destroy()
        self:Destroy()
    end
end

function modifier_thomas_ability_three_bet_target:OnDestroy()
    if not IsServer() then return end
    local player = PlayerResource:GetPlayer( self:GetParent():GetPlayerID() )
    if player then
        CustomGameEventManager:Send_ServerToPlayer( player, 'bebra_event_close', {} )
    end
end

function modifier_thomas_ability_three_bet_target:Win()
    if not IsServer() then return end
    self.win = true
end
    
function modifier_thomas_ability_three_bet_target:Lose()
    if not IsServer() then return end
    self.win = false
end

LinkLuaModifier( "modifier_shelby_shard", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shelby_shard_buff", "abilities/heroes/bebra.lua", LUA_MODIFIER_MOTION_NONE)

shelby_shard = class({})

function shelby_shard:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
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
function modifier_shelby_shard:IsHidden() return not self:GetCaster():HasShard() end

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
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_shelby_shard:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then return end
    if params.attacker ~= self:GetParent() then return end
    if not self:GetParent():HasShard() then return end

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

function modifier_shelby_shard_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

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

function modifier_shelby_shard_buff:GetModifierIncomingDamage_Percentage()
    if not self:GetParent():HasShard() then return end
    return self:GetAbility():GetSpecialValueFor("resist")
end



shelby_scepter = class({})