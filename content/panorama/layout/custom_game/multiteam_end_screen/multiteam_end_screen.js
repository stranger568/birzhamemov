"use strict";

(function()
{
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_end_screen/multiteam_end_screen_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_end_screen/multiteam_end_screen_player.xml",
	};

	var endScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#TeamsContainer" ) );
	$.GetContextPanel().SetHasClass( "endgame", 1 );
	
	var teamInfoList = ScoreboardUpdater_GetSortedTeamInfoList( endScoreboardHandle );
	var delay = 0.2;
	var delay_per_panel = 1 / teamInfoList.length;
	for ( var teamInfo of teamInfoList )
	{
		var teamPanel = ScoreboardUpdater_GetTeamPanel( endScoreboardHandle, teamInfo.team_id );
		teamPanel.SetHasClass( "team_endgame", false );
		var callback = function( panel )
		{
			return function(){ panel.SetHasClass( "team_endgame", 1 ); }
		}( teamPanel );
		$.Schedule( delay, callback )
		delay += delay_per_panel;
	}
})();


(function()
{

	var playerInfo = Game.GetPlayerInfo( Players.GetLocalPlayer() );

	if ( playerInfo )
	{
		var playerPortrait = $("#HeroImage");
		var MedalHeroLevelImage = $("#MedalHeroLevelImage");
		var HeroLevel = $("#HeroLevel");
		var HeroProgressLabel = $("#HeroProgressLabel");
		var HeroProgressBGActive = $("#HeroProgressBGActive");

		if ( playerPortrait )
		{
			if ( playerInfo.player_selected_hero !== "" )
			{
				playerPortrait.style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + playerInfo.player_selected_hero + '.png")'
				playerPortrait.style.backgroundSize = "100%"
			}
			else
			{
				playerPortrait.style.backgroundImage = 'url("file://{images}/custom_game/unassigned' + '.png")'
				playerPortrait.style.backgroundSize = "100%"
			}
		}

		if (playerInfo.player_selected_hero != "npc_dota_hero_wisp")
		{
			var player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
		    if (player_info)
		    {
		        let hero_information = GetHeroInformation(player_info, playerInfo.player_selected_hero)
		        if (hero_information != "No")
		        {
			        HeroLevel.text = GetHeroLevel(hero_information.experience)
			        MedalHeroLevelImage.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero_information.experience)) + '.png")'
					MedalHeroLevelImage.style.backgroundSize = "100%"

					let exp_percent =  GetHeroExpProgress(hero_information.experience)
					let exp = GetHeroExp(hero_information.experience)

					if (GetHeroLevel(hero_information.experience) >= 30)
					{
						exp_percent = "100%"
						exp = 1000
					} 

	                HeroProgressBGActive.style['width'] = exp_percent;
	  
					if (GetHeroLevel(hero_information.experience) >= 5)
					{
						if (player_info.bp_days <= 0)
						{
							$("#HasBPToNextLevel").style.opacity = "1"
						}
					}

					HeroProgressLabel.text = exp
				}
		    }
		}
        
		$.Schedule( 2, function()
		{
	    	Levelup()
	    })
	} 
})();

var exp_level_up = 0
var exp_level_up_new = 0

function Levelup()
{
	var exp_table = CustomNetTables.GetTableValue('exp_table', String(Players.GetLocalPlayer()));
	if (exp_table)
	{
		exp_level_up = exp_table.exp
	}
    

	if (exp_level_up > 0)
	{
		$.Schedule( 0.5, function()
		{
	    	LevelUpExpVisual()
	    })
	}
}
  
function LevelUpExpVisual()
{
	exp_level_up = exp_level_up - 1
	exp_level_up_new = exp_level_up_new + 1

	var playerInfo = Game.GetPlayerInfo( Players.GetLocalPlayer() );

	if ( playerInfo )
	{
		var playerPortrait = $("#HeroImage");
		var MedalHeroLevelImage = $("#MedalHeroLevelImage");
		var HeroLevel = $("#HeroLevel");
		var HeroProgressLabel = $("#HeroProgressLabel");
		var HeroProgressBGActive = $("#HeroProgressBGActive");

		HeroProgressBGActive.SetHasClass("HeroProgressBGActive2", true)

		if (playerInfo.player_selected_hero != "npc_dota_hero_wisp")
		{
			var player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
		    if (player_info)
		    {
		        let hero_information = GetHeroInformation(player_info, playerInfo.player_selected_hero)
		        if (hero_information != "No")
		        {
			        HeroLevel.text = GetHeroLevel(Number(hero_information.experience)+exp_level_up_new)
			        MedalHeroLevelImage.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(Number(hero_information.experience)+exp_level_up_new)) + '.png")'
					MedalHeroLevelImage.style.backgroundSize = "100%"

					let exp_percent =  GetHeroExpProgress(Number(hero_information.experience)+exp_level_up_new)
					let exp = GetHeroExp(Number(hero_information.experience) + exp_level_up_new)

					if (GetHeroLevel(Number(hero_information.experience)+exp_level_up_new) >= 30)
					{
						exp_percent = "100%"
						exp = 1000
					} 

	                HeroProgressBGActive.style['width'] = exp_percent;
 
					if (GetHeroLevel(Number(hero_information.experience)+exp_level_up_new) >= 5)
					{
                        if (IsAllowForThis())
                        {
                            if (player_info.bp_days <= 0)
                            {
                                $("#HasBPToNextLevel").style.opacity = "1"
                            }
                        }
					}

					HeroProgressLabel.text = exp
				}
		    }
		}
	}  

	if (exp_level_up % 10 == 1)   
	{
		Game.EmitSound("General.CompendiumLevelUpMinor")
	}

	if (exp_level_up > 0)
	{
		$.Schedule( 0.01, function()
		{
	    	LevelUpExpVisual()
	    })
	} else {
		Game.EmitSound("General.CompendiumLevelUp")
        if (Math.random() < 0.5) 
        {
            $.DispatchEvent('BrowserGoToURL', "https://bmemov.strangerdev.ru/ads.php");
        }
	}
}