var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#BirzhaPlusButton")) {
	if (parentHUDElements.FindChildTraverse("BirzhaPlusButton")){
		$("#BirzhaPlusButton").DeleteAsync( 0 );
	} else {
		$("#BirzhaPlusButton").SetParent(parentHUDElements);
	}
}

var localTeam = Players.GetTeam(Players.GetLocalPlayer())
if (localTeam == 1) {
	HideBattlepass()
}

function HideBattlepass() {
	$.GetContextPanel().style.visibility = "collapse";
	$.Schedule(2.0, HideBattlepass)
}

var toggle = false;
var first_time = false;
var cooldown_panel = false

function ToggleBattlepass() {
    if (toggle === false) {
    	if (cooldown_panel == false) {
	        toggle = true;
	        if (first_time === false) {
	            first_time = true;
	            $("#BirzhaPassWindow").AddClass("sethidden");
	            Init();
	        }  
	        if ($("#BirzhaPassWindow").BHasClass("sethidden")) {
	            $("#BirzhaPassWindow").RemoveClass("sethidden");
	        }
	        $("#BirzhaPassWindow").AddClass("setvisible");
	        $("#BirzhaPassWindow").style.visibility = "visible"
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        })
	    }
    } else {
    	if (cooldown_panel == false) {
	        toggle = false;
	        if ($("#BirzhaPassWindow").BHasClass("setvisible")) {
	            $("#BirzhaPassWindow").RemoveClass("setvisible");
	        }
	        $("#BirzhaPassWindow").AddClass("sethidden");
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        	$("#BirzhaPassWindow").style.visibility = "collapse"
			})
		}
    }
}




function SwitchTab(tab) {
	$("#TableInfoPlayer").style.visibility = "collapse";
	$("#HeroesInformation").style.visibility = "collapse";
	$("#" + tab).style.visibility = "visible";
}

function Init() {
	var table = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()))

	if (table) {
		if (table.bp_days <= 0) {
			$("#BirzhaPassWindow").RemoveAndDeleteChildren();
	    	var BuySubscribe = $.CreatePanel('Label', $("#BirzhaPassWindow"), "BuySubscribe");
	    	BuySubscribe.AddClass('BuySubscribe');
	    	BuySubscribe.text = $.Localize("#BuySubscribeBP")			
			return
		}
	} else {
		$("#BirzhaPassWindow").RemoveAndDeleteChildren();
	    var BuySubscribe = $.CreatePanel('Label', $("#BirzhaPassWindow"), "BuySubscribe");
	    BuySubscribe.AddClass('BuySubscribe');
	    BuySubscribe.text = $.Localize("#BuySubscribeBP")
		return
	}



	var player_matches = []

	var player_all_games = 0
	var player_win_games = 0
	var player_lose_games = 0
	var bp_days = 0
	var token_used = 0

	if (table) {
		if (Object.keys(table.heroes_matches).length <= 0) {
			$("#GamePlayeds").text = player_all_games
			$("#GameWins").text =    player_win_games
			$("#GameLoses").text =   player_lose_games

			$("#BpStatus").text = bp_days + " " + $.Localize("#day")
			$("#PlayerTokens").text = 0
			return
		}
		for (var i = 1; i <= Object.keys(table.heroes_matches).length; i++) {
			player_matches[i-1] = []

			var win = Number(table.heroes_matches[i]["win"])
			var winrate = 0
			if (win != 0) {
				winrate = (win / table.heroes_matches[i]["games"] * 100).toFixed(0)
			}

			var deaths = Number(table.heroes_matches[i]["deaths"])
			if (deaths == 0) {
				deaths = 1
			}


			player_matches[i-1].push(table.heroes_matches[i]["hero"], table.heroes_matches[i]["games"], table.heroes_matches[i]["win"], table.heroes_matches[i]["kills"], table.heroes_matches[i]["deaths"], winrate, (Number(table.heroes_matches[i]["kills"]) / deaths).toFixed(2), table.heroes_matches[i]["experience"])
		}
		bp_days = table.bp_days	
		token_used = table.token_used	
	} else {

		$("#GamePlayeds").text = player_all_games
		$("#GameWins").text =    player_win_games
		$("#GameLoses").text =   player_lose_games

		$("#BpStatus").text = bp_days + " " + $.Localize("#day")
		$("#PlayerTokens").text =  0
		return
	}
