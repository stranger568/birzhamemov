LinkLuaModifier( "modifier_Durov_AttackOnPoliceman", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Durov_AttackOnPoliceman_aura", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )

Durov_AttackOnPoliceman = class({})

function Durov_AttackOnPoliceman:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Durov_AttackOnPoliceman:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Durov_AttackOnPoliceman:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Durov_AttackOnPoliceman:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Durov_AttackOnPoliceman:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")

    local thinker = CreateModifierThinker(caster, self, "modifier_Durov_AttackOnPoliceman", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    thinker:EmitSound("Hero_Tinker.GridEffect")
end

modifier_Durov_AttackOnPoliceman = class({})

function modifier_Durov_AttackOnPoliceman:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.particle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_start_bots.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, 0, self.radius))
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_Durov_AttackOnPoliceman:IsPurgable() return false end
function modifier_Durov_AttackOnPoliceman:IsHidden() return true end
function modifier_Durov_AttackOnPoliceman:IsAura() return true end

function modifier_Durov_AttackOnPoliceman:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY end

function modifier_Durov_AttackOnPoliceman:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_Durov_AttackOnPoliceman:GetModifierAura()
    return "modifier_Durov_AttackOnPoliceman_aura"
end

function modifier_Durov_AttackOnPoliceman:GetAuraRadius()
    return self.radius
end

modifier_Durov_AttackOnPoliceman_aura = class({})

function modifier_Durov_AttackOnPoliceman_aura:IsPurgable() return false end

function modifier_Durov_AttackOnPoliceman_aura:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/durov/durov_one.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetOrigin(), true)
    ParticleManager:SetParticleControlEnt( self.particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
    self:AddParticle( self.particle, false, false, -1, false, false )
end

function modifier_Durov_AttackOnPoliceman_aura:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle( self.particle, false )
        ParticleManager:ReleaseParticleIndex( self.particle )
    end
end

function modifier_Durov_AttackOnPoliceman_aura:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, }
    return funcs
end

function modifier_Durov_AttackOnPoliceman_aura:GetModifierPreAttack_BonusDamage()
    return self.damage
end

LinkLuaModifier("modifier_Durov_omni_slash_caster", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE)

Durov_omni_slash = class({})

function Durov_omni_slash:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    else
        return self.BaseClass.GetCooldown(self, level)
    end
end

function Durov_omni_slash:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Durov_omni_slash:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Durov_omni_slash:OnOwnerDied()
    if not self:IsActivated() then
        self:SetActivated(true)
    end
end

function Durov_omni_slash:OnOwnerSpawned()
    self:OnOwnerDied()
end

function Durov_omni_slash:OnSpellStart()
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    self.previous_position = self.caster:GetAbsOrigin()
    if self.target:TriggerSpellAbsorb(self) then return end
    self.caster:Purge(false, true, false, false, false)
    self.duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_1")
    if self.caster:HasScepter() then
        self.duration = self:GetSpecialValueFor("duration_scepter") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_1")
    end

    local omnislash_modifier_handler = self.caster:AddNewModifier(self.caster, self, "modifier_Durov_omni_slash_caster", {duration = self.duration})

    if omnislash_modifier_handler then
        omnislash_modifier_handler.original_caster = self.caster
    end

    self:SetActivated(false)
    FindClearSpaceForUnit(self.caster, self.target:GetAbsOrigin() + RandomVector(128), false)
    self.caster:EmitSound("Hero_Juggernaut.OmniSlash")
    self.current_position = self.caster:GetAbsOrigin()
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self.caster)
    ParticleManager:SetParticleControl(particle, 0, self.previous_position)
    ParticleManager:SetParticleControl(particle, 1, self.current_position)
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_Durov_omni_slash_caster = class({})

function modifier_Durov_omni_slash_caster:IsHidden() return false end
function modifier_Durov_omni_slash_caster:IsPurgable() return false end
function modifier_Durov_omni_slash_caster:IsDebuff() return false end

