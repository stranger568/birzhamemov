LinkLuaModifier( "modifier_nix_phantom_q_buff", "abilities/heroes/nix_streamer/nix_phantom_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nix_phantom_q_debuff", "abilities/heroes/nix_streamer/nix_phantom_q", LUA_MODIFIER_MOTION_NONE )

nix_phantom_q = class({})

function nix_phantom_q:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_phantom_q.vpcf", context )
    PrecacheResource( "particle", "particles/nix/nix_phantom_q_hand.vpcf", context )
end

function nix_phantom_q:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function nix_phantom_q:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local movement_attack_speed_steal = self:GetSpecialValueFor("movement_attack_speed_steal")
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    local is_upgrade = nil
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        is_upgrade = true
    end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    if #enemies <= 0 then return end
    local modifier_nix_phantom_q_buff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_phantom_q_buff", {duration = duration, is_upgrade = is_upgrade})
    if modifier_nix_phantom_q_buff then
        modifier_nix_phantom_q_buff:SetStackCount(modifier_nix_phantom_q_buff:GetStackCount() + (movement_attack_speed_steal * #enemies))
    end
    self:GetCaster():EmitSound("Hero_Undying.FleshGolem.End")
    local nix_marci_w = self:GetCaster():FindAbilityByName("nix_marci_w")
    for _, enemy in pairs(enemies) do
        local particle = ParticleManager:CreateParticle("particles/nix/nix_phantom_q.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_nix_phantom_q_debuff", {duration = duration * (1-enemy:GetStatusResistance()), is_upgrade = is_upgrade})
        if nix_marci_w and nix_marci_w:GetLevel() > 0 then
            nix_marci_w:AddTargetMark(enemy)
        end
    end
end

modifier_nix_phantom_q_buff = class({})

function modifier_nix_phantom_q_buff:OnCreated(params)
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/nix/nix_phantom_q_hand.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
    self.is_upgrade = params.is_upgrade
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_nix_phantom_q_buff:AddCustomTransmitterData()
    return 
    {
        is_upgrade = self.is_upgrade,
    }
end

function modifier_nix_phantom_q_buff:HandleCustomTransmitterData( data )
    self.is_upgrade = data.is_upgrade
end

function modifier_nix_phantom_q_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_nix_phantom_q_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount()
end

function modifier_nix_phantom_q_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end

function modifier_nix_phantom_q_buff:GetModifierPreAttack_BonusDamage()
    if self.is_upgrade then
        return self:GetStackCount()
    end
end

modifier_nix_phantom_q_debuff = class({})

function modifier_nix_phantom_q_debuff:OnCreated(params)
    self.movement_attack_speed_steal = -self:GetAbility():GetSpecialValueFor("movement_attack_speed_steal")
    if not IsServer() then return end
    self.is_upgrade = params.is_upgrade
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_nix_phantom_q_debuff:AddCustomTransmitterData()
    return 
    {
        is_upgrade = self.is_upgrade,
    }
end

function modifier_nix_phantom_q_debuff:HandleCustomTransmitterData( data )
    self.is_upgrade = data.is_upgrade
end

function modifier_nix_phantom_q_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_nix_phantom_q_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.movement_attack_speed_steal
end

function modifier_nix_phantom_q_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.movement_attack_speed_steal
end

function modifier_nix_phantom_q_debuff:GetModifierPreAttack_BonusDamage()
    if self.is_upgrade then
        return self.movement_attack_speed_steal
    end
end