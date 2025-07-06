LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hesus_spider_movespeed_debuff", "abilities/heroes/jesus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

JesusAVGN_Spider = class({})

function JesusAVGN_Spider:Precache(context)
    local particle_list = 
    {
        
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function JesusAVGN_Spider:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function JesusAVGN_Spider:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function JesusAVGN_Spider:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function JesusAVGN_Spider:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local info = {
        EffectName = "particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf",
        Ability = self,
        iMoveSpeed = 1500,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")
end

function JesusAVGN_Spider:OnProjectileHit_ExtraData(hTarget, vLocation, hExtraData)
    if hTarget then
        hTarget:EmitSound("Hero_Broodmother.SpawnSpiderlingsImpact")
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
        ParticleManager:SetParticleControl( particle, 0, hTarget:GetAbsOrigin() )
        local duration = self:GetSpecialValueFor("duration")
        local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_jesus_4")
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_hesus_spider_movespeed_debuff", {duration = duration * (1 - hTarget:GetStatusResistance())})
        ApplyDamage({attacker = self:GetCaster(), victim = hTarget, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
        self.big_spider = CreateUnitByName("npc_jesus_spider_"..self:GetLevel(), hTarget:GetAbsOrigin() + RandomVector(50), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
        self.big_spider:SetOwner(self:GetCaster())
        self.big_spider:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(self.big_spider, self.big_spider:GetAbsOrigin(), true)
    end
end

modifier_hesus_spider_movespeed_debuff = class({})

function modifier_hesus_spider_movespeed_debuff:IsPurgable() return true end

function modifier_hesus_spider_movespeed_debuff:DeclareFunctions() return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
} end

function modifier_hesus_spider_movespeed_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_hesus_spider_movespeed_debuff:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf"
end

function modifier_hesus_spider_movespeed_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_jesusavgn_spiderpoison", "abilities/heroes/jesus.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jesusavgn_spiderpoison_aura", "abilities/heroes/jesus.lua", LUA_MODIFIER_MOTION_NONE )

JesusAVGN_SpiderPoison = class({})

function JesusAVGN_SpiderPoison:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function JesusAVGN_SpiderPoison:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function JesusAVGN_SpiderPoison:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function JesusAVGN_SpiderPoison:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function JesusAVGN_SpiderPoison:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor( "duration" )
    local radius = self:GetSpecialValueFor( "radius" )
    local stun_duration = self:GetSpecialValueFor( "stun_duration" )
    local count = self:GetSpecialValueFor('count')
    GridNav:DestroyTreesAroundPoint(point, radius, false)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, self, "modifier_birzha_stunned_purge", {duration = stun_duration})
    end
    CreateModifierThinker( caster, self, "modifier_jesusavgn_spiderpoison", { duration = duration }, point, caster:GetTeamNumber(), false )
    caster:EmitSound("Hero_Viper.NetherToxin")
    for i = 1, count do
        self.small_spider = CreateUnitByName("npc_jesus_mini_spider_"..self:GetLevel(), point + RandomVector(150), true, caster, nil, caster:GetTeamNumber())
        self.small_spider:SetOwner(caster)
        self.small_spider:SetControllableByPlayer(caster:GetPlayerID(), true)
        FindClearSpaceForUnit(self.small_spider, self.small_spider:GetAbsOrigin(), true)
    end
end

modifier_jesusavgn_spiderpoison = class({})

function modifier_jesusavgn_spiderpoison:IsPurgable()
    return false
end

function modifier_jesusavgn_spiderpoison:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_viper/viper_nethertoxin.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, 1, 1 ) )
    self:AddParticle(particle, false, false, -1, false, false )
end

function modifier_jesusavgn_spiderpoison:IsAura()
    return true
end

function modifier_jesusavgn_spiderpoison:GetModifierAura()
    return "modifier_jesusavgn_spiderpoison_aura"
end

function modifier_jesusavgn_spiderpoison:GetAuraRadius()
    return self.radius
end

function modifier_jesusavgn_spiderpoison:GetAuraDuration()
    return 0.5
end

function modifier_jesusavgn_spiderpoison:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_jesusavgn_spiderpoison:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_jesusavgn_spiderpoison:GetAuraSearchFlags()
    return 0
end

modifier_jesusavgn_spiderpoison_aura = class({})

function modifier_jesusavgn_spiderpoison_aura:IsPurgable()
    return false
end

function modifier_jesusavgn_spiderpoison_aura:IsHidden()
    return false
end

function modifier_jesusavgn_spiderpoison_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType()})
end

function modifier_jesusavgn_spiderpoison_aura:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType()})
end

LinkLuaModifier("modifier_jesus_punchspider", "abilities/heroes/jesus", LUA_MODIFIER_MOTION_NONE)

JesusAVGN_PunchSpider = class({}) 

function JesusAVGN_PunchSpider:GetIntrinsicModifierName()
    return "modifier_jesus_punchspider"
end

modifier_jesus_punchspider = class({}) 

function modifier_jesus_punchspider:IsHidden()      return true end
function modifier_jesus_punchspider:IsPurgable()    return false end

