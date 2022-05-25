LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

pucci_time_acceleration = class({})

LinkLuaModifier("modifier_pucci_time_acceleration_thinker", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pucci_time_acceleration_debuff", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)

function pucci_time_acceleration:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_pucci_1")
end


function pucci_time_acceleration:OnUpgrade()
    local mod = self:GetCaster():FindModifierByName("modifier_pucci_restart_world")
    if mod then
        if mod:GetStackCount() < 2 then
            self:SetActivated(false)
        end
    else
        self:SetActivated(false)
    end
end

function pucci_time_acceleration:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")

    local increase = 1
     
    local mod = self:GetCaster():FindModifierByName("modifier_pucci_restart_world")
    if mod then
        if mod:GetStackCount() >= 10 then
            increase = 3
        elseif mod:GetStackCount() >= 5 then
            increase = 2.5
        elseif mod:GetStackCount() >= 2 then
            increase = 2
        end
    end

    if increase == 1 then return end

    local particle = ParticleManager:CreateParticle("particles/pucci/time_exelec.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(300, 300, 300))

    self:SetActivated(false)
    self:EndCooldown()
    EmitGlobalSound("pucci_word_timescale")
    local ability = self
    Convars:SetFloat("host_timescale", increase)

    if self:GetCaster():HasTalent("special_bonus_birzha_pucci_2") then
        CreateModifierThinker( self:GetCaster(), self, "modifier_pucci_time_acceleration_thinker", {duration = duration * Convars:GetFloat("host_timescale")}, Vector(0,0,0), self:GetCaster():GetTeamNumber(), false )
    end

    Timers:CreateTimer({
        useGameTime = false,
        endTime = duration * Convars:GetFloat("host_timescale"),
        callback = function()
            Convars:SetFloat("host_timescale", 1)
            ability:SetActivated(true)
            ability:UseResources(false, false, true)
            return nil
        end
    })
end

modifier_pucci_time_acceleration_thinker = class({})

function modifier_pucci_time_acceleration_thinker:IsAura()
    return true
end

function modifier_pucci_time_acceleration_thinker:GetModifierAura()
    return "modifier_pucci_time_acceleration_debuff"
end

function modifier_pucci_time_acceleration_thinker:GetAuraRadius()
    return -1
end

function modifier_pucci_time_acceleration_thinker:GetAuraDuration()
    return 0.1
end

function modifier_pucci_time_acceleration_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_pucci_time_acceleration_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

modifier_pucci_time_acceleration_debuff = class({})

function modifier_pucci_time_acceleration_debuff:IsHidden() return true end

function modifier_pucci_time_acceleration_debuff:OnCreated()
    self.vision_day = 0
    self.vision_night = 0
    self.vision_day = -1 * (self:GetParent():GetDayTimeVisionRange() * 0.7)
    self.vision_night = -1 * (self:GetParent():GetNightTimeVisionRange() * 0.7)
end


function modifier_pucci_time_acceleration_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end
function modifier_pucci_time_acceleration_debuff:GetBonusDayVision( params )
    return self.vision_day
end

function modifier_pucci_time_acceleration_debuff:GetBonusNightVision( params )
    return self.vision_night
end









pucci_erace_disk = class({})

LinkLuaModifier("modifier_pucci_erace_disk", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)

pucci_erace_disk.duration_use = 1

function pucci_erace_disk:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function pucci_erace_disk:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local base_duration = self:GetSpecialValueFor("duration")
    local base_dmg_heal =  self:GetSpecialValueFor("damage_heal")
    local max_duration = self:GetSpecialValueFor("max_duration")
    local bonus_duration = self:GetSpecialValueFor("duration_per_use")
    self:GetCaster():EmitSound("pucci_erase_disk")
    if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        target:Heal(base_dmg_heal, self)
        target:GiveMana(base_dmg_heal)
    else
        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = base_dmg_heal, damage_type = self:GetAbilityDamageType(), ability = self})
        target:AddNewModifier(self:GetCaster(), self, "modifier_pucci_erace_disk", {duration = self.duration_use})
        if self.duration_use < max_duration then
            self.duration_use = self.duration_use + bonus_duration
        end
    end
    local particle = ParticleManager:CreateParticle("particles/pucci/erace_disk_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
    if ability_pucci and ability_pucci:GetLevel() > 0 then
        if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_use_erase_disk" then
            ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
            local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                ability_pucci.current_quest[4] = true
                ability_pucci.word_count = ability_pucci.word_count + 1
                ability_pucci:SetActivated(true)
                ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_use_abakan"]
                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            end
        end
    end
end

modifier_pucci_erace_disk = class({})

function modifier_pucci_erace_disk:IsPurgable() return false end

function modifier_pucci_erace_disk:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    return state
end


pucci_cmoon = class({})

LinkLuaModifier("modifier_pucci_cmoon", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)

function pucci_cmoon:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    if self:GetCaster():HasTalent("special_bonus_birzha_pucci_3") then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end
    return behavior
end

function pucci_cmoon:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("pucci_word_cmoon")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pucci_cmoon", {duration = duration})
end

modifier_pucci_cmoon = class({})

function modifier_pucci_cmoon:IsPurgable() return false end

function modifier_pucci_cmoon:OnCreated()
    self.attackers_list = {}
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/pucci/c_moon_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    self:AddParticle( particle, false, false, -1, false, false )
end

function modifier_pucci_cmoon:OnDestroy()
    if not IsServer() then return end
    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        self:GetAbility():GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )
    local particle = ParticleManager:CreateParticle("particles/pucci/c_moon_knockback.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"),self:GetAbility():GetSpecialValueFor("radius"),self:GetAbility():GetSpecialValueFor("radius")))
    for _,unit in pairs(units) do

        if not unit:IsMagicImmune() or self:GetCaster():HasTalent("special_bonus_birzha_pucci_5") then
            local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
            local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
            local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + self:GetAbility():GetSpecialValueFor("movespeed_range") * self:GetCaster():GetIdealSpeed())
            local knockbackProperties =
            {
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = 0.5,
                knockback_duration = 0.5,
                knockback_distance = self:GetAbility():GetSpecialValueFor("movespeed_range") * self:GetCaster():GetIdealSpeed(),
                knockback_height = 300,
                should_stun = true,
            }
            unit:RemoveModifierByName("modifier_knockback")
            unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackProperties )
        end
    end
