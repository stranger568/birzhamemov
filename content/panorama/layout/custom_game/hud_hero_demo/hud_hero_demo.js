var demo_default_hero = "npc_dota_hero_huskar"

function Init()
{
	$.RegisterEventHandler( 'DOTAUIHeroPickerHeroSelected', $( '#SelectHeroContainer' ), SwitchToNewHero );

    var UiDefaults = CustomNetTables.GetTableValue( "game_global", "ui_defaults" );

    if( UiDefaults )
    {
		$( '#FreeSpellsButton' ).SetSelected( UiDefaults["WTFEnabled"] );
		if ( UiDefaults['Cheats_enable'] && UiDefaults['Cheats_enable'] == 1 ) {
			$( '#control' ).style.visibility = "visible"
		} else {
			$( '#control' ).style.visibility = "collapse"
		}
    }
}
Init();

CustomNetTables.SubscribeNetTableListener( "birzha_pick", UpdateHeroes );

function UpdateHeroes(table, key, data ) {
	if (table == "birzha_pick") {
		if (key == "hero_list") {
			RegisterHeroes()
		}
	}
}

function RegisterHeroes()
{
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
        "npc_dota_hero_kelthuzad",
    ]

    $("#HeroBirzhaList").RemoveAndDeleteChildren()

    var AttributePanelSTR = $.CreatePanel("Panel", $("#HeroBirzhaList"), "AttributePanel" );
    AttributePanelSTR.style.borderBrush = "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( red ), to( #fff0 ) )"
    var AttributePanelStyleSTR = $.CreatePanel("Panel", AttributePanelSTR, "AttributePanelStyle" );
    var AttributePanelIconSTR = $.CreatePanel("Panel", AttributePanelStyleSTR, "AttributePanelIcon" );
    AttributePanelIconSTR.AddClass("StrIcon")
    var AttributePanelLabelSTR = $.CreatePanel("Label", AttributePanelStyleSTR, "AttributePanelLabel" );
    AttributePanelLabelSTR.text = $.Localize("#DOTA_Hero_Selection_STR")
    var str_row = $.CreatePanel("Panel", $("#HeroBirzhaList"), "StrengthSelector" );

    for (var i = 0; i < strength_heroes.length; i++) 
    {
        var hero_creating = $("#StrengthSelector").FindChild(strength_heroes[i])
        if (hero_creating) { return };
        var panel = $.CreatePanel("Panel", $("#StrengthSelector"), strength_heroes[i] );
        panel.AddClass("hero_select_panel"); 
        var icon = $.CreatePanel("Panel", panel, "image");
        icon.AddClass("hero_select_panel_img");
        icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + strength_heroes[i] + '.png")';
        icon.style.backgroundSize = 'contain';
        SetHero(panel, strength_heroes[i]);
        panel.BLoadLayoutSnippet('HeroCard');
    }

    var AttributePanelAGI = $.CreatePanel("Panel", $("#HeroBirzhaList"), "AttributePanel" );
    AttributePanelAGI.style.borderBrush = "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08cc0f ), to( #fff0 ) )"
    var AttributePanelStyleAGI = $.CreatePanel("Panel", AttributePanelAGI, "AttributePanelStyle" );
    var AttributePanelIconAGI = $.CreatePanel("Panel", AttributePanelStyleAGI, "AttributePanelIcon" );
    AttributePanelIconAGI.AddClass("AgiIcon")
    var AttributePanelLabelAGI = $.CreatePanel("Label", AttributePanelStyleAGI, "AttributePanelLabel" );
    AttributePanelLabelAGI.text = $.Localize("#DOTA_Hero_Selection_AGI")
    var agi_row = $.CreatePanel("Panel", $("#HeroBirzhaList"), "AgilitySelector" );

    for (var i = 0; i < agility_heroes.length; i++) 
    {
        var hero_creating = $("#AgilitySelector").FindChild(agility_heroes[i])
        if (hero_creating) { return };
        var panel = $.CreatePanel("Panel", $("#AgilitySelector"), agility_heroes[i] );
        panel.AddClass("hero_select_panel");
        var icon = $.CreatePanel("Panel", panel, "image");
        icon.AddClass("hero_select_panel_img");
        icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + agility_heroes[i] + '.png")';
        icon.style.backgroundSize = 'contain';
        SetHero(panel, agility_heroes[i]);
        panel.BLoadLayoutSnippet('HeroCard');
    }

    var AttributePanelINT = $.CreatePanel("Panel", $("#HeroBirzhaList"), "AttributePanel" );
    AttributePanelINT.style.borderBrush = "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08bfcc ), to( #fff0 ) )"
    var AttributePanelStyleINT = $.CreatePanel("Panel", AttributePanelINT, "AttributePanelStyle" );
    var AttributePanelIconINT = $.CreatePanel("Panel", AttributePanelStyleINT, "AttributePanelIcon" );
    AttributePanelIconINT.AddClass("IntIcon")
    var AttributePanelLabelINT = $.CreatePanel("Label", AttributePanelStyleINT, "AttributePanelLabel" );
    AttributePanelLabelINT.text = $.Localize("#DOTA_Hero_Selection_INT")
    var int_row = $.CreatePanel("Panel", $("#HeroBirzhaList"), "IntellectSelector" );

    for (var i = 0; i < intellect_heroes.length; i++) 
    {
        var hero_creating = $("#IntellectSelector").FindChild(intellect_heroes[i])
        if (hero_creating) { return };
        var panel = $.CreatePanel("Panel", $("#IntellectSelector"), intellect_heroes[i] );
        panel.AddClass("hero_select_panel");
        var icon = $.CreatePanel("Panel", panel, "image");
        icon.AddClass("hero_select_panel_img");
        icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + intellect_heroes[i] + '.png")';
        icon.style.backgroundSize = 'contain';
        SetHero(panel, intellect_heroes[i]);
        panel.BLoadLayoutSnippet('HeroCard');
    }
}

