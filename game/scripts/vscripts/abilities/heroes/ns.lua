LinkLuaModifier( "modifier_ns_tricks_damage", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_teleportation", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_bonus_damage", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_cast_range", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_abilities_fast_cooldown", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_items_fast_cooldown", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_attack_speed", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_movespeed", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_magic_immune", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_invulnerable", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_silenced", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_stunned", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_slow_movespeed", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_muted_items", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_passive_disabled", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_damage_debuff", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_cast_range_debuff", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_item_cooldown", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_ability_cooldown", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_attack_speed_cooldown", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ns_tricks_armor_debuff", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )

Ns_Tricks = class({})

function Ns_Tricks:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ns_3")
end

function Ns_Tricks:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ns_Tricks:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ns_Tricks:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasTalent("special_bonus_birzha_ns_1")) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end
    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter( hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end

function Ns_Tricks:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local info = 
    {
        EffectName = "particles/ns/ns_tricks.vpcf",
        Ability = self,
        iMoveSpeed = 800,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("xzns")
end

function Ns_Tricks:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:TriggerSpellAbsorb( self ) ) then
        local modifiers_friendly = 
        {
            "modifier_ns_tricks_teleportation",
            "modifier_ns_tricks_bonus_damage",
            "modifier_ns_tricks_cast_range",
            "modifier_ns_tricks_abilities_fast_cooldown",
            "modifier_ns_tricks_items_fast_cooldown",
            "modifier_ns_tricks_attack_speed",
            "modifier_ns_tricks_movespeed",
            "modifier_ns_tricks_magic_immune",
            "modifier_ns_tricks_invulnerable",
        }

        local modifiers_enemy = 
        {
            "modifier_ns_tricks_silenced",
            "modifier_ns_tricks_stunned",
            "modifier_ns_tricks_slow_movespeed",
            "modifier_ns_tricks_muted_items",
            "modifier_ns_tricks_passive_disabled",
            "modifier_ns_tricks_damage_debuff",
            "modifier_ns_tricks_cast_range_debuff",
            "modifier_ns_tricks_item_cooldown",
            "modifier_ns_tricks_ability_cooldown",
            "modifier_ns_tricks_attack_speed_cooldown",
            "modifier_ns_tricks_armor_debuff",
        }

        local damage_min = self:GetSpecialValueFor("damage_min")
        local damage_max = self:GetSpecialValueFor("damage_max")
        local duration = self:GetSpecialValueFor("duration")

        if target:IsBoss() then return end

        if not self:GetCaster():HasTalent("special_bonus_birzha_ns_1") then
            if target:IsMagicImmune() then return end
        end

        if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
            local damage = RandomInt(damage_min, damage_max)
            if self:GetCaster():HasTalent("special_bonus_birzha_ns_2") then
                damage = damage_max
            end
            ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
        end

        if self:GetCaster():HasTalent("special_bonus_birzha_ns_4") then
            if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
                local modifier = modifiers_friendly[RandomInt(1, #modifiers_friendly)]
                target:AddNewModifier( self:GetCaster(), self, modifier, { duration = duration } )  
            else
                local modifier = modifiers_enemy[RandomInt(1, #modifiers_enemy)]
                target:AddNewModifier( self:GetCaster(), self, modifier, { duration = duration } )  
            end
        else
            if RollPercentage(50) then
                local modifier = modifiers_friendly[RandomInt(1, #modifiers_friendly)]
                target:AddNewModifier( self:GetCaster(), self, modifier, { duration = duration } )  
            else
                local modifier = modifiers_enemy[RandomInt(1, #modifiers_enemy)]
                target:AddNewModifier( self:GetCaster(), self, modifier, { duration = duration } )  
            end
        end
    end

    return true
end

modifier_ns_tricks_teleportation = class({})
function modifier_ns_tricks_teleportation:IsDebuff() return false end
function modifier_ns_tricks_teleportation:OnCreated()
    if not IsServer() then return end
    local particle_one = ParticleManager:CreateParticle( "particles/items_fx/blink_dagger_start.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( particle_one, 0, self:GetParent():GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( particle_one )
    local origin = self:GetParent():GetAbsOrigin() + RandomVector(RandomInt(100, 500))
    FindClearSpaceForUnit(self:GetParent(), origin, true)
    local particle_two = ParticleManager:CreateParticle( "particles/items_fx/blink_dagger_end.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetParent():GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    self:Destroy()
end

modifier_ns_tricks_bonus_damage = class({})
function modifier_ns_tricks_bonus_damage:IsDebuff() return false end
function modifier_ns_tricks_bonus_damage:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end
function modifier_ns_tricks_bonus_damage:GetModifierDamageOutgoing_Percentage()
    return 50
end
function modifier_ns_tricks_bonus_damage:GetEffectName()
    return "particles/neutral_fx/wolf_intimidate_howl_cast_dmg_debuff.vpcf"
end

modifier_ns_tricks_cast_range = class({})
function modifier_ns_tricks_cast_range:IsDebuff() return false end
function modifier_ns_tricks_cast_range:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
    }
end
function modifier_ns_tricks_cast_range:GetModifierCastRangeBonusStacking(params)
    if params.ability then
        if params.ability.GetCastRange then
            local new = params.ability:GetCastRange(params.ability:GetCaster():GetAbsOrigin(), params.ability:GetCaster()) + self:GetParent():GetCastRangeBonus()
            if new > 0 then
                return (new * 0.5)
            end
        end
    end
end

modifier_ns_tricks_abilities_fast_cooldown = class({})
function modifier_ns_tricks_abilities_fast_cooldown:IsDebuff() return false end
function modifier_ns_tricks_abilities_fast_cooldown:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end
function modifier_ns_tricks_abilities_fast_cooldown:OnIntervalThink()
    if not IsServer() then return end
    for i = 1, 30 do
        local hAbility = self:GetParent():GetAbilityByIndex(i - 1)
        if hAbility and hAbility.GetCooldownTimeRemaining then
            local flRemaining = hAbility:GetCooldownTimeRemaining()
            if 0.1 < flRemaining then
               hAbility:EndCooldown()
               hAbility:StartCooldown(flRemaining-0.1)
            end
        end
    end
end

modifier_ns_tricks_items_fast_cooldown = class({})
function modifier_ns_tricks_items_fast_cooldown:IsDebuff() return false end
function modifier_ns_tricks_items_fast_cooldown:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end
function modifier_ns_tricks_items_fast_cooldown:OnIntervalThink()
    if not IsServer() then return end
    for i = 0, 5 do
        local hAbility = self:GetParent():GetItemInSlot(i)
        if hAbility and hAbility.GetCooldownTimeRemaining then
            local flRemaining = hAbility:GetCooldownTimeRemaining()
            if 0.1 < flRemaining then
               hAbility:EndCooldown()
               hAbility:StartCooldown(flRemaining-0.1)
            end
        end
    end
end

modifier_ns_tricks_attack_speed = class({})
function modifier_ns_tricks_attack_speed:IsDebuff() return false end
function modifier_ns_tricks_attack_speed:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
    }
end

function modifier_ns_tricks_attack_speed:GetModifierAttackSpeedPercentage()
    return 50
end
function modifier_ns_tricks_attack_speed:GetEffectName()
    return "particles/items2_fx/mask_of_madness.vpcf"
end

modifier_ns_tricks_movespeed = class({})
function modifier_ns_tricks_movespeed:IsDebuff() return false end
function modifier_ns_tricks_movespeed:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE 
    }
end
function modifier_ns_tricks_movespeed:GetModifierMoveSpeedOverride()
    return 550
end
function modifier_ns_tricks_movespeed:GetEffectName()
    return "particles/generic_gameplay/rune_haste.vpcf"
end

modifier_ns_tricks_magic_immune = class({})
function modifier_ns_tricks_magic_immune:IsDebuff() return false end
function modifier_ns_tricks_magic_immune:CheckState()
    return
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_ns_tricks_magic_immune:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_ns_tricks_magic_immune:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ns_tricks_magic_immune:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_ns_tricks_magic_immune:StatusEffectPriority()
    return 99999
end

modifier_ns_tricks_invulnerable = class({})
function modifier_ns_tricks_invulnerable:IsDebuff() return false end
function modifier_ns_tricks_invulnerable:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true
    }
end

modifier_ns_tricks_silenced = class({})
function modifier_ns_tricks_silenced:IsDebuff() return true end
function modifier_ns_tricks_silenced:CheckState()
    return
    {
        [MODIFIER_STATE_SILENCED] = true
    }
end
function modifier_ns_tricks_silenced:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_ns_tricks_silenced:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_ns_tricks_stunned = class({})
function modifier_ns_tricks_stunned:IsDebuff() return true end
function modifier_ns_tricks_stunned:CheckState()
    return
    {
        [MODIFIER_STATE_STUNNED] = true
    }
end
function modifier_ns_tricks_stunned:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_ns_tricks_stunned:GetOverrideAnimation( params )
    return ACT_DOTA_DISABLED
end

function modifier_ns_tricks_stunned:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_ns_tricks_stunned:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_ns_tricks_slow_movespeed = class({})
function modifier_ns_tricks_slow_movespeed:IsDebuff() return true end
function modifier_ns_tricks_slow_movespeed:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_ns_tricks_slow_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return -50
end

modifier_ns_tricks_muted_items = class({})
function modifier_ns_tricks_muted_items:IsDebuff() return true end
function modifier_ns_tricks_muted_items:CheckState()
    return
    {
        [MODIFIER_STATE_MUTED] = true
    }
end
function modifier_ns_tricks_muted_items:GetEffectName()
    return "particles/generic_gameplay/generic_muted.vpcf"
end

function modifier_ns_tricks_muted_items:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_ns_tricks_passive_disabled = class({})
function modifier_ns_tricks_passive_disabled:IsDebuff() return true end
function modifier_ns_tricks_passive_disabled:CheckState()
    return
    {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true
    }
end
function modifier_ns_tricks_passive_disabled:GetEffectName()
    return "particles/generic_gameplay/generic_break.vpcf"
end

function modifier_ns_tricks_passive_disabled:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_ns_tricks_damage_debuff = class({})
function modifier_ns_tricks_damage_debuff:IsDebuff() return true end
function modifier_ns_tricks_damage_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end
function modifier_ns_tricks_damage_debuff:GetModifierDamageOutgoing_Percentage()
    return -50
end
function modifier_ns_tricks_damage_debuff:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end

modifier_ns_tricks_cast_range_debuff = class({})
function modifier_ns_tricks_cast_range_debuff:IsDebuff() return true end
function modifier_ns_tricks_cast_range_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
    }
end
function modifier_ns_tricks_cast_range_debuff:GetModifierCastRangeBonusStacking(params)
    if params.ability then
        if params.ability.GetCastRange then
            local new = params.ability:GetCastRange(params.ability:GetCaster():GetAbsOrigin(), params.ability:GetCaster()) + self:GetParent():GetCastRangeBonus()
            if new > 0 then
                return (new * 0.5)*-1
            end
        end
    end
end

modifier_ns_tricks_item_cooldown = class({})
function modifier_ns_tricks_item_cooldown:IsDebuff() return true end
function modifier_ns_tricks_item_cooldown:OnCreated()
    if not IsServer() then return end
    for i=0,5 do
        local item = self:GetParent():GetItemInSlot(i)
        if item and item:GetCooldown(item:GetLevel()) > 0 then
            item:UseResources(false, false, false, true)
        end
    end
    self:Destroy()
end

modifier_ns_tricks_ability_cooldown = class({})
function modifier_ns_tricks_ability_cooldown:IsDebuff() return true end
function modifier_ns_tricks_ability_cooldown:OnCreated()
    if not IsServer() then return end
    for i=0,8 do
        local ability = self:GetParent():GetAbilityByIndex(i)
        if ability and ability:GetLevel() > 0 and ability:GetCooldown(ability:GetLevel()) > 0 then
            ability:UseResources(false, false, false, true)
        end
    end
    self:Destroy()
end

modifier_ns_tricks_attack_speed_cooldown = class({})
function modifier_ns_tricks_attack_speed_cooldown:IsDebuff() return true end
function modifier_ns_tricks_attack_speed_cooldown:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
    }
end

function modifier_ns_tricks_attack_speed_cooldown:GetModifierAttackSpeedPercentage()
    return -50
end
function modifier_ns_tricks_attack_speed_cooldown:GetEffectName()
    return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_ns_tricks_attack_speed_cooldown:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_ns_tricks_armor_debuff = class({})
function modifier_ns_tricks_armor_debuff:IsDebuff() return true end
function modifier_ns_tricks_armor_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR
    }
end 
function modifier_ns_tricks_armor_debuff:GetModifierIgnorePhysicalArmor()
    return 1
end
function modifier_ns_tricks_armor_debuff:GetEffectName()
    return "particles/units/heroes/hero_monkey_king/monkey_king_jump_armor_debuff.vpcf"
end

function modifier_ns_tricks_armor_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier( "modifier_ns_fullcounter_debuff", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )

Ns_FullCounter = class({})

function Ns_FullCounter:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ns_FullCounter:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ns_FullCounter:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ns_FullCounter:OnSpellStart()
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local info = 
    {
        EffectName = "particles/econ/items/wisp/wisp_tether_ti7.vpcf",
        Ability = self,
        iMoveSpeed = 2000,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
end

function Ns_FullCounter:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:TriggerSpellAbsorb( self ) ) then
        if target:IsMagicImmune() then return end
        local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_ns_6")
        self:GetCaster():EmitSound("kontra")
        target:AddNewModifier( self:GetCaster(), self, "modifier_ns_fullcounter_debuff", { duration = duration * (1 - target:GetStatusResistance()) } ) 
    end
    return true
end

modifier_ns_fullcounter_debuff = class({})

function modifier_ns_fullcounter_debuff:IsPurgable() return false end

function modifier_ns_fullcounter_debuff:CheckState()
    if self:GetCaster():HasTalent("special_bonus_birzha_ns_8") then
        return 
        {
            [MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_PASSIVES_DISABLED] = true,
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_EVADE_DISABLED] = true,
            [MODIFIER_STATE_NIGHTMARED] = true,
            [MODIFIER_STATE_STUNNED] = true
        }
    end
    return 
    {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_EVADE_DISABLED] = true,
        [MODIFIER_STATE_NIGHTMARED] = true
    }
end


function modifier_ns_fullcounter_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
    return funcs
end

function modifier_ns_fullcounter_debuff:GetModifierMagicalResistanceBonus( params )
    return self:GetAbility():GetSpecialValueFor("magic")
end

function modifier_ns_fullcounter_debuff:GetModifierPhysicalArmorBonus( params )
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_ns_fullcounter_debuff:GetBonusDayVision( params )
    return -9999999
end

function modifier_ns_fullcounter_debuff:GetBonusNightVision( params )
    return -9999999
end

LinkLuaModifier("modifier_ns_TricksMaster", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE)

Ns_TricksMaster = class({}) 

function Ns_TricksMaster:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ns_TricksMaster:GetIntrinsicModifierName()
    return "modifier_ns_TricksMaster"
end

modifier_ns_TricksMaster = class({})

function modifier_ns_TricksMaster:IsPurchasable()
    return false
end

function modifier_ns_TricksMaster:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_ns_TricksMaster:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources(false, false, false, true)
        local bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
        self:SetStackCount(self:GetStackCount() + bonus_intellect)
        self:GetParent():CalculateStatBonus(false)
    end
end

function modifier_ns_TricksMaster:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_ns_TricksMaster:GetModifierBonusStats_Intellect( params )
    if self:GetCaster():HasTalent("special_bonus_birzha_ns_7") then
        return self:GetStackCount() * self:GetCaster():FindTalentValue("special_bonus_birzha_ns_7") 
    end
    return self:GetStackCount()
end

LinkLuaModifier( "modifier_ns_old_beer_orb", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE )

ns_old_beer = class({})

function ns_old_beer:GetIntrinsicModifierName()
    return "modifier_ns_old_beer_orb"
end

function ns_old_beer:GetCastRange(vLocation, hTarget)
    return self:GetCaster():Script_GetAttackRange() + 50
end

function ns_old_beer:OnOrbImpact( params )
    local target = params.target
    if target:IsMagicImmune() then return end

    if self:GetCaster():HasShard() and not params.no_attack_cooldown then
        local modifier_ns_old_beer_orb = self:GetCaster():FindModifierByName("modifier_ns_old_beer_orb")
        if modifier_ns_old_beer_orb then
            if modifier_ns_old_beer_orb:GetStackCount() >= self:GetSpecialValueFor("attack_count_shard") - 1 then
                modifier_ns_old_beer_orb:SetStackCount(0)
                target:AddNewModifier(self:GetCaster(), self, "modifier_silence", {duration = self:GetSpecialValueFor("silence_shard_duration")})
            else
                modifier_ns_old_beer_orb:IncrementStackCount()
            end
        end
    end

    local glaive_pure_damage = self:GetCaster():GetIntellect(false) * (self:GetSpecialValueFor("intellect_damage_pct") + self:GetCaster():FindTalentValue("special_bonus_birzha_ns_5")) / 100
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, glaive_pure_damage, nil)
    ApplyDamage( { victim = target, attacker = self:GetCaster(), damage = glaive_pure_damage, damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self } )

    if self:GetCaster():HasScepter() and not params.no_attack_cooldown then
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
        if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
                if enemy and enemy ~= target and not enemy:IsAttackImmune() then
                    local projectile_info = 
                    {
                        Target = enemy,
                        Source = target,
                        Ability = self,
                        EffectName = "particles/rubick_willowisp_base_attack.vpcf",
                        bDodgable = true,
                        bProvidesVision = false,
                        bVisibleToEnemies = true,
                        bReplaceExisting = false,
                        iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
                        bIsAttack = false,
                        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                     }
                    ProjectileManager:CreateTrackingProjectile(projectile_info)
                    break
                end
            end
        end
    end
end

function ns_old_beer:OnProjectileHit(target, location)
    if not target then
        return
    end
    self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
    self:OnOrbImpact( {no_attack_cooldown = true, target = target, scepter = 1} )
end

modifier_ns_old_beer_orb = class({})

function modifier_ns_old_beer_orb:IsHidden()
    return not self:GetCaster():HasShard()
end

function modifier_ns_old_beer_orb:IsDebuff()
    return false
end

function modifier_ns_old_beer_orb:IsPurgable()
    return false
end

function modifier_ns_old_beer_orb:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_ns_old_beer_orb:OnCreated( kv )
    self.ability = self:GetAbility()
    self.cast = false
    self.records = {}
end

function modifier_ns_old_beer_orb:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_EVENT_ON_ATTACK
    }

    return funcs
