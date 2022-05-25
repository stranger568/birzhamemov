GameUI.SetMouseCallback( function( eventName, arg ) {
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;

	if ( GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_DRAG && eventName == "released" )
	{
		var id=Players.GetLocalPlayer();
		$.Schedule(0.001,(function (id) {
			return function(){
			  var ent=Players.GetQueryUnit(id)
			  if (ent>0)
			    GameEvents.SendCustomGameEventToServer( "top_season", { "playerID" : id, "unitEntityID" : ent } );
			}
		})(id));
		return CONTINUE_PROCESSING_EVENT;
	}

	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
	{
		return CONTINUE_PROCESSING_EVENT;
	}

	if ( eventName == "pressed" )
	{
		if ( arg === 0 )
		{
			var id=Players.GetLocalPlayer()
			var ent=GameUI.FindScreenEntities(GameUI.GetCursorPosition())
			if (ent[0] != null && ent[0] !== undefined)
			  ent=ent[0].entityIndex;
			else
			  ent=null;
			if (ent != null && ent !== undefined)
			  GameEvents.SendCustomGameEventToServer( "top_season", { "playerID" : id, "unitEntityID" : ent } );
			return CONTINUE_PROCESSING_EVENT;
		}
		if ( arg === 1 )
		{
			return CONTINUE_PROCESSING_EVENT;
		}
	}
	return CONTINUE_PROCESSING_EVENT;
} );

function OpenPanelTopSeason() {
    $("#TopSeasonPanel").style.visibility = "visible";
}

function ClosePanelTopSeason() {
    $("#TopSeasonPanel").style.visibility = "collapse";
}


GameEvents.Subscribe( "birzha_open_top_season_panel", OpenPanelTopSeason );
GameEvents.Subscribe( "birzha_close_top_season_panel", ClosePanelTopSeason );