end

function modifier_pucci_cmoon:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

function modifier_pucci_cmoon:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then
        local target                    = self:GetParent()
        if kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
            if not self.attackers_list[ kv.attacker:entindex() ] then
                local damageTable = {
                    victim          = kv.attacker,
                    damage          = kv.original_damage * (self:GetAbility():GetSpecialValueFor("return_damage") / 100 ),
                    damage_type     = kv.damage_type,
                    damage_flags    = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                    attacker        = self:GetParent(),
                    ability         = self:GetAbility()
                }
                if not kv.attacker:IsMagicImmune() or self:GetCaster():HasTalent("special_bonus_birzha_pucci_5") then
                    ApplyDamage(damageTable)
                    kv.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")} )
                end
                self.attackers_list[ kv.attacker:entindex() ] = kv.attacker
                local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
                if ability_pucci and ability_pucci:GetLevel() > 0 then
                    if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_use_cmoon" then
                        ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                        local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                            ability_pucci.current_quest[4] = true
                            ability_pucci:SetActivated(true)
                            ability_pucci.word_count = ability_pucci.word_count + 1
                            ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_respawn"]
                            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        end
                    end
                end
                return kv.damage
            end
        end
    end
end



pucci_passive_wave = class({})

LinkLuaModifier("modifier_pucci_passive_wave", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pucci_passive_wave_immortality", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)

function pucci_passive_wave:GetIntrinsicModifierName()
    return "modifier_pucci_passive_wave"
end

modifier_pucci_passive_wave = class({})

function modifier_pucci_passive_wave:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
    self.damage_count = 0
end

function modifier_pucci_passive_wave:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_MIN_HEALTH
    }

    return funcs
end

function modifier_pucci_passive_wave:OnTooltip()
    return self.damage_count
end

function modifier_pucci_passive_wave:OnTakeDamage( params )
    local max_stacks = self:GetAbility():GetSpecialValueFor("damage_need")
    if not IsServer() then return end
    if params.unit == self:GetParent() and params.attacker ~= self:GetParent() then
        if params.attacker:GetUnitName() ~= "dota_fountain" then
            if self:GetParent():HasModifier("modifier_pucci_passive_wave_immortality") then return end
            if params.attacker:IsBoss() then return end
            if self:GetParent():IsIllusion() then return end
            if not self:GetParent():IsAlive() then return end
            if self.damage_count > max_stacks then
                self:IncrementStackCount()
                self.damage_count = 0
                return
            end
            if self.damage_count <= max_stacks then
                self.damage_count = self.damage_count + params.damage
                self:OnTooltip()
            end
        end
        if self:GetParent():GetHealth() > 1 then return end
        if self:GetStackCount() <= 0 then return end
        if not self:GetAbility():IsFullyCastable() then return end
        if self:GetParent():PassivesDisabled() then return end
        self:GetAbility():UseResources(false, false, true)
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pucci_passive_wave_immortality", {duration = self:GetAbility():GetSpecialValueFor("duration")})
        self:DecrementStackCount()
    end
end

