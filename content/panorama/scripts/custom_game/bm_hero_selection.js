var dotahud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();

var heroes = 
{
    "npc_dota_hero_techies": true,
    "npc_dota_hero_abaddon": true,
    "npc_dota_hero_juggernaut": true,
    "npc_dota_hero_sand_king": true,
    "npc_dota_hero_winter_wyvern": true,
    "npc_dota_hero_enigma": true,
    "npc_dota_hero_invoker": true,
    "npc_dota_hero_gyrocopter": true,
    "npc_dota_hero_rubick": true,
    "npc_dota_hero_life_stealer": true,
    "npc_dota_hero_spectre": true,
    "npc_dota_hero_sven": true,
    "npc_dota_hero_naga_siren": true,
    "npc_dota_hero_enchantress": true,
    "npc_dota_hero_phantom_assassin": true,
    "npc_dota_hero_crystal_maiden": true,
    "npc_dota_hero_queenofpain": true,
    "npc_dota_hero_dark_willow": true,
    "npc_dota_hero_templar_assassin": true,
    "npc_dota_hero_lina": true,
    "npc_dota_hero_morphling": true,
    "npc_dota_hero_abyssal_underlord": true,
    "npc_dota_hero_phantom_lancer": true,
    "npc_dota_hero_luna": true,
    "npc_dota_hero_ogre_magi": true,
    "npc_dota_hero_vengefulspirit": true,
    "npc_dota_hero_riki": true,
    "npc_dota_hero_nyx_assassin": true,
    "npc_dota_hero_centaur": true,
    "npc_dota_hero_batrider": true,
    "npc_dota_hero_slardar": true,
    "npc_dota_hero_magnataur": true,
    "npc_dota_hero_treant": true,
    "npc_dota_hero_tidehunter": true,
    "npc_dota_hero_dawnbreaker": true,
    "npc_dota_hero_oracle": true,
    "npc_dota_hero_void_spirit": true,
    "npc_dota_hero_arc_warden": true,
    "npc_dota_hero_sasake": true,
    "npc_dota_hero_migi": true,
    "npc_dota_hero_overlord": true,
    "npc_dota_hero_stone_dwayne": true,
    "npc_dota_hero_silencer": true,
    "npc_dota_hero_marci": true,
    "npc_dota_hero_rat": true,
    "npc_dota_hero_pump": true,
    "npc_dota_hero_pyramide": true,
    "npc_dota_hero_sonic": true,
    "npc_dota_hero_travoman": true,
    "npc_dota_hero_jull": true,
    "npc_dota_hero_nolik": true,
    "npc_dota_hero_freddy": true,
    "npc_dota_hero_saitama": true,
    "npc_dota_hero_tailer": true,
    "npc_dota_hero_thomas_bebra": true,
    "npc_dota_hero_serega_pirat" : true,
    "npc_dota_hero_venom" : true,
};  

var selected_hero
var buttons;
var buttons_parent;
var chat;
var chat_parent;
var start_voice = true;
var double_rating = true

function IsSpectator() 
{
    const localPlayer = Players.GetLocalPlayer()
    if (Players.IsSpectator(localPlayer))
    {
        return true
    }
    const localTeam = Players.GetTeam(localPlayer)
    return localTeam !== 2 && localTeam !== 3 && localTeam !== 6 && localTeam !== 7 && localTeam !== 8 && localTeam !== 9 && localTeam !== 10 && localTeam !== 11 && localTeam !== 12 && localTeam !== 13
}

function BirzhaPickInit()
{
    if (IsSpectator())
    {
        return
    }

    GameEvents.Subscribe( 'birzha_pick_start', PickStart );
    GameEvents.Subscribe( 'birzha_pick_load_heroes', LoadHeroes );
    GameEvents.Subscribe( 'birzha_pick_timer_upd', TimerUpd );
    GameEvents.Subscribe( 'birzha_pick_ban_start', BanStart );
    GameEvents.Subscribe( 'birzha_pick_ban_heroes', BanHeroes );
    GameEvents.Subscribe( 'birzha_pick_start_selection', StartSelection );
    GameEvents.Subscribe( 'birzha_pick_preend_start', StartPreEnd );
    GameEvents.Subscribe( 'birzha_pick_select_hero', HeroSelected );
    GameEvents.Subscribe( 'birzha_pick_end', HeroSelectionEnd );
    GameEvents.Subscribe( 'hero_is_picked', HeroesIsPicked );
    GameEvents.Subscribe( 'more_ban_aviable', Moreban );
    GameEvents.Subscribe( 'birzha_pick_filter_reconnect', BirzhaShowFiltList );
    GameEvents.Subscribe( 'ban_count_changed', ban_count_changed );
}

