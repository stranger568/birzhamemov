LinkLuaModifier( "modifier_item_orchid_custom", "items/orchid", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_orchid_custom_active", "items/orchid", LUA_MODIFIER_MOTION_NONE )

item_orchid_custom = class({})

function item_orchid_custom:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("silence_duration")
	local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_item_orchid_custom_active", {duration = duration * (1 - target:GetStatusResistance())})
    target:EmitSound("DOTA_Item.Orchid.Activate")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_orchid")
    end
end

function item_orchid_custom:GetIntrinsicModifierName() 
    return "modifier_item_orchid_custom"
end

modifier_item_orchid_custom = class({})

function modifier_item_orchid_custom:IsHidden() return true end
function modifier_item_orchid_custom:IsPurgable() return false end
function modifier_item_orchid_custom:IsPurgeException() return false end
function modifier_item_orchid_custom:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_orchid_custom:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_orchid_custom:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_orchid_custom:GetModifierConstantManaRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
	end
end

function modifier_item_orchid_custom:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
	end
end

function modifier_item_orchid_custom:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

modifier_item_orchid_custom_active = class({})

function modifier_item_orchid_custom_active:GetEffectName()
    return "particles/items2_fx/orchid.vpcf"
end

function modifier_item_orchid_custom_active:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_orchid_custom_active:CheckState()
    return 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_item_orchid_custom_active:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_orchid_custom_active:OnCreated()
    if IsServer() then
        self.damage = 0
    end
end

function modifier_item_orchid_custom_active:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    self.damage = self.damage + params.damage
end

function modifier_item_orchid_custom_active:OnDestroy()
    if not IsServer() then return end
    if not self:GetAbility() then return end
    if self:GetRemainingTime() <= 0 then
        local damage = self.damage * self:GetAbility():GetSpecialValueFor("silence_damage_percent") * 0.01
        ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()), 1, Vector(damage))
        if damage > 0 then
            ApplyDamage({ attacker = self:GetCaster(), victim = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
        end
    end
end

LinkLuaModifier( "modifier_item_bloodthorn_custom", "items/orchid", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_bloodthorn_custom_active", "items/orchid", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_item_bloodthorn_arena_crit", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)

item_bloodthorn_custom = class({})

function item_bloodthorn_custom:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("silence_duration")
	local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_item_bloodthorn_custom_active", {duration = duration * (1 - target:GetStatusResistance())})
    target:EmitSound("DOTA_Item.Orchid.Activate")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_orchid")
    end
end

function item_bloodthorn_custom:GetIntrinsicModifierName() 
    return "modifier_item_bloodthorn_custom"
end

modifier_item_bloodthorn_custom = class({})

function modifier_item_bloodthorn_custom:IsHidden() return true end
function modifier_item_bloodthorn_custom:IsPurgable() return false end
function modifier_item_bloodthorn_custom:IsPurgeException() return false end
function modifier_item_bloodthorn_custom:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bloodthorn_custom:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_bloodthorn_custom:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_bloodthorn_custom:GetModifierConstantManaRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
	end
end

function modifier_item_bloodthorn_custom:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
	end
end

function modifier_item_bloodthorn_custom:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

modifier_item_bloodthorn_custom_active = class({})

function modifier_item_bloodthorn_custom_active:GetEffectName()
    return "particles/items2_fx/orchid.vpcf"
end

function modifier_item_bloodthorn_custom_active:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_bloodthorn_custom_active:CheckState()
    return 
    {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_EVADE_DISABLED] = true,
    }
end

function modifier_item_bloodthorn_custom_active:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_START,
    }
end

function modifier_item_bloodthorn_custom_active:OnCreated()
    if IsServer() then
        self.damage = 0
    end
end

function modifier_item_bloodthorn_custom_active:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    self.damage = self.damage + params.damage
end

function modifier_item_bloodthorn_custom_active:OnDestroy()
    if not IsServer() then return end
    if not self:GetAbility() then return end
    if self:GetRemainingTime() <= 0 then
        local damage = self.damage * self:GetAbility():GetSpecialValueFor("silence_damage_percent") * 0.01
        ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()), 1, Vector(damage))
        if damage > 0 then
            ApplyDamage({ attacker = self:GetCaster(), victim = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
        end
    end
end

function modifier_item_bloodthorn_custom_active:OnAttackStart(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_bloodthorn_arena_crit", {duration = 1.5})
end