end

function modifier_ns_old_beer_orb:OnAttack( params )
    if params.attacker~=self:GetParent() then return end
    if params.no_attack_cooldown then return end
    if self:ShouldLaunch( params.target ) then
        self.ability:UseResources( true, false, false, true )
        self.records[params.record] = true
        if self.ability.OnOrbFire then self.ability:OnOrbFire( params ) end
    end

    self.cast = false
end

function modifier_ns_old_beer_orb:GetModifierProcAttack_Feedback( params )
    if self.records[params.record] then
        if self.ability.OnOrbImpact then self.ability:OnOrbImpact( params ) end
    end
end
function modifier_ns_old_beer_orb:OnAttackFail( params )
    if self.records[params.record] then
        if self.ability.OnOrbFail then self.ability:OnOrbFail( params ) end
    end
end
function modifier_ns_old_beer_orb:OnAttackRecordDestroy( params )
    self.records[params.record] = nil
end

function modifier_ns_old_beer_orb:OnOrder( params )
    if params.unit~=self:GetParent() then return end

    if params.ability then
        if params.ability==self:GetAbility() then
            self.cast = true
            return
        end
        local pass = false
        local behavior = params.ability:GetBehaviorInt()
        if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL ) or 
            self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT ) or
            self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL )
        then
            local pass = true -- do nothing
        end

        if self.cast and (not pass) then
            self.cast = false
        end
    else
        if self.cast then
            if self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_POSITION ) or
                self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_TARGET ) or
                self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_MOVE ) or
                self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_TARGET ) or
                self:FlagExist( params.order_type, DOTA_UNIT_ORDER_STOP ) or
                self:FlagExist( params.order_type, DOTA_UNIT_ORDER_HOLD_POSITION )
            then
                self.cast = false
            end
        end
    end