function BirzhaHeroSelectionLoad()
{
    if (IsSpectator()) 
    {
        $.GetContextPanel().AddClass('Deletion');
        $.GetContextPanel().style.opacity = "0"
        return
    }

    $.Msg("dadadad")

    StealButtonsAndChat();

    $.Schedule( 1, function()
    {
        GameEvents.SendCustomGameEventToServer( 'birzha_pick_player_registred', {} );
    });

    $.Schedule( 1.5, function()
    {
        GameEvents.SendCustomGameEventToServer( 'birzha_pick_player_loaded', {} );
    });

    var game_start = CustomNetTables.GetTableValue('game_state', "pickstate");

    if (game_start)
    {
        if (game_start.v == "ended")
        {
            HeroSelectionEnd()
        } 
        else 
        {
            LoadHeroes()
        }
    } else {
        LoadHeroes()
    }

    CreateTokenPanel();
}

function StealButtonsAndChat()
{
    if( $.GetContextPanel().BHasClass('Deletion') ) return;

    buttons = dotahud.FindChildTraverse('MenuButtons');
    buttons_parent = buttons.GetParent();

    if( buttons )
    {
        buttons.SetParent( $.GetContextPanel() );
        buttons.FindChildTraverse('ToggleScoreboardButton').visible = false;
    }
    
    chat = dotahud.FindChildTraverse('HudChat');
    chat_parent = chat.GetParent();

    if( chat )
    {
        chat.SetParent( $.GetContextPanel() );
        chat.style.horizontalAlign = 'right';
        chat.style.y = '0px';
    }
}

function RestoreButtonsAndChat()
{
    var HudElements = dotahud.FindChildTraverse('HUDElements');
    var button = dotahud.FindChildTraverse('MenuButtons');
    var chating = dotahud.FindChildTraverse('HudChat');

    if ( button && HudElements )
    {
        button.SetParent( HudElements );
        button.FindChildTraverse('ToggleScoreboardButton').visible = true;
    }
    
    if ( chating && HudElements )
    {
        chating.SetParent( HudElements );
        chating.style.horizontalAlign = 'center';
        chating.style.y = '-220px';
    }
}

function HeroSelectionEnd()
{
    $.GetContextPanel().AddClass('Deletion');

    RestoreButtonsAndChat();

    $.Schedule(1.5, function() 
    {
        if ($("#BGScene"))
        {
            $("#BGScene").DeleteAsync(0)
        }
        $.GetContextPanel().style.opacity = "0"
    })

    var ButtonsPanelBackground = dotahud.FindChildTraverse("MenuButtons").FindChildTraverse("ButtonsPanelBackground");
    if (ButtonsPanelBackground)
    {
        ButtonsPanelBackground.style.visibility = "visible"
    }
}

function PickStart( kv )
{
    $.GetContextPanel().SetFocus();
}

