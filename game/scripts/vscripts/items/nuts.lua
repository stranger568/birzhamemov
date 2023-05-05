LinkLuaModifier( "modifier_item_nuts", "items/nuts", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_nuts_buff", "items/nuts", LUA_MODIFIER_MOTION_NONE )

item_nuts = class({})

function item_nuts:OnSpellStart()
	if not IsServer() then return end
    self:GetCaster():EmitSound("DOTA_Item.MaskOfMadness.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_nuts_buff", {duration = self:GetSpecialValueFor("duration")})
end

function item_nuts:GetIntrinsicModifierName() 
    return "modifier_item_nuts"
end

modifier_item_nuts = class({})

function modifier_item_nuts:IsHidden() return true end
function modifier_item_nuts:IsPurgable() return false end
function modifier_item_nuts:IsPurgeException() return false end
function modifier_item_nuts:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_nuts:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_nuts:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_nuts:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
    end
end

function modifier_item_nuts:OnTakeDamage(params)
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

modifier_item_nuts_buff = class({})

function modifier_item_nuts_buff:IsPurgable()
    return true
end

function modifier_item_nuts_buff:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_item_nuts_buff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end

function modifier_item_nuts_buff:GetTexture()
    return "items/nuts"
end

function modifier_item_nuts_buff:GetModifierMoveSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_item_nuts_buff:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_nuts_buff:GetEffectName()
    return "particles/nuts_effect.vpcf" 
end

function modifier_item_nuts_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end