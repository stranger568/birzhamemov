LinkLuaModifier( "modifier_metagame_shield", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

metagame_shield = class({})

function metagame_shield:OnSpellStart()
    if not IsServer() then return end

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_1")

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_metagame_shield", { duration = duration } )

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle )
end

modifier_metagame_shield = class({})

function modifier_metagame_shield:IsPurgable()
    return false
end

function modifier_metagame_shield:IsPurgeException()
    return false
end

function modifier_metagame_shield:OnCreated( kv )
    if not IsServer() then return end
    self.agility = self:GetAbility():GetSpecialValueFor("bonus_agility")
    self.status_resistance = self:GetAbility():GetSpecialValueFor("bonus_resist")

    local count_modifiers_old = 0
    local count_modifiers_new = 0
    local stack = 0

    for _, modifier in pairs(self:GetParent():FindAllModifiers()) do
        if modifier and modifier:IsDebuff() then
            count_modifiers_old = count_modifiers_old + 1
        end
    end

    self:GetParent():Purge(false, true, false, true, true)

    for _, modifier in pairs(self:GetParent():FindAllModifiers()) do
        if modifier and modifier:IsDebuff() then
            count_modifiers_new = count_modifiers_new + 1
        end
    end

    stack = count_modifiers_old - count_modifiers_new

    if stack > 0 then
        self.agility = self.agility + (stack * (self:GetAbility():GetSpecialValueFor("bonus_agility_per_effect") + self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_5")))
        self.status_resistance = self.status_resistance + (stack * self:GetAbility():GetSpecialValueFor("bonus_resist_per_effect"))
    end

    self:GetParent():EmitSound("metagame_repel")

    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_metagame_shield:AddCustomTransmitterData()
    return 
    {
        agility = self.agility,
        status_resistance = self.status_resistance,
    }
end

function modifier_metagame_shield:HandleCustomTransmitterData( data )
    self.agility = data.agility
    self.status_resistance = data.status_resistance
end

function modifier_metagame_shield:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_metagame_shield:OnDestroy( kv )
    if not IsServer() then return end
    self:GetParent():StopSound("metagame_repel")
end

function modifier_metagame_shield:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS
    }

    return funcs
end

function modifier_metagame_shield:GetModifierStatusResistanceStacking()
    return self.status_resistance
end

function modifier_metagame_shield:GetModifierBonusStats_Agility()
    return self.agility
end

function modifier_metagame_shield:GetEffectName()
    return "particles/econ/items/omniknight/omni_2021_immortal/omni_2021_immortal.vpcf"
end

function modifier_metagame_shield:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_metagame_mmr", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )

metagame_mmr = class({})

function metagame_mmr:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_3")
end

function metagame_mmr:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_metagame_mmr", { duration = duration } )
end

modifier_metagame_mmr = class({})

function modifier_metagame_mmr:IsPurgable() return false end
function modifier_metagame_mmr:IsPurgeException() return true end

function modifier_metagame_mmr:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_metagame_mmr:GetModifierProcAttack_BonusDamage_Magical(params)
    if not IsServer() then return end
    if params.target:IsWard() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_4")
end

function modifier_metagame_mmr:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_metagame_mmr:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():EmitSound("metagame_mmr")
    self.stun = self:GetAbility():GetSpecialValueFor( "stun_duration" )
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self:PlayEffects1()
    self:PlayEffects2()
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_metagame_mmr:OnIntervalThink()
    if not IsServer() then return end
    if self:GetCaster():HasShard() then
        self:Stun()
    end
end

function modifier_metagame_mmr:OnDestroy( kv )
    if not IsServer() then return end
    self:Stun()
end

function modifier_metagame_mmr:Stun( shard )
    if not IsServer() then return end

    local radius = self.radius

    if self:GetCaster():HasShard() then
        radius = self:GetAbility():GetSpecialValueFor("radius_shard")
    end

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self.stun * (1 - enemy:GetStatusResistance()) } )
    end

    self:PlayEffects3(radius)
end

function modifier_metagame_mmr:PlayEffects1()
    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crown_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector( 0, 0, 0 ), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector( 0, 0, 0 ), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self:GetCaster():EmitSound("Hero_DarkWillow.Ley.Cast")
    self:GetCaster():EmitSound("Hero_DarkWillow.Ley.Target")
end

function modifier_metagame_mmr:PlayEffects2()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_dark_willow/dark_willow_leyconduit_start.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    self:AddParticle( effect_cast, false, false,  -1, false,  false )
end

function modifier_metagame_mmr:PlayEffects3(radius)
    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crownmarker.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_DarkWillow.Ley.Stun", self:GetCaster() )
end

