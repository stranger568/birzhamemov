--[[
Admin commands
 -Win 1      				-- helper command to fix teammate-man. 
]]

Commands = Commands or class({})

local admin_ids = {
	[106096878] = 1,
}

local kick_ids = {
	[106096878] = 1,
	[113370083] = 1,
	[141989146] = 1,
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
	BirzhaData.PostData()
	BirzhaData.PostHeroesInfo()
end

function Commands:Key(player, arg)
	if not IsAdmin(player) then return end
	local hero = player:GetAssignedHero()	
	AUTH_KEY = GetDedicatedServerKeyV2('birzhamemov')
	GameRules:SendCustomMessage(AUTH_KEY, 0, 0)
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
	hero:ModifyGold(50000, false, 0)
end
	
function Commands:listid(player, arg)
	if not IsMod(player) then return end
	local caster = player:GetAssignedHero()	
    local all_heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(all_heroes) do
        if hero:IsRealHero() then
        	if _G.HEROES_ID_TABLE then
        		if _G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()] then
        			GameRules:SendCustomMessageToTeam(hero:GetUnitName().."  ".._G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()][1], caster:GetTeamNumber(), 0, 0)
        		end
        	end
        end
    end
end

function Commands:kick(player, arg)
	if not IsMod(player) then return end

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:IsRealHero() then
			if _G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()] then
				local number = _G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()][1]
				if tostring(number) == arg[1] then
					_G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()][2] = true
				end
			end
		end
	end
	SendToServerConsole('kickid '.. arg[1])
end