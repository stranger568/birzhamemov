var favourites = new Array();
var nowrings = 8;
var selected_sound_current = undefined;
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

    ["165", "sounds_49"], 
    ["166", "sounds_50"], 
    ["167", "sounds_51"], 
    ["168", "sounds_52"], 
    ["169", "sounds_53"], 
    ["170", "sounds_54"], 
    ["171", "sounds_55"], 
    ["172", "sounds_56"], 
    ["173", "sounds_57"], 
    ["174", "sounds_58"], 
    ["175", "sounds_59"], 
    ["176", "sounds_60"], 
    ["177", "sounds_61"], 
    ["178", "sounds_62"], 

    ["202", "sounds_202"],
    ["203", "sounds_203"],
    ["204", "sounds_204"],
    ["205", "sounds_205"],
    ["206", "sounds_206"],
    ["207", "sounds_207"],
    ["208", "sounds_208"],
    ["209", "sounds_209"],
    ["210", "sounds_210"],
    ["211", "sounds_211"],
    ["212", "sounds_212"],
    ["213", "sounds_213"],
    ["214", "sounds_214"],
    ["215", "sounds_215"],
    ["216", "sounds_216"],
    ["217", "sounds_217"],
    ["218", "sounds_218"],
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
    ["184", "toys_3"], 
]