LinkLuaModifier( "modifier_metagame_passive", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_metagame_passive_debuff", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )

metagame_passive = class({})

function metagame_passive:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_2")
end

function metagame_passive:GetIntrinsicModifierName()
    return "modifier_metagame_passive"
end

function metagame_passive:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target then
        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) + ( self:GetCaster():GetAverageTrueAttackDamage(nil)  / 100 * self:GetSpecialValueFor("bonus_damage"))
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        target:EmitSound("Hero_Tiny_Tree.Impact")
        for _,enemy in pairs(enemies) do
            local duration = self:GetSpecialValueFor("duration")
            local stun_duration = self:GetSpecialValueFor("stun_duration")
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_metagame_passive_debuff", {duration = duration * (1-enemy:GetStatusResistance())})
            if self:GetCaster():HasTalent("special_bonus_birzha_metagame_6") then
               enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_6") * (1-enemy:GetStatusResistance())}) 
            end
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
        end
    end
    return true
end

modifier_metagame_passive = class({})

function modifier_metagame_passive:IsHidden()
    return true
end

function modifier_metagame_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_metagame_passive:OnAttackLanded( params )
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not self:GetAbility():IsFullyCastable() then return end
    if self:GetParent():IsIllusion() then return end

    local info = 
    {
        EffectName = "particles/metagame_tree.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 1950,
        Source = self:GetCaster(),
        Target = params.attacker,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

    ProjectileManager:CreateTrackingProjectile(info)
    self:GetCaster():EmitSound("metagame_passive")
    self:GetAbility():UseResources(false, false, true)
end

modifier_metagame_passive_debuff = class({})

function modifier_metagame_passive_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_metagame_passive_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

LinkLuaModifier( "modifier_metagame_furion", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_metagame_furion_fury", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_metagame_furion_recovery", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_metagame_furion_silence", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )

metagame_furion = class({})

function metagame_furion:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function metagame_furion:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_metagame_furion", { duration = duration } )
end

modifier_metagame_furion = class({})

function modifier_metagame_furion:IsPurgable()
    return false
end

function modifier_metagame_furion:OnCreated( kv )
    self.parent = self:GetParent()
    if not IsServer() then return end
    self:GetParent():EmitSound("metagame_ultimate")
    self.parent:Purge( false, true, false, false, false )
    self.parent:AddNewModifier( self.parent, self:GetAbility(), "modifier_metagame_furion_fury", {} )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self.pulse = 0
    self:GetParent():EmitSound("Hero_Marci.Unleash.Cast")
end

function modifier_metagame_furion:OnRefresh( kv )
    if not IsServer() then return end
    self.parent:Purge( false, true, false, false, false )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self:GetParent():EmitSound("Hero_Marci.Unleash.Cast")
end

function modifier_metagame_furion:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("metagame_ultimate")
    local fury = self.parent:FindModifierByNameAndCaster( "modifier_metagame_furion_fury", self.parent )
    if fury then
        fury:ForceDestroy()
    end

    local recovery = self.parent:FindModifierByNameAndCaster( "modifier_metagame_furion_recovery", self.parent )
    if recovery then
        recovery:ForceDestroy()
    end
end

function modifier_metagame_furion:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_metagame_furion:OnAttackLanded( params )
    if params.attacker ~= self:GetParent() then return end
    self.pulse = self.pulse + 1
    if self.pulse >= self:GetAbility():GetSpecialValueFor("attack_per_impulse") then
        self.pulse = 0
        self:Pulse( params.target:GetAbsOrigin() )
    end
end

function modifier_metagame_furion:Pulse( center )
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), center, nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    local damageTable = { attacker = self:GetParent(), damage = self:GetAbility():GetSpecialValueFor("impulse_damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility(), }
    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage(damageTable)
        if self:GetCaster():HasTalent("special_bonus_birzha_metagame_8") then
           enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_metagame_furion_silence", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_8") * (1-enemy:GetStatusResistance())}) 
        end
    end
    self:PlayEffects4( center, self:GetAbility():GetSpecialValueFor("radius") )
end

function modifier_metagame_furion:PlayEffects4( point, radius )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_pulse.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius,radius,radius) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( point, "Hero_Marci.Unleash.Pulse", self:GetParent() )
end

modifier_metagame_furion_fury = class({})

function modifier_metagame_furion_fury:IsPurgable()
    return false
end

function modifier_metagame_furion_fury:IsHidden()
    return true
end

function modifier_metagame_furion_fury:OnCreated( kv )
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.bonus_as = self:GetAbility():GetSpecialValueFor( "flurry_bonus_attack_speed" )
    self.recovery = self:GetAbility():GetSpecialValueFor("attack_cooldown") + self:GetCaster():FindTalentValue("special_bonus_birzha_metagame_7")
    self.charges = self:GetAbility():GetSpecialValueFor( "charges_per_flurry" )
    self.timer = 1
    if not IsServer() then return end
    self.counter = self.charges
    self:SetStackCount( self.counter )
    self.success = 0
    self:PlayEffects1()
    self:PlayEffects2( self.parent, self.counter )
end

