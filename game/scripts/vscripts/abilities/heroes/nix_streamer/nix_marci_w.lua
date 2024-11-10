LinkLuaModifier("modifier_nix_marci_w", "abilities/heroes/nix_streamer/nix_marci_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_marci_w_debuff", "abilities/heroes/nix_streamer/nix_marci_w", LUA_MODIFIER_MOTION_NONE)

nix_marci_w = class({})

function nix_marci_w:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_impact.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_overhead.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_buff.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_pulse_new.vpcf", context )
end

function nix_marci_w:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local has_upgrade = nil
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        has_upgrade = true
        duration = duration * self:GetSpecialValueFor("upgrade_duration")
    end
    self:GetCaster():EmitSound("nix_eat")
    local particle = ParticleManager:CreateParticle("particles/nix/nix_marci_w_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_w", {duration = duration, has_upgrade = has_upgrade})
end

modifier_nix_marci_w = class({})
function modifier_nix_marci_w:IsPurgable() return false end
function modifier_nix_marci_w:IsPurgeException() return false end

function modifier_nix_marci_w:OnCreated(params)
    self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage_from_attack = self:GetAbility():GetSpecialValueFor("damage_from_attack")
    if params.has_upgrade then
        self.max_attacks = self:GetAbility():GetSpecialValueFor("upgrade_attacks")
    end
    if not IsServer() then return end
    local overhead_effect = ParticleManager:CreateParticle("particles/nix/nix_marci_w_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(overhead_effect, false, false, -1, false, false)
    self:SetStackCount(self.max_attacks)
end

function modifier_nix_marci_w:OnRefresh(params)
    self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage_from_attack = self:GetAbility():GetSpecialValueFor("damage_from_attack")
    if params.has_upgrade then
        self.max_attacks = self:GetAbility():GetSpecialValueFor("upgrade_attacks")
    end
    if not IsServer() then return end
    self:SetStackCount(self.max_attacks)
end

function modifier_nix_marci_w:GetEffectName()
    return "particles/nix/nix_marci_w_buff.vpcf"
end

function modifier_nix_marci_w:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_nix_marci_w:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_nix_marci_w:OnAttack(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if self:GetStackCount() <= 0 then return end
    if params.no_attack_cooldown then return end
    if self:GetParent():HasModifier("modifier_nix_marci_w_debuff") then return end
    self:DecrementStackCount()
    self:Pulse(params.target)
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end

function modifier_nix_marci_w:Pulse(target)
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/nix/nix_marci_w_pulse_new.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius / 2, self.radius / 4))
    ParticleManager:ReleaseParticleIndex(particle)
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _, unit in pairs(units) do
        if unit ~= target then
            local modifier_nix_marci_w_debuff = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_nix_marci_w_debuff", {})
            self:GetCaster():PerformAttack(unit, true, true, true, true, false, false, true)
            if modifier_nix_marci_w_debuff then
                modifier_nix_marci_w_debuff:Destroy()
            end
        end
    end
end

modifier_nix_marci_w_debuff = class({})
function modifier_nix_marci_w_debuff:IsHidden() return true end
function modifier_nix_marci_w_debuff:IsPurgable() return false end
function modifier_nix_marci_w_debuff:IsPurgeException() return false end
function modifier_nix_marci_w_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end
function modifier_nix_marci_w_debuff:GetModifierDamageOutgoing_Percentage()
    if not IsServer() then return end
    return -100 + self:GetAbility():GetSpecialValueFor("damage_from_attack")
end





