LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gorshok_death_anarhia_zombie", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gorshok_death_anarhia_zombie_death", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )

gorshok_death_anarhia = class({}) 

function gorshok_death_anarhia:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function gorshok_death_anarhia:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

gorshok_death_anarhia.spawn_anarhist_talent = false

function gorshok_death_anarhia:OnSpellStart()
    if not IsServer() then return end

    self.count = self:GetSpecialValueFor( "zombies_count" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_7")

    if not self:GetCaster():HasTalent("special_bonus_birzha_gorshok_6") then
        for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
            if unit:GetUnitName() == "npc_gorshok_mini_zombie" and unit:GetOwner() == self:GetCaster() then
                unit:ForceKill(false)               
            end
        end
    end

    for i = 1, self.count do
        local zombie = CreateUnitByName("npc_gorshok_mini_zombie", self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300) + (self:GetCaster():GetRightVector() * 20 * i), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
        zombie:SetOwner(self:GetCaster())
        zombie:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(zombie, zombie:GetAbsOrigin(), true)
        local zombie_blood_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, zombie)
        ParticleManager:SetParticleControl(zombie_blood_particle, 0, zombie:GetAbsOrigin())
        ParticleManager:SetParticleControl(zombie_blood_particle, 1, zombie:GetAbsOrigin())
        ParticleManager:SetParticleControl(zombie_blood_particle, 2, zombie:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(zombie_blood_particle)
        zombie:SetForwardVector(self:GetCaster():GetForwardVector())
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_gorshok_death_anarhia_zombie", {})
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    end

    self:GetCaster():EmitSound("GorshokZombie")
end

function gorshok_death_anarhia:SpawnAnarchist(abs)
    local zombie = CreateUnitByName("npc_gorshok_mega_zombie", abs, true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    zombie:SetOwner(self:GetCaster())
    zombie:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
    FindClearSpaceForUnit(zombie, zombie:GetAbsOrigin(), true)
    local zombie_blood_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, zombie)
    ParticleManager:SetParticleControl(zombie_blood_particle, 0, zombie:GetAbsOrigin())
    ParticleManager:SetParticleControl(zombie_blood_particle, 1, zombie:GetAbsOrigin())
    ParticleManager:SetParticleControl(zombie_blood_particle, 2, zombie:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(zombie_blood_particle)
    zombie:SetForwardVector(self:GetCaster():GetForwardVector())
    zombie:AddNewModifier(self:GetCaster(), self, "modifier_gorshok_death_anarhia_zombie", {})
    zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    zombie:EmitSound("GorshokAnarhia")
end

modifier_gorshok_death_anarhia_zombie = class({})

function modifier_gorshok_death_anarhia_zombie:IsPurgable()
    return false
end

function modifier_gorshok_death_anarhia_zombie:IsHidden()
    return true
end

function modifier_gorshok_death_anarhia_zombie:OnCreated()
    if not IsServer() then return end
    local health = self:GetAbility():GetSpecialValueFor( "zombie_health" )
    local damage = self:GetAbility():GetSpecialValueFor( "zombie_damage" )
    local mult = self:GetAbility():GetSpecialValueFor( "zombie_multiplier" )

    if self:GetParent():GetUnitName() == "npc_gorshok_mega_zombie" then
        health = health * mult
        damage = damage * mult
    end

    self:GetParent():SetBaseDamageMin(damage)
    self:GetParent():SetBaseDamageMax(damage)
    self:GetParent():SetBaseMaxHealth(health)
    self:GetParent():SetHealth(health)
end 

function modifier_gorshok_death_anarhia_zombie:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return decFuncs
end

function modifier_gorshok_death_anarhia_zombie:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if not params.target:IsRealHero() then return end
    if not self:GetCaster():HasTalent("special_bonus_birzha_gorshok_2") then return end
    params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gorshok_death_anarhia_zombie_death", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_2")})
end

modifier_gorshok_death_anarhia_zombie_death = class({})

function modifier_gorshok_death_anarhia_zombie_death:IsHidden() return false end
function modifier_gorshok_death_anarhia_zombie_death:IsPurgable() return false end

function modifier_gorshok_death_anarhia_zombie_death:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_gorshok_death_anarhia_zombie_death:OnDeath(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    self:GetAbility():SpawnAnarchist(params.unit:GetAbsOrigin())
end

LinkLuaModifier( "modifier_gorshok_rome", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )

gorshok_rome = class({}) 

function gorshok_rome:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function gorshok_rome:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function gorshok_rome:GetCastRange(location, target)
    return self:GetSpecialValueFor( "radius" )
end

function gorshok_rome:OnSpellStart()
    if not IsServer() then return end

    local duration = self:GetSpecialValueFor( "duration" )

    local radius = self:GetSpecialValueFor( "radius" )

    self:GetCaster():EmitSound("GorshokRome")

    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_gorshok_rome", {duration = duration})
    end
end

modifier_gorshok_rome = class({})

function modifier_gorshok_rome:IsPurgable()
    return true
end

function modifier_gorshok_rome:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }

    return funcs
