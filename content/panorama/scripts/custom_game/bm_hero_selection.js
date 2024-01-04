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
    "npc_dota_hero_faceless_void" : true,
    "npc_dota_hero_kelthuzad" : true,
};  

var strength_heroes = 
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

var agility_heroes = 
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

var intellect_heroes = 
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
    "npc_dota_hero_kelthuzad",
]

var heroes_ids = 
{
    npc_dota_hero_antimage: 1,
    npc_dota_hero_axe: 2,
    npc_dota_hero_bane: 3,
    npc_dota_hero_bloodseeker: 4,
    npc_dota_hero_crystal_maiden: 5,
    npc_dota_hero_drow_ranger: 6,
    npc_dota_hero_earthshaker: 7,
    npc_dota_hero_juggernaut: 8,
    npc_dota_hero_mirana: 9,
    npc_dota_hero_nevermore: 11,
    npc_dota_hero_morphling: 10,
    npc_dota_hero_phantom_lancer: 12,
    npc_dota_hero_puck: 13,
    npc_dota_hero_pudge: 14,
    npc_dota_hero_razor: 15,
    npc_dota_hero_sand_king: 16,
    npc_dota_hero_storm_spirit: 17,
    npc_dota_hero_sven: 18,
    npc_dota_hero_tiny: 19,
    npc_dota_hero_vengefulspirit: 20,
    npc_dota_hero_windrunner: 21,
    npc_dota_hero_zuus: 22,
    npc_dota_hero_kunkka: 23,
    npc_dota_hero_lina: 25,
    npc_dota_hero_lich: 31,
    npc_dota_hero_lion: 26,
    npc_dota_hero_shadow_shaman: 27,
    npc_dota_hero_slardar: 28,
    npc_dota_hero_tidehunter: 29,
    npc_dota_hero_witch_doctor: 30,
    npc_dota_hero_riki: 32,
    npc_dota_hero_enigma: 33,
    npc_dota_hero_tinker: 34,
    npc_dota_hero_sniper: 35,
    npc_dota_hero_necrolyte: 36,
    npc_dota_hero_warlock: 37,
    npc_dota_hero_beastmaster: 38,
    npc_dota_hero_queenofpain: 39,
    npc_dota_hero_venomancer: 40,
    npc_dota_hero_faceless_void: 41,
    npc_dota_hero_skeleton_king: 42,
    npc_dota_hero_death_prophet: 43,
    npc_dota_hero_phantom_assassin: 44,
    npc_dota_hero_pugna: 45,
    npc_dota_hero_templar_assassin: 46,
    npc_dota_hero_viper: 47,
    npc_dota_hero_luna: 48,
    npc_dota_hero_dragon_knight: 49,
    npc_dota_hero_dazzle: 50,
    npc_dota_hero_rattletrap: 51,
    npc_dota_hero_leshrac: 52,
    npc_dota_hero_furion: 53,
    npc_dota_hero_life_stealer: 54,
    npc_dota_hero_dark_seer: 55,
    npc_dota_hero_clinkz: 56,
    npc_dota_hero_omniknight: 57,
    npc_dota_hero_enchantress: 58,
    npc_dota_hero_huskar: 59,
    npc_dota_hero_night_stalker: 60,
    npc_dota_hero_broodmother: 61,
    npc_dota_hero_bounty_hunter: 62,
    npc_dota_hero_weaver: 63,
    npc_dota_hero_jakiro: 64,
    npc_dota_hero_batrider: 65,
    npc_dota_hero_chen: 66,
    npc_dota_hero_spectre: 67,
    npc_dota_hero_doom_bringer: 69,
    npc_dota_hero_ancient_apparition: 68,
    npc_dota_hero_ursa: 70,
    npc_dota_hero_spirit_breaker: 71,
    npc_dota_hero_gyrocopter: 72,
    npc_dota_hero_alchemist: 73,
    npc_dota_hero_invoker: 74,
    npc_dota_hero_silencer: 75,
    npc_dota_hero_obsidian_destroyer: 76,
    npc_dota_hero_lycan: 77,
    npc_dota_hero_brewmaster: 78,
    npc_dota_hero_shadow_demon: 79,
    npc_dota_hero_lone_druid: 80,
    npc_dota_hero_chaos_knight: 81,
    npc_dota_hero_meepo: 82,
    npc_dota_hero_treant: 83,
    npc_dota_hero_ogre_magi: 84,
    npc_dota_hero_undying: 85,
    npc_dota_hero_rubick: 86,
    npc_dota_hero_disruptor: 87,
    npc_dota_hero_nyx_assassin: 88,
    npc_dota_hero_naga_siren: 89,
    npc_dota_hero_keeper_of_the_light: 90,
    npc_dota_hero_wisp: 91,
    npc_dota_hero_visage: 92,
    npc_dota_hero_slark: 93,
    npc_dota_hero_medusa: 94,
    npc_dota_hero_troll_warlord: 95,
    npc_dota_hero_centaur: 96,
    npc_dota_hero_magnataur: 97,
    npc_dota_hero_shredder: 98,
    npc_dota_hero_bristleback: 99,
    npc_dota_hero_tusk: 100,
    npc_dota_hero_skywrath_mage: 101,
    npc_dota_hero_abaddon: 102,
    npc_dota_hero_elder_titan: 103,
    npc_dota_hero_legion_commander: 104,
    npc_dota_hero_ember_spirit: 106,
    npc_dota_hero_earth_spirit: 107,
    npc_dota_hero_abyssal_underlord: 108,
    npc_dota_hero_terrorblade: 109,
    npc_dota_hero_phoenix: 110,
    npc_dota_hero_techies: 105,
    npc_dota_hero_oracle: 111,
    npc_dota_hero_winter_wyvern: 112,
    npc_dota_hero_arc_warden: 113,
    npc_dota_hero_monkey_king: 114,
    npc_dota_hero_dark_willow: 119,
    npc_dota_hero_pangolier: 120,
    npc_dota_hero_grimstroke: 121,
    npc_dota_hero_hoodwink: 123,
    npc_dota_hero_void_spirit: 126,
    npc_dota_hero_snapfire: 128,
    npc_dota_hero_mars: 129,
    npc_dota_hero_dawnbreaker: 135,
    npc_dota_hero_marci: 136,
    npc_dota_hero_primal_beast: 137,
    npc_dota_hero_muerta: 138,
    npc_dota_hero_saitama: 180,
    npc_dota_hero_migi: 169,
    npc_dota_hero_venom:184,
    npc_dota_hero_tailer:181,
    npc_dota_hero_nolik:179,
    npc_dota_hero_pyramide:174,
    npc_dota_hero_stone_dwayne:171,
    npc_dota_hero_serega_pirat:183,
    npc_dota_hero_sonic:175,
    npc_dota_hero_sasake:168,
    npc_dota_hero_rat:172,
    npc_dota_hero_thomas_bebra:182,
    npc_dota_hero_jull:177,
    npc_dota_hero_pump:173,
    npc_dota_hero_freddy:178,
    npc_dota_hero_travoman:176,
    npc_dota_hero_overlord:170,
    npc_dota_hero_kelthuzad:185,
}

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
    $( "#SearchHeroEntry" ).RaiseChangeEvents( true );
    $.RegisterEventHandler( 'TextEntryChanged', $( "#SearchHeroEntry" ), SearchHero );
    GameEvents.Subscribe( 'birzha_pick_load_heroes', LoadHeroes );
    GameEvents.Subscribe( 'birzha_pick_timer_upd', TimerUpd );
    GameEvents.Subscribe( 'birzha_pick_ban_start', BanStart );
    GameEvents.Subscribe( 'birzha_pick_start_selection', StartSelection );
    GameEvents.Subscribe( 'birzha_pick_preend_start', StartPreEnd );
    GameEvents.Subscribe( 'birzha_pick_end', HeroSelectionEnd );
    GameEvents.Subscribe( 'hero_is_picked', HeroesIsPicked );
    GameEvents.Subscribe( 'ban_count_changed', ban_count_changed );
}

