BirzhaDisconnectFunction = class({})

function BirzhaDisconnectFunction:Init()
	DISCONNECT_STATUS = {}
end

function BirzhaDisconnectFunction:AutoWin()
	Debug:Execute( function()
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
	BirzhaGameMode:EndGame(winteam)
	GameRules:SetGameWinner(winteam)
	end)	
end

function BirzhaDisconnectFunction:GetCNPlayersInTeam(t)
	local count = 0
	for id = 0, PlayerResource:GetPlayerCount() - 1 do
		if PlayerResource:GetTeam(id) == t and not IsPlayerDisconnected(id) then
			count = count + 1
		end
	end
	return count
end