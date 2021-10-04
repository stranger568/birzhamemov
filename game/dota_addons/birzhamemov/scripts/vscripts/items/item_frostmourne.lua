LinkLuaModifier("modifier_item_frostmorn", "items/item_frostmourne", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_frostmorn_active", "items/item_frostmourne", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_frostmorn_debuff", "items/item_frostmourne", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_frostmorn_debuff_hex", "items/item_frostmourne", LUA_MODIFIER_MOTION_NONE)

item_frostmorn = class({})

function item_frostmorn:GetIntrinsicModifierName()
    return "modifier_item_frostmorn"
end

function item_frostmorn:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("Hero_Crystal.Frostbite")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_frostmorn_active", {duration = duration})
end


modifier_item_frostmorn = class({})

function modifier_item_frostmorn:IsHidden()
	return true
end

function modifier_item_frostmorn:IsPurgable()
    return false
end

function modifier_item_frostmorn:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_frostmorn:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_BASE_MANA_REGEN,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_item_frostmorn:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor('strength')
end

function modifier_item_frostmorn:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor('agility')
end

function modifier_item_frostmorn:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('intellect')
end

function modifier_item_frostmorn:GetModifierBaseRegen()
    return self:GetAbility():GetSpecialValueFor('regenmana')
end

function modifier_item_frostmorn:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_item_frostmorn:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_mana')
end

function modifier_item_frostmorn:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()

    if attacker ~= keys.attacker then
        return
    end

    local target = keys.target

    if attacker:GetTeam() == target:GetTeam() then
        return
    end 
    if target:IsOther() then
        return nil
    end

    local dur_range = self:GetAbility():GetSpecialValueFor('cold_duration_ranged')
    local dur_melee = self:GetAbility():GetSpecialValueFor('cold_duration_melee')

	if self:GetParent():IsRangedAttacker() then
		keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_frostmorn_debuff", {duration = dur_range})
	else
		keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_frostmorn_debuff", {duration = dur_melee})
	end
end

modifier_item_frostmorn_debuff = class({})

function modifier_item_frostmorn_debuff:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_item_frostmorn_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('cold_attack_speed')
end

function modifier_item_frostmorn_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('cold_movement_speed')
end

function modifier_item_frostmorn_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_item_frostmorn_debuff:StatusEffectPriority()
    return 10
end

modifier_item_frostmorn_active = class({})

function modifier_item_frostmorn_active:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)
end


function modifier_item_frostmorn_active:DeclareFunctions()
    local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_item_frostmorn_active:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()

    if attacker ~= keys.attacker then
        return
    end

    local target = keys.target

    if attacker:GetTeam() == target:GetTeam() then
        return
    end 
    if target:IsOther() then
        return nil
    end

    local duration_hex = self:GetAbility():GetSpecialValueFor('duration_hex')

	keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_frostmorn_debuff_hex", {duration = duration_hex * (1 - keys.target:GetStatusResistance())})
	self:Destroy()
end

modifier_item_frostmorn_debuff_hex = class({})

function modifier_item_frostmorn_debuff_hex:OnCreated()
	if not IsServer() then return end
	local player = self:GetCaster():GetPlayerID()
	self:GetParent():EmitSound("DOTA_Item.Maim")
	self:GetParent():EmitSound("DOTA_Item.Sheepstick.Activate")
	if IsUnlockedInPass(player, "reward85") then
		self.model = "models/items/courier/flightless_dod/flightless_dod.vmdl"
	else
		self.model = "models/props_gameplay/pig_blue.vmdl"
	end
end

function modifier_item_frostmorn_debuff_hex:CheckState()
    local state = {
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    return state
end

function modifier_item_frostmorn_debuff_hex:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MODEL_CHANGE,
                      MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,}
    return decFuncs
end

function modifier_item_frostmorn_debuff_hex:GetModifierMoveSpeed_Absolute()
    return 140   
end

function modifier_item_frostmorn_debuff_hex:GetModifierModelChange()
    return self.model   
end