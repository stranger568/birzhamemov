modifier_birzha_illusion_kill = class({})
function modifier_birzha_illusion_kill:IsHidden() return true end
function modifier_birzha_illusion_kill:IsPurgeException() return false end
function modifier_birzha_illusion_kill:IsPurgable() return false end
function modifier_birzha_illusion_kill:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    Timers:CreateTimer(0.5, function()
        UTIL_Remove(parent)
    end)
end