-- ПЕРЕМЕННЫЕ ИГРОВОГО ВРЕМЕНИ
_G.BIRZHA_FOUNTAIN_GAME_TIMER = 900
_G.BIRZHA_TIMER_TO_END_GAME = 300
_G.BIRZHA_GAME_ALL_TIMER = 0
_G.BIRZHA_CONTRACT_TIME = 180

if IsInToolsMode() then
    BIRZHA_FOUNTAIN_GAME_TIMER = 10
end

_G.MAPS_MAX_SCORES =
{
    ["birzhamemov_solo"] = 50,
	["birzhamemov_duo"] = 60,
	["birzhamemov_trio"] = 90,
	["birzhamemov_5v5v5"] = 150,
	["birzhamemov_5v5"] = 100,
	["birzhamemov_zxc"] = 2,
	["birzhamemov_samepick"] = 100,
}
function BirzhaGameMode:GameInProgressThink()
    ---- Предметы и монеты
    BirzhaGameMode:ThinkGoldDrop()
	BirzhaGameMode:ThinkItemCheck()

    ---- Игровое время
    BIRZHA_GAME_ALL_TIMER = BIRZHA_GAME_ALL_TIMER + 1
    GameTimerUpdater(BIRZHA_GAME_ALL_TIMER, "GameTimer")

    ---- Фонтан
    if BIRZHA_FOUNTAIN_GAME_TIMER > 0 then
        BIRZHA_FOUNTAIN_GAME_TIMER = BIRZHA_FOUNTAIN_GAME_TIMER - 1
        GameTimerUpdater(BIRZHA_FOUNTAIN_GAME_TIMER, "fountain")
        if BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then
            CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "fountainoff", icon = "fountain"} )
        end
    end

    ---- Контракты
    if BIRZHA_CONTRACT_TIME > 0 then
        BIRZHA_CONTRACT_TIME = BIRZHA_CONTRACT_TIME - 1
        GameTimerUpdater(BIRZHA_CONTRACT_TIME, "contarct_time")
        if BIRZHA_CONTRACT_TIME <= 0 then
            self:SpawnContracts()
            BIRZHA_CONTRACT_TIME = 180
        end
    end

    -- Окончание игры
    if BIRZHA_FOUNTAIN_GAME_TIMER <= 0 and BIRZHA_TIMER_TO_END_GAME > 0 then
        BIRZHA_TIMER_TO_END_GAME = BIRZHA_TIMER_TO_END_GAME - 1
        GameTimerUpdater(BIRZHA_TIMER_TO_END_GAME, "endgametimer")
        if BIRZHA_TIMER_TO_END_GAME <= 0 and not GameRules:IsCheatMode() then
            BirzhaGameMode:EndGame( leaderbirzha )
            GameRules:SetGameWinner( leaderbirzha )
        end
    end
end

-- Установка времени для PUCCI
function BirzhaGameMode:PucciSetTime(time)
    BirzhaGameMode.PucciFastTime = time
end

-- ИНИЦИАЛИЗАЦИЯ СТАДИЙ ИГРЫ
function BirzhaGameMode:OnGameRulesStateChange(params)
	local nNewState = GameRules:State_Get()
	HeroDemo:OnGameRulesStateChange(params)
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		birzha_hero_selection:Init()
	end
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self.ContractTimer = 180
		self.contract_gold = 
        {
			[2] = 1000,
			[3] = 1000,
			[6] = 1000,
			[7] = 1000,
			[8] = 1000,
			[9] = 1000,
			[10] = 1000,
			[11] = 1000,
			[12] = 1000,
			[13] = 1000,
		}
		CustomNetTables:SetTableValue( "game_state", "scores_to_win", { kills = MAPS_MAX_SCORES[GetMapName()] } )
	end
	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		birzha_hero_selection:StartCheckingToStart()
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
		SpawnDonaters()
	end
end

-- Ивент произошедшего убийства
function BirzhaGameMode:OnTeamKillCredit( event )
	if BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then
		BIRZHA_TIMER_TO_END_GAME = 300
	end
    if BirzhaGameMode.PucciFastTime ~= nil and BirzhaGameMode.PucciFastTime == true then return end
	BirzhaGameMode:AddScoreToTeam( event.teamnumber, 1 )
end

function BirzhaGameMode:AddScoreToTeam( Team, AddScore )
	local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(Team))
	local table_game_score = CustomNetTables:GetTableValue("game_state", "scores_to_win")
	local team_kills = 0
	if table_team_score then
		team_kills = table_team_score.kills + AddScore
		CustomNetTables:SetTableValue( "game_state", tostring(Team), { kills = team_kills } )
	end
	table_team_score = CustomNetTables:GetTableValue("game_state", tostring(Team))
	if table_team_score and table_game_score then
		if table_team_score.kills >= table_game_score.kills then	
			BirzhaGameMode:EndGame( Team )
			GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[Team] )
		end
	end
end

-- Подбор предмета
function BirzhaGameMode:OnItemPickUp( event )
	VectorTarget:OnItemPickup(event)
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
	end
	if event.itemname == "item_bag_of_gold" then
		PlayerResource:ModifyGold( owner:GetPlayerID(), 150, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, 150, nil )
		UTIL_Remove( item )
	end
	if event.itemname == "item_bag_of_gold_van" then
		local gold = 0
		for _,hero in pairs (HeroList:GetAllHeroes()) do
			if hero:IsRealHero() and hero:FindAbilityByName("van_takeitboy") then
				local abilka = hero:FindAbilityByName("van_takeitboy")
				gold = abilka:GetSpecialValueFor("gold")
				break
			end
		end
		PlayerResource:ModifyGold( owner:GetPlayerID(), gold, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, gold, nil )
		UTIL_Remove( item )
	end
	if event.itemname == "item_bag_of_gold_bp_fake" then
		UTIL_Remove( item )
	end
	if event.itemname == "item_treasure_chest" then
		BirzhaGameMode:SpecialItemAdd( event )
		UTIL_Remove( item )
	end
	if event.itemname == "item_treasure_chest_winter" then
		BirzhaGameMode:SpecialItemAdd( event )
		UTIL_Remove( item )
	end
	if item.origin then
        item.origin.is_spawned = nil
		UTIL_Remove(item)
    end
end

