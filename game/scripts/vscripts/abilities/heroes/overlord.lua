LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_prihvosti", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_overlord_prihvosti_fire_talent", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_overlord_prihvosti_venom_talent", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_overlord_prihvosti_venom_talent_debuff", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )

overlord_prihvosti = class({}) 

function overlord_prihvosti:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function overlord_prihvosti:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function overlord_prihvosti:OnSpellStart()
    if not IsServer() then return end

    self.count = self:GetSpecialValueFor( "count" )

    local duration = self:GetSpecialValueFor( "duration" )

    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)) do
        if unit:GetUnitName() == "npc_overlord_small_prihvost" and unit:GetOwner() == self:GetCaster() then
            unit:ForceKill(false)               
        end
    end

    for i = 1, self.count do
        local prihvost = CreateUnitByName("npc_overlord_small_prihvost", self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300) + (self:GetCaster():GetRightVector() * 20 * i), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
        prihvost:SetOwner(self:GetCaster())
        prihvost:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(prihvost, prihvost:GetAbsOrigin(), true)
        prihvost:SetForwardVector(self:GetCaster():GetForwardVector())
        prihvost:AddNewModifier(self:GetCaster(), self, "modifier_overlord_prihvosti", {})
        prihvost:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    end

    self:GetCaster():EmitSound("OverlordOne")
end

modifier_overlord_prihvosti = class({})

function modifier_overlord_prihvosti:IsPurgable()
    return false
end

function modifier_overlord_prihvosti:IsHidden()
    return true
end

function modifier_overlord_prihvosti:OnCreated()
    if not IsServer() then return end

    local health = self:GetAbility():GetSpecialValueFor( "prihvosti_hp" )

    local damage = self:GetAbility():GetSpecialValueFor( "prihvosti_dmg" )

    if self:GetParent():GetUnitName() == "npc_overlord_big_prihvost_portal" then
        local ability = self:GetCaster():FindAbilityByName("overlord_portal")
        if ability and ability:GetLevel() > 0 then
            local mult = ability:GetSpecialValueFor("mult")
            health = health * mult
            damage = damage * mult
        end
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_6") then
        damage = damage + (damage * (self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_6") / 100))
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_1") then
        local armor = self:GetParent():GetPhysicalArmorBaseValue() + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_1")
        self:GetParent():SetPhysicalArmorBaseValue(armor)
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_2") then
        local magic_resist = self:GetParent():GetBaseMagicalResistanceValue() + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_2")
        self:GetParent():SetBaseMagicalResistanceValue(magic_resist)
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_3") then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_prihvosti_fire_talent", {})
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_4") then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_prihvosti_venom_talent", {})
    end

    self:GetParent():SetBaseDamageMin(damage)

    self:GetParent():SetBaseDamageMax(damage)

    self:GetParent():SetBaseMaxHealth(health)

    self:GetParent():SetHealth(health)
end

modifier_overlord_prihvosti_fire_talent = class({})

function modifier_overlord_prihvosti_fire_talent:IsHidden()
    return true
end

function modifier_overlord_prihvosti_fire_talent:IsPurgable()
    return false
end

function modifier_overlord_prihvosti_fire_talent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_overlord_prihvosti_fire_talent:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    local ability = self:GetCaster():FindAbilityByName("overlord_fireball")
    if ability and ability:GetLevel() > 0 then
        params.target:AddNewModifier(self:GetCaster(), ability, "modifier_overlord_fireball_debuff_duration", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_3") * (1-params.target:GetStatusResistance())})
    end
end

modifier_overlord_prihvosti_venom_talent = class({})

function modifier_overlord_prihvosti_venom_talent:IsHidden()
    return true
end

function modifier_overlord_prihvosti_venom_talent:IsPurgable()
    return false
end

function modifier_overlord_prihvosti_venom_talent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_overlord_prihvosti_venom_talent:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_prihvosti_venom_talent_debuff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_4") * (1-params.target:GetStatusResistance())})
end

modifier_overlord_prihvosti_venom_talent_debuff = class({})

function modifier_overlord_prihvosti_venom_talent_debuff:IsPurgable()
    return true
end

function modifier_overlord_prihvosti_venom_talent_debuff:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }

    return decFuncs
