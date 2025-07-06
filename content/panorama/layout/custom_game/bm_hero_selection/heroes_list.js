"use strict";

function OnUpdateHeroSelection()
{
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		UpdateTeam( teamId );
	}
}

function UpdateTeam( teamId )
{
    let PlayersList = $("#PlayersList")
	let teamPanelName = "team_" + teamId;
	let teamPanel = PlayersList.FindChildTraverse(teamPanelName)
    if (teamPanel == null)
    {
        teamPanel = $.CreatePanel( "Panel", PlayersList, teamPanelName );
        teamPanel.AddClass( "TeamPanel" );

        let team_color = $.CreatePanel( "Panel", teamPanel, "" );
        team_color.AddClass("team_color")
        team_color.style.backgroundColor = GameUI.CustomUIConfig().team_colors[teamId];

        let team_players = $.CreatePanel( "Panel", teamPanel, "team_players" );
        team_players.AddClass("team_players")
    }
	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
	for ( var playerId of teamPlayers )
	{
		UpdatePlayer( teamPanel, playerId );
	}
}

function UpdatePlayer( teamPanel, playerId )
{
    var playerInfo = Game.GetPlayerInfo( playerId );
	if ( !playerInfo )
		return;

	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if ( !localPlayerInfo )
		return;

	let team_players = teamPanel.FindChildTraverse( "team_players" );
	let playerPanelName = "player_" + playerId;
    var playerPanel = team_players.FindChildTraverse( playerPanelName );
	if ( playerPanel === null )
	{
        playerPanel = $.CreatePanel( "Panel", team_players, playerPanelName );
        playerPanel.AddClass( "PlayerPanel" );

        let player_hero_image = $.CreatePanel( "Panel", playerPanel, "player_hero_image" );
        player_hero_image.AddClass( "player_hero_image" );

        let player_account_name = $.CreatePanel( "Label", playerPanel, "player_account_name" );
        player_account_name.AddClass( "player_account_name" );
        player_account_name.text = Players.GetPlayerName(playerId) || 'noname';
	}

    let player_hero_image = playerPanel.FindChildTraverse( "player_hero_image" );
    if ( playerInfo.player_selected_hero !== "" )
    {
        player_hero_image.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + playerInfo.player_selected_hero + '.png")';
        player_hero_image.style.backgroundSize = '100%';
    }
    else
    {
        player_hero_image.style.backgroundImage = 'url("file://{images}/custom_game/unassigned.png")';
        player_hero_image.style.backgroundSize = '150% 100%';
        player_hero_image.style.backgroundPosition = '50% 50%';
    }

    let player_account_name = playerPanel.FindChildTraverse( "player_account_name" );
    if (player_account_name)
    {
        player_account_name.text = Players.GetPlayerName(playerId) || 'noname';
    }
}

function intToARGB(i) 
{ 
    return ('00' + ( i & 0xFF).toString( 16 ) ).substr( -2 ) + ('00' + ( ( i >> 8 ) & 0xFF ).toString( 16 ) ).substr( -2 ) + ('00' + ( ( i >> 16 ) & 0xFF ).toString( 16 ) ).substr( -2 ) + ('00' + ( ( i >> 24 ) & 0xFF ).toString( 16 ) ).substr( -2 );
}

(function()
{
	OnUpdateHeroSelection();
	GameEvents.Subscribe( "dota_player_hero_selection_dirty", OnUpdateHeroSelection );
	GameEvents.Subscribe( "dota_player_update_hero_selection", OnUpdateHeroSelection );
})();