function modifier_pucci_passive_wave:GetMinHealth()
    if not self:GetAbility():IsFullyCastable() then return end
    if self:GetStackCount() <= 0 then return end
    return 1
end

modifier_pucci_passive_wave_immortality = class({})

function modifier_pucci_passive_wave_immortality:OnCreated()
    if not IsServer() then return end
    self:GetCaster():EmitSound("pucci_word_passive")
    local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
    if ability_pucci and ability_pucci:GetLevel() > 0 then
        if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_wave" then
            ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
            local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                ability_pucci.current_quest[4] = true
                ability_pucci:SetActivated(true)
                ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_damage"]
                ability_pucci.word_count = ability_pucci.word_count + 1
                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            end
        end
    end
end

function modifier_pucci_passive_wave_immortality:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Heal(500000, self:GetAbility())
    self:GetParent():GiveMana(500000)
end

function modifier_pucci_passive_wave_immortality:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MIN_HEALTH,
    }

    return funcs
end

function modifier_pucci_passive_wave_immortality:GetMinHealth()
    return 1
end

function modifier_pucci_passive_wave_immortality:GetEffectName()
    return "particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold.vpcf"
end

function modifier_pucci_passive_wave_immortality:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end



pucci_passive_dio = class({})

LinkLuaModifier("modifier_pucci_passive_dio", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pucci_passive_dio_aura", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)

function pucci_passive_dio:GetIntrinsicModifierName()
    return "modifier_pucci_passive_dio"
end

modifier_pucci_passive_dio = class({})

function modifier_pucci_passive_dio:RemoveOnDeath() return false end

function modifier_pucci_passive_dio:IsHidden() 
    return true
end

function modifier_pucci_passive_dio:IsPurgable() return false end
function modifier_pucci_passive_dio:IsDebuff() return false end

function modifier_pucci_passive_dio:GetAuraRadius()
    return -1
end

function modifier_pucci_passive_dio:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_pucci_passive_dio:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_pucci_passive_dio:GetAuraEntityReject(target)
    if target:GetUnitName() == "npc_dota_hero_faceless_void" then
        return false
    else
        return true
    end
end

function modifier_pucci_passive_dio:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_pucci_passive_dio:GetModifierAura()
    return "modifier_pucci_passive_dio_aura"
end

function modifier_pucci_passive_dio:IsAura()
    return true
end

modifier_pucci_passive_dio_aura = class({})

function modifier_pucci_passive_dio_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }

    return funcs
end

function modifier_pucci_passive_dio_aura:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_in")
end

function modifier_pucci_passive_dio_aura:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_out")
end



pucci_restart_world = class({})

