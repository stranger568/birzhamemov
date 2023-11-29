LinkLuaModifier( "modifier_item_birzha_gem", "items/gem", LUA_MODIFIER_MOTION_NONE )

item_birzha_gem = class({})

function item_birzha_gem:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_birzha_gem", {})
	self:SpendCharge()
end

modifier_item_birzha_gem = class({})

function modifier_item_birzha_gem:RemoveOnDeath() return true end

function modifier_item_birzha_gem:DeclareFunctions()
	local decfuncs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return decfuncs
end

function modifier_item_birzha_gem:OnDeath(params)
	local caster = self:GetCaster()
	local target = params.unit
	if IsServer() then
		if target == self:GetParent() then
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

function modifier_item_birzha_gem:GetTexture()
  	return "items/gem"
end

function modifier_item_birzha_gem:IsAura()
    return true
end

function modifier_item_birzha_gem:IsHidden()
    return false
end

function modifier_item_birzha_gem:IsPurgable()
    return false
end

function modifier_item_birzha_gem:GetAuraRadius()
    return 900
end

function modifier_item_birzha_gem:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_item_birzha_gem:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_birzha_gem:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_birzha_gem:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_item_birzha_gem:GetAuraDuration()
    return 0.1
end