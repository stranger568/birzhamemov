LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Kurumi_eight_bullet", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE )

Kurumi_eight_bullet = class({})

function Kurumi_eight_bullet:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_7")
end

function Kurumi_eight_bullet:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kurumi_eight_bullet:GetAOERadius()
    return self:GetSpecialValueFor("target_aoe")
end

function Kurumi_eight_bullet:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_PhantomLancer.Doppelganger.Cast")
    local doppleganger_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(doppleganger_particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(doppleganger_particle, 2, Vector(self:GetSpecialValueFor("target_aoe"), self:GetSpecialValueFor("target_aoe"), self:GetSpecialValueFor("target_aoe")))
    ParticleManager:SetParticleControl(doppleganger_particle, 3, Vector(self:GetSpecialValueFor("delay"), 0, 0))
    ParticleManager:ReleaseParticleIndex(doppleganger_particle)
    self.forward = self:GetCaster():GetForwardVector()
    self.first_unit = nil
    self.new_pos    = nil
    local illusion_count = 2
    if self:GetCaster():HasTalent("special_bonus_birzha_kurumi_8") then
        illusion_count = 3
    end
    local illusions_list = {}
    table.insert(illusions_list, self:GetCaster())
    local affected_units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("search_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
    for _, illusion_old in pairs(affected_units) do
        if illusion_old and illusion_old:IsIllusion() and illusion_old:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
            table.insert(illusions_list, illusion_old)
        end
    end
    for i=1,illusion_count do
        local outgoing_damage = self:GetSpecialValueFor("illusion_1_damage_out_pct")
        local incoming_damage = self:GetSpecialValueFor("illusion_1_damage_in_pct")
        if i > 1 then
            outgoing_damage = self:GetSpecialValueFor("illusion_2_damage_out_pct")
            incoming_damage = self:GetSpecialValueFor("illusion_2_damage_in_pct")
        end
        local illusions = BirzhaCreateIllusion(self:GetCaster(), self:GetCaster(), 
        {
            outgoing_damage = outgoing_damage,
            incoming_damage = incoming_damage,
            bounty_base     = 5,
            bounty_growth   = nil,
            outgoing_damage_structure   = nil,
            outgoing_damage_roshan      = nil,
            duration        = self:GetSpecialValueFor("illusion_duration") + self:GetSpecialValueFor("delay")
        } , 1, self:GetCaster():GetHullRadius(), true, true)
        illusions[1]:AddNewModifier(self:GetCaster(), self, "modifier_phantom_lancer_doppelwalk_illusion", {})
        illusions[1]:AddNewModifier(self:GetCaster(), self, "modifier_phantom_lancer_juxtapose_illusion", {})
        table.insert(illusions_list, illusions[1])
    end
    for _, unit in pairs(illusions_list) do
        unit:Purge(false, true, false, false, false)
        ProjectileManager:ProjectileDodge(unit)
        if not self.first_unit then
            self.first_unit = unit:entindex()
            self.new_pos    = self:GetCursorPosition()
        else
            if RollPercentage(50) then
                self.new_pos = self:GetCursorPosition() + Vector(RandomInt(-self:GetSpecialValueFor("target_aoe"), self:GetSpecialValueFor("target_aoe")), 0, 0)
            else
                self.new_pos = self:GetCursorPosition() + Vector(0, RandomInt(-self:GetSpecialValueFor("target_aoe"), self:GetSpecialValueFor("target_aoe")), 0)
            end
        end
        unit:AddNewModifier(self:GetCaster(), self, "modifier_Kurumi_eight_bullet", 
        {
            duration    = self:GetSpecialValueFor("delay"),
            pos_x       = self:GetCursorPosition().x,
            pos_y       = self:GetCursorPosition().y,
            pos_z       = self:GetCursorPosition().z,
            new_pos_x   = self.new_pos.x,
            new_pos_y   = self.new_pos.y,
            new_pos_z   = self.new_pos.z
        })
    end
end

modifier_Kurumi_eight_bullet = class({})

function modifier_Kurumi_eight_bullet:IsHidden()   return true end
function modifier_Kurumi_eight_bullet:IsPurgable() return false end

function modifier_Kurumi_eight_bullet:OnCreated(keys)
    if not IsServer() then return end
    
    self.new_pos = Vector(keys.new_pos_x, keys.new_pos_y, keys.new_pos_z)

    Timers:CreateTimer(FrameTime(), function()
        self:GetParent():AddNoDraw()
    end)
    
    local doppleganger_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(doppleganger_particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(doppleganger_particle, 1, self.new_pos + Vector(0,0,75))
    self:AddParticle(doppleganger_particle, false, false, -1, false, false)
end

function modifier_Kurumi_eight_bullet:OnDestroy()
    if not IsServer() then return end
    
    self:GetCaster():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
    
    self:GetParent():RemoveNoDraw()
    
    if self:GetParent():IsAlive() then
        FindClearSpaceForUnit(self:GetParent(), self.new_pos, true)
        GridNav:DestroyTreesAroundPoint(self.new_pos, 200, false)
    end

    self:GetParent():SetForwardVector(self:GetAbility().forward)

    self.spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.spawn_particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.spawn_particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(self.spawn_particle)
end

function modifier_Kurumi_eight_bullet:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE]   = true,
        [MODIFIER_STATE_STUNNED]        = true
    }
end

LinkLuaModifier( "modifier_kurumi_god", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kurumi_god_magic_immune", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE )

Kurumi_god = class({})

function Kurumi_god:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_4")
end

function Kurumi_god:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kurumi_god:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("Hero_SkywrathMage.AncientSeal.Target")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kurumi_god", { duration = duration } )
    if self:GetCaster():HasTalent("special_bonus_birzha_kurumi_5") then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kurumi_god_magic_immune", { duration = duration } )
    end
end

modifier_kurumi_god_magic_immune = class({})

function modifier_kurumi_god_magic_immune:IsPurgable() return false end
function modifier_kurumi_god_magic_immune:IsHidden() return true end

function modifier_kurumi_god_magic_immune:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_kurumi_god_magic_immune:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kurumi_god_magic_immune:CheckState()
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_kurumi_god_magic_immune:GetStatusEffectName()
    return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_kurumi_god_magic_immune:StatusEffectPriority()
    return 99999
end

modifier_kurumi_god = class({})

function modifier_kurumi_god:IsPurgable()
    return false
end

function modifier_kurumi_god:GetEffectName()
    return "particles/econ/events/ti6/mjollnir_shield_ti6.vpcf"
end

function modifier_kurumi_god:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_Kurumi_Absorption_buff", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Kurumi_Absorption_debuff", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)

Kurumi_Absorption = class({})

function Kurumi_Absorption:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_3")
end

function Kurumi_Absorption:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Kurumi_Absorption:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kurumi_Absorption:GetIntrinsicModifierName()
    return "modifier_Kurumi_Absorption_buff"
end

function Kurumi_Absorption:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end

    local duration = self:GetSpecialValueFor('duration')

    local damage = self:GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_2")

    local modifier_Kurumi_Absorption_buff = self:GetCaster():FindModifierByName("modifier_Kurumi_Absorption_buff")

    if modifier_Kurumi_Absorption_buff then
        damage = damage + (self:GetCaster():FindModifierByName("modifier_Kurumi_Absorption_buff"):GetStackCount() * self:GetSpecialValueFor("damage_per_kill"))
    end

    target:AddNewModifier(self:GetCaster(), self, "modifier_Kurumi_Absorption_debuff", {duration = self:GetSpecialValueFor("kill_duration")})

    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})

    self:GetCaster():EmitSound("kurskill")

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle )

    if self:GetCaster():HasTalent("special_bonus_birzha_kurumi_1") then
        local heal = damage / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_1")
        self:GetCaster():Heal(heal, self)
    end
