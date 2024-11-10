LinkLuaModifier("modifier_old_god_e", "abilities/heroes/old_god/old_god_e", LUA_MODIFIER_MOTION_NONE)

old_god_e = class({})

function old_god_e:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local modifier_old_god_e = self:GetCaster():FindModifierByName("modifier_old_god_e")
    if modifier_old_god_e then
        modifier_old_god_e:Destroy()
    end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_old_god_e", {duration = duration})
end

modifier_old_god_e = class({})

function modifier_old_god_e:OnCreated(params)
    self.shield_from_hp = self:GetAbility():GetSpecialValueFor("shield_from_hp")
    self.max_shield  = self:GetParent():GetHealth() / 100 * self.shield_from_hp
    if not IsServer() then return end
    self:SetStackCount(self.max_shield)
    self:GetCaster():EmitSound("stariy_natura")
end

function modifier_old_god_e:OnRefresh(params)
    self.shield_from_hp = self:GetAbility():GetSpecialValueFor("shield_from_hp")
    self.max_shield  = self:GetParent():GetHealth() / 100 * self.shield_from_hp
    if not IsServer() then return end
    self:SetStackCount(self.max_shield)
end

function modifier_old_god_e:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    }
end

function modifier_old_god_e:GetModifierIncomingPhysicalDamageConstant( params )
    if self:GetCaster():HasModifier("modifier_old_god_d") then return end
    if IsClient() then 
        if params.report_max then 
            return self.max_shield 
        else 
            return self:GetStackCount()
        end 
    end
    self:PlayEffects5()
    if params.damage >= self:GetStackCount() then
        self:Destroy()
        return -self:GetStackCount()
    else
        self:SetStackCount(self:GetStackCount()-params.damage)
        return -params.damage
    end
end

function modifier_old_god_e:GetModifierIncomingDamageConstant( params )
    if not self:GetCaster():HasModifier("modifier_old_god_d") then return end
    if IsClient() then 
        if params.report_max then 
            return self.max_shield 
        else 
            return self:GetStackCount()
        end 
    end
    self:PlayEffects5()
    if params.damage>=self:GetStackCount() then
        self:Destroy()
        return -self:GetStackCount()
    else
        self:SetStackCount(self:GetStackCount()-params.damage)
        return -params.damage
    end
end