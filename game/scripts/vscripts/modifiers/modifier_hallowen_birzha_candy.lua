modifier_hallowen_birzha_candy = class({})
function modifier_hallowen_birzha_candy:IsPurgable() return false end
function modifier_hallowen_birzha_candy:IsPurgeException() return false end
function modifier_hallowen_birzha_candy:RemoveOnDeath() return false end
function modifier_hallowen_birzha_candy:GetTexture() return "candy" end
function modifier_hallowen_birzha_candy:OnCreated()
    if not IsServer() then return end
    self:IncrementStackCount()
end
function modifier_hallowen_birzha_candy:OnRefresh()
    if not IsServer() then return end
    self:OnCreated()
end