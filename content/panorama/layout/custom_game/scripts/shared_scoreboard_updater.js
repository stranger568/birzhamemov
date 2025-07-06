"use strict";

function _ScoreboardUpdater_UpdatePlayerPanel( scoreboardConfig, playersContainer, playerId, localPlayerTeamId )
{
	let playerPanelName = "_dynamic_player_" + playerId;
	let playerPanel = playersContainer.FindChild( playerPanelName );
	if ( playerPanel === null )
	{
		playerPanel = $.CreatePanel( "Panel", playersContainer, playerPanelName );
		playerPanel.SetAttributeInt( "player_id", playerId );
		playerPanel.BLoadLayout( scoreboardConfig.playerXmlName, false, false );
		let start_info = CustomNetTables.GetTableValue('birzhainfo', String(playerId));
		if (start_info)
		{
			UpdateBorderPlayer("birzhainfo", String(playerId), start_info)
		}
	}

    playerPanel.SetHasClass( "is_local_player", ( playerId == Game.GetLocalPlayerID() ) );

	let playerInfo = Game.GetPlayerInfo( playerId );
	if ( playerInfo )
	{
        let PartyIcon_team = playerPanel.FindChildInLayoutFile("PartyIcon_team");
		if (PartyIcon_team)
		{
			HighlightByParty(playerId, PartyIcon_team);
		}
        let playername = playerPanel.FindChildInLayoutFile( "tophud_player_name" );
		if ( playername )
		{
			playername.text = Players.GetPlayerName(playerId) || 'noname';
		}
        let heroNameAndDescription = playerPanel.FindChildInLayoutFile( "HeroNameAndDescription" );
		if ( heroNameAndDescription )
		{
            heroNameAndDescription.SetDialogVariable( "hero_name", $.Localize( "#"+playerInfo.player_selected_hero ) );
			heroNameAndDescription.SetDialogVariableInt( "hero_level",  playerInfo.player_level );
		}
        let playerAvatar = playerPanel.FindChildInLayoutFile( "AvatarImage" );
		if ( playerAvatar )
		{
			playerAvatar.steamid = playerInfo.player_steamid;
		}
		
		playerPanel.SetHasClass( "player_dead", ( playerInfo.player_respawn_seconds >= 0 ) );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "RespawnTimer", ( playerInfo.player_respawn_seconds + 1 ) );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "PlayerName", playerInfo.player_name );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Level", playerInfo.player_level );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Kills", playerInfo.player_kills );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Deaths", playerInfo.player_deaths );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Assists", playerInfo.player_assists );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "HeroName", $.Localize( "#"+playerInfo.player_selected_hero ) )
		playerPanel.SetHasClass( "player_connection_abandoned", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED );
		playerPanel.SetHasClass( "player_connection_failed", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED );
		playerPanel.SetHasClass( "player_connection_disconnected", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED );
        AddHeroLevelRank(playerId, playerInfo.player_selected_hero, playerPanel)

        let info = CustomNetTables.GetTableValue('birzhainfo', String(playerId));
		if (info)
		{
			_ScoreboardUpdater_SetTextSafe( playerPanel, "Mmr", (info.mmr[GetCurrentSeasonNumber()] || 0) );
            _ScoreboardUpdater_SetTextSafe( playerPanel, "Rating", (info.mmr[GetCurrentSeasonNumber()] || 0) );
			let mmr_label = GetMmrLabel(playerPanel);
			if (mmr_label)
			{
				mmr_label.text =  'MMR: ' + (info.mmr[GetCurrentSeasonNumber()] || 0);
			}
			let bonus_mmr = CustomNetTables.GetTableValue('bonus_rating', String(playerId));
			if (bonus_mmr)
			{
				if (bonus_mmr.mmr && bonus_mmr.mmr < 0) 
                {
					_ScoreboardUpdater_SetTextSafe( playerPanel, "MmrPlus", "- " + (bonus_mmr.mmr*-1) );
					let mmrpluspanel = playerPanel.FindChildInLayoutFile( "MmrPlus" )
					if ( mmrpluspanel ) 
                    {
						mmrpluspanel.style.color = "gradient( linear, 90% 80%, 30% 20%, from( #fc0000 ), to( #ff9898 ) )"
					}
				} 
                else 
                {
					_ScoreboardUpdater_SetTextSafe( playerPanel, "MmrPlus", "+ " + bonus_mmr.mmr );
				}
			}
            let bonus_dogecoin = CustomNetTables.GetTableValue('bonus_dogecoin', String(playerId));
			if (bonus_dogecoin)
			{
				_ScoreboardUpdater_SetTextSafe( playerPanel, "DogePlus", bonus_dogecoin.coin );
			}
			let rat_clib = " "
			let calibrating_check = String(info.games_calibrating[GetCurrentSeasonNumber()])
			if (calibrating_check == "undefined")
			{
				rat_clib = "<font color='gold'>" + "(" + 10 + ")" + "</font>"
			} 
            else if (calibrating_check == "0")
			{
				rat_clib = " "
			} 
            else 
            {
				rat_clib = "<font color='gold'>" + "(" + calibrating_check + ")" + "</font>"
			}
			_ScoreboardUpdater_SetTextSafe( playerPanel, "PlayerMmr", (info.mmr[GetCurrentSeasonNumber()] || 2500) + rat_clib);
		}

		let playerColorBar = playerPanel.FindChildInLayoutFile( "PlayerColorBar" );
		if ( playerColorBar !== null )
		{
			if ( GameUI.CustomUIConfig().team_colors )
			{
				let teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo.player_team_id ];
				if ( teamColor )
				{
					playerColorBar.style.backgroundColor = teamColor;
				}
			}
			else
			{
				let playerColor = "#000000";
				playerColorBar.style.backgroundColor = playerColor;
			}
		}

        let playerPortrait = playerPanel.FindChildInLayoutFile( "HeroIcon" );
		if ( playerPortrait )
		{
			if ( playerInfo.player_selected_hero !== "" )
			{
				let no_portrait = true
				if (playerInfo.player_selected_hero == "npc_dota_hero_pyramide")
				{
					if (player_has_item(playerId, 181))
					{
						playerPortrait.SetImage( "file://{images}/custom_game/hight_hood/heroes/" + playerInfo.player_selected_hero + "_new.png" );
						no_portrait = false
					}
				}
				if (playerInfo.player_selected_hero == "npc_dota_hero_oracle")
				{ 
					if (player_has_item(playerId, 182))
					{
						playerPortrait.SetImage( "file://{images}/custom_game/hight_hood/heroes/" + playerInfo.player_selected_hero + "_new.png" );
						no_portrait = false
					}
				}
				if (playerInfo.player_selected_hero == "npc_dota_hero_faceless_void")
				{
					if (player_has_item(playerId, 180))
					{
						playerPortrait.SetImage( "file://{images}/custom_game/hight_hood/heroes/" + playerInfo.player_selected_hero + "_new.png" );
						no_portrait = false
					}
				}
				if (playerInfo.player_selected_hero == "npc_dota_hero_sonic")
				{
					if (player_has_item(playerId, 183))
					{
						playerPortrait.SetImage( "file://{images}/custom_game/hight_hood/heroes/" + playerInfo.player_selected_hero + "_new.png" );
						no_portrait = false
					}
				}
				if (no_portrait)
				{
					playerPortrait.SetImage( "file://{images}/custom_game/hight_hood/heroes/" + playerInfo.player_selected_hero + ".png" );
				} 
			}
			else
			{
				playerPortrait.SetImage( "file://{images}/custom_game/unassigned.png" );
			}
		}
	}

	var tip_cooldown_label = CustomNetTables.GetTableValue("tip_cooldown", Players.GetLocalPlayer());
	if (tip_cooldown_label)
	{
        let TipButtonCustom = playerPanel.FindChildInLayoutFile("TipButtonCustom");
        let TipText = playerPanel.FindChildInLayoutFile("TipText");
		if (GameUI.IsAltDown() && (playerId != Game.GetLocalPlayerID()) ) 
        {
			if (!playerPanel.BHasClass("player_connection_abandoned") && !playerPanel.BHasClass("player_connection_failed") && !playerPanel.BHasClass("player_connection_disconnected"))
			{
				playerPanel.SetHasClass( "alt_health_check", true );
			} 
            else 
            {
				playerPanel.SetHasClass( "alt_health_check", false );
			}
		} 
        else 
        {
			playerPanel.SetHasClass( "alt_health_check", false );
		}  
		if (tip_cooldown_label.cooldown > 0)
		{
            if (TipButtonCustom)
            {
                SetPSelectEvent(TipButtonCustom, true, playerId)
                TipButtonCustom.style.saturation = "0"
            }
			let time = tip_cooldown_label.cooldown
			let min = Math.trunc((time)/60) 
			let sec_n =  (time) - 60*Math.trunc((time)/60) 
			min = String(min - 60*( Math.trunc(min/60) ))
			let sec = String(sec_n)
			if (sec_n < 10) 
			{
				sec = '0' + sec
			} 
            if (TipText)
            {
                TipText.text = min + ':' + sec
            }
		} 
        else 
        {
            if (TipButtonCustom)
            {
                SetPSelectEvent(TipButtonCustom, false, playerId)
                TipButtonCustom.style.saturation = "1"
            }
            if (TipText)
            {
                TipText.text = $.Localize("#tip_player")
            }
		}
	}
		
	var playerItemsContainer = playerPanel.FindChildInLayoutFile( "PlayerItemsContainer" );
    if ( playerItemsContainer )
    {
        var item_table = CustomNetTables.GetTableValue('end_game_items', String(playerId));
        if ( item_table )
        {
            for ( var i = 0; i < 6; ++i )
            {
                var itemPanelName = "_dynamic_item_" + i;
                var itemPanel = playerItemsContainer.FindChild( itemPanelName );
                if ( itemPanel === null )
                {
                    itemPanel = $.CreatePanel( "DOTAItemImage", playerItemsContainer, itemPanelName );
                    itemPanel.AddClass( "PlayerItem" );
                }
                itemPanel.itemname = item_table[i];
            }
        }
    }
}

