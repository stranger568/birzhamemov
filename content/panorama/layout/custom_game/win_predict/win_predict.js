GameEvents.Subscribe( 'open_win_predict', open_win_predict);

function open_win_predict()
{
    let birzhainfo = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
    if (birzhainfo)
    {
        $("#WinPredictTopCounterLabel").text = String(birzhainfo.win_predict)
    }
    $("#WinPredict").SetHasClass("open", true)
    $.Schedule(1, function()
    {
        $("#WinPredict").SetHasClass("Pulse", true)
    })
}

GameEvents.Subscribe( 'close_win_predict', close_win_predict);

function close_win_predict()
{
    $("#WinPredict").SetHasClass("open", false)
}

function WinCondition()
{
    $("#WinPredictButton").SetPanelEvent("onactivate", function() {});
    $("#WinPredictButton").SetHasClass("IsClick", true)
    $("#WinPredictButtonLabel").text = $.Localize("#birzha_win_predict_3")
    GameEvents.SendCustomGameEventToServer( "win_condition_predict", {} );
}