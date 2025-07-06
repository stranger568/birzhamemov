var minimap_container = FindDotaHudElement("minimap_container");
$("#NewTimersPanels").SetParent(minimap_container);
let ORIGINAL_PANEL_WITH_TIMERS = minimap_container.FindChildTraverse("NewTimersPanels")

function UpdateTimer( data )
{
	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

    let original_time = data.original_time
    let full_original_time = data.full_original_time
    let NewTimerRadial = ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaRewardTime").FindChildTraverse("NewTimerRadial")
    if (NewTimerRadial)
    {
        NewTimerRadial.style.clip = "radial(50.0% 50.0%, 0deg," + (360 * (1 - (original_time / full_original_time))) + "deg)"
    }

	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("Timer" ).text = timerText;
}

function RefreshFountainTimer(data)
{
	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

    let original_time = data.original_time
    let full_original_time = data.full_original_time
    ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaEnd").visible = original_time > 0
    let NewTimerRadial = ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaEnd").FindChildTraverse("NewTimerRadial")
    if (NewTimerRadial)
    {
        NewTimerRadial.style.clip = "radial(50.0% 50.0%, 0deg," + (360 * (1 - (original_time / full_original_time))) + "deg)"
    }

	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("EndTimer" ).text = timerText;
}

function FountainUpdateTimer( data )
{
	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

    let original_time = data.original_time
    let full_original_time = data.full_original_time
    ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaFountainTime").visible = original_time > 0
    let NewTimerRadial = ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaFountainTime").FindChildTraverse("NewTimerRadial")
    if (NewTimerRadial)
    {
        NewTimerRadial.style.clip = "radial(50.0% 50.0%, 0deg," + (360 * (1 - (original_time / full_original_time))) + "deg)"
    }

	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("FountainTimer" ).text = timerText;
}


function ContractTime( data )
{
	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("ContractTimer" ).text = timerText;
}

function gametimer( data )
{
	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;
	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("GameTimer" ).text = timerText;

    if (Game.IsDayTime()) 
    {
        ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("GameTime" ).style.backgroundImage = "url('s2r://panorama/images/hud/reborn/icon_sun_psd.vtex');"
        ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("GameTime").style.backgroundSize = "100%"
    } 
    else 
    {
        ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("GameTime" ).style.backgroundImage = "url('s2r://panorama/images/hud/reborn/icon_moon_psd.vtex');"
        ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("GameTime").style.backgroundSize = "100%"
    }
}

function ShowTimer( data )
{
	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("Timer" ).AddClass( "timer_visible" );
}

function AlertTimer( data )
{
	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("Timer" ).AddClass( "timer_alert" );
}

function HideTimer( data )
{
	ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("Timer" ).AddClass( "timer_hidden" );
}

function UpdateKillsToWin()
{
	var victory_condition = CustomNetTables.GetTableValue( "game_state", "scores_to_win" );
	if (( victory_condition ) && (victory_condition.kills) && ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("VictoryPoints"))
	{
		ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("VictoryPoints").text = victory_condition.kills;
	}
}

function OnGameStateChanged( table, key, data )
{
	UpdateKillsToWin();
}

(function()
{
	ShowTextForPanel(ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaScore" ), $.Localize("#gamekills"))
	ShowTextForPanel(ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaRewardTime" ), $.Localize("#gametime"))
	ShowTextForPanel(ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaGameTime" ), $.Localize("#gametimename"))
	ShowTextForPanel(ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaFountainTime" ), $.Localize("#fountaintime"))
	ShowTextForPanel(ORIGINAL_PANEL_WITH_TIMERS.FindChildTraverse("BirzhaEnd" ), $.Localize("#endtimertext"))
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
})();