function _ScoreboardUpdater_SetTextSafe( panel, childName, textValue )
{
	if ( panel === null )
		return;
	var childPanel = panel.FindChildInLayoutFile( childName )
	if ( childPanel === null )
		return;
	
	childPanel.text = textValue;
}
 
function HighlightByParty(player_id, party_icon) 
{
    if (party_icon)
    {
	    var party_map = CustomNetTables.GetTableValue("game_state", "party_map")
	    if (party_map != undefined)
	    {
		    var party_id = party_map[player_id];
			if (party_id != undefined && parseInt(party_id)>0 && parseInt(party_id) <= 10) 
			{
				party_icon.SetHasClass("NoParty",false)
				party_icon.SetHasClass("Party_" + party_id, true);
				party_icon.style.visibility = "visible"
			} 
            else 
            {
				party_icon.SetHasClass("NoParty", true);
				party_icon.style.visibility = "collapse"
			}
		} 
        else 
        {
			party_icon.SetHasClass("NoParty", true);
			party_icon.style.visibility = "collapse"
		}
	}
}

CustomNetTables.SubscribeNetTableListener( "birzhainfo", UpdateBorderPlayer );

function UpdateBorderPlayer(table, key, data ) 
{
	if (table == "birzhainfo") 
	{
        var playerPanelName = "_dynamic_player_" + key;
        if (playerPanelName) 
        {
            var playerPanel = $.GetContextPanel().FindChildTraverse(playerPanelName)
            if (playerPanel) 
            {
                var border_bp = playerPanel.FindChildInLayoutFile( "border_bp" );
                var gold_particle = playerPanel.FindChildInLayoutFile( "gold_particle" );
                if (border_bp) 
                {
                    border_bp.DeleteAsync(0)
                }
                if (gold_particle) 
                {
                    gold_particle.DeleteAsync(0)
                }
                if (data.border_id == 112) 
                {
                    AddDonateStatus(playerPanel);
                } 
                else if (data.border_id == 115) 
                {
                    AddBorderSnow(playerPanel);
                } 
                else if (data.border_id == 116) 
                {
                    AddBorderBlackHole(playerPanel);
                } 
                else if (data.border_id == 117) 
                {
                    AddBorderRubickGreen(playerPanel);
                } 
                else if (data.border_id == 127) 
                {
                    AddBorderGachi(playerPanel);
                } 
                else if (data.border_id == 128) 
                {
                    AddBorderRoflan(playerPanel);
                } 
                else if (data.border_id == 129) 
                {
                    AddBorderElectric(playerPanel);
                } 
                else if (data.border_id == 164) 
                {
                    AddBorderAnimationSnake(playerPanel)
                } 
                else if (data.border_id == 404) 
                {
                    AddBorderDiretide(playerPanel)
                }
            }
        }
	}
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdateTeamPanel( scoreboardConfig, containerPanel, teamDetails, teamsInfo )
{
	if ( !containerPanel )
		return;

	var teamId = teamDetails.team_id;
//	$.Msg( "_ScoreboardUpdater_UpdateTeamPanel: ", teamId );

	var teamPanelName = "_dynamic_team_" + teamId;
	var teamPanel = containerPanel.FindChild( teamPanelName );
	if ( teamPanel === null )
	{
//		$.Msg( "UpdateTeamPanel.Create: ", teamPanelName, " = ", scoreboardConfig.teamXmlName );
		teamPanel = $.CreatePanel( "Panel", containerPanel, teamPanelName );
		teamPanel.SetAttributeInt( "team_id", teamId );
		teamPanel.BLoadLayout( scoreboardConfig.teamXmlName, false, false );

		var logo_xml = GameUI.CustomUIConfig().team_logo_xml;
		if ( logo_xml )
		{
			var teamLogoPanel = teamPanel.FindChildInLayoutFile( "TeamLogo" );
			if ( teamLogoPanel )
			{
				teamLogoPanel.SetAttributeInt( "team_id", teamId );
				teamLogoPanel.BLoadLayout( logo_xml, false, false );
			}
		}
	}
	
	var localPlayerTeamId = -1;
	var localPlayer = Game.GetLocalPlayerInfo();
	if ( localPlayer )
	{
		localPlayerTeamId = localPlayer.player_team_id;
	}
	teamPanel.SetHasClass( "local_player_team", localPlayerTeamId == teamId );
	teamPanel.SetHasClass( "not_local_player_team", localPlayerTeamId != teamId );

	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
	var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	if ( playersContainer )
	{
		for ( var playerId of teamPlayers )
		{
			_ScoreboardUpdater_UpdatePlayerPanel( scoreboardConfig, playersContainer, playerId, localPlayerTeamId )
		}
	}
	
	teamPanel.SetHasClass( "no_players", (teamPlayers.length == 0) )
	teamPanel.SetHasClass( "one_player", (teamPlayers.length == 1) )
	
	if ( teamsInfo.max_team_players < teamPlayers.length )
	{
		teamsInfo.max_team_players = teamPlayers.length;
	}

	var game_start = CustomNetTables.GetTableValue('game_state', "pickstate");
	if (game_start)
	{
		if (game_start.v == "ended")
		{
			let table_score_team = CustomNetTables.GetTableValue("game_state", String(teamId))
			if (table_score_team) 
            {
				_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamScore", table_score_team.kills )
                let teamscorewithimage = teamPanel.FindChildTraverse("TeamScoreWithImage")
                if (teamscorewithimage)
                {
                    teamscorewithimage.style.opacity = "1"
                }
			}
		} else {
			_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamScore", " " )
            let teamscorewithimage = teamPanel.FindChildTraverse("TeamScoreWithImage")
            if (teamscorewithimage)
            {
                teamscorewithimage.style.opacity = "0"
            }
		}
	} else {
		_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamScore", " " )
        let teamscorewithimage = teamPanel.FindChildTraverse("TeamScoreWithImage")
        if (teamscorewithimage)
        {
            teamscorewithimage.style.opacity = "0"
        }
	}

	_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamName", $.Localize( "#" + teamDetails.team_name ) )
	
	if ( GameUI.CustomUIConfig().team_colors )
	{
		var teamColor = GameUI.CustomUIConfig().team_colors[ teamId ];
		var teamColorPanel = teamPanel.FindChildInLayoutFile( "TeamColor" );
		
		teamColor = teamColor.replace( ";", "" );

		if ( teamColorPanel )
		{
			teamNamePanel.style.backgroundColor = teamColor + ";";
		}
		
		var teamColor_GradentFromTransparentLeft = teamPanel.FindChildInLayoutFile( "TeamColor_GradentFromTransparentLeft" );
		if ( teamColor_GradentFromTransparentLeft )
		{
			teamColor_GradentFromTransparentLeft.style.backgroundColor = teamColor;
		} 
	}
	
	return teamPanel;
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_ReorderTeam( scoreboardConfig, teamsParent, teamPanel, teamId, newPlace, prevPanel )
{
//	$.Msg( "UPDATE: ", GameUI.CustomUIConfig().teamsPrevPlace );
	var oldPlace = null;
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length > teamId )
	{
		oldPlace = GameUI.CustomUIConfig().teamsPrevPlace[ teamId ];
	}
	GameUI.CustomUIConfig().teamsPrevPlace[ teamId ] = newPlace;
	
	if ( newPlace != oldPlace )
	{
//		$.Msg( "Team ", teamId, " : ", oldPlace, " --> ", newPlace );
		teamPanel.RemoveClass( "team_getting_worse" );
		teamPanel.RemoveClass( "team_getting_better" );
		if ( newPlace > oldPlace )
		{
			teamPanel.AddClass( "team_getting_worse" );
		}
		else if ( newPlace < oldPlace )
		{
			teamPanel.AddClass( "team_getting_better" );
		}
	}

	teamsParent.MoveChildAfter( teamPanel, prevPanel );
}

// sort / reorder as necessary
function compareFunc( a, b ) // GameUI.CustomUIConfig().sort_teams_compare_func;
{

	let table_score_team_a = CustomNetTables.GetTableValue("game_state", String(a.team_id))
	let table_score_team_b = CustomNetTables.GetTableValue("game_state", String(b.team_id))

	if (table_score_team_a && table_score_team_b) {
		if ( table_score_team_a.kills < table_score_team_b.kills )
		{
			return 1; // [ B, A ]
		}
		else if ( table_score_team_a.kills > table_score_team_b.kills )
		{
			return -1; // [ A, B ]
		}
		else
		{
			return 0;
		}
	}
};

function stableCompareFunc( a, b )
{
	var unstableCompare = compareFunc( a, b );
	if ( unstableCompare != 0 )
	{
		return unstableCompare;
	}
	
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length <= a.team_id )
	{
		return 0;
	}
	
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length <= b.team_id )
	{
		return 0;
	}
	
