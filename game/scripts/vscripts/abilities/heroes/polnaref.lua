LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_polnaref_stand", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_disarm", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_scepter_in_stand_buff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_scepter_in_stand_buff_stand", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_stand_inside = class({})

function polnaref_stand_inside:OnInventoryContentsChanged()
    if not IsServer() then return end

    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end

    for i=0, 8 do
        local item = self:GetCaster():GetItemInSlot(i)
        if item then
            if (item:GetName() == "item_ultimate_scepter" or item:GetName() == "item_ultimate_mem" ) and not item.scepter_polnaref then
                item:SetDroppable(false)
                item:SetSellable(false)
            end
        end
    end
end

function polnaref_stand_inside:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function polnaref_stand_inside:OnAbilityPhaseStart()
    local target = self:GetCursorTarget()
    if target and target:GetUnitName() == "npc_palnoref_chariot" then
        return true
    end
    return false
end

function polnaref_stand_inside:GetCooldown(level)
    if self:GetCaster():HasModifier("modifier_polnaref_scepter_in_stand_buff") then
        return 0
    end
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_stand_inside:GetBehavior()
    if self:GetCaster():HasModifier("modifier_polnaref_scepter_in_stand_buff") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function polnaref_stand_inside:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("polnaref_instand")
    if self:GetCaster():HasModifier("modifier_polnaref_scepter_in_stand_buff") then
        local modifier = self:GetCaster():FindModifierByName("modifier_polnaref_scepter_in_stand_buff")
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        return
    end
    local target = self:GetCursorTarget()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_polnaref_scepter_in_stand_buff", {stand = target:entindex()})
    self:EndCooldown()
end

modifier_polnaref_scepter_in_stand_buff = class({})

function modifier_polnaref_scepter_in_stand_buff:IsPurgable() return false end

function modifier_polnaref_scepter_in_stand_buff:OnCreated(kv)
    if not IsServer() then return end
    self.stand = EntIndexToHScript(kv.stand)
    self:GetParent():EmitSound("Hero_LifeStealer.Infest")
    local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(FrameTime())
    local ability_stand_spawn = self:GetParent():FindAbilityByName("polnaref_stand")
    if ability_stand_spawn then
        ability_stand_spawn:SetActivated(false)
    end
    if self.stand then
        self.stand:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polnaref_scepter_in_stand_buff_stand", {})
    end
    local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
end

function modifier_polnaref_scepter_in_stand_buff:OnDestroy()
    if not IsServer() then return end
    self:GetAbility():UseResources(false, false, true)
    self:GetParent():RemoveNoDraw()
    local ability_stand_spawn = self:GetParent():FindAbilityByName("polnaref_stand")
    if ability_stand_spawn then
        ability_stand_spawn:SetActivated(true)
    end
    if self.stand then
        self.stand:RemoveModifierByName("modifier_polnaref_scepter_in_stand_buff_stand")
    end
    local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
end

function modifier_polnaref_scepter_in_stand_buff:OnIntervalThink()
    if not IsServer() then return end
    if not self.stand:IsAlive() then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    self:GetParent():SetAbsOrigin(self.stand:GetAbsOrigin())
end

function modifier_polnaref_scepter_in_stand_buff:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
end

modifier_polnaref_scepter_in_stand_buff_stand = class({})
function modifier_polnaref_scepter_in_stand_buff_stand:IsPurgable() return false end
function modifier_polnaref_scepter_in_stand_buff_stand:IsHidden() return true end
function modifier_polnaref_scepter_in_stand_buff_stand:GetEffectName()
    return "particles/polnaref_inside.vpcf"
end

function modifier_polnaref_scepter_in_stand_buff_stand:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

polnaref_stand = class({})

function polnaref_stand:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_1")
end

function polnaref_stand:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_stand:OnUpgrade()
     if self.stand and IsValidEntity(self.stand) and self.stand:IsAlive() then
        self.stand:FindModifierByName("modifier_polnaref_stand"):ForceRefresh()
    end
end

function polnaref_stand:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerID()
    local ability = self
    local level = self:GetLevel()
    local origin = caster:GetAbsOrigin() + RandomVector(100)

    if self.stand and IsValidEntity(self.stand) and self.stand:IsAlive() then
        self.stand:BirzhaTrueKill( self, self:GetCaster() )
        self:EndCooldown()
    elseif self.stand then
        self.stand:RespawnUnit() 
        FindClearSpaceForUnit(self.stand, origin, true)
        self.stand:AddNewModifier(self:GetCaster(), self, 'modifier_polnaref_stand', {})
        self.stand:SetForwardVector( self:GetCaster():GetForwardVector() )
        self.stand:EmitSound("PolnarefChariot")
        Timers:CreateTimer(0.1, function()         
            self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.stand)
            ParticleManager:SetParticleControl(self.particle, 0, self.stand:GetAbsOrigin()) 
        end)
    else
        self.stand = CreateUnitByName("npc_palnoref_chariot", origin, true, caster, caster, caster:GetTeamNumber())
        self.stand:SetControllableByPlayer(player, true)
        self.stand:SetOwner(self:GetCaster())
        self.stand:AddNewModifier(self:GetCaster(), self, 'modifier_polnaref_stand', {})
        self.stand:SetForwardVector( self:GetCaster():GetForwardVector() )
        self.stand:EmitSound("PolnarefChariot")
        self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.stand)
        ParticleManager:SetParticleControl(self.particle, 0, self.stand:GetAbsOrigin())
        self.stand:SetUnitCanRespawn(true)  
    end
end

modifier_polnaref_stand = class({})

function modifier_polnaref_stand:IsHidden()
    return true
end

function modifier_polnaref_stand:IsPurgable()
    return false
end