end

function modifier_overlord_prihvosti_venom_talent_debuff:Custom_HealAmplifyReduce()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_4", "value2")
end

function modifier_overlord_prihvosti_venom_talent_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_4", "value3")
end

function modifier_overlord_prihvosti_venom_talent_debuff:GetModifierHPRegenAmplify_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_4", "value2")
end

function modifier_overlord_prihvosti_venom_talent_debuff:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_overlord_prihvosti_venom_talent_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_overlord_fireball", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_fireball_debuff", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_fireball_debuff_duration", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )

overlord_fireball = class({})

function overlord_fireball:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function overlord_fireball:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function overlord_fireball:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function overlord_fireball:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function overlord_fireball:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local ability = self
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():EmitSound("Hero_DragonKnight.BreathFire")
    Timers:CreateTimer(0.25, function()
         CreateModifierThinker( caster, ability, "modifier_overlord_fireball", { duration = duration }, point, caster:GetTeamNumber(), false )
    end)
    self.particle_cast = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball_projectile.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControlEnt(self.particle_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.particle_cast, 1, point)
    ParticleManager:SetParticleControl(self.particle_cast, 2, point)
end

modifier_overlord_fireball = class({})

function modifier_overlord_fireball:IsPurgable()
    return false
end

function modifier_overlord_fireball:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    self:GetParent():EmitSound("n_black_dragon.Fireball.Target")
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.radius, false)
    local particle = ParticleManager:CreateParticle("particles/lava_overlord.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(particle, 2, Vector(self:GetAbility():GetSpecialValueFor( "duration" ), self:GetAbility():GetSpecialValueFor( "duration" ), self:GetAbility():GetSpecialValueFor( "duration" )))
    self:AddParticle(particle, false, false, -1, false, false )
    local particle_2 = ParticleManager:CreateParticle("particles/lava_overlord_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle_2, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_2, 1, Vector(self.radius/2, self.radius/2, self.radius/2))
    ParticleManager:SetParticleControl(particle_2, 2, Vector(self:GetAbility():GetSpecialValueFor( "duration" ), self:GetAbility():GetSpecialValueFor( "duration" ), self:GetAbility():GetSpecialValueFor( "duration" )))
    self:AddParticle(particle_2, false, false, -1, false, false )
end

function modifier_overlord_fireball:IsAura()
    return true
end

function modifier_overlord_fireball:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("n_black_dragon.Fireball.Target", self:GetParent())
end

function modifier_overlord_fireball:GetModifierAura()
    return "modifier_overlord_fireball_debuff"
end

function modifier_overlord_fireball:GetAuraRadius()
    return self.radius
end

function modifier_overlord_fireball:GetAuraDuration()
    return 0
end

function modifier_overlord_fireball:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_overlord_fireball:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_overlord_fireball:GetAuraSearchFlags()
    return 0
end

modifier_overlord_fireball_debuff = class({})

function modifier_overlord_fireball_debuff:IsPurgable()
    return false
end

function modifier_overlord_fireball_debuff:IsHidden()
    return true
end

function modifier_overlord_fireball_debuff:OnCreated()
    if not IsServer() then return end
    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_8") then
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration=self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_8") * (1 - self:GetParent():GetStatusResistance())} )
    end
    self:StartIntervalThink(FrameTime())
end

function modifier_overlord_fireball_debuff:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_overlord_fireball_debuff_duration", {duration=self:GetAbility():GetSpecialValueFor( "debuff_duration" ) * (1 - self:GetParent():GetStatusResistance())} )
end

modifier_overlord_fireball_debuff_duration = class({})

function modifier_overlord_fireball_debuff_duration:IsPurgable()
    return true
end

function modifier_overlord_fireball_debuff_duration:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor( "interval" )
    self:StartIntervalThink( interval )
end

function modifier_overlord_fireball_debuff_duration:OnIntervalThink()
    self.min_damage = self:GetAbility():GetSpecialValueFor( "min_damage" )
    self.max_damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
    if not IsServer() then return end

    local damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }

    damageTable.damage = self.min_damage

    if self:GetStackCount() >=3 then
        damageTable.damage = self.max_damage
    end

    if self:GetParent():HasModifier("modifier_overlord_fireball_debuff") then
        self:IncrementStackCount()
    end

    ApplyDamage( damageTable )
end

function modifier_overlord_fireball_debuff_duration:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function modifier_overlord_fireball_debuff_duration:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_overlord_fireball_debuff_duration:GetStatusEffectName()
    return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_overlord_fireball_debuff_duration:StatusEffectPriority()
    return MODIFIER_PRIORITY_NORMAL
end

LinkLuaModifier( "modifier_overlord_terror_legion", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_overlord_terror_legion_talent", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )

overlord_terror_legion = class({}) 

function overlord_terror_legion:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function overlord_terror_legion:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function overlord_terror_legion:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
        if unit:GetUnitName() == "npc_overlord_small_prihvost" or unit:GetUnitName() == "npc_overlord_small_prihvost_portal" or unit:GetUnitName() == "npc_overlord_big_prihvost_portal" then
            unit:AddNewModifier(self:GetCaster(), self, "modifier_overlord_terror_legion", {duration = duration})
            if self:GetCaster():HasTalent("special_bonus_birzha_overlord_7") then
                unit:AddNewModifier(self:GetCaster(), self, "modifier_overlord_terror_legion_talent", {duration = duration})
            end
        end
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_7") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_overlord_terror_legion_talent", {duration = duration})
    end
    self:GetCaster():EmitSound("OverlordThree")
end

modifier_overlord_terror_legion = class({})

function modifier_overlord_terror_legion:IsPurgable()
    return false
end

function modifier_overlord_terror_legion:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
    self.health = self:GetAbility():GetSpecialValueFor( "bonus_health" )
end

function modifier_overlord_terror_legion:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_overlord_terror_legion:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_overlord_terror_legion:GetModifierExtraHealthBonus()
    return self.health
end

function modifier_overlord_terror_legion:GetEffectName()
    return "particles/units/heroes/hero_centaur/centaur_return_buff.vpcf"
end

function modifier_overlord_terror_legion:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_overlord_terror_legion_talent = class({})

function modifier_overlord_terror_legion_talent:IsPurgable()
    return false
end

function modifier_overlord_terror_legion_talent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MIN_HEALTH,
    }

    return funcs