//			$.Msg( GameUI.CustomUIConfig().teamsPrevPlace );

	var a_prev = GameUI.CustomUIConfig().teamsPrevPlace[ a.team_id ];
	var b_prev = GameUI.CustomUIConfig().teamsPrevPlace[ b.team_id ];
	if ( a_prev < b_prev ) // [ A, B ]
	{
		return -1; // [ A, B ]
	}
	else if ( a_prev > b_prev ) // [ B, A ]
	{
		return 1; // [ B, A ]
	}
	else
	{
		return 0;
	}
};

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdateAllTeamsAndPlayers( scoreboardConfig, teamsContainer )
{
	var teamsList = [];
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		teamsList.push( Game.GetTeamDetails( teamId ) );
	}

	// update/create team panels
	var teamsInfo = { max_team_players: 0 };
	var panelsByTeam = [];
	for ( var i = 0; i < teamsList.length; ++i )
	{
		var teamPanel = _ScoreboardUpdater_UpdateTeamPanel( scoreboardConfig, teamsContainer, teamsList[i], teamsInfo );
		if ( teamPanel )
		{
			panelsByTeam[ teamsList[i].team_id ] = teamPanel;
		}
	}

	if ( teamsList.length > 1 )
	{
		if ( scoreboardConfig.shouldSort )
		{
			teamsList.sort( stableCompareFunc );
		}
		var prevPanel = panelsByTeam[ teamsList[0].team_id ];
		for ( var i = 0; i < teamsList.length; ++i )
		{
			var teamId = teamsList[i].team_id;
			var teamPanel = panelsByTeam[ teamId ];
			_ScoreboardUpdater_ReorderTeam( scoreboardConfig, teamsContainer, teamPanel, teamId, i, prevPanel );
			prevPanel = teamPanel;
		}
	}
}