end

modifier_Kurumi_Absorption_buff = class({})

function modifier_Kurumi_Absorption_buff:IsHidden() return self:GetStackCount() == 0 end
function modifier_Kurumi_Absorption_buff:RemoveOnDeath() return false end
function modifier_Kurumi_Absorption_buff:IsPurgable() return false end

function modifier_Kurumi_Absorption_buff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_TOOLTIP}
    return funcs
end

function modifier_Kurumi_Absorption_buff:OnTooltip(kv)
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_kill")
end

modifier_Kurumi_Absorption_debuff = class({})

function modifier_Kurumi_Absorption_debuff:IsPurgable()
    return false
end

function modifier_Kurumi_Absorption_debuff:IsHidden()
    return true
end

function modifier_Kurumi_Absorption_debuff:DeclareFunctions()
    local decfuncs = {MODIFIER_EVENT_ON_DEATH}
    return decfuncs
end

function modifier_Kurumi_Absorption_debuff:OnDeath(params)
    local caster = self:GetCaster()
    local target = params.unit
    if target:IsRealHero() and caster:GetTeamNumber() ~= target:GetTeamNumber() and target == self:GetParent() and (params.attacker == self:GetCaster() or (params.attacker:IsIllusion() and params.attacker:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID())) then   
        local mana_restore = self:GetAbility():GetSpecialValueFor("mana_restore")
        self:GetCaster():GiveMana(mana_restore)   
        local modifier_bonus = self:GetCaster():FindModifierByName("modifier_Kurumi_Absorption_buff")
        if modifier_bonus then
            modifier_bonus:IncrementStackCount()
        end
    end
end

LinkLuaModifier("modifier_kurumi_zafkiel", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kurumi_zafkiel_aura", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kurumi_donate_zafkiel", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)

Kurumi_Zafkiel = class({})

function Kurumi_Zafkiel:OnSpellStart()
    if not IsServer() then return end

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_6")

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kurumi_zafkiel_aura", {duration = duration})

    if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 26) then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kurumi_donate_zafkiel", {duration = duration})
    end

    EmitGlobalSound("kurult")
end

modifier_kurumi_zafkiel_aura = class({})

function modifier_kurumi_zafkiel_aura:DeclareFunctions()
    local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
    return funcs
