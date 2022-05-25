
modifier_birzha_toy_scale = class({})

function modifier_birzha_toy_scale:IsHidden()
	return true
end

function modifier_birzha_toy_scale:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

function modifier_birzha_toy_scale:GetModifierModelScale()
	if self:GetParent():HasModifier("modifier_puchkov_small_debils") then return 0 end
	return -50
end