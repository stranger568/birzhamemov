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

(function()
{
    iIndexTip = RandomTipIndex();
    var sTip = "#LoadingTip_" + iIndexTip;
    $("#TipLabel").text=$.Localize(sTip);
    NextTip_Delay();
    $.CreatePanelWithProperties("MoviePanel", $("#CustomBg"), "Movie", { src: "file://{resources}/videos/custom_game/Loading/outlanders_header.webm", repeat:"true", autoplay:"onload" });
})();

var hittestBlocker = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer");

if (hittestBlocker) {
    hittestBlocker.hittest = false;
    hittestBlocker.hittestchildren = false;
}