-- Изменение убийств если ливнул парень
function BirzhaGameMode:PlayerLeaveUpdateMaxScore()
	local current_max_kills = CustomNetTables:GetTableValue("game_state", "scores_to_win").kills
	local leader_max_kills = BirzhaGameMode:GetMaxKillLeader()
	local maps_scores_change = 
	{
		["birzhamemov_solo"] = 2,
		["birzhamemov_duo"] = 2,
		["birzhamemov_trio"] = 2,
		["birzhamemov_5v5v5"] = 4,
		["birzhamemov_5v5"] = 4,
		["birzhamemov_zxc"] = 0,
		["birzhamemov_samepick"] = 4,
	}
	local new_kills = current_max_kills - maps_scores_change[GetMapName()]
	if leader_max_kills >= new_kills then
		new_kills = leader_max_kills + math.floor(( maps_scores_change[GetMapName()] / 2 ))
	end
	if new_kills > MAPS_MAX_SCORES[GetMapName()] then
		new_kills = MAPS_MAX_SCORES[GetMapName()]
	end
	CustomNetTables:SetTableValue( "game_state", "scores_to_win", { kills = new_kills } )
end

function BirzhaGameMode:GetMaxKillLeader()
	local team = {}
    local teams_table = {2,3,6,7,8,9,10,11,12,13}
    for _, i in ipairs(teams_table) do
        local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
        if table_team_score then
            table.insert(team, {id = i, kills = table_team_score.kills} )
        end
    end 
    table.sort( team, function(x,y) return y.kills < x.kills end )
    return team[1].kills
end

-- Окончание игры
function BirzhaGameMode:EndGame( victoryTeam )
	if BirzhaGameMode.game_is_end then return end
	BirzhaGameMode.game_is_end = true
	BirzhaData:RegisterEndGameItems()
    BirzhaData:PlayVictoryPlayerSound(victoryTeam)
	if GameRules:IsCheatMode() and not IsInToolsMode() then 
        GameRules:SetGameWinner( victoryTeam ) 
        return 
    end
	if GetMapName() == "birzhamemov_zxc" then
		CustomNetTables:SetTableValue("birzha_mmr", "game_winner", {t = victoryTeam} )
		BirzhaData.PostData()
		GameRules:SetGameWinner( victoryTeam )
		return
	end
	Timers:CreateTimer(1, function()
		GameRules:SetGameWinner( victoryTeam )
	end)
	if BirzhaData:GetPlayerCount() > 5 or IsInToolsMode() then
		CustomNetTables:SetTableValue("birzha_mmr", "game_winner", {t = victoryTeam} )
		BirzhaData.PostData()
		BirzhaData.PostHeroesInfo()
		BirzhaData.PostHeroPlayerHeroInfo()
		BirzhaData:SendDataPlayerReports()
	end
end

-- Ивент убийства

function BirzhaGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
    local hero = nil

    -- Если существует убийца
	if event.entindex_attacker then
		hero = EntIndexToHScript( event.entindex_attacker )
	end

    -- Какая-то хуйня, не помню че она делает
  	if not killedUnit.IsRealHero or not killedUnit:IsRealHero() then
  		local panels = WorldPanels.entToPanels[killedUnit]
		if panels then
	  		for i=1,#panels do
	    		local panel = panels[i]
	    		for j=1,#panel.pids do
	      			local pid = panel.pids[j]
	      			PlayerTables:DeleteTableKey("worldpanels_" .. pid, panel.idString)
	    		end
	  		end
		end
    end

    -- Респавн время установить
	if killedUnit:IsRealHero() then
		if killedUnit:GetRespawnTime() > 10 then
			if killedUnit:IsReincarnating() == true then
				return nil
			else
				BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit )
			end
		else
			BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit )
		end
	end

	if hero ~= nil then
		local heroTeam = hero:GetTeam()
		local game_time = BIRZHA_GAME_ALL_TIMER / 60

        -- Бонус за вард
		if killedUnit:IsBaseNPC() and killedUnit:IsWard() then
			local mod = hero:FindModifierByName("modifier_item_birzha_ward")
			if mod then
				if killedUnit:GetUnitName() == "npc_dota_observer_wards" then
					hero:ModifyGold( 50, true, 0 )
				elseif killedUnit:GetUnitName() == "npc_dota_sentry_wards" then
					hero:ModifyGold( 25, true, 0 )
				end 
			end
		end

		if killedUnit:IsRealHero() and heroTeam ~= killedTeam then
			-- Бесполезные ивенты со звуками
            if killedUnit:GetUnitName() == "npc_dota_hero_treant" then
                if RollPercentage(25) then
                    killedUnit:EmitSound("OverlordDeath")
                end
            elseif hero:GetUnitName() == "npc_dota_hero_treant" then
                hero:OverlordKillSound(hero, killedUnit)
            end
            if killedUnit:GetUnitName() == "npc_dota_hero_sasake" then
                if RollPercentage(25) then
                    killedUnit:EmitSound("sasake_death")
                end
            elseif hero:GetUnitName() == "npc_dota_hero_sasake" then
                if RollPercentage(25) then
                    hero:EmitSound("sasake_kill")
                end
            end
            if killedUnit:GetUnitName() == "npc_dota_hero_travoman" then
                if RollPercentage(25) then
                    killedUnit:EmitSound("travoman_death")
                end
            elseif hero:GetUnitName() == "npc_dota_hero_travoman" then
                if RollPercentage(25) then
                    hero:EmitSound("travoman_kill")
                end
            end
            -- Бесполезный эффект за убийство
            if DonateShopIsItemBought(hero:GetPlayerOwnerID(), 194) then
                local particle = ParticleManager:CreateParticle("particles/econ/items/drow/drow_arcana/drow_v2_arcana_revenge_kill_effect_caster.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                ParticleManager:SetParticleControlEnt(particle, 1, hero, PATTACH_POINT_FOLLOW, nil, hero:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(particle)
            end
            -- Бонус скейл лидера
			local bonus = false
			local attacker_kills = 0
			local target_kills = 0
			local networth_attacker = 0
			local networth_target = 0
			local team = {}
			local teams_table = {2,3,6,7,8,9,10,11,12,13}
            for _, i in ipairs(teams_table) do
                local table_team_score = CustomNetTables:GetTableValue("game_state", tostring(i))
                if table_team_score then
                    table.insert(team, {id = i, kills = table_team_score.kills} )
                end
            end  
			table.sort( team, function(x,y) return y.kills < x.kills end )
            for _, team_info in pairs(team) do
                if team_info.id == killedUnit:GetTeamNumber() then
                    target_kills = team_info.kills
                end
                if team_info.id == hero:GetTeamNumber() then
                    attacker_kills = team_info.kills
                end
            end
			if PlayerResource:GetNetWorth(hero:GetPlayerOwnerID()) ~= nil then
			  	networth_attacker = PlayerResource:GetNetWorth(hero:GetPlayerOwnerID())
			end
			if PlayerResource:GetNetWorth(killedUnit:GetPlayerOwnerID()) ~= nil then
			  	networth_target = PlayerResource:GetNetWorth(killedUnit:GetPlayerOwnerID())
			end
			if target_kills > attacker_kills and networth_target > networth_attacker then
			    bonus = true
			end
            local bonus_visual_gold = 0
            local bonus_visual_exp = 0
            if bonus and (game_time >= 5 or IsInToolsMode()) then
                local memberID = hero:GetPlayerOwnerID()
                local gold = (250 + (250 * game_time / 10)) + ((target_kills - attacker_kills) * 50)
                local exp = (500 * (game_time / 5)) + ((target_kills - attacker_kills) * 100)
                bonus_visual_gold = gold
                bonus_visual_exp = exp
                PlayerResource:ModifyGold( memberID, gold, true, 0 )
                if hero:IsHero() then
                    hero:AddExperience( exp, 0, false, false )
                end
            else
                if hero:IsHero() then
                    hero:AddExperience( 100, 0, false, false )
                end
            end
            if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false and game_time >= 5 then
                local name = hero:GetClassname()
                local victim = killedUnit:GetClassname()
                local kill_alert =
                {
                    hero_id = hero:GetUnitName()
                }
                CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "__", icon = "leader", kill = 1, hero_id = hero:GetUnitName(), exp = math.floor(bonus_visual_exp), gold = math.floor(bonus_visual_gold)} )
            end

			--- Overlord Чушпан
			local modifier_passive = hero:FindModifierByName("modifier_Overlord_passive")
	        if modifier_passive then
	            modifier_passive:SetStackCount(modifier_passive:GetStackCount()+5)
	        end

            -- Ассисты
			local allHeroes = HeroList:GetAllHeroes()
			for _, attacker in pairs( allHeroes ) do
				for i = 0, killedUnit:GetNumAttackers() - 1 do
					if attacker:GetPlayerOwnerID() == killedUnit:GetAttacker( i ) then
						attacker:AddExperience( 50, 0, false, false )
						if attacker ~= hero then
                            -- Overlord Чушпан
							local modifier_passive = attacker:FindModifierByName("modifier_Overlord_passive")
				            if modifier_passive then
				                modifier_passive:SetStackCount(modifier_passive:GetStackCount()+2)
				            end
							local mod = attacker:FindModifierByName("modifier_item_birzha_ward")
							if mod and attacker:IsRealHero() then
								if hero:GetTeamNumber() == attacker:GetTeamNumber() then
									mod:GetAbility().assists = mod:GetAbility().assists + 1
									if mod:GetAbility().assists >= 30 then
										attacker:ModifyGold( 125, true, 0 )
										mod:SetStackCount(3)
										mod:GetAbility().level = 3
									elseif mod:GetAbility().assists >= 15 then
										attacker:ModifyGold( 100, true, 0 )
										mod:SetStackCount(2)
										mod:GetAbility().level = 2
									elseif mod:GetAbility().assists < 15 then
										attacker:ModifyGold( 75, true, 0 )
									end
								end
							end
						end
					end
				end
			end
		end
    end