//=============================================================================
//=============================================================================
function ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, scoreboardPanel )
{
	GameUI.CustomUIConfig().teamsPrevPlace = [];
	if ( typeof(scoreboardConfig.shouldSort) === 'undefined')
	{
		scoreboardConfig.shouldSort = true;
	}
	_ScoreboardUpdater_UpdateAllTeamsAndPlayers( scoreboardConfig, scoreboardPanel );
	return { "scoreboardConfig": scoreboardConfig, "scoreboardPanel":scoreboardPanel }
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_SetScoreboardActive( scoreboardHandle, isActive )
{
	if ( scoreboardHandle.scoreboardConfig === null || scoreboardHandle.scoreboardPanel === null )
	{
		return;
	}
	
	if ( isActive )
	{
		_ScoreboardUpdater_UpdateAllTeamsAndPlayers( scoreboardHandle.scoreboardConfig, scoreboardHandle.scoreboardPanel );
	}
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_GetTeamPanel( scoreboardHandle, teamId )
{
	if ( scoreboardHandle.scoreboardPanel === null )
	{
		return;
	}
	
	var teamPanelName = "_dynamic_team_" + teamId;
	return scoreboardHandle.scoreboardPanel.FindChild( teamPanelName );
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_GetSortedTeamInfoList( scoreboardHandle )
{
	var teamsList = [];
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		teamsList.push( Game.GetTeamDetails( teamId ) );
	}

	if ( teamsList.length > 1 )
	{
		teamsList.sort( stableCompareFunc );		
	}
	
	return teamsList;
}

function GetMmrLabel(panel)
{
	var mmr_panel = panel.FindChildInLayoutFile('tophud_player_mmrpanel');
	if (mmr_panel)
	{
		return mmr_panel.FindChild('mmr_label')
	}	
}

function AddDonateStatus(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');

		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		border_bp.AddClass('border_bp');
		$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", map: "heroes", particleonly:"false", camera:"bp_effect" });
	}
}


function AddBorderSnow(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		border_bp.AddClass('border_snow');
		$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", map: "heroes", particleonly:"false", camera:"snow_effect" });
	}
}