function CloseSearch()
{
    $("#SearchHeroEntry").text = ""
    $("#SearchLupa").style.opacity = "1"
    $("#CloseSearch").style.opacity = "0"
}

function SearchHero()
{
    let search_text = $("#SearchHeroEntry").text
    search_text = search_text.toLowerCase()
    if (search_text == "")
    {
        $("#SearchLupa").style.opacity = "1"
        $("#CloseSearch").style.opacity = "0"
    }
    else
    {
        $("#SearchLupa").style.opacity = "0"
        $("#CloseSearch").style.opacity = "1"
    }

    for (let i = 1; i <= 3; i++)
    {
        let main_panel = $("#panel_with_heroes_" + i)
        if (main_panel)
        {
            for (let d = 0; d < main_panel.GetChildCount(); d++) 
            {
                let item_panel = main_panel.GetChild(d)
                if (item_panel)
                {
                    let panel_name = item_panel.id
                    let check_localize = $.Localize("#" + panel_name).toLowerCase()
                    if ( (panel_name.indexOf(search_text) == -1 && check_localize.indexOf(search_text) == -1) && search_text.text != "")
                    {
                        item_panel.SetHasClass("search_close", true)
                    }
                    else
                    {
                        item_panel.SetHasClass("search_close", false)
                    }
                }  
            }
        }
    }
}