function modifier_jesus_punchspider:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_jesus_punchspider:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()

    if attacker ~= keys.attacker then
        return
    end

    if attacker:PassivesDisabled() or attacker:IsIllusion() then
        return
    end

    local target = keys.target

    if attacker:GetTeam() == target:GetTeam() then
        return
    end 

    if target:IsOther() then
        return nil
    end

    local chance = self:GetAbility():GetSpecialValueFor('chance') + self:GetCaster():FindTalentValue("special_bonus_birzha_jesus_1")
    if target:IsBoss() then return end
    if RandomInt(1, 100) <= chance then
        if self:GetCaster():HasTalent("special_bonus_birzha_jesus_2") then
            self.big_spider = CreateUnitByName("npc_jesus_spider_"..self:GetAbility():GetLevel(), target:GetAbsOrigin() + RandomVector(150), true, attacker, nil, attacker:GetTeamNumber())
            self.big_spider:SetOwner(attacker)
            self.big_spider:SetControllableByPlayer(attacker:GetPlayerID(), true)
            FindClearSpaceForUnit(self.big_spider, self.big_spider:GetAbsOrigin(), true)
        else
            self.small_spider = CreateUnitByName("npc_jesus_mini_spider_"..self:GetAbility():GetLevel(), target:GetAbsOrigin() + RandomVector(150), true, attacker, nil, attacker:GetTeamNumber())
            self.small_spider:SetOwner(attacker)
            self.small_spider:SetControllableByPlayer(attacker:GetPlayerID(), true)
            FindClearSpaceForUnit(self.small_spider, self.small_spider:GetAbsOrigin(), true)
        end        
    end
end

LinkLuaModifier("modifier_jesus_ganstaalexey", "abilities/heroes/jesus.lua", LUA_MODIFIER_MOTION_NONE)

JesusAVGN_GangstaAlexey = class ({})

function JesusAVGN_GangstaAlexey:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function JesusAVGN_GangstaAlexey:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function JesusAVGN_GangstaAlexey:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound( "hesusult" )
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_jesus_3")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jesus_ganstaalexey", { duration = duration })
end

modifier_jesus_ganstaalexey = class ({})

function modifier_jesus_ganstaalexey:IsPurgable()
    return false
end

function modifier_jesus_ganstaalexey:OnCreated()
    if not IsServer() then return end
    if self:GetAbility():GetLevel() == 1 then
        self.Wmotka1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/heavymetal_weapon/heavymetal_weapon.vmdl"})
        self.Wmotka2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/heavymetal_shoulder/heavymetal_shoulder.vmdl"})
        self.Wmotka3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/heavymetal_back/heavymetal_back.vmdl"})
        self.Wmotka1:FollowEntity(self:GetParent(), true)
        self.Wmotka2:FollowEntity(self:GetParent(), true)
        self.Wmotka3:FollowEntity(self:GetParent(), true)
    elseif self:GetAbility():GetLevel() == 2 then
        self.Wmotka1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/wolf_arms_dark/wolf_arms_dark.vmdl"})
        self.Wmotka2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/wolf_cape_dark/wolf_cape_dark.vmdl"})
        self.Wmotka3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/wolf_gun_bright/wolf_gun_bright.vmdl"})
        self.Wmotka4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/wolf_hat_dark/wolf_hat_dark.vmdl"})
        self.Wmotka1:FollowEntity(self:GetParent(), true)
        self.Wmotka2:FollowEntity(self:GetParent(), true)
        self.Wmotka3:FollowEntity(self:GetParent(), true)
        self.Wmotka4:FollowEntity(self:GetParent(), true)
    elseif self:GetAbility():GetLevel() == 3 then
        self.Wmotka1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/witch_hunter_set_back/witch_hunter_set_back.vmdl"})
        self.Wmotka2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/witch_hunter_set_head/witch_hunter_set_head.vmdl"})
        self.Wmotka3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/witch_hunter_set_shoulder/witch_hunter_set_shoulder.vmdl"})
        self.Wmotka4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/witch_hunter_set_weapon/witch_hunter_set_weapon.vmdl"})
        self.Wmotka1:FollowEntity(self:GetParent(), true)
        self.Wmotka2:FollowEntity(self:GetParent(), true)
        self.Wmotka3:FollowEntity(self:GetParent(), true)
        self.Wmotka4:FollowEntity(self:GetParent(), true)
    end
end

function modifier_jesus_ganstaalexey:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("hesusult")
    if self.Wmotka1 then
        UTIL_Remove(self.Wmotka1)
    end
    if self.Wmotka2 then
        UTIL_Remove(self.Wmotka2)
    end
    if self.Wmotka3 then
        UTIL_Remove(self.Wmotka3)
    end
    if self.Wmotka4 then
        UTIL_Remove(self.Wmotka4)
    end
end

function modifier_jesus_ganstaalexey:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }
 
    return funcs
end

function modifier_jesus_ganstaalexey:GetModifierModelChange()
    return "models/heroes/sniper/sniper.vmdl"
end

function modifier_jesus_ganstaalexey:GetModifierProjectileName()
    return "particles/econ/items/sniper/sniper_charlie/sniper_base_attack_charlie.vpcf"
end

function modifier_jesus_ganstaalexey:GetModifierAttackRangeBonus(params)
    return self:GetAbility():GetSpecialValueFor("bonus_range")
end

function modifier_jesus_ganstaalexey:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and not self:GetParent():IsIllusion() and params.target:GetTeamNumber() ~= params.attacker:GetTeamNumber() then
        if params.target:IsOther() then
            return nil
        end
        local chance = self:GetAbility():GetSpecialValueFor('chance')
        local damage = self:GetAbility():GetSpecialValueFor('damage')
        if RandomInt(1, 100) <= chance then        
            local knockback =
            {
                should_stun = false,
                knockback_duration = 0.5,
                duration = 0.5,
                knockback_distance = 50,
                knockback_height = 10,
            }
            if params.target:HasModifier("modifier_knockback") then
                params.target:RemoveModifierByName("modifier_knockback")
            end
            ApplyDamage({attacker = self:GetCaster(), victim = params.target, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE})
            if params.target:IsBoss() then return end
            if params.target:IsMagicImmune() then return end
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_knockback", knockback)
        end
    end
end