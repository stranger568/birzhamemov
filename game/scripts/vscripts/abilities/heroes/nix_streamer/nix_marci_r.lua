LinkLuaModifier("modifier_nix_marci_r", "abilities/heroes/nix_streamer/nix_marci_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_marci_r_upgrade", "abilities/heroes/nix_streamer/nix_marci_r", LUA_MODIFIER_MOTION_NONE)

nix_marci_r = class({})

function nix_marci_r:Precache( context )
    PrecacheResource( "particle", "particles/antimage_meta/meta.vpcf", context )
end

function nix_marci_r:GetManaCost(iLevel)
    local base_cost = self:GetSpecialValueFor("base_manacost")
    local manacost_from_current_mana = self:GetSpecialValueFor("manacost_from_current_mana")
    return base_cost + (self:GetCaster():GetMana() / 100 * manacost_from_current_mana)
end

function nix_marci_r:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_r_upgrade", {})
    local modifier_nix_marci_r = self:GetCaster():FindModifierByName("modifier_nix_marci_r")
    if modifier_nix_marci_r then
        modifier_nix_marci_r:Destroy()
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nix_marci_r", {})
    end
    self:GetCaster():EmitSound("nix_pravin")
    local particle = ParticleManager:CreateParticle("particles/antimage_meta/meta.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_nix_marci_r = class({})
function modifier_nix_marci_r:IsHidden() return true end
function modifier_nix_marci_r:IsPurgable() return false end
function modifier_nix_marci_r:IsPurgeException() return false end
function modifier_nix_marci_r:RemoveOnDeath() return false end

function modifier_nix_marci_r:OnCreated()
    if not IsServer() then return end
    self.abilities_list = 
    {
        {"nix_marci_q", "nix_phantom_q"},
        {"nix_marci_w", "nix_phantom_w"},
        {"nix_marci_e", "nix_phantom_e"},
        {"nix_marci_d", "nix_phantom_d"},
        {"nix_marci_r", "nix_phantom_r"},
    }
    self.model = self:GetParent():GetModelName()
    self:GetParent():SetModel("models/nix/nix_phantom.vmdl")
    self:GetParent():SetOriginalModel("models/nix/nix_phantom.vmdl")
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)
    for _, info in pairs(self.abilities_list) do
        self:GetCaster():SwapAbilities(info[1], info[2], false, true)
    end
end

function modifier_nix_marci_r:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModel(self.model)
    self:GetParent():SetOriginalModel(self.model)
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
    for _, info in pairs(self.abilities_list) do
        self:GetCaster():SwapAbilities(info[2], info[1], false, true)
    end
end

modifier_nix_marci_r_upgrade = class({})
function modifier_nix_marci_r_upgrade:IsHidden() return true end
function modifier_nix_marci_r_upgrade:IsPurgable() return false end
function modifier_nix_marci_r_upgrade:IsPurgeException() return false end
function modifier_nix_marci_r_upgrade:RemoveOnDeath() return false end