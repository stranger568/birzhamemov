GameEvents.Subscribe( 'open_win_predict', open_win_predict);

function open_win_predict()
{
    let birzhainfo = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
    if (birzhainfo)
    {
        $("#WinPredictTopCounterLabel").text = String(birzhainfo.win_predict)
    }
    $("#WinPredict").SetHasClass("open", true)
}

GameEvents.Subscribe( 'close_win_predict', close_win_predict);

function close_win_predict()
{
    $("#WinPredict").SetHasClass("open", false)
}

function WinCondition()
{
    $("#WinPredictButton").style.opacity = "0"
    GameEvents.SendCustomGameEventToServer( "win_condition_predict", {} );
}