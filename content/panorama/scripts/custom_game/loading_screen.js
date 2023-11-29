var iIndexTip = 1; 
var LOADINGTIP_CHANGE_DELAY = 15;

var availableIndexTable = 
[
    1,2,3,4,5,6,7,8,9,10,11,12,13
]

function NextTip_Delay()
{
    NextTip();
    $.Schedule(LOADINGTIP_CHANGE_DELAY, NextTip_Delay);
}

function RandomTipIndex()
{
    var randomIndex = Math.floor(Math.random()*availableIndexTable.length);
    while(availableIndexTable[(randomIndex).toString()] == iIndexTip)
    {
        
        randomIndex = Math.floor(Math.random()*availableIndexTable.length);
    }
    return availableIndexTable[(randomIndex).toString()];
}

function NextTip()
{
    iIndexTip = RandomTipIndex();
    var sTip = "#LoadingTip_" + iIndexTip;
    $("#TipLabel").text=$.Localize(sTip);
}

function SwapLeaders(panel, button)
{
    $("#SoloPlayers").style.visibility = "collapse"
    $("#DuoPlayers").style.visibility = "collapse"
    $("#TrioPlayers").style.visibility = "collapse"
    $("#5v5Players").style.visibility = "collapse"
    $("#5v5v5Players").style.visibility = "collapse"
    $("#zxcPlayers").style.visibility = "collapse"

    $("#SoloPlayers_button").SetHasClass("ButtonActive", false)
    $("#DuoPlayers_button").SetHasClass("ButtonActive", false)
    $("#TrioPlayers_button").SetHasClass("ButtonActive", false)
    $("#5v5Players_button").SetHasClass("ButtonActive", false)
    $("#5v5v5Players_button").SetHasClass("ButtonActive", false)
    $("#zxcPlayers_button").SetHasClass("ButtonActive", false)

    $("#"+panel).style.visibility = "visible"
    $("#"+button).SetHasClass("ButtonActive", true)
}

(function()
{
    //iIndexTip = RandomTipIndex();
    //var sTip = "#LoadingTip_" + iIndexTip;
    //$("#TipLabel").text=$.Localize(sTip);
    //NextTip_Delay();
    LastSeasonPlayers()
    $.CreatePanel("MoviePanel", $("#CustomBg"), "Movie", { src: "file://{resources}/videos/custom_game/Loading/outlanders_header.webm", repeat:"true", autoplay:"onload" });
})();

var hittestBlocker = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer");

if (hittestBlocker) {
    hittestBlocker.hittest = false;
    hittestBlocker.hittestchildren = false;
}

function LastSeasonPlayers()
{
    let last_season_info = CustomNetTables.GetTableValue("game_state", "birzha_top_last_season") 
    if (last_season_info)
    {
        for (var i = 1; i <= Object.keys(last_season_info["birzhamemov_solo"]).length; i++) 
        {
            $("#SoloPlayers").FindChildTraverse("Player_"+i).accountid = last_season_info["birzhamemov_solo"][i]["steamid"]
        }
        for (var i = 1; i <= Object.keys(last_season_info["birzhamemov_duo"]).length; i++) 
        {
            $("#DuoPlayers").FindChildTraverse("Player_"+i).accountid = last_season_info["birzhamemov_duo"][i]["steamid"]
        }
        for (var i = 1; i <= Object.keys(last_season_info["birzhamemov_trio"]).length; i++) 
        {
            $("#TrioPlayers").FindChildTraverse("Player_"+i).accountid = last_season_info["birzhamemov_trio"][i]["steamid"]
        }
        for (var i = 1; i <= Object.keys(last_season_info["birzhamemov_5v5"]).length; i++) 
        {
            $("#5v5Players").FindChildTraverse("Player_"+i).accountid = last_season_info["birzhamemov_5v5"][i]["steamid"]
        }
        for (var i = 1; i <= Object.keys(last_season_info["birzhamemov_5v5v5"]).length; i++) 
        {
            $("#5v5v5Players").FindChildTraverse("Player_"+i).accountid = last_season_info["birzhamemov_5v5v5"][i]["steamid"]
        }
        for (var i = 1; i <= Object.keys(last_season_info["birzhamemov_zxc"]).length; i++) 
        {
            $("#zxcPlayers").FindChildTraverse("Player_"+i).accountid = last_season_info["birzhamemov_zxc"][i]["steamid"]
        }
    }
    else
    {
        $.Schedule(0.1, LastSeasonPlayers)
    }
}