end

function modifier_overlord_terror_legion_talent:GetMinHealth()
    return 1
end

LinkLuaModifier( "modifier_overlord_select_target", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )

overlord_select_target = class({}) 

function overlord_select_target:GetCooldown(level)
    if self:GetCaster():HasShard() then
        return self.BaseClass.GetCooldown( self, level ) - self:GetSpecialValueFor("shard_cooldown")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function overlord_select_target:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function overlord_select_target:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb(self) then return nil end
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
        if unit:GetUnitName() == "npc_overlord_small_prihvost" or unit:GetUnitName() == "npc_overlord_small_prihvost_portal" or unit:GetUnitName() == "npc_overlord_big_prihvost_portal" then
            unit:AddNewModifier(self:GetCaster(), self, "modifier_overlord_select_target", {duration = duration})
        end
    end
    self:GetCaster():EmitSound("OverlordFour")
end

modifier_overlord_select_target = class({}) 

function modifier_overlord_select_target:IsHidden()
    return false
end

function modifier_overlord_select_target:IsPurgable()
    return false
end

function modifier_overlord_select_target:OnCreated()
    if not IsServer() then return end
    self.target = self:GetAbility().target
    local order =
    {
        UnitIndex = self:GetParent():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(order)
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(FrameTime())
end

function modifier_overlord_select_target:OnDestroy()
   if not IsServer() then return end
    self:GetParent():Interrupt()
    self:GetParent():SetForceAttackTarget(nil)
    self:GetParent():SetForceAttackTargetAlly(nil)
    self:GetParent():Stop()
end

function modifier_overlord_select_target:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 50, FrameTime(), false)
    self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration = 0.1})
    if self.target == nil or self.target:IsAlive() == false or self.target:IsInvulnerable() then 
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_overlord_select_target:DeclareFunctions()
    local funcs = {

        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }

    return funcs
