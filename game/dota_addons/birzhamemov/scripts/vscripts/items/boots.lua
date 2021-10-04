LinkLuaModifier("modifier_item_boots_of_invisibility", "items/boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_boots_of_invisibility_active", "items/boots", LUA_MODIFIER_MOTION_NONE)

item_boots_of_invisibility = class({})

function item_boots_of_invisibility:GetIntrinsicModifierName()
    return "modifier_item_boots_of_invisibility"
end

function item_boots_of_invisibility:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("Item.GlimmerCape.Activate")
    local particle = ParticleManager:CreateParticle( "particles/hovanboots/hovan_boots_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    local particle_smoke_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_smoke_fx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_smoke_fx)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_boots_of_invisibility_active", {duration = duration} )
end

modifier_item_boots_of_invisibility_active = class({})

function modifier_item_boots_of_invisibility_active:IsHidden()
    return false
end

function modifier_item_boots_of_invisibility_active:IsPurgable()
    return false
end

function modifier_item_boots_of_invisibility_active:GetTexture()
    return "Items/boots_of_invisibility"
end

function modifier_item_boots_of_invisibility_active:OnCreated()
    self.resist = self:GetAbility():GetSpecialValueFor('bonus_resist_active')
end

function modifier_item_boots_of_invisibility_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_item_boots_of_invisibility_active:GetModifierMagicalResistanceBonus()
    return self.resist
end

function modifier_item_boots_of_invisibility_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_item_boots_of_invisibility_active:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

function modifier_item_boots_of_invisibility_active:OnAbilityExecuted(keys)
    if IsServer() then
        local ability = keys.ability
        local caster = keys.unit
        if caster == self:GetCaster() then
            self:Destroy()
        end
    end
end

function modifier_item_boots_of_invisibility_active:OnAttackLanded(keys)
    if IsServer() then
        local attacker = keys.attacker
        local target = keys.target
        if self:GetCaster() == attacker then
            self:Destroy()
        end
    end
end

modifier_item_boots_of_invisibility = class({})

function modifier_item_boots_of_invisibility:IsHidden()
	return true
end

function modifier_item_boots_of_invisibility:IsPurgable()
    return false
end

function modifier_item_boots_of_invisibility:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_boots_of_invisibility:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function modifier_item_boots_of_invisibility:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
end

function modifier_item_boots_of_invisibility:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('bonus_speed')
end

function modifier_item_boots_of_invisibility:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_resist')
end

LinkLuaModifier("modifier_item_pt_stats", "items/boots", LUA_MODIFIER_MOTION_NONE)

item_pt_mem = class({})

function item_pt_mem:GetIntrinsicModifierName()
    return "modifier_item_pt_stats"
end

modifier_item_pt_stats = class({})

function modifier_item_pt_stats:IsHidden()
    return true
end

function modifier_item_pt_stats:IsPurgable()
    return false
end

function modifier_item_pt_stats:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_pt_stats:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_pt_stats:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
end

function modifier_item_pt_stats:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_item_pt_stats:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_pt_stats:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

function modifier_item_pt_stats:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('bonus_stats')
end

LinkLuaModifier("modifier_item_imba_phase_boots_2", "items/boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_phase_boots_2_active", "items/boots", LUA_MODIFIER_MOTION_NONE)

item_imba_phase_boots_2 = class({})

function item_imba_phase_boots_2:GetIntrinsicModifierName()
    return "modifier_item_imba_phase_boots_2"
end