function BirzhaHeroSelectionLoad()
{
    if (IsSpectator())
    {
        $.GetContextPanel().AddClass('Deletion');
        $.GetContextPanel().style.opacity = "0"
        return
    }
    $.GetContextPanel().SetFocus();
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
            return
        } 
    }

    LoadHeroes()
}

function LoadHeroes()
{
    $("#HeroInfoCont").style.opacity = "1"
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    $("#AllHeroesList").RemoveAndDeleteChildren()
    var subscribe_heroes = CustomNetTables.GetTableValue("birzha_pick", "subscribe_heroes");

    let StrengthSelector = CreateHeroesRow("#DOTA_Hero_Selection_STR", "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( red ), to( #fff0 ) )", "StrIcon", 1)
    for (var i = 0; i < strength_heroes.length; i++) 
    {
        CreateHeroesCard(strength_heroes[i], StrengthSelector, subscribe_heroes, player_info)
    }
    let AgilitySelector = CreateHeroesRow("#DOTA_Hero_Selection_AGI", "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08cc0f ), to( #fff0 ) )", "AgiIcon", 2)
    for (var i = 0; i < agility_heroes.length; i++) 
    {
        CreateHeroesCard(agility_heroes[i], AgilitySelector, subscribe_heroes, player_info)
    }
    let IntellectSelector = CreateHeroesRow("#DOTA_Hero_Selection_INT", "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08bfcc ), to( #fff0 ) )", "IntIcon", 3)
    for (var i = 0; i < intellect_heroes.length; i++) 
    {
        CreateHeroesCard(intellect_heroes[i], IntellectSelector, subscribe_heroes, player_info)
    }
    ChangeHeroInfo("npc_dota_hero_huskar");
    UpdateLockedHeroes()
}

function CreateHeroesRow(label, color, icon_style, num)
{
    let AttributePanel = $.CreatePanel("Panel", $("#AllHeroesList"), "" );
    AttributePanel.AddClass("AttributePanel")
    AttributePanel.style.borderBrush = color
    let AttributeInfo = $.CreatePanel("Panel", AttributePanel, "" );
    AttributeInfo.AddClass("AttributePanelStyle")
    let AttributePanelIcon = $.CreatePanel("Panel", AttributeInfo, "" );
    AttributePanelIcon.AddClass("AttributePanelIcon")
    AttributePanelIcon.AddClass(icon_style)
    let AttributePanelLabel = $.CreatePanel("Label", AttributeInfo, "" );
    AttributePanelLabel.AddClass("AttributePanelLabel")
    AttributePanelLabel.text = $.Localize(label)
    let row = $.CreatePanel("Panel", $("#AllHeroesList"), "panel_with_heroes_"+num );
    row.AddClass("panel_with_heroes")
    return row
}