function modifier_Durov_omni_slash_caster:OnCreated()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.base_bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.last_enemy = nil

    self.slash = true

    if IsServer() then
        Timers:CreateTimer(FrameTime(), function()
            if (not self.parent:IsNull()) then
                self.bounce_range = self:GetAbility():GetSpecialValueFor("omni_slash_radius")
                self.hero_agility = self.original_caster:GetAgility()
                self:GetAbility():SetRefCountsModifiers(false)
                self:BounceAndSlaughter(true)
                local slash_rate = (1 / ( self.caster:GetAttackSpeed() * (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))))
                self:StartIntervalThink(slash_rate)
            end
        end)
    end
end

function modifier_Durov_omni_slash_caster:OnIntervalThink()
    self.hero_agility = self.original_caster:GetAgility()
    self:BounceAndSlaughter()
    local slash_rate = (1 / ( self.caster:GetAttackSpeed() * (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier"), 1))))
    self:StartIntervalThink(-1)
    self:StartIntervalThink(slash_rate)
end

function modifier_Durov_omni_slash_caster:BounceAndSlaughter(first_slash)
    local order = FIND_ANY_ORDER
    if first_slash then
        order = FIND_CLOSEST
    end
    
    self.nearby_enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),
        self.parent:GetAbsOrigin(),
        nil,
        self.bounce_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        order,
        false
    )
    
    for count = #self.nearby_enemies, 1, -1 do
        if self.nearby_enemies[count] and (self.nearby_enemies[count]:GetName() == "npc_dota_face_zombie") then
            table.remove(self.nearby_enemies, count)
        end
    end

    if #self.nearby_enemies >= 1 then
        for _,enemy in pairs(self.nearby_enemies) do
            local previous_position = self.parent:GetAbsOrigin()
            FindClearSpaceForUnit(self.parent, enemy:GetAbsOrigin() + RandomVector(100), false)
            if not self:GetAbility() then break end
            local current_position = self.parent:GetAbsOrigin()
            self.parent:FaceTowards(enemy:GetAbsOrigin())
            AddFOWViewer(self:GetCaster():GetTeamNumber(), enemy:GetAbsOrigin(), 200, 1, false)
            self.slash = true
            self.parent:StartGesture(ACT_DOTA_ATTACK_EVENT)
            self.parent:PerformAttack(enemy, true, true, true, true, true, false, false)
            enemy:EmitSound("Hero_Juggernaut.OmniSlash.Damage")


            local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControl(hit_pfx, 0, current_position)
            ParticleManager:SetParticleControl(hit_pfx, 1, current_position)
            ParticleManager:ReleaseParticleIndex(hit_pfx)

            -- Play particle trail when moving
            local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self.parent)
            ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
            ParticleManager:SetParticleControl(trail_pfx, 1, current_position)
            ParticleManager:ReleaseParticleIndex(trail_pfx)

            if self.last_enemy ~= enemy then
                local dash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf", PATTACH_ABSORIGIN, self.parent)
                ParticleManager:SetParticleControl(dash_pfx, 0, previous_position)
                ParticleManager:SetParticleControl(dash_pfx, 2, current_position)
                ParticleManager:ReleaseParticleIndex(dash_pfx)
            end
            self.last_enemy = enemy
            break
        end
    else
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Durov_omni_slash_caster:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return decFuncs
end

function modifier_Durov_omni_slash_caster:GetModifierPreAttack_BonusDamage(kv)
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_Durov_omni_slash_caster:OnDestroy()
    if IsServer() then
        self:GetAbility():SetActivated(true)
        self.parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
        self.parent:MoveToPositionAggressive(self.parent:GetAbsOrigin())
    end
end

function modifier_Durov_omni_slash_caster:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }

    return state
end

