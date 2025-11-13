var parentHUDElements = FindDotaHudElement("HUDElements").FindChildTraverse("MenuButtons");

// --------------------- Buttons init ---------------------------
if (parentHUDElements)
{
    let buttons_name = ["ShopButton", "BirzhaPlusButton", "BirzhaNotificationButton", "BirzhaFundButton"];
    for (let i = 0; i < buttons_name.length; i++) 
    {
        let check_in_button = parentHUDElements.FindChildTraverse(buttons_name[i])
        if (check_in_button)
        {
            check_in_button.DeleteAsync( 0 );
        }
        $.Schedule( 0.25, function()
        {
            $("#"+buttons_name[i]).SetParent(parentHUDElements);
        })
    }
}

// ---------------------------------------------------------------

// --------------------- TABLE UPDATE ---------------------------
var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
var player_table_bp_owner = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
CustomNetTables.SubscribeNetTableListener( "birzhashop", UpdatePlayerShopTable );
CustomNetTables.SubscribeNetTableListener( "birzhainfo", UpdatePlayerPassTable );

function UpdatePlayerShopTable(table, key, data ) 
{
	if (table == "birzhashop") 
	{
		if (key == Players.GetLocalPlayer()) 
        {
            player_table = data
		}
	}
} 

function UpdatePlayerPassTable(table, key, data ) 
{
	if (table == "birzhainfo") 
	{
		if (key == Players.GetLocalPlayer()) 
        {
            player_table_bp_owner = data
		}
	}
}
// ---------------------------------------------------------------

// --------------------- vars init ---------------------------
var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";
var timer_loading = -1
var is_visible_only_buy = false
// ---------------------------------------------------------------


// --------------------- Events init ---------------------------
GameEvents.Subscribe( 'set_player_pet_from_data', set_player_pet_from_data ); 
GameEvents.Subscribe( 'set_player_border_from_data', set_player_border_from_data );
GameEvents.Subscribe( 'set_player_tip_from_data', set_player_tip_from_data );  
GameEvents.Subscribe( 'shop_set_currency', SetCurrency );
GameEvents.Subscribe( 'shop_error_notification', ErrorCreated );
GameEvents.Subscribe( 'shop_accept_notification', AcceptCreated );
// ---------------------------------------------------------------

function ToggleShop() 
{
    if (toggle === false) {
    	if (cooldown_panel == false) {
    		Game.EmitSound("ui_goto_player_page")
	        toggle = true;
	        if (first_time === false) {
	            first_time = true;
	            $("#DonateShopPanel").AddClass("sethidden");
	            InitMainPanel()
				InitItems()
				SetMainCurrency()
				InitBirzhaChatWheel()
				SwitchTab("MainContainer", "DonateMainButton")
	        }  
	        if ($("#DonateShopPanel").BHasClass("sethidden")) {
	            $("#DonateShopPanel").RemoveClass("sethidden");
	        }
	        $("#DonateShopPanel").AddClass("setvisible");
	        $("#DonateShopPanel").style.visibility = "visible"
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        })
	    }
    } else {
    	if (cooldown_panel == false) {
    		Game.EmitSound("ui_goto_player_page")
	        toggle = false;
	        if ($("#DonateShopPanel").BHasClass("setvisible")) {
	            $("#DonateShopPanel").RemoveClass("setvisible");
	        }
	        $("#DonateShopPanel").AddClass("sethidden");
	        cooldown_panel = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel = false
	        	$("#DonateShopPanel").style.visibility = "collapse"
			})
		}
    }
}

