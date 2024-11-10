LinkLuaModifier("modifier_nix_marci_r", "abilities/heroes/nix_streamer/nix_marci_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_marci_r_upgrade", "abilities/heroes/nix_streamer/nix_marci_r", LUA_MODIFIER_MOTION_NONE)

nix_phantom_r = class({})

function nix_phantom_r:GetManaCost(iLevel)
    local base_cost = self:GetSpecialValueFor("base_manacost")
    local manacost_from_current_mana = self:GetSpecialValueFor("manacost_from_current_mana")
    return base_cost + (self:GetCaster():GetMana() / 100 * manacost_from_current_mana)
end

function nix_phantom_r:Precache( context )
    PrecacheResource( "particle", "particles/antimage_meta/meta_another.vpcf", context )
end

function nix_phantom_r:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_r_upgrade", {})
    local modifier_nix_marci_r = self:GetCaster():FindModifierByName("modifier_nix_marci_r")
    if modifier_nix_marci_r then
        modifier_nix_marci_r:Destroy()
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_r", {})
    end
    local particle = ParticleManager:CreateParticle("particles/antimage_meta/meta_another.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
end