LinkLuaModifier("modifier_Durov_DropMoneyInFace_crit_passive", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Durov_DropMoneyInFace_slow", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE)

Durov_DropMoneyInFace = class({})

function Durov_DropMoneyInFace:GetIntrinsicModifierName()
    return "modifier_Durov_DropMoneyInFace_crit_passive"
end

modifier_Durov_DropMoneyInFace_crit_passive = class({})

function modifier_Durov_DropMoneyInFace_crit_passive:IsPurgable() return false end
function modifier_Durov_DropMoneyInFace_crit_passive:IsHidden() return true end

function modifier_Durov_DropMoneyInFace_crit_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_Durov_DropMoneyInFace_crit_passive:OnAttackStart(keys)
    if keys.attacker == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if keys.target:IsOther() then
            return nil
        end
        self.critProc = false
        self.chance = self:GetAbility():GetSpecialValueFor("chance")
        self.crit = self:GetAbility():GetSpecialValueFor("critical")
        self.duration = self:GetAbility():GetSpecialValueFor("duration")
        if self.chance >= RandomInt(1, 100) then
            self:GetParent():StartGesture(ACT_DOTA_ATTACK_EVENT)
            self:GetParent():EmitSound("Hero_Juggernaut.BladeDance")
            local crit_pfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_armor_of_the_favorite_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_pfx)
            self.critProc = true
            return self.crit
        end 
    end
end

function modifier_Durov_DropMoneyInFace_crit_passive:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    if self.critProc == true then
        return self.crit
    else
        return nil
    end
end

function modifier_Durov_DropMoneyInFace_crit_passive:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self.critProc == true then
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_Durov_DropMoneyInFace_slow", {duration = self.duration})
            self.critProc = false
        end
    end
end

modifier_Durov_DropMoneyInFace_slow = class({})

function modifier_Durov_DropMoneyInFace_slow:IsPurgable()
    return true
end

function modifier_Durov_DropMoneyInFace_slow:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_Durov_DropMoneyInFace_slow:GetEffectName()
    return "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_projectile.vpcf"
end

function modifier_Durov_DropMoneyInFace_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Durov_DropMoneyInFace_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_Durov_DropMoneyInFace_slow:GetModifierMoveSpeedBonus_Percentage()
    return -100
end

LinkLuaModifier( "modifier_Durov_Vpn_buff", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )

Durov_Vpn = class({})

function Durov_Vpn:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_Durov_Vpn_buff', {duration = duration})
    self:GetCursorTarget():EmitSound("Hero_Magnataur.Empower.Cast")
    self:GetCursorTarget():EmitSound("Hero_Magnataur.Empower.Target")
end

modifier_Durov_Vpn_buff = class({})

function modifier_Durov_Vpn_buff:IsPurgable() return false end

function modifier_Durov_Vpn_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_Durov_Vpn_buff:GetModifierBaseDamageOutgoing_Percentage()
    if self:GetCaster():IsRealHero() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
    end
    return 0
end

function modifier_Durov_Vpn_buff:GetEffectName()
    return "particles/durov/durov_vpn.vpcf"
end

function modifier_Durov_Vpn_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Durov_Vpn_buff:OnCreated()
    if not IsServer() then return end
    self.percent = 20
    if self:GetParent():GetPrimaryAttribute() == 0 then
        self.attribute_bonus = self:GetParent():GetStrength() / 100 * self.percent
    elseif self:GetParent():GetPrimaryAttribute() == 1 then
        self.attribute_bonus = self:GetParent():GetAgility() / 100 * self.percent
    elseif self:GetParent():GetPrimaryAttribute() == 2 then
        self.attribute_bonus = self:GetParent():GetIntellect() / 100 * self.percent
    end
end

function modifier_Durov_Vpn_buff:GetModifierBonusStats_Strength()
    if not self:GetCaster():HasShard() then return end
    if self:GetParent():GetPrimaryAttribute() == 0 then
        return self.attribute_bonus
    end
    return 0
end

function modifier_Durov_Vpn_buff:GetModifierBonusStats_Agility()
    if not self:GetCaster():HasShard() then return end
    if self:GetParent():GetPrimaryAttribute() == 1 then
        return self.attribute_bonus
    end
    return 0
end

function modifier_Durov_Vpn_buff:GetModifierBonusStats_Intellect()
    if not self:GetCaster():HasShard() then return end
    if self:GetParent():GetPrimaryAttribute() == 2 then
        return self.attribute_bonus
    end
    return 0
end
