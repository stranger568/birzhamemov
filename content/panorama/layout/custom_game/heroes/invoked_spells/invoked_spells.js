var toggle = false;
var first_time = false;
var toggle_aang = false;
var first_time_aang = false;

function InitAbilityAang(){
    var button = $("#AangButton")
    if ($("#AangButton")) 
    {
        button = $("#AangButton")
    } 
    else 
    {
        button = FindDotaHudElement("Ability5").FindChildTraverse("AangButton")
    }

    var hero = Entities.GetUnitName(Players.GetLocalPlayerPortraitUnit())

    if (hero === "npc_dota_hero_oracle") 
    {
        var parentHUDElements = FindDotaHudElement("Ability5");
        button.style.visibility = "visible"
        if ($("#AangButton")) 
        {
            $("#AangButton").SetParent(parentHUDElements);
        }
    } 
    else 
    {
        button.style.visibility = "collapse"
        if (Players.GetPlayerSelectedHero( Players.GetLocalPlayer() )  === "npc_dota_hero_oracle" ) 
        {

        } 
        else 
        {
            if ($("#AangWindowAbilities").style.visibility == "visible") 
            {
                AangWindowActive()
            }
        }
    }

    for (var i = 0; i < 45; i++) 
    {
        var abilityId = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), i )
    
        if (abilityId > -1) {
    
            var abilityPanel = null
            var ability_name =  Abilities.GetAbilityName( abilityId )
    
    
            if (ability_name == "aang_lunge" ) {
                abilityPanel = "ability_0"
            } else if (ability_name == "aang_ice_wall" ) {
                abilityPanel = "ability_1"    
            } else if (ability_name == "aang_vacuum" ) {
                abilityPanel = "ability_2"
            } else if (ability_name == "aang_fast_hit" ) {
                abilityPanel = "ability_3"
            } else if (ability_name == "aang_jumping" ) {
                abilityPanel = "ability_4"
            } else if (ability_name == "aang_agility" ) {
                abilityPanel = "ability_5"
            } else if (ability_name == "aang_fire_hit" ) {
                abilityPanel = "ability_6"
            } else if (ability_name == "aang_lightning" ) {
                abilityPanel = "ability_7"
            } else if (ability_name == "aang_firestone" ) {
               abilityPanel = "ability_8" 
            } else if (ability_name == "aang_avatar" ) {
               abilityPanel = "ability_9" 
            }
    
            if (abilityPanel != null) {
                var abil_panel = $("#AangWindowAbilities").FindChildTraverse(abilityPanel)   
                if (abil_panel) {
                    var cooldownLength = Abilities.GetCooldownLength(abilityId);
                    var cooldownRemaining = Abilities.GetCooldownTimeRemaining(abilityId);
                    var cooldownPercent = 0
                    if (cooldownLength !== 0){ 
                        cooldownPercent = Math.ceil(100 * cooldownRemaining / cooldownLength);
                    }
    
                    if (!Abilities.IsCooldownReady(abilityId)){
                        abil_panel.GetChild(0).FindChild("AbilityCooldownTimer").text = Math.ceil(cooldownRemaining);
                        abil_panel.GetChild(0).FindChild("AbilityCooldownOverlay").style.width = cooldownPercent + "%";
                    } else {
                        abil_panel.GetChild(0).FindChild("AbilityCooldownTimer").text = " ";
                        abil_panel.GetChild(0).FindChild("AbilityCooldownOverlay").style.width = "0%";
                    }
                } 
            }
        }
    }
    $.Schedule(1/144, InitAbilityAang)
}

function AangWindowActive() {
    if (toggle_aang === false) {
        toggle_aang = true;
        if (first_time_aang === false) {
            first_time_aang = true;
            AangInit();
        }  
        $("#AangWindowAbilities").style.visibility = "visible"
    } else {
        toggle_aang = false;
        $("#AangWindowAbilities").style.visibility = "collapse"
    }
} 