function LoadHeroes( kv )
{
    $("#HeroInfoCont").style.opacity = "1"
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));



    let strength_heroes = 
    [
        "npc_dota_hero_huskar",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_slardar",
        "npc_dota_hero_lycan",
        "npc_dota_hero_tusk",
        "npc_dota_hero_saitama",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_slark",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_migi",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_pudge",
        "npc_dota_hero_venom",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_tailer",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_nolik",
        "npc_dota_hero_pyramide",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_stone_dwayne",
        "npc_dota_hero_mars",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_axe",
        "npc_dota_hero_treant",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_spectre",
        "npc_dota_hero_centaur",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_ursa",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_tiny",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_sven",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_chaos_knight",
    ]

    let agility_heroes = 
    [
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_antimage",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_serega_pirat",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_marci",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_furion",
        "npc_dota_hero_sonic",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_sasake",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_batrider",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_luna",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_dragon_knight",
        //"npc_dota_hero_clinkz",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_warlock",
        "npc_dota_hero_rat",
        "npc_dota_hero_sniper",
        "npc_dota_hero_thomas_bebra",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_troll_warlord",
    ]

    let intellect_heroes = 
    [
        "npc_dota_hero_jull",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_morphling",
        "npc_dota_hero_enigma",
        "npc_dota_hero_oracle",
        "npc_dota_hero_shredder",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_lina",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_pump",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_freddy",
        "npc_dota_hero_travoman",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_silencer",
        "npc_dota_hero_overlord",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_puck",
        "npc_dota_hero_invoker",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_zuus",
        "npc_dota_hero_visage",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_rubick",
        "npc_dota_hero_techies",
        "npc_dota_hero_leshrac",
    ]
    
    var hero_list = CustomNetTables.GetTableValue("birzha_pick", "hero_list");
    if (hero_list)
    {
        if (hero_list.str !== null)
        {
            if( $("#PanelSelector").FindChild("StrengthSelector") ) return;


            var AttributePanelSTR = $.CreatePanel("Panel", $("#PanelSelector"), "AttributePanel" );
            AttributePanelSTR.style.borderBrush = "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( red ), to( #fff0 ) )"
            var AttributePanelStyleSTR = $.CreatePanel("Panel", AttributePanelSTR, "AttributePanelStyle" );
            var AttributePanelIconSTR = $.CreatePanel("Panel", AttributePanelStyleSTR, "AttributePanelIcon" );
            AttributePanelIconSTR.AddClass("StrIcon")
            var AttributePanelLabelSTR = $.CreatePanel("Label", AttributePanelStyleSTR, "AttributePanelLabel" );
            AttributePanelLabelSTR.text = $.Localize("#DOTA_Hero_Selection_STR")
            var str_row = $.CreatePanel("Panel", $("#PanelSelector"), "StrengthSelector" );

            for (var i = 0; i < strength_heroes.length; i++) 
            {
                var hero_creating = $("#StrengthSelector").FindChild(strength_heroes[i])
                if (hero_creating) { return };
                var panel = $.CreatePanel("Panel", $("#StrengthSelector"), strength_heroes[i] );
                panel.AddClass("hero_select_panel");
                SetPSelectEvent(panel, strength_heroes[i]);
                var icon = $.CreatePanel("Panel", panel, "image");
                icon.AddClass("hero_select_panel_img");
                icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + strength_heroes[i] + '.png")';
                icon.style.backgroundSize = 'contain';

                for (var d = 1; d <= Object.keys(hero_list.bp_heroes).length; d++)  {
                    if (hero_list.bp_heroes[d] == strength_heroes[i]) {
                        var DonateIcon = $.CreatePanel("Panel", panel, "DonateIcon");
                        if (panel.GetChild(0))
                        {
                            panel.GetChild(0).style.border = "1px solid gold"
                        }
                    }
                }
                if (player_info)
                {
                    let hero_information = GetHeroInformation(player_info, strength_heroes[i])
                    if (hero_information == "No") 
                    {

                    } else {
                        if (GetHeroLevel(hero_information.experience) > 0)
                        {
                            var RankInfoHero = $.CreatePanel("Panel", panel, "");
                            if (RankInfoHero)
                            {
                                RankInfoHero.AddClass("RankInfoHero")
                                var RankIcon = $.CreatePanel("Panel", RankInfoHero, "");
                                if (RankIcon)
                                {
                                    RankIcon.AddClass("RankIcon")
                                    RankIcon.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero_information.experience)) + '.png")';
                                    RankIcon.style.backgroundSize = "100%"
                                }
                                var RankLevel = $.CreatePanel("Label", RankInfoHero, "");
                                if (RankLevel)
                                {
                                    RankLevel.AddClass("RankLevel")
                                    RankLevel.text = GetHeroLevel(hero_information.experience) 
                                }
                            }
                        }         
                    }
                }
            }
        }

        if (hero_list.ag !== null)
        {
            if( $("#PanelSelector").FindChild("AgilitySelector") ) return;

            var AttributePanelAGI = $.CreatePanel("Panel", $("#PanelSelector"), "AttributePanel" );
            AttributePanelAGI.style.borderBrush = "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08cc0f ), to( #fff0 ) )"
            var AttributePanelStyleAGI = $.CreatePanel("Panel", AttributePanelAGI, "AttributePanelStyle" );
            var AttributePanelIconAGI = $.CreatePanel("Panel", AttributePanelStyleAGI, "AttributePanelIcon" );
            AttributePanelIconAGI.AddClass("AgiIcon")
            var AttributePanelLabelAGI = $.CreatePanel("Label", AttributePanelStyleAGI, "AttributePanelLabel" );
            AttributePanelLabelAGI.text = $.Localize("#DOTA_Hero_Selection_AGI")
            var agi_row = $.CreatePanel("Panel", $("#PanelSelector"), "AgilitySelector" );


            for (var i = 0; i < agility_heroes.length; i++) 
            {
                var hero_creating = $("#AgilitySelector").FindChild(agility_heroes[i])
                if (hero_creating) { return };
                var panel = $.CreatePanel("Panel", $("#AgilitySelector"), agility_heroes[i] );
                panel.AddClass("hero_select_panel");
                SetPSelectEvent(panel, agility_heroes[i]);
                var icon = $.CreatePanel("Panel", panel, "image");
                icon.AddClass("hero_select_panel_img");
                icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + agility_heroes[i] + '.png")';
                icon.style.backgroundSize = 'contain';

                for (var d = 1; d <= Object.keys(hero_list.bp_heroes).length; d++)   {
                    if (hero_list.bp_heroes[d] == agility_heroes[i]) {
                        var DonateIcon = $.CreatePanel("Panel", panel, "DonateIcon");
                        if (panel.GetChild(0))
                        {
                            panel.GetChild(0).style.border = "1px solid gold"
                        }
                    }
                }
                if (player_info)
                {
                    let hero_information = GetHeroInformation(player_info, agility_heroes[i])
                    if (hero_information == "No") 
                    {

                    } else {
                        if (GetHeroLevel(hero_information.experience) > 0)
                        {
                            var RankInfoHero = $.CreatePanel("Panel", panel, "");
                            if (RankInfoHero)
                            {
                                RankInfoHero.AddClass("RankInfoHero")
                                var RankIcon = $.CreatePanel("Panel", RankInfoHero, "");
                                if (RankIcon)
                                {
                                    RankIcon.AddClass("RankIcon")
                                    RankIcon.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero_information.experience)) + '.png")';
                                    RankIcon.style.backgroundSize = "100%"
                                }
                                var RankLevel = $.CreatePanel("Label", RankInfoHero, "");
                                if (RankLevel)
                                {
                                    RankLevel.AddClass("RankLevel")
                                    RankLevel.text = GetHeroLevel(hero_information.experience) 
                                }
                            }
                        }         
                    }
                }
            }
        }

        if (hero_list.int !== null)
        {
            if( $("#PanelSelector").FindChild("IntellectSelector") ) return;
            var AttributePanelINT = $.CreatePanel("Panel", $("#PanelSelector"), "AttributePanel" );
            AttributePanelINT.style.borderBrush = "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08bfcc ), to( #fff0 ) )"
            var AttributePanelStyleINT = $.CreatePanel("Panel", AttributePanelINT, "AttributePanelStyle" );
            var AttributePanelIconINT = $.CreatePanel("Panel", AttributePanelStyleINT, "AttributePanelIcon" );
            AttributePanelIconINT.AddClass("IntIcon")
            var AttributePanelLabelINT = $.CreatePanel("Label", AttributePanelStyleINT, "AttributePanelLabel" );
            AttributePanelLabelINT.text = $.Localize("#DOTA_Hero_Selection_INT")
            var int_row = $.CreatePanel("Panel", $("#PanelSelector"), "IntellectSelector" );

            for (var i = 0; i < intellect_heroes.length; i++) 
            {
                var hero_creating = $("#IntellectSelector").FindChild(intellect_heroes[i])
                if (hero_creating) { return };
                var panel = $.CreatePanel("Panel", $("#IntellectSelector"), intellect_heroes[i] );
                panel.AddClass("hero_select_panel");
                SetPSelectEvent(panel, intellect_heroes[i]);
                var icon = $.CreatePanel("Panel", panel, "image");
                icon.AddClass("hero_select_panel_img");
                icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + intellect_heroes[i] + '.png")';
                icon.style.backgroundSize = 'contain';

                for (var d = 1; d <= Object.keys(hero_list.bp_heroes).length; d++)   {
                    if (hero_list.bp_heroes[d] == intellect_heroes[i]) {
                        var DonateIcon = $.CreatePanel("Panel", panel, "DonateIcon");
                        if (panel.GetChild(0))
                        {
                            panel.GetChild(0).style.border = "1px solid gold"
                        }
                    }
                }
                if (player_info)
                {
                    let hero_information = GetHeroInformation(player_info, intellect_heroes[i])
                    if (hero_information == "No") 
                    {

                    } else {
                        if (GetHeroLevel(hero_information.experience) > 0)
                        {
                            var RankInfoHero = $.CreatePanel("Panel", panel, "");
                            if (RankInfoHero)
                            {
                                RankInfoHero.AddClass("RankInfoHero")
                                var RankIcon = $.CreatePanel("Panel", RankInfoHero, "");
                                if (RankIcon)
                                {
                                    RankIcon.AddClass("RankIcon")
                                    RankIcon.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero_information.experience)) + '.png")';
                                    RankIcon.style.backgroundSize = "100%"
                                }
                                var RankLevel = $.CreatePanel("Label", RankInfoHero, "");
                                if (RankLevel)
                                {
                                    RankLevel.AddClass("RankLevel")
                                    RankLevel.text = GetHeroLevel(hero_information.experience) 
                                }
                            }
                        }         
                    }
                }
            }
        }
        ChangeHeroInfo("npc_dota_hero_huskar");
    }
}