function AddBorderBlackHole(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		$.CreatePanel("DOTAParticleScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", particleName: "particles/units/heroes/hero_enigma/enigma_blackhole_l.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"150 150 150", lookAt:"0 0 0",  fov:"50", squarePixels:"false" });
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		border_bp.AddClass('border_blackhole');
	}
}

function AddBorderAnimationSnake(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		$.CreatePanel("DOTAParticleScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", particleName: "particles/donate/gold_icon_bp_3.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"55", squarePixels:"true" });
	}
} 


function AddBorderRubickGreen(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", map: "maps/scenes/hud/rubickarcanagreen.vmap", particleonly:"false", camera:"camera_1" });
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		border_bp.AddClass('border_rubick');
	}
}

function AddBorderGachi(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		//$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:100%;height:100%;align:center center;", renderdeferred: "true", deferredalpha: "true", antialias: "true", hittest: "false", particleonly: "true", map: "heroes", particleonly:"true", camera:"gachi_effect" });
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		$.CreatePanel("DOTAParticleScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", particleName: "particles/borders/border_effect_4.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"37", squarePixels:"true" });
	}
}

function AddBorderRoflan(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		//$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:100%;height:100%;align:center center;", map: "heroes", particleonly:"true", camera:"roflan_effect" });
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		$.CreatePanel("DOTAParticleScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", particleName: "particles/borders/border_effect_5.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"35", squarePixels:"true" });
	}
}

