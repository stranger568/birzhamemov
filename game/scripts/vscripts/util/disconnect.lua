BirzhaDisconnectFunction = class({})

function BirzhaDisconnectFunction:Init()
	DISCONNECT_STATUS = {}
end

function BirzhaDisconnectFunction:AutoWin()
	local winteam = nil
	local teams_table = {2,3,6,7,8,9,10,11,12,13}

	for _, team in ipairs(teams_table) do
		local player_count = self:GetCNPlayersInTeam(team)
		if player_count > 0 then
			if winteam == nil then
				winteam = team
			else
				return nil
			end		
		end
	end

	if winteam ~= nil then
		BirzhaGameMode:EndGame(winteam)
		GameRules:SetGameWinner(winteam)
	end
end

function BirzhaDisconnectFunction:GetCNPlayersInTeam(t)
	local count = 0
	for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
		if not IsPlayerDisconnected(id) and PlayerResource:GetTeam(id) == t then
			count = count + 1
		end
	end
	return count
end