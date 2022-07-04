var favourites = new Array();
var nowrings = 8;
var selected_sound_current = undefined;
var rings = new Array(
    new Array(//0 start
        new Array("","","","","","","",""),
        new Array(true,true,true,true,true,true,true,true),
    ),
);
var nowselect = 0;

var Items_sounds = [
    ["52",  "sounds_1"], 
    ["53",  "sounds_2"], 
    ["54",  "sounds_3"], 
    ["55",  "sounds_4"],
    ["56",  "sounds_5"], 
    ["57",  "sounds_6"], 
    ["58",  "sounds_7"], 
    ["59",  "sounds_8"], 
    ["60",  "sounds_9"], 
    ["61",  "sounds_10"], 
    ["62",  "sounds_11"], 
    ["63",  "sounds_12"], 
    ["64",  "sounds_13"], 
    ["65",  "sounds_14"], 
    ["66",  "sounds_15"], 
    ["67",  "sounds_16"],
    ["68",  "sounds_17"], 
    ["69",  "sounds_18"], 
    ["70",  "sounds_19"], 
    ["71",  "sounds_20"], 
    ["72",  "sounds_21"], 
    ["73",  "sounds_22"], 
    ["74",  "sounds_23"], 
    ["75",  "sounds_24"],
    ["76",  "sounds_25"], 
    ["77",  "sounds_26"], 
    ["78",  "sounds_27"], 
    ["79",  "sounds_28"], 
    ["80",  "sounds_29"], 
    ["81",  "sounds_30"], 
    ["82",  "sounds_31"], 
    ["83",  "sounds_32"], 
    ["84",  "sounds_33"], 
    ["85",  "sounds_34"], 
    ["86",  "sounds_35"], 
    ["87",  "sounds_36"], 
    ["113", "sounds_37"], 
    ["114", "sounds_38"], 
    ["118", "sounds_39"], 
    ["119", "sounds_40"], 
    ["120", "sounds_41"], 
    ["121", "sounds_42"], 
    ["122", "sounds_43"], 
    ["123", "sounds_44"], 
    ["131", "sounds_45"], 
    ["132", "sounds_46"], 
    ["133", "sounds_47"], 
    ["134", "sounds_48"], 
]

var Items_sprays = [
    ["88",  "spray_1"], 
    ["89",  "spray_2"], 
    ["90",  "spray_3"], 
    ["91",  "spray_4"], 
    ["92",  "spray_5"], 
    ["93",  "spray_6"], 
    ["94",  "spray_7"], 
    ["95",  "spray_8"],
    ["96",  "spray_9"], 
    ["97",  "spray_10"], 
    ["98",  "spray_11"], 
    ["99",  "spray_12"], 
    ["100", "spray_13"], 
    ["101", "spray_14"], 
    ["102", "spray_15"], 
    ["103", "spray_16"],
    ["104", "spray_17"], 
    ["105", "spray_18"], 
    ["106", "spray_19"], 
    ["107", "spray_20"],
    ["108", "spray_21"], 
    ["109", "spray_22"], 
    ["110", "spray_23"], 
    ["111", "spray_24"],  
]

var Items_toys = [ 
    ["124", "toys_1"], 
    ["125", "toys_2"], 
]





















function StartWheel() {
    selected_sound_current = undefined;
    $("#Wheel").visible = true;
    $("#Bubble").visible = true;
    $("#PhrasesContainer").visible = true;

    $("#PhrasesContainer").RemoveAndDeleteChildren();
    for ( var i = 0; i < 8; i++ )
    {
        $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
            class: `MyPhrases`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        });
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
        $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];

        let name = $.Localize("#chatwheel_birzha_null")
        var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
        if (player_table)
        {
            if (player_table.chat_wheel)
            {
                for ( var item of Items_sounds )
                {
                    if (item[0] == String(player_table.chat_wheel[i+1])) {
                        name = $.Localize("#" + item[1])
                    }
                }
                for ( var item of Items_sprays )
                {
                    if (item[0] == String(player_table.chat_wheel[i+1])) {
                        name = $.Localize("#" + item[1])
                    }
                }
                for ( var item of Items_toys )
                {
                    if (item[0] == String(player_table.chat_wheel[i+1])) {
                        name = $.Localize("#" + item[1])
                    }
                }
            }
        }

        $("#Phrase"+i).GetChild(0).GetChild(0).text = name;
    }
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
                onmouseover: `OnMouseOver(${i})`,
                onmouseout: `OnMouseOut(${i})`,
            });
            $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
            $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];

            let name = $.Localize("#chatwheel_birzha_null")
            var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
            if (player_table)
            {
                if (player_table.chat_wheel)
                {
                    for ( var item of Items_sounds )
                    {
                        if (item[0] == String(player_table.chat_wheel[i+1])) {
                            name = $.Localize("#" + item[1])
                        }
                    }
                    for ( var item of Items_sprays )
                    {
                        if (item[0] == String(player_table.chat_wheel[i+1])) {
                            name = $.Localize("#" + item[1])
                        }
                    }
                    for ( var item of Items_toys )
                    {
                        if (item[0] == String(player_table.chat_wheel[i+1])) {
                            name = $.Localize("#" + item[1])
                        }
                    }
                }
            }

            $("#Phrase"+i).GetChild(0).GetChild(0).text = name;
        }
        nowselect = 0;
    }
    var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
    if (player_table)
    {
        if (player_table.chat_wheel)
        {
            if (selected_sound_current != undefined)
            {
                GameEvents.SendCustomGameEventToServer("SelectVO", {num: Number(player_table.chat_wheel[selected_sound_current+1])});
            }
        }
    }
    selected_sound_current = undefined;
}

function OnSelect(num) {
    var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
    if (player_table)
    {
        if (player_table.chat_wheel)
        {
            GameEvents.SendCustomGameEventToServer("SelectVO", {num: Number(player_table.chat_wheel[num+1])});
        }
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
    selected_sound_current = num;
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
    selected_sound_current = undefined;
    $( "#WheelPointer" ).AddClass( "Hidden" );
    $( "#Arrow" ).AddClass( "Hidden" );
}

(function() {
	GameUI.CustomUIConfig().chatWheelLoaded = true;

    for ( var i = 0; i < 8; i++ )
    {
        $.CreatePanelWithProperties(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
            class: `MyPhrases`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        });
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
        $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];


 
        let name = $.Localize("#chatwheel_birzha_null")

        var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
        if (player_table)
        {
            if (player_table.chat_wheel)
            {
                for ( var item of Items_sounds )
                {
                    if (item[0] == String(player_table.chat_wheel[i+1])) {
                        name = $.Localize("#" + item[1])
                    }
                }
                for ( var item of Items_sprays )
                {
                    if (item[0] == String(player_table.chat_wheel[i+1])) {
                        name = $.Localize("#" + item[1])
                    }
                }
                for ( var item of Items_toys )
                {
                    if (item[0] == String(player_table.chat_wheel[i+1])) {
                        name = $.Localize("#" + item[1])
                    }
                }
            }
        }

        $("#Phrase"+i).GetChild(0).GetChild(0).text = name;
    }
    Game.AddCommand("+WheelButton", StartWheel, "", 0);
    Game.AddCommand("-WheelButton", StopWheel, "", 0);
    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
})();
