modifier_gaben_int_fixed = class({})
function modifier_gaben_int_fixed:IsHidden() return true end
function modifier_gaben_int_fixed:IsDebuff() return false end
function modifier_gaben_int_fixed:IsPurgable() return false end
function modifier_gaben_int_fixed:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_gaben_int_fixed:DeclareFunctions()
    local funcs = 
    {
    	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION,
	}
	return funcs
end

function modifier_gaben_int_fixed:GetModifierMagicalResistanceDirectModification()
    return (self:GetParent():GetIntellect(false) * 0.1) * -1
end