LinkLuaModifier("modifier_pucci_restart_world", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pucci_restart_world_thinker", "abilities/heroes/pucci", LUA_MODIFIER_MOTION_NONE)

pucci_restart_world.quests = {
    ["birzhamemov_solo"] = {
        ["pucci_quest_run"] = { "pucci_quest_run", 0, 20000, false},
        ["pucci_quest_use_nimb"] = { "pucci_quest_use_nimb", 0, 4, false},
        ["pucci_quest_use_erase_disk"] = { "pucci_quest_use_erase_disk", 0, 6, false},
        ["pucci_quest_use_abakan"] = { "pucci_quest_use_abakan", 0, 12, false},
        ["pucci_quest_use_cmoon"] = { "pucci_quest_use_cmoon", 0, 6, false},
        ["pucci_quest_respawn"] = { "pucci_quest_respawn", 0, 2, false},
        ["pucci_quest_stunned"] = { "pucci_quest_stunned", 0, 5, false},
        ["pucci_quest_observer_ward"] = { "pucci_quest_observer_ward", 0, 5, false},
        ["pucci_quest_sentry_ward"] = { "pucci_quest_sentry_ward", 0, 8, false},
        ["pucci_quest_wave"] = { "pucci_quest_wave", 0, 2, false},
        ["pucci_quest_damage"] = { "pucci_quest_damage", 0, 4000, false},
        ["pucci_quest_trees"] = { "pucci_quest_trees", 0, 20, false},
        ["pucci_quest_time_acceleration"] = { "pucci_quest_time_acceleration", 0, 10, false},
        ["pucci_quest_stand_point"] = { "pucci_quest_stand_point", 0, 2, false},
    },
    ["birzhamemov_duo"] = {
        ["pucci_quest_run"] = { "pucci_quest_run", 0, 25000, false},
        ["pucci_quest_use_nimb"] = { "pucci_quest_use_nimb", 0, 4, false},
        ["pucci_quest_use_erase_disk"] = { "pucci_quest_use_erase_disk", 0, 6, false},
        ["pucci_quest_use_abakan"] = { "pucci_quest_use_abakan", 0, 12, false},
        ["pucci_quest_use_cmoon"] = { "pucci_quest_use_cmoon", 0, 6, false},
        ["pucci_quest_respawn"] = { "pucci_quest_respawn", 0, 2, false},
        ["pucci_quest_stunned"] = { "pucci_quest_stunned", 0, 7, false},
        ["pucci_quest_observer_ward"] = { "pucci_quest_observer_ward", 0, 6, false},
        ["pucci_quest_sentry_ward"] = { "pucci_quest_sentry_ward", 0, 8, false},
        ["pucci_quest_wave"] = { "pucci_quest_wave", 0, 2, false},
        ["pucci_quest_damage"] = { "pucci_quest_damage", 0, 4000, false},
        ["pucci_quest_trees"] = { "pucci_quest_trees", 0, 20, false},
        ["pucci_quest_time_acceleration"] = { "pucci_quest_time_acceleration", 0, 15, false},
        ["pucci_quest_stand_point"] = { "pucci_quest_stand_point", 0, 2, false},
    },
    ["birzhamemov_trio"] = {
        ["pucci_quest_run"] = { "pucci_quest_run", 0, 30000, false},
        ["pucci_quest_use_nimb"] = { "pucci_quest_use_nimb", 0, 5, false},
        ["pucci_quest_use_erase_disk"] = { "pucci_quest_use_erase_disk", 0, 6, false},
        ["pucci_quest_use_abakan"] = { "pucci_quest_use_abakan", 0, 15, false},
        ["pucci_quest_use_cmoon"] = { "pucci_quest_use_cmoon", 0, 7, false},
        ["pucci_quest_respawn"] = { "pucci_quest_respawn", 0, 2, false},
        ["pucci_quest_stunned"] = { "pucci_quest_stunned", 0, 9, false},
        ["pucci_quest_observer_ward"] = { "pucci_quest_observer_ward", 0, 7, false},
        ["pucci_quest_sentry_ward"] = { "pucci_quest_sentry_ward", 0, 10, false},
        ["pucci_quest_wave"] = { "pucci_quest_wave", 0, 2, false},
        ["pucci_quest_damage"] = { "pucci_quest_damage", 0, 5000, false},
        ["pucci_quest_trees"] = { "pucci_quest_trees", 0, 20, false},
        ["pucci_quest_time_acceleration"] = { "pucci_quest_time_acceleration", 0, 20, false},
        ["pucci_quest_stand_point"] = { "pucci_quest_stand_point", 0, 2, false},
    },
    ["birzhamemov_5v5"] = {
        ["pucci_quest_run"] = { "pucci_quest_run", 0, 35000, false},
        ["pucci_quest_use_nimb"] = { "pucci_quest_use_nimb", 0, 6, false},
        ["pucci_quest_use_erase_disk"] = { "pucci_quest_use_erase_disk", 0, 8, false},
        ["pucci_quest_use_abakan"] = { "pucci_quest_use_abakan", 0, 20, false},
        ["pucci_quest_use_cmoon"] = { "pucci_quest_use_cmoon", 0, 9, false},
        ["pucci_quest_respawn"] = { "pucci_quest_respawn", 0, 2, false},
        ["pucci_quest_stunned"] = { "pucci_quest_stunned", 0, 11, false},
        ["pucci_quest_observer_ward"] = { "pucci_quest_observer_ward", 0, 8, false},
        ["pucci_quest_sentry_ward"] = { "pucci_quest_sentry_ward", 0, 12, false},
        ["pucci_quest_wave"] = { "pucci_quest_wave", 0, 2, false},
        ["pucci_quest_damage"] = { "pucci_quest_damage", 0, 5000, false},
        ["pucci_quest_trees"] = { "pucci_quest_trees", 0, 25, false},
        ["pucci_quest_time_acceleration"] = { "pucci_quest_time_acceleration", 0, 25, false},
        ["pucci_quest_stand_point"] = { "pucci_quest_stand_point", 0, 2, false},
    },
    ["birzhamemov_5v5v5"] = {
        ["pucci_quest_run"] = { "pucci_quest_run", 0, 50000, false},
        ["pucci_quest_use_nimb"] = { "pucci_quest_use_nimb", 0, 7, false},
        ["pucci_quest_use_erase_disk"] = { "pucci_quest_use_erase_disk", 0, 10, false},
        ["pucci_quest_use_abakan"] = { "pucci_quest_use_abakan", 0, 23, false},
        ["pucci_quest_use_cmoon"] = { "pucci_quest_use_cmoon", 0, 10, false},
        ["pucci_quest_respawn"] = { "pucci_quest_respawn", 0, 2, false},
        ["pucci_quest_stunned"] = { "pucci_quest_stunned", 0, 12, false},
        ["pucci_quest_observer_ward"] = { "pucci_quest_observer_ward", 0, 9, false},
        ["pucci_quest_sentry_ward"] = { "pucci_quest_sentry_ward", 0, 14, false},
        ["pucci_quest_wave"] = { "pucci_quest_wave", 0, 2, false},
        ["pucci_quest_damage"] = { "pucci_quest_damage", 0, 7000, false},
        ["pucci_quest_trees"] = { "pucci_quest_trees", 0, 30, false},
        ["pucci_quest_time_acceleration"] = { "pucci_quest_time_acceleration", 0, 30, false},
        ["pucci_quest_stand_point"] = { "pucci_quest_stand_point", 0, 2, false},
    },
    ["birzhamemov_zxc"] = {
        ["pucci_quest_run"] = { "pucci_quest_run", 0, 20000, false},
        ["pucci_quest_use_nimb"] = { "pucci_quest_use_nimb", 0, 4, false},
        ["pucci_quest_use_erase_disk"] = { "pucci_quest_use_erase_disk", 0, 6, false},
        ["pucci_quest_use_abakan"] = { "pucci_quest_use_abakan", 0, 15, false},
        ["pucci_quest_use_cmoon"] = { "pucci_quest_use_cmoon", 0, 7, false},
        ["pucci_quest_respawn"] = { "pucci_quest_respawn", 0, 2, false},
        ["pucci_quest_stunned"] = { "pucci_quest_stunned", 0, 5, false},
        ["pucci_quest_observer_ward"] = { "pucci_quest_observer_ward", 0, 6, false},
        ["pucci_quest_sentry_ward"] = { "pucci_quest_sentry_ward", 0, 8, false},
        ["pucci_quest_wave"] = { "pucci_quest_wave", 0, 3, false},
        ["pucci_quest_damage"] = { "pucci_quest_damage", 0, 4000, false},
        ["pucci_quest_trees"] = { "pucci_quest_trees", 0, 35, false},
        ["pucci_quest_time_acceleration"] = { "pucci_quest_time_acceleration", 0, 5, false},
        ["pucci_quest_stand_point"] = { "pucci_quest_stand_point", 0, 2, false},
    },
}

pucci_restart_world.current_quest = nil
pucci_restart_world.word_count = 0

pucci_restart_world.word_count_to_win = 0

function pucci_restart_world:GetIntrinsicModifierName()
    return "modifier_pucci_restart_world"
end

function pucci_restart_world:Spawn()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_pucci_restart_world") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pucci_restart_world", {})
    end