var rings = new Array(
    new Array(//0 start
        new Array("","","","","","","",""),
        new Array(true,true,true,true,true,true,true,true),
    ),
    new Array(
        new Array("#sounds_1","#sounds_2","#sounds_3","#sounds_4","#sounds_5","#sounds_6","#sounds_7","#sounds_8"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(52,53,54,55,56,57,58,59)
    ),
    new Array(
        new Array("#sounds_9","#sounds_10","#sounds_11","#sounds_12","#sounds_13","#sounds_14","#sounds_15","#sounds_16"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(60,61,62,63,64,65,66,67)
    ),
    new Array(
        new Array("#sounds_17","#sounds_18","#sounds_19","#sounds_20","#sounds_21","#sounds_22","#sounds_23","#sounds_24"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(68,69,70,71,72,73,74,75)
    ),
    new Array(
        new Array("#sounds_25","#sounds_26","#sounds_27","#sounds_28","#sounds_29","#sounds_30","#sounds_31","#sounds_32"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(76,77,78,79,80,81,82,83)
    ),
    new Array(
        new Array("#sounds_33","#sounds_34","#sounds_35","#sounds_36","#sounds_37","#sounds_38","#sounds_39","#sounds_40"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(84,85,86,87,113,114,118,119)
    ),
    new Array(
        new Array("#sounds_41","#sounds_42","#sounds_43","#sounds_44","#sounds_45","#sounds_46","#sounds_47","#sounds_48"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(120,121,122,123,131,132,133,134)
    ),
    new Array(
        new Array("#sounds_49","#sounds_50","#sounds_51","#sounds_52","#sounds_53","#sounds_54","#sounds_55","#sounds_56"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(165,166,167,168,169,170,171,172)
    ),
    new Array(
        new Array("#sounds_57","#sounds_58","#sounds_59","#sounds_60","#sounds_61","#sounds_62","#sounds_202","#sounds_203"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(173,174,175,176,177,178,202,203)
    ),
    new Array(
        new Array("#sounds_204","#sounds_205","#sounds_206","#sounds_207","#sounds_208","#sounds_209","#sounds_210","#sounds_211"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(204,205,206,207,208,209,210,211)
    ),
    new Array(
        new Array("#sounds_212","#sounds_213","#sounds_214","#sounds_215","#sounds_216","#sounds_217","#sounds_218",""),
        new Array(true,true,true,true,true,true,true,false),
        new Array(212,213,214,215,216,217,218,0)
    ),
    new Array(
        new Array("#spray_1","#spray_2","#spray_3","#spray_4","#spray_5","#spray_6","#spray_7","#spray_8"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(88,89,90,91,92,93,94,95)
    ),
    new Array(
        new Array("#spray_9","#spray_10","#spray_11","#spray_12","#spray_13","#spray_14","#spray_15","#spray_16"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(96,97,98,99,100,101,102,103)
    ),
    new Array(
        new Array("#spray_17","#spray_18","#spray_19","#spray_20","#spray_21","#spray_22","#spray_23","#spray_24"),
        new Array(true,true,true,true,true,true,true,true),
        new Array(104,105,106,107,108,109,110,111)
    ),
    new Array(
        new Array("#spray_249","#spray_250","#spray_251","#spray_252","#spray_253","#spray_254","",""),
        new Array(true,true,true,true,true,true,false,false),
        new Array(249,250,251,252,253,254,0,0)
    ),
    new Array(
        new Array("#toys_1","#toys_2","#toys_3","","","","",""),
        new Array(true,true,true,false,false,false,false,false),
        new Array(124,125,184,0,0,0,0,0)
    ),
);

function StartWheel() {
    selected_sound_current = undefined;
    $("#Wheel").visible = true;
    $("#Bubble").visible = true;
    $("#PhrasesContainer").visible = true;
    $("#ChangeWheelButtons").visible = true;
    $("#ChangeWheelButtonLabel").text = (nowselect + 1) + " / " + rings.length 
    $("#PhrasesContainer").RemoveAndDeleteChildren();
    for ( var i = 0; i < 8; i++ )
    {
        $.CreatePanel(`Button`, $("#PhrasesContainer"), `Phrase${i}`, {
            class: `MyPhrases`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        });
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");
        $("#Phrase"+i).GetChild(0).GetChild(0).visible = rings[0][1][i];

        if (nowselect != 0)
        {
             var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
             var player_table_js = []
            
             for (var d = 1; d < 300; d++) {
                 player_table_js.push(player_table.player_items[d])
             }
            
             var phase_deactive = true
            
             for ( var item of player_table_js )
             {
                 if (item == rings[nowselect][2][i]) {
                     phase_deactive = false
                     break
                 }
             }

             if (rings[nowselect][1][i] == false)
             {
                $("#Phrase"+i).style.visibility = "collapse"
             } else {
                $("#Phrase"+i).style.visibility = "visible"
             }

            $("#Phrase"+i).GetChild(0).GetChild(0).text = $.Localize(rings[nowselect][0][i]);

            if (phase_deactive) {   
                var blocked = $.CreatePanel("Panel", $("#Phrase"+i).GetChild(0), "" );
                blocked.AddClass("BlockChatWheel");
                $("#Phrase"+i).GetChild(0).style.washColor = "red"
            }
        } else {
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
}

function LeftButton()
{
    if (nowselect - 1 < 0)
    {
        nowselect = rings.length - 1
    } else {
        nowselect = nowselect - 1
    }
    $("#ChangeWheelButtonLabel").text = (nowselect + 1) + " / " + rings.length
    $("#PhrasesContainer").RemoveAndDeleteChildren();
    for ( var i = 0; i < 8; i++ )
    {
        let properities_for_panel = {
            class: `MyPhrases`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        };

        $.CreatePanel(`Button`, $("#PhrasesContainer"), `Phrase${i}`, properities_for_panel);
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");

        if (nowselect != 0)
        {
             var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
             var player_table_js = []
            
             for (var d = 1; d < 300; d++) {
                 player_table_js.push(player_table.player_items[d])
             }
            
             var phase_deactive = true
            
             for ( var item of player_table_js )
             {
                 if (item == rings[nowselect][2][i]) {
                     phase_deactive = false
                     break
                 }
             }

             if (rings[nowselect][1][i] == false)
             {
                $("#Phrase"+i).style.visibility = "collapse"
             } else {
                $("#Phrase"+i).style.visibility = "visible"
             }

            $("#Phrase"+i).GetChild(0).GetChild(0).text = $.Localize(rings[nowselect][0][i]);

            if (phase_deactive) {   
                var blocked = $.CreatePanel("Panel", $("#Phrase"+i).GetChild(0), "" );
                blocked.AddClass("BlockChatWheel");
                $("#Phrase"+i).GetChild(0).style.washColor = "red"
            }
        } else {
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
}

function RightButton()
{
    if (nowselect + 1 > (rings.length - 1))
    {
        nowselect = 0
    } else {
        nowselect = nowselect + 1
    }
    $("#ChangeWheelButtonLabel").text = (nowselect + 1) + " / " + rings.length
    $("#PhrasesContainer").RemoveAndDeleteChildren();
    for ( var i = 0; i < 8; i++ )
    {
        let properities_for_panel = {
            class: `MyPhrases`,
            onmouseover: `OnMouseOver(${i})`,
            onmouseout: `OnMouseOut(${i})`,
        };

        $.CreatePanel(`Button`, $("#PhrasesContainer"), `Phrase${i}`, properities_for_panel);
        $("#Phrase"+i).BLoadLayoutSnippet("Phrase");

        if (nowselect != 0)
        {
             var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
             var player_table_js = []
            
             for (var d = 1; d < 300; d++) {
                 player_table_js.push(player_table.player_items[d])
             }
            
             var phase_deactive = true
            
             for ( var item of player_table_js )
             {
                 if (item == rings[nowselect][2][i]) {
                     phase_deactive = false
                     break
                 }
             }

             if (rings[nowselect][1][i] == false)
             {
                $("#Phrase"+i).style.visibility = "collapse"
             } else {
                $("#Phrase"+i).style.visibility = "visible"
             }

            $("#Phrase"+i).GetChild(0).GetChild(0).text = $.Localize(rings[nowselect][0][i]);

            if (phase_deactive) {   
                var blocked = $.CreatePanel("Panel", $("#Phrase"+i).GetChild(0), "" );
                blocked.AddClass("BlockChatWheel");
                $("#Phrase"+i).GetChild(0).style.washColor = "red"
            }
        } else {
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
}

function StopWheel() {
    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
    $("#ChangeWheelButtons").visible = false;

    if (nowselect == 0)
    {
        var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
        if (player_table)
        {
            if (player_table.chat_wheel)
            {
                if (player_table.chat_wheel[selected_sound_current+1])
                {
                    GameEvents.SendCustomGameEventToServer("SelectVO", {num: Number(player_table.chat_wheel[selected_sound_current+1])});
                }
            }
        }
    } else {
        var newnum = rings[nowselect][2][selected_sound_current];
        if (rings[nowselect][1][selected_sound_current])
        {
            GameEvents.SendCustomGameEventToServer("SelectVO", {num: Number(newnum)});
        }
    }
    selected_sound_current = undefined;
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

    let button_bind = GetGameKeybind(DOTAKeybindCommand_t.DOTA_KEYBIND_CHAT_WHEEL)

    if (GetGameKeybind(DOTAKeybindCommand_t.DOTA_KEYBIND_CHAT_WHEEL) == "") 
    {
        button_bind = "Y"
    }

    const name_bind = "WheelButton" + Math.floor(Math.random() * 99999999);
    Game.AddCommand("+" + name_bind, StartWheel, "", 0);
    Game.AddCommand("-" + name_bind, StopWheel, "", 0);

    GameUI.CustomUIConfig().button_with_wheel = button_bind

    Game.CreateCustomKeyBind(button_bind, "+" + name_bind);

    $("#Wheel").visible = false;
    $("#Bubble").visible = false;
    $("#PhrasesContainer").visible = false;
    $("#ChangeWheelButtons").visible = false;
})();

function GetGameKeybind(command) {
    return Game.GetKeybindForCommand(command);
}