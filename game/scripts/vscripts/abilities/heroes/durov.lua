LinkLuaModifier( "modifier_Durov_AttackOnPoliceman", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Durov_AttackOnPoliceman_debuff", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )

Durov_AttackOnPoliceman = class({})

function Durov_AttackOnPoliceman:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_omnislash.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_armor_of_the_favorite_crit.vpcf", context)
    PrecacheResource("particle", "particles/econ/courier/courier_flopjaw_gold/flopjaw_death_gold.vpcf", context)
    PrecacheResource("particle", "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf", context)
    PrecacheResource("particle", "particles/durov/durov_vpn.vpcf", context)
end

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
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_2")
end

function Durov_AttackOnPoliceman:OnOwnerDied()
    if not self:IsActivated() then
        self:SetActivated(true)
    end
end

function Durov_AttackOnPoliceman:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_durov_7" )
end

function Durov_AttackOnPoliceman:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local disarmed = self:GetCaster():IsDisarmed()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local original_direction = (caster:GetAbsOrigin() - target_loc):Normalized()
    local effect_radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_2")
    local attack_interval = self:GetSpecialValueFor("attack_cooldown")
    local sleight_targets = {}
    
    caster:EmitSound("Hero_EmberSpirit.SleightOfFist.Cast")
    
    local cast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(cast_pfx, 0, target_loc)
    ParticleManager:SetParticleControl(cast_pfx, 1, Vector(effect_radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(cast_pfx)

    local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_loc, nil, effect_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    for _,enemy in pairs(nearby_enemies) do
        if enemy:GetUnitName() ~= "npc_dota_face_zombie" then
            table.insert(sleight_targets, enemy)
            enemy:AddNewModifier(caster, self, "modifier_Durov_AttackOnPoliceman_debuff", {duration = (#sleight_targets - 1) * attack_interval})
        end
    end

    if #sleight_targets > 0 then
        local duration = #sleight_targets * attack_interval
        local modifier_Durov_AttackOnPoliceman = caster:AddNewModifier(caster, self, "modifier_Durov_AttackOnPoliceman", {duration = duration + 0.1, dir_x = original_direction.x, dir_y = original_direction.y})
        if modifier_Durov_AttackOnPoliceman then
            modifier_Durov_AttackOnPoliceman.heroes = sleight_targets
            modifier_Durov_AttackOnPoliceman:Start()
        end
    end
end

modifier_Durov_AttackOnPoliceman_debuff = class({})
function modifier_Durov_AttackOnPoliceman_debuff:IsDebuff() return true end
function modifier_Durov_AttackOnPoliceman_debuff:IsHidden() return true end
function modifier_Durov_AttackOnPoliceman_debuff:IsPurgable() return false end
function modifier_Durov_AttackOnPoliceman_debuff:GetEffectName()
    return "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf"
end
function modifier_Durov_AttackOnPoliceman_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_Durov_AttackOnPoliceman = class({})
function modifier_Durov_AttackOnPoliceman:IsPurgable() return false end
function modifier_Durov_AttackOnPoliceman:OnCreated(params)
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_CUSTOMORIGIN_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlForward(self.particle, 1, self:GetParent():GetForwardVector())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self.dir_x = params.dir_x
    self.dir_y = params.dir_y
    self:GetParent():AddNoDraw()
    self.loc = self:GetParent():GetAbsOrigin()
    self.heroes = {}
    self.current_count = 0
    self.attack_interval = self:GetAbility():GetSpecialValueFor("attack_cooldown")
    self:GetAbility():SetActivated(false)
    local Durov_omni_slash = self:GetCaster():FindAbilityByName("Durov_omni_slash")
    if Durov_omni_slash then
        Durov_omni_slash:SetActivated(false)
    end
end

function modifier_Durov_AttackOnPoliceman:Start()
    if not IsServer() then return end
    self:StartIntervalThink(self.attack_interval)
    self:OnIntervalThink()
end

function modifier_Durov_AttackOnPoliceman:OnIntervalThink()
    if not IsServer() then return end
    self.current_count = self.current_count + 1
    local previous_position = self:GetParent():GetAbsOrigin()
    local current_target = self.heroes[self.current_count]
    if current_target and not current_target:IsNull() and current_target:IsAlive() and not (current_target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(current_target)) and not current_target:IsAttackImmune() then
        self:GetParent():EmitSound("Hero_EmberSpirit.SleightOfFist.Damage")
        local slash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, current_target)
        ParticleManager:SetParticleControl(slash_pfx, 0, current_target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(slash_pfx)
        --------------------------------------------------
        local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(trail_pfx, 0, current_target:GetAbsOrigin())
        ParticleManager:SetParticleControl(trail_pfx, 1, previous_position)
        ParticleManager:ReleaseParticleIndex(trail_pfx)
        --------------------------------------------------
        self:GetParent():SetAbsOrigin(current_target:GetAbsOrigin() + Vector(self.dir_x, self.dir_y, 0) * 64)
        self:GetParent():PerformAttack(current_target, true, true, true, false, false, false, false)
    else
        local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(trail_pfx, 0, self.loc)
        ParticleManager:SetParticleControl(trail_pfx, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(trail_pfx) 

        FindClearSpaceForUnit(self:GetParent(), self.loc, true)

        for _, target in pairs(self.heroes) do
            if target and not target:IsNull() then
                target:RemoveModifierByName("modifier_Durov_AttackOnPoliceman_debuff")
            end
        end

        self:Destroy()
    end
end

function modifier_Durov_AttackOnPoliceman:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveNoDraw()
        self:GetAbility():SetActivated(true)
        local Durov_omni_slash = self:GetCaster():FindAbilityByName("Durov_omni_slash")
        if Durov_omni_slash then
            Durov_omni_slash:SetActivated(true)
        end
    end
end

function modifier_Durov_AttackOnPoliceman:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

function modifier_Durov_AttackOnPoliceman:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
    }
    return funcs
end

function modifier_Durov_AttackOnPoliceman:GetModifierPreAttack_BonusDamage(keys)
    if IsClient() then return 0 end
    return self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_5")
end

function modifier_Durov_AttackOnPoliceman:GetModifierIgnoreCastAngle()
    return 1
end























LinkLuaModifier("modifier_Durov_omni_slash_caster", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE)

Durov_omni_slash = class({})

function Durov_omni_slash:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
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
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    self.previous_position = self.caster:GetAbsOrigin()
    if self.target:TriggerSpellAbsorb(self) then return end
    self.duration = self:GetSpecialValueFor("duration")

    local omnislash_modifier_handler = self.caster:AddNewModifier(self.caster, self, "modifier_Durov_omni_slash_caster", {duration = self.duration})
    if omnislash_modifier_handler then
        omnislash_modifier_handler.original_caster = self.caster
    end

    self:SetActivated(false)

    local Durov_AttackOnPoliceman = self:GetCaster():FindAbilityByName("Durov_AttackOnPoliceman")
    if Durov_AttackOnPoliceman then
        Durov_AttackOnPoliceman:SetActivated(false)
    end

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
    self.base_bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_3")
    self.last_enemy = nil
    self.slash = true

    if not IsServer() then return end
    Timers:CreateTimer(FrameTime(), function()
        if (not self.parent:IsNull()) then
            self.bounce_range = self:GetAbility():GetSpecialValueFor("omni_slash_radius")
            self.hero_agility = self.original_caster:GetAgility()
            self:GetAbility():SetRefCountsModifiers(false)
            self:BounceAndSlaughter(true)
            local slash_rate = (1 / ( self.caster:GetAttackSpeed(true) * (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier")+ self:GetCaster():FindTalentValue("special_bonus_birzha_durov_1"), 1))))
            self:StartIntervalThink(slash_rate)
        end
    end)
end

function modifier_Durov_omni_slash_caster:OnIntervalThink()
    self.hero_agility = self.original_caster:GetAgility()
    self:BounceAndSlaughter()
    local slash_rate = (1 / ( self.caster:GetAttackSpeed(true) * (math.max(self:GetAbility():GetSpecialValueFor("attack_rate_multiplier")+ self:GetCaster():FindTalentValue("special_bonus_birzha_durov_1"), 1))))
    self:StartIntervalThink(-1)
    self:StartIntervalThink(slash_rate)
end

function modifier_Durov_omni_slash_caster:BounceAndSlaughter(first_slash)
    local order = FIND_ANY_ORDER
    if first_slash then
        order = FIND_CLOSEST
    end
    
    self.nearby_enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.bounce_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, order, false )
    
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
            ParticleManager:SetParticleControlEnt( hit_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true )
            ParticleManager:SetParticleControl(hit_pfx, 1, current_position)
            ParticleManager:ReleaseParticleIndex(hit_pfx)

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

function modifier_Durov_omni_slash_caster:StatusEffectPriority()
    return 20
end

function modifier_Durov_omni_slash_caster:GetStatusEffectName()
    return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_Durov_omni_slash_caster:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return decFuncs
end

function modifier_Durov_omni_slash_caster:GetModifierPreAttack_BonusDamage(kv)
    if IsClient() then
        return 0
    end
    return self.base_bonus_damage
end

function modifier_Durov_omni_slash_caster:OnDestroy()
    if IsServer() then
        self:GetAbility():SetActivated(true)
        local Durov_AttackOnPoliceman = self:GetCaster():FindAbilityByName("Durov_AttackOnPoliceman")
        if Durov_AttackOnPoliceman then
            Durov_AttackOnPoliceman:SetActivated(true)
        end
        self.parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
        self.parent:MoveToPositionAggressive(self.parent:GetAbsOrigin())
    end
end

function modifier_Durov_omni_slash_caster:CheckState()
    local state = 
    {
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
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_Durov_DropMoneyInFace_crit_passive:OnCreated()
    if not IsServer() then return end
    self.record = nil
end

function modifier_Durov_DropMoneyInFace_crit_passive:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():PassivesDisabled() then return end
    if params.target:IsWard() then return end
    
    local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_8")
    local min_crit = self:GetAbility():GetSpecialValueFor("min_crit")
    local max_crit = self:GetAbility():GetSpecialValueFor("max_crit")

    if RollPercentage(chance) then
        self.record = params.record
        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed(true))
        local crit_pfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_armor_of_the_favorite_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(crit_pfx)
        return RandomInt(min_crit, max_crit)
    end
end

function modifier_Durov_DropMoneyInFace_crit_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.record ~= self.record then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    self:GetParent():EmitSound("Hero_Juggernaut.BladeDance")
    local crit_pfx = ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/flopjaw_death_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
    ParticleManager:SetParticleControl(crit_pfx, 0, params.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(crit_pfx, 1, params.target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(crit_pfx)
    params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_Durov_DropMoneyInFace_slow", {duration = duration * (1 - params.target:GetStatusResistance()) })
    params.target:EmitSound("General.Sell")
end

modifier_Durov_DropMoneyInFace_slow = class({})

function modifier_Durov_DropMoneyInFace_slow:IsPurgable()
    return true
end

function modifier_Durov_DropMoneyInFace_slow:GetEffectName()
    return "particles/econ/courier/courier_flopjaw_gold/courier_flopjaw_ambient_gold.vpcf"
end

function modifier_Durov_DropMoneyInFace_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Durov_DropMoneyInFace_slow:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_Durov_DropMoneyInFace_slow:GetModifierMoveSpeedBonus_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("tooltip_slow")
    end
end

LinkLuaModifier( "modifier_Durov_Vpn_buff", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Durov_Vpn_buff_illusion", "abilities/heroes/durov.lua", LUA_MODIFIER_MOTION_NONE )

Durov_Vpn = class({})

function Durov_Vpn:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_4")
    self:GetCaster():RemoveModifierByName("modifier_Durov_Vpn_buff")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_Durov_Vpn_buff', {duration = duration})
    self:GetCaster():EmitSound("Hero_Magnataur.Empower.Cast")
    self:GetCaster():EmitSound("Hero_Magnataur.Empower.Target")
end

modifier_Durov_Vpn_buff = class({})

function modifier_Durov_Vpn_buff:IsPurgable() return false end

function modifier_Durov_Vpn_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_Durov_Vpn_buff:GetEffectName()
    return "particles/durov/durov_vpn.vpcf"
end

function modifier_Durov_Vpn_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Durov_Vpn_buff:OnCreated()
    if not IsServer() then return end
    self.percent = self:GetAbility():GetSpecialValueFor("shard_attribute")
    if self:GetParent():GetPrimaryAttribute() == 0 then
        self.attribute_bonus = self:GetParent():GetStrength() / 100 * self.percent
    elseif self:GetParent():GetPrimaryAttribute() == 1 then
        self.attribute_bonus = self:GetParent():GetAgility() / 100 * self.percent
    elseif self:GetParent():GetPrimaryAttribute() == 2 then
        self.attribute_bonus = self:GetParent():GetIntellect(false) / 100 * self.percent
    end

    local damage = self:GetAbility():GetSpecialValueFor("damage") - 100 + self:GetCaster():FindTalentValue("special_bonus_birzha_durov_6")

    self.illusions = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=self:GetDuration(),outgoing_damage=damage,incoming_damage=0}, 2, 1, false, false ) 

    for k, illusion in pairs(self.illusions) do
        illusion:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Durov_Vpn_buff_illusion", {})
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_Durov_Vpn_buff:OnDestroy()
    if not IsServer() then return end
    for k, illusion in pairs(self.illusions) do
        illusion:ForceKill(false)
    end
end

function modifier_Durov_Vpn_buff:OnIntervalThink()
    if not IsServer() then return end
    if self.illusions[1] then
        local origin = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetRightVector() * 100
        self.illusions[1]:SetAbsOrigin(origin)
        self.illusions[1]:SetForwardVector(self:GetCaster():GetForwardVector())
    end
    if self.illusions[2] then
        local origin = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetLeftVector() * 100
        self.illusions[2]:SetAbsOrigin(origin)
        self.illusions[2]:SetForwardVector(self:GetCaster():GetForwardVector())
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

modifier_Durov_Vpn_buff_illusion = class({})

function modifier_Durov_Vpn_buff_illusion:IsPurgable() return false end
function modifier_Durov_Vpn_buff_illusion:IsHidden() return true end

function modifier_Durov_Vpn_buff_illusion:OnCreated()
    if not IsServer() then return end
    self.move = false
    self:StartIntervalThink(FrameTime())
end

function modifier_Durov_Vpn_buff_illusion:OnIntervalThink()
    local nearby_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange()+50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
    if #nearby_enemies > 0 then
        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, self:GetParent():GetAttackSpeed(true)*1.2)
        self:GetParent():PerformAttack(nearby_enemies[1], true, true, false, false, false, false, false)
        self.move = false
    elseif self:GetCaster():IsMoving() then
        if not self.move then
            self:GetParent():RemoveGesture(ACT_DOTA_IDLE)
            self:GetParent():StartGesture(ACT_DOTA_RUN)
            self.move = true
        end
    else
        self:GetParent():StartGesture(ACT_DOTA_IDLE)
        self.move = false
    end

    if self:GetCaster():HasModifier("modifier_Durov_AttackOnPoliceman") or self:GetCaster():HasModifier("modifier_Durov_omni_slash_caster") then
        self:GetParent():AddNoDraw()
    else
        self:GetParent():RemoveNoDraw()
    end
end

function modifier_Durov_Vpn_buff_illusion:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end