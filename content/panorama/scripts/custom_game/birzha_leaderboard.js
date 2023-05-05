var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#LeaderBoardButton")) {
	if (parentHUDElements.FindChildTraverse("LeaderBoardButton")){
		$("#LeaderBoardButton").DeleteAsync( 0 );
	} else {
		$("#LeaderBoardButton").SetParent(parentHUDElements);
	}
}

if (parentHUDElements)
{
	parentHUDElements.style.marginLeft = "0px";
	parentHUDElements.style.marginTop = "4px";
	parentHUDElements.style.padding = "0px";
}

if ($("#ButtonsPanelBackground")) {
	if (parentHUDElements.FindChildTraverse("ButtonsPanelBackground")){
		$("#ButtonsPanelBackground").DeleteAsync( 0 );
	} else {
		$("#ButtonsPanelBackground").SetParent(parentHUDElements);
	}
}

var DashboardButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons").FindChildTraverse("DashboardButton");
var SettingsButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons").FindChildTraverse("SettingsButton");
var ToggleScoreboardButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons").FindChildTraverse("ToggleScoreboardButton");

if (DashboardButton) {
	DashboardButton.style.marginTop = "4px"
	DashboardButton.style.width = "30px"
	DashboardButton.style.height = "30px"
}

if (SettingsButton) {
	SettingsButton.style.marginTop = "4px"
	SettingsButton.style.width = "35px"
	SettingsButton.style.height = "35px"
}

if (ToggleScoreboardButton) {
	ToggleScoreboardButton.style.marginTop = "4px"
	ToggleScoreboardButton.style.width = "35px"
	ToggleScoreboardButton.style.height = "35px"
}

function ToggleMap(button, map_name)
{
	$("#solo").SetHasClass( "ButtonMapSelect", false );
	$("#duo").SetHasClass( "ButtonMapSelect", false );
	$("#trio").SetHasClass( "ButtonMapSelect", false );
	$("#5v5v5").SetHasClass( "ButtonMapSelect", false );
	$("#5v5").SetHasClass( "ButtonMapSelect", false );
	$("#zxc").SetHasClass( "ButtonMapSelect", false );
	Game.EmitSound("ui_topmenu_select")
	$("#" + button).SetHasClass( "ButtonMapSelect", true );
	GetMmrTop(map_name)
}

var toggle = false;
var first_time = false;
var cooldown_panel = false

function ToggleLeaderboard() {
    if (toggle === false) {
    	if (cooldown_panel == false) {
	        toggle = true;
	        Game.EmitSound("ui_goto_player_page")
	        if (first_time === false) {
	            first_time = true;
	            $("#LeaderboardWindow").AddClass("sethidden");
	            GetMmrTop("birzhamemov_solo");
	        }  
	        if ($("#LeaderboardWindow").BHasClass("sethidden")) {
	            $("#LeaderboardWindow").RemoveClass("sethidden");
	        }
	        $("#LeaderboardWindow").AddClass("setvisible");
	        $("#LeaderboardWindow").style.visibility = "visible"
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        })
	    }
    } else {
    	if (cooldown_panel == false) {
	        toggle = false;
	        Game.EmitSound("ui_goto_player_page")
	        if ($("#LeaderboardWindow").BHasClass("setvisible")) {
	            $("#LeaderboardWindow").RemoveClass("setvisible");
	        }
	        $("#LeaderboardWindow").AddClass("sethidden");
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        	$("#LeaderboardWindow").style.visibility = "collapse"
			})
		}
    }
}

function GetMmrTop(map_name) {
	$("#PlayersList").RemoveAndDeleteChildren()
	var topmmr = CustomNetTables.GetTableValue("birzha_mmr", "topmmr"); 
	if (topmmr)
	{
		if (topmmr[map_name])
		{
			for (var i = 1; i <= Object.keys(topmmr[map_name]).length; i++) {
				CreatePlayer(topmmr[map_name][i], i)
			}
		}
	}
}

function CreatePlayer(table, count)
{
	let player_panel = $.CreatePanel("Panel", $("#PlayersList"), "")
	player_panel.AddClass("TopMmrClass")

	let player_place = $.CreatePanel("Label", player_panel, "")
	player_place.AddClass("LabelTopMmrlow")
	player_place.text = count

	let player_nickname_and_avatar = $.CreatePanel("Panel", player_panel, "")
	player_nickname_and_avatar.AddClass("PlayerInfoTable")

	$.CreatePanelWithProperties("DOTAAvatarImage", player_nickname_and_avatar, "TopMmrAvatar", { style: "width:32px;height:32px;", accountid: table.steamid });
    $.CreatePanelWithProperties("DOTAUserName", player_nickname_and_avatar, "NickLabelid", { class: "TopMmrNick", steamid: table.steamid });
  
    let player_rating_panel = $.CreatePanel("Panel", player_panel, "")
	player_rating_panel.AddClass("MmrInfoTable")

	let RatingIcon = $.CreatePanel("Panel", player_rating_panel, "")
	RatingIcon.AddClass("MmrLeaderboard")

	let player_rating = $.CreatePanel("Label", player_rating_panel, "")
	player_rating.AddClass("TopMmrReatingCount")
	player_rating.text = (table.mmr || 0)

}

function GetMmrSeason()
{
    return (CustomNetTables.GetTableValue('game_state', 'birzha_gameinfo') || {}).mmr_season

}













