end

function modifier_ns_old_beer_orb:GetModifierProjectileName()
    if self:ShouldLaunch( self:GetCaster():GetAggroTarget() ) then
        return "particles/rubick_willowisp_base_attack.vpcf"
    end
end

function modifier_ns_old_beer_orb:ShouldLaunch( target )
    if self.ability:GetAutoCastState() then
        if self.ability.CastFilterResultTarget~=CDOTA_Ability_Lua.CastFilterResultTarget then
            if self.ability:CastFilterResultTarget( target )==UF_SUCCESS then
                self.cast = true
            end
        else
            local nResult = UnitFilter(
                target,
                self.ability:GetAbilityTargetTeam(),
                self.ability:GetAbilityTargetType(),
                self.ability:GetAbilityTargetFlags(),
                self:GetCaster():GetTeamNumber()
            )
            if nResult == UF_SUCCESS then
                self.cast = true
            end
        end
    end

    if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
        return true
    end

    return false
end

function modifier_ns_old_beer_orb:FlagExist(a,b)
    local p,c,d=1,0,b
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c==d
end
















--LinkLuaModifier("modifier_ns_kbu_delay", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_ns_kbu_duration", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE)
--
--Ns_KBU = class({})
--
--function Ns_KBU:GetCooldown(level)
--    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ns_2")
--end
--
--function Ns_KBU:GetManaCost(level)
--    return self.BaseClass.GetManaCost(self, level)
--end
--
--function Ns_KBU:OnAbilityPhaseStart()
--    self:GetCaster():EmitSound("ns1")
--    return true
--end
--
--function Ns_KBU:OnAbilityPhaseInterrupted()
--    self:GetCaster():StopSound("ns1")
--end
--
--function Ns_KBU:OnSpellStart()
--    if not IsServer() then return end
--    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ns_kbu_delay", {duration = 0.65})
--end
--
--modifier_ns_kbu_delay = class({})
--
--function modifier_ns_kbu_delay:IsHidden()   return true end
--function modifier_ns_kbu_delay:IsPurgable() return false end
--
--function modifier_ns_kbu_delay:OnCreated()
--    if not IsServer() then return end
--    local split_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_primal_split.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
--    ParticleManager:SetParticleControl(split_particle, 0, self:GetParent():GetAbsOrigin())
--    ParticleManager:SetParticleControlForward(split_particle, 0, self:GetParent():GetForwardVector())
--    self:AddParticle(split_particle, false, false, -1, false, false)
--end
--
--function modifier_ns_kbu_delay:CheckState()
--    return 
--    {
--        [MODIFIER_STATE_INVULNERABLE]   = true,
--        [MODIFIER_STATE_OUT_OF_GAME]    = true,
--        [MODIFIER_STATE_STUNNED]            = true,
--        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
--        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
--    }
--end
--
--function modifier_ns_kbu_delay:OnDestroy()
--    if not IsServer() then return end
--    local duration = self:GetAbility():GetSpecialValueFor("duration")
--    self.kbu = {}
--    self.kbu_entindexes = {}
--
--    if self:GetParent():IsAlive() and self:GetAbility() then
--        self:GetCaster():EmitSound("ns2")
--        local split_modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ns_kbu_duration", {duration = duration})
--        local earth_panda   = CreateUnitByName("npc_dota_dread_"..self:GetAbility():GetLevel(), self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100, true, self:GetParent(), self:GetParent(), self:GetCaster():GetTeamNumber())
--        local storm_panda   = CreateUnitByName("npc_dota_xbost_"..self:GetAbility():GetLevel(), RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, 120, 0), self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
--        local fire_panda    = CreateUnitByName("npc_dota_inmate_"..self:GetAbility():GetLevel(), RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, -120, 0), self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
--        
--        if earth_panda then
--            if not self:GetCaster():HasShard() then
--                local ability = earth_panda:FindAbilityByName("Dread_Armor")
--                if ability then
--                    ability:SetLevel(0)
--                end
--            end
--        end
--        if storm_panda then
--            if not self:GetCaster():HasShard() then
--                local ability = storm_panda:FindAbilityByName("Xbost_two_rapier")
--                if ability then
--                    ability:SetLevel(0)
--                end
--            end            
--        end
--        
--        table.insert(self.kbu, earth_panda)
--        table.insert(self.kbu, storm_panda)
--        table.insert(self.kbu, fire_panda)
--        table.insert(self.kbu_entindexes, earth_panda:entindex())
--        
--        if self:GetCaster() == self:GetParent() then
--            table.insert(self.kbu_entindexes, storm_panda:entindex())
--            table.insert(self.kbu_entindexes, fire_panda:entindex())
--        end
--        
--        self:GetParent():FollowEntity(earth_panda, false)
--        
--        if split_modifier then
--            split_modifier.kbu               = self.kbu
--            split_modifier.pandas_entindexes    = self.kbu_entindexes
--        end
--        
--        for _, panda in pairs(self.kbu) do
--            panda:SetForwardVector(self:GetParent():GetForwardVector())
--            panda:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ns_kbu_duration", {duration = duration, parent_entindex = self:GetParent():entindex()})
--            panda:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
--            panda:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
--        end
--        self:GetParent():AddNoDraw()
--    end
--end
--
--modifier_ns_kbu_duration = class({})
--
--function modifier_ns_kbu_duration:IsPurgable()    return false end
--
--function modifier_ns_kbu_duration:OnCreated(keys)
--    if not IsServer() then return end
--    self.attack_speed = 0
--    if keys and keys.parent_entindex then
--        self.parent = EntIndexToHScript(keys.parent_entindex)
--    end
--    if not self:GetParent():IsHero() then
--        if self:GetCaster():HasTalent("special_bonus_birzha_ns_5") then
--            self:GetParent():SetBaseMaxHealth(self:GetParent():GetBaseMaxHealth() + self:GetCaster():FindTalentValue("special_bonus_birzha_ns_5"))
--            self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
--        end
--    end
--    if self:GetParent():GetUnitName() == "npc_dota_xbost_1" then
--        self.attack_speed = self:GetCaster():FindTalentValue("special_bonus_birzha_ns_4")
--    end
--    if self:GetParent():GetUnitName() == "npc_dota_xbost_2" then
--        self.attack_speed = self:GetCaster():FindTalentValue("special_bonus_birzha_ns_4")
--    end
--    if self:GetParent():GetUnitName() == "npc_dota_xbost_3" then
--        self.attack_speed = self:GetCaster():FindTalentValue("special_bonus_birzha_ns_4")
--    end
--end
--
--function modifier_ns_kbu_duration:OnDestroy()
--    if not IsServer() then return end
--    
--    if self:GetParent():IsHero() then
--        self:GetParent():EmitSound("Hero_Brewmaster.PrimalSplit.Return")
--        self:GetParent():FollowEntity(nil, false)
--        self:GetParent():RemoveNoDraw()
--    end
--end
--        
--function modifier_ns_kbu_duration:CheckState()
--    if not self:GetParent():IsHero() then
--        return 
--    end
--
--    return 
--    {
--        [MODIFIER_STATE_INVULNERABLE]       = self:GetParent():IsHero(),
--        [MODIFIER_STATE_OUT_OF_GAME]        = self:GetParent():IsHero(),
--        [MODIFIER_STATE_STUNNED]            = self:GetParent():IsHero(),
--        [MODIFIER_STATE_NOT_ON_MINIMAP]     = self:GetParent():IsHero(),
--        [MODIFIER_STATE_NO_UNIT_COLLISION]  = self:GetParent():IsHero(),
--        [MODIFIER_STATE_UNSELECTABLE]       = self:GetParent():IsHero(),
--    }
--end
--
--function modifier_ns_kbu_duration:DeclareFunctions()
--    return 
--    {
--        MODIFIER_EVENT_ON_DEATH,
--        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
--    }
--end
--
--function modifier_ns_kbu_duration:GetModifierAttackSpeedBonus_Constant()
--    return self.attack_speed
--end
--
--function modifier_ns_kbu_duration:OnDeath(keys)
--    if keys.unit == self:GetParent() and not self:GetParent():IsHero() then
--        if self:GetRemainingTime() > 0 then
--            if self.parent and not self.parent:IsNull() and self.parent:HasModifier("modifier_ns_kbu_duration") and self.parent:FindModifierByName("modifier_ns_kbu_duration").pandas_entindexes then
--                local bNoneAlive    = true
--                
--                for _, panda in pairs(self.parent:FindModifierByName("modifier_ns_kbu_duration").kbu) do
--                    if not panda:IsNull() and panda:IsAlive() then
--                        bNoneAlive = false
--                        self.parent:FollowEntity(panda, false)
--                        
--                        if self.parent ~= self:GetCaster() then
--                            table.insert(self.parent:FindModifierByName("modifier_ns_kbu_duration").kbu_entindexes, panda:entindex())
--                            panda:SetOwner(self.parent)
--                            panda:SetControllableByPlayer(self.parent:GetPlayerID(), true)
--                        end
--                        
--                        break
--                    end
--                end
--                
--                if bNoneAlive then
--                    self.parent:RemoveModifierByName("modifier_ns_kbu_duration")
--                    if keys.attacker ~= self:GetParent() then
--                        if not self.parent:HasScepter() then
--                            self.parent:BirzhaTrueKill( self:GetAbility(), keys.attacker )
--                        end
--                    end
--                end
--            end
--        end
--    end
--end
--
--LinkLuaModifier("modifier_xbost_rapier", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)
--
--Xbost_one_rapier = class({})
--
--function Xbost_one_rapier:GetIntrinsicModifierName()
--    return "modifier_xbost_rapier"
--end
--
--modifier_xbost_rapier = class({})
--
--function modifier_xbost_rapier:IsHidden()
--    return true
--end
--
--function modifier_xbost_rapier:IsPurgable() return false end
--
--function modifier_xbost_rapier:DeclareFunctions()
--    local declfuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
--    return declfuncs
--end
--
--function modifier_xbost_rapier:GetModifierPreAttack_BonusDamage()
--    return self:GetAbility():GetSpecialValueFor("bonus_damage")
--end
--
--LinkLuaModifier("modifier_xbost_rapier_2", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)
--
--Xbost_two_rapier = class({})
--
--function Xbost_two_rapier:GetIntrinsicModifierName()
--    return "modifier_xbost_rapier_2"
--end
--
--modifier_xbost_rapier_2 = class({})
--
--function modifier_xbost_rapier_2:IsPurgable() return false end
--
--function modifier_xbost_rapier_2:IsHidden()
--    return true
--end
--
--function modifier_xbost_rapier_2:DeclareFunctions()
--    local declfuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
--    return declfuncs
--end
--
--function modifier_xbost_rapier_2:GetModifierPreAttack_BonusDamage()
--    return self:GetAbility():GetSpecialValueFor("bonus_damage")
--end
--
--LinkLuaModifier("modifier_dread_aura", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_dread_armor", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)
--
--Dread_Armor = class({})
--
--function Dread_Armor:GetIntrinsicModifierName()
--    return "modifier_dread_aura"
--end
--
--function Dread_Armor:GetCastRange(location, target)
--    return self:GetSpecialValueFor("radius")
--end
--
--modifier_dread_aura = class({})
--
--function modifier_dread_aura:IsPurgable() return false end
--function modifier_dread_aura:IsHidden() return true end
--function modifier_dread_aura:IsAura() return true end
--
--function modifier_dread_aura:GetAuraSearchTeam()
--    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
--end
--
--function modifier_dread_aura:GetAuraSearchType()
--    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
--end
--
--function modifier_dread_aura:GetModifierAura()
--    return "modifier_dread_armor"
--end
--
--function modifier_dread_aura:GetAuraRadius()
--    return self:GetAbility():GetSpecialValueFor("radius")
--end
--
--modifier_dread_armor = class({})
--
--function modifier_dread_armor:IsPurgable() return false end
--
--function modifier_dread_armor:DeclareFunctions()
--    local funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
--    return funcs
--end
--
--function modifier_dread_armor:GetModifierPhysicalArmorBonus()
--    return self:GetAbility():GetSpecialValueFor("armor")
--end