GameEvents.Subscribe( "birzha_ban_player", birzha_ban_player );

function birzha_ban_player(data)
{
    $("#ReportPanelLabel").text = $.Localize("#birzha_ban_player") + " " + data.days  + " " + $.Localize("#day")
    $("#ReportPanel").style.visibility = "visible"
}