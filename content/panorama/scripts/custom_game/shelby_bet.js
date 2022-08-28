GameEvents.Subscribe( 'bebra_event_activate_caster', BebraCasterStart );
GameEvents.Subscribe( 'bebra_event_activate_target', BebraTargetStart );
GameEvents.Subscribe( 'bebra_event_time_coint', BebraEventTimeCount );
GameEvents.Subscribe( 'bebra_event_close', BebraClose );
GameEvents.Subscribe( 'bebra_event_run', bebra_event_run );

select_runner = undefined

function BebraClose()
{
	$("#ShelbyPanel").style.visibility = "collapse"
}

function BebraEventTimeCount(data)
{
	$("#RunTimer").text = data.time
}

function BebraCasterStart(data)
{
	select_runner = undefined
	$( "#kotlrunner" ).SetHasClass( "SelectedUnit", false );
	$( "#miranarunner" ).SetHasClass( "SelectedUnit", false );
	$( "#chaosrunner" ).SetHasClass( "SelectedUnit", false );
	$( "#kotlrunner" ).FindChildTraverse("Tier").style.opacity = 0
	$( "#miranarunner" ).FindChildTraverse("Tier").style.opacity = 0
	$( "#chaosrunner" ).FindChildTraverse("Tier").style.opacity = 0
	$( "#kotlrunner" ).FindChildTraverse("KotlRunnerBackground").style.width = "0%"
	$( "#miranarunner" ).FindChildTraverse("MiranaRunnerBackground").style.width = "0%"
	$( "#chaosrunner" ).FindChildTraverse("ChaosRunnerBackground").style.width = "0%"

	var slider = $.GetContextPanel().FindChildInLayoutFile("EventRun_Slider");
	slider.min = 100;
	slider.max = data.max;
	slider.value = 0;

	$("#ShelbyPanel").style.visibility = "visible"
	$("#SelectRunnerPanel").style.visibility = "visible"
	$("#EventRun_Slider").style.visibility = "visible"
	$( "#EventLabelTwo" ).style.visibility = "collapse"
	$( "#RunTimer" ).style.visibility = "collapse"
	$( "#selectbutton" ).style.marginTop = "0px"

	SetPanelEvent($( "#kotlrunner" ), "kotl")
	SetPanelEvent($( "#miranarunner" ), "mirana")
	SetPanelEvent($( "#chaosrunner" ), "chaos")

	SetTextHover($( "#EventRunInfo" ), $.Localize("#shelby_caster_notification"))

	$( "#selectbutton" ).SetPanelEvent("onactivate", function() 
	{
		SelectRunnerCaster()
	})
}



function BebraTargetStart(data)
{
	select_runner = undefined
	$( "#kotlrunner" ).SetHasClass( "SelectedUnit", false );
	$( "#miranarunner" ).SetHasClass( "SelectedUnit", false );
	$( "#chaosrunner" ).SetHasClass( "SelectedUnit", false );
	$( "#kotlrunner" ).FindChildTraverse("Tier").style.opacity = 0
	$( "#miranarunner" ).FindChildTraverse("Tier").style.opacity = 0
	$( "#chaosrunner" ).FindChildTraverse("Tier").style.opacity = 0
	$( "#kotlrunner" ).FindChildTraverse("KotlRunnerBackground").style.width = "0%"
	$( "#miranarunner" ).FindChildTraverse("MiranaRunnerBackground").style.width = "0%"
	$( "#chaosrunner" ).FindChildTraverse("ChaosRunnerBackground").style.width = "0%"
	$( "#BetALabel" ).text = Math.round(data.bet)

	$("#ShelbyPanel").style.visibility = "visible"
	$("#SelectRunnerPanel").style.visibility = "visible"
	$("#EventRun_Slider").style.visibility = "collapse"
	$( "#EventLabelTwo" ).style.visibility = "visible"
	$( "#RunTimer" ).style.visibility = "visible"
	$( "#selectbutton" ).style.marginTop = "12px"

	SetPanelEvent($( "#kotlrunner" ), "kotl")
	SetPanelEvent($( "#miranarunner" ), "mirana")
	SetPanelEvent($( "#chaosrunner" ), "chaos")

	SetTextHover($( "#EventRunInfo" ), $.Localize("#shelby_target_notification"))

	$( "#selectbutton" ).SetPanelEvent("onactivate", function() 
	{
		SelectRunnerTarget()
	})
}

