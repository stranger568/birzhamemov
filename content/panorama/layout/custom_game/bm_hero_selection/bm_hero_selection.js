var selected_hero
var buttons;
var buttons_parent;
var chat;
var chat_parent;
var start_voice = true;
var double_rating = true
var TOKEN_INIT = false

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
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    
    $("#HeroInfoCont").style.opacity = "1"
    $("#AllHeroesList").RemoveAndDeleteChildren()
    let StrengthSelector = CreateHeroesRow("#DOTA_Hero_Selection_STR", "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( red ), to( #fff0 ) )", "StrIcon", 1)
    for (var i = 0; i < strength_heroes.length; i++) 
    {
        CreateHeroesCard(strength_heroes[i], StrengthSelector, player_info)
    }
    let AgilitySelector = CreateHeroesRow("#DOTA_Hero_Selection_AGI", "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08cc0f ), to( #fff0 ) )", "AgiIcon", 2)
    for (var i = 0; i < agility_heroes.length; i++) 
    {
        CreateHeroesCard(agility_heroes[i], AgilitySelector, player_info)
    }
    let IntellectSelector = CreateHeroesRow("#DOTA_Hero_Selection_INT", "gradient( radial, 50% 50%, 0% 0%, 50% 55%, from( #08bfcc ), to( #fff0 ) )", "IntIcon", 3)
    for (var i = 0; i < intellect_heroes.length; i++) 
    {
        CreateHeroesCard(intellect_heroes[i], IntellectSelector, player_info)
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

function CreateHeroesCard(hero_name, main, player_info)
{
    let panel = $.CreatePanel("Panel", main, hero_name );
    panel.AddClass("hero_select_panel");
    SetPSelectEvent(panel, hero_name);

    let icon = $.CreatePanel("Panel", panel, "image");
    icon.AddClass("hero_select_panel_img");
    icon.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + hero_name + '.png")';
    icon.style.backgroundSize = '100%';

    let ban_panel = $.CreatePanel("Panel", icon, "ban_panel");
    ban_panel.AddClass("ban_panel")
    
    let pick_panel = $.CreatePanel("Panel", icon, "pick_panel");
    pick_panel.AddClass("pick_panel")

    if (IsAllowForThis())
    {
        if (IsPlusHero(hero_name))
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
                let RankInfoHero = $.CreatePanel("Panel", panel, "");
                if (RankInfoHero)
                {
                    RankInfoHero.AddClass("RankInfoHero")
                    let RankIcon = $.CreatePanel("Panel", RankInfoHero, "");
                    if (RankIcon)
                    {
                        RankIcon.AddClass("RankIcon")
                        RankIcon.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero_information.experience)) + '.png")';
                        RankIcon.style.backgroundSize = "100%"
                    }
                    let RankLevel = $.CreatePanel("Label", RankInfoHero, "");
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
    $("#PickState").text = $.Localize("#BIRZHA_PICK_STATE_SELECT");
    $("#BannedButtonsPick").style.visibility = "collapse"
    $("#RandomButtonWithUnlock").style.visibility = "visible"
    if (selected_hero)
    {
        if (IsPlusHero(selected_hero))
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

function StartPreEnd()
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
        $.GetContextPanel().style.opacity = "0"
    })
    var ButtonsPanelBackground = FindDotaHudElement("ButtonsPanelBackground");
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

    let hero_winrate = Number(GetHeroWinrate(hero_name))
    $("#HeroWinrate").text = hero_winrate + "%";
    $("#HeroWinrate").SetHasClass("LowRate", hero_winrate < 50)

    SetShowText($("#BanCountPanel"), $.Localize("#ban_count_information"))
    SetShowText($("#BPHeroBlock"), $.Localize("#HeroAviableInBPPlus_description"))
    SetShowText($("#HeroRole"), $.Localize("#" + abilities.role_hero + "_description"))

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

    if (IsAllowForThis())
    {
        if (IsPlusHero(hero_name))
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

    $("#PickButton").SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "birzha_pick_select_hero", {hero : hero_name} );    
        Game.EmitSound("General.ButtonClick");
        var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");
        if (IsAllowForThis())
        {
            if (IsPlusHero(hero_name))
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
        }
    });

    $("#ButtonBanHeroNew").SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "birzha_pick_select_hero", {hero : hero_name} );    
        Game.EmitSound("General.ButtonClick");
        var game_state_name = CustomNetTables.GetTableValue('game_state', "pickstate_name");
        if (IsAllowForThis())
        {
            if (IsPlusHero(hero_name))
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
    InitDonateEffects(kv.hero);

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
    abilities_picked_panel.AddClass("BirzaAbilitiesPanelPicked")

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
    
    //$("#HeroInfoCont").style.width = "600px"; 
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

function TimerUpd( kv )
{
    var timer_panel = $('#PickTimer');
    if ( timer_panel )
    {
        timer_panel.text = kv.timer;
    }
    $('#PickAverageRating').text = $.Localize("#Pick_AverageRating") + GetAverageRating()
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

// Search hero 
function CloseSearch()
{   
    if (Game.IsInToolsMode()) { return }
    $("#SearchHeroEntry").text = ""  
    $("#SearchLupa").style.opacity = "1"
    $("#CloseSearch").style.opacity = "0"
}
 
function SearchHero()
{
    if (Game.IsInToolsMode()) { return }
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

function InitDonateEffects(hero_name)
{
    $("#DonateBlockPanelWithItems_1").RemoveAndDeleteChildren()
    $("#DonateBlockPanelWithItems_2").RemoveAndDeleteChildren()
    $("#DonateBlockPanelWithItems_3").RemoveAndDeleteChildren()
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    for (var i = 0; i < EFFECTS_LIST.length; i++) 
    {
        CreateDonateBlock(EFFECTS_LIST[i], player_info)
    }
    for (var i = 0; i < Items_pets.length; i++) 
    {
        CreatePetBlock(Items_pets[i], player_info)
    }
    for (var i = 0; i < Items_heroes.length; i++) 
    {
        CreateItemHeroesBlock(Items_heroes[i], player_info, hero_name)
    }
    if (IsAllowForThis())
    {
        $("#HeroDonateBlock").style.visibility = "visible"
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

function CreateItemHeroesBlock(table, player_info, hero_name)
{
    if (HEROES_ITEMS_INFO_START[table[0]] == hero_name)
    {
        var Recom_item = $.CreatePanel("Panel", $("#DonateBlockPanelWithItems_1"), "item_inventory_" + table[0]);
        Recom_item.AddClass("ItemInventory");
    
        var ItemImage = $.CreatePanel("Panel", Recom_item, "");
        ItemImage.AddClass("ItemImage");
        ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[3] + '.png")';
        ItemImage.style.backgroundSize = "100%"
    
        var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
        ItemName.AddClass("ItemName");
        ItemName.text = $.Localize( "#" + table[3] )
    
        var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
        BuyItemPanel.AddClass("BuyItemPanel");
    
        var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
        ItemPrice.AddClass("ItemPrice");
    
        var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
        PriceLabel.AddClass("PriceLabel");
        PriceLabel.text = $.Localize( "#effect_locked" )
        BuyItemPanel.SetHasClass("item_buying", true)
    
        if (HasItemInventory(table[0]))
        {
            BuyItemPanel.SetHasClass("item_buying", false)
            if (HasItemInventoryActive(table[0]))
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
                SetItemHero(table[0], Recom_item)
            });
        }
    }
}

function SetItemHero(num, panel)
{
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));

    if (!HasItemInventoryActive(num))
    {
    	panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "donate_change_item_active", {item_id: num, delete_item:false} );
    }
    else
    {
    	panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "donate_change_item_active", {item_id: num, delete_item: true} );
    }
}

