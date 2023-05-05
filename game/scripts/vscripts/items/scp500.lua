LinkLuaModifier("modifier_item_scp500", "items/scp500", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_scp500_buff", "items/scp500", LUA_MODIFIER_MOTION_NONE)

item_scp500 = class({})

function item_scp500:GetIntrinsicModifierName()
    return "modifier_item_scp500"
end

function item_scp500:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("scp500_cast")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_scp500_buff", {duration = duration})
    self:SpendCharge()
end

modifier_item_scp500 = class({})

function modifier_item_scp500:IsHidden() return true end
function modifier_item_scp500:IsPurgable() return false end

function modifier_item_scp500:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_scp500:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attributes")
    end
end

function modifier_item_scp500:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attributes")
    end
end

function modifier_item_scp500:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attributes")
    end
end

modifier_item_scp500_buff = class({})

function modifier_item_scp500_buff:IsPurgable() return false end

function modifier_item_scp500_buff:GetTexture()
    return "items/scp500"
end

function modifier_item_scp500_buff:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/scp500_effect.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)
    self.damage_reduce = self:GetAbility():GetSpecialValueFor("damage_reduce")
    self.health = (self:GetParent():GetMaxHealth() / 3) * FrameTime()
    self.mana = (self:GetParent():GetMaxMana() / 3) * FrameTime()
    self.attack = false
    self.hp_restore = true
    self.mana_restore = true
    self.cd = 0
    self:StartIntervalThink(FrameTime())
end

function modifier_item_scp500_buff:OnIntervalThink()
    if not IsServer() then return end
    self.cd = self.cd + FrameTime()
    if self.cd >= self:GetAbility():GetSpecialValueFor("think") then
        self.cd = 0
        self:GetParent():Purge(false, true, false, true, true)
    end
    if self.hp_restore then
        self:GetParent():Heal(self.health, self:GetAbility())
        if self.hp_restore then
            if self:GetParent():GetHealth() == self:GetParent():GetMaxHealth() then
                self.hp_restore = false
            end
        end
    end
    if self.mana_restore then
        self:GetParent():GiveMana(self.mana)
        if self.mana_restore then
            if self:GetParent():GetMana() == self:GetParent():GetMaxMana() then
                self.mana_restore = false
            end
        end
    end
end

function modifier_item_scp500_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_item_scp500_buff:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.attacker == self:GetParent() then return end
    if self.attack then return end
    print("lalala")
    self.attack = true
    print(self:GetRemainingTime() / 2)
    self:SetDuration(self:GetRemainingTime() / 2, true)
end

function modifier_item_scp500_buff:GetModifierIncomingDamage_Percentage()
    return self.damage_reduce
end