end

function modifier_kurumi_zafkiel_aura:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_kurumi_zafkiel_aura:IsAura() return true end

function modifier_kurumi_zafkiel_aura:GetAuraRadius()
    return 999999
end

function modifier_kurumi_zafkiel_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_kurumi_zafkiel_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_kurumi_zafkiel_aura:GetAuraSearchFlags()
    if self:GetCaster():HasTalent("special_bonus_birzha_kurumi_6") then
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    end
    return DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
end

function modifier_kurumi_zafkiel_aura:GetModifierAura()
    return "modifier_kurumi_zafkiel"
end

function modifier_kurumi_zafkiel_aura:GetAuraDuration() return 0 end

function modifier_kurumi_zafkiel_aura:GetAuraEntityReject(target)
    if not IsServer() then return end
    if target == self:GetCaster() or (target:IsIllusion() and target:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID()) or target:HasModifier("modifier_Dio_Za_Warudo") then
        return true
    else
        return false
    end
end

modifier_kurumi_zafkiel = class({})

function modifier_kurumi_zafkiel:OnCreated()
    if not IsServer() then return end

    local particle = ParticleManager:CreateParticle("particles/kurumi_ultimate_debuff_v2.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(175, 175, 175))
    self:AddParticle(particle, false, false, -1, false, false)

    self.damage_taken = 0
end

function modifier_kurumi_zafkiel:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_kurumi_zafkiel:OnTakeDamage(params)
    if not IsServer() then return end
    local unit = params.unit
    if unit == self:GetParent() then
        self.damage_taken = self.damage_taken + params.damage
    end
end

function modifier_kurumi_zafkiel:OnDestroy()
    if not IsServer() then return end

    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = 0.1 })

    if self:GetParent():GetHealth() - self.damage_taken <= 0 then 
        self:GetParent():Kill(self:GetAbility(), self:GetCaster())
        self.damage_taken = 0 
        return
    end

    self:GetParent():SetHealth(self:GetParent():GetHealth() - self.damage_taken)

    self.damage_taken = 0 
end

function modifier_kurumi_zafkiel:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true, 
    }
end

function modifier_kurumi_zafkiel:GetStatusEffectName()
    return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
end

modifier_kurumi_donate_zafkiel = class({})

function modifier_kurumi_donate_zafkiel:IsHidden() return true end

function modifier_kurumi_donate_zafkiel:IsPurgable() return false end

function modifier_kurumi_donate_zafkiel:IsPurgeException() return false end

function modifier_kurumi_donate_zafkiel:GetEffectName()
    return "particles/kurumi/kurumi_ultimate_donate.vpcf"
end

function modifier_kurumi_donate_zafkiel:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_kurumi_scepter_buff", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)

Kurumi_scepter = class({})

function Kurumi_scepter:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function Kurumi_scepter:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function Kurumi_scepter:OnSpellStart()
    if not IsServer() then return end
    local info = 
    {
        Target = self:GetCursorTarget(),
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_base_attack.vpcf",
        iMoveSpeed = 1500,
        bDodgeable = false,
        bVisibleToEnemies = true, 
        bProvidesVision = false,
    }
    self:GetCaster():EmitSound("Hero_Sniper.ShrapnelShoot")
    ProjectileManager:CreateTrackingProjectile(info)
end


function Kurumi_scepter:OnProjectileHit(target, vLocation)
    if not IsServer() then return end
    if not target then return end
    target:EmitSound("Hero_Sniper.ProjectileImpact")
    target:AddNewModifier(self:GetCaster(), self, "modifier_kurumi_scepter_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_kurumi_scepter_buff = class({})

function modifier_kurumi_scepter_buff:IsPurgable() return true end

function modifier_kurumi_scepter_buff:OnCreated()
    self.movespeed = 0
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_ally")

    else
        self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_enemy")
    end
end

function modifier_kurumi_scepter_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }

    return funcs
end

function modifier_kurumi_scepter_buff:GetModifierMoveSpeed_Absolute(keys)
    return self.movespeed
end

function modifier_kurumi_scepter_buff:GetStatusEffectName() return "particles/status_fx/status_effect_purple_poison.vpcf" end

Kurumi_shard = class({})

function Kurumi_shard:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function Kurumi_shard:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function Kurumi_shard:OnSpellStart()
    if not IsServer() then return end
    local info = {
        Target = self:GetCursorTarget(),
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "particles/kurumi_shard_attack.vpcf",
        iMoveSpeed = 1500,
        bDodgeable = false,
        bVisibleToEnemies = true, 
        bProvidesVision = false,
    }
    self:GetCaster():EmitSound("kurumi_shard")
    ProjectileManager:CreateTrackingProjectile(info)
end


function Kurumi_shard:OnProjectileHit(target, vLocation)
    if not IsServer() then return end
    if not target then return end
    for i = 0, 23 do
        local current_ability = target:GetAbilityByIndex(i)
        if current_ability and not current_ability:IsAttributeBonus() and current_ability:IsCooldownReady() then
            current_ability:StartCooldown( 2 )
        end
    end
end