function SetHero(panel, hero)
{
	panel.SetPanelEvent("onactivate", function() { 
        demo_default_hero = hero
        SetHeroPickerVisible( false );
        $("#SpawnHeroName").text = $.Localize("#" + hero)
        $("#HeroPickerImage").style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + hero + '.png")'
        $("#HeroPickerImage").style.backgroundSize = "100%"
    } ); 
}



 
















var bHeroPickerVisible = false;

function ToggleHeroPicker( bMainHero )
{
	RegisterHeroes()
	Game.EmitSound( "UI.Button.Pressed" );

	$( '#SelectHeroContainer' ).SetHasClass( 'PickMainHero', bMainHero );

	SetHeroPickerVisible( !bHeroPickerVisible );
}

function SetHeroPickerVisible( bVisible )
{
	if ( bHeroPickerVisible )
	{
		if ( !bVisible )
		{
			$( '#SelectHeroContainer' ).RemoveClass( 'HeroPickerVisible' );
		}
	}
	else
	{
		if ( bVisible )
		{
			$( '#SelectHeroContainer' ).AddClass( 'HeroPickerVisible' );
		}
	}
	bHeroPickerVisible = bVisible;
}

function SwitchToNewHero( nHeroID )
{
	RegisterHeroes()
	Game.EmitSound( "UI.Button.Pressed" );

	if ( $( '#SelectHeroContainer' ).BHasClass( 'PickMainHero' ) )
	{
		$.DispatchEvent( 'FireCustomGameEvent_Str', 'SelectMainHeroButtonPressed', String( nHeroID ) );
	}
	else
	{
		$.DispatchEvent( 'FireCustomGameEvent_Str', 'SelectSpawnHeroButtonPressed', String( nHeroID ) );
	}

	$( '#SelectHeroContainer' ).RemoveClass( 'PickMainHero' );

	SetHeroPickerVisible( false );
}

function ToggleCategoryVisibility( str )
{
    //$.Msg( "^^^ToggleCategoryVisibility() - " + str )
    $( str ).ToggleClass( 'CollapseCategory' )
}



























 





function SpawnHero(team)
{
	GameEvents.SendCustomGameEventToServer( "SpawnHeroDemo", {hero_name: demo_default_hero, team:team} );
}

function ChangeSelf()
{
	GameEvents.SendCustomGameEventToServer( "ChangeHeroDemo", {hero_name: demo_default_hero} );
}


function ToggleInvulnerability()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

    for ( var i = 0; i < numEntities; i++ )
    {
        var entindex = entities[ i ];
        if ( entindex == -1 )
            continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'ToggleInvulnerabilityHero', String( entindex ) );
	}
}

function InvulnerableOn()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

	for ( var i = 0; i < numEntities; i++ )
	{
		var entindex = entities[i];
		if ( entindex == -1 )
			continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'InvulnOnHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function InvulnerableOff()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

	for ( var i = 0; i < numEntities; i++ )
	{
		var entindex = entities[i];
		if ( entindex == -1 )
			continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'InvulnOffHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function LevelUpSelectedHeroes()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

    for ( var i = 0; i < numEntities; i++ )
    {
        var entindex = entities[ i ];
        if ( entindex == -1 )
            continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'LevelUpHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function MaxLevelUpSelectedHeroes()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

    for ( var i = 0; i < numEntities; i++ )
    {
        var entindex = entities[ i ];
        if ( entindex == -1 )
            continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'MaxLevelUpHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function ResetSelectedHeroes()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

	for ( var i = 0; i < numEntities; i++ )
	{
		var entindex = entities[i];
		if ( entindex == -1 )
			continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'ResetHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function ShardSelectedHeroes()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

    for ( var i = 0; i < numEntities; i++ )
    {
        var entindex = entities[ i ];
        if ( entindex == -1 )
            continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'ShardHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function ScepterSelectedHeroes()
{
	var entities = Players.GetSelectedEntities( 0 );

	var numEntities = Object.keys( entities ).length;

    for ( var i = 0; i < numEntities; i++ )
    {
        var entindex = entities[ i ];
        if ( entindex == -1 )
            continue;

		$.DispatchEvent( 'FireCustomGameEvent_Str', 'ScepterHero', String( entindex ) );
	}

	if ( numEntities > 0 )
	{
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function MouseOverRune( strRuneID, strRuneTooltip )
{
	var runePanel = $( '#' + strRuneID );
	runePanel.StartAnimating();
	$.DispatchEvent( 'UIShowTextTooltip', runePanel, strRuneTooltip );
}

function MouseOutRune( strRuneID )
{
	var runePanel = $( '#' + strRuneID );
	runePanel.StopAnimating();
	$.DispatchEvent( 'UIHideTextTooltip', runePanel );
}

function SlideThumbActivate()
{
	var slideThumb = $.GetContextPanel();
	var bMinimized = slideThumb.BHasClass( 'Minimized' );

	if ( bMinimized )
	{
		Game.EmitSound( "ui_settings_slide_out" );
	}
	else
	{
		Game.EmitSound( "ui_settings_slide_in" );
	}

	slideThumb.ToggleClass( 'Minimized' );
}