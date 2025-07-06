modifier_birzha_disconnect = class({})
function modifier_birzha_disconnect:IsHidden() return true end
function modifier_birzha_disconnect:IsPurgable() return false end
function modifier_birzha_disconnect:IsPurgeException() return false end
function modifier_birzha_disconnect:RemoveOnDeath() return false end