end

function pucci_restart_world:OnUpgrade()
    local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_activate", {} )
    if self:GetLevel() == 1 then
        self.current_quest = self.quests[GetMapName()]["pucci_quest_run"]
        if IsInToolsMode() then
            --self.current_quest = self.quests[GetMapName()]["pucci_quest_time_acceleration"]
            --self.word_count = 14
        end
        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = self.current_quest[1], min = self.current_quest[2], max = self.current_quest[3]} )
    end
    if self.word_count == 0 then
        self:SetActivated(false)
    end
end

function pucci_restart_world:OnSpellStart()
    if not IsServer() then return end
    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        self:GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        FIND_ANY_ORDER,
        false
    )

    for _,unit in pairs(units) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetSpecialValueFor("stun_duration")} )
    end

    self.word_count = self.word_count - 1
    self.word_count_to_win = self.word_count_to_win + 1

    if self.word_count <= 0 then
        self:SetActivated(false)
    end

    local mod = self:GetCaster():FindModifierByName("modifier_pucci_restart_world")
    if mod then
        mod:IncrementStackCount()
    end

    local particle = ParticleManager:CreateParticle("particles/pucci/ultimate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())

    if mod then
        if mod:GetStackCount() >= 2 then
            local ab = self:GetCaster():FindAbilityByName("pucci_time_acceleration")
            if ab then
                ab:SetActivated(true)
            end
        end
    end

    EmitGlobalSound("pucci_word_"..self.word_count_to_win)

    if self.word_count_to_win >= 14 then
        BirzhaGameMode:AddScoreToTeam( self:GetCaster():GetTeamNumber(), 150 )
    end
end

modifier_pucci_restart_world = class({})

function modifier_pucci_restart_world:IsPurgable() return false end
function modifier_pucci_restart_world:IsPurgeException() return false end
function modifier_pucci_restart_world:RemoveOnDeath() return false end

function modifier_pucci_restart_world:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_UNIT_MOVED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }

    return funcs
end

function modifier_pucci_restart_world:GetModifierMoveSpeedBonus_Constant()
    if not self:GetParent():HasTalent("special_bonus_birzha_pucci_4") then return end
    return 550
end

function modifier_pucci_restart_world:GetModifierIncomingDamage_Percentage()
    if not self:GetParent():HasTalent("special_bonus_birzha_pucci_6") then return end
    return -20