end

function modifier_gorshok_rome:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow") 
end

function modifier_gorshok_rome:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor") 
end

function modifier_gorshok_rome:GetModifierDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_1")
end

function modifier_gorshok_rome:GetEffectName() return "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_debuff.vpcf" end
function modifier_gorshok_rome:GetStatusEffectName() return "particles/status_fx/status_effect_brewmaster_cinder_brew.vpcf" end


LinkLuaModifier( "modifier_gorshok_writer_goodwin_caster", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gorshok_writer_goodwin_aura", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )

gorshok_writer_goodwin = class({}) 

function gorshok_writer_goodwin:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function gorshok_writer_goodwin:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function gorshok_writer_goodwin:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function gorshok_writer_goodwin:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_8")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gorshok_writer_goodwin_caster", {duration = duration})
    self:GetCaster():EmitSound("GorshokGoodwin")
end

modifier_gorshok_writer_goodwin_caster = class({})

function modifier_gorshok_writer_goodwin_caster:IsPurgable()
    return false
end

function modifier_gorshok_writer_goodwin_caster:IsAura()
    return true
end

function modifier_gorshok_writer_goodwin_caster:GetAuraDuration() return 0.03 end

function modifier_gorshok_writer_goodwin_caster:GetModifierAura()
    return "modifier_gorshok_writer_goodwin_aura"
end

function modifier_gorshok_writer_goodwin_caster:GetAuraRadius()
    return FIND_UNITS_EVERYWHERE
end

function modifier_gorshok_writer_goodwin_caster:GetAuraEntityReject(hEntity)
    if hEntity:GetOwner() == self:GetCaster() then
        return false
    end
    return true
end

function modifier_gorshok_writer_goodwin_caster:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_gorshok_writer_goodwin_caster:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end

function modifier_gorshok_writer_goodwin_caster:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

modifier_gorshok_writer_goodwin_aura = class({})

function modifier_gorshok_writer_goodwin_aura:IsPurgable()
    return false
end

function modifier_gorshok_writer_goodwin_aura:OnCreated(keys)
    local bonus_health_str = self:GetAbility():GetSpecialValueFor("bonus_health_str")
    local bonus_attack_speed_agi = self:GetAbility():GetSpecialValueFor("bonus_attack_speed_agi")
    local bonus_damage_int = self:GetAbility():GetSpecialValueFor("bonus_damage_int")
    local bonus_movespeed_kill = self:GetAbility():GetSpecialValueFor("bonus_movespeed_kill")

    if IsServer() then
        self:SetHasCustomTransmitterData(true)
        self.damage = (self:GetCaster():GetIntellect() * bonus_damage_int)
        self.attack_speed = (self:GetCaster():GetAgility() * bonus_attack_speed_agi)
        self.movespeed = (self:GetCaster():GetKills() * bonus_movespeed_kill)
        self.health = (self:GetCaster():GetStrength() * bonus_health_str)
    end

    self:StartIntervalThink(1)
end

function modifier_gorshok_writer_goodwin_aura:OnIntervalThink()
    if not IsServer() then return end
    self:OnCreated()
end

function modifier_gorshok_writer_goodwin_aura:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }
    return funcs
end

function modifier_gorshok_writer_goodwin_aura:AddCustomTransmitterData() 
    return 
    {
        damage = self.damage,
        attack_speed = self.attack_speed,
        movespeed = self.movespeed,
        health = self.health
    } 
end

function modifier_gorshok_writer_goodwin_aura:HandleCustomTransmitterData(data)
    self.damage = data.damage
    self.attack_speed = data.attack_speed
    self.movespeed = data.movespeed
    self.health = data.health
end

function modifier_gorshok_writer_goodwin_aura:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_gorshok_writer_goodwin_aura:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_gorshok_writer_goodwin_aura:GetModifierMoveSpeedBonus_Constant()
    return self.movespeed
end

function modifier_gorshok_writer_goodwin_aura:GetModifierExtraHealthBonus()
    return self.health
end

function modifier_gorshok_writer_goodwin_aura:GetEffectName() return "particles/units/heroes/hero_clinkz/clinkz_death_pact_buff.vpcf" end

LinkLuaModifier( "modifier_gorshok_evil_dance", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )

gorshok_evil_dance = class({}) 

function gorshok_evil_dance:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function gorshok_evil_dance:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function gorshok_evil_dance:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_gorshok_evil_dance", {duration = duration})
    end
    self:GetCaster():EmitSound("GorshokDance")