function SetPSelectEvent(p, n)
{
    p.SetPanelEvent("onactivate", function() 
    { 
        ChangeHeroInfo(n);
    });        
}

function ChangeHeroInfo(hero_name) 
{
    if (hero_name == selected_hero) { return }

    selected_hero = hero_name

    $('#HeroModel').style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + hero_name + '.png")';
    $('#HeroModel').style.backgroundSize = "100%"

    $("#hero_name_info").text = $.Localize("#" + hero_name);  

    var abilities = GetHeroAbility(hero_name);

    $("#HeroDifficulty").html = true
    $("#HeroRole").html = true
    $('#HeroAviableInBPPlus').html = true
    $("#HeroDifficulty").text = $.Localize("#Pick_HeroDifficulty") + ": " + $.Localize("#" + abilities.difficulty)
    $("#HeroRole").text = $.Localize("#Pick_HeroRole") + ": " + $.Localize("#" +abilities.role_hero)

    let bp_hero = false

    SetShowText($("#HeroAviableInBPPlus"), $.Localize("#HeroAviableInBPPlus_description"))
    SetShowText($("#HeroRole"), $.Localize("#" + abilities.role_hero + "_description"))

    $('#BirzaAbilitiesInfo').RemoveAndDeleteChildren(); 
    $('#BirzaAbilitiesInfoBonus').RemoveAndDeleteChildren(); 
    var ab = 0;

    $('#BirzaAbilitiesPanelBonus').style.visibility = "collapse"
    $('#BirzaAbilitiesInfoBonus').style.visibility = "collapse"

    $('#HeroAviableInBPPlus').style.visibility = "collapse"
    
    var hero_list = CustomNetTables.GetTableValue("birzha_pick", "hero_list");
    if (hero_list) {
        for (var d = 1; d <= Object.keys(hero_list.bp_heroes).length; d++)   {
            if (hero_list.bp_heroes[d] == hero_name) {
                $('#HeroAviableInBPPlus').style.visibility = "visible"
                bp_hero = true
            }
        }        
    }

    while(true)
    {
        ab++;     
        if (!abilities.active_table[ab]) {break;}
        var ability_panel = $.CreatePanel('DOTAAbilityImage', $('#BirzaAbilitiesInfo'), 'ability_' + ab);
        ability_panel.abilityname = abilities.active_table[ab];
        ability_panel.AddClass('HeroInfoAbilty');
        SetShowAbDesc(ability_panel, abilities.active_table[ab]);
    }

    var bonus_ab = 0;

    while(true)
    {
        bonus_ab++;     
        if (!abilities.hidden_table[bonus_ab]) {break;}
        var ability_panel = $.CreatePanel('DOTAAbilityImage', $('#BirzaAbilitiesInfoBonus'), 'ability_' + bonus_ab);
        ability_panel.abilityname = abilities.hidden_table[bonus_ab];
        ability_panel.AddClass('HeroInfoAbiltyBonus');
        SetShowAbDesc(ability_panel, abilities.hidden_table[bonus_ab]);
        $('#BirzaAbilitiesPanelBonus').style.visibility = "visible"
        $('#BirzaAbilitiesInfoBonus').style.visibility = "visible"
    }

    $("#PickButton").SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "birzha_pick_select_hero", {hero : hero_name,} );    
        Game.EmitSound("General.ButtonClick");

        var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");

        if (bp_hero)
        {
            var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
            if (p_info.bp_days <= 0) 
            {
                if (game_state_name && game_state_name.pickstate_name == "start")
                {
                    GameUI.CustomUIConfig().OpenBirzhaPlus()
                }
            }
        }
    });

    $("#BirzhaRandomButton").SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "birzha_pick_select_hero", {hero : hero_name, random : true,} );    
        Game.EmitSound("General.ButtonClick");
    });
}

