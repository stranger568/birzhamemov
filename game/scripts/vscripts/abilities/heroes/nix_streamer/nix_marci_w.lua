LinkLuaModifier("modifier_nix_marci_w", "abilities/heroes/nix_streamer/nix_marci_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_marci_w_debuff", "abilities/heroes/nix_streamer/nix_marci_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_marci_w_handler", "abilities/heroes/nix_streamer/nix_marci_w", LUA_MODIFIER_MOTION_NONE)

nix_marci_w = class({})

function nix_marci_w:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_impact.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_overhead.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_buff.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_marci_w_pulse_new.vpcf", context )
    PrecacheResource( "particle", "particles/nix_custom/nix_w_strike.vpcf", context )
end

function nix_marci_w:GetIntrinsicModifierName()
    return "modifier_nix_marci_w_handler"
end

function nix_marci_w:AttackBashed(target, parry)
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_bashed", {duration = stun_duration * (1 - target:GetStatusResistance())})
    local coup_pfx = ParticleManager:CreateParticle("particles/nix_custom/nix_w_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(coup_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(coup_pfx, 1, target:GetAbsOrigin())
    local line = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    ParticleManager:SetParticleControlTransformForward( coup_pfx, 1, target:GetOrigin(), -line )
    ParticleManager:ReleaseParticleIndex(coup_pfx)
end

function nix_marci_w:AddTargetMark(target)
    local mark_duration = self:GetSpecialValueFor("mark_duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_w_debuff", {duration = mark_duration * (1 - target:GetStatusResistance())})
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

modifier_nix_marci_w_handler = class({})
function modifier_nix_marci_w_handler:IsHidden() return true end
function modifier_nix_marci_w_handler:IsPurgable() return false end
function modifier_nix_marci_w_handler:IsPurgeException() return false end
function modifier_nix_marci_w_handler:RemoveOnDeath() return false end
function modifier_nix_marci_w_handler:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }
end

function modifier_nix_marci_w_handler:OnAttackStart(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    local modifier_nix_marci_w_debuff = params.target:FindModifierByName("modifier_nix_marci_w_debuff")
    if modifier_nix_marci_w_debuff then
        self.is_mark_attack = true
    else
        self.is_mark_attack = false
        self.is_upgrade_mark = false
    end
end

function modifier_nix_marci_w_handler:GetModifierPreAttack_CriticalStrike(params)
    if self.is_mark_attack then
        return self:GetAbility():GetSpecialValueFor("critical_damage")
    end
end

function modifier_nix_marci_w_handler:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    local has_mark = false
    local modifier_nix_marci_w_debuff = params.target:FindModifierByName("modifier_nix_marci_w_debuff")
    if modifier_nix_marci_w_debuff then
        self:GetAbility():AttackBashed(params.target)
        modifier_nix_marci_w_debuff:Destroy()
        has_mark = true
    end
    self.is_mark_attack = false
    if self:GetCaster():HasModifier("modifier_nix_marci_w") and not has_mark then
        self:GetAbility():AddTargetMark(params.target)
    end
end

modifier_nix_marci_w = class({})
function modifier_nix_marci_w:IsPurgable() return false end
function modifier_nix_marci_w:IsPurgeException() return false end
function modifier_nix_marci_w:GetEffectName()
    return "particles/nix/nix_marci_w_buff.vpcf"
end
function modifier_nix_marci_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_nix_marci_w_debuff = class({})
function modifier_nix_marci_w_debuff:IsHidden() return true end
function modifier_nix_marci_w_debuff:OnCreated()
    if not IsServer() then return end
    local overhead_effect = ParticleManager:CreateParticle("particles/nix/nix_marci_w_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(overhead_effect, false, false, -1, false, false)
end




