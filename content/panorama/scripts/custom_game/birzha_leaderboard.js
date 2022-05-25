var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#LeaderBoardButton")) {
	if (parentHUDElements.FindChildTraverse("LeaderBoardButton")){
		$("#LeaderBoardButton").DeleteAsync( 0 );
	} else {
		$("#LeaderBoardButton").SetParent(parentHUDElements);
	}
}

parentHUDElements.style.marginLeft = "0px";

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











var toggle = false;
var first_time = false;
var cooldown_panel = false

function ToggleLeaderboard() {
    if (toggle === false) {
    	if (cooldown_panel == false) {
	        toggle = true;
	        if (first_time === false) {
	            first_time = true;
	            $("#LeaderboardWindow").AddClass("sethidden");
	            GetMmrTop();
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





function GetMmrTop() {
	var topmmr = CustomNetTables.GetTableValue("birzha_mmr", "topmmr"); 


	for (var i = 1; i <= 10; i++) {
		$("#MmrTopCount" + i).text = i;        
	}

	if (!topmmr)
	{
	    $.Schedule(1, GetMmrTop)
	    return;
	}  

	for (var i = 1; i <= 10; i++)
	{
	    var bp = 0;
	    if (topmmr[i] != null)
	    {
	        $("#TopMmrAvatar" + i).accountid =  topmmr[i].steamid;
	        $("#NickLabelid" + i).steamid = topmmr[i].steamid;
	        $("#TopMmrReatingCount" + i).text = topmmr[i].mmr;
	    }    
	}

	if (topmmr.length > 9) { return true;}
	for (var i = topmmr.length + 1; i <= 14; i++) 
	{ 
	    $("#TopMmrPanel" + i).AddClass("mmrhidden");
	}
}


function GetMmrSeason()
{
    return (CustomNetTables.GetTableValue('game_state', 'birzha_gameinfo') || {}).mmr_season

}













