end

function modifier_pucci_restart_world:OnUnitMoved( params )
    if IsServer() then
        local unit = params.unit
        local caster = self:GetParent()
        if unit == caster then
          
            if self.last_position == nil then
                self.last_position = caster:GetAbsOrigin()
            else
                local bonus = (self.last_position - caster:GetAbsOrigin()):Length2D()
                local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
                if ability_pucci and ability_pucci:GetLevel() > 0 then
                    if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_run" then
                        ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + math.ceil(bonus)
                        local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                            ability_pucci.current_quest[4] = true
                            ability_pucci:SetActivated(true)
                            ability_pucci.word_count = ability_pucci.word_count + 1
                            ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_use_nimb"]
                            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        end
                    end
                end
                self.last_position = caster:GetAbsOrigin()
            end  
        end
    end
end

function modifier_pucci_restart_world:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == self:GetAbility() then return end

        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if params.target ~= nil then return end

        if hAbility:GetAbilityName() == "item_ward_observer" then
            local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
            if ability_pucci and ability_pucci:GetLevel() > 0 then
                if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_observer_ward" then
                    ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                    local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                    CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                        ability_pucci.current_quest[4] = true
                        ability_pucci:SetActivated(true)
                        ability_pucci.word_count = ability_pucci.word_count + 1
                        ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_sentry_ward"]
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    end
                end
            end
        end

        if hAbility:GetAbilityName() == "item_ward_sentry" then
            local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
            if ability_pucci and ability_pucci:GetLevel() > 0 then
                if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_sentry_ward" then
                    ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                    local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                    CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                        ability_pucci.current_quest[4] = true
                        ability_pucci:SetActivated(true)
                        ability_pucci.word_count = ability_pucci.word_count + 1
                        ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_wave"]
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    end
                end
            end
        end

        if hAbility:GetAbilityName() == "item_ward_dispenser" then
            if hAbility:GetToggleState() then
                local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
                if ability_pucci and ability_pucci:GetLevel() > 0 then
                    if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_observer_ward" then
                        ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                        local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                            ability_pucci.current_quest[4] = true
                            ability_pucci:SetActivated(true)
                            ability_pucci.word_count = ability_pucci.word_count + 1
                            ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_sentry_ward"]
                            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        end
                    end
                end
            else
                local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
                if ability_pucci and ability_pucci:GetLevel() > 0 then
                    if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_sentry_ward" then
                        ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                        local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                            ability_pucci.current_quest[4] = true
                            ability_pucci:SetActivated(true)
                            ability_pucci.word_count = ability_pucci.word_count + 1
                            ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_wave"]
                            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                        end
                    end
                end
            end
        end

        if hAbility:GetAbilityName() == "item_branches" then
            local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
            if ability_pucci and ability_pucci:GetLevel() > 0 then
                if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_trees" then
                    ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                    local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                    CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                        ability_pucci.current_quest[4] = true
                        ability_pucci:SetActivated(true)
                        ability_pucci.word_count = ability_pucci.word_count + 1
                        ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_time_acceleration"]
                        CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    end
                end
            end
        end
    end
        
end

function modifier_pucci_restart_world:OnDeath( params )
    if not IsServer() then return end
    if Convars:GetFloat("host_timescale") ~= 1 then
        if not params.unit:IsRealHero() then return end
        local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
        if ability_pucci and ability_pucci:GetLevel() > 0 then
            if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_time_acceleration" then
                ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                    ability_pucci.current_quest[4] = true
                    ability_pucci.word_count = ability_pucci.word_count + 1
                    ability_pucci:SetActivated(true)
                    ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_stand_point"]
                    CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                    for i=1,2 do
                        if i == 1 then
                            CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_pucci_restart_world_thinker", {}, GetGroundPosition(Vector(0,0,0)+RandomVector(RandomFloat( -1200, -1800 )), nil), self:GetCaster():GetTeamNumber(), false )
                        else
                            CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_pucci_restart_world_thinker", {}, GetGroundPosition(Vector(0,0,0)+RandomVector(RandomFloat( 1200, 1800 )), nil), self:GetCaster():GetTeamNumber(), false )
                        end
                    end
                end
            end
        end
    end
end

modifier_pucci_restart_world_thinker = class({})

function modifier_pucci_restart_world_thinker:IsHidden() return false end
function modifier_pucci_restart_world_thinker:IsPurgable() return false end
function modifier_pucci_restart_world_thinker:DestroyOnExpire() return false end

