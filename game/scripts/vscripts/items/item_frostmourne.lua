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

function modifier_item_frostmorn:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_item_frostmorn:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('strength')
    end
end

function modifier_item_frostmorn:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('agility')
    end
end

function modifier_item_frostmorn:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('intellect')
    end
end

function modifier_item_frostmorn:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
    end
end

function modifier_item_frostmorn:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_health')
    end
end

function modifier_item_frostmorn:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_mana')
    end
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

    local duration = self:GetAbility():GetSpecialValueFor('cold_duration')
	keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_frostmorn_debuff", {duration = duration})
end

modifier_item_frostmorn_debuff = class({})

function modifier_item_frostmorn_debuff:GetTexture()
    return "items/frostmourne"
end

function modifier_item_frostmorn_debuff:OnCreated()
    self.cold_attack_speed = self:GetAbility():GetSpecialValueFor("cold_attack_speed")
    self.cold_movement_speed = self:GetAbility():GetSpecialValueFor("cold_movement_speed")
    self.regen_reduce = self:GetAbility():GetSpecialValueFor("regen_reduce")
end

function modifier_item_frostmorn_debuff:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,

    }

    return funcs
end

function modifier_item_frostmorn_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.cold_attack_speed
end

function modifier_item_frostmorn_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.cold_movement_speed
end

function modifier_item_frostmorn_debuff:Custom_HealAmplifyReduce()
    return self.regen_reduce
end

function modifier_item_frostmorn_debuff:GetModifierHPRegenAmplify_Percentage()
    return self.regen_reduce
end

function modifier_item_frostmorn_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_item_frostmorn_debuff:StatusEffectPriority()
    return 10
end

modifier_item_frostmorn_active = class({})


function modifier_item_frostmorn_active:GetTexture()
    return "items/frostmourne"
end

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

    if not self:GetAbility() then
        if not self:IsNull() then
            self:Destroy()
        end
        return 
    end

    local duration_hex = self:GetAbility():GetSpecialValueFor('duration_hex')

	keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_frostmorn_debuff_hex", {duration = duration_hex * (1 - keys.target:GetStatusResistance())})
    if not self:IsNull() then
        self:Destroy()
    end
end

modifier_item_frostmorn_debuff_hex = class({})

function modifier_item_frostmorn_debuff_hex:GetTexture()
    return "items/frostmourne"
end

function modifier_item_frostmorn_debuff_hex:OnCreated()
	if not IsServer() then return end
    local caster = self:GetCaster()

    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end
	local player = caster:GetPlayerID()
	self:GetParent():EmitSound("DOTA_Item.Maim")
	self:GetParent():EmitSound("DOTA_Item.Sheepstick.Activate")
	if DonateShopIsItemBought(player, 50) then
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