end

function modifier_overlord_select_target:GetModifierMoveSpeed_Absolute( params )
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_overlord_select_target:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FAKE_ALLY] = true,
    }
    return state
end

function modifier_overlord_select_target:GetEffectName()
    return "particles/items2_fx/mask_of_madness.vpcf" 
end

function modifier_overlord_select_target:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

LinkLuaModifier( "modifier_overlord_portal", "abilities/heroes/overlord", LUA_MODIFIER_MOTION_BOTH )

overlord_portal = class({}) 

function overlord_portal:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function overlord_portal:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function overlord_portal:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function overlord_portal:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor( "duration" )
    local portal = CreateUnitByName("npc_dota_overlord_portal", point, true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    portal:SetOwner(self:GetCaster())
    FindClearSpaceForUnit(portal, portal:GetAbsOrigin(), true)
    portal:SetForwardVector(self:GetCaster():GetForwardVector())
    portal:AddNewModifier(self:GetCaster(), self, "modifier_overlord_portal", {})
    portal:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    portal:EmitSound("OverlordScepter")
end

modifier_overlord_portal = class({})

function modifier_overlord_portal:IsPurgable()
    return false
end

function modifier_overlord_portal:IsHidden()
    return true
end

function modifier_overlord_portal:OnCreated()
    if not IsServer() then return end
    local interval = self:GetAbility():GetSpecialValueFor( "interval" )
    self.unit = 0
    local particle_2 = ParticleManager:CreateParticle("particles/winter_fx/healing_campfire_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle_2, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_2, 1, Vector(100,0,0))
    ParticleManager:SetParticleControl(particle_2, 2, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle_2, false, false, -1, false, false )
    self:StartIntervalThink(interval)
end

function modifier_overlord_portal:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetCaster():FindAbilityByName("overlord_prihvosti")
    if ability and ability:GetLevel() > 0 then
        if self.unit >= 2 then
            self.unit = 0
            name_prihvost = "npc_overlord_big_prihvost_portal"
        else
            self.unit = self.unit + 1
            name_prihvost = "npc_overlord_small_prihvost_portal"
        end
        local prihvost = CreateUnitByName( name_prihvost, self:GetParent():GetOrigin() + RandomVector( 50 ), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )
        prihvost:SetOwner(self:GetCaster())
        prihvost:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(prihvost, prihvost:GetAbsOrigin(), true)
        prihvost:AddNewModifier(self:GetCaster(), ability, "modifier_overlord_prihvosti", {})
        prihvost:AddNewModifier(self:GetCaster(), ability, "modifier_kill", {duration = ability:GetSpecialValueFor("duration")})
    end
end

function modifier_overlord_portal:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

LinkLuaModifier( "modifier_overlord_shut", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_shut_debuff", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_shut_buff", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_shut_jump", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_generic_arc_lua", "abilities/heroes/overlord.lua", LUA_MODIFIER_MOTION_BOTH )

overlord_shut = class({})

function overlord_shut:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function overlord_shut:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function overlord_shut:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function overlord_shut:OnSpellStart()
    if not IsServer() then return end
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb(self) then return end
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack2"))
    local prihvost = CreateUnitByName("npc_overlord_prihvost_ultimate", point, true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    prihvost:SetForwardVector((self.target:GetAbsOrigin() - prihvost:GetAbsOrigin()):Normalized())
    prihvost:SetOwner(self:GetCaster())
    prihvost:AddNewModifier(self:GetCaster(), self, "modifier_overlord_shut", {})
    prihvost:AddNewModifier( self:GetCaster(), self, "modifier_overlord_shut_jump", { target = self.target:entindex() } )
    prihvost:EmitSound("OverlordUltstart")
end

modifier_overlord_shut_jump = class({})

function modifier_overlord_shut_jump:IsHidden()
    return true
end

function modifier_overlord_shut_jump:IsPurgable()
    return false
end

function modifier_overlord_shut_jump:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    if not IsServer() then return end
    local duration = 0.5
    self.duration_buff = self:GetAbility():GetSpecialValueFor("duration")
    self.target = EntIndexToHScript( kv.target )
    local height = 350

    self.arc = self.parent:AddNewModifier(
        self.caster,
        self:GetAbility(),
        "modifier_generic_arc_lua",
        {
            duration = duration,
            distance = 0,
            height = height,
            fix_duration = false,
            isStun = true,
            activity = ACT_DOTA_FLAIL,
        } -- kv
    )

    self.arc:SetEndCallback(function( interrupted )
        if not self:IsNull() then
            self:Destroy()
        end
        if interrupted then return UTIL_Remove(self:GetParent()) end
        self.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_overlord_shut_debuff", { duration = self.duration_buff * (1-self.target:GetStatusResistance()) } )
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_overlord_shut_buff", { duration = self.duration_buff, target_entindex = self.target:entindex() } )
        self:GetParent():SetForwardVector((self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
    end)

    local origin = self.target:GetOrigin()
    local direction = origin-self.parent:GetOrigin()
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    self.distance = distance
    if self.distance==0 then self.distance = 1 end
    self.duration = duration
    self.speed = distance/duration
    self.accel = 100
    self.max_speed = 3000
    if not self:ApplyHorizontalMotionController() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_overlord_shut_jump:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_overlord_shut_jump:UpdateHorizontalMotion( me, dt )
    local target = self.target:GetOrigin()
    local parent = self.parent:GetOrigin()
    local duration = self:GetElapsedTime()
    local direction = target-parent
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    local original_distance = duration/self.duration * self.distance
    local expected_speed
    if self:GetElapsedTime()>=self.duration then
        expected_speed = self.speed
    else
        expected_speed = distance/(self.duration-self:GetElapsedTime())
    end
    if self.speed<expected_speed then
        self.speed = math.min(self.speed + self.accel, self.max_speed)
    elseif self.speed>expected_speed then
        self.speed = math.max(self.speed - self.accel, 0)
    end
    local pos = parent + direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_overlord_shut_jump:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

modifier_overlord_shut = class({})

function modifier_overlord_shut:IsPurgable() return false end
function modifier_overlord_shut:IsHidden() return true end

function modifier_overlord_shut:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

function modifier_overlord_shut:DeclareFunctions()
    if self:GetParent():HasModifier("modifier_overlord_shut_jump") then
        self.animation = ACT_DOTA_IDLE
    else
        self.animation = ACT_DOTA_ATTACK
    end
    local decFuncs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return decFuncs
end

function modifier_overlord_shut:GetOverrideAnimation()
    return self.animation
end

modifier_overlord_shut_debuff = class({})

function modifier_overlord_shut_debuff:IsPurgable() return false end
function modifier_overlord_shut_debuff:IsHidden() return false end

function modifier_overlord_shut_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

function modifier_overlord_shut_debuff:OnCreated()
    if not IsServer() then return end
    self:OnIntervalThink()
    self:StartIntervalThink(1)
end

function modifier_overlord_shut_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end

function modifier_overlord_shut_debuff:GetBonusDayVision( params )
    return -9999999
end

function modifier_overlord_shut_debuff:GetBonusNightVision( params )
    return -9999999
end

function modifier_overlord_shut_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetAbility():GetSpecialValueFor("damage_from_attack"))
    local damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        ability = self:GetAbility(),
        damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable)
    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_5") then
        self:Purge()
    end
end

function modifier_overlord_shut_debuff:Purge()
    self:GetParent():Purge(true, false, false, false, false)
end

modifier_overlord_shut_buff = class({})

function modifier_overlord_shut_buff:IsPurgable() return false end
function modifier_overlord_shut_buff:IsHidden() return false end

function modifier_overlord_shut_buff:OnCreated(params)
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target_entindex)
    self:StartIntervalThink(FrameTime())
end

function modifier_overlord_shut_buff:OnIntervalThink()
    if self.target and not self.target:IsNull() then
        if self.target:IsAlive() then
            self:GetParent():SetAbsOrigin(self.target:GetAbsOrigin() - self.target:GetForwardVector() * 64)
            self:GetParent():SetForwardVector((self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_overlord_shut_buff:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():IsNull() then
        return
    end
    self:GetParent():EmitSound("OverlordUltend")
    self:GetParent():Destroy()
end

-- Created by Elfansoer
--[[
    Generic Jump Arc

    kv data (default):
    -- direction, provide just one (or none for default):
        dir_x/y (forward), for direction
        target_x/y (forward), for target point
    -- horizontal motion, provide 2 of 3, duration-only (for vertical arc), or all 3
        speed (0)
        duration (0)
        distance (0): zero means no horizontal motion
    -- vertical motion.
        height (0): max height. zero means no vertical motion
        start_offset (0), height offset from ground at start of jump
        end_offset (0), height offset from ground at end of jump
    -- arc types
        fix_end (true): if true, landing z-pos is the same as jumping z-pos, not respecting on landing terrain height (Pounce)
        fix_duration (true): if false, arc ends when unit touches ground, not respecting duration (Shield Crash)
        fix_height (true): if false, arc max height depends on jump distance, height provided is max-height (Tree Dance)
    -- other
        isStun (false), parent is stunned
        isRestricted (false), parent is command restricted
        isForward (false), lock parent forward facing
        activity (none), activity when leaping
]] 
--------------------------------------------------------------------------------
modifier_generic_arc_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_arc_lua:IsHidden()
    return true
end

function modifier_generic_arc_lua:IsDebuff()
    return false
end

function modifier_generic_arc_lua:IsStunDebuff()
    return false
end

function modifier_generic_arc_lua:IsPurgable()
    return true
end

function modifier_generic_arc_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_arc_lua:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_generic_arc_lua:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_generic_arc_lua:OnRemoved()
end

function modifier_generic_arc_lua:OnDestroy()
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
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_generic_arc_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    if self:GetStackCount()>0 then
        table.insert( funcs, MODIFIER_PROPERTY_OVERRIDE_ANIMATION )
    end

    return funcs
end

function modifier_generic_arc_lua:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end
function modifier_generic_arc_lua:GetOverrideAnimation()
    return self:GetStackCount()
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_arc_lua:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = self.isStun or false,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_generic_arc_lua:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end

    -- set relative position
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_generic_arc_lua:UpdateVerticalMotion( me, dt )
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
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_generic_arc_lua:OnHorizontalMotionInterrupted()
    self.interrupted = true
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_generic_arc_lua:OnVerticalMotionInterrupted()
    self.interrupted = true
    if not self:IsNull() then
        self:Destroy()
    end
end

--------------------------------------------------------------------------------
-- Motion Helper
function modifier_generic_arc_lua:SetJumpParameters( kv )
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

function modifier_generic_arc_lua:Jump()
    -- apply horizontal motion
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            if not self:IsNull() then
                self:Destroy()
                return
            end
        end
    end

    -- apply vertical motion
    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            if not self:IsNull() then
                self:Destroy()
                return
            end
        end
    end
end

function modifier_generic_arc_lua:InitVerticalArc( height_start, height_max, height_end, duration )
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

function modifier_generic_arc_lua:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_generic_arc_lua:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

--------------------------------------------------------------------------------
-- Helper
function modifier_generic_arc_lua:SetEndCallback( func )
    self.endCallback = func
end