//
	for ( var hero of player_matches ) {
		player_all_games = player_all_games + Number(hero[1])
		player_win_games = Number(player_win_games) + Number(hero[2])
	}
 
	player_lose_games = Number(player_all_games) - Number(player_win_games)


	$("#GamePlayeds").text = player_all_games
	$("#GameWins").text =    player_win_games
	$("#GameLoses").text =   player_lose_games

	let winrate_percent =  player_win_games / player_all_games 
	$("#WinrateLabel").text = ((winrate_percent) * 100).toFixed(1) + "%"

	let radial_number = 0
	radial_number = 360 * winrate_percent
	$("#PlayerCircleWinrateFG").style.clip = 'radial( 50.0% 50.0%, 0.0deg, ' + radial_number + 'deg);'

	for (var i = 1; i <= Object.keys(table.mmr).length; i++) {

		var MmrSeasonBlock = $.CreatePanel('Panel', $("#AllRatingSeasons"), "");
	    MmrSeasonBlock.AddClass('MmrSeasonBlock');

	    var MmrBlockPanel = $.CreatePanel('Panel', MmrSeasonBlock, "");
	    MmrBlockPanel.AddClass('MmrBlockPanelSeason');

	    var label_block_rating = $.CreatePanel('Label', MmrBlockPanel, "");
	    label_block_rating.AddClass('label_block_rating');
	    label_block_rating.text =  $.Localize("#Season") + " " + i

	    var MmrBlockPanel_2 = $.CreatePanel('Panel', MmrSeasonBlock, "");
	    MmrBlockPanel_2.AddClass('MmrBlockPanel');

	    var label_block_rating_2 = $.CreatePanel('Label', MmrBlockPanel_2, "");
	    label_block_rating_2.AddClass('label_block_rating');
	    label_block_rating_2.text = String(table.mmr[i])
	}

	$("#BpStatus").text = bp_days + " " + $.Localize("#day")
	$("#PlayerTokens").text = String((10 - Number(token_used)))
////

	player_matches.sort(function (a, b) {
	  return Number(b[5])-Number(a[5]) && Number(b[1])-Number(a[1])
	});

	$("#TopHero").text =    $.Localize("#" + player_matches[0][0])

    var panel_withs_heroes_stats = $.CreatePanel('Panel', $("#HeroesInformation"), 'panel_withs_heroes_stats');
    panel_withs_heroes_stats.AddClass('PanelHeroes');


    var Row_Info = $.CreatePanel('Panel', panel_withs_heroes_stats, 'Row_info');
    Row_Info.AddClass('Row_Info');	

	var Info_HeroName = $.CreatePanel('Label', Row_Info, "Info_HeroName");
	Info_HeroName.AddClass('Info_HeroName');
	Info_HeroName.text = $.Localize("#Info_HeroName")

	var Info_HeroGames = $.CreatePanel('Label', Row_Info, "Info_HeroGames");
	Info_HeroGames.AddClass('Info_HeroGames');
	Info_HeroGames.text = $.Localize("#Info_HeroGames")

	var Info_HeroWinrate = $.CreatePanel('Label', Row_Info, "Info_HeroWinrate");
	Info_HeroWinrate.AddClass('Info_HeroWinrate');
	Info_HeroWinrate.text = $.Localize("#Info_HeroWinrate")

	var Info_HeroKD = $.CreatePanel('Label', Row_Info, "Info_HeroKD");
	Info_HeroKD.AddClass('Info_HeroKD');
	Info_HeroKD.text = $.Localize("#Info_HeroKD")

	var Info_HeroRank = $.CreatePanel('Label', Row_Info, "Info_HeroRank");
	Info_HeroRank.AddClass('Info_HeroRank');
	Info_HeroRank.text = $.Localize("#Info_HInfo_HeroRank")

    var PanelHeroes = $.CreatePanel('Panel', panel_withs_heroes_stats, 'PanelHeroes');
    PanelHeroes.AddClass('PanelHeroesMain');

    Info_HeroGames.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(player_matches, 1);
    } ); 

    Info_HeroWinrate.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(player_matches, 5);
    } ); 

    Info_HeroKD.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(player_matches, 6);
    } );  


	player_matches.sort(function (a, b) {
	  return Number(b[1])-Number(a[1])
	});

	for ( var hero of player_matches ) {
	    var HeroRow = $.CreatePanel('Panel', PanelHeroes, 'hero_'+hero[0]);
    	HeroRow.AddClass('HeroRow');

    	//if (Players.GetPlayerSelectedHero(Players.GetLocalPlayer()) == hero[0]) {
    	//	HeroRow.style.boxShadow = "0px 0px 2px 1px gray"
    	//}	

    	var HeroIcon = $.CreatePanel('Panel', HeroRow, "HeroIcon");
    	HeroIcon.AddClass('HeroIcon');
    	HeroIcon.style.backgroundImage = 'url( "file://{images}/custom_game/hight_hood/heroes/' + hero[0] + '.png" )';
    	HeroIcon.style.backgroundSize = "100% 100%"

    	var HeroName = $.CreatePanel('Label', HeroRow, "HeroName");
    	HeroName.AddClass('HeroName');
    	HeroName.text = $.Localize("#" + hero[0])

    	var HeroGames = $.CreatePanel('Label', HeroRow, "HeroGames");
    	HeroGames.AddClass('HeroGames');
    	HeroGames.text = hero[1]

    	var HeroWinrate = $.CreatePanel('Label', HeroRow, "HeroWinrate");
    	HeroWinrate.AddClass('HeroWinrate');
    	HeroWinrate.text = hero[5] + "%"

    	var HeroKD = $.CreatePanel('Label', HeroRow, "HeroKD");
    	HeroKD.AddClass('HeroKD');
    	HeroKD.text = hero[6]

    	var HeroRank = $.CreatePanel('Panel', HeroRow, "HeroRank");
    	HeroRank.AddClass('HeroRank');

		var rank_player = $.CreatePanel('Panel', HeroRank, 'rank_player');
		rank_player.style.width = "32px"
		rank_player.style.height = "32px"
		rank_player.style.align = "center center"
		rank_player.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero[7])) + '.png")'
		rank_player.style.backgroundSize = "100%"

	}
}

