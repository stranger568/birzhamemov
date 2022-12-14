LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_jew_flame_guard", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jew_flame_guard_shard", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jew_flame_guard_shard_aura", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jew_flame_guard_shard_debuff", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)

jew_flame_guard = class({}) 

function jew_flame_guard:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_6")
end

function jew_flame_guard:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function jew_flame_guard:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_2")
end

function jew_flame_guard:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jew_flame_guard", {duration = duration})

    if self:GetCaster():HasShard() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jew_flame_guard_shard", {duration = duration})
    end

    self:GetCaster():EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
end

modifier_jew_flame_guard = class ({})

function modifier_jew_flame_guard:IsPurgable() return true end

function modifier_jew_flame_guard:GetEffectName()
    return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_jew_flame_guard:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jew_flame_guard:OnCreated(keys)
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_EmberSpirit.FlameGuard.Loop") 
    local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    local damage = self:GetAbility():GetSpecialValueFor("damage_per_second") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_1")
    local absorb_amount = (self:GetAbility():GetSpecialValueFor("absorb_amount") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_3"))
    self.damage = damage * tick_interval
    self.remaining_health = absorb_amount
    self:SetStackCount(self.remaining_health)
    self:StartIntervalThink(tick_interval)
end

function modifier_jew_flame_guard:OnRefresh(keys)
    if not IsServer() then return end
    local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    local damage = self:GetAbility():GetSpecialValueFor("damage_per_second") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_1")
    local absorb_amount = (self:GetAbility():GetSpecialValueFor("absorb_amount") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_3"))
    self.damage = damage * tick_interval
    self.remaining_health = absorb_amount
    self:SetStackCount(self.remaining_health)
    self:StartIntervalThink(tick_interval)
end

function modifier_jew_flame_guard:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function modifier_jew_flame_guard:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_2")
    if self.remaining_health <= 0 then
        self:GetParent():RemoveModifierByName("modifier_jew_flame_guard")
    else
        local nearby_enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, enemy in pairs(nearby_enemies) do
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end
end

function modifier_jew_flame_guard:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_jew_flame_guard:GetModifierAvoidDamage(keys)
    if not IsServer() then return end

    if keys.damage <= 0 then return end

    if self:GetCaster():HasTalent("special_bonus_birzha_evrei_8") then
        self.remaining_health = self.remaining_health - keys.original_damage
        self:SetStackCount(self.remaining_health)
        return 1
    end

    if keys.damage_type == DAMAGE_TYPE_MAGICAL then
        self.remaining_health = self.remaining_health - keys.original_damage
        self:SetStackCount(self.remaining_health)
        return 1
    else
        return 0
    end
end

modifier_jew_flame_guard_shard = class({})

function modifier_jew_flame_guard_shard:IsHidden() return true end
function modifier_jew_flame_guard_shard:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end
function modifier_jew_flame_guard_shard:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_jew_flame_guard") then
        self:Destroy()
    end
end
function modifier_jew_flame_guard_shard:IsAura()
    return true
end

function modifier_jew_flame_guard_shard:GetModifierAura()
    return "modifier_jew_flame_guard_shard_aura"
end

function modifier_jew_flame_guard_shard:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_2")
end

function modifier_jew_flame_guard_shard:GetAuraDuration()
    return 0
end

function modifier_jew_flame_guard_shard:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_jew_flame_guard_shard:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
modifier_jew_flame_guard_shard_aura = class({})

function modifier_jew_flame_guard_shard_aura:IsHidden() return true end
function modifier_jew_flame_guard_shard_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("shard_to_active"))
end
function modifier_jew_flame_guard_shard_aura:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jew_flame_guard_shard_debuff", {duration = self:GetAbility():GetSpecialValueFor("shard_duration")})
end

modifier_jew_flame_guard_shard_debuff = class ({})

function modifier_jew_flame_guard_shard_debuff:IsPurgable() return true end

function modifier_jew_flame_guard_shard_debuff:GetEffectName()
    return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_jew_flame_guard_shard_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jew_flame_guard_shard_debuff:OnCreated(keys)
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_EmberSpirit.FlameGuard.Loop") 
    local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    local damage = self:GetAbility():GetSpecialValueFor("damage_per_second") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_1")
    self.damage = damage * tick_interval
    self:StartIntervalThink(tick_interval)
end

function modifier_jew_flame_guard_shard_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function modifier_jew_flame_guard_shard_debuff:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_2")
    local nearby_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, enemy in pairs(nearby_enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

LinkLuaModifier("modifier_evrei_zhad", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evrei_zhad_damage_buff", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evrei_zhad_damage_debuff", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evrei_zhad_damage_buff_stack", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evrei_zhad_damage_debuff_stack", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)

evrei_zhad = class({})

function evrei_zhad:GetIntrinsicModifierName()
    return "modifier_evrei_zhad"
end

modifier_evrei_zhad = class ({})

function modifier_evrei_zhad:IsHidden()
    return true
end

function modifier_evrei_zhad:IsPurgable()
    return false
end

function modifier_evrei_zhad:DeclareFunctions()
    local declfuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
    return declfuncs
end

function modifier_evrei_zhad:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if params.target:IsBoss() then return end

    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_5")

    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target )
    ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_buff_stack", { duration = duration } )
    self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_buff", { duration = duration } )

    params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_debuff_stack", { duration = duration * (1-params.target:GetStatusResistance()) } )
    params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_debuff", { duration = duration * (1-params.target:GetStatusResistance()) } )
end

modifier_evrei_zhad_damage_buff = class({})

function modifier_evrei_zhad_damage_buff:IsPurgable() return false end
function modifier_evrei_zhad_damage_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_evrei_zhad_damage_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_evrei_zhad_damage_buff:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_evrei_zhad_damage_buff_stack")
    local damage_steal = self:GetAbility():GetSpecialValueFor("damage_steal")
    if self:GetCaster():HasTalent("special_bonus_birzha_evrei_7") then
        damage_steal = damage_steal * self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_7")
    end
    self:SetStackCount(#modifier * damage_steal)
end

function modifier_evrei_zhad_damage_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_evrei_zhad_damage_buff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

modifier_evrei_zhad_damage_debuff = class({})

function modifier_evrei_zhad_damage_debuff:IsPurgable() return false end
function modifier_evrei_zhad_damage_debuff:IsHidden() return self:GetStackCount() == 0 end

function modifier_evrei_zhad_damage_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_evrei_zhad_damage_debuff:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_evrei_zhad_damage_debuff_stack")
    local damage_steal = self:GetAbility():GetSpecialValueFor("damage_steal")
    if self:GetCaster():HasTalent("special_bonus_birzha_evrei_7") then
        damage_steal = damage_steal * self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_7")
    end
    self:SetStackCount(#modifier * damage_steal)
end

function modifier_evrei_zhad_damage_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_evrei_zhad_damage_debuff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * -1
end

modifier_evrei_zhad_damage_buff_stack = class({})

function modifier_evrei_zhad_damage_buff_stack:IsHidden()
    return true
end
function modifier_evrei_zhad_damage_buff_stack:IsPurgable() return false end

function modifier_evrei_zhad_damage_buff_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_evrei_zhad_damage_debuff_stack = class({})

function modifier_evrei_zhad_damage_debuff_stack:IsHidden()
    return true
end

function modifier_evrei_zhad_damage_debuff_stack:IsPurgable() return false end

function modifier_evrei_zhad_damage_debuff_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier("modifier_evrei_znak", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)

evrei_znak = class({})

function evrei_znak:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function evrei_znak:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function evrei_znak:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function evrei_znak:GetIntrinsicModifierName()
    return "modifier_evrei_znak"
end

modifier_evrei_znak = class({})

function modifier_evrei_znak:IsHidden()
    return true
end

function modifier_evrei_znak:IsPurgable() return false end

function modifier_evrei_znak:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
    return declfuncs
end

function modifier_evrei_znak:GetModifierBonusStats_Agility()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_evrei_znak:GetModifierBonusStats_Strength()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function evrei_znak:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local projectile_speed = 1200
    local count = self:GetSpecialValueFor("scepter_count")

    local shuriken_projectile = 
    {
        Target = target,
        Source = self:GetCaster(),
        Ability = self,
        EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
        iMoveSpeed = projectile_speed,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        ExtraData = {count = count}
    }

    ProjectileManager:CreateTrackingProjectile(shuriken_projectile)
    self:GetCaster():EmitSound("Hero_BountyHunter.Shuriken")
end

function evrei_znak:StartShuriken(pre_target, target, count)
    if not IsServer() then return end
    local projectile_speed = 1200

    local shuriken_projectile = 
    {
        Target = target,
        Source = pre_target,
        Ability = self,
        EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
        iMoveSpeed = projectile_speed,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        ExtraData = {count = count}
    }

    ProjectileManager:CreateTrackingProjectile(shuriken_projectile)
end

function evrei_znak:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not IsServer() then return end
    if target == nil then return end

    local scepter_damage = self:GetSpecialValueFor("scepter_damage")
    local scepter_stun = self:GetSpecialValueFor("scepter_stun")
    local scepter_radius = self:GetSpecialValueFor("scepter_radius")

    target:EmitSound("Hero_BountyHunter.Shuriken.Impact")

    if target:TriggerSpellAbsorb(self) then
        return nil
    end

    if target:IsMagicImmune() then return end

    ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = scepter_damage, damage_type = DAMAGE_TYPE_MAGICAL})
    target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = scepter_stun * (1 - target:GetStatusResistance())})

    if ExtraData.count > 0 then
        ExtraData.count = ExtraData.count - 1
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, scepter_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
        for _, unit in pairs(units) do
            if unit and unit ~= target then
                self:StartShuriken(target, unit, ExtraData.count)
                break
            end
        end
    end
end

LinkLuaModifier("modifier_evrei_gold", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)

evrei_ult = class({}) 

function evrei_ult:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function evrei_ult:GetIntrinsicModifierName()
    return "modifier_evrei_gold"
end

modifier_evrei_gold = class({})

function modifier_evrei_gold:IsHidden()
    return true
end

function modifier_evrei_gold:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_evrei_gold:OnIntervalThink()
    if not IsServer() then return end
    local money = self:GetAbility():GetSpecialValueFor("money_amount") + self:GetCaster():FindTalentValue("special_bonus_birzha_evrei_4")
    if self:GetParent():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources(false, false, true)
        self:GetParent():ModifyGold( money, true, 0 )
        self:GetParent():EmitSound("DOTA_Item.Hand_Of_Midas")
        if DonateShopIsItemBought(self:GetParent():GetPlayerID(), 31) then
            local midas_particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())    
            ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        else
            local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())   
            ParticleManager:SetParticleControlEnt(midas_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        end
    end
end