function AddBorderElectric(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		border_bp.AddClass('border_electric');
		//$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:100%;height:100%;align:center center;", map: "heroes", particleonly:"true", camera:"electric_effect" });
		$.CreatePanel("DOTAParticleScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", particleName: "particles/electric_border.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"45", squarePixels:"true" });
	}
}

function AddBorderDiretide(panel)
{	
	var playerPortrait = panel.FindChildInLayoutFile( "TopHero" );
	if (playerPortrait)
	{
		var HeroPortrait = playerPortrait.FindChild('HeroIcon');
		//$.CreatePanel("DOTAScenePanel", HeroPortrait, "gold_particle", { style: "width:100%;height:100%;align:center center;", map: "heroes", particleonly:"true", camera:"roflan_effect" });
		var border_bp = $.CreatePanel('Panel', HeroPortrait, 'border_bp');
		$.CreatePanel("DOTAParticleScenePanel", HeroPortrait, "gold_particle", { style: "width:150px;height:200px;", particleName: "particles/donate/diretide_border.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"57", squarePixels:"true" });
	}
}

function AddHeroLevelRank(id, hero, panel)
{
	if (hero != "npc_dota_hero_wisp")
	{
		var player_info = CustomNetTables.GetTableValue('birzhainfo', String(id));
	    if (player_info)
	    {
	        let hero_information = GetHeroInformation(player_info, hero)
	        let has_rank = panel.FindChildTraverse("PlayerRank")
	        if (has_rank)
	        {
				has_rank.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero_information.experience), player_info.bp_days) + '.png")'
				has_rank.style.backgroundSize = "100%"
				has_rank.style.opacity = "1"
	        }
	    }
	}
}

