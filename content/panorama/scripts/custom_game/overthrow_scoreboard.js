"use strict";

var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements");
if ($.GetContextPanel() && parentHUDElements)
{
	$.GetContextPanel().SetParent(parentHUDElements);
}
 
var toggle = false

function UpdateTimer( data )
{
	//$.Msg( "UpdateTimer: ", data );
	//var timerValue = Game.GetDOTATime( false, false );

	//var sec = Math.floor( timerValue % 60 );
	//var min = Math.floor( timerValue / 60 );

	//var timerText = "";
	//timerText += min;
	//timerText += ":";

	//if ( sec < 10 )
	//{
	//	timerText += "0";
	//}
	//timerText += sec;

	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	if ($("#Timer"))
	{
		$( "#Timer" ).text = timerText;
	}

	//$.Schedule( 0.1, UpdateTimer );
}

function RefreshFountainTimer(data)
{
	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	if ($("#EndTimer"))
	{
		$( "#EndTimer" ).text = timerText;
	}
}






function ToggleInfo()
{
	if (toggle === false) {
		$.GetContextPanel().FindChildTraverse("AllVictoryPanel").style.transform = "translateX( 1000px )"
		$.GetContextPanel().FindChildTraverse("ContractPanel").style.transform = "translateX( 1000px )"
		$.GetContextPanel().FindChildTraverse("InfoText").text = $.Localize("#OpenGameInfo")
		toggle = true
	} else {
		$.GetContextPanel().FindChildTraverse("AllVictoryPanel").style.transform = "translateX( 0px )"
		$.GetContextPanel().FindChildTraverse("ContractPanel").style.transform = "translateX( 0px )"
		$.GetContextPanel().FindChildTraverse("InfoText").text = $.Localize("#CloseGameInfo")
		toggle = false
	}
}

function FountainUpdateTimer( data )
{
	//$.Msg( "UpdateTimer: ", data );
	//var timerValue = Game.GetDOTATime( false, false );

	//var sec = Math.floor( timerValue % 60 );
	//var min = Math.floor( timerValue / 60 );

	//var timerText = "";
	//timerText += min;
	//timerText += ":";

	//if ( sec < 10 )
	//{
	//	timerText += "0";
	//}
	//timerText += sec;

	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	if ($("#FountainTimer"))
	{
		$( "#FountainTimer" ).text = timerText;
	}

	//$.Schedule( 0.1, UpdateTimer );
}


function ContractTime( data )
{
	//$.Msg( "UpdateTimer: ", data );
	//var timerValue = Game.GetDOTATime( false, false );

	//var sec = Math.floor( timerValue % 60 );
	//var min = Math.floor( timerValue / 60 );

	//var timerText = "";
	//timerText += min;
	//timerText += ":";

	//if ( sec < 10 )
	//{
	//	timerText += "0";
	//}
	//timerText += sec;

	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	if ($("#ContractTimer"))
	{
		$( "#ContractTimer" ).text = timerText;
	}

	//$.Schedule( 0.1, UpdateTimer );
}


function gametimer( data )
{
	//$.Msg( "UpdateTimer: ", data );
	//var timerValue = Game.GetDOTATime( false, false );

	//var sec = Math.floor( timerValue % 60 );
	//var min = Math.floor( timerValue / 60 );

	//var timerText = "";
	//timerText += min;
	//timerText += ":";

	//if ( sec < 10 )
	//{
	//	timerText += "0";
	//}
	//timerText += sec;

	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	if ($("#GameTimer"))
	{
		$( "#GameTimer" ).text = timerText;
	}

	if ($( "#TimerGame" )) {
		if (Game.IsDayTime()) {
			$( "#TimerGame" ).style.backgroundImage = "url('s2r://panorama/images/hud/reborn/icon_sun_psd.vtex');"
		} else {
			$( "#TimerGame" ).style.backgroundImage = "url('s2r://panorama/images/hud/reborn/icon_moon_psd.vtex');"
		}
	}

	//$.Schedule( 0.1, UpdateTimer );
}

function SetShowText(panel, text)
{
	if (panel)
	{
		panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
        
	    panel.SetPanelEvent('onmouseout', function() {
	        $.DispatchEvent('DOTAHideTextTooltip', panel);
	    }); 
	}      
}

function ShowTimer( data )
{
	if ($("#Timer"))
	{
		$( "#Timer" ).AddClass( "timer_visible" );
	}
}

function AlertTimer( data )
{
	if ($("#Timer"))
	{
		$( "#Timer" ).AddClass( "timer_alert" );
	}
}

function HideTimer( data )
{
	if ($("#Timer"))
	{
		$( "#Timer" ).AddClass( "timer_hidden" );

	}
}

function UpdateKillsToWin()
{
	var victory_condition = CustomNetTables.GetTableValue( "game_state", "scores_to_win" );
	if (( victory_condition ) && (victory_condition.kills) && $("#VictoryPoints"))
	{
		$("#VictoryPoints").text = victory_condition.kills;
	}
}

function OnGameStateChanged( table, key, data )
{
	UpdateKillsToWin();
}


function AddHeroInPanel(data)
{
	if ($("#HeroIcons"))
	{
		var Hero = $.CreatePanel("Panel", $("#HeroIcons"), "hero_name_" + data.hero);
		Hero.AddClass("Hero");

		var HeroImage = $.CreatePanel("Panel", Hero, "HeroImage");
		HeroImage.AddClass("HeroIcon");
		HeroImage.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + data.hero + '.png")'

		var HeroName = $.CreatePanel("Label", Hero, "HeroName");
		HeroName.AddClass("HeroName");
		HeroName.text = $.Localize("#" + data.hero)
	}	
}

function RemoveHeroPanel(data)
{
	if ($("#HeroIcons"))
	{
		$("#HeroIcons").FindChildTraverse("hero_name_" + data.hero).DeleteAsync(0.1)
	}	
}

(function()
{
	GameEvents.Subscribe( 'contract_hero_add', AddHeroInPanel );
	GameEvents.Subscribe( 'contract_hero_delete', RemoveHeroPanel );
	SetShowText($( "#BirzhaScore" ), $.Localize("#gamekills"))
	SetShowText($( "#BirzhaRewardTime" ), $.Localize("#gametime"))
	SetShowText($( "#BirzhaGameTime" ), $.Localize("#gametimename"))
	SetShowText($( "#BirzhaFountainTime" ), $.Localize("#fountaintime"))
	SetShowText($( "#BirzhaEnd" ), $.Localize("#endtimertext"))
	SetShowText($( "#BirzhaContractTime" ), $.Localize("#contracttext"))
	UpdateKillsToWin();
	CustomNetTables.SubscribeNetTableListener( "game_state", OnGameStateChanged );
    GameEvents.Subscribe( "countdown", UpdateTimer );
    GameEvents.Subscribe( "endgametimer", RefreshFountainTimer );
	GameEvents.Subscribe( "fountain", FountainUpdateTimer );
	GameEvents.Subscribe( "gametimer", gametimer );
    GameEvents.Subscribe( "show_timer", ShowTimer );
    GameEvents.Subscribe( "timer_alert", AlertTimer );
    GameEvents.Subscribe( "overtime_alert", HideTimer );
    GameEvents.Subscribe( "contarct_time", ContractTime );
	//UpdateTimer();
})();