function SetShowAbDesc(panel, ability)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function GetHeroAbility(hn) 
{
    var ab = CustomNetTables.GetTableValue("birzha_pick", hn);
    if (ab)
    {
        return ab;
    } 
    return [];
}

function TimerUpd( kv )
{
    var timer_panel = $('#PickTimer');

    if ( timer_panel )
    {
        timer_panel.text = kv.timer;
    }
    
    $('#PickAverageRating').text = $.Localize("#Pick_AverageRating") + GetAverageRating()
}

function BanStart()
{
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_BAN");
}

function StartSelection( kv )
{
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_SELECT");

    $("#birzhapickbutton").text = $.Localize("#birzhapickhero");

    if (start_voice) 
    {
        start_voice = false
        Game.EmitSound("announcer_dlc_rick_and_morty_choose_your_hero_02");
    }

    if ($("#moreban_aviablefordonaters")) 
    {
        $("#moreban_aviablefordonaters").style.visibility = "collapse";
    }
}

function StartPreEnd( kv )
{
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_PRE_END");
    $("#PickButton").style.visibility = "collapse";
    $("#RandomButtonWithUnlock").style.visibility = "collapse";
    $("#BirzhaRandomButton").style.visibility = "collapse";
    let repick_hero_panel = $.GetContextPanel().FindChildTraverse("repick_hero")
    if (repick_hero_panel) 
    {
        repick_hero_panel.style.visibility = "collapse"
    }
}

function BanHeroes( kv )
{
    var child = $("#" + kv.hero);

    if (child) 
    {
        child.AddClass('Banned');
        var child_img = child.FindChild("image")
        if (child_img) 
        {
            var ban = $.CreatePanel("Panel", child_img, "ban");
            ban.style.width = "100%";
            ban.style.height = "100%";

            if (kv.hero == "npc_dota_hero_kunkka") 
            {
                ban.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/prison.png")';
            } else {
                ban.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/ban.png")';
            }

            ban.style.backgroundSize = "contain";
        } 
    }
}

function HeroSelected(kv)
{    
    var child = $("#" + kv.hero);
    if (child) 
    {
        child.AddClass('Picked');
        var child_img = child.FindChild("image")
        if (child_img) 
        {
            var ban = $.CreatePanel("Panel", child_img, "selected");
            ban.style.width = "100%";
            ban.style.height = "100%";
            ban.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/selected.png")';
            ban.style.backgroundSize = "contain";
        }
    }
}

