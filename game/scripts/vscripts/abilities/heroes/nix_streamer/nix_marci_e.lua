LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

nix_marci_e = class({})

function nix_marci_e:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_marci_e.vpcf", context )
end

function nix_marci_e:OnSpellStart()
    if not IsServer() then return end
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local radius = self:GetSpecialValueFor("radius")
    local upgrade_damage = self:GetSpecialValueFor("upgrade_damage")
    local has_upgrade = false
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        radius = self:GetSpecialValueFor("upgrade_radius")
        has_upgrade = true
    end
    self:GetCaster():EmitSound("nix_allin")
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _, unit in pairs(units) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration * (1 - unit:GetStatusResistance())})
        if has_upgrade then
            ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = upgrade_damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
        end
    end
    local particle = ParticleManager:CreateParticle("particles/nix/nix_marci_e.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius*2, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
end