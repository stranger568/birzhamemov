LinkLuaModifier( "modifier_boss_drop", "abilities/units/boss_drop.lua", LUA_MODIFIER_MOTION_NONE )

Boss_Drop = class({})

function Boss_Drop:GetIntrinsicModifierName()
    return "modifier_boss_drop"
end

modifier_boss_drop = class({})

function modifier_boss_drop:IsHidden()
    return true
end

function modifier_boss_drop:StatusEffectPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_boss_drop:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_boss_drop:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_boss_drop:OnDeath(params)
	if params.unit == self:GetParent() then
		if self:GetParent():GetUnitName() == "npc_dota_bristlekek" then
			local spawnPointChest = self:GetParent():GetAbsOrigin()
			local dropRadiusChest = RandomFloat( 100, 200 )
			local attacker = params.attacker
			local team = attacker:GetTeam()
			local AllHeroes = HeroList:GetAllHeroes()
			EmitGlobalSound("conquest.stinger.capture_radiant")
			CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "BristekekDeath", icon = "bristlekek"} )
			BirzhaGameMode:AddScoreToTeam( team, 10 )
			Timers:CreateTimer(300, function()
				local RoshanSpawnPoint = Entities:FindByName( nil, "RoshanSpawn" ):GetAbsOrigin()
				local Boss = CreateUnitByName("npc_dota_bristlekek", RoshanSpawnPoint, false, nil, nil, DOTA_TEAM_NEUTRALS)
			end)
		elseif self:GetParent():GetUnitName() == "npc_dota_LolBlade" then
			local spawnPointChest = self:GetParent():GetAbsOrigin()
			local dropRadiusChest = RandomFloat( 100, 200 )
			local attacker = params.attacker
			local team = attacker:GetTeam()
			local AllHeroes = HeroList:GetAllHeroes()
			EmitGlobalSound("conquest.stinger.capture_radiant")
			CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "LolBladeDeath", icon = "lolblade"} )
			BirzhaGameMode:AddScoreToTeam( team, 20 )
			Timers:CreateTimer(300, function()
				local RoshanSpawnPoint = Entities:FindByName( nil, "RoshanSpawn2" ):GetAbsOrigin()
				local Boss = CreateUnitByName("npc_dota_LolBlade", RoshanSpawnPoint, false, nil, nil, DOTA_TEAM_NEUTRALS)
			end)
		end
	end	
end

function modifier_boss_drop:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = false,
        [MODIFIER_STATE_HEXED] = false,
        [MODIFIER_STATE_DISARMED] = false,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end