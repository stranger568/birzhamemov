LinkLuaModifier("modifier_nix_marci_d_handler", "abilities/heroes/nix_streamer/nix_marci_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_marci_d_buff", "abilities/heroes/nix_streamer/nix_marci_d", LUA_MODIFIER_MOTION_NONE)

nix_marci_d = class({})

function nix_marci_d:Precache( context )
    PrecacheResource( "particle", "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold.vpcf", context )
end

function nix_marci_d:GetIntrinsicModifierName()
    return "modifier_nix_marci_d_handler"
end

function nix_marci_d:OnSpellStart()
    if not IsServer() then return end
    local modifier_nix_marci_d_handler = self:GetCaster():FindModifierByName("modifier_nix_marci_d_handler")
    if modifier_nix_marci_d_handler then
        local target = modifier_nix_marci_d_handler.target
        local victim_angle = target:GetAnglesAsVector()
        local victim_forward_vector = target:GetForwardVector()
        local victim_angle_rad = victim_angle.y*math.pi/180
        local victim_position = target:GetAbsOrigin()
        local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
        local pfx = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	    ParticleManager:SetParticleControlEnt(pfx, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	    ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	    ParticleManager:SetParticleControlEnt(pfx, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(pfx)
        self:GetCaster():SetAbsOrigin(attacker_new)
        FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
        self:GetCaster():SetForwardVector(victim_forward_vector)
        self:GetCaster():MoveToTargetToAttack(target)
        local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
        if modifier_nix_marci_r_upgrade then
            modifier_nix_marci_r_upgrade:Destroy()
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_d_buff", {})
        end
        self:GetCaster():EmitSound("nix_stone")
    end
end

modifier_nix_marci_d_handler = class({})

function modifier_nix_marci_d_handler:IsHidden() return true end
function modifier_nix_marci_d_handler:IsPurgable() return false end
function modifier_nix_marci_d_handler:IsPurgeException() return false end
function modifier_nix_marci_d_handler:RemoveOnDeath() return false end
function modifier_nix_marci_d_handler:OnCreated()
    if not IsServer() then return end
    self.target = nil
    self.target_time = 0
    self.last_damage_duration = self:GetAbility():GetSpecialValueFor("last_damage_duration")
    self:StartIntervalThink(0.1)
end

function modifier_nix_marci_d_handler:OnIntervalThink()
    if self.target ~= nil then
        self:GetAbility():SetActivated(true)
        self.target_time = self.target_time - 0.1
        if self.target_time <= 0 then
            self.target = nil
        end
    else
        self:GetAbility():SetActivated(false)
    end
end

function modifier_nix_marci_d_handler:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_nix_marci_d_handler:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.unit == self:GetParent() then return end
    self.target = params.unit
    self.target_time = self.last_damage_duration
end

modifier_nix_marci_d_buff = class({})
function modifier_nix_marci_d_buff:IsPurgable() return false end
function modifier_nix_marci_d_buff:IsPurgeException() return false end
function modifier_nix_marci_d_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end
function modifier_nix_marci_d_buff:GetModifierPreAttack_CriticalStrike()
    return self:GetAbility():GetSpecialValueFor("upgrade_damage")
end
function modifier_nix_marci_d_buff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    self:Destroy()
end