function CreateHeroesCard(hero_name, main, subscribe_heroes, player_info)
{
    var panel = $.CreatePanel("Panel", main, hero_name );
    panel.AddClass("hero_select_panel");
    SetPSelectEvent(panel, hero_name);

    var icon = $.CreatePanel("Panel", panel, "image");
    icon.AddClass("hero_select_panel_img");
    icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + hero_name + '.png")';
    icon.style.backgroundSize = '100%';

    for (var d = 1; d <= Object.keys(subscribe_heroes.bp_heroes).length; d++)  
    {
        if (subscribe_heroes.bp_heroes[d] == hero_name) 
        { 
            $.CreatePanel("Panel", panel, "DonateIcon");
            icon.style.border = "1px solid gold"
        }
    }

    if (player_info)
    {
        let hero_information = GetHeroInformation(player_info, hero_name)
        if (hero_information != "No") 
        {
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

    var ban_panel = $.CreatePanel("Panel", icon, "ban_panel");
    ban_panel.AddClass("ban_panel")
    if (hero_name == "npc_dota_hero_kunkka") 
    {
        ban_panel.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/prison.png")';
    } else {
        ban_panel.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/ban.png")';
    }
    ban_panel.style.backgroundSize = "100%";

    var pick_panel = $.CreatePanel("Panel", icon, "pick_panel");
    pick_panel.AddClass("pick_panel")
    pick_panel.style.backgroundImage = 'url("file://{images}/custom_game/custom_pick/selected.png")';
    pick_panel.style.backgroundSize = "100%";
}

function BanStart()
{
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_BAN");
    $("#BannedButtonsPick").style.visibility = "visible"
    $("#RandomButtonWithUnlock").style.visibility = "collapse"
}

function ban_count_changed(data) 
{
    var ban_count = data.count
    $("#BanCountChangeLabel").text = ban_count;
}

function StartSelection()
{
    var subscribe_heroes = CustomNetTables.GetTableValue("birzha_pick", "subscribe_heroes");
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_SELECT");
    $("#BannedButtonsPick").style.visibility = "collapse"
    $("#RandomButtonWithUnlock").style.visibility = "visible"
    if (selected_hero)
    {
        var bp_hero = false
        for (var d = 1; d <= Object.keys(subscribe_heroes.bp_heroes).length; d++)   
        {
            if (subscribe_heroes.bp_heroes[d] == selected_hero) 
            {
                bp_hero = true
                break
            }
        }
        if (bp_hero)
        {
            var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
            if (p_info && p_info.bp_days <= 0) 
            {
                var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");
                if (game_state_name && game_state_name.pickstate_name == "start")
                {
                    $('#BPHeroBlock').style.visibility = "visible"
                    $('#birzhapickbutton').style.visibility = "collapse"
                }
            }
        }
    }
    if (start_voice) 
    {
        start_voice = false
        Game.EmitSound("announcer_dlc_rick_and_morty_choose_your_hero_02");
    }
}

function StartPreEnd( kv )
{
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_PRE_END");
    $("#BannedButtonsPick").style.visibility = "collapse"
    $("#RandomButtonWithUnlock").style.visibility = "collapse"
    let repick_hero_panel = $.GetContextPanel().FindChildTraverse("repick_hero")
    if (repick_hero_panel)
    {
        repick_hero_panel.style.visibility = "collapse"
    }
}

function HeroSelectionEnd()
{
    $.GetContextPanel().AddClass('Deletion');
    RestoreButtonsAndChat();
    $.Schedule(1.5, function() 
    {
        if ($("#MovieBackground"))
        {
            $("#MovieBackground").DeleteAsync(1.5)
        }
        if ($("#pick_timer_particle"))
        {
            $("#pick_timer_particle").DeleteAsync(1.5)
        }
        if ($("#MovieBackground2"))
        {
            $("#MovieBackground2").DeleteAsync(1.5)
        }
        if ($("#MovieBackground2"))
        {
            $("#MovieBackground2").DeleteAsync(1.5)
        }
        $.GetContextPanel().style.opacity = "0"
    })
    var ButtonsPanelBackground = dotahud.FindChildTraverse("MenuButtons").FindChildTraverse("ButtonsPanelBackground");
    if (ButtonsPanelBackground)
    {
        ButtonsPanelBackground.style.visibility = "visible"
    }
}

function ChangeHeroInfo(hero_name) 
{
    if (hero_name == selected_hero) {return}
    selected_hero = hero_name
    var abilities = GetHeroAbility(hero_name);
    $('#HeroModel').style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + hero_name + '.png")';
    $('#HeroModel').style.backgroundSize = "100%"
    $("#hero_name_info").text = $.Localize("#" + hero_name);  
    $("#HeroDifficulty").text = $.Localize("#Pick_HeroDifficulty") + ": " + $.Localize("#" + abilities.difficulty)
    $("#HeroRole").text = $.Localize("#Pick_HeroRole") + ": " + $.Localize("#" +abilities.role_hero)
    $('#BirzaAbilitiesInfo').RemoveAndDeleteChildren(); 
    $('#BirzaAbilitiesInfoBonus').RemoveAndDeleteChildren(); 
    $('#BirzaAbilitiesPanelBonus').style.visibility = "collapse"
    $('#BirzaAbilitiesInfoBonus').style.visibility = "collapse"
    $('#BPHeroBlock').style.visibility = "collapse"
    $('#birzhapickbutton').style.visibility = "visible"
    SetShowText($("#BanCountPanel"), $.Localize("#ban_count_information"))
    SetShowText($("#BPHeroBlock"), $.Localize("#HeroAviableInBPPlus_description"))
    SetShowText($("#HeroRole"), $.Localize("#" + abilities.role_hero + "_description"))
    let bp_hero = false
    let subscribe_heroes = CustomNetTables.GetTableValue("birzha_pick", "subscribe_heroes");
    for (let d = 1; d <= Object.keys(subscribe_heroes.bp_heroes).length; d++)   
    {
        if (subscribe_heroes.bp_heroes[d] == hero_name) 
        {
            bp_hero = true
        }
    }

    var ab = 0;
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

    let talent_hero_block = $.CreatePanel("Panel", $('#BirzaAbilitiesInfo'), "")
    talent_hero_block.AddClass("talent_hero_block")
    TalentOver(talent_hero_block, GetHeroID(hero_name)) 

    if (bp_hero)
    {
        var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
        if (p_info && p_info.bp_days <= 0) 
        {
            var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");
            if (game_state_name && game_state_name.pickstate_name == "start")
            {
                $('#BPHeroBlock').style.visibility = "visible"
                $('#birzhapickbutton').style.visibility = "collapse"
            }
        }
    }

    $("#PickButton").SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "birzha_pick_select_hero", {hero : hero_name} );    
        Game.EmitSound("General.ButtonClick");
        var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");
        if (bp_hero)
        {
            var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
            if (p_info && p_info.bp_days <= 0) 
            {
                if (game_state_name && game_state_name.pickstate_name == "start")
                {
                    GameUI.CustomUIConfig().OpenBirzhaPlus()
                }
            }
        }
    });

    $("#ButtonBanHeroNew").SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "birzha_pick_select_hero", {hero : hero_name} );    
        Game.EmitSound("General.ButtonClick");
        var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");
        if (bp_hero)
        {
            var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
            if (p_info && p_info.bp_days <= 0) 
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

function HeroesIsPicked(kv) 
{
    $("#BannedButtonsPick").style.visibility = "collapse"
    $("#RandomButtonWithUnlock").style.visibility = "collapse"
    $("#BacktoHero").style.opacity = "1"
    $("#GeneralPickPanel").AddClass("close_general_pick");
    $("#hero_selection_your_hero").RemoveClass("close_your_hero");
    $("#SearchHero").style.visibility = "collapse"
    $("#HeroPickedContainer").RemoveAndDeleteChildren()
    InitTokens();
    InitDonateEffects();

    if (!heroes[kv.hero])
    {
        $.CreatePanel("DOTAScenePanel", $("#HeroPickedContainer"), "hero_model", { class:"hero_preview_panel", fov: "1", unit:kv.hero, light:"hero_light", renderdeferred:"true", antialias:"false", particleonly:"false", hittest:"false", renderwaterreflections:"true", drawbackground: "0" });
    } else {
        $.CreatePanel("DOTAScenePanel", $("#HeroPickedContainer"), "hero_model", { class:"hero_preview_panel", fov: "1", unit:"scene_panel_"+kv.hero, light:"hero_light", renderdeferred:"true", antialias:"false", particleonly:"false", hittest:"false", renderwaterreflections:"true", drawbackground: "0" });
    }
 
    let HeroPickedName = $.CreatePanel("Label", $("#HeroPickedContainer"), "")
    HeroPickedName.AddClass("HeroPickedName")
    HeroPickedName.text = $.Localize("#" + kv.hero)

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

    if (kv.is_random_hero == 1 || Game.IsInToolsMode())
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
        if (Game.IsInToolsMode())
        {
            $.Schedule( 1, function()
            {
                repick_hero_panel.style.visibility = "visible"
            });
        }
    }
    
    $("#HeroInfoCont").style.width = "600px"; 
}