function ChangeHeroTable(table, num) {

	$("#PanelHeroes").RemoveAndDeleteChildren();

	table.sort(function (a, b) {
	  return Number(b[num])-Number(a[num])
	});

	for ( var hero of table ) {
	    var HeroRow = $.CreatePanel('Panel', $("#PanelHeroes"), 'hero_'+hero[0]);
    	HeroRow.AddClass('HeroRow');	

    	var HeroIcon = $.CreatePanel('Panel', HeroRow, "HeroIcon");
    	HeroIcon.AddClass('HeroIcon');
    	HeroIcon.style.backgroundImage = 'url( "file://{images}/custom_game/hight_hood/heroes/' + hero[0] + '.png" )';
    	HeroIcon.style.backgroundSize = "100% 100%"

    	var HeroName = $.CreatePanel('Label', HeroRow, "HeroName");
    	HeroName.AddClass('HeroName');
    	HeroName.text = $.Localize("#" + hero[0])

    	var HeroGames = $.CreatePanel('Label', HeroRow, "HeroGames");
    	HeroGames.AddClass('HeroGames');
    	HeroGames.text = hero[1]

    	var HeroWinrate = $.CreatePanel('Label', HeroRow, "HeroWinrate");
    	HeroWinrate.AddClass('HeroWinrate');
    	HeroWinrate.text = hero[5] + "%"

    	var HeroKD = $.CreatePanel('Label', HeroRow, "HeroKD");
    	HeroKD.AddClass('HeroKD');
    	HeroKD.text = hero[6]

    	var HeroRank = $.CreatePanel('Panel', HeroRow, "HeroRank");
    	HeroRank.AddClass('HeroRank');

		var rank_player = $.CreatePanel('Panel', HeroRank, 'rank_player');
		rank_player.style.width = "32px"
		rank_player.style.height = "32px"
		rank_player.style.align = "center center"
		rank_player.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero[7])) + '.png")'
		rank_player.style.backgroundSize = "100%"
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



function HasBirzhaPass(id)
{
    return (CustomNetTables.GetTableValue('birzhainfo', String(id)) || {}).bp_days > 0;
}