var PANORAMA_TIP_COOLDOWN = false

function SetPSelectEvent(panel, cooldown, player_id_tip)
{
	if (panel)
	{
		if ( cooldown ) 
        { 
			panel.SetPanelEvent("onactivate", function() {})
	    	return
		}
	    panel.SetPanelEvent("onactivate", function() 
        { 
            if (PANORAMA_TIP_COOLDOWN)
            {
                return
            }
            PANORAMA_TIP_COOLDOWN = true
            $.Schedule( 1, function()
            {
	        	PANORAMA_TIP_COOLDOWN = false
	        })
	        GameEvents.SendCustomGameEventToServer("PlayerTip", {player_id_tip : player_id_tip});
	        panel.SetPanelEvent("onactivate", function() {})
	    })
	}
}

function player_has_item(id, item_id)
{
	var player_table = CustomNetTables.GetTableValue("birzhashop", String(id))
	if (player_table)
	{
		let player_table_js = []

		for (var d = 1; d < 300; d++) 
		{
			player_table_js.push(player_table.player_items[d])
		}

		for ( var item of player_table_js )
	    {
	    	if (item == String(item_id))
	    	{
	    		return true
	    	}
	    }
	}
	return false
}

function GetCurrentSeasonNumber()
{
	let table = CustomNetTables.GetTableValue("game_state", "birzha_gameinfo")
	if (table)
	{
		if (table.season)
		{
			return Number(table.season)
		}
	}
}