function BacktoHeroes() 
{
    $("#GeneralPickPanel").RemoveClass("close_general_pick");
    $("#hero_selection_your_hero").AddClass("close_your_hero");
    $("#SearchHero").style.visibility = "visible"
}

function BacktoHero() 
{
    $("#GeneralPickPanel").AddClass("close_general_pick");
    $("#hero_selection_your_hero").RemoveClass("close_your_hero");
    $("#SearchHero").style.visibility = "collapse"
}

var TOKEN_INIT = false
function InitTokens()
{
    if (TOKEN_INIT)
    {
        return
    }
    TOKEN_INIT = true
    $("#double_rating_token_counter").text = GetPlayerTokensCount()
    if (IsHasTokenAndSubscribe())
    {
        $("#button_double_rating_activate").SetPanelEvent("onactivate", function() 
        { 
            Game.EmitSound("BUTTON_CLICK_MAJOR")
            $("#button_double_rating_activate").SetPanelEvent("onactivate", function() {});
            $("#double_rating_token_counter").text = GetPlayerTokensCount() - 1
            $("#button_double_rating_activate").SetHasClass("button_double_rating_active", false)
            GameEvents.SendCustomGameEventToServer('birzha_token_set', {});
        });
    }
    else
    {
        $("#button_double_rating_activate").SetHasClass("button_double_rating_active", false)
        SetShowText($("#button_double_rating_activate"), "#double_rating_no_subs")
    }
}
function IsHasTokenAndSubscribe()
{
    var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    if (p_info)
    {
        if (p_info.bp_days > 0 && getTokens() - p_info.token_used > 0)
        {
            return true
        }
    }
    return false
}