function modifier_polnaref_stand:OnCreated()
    self.stand_hp = self:GetAbility():GetSpecialValueFor("stand_hp")
    self.stand_damage = self:GetAbility():GetSpecialValueFor("stand_damage")
    self.stand_regen = self:GetAbility():GetSpecialValueFor("stand_regen")
    self.stand_ms = self:GetAbility():GetSpecialValueFor("stand_ms")
    self.stand_armor = self:GetAbility():GetSpecialValueFor("stand_armor")
    self.bat = self:GetAbility():GetSpecialValueFor("bat")
    self.stand_hp_per_level = self:GetAbility():GetSpecialValueFor("stand_hp_per_level")
    self.stand_damage_per_level = self:GetAbility():GetSpecialValueFor("stand_damage_per_level")

    if not IsServer() then return end

    self.health_bonus = self.stand_hp + (self:GetCaster():GetLevel() * self.stand_hp_per_level)

    local damage_min = self.stand_damage + ( (self:GetCaster():GetLevel() - 1) * self.stand_damage_per_level )
    local damage_max = self.stand_damage + ( (self:GetCaster():GetLevel() - 1) * self.stand_damage_per_level )

    self:GetParent():SetBaseHealthRegen(self.stand_regen)
    self:GetParent():SetPhysicalArmorBaseValue(self.stand_armor)
    self:GetParent():SetBaseMoveSpeed(self.stand_ms)
    self:GetParent():SetBaseDamageMin(damage_min)
    self:GetParent():SetBaseDamageMax(damage_max)

    ------------------------------------------------------- Abilities
    local polnaref_stand = self:GetCaster():FindAbilityByName("polnaref_stand")
    local polnaref_battle_exp = self:GetCaster():FindAbilityByName("polnaref_battle_exp")
    local polnaref_ragess = self:GetCaster():FindAbilityByName("polnaref_ragess")
    local polnaref_requeim = self:GetCaster():FindAbilityByName("polnaref_requeim")

    local polnaref_rapier = self:GetParent():FindAbilityByName("polnaref_rapier")
    local polnaref_chariotarmor = self:GetParent():FindAbilityByName("polnaref_chariotarmor")
    local polnaref_shoot = self:GetParent():FindAbilityByName("polnaref_shoot")
    local polnaref_afterimage = self:GetParent():FindAbilityByName("polnaref_afterimage")
    local polnaref_silver_rage = self:GetParent():FindAbilityByName("polnaref_silver_rage")

    if polnaref_rapier and polnaref_stand then
        polnaref_rapier:SetLevel(polnaref_stand:GetLevel())
    end

    if polnaref_shoot and polnaref_battle_exp then
        polnaref_shoot:SetLevel(polnaref_battle_exp:GetLevel())
    end

    if polnaref_chariotarmor then
        polnaref_chariotarmor:SetLevel(1)
    end

    if polnaref_silver_rage and polnaref_ragess then
        polnaref_silver_rage:SetLevel(polnaref_ragess:GetLevel())
    end

    if polnaref_afterimage and polnaref_requeim then
        polnaref_afterimage:SetLevel(polnaref_requeim:GetLevel())
    end

    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()

    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_stand:OnRefresh()
    self.stand_hp = self:GetAbility():GetSpecialValueFor("stand_hp")
    self.stand_damage = self:GetAbility():GetSpecialValueFor("stand_damage")
    self.stand_regen = self:GetAbility():GetSpecialValueFor("stand_regen")
    self.stand_ms = self:GetAbility():GetSpecialValueFor("stand_ms")
    self.stand_armor = self:GetAbility():GetSpecialValueFor("stand_armor")
    self.bat = self:GetAbility():GetSpecialValueFor("bat")
    self.stand_hp_per_level = self:GetAbility():GetSpecialValueFor("stand_hp_per_level")
    self.stand_damage_per_level = self:GetAbility():GetSpecialValueFor("stand_damage_per_level")

    if not IsServer() then return end

    self.bonus_damage_talent = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_polnaref_3") then
        self.bonus_damage_talent = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_3")
    end

    self.attack_speed_talent = 0
    if self:GetCaster():HasTalent("special_bonus_birzha_polnaref_5") then
        self.attack_speed_talent = self:GetCaster():GetAttackSpeed() * self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_5")
    end

    self.health_bonus = self.stand_hp + (self:GetCaster():GetLevel() * self.stand_hp_per_level)

    local damage_min = self.stand_damage + ( (self:GetCaster():GetLevel() - 1) * self.stand_damage_per_level )
    local damage_max = self.stand_damage + ( (self:GetCaster():GetLevel() - 1) * self.stand_damage_per_level )

    self:GetParent():SetBaseHealthRegen(self.stand_regen)
    self:GetParent():SetPhysicalArmorBaseValue(self.stand_armor)
    self:GetParent():SetBaseMoveSpeed(self.stand_ms)
    self:GetParent():SetBaseDamageMin(damage_min)
    self:GetParent():SetBaseDamageMax(damage_max)

    ------------------------------------------------------- Abilities
    local polnaref_stand = self:GetCaster():FindAbilityByName("polnaref_stand")
    local polnaref_battle_exp = self:GetCaster():FindAbilityByName("polnaref_battle_exp")
    local polnaref_ragess = self:GetCaster():FindAbilityByName("polnaref_ragess")
    local polnaref_requeim = self:GetCaster():FindAbilityByName("polnaref_requeim")

    local polnaref_rapier = self:GetParent():FindAbilityByName("polnaref_rapier")
    local polnaref_chariotarmor = self:GetParent():FindAbilityByName("polnaref_chariotarmor")
    local polnaref_shoot = self:GetParent():FindAbilityByName("polnaref_shoot")
    local polnaref_afterimage = self:GetParent():FindAbilityByName("polnaref_afterimage")
    local polnaref_silver_rage = self:GetParent():FindAbilityByName("polnaref_silver_rage")

    if polnaref_rapier and polnaref_stand then
        polnaref_rapier:SetLevel(polnaref_stand:GetLevel())
    end

    if polnaref_shoot and polnaref_battle_exp then
        polnaref_shoot:SetLevel(polnaref_battle_exp:GetLevel())
    end

    if polnaref_chariotarmor then
        polnaref_chariotarmor:SetLevel(1)
    end

    if polnaref_silver_rage and polnaref_ragess then
        polnaref_silver_rage:SetLevel(polnaref_ragess:GetLevel())
    end

    if polnaref_afterimage and polnaref_requeim then
        polnaref_afterimage:SetLevel(polnaref_requeim:GetLevel())
    end
end

function modifier_polnaref_stand:OnIntervalThink()
    if not IsServer() then return end
    
    self:OnRefresh()
    self:SendBuffRefreshToClients()

    local distance = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
    if distance >= self:GetAbility():GetSpecialValueFor("radius") and not self:GetCaster():HasModifier("modifier_polnaref_requeim") then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_polnaref_disarm', {})
    else
        self:GetParent():RemoveModifierByName("modifier_polnaref_disarm") 
    end
end

function modifier_polnaref_stand:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_polnaref_stand:AddCustomTransmitterData()
    return 
    {
        health_bonus = self.health_bonus,
        bat = self.bat,
        bonus_damage_talent = self.bonus_damage_talent,
        attack_speed_talent = self.attack_speed_talent,
    }