function HeroesIsPicked(kv) 
{
    $("#RandomButtonWithUnlock").style.visibility = "collapse";
    $("#PickButton").style.visibility = "collapse";
    $("#BirzhaRandomButton").style.visibility = "collapse";
    $("#GeneralPickPanel").style.visibility = "collapse";
    $("#hero_selection_your_hero").style.visibility = "visible";

    let hero_info_model = $("#HeroPickedContainer").FindChildTraverse("hero_model")
    let hero_info_abilities = $("#HeroPickedContainer").FindChildTraverse("BirzaAbilitiesPanel")
    let hero_info_abilities_panel = $("#HeroPickedContainer").FindChildTraverse("abilities_picked")
    let repick_hero = $("#HeroPickedContainer").FindChildTraverse("repick_hero")

    if (hero_info_model)
    {
        hero_info_model.DeleteAsync(0.01)
    }

    if (hero_info_abilities)
    {
        hero_info_abilities.DeleteAsync(0.01)
    }

    if (hero_info_abilities_panel)
    {
        hero_info_abilities_panel.DeleteAsync(0.01)
    }

    if (repick_hero)
    {
        repick_hero.DeleteAsync(0.01)
    }
    
    if (!heroes[kv.hero])
    {
        $.CreatePanelWithProperties("DOTAScenePanel", $("#HeroPickedContainer"), "hero_model", { style: "width:600px;height:600px;", drawbackground: "0", unit:kv.hero, particleonly:"false", renderdeferred:"false", antialias:"true", renderwaterreflections:"true" });
    } else {
        $.CreatePanelWithProperties("DOTAScenePanel", $("#HeroPickedContainer"), "hero_model", { style: "width:600px;height:600px;", map: "heroes", light:"global_light", particleonly:"false", camera:kv.hero, renderdeferred:"false", antialias:"true", renderwaterreflections:"true" });
    }

    var abilities_picked_panel = $.CreatePanel("Panel", $("#HeroPickedContainer"), "BirzaAbilitiesPanel");
    abilities_picked_panel.AddClass("BirzaAbilitiesPanel")
    var abilities_picked_label = $.CreatePanel("Label", abilities_picked_panel, "BirzaAbilitiesLabel");
    abilities_picked_label.AddClass("BirzaAbilitiesLabel")
    abilities_picked_label.text = $.Localize("#Pick_abilities")

    var abilities_picked = $.CreatePanel("Panel", $("#HeroPickedContainer"), "abilities_picked");

    var abilities = GetHeroAbility(kv.hero);

    var abilities_pick = 0;
    while(true)
    {
        abilities_pick++;     
        if (!abilities.active_table[abilities_pick]) {break;}
        var ability_panel = $.CreatePanel('DOTAAbilityImage', abilities_picked, 'ability_' + abilities_pick);
        ability_panel.abilityname = abilities.active_table[abilities_pick];
        ability_panel.AddClass('HeroInfoAbilty');
        SetShowAbDesc(ability_panel, abilities.active_table[abilities_pick]);
    }

    if (kv.is_random_hero == 1)
    {
        var repick_hero_panel = $.CreatePanel("Panel", $("#HeroPickedContainer"), "repick_hero");
        repick_hero_panel.AddClass("repick_hero_panel")
        var repick_hero_panel_label = $.CreatePanel("Label", repick_hero_panel, "");
        repick_hero_panel_label.AddClass("repick_hero_panel_label")
        repick_hero_panel_label.text = $.Localize("#repick_hero_panel_label")
        repick_hero_panel.SetPanelEvent("onactivate", function() 
        {
            GameEvents.SendCustomGameEventToServer( "birzha_pick_rerandom", {} );    
            Game.EmitSound("General.ButtonClick");
            repick_hero_panel.SetPanelEvent("onactivate", function() {});
            repick_hero_panel.style.visibility = "collapse"
        });
    } 

    $("#HeroPickedName").text = $.Localize("#" + kv.hero);
    $("#HeroInfoCont").style.width = "600px"; 
    GeneratePreGameDonate(); 
}

function BacktoHeroes() 
{
    $("#GeneralPickPanel").style.visibility = "visible";
    $("#hero_selection_your_hero").style.visibility = "collapse";
}

function BacktoHero() 
{
    $("#GeneralPickPanel").style.visibility = "collapse";
    $("#hero_selection_your_hero").style.visibility = "visible";
}

function Moreban() 
{
    var moreban_aviablefordonaters = $.CreatePanel('Label', $("#RandomButtonWithUnlock"), 'moreban_aviablefordonaters');
    moreban_aviablefordonaters.AddClass('aviablefordonate');
    moreban_aviablefordonaters.html = true
    moreban_aviablefordonaters.text = $.Localize("#moreban_aviablefordonaters")
}