function ChangeDonateBlock(panel, button)
{
    $("#DonateBlockPanelWithItems_2").style.visibility = "collapse"
    $("#DonateBlockPanelWithItems_3").style.visibility = "collapse"
    for (var i = 0; i < $("#HeroDonateBlockButtons").GetChildCount(); i++) 
	{
		$("#HeroDonateBlockButtons").GetChild(i).SetHasClass("HeroDonateBlockButton_selected", false)
	}
    $("#"+button).SetHasClass("HeroDonateBlockButton_selected", true)
    $("#"+panel).style.visibility = "visible"
}

// Дополнительные функции

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
        chat.style.y = '60px';
        chat.style.width = '660px';
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
        chat.style.width = '800px';
    }
}

function GetPlayerTokensCount()
{
    var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    if (p_info)
    {
        return getTokens() - p_info.token_used
    }
    return 0
}

function getTokens()     
{
    let token_max = 10
    let token_items = 
    [
        219,
        220,
        221,
        222,
        223,
        224,
        225,
        226,
        227,
        228,
    ]
    for (var i = 0; i < token_items.length; i++) 
    {
        if (HasItemInventory(token_items[i]))
        {
            token_max = token_max + 1
        }
    }
    return token_max
}

function HasItemInventory(item_id)
{
    let player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
    if (player_table && player_table.player_items)
    {
        for (var d = 1; d <= Object.keys(player_table.player_items).length; d++) 
        {
            if (player_table.player_items[d])
            {
                if (String(player_table.player_items[d]) == String(item_id))
                {
                    return true
                }
            }
        }
    }
    return false
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
   
function GetAverageRating() {

    let average_rating = 0
    let current_players = 0
    for ( let teamId of Game.GetAllTeamIDs() )
    {
        let teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
        for ( let playerId of teamPlayers )
        {
            current_players = current_players + 1
            let seasons = CustomNetTables.GetTableValue('game_state', "birzha_gameinfo");
            if (seasons) 
            {
                let info = CustomNetTables.GetTableValue('birzhainfo', String(playerId));
                if (info && info.mmr && info.mmr[seasons.season]) {
                    average_rating = average_rating + (info.mmr[seasons.season] || 2500)
                }
            }
        }
    }
    if (average_rating > 0) 
    {
        average_rating = average_rating / current_players
    }
    average_rating = Math.round(average_rating)
    return String(average_rating)
}
 
function SetShowText(panel, text)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
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

function SetPSelectEvent(p, n)
{
    p.SetPanelEvent("onactivate", function() 
    { 
        ChangeHeroInfo(n);
    });        
}

CustomNetTables.SubscribeNetTableListener( "birzha_pick", PickerUpdates );

function PickerUpdates(table, key, data ) 
{
	if (table == "birzha_pick") 
	{
		if (key == "picked_heroes") 
		{
            UpdatePickedHeroes(data)
		}
        if (key == "banned_heroes") 
		{
            UpdateBannedHeroes(data)
		}
	}
}

function UpdateLockedHeroes()
{
    let picked_heroes = CustomNetTables.GetTableValue("birzha_pick", "picked_heroes")
    let banned_heroes = CustomNetTables.GetTableValue("birzha_pick", "banned_heroes")
    if (picked_heroes)
    {
        UpdatePickedHeroes(picked_heroes)
    }
    if (banned_heroes)
    {
        UpdateBannedHeroes(banned_heroes)
    }
}

function UpdateBannedHeroes(data)
{
    for (let i = 1; i <= 3; i++)
    {
        let main_panel = $("#panel_with_heroes_" + i)
        if (main_panel)
        {
            for (let d = 0; d < main_panel.GetChildCount(); d++) 
            {
                main_panel.GetChild(d).SetHasClass("Banned", false)
            }
        }
    }
    for (var i = 1; i <= Object.keys(data).length; i++) 
    {
        let hero_name = data[i]
        var hero_panel = $("#" + hero_name);
        if (hero_panel)
        {
            hero_panel.SetHasClass("Banned", true)
        }
    }
}

function UpdatePickedHeroes(data)
{    
    for (let i = 1; i <= 3; i++)
    {
        let main_panel = $("#panel_with_heroes_" + i)
        if (main_panel)
        {
            for (let d = 0; d < main_panel.GetChildCount(); d++) 
            {
                main_panel.GetChild(d).SetHasClass("Picked", false)
            }
        }
    }
    for (var i = 1; i <= Object.keys(data).length; i++) 
    {
        let hero_name = data[i]
        var hero_panel = $("#" + hero_name);
        if (hero_panel)
        {
            hero_panel.SetHasClass("Picked", true)
        }
    }
}

function GetHeroID(heroName) 
{
    var result = heroes_ids[heroName];
    if (result == null) return -1;
    return result;
}

function TalentOver(panel, hero_id) 
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAHUDShowHeroStatBranchTooltip', panel, hero_id)
    });

    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHUDHideStatBranchTooltip', panel);
    });
}


