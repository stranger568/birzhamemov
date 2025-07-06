LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_slidan_damage_tower", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_effect_tower2", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slidan_heal_tower", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slidan_default_tower", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slidan_passive", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slidan_worldedit_stack", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE)

Slidan_WorldEdit = class({})

function Slidan_WorldEdit:Precache(context)
    local particle_list = 
    {
        "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf",
        "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf",
        "particles/world_shrine/radiant_shrine_active.vpcf",
        "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf",
        "particles/slidan/slidan_suckdick.vpcf",
        "particles/status_fx/status_effect_doom.vpcf",
        "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf",
        "particles/units/heroes/hero_tinker/tinker_rearm.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function Slidan_WorldEdit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Slidan_WorldEdit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Slidan_WorldEdit:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Slidan_WorldEdit:GetIntrinsicModifierName()
    return "modifier_slidan_worldedit_stack"
end

function Slidan_WorldEdit:OnSpellStart()
    if not IsServer() then return end

    local Towers = 
    {
        "npc_slidan_healing_tower",
        "npc_slidan_default_tower",
        "npc_slidan_fired_tower",
    }

    local tower_random = Towers[RandomInt(1, #Towers)]
    local modifier_slidan_worldedit_stack = self:GetCaster():FindModifierByName("modifier_slidan_worldedit_stack")
    if modifier_slidan_worldedit_stack then
        tower_random = Towers[modifier_slidan_worldedit_stack:GetStackCount()]
    end

    local damage_tower = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_slidan_1")

    local duration = self:GetSpecialValueFor("duration")

    self:GetCaster():EmitSound("worldeditor")

    local tower = CreateUnitByName(tower_random, self:GetCaster():GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    tower:SetControllableByPlayer( self:GetCaster():GetPlayerOwnerID(), true )
    tower:SetOwner(self:GetCaster())

    if tower_random == "npc_slidan_fired_tower" then
        tower:AddNewModifier(self:GetCaster(), self, "modifier_slidan_damage_tower", {})
    elseif tower_random == "npc_slidan_healing_tower" then
        tower:AddNewModifier(self:GetCaster(), self, "modifier_slidan_heal_tower", {})
    elseif tower_random == "npc_slidan_default_tower" then
        tower:AddNewModifier(self:GetCaster(), self, "modifier_slidan_default_tower", {})
        tower:SetBaseDamageMin(damage_tower)
        tower:SetBaseDamageMax(damage_tower)
    end

    tower:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    tower:AddNewModifier(self:GetCaster(), self, "modifier_slidan_passive", {})
end

modifier_slidan_worldedit_stack = class({})
function modifier_slidan_worldedit_stack:IsPurgable() return false end
function modifier_slidan_worldedit_stack:IsPurgeException() return false end
function modifier_slidan_worldedit_stack:IsHidden() return true end
function modifier_slidan_worldedit_stack:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end

modifier_slidan_damage_tower = class({})

function modifier_slidan_damage_tower:IsPurgable() return false end
function modifier_slidan_damage_tower:IsHidden() return true end
function modifier_slidan_damage_tower:IsAura() return true end

function modifier_slidan_damage_tower:OnCreated()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(600, 0, 0))
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_slidan_damage_tower:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_slidan_damage_tower:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_slidan_damage_tower:GetModifierAura()
    return "modifier_effect_tower2"
end

function modifier_slidan_damage_tower:GetAuraRadius()
    return 600
end

modifier_effect_tower2 = class({})

function modifier_effect_tower2:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_effect_tower2:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("firedamage") + self:GetCaster():FindTalentValue("special_bonus_birzha_slidan_5")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
end

function modifier_effect_tower2:GetAttributes()
    if self:GetCaster():HasTalent("special_bonus_birzha_slidan_3") then
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
end

function modifier_effect_tower2:IsPurgable() return false end

function modifier_effect_tower2:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_effect_tower2:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_effect_tower2:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_effect_tower2:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_slidan_heal_tower = class({})

function modifier_slidan_heal_tower:IsPurgable() return false end
function modifier_slidan_heal_tower:IsHidden() return true end

function modifier_slidan_heal_tower:OnCreated()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local particle = ParticleManager:CreateParticle("particles/world_shrine/radiant_shrine_active.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())
    self:OnIntervalThink()
end

function modifier_slidan_heal_tower:OnIntervalThink()
    if not IsServer() then return end
    local radius = 600
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _,unit in pairs(targets) do
        local heal_tower = (unit:GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("heal")  ) * FrameTime()
        unit:Heal(heal_tower, self:GetAbility())
    end
end

modifier_slidan_default_tower = class({})

function modifier_slidan_default_tower:IsPurgable() return false end
function modifier_slidan_default_tower:IsHidden() return true end

function modifier_slidan_default_tower:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,

    }

    return decFuncs
end

function modifier_slidan_default_tower:RemoveOnDeath()
    return false
end

function modifier_slidan_default_tower:GetOverrideAnimation()
    return ACT_DOTA_CONSTANT_LAYER
end

function modifier_slidan_default_tower:GetActivityTranslationModifiers()
    return "level6"
end

modifier_slidan_passive = class({})

function modifier_slidan_passive:IsPurgable() return false end
function modifier_slidan_passive:IsHidden() return true end

function modifier_slidan_passive:CheckState()
    local state = 
    { 
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true
    }
    return state
end

LinkLuaModifier( "modifier_slidan_suckdick_debuff", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE )

Slidan_SuckDick = class({})
Slidan_SuckDick.modifiers = {}

function Slidan_SuckDick:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasShard()) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function Slidan_SuckDick:OnSpellStart()
    local target = self:GetCursorTarget()
    local modifier_slidan_worldedit_stack = self:GetCaster():FindModifierByName("modifier_slidan_worldedit_stack")
    if modifier_slidan_worldedit_stack then
        modifier_slidan_worldedit_stack:SetStackCount(1)
    end
    if target:TriggerSpellAbsorb( self ) then
        return
    end
    local duration = self:GetSpecialValueFor("duration")
    local modifier = target:AddNewModifier( self:GetCaster(), self, "modifier_slidan_suckdick_debuff", { duration = duration * (1 - target:GetStatusResistance()) } )
    self.modifiers[modifier] = true
end

function Slidan_SuckDick:OnChannelFinish( bInterrupted )
    for modifier,_ in pairs(self.modifiers) do
        if not modifier:IsNull() then
            modifier.forceDestroy = bInterrupted
            modifier:Destroy()
        end
    end
    self.modifiers = {}
end

function Slidan_SuckDick:Unregister( modifier )
    self.modifiers[modifier] = nil
    local counter = 0
    for modifier,_ in pairs(self.modifiers) do
        if not modifier:IsNull() then
            counter = counter+1
        end
    end

    if counter==0 and self:IsChanneling() then
        self:EndChannel( false )
    end
end

modifier_slidan_suckdick_debuff = class({})

function modifier_slidan_suckdick_debuff:IsPurgable()
    return not self:GetCaster():HasShard()
end

function modifier_slidan_suckdick_debuff:OnCreated( kv )
    self.mana = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_slidan_2")
    self.radius = 1200
    self.slow = self:GetAbility():GetSpecialValueFor( "reduse_speed" )
    local interval = 0.1
    self.mana = self.mana * interval
    if IsServer() then
        self.parent = self:GetParent()
        self:StartIntervalThink( interval )
        self:PlayEffects()
        self:GetCaster():EmitSound("Hero_Lion.ManaDrain")
    end
end

function modifier_slidan_suckdick_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("Hero_Lion.ManaDrain")
    if not self.forceDestroy then
        self:GetAbility():Unregister( self )
    end
    if self.parent:IsIllusion() then
        self.parent:Kill( self:GetAbility(), self:GetCaster() )
    end
end

function modifier_slidan_suckdick_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_slidan_suckdick_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_slidan_suckdick_debuff:OnIntervalThink()
    if not IsServer() then return end

    if self:GetCaster():IsStunned() or self:GetCaster():IsSilenced() then
        self:Destroy()
        return
    end
    if self.parent:IsInvulnerable() then
        self:Destroy()
        return
    end
    if not self:GetCaster():HasShard() then
        if self.parent:IsMagicImmune() then
            self:Destroy()
            return
        end
    end
    if self.parent:IsIllusion() then
        self:Destroy()
        return
    end
    if not self:GetCaster():IsAlive() then
        self:Destroy()
        return
    end
    if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>self.radius then
        self:Destroy()
        return
    end

    local damageTable =
    {   victim = self:GetParent(),
        damage = self.mana,
        damage_type = DAMAGE_TYPE_MAGICAL,
        attacker = self:GetCaster(),
        ability = self:GetAbility()
    }

    ApplyDamage(damageTable)

    self:GetParent():Script_ReduceMana( self.mana, self:GetAbility() )
    self:GetCaster():GiveMana( self.mana )
end

function modifier_slidan_suckdick_debuff:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    self:AddParticle( effect_cast, false, false, -1, false, false )

    local effect_cast_2 = ParticleManager:CreateParticle( "particles/slidan/slidan_suckdick.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast_2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast_2, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    self:AddParticle( effect_cast_2, false, false, -1, false, false )
end

LinkLuaModifier( "modifier_slidan_NetherDroch", "abilities/heroes/slidan", LUA_MODIFIER_MOTION_NONE )

Slidan_NetherDroch = class({})

function Slidan_NetherDroch:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Slidan_NetherDroch:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Slidan_NetherDroch:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Slidan_NetherDroch:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Slidan_NetherDroch:OnSpellStart()
    if IsServer() then
        local point = self:GetCursorPosition()
        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_slidan_4")
        local duration = self:GetSpecialValueFor("duration")
        self:GetCaster():EmitSound("slidandroch")
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        for _,enemy in ipairs(enemies) do
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_slidan_NetherDroch", {duration = duration * (1 - enemy:GetStatusResistance())})
        end
        local modifier_slidan_worldedit_stack = self:GetCaster():FindModifierByName("modifier_slidan_worldedit_stack")
        if modifier_slidan_worldedit_stack then
            modifier_slidan_worldedit_stack:SetStackCount(2)
        end
    end
end

modifier_slidan_NetherDroch = class({})

function modifier_slidan_NetherDroch:IsPurgable() return false end

function modifier_slidan_NetherDroch:OnCreated( kv )
    if not IsServer() then return end
    self:PlayEffects()
    self:GetParent():Purge( true, false, false, false, false)
end

function modifier_slidan_NetherDroch:CheckState()
    local state = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    if self:GetCaster():HasTalent("special_bonus_birzha_slidan_8") then
        state = 
        {
            [MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_MUTED] = true,
        }
    end
    return state
end

function modifier_slidan_NetherDroch:GetStatusEffectName()
    return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_slidan_NetherDroch:StatusEffectPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_slidan_NetherDroch:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    self:AddParticle( effect_cast, false, false, MODIFIER_PRIORITY_SUPER_ULTRA, false, false )
end

function modifier_slidan_NetherDroch:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return funcs
end

function modifier_slidan_NetherDroch:GetDisableHealing()
    if self:GetCaster():HasScepter() then
        return 1
    end
end

function modifier_slidan_NetherDroch:GetModifierMiss_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_slidan_6")
end

Slidan_ReallyClassic = class({})

function Slidan_ReallyClassic:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Slidan_ReallyClassic:GetManaCost(level)
    if self:GetCaster():HasTalent("special_bonus_birzha_slidan_7") then
        return self.BaseClass.GetManaCost(self, level) / self:GetCaster():FindTalentValue("special_bonus_birzha_slidan_7")
    end
    return self.BaseClass.GetManaCost(self, level)
end

function Slidan_ReallyClassic:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("classic")
    local modifier_slidan_worldedit_stack = self:GetCaster():FindModifierByName("modifier_slidan_worldedit_stack")
    if modifier_slidan_worldedit_stack then
        modifier_slidan_worldedit_stack:SetStackCount(3)
    end
end

function Slidan_ReallyClassic:OnChannelFinish( bInterrupted )
    local caster = self:GetCaster()
    if bInterrupted then return end

    for i=0,caster:GetAbilityCount()-1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability and ability:GetAbilityType()~=ABILITY_TYPE_ATTRIBUTES then
            ability:RefreshCharges()
            ability:EndCooldown()
        end
    end

    for i=0,8 do
        local item = caster:GetItemInSlot(i)
        if item then
            local pass = false
            if item:GetPurchaser()==caster and not self:IsItemException( item ) then
                pass = true
            end

            if pass then
                item:EndCooldown()
            end
        end
    end

    self:PlayEffects()
end

function Slidan_ReallyClassic:IsItemException( item )
    return self.ItemException[item:GetName()]
end

Slidan_ReallyClassic.ItemException = 
{
    ["item_aeon_disk"] = true,
    ["item_arcane_boots"] = true,
    ["item_black_king_bar"] = true,
    ["item_hand_of_midas"] = true,
    ["item_helm_of_the_dominator"] = true,
    ["item_meteor_hammer"] = true,
    ["item_necronomicon"] = true,
    ["item_necronomicon_2"] = true,
    ["item_necronomicon_3"] = true,
    ["item_refresher"] = true,
    ["item_refresher_shard"] = true,
    ["item_pipe"] = true,
    ["item_sphere"] = true,
    ["item_frostmorn"] = true,
    ["item_baldezh"] = true,
    ["item_cosmobaldezh"] = true,
    ["item_superbaldezh"] = true,
    ["item_roscom_midas"] = true,
    ["item_guardian_greaves"] = true,
    ["item_overheal_trank"] = true,
    ["item_chill_aquila"] = true,
    ["item_drum_of_speedrun"] = true,
    ["item_aether_lupa"] = true,
    ["item_uebator"] = true,
    ["item_angel_boots"] = true, 
    ["item_brain_burner"] = true,  
    ["item_gamble_gold_ring"] = true,
    ["item_gamble_gold_ring_2"] = true,
    ["item_hookah"] = true,
}

function Slidan_ReallyClassic:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end
