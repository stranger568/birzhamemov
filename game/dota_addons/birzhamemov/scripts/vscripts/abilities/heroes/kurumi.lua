LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kurumi_god", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE )

Kurumi_god = class({})

function Kurumi_god:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kurumi_god:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kurumi_god:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("Hero_SkywrathMage.AncientSeal.Target")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kurumi_god", { duration = duration } )
end

modifier_kurumi_god = class({})

function modifier_kurumi_god:IsPurgable()
    return false
end

function modifier_kurumi_god:GetEffectName()
    return "particles/econ/events/ti7/mjollnir_shield_ti7.vpcf"
end

function modifier_kurumi_god:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kurumi_god:CheckState()
    if not self:GetCaster():HasTalent("special_bonus_birzha_kurumi_5") then return end
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }

    return state
end

LinkLuaModifier("modifier_Kurumi_Absorption_buff", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)

Kurumi_Absorption = class({})

function Kurumi_Absorption:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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
    local duration = self:GetSpecialValueFor('duration')
    local damage = self:GetSpecialValueFor('damage') + self:GetCaster():GetAgility() + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_3") + (self:GetCaster():FindModifierByName("modifier_Kurumi_Absorption_buff"):GetStackCount() * 5)
    if target:TriggerSpellAbsorb(self) then return end
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
    self:GetCaster():EmitSound("kurskill")
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex( particle )
    if self:GetCaster():HasTalent("special_bonus_birzha_kurumi_2") then
        self:GetCaster():Heal(damage, self)
    end
end

modifier_Kurumi_Absorption_buff = class({})

function modifier_Kurumi_Absorption_buff:RemoveOnDeath() return false end

function modifier_Kurumi_Absorption_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP
    }

    return funcs
end

function modifier_Kurumi_Absorption_buff:OnTooltip(kv)
    return self:GetStackCount() * 5
end

function modifier_Kurumi_Absorption_buff:OnDeath(kv)
    if not IsServer() then return end
    local attacker = kv.attacker
    if self:GetParent() == attacker then
        if kv.inflictor and kv.inflictor ~= nil and kv.inflictor:GetName() == "Kurumi_Absorption" then
            self:GetCaster():GiveMana(50)
            self:IncrementStackCount()
        end
    end
end











LinkLuaModifier("modifier_kurumi_zafkiel", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kurumi_zafkiel_aura", "abilities/heroes/kurumi.lua", LUA_MODIFIER_MOTION_NONE)

Kurumi_Zafkiel = class({})

function Kurumi_Zafkiel:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kurumi_1")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kurumi_zafkiel_aura", {duration = duration})
    self:GetCaster():EmitSound("kurult")
end

modifier_kurumi_zafkiel_aura = class({})

function modifier_kurumi_zafkiel_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_kurumi_zafkiel_aura:OnAttackLanded(kv)
    if not IsServer() then return end
    local attacker = kv.attacker
    local target = kv.target
    local damage = kv.damage
    if self:GetParent() == attacker then
	    if attacker:GetTeam() == target:GetTeam() then
			return
		end 
        self:GetParent():Heal(damage, self:GetAbility())
    end
end

function modifier_kurumi_zafkiel_aura:IsAura() return true end

function modifier_kurumi_zafkiel_aura:GetAuraRadius()
    return 999999
end

function modifier_kurumi_zafkiel_aura:GetAuraSearchTeam()
    if self:GetCaster():HasTalent("special_bonus_birzha_kurumi_4") then
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_kurumi_zafkiel_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_kurumi_zafkiel_aura:GetModifierAura()
    return "modifier_kurumi_zafkiel"
end

modifier_kurumi_zafkiel = class({})

function modifier_kurumi_zafkiel_aura:GetAuraEntityReject(target)
    if not IsServer() then return end
    if target == self:GetCaster() or target:IsIllusion() then
        return true
    else
        return false
    end
end

function modifier_kurumi_zafkiel:IsDebuff()
    return true
end

function modifier_kurumi_zafkiel:OnCreated()
    if not IsServer() then return end
    if self:GetParent().particle then
        ParticleManager:DestroyParticle(self:GetParent().particle, false)
    end
    self:GetParent().particle = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_mace_of_aeons/fv_chronosphere_aeons.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self:GetParent().particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self:GetParent().particle, 1, Vector(100, 100, 0))
    if not self:GetParent().damage_taken then
        self:GetParent().damage_taken = 0 
    end
end

function modifier_kurumi_zafkiel:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_kurumi_zafkiel:OnTakeDamage(keys)
    local unit = keys.unit
    if not IsServer() then return end
    if unit == self:GetParent() then
        local damage = keys.damage
        self:GetParent().damage_taken = self:GetParent().damage_taken + damage
    end
end

function modifier_kurumi_zafkiel:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self:GetParent().particle, false)
    if self:GetParent():GetHealth() - self:GetParent().damage_taken <=0 then 
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetParent().damage_taken, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
        self:GetParent().damage_taken = 0 
        return
    end
    self:GetParent():SetHealth(self:GetParent():GetHealth() - self:GetParent().damage_taken)
    self:GetParent().damage_taken = 0 
end

function modifier_kurumi_zafkiel:OnRemoved()
    if not IsServer() then return end
    self:GetParent():AddNewModifier( self:GetAbility():GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = 0.1 }  )
    ParticleManager:DestroyParticle(self:GetParent().particle, false)
    if self:GetParent():GetHealth() - self:GetParent().damage_taken <=0 then 
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetParent().damage_taken, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
        self:GetParent().damage_taken = 0 
        return
    end
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self:GetParent().damage_taken, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
    self:GetParent().damage_taken = 0 
end

function modifier_kurumi_zafkiel:CheckState()
    return {[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true, }
end

function modifier_kurumi_zafkiel:GetStatusEffectName()
    return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
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
    local info = {
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