var EFFECTS_LIST =
[
    ["vip", "effect_donater", 259, "vip"], 
    ["premium", "effect_top_donater", 257, "premium"], 
    ["gob", "effect_developer", 258, "gob"], 
    ["dragonball", "effect_unique", 260, "dragonball"], 
    ["season_12", "leader_season_12", 261, "useless"], 
    ["season_13", "leader_season_13", 262, "useless"],
    ["season_14", "leader_season_14", 263, "useless"],
]

function InitDonateEffects()
{
    $("#DonateBlockPanelWithItems_2").RemoveAndDeleteChildren()
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    for (var i = 0; i < EFFECTS_LIST.length; i++) 
    {
        CreateDonateBlock(EFFECTS_LIST[i], player_info)
    }
}

function CreateDonateBlock(table, player_info)
{
    var Recom_item = $.CreatePanel("Panel", $("#DonateBlockPanelWithItems_2"), "item_inventory_" + table[0]);
    Recom_item.AddClass("ItemInventory");
    //SetItemInventory(Recom_item, table[i])

    var ItemImage = $.CreatePanel("Panel", Recom_item, "");
    ItemImage.AddClass("ItemImage");
    ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[0] + '.png")';
    ItemImage.style.backgroundSize = "100%"

    var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
    ItemName.AddClass("ItemName");
    ItemName.text = $.Localize( "#" + table[1] )

    var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
    BuyItemPanel.AddClass("BuyItemPanel");

    var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
    ItemPrice.AddClass("ItemPrice");

    var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
    PriceLabel.AddClass("PriceLabel");
    PriceLabel.text = $.Localize( "#effect_locked" )
    BuyItemPanel.SetHasClass("item_buying", true)

    if (HasItemInventory(table[2]) || player_info[table[3]] == 1 || Game.IsInToolsMode())
    {
        BuyItemPanel.SetHasClass("item_buying", false)
        if (player_info.effect_id == table[2])
        {
            BuyItemPanel.SetHasClass("item_deactive", true)
            PriceLabel.text = $.Localize( "#shop_deactivate" )
        }
        else
        {
            BuyItemPanel.SetHasClass("item_deactive", false)
            PriceLabel.text = $.Localize( "#shop_activate" )
        }
        Recom_item.SetPanelEvent("onactivate", function() 
        { 
            SelectEffect(table[2], Recom_item)
        });
    }
}

function SelectEffect(num, panel)
{
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    let current_effect = player_info.effect_id

    if (current_effect != num)
    {
    	for (var i = 0; i < $("#DonateBlockPanelWithItems_2").GetChildCount(); i++) 
        {
            if (!$("#DonateBlockPanelWithItems_2").GetChild(i).FindChildTraverse("BuyItemPanel").BHasClass("item_buying"))
            {
                $("#DonateBlockPanelWithItems_2").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
                $("#DonateBlockPanelWithItems_2").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 
    	panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_hero_effect", {effect_id: num, delete_pet:false} );
    }
    else
    {
    	panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_hero_effect", {effect_id: num, delete_pet: true} );
    }
}

BirzhaPickInit();