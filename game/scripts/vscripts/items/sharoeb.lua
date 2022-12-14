LinkLuaModifier("modifier_item_sharoeb", "items/sharoeb", LUA_MODIFIER_MOTION_NONE)

item_sharoeb = class({})

function item_sharoeb:GetIntrinsicModifierName()
    return "modifier_item_sharoeb"
end

modifier_item_sharoeb = class({})

function modifier_item_sharoeb:IsHidden() return true end
function modifier_item_sharoeb:IsPurgable() return false end
function modifier_item_sharoeb:IsPurgeException() return false end

function modifier_item_sharoeb:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_item_sharoeb:GetModifierPercentageCooldown()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('cd')
    end
end

function modifier_item_sharoeb:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mp')
    end
end

function modifier_item_sharoeb:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_sharoeb:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('int')
    end
end

function modifier_item_sharoeb:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_sharoeb")[1] ~= self then return end
    if params.inflictor ~= nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local bonus_percentage = 0
        for _, mod in pairs(self:GetParent():FindAllModifiers()) do
            if mod.GetModifierSpellLifestealRegenAmplify_Percentage and mod:GetModifierSpellLifestealRegenAmplify_Percentage() then
                bonus_percentage = bonus_percentage + mod:GetModifierSpellLifestealRegenAmplify_Percentage()
            end
        end    
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        heal = heal * (bonus_percentage / 100 + 1)
        self:GetParent():Heal(heal, params.inflictor)
        local octarine = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( octarine )
    end
end






