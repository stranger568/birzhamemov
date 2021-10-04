LinkLuaModifier( "modifier_ns_tricks_damage", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Ns_Tricks = class({})

function Ns_Tricks:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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

function Ns_Tricks:OnSpellStart()
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local info = {
        EffectName = "particles/ns/ns_tricks.vpcf",
        Ability = self,
        iMoveSpeed = 600,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("xzns")
end

function Ns_Tricks:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:TriggerSpellAbsorb( self ) ) then
        local modifiers = {
            "modifier_silenced",
            "modifier_disarmed",
            "modifier_birzha_stunned",
            "modifier_shadow_shaman_voodoo",
        }

        local chance = RandomInt(1,3)
        if target:IsAncient() then return end

        if not self:GetCaster():HasTalent("special_bonus_birzha_ns_1") then
            if target:IsMagicImmune() then return end
        end

        if chance == 1 then
            local modifier = modifiers[RandomInt(1, #modifiers)]
            target:AddNewModifier( self:GetCaster(), self, modifier, { duration = 5 } )  
        elseif chance == 2 then
            target:AddNewModifier( self:GetCaster(), self, "modifier_ns_tricks_damage", { duration = 5 } ) 
        elseif chance == 3 then
            local damage = RandomInt(100,1000)
            ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
        end
    end
    return true
end

modifier_ns_tricks_damage = class({})

function modifier_ns_tricks_damage:IsPurgable() return false end
function modifier_ns_tricks_damage:IsHidden() return true end

function modifier_ns_tricks_damage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end

function modifier_ns_tricks_damage:GetModifierPreAttack_BonusDamage( params )
    return 500
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
    local info = {
        EffectName = "particles/econ/items/wisp/wisp_tether_ti7.vpcf",
        Ability = self,
        iMoveSpeed = 2000,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    
end

function Ns_FullCounter:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:TriggerSpellAbsorb( self ) ) then
        if target:IsMagicImmune() then return end
        local duration = self:GetSpecialValueFor("duration")
        self:GetCaster():EmitSound("kontra")
        target:AddNewModifier( self:GetCaster(), self, "modifier_ns_fullcounter_debuff", { duration = duration * (1 - target:GetStatusResistance()) } ) 
    end
    return true
end

modifier_ns_fullcounter_debuff = class({})

function modifier_ns_fullcounter_debuff:IsPurgable() return false end

function modifier_ns_fullcounter_debuff:CheckState()
    return {[MODIFIER_STATE_SILENCED] = true,
    [MODIFIER_STATE_DISARMED] = true,
[MODIFIER_STATE_PASSIVES_DISABLED] = true,
[MODIFIER_STATE_ROOTED] = true,
[MODIFIER_STATE_EVADE_DISABLED] = true,
[MODIFIER_STATE_STUNNED] = true,
[MODIFIER_STATE_NIGHTMARED] = true,}
end


function modifier_ns_fullcounter_debuff:DeclareFunctions()
    local funcs = {
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
    self:SetStackCount(1)
end

function modifier_ns_TricksMaster:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources(false, false, true)
        local bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect") + self:GetCaster():FindTalentValue("special_bonus_birzha_ns_2")
        self:SetStackCount(self:GetStackCount() + bonus_intellect)
    end
end

function modifier_ns_TricksMaster:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_ns_TricksMaster:GetModifierBonusStats_Intellect( params )
    return self:GetStackCount()
end

LinkLuaModifier("modifier_ns_kbu_delay", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ns_kbu_duration", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE)

Ns_KBU = class({})

function Ns_KBU:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ns_KBU:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ns_KBU:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("ns1")
    return true
end

function Ns_KBU:OnAbilityPhaseInterrupted()
    self:GetCaster():StopSound("ns1")
end

function Ns_KBU:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ns_kbu_delay", {duration = 0.65})
end

modifier_ns_kbu_delay = class({})

function modifier_ns_kbu_delay:IsHidden()   return true end
function modifier_ns_kbu_delay:IsPurgable() return false end

function modifier_ns_kbu_delay:OnCreated()
    if not IsServer() then return end
    local split_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_primal_split.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(split_particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControlForward(split_particle, 0, self:GetParent():GetForwardVector())
    self:AddParticle(split_particle, false, false, -1, false, false)
end

function modifier_ns_kbu_delay:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE]   = true,
        [MODIFIER_STATE_OUT_OF_GAME]    = true,
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end

function modifier_ns_kbu_delay:OnDestroy()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    self.kbu = {}
    self.kbu_entindexes = {}

    if self:GetParent():IsAlive() and self:GetAbility() then
        self:GetCaster():EmitSound("ns2")
        local split_modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ns_kbu_duration", {duration = duration})
        local earth_panda   = CreateUnitByName("npc_dota_dread_"..self:GetAbility():GetLevel(), self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100, true, self:GetParent(), self:GetParent(), self:GetCaster():GetTeamNumber())
        local storm_panda   = CreateUnitByName("npc_dota_xbost_"..self:GetAbility():GetLevel(), RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, 120, 0), self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        local fire_panda    = CreateUnitByName("npc_dota_inmate_"..self:GetAbility():GetLevel(), RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, -120, 0), self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        

        
        table.insert(self.kbu, earth_panda)
        table.insert(self.kbu, storm_panda)
        table.insert(self.kbu, fire_panda)
        table.insert(self.kbu_entindexes, earth_panda:entindex())
        
        if self:GetCaster() == self:GetParent() then
            table.insert(self.kbu_entindexes, storm_panda:entindex())
            table.insert(self.kbu_entindexes, fire_panda:entindex())
        end
        
        self:GetParent():FollowEntity(earth_panda, false)
        
        if split_modifier then
            split_modifier.kbu               = self.kbu
            split_modifier.pandas_entindexes    = self.kbu_entindexes
        end
        
        for _, panda in pairs(self.kbu) do
            panda:SetForwardVector(self:GetParent():GetForwardVector())
            panda:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ns_kbu_duration", {duration = duration, parent_entindex = self:GetParent():entindex()})
            panda:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
            panda:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        end
        self:GetParent():AddNoDraw()
    end
end

modifier_ns_kbu_duration = class({})

function modifier_ns_kbu_duration:IsPurgable()    return false end

function modifier_ns_kbu_duration:OnCreated(keys)
    if not IsServer() then return end

    if keys and keys.parent_entindex then
        self.parent = EntIndexToHScript(keys.parent_entindex)
    end
end

function modifier_ns_kbu_duration:OnDestroy()
    if not IsServer() then return end
    
    if self:GetParent():IsHero() then
        self:GetParent():EmitSound("Hero_Brewmaster.PrimalSplit.Return")
        self:GetParent():FollowEntity(nil, false)
        self:GetParent():RemoveNoDraw()
    end
end
        
function modifier_ns_kbu_duration:CheckState()
    if not self:GetParent():IsHero() then
        return 
    end

    return {
        [MODIFIER_STATE_INVULNERABLE]       = self:GetParent():IsHero(),
        [MODIFIER_STATE_OUT_OF_GAME]        = self:GetParent():IsHero(),
    
        [MODIFIER_STATE_STUNNED]            = self:GetParent():IsHero(),
        [MODIFIER_STATE_NOT_ON_MINIMAP]     = self:GetParent():IsHero(),
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = self:GetParent():IsHero(),
        [MODIFIER_STATE_UNSELECTABLE]       = self:GetParent():IsHero(),
    }
end

function modifier_ns_kbu_duration:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_ns_kbu_duration:OnDeath(keys)
    if keys.unit == self:GetParent() and not self:GetParent():IsHero() then
        if self:GetRemainingTime() > 0 then
            if self.parent and not self.parent:IsNull() and self.parent:HasModifier("modifier_ns_kbu_duration") and self.parent:FindModifierByName("modifier_ns_kbu_duration").pandas_entindexes then
                local bNoneAlive    = true
                
                for _, panda in pairs(self.parent:FindModifierByName("modifier_ns_kbu_duration").kbu) do
                    if not panda:IsNull() and panda:IsAlive() then
                        bNoneAlive = false
                        self.parent:FollowEntity(panda, false)
                        
                        if self.parent ~= self:GetCaster() then
                            table.insert(self.parent:FindModifierByName("modifier_ns_kbu_duration").kbu_entindexes, panda:entindex())
                            panda:SetOwner(self.parent)
                            panda:SetControllableByPlayer(self.parent:GetPlayerID(), true)
                        end
                        
                        break
                    end
                end
                
                if bNoneAlive then
                    self.parent:RemoveModifierByName("modifier_ns_kbu_duration")
                    if keys.attacker ~= self:GetParent() then
                        local damageTable = {
                            victim = self.parent,
                            attacker = keys.attacker,
                            damage = 100000000,
                            damage_type = DAMAGE_TYPE_PURE,
                            ability = self:GetAbility(),
                            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                        }
                        ApplyDamage(damageTable)
                    end
                end
            end
        end
    end
end



LinkLuaModifier("modifier_xbost_rapier", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)

Xbost_one_rapier = class({})

function Xbost_one_rapier:GetIntrinsicModifierName()
    return "modifier_xbost_rapier"
end

modifier_xbost_rapier = class({})

function modifier_xbost_rapier:IsHidden()
    return true
end

function modifier_xbost_rapier:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
    return declfuncs
end

function modifier_xbost_rapier:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

LinkLuaModifier("modifier_xbost_rapier_2", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)

Xbost_two_rapier = class({})

function Xbost_two_rapier:GetIntrinsicModifierName()
    return "modifier_xbost_rapier_2"
end

modifier_xbost_rapier_2 = class({})

function modifier_xbost_rapier_2:IsHidden()
    return true
end

function modifier_xbost_rapier_2:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
    return declfuncs
end

function modifier_xbost_rapier_2:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end




LinkLuaModifier("modifier_dread_aura", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dread_armor", "abilities/heroes/ns.lua", LUA_MODIFIER_MOTION_NONE)

Dread_Armor = class({})

function Dread_Armor:GetIntrinsicModifierName()
    return "modifier_dread_aura"
end

function Dread_Armor:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

modifier_dread_aura = class({})

function modifier_dread_aura:IsPurgable() return false end
function modifier_dread_aura:IsHidden() return true end
function modifier_dread_aura:IsAura() return true end

function modifier_dread_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY end

function modifier_dread_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_dread_aura:GetModifierAura()
    return "modifier_dread_armor"
end

function modifier_dread_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

modifier_dread_armor = class({})

function modifier_dread_armor:IsPurgable() return false end

function modifier_dread_armor:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, }
    return funcs
end

function modifier_dread_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end