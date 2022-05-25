var favourites = new Array();
var nowrings = 8;
var rings = new Array(
    new Array(//0 start
        new Array("#favourites","#BirzhaPass_sound_1","#BirzhaPass_sound_2","#BirzhaPass_sound_3","#BirzhaPass_next_wheel","#BirzhaPass_sprays_3","#BirzhaPass_sprays_2","#BirzhaPass_sprays_1"),
        new Array(false,false,false,false,false,false,false,false),
        new Array(7,1,2,3,8,6,5,4)
    ),

    new Array(//1 Sound list 1
        new Array("#sounds_1","#sounds_2","#sounds_3","#sounds_4","#sounds_5","#sounds_6","#sounds_7","#sounds_8"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(52,53,54,55,56,57,58,59)
    ),
    new Array(//2 Sound list 2
        new Array("#sounds_9","#sounds_10","#sounds_11","#sounds_12","#sounds_13","#sounds_14","#sounds_15","#sounds_16"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(60,61,62,63,64,65,66,67)
    ),
    new Array(//3 Sound list 3
        new Array("#sounds_17","#sounds_18","#sounds_19","#sounds_20","#sounds_21","#sounds_22","#sounds_23","#sounds_24"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(68,69,70,71,72,73,74,75)
    ),


    new Array(//4 Sprays list 1
        new Array("#spray_1","#spray_2","#spray_3","#spray_4","#spray_5","#spray_6","#spray_7","#spray_8"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(88,89,90,91,92,93,94,95)
    ),
    new Array(//5 Sprays list 2
        new Array("#spray_9","#spray_10","#spray_11","#spray_12","#spray_13","#spray_14","#spray_15","#spray_16"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(96,97,98,99,100,101,102,103)
    ),
    new Array(//6 Sprays list 3
        new Array("#spray_17","#spray_18","#spray_19","#spray_20","#spray_21","#spray_22","#spray_23","#spray_24"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(104,105,106,107,108,109,110,111)
    ),
    

    new Array(//7 Favourites
        new Array("#favoriteWhat","","","","","","",""),
        new Array(false,false,false,false,false,false,false,false),
        new Array(0,0,0,0,0,0,0,0)
    ),

    new Array(//8 New Wheel
        new Array("#BirzhaPass_sound_4","#BirzhaPass_sound_5","#BirzhaPass_sound_6","#BirzhaPass_toys_1","","","",""),
        new Array(false,false,false,false,false,false,false,false),
        new Array(9,10,11,12,0,0,0,0)
    ),
    new Array(//9 Sound list 4
        new Array("#sounds_25","#sounds_26","#sounds_27","#sounds_28","#sounds_29","#sounds_30","#sounds_31","#sounds_32"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(76,77,78,79,80,81,82,83)
    ),
    new Array(//10 Sound list 5
        new Array("#sounds_33","#sounds_34","#sounds_35","#sounds_36","#sounds_37","#sounds_38","#sounds_39","#sounds_40"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(84,85,86,87,113,114,118,119)
    ),
    new Array(//11 Sound list 6
        new Array("#sounds_41","#sounds_42","#sounds_43","#sounds_44","#sounds_45","#sounds_46","#sounds_47","#sounds_48"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(120,121,122,123,131,132,133,134)
    ),
    new Array(//12 Toys list 1
        new Array("#toys_1","#toys_2","","","","","",""),
        new Array(true,true,false,false,false,false,false,false),
        new Array(124,125,0,0,0,0,0,0)
    ),
);
var nowselect = 0;

function StartWheel() {
    $("#Wheel").visible = true;
    $("#Bubble").visible = true;
    $("#PhrasesContainer").visible = true;
}

function StopWheel() {
    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
    if (nowselect != 0)
    {
        $("#PhrasesContainer").RemoveAndDeleteChildren();
        for ( var i = 0; i < 8; i++ )
        {
            $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
                class: `MyPhrases`,
                onmouseactivate: `OnSelect(${i})`,
                onmouseover: `OnMouseOver(${i})`,
                onmouseout: `OnMouseOut(${i})`,
            });
            $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
            $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];
            $("#Phrase"+i).GetChild(0).GetChild(1).text = $.Localize(rings[0][0][i]);
        }
        nowselect = 0;
    }
}

function OnSelect(num) {
    var newnum = rings[nowselect][2][num];
    if (rings[nowselect][1][num])
    {
        GameEvents.SendCustomGameEventToServer("SelectVO", {num: newnum});
    }
    else
    {
        $("#PhrasesContainer").RemoveAndDeleteChildren();
        for ( var i = 0; i < 8; i++ )
        {
            let properities_for_panel = {
                class: `MyPhrases`,
                onmouseactivate: `OnSelect(${i})`,
                onmouseover: `OnMouseOver(${i})`,
                onmouseout: `OnMouseOut(${i})`,
            };

            if (rings[newnum][1][i]) {
                properities_for_panel.oncontextmenu = `AddOnFavourites(${i})`;
            }

            $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, properities_for_panel);
            $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
            $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[newnum][1][i];

            //var plyData = CustomNetTables.GetTableValue("birzhainfo", Players.GetLocalPlayer());

             var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
             var player_table_js = []
            
             for (var d = 1; d < 300; d++) {
                 player_table_js.push(player_table.player_items[d])
             }
            
             var phase_deactive = true
            
             for ( var item of player_table_js )
             {
                 if (item == rings[newnum][2][i]) {
                     phase_deactive = false
                     break
                 }
             }

            $("#Phrase"+i).GetChild(0).GetChild(1).text = $.Localize(rings[newnum][0][i]);

            if (phase_deactive && rings[newnum][2][i] != 0 && rings[newnum][2][i] != 7 && rings[newnum][2][i] != 1 && rings[newnum][2][i] != 2 && rings[newnum][2][i] != 3 && rings[newnum][2][i] != 8 && rings[newnum][2][i] != 6 && rings[newnum][2][i] != 5 && rings[newnum][2][i] != 4 && rings[newnum][2][i] != 9 && rings[newnum][2][i] != 10 && rings[newnum][2][i] != 11 && rings[newnum][2][i] != 12) {   
                $("#Phrase"+i).GetChild(0).GetChild(1).style.textDecoration = "line-through"
            }
        }
        nowselect = newnum;
    }
}

function AddOnFavourites(num) {
    if (nowselect != 8)
    {
        favourites.unshift(rings[nowselect][2][num]);
        if (favourites.length > 8)
            favourites[8] = null;
        favourites = favourites.filter(function (el) {
            return el != null;
        });
        Game.EmitSound( "ui.crafting_gem_create" )
        UpdateFavourites();
    }
    else
    {
        favourites[num] = null;
        favourites = favourites.filter(function (el) {
            return el != null;
        });
        UpdateFavourites();
        nowselect = 0;
        OnSelect(2);
    }
}

function UpdateFavourites() {
    var msg = new Array();
    var numsb = new Array();
    var numsi = new Array();
    for ( var i = 0; i < 8; i++ )
    {
        if (favourites[i])
        {
            msg[i] = FindLabelByNum(favourites[i]);
            numsi[i] = favourites[i];
            numsb[i] = true;
        }
        else
        {
            msg[i] = "";
            numsi[i] = 0;
            numsb[i] = false;
        }
    }
    rings[7] = new Array(msg,numsb,numsi);
}

function FindLabelByNum(num) {
    for (var key in rings) {
        var element = rings[key];
        for ( var i = 0; i < 8; i++ )
        {
            if (element[1][i] == true && element[2][i] == num)
            {
                return element[0][i];
            }
        }
    }
}

function OnMouseOver(num) {
    //$.Msg(num);
    $( "#WheelPointer" ).RemoveClass( "Hidden" );
    $( "#Arrow" ).RemoveClass( "Hidden" );
    for ( var i = 0; i < 8; i++ )
    {
        if ($("#Wheel").BHasClass("ForWheel"+i))
            $( "#Wheel" ).RemoveClass( "ForWheel"+i );
    }
    $( "#Wheel" ).AddClass( "ForWheel"+num );
}

function OnMouseOut(num) {
    $( "#WheelPointer" ).AddClass( "Hidden" );
    $( "#Arrow" ).AddClass( "Hidden" );
}

(function() {
	GameUI.CustomUIConfig().chatWheelLoaded = true;

    for ( var i = 0; i < 8; i++ )
    {
        $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
            class: `MyPhrases`,
            onmouseactivate: `OnSelect(${i})`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        });
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
        $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];
        $("#Phrase"+i).GetChild(0).GetChild(1).text = $.Localize(rings[0][0][i]);
    }
    Game.AddCommand("+WheelButton", StartWheel, "", 0);
    Game.AddCommand("-WheelButton", StopWheel, "", 0);
    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
})();
