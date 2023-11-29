LinkLuaModifier( "modifier_item_birzha_force_boots", "items/force", LUA_MODIFIER_MOTION_NONE )

item_birzha_force_boots = class({})

function item_birzha_force_boots:OnSpellStart()
    if not IsServer() then return end
    local mod = self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_item_forcestaff_active', {push_length = self:GetSpecialValueFor("push_length"), duration = self:GetSpecialValueFor("push_time")})

    if mod then
        if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 196) or IsInToolsMode() then
            local particle = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
            mod:AddParticle(particle, false, false, -1, false, false)
        end
    end

    self:GetCaster():RemoveGesture(ACT_DOTA_DISABLED)
    self:GetCaster():EmitSound('DOTA_Item.ForceStaff.Activate')
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_force")
    end
end

function item_birzha_force_boots:GetIntrinsicModifierName() 
    return "modifier_item_birzha_force_boots"
end

modifier_item_birzha_force_boots = class({})

function modifier_item_birzha_force_boots:IsHidden() return true end
function modifier_item_birzha_force_boots:IsPurgable() return false end
function modifier_item_birzha_force_boots:IsPurgeException() return false end
function modifier_item_birzha_force_boots:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_birzha_force_boots:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
end

function modifier_item_birzha_force_boots:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_int")
    end
end

function modifier_item_birzha_force_boots:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_regen')
    end
end

function modifier_item_birzha_force_boots:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
    end
end