function SetPanelEvent(panel, runner)
{
	panel.SetPanelEvent("onactivate", function()
	{       
		$( "#kotlrunner" ).SetHasClass( "SelectedUnit", false );
		$( "#miranarunner" ).SetHasClass( "SelectedUnit", false );
		$( "#chaosrunner" ).SetHasClass( "SelectedUnit", false );
		panel.SetHasClass( "SelectedUnit", true );
		select_runner = runner	
 	})
} 

function SliderValueCheck() {
	var slider = $.GetContextPanel().FindChildInLayoutFile("EventRun_Slider");
	if (slider.value > 0) {
		$( "#BetALabel" ).text = Math.round(slider.value)
	}
}

function SetTextHover(panel, text) {
	panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });
}

function SelectRunnerCaster()
{
	if (select_runner == undefined) { return }
	$("#SelectRunnerPanel").style.visibility = "collapse"
	$( "#kotlrunner" ).SetPanelEvent("onactivate", function() {})
	$( "#miranarunner" ).SetPanelEvent("onactivate", function() {})
	$( "#chaosrunner" ).SetPanelEvent("onactivate", function() {})
	$( "#selectbutton" ).SetPanelEvent("onactivate", function() {})
	var slider = $.GetContextPanel().FindChildInLayoutFile("EventRun_Slider");
	GameEvents.SendCustomGameEventToServer( "BebraBetCaster", {pick : select_runner, bet : slider.value } );
}

function SelectRunnerTarget()
{
	if (select_runner == undefined) { return }
	$("#SelectRunnerPanel").style.visibility = "collapse"
	$( "#kotlrunner" ).SetPanelEvent("onactivate", function() {})
	$( "#miranarunner" ).SetPanelEvent("onactivate", function() {})
	$( "#chaosrunner" ).SetPanelEvent("onactivate", function() {})
	$( "#selectbutton" ).SetPanelEvent("onactivate", function() {})
	var slider = $.GetContextPanel().FindChildInLayoutFile("EventRun_Slider");
	GameEvents.SendCustomGameEventToServer( "BebraBetTarget", {pick : select_runner } );
}

function bebra_event_run( data )
{
	$( "#kotlrunner" ).FindChildTraverse("KotlRunnerBackground").style.width = data.kotl + "%"
	$( "#miranarunner" ).FindChildTraverse("MiranaRunnerBackground").style.width = data.mirana + "%"
	$( "#chaosrunner" ).FindChildTraverse("ChaosRunnerBackground").style.width = data.chaos + "%"

	if (data.kotl_number != 0 ) {
		$( "#kotlrunner" ).FindChildTraverse("Tier").style.backgroundImage = 'url("file://{images}/custom_game/shelby_bet/' + data.kotl_number + '_tier.png")'
		$( "#kotlrunner" ).FindChildTraverse("Number").text = data.kotl_number
		$( "#kotlrunner" ).FindChildTraverse("Tier").style.opacity = 1
	} else {
		$( "#kotlrunner" ).FindChildTraverse("Tier").style.opacity = 0
	}
	if (data.mirana_number != 0 ) {
		$( "#miranarunner" ).FindChildTraverse("Tier").style.backgroundImage = 'url("file://{images}/custom_game/shelby_bet/' + data.mirana_number + '_tier.png")'
		$( "#miranarunner" ).FindChildTraverse("Number").text = data.mirana_number
		$( "#miranarunner" ).FindChildTraverse("Tier").style.opacity = 1
	} else {
		$( "#miranarunner" ).FindChildTraverse("Tier").style.opacity = 0
	}
	if (data.chaos_number != 0 ) {
		$( "#chaosrunner" ).FindChildTraverse("Tier").style.backgroundImage = 'url("file://{images}/custom_game/shelby_bet/' + data.chaos_number + '_tier.png")'
		$( "#chaosrunner" ).FindChildTraverse("Number").text = data.chaos_number
		$( "#chaosrunner" ).FindChildTraverse("Tier").style.opacity = 1
	} else {
		$( "#chaosrunner" ).FindChildTraverse("Tier").style.opacity = 0
	}
}