function modifier_pucci_restart_world_thinker:OnCreated()
    if not IsServer() then return end   
    local hParent = self:GetParent()
    self.nCaptureProgress = 0
    self.nRecaptutingTime = 0
    self.nMovingTime = 0
    self.nLifeTime = 0

    self.pCaptureRingEffect = ParticleManager:CreateParticle("particles/pucci/capture_point_ring.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.pCaptureRingEffect, 3, Vector(0,255,0))
    ParticleManager:SetParticleControl(self.pCaptureRingEffect, 9, Vector(300, 0, 0))
    self:StartIntervalThink(0.02)

end

function modifier_pucci_restart_world_thinker:OnIntervalThink()
    if not IsServer() then return end
    
    local tTargets = FindUnitsInRadius (
        self:GetParent():GetTeamNumber(), 
        self:GetParent():GetAbsOrigin(), 
        nil, 
        300, 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_HERO, 
        DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER, 
        false
    )

    for team = 0, (DOTA_TEAM_COUNT-1) do
        AddFOWViewer(team, self:GetParent():GetAbsOrigin(), 300, 0.02/Convars:GetFloat("host_timescale"), true)
    end

    for i = #tTargets, 1, -1 do
        if tTargets[i] ~= nil then
            local ab = tTargets[i]:FindAbilityByName("pucci_restart_world")
            if ab == nil then
                table.remove(tTargets, i)
            end
        end
    end

    for i = #tTargets, 1, -1 do
        if tTargets[i] ~= nil then
            if tTargets[i]:HasModifier("modifier_pucci_passive_wave_immortality") then
                table.remove(tTargets, i)
            end
        end
    end

    if #tTargets > 0 then
        if self.nRecaptutingTime <= 0 then
            self.nCapturingTeam = nTemporallyCapturingTeam
        end
        self:StartCapturePoint()
    else
        if self.pCaptureInProgressEffect then
            ParticleManager:DestroyParticle(self.pCaptureInProgressEffect, false)
            self.pCaptureInProgressEffect = nil
        end
        if self.nCaptureProgress > 0 then
            if self.nRecaptutingTime > 0 then
                self.nCaptureProgress = self.nRecaptutingTime
            end
            --self.nCaptureProgress = math.max(self.nCaptureProgress - 0.02/Convars:GetFloat("host_timescale"), 0)
            self.nRecaptutingTime = 0
            self:StartClock()
        else
            if self.pCaptureClockEffect then
                ParticleManager:DestroyParticle(self.pCaptureClockEffect, false)
                self.pCaptureClockEffect = nil
            end
            if self.nCaptureProgress > 0 then
                if self.nRecaptutingTime > 0 then
                    self.nCaptureProgress = self.nRecaptutingTime
                end
                --self.nCaptureProgress = math.max(self.nCaptureProgress - 0.02/Convars:GetFloat("host_timescale"), 0)
                self.nRecaptutingTime = 0
                self:StartClock()
            else
                if self.pCaptureClockEffect then
                    ParticleManager:DestroyParticle(self.pCaptureClockEffect, false)
                    self.pCaptureClockEffect = nil
                end
            end
        end
    end
end

function modifier_pucci_restart_world_thinker:SetRingColor()
    ParticleManager:SetParticleControl(self.pCaptureRingEffect, 3, Vector(0,255,0))
end

function modifier_pucci_restart_world_thinker:StartCapturePoint()
    if not self.pCaptureInProgressEffect then
        self.pCaptureInProgressEffect = ParticleManager:CreateParticle("particles/pucci/capture_point_ring_capturing.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    end
    ParticleManager:SetParticleControl(self.pCaptureInProgressEffect, 9, Vector(300, 0, 0))
    ParticleManager:SetParticleControl(self.pCaptureInProgressEffect, 3, Vector(0,255,255))

    if self.nRecaptutingTime <= 0 then
        self.nCaptureProgress = self.nCaptureProgress + 0.02/Convars:GetFloat("host_timescale")
        self:SetRingColor()

        if self:GetCaster():HasTalent("special_bonus_birzha_pucci_7") then
            if self.nCaptureProgress >= 105 then
                self:StopPoint()
            end
        elseif self:GetCaster():HasTalent("special_bonus_birzha_pucci_8") then
            if self.nCaptureProgress >= 90 then
                self:StopPoint()
            end
        else
            if self.nCaptureProgress >= 120 then
                self:StopPoint()
            end
        end
    else
        self.nRecaptutingTime = self.nRecaptutingTime - 0.02/Convars:GetFloat("host_timescale")
        self.nCaptureProgress = self.nCaptureProgress - 0.02/Convars:GetFloat("host_timescale")
        if self.nRecaptutingTime <= 0 then
            self.nCaptureProgress = 0
            self:SetRingColor()
        end
    end
    self:StartClock()
end

function modifier_pucci_restart_world_thinker:StartClock()
    local fCreateTimeParticle = function()
        self.pCaptureClockEffect = ParticleManager:CreateParticle("particles/pucci/capture_point_ring_clock.vpcf", PATTACH_ABSORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(self.pCaptureClockEffect, 9, Vector(300, 0, 0))
    end
    if not self.pCaptureClockEffect then
        fCreateTimeParticle()
    end

    if self.nCaptureProgress == 0 then
        if self.pCaptureClockEffect then
            ParticleManager:DestroyParticle(self.pCaptureClockEffect, false)
        end
        self.pCaptureClockEffect = nil
        fCreateTimeParticle()
        self:SetRingColor()
    end
    
    ParticleManager:SetParticleControl(self.pCaptureClockEffect, 11, Vector(0, 0, 1))
    ParticleManager:SetParticleControl(self.pCaptureClockEffect, 3, Vector(0,255,0))

    local nTime = self.nCaptureProgress
    if self.nRecaptutingTime > 0 then
        nTime = self.nRecaptutingTime
    end

    local theta = nTime / 120 * 2 * math.pi

    if self:GetCaster():HasTalent("special_bonus_birzha_pucci_7") then
        theta = nTime / 105 * 2 * math.pi
    elseif self:GetCaster():HasTalent("special_bonus_birzha_pucci_8") then
        theta = nTime / 90 * 2 * math.pi
    end

    ParticleManager:SetParticleControlForward(self.pCaptureClockEffect, 1, Vector(math.cos(theta), math.sin(theta), 0))
end

function modifier_pucci_restart_world_thinker:OnDestroy()
    local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
    if ability_pucci and ability_pucci:GetLevel() > 0 then
        if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_stand_point" then
            ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
            local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                ability_pucci.current_quest[4] = true
                ability_pucci:SetActivated(true)
                ability_pucci.word_count = ability_pucci.word_count + 1
                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            end
        end
    end
    local tParticles = {
        self.pCaptureClockEffect,
        self.pCaptureInProgressEffect,
        self.pCaptureRingEffect,
    }
    for _, particle in pairs(tParticles) do
        if particle then
            ParticleManager:DestroyParticle(particle, false)
        end
    end
end

function modifier_pucci_restart_world_thinker:StopPoint()
    if not self:IsNull() then
        self:Destroy()
    end
end





































--Жук-носорог (успешно нажать нимб 5 раз),
--Улица опустошения (использовать Erase Disc на противника 6 раз), 
--Инжирный пирог (выпить 15 пива)
--Жук-носорог (успешно использовать способность Тюремный Священник 7 раз)
--Виа Долороза (возродиться 2 раза)
--Жук-носорог (оглушить врага 9 раз)
--Точка сингулярности (поставить 9 вардов (сентри) и 3 варда (обс) )
--Точка сингулярности (поставить 8 желтых вардов) 
--Джотто (Активировать крест 2 раза),
--Ангел (нанести 4к урона)
--Гортензия (посадить 12 деревьев и cъесть ПОЖРАТЬ СХАВАТЬ фреш мит 36 деревьев)
--Жук-носорог (привести к самоубийству героя 6 раз способностью Time Acceleration или убить 2 раза)
--Тайный император (простоять минуту на месте в подсвеченной зоне, не умерев)
--
--
--
--
--
--Чтобы выложить дорогу в рай и выиграть игру, Пуччи должен сказать 14 слов. Каждое слово - задание, которое нужно выполнить.
--Как только пуччи выполняет задание, ульта получает одно слово (нажатие = произнесение).
--При произнесении слова оглушает противников в радиусе поблизости.
--Произнося 14-ое слово, Пуччи перезапускает вселенную, выигрывая игру.
--Нельзя использовать повторно, пока не выполнено текущее задание.
--
--Задания для выполнения: Спиральная лестница (пройти 30 000 единиц расстояния) 
--Жук-носорог (успешно нажать нимб 5 раз),
--Улица опустошения (использовать Erase Disc на противника 6 раз), 
--Инжирный пирог (выпить 15 пива)
--Жук-носорог (успешно использовать способность Тюремный Священник 7 раз)
--Виа Долороза (возродиться 2 раза)
--Жук-носорог (оглушить врага 9 раз)
--Точка сингулярности (поставить 9 вардов (сентри) и 3 варда (обс) )
--Точка сингулярности (поставить 8 желтых вардов) 
-- Джотто (Активировать крест 2 раза),
--Ангел (нанести 4к урона)
-- Гортензия (посадить 12 деревьев и cъесть ПОЖРАТЬ СХАВАТЬ фреш мит 36 деревьев)
--Жук-носорог (привести к самоубийству героя 6 раз способностью Time Acceleration или убить 2 раза)
--
--Тайный император (простоять минуту на месте в подсвеченной зоне, не умерев)








--pucci_quest_event_activate
--pucci_quest_event_set_quest
--pucci_quest_event_set_progress