function AangInit() 
{
    var invoke_list = 
    [
        "aang_lunge",
        "aang_ice_wall",
        "aang_vacuum",
        "aang_fast_hit",
        "aang_jumping",
        "aang_agility",
        "aang_fire_hit",
        "aang_lightning",
        "aang_firestone",
        "aang_avatar",
    ]

    var buttons = 
    [
        "q q q",
        "q q w",
        "q q e",
        "w w w",
        "q w w",
        "w w e",
        "e e e",
        "q e e",
        "w e e",
        "q w e",
    ]

    for (var i = 0; i < invoke_list.length; i++) 
    {
        var abilities_row = $.CreatePanel("Panel", $("#AangWindowAbilities"), "abilities_row"+i );
        abilities_row.AddClass("AbilitiesRow");
        var ability_panel = $.CreatePanel('DOTAAbilityImage', abilities_row, 'ability_' + i);
        ability_panel.abilityname = invoke_list[i];
        ability_panel.AddClass('HeroInfoAbilty');
        SetShowAbDesc(ability_panel, invoke_list[i]);
        var label = $.CreatePanel('Label', abilities_row, 'text_' + i);
        label.AddClass('LabelAbility');

        var cooldownPanel = $.CreatePanel('Panel', ability_panel, "");
        cooldownPanel.AddClass("Cooldown");
        var cooldownOverlayPanel = $.CreatePanel('Panel', cooldownPanel, "AbilityCooldownOverlay");
        cooldownOverlayPanel.AddClass("CooldownOverlay");
        var cooldownTimer = $.CreatePanel('Label', cooldownPanel, "AbilityCooldownTimer");
        cooldownTimer.AddClass("CooldownTimer");

        var buttons_string = buttons[i]

        var ability_1 = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), 0 )
        var ability_2 = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), 1 )
        var ability_3 = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), 2 )

        var q_new = Abilities.GetKeybind( ability_1 )
        var w_new = Abilities.GetKeybind( ability_2 )
        var e_new = Abilities.GetKeybind( ability_3 )

        buttons_string = buttons_string.replace( "q", String(q_new) )
        buttons_string = buttons_string.replace( "w", String(w_new) )
        buttons_string = buttons_string.replace( "e", String(e_new) )

        buttons_string = buttons_string.replace( "q", String(q_new) )
        buttons_string = buttons_string.replace( "w", String(w_new) )
        buttons_string = buttons_string.replace( "e", String(e_new) )

        buttons_string = buttons_string.replace( "q", String(q_new) )
        buttons_string = buttons_string.replace( "w", String(w_new) )
        buttons_string = buttons_string.replace( "e", String(e_new) )

        label.text = buttons_string;
    }
}

function SetShowAbDesc(panel, ability)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function InitAbilityKakashi(){
    var button_kakashi = $("#KakashiButton")
    if ($("#KakashiButton")) 
    {
        button_kakashi = $("#KakashiButton")
    } 
    else 
    {
        button_kakashi = FindDotaHudElement("Ability5").FindChildTraverse("KakashiButton")
    }

    var hero = Entities.GetUnitName(Players.GetLocalPlayerPortraitUnit())


    if (hero === "npc_dota_hero_dawnbreaker") 
    {
        var parentHUDElements = FindDotaHudElement("Ability5");
        button_kakashi.style.visibility = "visible"
        if ($("#KakashiButton")) 
        {
            $("#KakashiButton").SetParent(parentHUDElements);
        }
    }
    else 
    {
        button_kakashi.style.visibility = "collapse"
        if (Players.GetPlayerSelectedHero( Players.GetLocalPlayer() )  === "npc_dota_hero_dawnbreaker" ) 
        {

        } 
        else 
        {
            if ($("#KakashiWindowAbilities").style.visibility == "visible") {
                KakashiWindowActive()
            }
        }
    }

    for (var i = 0; i < 45; i++) {
    
        var abilityId = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), i )
    
    
        if (abilityId > -1) {
    
            var abilityPanel = null
            var ability_name =  Abilities.GetAbilityName( abilityId )
    
    
            if (ability_name == "kakashi_raikiri" ) {
                abilityPanel = "ability_0"
            } else if (ability_name == "kakashi_lightning_hit" ) {
                abilityPanel = "ability_1"    
            } else if (ability_name == "kakashi_shadow_clone" ) {
                abilityPanel = "ability_2"
            } else if (ability_name == "kakashi_tornado" ) {
                abilityPanel = "ability_3"
            } else if (ability_name == "kakashi_graze_wave" ) {
                abilityPanel = "ability_4"
            } else if (ability_name == "kakashi_susano" ) {
                abilityPanel = "ability_5"
            } else if (ability_name == "kakashi_lightning" ) {
                abilityPanel = "ability_6"
            } else if (ability_name == "kakashi_ligning_sphere" ) {
                abilityPanel = "ability_7"
            } else if (ability_name == "kakashi_meteor" ) {
               abilityPanel = "ability_8" 
            } else if (ability_name == "kakashi_sharingan" ) {
               abilityPanel = "ability_9" 
            }
    
            if (abilityPanel != null) {
                var abil_panel = $("#KakashiWindowAbilities").FindChildTraverse(abilityPanel)   
                if (abil_panel) {
                    var cooldownLength = Abilities.GetCooldownLength(abilityId);
                    var cooldownRemaining = Abilities.GetCooldownTimeRemaining(abilityId);
                    var cooldownPercent = 0
                    if (cooldownLength !== 0){ 
                        cooldownPercent = Math.ceil(100 * cooldownRemaining / cooldownLength);
                    }
    
                    if (!Abilities.IsCooldownReady(abilityId)){
                        abil_panel.GetChild(0).FindChild("AbilityCooldownTimer").text = Math.ceil(cooldownRemaining);
                        abil_panel.GetChild(0).FindChild("AbilityCooldownOverlay").style.width = cooldownPercent + "%";
                    } else {
                        abil_panel.GetChild(0).FindChild("AbilityCooldownTimer").text = " ";
                        abil_panel.GetChild(0).FindChild("AbilityCooldownOverlay").style.width = "0%";
                    }
                } 
            }
        }
    }
    $.Schedule(1/144, InitAbilityKakashi)
}