end

function modifier_polnaref_stand:HandleCustomTransmitterData( data )
    self.health_bonus = data.health_bonus
    self.bat = data.bat
    self.bonus_damage_talent = data.bonus_damage_talent
    self.attack_speed_talent = data.attack_speed_talent
end

function modifier_polnaref_stand:GetModifierHealthBonus()
    return self.health_bonus
end

function modifier_polnaref_stand:GetModifierExtraHealthBonus()
    return self.health_bonus
end

function modifier_polnaref_stand:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage_talent
end

function modifier_polnaref_stand:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_talent
end

function modifier_polnaref_stand:GetModifierBaseAttackTimeConstant()
    if self:GetParent():HasModifier("modifier_polnaref_silver_rage") then return 0.2 end
    return self.bat
end

modifier_polnaref_disarm = class({})

function modifier_polnaref_disarm:IsHidden()
    return true
end

function modifier_polnaref_disarm:IsPurgable()
    return false
end

function modifier_polnaref_disarm:CheckState()
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

function modifier_polnaref_disarm:GetStatusEffectName()
    return "particles/status_fx/status_effect_spirit_bear.vpcf"
end

function modifier_polnaref_disarm:StatusEffectPriority()
    return 99999
end

function modifier_polnaref_disarm:GetEffectName()
    return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_polnaref_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier("modifier_polnaref_battle_exp", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_battle_aura", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_battle_exp = class({})

function polnaref_battle_exp:GetIntrinsicModifierName()
    return "modifier_polnaref_battle_exp"
end

modifier_polnaref_battle_exp = class({})

function modifier_polnaref_battle_exp:IsHidden()
    return true
end

function modifier_polnaref_battle_exp:IsPurgable() return false end

function modifier_polnaref_battle_exp:IsAura() return true end

function modifier_polnaref_battle_exp:IsAuraActiveOnDeath() return true end

function modifier_polnaref_battle_exp:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_polnaref_battle_exp:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_polnaref_battle_exp:GetAuraEntityReject(hEntity)
    if hEntity:GetUnitName() == "npc_palnoref_chariot" or hEntity == self:GetCaster() then
        return false
    end
    return true
end

function modifier_polnaref_battle_exp:GetModifierAura()
    return "modifier_polnaref_battle_aura"
end

function modifier_polnaref_battle_exp:GetAuraRadius()
    return -1
end

modifier_polnaref_battle_aura = class({})

function modifier_polnaref_battle_aura:IsHidden() return true end
function modifier_polnaref_battle_aura:IsPurgable() return false end

function modifier_polnaref_battle_aura:DeclareFunctions()
    local declfuncs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return declfuncs
end

function modifier_polnaref_battle_aura:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = (self:GetAbility():GetSpecialValueFor("lifesteal") +  self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_4")) / 100 * params.damage
        self:GetParent():Heal(heal, nil)
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_polnaref_battle_aura:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_polnaref_battle_aura:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

LinkLuaModifier("modifier_polnaref_ragess", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_ragess = class({})

function polnaref_ragess:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level) + self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_2")
end

function polnaref_ragess:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_ragess:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_ragess", { duration = duration } ) 
    self:GetCaster():EmitSound("PolnarefRage")
end

modifier_polnaref_ragess = class({})

function modifier_polnaref_ragess:IsHidden()
    return false
end

function modifier_polnaref_ragess:IsPurgable()
    return false
end

function modifier_polnaref_ragess:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    }

    return funcs
end

function modifier_polnaref_ragess:GetModifierBaseAttackTimeConstant()
    if self:GetCaster():HasTalent("special_bonus_birzha_polnaref_6") then
        return self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_6")
    end
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_polnaref_ragess:GetEffectName()
    return "particles/polnaref/polnaref_rage.vpcf"
end

function modifier_polnaref_ragess:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

LinkLuaModifier("modifier_polnaref_requeim", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_requeim_aura", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_requeim = class({})

function polnaref_requeim:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_8")
end

function polnaref_requeim:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_requeim:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    return behavior
end

function polnaref_requeim:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_requeim", { duration = duration } )  
end

modifier_polnaref_requeim = ({})

function modifier_polnaref_requeim:IsPurgable()
    return false
end

function modifier_polnaref_requeim:RemoveOnDeath()
    return false
end

function modifier_polnaref_requeim:IsAura() return true end

function modifier_polnaref_requeim:GetAuraRadius()
    return FIND_UNITS_EVERYWHERE
end

function modifier_polnaref_requeim:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_polnaref_requeim:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_polnaref_requeim:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_polnaref_requeim:GetModifierAura()
    return "modifier_polnaref_requeim_aura"
end

function modifier_polnaref_requeim:GetAuraEntityReject(hEntity)
    if hEntity:GetUnitName() == "npc_palnoref_chariot" or hEntity == self:GetCaster() then
        return false
    end
    return true
end

modifier_polnaref_requeim_aura = ({})

function modifier_polnaref_requeim_aura:OnCreated()
    if not IsServer() then return end
    if self:GetParent():GetUnitName() == "npc_palnoref_chariot" then
        self:GetParent():SetRenderColor(0, 0, 0)
    end
end

function modifier_polnaref_requeim_aura:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():GetUnitName() == "npc_palnoref_chariot" then
        self:GetParent():SetRenderColor(255, 255, 255)
    end
end

function modifier_polnaref_requeim_aura:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MIN_HEALTH
    }
end

function modifier_polnaref_requeim_aura:GetMinHealth()
    return 1
end

--- Polnaref Abilities

LinkLuaModifier("modifier_polnaref_rapier", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_rapier = class({})

function polnaref_rapier:GetCooldown(level)
    if IsServer() then
        return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_7")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_rapier:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_rapier:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor( "range" )
end

function polnaref_rapier:GetChannelTime()
    return self.BaseClass.GetChannelTime(self)
end

function polnaref_rapier:OnSpellStart() 
    self.target = self:GetCursorPosition()
    local duration = self:GetChannelTime()
    if self.target == nil then
        return
    end
    if self:GetCaster():HasModifier("modifier_polnaref_shoot_debuff") then
        self:GetCaster():GiveMana(self:GetManaCost(self:GetLevel()))
        self:EndCooldown()
        self:EndChannel( false )
        return
    end
    self.modifier_caster = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_rapier", { duration = self:GetChannelTime() } )
    self:GetCaster():EmitSound("PolnarefRapier")
end

function polnaref_rapier:OnChannelFinish( bInterrupted )
    if self:GetCaster():HasModifier("modifier_polnaref_shoot_debuff") then
        return
    end
    if self.modifier_caster and not self.modifier_caster:IsNull() then
        self.modifier_caster:Destroy()
    end
end

modifier_polnaref_rapier = class({}) 

function modifier_polnaref_rapier:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
    self.point = self:GetAbility().target
    self.origin = self:GetParent():GetOrigin()
    self.dist = self:GetAbility():GetSpecialValueFor( "range" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.attack_count = self:GetAbility():GetSpecialValueFor( "attack_count" )
    local direction = (self.point-self.origin)
    local dist = math.max( math.min( self.dist, direction:Length2D() ), self.dist )
    direction.z = 0
    direction = direction:Normalized()
    self.main_point = GetGroundPosition( self.origin + direction*dist, nil )
    self.particle_point = self.main_point
    self.particle_point.z = self.main_point.z + 128
end

function modifier_polnaref_rapier:IsHidden()
    return true
end

function modifier_polnaref_rapier:IsPurgable()
    return false
end

function modifier_polnaref_rapier:OnIntervalThink()
    if self.attack_count <= 0 and self:GetAbility():IsChanneling() then
        self:GetAbility():EndChannel( false )
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
    self.attack_count = self.attack_count - 1
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
    local enemies = FindUnitsInLine( self:GetCaster():GetTeamNumber(), self.origin, self.main_point, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES )

    self.zap_particle = ParticleManager:CreateParticle("particles/polnaref/attack_particle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.zap_particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.zap_particle, 1, nil, PATTACH_POINT_FOLLOW, "attach_hitloc", self.particle_point, true)
    ParticleManager:SetParticleControl(self.zap_particle, 2, Vector(1, 1, 1))
    ParticleManager:ReleaseParticleIndex(self.zap_particle)

    for _,enemy in pairs(enemies) do
        self:GetCaster():PerformAttack( enemy, true, true, true, true, false, false, true )
    end
end

function modifier_polnaref_rapier:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_polnaref_rapier:GetModifierProcAttack_BonusDamage_Physical( params )
    local damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
    return damage
end

LinkLuaModifier( "modifier_polnaref_shoot", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_polnaref_shoot_debuff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_polnaref_shoot_sword_on_groud", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_polnaref_shoot_sword_on_back", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE )

polnaref_shoot = class({})

function polnaref_shoot:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_shoot:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function polnaref_shoot:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_shoot:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
    return true
end

function polnaref_shoot:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_3 )
end

function polnaref_shoot:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local cast_direction = (point - caster_loc):Normalized()

    if self:GetCaster():HasModifier("modifier_polnaref_shoot_debuff") then
        self:GetCaster():GiveMana(self:GetManaCost(self:GetLevel()))
        self:EndCooldown()
        return
    end

    if point == caster_loc then
        cast_direction = caster:GetForwardVector()
    else
        cast_direction = (point - caster_loc):Normalized()
    end

    self.comeback_sword = false
    self.comeback_sword_units = {}

    local info = 
    {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        bDeleteOnHit = true,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/polnaref_sword.vpcf",
        fDistance = 3000,
        fStartRadius = 75,
        fEndRadius =75,
        vVelocity = cast_direction * 1800,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = false,
    }

    ProjectileManager:CreateLinearProjectile(info)

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_shoot_debuff", {} )
    self:GetCaster():EmitSound("PolnarefLaunch")
    self:SetActivated(false)
    self:EndCooldown()
    self:GetCaster():FindAbilityByName("polnaref_rapier"):SetActivated(false)
end

function polnaref_shoot:OnProjectileHit( target, vLocation )
    if not IsServer() then return end

    if not self:GetCaster():IsAlive() then
        return
    end

    if self.comeback_sword then
        local modifier_disarmed_sword = self:GetCaster():FindModifierByName("modifier_polnaref_shoot_debuff")
        if modifier_disarmed_sword and not modifier_disarmed_sword:IsNull() then
            if modifier_disarmed_sword.back_sword_unit then
                UTIL_Remove(modifier_disarmed_sword.back_sword_unit)
            end
            modifier_disarmed_sword:AddedModelWeapon()
            modifier_disarmed_sword:Destroy()
        end
        return
    end

    if target ~= nil then
        local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_shoot", {} )
        self:GetCaster():PerformAttack ( target, true, true, true, true, false, false, true )
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
    end

    if target == nil then
        if not self:GetCaster():GetOwner():HasShard() then
            local modifier_disarmed_sword = self:GetCaster():FindModifierByName("modifier_polnaref_shoot_debuff")
            if modifier_disarmed_sword then
                modifier_disarmed_sword.sword_on_groud = CreateUnitByName( "npc_dota_companion", vLocation, true, nil, nil, self:GetCaster():GetTeamNumber() )
                modifier_disarmed_sword.sword_on_groud:SetOwner(self:GetCaster())
                modifier_disarmed_sword.sword_on_groud:AddNewModifier(self:GetCaster(), self, "modifier_polnaref_shoot_sword_on_groud", {})
                modifier_disarmed_sword.sword_on_groud:SetModel("models/polnaref_sword/sword_ground.vmdl")
                modifier_disarmed_sword.sword_on_groud:SetOriginalModel("models/polnaref_sword/sword_ground.vmdl")
            end
        end

        if self:GetCaster():GetOwner():HasShard() then
            self.comeback_sword = true
            local modifier_disarmed_sword = self:GetCaster():FindModifierByName("modifier_polnaref_shoot_debuff")
            if modifier_disarmed_sword then
                modifier_disarmed_sword.back_sword_unit = CreateUnitByName( "npc_dota_companion", vLocation, false, nil, nil, self:GetCaster():GetTeamNumber() )
                modifier_disarmed_sword.back_sword_unit:AddNewModifier(self:GetCaster(), self, "modifier_polnaref_shoot_sword_on_back", {})
                local info = {
                    Target = self:GetCaster(),
                    Source =modifier_disarmed_sword.back_sword_unit,
                    Ability = self, 
                    EffectName = "particles/polnaref_sword_fly.vpcf",
                    iMoveSpeed = 1800,
                    bDodgeable = false,
                    bVisibleToEnemies = true, 
                    bProvidesVision = true,
                    iVisionRadius = 75,
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                }
                local back_proj = ProjectileManager:CreateTrackingProjectile(info)
            end
        end
    end
end

function polnaref_shoot:OnProjectileThink(vLocation)
    if not self:GetCaster():IsAlive() then
        return
    end
    if self.comeback_sword then
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vLocation,  nil,  75,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _, unit in pairs(units) do
            if not self.comeback_sword_units[unit:entindex()] then
                self.comeback_sword_units[unit:entindex()] = unit
                local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_shoot", {} )
                self:GetCaster():PerformAttack ( unit, true, true, true, true, false, false, true )
                if modifier and not modifier:IsNull() then
                    modifier:Destroy()    
                end
            end        
        end
    end 
end

modifier_polnaref_shoot_sword_on_groud = class({})

function modifier_polnaref_shoot_sword_on_groud:IsPurgable() return false end
function modifier_polnaref_shoot_sword_on_groud:IsHidden() return true end

function modifier_polnaref_shoot_sword_on_groud:OnCreated()
    if not IsServer() then return end
    self.arrow_particle = ParticleManager:CreateParticleForPlayer( "particles/gameplay/location_hint_goal.vpcf", PATTACH_WORLDORIGIN, nil, PlayerResource:GetPlayer( self:GetCaster():GetOwner():GetPlayerID() ) )
    ParticleManager:SetParticleControl( self.arrow_particle, 0, self:GetParent():GetAbsOrigin() )
    ParticleManager:SetParticleControl( self.arrow_particle, 1, Vector( 1.0, 0.8, 0.2 ) )
end

function modifier_polnaref_shoot_sword_on_groud:OnDestroy()
    if not IsServer() then return end
    if self.arrow_particle then
        ParticleManager:DestroyParticle(self.arrow_particle, true)
    end
end

function modifier_polnaref_shoot_sword_on_groud:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end

modifier_polnaref_shoot_sword_on_back = class({})

function modifier_polnaref_shoot_sword_on_back:IsPurgable() return false end
function modifier_polnaref_shoot_sword_on_back:IsHidden() return true end

function modifier_polnaref_shoot_sword_on_back:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end

modifier_polnaref_shoot = class({})

function modifier_polnaref_shoot:IsHidden()
    return true
end

function modifier_polnaref_shoot:IsPurgable()
    return false
end

function modifier_polnaref_shoot:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }
    return funcs
end

function modifier_polnaref_shoot:GetModifierPreAttack_CriticalStrike( params )
    if IsServer() then
        return self:GetAbility():GetSpecialValueFor( "damage_crit" )
    end
end

function modifier_polnaref_shoot:GetModifierProcAttack_BonusDamage_Physical( params )
    local damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
    return damage
end

modifier_polnaref_shoot_debuff = class({})

function modifier_polnaref_shoot_debuff:IsHidden()
    return true
end

function modifier_polnaref_shoot_debuff:IsPurgable()
    return false
end

function modifier_polnaref_shoot_debuff:OnCreated()
    if not IsServer() then return end
    if self:GetParent().chariot_sword and not self:GetParent().chariot_sword:IsNull() then
        self:GetParent().chariot_sword:Destroy()
        self:GetParent().chariot_sword = nil
    end
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_shoot_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetAbility():SetActivated(true)
    self:GetAbility():UseResources(false, false, true)
    self:GetCaster():FindAbilityByName("polnaref_rapier"):SetActivated(true)
    if self.sword_on_groud then
        UTIL_Remove(self.sword_on_groud)
    end
    if self.sword_on_groud_particle then
        UTIL_Remove(self.sword_on_groud_particle)
    end
end

function modifier_polnaref_shoot_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

function modifier_polnaref_shoot_debuff:AddedModelWeapon()
    if not self:GetParent().chariot_sword or ( self:GetParent().chariot_sword and self:GetParent().chariot_sword == nil )then
        self:GetParent().chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
        self:GetParent().chariot_sword:FollowEntity(self:GetParent(), true)
    end
end

function modifier_polnaref_shoot_debuff:OnIntervalThink()
    if not IsServer() then return end
    if self.sword_on_groud and not self.sword_on_groud:IsNull() then
        if self:GetParent():IsPositionInRange( self.sword_on_groud:GetAbsOrigin(), 50 ) then
            self:AddedModelWeapon()
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

LinkLuaModifier("modifier_polnaref_silver_rage", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_silver_rage = class({})

function polnaref_silver_rage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_silver_rage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_silver_rage:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    print(self:GetCaster():GetBaseAttackTime())
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_silver_rage", { duration = duration } ) 
    print(self:GetCaster():GetBaseAttackTime())
end

modifier_polnaref_silver_rage = class({})

function modifier_polnaref_silver_rage:IsHidden()
    return false
end

function modifier_polnaref_silver_rage:IsPurgable()
    return false
end

function modifier_polnaref_silver_rage:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    }

    return funcs
end

function modifier_polnaref_silver_rage:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_polnaref_silver_rage:GetEffectName()
    return "particles/polnaref/polnaref_rage.vpcf"
end

function modifier_polnaref_silver_rage:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

LinkLuaModifier("modifier_polnaref_chariotarmor", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_chariotarmor_active", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_chariotarmor = class({})

function polnaref_chariotarmor:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_polnaref_chariotarmor_active", {duration = duration})
end

modifier_polnaref_chariotarmor_active = class({})

function modifier_polnaref_chariotarmor_active:IsPurgable() return false end

function modifier_polnaref_chariotarmor_active:OnCreated(table)
    if not IsServer() then return end

    local minus_health = self:GetAbility():GetSpecialValueFor("minus_health_regen") / 100

    local minus_health_really = self:GetParent():GetHealth() * ( 1 - minus_health)
    self:GetParent():SetHealth(minus_health_really)

    local bonus_health = (self:GetAbility():GetSpecialValueFor("bonus_health_regen") / 100) / self:GetAbility():GetSpecialValueFor("duration")

    self.tick_health = self:GetParent():GetMaxHealth() * 0.01
    self:StartIntervalThink(0.16)
end

function modifier_polnaref_chariotarmor_active:OnIntervalThink()
    if not IsServer() then return end
    local new_health = math.min(self:GetParent():GetMaxHealth(), self:GetParent():GetHealth() + self.tick_health)
    self:GetParent():SetHealth(new_health)
    if self:GetParent():GetHealth() == self:GetParent():GetMaxHealth() then
        self:Destroy()
    end
end

function polnaref_chariotarmor:GetIntrinsicModifierName()
    return "modifier_polnaref_chariotarmor"
end

modifier_polnaref_chariotarmor = class({})

function modifier_polnaref_chariotarmor:IsHidden()
    return true
end

function modifier_polnaref_chariotarmor:IsPurgable()
    return false
end

function modifier_polnaref_chariotarmor:OnCreated()
    if not IsServer() then return end
    self.max_effect = self:GetAbility():GetSpecialValueFor( "max_effect" )
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_chariotarmor:OnIntervalThink()
    if not IsServer() then return end
    self.attackspeed = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
    local max_health = self:GetParent():GetMaxHealth()
    local health = self:GetParent():GetHealth()
    local stack = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() * 100
    if stack < self.max_effect then
        stack = 25
    end
    local perc = 100 - stack
    self:SetStackCount(perc)
end

function modifier_polnaref_chariotarmor:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return declfuncs
end

function modifier_polnaref_chariotarmor:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
end

LinkLuaModifier("modifier_polnaref_afterimage", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_afterimage_illusion", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_afterimage = class({})

function polnaref_afterimage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_afterimage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_afterimage:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_afterimage", { duration = duration } )  
    self:GetCaster():EmitSound("PolnarefAfterimage")
end

modifier_polnaref_afterimage = class({})

function modifier_polnaref_afterimage:IsHidden()
    return false
end

function modifier_polnaref_afterimage:IsPurgable()
    return false
end

function modifier_polnaref_afterimage:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
    return funcs
end

function modifier_polnaref_afterimage:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_polnaref_afterimage:OnCreated( params )
    if not IsServer() then return end
    self.position = self:GetParent():GetAbsOrigin()
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_afterimage:OnIntervalThink()
    if not IsServer() then return end
    local vector_distance = self.position - self:GetParent():GetAbsOrigin()
    local distance = (vector_distance):Length2D()
    if distance >= 300 and distance > 0 then
        self.position = self:GetParent():GetAbsOrigin()
        local dummy = CreateUnitByName( "npc_palnoref_chariot_illusion", self:GetParent():GetAbsOrigin(), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )
        dummy:SetOwner(self:GetCaster())
        local illusion_duration = self:GetAbility():GetSpecialValueFor("illusion_duration")
        dummy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_polnaref_afterimage_illusion", {duration = illusion_duration})
        dummy:SetForwardVector( self:GetParent():GetForwardVector() )
    end
end

function modifier_polnaref_afterimage:GetEffectName()
    return "particles/polnaref/polnaref_windrun.vpcf"
end

function modifier_polnaref_afterimage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_polnaref_afterimage_illusion = class({})

function modifier_polnaref_afterimage_illusion:IsHidden()
    return false
end

function modifier_polnaref_afterimage_illusion:IsPurgable()
    return false
end

function modifier_polnaref_afterimage_illusion:OnCreated()
    if not IsServer() then return end
    local damage = self:GetCaster():GetBaseDamageMax()
    self:GetParent():SetBaseDamageMin(damage)
    self:GetParent():SetBaseDamageMax(damage)
    self:GetParent().attack = true
    self:GetParent():SetRenderColor(0, 0, 0)
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_afterimage_illusion:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetCaster() then self:GetParent():ForceKill(false) return end
    if self:GetCaster():IsNull() then self:GetParent():ForceKill(false) return end
    if not self:GetCaster():IsAlive() then self:GetParent():ForceKill(false) return end

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, 190, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false )
    if #enemies > 0 then
        for enemy = 1, #enemies do
            if enemies[enemy] and enemies[enemy]:IsAlive() and not enemies[enemy]:IsAttackImmune() and not enemies[enemy]:IsInvulnerable() then
                if self.attack_true then return end
                self.attack_true = true
                self:GetParent():MoveToTargetToAttack(enemies[1])
                self:GetParent():SetForwardVector( (enemies[1]:GetOrigin()-self:GetParent():GetOrigin()):Normalized() )
                self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1)
                local parent = self:GetParent()
                local modifier = self
                Timers:CreateTimer(0.5,function()
                    if not modifier:IsNull() and not parent:IsNull() and parent.attack then
                        parent.attack = false
                        parent:PerformAttack( enemies[enemy], true, true, true, true, false, false, true )
                        parent:ForceKill(false)
                    end
                end)
            end
        end
    end
end

function modifier_polnaref_afterimage_illusion:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = false,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }

    return state
end

function modifier_polnaref_afterimage_illusion:GetEffectName()
    return "particles/polnaref/polnaref_windrun.vpcf"
end

function modifier_polnaref_afterimage_illusion:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_polnaref_afterimage_illusion:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():IsAlive() then
        self:GetParent():ForceKill(false)
    end
end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
---------------------
-- Старые способности
--LinkLuaModifier("modifier_polnaref_sleep", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_polnaref_sleep_debuff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_polnaref_sleep_debuff_sleep", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
--
--polnaref_sleep = class({})
--
--function polnaref_sleep:GetCooldown(level)
--    return self.BaseClass.GetCooldown( self, level )
--end
--
--function polnaref_sleep:GetManaCost(level)
--    return self.BaseClass.GetManaCost(self, level)
--end
--
--function polnaref_sleep:OnSpellStart()
--    if IsServer() then
--        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_polnaref_sleep", {duration = 0.7})
--        self:GetCaster():EmitSound("PolnarefSon")
--        Timers:CreateTimer(self:GetSpecialValueFor("sleep_duration"),function()
--            self:GetCaster():StopSound("PolnarefSon")
--        end)
--    end
--end
--
--modifier_polnaref_sleep = class({})
--
--function modifier_polnaref_sleep:IsHidden()
--    return true
--end
--
--function modifier_polnaref_sleep:OnCreated()
--    self.parent = self:GetParent()
--    self:StartIntervalThink(0.1)
--    self.radius_effect = 0
--    local radius = self:GetAbility():GetSpecialValueFor("radius")
--    self.particle = ParticleManager:CreateParticle("particles/econ/items/razor/razor_ti6/razor_plasmafield_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
--    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
--    ParticleManager:SetParticleControl(self.particle, 1, Vector(1200, radius, 0))
--    self:GetAbility().heroes = {}
--end
--
--function modifier_polnaref_sleep:OnIntervalThink()
--    self.radius_effect = self.radius_effect + 120
--    if self.radius_effect >= 600 then
--        self.radius_effect = 600
--    end
--end
--
--function modifier_polnaref_sleep:OnDestroy()
--    if self.particle then
--        ParticleManager:DestroyParticle(self.particle,true)
--        ParticleManager:ReleaseParticleIndex(self.particle)
--    end
--end
--
--function modifier_polnaref_sleep:IsAura() return true end
--
--function modifier_polnaref_sleep:GetAuraRadius()
--    return self.radius_effect
--end
--function modifier_polnaref_sleep:GetAuraSearchTeam()
--    return DOTA_UNIT_TARGET_TEAM_ENEMY
--end
--
--function modifier_polnaref_sleep:GetAuraSearchType()
--    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
--end
--
--function modifier_polnaref_sleep:GetModifierAura()
--    return "modifier_polnaref_sleep_debuff"
--end
--
--modifier_polnaref_sleep_debuff = ({})
--
--function modifier_polnaref_sleep_debuff:IsHidden()
--    return true
--end
--
--function modifier_polnaref_sleep_debuff:OnCreated()
--    if not IsServer() then return end
--    if not self:GetParent():IsAlive() then return end
--    local info = {
--        Target = self:GetCaster(),
--        Source = self:GetParent(),
--        Ability = self:GetAbility(), 
--        EffectName = "particles/polnaref/polnaref_sleep.vpcf",
--        iMoveSpeed = 800,
--        vSourceLoc = self:GetParent():GetAbsOrigin(),       
--        bDrawsOnMinimap = false,                         
--        bDodgeable = false,                               
--        bVisibleToEnemies = true,                        
--        bReplaceExisting = false,                         
--    }
--    ProjectileManager:CreateTrackingProjectile(info)
--    local duration = self:GetAbility():GetSpecialValueFor("sleep_duration")
--    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_polnaref_sleep_debuff_sleep', {duration = duration})
--    table.insert(self:GetAbility().heroes, self:GetParent():GetAbsOrigin())
--end
--
--function modifier_polnaref_sleep_debuff:OnDestroy()
--    if not IsServer() then return end
--    self:GetParent():SetAbsOrigin(table.remove(self:GetAbility().heroes, RandomInt(1, #self:GetAbility().heroes)))
--end
--
--modifier_polnaref_sleep_debuff_sleep = class({})
--
--function modifier_polnaref_sleep_debuff_sleep:IsPurgable() return false end
--function modifier_polnaref_sleep_debuff_sleep:IsPurgeException() return true end
--
--function modifier_polnaref_sleep_debuff_sleep:CheckState()
--    return {
--        [MODIFIER_STATE_STUNNED] = true,
--    }
--end
--
--function modifier_polnaref_sleep_debuff_sleep:DeclareFunctions()
--    return {
--        MODIFIER_EVENT_ON_TAKEDAMAGE
--    }
--end
--
--function modifier_polnaref_sleep_debuff_sleep:OnCreated()
--    if not IsServer() then return end
--    self.max_damage = self:GetAbility():GetSpecialValueFor("sleep_damage") + self:GetCaster():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_8")
--    self.damage = 0
--end
--
--function modifier_polnaref_sleep_debuff_sleep:OnTakeDamage(params)
--    if not IsServer() then return end
--    if params.attacker == self:GetParent() then return end
--    if params.unit ~= self:GetParent() then return end
--
--    self.damage = self.damage + params.damage
--
--    if self.damage >= self.max_damage then
--        if not self:IsNull() then
--            self:Destroy()
--        end
--    end 
--end
--
--function modifier_polnaref_sleep_debuff_sleep:GetEffectName()
--    return "particles/generic_gameplay/generic_sleep.vpcf"
--end
--
--function modifier_polnaref_sleep_debuff_sleep:GetEffectAttachType()
--    return PATTACH_OVERHEAD_FOLLOW
--end
--
--LinkLuaModifier("modifier_polnaref_regeneration", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_polnaref_regeneration_debuff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
--
--polnaref_regeneration = class({})
--
--function polnaref_regeneration:GetIntrinsicModifierName()
--    return "modifier_polnaref_regeneration"
--end
--
--modifier_polnaref_regeneration = class({})
--
--function modifier_polnaref_regeneration:IsHidden()
--    return true
--end
--
--function modifier_polnaref_regeneration:DeclareFunctions()
--    local declfuncs = {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
--    return declfuncs
--end
--
--function modifier_polnaref_regeneration:GetModifierHealthRegenPercentage()
--    if not self:GetParent():HasModifier("modifier_polnaref_requeim_aura") then return 0 end
--    return self:GetAbility():GetSpecialValueFor("regen") / 10
--end
--
--function modifier_polnaref_regeneration:OnAttackLanded(params)
--    if params.target ~= self:GetParent() then return end
--    params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polnaref_regeneration_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
--end
--
--modifier_polnaref_regeneration_debuff = class({})
--
--function modifier_polnaref_regeneration_debuff:IsHidden() return false end
--function modifier_polnaref_regeneration_debuff:IsPurgable() return true end
--
--function modifier_polnaref_regeneration_debuff:Custom_HealAmplifyReduce()
--    return self:GetAbility():GetSpecialValueFor("regen_reduce")
--end
--
--LinkLuaModifier("modifier_polnaref_return", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
--
--polnaref_return = class({})
--
--function polnaref_return:GetIntrinsicModifierName()
--    return "modifier_polnaref_return"
--end
--
--modifier_polnaref_return = class({})
--
--function modifier_polnaref_return:IsHidden()
--    return true
--end
--
--function modifier_polnaref_return:DeclareFunctions()
--    local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
--
--    return decFuncs
--end
--
--function modifier_polnaref_return:OnTakeDamage(keys)
--    if not IsServer() then return end
--    local attacker = keys.attacker
--    local target = keys.unit
--    local original_damage = keys.original_damage
--    local damage_type = keys.damage_type
--    local damage_flags = keys.damage_flags
--    if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then  
--        if not keys.unit:IsOther() then
--            if not self:GetParent():HasModifier("modifier_polnaref_requeim_aura") then return 0 end
--            EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
--            local damage = self:GetAbility():GetSpecialValueFor("return_damage") / 100
--            local damageTable = {
--                victim          = keys.attacker,
--                damage          = keys.original_damage * damage,
--                damage_type     = keys.damage_type,
--                damage_flags    = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
--                attacker        = self:GetParent(),
--                ability         = self:GetAbility()
--            }
--            ApplyDamage(damageTable)
--        end
--    end
--end
--
--LinkLuaModifier("modifier_polnaref_darkheart", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_polnaref_darkheart_buff", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_polnaref_darkheart_illusion_debuff", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
--
--polnaref_darkheart = class({}) 
--
--function polnaref_darkheart:GetCooldown(level)
--    return self.BaseClass.GetCooldown( self, level )
--end
--
--function polnaref_darkheart:GetManaCost(level)
--    return self.BaseClass.GetManaCost(self, level)
--end
--
--function polnaref_darkheart:GetChannelTime()
--    return self:GetSpecialValueFor("duration")
--end
--
--function polnaref_darkheart:OnAbilityPhaseStart()
--    if self:GetCaster():GetOwner():HasModifier("modifier_polnaref_ragess") then
--        return false
--    end
--    return true
--end
--
--function polnaref_darkheart:OnSpellStart()
--    if not IsServer() then return end
--    local caster = self:GetCaster()
--    local duration = self:GetSpecialValueFor("duration")
--    EmitGlobalSound("")
--    GameRules:SetTimeOfDay(duration)
--    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)
--    for _, enemy in pairs(enemies) do
--        if enemy:GetUnitName() == "npc_dota_hero_faceless_void" then return end
--        enemy:AddNewModifier(self:GetCaster(), self, "modifier_polnaref_darkheart", {duration = duration})
--    end
--end
--
--function polnaref_darkheart:OnChannelFinish( bInterrupted )
--    if not IsServer() then return end
--    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)
--    for _, enemy in pairs(enemies) do
--        if enemy:HasModifier("modifier_polnaref_darkheart") then
--            enemy:RemoveModifierByName( "modifier_polnaref_darkheart" )
--        end
--    end
--end
--
--modifier_polnaref_darkheart = class({})
--
--function modifier_polnaref_darkheart:IsHidden()
--    return true
--end
--
--function modifier_polnaref_darkheart:OnCreated()
--    if not IsServer() then return end
--    local duration = self:GetAbility():GetSpecialValueFor("duration")
--    local origin = self:GetParent():GetAbsOrigin() + RandomVector(100)
--    self.dummy = CreateUnitByName( "npc_palnoref_chariot_illusion_2", self:GetParent():GetAbsOrigin(), true, self:GetCaster():GetOwner(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
--    self.dummy:SetOwner(self:GetCaster():GetOwner())
--    self.dummy:SetAbsOrigin(origin)
--    self.dummy:SetForwardVector(self:GetParent():GetAbsOrigin() - self.dummy:GetAbsOrigin())
--    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polnaref_darkheart_buff", {enemy_entindex = self:GetParent():entindex()})
--    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
--    self.dummy:MoveToTargetToAttack(self:GetParent())
--    self.dummy:SetAggroTarget(self:GetParent())
--end
--
--function modifier_polnaref_darkheart:OnRefresh()
--    if not IsServer() then return end
--    local duration = self:GetAbility():GetSpecialValueFor("duration")
--    local origin = self:GetParent():GetAbsOrigin() + RandomVector(100)
--    self.dummy = CreateUnitByName( "npc_palnoref_chariot_illusion_2", self:GetParent():GetAbsOrigin(), true, self:GetCaster():GetOwner(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
--    self.dummy:SetOwner(self:GetCaster():GetOwner())
--    self.dummy:SetAbsOrigin(origin)
--    self.dummy:SetForwardVector(self:GetParent():GetAbsOrigin() - self.dummy:GetAbsOrigin())
--    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polnaref_darkheart_buff", {enemy_entindex = self:GetParent():entindex()})
--    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
--    self.dummy:MoveToTargetToAttack(self:GetParent())
--    self.dummy:SetAggroTarget(self:GetParent())
--end
--
--function modifier_polnaref_darkheart:OnDestroy()
--    if not IsServer() then return end
--    if self.dummy and not self.dummy:IsNull() then
--        self.dummy:ForceKill(false)
--    end
--end
--
--modifier_polnaref_darkheart_buff = class({})
--
--function modifier_polnaref_darkheart_buff:IsHidden()
--    return true
--end
--
--function modifier_polnaref_darkheart_buff:OnCreated(keys)
--    if not IsServer() then return end
--    self.aggro_target = EntIndexToHScript(keys.enemy_entindex)
--
--
--    self.perc_damage = self:GetAbility():GetSpecialValueFor("damage") - 100
--
--    local damage = self:GetCaster():GetBaseDamageMax()
--    self:GetParent():SetBaseDamageMin(damage)
--    self:GetParent():SetBaseDamageMax(damage)
--
--    for itemSlot=0,5 do
--        local item = self:GetCaster():GetItemInSlot(itemSlot)
--        if item ~= nil then
--            local itemName = item:GetName()
--            if itemName ~= "item_rapier" then
--                local newItem = CreateItem(itemName, self:GetParent(), self:GetParent())
--                self:GetParent():AddItem(newItem)
--            end
--        end
--    end
--
--    self:GetParent():SetRenderColor(0, 0, 0)
--    local attack_per_second = self:GetCaster():GetAttackSpeed() / self:GetParent():GetBaseAttackTime()
--    local interval = 1 / attack_per_second
--    self.anim = self:GetCaster():GetAttackSpeed()
--    print(interval)
--    self:StartIntervalThink(interval)
--end
--
--function modifier_polnaref_darkheart_buff:OnIntervalThink()
--    if not IsServer() then return end
--    if not self.aggro_target:IsAlive() then
--        if not self:IsNull() then
--            self:Destroy()
--            return
--        end
--    end
--    if not self:GetParent():GetOwner():HasModifier("modifier_polnaref_requeim") then
--        self:GetParent():Destroy()
--        if not self:IsNull() then
--            self:Destroy()
--            return
--        end
--    end
--    local pos = self.aggro_target:GetAbsOrigin() + RandomVector(100)
--    FindClearSpaceForUnit(self:GetParent(), pos, true)
--    local angle_vector = self.aggro_target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
--    self:GetParent():SetAngles(0, VectorToAngles(angle_vector).y, 0)
--    self:GetParent():PerformAttack( self.aggro_target, true, true, true, true, false, false, true )
--    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, self.anim)
--end
--
--function modifier_polnaref_darkheart_buff:CheckState()
--    local state = 
--    {
--        [MODIFIER_STATE_INVULNERABLE] = true,
--        [MODIFIER_STATE_UNSELECTABLE] = true,
--        [MODIFIER_STATE_CANNOT_MISS] = true,
--        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
--        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
--        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = false,
--        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
--    }
--    return state
--end
--
--function modifier_polnaref_darkheart_buff:DeclareFunctions()
--    local declfuncs = {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
--    return declfuncs
--end
--
--function modifier_polnaref_darkheart_buff:GetModifierDamageOutgoing_Percentage()
--    return self.perc_damage
--end