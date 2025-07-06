function GetMmrSeason()
{
    return (CustomNetTables.GetTableValue('game_state', 'birzha_gameinfo') || {}).season
}

function GetCurrentSeasonDays()
{
	let table = CustomNetTables.GetTableValue("game_state", "birzha_gameinfo")
	if (table)
	{
		if (table.days_season)
		{
			return Number(table.days_season)
		}
	}
	return 0
}

function GetHeroExp(exp)
{
    let level = exp % 1000 + " / 1000"
    return level
} 

function GetHeroExpProgress(exp)
{
    let level = exp % 1000
    var percent = ((1000-level)*100)/1000

    if (percent >= 0) {
        return (100 - percent) +'%';
    } else {
        return '0%'
    }
} 

function GetHeroLevel(exp)
{
    let level = exp / 1000
    return Math.floor(level)
} 

function GetHeroRankIcon(level)
{
    if (level >= 35) {
        return "rank_7"
    } else if (level >= 30) {
        return "rank_6"
    } else if (level >= 25) {
        return "rank_5"
    } else if (level >= 20) {
        return "rank_4"
    } else if (level >= 15) {
        return "rank_3"
    } else if (level >= 10) {
        return "rank_2"
    } else if (level >= 5) {
        return "rank_1"
    } else {
        return "rank_0"
    }
}

function GetHeroRankName(level)
{
    if (level >= 30) {
        return $.Localize("#BP_rank_7")
    } else if (level >= 20) {
        return $.Localize("#BP_rank_6")
    } else if (level >= 10) {
        return $.Localize("#BP_rank_5")
    } else if (level >= 7) {
        return $.Localize("#BP_rank_4")
    } else if (level >= 5) {
        return $.Localize("#BP_rank_3")
    } else if (level >= 3) {
        return $.Localize("#BP_rank_2")
    } else if (level >= 1) {
        return $.Localize("#BP_rank_1")
    } else {
        return $.Localize("#BP_rank_0")
    }
}

function GetHeroInformation(info, hero)
{
    for (var i = 1; i <= Object.keys(info.heroes_matches).length; i++) {
        if (info.heroes_matches[i]["hero"] == hero)
        {
            return info.heroes_matches[i]
        }
    }
    return "No"
}  

function HasBirzhaPass(id)
{
    return (CustomNetTables.GetTableValue('birzhainfo', String(id)) || {}).bp_days > 0;
}

function GetCurrentSeasonNumber()
{
	let table = CustomNetTables.GetTableValue("game_state", "birzha_gameinfo")
	if (table)
	{
		if (table.season)
		{
			return Number(table.season)
		}
	}
}

function IsAllowForThis()
{
    var player_table = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()))
    if (player_table && player_table.games && player_table.games >= 5)
    {
        return true
    }
    return false
}

function GenerateAlphabet(num)
{
    var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "/", ":", "."]
    let result = ""
    for (var i = 0; i < num.length; i++) 
    {
        result = result + alphabet[num[i]]
    }
    return result
} 

function FreddyScreamerTrue()
{
    $.CreatePanel("MoviePanel", $("#FreddyScreamerPanel"), 'screamer_freddy', { style:"width:70%;height:70%;align:center center;opacity:0.99;", class:"freddy_screamer_webm", src:"file://{resources}/videos/custom_game/fnaf_screamer.webm", repeat:"true", hittest:"false", autoplay:"onload"});
}
function FreddyScreamerFalse()
{
    $("#FreddyScreamerPanel").RemoveAndDeleteChildren()
}

function SaitamaPunchTrue()
{
    $("#SaitamaPunch").visible = true;
    if ($("#SaitamaPunchImage").BHasClass("sethidden")) {
        $("#SaitamaPunchImage").RemoveClass("sethidden");
    }
    $("#SaitamaPunchImage").AddClass("setvisible");
}

function SaitamaPunchFalse()
{
    $("#SaitamaPunch").visible = false;
    if ($("#SaitamaPunchImage").BHasClass("setvisible")) {
        $("#SaitamaPunchImage").RemoveClass("setvisible");
    }
    $("#SaitamaPunchImage").AddClass("sethidden");
}

function ScpScreamerTrue()
{
    $("#ScreamerScp").visible = true;
}

function ScpScreamerFalse()
{
    $("#ScreamerScp").visible = false;
}

function ScpScreamerTrueBonus()
{
    $("#ScreamerScpBonus").visible = true;
}

function ScpScreamerFalseBonus()
{
    $("#ScreamerScpBonus").visible = false;
}

function PortraitClicked()
{
    Players.PlayerPortraitClicked( $.GetContextPanel().GetAttributeInt( "player_id", -1 ), false, false );
}

function GetHeroWinrate(hero_name)
{
    let player_winrate = CustomNetTables.GetTableValue("game_state", "heroes_winrate");
    if (player_winrate)
    {
        return (player_winrate["heroes"][hero_name] || 0)
    }
    return 0
}

(function () {
    GameEvents.Subscribe( "ScpScreamerTrue", ScpScreamerTrue );
    GameEvents.Subscribe( "ScpScreamerFalse", ScpScreamerFalse );
    GameEvents.Subscribe( "ScpScreamerTrueBonus", ScpScreamerTrueBonus );
    GameEvents.Subscribe( "ScpScreamerFalseBonus", ScpScreamerFalseBonus );
    GameEvents.Subscribe( "FreddyScreamerTrue", FreddyScreamerTrue );
    GameEvents.Subscribe( "FreddyScreamerFalse", FreddyScreamerFalse );
    GameEvents.Subscribe( "SaitamaPunchTrue", SaitamaPunchTrue );
    GameEvents.Subscribe( "SaitamaPunchFalse", SaitamaPunchFalse );
})();