function modifier_metagame_furion_fury:OnDestroy()
    if not IsServer() then return end
    local main = self.parent:FindModifierByNameAndCaster( "modifier_metagame_furion", self.parent )
    if not main then return end
    if self.forced then return end
    self.parent:AddNewModifier( self.parent, self.ability, "modifier_metagame_furion_recovery", { duration = self.recovery, success = self.success, } )
    if self.success~=1 then return end
end

function modifier_metagame_furion_fury:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_HERO_KILLED,
    }
    return funcs
end

function modifier_metagame_furion_fury:GetModifierAttackSpeed_Limit()
    return 1
end

function modifier_metagame_furion_fury:OnHeroKilled(params)
    if not IsServer() then return end
    if self:GetParent() == params.attacker and self:GetParent() ~= params.target then
        self:GetParent():ModifyGold(self:GetAbility():GetSpecialValueFor("bonus_gold"), false, 0)  
    end
end

function modifier_metagame_furion_fury:OnAttack( params )
    if params.attacker ~= self:GetParent() then return end
    self:StartIntervalThink( self.timer )
    self.counter = self.counter - 1
    self:SetStackCount( self.counter )
    self:EditEffects2( self.counter )
    self:PlayEffects3( self.parent, params.target )
    if self.counter<=0 then
        self.success = 1
        self:Destroy()
    end
end

function modifier_metagame_furion_fury:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_metagame_furion_fury:OnIntervalThink()
    self:Destroy()
end

function modifier_metagame_furion_fury:ForceDestroy()
    self.forced = true
    self:Destroy()
end

function modifier_metagame_furion_fury:ShouldUseOverheadOffset()
    return true
end

function modifier_metagame_furion_fury:PlayEffects1()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
    self:AddParticle( effect_cast, false, false, -1, false, false  )
    self:GetParent():EmitSound("Hero_Marci.Unleash.Charged")
    EmitSoundOnClient( "Hero_Marci.Unleash.Charged.2D", self:GetParent():GetPlayerOwner() )
end

function modifier_metagame_furion_fury:PlayEffects2( caster, counter )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 0, counter, 0 ) )
    self:AddParticle( effect_cast, false, false, 1, false, true )
    self.effect_cast = effect_cast
end

function modifier_metagame_furion_fury:EditEffects2( counter )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 0, counter, 0 ) )
end

function modifier_metagame_furion_fury:PlayEffects3( caster, target )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_metagame_furion_recovery = class({})

function modifier_metagame_furion_recovery:IsPurgable()
    return false
end

function modifier_metagame_furion_recovery:IsHidden()
    return true
end

function modifier_metagame_furion_recovery:OnCreated( kv )
    self.parent = self:GetParent()
    self.rate = 2
    if not IsServer() then return end
    self.success = kv.success==1
end

function modifier_metagame_furion_recovery:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_metagame_furion_recovery:OnDestroy()
    if not IsServer() then return end
    local main = self.parent:FindModifierByNameAndCaster( "modifier_metagame_furion", self.parent )
    if not main then return end
    if self.forced then return end
    self.parent:AddNewModifier( self.parent, self:GetAbility(), "modifier_metagame_furion_fury", {} )
end

function modifier_metagame_furion_recovery:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
    }
    return funcs
end

function modifier_metagame_furion_recovery:GetModifierFixedAttackRate( params )
    return self.rate
end

function modifier_metagame_furion_recovery:ForceDestroy()
    self.forced = true
    self:Destroy()
end

modifier_metagame_furion_silence = class({})

function modifier_metagame_furion_silence:CheckState()
    return 
    {
        [MODIFIER_STATE_SILENCED] = true
    }
end

function modifier_metagame_furion_silence:GetEffectName()
    return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_metagame_furion_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier( "modifier_metagame_shadow_blade", "abilities/heroes/metagame.lua", LUA_MODIFIER_MOTION_NONE )

metagame_shadow_blade = class({})

function metagame_shadow_blade:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function metagame_shadow_blade:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function metagame_shadow_blade:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("DOTA_Item.InvisibilitySword.Activate")
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_metagame_shadow_blade", {duration = duration})
end

modifier_metagame_shadow_blade = class({})

function modifier_metagame_shadow_blade:IsPurgable() return false end

function modifier_metagame_shadow_blade:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_metagame_shadow_blade:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():RemoveModifierByName("modifier_item_dustofappearance")
    self:GetParent():RemoveModifierByName("modifier_truesight")
end

function modifier_metagame_shadow_blade:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_metagame_shadow_blade:GetModifierInvisibilityLevel()
    return 1
end

function modifier_metagame_shadow_blade:CheckState()
    return 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_metagame_shadow_blade:GetModifierProcAttack_BonusDamage_Physical(params)
    if params.attacker == self:GetParent() then 
        self:Destroy()
        return self:GetAbility():GetSpecialValueFor("damage")
    end
end

function modifier_metagame_shadow_blade:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability

        if hAbility == self:GetAbility() then return end

        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        self:Destroy()
    end
end