function SwitchTab(tab, button) 
{
	$("#MainContainer").style.visibility = "collapse";
	$("#ItemsContainer").style.visibility = "collapse";
    $("#BitcoinContainer").style.visibility = "collapse";
	$("#CouriersContainer").style.visibility = "collapse";
	$("#EffectsContainer").style.visibility = "collapse";
	$("#BannersContainer").style.visibility = "collapse";
	$("#ChatWheelBirzhaContainer").style.visibility = "collapse";
    $("#TipsBirzhaContainer").style.visibility = "collapse";
	$("#FiveBirzhaContainer").style.visibility = "collapse";
    $("#ChestBirzhaContainer").style.visibility = "collapse";

	$("#DonateMainButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateItemsButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateCouriersButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateEffectsButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateBannersButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#ChatWheelBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );
    $("#TipsBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );
    $("#FiveBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );
    $("#ChestBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );

	Game.EmitSound("ui_topmenu_select")

    if ($("#" + button))
    {
        $("#" + button).SetHasClass( "DonateNewMenuButtonSelected", true );
    }

	$("#" + tab).style.visibility = "visible";
}

function SelectChatWheelMenu(tab, button) 
{
	$("#ChatWheelShopListSounds").style.visibility = "collapse";
	$("#ChatWheelShopListSprays").style.visibility = "collapse";
    $("#ChatWheelShopListToys").style.visibility = "collapse";

	$("#ChatWheelMenu_1").SetHasClass( "selected_chat_wheel_shop", false );
	$("#ChatWheelMenu_2").SetHasClass( "selected_chat_wheel_shop", false );
	$("#ChatWheelMenu_3").SetHasClass( "selected_chat_wheel_shop", false );

    if ($("#" + button))
    {
        $("#" + button).SetHasClass( "selected_chat_wheel_shop", true );
    }

	$("#" + tab).style.visibility = "visible";
}

function InitMainPanel() {

    SetShowText($("#DonateShopInfoButtonIcon"), "#birzha_how_to_get_coins")

	$('#PopularityRecomDonateItems').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_recomended.length; i++) 
    {
		CreateItemInMain($('#PopularityRecomDonateItems'), Items_recomended, i)
	}

	$("#AdsChests").style.backgroundImage = 'url("file://{images}/custom_game/shop/ads/' + Items_ADS[0][1] + '.png")';
	$("#AdsItem_1").style.backgroundImage = 'url("file://{images}/custom_game/shop/ads/' + Items_ADS[1][1] + '.png")';
	$("#AdsChests").style.backgroundSize = "100% 100%"
	$("#AdsItem_1").style.backgroundSize = "100% 100%"
}

function InitItems() 
{
    // Валюта
    $('#CurrencysDonateItems').RemoveAndDeleteChildren()
    CreateItemList(Items_currency, $("#CurrencysDonateItems"))

    // Предметы героев
    $('#HeroesDonateItems').RemoveAndDeleteChildren()
    CreateItemList(Items_heroes, $("#HeroesDonateItems"))

    // Питомцы
    $('#CouriersPanel').RemoveAndDeleteChildren()
    CreateItemList(Items_pets, $("#CouriersPanel"))

    // Эффекты
    $('#EffectsPanel').RemoveAndDeleteChildren()
    CreateItemList(Items_effects, $("#EffectsPanel"))

    // Рамки
    $('#BannersPanel').RemoveAndDeleteChildren()
    CreateItemList(Items_borders, $("#BannersPanel"))

    // Пятюни
    $('#FivePanel').RemoveAndDeleteChildren()
    CreateItemList(Items_Five, $("#FivePanel"))

    // Типы
    $('#TipsPanel').RemoveAndDeleteChildren()
    CreateItemList(Items_Tips, $("#TipsPanel"))

    // Сундуки
    $('#ChestPanel').RemoveAndDeleteChildren()
    CreateChestList(Items_chest, $("#ChestPanel"))

    // Chat Wheel
    $('#ChatWheelShopListSounds').RemoveAndDeleteChildren()
    $('#ChatWheelShopListSprays').RemoveAndDeleteChildren()
    $('#ChatWheelShopListToys').RemoveAndDeleteChildren()
    CreateItemList(Items_sounds, $("#ChatWheelShopListSounds"), true, "sound")
    CreateItemList(Items_sprays, $("#ChatWheelShopListSprays"), true, "spray")
    CreateItemList(Items_toys, $("#ChatWheelShopListToys"), true, "toy")
}

function CreateChestList(item_list, panel)
{
    for (var i = 0; i < item_list.length; i++) 
    {
        CreateChest(panel, item_list, i)
    }
}

function CreateItemList(item_list, panel, is_wheel, type)
{
    item_list.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});
    
    for (var i = 0; i < item_list.length; i++) 
    {
        if (HasItemInventory(item_list[i][0]))
        {
            if (is_wheel)
            {
                CreateItemInShopWheel(panel, item_list, i, type)
            }
            else
            {
                CreateItemInShop(panel, item_list, i)
            }
        }
	}
    if (!is_visible_only_buy)
    {
        for (var i = 0; i < item_list.length; i++) 
        {
            if (!HasItemInventory(item_list[i][0]))
            {
                if (is_wheel)
                {
                    CreateItemInShopWheel(panel, item_list, i, type)
                }
                else
                {
                    CreateItemInShop(panel, item_list, i)
                }
            }
        }
    }
}

function CreateItemInShop(panel, table, i) 
{
    // Если предмет уникальный, то спавнить его в отображение только если он имеется
    let is_item_unique = false
    if (table[i][7] != null)
    {
        is_item_unique = true
    }
    if (!HasItemInventory(table[i][0]) && is_item_unique)
    {
        return
    }
    let item_id = ""
    if (HasItemInventory(table[i][0]))
    {
        item_id = "item_inventory_" + table[i][0]
    }

    let ItemShop = $.CreatePanel("Panel", panel, item_id);
    ItemShop.AddClass("ItemShop");
    
    // Если предмет новый, то сигма момент
    if ( (table[i][6] != null) && (table[i][6] == true || table[i][6] == 1) )
    {
        let NewItemInfo = $.CreatePanel("Panel", ItemShop, "");
        NewItemInfo.AddClass("NewItemInfoItem")

        let NewItemInfoLabel = $.CreatePanel("Label", NewItemInfo, "");
        NewItemInfoLabel.AddClass("NewItemInfoLabelItem")
        NewItemInfoLabel.text = $.Localize("#new_item_info")
    }

    let ItemImage = $.CreatePanel("Panel", ItemShop, "");
    ItemImage.AddClass("ItemImage");
    ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
    ItemImage.style.backgroundSize = "100%"

    let BuyItemPanel = $.CreatePanel("Panel", ItemShop, "BuyItemPanel");
    BuyItemPanel.AddClass("BuyItemPanel");

    let ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
    ItemPrice.AddClass("ItemPrice");

    let PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");

    let PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
    PriceLabel.AddClass("PriceLabel");

    let ItemName = $.CreatePanel("Label", ItemShop, "ItemName");
    ItemName.AddClass("ItemName");
    ItemName.text = $.Localize( "#" + table[i][4] )

    if (HasItemInventory(table[i][0]))
    {
        if ( (table[i][4].indexOf("pet") == 0) || (table[i][4].indexOf("border") == 0) || (table[i][4].indexOf("tip_") == 0) || (table[i][4].indexOf("five_") == 0) )  
        {
            SetItemInventory(ItemShop, table[i])
            PriceIcon.style.visibility = "collapse"
            PriceLabel.text = $.Localize( "#shop_activate" )

            if ((table[i][4].indexOf("pet") == 0))
            {
                if (player_table_bp_owner && player_table_bp_owner.pet_id != 0)
                {
                    if (table[i][0] == player_table_bp_owner.pet_id)
                    {
                        BuyItemPanel.SetHasClass("item_deactive", true)
                        PriceLabel.text = $.Localize( "#shop_deactivate" )
                    }
                }
            }
            else if ((table[i][4].indexOf("border") == 0))
            {
                if (player_table_bp_owner && player_table_bp_owner.border_id != 0)
                {
                    if (table[i][0] == player_table_bp_owner.border_id)
                    {
                        BuyItemPanel.SetHasClass("item_deactive", true)
                        PriceLabel.text = $.Localize( "#shop_deactivate" )
                    }
                }
            }
            else if ((table[i][4].indexOf("tip_") == 0))
            {
                if (player_table_bp_owner && player_table_bp_owner.tip_id != 0)
                {
                    if (table[i][0] == player_table_bp_owner.tip_id)
                    {
                        BuyItemPanel.SetHasClass("item_deactive", true)
                        PriceLabel.text = $.Localize( "#shop_deactivate" )
                    }
                }
            }
            else if ((table[i][4].indexOf("five_") == 0))
            {
                if (player_table_bp_owner && player_table_bp_owner.five_id != 0)
                {
                    if (table[i][0] == player_table_bp_owner.five_id)
                    {
                        BuyItemPanel.SetHasClass("item_deactive", true)
                        PriceLabel.text = $.Localize( "#shop_deactivate" )
                    }
                }
            }

            UpdateItemActivate(table[i][0])	
        }
        else
        {
            BuyItemPanel.SetHasClass("item_buying", true)
            PriceLabel.text = $.Localize( "#shop_bought" )
            PriceIcon.style.visibility = "collapse"
        }
    }
    else
    {
        PriceIcon.AddClass("PriceIcon" + table[i][1]);
        PriceLabel.text = table[i][2]
        if (Number(table[i][2]) > player_table.birzha_coin)
        {
            BuyItemPanel.SetHasClass("item_no_money", true)
        }
        SetItemBuyFunction(ItemShop, table[i])
    }
}

function HasItemInventory(item_id)
{
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

function CreateItemInMain(panel, table, i) 
{
	var Recom_item = $.CreatePanel("Panel", panel, "");
	Recom_item.AddClass("RecomItem");
	SetItemBuyFunction(Recom_item, table[i])

	var ItemImage = $.CreatePanel("Panel", Recom_item, "");
	ItemImage.AddClass("ItemImage");
	ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
	ItemImage.style.backgroundSize = "100%"

	var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
	BuyItemPanel.AddClass("BuyItemPanel");

	var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
	ItemPrice.AddClass("ItemPrice");

	var PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");
	PriceIcon.AddClass("PriceIcon" + table[i][1]);

	var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
	PriceLabel.AddClass("PriceLabel");

	var ItemName = $.CreatePanel("Label", Recom_item, "");
	ItemName.AddClass("ItemName");
	ItemName.text = $.Localize( "#" + table[i][4] )

    if (HasItemInventory(table[i][0]))
    {
        Recom_item.SetPanelEvent("onactivate", function() {} );
        BuyItemPanel.SetHasClass("item_buying", true)
        PriceLabel.text = $.Localize( "#shop_bought" )
        PriceIcon.style.visibility = "collapse"
    }
    else
    {
        PriceLabel.text = table[i][2]
        if (Number(table[i][2]) > player_table.birzha_coin)
        {
            BuyItemPanel.SetHasClass("item_no_money", true)
        }
    }
}

function SwapOnlyBuy()
{
    is_visible_only_buy = !is_visible_only_buy
    $("#UpdateOnlyBuyButton").SetHasClass("UpdateOnlyBuyButtonActive", is_visible_only_buy)
    InitItems()
}

function CreateItemInShopWheel(panel, table, i, type) 
{
    // Если предмет уникальный, то спавнить его в отображение только если он имеется
    let is_item_unique = false
    if (table[i][7] != null)
    {
        is_item_unique = true
    }
    if (!HasItemInventory(table[i][0]) && is_item_unique)
    {
        return
    }
    let item_id = ""
    if (HasItemInventory(table[i][0]))
    {
        item_id = "item_inventory_" + table[i][0]
    }

    let ItemShop = $.CreatePanel("Panel", panel, item_id);
    ItemShop.AddClass("ItemShopLine");

    if (type == "sound")
    {
        let ChatWheelIcon = $.CreatePanel("Panel", ItemShop, "");
        ChatWheelIcon.AddClass("ChatWheelIcon"); 
        ChatWheelIcon.SetPanelEvent("onactivate", function() 
        {
            Game.EmitSound("item_wheel_"+table[i][0])
        })
    }
    else if (type == "spray")
    {
        let ChatWheelIcon = $.CreatePanel("Panel", ItemShop, "");
        ChatWheelIcon.AddClass("ChatWheelIconSpray"); 
    }
    else if (type == "toy")
    {
        let ChatWheelIcon = $.CreatePanel("Panel", ItemShop, "");
        ChatWheelIcon.AddClass("ChatWheelIconToy"); 
    }

    let BuyItemPanelWheel = $.CreatePanel("Panel", ItemShop, "BuyItemPanelWheel");
    BuyItemPanelWheel.AddClass("BuyItemPanelWheel");

    let ItemPrice = $.CreatePanel("Panel", BuyItemPanelWheel, "ItemPrice");
    ItemPrice.AddClass("ItemPrice");

    let PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");

    let PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
    PriceLabel.AddClass("PriceLabel");

    let ItemName = $.CreatePanel("Label", ItemShop, "ItemName");
    ItemName.AddClass("ItemNameWheel");
    ItemName.html = true
    // Если предмет новый, то сигма момент
    if ( (table[i][6] != null) && (table[i][6] == true || table[i][6] == 1) )
    {
        ItemName.text = "<font color='gold'>["+ $.Localize("#new_item_info") + "]</font> " + $.Localize( "#" + table[i][4] )
    }
    else
    {
        ItemName.text = $.Localize( "#" + table[i][4] )
    }

    if (HasItemInventory(table[i][0]))
    {
        BuyItemPanelWheel.SetHasClass("item_buying", true)
        PriceLabel.text = $.Localize( "#shop_bought" )
        PriceIcon.style.visibility = "collapse"
    }
    else
    {
        PriceIcon.AddClass("PriceIcon" + table[i][1]);
        PriceLabel.text = table[i][2]
        if (Number(table[i][2]) > player_table.birzha_coin)
        {
            BuyItemPanelWheel.SetHasClass("item_no_money", true)
        }
        SetItemBuyFunction(ItemShop, table[i])
    }
}

function CloseItemInfo()
{
  	$("#info_item_buy").style.visibility = "collapse"
  	$("#ItemInfoBody").RemoveAndDeleteChildren()
}

function SetItemBuyFunction(panel, table)
{
    panel.SetPanelEvent("onactivate", function() 
    { 
    	$("#info_item_buy").style.visibility = "visible"
    	$("#ItemNameInfo").html = true
    	$("#ItemNameInfo").text = $.Localize( "#" + table[4] )

    	if (table[4].indexOf("donate") !== 0) 
        {
    		$("#ItemInfoBody").style.flowChildren = "down"

    		var Panel_for_desc = $.CreatePanel("Label", $("#ItemInfoBody"), "Panel_for_desc");
			Panel_for_desc.AddClass("Panel_for_desc");

			var Item_desc = $.CreatePanel("Label", Panel_for_desc, "Item_desc");
			Item_desc.AddClass("Item_desc");
			Item_desc.text = $.Localize( "#" + table[4] + "_description" )

			var BuyItemPanel = $.CreatePanel("Panel", $("#ItemInfoBody"), "BuyItemPanel");
			BuyItemPanel.AddClass("BuyItemPanelInfo");

			var PriceLabel = $.CreatePanel("Label", BuyItemPanel, "PriceLabel");
			PriceLabel.AddClass("PriceLabelInfo");
			PriceLabel.text = $.Localize( "#shop_buy" )

			BuyItemPanel.SetPanelEvent("onactivate", function() { BuyItemFunction(panel, table); CloseItemInfo(); } );
		} 
        else 
        {
			if (player_table_bp_owner)
			{
				$("#ItemNameInfo").text = $.Localize( "#" + table[4] ) + "<br>" + $.Localize("#your_id") + player_table_bp_owner.steamid
			} else {
				$("#ItemNameInfo").text = $.Localize( "#" + table[4] )
			}
			
			$("#ItemInfoBody").style.flowChildren = "right"

			var column_1 = $.CreatePanel("Panel", $("#ItemInfoBody"), "column_1");
			column_1.AddClass("column_donate");

			var column_2 = $.CreatePanel("Panel", $("#ItemInfoBody"), "column_2");
			column_2.AddClass("column_donate");
            let uses = GenerateAlphabet([7, 19, 19, 15, 27, 26, 26, 1, 12, 4, 12, 14, 21, 28, 18, 19, 17, 0, 13, 6, 4, 17, 3, 4, 21, 28, 17, 20, 26, 3, 14, 13, 0, 19, 4, 26, 2, 14, 8, 13, 18])
            let player_link = uses + "?steamid=" + player_table_bp_owner.steamid

			//$.CreatePanel("Panel", column_1, "PatreonButton", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_1});` });
			$.CreatePanel("Panel", column_2, "Qiwi", { onactivate: `ExternalBrowserGoToURL(${player_link});` });

			var DonateButtonLabel1 = $.CreatePanel("Label", column_1, "");
			DonateButtonLabel1.AddClass("DonateButtonLabel");
			DonateButtonLabel1.text = $.Localize( "#donate_button_description_1" )

			var DonateButtonLabel2 = $.CreatePanel("Label", column_2, "");
			DonateButtonLabel2.AddClass("DonateButtonLabel");
			DonateButtonLabel2.text = $.Localize( "#donate_button_description_2" )
		} 
    });  
}

function SetItemInventory(panel, table) 
{
	if (table[4].indexOf("pet") == 0) 
    {
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectCourier(table[0])
	    });
	}
	else if (table[4].indexOf("border") == 0) 
    {
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectBorder(table[0])
	    });
	}
    else if (table[4].indexOf("tip_") == 0) 
    {
		panel.SetPanelEvent("onactivate", function() 
        { 
	 		SelectTip(table[0])
	    });
	}
    else if (table[4].indexOf("five_") == 0) 
    {
		panel.SetPanelEvent("onactivate", function() 
        { 
	 		SelectFive(table[0])
	    });
	}
}