function KakashiWindowActive() {
    if (toggle === false) {
        toggle = true;
        if (first_time === false) {
            first_time = true;
            KakashiInit();
        }  
        $("#KakashiWindowAbilities").style.visibility = "visible"
    } else {
        toggle = false;
        $("#KakashiWindowAbilities").style.visibility = "collapse"
    }
}

function KakashiInit() 
{
    var invoke_list = 
    [
        "kakashi_raikiri",
        "kakashi_lightning_hit",
        "kakashi_shadow_clone",
        "kakashi_tornado",
        "kakashi_graze_wave",
        "kakashi_susano",
        "kakashi_lightning",
        "kakashi_ligning_sphere",
        "kakashi_meteor",
        "kakashi_sharingan",
    ]
    var buttons = 
    [
        "q q q",
        "q q w",
        "q q e",
        "w w w",
        "q w w",
        "w w e",
        "e e e",
        "q e e",
        "w e e",
        "q w e",
    ]
    for (var i = 0; i < invoke_list.length; i++) 
    {
        var abilities_row = $.CreatePanel("Panel", $("#KakashiWindowAbilities"), "abilities_row"+i );
        abilities_row.AddClass("AbilitiesRow");
        var ability_panel = $.CreatePanel('DOTAAbilityImage', abilities_row, 'ability_' + i);
        ability_panel.abilityname = invoke_list[i];
        ability_panel.AddClass('HeroInfoAbilty');
        SetShowAbDesc(ability_panel, invoke_list[i]);
        var label = $.CreatePanel('Label', abilities_row, 'text_' + i);
        label.AddClass('LabelAbility');
        var cooldownPanel = $.CreatePanel('Panel', ability_panel, "");
        cooldownPanel.AddClass("Cooldown");
        var cooldownOverlayPanel = $.CreatePanel('Panel', cooldownPanel, "AbilityCooldownOverlay");
        cooldownOverlayPanel.AddClass("CooldownOverlay");
        var cooldownTimer = $.CreatePanel('Label', cooldownPanel, "AbilityCooldownTimer");
        cooldownTimer.AddClass("CooldownTimer");
        var buttons_string = buttons[i]
        var ability_1 = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), 0 )
        var ability_2 = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), 1 )
        var ability_3 = Entities.GetAbility( Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), 2 )
        var q_new = Abilities.GetKeybind( ability_1 )
        var w_new = Abilities.GetKeybind( ability_2 )
        var e_new = Abilities.GetKeybind( ability_3 )
        buttons_string = buttons_string.replace( "q", String(q_new) )
        buttons_string = buttons_string.replace( "w", String(w_new) )
        buttons_string = buttons_string.replace( "e", String(e_new) )
        buttons_string = buttons_string.replace( "q", String(q_new) )
        buttons_string = buttons_string.replace( "w", String(w_new) )
        buttons_string = buttons_string.replace( "e", String(e_new) )
        buttons_string = buttons_string.replace( "q", String(q_new) )
        buttons_string = buttons_string.replace( "w", String(w_new) )
        buttons_string = buttons_string.replace( "e", String(e_new) )
        label.text = buttons_string;
    }
}

InitAbilityAang()
InitAbilityKakashi()