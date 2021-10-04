LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_thomas_smoke_debuff", "abilities/heroes/thomas.lua", LUA_MODIFIER_MOTION_NONE)

Thomas_smoke = class({})

function Thomas_smoke:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Thomas_smoke:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Thomas_smoke:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Thomas_smoke:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    self:GetCaster():EmitSound("Hero_Venomancer.PoisonNova")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    0,
    FIND_ANY_ORDER,
    false)

    for _,unit in pairs(targets) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_thomas_smoke_debuff", { duration = duration } )
    end
    local particle = ParticleManager:CreateParticle("particles/thomas/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, (radius - 125) / 500, 500))
end

modifier_thomas_smoke_debuff = class({})

function modifier_thomas_smoke_debuff:IsPurgable()
    return false
end

function modifier_thomas_smoke_debuff:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Venomancer.PoisonNovaImpact")
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_thomas_smoke_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_thomas_1")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_thomas_smoke_debuff:GetEffectName()
    return "particles/debuff/venomancer_poison_debuff_nova.vpcf"
end

function modifier_thomas_smoke_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

LinkLuaModifier("modifier_thomas_housing", "abilities/heroes/thomas.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )

thomas_housing = class({})

function thomas_housing:GetIntrinsicModifierName()
    return "modifier_thomas_housing"
end

modifier_thomas_housing = class({})

function modifier_thomas_housing:IsHidden()
    return true
end

function modifier_thomas_housing:OnCreated()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_movespeed_cap", {})
end

function modifier_thomas_housing:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
    return declfuncs
end

function modifier_thomas_housing:GetModifierPercentageCooldown()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("cooldown_reduce_pct")
end

function modifier_thomas_housing:GetModifierMoveSpeedBonus_Constant()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

LinkLuaModifier( "modifier_thomas_fired", "abilities/heroes/thomas.lua", LUA_MODIFIER_MOTION_NONE )

thomas_fired = class({})

function thomas_fired:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_thomas_4")
end

function thomas_fired:GetManaCost(level)
    return self:GetSpecialValueFor("mana_per_sec")
end

function thomas_fired:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()
    if not IsServer() then return end
    if toggle then
        self.modifier = caster:AddNewModifier( caster, self, "modifier_thomas_fired", {} )
    else
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
        self.modifier = nil
    end
end

modifier_thomas_fired = class({})

function modifier_thomas_fired:IsPurgable()
    return false
end

function modifier_thomas_fired:IsHidden()
    return false
end


function modifier_thomas_fired:OnCreated()
    if not IsServer() then return end
    self.manacost = self:GetAbility():GetSpecialValueFor( "mana_per_sec" )
    self:StartIntervalThink(0.2)
    self:OnIntervalThink()
end

function modifier_thomas_fired:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_thomas_4")
    local mana = self:GetParent():GetMana()
    if mana < self.manacost then
        if self:GetAbility():GetToggleState() then
            self:GetAbility():ToggleAbility()
            self:Destroy()
        end
        return
    end
    self:GetParent():SpendMana( self.manacost, self:GetAbility() )
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), radius, true)
    self.particle_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle_1, 11, Vector(1, 0, 0))
    self:AddParticle(self.particle_1, false, false, -1, false, false)

    self.particle_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk_smoke_light.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle_2, 11, Vector(1, 0, 0))
    self:AddParticle(self.particle_2, false, false, -1, false, false)

    self.particle_3 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_loadout_char_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle_3, 11, Vector(1, 0, 0))
    self:AddParticle(self.particle_3, false, false, -1, false, false)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_thomas_2")
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    end
end

LinkLuaModifier( "modifier_Train_Thomas", "abilities/heroes/thomas.lua", LUA_MODIFIER_MOTION_NONE)

Thomas_MLG_RaGE = class({})

function Thomas_MLG_RaGE:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Thomas_MLG_RaGE:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Thomas_MLG_RaGE:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Thomas_MLG_RaGE:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("thomas")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Train_Thomas", { duration = duration } )
end

modifier_Train_Thomas = class({})

function modifier_Train_Thomas:IsPurgable()
    return false
end

function modifier_Train_Thomas:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_Train_Thomas:GetEffectName()
    return "particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf"
end

function modifier_Train_Thomas:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Train_Thomas:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
    return decFuncs
end

function modifier_Train_Thomas:GetModifierAttackRangeBonus()
    return -1000
end

function modifier_Train_Thomas:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("speed")    
end

function modifier_Train_Thomas:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        self:Destroy()
    end
end

function modifier_Train_Thomas:OnDestroy()
    if not IsServer() then return end
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    local radius_boom = self:GetAbility():GetSpecialValueFor("radius_boom")
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_thomas_3")
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        radius_boom,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = stun_duration})
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = stun_duration} )
    end
    if #enemies <= 0 then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = 3} )
    end
    self:GetParent():StopSound("thomas")
    local particle_explosion_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_explosion_fx)
    EmitSoundOn("Hero_Techies.LandMine.Detonate", self:GetParent())
end