function item_imba_phase_boots_2:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local player = self:GetCaster():GetPlayerID()
    if IsUnlockedInPass(player, "reward35") then
        local haste_pfx = ParticleManager:CreateParticle("particles/birzhapass/abibas_boots_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(haste_pfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(haste_pfx)
    else
        local haste_pfx = ParticleManager:CreateParticle("particles/abibas/phase_abibas_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(haste_pfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(haste_pfx)
    end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_imba_phase_boots_2_active", {duration = duration} )
    EmitSoundOnClient("DOTA_Item.PhaseBoots.Activate", PlayerResource:GetPlayer(self:GetCaster():GetPlayerID()))
end

modifier_item_imba_phase_boots_2 = class({})

function modifier_item_imba_phase_boots_2:IsHidden()
    return true
end

function modifier_item_imba_phase_boots_2:IsPurgable()
    return false
end

function modifier_item_imba_phase_boots_2:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_imba_phase_boots_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_item_imba_phase_boots_2:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
end

function modifier_item_imba_phase_boots_2:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor('bonus_damage')
end

function modifier_item_imba_phase_boots_2:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

modifier_item_imba_phase_boots_2_active = class({})

function modifier_item_imba_phase_boots_2_active:IsHidden()
    return false
end

function modifier_item_imba_phase_boots_2_active:IsPurgable()
    return false
end

function modifier_item_imba_phase_boots_2_active:GetTexture()
    return "items/abibas"
end

function modifier_item_imba_phase_boots_2_active:OnCreated()
    self.bonus_movespeed = self:GetAbility():GetSpecialValueFor("phase_ms")
end

function modifier_item_imba_phase_boots_2_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_item_imba_phase_boots_2_active:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_movespeed
end

function modifier_item_imba_phase_boots_2_active:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

LinkLuaModifier("modifier_item_birzha_blink_boots", "items/boots", LUA_MODIFIER_MOTION_NONE)

item_blink_boots = class({})

function item_blink_boots:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
    end
    return true;
end

function item_blink_boots:OnSpellStart()
    if not IsServer() then return end
    local player = self:GetCaster():GetPlayerID()
    if IsUnlockedInPass(player, "reward93") then
        ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        local particle = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_start.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(100, 100, 0))
        Timers:CreateTimer(1, function()        
            if particle then
                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)    
            end
        end)
    end
    ParticleManager:CreateParticle("particles/blink/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    self:GetCaster():EmitSound("DOTA_Item.BlinkDagger.Activate")
    local origin_point = self:GetCaster():GetAbsOrigin()
    local target_point = self:GetCursorPosition()
    local difference_vector = target_point - origin_point
    if difference_vector:Length2D() > 1200 then
        target_point = origin_point + (target_point - origin_point):Normalized() * 1200
    end
    self:GetCaster():SetAbsOrigin(target_point)
    FindClearSpaceForUnit(self:GetCaster(), target_point, false)
    ProjectileManager:ProjectileDodge(self:GetCaster())
    ParticleManager:CreateParticle("particles/blink/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
end

function item_blink_boots:GetIntrinsicModifierName()
    return "modifier_item_birzha_blink_boots"
end

modifier_item_birzha_blink_boots = class({})

function modifier_item_birzha_blink_boots:IsHidden()
    return true
end

function modifier_item_birzha_blink_boots:IsPurgable()
    return false
end

function modifier_item_birzha_blink_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_birzha_blink_boots:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_item_birzha_blink_boots:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
end

function modifier_item_birzha_blink_boots:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('bonus_int')
end

function modifier_item_birzha_blink_boots:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor('bonus_regen')
end

function modifier_item_birzha_blink_boots:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        self:GetAbility():StartCooldown(1)
    end
end

LinkLuaModifier( "modifier_item_birzha_force_boots", "items/boots", LUA_MODIFIER_MOTION_NONE )

item_birzha_force_boots = class({})

function item_birzha_force_boots:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_item_forcestaff_active', {push_length = self:GetSpecialValueFor("push_length")})
    self:GetCaster():RemoveGesture(ACT_DOTA_DISABLED)
    EmitSoundOn('DOTA_Item.ForceStaff.Activate', self:GetCaster())
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_force")
    end
end

function item_birzha_force_boots:GetIntrinsicModifierName() 
    return "modifier_item_birzha_force_boots"
end

modifier_item_birzha_force_boots = class({})

function modifier_item_birzha_force_boots:IsHidden()
    return true
end

function modifier_item_birzha_force_boots:IsPurgable()
    return false
end

function modifier_item_birzha_force_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_birzha_force_boots:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
            MODIFIER_PROPERTY_HEALTH_BONUS,
        }
end

function modifier_item_birzha_force_boots:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_birzha_force_boots:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_regen')
end

function modifier_item_birzha_force_boots:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

LinkLuaModifier( "modifier_item_overheal_trank", "items/boots", LUA_MODIFIER_MOTION_NONE )

item_overheal_trank = class({})

modifier_item_overheal_trank = class({})

function item_overheal_trank:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = duration})
    self:GetCaster():EmitSound("Rune.Regen")
