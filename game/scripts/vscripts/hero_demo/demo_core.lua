-- THANK YOU https://github.com/MouJiaoZi/custom_hero_demo

if HeroDemo == nil then
	_G.HeroDemo = class({})
end

require("hero_demo/demo_events")

if not GameRules:IsCheatMode() then return end

LinkLuaModifier( "lm_take_no_damage", "hero_demo/demo_core.lua", LUA_MODIFIER_MOTION_NONE )
lm_take_no_damage = lm_take_no_damage or class({})
function lm_take_no_damage:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE} end
function lm_take_no_damage:GetTexture() return "modifier_invulnerable" end
function lm_take_no_damage:GetAbsoluteNoDamageMagical( params ) return 1 end
function lm_take_no_damage:GetAbsoluteNoDamagePhysical( params ) return 1 end
function lm_take_no_damage:GetAbsoluteNoDamagePure( params ) return 1 end

function HeroDemo:Init()
    if self.init then return end
    self.init = true

    CustomGameEventManager:RegisterListener( "RequestInitialSpawnHeroID", function(...) return self:OnRequestInitialSpawnHeroID( ... ) end )
    CustomGameEventManager:RegisterListener( "WelcomePanelDismissed", function(...) return self:OnWelcomePanelDismissed( ... ) end )
    CustomGameEventManager:RegisterListener( "RefreshButtonPressed", function(...) return self:OnRefreshButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LevelUpButtonPressed", function(...) return self:OnLevelUpButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "UltraMaxLevelButtonPressed", function(...) return self:OnUltraMaxLevelButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "FreeSpellsButtonPressed", function(...) return self:OnFreeSpellsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "CombatLogButtonPressed", function(...) return self:CombatLogButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SelectMainHeroButtonPressed", function(...) return self:OnSelectMainHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SelectSpawnHeroButtonPressed", function(...) return self:OnSelectSpawnHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "RemoveHeroButtonPressed", function(...) return self:OnRemoveHeroButtonPressed( ... ) end )	
    CustomGameEventManager:RegisterListener( "LevelUpHero", function(...) return self:OnLevelUpHero( ... ) end )
    CustomGameEventManager:RegisterListener( "MaxLevelUpHero", function(...) return self:OnMaxLevelUpHero( ... ) end )
    CustomGameEventManager:RegisterListener( "ScepterHero", function(...) return self:OnScepterHero( ... ) end )
    CustomGameEventManager:RegisterListener( "ShardHero", function(...) return self:OnShardHero( ... ) end )
    CustomGameEventManager:RegisterListener( "ResetHero", function(...) return self:OnResetHero( ... ) end )
    CustomGameEventManager:RegisterListener( "ToggleInvulnerabilityHero", function(...) return self:OnSetInvulnerabilityHero( nil, ... ) end )
    CustomGameEventManager:RegisterListener( "InvulnOnHero", function(...) return self:OnSetInvulnerabilityHero( true, ... ) end )
    CustomGameEventManager:RegisterListener( "InvulnOffHero", function(...) return self:OnSetInvulnerabilityHero( false, ... ) end )
    CustomGameEventManager:RegisterListener( "DummyTargetButtonPressed", function(...) return self:OnDummyTargetButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ChangeHeroButtonPressed", function(...) return self:OnChangeHeroButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "ChangeCosmeticsButtonPressed", function(...) return self:OnChangeCosmeticsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnCreepsButtonPressed", function(...) return self:OnSpawnCreepsButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnSingleCreepWaveButtonPressed", function(...) return self:OnSpawnSingleCreepWaveButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "TowersEnabledButtonPressed", function(...) return self:OnTowersEnabledButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "PauseButtonPressed", function(...) return self:OnPauseButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "LeaveButtonPressed", function(...) return self:OnLeaveButtonPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRuneDoubleDamagePressed", function(...) return self:OnSpawnRuneDoubleDamagePressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRuneHastePressed", function(...) return self:OnSpawnRuneHastePressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRuneIllusionPressed", function(...) return self:OnSpawnRuneIllusionPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRuneInvisibilityPressed", function(...) return self:OnSpawnRuneInvisibilityPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRuneRegenerationPressed", function(...) return self:OnSpawnRuneRegenerationPressed( ... ) end )
    CustomGameEventManager:RegisterListener( "SpawnRuneArcanePressed", function(...) return self:OnSpawnRuneArcanePressed( ... ) end )
    CustomGameEventManager:RegisterListener( "CreateDemoChest", function(...) return self:CreateDemoChest( ... ) end )

	self.m_bFreeSpellsEnabled = false
	self.m_bInvulnerabilityEnabled = false

	CustomNetTables:SetTableValue( "game_global", "ui_defaults", { WTFEnabled=Convars:GetInt("dota_ability_debug"), Cheats_enable = GameRules:IsCheatMode() } )
end

function HeroDemo:CreateDemoChest()
	BirzhaGameMode:SpawnItem()
end

function HeroDemo:SpawnHeroDemo( data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	local hPlayer = PlayerResource:GetPlayer( data.PlayerID )
	local sHeroToSpawn = tostring(data.hero_name)
	local team = tonumber(data.team)

	DebugCreateUnit( hPlayer, sHeroToSpawn, team, false,
	function( hAlly )
		hAlly:SetControllableByPlayer( hPlayerHero:GetPlayerID(), false )
		hAlly:SetRespawnPosition( hPlayerHero:GetAbsOrigin() )
		FindClearSpaceForUnit( hAlly, hPlayerHero:GetAbsOrigin(), false )
		hAlly:Hold()
		hAlly:SetIdleAcquire( false )
		hAlly:SetAcquisitionRange( 0 )
	end )
end

function HeroDemo:ChangeHeroDemo( data )
	PlayerResource:ReplaceHeroWith(data.PlayerID, data.hero_name, 99999, 0)
end

function HeroDemo:OnWelcomePanelDismissed( event )

end

-- ОБНОВИТЬ СКИЛЛЫ
function HeroDemo:OnRefreshButtonPressed( eventSourceIndex )
	local AllHeroes = HeroList:GetAllHeroes()
	for count, hero in ipairs(AllHeroes) do
		for i=0, hero:GetAbilityCount()-1 do
	        local ability = hero:GetAbilityByIndex( i )
	        if ability and ability:GetAbilityType()~=DOTA_ABILITY_TYPE_ATTRIBUTES then
	            ability:RefreshCharges()
	            ability:EndCooldown()
	        end
	    end

	    for i=0,8 do
	        local item = hero:GetItemInSlot(i)
	        if item then
	            item:EndCooldown()
	        end
	    end
	end
end


-- ПЛЮС 1 УРОВЕНЬ
function HeroDemo:OnLevelUpButtonPressed( eventSourceIndex )
	local AllHeroes = HeroList:GetAllHeroes()
	for count, hero in ipairs(AllHeroes) do
		hero:HeroLevelUp(false)
	end
end

-- МАКС. УРОВЕНЬ
function HeroDemo:OnUltraMaxLevelButtonPressed( eventSourceIndex, data )
	local AllHeroes = HeroList:GetAllHeroes()
	for count, hero in ipairs(AllHeroes) do
		for i=1,25 do
			hero:HeroLevelUp(false)
		end
	end
end

-- втф режим
function HeroDemo:OnFreeSpellsButtonPressed( eventSourceIndex )
    local nWTFEnabledEnabled = Convars:GetInt("dota_ability_debug") 

	if nWTFEnabledEnabled == 0 then	
		Convars:SetInt("dota_ability_debug", 1)
		self.m_bFreeSpellsEnabled = true
		local AllHeroes = HeroList:GetAllHeroes()
		for count, hero in ipairs(AllHeroes) do
			for i=0, hero:GetAbilityCount()-1 do
		        local ability = hero:GetAbilityByIndex( i )
		        if ability and ability:GetAbilityType()~=DOTA_ABILITY_TYPE_ATTRIBUTES then
		            ability:RefreshCharges()
		            ability:EndCooldown()
		        end
		    end

		    for i=0,8 do
		        local item = hero:GetItemInSlot(i)
		        if item then
		            item:EndCooldown()
		        end
		    end
		end
		self:BroadcastMsg( "#FreeSpellsOn_Msg" )
	elseif nWTFEnabledEnabled == 1 then
		Convars:SetInt("dota_ability_debug", 0)
		self.m_bFreeSpellsEnabled = false
		self:BroadcastMsg( "#FreeSpellsOff_Msg" )
	end
end

function HeroDemo:CombatLogButtonPressed( eventSourceIndex )

end

-- ИНВУЛ
function HeroDemo:OnSetInvulnerabilityHero( bInvuln, eventSourceIndex, data )
	local nHeroEntIndex = tonumber( data.str )
	local hHero = EntIndexToHScript( nHeroEntIndex )
	if ( hHero ~= nil and hHero:IsNull() == false ) then
		local hAllUnits = {}
		if hHero:IsRealHero() then
			hAllUnits = hHero:GetAdditionalOwnedUnits()
		end
		table.insert( hAllUnits, hHero )

		if bInvuln == nil then
			bInvuln = hHero:FindModifierByName( "lm_take_no_damage" ) == nil
		end

		if bInvuln then
			for _, hUnit in pairs( hAllUnits ) do
				hUnit:AddNewModifier( hHero, nil, "lm_take_no_damage", nil )
			end
		else
			for _, hUnit in pairs( hAllUnits ) do
				hUnit:RemoveModifierByName( "lm_take_no_damage" )
			end
		end
	end
end

function HeroDemo:OnRequestInitialSpawnHeroID( eventSourceIndex, data )

end

function HeroDemo:OnSelectMainHeroButtonPressed( eventSourceIndex, data )

end

function HeroDemo:OnSelectSpawnHeroButtonPressed( eventSourceIndex, data )

end

function HeroDemo:OnRemoveHeroButtonPressed( eventSourceIndex, data )

end

function HeroDemo:OnLevelUpHero( eventSourceIndex, data )
	local nHeroEntIndex = tonumber( data.str )
	local hHero = EntIndexToHScript( nHeroEntIndex )
	if ( hHero ~= nil and hHero:IsNull() == false ) then
		if hHero.HeroLevelUp then
			hHero:HeroLevelUp( true )
		end
	end
end

-- Максимальный уровнень
function HeroDemo:OnMaxLevelUpHero( eventSourceIndex, data )
	local nHeroEntIndex = tonumber( data.str )
	local hHero = EntIndexToHScript( nHeroEntIndex )
	if ( hHero ~= nil and hHero:IsNull() == false ) then
		if hHero.AddExperience then
			hHero:AddExperience( 59900, false, false )
			for i = 0, DOTA_MAX_ABILITIES - 1 do
				local hAbility = hHero:GetAbilityByIndex( i )
				if hAbility and not hAbility:IsAttributeBonus() then
					while hAbility:GetLevel() < hAbility:GetMaxLevel() and hAbility:CanAbilityBeUpgraded () == ABILITY_CAN_BE_UPGRADED and not hAbility:IsHidden()  do
						hHero:UpgradeAbility( hAbility )
					end
				end
			end
		end
	end
end

function HeroDemo:OnScepterHero( eventSourceIndex, data )
	local nHeroEntIndex = tonumber( data.str )
	local hHero = EntIndexToHScript( nHeroEntIndex )
	if ( hHero ~= nil and hHero:IsNull() == false ) then
		if not hHero:FindModifierByName( "modifier_item_ultimate_scepter_consumed" ) then
			hHero:AddNewModifier(hHero, nil, "modifier_item_ultimate_scepter_consumed", {})
		end
	end
end

function HeroDemo:OnShardHero( eventSourceIndex, data )
	local nHeroEntIndex = tonumber( data.str )
	local hHero = EntIndexToHScript( nHeroEntIndex )
	if ( hHero ~= nil and hHero:IsNull() == false ) then
		if not hHero:FindModifierByName( "modifier_item_aghanims_shard" ) then
			hHero:AddItemByName( "item_aghanims_shard" )
		end
	end
end

-- РЕСЕТ ХИРО
function HeroDemo:OnResetHero( eventSourceIndex, data )
	local nHeroEntIndex = tonumber( data.str )
	local hHero = EntIndexToHScript( nHeroEntIndex )
	if ( hHero ~= nil and hHero:IsNull() == false ) then
		GameRules:SetSpeechUseSpawnInsteadOfRespawnConcept( true )
		PlayerResource:ReplaceHeroWithNoTransfer( hHero:GetPlayerOwnerID(), hHero:GetUnitName(), -1, 0 )
		GameRules:SetSpeechUseSpawnInsteadOfRespawnConcept( false )
	end
end

-- СПАВН ДУММИ
function HeroDemo:OnDummyTargetButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	local hDummy = CreateUnitByName( "npc_dota_hero_target_dummy", hPlayerHero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS )
	hDummy:SetAbilityPoints( 0 )
	hDummy:Hold()
	hDummy:SetIdleAcquire( false )
	hDummy:SetAcquisitionRange( 0 )
end

function HeroDemo:OnTowersEnabledButtonPressed( eventSourceIndex )

end

function HeroDemo:SetTowersEnabled( bEnabled )
	
end

function HeroDemo:FindTowers()

end

function HeroDemo:OnSpawnCreepsButtonPressed( eventSourceIndex )

end

function HeroDemo:OnSpawnSingleCreepWaveButtonPressed( eventSourceIndex )

end

function HeroDemo:RemoveCreeps()

end

-- СПАВН РУНЫ
function HeroDemo:SpawnRuneInFrontOfUnit( hUnit, runeType )
	if hUnit == nil then
		return
	end

	local fDistance = 200.0
	local fMinSeparation = 50.0
	local fRingOffset = fMinSeparation + 20.0
	local vDir = hUnit:GetForwardVector()
	local vInitialTarget = hUnit:GetAbsOrigin() + vDir * fDistance
	vInitialTarget.z = GetGroundHeight( vInitialTarget, nil )
	local vTarget = vInitialTarget
	local nRemainingAttempts = 100
	local fAngle = 2 * math.pi
	local fOffset = 0.0
	local bDone = false

	local vecRunes = Entities:FindAllByClassname( "dota_item_rune" )
	while ( not bDone and nRemainingAttempts > 0 ) do
		bDone = true
		-- Too close to other runes?
		for i=1, #vecRunes do
			if ( vecRunes[i]:GetAbsOrigin() - vTarget ):Length() < fMinSeparation then
				bDone = false
				break
			end
		end
		if not GridNav:CanFindPath( hUnit:GetAbsOrigin(), vTarget ) then
			bDone = false
		end 
		if not bDone then
			fAngle = fAngle + 2 * math.pi / 8
			if fAngle >= 2 * math.pi then
				fOffset = fOffset + fRingOffset
				fAngle = 0
			end
			vTarget = vInitialTarget + fOffset * Vector( math.cos( fAngle ), math.sin( fAngle), 0.0 )
			vTarget.z = GetGroundHeight( vTarget, nil )
		end
		nRemainingAttempts = nRemainingAttempts - 1
	end

	CreateRune( vTarget, runeType )
end

function HeroDemo:OnSpawnRuneDoubleDamagePressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	self:SpawnRuneInFrontOfUnit( hPlayerHero, DOTA_RUNE_DOUBLEDAMAGE )
	EmitGlobalSound( "UI.Button.Pressed" )
end

function HeroDemo:OnSpawnRuneHastePressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	self:SpawnRuneInFrontOfUnit( hPlayerHero, DOTA_RUNE_HASTE )
	EmitGlobalSound( "UI.Button.Pressed" )
end

function HeroDemo:OnSpawnRuneIllusionPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	self:SpawnRuneInFrontOfUnit( hPlayerHero, DOTA_RUNE_ILLUSION )
	EmitGlobalSound( "UI.Button.Pressed" )
end

function HeroDemo:OnSpawnRuneInvisibilityPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	self:SpawnRuneInFrontOfUnit( hPlayerHero, DOTA_RUNE_INVISIBILITY )
	EmitGlobalSound( "UI.Button.Pressed" )
end

function HeroDemo:GetRuneSpawnLocation()

end

function HeroDemo:OnSpawnRuneRegenerationPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	self:SpawnRuneInFrontOfUnit( hPlayerHero, DOTA_RUNE_REGENERATION )
	EmitGlobalSound( "UI.Button.Pressed" )
end

function HeroDemo:OnSpawnRuneArcanePressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	if hPlayerHero == nil then return end
	self:SpawnRuneInFrontOfUnit( hPlayerHero, DOTA_RUNE_ARCANE )
end

function HeroDemo:OnChangeCosmeticsButtonPressed( eventSourceIndex )

end

function HeroDemo:OnChangeHeroButtonPressed( eventSourceIndex, data )

end

function HeroDemo:OnPauseButtonPressed( eventSourceIndex )

end

function HeroDemo:OnLeaveButtonPressed( eventSourceIndex )

end

function HeroDemo:BroadcastMsg( sMsg )
	-- Display a message about the button action that took place
	local buttonEventMessage = sMsg
	--print( buttonEventMessage )
	local centerMessage = {
		message = buttonEventMessage,
		duration = 1.0,
		clearQueue = true -- this doesn't seem to work
	}
	FireGameEvent( "show_center_message", centerMessage )
end