end

function BirzhaGameMode:SetRespawnTime( killedTeam, killedUnit )
    -- Respawn Jull герой
	if killedUnit:HasModifier("modifier_jull_steal_time") then
		local respawn_time_base = 5
		local bonus_respawn_time = math.floor(math.min(BIRZHA_GAME_ALL_TIMER / 240, 8))
		if killedTeam == self.leadingTeam then
			if BIRZHA_GAME_ALL_TIMER >= 600 then
				bonus_respawn_time = bonus_respawn_time + 8
			elseif BIRZHA_GAME_ALL_TIMER >= 300 then
				bonus_respawn_time = bonus_respawn_time + 6
			elseif BIRZHA_GAME_ALL_TIMER >= 120 then
				bonus_respawn_time = bonus_respawn_time + 4
			elseif BIRZHA_GAME_ALL_TIMER >= 0 then
				bonus_respawn_time = bonus_respawn_time + 0
			end
		end
		local respawn_time = respawn_time_base + bonus_respawn_time
		local modifier = killedUnit:FindModifierByName("modifier_jull_steal_time_stack")
		if modifier then
			local stackcount = modifier:GetStackCount()
			if stackcount > 0 then
				for i = 1, stackcount do
					if respawn_time > 1 then
						respawn_time = respawn_time - 1
						modifier:DecrementStackCount()
					end
				end
			end
		end
		if respawn_time < 1 then
			respawn_time = 1
		end
		killedUnit:SetTimeUntilRespawn( respawn_time )
		return
	end

    -- Респавн для лидера и не для лидера
	if killedTeam == self.leadingTeam then
		local respawn_time_base = 5
		local bonus_respawn_time = math.floor(math.min(BIRZHA_GAME_ALL_TIMER / 240, 8))
		if BIRZHA_GAME_ALL_TIMER >= 600 then
			bonus_respawn_time = bonus_respawn_time + 8
		elseif BIRZHA_GAME_ALL_TIMER >= 300 then
			bonus_respawn_time = bonus_respawn_time + 6
		elseif BIRZHA_GAME_ALL_TIMER >= 120 then
			bonus_respawn_time = bonus_respawn_time + 4
		elseif BIRZHA_GAME_ALL_TIMER >= 0 then
			bonus_respawn_time = bonus_respawn_time + 0
		end
		killedUnit:SetTimeUntilRespawn( respawn_time_base + bonus_respawn_time )
	else
		local respawn_time_base = 5
		local bonus_respawn_time = math.floor(math.min(BIRZHA_GAME_ALL_TIMER / 240, 8))
		killedUnit:SetTimeUntilRespawn( respawn_time_base + bonus_respawn_time )
	end
end