function CreateTokenPanel()
{
    var player = Players.GetLocalPlayer();
    var p_info = CustomNetTables.GetTableValue('birzhainfo', String(player));
   
    var event = function()
    {
        var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
        if (p_info)
        {
            if ( getTokens() - p_info.token_used == 0 ) {return;}
            GameEvents.SendCustomGameEventToServer('birzha_token_set', {});
            if ($("#token_label"))
            {
                $("#token_label").text = String(( getTokens()   - p_info.token_used - 1) );
            }
            Game.EmitSound("ui_hero_transition");
            if ($("#token_panel"))
            {
                $("#token_panel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #373d45 ), to( #4d5860 ) )";
            }
        }
    }

    if (!p_info)
    {
        $.Schedule(1, CreateTokenPanel)
        return;
    }

    if (p_info.bp_days <= 0) 
    {
        if ($("#token_panel"))
        {
            $("#token_panel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #373d45 ), to( #4d5860 ) )";
        }
    }

    if ($("#TokenInfo"))
    {
        SetShowText($("#TokenInfo"), $.Localize("#Token_Info_Descr"))
    } 

    if (double_rating) 
    {
        if ($("#token_label"))
        {
            $("#token_label").text = String(( getTokens() - p_info.token_used) );
        }
        if (p_info.bp_days > 0) 
        {
            double_rating = false
            if ($("#token_panel"))
            {
                $("#token_panel").SetPanelEvent('onactivate', event);  
            }
        } 
    }
}

function getTokens()     
{
    return 10;
}

GameEvents.Subscribe('birzha_token_change', ChangeToken );

function ChangeToken()
{        
    var player = Players.GetLocalPlayer();
    var p_info = CustomNetTables.GetTableValue('birzhainfo', String(player));
    var token_panel = $.GetContextPanel().FindChild('token_panel');
    if (token_panel && p_info )
    {
        var token_label = token_panel.FindChild('token_label');
        token_label.text = String(( getTokens() - p_info.token_used - 1) );
    }
}
 
function BirzhaShowFiltList(kv) 
{   
    for (var i = 1; i <= kv.banned_length; i++) {
        var panel = $("#" + kv.banned[i]);
        if (panel)
        {
            panel.AddClass('Banned');
            var panel_img = panel.FindChild("image");
            if (panel_img) {
                var ban = panel_img.FindChild("ban");
                if (ban)
                {
                    ban.style.visibility = "visible";
                } else {
                    var ban = $.CreatePanel("Panel", panel_img, "ban");
                    ban.style.width = "100%";
                    ban.style.height = "100%";
                    ban.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/ban.png")';
                    ban.style.backgroundSize = "contain";
                }
            }         
        }
    } 
    for (var i = 1; i <= kv.picked_length; i++) {
        var panel = $("#" + kv.picked[i]);
        if (panel)
        {
            panel.AddClass('Picked');
            var panel_img = panel.FindChild("image");
            if (panel_img) {
                var picked = panel_img.FindChild("picked");
                if (picked)
                {
                    picked.style.visibility = "visible";
                } else {
                    var picked = $.CreatePanel("Panel", panel_img, "picked");
                    picked.style.width = "100%";
                    picked.style.height = "100%";
                    picked.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/selected.png")';
                    picked.style.backgroundSize = "contain";
                }
            }                    
        }
    }  
}

function GeneratePreGameDonate()
{
    var player = CustomNetTables.GetTableValue("birzhainfo", Players.GetLocalPlayer())

    if (player) {
        if (!($("#HeroDonateBlockEffects").FindChild("vip_panel"))) {
            $.CreatePanelWithProperties("RadioButton", $("#HeroDonateBlockEffects"), "vip_panel", { group: "effects"});
            $.CreatePanelWithProperties("DOTAScenePanel", $("#vip_panel"), "vip", {  camera:"effect_vip", rotateonhover: "false", map: "heroes", light:"global_light", particleonly:"false" });
        }

        if (!($("#HeroDonateBlockEffects").FindChild("premium_panel"))) {    
            $.CreatePanelWithProperties("RadioButton", $("#HeroDonateBlockEffects"), "premium_panel", { group: "effects"});
            $.CreatePanelWithProperties("DOTAScenePanel", $("#premium_panel"), "premium", {  camera:"effect_premium", rotateonhover: "false", map: "heroes", light:"global_light", particleonly:"false" });
        }

        if (!($("#HeroDonateBlockEffects").FindChild("gob_panel"))) {
            $.CreatePanelWithProperties("RadioButton", $("#HeroDonateBlockEffects"), "gob_panel", { group: "effects"});     
            $.CreatePanelWithProperties("DOTAScenePanel", $("#gob_panel"), "gob", {  camera:"effect_gob", rotateonhover: "false", map: "heroes", light:"global_light", particleonly:"false" });
        }

        if (!($("#HeroDonateBlockEffects").FindChild("dragonball_panel"))) {    
            $.CreatePanelWithProperties("RadioButton", $("#HeroDonateBlockEffects"), "dragonball_panel", { group: "effects"});
            $.CreatePanelWithProperties("DOTAScenePanel", $("#dragonball_panel"), "dragonball", {  camera:"effect_dragon", rotateonhover: "false", map: "heroes", light:"global_light", particleonly:"false" });
        }

        if (!($("#HeroDonateBlockEffects").FindChild("leader_panel"))) {  
            $.CreatePanelWithProperties("RadioButton", $("#HeroDonateBlockEffects"), "leader_panel", { group: "effects"});
            $.CreatePanelWithProperties("DOTAScenePanel", $("#leader_panel"), "leader", {  camera:"effect_top", rotateonhover: "false", map: "heroes", light:"global_light", particleonly:"false" });
        }

        SetShowText($("#HeroDonateBlockEffects").FindChild("vip_panel"), "#vip_effect_description")
        SetShowText($("#HeroDonateBlockEffects").FindChild("premium_panel"), "#premium_effect_description")
        SetShowText($("#HeroDonateBlockEffects").FindChild("gob_panel"), "#gob_effect_description")
        SetShowText($("#HeroDonateBlockEffects").FindChild("dragonball_panel"), "#dragonball_effect_description")
        SetShowText($("#HeroDonateBlockEffects").FindChild("leader_panel"), "#leader_effect_description")
    
       if (player["vip"]==1) {
           SetEffectPanelEvent($("#vip_panel"), "vip");
           $("#vip_panel").AddClass("EffectUnLocked")
           $("#vip_panel").AddClass("EffectInfoGeneralAnimation");
       } else {
           $("#vip_panel").AddClass("EffectLocked")
       }

       if (player["premium"]==1) {
           SetEffectPanelEvent($("#premium_panel"), "premium");
           $("#premium_panel").AddClass("EffectUnLocked")
           $("#premium_panel").AddClass("EffectInfoGeneralAnimation");
       } else {
           $("#premium_panel").AddClass("EffectLocked")
       }  

       if (player["gob"]==1) {
           SetEffectPanelEvent($("#gob_panel"), "gob");
           $("#gob_panel").AddClass("EffectUnLocked")
           $("#gob_panel").AddClass("EffectInfoGeneralAnimation");
       } else {
           $("#gob_panel").DeleteAsync( 0.1 );
       }  

       if (player["dragonball"]==1) {
           SetEffectPanelEvent($("#dragonball_panel"), "dragonball");
           $("#dragonball_panel").AddClass("EffectInfoGeneralAnimation");
           $("#dragonball_panel").AddClass("EffectUnLocked")
       } else {
           $("#dragonball_panel").DeleteAsync( 0.1 );
       }  

       if (player["leader"]==1) {
           SetEffectPanelEvent($("#leader_panel"), "leader");
           $("#leader_panel").AddClass("EffectUnLocked")
           $("#leader_panel").AddClass("EffectInfoGeneralAnimation");
       } else {
           $("#leader_panel").AddClass("EffectLocked")
       }
    }   
}

function SetPetPanelEvent(panel, i, effect)
{
    panel.SetPanelEvent("onactivate", function()
    {        
        GameEvents.SendCustomGameEventToServer( "change_pet", {model : i, effect : effect} ); Game.EmitSound("General.ButtonClick");
    })
    
} 

function SetEffectPanelEvent(panel, effect)
{
    panel.SetPanelEvent("onactivate", function()
    {        
        GameEvents.SendCustomGameEventToServer( "change_effect", {effect : effect} ); Game.EmitSound("General.ButtonClick");
    })
} 










function ban_count_changed(data) {
    var ban_count = data.count
    $("#birzhapickbutton").text = $.Localize("#birzhabanhero") + " " + "(" + data.count + ")";
}





function SetShowText(panel, text)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });       
}



