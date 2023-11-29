Commands = Commands or class({})

local admin_ids =
{
	[106096878] = 1,
}

local kick_ids = 
{
	[106096878] = 1,
}

function IsAdmin(player)
	local steam_account_id = PlayerResource:GetSteamAccountID( player:GetPlayerID()  )
	return (admin_ids[steam_account_id] == 1)
end 

function IsMod(player)
	local steam_account_id = PlayerResource:GetSteamAccountID( player:GetPlayerID()  )
	return (kick_ids[steam_account_id] == 1)
end 

function Commands:win(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()	
	BirzhaGameMode:EndGame( hero:GetTeam() )
end

function Commands:plusmmr(player, arg)
	if not IsAdmin(player) then return end
	BirzhaData.PostHeroPlayerHeroInfo()
end

function Commands:Key(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()	
	GameRules:SendCustomMessage(GetDedicatedServerKeyV3('birzhamemov'), 0, 0)
end

function Commands:invul(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()	
	hero:AddInvul()
end

function Commands:removeinvul(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()	
	hero:RemoveModifierByName("modifier_birzha_invul")
end

function Commands:donate(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()	
	hero:ModifyGold(tonumber(arg[1]), false, 0)
end

function Commands:time(player, arg)
	if not IsAdmin(player) then return end
	Convars:SetFloat("host_timescale", tonumber(arg[1]))
end

function Commands:mod(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()
	for _, modifier in pairs(hero:FindAllModifiers()) do
		print(modifier:GetName())
	end
end

function Commands:report(player, arg)
	if not IsAdmin(player) then return end
	local caster = player:GetAssignedHero()	
	BirzhaEvents:AddPlayerFullDisconnectDebuff(caster, caster:GetPlayerID())
end

function Commands:leave(player, arg)
    if not IsAdmin(player) then return end
	BirzhaEvents:AutoWin()
end

function Commands:visual(player, arg)
    if not IsAdmin(player) then return end
    CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "ServerNoConnection", icon = "server_connect"} )
end

function Commands:banner(player, arg)
    if not IsAdmin(player) then return end
    CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = arg[1], icon = "server_connect"} )
end