end

modifier_gorshok_evil_dance = class({})

function modifier_gorshok_evil_dance:IsPurgable()
    return false
end

function modifier_gorshok_evil_dance:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_gorshok_evil_dance:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_4")
end

function modifier_gorshok_evil_dance:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_magical_resist")
end

function modifier_gorshok_evil_dance:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_gorshok_evil_dance:GetEffectName() return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf" end

LinkLuaModifier( "modifier_gorshok_wodoo", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gorshok_wodoo_movespeed", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gorshok_wodoo_hunt", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE )

gorshok_wodoo = class({}) 

function gorshok_wodoo:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_5")
end

function gorshok_wodoo:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function gorshok_wodoo:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_gorshok_wodoo_movespeed", {duration = duration})
        unit:AddNewModifier(self:GetCaster(), self, "modifier_movespeed_cap", {duration = duration})
    end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gorshok_wodoo", {duration = duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_movespeed_cap", {duration = duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gorshok_wodoo_movespeed", {duration = duration})
    self:GetCaster():EmitSound("GorshokTalent")
end

modifier_gorshok_wodoo_movespeed = class({})

function modifier_gorshok_wodoo_movespeed:IsHidden()
    return true
end

function modifier_gorshok_wodoo_movespeed:IsPurgable()
    return false
end

function modifier_gorshok_wodoo_movespeed:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_gorshok_wodoo_movespeed:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed") 
end

modifier_gorshok_wodoo = class({})

function modifier_gorshok_wodoo:IsPurgable()
    return false
end

function modifier_gorshok_wodoo:OnCreated()
    self.damage = 0
    self.damage_for_hunt = self:GetAbility():GetSpecialValueFor( "damage_for_hunt" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gorshok_3")
end

function modifier_gorshok_wodoo:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_gorshok_wodoo:OnTakeDamage( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.unit
    if parent == params.attacker:GetOwner() and target:GetTeamNumber() ~= parent:GetTeamNumber() then 
        local controlled = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
        for i = #controlled, 1, -1 do
            if controlled[i] ~= nil and controlled[i]:GetUnitName() ~= "npc_gorshok_hunt" then
                table.remove(controlled, i)
            end
        end
        local max_count = self:GetAbility():GetSpecialValueFor("max_count")
        if self:GetCaster():HasShard() then
            max_count = max_count + self:GetAbility():GetSpecialValueFor("max_count_shard")
        end
        if #controlled < max_count then
            self.damage = self.damage + params.damage
            if self.damage >= self.damage_for_hunt then
                local hunt = CreateUnitByName("npc_gorshok_hunt", target:GetAbsOrigin(), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
                hunt:SetOwner(self:GetCaster())
                hunt:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
                FindClearSpaceForUnit(hunt, hunt:GetAbsOrigin(), true)
                hunt:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gorshok_wodoo_hunt", {})
                self.damage = 0
            end
            self:SetStackCount(self.damage)
        end
    end
end

function modifier_gorshok_wodoo:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("GorshokTalent")
end

modifier_gorshok_wodoo_hunt = class({})

function modifier_gorshok_wodoo_hunt:IsPurgable()
    return false
end

function modifier_gorshok_wodoo_hunt:IsHidden()
    return true
end

function modifier_gorshok_wodoo_hunt:OnCreated()
    if not IsServer() then return end
    local health = self:GetAbility():GetSpecialValueFor( "hunt_health" )
    local damage = self:GetAbility():GetSpecialValueFor( "hunt_damage" )
    self:GetParent():SetBaseDamageMin(damage)
    self:GetParent():SetBaseDamageMax(damage)
    self:GetParent():SetBaseMaxHealth(health)
    self:GetParent():SetHealth(health)
end 


LinkLuaModifier("modifier_gorshok_broodmother_spin_web_aura", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gorshok_broodmother_spin_web", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gorshok_spin_web_charge", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gorshok_spin_web_cooldown", "abilities/heroes/gorshok", LUA_MODIFIER_MOTION_NONE)


gorshok_spin_web = class({})

function gorshok_spin_web:GetCastRange(location, target)
    if IsServer() then
        if IsNearEntity("npc_dota_broodmother_web", location, self:GetSpecialValueFor("radius") * 2, self:GetCaster()) then
            return 25000
        end
    end

    return self.BaseClass.GetCastRange(self, location, target)
end

function gorshok_spin_web:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function gorshok_spin_web:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function gorshok_spin_web:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function gorshok_spin_web:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    local target_point = ability:GetCursorPosition()
    local modifier_aura_friendly = "modifier_gorshok_broodmother_spin_web_aura"
    local count = ability:GetSpecialValueFor("count")
    local web_count = count
    local webs = Entities:FindAllByClassname("npc_dota_broodmother_web")
    if #webs >= web_count then
        local table_position = nil
        local oldest_web = nil

        for k, web in pairs(webs) do
            if table_position == nil then table_position = k end
            if oldest_web == nil then oldest_web = web end

            if web.spawn_time < oldest_web.spawn_time then
                oldest_web = web
                table_position = k
            end
        end

        if IsValidEntity(oldest_web) and oldest_web:IsAlive() then
            oldest_web:ForceKill(false)
        end
    end
    local web = CreateUnitByName("npc_dota_broodmother_web", target_point, false, caster, caster, caster:GetTeamNumber())
    web:AddNewModifier(caster, ability, modifier_aura_friendly, {})
    web:SetOwner(caster)
    web:SetControllableByPlayer(caster:GetPlayerID(), false)
    web.spawn_time = math.floor(GameRules:GetDOTATime(false, false))
    for i = 0, web:GetAbilityCount() -1 do
        local ability = web:GetAbilityByIndex(i)

        if ability then
            ability:SetLevel(1)
        end
    end
    caster:EmitSound("GorshokForest")
end

modifier_gorshok_broodmother_spin_web_aura = class({})

function modifier_gorshok_broodmother_spin_web_aura:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()    
    self.radius = self.ability:GetSpecialValueFor("radius")

    if IsServer() then
        self:GetParent():EmitSound("Hero_Broodmother.WebLoop")
    end
end

function modifier_gorshok_broodmother_spin_web_aura:IsAura() return true end
function modifier_gorshok_broodmother_spin_web_aura:GetAuraDuration() return 0.2 end
function modifier_gorshok_broodmother_spin_web_aura:GetAuraRadius() return self.radius end
function modifier_gorshok_broodmother_spin_web_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_gorshok_broodmother_spin_web_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_gorshok_broodmother_spin_web_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_gorshok_broodmother_spin_web_aura:GetModifierAura() return "modifier_gorshok_broodmother_spin_web" end
function modifier_gorshok_broodmother_spin_web_aura:IsHidden() return true end
function modifier_gorshok_broodmother_spin_web_aura:IsPurgable() return false end
function modifier_gorshok_broodmother_spin_web_aura:IsPurgeException() return false end
function modifier_gorshok_broodmother_spin_web_aura:RemoveOnDeath() return true end

function modifier_gorshok_broodmother_spin_web_aura:GetAuraEntityReject(hTarget)
    if not IsServer() then return end

    if hTarget == self:GetCaster() or hTarget:GetOwner() == self:GetCaster() then
        return false
    end

    return true
end

function modifier_gorshok_broodmother_spin_web_aura:CheckState() return {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
} end

function modifier_gorshok_broodmother_spin_web_aura:DeclareFunctions() return {
    MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    MODIFIER_EVENT_ON_DEATH,
} end

function modifier_gorshok_broodmother_spin_web_aura:GetModifierProvidesFOWVision()
    return 1
end

function modifier_gorshok_broodmother_spin_web_aura:OnDeath(params)
    if not IsServer() then return end

    if params.unit == self:GetParent() then
        self:GetParent():StopSound("Hero_Broodmother.WebLoop")
        UTIL_Remove(self:GetParent())
    end
end

modifier_gorshok_broodmother_spin_web = class({})

function modifier_gorshok_broodmother_spin_web:IsHidden() return true end

function modifier_gorshok_broodmother_spin_web:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
end

function modifier_gorshok_broodmother_spin_web:IsPurgable() return false end
function modifier_gorshok_broodmother_spin_web:IsPurgeException() return false end

function modifier_gorshok_broodmother_spin_web:CheckState() 
    if self:GetParent():HasModifier("modifier_gorshok_spin_web_cooldown") then return end
    return {
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    [MODIFIER_STATE_INVISIBLE] = true,
} end

function modifier_gorshok_broodmother_spin_web:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
    return decFuncs
end

function modifier_gorshok_broodmother_spin_web:OnAttackLanded( keys )
    if keys.attacker == self:GetParent() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gorshok_spin_web_cooldown", {duration = 0.5})
    end
end
function modifier_gorshok_broodmother_spin_web:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == self:GetAbility() then return end

        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gorshok_spin_web_cooldown", {duration = 0.5})
    end
        
end

function modifier_gorshok_broodmother_spin_web:GetModifierInvisibilityLevel()
    if self:GetParent():HasModifier("modifier_gorshok_spin_web_cooldown") then return 0 end
    return 1
end


modifier_gorshok_spin_web_cooldown = class({})
function modifier_gorshok_spin_web_cooldown:IsHidden() return true end
function modifier_gorshok_spin_web_cooldown:IsPurgable() return false end