end

function item_overheal_trank:GetIntrinsicModifierName() 
    return "modifier_item_overheal_trank"
end

modifier_item_overheal_trank = class({})

function modifier_item_overheal_trank:IsHidden()
    return true
end

function modifier_item_overheal_trank:IsPurgable()
    return false
end

function modifier_item_overheal_trank:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_overheal_trank:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_item_overheal_trank:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_overheal_trank:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

LinkLuaModifier( "modifier_item_angel_boots", "items/boots", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_angel_boots_aura", "items/boots", LUA_MODIFIER_MOTION_NONE )

item_angel_boots = class({})

function item_angel_boots:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local mana = self:GetSpecialValueFor("restore_mana")
    local health = self:GetSpecialValueFor("restore_health")
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
    for _,target in pairs(targets) do
        local particle_effect = nil
        if IsUnlockedInPass(self:GetCaster():GetPlayerID(), "reward60") then
            particle_effect = "particles/birzhapass/angel_boots_effect.vpcf"
        else
            particle_effect = "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"
        end
        target:AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = duration})
        self:GetCaster():EmitSound("Item.GuardianGreaves.Activate")
        self:GetCaster():EmitSound("Hero_Chen.HandOfGodHealHero")
        local particle = ParticleManager:CreateParticle( particle_effect, PATTACH_CUSTOMORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true  );
        ParticleManager:SetParticleControl( particle, 1, Vector( 200, 200, 200 ) );
        ParticleManager:ReleaseParticleIndex( particle );
        target:SetMana(target:GetMana() + mana)
        target:Heal(health, self)
        target:Purge( false, true, false, true, true)
    end
end

function item_angel_boots:GetIntrinsicModifierName() 
    return "modifier_item_angel_boots"
end

modifier_item_angel_boots = class({})

function modifier_item_angel_boots:IsHidden()
    return true
end

function modifier_item_angel_boots:IsPurgable()
    return false
end

function modifier_item_angel_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_angel_boots:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
            MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
            MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
            MODIFIER_PROPERTY_MANA_BONUS,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        }
end

function modifier_item_angel_boots:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_angel_boots:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_angel_boots:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_angel_boots:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_angel_boots:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_angel_boots:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_angel_boots:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

function modifier_item_angel_boots:IsAura() return true end

function modifier_item_angel_boots:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_item_angel_boots:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_angel_boots:GetModifierAura()
    return "modifier_item_angel_boots_aura"
end

function modifier_item_angel_boots:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_item_angel_boots:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_angel_boots:GetAuraDuration()
    return 0.1
end

modifier_item_angel_boots_aura = class({})

function modifier_item_angel_boots_aura:IsPurgable()
    return false
end

function modifier_item_angel_boots_aura:OnCreated()
    if not IsServer() then return end
    self.regen_aura = self:GetAbility():GetSpecialValueFor("bonus_regen_aura")
    self.armor_aura = self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
    self:SetStackCount(0)
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_angel_boots_aura:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():GetHealth() > self:GetParent():GetMaxHealth() * 0.2 then
        self:SetStackCount(0)
    else
        self:SetStackCount(1)
    end
end

function modifier_item_angel_boots_aura:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        }
end

function modifier_item_angel_boots_aura:AddCustomTransmitterData() return {
    regen_aura = self.regen_aura,
    armor_aura = self.armor_aura,

} end

function modifier_item_angel_boots_aura:HandleCustomTransmitterData(data)
    if self:GetStackCount() == 1 then
        self.regen_aura = data.regen_aura * 2
        self.armor_aura = data.armor_aura * 4
    else
        self.regen_aura = data.regen_aura
        self.armor_aura = data.armor_aura
    end
end

function modifier_item_angel_boots_aura:GetModifierConstantHealthRegen()
    return self.regen_aura 
end

function modifier_item_angel_boots_aura:GetModifierPhysicalArmorBonus()
    return self.armor_aura
end