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
	--[113370083] = 1,
	--[141989146] = 1,
	--[1013907017] = 1,
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
	AUTH_KEY = GetDedicatedServerKeyV3('birzhamemov')
	GameRules:SendCustomMessage(AUTH_KEY, 0, 0)
	hero:EmitSound("Birzha.Test_sound")
	BirzhaGameMode:PlayerLeaveUpdateMaxScore()
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

function Commands:listid(player, arg)
	if not IsMod(player) then return end
	local caster = player:GetAssignedHero()	
    local all_heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(all_heroes) do
        if hero:IsRealHero() then
        	if _G.HEROES_ID_TABLE then
        		if _G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()] then
        			GameRules:SendCustomMessageToTeam(hero:GetUnitName().."  ".._G.HEROES_ID_TABLE[hero:GetPlayerOwnerID()][1], caster:GetTeamNumber(), caster:GetTeamNumber(), caster:GetTeamNumber())
        		end
        	end
        end
    end
end

function Commands:kick(player, arg)
	if not IsMod(player) then return end
	SendToServerConsole('kickid '.. arg[1])
end

function Commands:report(player, arg)
	if not IsMod(player) then return end
	local caster = player:GetAssignedHero()	
	BirzhaEvents:AddPlayerFullDisconnectDebuff(caster, caster:GetPlayerID())
end