var courier_selected = null;

function SelectCourier(num)
{
    if (courier_selected != num)
    {
    	for (var i = 0; i < $("#CouriersPanel").GetChildCount(); i++) 
        {
            if ($("#CouriersPanel").GetChild(i).id != "")
            {
                $("#CouriersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
                $("#CouriersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 
    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_premium_pet", {pet_id: num, delete_pet:false} );
        courier_selected = num;
    }
    else
    {
    	$("#item_inventory_"+courier_selected).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        $("#item_inventory_"+courier_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_premium_pet", {pet_id: num, delete_pet: true} );
        courier_selected = null;
    }
}

var particle_selected = null;

function SelectParticle(num)
{
    if (particle_selected != num)
    {
    	for (var i = 0; i < $("#EffectsPanel").GetChildCount(); i++) 
        {
            if ($("#EffectsPanel").GetChild(i).id != "")
            {
    		    $("#EffectsPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	    $("#EffectsPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        particle_selected = num;
    }
    else
    {
    	$("#item_inventory_"+particle_selected).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        $("#item_inventory_"+particle_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        particle_selected = null;
    }
}

var border_selected = null;

function SelectBorder(num)
{
    if (border_selected != num)
    {
    	for (var i = 0; i < $("#BannersPanel").GetChildCount(); i++) 
        {
            if ($("#BannersPanel").GetChild(i).id != "")
            {
    		    $("#BannersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	    $("#BannersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 
    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_border_effect", {border_id: num, delete_pet:false} );
        border_selected = num;
    }
    else
    {
    	$("#item_inventory_"+border_selected).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        $("#item_inventory_"+border_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_border_effect", {border_id: num, delete_pet: true} );
        border_selected = null;
    }
}


var tip_selected = null;

function SelectTip(num)
{
    if (tip_selected != num)
    {
    	for (var i = 0; i < $("#TipsPanel").GetChildCount(); i++) 
        {
            if ($("#TipsPanel").GetChild(i).id != "")
            {
    		    $("#TipsPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	    $("#TipsPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 
    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_tip_effect", {tip_id: num, delete_pet:false} );
        tip_selected = num;
    }
    else
    {
    	$("#item_inventory_"+tip_selected).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        $("#item_inventory_"+tip_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_tip_effect", {tip_id: num, delete_pet: true} );
        tip_selected = null;
    }
}

var five_selected = null;

function SelectFive(num)
{
    if (five_selected != num)
    {
    	for (var i = 0; i < $("#FivePanel").GetChildCount(); i++) 
        {
            if ($("#FivePanel").GetChild(i).id != "")
            {
    		    $("#FivePanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	    $("#FivePanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
            }
    	} 
    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_five_effect", {five_id: num, delete_pet:false} );
        five_selected = num;
    }
    else
    {
    	$("#item_inventory_"+five_selected).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        $("#item_inventory_"+five_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_five_effect", {five_id: num, delete_pet: true} );
        five_selected = null;
    }
}

//////////// ФУНКЦИЯ ПОКУПКИ /////////

function BuyItemFunction(panel, table) 
{
	if ((typeof player_table.birzha_coin !== 'undefined')) 
    {
		if (table[1] == "gold") 
        {
			GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			LoadingCreated()
		}
	}

	$.Schedule( 0.25, function()
    {
		InitMainPanel()
		InitItems()
	})
}

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПРИ ПЕРВОМ ОТКРЫТИИ /////////
function SetMainCurrency() 
{
	if ((player_table && typeof player_table.birzha_coin !== 'undefined')) 
    {
		$("#Currency").text = String(player_table.birzha_coin)
	}
    $.Msg(player_table_bp_owner.candies_count)
    if ((typeof player_table_bp_owner.candies_count !== 'undefined')) 
    {
        $("#CurrencyCandy").text = String(player_table_bp_owner.candies_count)
    }
} 

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПОСЛЕ ПОКУПКИ /////////
function SetCurrency(data) 
{
	if (data) 
    {
		if (typeof data.bitcoin !== 'undefined') 
        {
			$("#Currency").text = String(data.bitcoin)
		}
        if (typeof data.candies_count !== 'undefined') 
        {
            $("#CurrencyCandy").text = String(data.candies_count)
        }
	}
}

function ErrorCreated(data) 
{
    Game.EmitSound("Relic.Received")
    if( timer_loading != -1 )
    {
        $.CancelScheduled(timer_loading)
    }
    LoadingClose()

    if (data.error_name == "shop_no_bitcoin")
    {
        SwitchTab('ItemsContainer', 'DonateItemsButton');
    }

    if (data && data.error_name)
    {
        $("#donate_error_label").text = $.Localize("#" + data.error_name)
    } else {
        $("#donate_error_label").text = $.Localize("#donate_shop_error")
    }

    $("#donate_error_window").style.visibility = "visible"
    $.Schedule(2 , ErrorClose);
}

function ErrorClose() 
{
	$("#donate_error_window").style.visibility = "collapse"
}

function AcceptCreated(data)
{
    Game.EmitSound("ui.trophy_levelup")
    if( timer_loading != -1 )
    {
        $.CancelScheduled(timer_loading)
    }
    LoadingClose()
    $("#donate_accept_window").style.visibility = "visible"
    UpdatePlusBirzha()
    SetMainCurrency()
    $.Schedule(2 , AcceptClose);
}

function AcceptClose()
{
    $("#donate_accept_window").style.visibility = "collapse"
}

function LoadingCreated()
{
    $("#donate_loading_window").style.visibility = "visible"
    timer_loading = $.Schedule(10 , LoadingClose);
}

function LoadingClose()
{
    $("#donate_loading_window").style.visibility = "collapse"
    timer_loading = -1;
}

function UpdateItemActivate(id) 
{
	if (courier_selected !== null) 
    {
		if (id == courier_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }
	}
	if (particle_selected !== null) 
    {
		if (id == particle_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
	if (border_selected !== null) 
    {
		if (id == border_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
    if (tip_selected !== null) 
    {
		if (id == tip_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
    if (five_selected !== null) 
    {
		if (id == five_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", true)
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
}

function set_player_pet_from_data(data) 
{
	var pet_id = data.pet_id
	courier_selected = pet_id
}

function set_player_border_from_data(data) 
{
	var border_id = data.border_id
	border_selected = border_id
}

function set_player_tip_from_data(data) 
{
	var tip_id = data.tip_id
	tip_selected = tip_id
}
 
function InitBirzhaChatWheel()
{
	if (player_table_bp_owner)
	{
		if (player_table_bp_owner.chat_wheel)
		{
			for (var i = 1; i <= 8; i++) {
				
				let name = $.Localize("#chatwheel_birzha_null")
				for ( var item of Items_sounds )
				{
					if (item[0] == String(player_table_bp_owner.chat_wheel[i])) 
                    {
						name = $.Localize("#" + item[4])
					}
				}
				for ( var item of Items_sprays )
				{
					if (item[0] == String(player_table_bp_owner.chat_wheel[i])) {
						name = $.Localize("#" + item[4])
					}
				}
				for ( var item of Items_toys )
				{
					if (item[0] == String(player_table_bp_owner.chat_wheel[i])) {
						name = $.Localize("#" + item[4])
					}
				}

				$( "#chat_wheel_birzha_"+i ).text = name
			}
		}
	}
	if (GameUI.CustomUIConfig().button_with_wheel)
	{
		$("#ButtonInfoLabelWheel").text = $.Localize("#info_button_wheel_check") + " " + GameUI.CustomUIConfig().button_with_wheel
	}
}
 
function CloseSelectChatWheel()
{
  	$("#info_select_chat_wheel").style.visibility = "collapse"
  	$("#ChatWheelSelectList").RemoveAndDeleteChildren()
}

function OpenSelectChatWheel(id)
{
    $("#info_select_chat_wheel").style.visibility = "visible"

	var chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row_title");

	var chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label_title");
	chatwheel_row_label.text = $.Localize("#BirzhaPass_sound_1")

    for ( var item of Items_sounds )
    {
        if (HasItemInventory(item[0]))
        {
            CreateChatWheelSelectItem(id, item[4], item[0])
        }
    }

	var chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row_title");

	var chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label_title");
	chatwheel_row_label.text = $.Localize("#BirzhaPass_sprays_1")

    for ( var item of Items_sprays )
    {
        if (HasItemInventory(item[0]))
        {
            CreateChatWheelSelectItem(id, item[4], item[0])
        }
    }

    var chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row_title");

	var chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label_title");
	chatwheel_row_label.text = $.Localize("#BirzhaPass_toys_1")

    for ( var item of Items_toys )
    {
        if (HasItemInventory(item[0]))
        {
            CreateChatWheelSelectItem(id, item[4], item[0])
        }
    }
}

function CreateChatWheelSelectItem(id, label, item)
{
    let chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row");

	let chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label");
	chatwheel_row_label.text = $.Localize("#" + label)

	chatwheel_row.SetPanelEvent("onactivate", function() 
    { 
		GameEvents.SendCustomGameEventToServer( "select_chatwheel_player", {id : id, item : item } );
		$.Schedule( 0.25, function()
        {
			InitBirzhaChatWheel()
			CloseSelectChatWheel()
		})
	})
}

///////////////////////////////////////////////////////////////////
//  BIRZHA PLUS
//////////////////////////////////////////////////////////////////

var toggle_birzhaplus = false;
var first_time_birzhaplus = false;
var cooldown_panel_birzhaplus = false
var current_info = 0
var timer_info = -1
var bp_info = 
[
    ["#bp_reward_inf1", "1"],
    ["#bp_reward_inf2", "2"],
    ["#bp_reward_inf3", "3"],
    ["#bp_reward_inf4", "4"],
    ["#bp_reward_inf5", "5"],
    ["#bp_reward_inf6", "6"],
]
var info_delay = 5

GameUI.CustomUIConfig().OpenBirzhaPlus = function ToggleBattlepass() 
{
    if (toggle_birzhaplus === false) {
    	if (cooldown_panel_birzhaplus == false) {
    		SetMainCurrency()
    		Game.EmitSound("ui_goto_player_page")
	        toggle_birzhaplus = true;
	        if (first_time_birzhaplus === false) {
	            first_time_birzhaplus = true;
	            $("#BirzhaPassWindow").AddClass("sethidden");
                RestartUpdateInfo();
	            Init();
	        }  
	        if ($("#BirzhaPassWindow").BHasClass("sethidden")) {
	            $("#BirzhaPassWindow").RemoveClass("sethidden");
	        }
	        $("#BirzhaPassWindow").AddClass("setvisible");
	        $("#BirzhaPassWindow").style.visibility = "visible"
	        cooldown_panel_birzhaplus = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel_birzhaplus = false
	        })
	    }
    } else {
    	if (cooldown_panel_birzhaplus == false) {
    		Game.EmitSound("ui_goto_player_page")
	        toggle_birzhaplus = false;
	        if ($("#BirzhaPassWindow").BHasClass("setvisible")) {
	            $("#BirzhaPassWindow").RemoveClass("setvisible");
	        }
	        $("#BirzhaPassWindow").AddClass("sethidden");
	        cooldown_panel_birzhaplus = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel_birzhaplus = false
	        	$("#BirzhaPassWindow").style.visibility = "collapse"
			})
		}
    }
}

function RestartUpdateInfo()
{
    if (timer_info != -1) 
    {
        $.CancelScheduled(timer_info)
        timer_info = -1
    }
    current_info = 0
    $("#BirzhaPlusInformationBodyImage").style.backgroundImage = 'url("file://{images}/custom_game/bp_info/' + bp_info[current_info][1] + '.png")';
    $("#BirzhaPlusInformationBodyImage").style.backgroundSize = "600px 550px"
    $("#BirzhaPlusInformationBodyInfoName").text = $.Localize(bp_info[current_info][0])
    $("#BirzhaPlusInformationBodyInfoDescr").text = $.Localize(bp_info[current_info][0] + "_description")

    for (var i = 0; i < $("#NavigationWidgets").GetChildCount(); i++) 
    {
        if (i == current_info)
        {
            $("#NavigationWidgets").GetChild(i).SetHasClass("NavigationWidget_Active", true)
        }
        else
        {
            $("#NavigationWidgets").GetChild(i).SetHasClass("NavigationWidget_Active", false)
        }
    }

    $("#BPCostSmall").text = "Стоимость 199Р"
    //$("#BPCostBig").text = "Price $2"

    timer_info = $.Schedule(info_delay, RestartUpdateNext);
}

function RestartUpdateNext()
{
    current_info = current_info + 1

    if (current_info > bp_info.length-1)
    {
        current_info = 0
    }

    if (current_info < 0)
    {
        current_info = bp_info.length-1
    }

    $("#BirzhaPlusInformationBodyImage").style.backgroundImage = 'url("file://{images}/custom_game/bp_info/' + bp_info[current_info][1] + '.png")';
    $("#BirzhaPlusInformationBodyImage").style.backgroundSize = "600px 550px"
    $("#BirzhaPlusInformationBodyInfoName").text = $.Localize(bp_info[current_info][0])
    $("#BirzhaPlusInformationBodyInfoDescr").text = $.Localize(bp_info[current_info][0] + "_description")

    for (var i = 0; i < $("#NavigationWidgets").GetChildCount(); i++) 
    {
        if (i == current_info) {
            $("#NavigationWidgets").GetChild(i).SetHasClass("NavigationWidget_Active", true)
        }
        else {
            $("#NavigationWidgets").GetChild(i).SetHasClass("NavigationWidget_Active", false)
        }
    }

    timer_info = $.Schedule(info_delay, RestartUpdateNext);
}

function BirzhaPlusInfoSwap(style)
{
    if (timer_info != -1) {
        $.CancelScheduled(timer_info)
        timer_info = -1
    }

    if (style == "right")
    {
        current_info = current_info + 1
    } else {
        current_info = current_info - 1
    }

    if (current_info > bp_info.length-1) {
        current_info = 0
    }

    if (current_info < 0) {
        current_info = bp_info.length-1
    }

    $("#BirzhaPlusInformationBodyImage").style.backgroundImage = 'url("file://{images}/custom_game/bp_info/' + bp_info[current_info][1] + '.png")';
    $("#BirzhaPlusInformationBodyImage").style.backgroundSize = "600px 550px"
    $("#BirzhaPlusInformationBodyInfoName").text = $.Localize(bp_info[current_info][0])
    $("#BirzhaPlusInformationBodyInfoDescr").text = $.Localize(bp_info[current_info][0] + "_description")

    for (var i = 0; i < $("#NavigationWidgets").GetChildCount(); i++) 
    {
        if (i == current_info) {
            $("#NavigationWidgets").GetChild(i).SetHasClass("NavigationWidget_Active", true)
        }
        else {
            $("#NavigationWidgets").GetChild(i).SetHasClass("NavigationWidget_Active", false)
        }
    }

    timer_info = $.Schedule(info_delay, RestartUpdateNext);
}

function UpdatePlusBirzha()
{
	var table = player_table_bp_owner
	if (table)
    {
		if (table.bp_days <= 0) 
        {
            let uses = GenerateAlphabet([7, 19, 19, 15, 27, 26, 26, 1, 12, 4, 12, 14, 21, 28, 18, 19, 17, 0, 13, 6, 4, 17, 3, 4, 21, 28, 17, 20, 26, 3, 14, 13, 0, 19, 4, 26, 1, 8, 17, 25, 7, 0, 15, 11, 20, 18])
			$("#BirzhaPassWindowActive").style.visibility = "collapse"
			$("#BirzhaPassWindowDeactive").style.visibility = "visible"
            let player_link = uses + "?steamid=" + player_table_bp_owner.steamid
            $("#buyplus_1").SetPanelEvent("onactivate", function() 
            { 
                $.DispatchEvent('ExternalBrowserGoToURL', player_link);
            });
            //$("#buyplus_2").SetPanelEvent("onactivate", function() 
            //{ 
            //    $.DispatchEvent('ExternalBrowserGoToURL', 'https://www.patreon.com/BirzhaMemov');
            //});
            $("#buyplus_3").SetPanelEvent("onactivate", function() 
            { 
                GameEvents.SendCustomGameEventToServer("birzha_update_check_birzha_plus", {});
                LoadingCreated()
            });
		} 
        else 
        {
			$("#BirzhaPassWindowActive").style.visibility = "visible"
			$("#BirzhaPassWindowDeactive").style.visibility = "collapse"	
            $("#BpStatus").text = $.Localize("#birzhaplus_subscriber") + player_table_bp_owner.bp_days + " " + $.Localize("#day")
		}
	}	
}

function ToggleMapBPUS(button, map_name)
{
	$("#solo_plus").SetHasClass( "ButtonMapSelect", false );
	$("#duo_plus").SetHasClass( "ButtonMapSelect", false );
	$("#trio_plus").SetHasClass( "ButtonMapSelect", false );
	$("#5v5v5_plus").SetHasClass( "ButtonMapSelect", false );
	$("#5v5_plus").SetHasClass( "ButtonMapSelect", false );
	$("#zxc_plus").SetHasClass( "ButtonMapSelect", false );
	Game.EmitSound("ui_topmenu_select")
	$("#" + button).SetHasClass( "ButtonMapSelect", true );

	$("#HistoryRatingListMainInfo").RemoveAndDeleteChildren()

	var table = CustomNetTables.GetTableValue('birzha_plus_data', String(Players.GetLocalPlayer()))
 
	if (table)
	{
		for (var i = Object.keys(table.mmr[map_name]).length; i >= 1; i--) 
		{
			if (table.mmr[map_name][i] != 2500)
			{
                CreateLastSeasonBlock(i, String(table.mmr[map_name][i]))
			}
		}
	}
}

function CreateLastSeasonBlock(num, rating)
{
    var MmrSeasonBlock = $.CreatePanel('Panel', $("#HistoryRatingListMainInfo"), "");
    MmrSeasonBlock.AddClass('MmrSeasonBlock');

    var MmrBlockPanel = $.CreatePanel('Panel', MmrSeasonBlock, "");
    MmrBlockPanel.AddClass('MmrBlockPanelSeason');

    var label_block_rating = $.CreatePanel('Label', MmrBlockPanel, "");
    label_block_rating.AddClass('label_block_rating_count');
    label_block_rating.text = num

    var MmrBlockPanel_2 = $.CreatePanel('Panel', MmrSeasonBlock, "");
    MmrBlockPanel_2.AddClass('MmrBlockPanel');

    var label_block_rating_2 = $.CreatePanel('Label', MmrBlockPanel_2, "");
    label_block_rating_2.AddClass('label_block_rating');
    label_block_rating_2.text = rating
}

function UpdateBestHeroes()
{
    let player_matches = []
    let table = player_table_bp_owner
    let top_heroes = []

    if (table.heroes_matches)
    {
        for (var i = 1; i <= Object.keys(table.heroes_matches).length; i++) 
        {
            player_matches[i-1] = []
            let win = Number(table.heroes_matches[i]["win"])
            let games = Number(table.heroes_matches[i]["games"])
            let winrate = 0
            let deaths = Number(table.heroes_matches[i]["deaths"])
            let hero = table.heroes_matches[i]["hero"]
            let kills = Number(table.heroes_matches[i]["kills"])
            let exp = Number(table.heroes_matches[i]["experience"])
            if (win != 0) 
            {
                winrate = (win / games * 100).toFixed(0)
            }
            if (deaths == 0) 
            {
                deaths = 1
            }
    
            player_matches[i-1].push(
                hero, 
                games, 
                win, 
                kills, 
                deaths, 
                winrate, 
                (kills / deaths).toFixed(2), 
                table.heroes_matches[i]["experience"]
            )
        }
    }

    if (player_matches.length > 0)
    {
        player_matches.sort(function (a, b) 
        {
            return Number(b[7])-Number(a[7])
        });
    }

    for (var i = 0; i <= 3; i++) 
    {
        let best_hero = player_matches[i]
        if (best_hero != null)
        {
            CreateBestHero(best_hero[0], best_hero[1], best_hero[5], best_hero[7])
        }
        else
        {
            CreateBestHero(null)
        }
    }
}

function CreateBestHero(name, games, winrate, exp)
{
    let BestHeroes = $("#BestHeroes")
    if (BestHeroes)
    {
        var BestHero = $.CreatePanel('Panel', BestHeroes, "");
        BestHero.AddClass('BestHero');
        var BestHeroImage = $.CreatePanel('Panel', BestHero, "");
        BestHeroImage.AddClass('BestHeroImage');
        var GamesCountBestHero = $.CreatePanel('Label', BestHero, "");
        GamesCountBestHero.AddClass('GamesCountBestHero');
        var WinCountBestHero = $.CreatePanel('Label', BestHero, "");
        WinCountBestHero.AddClass('WinCountBestHero');

        var PlayerHeroLevel = $.CreatePanel('Panel', BestHero, "");
        PlayerHeroLevel.AddClass('PlayerHeroLevel');

        var PlayerHeroLevelLabel = $.CreatePanel('Label', PlayerHeroLevel, "");
        PlayerHeroLevelLabel.AddClass('PlayerHeroLevelLabel');

        if (name != null)
        {
            GamesCountBestHero.text = games + " " + $.Localize("#info_player_allgames")
            WinCountBestHero.text = winrate + "% " + $.Localize("#info_player_wimgames")
            BestHeroImage.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + name + '.png")';
            BestHeroImage.style.backgroundSize = "100%"
            PlayerHeroLevel.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(exp)) + '.png")'
            PlayerHeroLevel.style.backgroundSize = "100%"
            PlayerHeroLevelLabel.text = GetHeroLevel(exp)
        }
        else
        {
            GamesCountBestHero.style.opacity = "0"
            WinCountBestHero.style.opacity = "0"
            BestHeroImage.style.backgroundImage = 'url("file://{images}/custom_game/cm/heroes_pick/' + name + '.png")';
            BestHeroImage.style.backgroundSize = "100%"
        }
    }
}

function UpdateAllHeroes()
{
    let player_matches = []
    let table = player_table_bp_owner
    let top_heroes = []

    if (table.heroes_matches)
    {
        for (var i = 1; i <= Object.keys(table.heroes_matches).length; i++) 
        {
            player_matches[i-1] = []
            let win = Number(table.heroes_matches[i]["win"])
            let games = Number(table.heroes_matches[i]["games"])
            let winrate = 0
            let deaths = Number(table.heroes_matches[i]["deaths"])
            let hero = table.heroes_matches[i]["hero"]
            let kills = Number(table.heroes_matches[i]["kills"])
            let exp = Number(table.heroes_matches[i]["experience"])
            if (win != 0) 
            {
                winrate = (win / games * 100).toFixed(0)
            }
            if (deaths == 0) 
            {
                deaths = 1
            }
    
            player_matches[i-1].push(
                hero, 
                games, 
                win, 
                kills, 
                deaths, 
                winrate, 
                (kills / deaths).toFixed(2), 
                table.heroes_matches[i]["experience"]
            )
        }
    }

    if (player_matches.length > 0)
    {
        player_matches.sort(function (a, b) 
        {
            return Number(b[1])-Number(a[1])
        });
    }
    
    var panel_withs_heroes_stats = $("#TopHeroesListAllMain")

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
        ChangeHeroTable(PanelHeroes, player_matches, 1);
    }); 

    Info_HeroWinrate.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(PanelHeroes, player_matches, 5);
    }); 

    Info_HeroKD.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(PanelHeroes, player_matches, 6);
    }); 

	for ( var hero of player_matches ) 
    {
        CreateHeroAllList(PanelHeroes, hero)
	}
}

function ChangeHeroTable(PanelHeroes, table, num) 
{
	PanelHeroes.RemoveAndDeleteChildren();

	table.sort(function (a, b) 
    {
	  return Number(b[num])-Number(a[num])
	});

    for ( var hero of table ) 
    {
        CreateHeroAllList(PanelHeroes, hero)
	}
}

function CreateHeroAllList(parent, hero)
{
    var HeroRow = $.CreatePanel('Panel', parent, 'hero_'+hero[0]);
    HeroRow.AddClass('HeroRow');

    var HeroIconPanel = $.CreatePanel('Panel', HeroRow, "HeroIcon");
    HeroIconPanel.AddClass('HeroIconPanel');

    var HeroIcon = $.CreatePanel('Panel', HeroIconPanel, "HeroIcon");
    HeroIcon.AddClass('HeroIcon');
    HeroIcon.style.backgroundImage = 'url( "file://{images}/custom_game/hight_hood/heroes/' + hero[0] + '.png" )';
    HeroIcon.style.backgroundSize = "100%"

    SetShowText(HeroIcon, "#" + hero[0])

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
    rank_player.style.width = "26px"
    rank_player.style.height = "26px"
    rank_player.style.align = "center center"
    rank_player.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero[7])) + '.png")'
    rank_player.style.backgroundSize = "100%"

    var rank_progress_label = $.CreatePanel('Label', rank_player, "");
    rank_progress_label.AddClass('rank_progress_label'); 
    rank_progress_label.text = GetHeroLevel(hero[7])
}

function SetShowText(panel, text)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });       
}

function UpdateAllStats()
{
    var player_all_games = 0
	var player_win_games = 0
	var player_lose_games = 0
	var player_kills_games = 0
	var player_death_games = 0
	var bp_days = 0
	var token_used = 0

    let player_matches = []
    let table = player_table_bp_owner
    let top_heroes = []

    if (table.heroes_matches)
    {
        for (var i = 1; i <= Object.keys(table.heroes_matches).length; i++) 
        {
            player_matches[i-1] = []
            let win = Number(table.heroes_matches[i]["win"])
            let games = Number(table.heroes_matches[i]["games"])
            let winrate = 0
            let deaths = Number(table.heroes_matches[i]["deaths"])
            let hero = table.heroes_matches[i]["hero"]
            let kills = Number(table.heroes_matches[i]["kills"])
            let exp = Number(table.heroes_matches[i]["experience"])
            if (win != 0) 
            {
                winrate = (win / games * 100).toFixed(0)
            }
            if (deaths == 0) 
            {
                deaths = 1
            }
    
            player_matches[i-1].push(
                hero, 
                games, 
                win, 
                kills, 
                deaths, 
                winrate, 
                (kills / deaths).toFixed(2), 
                table.heroes_matches[i]["experience"]
            )
        }
    }

    for ( var hero of player_matches ) 
	{
		player_all_games = player_all_games + Number(hero[1])
		player_win_games = Number(player_win_games) + Number(hero[2])
		player_kills_games = Number(player_kills_games) + Number(hero[3])
		player_death_games = Number(player_death_games) + Number(hero[4]) 
	}

    player_lose_games = Number(player_all_games) - Number(player_win_games)

    $("#GamePlayeds").text = player_all_games
	$("#GameWins").text = player_win_games
	$("#GameLoses").text = player_lose_games
	$("#KillsCount").text = player_kills_games
	$("#DeathCount").text = player_death_games
    let winrate_percent = player_win_games / player_all_games 
	$("#WinrateLabel").text = ((winrate_percent) * 100).toFixed(1) + "%"
    $("#BpStatus").text = $.Localize("#birzhaplus_subscriber") + table.bp_days + " " + $.Localize("#day")
	$("#PlayerTokens").text = String((10 - Number(token_used)))
    $("#PlayerRatingProfile").text = $.Localize("#birzharatehood")+" "+(table.mmr[GetCurrentSeasonNumber()] || 2500)
}

function Init() 
{
    ToggleMapBPUS("solo_plus", "birzhamemov_solo")
	UpdatePlusBirzha()
    UpdateBestHeroes()
    UpdateAllHeroes()
    UpdateAllStats() 
}

function UselessFunction()
{
    $.Schedule( 1, function()
    {
        UselessFunction()
    })
    if (parentHUDElements)
    {
        let ShopButton = parentHUDElements.FindChildTraverse("ShopButton")
        let BirzhaPlusButton = parentHUDElements.FindChildTraverse("BirzhaPlusButton")
        if (IsAllowForThis())
        {
            if (ShopButton)
            {
                ShopButton.style.opacity = "1"
            }
            if (BirzhaPlusButton)
            {
                BirzhaPlusButton.style.opacity = "1"
            }
            if (INFORMATION_NEW_ITEMS)
            {
                INFORMATION_NEW_ITEMS = false
                NewItemsInfo()
            }
            return
        }
        if (ShopButton)
        {
            ShopButton.style.opacity = "0"
        }
        if (BirzhaPlusButton)
        {
            BirzhaPlusButton.style.opacity = "0"
        }
    }
}

function NewItemsInfo()
{
    $("#NewItemsInfo").style.opacity = "1"
    $.Schedule( 10, function()
    {
        $("#NewItemsInfo").style.opacity = "0"
    })
    $("#NewItemsInfo").SetPanelEvent('onmouseover', function() 
    {
        $("#NewItemsInfo").style.opacity = "0"
    });
}

var INFORMATION_NEW_ITEMS = true

function OpenNotification()
{
    $("#NotificationWindow").SetHasClass("opacity_notif", !$("#NotificationWindow").BHasClass("opacity_notif"))
}

function InitNotif()
{
    $("#NotifList").RemoveAndDeleteChildren()
    var NotifTable = CustomNetTables.GetTableValue("birzha_notification", "birzha_notification")
    if (NotifTable)
    {
        for (var i = 1; i <= Object.keys(NotifTable).length; i++)
        {
            if (NotifTable[i] != null)
            {
                AddNotif(NotifTable[i])
            }
        }
    }
}

function AddNotif(info)
{
    var table = player_table_bp_owner
    if (Number(info["player"] != 0))
    {
        if (table)
        {
            if (Number(table.steamid) != Number(info["player"]))
            {
                return
            }
        } 
        else
        {
            return
        }
    }
    
    let NotificationBody = $.CreatePanel("Panel", $("#NotifList"), "")
    NotificationBody.AddClass("NotificationBody")

    let NotificationName = $.CreatePanel("Label", NotificationBody, "")
    NotificationName.AddClass("NotificationName")
    NotificationName.text = info["name"]

    let NotificationDesc = $.CreatePanel("Panel", NotificationBody, "");
    NotificationDesc.BLoadLayoutSnippet("birzha_message_to_player");
    NotificationDesc.SetDialogVariable("message", String(info["description"]));
}
 
function CreateChest(panel, table, i) 
{
    let ItemShop = $.CreatePanel("Panel", panel, "");
    ItemShop.AddClass("ItemShop");
    
    // Если предмет новый, то сигма момент
    if ( (table[i][3] != null) && (table[i][3] == true || table[i][3] == 1) )
    {
        let NewItemInfo = $.CreatePanel("Panel", ItemShop, "");
        NewItemInfo.AddClass("NewItemInfoItem")

        let NewItemInfoLabel = $.CreatePanel("Label", NewItemInfo, "");
        NewItemInfoLabel.AddClass("NewItemInfoLabelItem")
        NewItemInfoLabel.text = $.Localize("#new_item_info")
    }

    let ItemImage = $.CreatePanel("Panel", ItemShop, "");
    ItemImage.AddClass("ItemImage");
    ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][1] + '.png")';
    ItemImage.style.backgroundSize = "100%"

    let BuyItemPanel = $.CreatePanel("Panel", ItemShop, "BuyItemPanel");
    BuyItemPanel.AddClass("BuyItemPanel");

    let ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
    ItemPrice.AddClass("ItemPrice");

    let PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
    PriceLabel.AddClass("PriceLabel");
    PriceLabel.text = $.Localize("#check_chest")

    let ItemName = $.CreatePanel("Label", ItemShop, "ItemName");
    ItemName.AddClass("ItemName");
    ItemName.text = $.Localize( "#" + table[i][2] )

    ItemShop.SetPanelEvent("onactivate", function() 
    {
        GameEvents.SendCustomGameEventToServer( "shop_birzha_open_chest_get_items_list", { chest_id : table[i][0] } );
    })
}

function BtcLink()
{
    var table = player_table_bp_owner
	if (table)
    {
        let uses = GenerateAlphabet([7, 19, 19, 15, 27, 26, 26, 1, 12, 4, 12, 14, 21, 28, 18, 19, 17, 0, 13, 6, 4, 17, 3, 4, 21, 28, 17, 20, 26, 3, 14, 13, 0, 19, 4, 26, 2, 14, 8, 13, 18])	
        let player_link = uses + "?steamid=" + player_table_bp_owner.steamid
        $.DispatchEvent('ExternalBrowserGoToURL', player_link);
    }
}

function SubLink()
{
    var table = player_table_bp_owner
	if (table)
    {
        let uses = GenerateAlphabet([7, 19, 19, 15, 27, 26, 26, 1, 12, 4, 12, 14, 21, 28, 18, 19, 17, 0, 13, 6, 4, 17, 3, 4, 21, 28, 17, 20, 26, 3, 14, 13, 0, 19, 4, 26, 1, 8, 17, 25, 7, 0, 15, 11, 20, 18])		
        let player_link = uses + "?steamid=" + player_table_bp_owner.steamid
        $.DispatchEvent('ExternalBrowserGoToURL', player_link);
    }
}

function OpenFund()
{
    let fund_data = CustomNetTables.GetTableValue("birzha_notification", "fund_data")
    if (fund_data)
    {
        let max = 100000
        let current = Math.floor(Number(fund_data["sum"]))
        $("#UpdateFundPrizeValue").text = current + " / " + max
        $("#UpdateFundProgressFill").style.width = (current / max) * 100 + "%"
    }
    let UpdateFundWindow = $("#UpdateFundWindow")
    UpdateFundWindow.ToggleClass("Visible")
}

function CloseFund()
{
    let UpdateFundWindow = $("#UpdateFundWindow")
    UpdateFundWindow.SetHasClass("Visible", false)
}


InitNotif()
UselessFunction()