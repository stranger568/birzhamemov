modifier_birzha_loser = class({})

function modifier_birzha_loser:IsPurgable()
	return false
end

function modifier_birzha_loser:IsPurgeException()
	return false
end

function modifier_birzha_loser:RemoveOnDeath()
	return false
end

function modifier_birzha_loser:GetTexture()
	return "ban"
end

function modifier_birzha_loser:IsHidden()
	return false
end

function modifier_birzha_loser:AllowIllusionDuplicate()
	return true
end

function modifier_birzha_loser:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_birzha_loser:OnIntervalThink()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
	CustomGameEventManager:Send_ServerToPlayer(Player, "birzha_ban_player", {days = self:GetStackCount()} )
end

function modifier_birzha_loser:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
end