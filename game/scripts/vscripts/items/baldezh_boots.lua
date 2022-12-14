LinkLuaModifier("modifier_item_boots_of_invisibility", "items/baldezh_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_boots_of_invisibility_active", "items/baldezh_boots", LUA_MODIFIER_MOTION_NONE)

item_boots_of_invisibility = class({})

function item_boots_of_invisibility:GetIntrinsicModifierName()
    return "modifier_item_boots_of_invisibility"
end

function item_boots_of_invisibility:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():EmitSound("bkbitem")
    self:GetCaster():Purge( false, true, false, true, false)
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_boots_of_invisibility_active", {duration = duration})
    self:GetCaster():RemoveModifierByName("modifier_item_ethereal_blade_ethereal")
    local particle_smoke_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_smoke_fx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_smoke_fx)
end

modifier_item_boots_of_invisibility_active = class({})

function modifier_item_boots_of_invisibility_active:IsPurgable() return false end

function modifier_item_boots_of_invisibility_active:OnCreated()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end
    local player = caster:GetPlayerID()
    if DonateShopIsItemBought(player, 40) then
        self.effect = "particles/birzhapass/baldezh_donate.vpcf"
    else
        self.effect = "particles/items_fx/black_king_bar_avatar.vpcf"
    end
    self:GetCaster():Purge(false, true, false, false, false)
    local particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
    self.record = nil
    self.attack_proc = false
end

function modifier_item_boots_of_invisibility_active:GetTexture()
    return "Items/boots_of_invisibility"
end

function modifier_item_boots_of_invisibility_active:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK,
    }
    return funcs
end

function modifier_item_boots_of_invisibility_active:OnAttack(params)
    if self:GetParent() ~= params.attacker then return end
    if self.attack_proc then return end
    self.record = params.record
    self.attack_proc = true
end

function modifier_item_boots_of_invisibility_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_item_boots_of_invisibility_active:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
    return state
end

function modifier_item_boots_of_invisibility_active:OnAbilityExecuted(keys)
    if IsServer() then
        local ability = keys.ability
        local caster = keys.unit
        if caster == self:GetParent() then
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_item_boots_of_invisibility_active:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if self.attack_proc == false then return end
    if self.record ~= params.record then return end
    if self:IsNull() then return end
    self:Destroy()
end

modifier_item_boots_of_invisibility = class({})

function modifier_item_boots_of_invisibility:IsHidden() return true end
function modifier_item_boots_of_invisibility:IsPurgable() return false end
function modifier_item_boots_of_invisibility:IsPurgeException() return false end
function modifier_item_boots_of_invisibility:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_boots_of_invisibility:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function modifier_item_boots_of_invisibility:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end

function modifier_item_boots_of_invisibility:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_strength')
    end
end

function modifier_item_boots_of_invisibility:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_damage')
    end
end

function modifier_item_boots_of_invisibility:GetModifierMagicalResistanceBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_resist')
    end
end