-- Спавн героя
function BirzhaGameMode:OnNPCSpawned( event )
	local hero = EntIndexToHScript(event.entindex)

	-- Дисконнект игрока
	if hero and hero:HasModifier("modifier_birzha_disconnect") then
		hero:AddNewModifier(hero, nil, "modifier_fountain_invulnerability", {})
	end

	-- Шпага для чариота
	if hero:GetUnitName() == "npc_palnoref_chariot" then
		if not hero.chariot_sword or ( hero.chariot_sword and hero.chariot_sword == nil )then
			hero.chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
			hero.chariot_sword:FollowEntity(hero, true)
		end
	end
	if hero:GetUnitName() == "npc_palnoref_chariot_illusion" then
		local illusion_chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
		illusion_chariot_sword:FollowEntity(hero, true)
		illusion_chariot_sword:SetRenderColor(0, 0, 0)
	end
	if hero:GetUnitName() == "npc_palnoref_chariot_illusion_2" then
		local illusion_chariot_sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/polnaref/chariot_sword.vmdl"})
		illusion_chariot_sword:FollowEntity(hero, true)
		illusion_chariot_sword:SetRenderColor(0, 0, 0)
	end

	-- Иллюзии инвокера
	if hero and hero:IsIllusion() and hero:GetUnitName() == "npc_dota_hero_oracle" then
    	local original_aang = nil
    	for _,hero in pairs (HeroList:GetAllHeroes()) do
    		if hero:GetUnitName() == "npc_dota_hero_oracle" and not hero:IsIllusion() then
    			original_aang = hero
    		end
    	end
    	if original_aang ~= nil then
    		local modifiers = original_aang:FindAllModifiers() 
    		for _,modifier in pairs(modifiers) do 
    			if modifier:GetName() == "modifier_aang_quas" then
    				local modifier_2 = hero:AddNewModifier(hero, hero:FindAbilityByName( "aang_quas" ), "modifier_aang_quas", {})
    				hero:FindAbilityByName( "aang_invoke" ):OnUpgrade()
    				hero:FindAbilityByName( "aang_invoke" ):AddOrb( modifier_2, "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf" )
    			elseif modifier:GetName() == "modifier_aang_exort" then
    				local modifier_2 = hero:AddNewModifier(hero, hero:FindAbilityByName( "aang_exort" ), "modifier_aang_exort", {})
    				hero:FindAbilityByName( "aang_invoke" ):OnUpgrade()
    				hero:FindAbilityByName( "aang_invoke" ):AddOrb( modifier_2, "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf" )
    			elseif modifier:GetName() == "modifier_aang_wex" then
    				local modifier_2 = hero:AddNewModifier(hero, hero:FindAbilityByName( "aang_wex" ), "modifier_aang_wex", {})
    				hero:FindAbilityByName( "aang_invoke" ):OnUpgrade()
    				hero:FindAbilityByName( "aang_invoke" ):AddOrb( modifier_2, "particles/avatar/aang_earth_orb.vpcf" )
    			end 
    		end
    	end
    end

	-- Если спавнится настоящий герой
	if hero:IsRealHero() then
		local PlayerID = hero:GetPlayerOwnerID()
		local PlayerSteamID = PlayerResource:GetSteamAccountID(PlayerID)
		--Бесполезные звуки появления
		if hero:GetUnitName() == "npc_dota_hero_treant" then
			if hero.BirzhaFirstSpawned then
				if RollPercentage(25) then
	   				hero:EmitSound("OverlordRein")
				end
	   		else
				hero:EmitSound("OverlordSpawn")
			end
	   	end
	   	if hero:GetUnitName() == "npc_dota_hero_venom" then
			if hero.BirzhaFirstSpawned == nil then
	   			hero:EmitSound("venom_start")
	   		end
	   	end
	   	if hero:GetUnitName() == "npc_dota_hero_travoman" then
			if RollPercentage(25) or hero.BirzhaFirstSpawned == nil then
	   			hero:EmitSound("travoman_spawn")
			end
	   	end
		if hero:GetUnitName() == "npc_dota_hero_sasake" then
			if hero.BirzhaFirstSpawned then
				if RollPercentage(20) then
	   				hero:EmitSound("sasake_respawn")
	   			end
	   		end
	   		Timers:CreateTimer(0.5, function()
	   			hero:RemoveModifierByName("modifier_medusa_mana_shield")
	   		end)
	   	end
		-- Задание пуччи на возрождение
	    local ability_pucci = hero:FindAbilityByName("pucci_restart_world")
        if ability_pucci and ability_pucci:GetLevel() > 0 then
            if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_respawn" then
                ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
                local player = PlayerResource:GetPlayer(hero:GetPlayerOwnerID())
                CustomGameEventManager:Send_ServerToPlayer(player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                    ability_pucci.current_quest[4] = true
                    ability_pucci.word_count = ability_pucci.word_count + 1
                    ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_stunned"]
                    ability_pucci:SetActivated(true)
                    CustomGameEventManager:Send_ServerToPlayer(player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
                end
            end
        end
		-- Бессмертие после возрождения
		if BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then
			if not hero:IsReincarnating() then
				if not hero:IsIllusion() then
					hero:AddInvul(3)
				end
			end
		end
		-- То, что вызывается только на старте игры
	   	if hero.BirzhaFirstSpawned == nil then
			hero.BirzhaFirstSpawned = true
	   		if hero:IsRealHero() then
	   			if BirzhaData.PLAYERS_GLOBAL_INFORMATION[PlayerID] then
					BirzhaData.PLAYERS_GLOBAL_INFORMATION[PlayerID].team = hero:GetTeamNumber()
	   			end
	   		end
	   		if hero:GetUnitName() == "npc_dota_hero_wisp" then
				local start_stun = hero:FindAbilityByName("game_start")
				if start_stun then
					start_stun:SetLevel(1)
				end
	   			return
	   		end
	   		if BirzhaData.PLAYERS_GLOBAL_INFORMATION[PlayerID] then
				if BirzhaData.PLAYERS_GLOBAL_INFORMATION[PlayerID].has_report > 0 then
					local ban_mod = hero:AddNewModifier(hero, nil, "modifier_birzha_loser", {})
	   				ban_mod:SetStackCount(BirzhaData.PLAYERS_GLOBAL_INFORMATION[PlayerID].has_report)
				end
			end
			if hero:IsHero() then
				BirzhaGameMode:AbilitiesStart(hero)
			end
            if IsInToolsMode() and PlayerResource:IsFakeClient(PlayerID) then
                BirzhaData:RegisterPlayer(PlayerID)
                BirzhaData.PLAYERS_GLOBAL_INFORMATION[PlayerID].selected_hero = hero
            end
		end	
	end

	if hero:IsHero() and hero.AddedCustomModels == nil then
		hero.AddedCustomModels = true
		hero.overlord_kill = nil
		BirzhaGameMode:OnHeroInGame(hero)
	end
end

function BirzhaGameMode:AbilitiesStart(hero)
	local FastAbilities = 
	{
		"Ayano_Mischief",
		"Ranger_Jump",
		"edward_bil_prank",
		"Rikardo_Fire",
		"dio_vampire",
		"Akame_Demon",
		"face_esketit",
		"goku_blink_one",
		"Akame_jump",
		"Miku_ritmic_song",
		"Felix_water_block",
		"gorshok_death_passive",
		"overlord_select_target",
		"haku_mask",
		"haku_zerkalo",
		"kakashi_invoke",
		"aang_invoke",
		"migi_death",
		"overlord_spellbook_close",
		"Overlord_passive",
		"gorshok_evil_dance",
		"pucci_passive_dio",
		"pucci_passive_wave",
		"pyramide_passive",
		"sonic_steal_speed",
		"sonic_passive",
		"travoman_minefield_sign",
		"travoman_focused_detonate",
		"jull_light_future",
		"jull_steal_time",
        "kelthuzad_cold_undead",
	}

	for _, name in pairs(FastAbilities) do
	   	local FastAbility = hero:FindAbilityByName(name)
		if FastAbility then
			FastAbility:SetLevel(1)
		end
	end
end

function BirzhaGameMode:OnHeroInGame(hero)
	local playerID = hero:GetPlayerID()
	local npcName = hero:GetUnitName()

    -- Heroes with visual particles
    if npcName == "npc_dota_hero_travoman" then
		local particle_cart = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_ambient_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:SetParticleControlEnt( particle_cart, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	end
    if npcName == "npc_dota_hero_kelthuzad" then
        local particle_list =
        {
            {"particles/econ/items/lich/forbidden_knowledge/lich_forbidden_knowledge_ambient_book.vpcf", "attach_hitloc"},
            {"particles/units/heroes/hero_lich/lich_ambient_frost.vpcf", "attach_attack1"},
            {"particles/units/heroes/hero_lich/lich_ambient_frost_legs.vpcf", "attach_hitloc"},
            {"particles/units/heroes/hero_lich/lich_ambient_frost_ground_effect.vpcf", "attach_hitloc"},
        }
        for _, info in pairs(particle_list) do
		    local particle = ParticleManager:CreateParticle(info[1], PATTACH_ABSORIGIN_FOLLOW, hero)
		    ParticleManager:SetParticleControlEnt( particle, 0, hero, PATTACH_POINT_FOLLOW, info[2], Vector(0,0,0), true )
            if _ == 1 then
                ParticleManager:SetParticleControlEnt( particle, 1, hero, PATTACH_POINT_FOLLOW, info[2], Vector(0,0,0), true )
            end
        end
	end

    -- Heroes with Free Items
    if npcName == "npc_dota_hero_serega_pirat" then
		hero.pirat_item_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_weapon/god_eater_weapon.vmdl" })
		hero.pirat_item_weapon:FollowEntity(hero, true)
		hero.pirat_item_offhand = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_off_hand/god_eater_off_hand.vmdl" })
		hero.pirat_item_offhand:FollowEntity(hero, true)
		hero.pirat_item_shoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_shoulder/god_eater_shoulder.vmdl" })
		hero.pirat_item_shoulder:FollowEntity(hero, true)
		hero.pirat_item_head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_head/god_eater_head.vmdl" })
		hero.pirat_item_head:FollowEntity(hero, true)
		hero.pirat_item_belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_belt/god_eater_belt.vmdl" })
		hero.pirat_item_belt:FollowEntity(hero, true)
		hero.pirat_item_arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_arms/god_eater_arms.vmdl" })
		hero.pirat_item_arms:FollowEntity(hero, true)
		hero.pirat_item_armor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/antimage/god_eater_armor/god_eater_armor.vmdl" })
		hero.pirat_item_armor:FollowEntity(hero, true)
	end

    if npcName == "npc_dota_hero_sasake" then
		hero.JuggHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/arcana/juggernaut_arcana_mask.vmdl"})
		hero.JuggHead:FollowEntity(hero, true)
		hero.JugLegs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/armor_for_the_favorite_legs/armor_for_the_favorite_legs.vmdl"})
		hero.JugLegs:FollowEntity(hero, true)
		hero.JugSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/jugg_ti8/jugg_ti8_sword.vmdl"})
		hero.JugSword:FollowEntity(hero, true)
		hero.JugSword_particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/jugg_ti8_crimson_sword_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.JugSword)
	end

    if hero:GetUnitName() == "npc_dota_hero_void_spirit" then
		hero.model_void_1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_head.vmdl"})
		hero.model_void_1:FollowEntity(hero, true)
		hero.model_void_2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_armor.vmdl"})
		hero.model_void_2:FollowEntity(hero, true)
		hero.effectvan = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.model_void_1)
	end

    if hero:GetUnitName() == "npc_dota_hero_grimstroke" then
		if hero ~= nil and hero:IsHero() then
			local children = hero:GetChildren();
			for k,child in pairs(children) do
				if child:GetClassname() == "dota_item_wearable" and child:GetModelName() == "models/heroes/grimstroke/grimstroke_head_item.vmdl" then
					child:RemoveSelf();
				end
			end
		end
	end

    if npcName == "npc_dota_hero_abaddon" then
		hero.WeaponMeepo = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/meepo/ti8_meepo_pitmouse_fraternity_weapon/ti8_meepo_pitmouse_fraternity_weapon.vmdl"})
		hero.WeaponMeepo:FollowEntity(hero, true)
	end

	if npcName == "npc_dota_hero_enigma" then
		hero.Ricardo = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/axe/ricardaxe.vmdl"})
		hero.Ricardo:FollowEntity(hero, true)
	end

    if npcName == "npc_dota_hero_nyx_assassin" then
		hero.Stray1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/ti6_blink_strike/riki_ti6_blink_strike.vmdl"})
		hero.Stray1:FollowEntity(hero, true)
		hero.Stray2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/umbrage/umbrage.vmdl"})
		hero.Stray2:FollowEntity(hero, true)
		hero.Stray3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/umbrage__offhand/umbrage__offhand.vmdl"})
		hero.Stray3:FollowEntity(hero, true)
		hero.Stray4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/riki_ti8_immortal_head/riki_ti8_immortal_head.vmdl"})
		hero.Stray4:FollowEntity(hero, true)
		hero.Stray5 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/rikimaru/riki_cunning_corsair_ti_2017_tail/riki_cunning_corsair_ti_2017_tail.vmdl"})
		hero.Stray5:FollowEntity(hero, true)
		hero.stray_effect_1 = ParticleManager:CreateParticle("particles/econ/items/riki/riki_head_ti8/riki_head_ambient_ti8.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.Stray4)
		hero.stray_effect_2 = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.Stray1)
	end





    
    
    
    

    
    
    
    

















	if hero:IsIllusion() then
		hero:AddNewModifier( hero, nil, "modifier_birzha_illusion_cosmetics", {} )
	end







































	if hero:GetUnitName() == "npc_dota_hero_nevermore" then
		if DonateShopIsItemBought(playerID, 27) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" and child:GetModelName() ~= "models/heroes/shadow_fiend/shadow_fiend_head.vmdl" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/heroes/shadow_fiend/shadow_fiend_arcana.vmdl")
			hero.NevermoreWings = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/shadow_fiend/arcana_wings.vmdl"})
			hero.NevermoreWings:FollowEntity(hero, true)
			hero.NevermorePauldrons = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/nevermore/ferrum_chiroptera_shoulder/ferrum_chiroptera_shoulder.vmdl"})
			hero.NevermorePauldrons:FollowEntity(hero, true)
			hero.NevermoreHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/shadow_fiend/head_arcana.vmdl"})
			hero.NevermoreHead:FollowEntity(hero, true)
			hero.NevermoreArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/shadow_fiend/arms_deso/arms_deso.vmdl"})
			hero.NevermoreArms:FollowEntity(hero, true)

			Timers:CreateTimer(0.25, function()
				local desolator = ParticleManager:CreateParticle("particles/never_arcana/desolationhadow_fiend_desolation_ambient.vpcf", PATTACH_CUSTOMORIGIN, hero)
				ParticleManager:SetParticleControlEnt( desolator, 0, hero, PATTACH_POINT_FOLLOW, "attach_arm_L", Vector(0,0,0), true )
				ParticleManager:SetParticleControlEnt( desolator, 1, hero, PATTACH_POINT_FOLLOW, "attach_arm_R", Vector(0,0,0), true )
			end)
			
			hero:AddNewModifier( hero, nil, "modifier_bp_never_reward", {})
		end
	end

	if npcName == "npc_dota_hero_earthshaker" then
		if DonateShopIsItemBought(playerID, 28) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/items/earthshaker/earthshaker_arcana/earthshaker_arcana.vmdl")
			hero.ValakasHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/earthshaker_arcana/earthshaker_arcana_head.vmdl"})
			hero.ValakasHead:FollowEntity(hero, true)
			hero.ValakasWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/ti9_immortal/ti9_immortal.vmdl"})
			hero.ValakasWeapon:FollowEntity(hero, true)
			hero.ValakasHands = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/frostivus2018_es_frozen_wastes_arms/frostivus2018_es_frozen_wastes_arms.vmdl"})
			hero.ValakasHands:FollowEntity(hero, true)
			hero.HeadSAaker = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.ValakasHead)
			hero.WeaponShaker = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_ti9/earthshaker_ti9_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.ValakasWeapon)
			hero:AddNewModifier( hero, nil, "modifier_bp_valakas_reward", {})
		end
	end

	if npcName == "npc_dota_hero_legion_commander" then
		if DonateShopIsItemBought(playerID, 126) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:AddActivityModifier("dualwield")
			hero:AddActivityModifier("arcana")
			hero:SetMaterialGroup("1")
			hero.AyanoHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_head/radiant_conqueror_head.vmdl"})
			hero.AyanoHead:FollowEntity(hero, true)
			hero.AyanoArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_arms/radiant_conqueror_arms.vmdl"})
			hero.AyanoArms:FollowEntity(hero, true)
			hero.AyanoBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_back/radiant_conqueror_back.vmdl"})
			hero.AyanoBack:FollowEntity(hero, true)
			hero.AyanoShoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_shoulder/radiant_conqueror_shoulder.vmdl"})
			hero.AyanoShoulder:FollowEntity(hero, true)
			hero.AyanoLegs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/radiant_conqueror_legs/radiant_conqueror_legs.vmdl"})
			hero.AyanoLegs:FollowEntity(hero, true)
			hero.AyanoSword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/legion_commander/demon_sword.vmdl"})
			hero.AyanoSword:FollowEntity(hero, true)

			ParticleManager:CreateParticle("particles/econ/items/legion/legion_radiant_conqueror/legion_radiant_conqueror_back_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoBack)
			ParticleManager:CreateParticle("particles/econ/items/legion/legion_radiant_conqueror/legion_radiant_conqueror_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoHead)
			ParticleManager:CreateParticle("particles/econ/items/legion/legion_radiant_conqueror/legion_radiant_conqueror_shoulder_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoShoulder)

			local particle_ayano_1 = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_arcana_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoSword)
			ParticleManager:SetParticleControlEnt( particle_ayano_1, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
			local particle_ayano_2 = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_arcana_weapon_offhand.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.AyanoSword)
			ParticleManager:SetParticleControlEnt( particle_ayano_2, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )

			hero:AddNewModifier( hero, nil, "modifier_bp_ayano", {})
		end
	end

	if npcName == "npc_dota_hero_monkey_king" then
		if DonateShopIsItemBought(playerID, 130) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end

			hero:AddActivityModifier("arcana")
			
			hero.BoyHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/monkey_king_arcana_head/mesh/monkey_king_arcana.vmdl"})
			hero.BoyHead:FollowEntity(hero, true)
			hero.BoyWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/monkey_king_immortal_weapon/monkey_king_immortal_weapon.vmdl"})
			hero.BoyWeapon:FollowEntity(hero, true)
			hero.BoyArmor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/mk_ti9_immortal_armor/mk_ti9_immortal_armor.vmdl"})
			hero.BoyArmor:FollowEntity(hero, true)
			hero.BoyShoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/monkey_king/mk_ti9_immortal_shoulder/mk_ti9_immortal_shoulder.vmdl"})
			hero.BoyShoulder:FollowEntity(hero, true)
			hero.BoyWeapon:SetMaterialGroup("2")
			hero:SetMaterialGroup("1")
			ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/monkey_king_arcana_crown_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BoyHead)
			ParticleManager:CreateParticle("particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_armor_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BoyArmor)
			ParticleManager:CreateParticle("particles/econ/items/monkey_king/ti7_weapon/mk_ti7_golden_immortal_weapon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BoyWeapon)
			local particle_boy_1 = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/monkey_king_arcana_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
			ParticleManager:SetParticleControl(particle_boy_1, 0, hero:GetAbsOrigin())
			hero:AddNewModifier( hero, nil, "modifier_bp_dangerous_boy", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_lycan" then
		if DonateShopIsItemBought(playerID, 37) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/creeps/knoll_1/werewolf_boss.vmdl")
			hero:SetModelScale(1.4)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_queenofpain" then
		if DonateShopIsItemBought(playerID, 26) then
			hero:SetOriginalModel("models/update_heroes/kurumi/kurumi_arcana.vmdl")
			hero:SetModelScale(0.92)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_faceless_void" then
		if DonateShopIsItemBought(playerID, 180) then
			hero:SetOriginalModel("models/dio_arcana/dio_arcana.vmdl")
			hero:SetModelScale(1.03)
			hero:AddNewModifier(hero, nil, "modifier_bp_dio", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_oracle" then
		if DonateShopIsItemBought(playerID, 182) then
			hero:SetOriginalModel("models/korra/korra_model.vmdl")
			hero:AddNewModifier(hero, nil, "modifier_avatar_persona", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_sonic" then
		if DonateShopIsItemBought(playerID, 183) then
			hero:SetOriginalModel("models/sonic_arcana/sonic_arcana.vmdl")
			hero:AddNewModifier(hero, nil, "modifier_sonic_arcana", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_alchemist" then
		if DonateShopIsItemBought(playerID, 36) then
			hero.brb_crown = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/crown_bigrussianboss.vmdl"})
			hero.brb_crown:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_pudge" then
		if DonateShopIsItemBought(playerID, 25) then
			hero:SetOriginalModel("models/items/pudge/arcana/pudge_arcana_base.vmdl")
			hero.PudgeBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/pudge/arcana/pudge_arcana_back.vmdl"})
			hero.PudgeBack:FollowEntity(hero, true)
			hero.PudgeEffect = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_back_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PudgeBack)
			hero:AddNewModifier( hero, nil, "modifier_bp_mum_arcana", {})
		end
		if DonateShopIsItemBought(playerID, 39) then
			hero.pudge_mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/pudge_kaneki_mask.vmdl"})
			hero.pudge_mask:FollowEntity(hero, true)
			hero:AddNewModifier( hero, nil, "modifier_bp_mum_mask", {})
		end

		if DonateShopIsItemBought(playerID, 179) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" and (string.find(child:GetModelName(), "weapon") == nil and string.find(child:GetModelName(), "hook") == nil) then
						child:RemoveSelf();
					elseif child:GetClassname() == "dota_item_wearable" and child:GetModelName() == "models/heroes/pudge/leftweapon.vmdl" then
						child:RemoveSelf();
					elseif child:GetClassname() == "dota_item_wearable" and (string.find(child:GetModelName(), "offhand") ~= nil) then
						child:RemoveSelf();
					end
				end
			end
			hero.pudge_gopo_back = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pudge_gopo_set/gopo_back.vmdl"})
			hero.pudge_gopo_back:FollowEntity(hero, true)
			hero.pudge_gopo_left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/pudge/leftarm.vmdl"})
			hero.pudge_gopo_left_arm:FollowEntity(hero, true)
			hero.pudge_gopo_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pudge_gopo_set/gopo_arm.vmdl"})
			hero.pudge_gopo_arm:FollowEntity(hero, true)
			hero.pudge_gopo_head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pudge_gopo_set/gopo_head.vmdl"})
			hero.pudge_gopo_head:FollowEntity(hero, true)
			hero.pudge_gopo_belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pudge_gopo_set/gopo_belt.vmdl"})
			hero.pudge_gopo_belt:FollowEntity(hero, true)
			hero.pudge_gopo_wepon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pudge_gopo_set/gopo_wepon.vmdl"})
			hero.pudge_gopo_wepon:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_bounty_hunter" then
		if DonateShopIsItemBought(playerID, 31) then
			hero.BountyWeapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/bounty_hunter/bh_ti9_immortal_weapon/bh_ti9_immortal_weapon.vmdl"})
			hero.BountyWeapon:FollowEntity(hero, true)
			hero.WeaponEffect = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.BountyWeapon)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_skeleton_king" then
		if DonateShopIsItemBought(playerID, 29) or IsInToolsMode() then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/items/wraith_king/arcana/wraith_king_arcana.vmdl")
			hero.PapichBloodShard = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_weapon.vmdl"})
			hero.PapichBloodShard:FollowEntity(hero, true)
			hero.PapichHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_head.vmdl"})
			hero.PapichHead:FollowEntity(hero, true)
			hero.PapichPauldrons = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_shoulder.vmdl"})
			hero.PapichPauldrons:FollowEntity(hero, true)

			if not DonateShopIsItemBought(playerID, 29) then
				hero.PapichPunch = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_arms.vmdl"})
				hero.PapichPunch:FollowEntity(hero, true)
			end

			hero.PapichCape = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_back.vmdl"})
			hero.PapichCape:FollowEntity(hero, true)
			hero.PapichArmor = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/arcana/wraith_king_arcana_armor.vmdl"})
			hero.PapichArmor:FollowEntity(hero, true)
			hero.SwordEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PapichBloodShard)
			hero.HeadEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_ambient_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PapichHead)
			hero.AmbientEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_ambient.vpcf", PATTACH_POINT_FOLLOW, hero)
			ParticleManager:SetParticleControl(hero.AmbientEffect, 0, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 1, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 2, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 3, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 4, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 5, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.AmbientEffect, 6, hero:GetAbsOrigin())
		end

		if DonateShopIsItemBought(playerID, 198) or IsInToolsMode() then
			hero.PapichPunch = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/wraith_king/blistering_shade/mesh/blistering_shade_alt.vmdl"})
			hero.PapichPunch:FollowEntity(hero, true)
			hero.PapichPunch:SetMaterialGroup("witness")
			hero.PapichEffect = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.PapichPunch)
			hero:AddNewModifier(hero, nil, "modifier_papich_hand_effect", {})
		end
		
	end

	if hero:GetUnitName() == "npc_dota_hero_sniper" then
		if DonateShopIsItemBought(playerID, 200) or IsInToolsMode() then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end

			hero.RangerShoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/scifi_sniper_test_shoulder/scifi_sniper_test_shoulder.vmdl"})
			hero.RangerShoulder:FollowEntity(hero, true)
			hero.RangerHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/scifi_sniper_test_head/scifi_sniper_test_head.vmdl"})
			hero.RangerHead:FollowEntity(hero, true)
			hero.RangerGun = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/scifi_sniper_test_gun/scifi_sniper_test_gun.vmdl"})
			hero.RangerGun:FollowEntity(hero, true)
			hero.RangerBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/scifi_sniper_test_back/scifi_sniper_test_back.vmdl"})
			hero.RangerBack:FollowEntity(hero, true)
			hero.RangerArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sniper/scifi_sniper_test_arms/scifi_sniper_test_arms.vmdl"})
			hero.RangerArms:FollowEntity(hero, true)
			hero:AddActivityModifier("scifi")
			hero:AddActivityModifier("SCIFI")
			hero:AddActivityModifier("MGC")
			hero:SetRangedProjectileName("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_base_attack.vpcf")

			hero.AmbientEffect1 = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_weapon_ambient.vpcf", PATTACH_POINT_FOLLOW, hero.RangerGun)
			hero.AmbientEffect2 = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_head.vpcf", PATTACH_POINT_FOLLOW, hero.RangerHead)
			hero.AmbientEffect3 = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_jetpack.vpcf", PATTACH_POINT_FOLLOW, hero.RangerBack)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_tiny" then
		if DonateShopIsItemBought(playerID, 30) then
			hero:SetOriginalModel("models/items/tiny/tiny_prestige/tiny_prestige_lvl_01.vmdl")
			hero:AddNewModifier( hero, nil, "modifier_bp_johncena", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_terrorblade" then
		hero:AddActivityModifier("arcana")
		hero:AddActivityModifier("abysm")
		if DonateShopIsItemBought(playerID, 34) then
			local TerrorbladeWeapons = {
				"models/heroes/terrorblade/weapon.vmdl",
				"models/items/terrorblade/corrupted_weapons/corrupted_weapons.vmdl",
				"models/items/terrorblade/endless_purgatory_weapon/endless_purgatory_weapon.vmdl",
				"models/items/terrorblade/knight_of_foulfell_terrorblade_weapon/knight_of_foulfell_terrorblade_weapon.vmdl",
				"models/items/terrorblade/marauders_weapon/marauders_weapon.vmdl",
				"models/items/terrorblade/tb_ti9_immortal_weapon/tb_ti9_immortal_weapon.vmdl",
				"models/items/terrorblade/tb_samurai_weapon/tb_samurai_weapon.vmdl",
				"models/heroes/terrorblade/terrorblade_weapon_planes.vmdl",

			}
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					for _,weapon in pairs(TerrorbladeWeapons) do
						if child:GetClassname() == "dota_item_wearable" and child:GetModelName() == weapon then
							child:RemoveSelf();
						end
					end
				end
			end

			hero.BookLeft = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/terrorblade_sobolev_book_left.vmdl"})
			hero.BookLeft:FollowEntity(hero, true)
			hero.BookRight = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/birzhapass/terrorblade_sobolev_book_right.vmdl"})
			hero.BookRight:FollowEntity(hero, true)
			hero:AddNewModifier( hero, nil, "modifier_bp_sobolev", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_sand_king" then
		if DonateShopIsItemBought(playerID, 22) then
			hero:SetMaterialGroup("event")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_pyramide" then
		if DonateShopIsItemBought(playerID, 181) then
			hero:SetMaterialGroup("battlepass")
			hero:AddNewModifier(hero, nil, "modifier_pyramide_persona", {})
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_winter_wyvern" then
		if DonateShopIsItemBought(playerID, 35) then
			hero:SetMaterialGroup("event")
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_dragon_knight" then
		if DonateShopIsItemBought(playerID, 38) then
			hero:SetOriginalModel("models/heroes/dragon_knight_persona/dk_persona_base.vmdl")
			hero.robbie_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/dragon_knight_persona/dk_persona_weapon_alt.vmdl"})
			hero.robbie_weapon:FollowEntity(hero, true)
		else
			hero.robbie_weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/dragon_knight/aurora_warrior_set_weapon/aurora_warrior_set_weapon.vmdl"})
			hero.robbie_weapon:FollowEntity(hero, true)
		end
	end

	if hero:GetUnitName() == "npc_dota_hero_ogre_magi" then
		if DonateShopIsItemBought(playerID, 23) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
					end
				end
			end
			hero:SetOriginalModel("models/creeps/ogre_1/boss_ogre.vmdl")
		end
	end



	if npcName == "npc_dota_hero_troll_warlord" then
		if DonateShopIsItemBought(playerID, 24) then
			if hero ~= nil and hero:IsHero() then
				local children = hero:GetChildren();
				for k,child in pairs(children) do
					if child:GetClassname() == "dota_item_wearable" then
							child:RemoveSelf();
					end
				end
			end
			hero.GorinStools = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/troll_warlord_gorin_stool.vmdl"})
			hero.GorinStools:FollowEntity(hero, true)
			hero.TrollHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/troll_warlord_head.vmdl"})
			hero.TrollHead:FollowEntity(hero, true)
			hero.TrollShoulders = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/troll_warlord_shoulders.vmdl"})
			hero.TrollShoulders:FollowEntity(hero, true)
			hero.TrollLod = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/mesh/troll_warlord_armor_model_lod0.vmdl"})
			hero.TrollLod:FollowEntity(hero, true)
			hero:SetRangedProjectileName("particles/gorin_attack_item.vpcf")
		end
	end

	if npcName == "npc_dota_hero_omniknight" then
		if DonateShopIsItemBought(playerID, 32) then
			hero.ZelenskyHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/omniknight_zelensky_head.vmdl"})
			hero.ZelenskyHead:FollowEntity(hero, true)
		end
	end

	if npcName == "npc_dota_hero_invoker" then
		if hero ~= nil and hero:IsHero() then
			local children = hero:GetChildren();
			for k,child in pairs(children) do
				if child:GetClassname() == "dota_item_wearable" then
						child:RemoveSelf();
				end
			end
		end
		if DonateShopIsItemBought(playerID, 33) then
			hero:AddNewModifier( hero, nil, "modifier_bp_druzhko_reward", {})
		end
		if DonateShopIsItemBought(playerID, 33) then
			hero.InvokerBelt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_armor.vmdl"})
			hero.InvokerBelt:FollowEntity(hero, true)
			hero.InvokerBracer = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_shoulder.vmdl"})
			hero.InvokerBracer:FollowEntity(hero, true)
			hero.InvokerArms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_arms.vmdl"})
			hero.InvokerArms:FollowEntity(hero, true)
			hero.InvokerBack = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/invoker_kid_dark_artistry_back.vmdl"})
			hero.InvokerBack:FollowEntity(hero, true)
			hero.InvokerApexKid = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/invoker_kid/dark_artistry_kid/magus_apex_kid.vmdl"})
			hero.InvokerApexKid:FollowEntity(hero, true)
			hero.invoker_effect_1 = ParticleManager:CreateParticle("particles/econ/items/invoker_kid/invoker_dark_artistry/invoker_kid_dark_artistry_cape_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.InvokerBack)
			hero.invoker_effect_2 = ParticleManager:CreateParticle("particles/econ/items/invoker_kid/invoker_dark_artistry/invoker_kid_magus_apex_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.InvokerApexKid)
		else
			hero.InvokerBelt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_cape.vmdl"})
			hero.InvokerBelt:FollowEntity(hero, true)
			hero.InvokerBracer = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_sleeves.vmdl"})
			hero.InvokerBracer:FollowEntity(hero, true)
		end
	end
end