function GetAverageRating() {

    let average_rating = 0
    let current_players = 0

    for ( var teamId of Game.GetAllTeamIDs() )
    {
        var teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
        for ( var playerId of teamPlayers )
        {
            current_players = current_players + 1

            var seasons = CustomNetTables.GetTableValue('game_state', "birzha_gameinfo");

            if (seasons) {
                let info = CustomNetTables.GetTableValue('birzhainfo', String(playerId));
                if (info && info.mmr && info.mmr[seasons.mmr_season]) {
                    average_rating = average_rating + (info.mmr[seasons.mmr_season] || 2500)
                }
            }
        }
    }

    if (average_rating > 0) {
        average_rating = average_rating / current_players
    }

    average_rating = Math.round(average_rating)

    return String(average_rating)
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

function GetHeroLevel(exp)
{
    let level = exp / 1000
    return Math.floor(level)
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

function GetHeroRankIcon(level)
{
    if (level >= 30) {
        return "rank_7"
    } else if (level >= 20) {
        return "rank_6"
    } else if (level >= 10) {
        return "rank_5"
    } else if (level >= 7) {
        return "rank_4"
    } else if (level >= 5) {
        return "rank_3"
    } else if (level >= 3) {
        return "rank_2"
    } else if (level >= 1) {
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



BirzhaPickInit();