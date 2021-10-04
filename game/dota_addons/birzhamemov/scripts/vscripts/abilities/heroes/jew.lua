LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_jew_flame_guard", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)

jew_flame_guard = class({}) 

function jew_flame_guard:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function jew_flame_guard:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function jew_flame_guard:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function jew_flame_guard:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jew_flame_guard", {duration = duration})
    self:GetCaster():EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
    self:GetCaster():EmitSound("Hero_EmberSpirit.FlameGuard.Loop") 
end

modifier_jew_flame_guard = class ({})

function modifier_jew_flame_guard:IsPurgable() return true end

function modifier_jew_flame_guard:GetEffectName()
    return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_jew_flame_guard:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jew_flame_guard:OnCreated(keys)
    if not IsServer() then return end
    local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    local damage = self:GetAbility():GetSpecialValueFor("damage_per_second") + self:GetCaster():FindTalentValue("special_bonus_birzha_jew_3")
    local absorb_amount = (self:GetAbility():GetSpecialValueFor("absorb_amount") + self:GetCaster():FindTalentValue("special_bonus_birzha_jew_1"))
    self.damage = damage * tick_interval
    self.remaining_health = absorb_amount
    self:SetStackCount(self.remaining_health)
    self:StartIntervalThink(tick_interval)
end

function modifier_jew_flame_guard:OnRefresh(keys)
    if not IsServer() then return end
    local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
    local damage = self:GetAbility():GetSpecialValueFor("damage_per_second") + self:GetCaster():FindTalentValue("special_bonus_birzha_jew_3")
    local absorb_amount = (self:GetAbility():GetSpecialValueFor("absorb_amount") + self:GetCaster():FindTalentValue("special_bonus_birzha_jew_1"))
    self.damage = damage * tick_interval
    self.remaining_health = absorb_amount
    self:SetStackCount(self.remaining_health)
    self:StartIntervalThink(tick_interval)
end

function modifier_jew_flame_guard:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
end

function modifier_jew_flame_guard:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    if self.remaining_health <= 0 then
        self:GetParent():RemoveModifierByName("modifier_jew_flame_guard")
    else
        local nearby_enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, enemy in pairs(nearby_enemies) do
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end
end

function modifier_jew_flame_guard:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_jew_flame_guard:GetModifierAvoidDamage(keys)
    if not IsServer() then return end
    if keys.damage_type == DAMAGE_TYPE_MAGICAL then
        self.remaining_health = self.remaining_health - keys.original_damage
        self:SetStackCount(self.remaining_health)
        return 1
    else
        return 0
    end
end

LinkLuaModifier("modifier_evrei_zhad", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evrei_zhad_damage_buff", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evrei_zhad_damage_debuff", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)

evrei_zhad = class({})

function evrei_zhad:GetIntrinsicModifierName()
    return "modifier_evrei_zhad"
end

modifier_evrei_zhad = class ({})

function modifier_evrei_zhad:IsHidden()
    return true
end

function modifier_evrei_zhad:IsPurgable()
    return false
end

function modifier_evrei_zhad:DeclareFunctions()
    local declfuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}

    return declfuncs
end

function modifier_evrei_zhad:OnAttackLanded(kv)
    if not IsServer() then return end
    local attacker = kv.attacker
    local target = kv.target
    if self:GetParent() == attacker then
	    if attacker:GetTeam() == target:GetTeam() then
			return
		end 
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if target:IsAncient() then return end
        if target:IsOther() then
            return nil
        end
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        local damage_steal = self:GetAbility():GetSpecialValueFor("damage_steal") 
        if self:GetCaster():HasTalent("special_bonus_birzha_jew_4") then damage_steal = damage_steal * 3 end
        local current_stack_buff = self:GetParent():GetModifierStackCount( "modifier_evrei_zhad_damage_buff", self:GetParent() )
        local current_stack_debuff = target:GetModifierStackCount( "modifier_evrei_zhad_damage_debuff", self:GetParent() )

        local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
        ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        if self:GetParent():HasModifier("modifier_evrei_zhad_damage_buff") then
            self:GetParent():SetModifierStackCount( "modifier_evrei_zhad_damage_buff", self:GetAbility(), current_stack_buff + damage_steal )
            self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_buff", { duration = duration } )
        else
            self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_buff", { duration = duration } )
            self:GetParent():SetModifierStackCount( "modifier_evrei_zhad_damage_buff", self:GetAbility(), damage_steal )
        end
        
        if target:HasModifier("modifier_evrei_zhad_damage_debuff") then
            target:SetModifierStackCount( "modifier_evrei_zhad_damage_debuff", self:GetAbility(), current_stack_debuff + damage_steal )
            target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_debuff", { duration = duration } )
        else
            target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_evrei_zhad_damage_debuff", { duration = duration } )
            target:SetModifierStackCount( "modifier_evrei_zhad_damage_debuff", self:GetAbility(), damage_steal )
        end
    end
end

modifier_evrei_zhad_damage_buff = class ({})

function modifier_evrei_zhad_damage_buff:IsPurgable()
    return true
end

function modifier_evrei_zhad_damage_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
    return declfuncs
end

function modifier_evrei_zhad_damage_buff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * 1
end

modifier_evrei_zhad_damage_debuff = class ({})

function modifier_evrei_zhad_damage_debuff:IsPurgable()
    return true
end

function modifier_evrei_zhad_damage_debuff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
    return declfuncs
end

function modifier_evrei_zhad_damage_debuff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * -1
end


LinkLuaModifier("modifier_evrei_znak", "abilities/heroes/jew.lua", LUA_MODIFIER_MOTION_NONE)

evrei_znak = class({})

function evrei_znak:GetIntrinsicModifierName()
    return "modifier_evrei_znak"
end

modifier_evrei_znak = class({})

function modifier_evrei_znak:IsHidden()
    return true
end

function modifier_evrei_znak:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
    return declfuncs
end

function modifier_evrei_znak:GetModifierBonusStats_Agility()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_evrei_znak:GetModifierBonusStats_Strength()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

LinkLuaModifier("modifier_evrei_gold", "abilities/heroes/jew", LUA_MODIFIER_MOTION_NONE)

evrei_ult = class({}) 

function evrei_ult:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function evrei_ult:GetIntrinsicModifierName()
    return "modifier_evrei_gold"
end

modifier_evrei_gold = class({})

function modifier_evrei_gold:IsHidden()
    return true
end

function modifier_evrei_gold:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_evrei_gold:OnIntervalThink()
    if not IsServer() then return end
    local money = self:GetAbility():GetSpecialValueFor("money_amount") + self:GetCaster():FindTalentValue("special_bonus_birzha_jew_2")
    if self:GetParent():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources(false, false, true)
        self:GetParent():ModifyGold( money, true, 0 )
        self:GetParent():EmitSound("DOTA_Item.Hand_Of_Midas")
        if IsUnlockedInPass(self:GetParent():GetPlayerID(), "reward77") then
            local midas_particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())    
            ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        else
            local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())   
            ParticleManager:SetParticleControlEnt(midas_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        end
    end
end