function CreatePetBlock(table, player_info)
{
    var Recom_item = $.CreatePanel("Panel", $("#DonateBlockPanelWithItems_3"), "item_inventory_" + table[0]);
    Recom_item.AddClass("ItemInventory");
    //SetItemInventory(Recom_item, table[i])

    var ItemImage = $.CreatePanel("Panel", Recom_item, "");
    ItemImage.AddClass("ItemImage");
    ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[3] + '.png")';
    ItemImage.style.backgroundSize = "100%"

    var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
    ItemName.AddClass("ItemName");
    ItemName.text = $.Localize( "#" + table[3] )

    var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
    BuyItemPanel.AddClass("BuyItemPanel");

    var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
    ItemPrice.AddClass("ItemPrice");

    var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
    PriceLabel.AddClass("PriceLabel");
    PriceLabel.text = $.Localize( "#effect_locked" )
    BuyItemPanel.SetHasClass("item_buying", true)

    if (HasItemInventory(table[0]))
    {
        BuyItemPanel.SetHasClass("item_buying", false)
        if (player_info.pet_id == table[0])
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
            SelectPet(table[0], Recom_item)
        });
    } else
    {
        Recom_item.style.visibility = "collapse"
    }
}

function SelectPet(num, panel)
{
    let player_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    let current_effect = player_info.pet_id

    if (current_effect != num)
    {
    	for (var i = 0; i < $("#DonateBlockPanelWithItems_3").GetChildCount(); i++) 
        {
            if (!$("#DonateBlockPanelWithItems_3").GetChild(i).FindChildTraverse("BuyItemPanel").BHasClass("item_buying"))
            {
                $("#DonateBlockPanelWithItems_3").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
                $("#DonateBlockPanelWithItems_3").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 
    	panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_premium_pet", {pet_id: num, delete_pet:false} );
    }
    else
    {
    	panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_premium_pet", {pet_id: num, delete_pet: true} );
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

// HeroSelection Init
function BirzhaPickInit()
{
    if (IsSpectator()) { return }
    if (!$.DbgIsReloadingScript())
    {
        $( "#SearchHeroEntry" ).RaiseChangeEvents( true );
        $.RegisterEventHandler( 'TextEntryChanged', $( "#SearchHeroEntry" ), SearchHero );
    }
    GameEvents.Subscribe( 'birzha_pick_load_heroes', LoadHeroes );
    GameEvents.Subscribe( 'birzha_pick_timer_upd', TimerUpd );
    GameEvents.Subscribe( 'birzha_pick_ban_start', BanStart );
    GameEvents.Subscribe( 'birzha_pick_start_selection', StartSelection );
    GameEvents.Subscribe( 'birzha_pick_preend_start', StartPreEnd );
    GameEvents.Subscribe( 'birzha_pick_end', HeroSelectionEnd );
    GameEvents.Subscribe( 'hero_is_picked', HeroesIsPicked );
    GameEvents.Subscribe( 'ban_count_changed', ban_count_changed );
}    

BirzhaPickInit();