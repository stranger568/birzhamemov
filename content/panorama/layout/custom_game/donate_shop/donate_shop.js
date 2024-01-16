var parentHUDElements = FindDotaHudElement("HUDElements").FindChildTraverse("MenuButtons");

// --------------------- Buttons init ---------------------------
if (parentHUDElements)
{
	if ($("#ShopButton")) 
    {
		if (parentHUDElements.FindChildTraverse("ShopButton"))
        {
			$("#ShopButton").DeleteAsync( 0 );
		} else {
			$("#ShopButton").SetParent(parentHUDElements);
		}
	}
	if ($("#BirzhaPlusButton")) 
    {
		if (parentHUDElements.FindChildTraverse("BirzhaPlusButton")){
			$("#BirzhaPlusButton").DeleteAsync( 0 );
		} else {
			$("#BirzhaPlusButton").SetParent(parentHUDElements);
		}
	}
}

// ---------------------------------------------------------------

// --------------------- Smiles Init ---------------------------
var dotaHudChatControls = FindDotaHudElement("ChatControls");
$("#SmilesButton").SetParent(dotaHudChatControls);
dotaHudChatControls.MoveChildBefore(dotaHudChatControls.FindChildTraverse("SmilesButton"), dotaHudChatControls.FindChildTraverse("ChatEmoticonButton"))
dotaHudChatControls.FindChildTraverse("ChatEmoticonButton").style.visibility = "collapse"
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
            player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
		}
	}
}

function UpdatePlayerPassTable(table, key, data ) 
{
	if (table == "birzhainfo") 
	{
		if (key == Players.GetLocalPlayer()) 
        {
            player_table_bp_owner = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
		}
	}
}
// ---------------------------------------------------------------

// --------------------- vars init ---------------------------
var sound_preview = null;
var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";
var subscribe_buy = false
var timer_loading = -1
var button_donate_link_1 = "https://www.patreon.com/BirzhaMemov"
var button_donate_link_3 = "https://bmemov.strangerdev.ru/donate/coins/"
// ---------------------------------------------------------------

// --------------------- Events init ---------------------------
GameEvents.Subscribe( 'set_player_pet_from_data', set_player_pet_from_data ); 
GameEvents.Subscribe( 'set_player_border_from_data', set_player_border_from_data ); 
GameEvents.Subscribe( 'shop_set_currency', SetCurrency );
GameEvents.Subscribe( 'shop_error_notification', ErrorCreated );
GameEvents.Subscribe( 'shop_accept_notification', AcceptCreated );
// ---------------------------------------------------------------

function ToggleShop() {
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
				InitInventory()
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
	$("#CouriersContainer").style.visibility = "collapse";
	$("#EffectsContainer").style.visibility = "collapse";
	$("#BannersContainer").style.visibility = "collapse";
	$("#ChatWheelBirzhaContainer").style.visibility = "collapse";

	$("#DonateMainButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateItemsButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateCouriersButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateEffectsButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateBannersButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#ChatWheelBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );

	Game.EmitSound("ui_topmenu_select")

	$("#" + button).SetHasClass( "DonateNewMenuButtonSelected", true );

	$("#" + tab).style.visibility = "visible";
}

function SwitchShopTab(tab, button) 
{
	$("#AllDonateItems").style.visibility = "collapse";
	$("#DogeCoinsItems").style.visibility = "collapse";
	$("#PetsDonateItems").style.visibility = "collapse";
	$("#HeroesDonateItems").style.visibility = "collapse";
	$("#EffectsDonateItems").style.visibility = "collapse";
	$("#CurrencysDonateItems").style.visibility = "collapse";
	$("#SoundsDonateItems").style.visibility = "collapse";
	$("#SpraysonateItems").style.visibility = "collapse";
	$("#BorderDonateItems").style.visibility = "collapse";
	$("#ToysDonateItems").style.visibility = "collapse";

	for (var i = 0; i < $("#MenuItems").GetChildCount(); i++) 
	{
		$("#MenuItems").GetChild(i).SetHasClass("selected_menu_shop", false)
	}

	Game.EmitSound("ui_select_md")

	$("#" + button).SetHasClass("selected_menu_shop", true)

	$("#" + tab).style.visibility = "visible";
}


function InitMainPanel() {
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
	$('#AllDonateItems').RemoveAndDeleteChildren()
	$('#HeroesDonateItems').RemoveAndDeleteChildren()
	$('#PetsDonateItems').RemoveAndDeleteChildren()
	$('#EffectsDonateItems').RemoveAndDeleteChildren()
	$('#CurrencysDonateItems').RemoveAndDeleteChildren()
	$('#SoundsDonateItems').RemoveAndDeleteChildren()
	$('#SpraysonateItems').RemoveAndDeleteChildren()
	$('#BorderDonateItems').RemoveAndDeleteChildren()
	$('#DogeCoinsItems').RemoveAndDeleteChildren()
	$('#ToysDonateItems').RemoveAndDeleteChildren()

	Items_pets.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	Items_effects.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	Items_heroes.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	Items_sounds.sort(function (a, b) 
	{
	  	return Number(b[6])-Number(a[6])
	});

	Items_dogecoins.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	Items_borders.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	Items_sprays.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	Items_toys.sort(function (a, b) 
	{
	  	return Number(a[2])-Number(b[2])
	});

	for (var i = 0; i < Items_heroes.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_heroes, i)
		CreateItemInShop($('#HeroesDonateItems'), Items_heroes, i)
	}

	for (var i = 0; i < Items_pets.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_pets, i)
		CreateItemInShop($('#PetsDonateItems'), Items_pets, i)
	}

	for (var i = 0; i < Items_effects.length; i++) {
 		CreateItemInShop($('#AllDonateItems'), Items_effects, i)
 		CreateItemInShop($('#EffectsDonateItems'), Items_effects, i)
	}

	for (var i = 0; i < Items_sounds.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_sounds, i)
		CreateItemInShop($('#SoundsDonateItems'), Items_sounds, i)
	}

	for (var i = 0; i < Items_sprays.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_sprays, i)
		CreateItemInShop($('#SpraysonateItems'), Items_sprays, i)
	}

	for (var i = 0; i < Items_borders.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_borders, i)
		CreateItemInShop($('#BorderDonateItems'), Items_borders, i)
	}

	for (var i = 0; i < Items_toys.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_toys, i)
		CreateItemInShop($('#ToysDonateItems'), Items_toys, i)
	}

	for (var i = 0; i < Items_dogecoins.length; i++) {
		CreateItemInShop($('#DogeCoinsItems'), Items_dogecoins, i)
	}

	for (var i = 0; i < Items_currency.length; i++) {
 		CreateItemInShop($('#CurrencysDonateItems'), Items_currency, i)
	}
}

function InitInventory() 
{
	$('#CouriersPanel').RemoveAndDeleteChildren()
	$('#EffectsPanel').RemoveAndDeleteChildren()
	$('#BannersPanel').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_pets.length; i++) 
    {
		CreateItemInInventory($('#CouriersPanel'), Items_pets, i)
	}
	for (var i = 0; i < Items_effects.length; i++) {
 		CreateItemInInventory($('#EffectsPanel'), Items_effects, i)
	}
	for (var i = 0; i < Items_borders.length; i++) {
 		CreateItemInInventory($('#BannersPanel'), Items_borders, i)
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

    if (table[i][0] == "21" || table[i][0] == "135") 
    {
        if (player_table_bp_owner)
        {
            if (player_table_bp_owner.bp_days > 0 || subscribe_buy) 
            {
                Recom_item.SetPanelEvent("onactivate", function() {} );
                BuyItemPanel.SetHasClass("item_buying", true)
				PriceLabel.text = $.Localize( "#shop_bought" )
				PriceIcon.style.visibility = "collapse" 
            }
            else
            {
                PriceLabel.text = table[i][2]
            }
        }
    }
    else if (HasItemInventory(table[i][0]))
    {
        Recom_item.SetPanelEvent("onactivate", function() {} );
        BuyItemPanel.SetHasClass("item_buying", true)
        PriceLabel.text = $.Localize( "#shop_bought" )
        PriceIcon.style.visibility = "collapse"
    }
    else
    {
        PriceLabel.text = table[i][2]
    }
}

function CreateItemInShop(panel, table, i) 
{
    if (table[i][7] != null)
    {
        return
    }

    var Recom_item = $.CreatePanel("Panel", panel, "");
    Recom_item.AddClass("ItemShop");
    SetItemBuyFunction(Recom_item, table[i])

    if ( (table[i][6] != null) && (table[i][6] == true || table[i][6] == 1) )
    {
        var NewItemInfo = $.CreatePanel("Panel", Recom_item, "");
        NewItemInfo.AddClass("NewItemInfoItem");
        var NewItemInfoLabel = $.CreatePanel("Label", NewItemInfo, "");
        NewItemInfoLabel.AddClass("NewItemInfoLabelItem"); 
        NewItemInfoLabel.text = $.Localize("#new_item_info")
    }

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
    PriceLabel.text = table[i][2]

    var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
    ItemName.AddClass("ItemName");
    ItemName.text = $.Localize( "#" + table[i][4] )

    if (table[i][0] == "21" || table[i][0] == "135") 
    {
        if (player_table_bp_owner)
        {
            if (player_table_bp_owner.bp_days > 0 || subscribe_buy) 
            {
                Recom_item.SetPanelEvent("onactivate", function() {} );
                BuyItemPanel.SetHasClass("item_buying", true)
				PriceLabel.text = $.Localize( "#shop_bought" )
				PriceIcon.style.visibility = "collapse" 
            }
        }
    }
    else if (HasItemInventory(table[i][0]))
    {
        Recom_item.SetPanelEvent("onactivate", function() {} );
        BuyItemPanel.SetHasClass("item_buying", true)
        PriceLabel.text = $.Localize( "#shop_bought" )
        PriceIcon.style.visibility = "collapse"
    }
    else
    {
        PriceLabel.text = table[i][2]
    }
}

function CreateItemInInventory(panel, table, i) 
{
    (HasItemInventory(table[i][0]))
    {
        var Recom_item = $.CreatePanel("Panel", panel, "item_inventory_" + table[i][0]);
        Recom_item.AddClass("ItemInventory");
        SetItemInventory(Recom_item, table[i])

        var ItemImage = $.CreatePanel("Panel", Recom_item, "");
        ItemImage.AddClass("ItemImage");
        ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
        ItemImage.style.backgroundSize = "100%"

        var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
        ItemName.AddClass("ItemName");
        ItemName.text = $.Localize( "#" + table[i][4] )

        if ( (table[i][4].indexOf("pet") == 0) || (table[i][4].indexOf("border") == 0) )  
        {
            var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
            BuyItemPanel.AddClass("BuyItemPanel");

            var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
            ItemPrice.AddClass("ItemPrice");

            var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
            PriceLabel.AddClass("PriceLabel");
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
            if ((table[i][4].indexOf("border") == 0))
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

            UpdateItemActivate(table[i][0])	
        }
    }
}

function CloseItemInfo()
{
  	$("#info_item_buy").style.visibility = "collapse"
  	$("#ItemInfoBody").RemoveAndDeleteChildren()
    if (sound_preview != null)
    {
        Game.StopSound(sound_preview)
        sound_preview = null
    }
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
    		if (table[4].indexOf("sounds") == 0)
            {
    			sound_preview = Game.EmitSound("item_wheel_"+table[0])
    		}

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

            let player_link = button_donate_link_3 + "?steamid=" + player_table_bp_owner.steamid

			$.CreatePanel("Panel", column_1, "PatreonButton", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_1});` });
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
	if (table[4].indexOf("pet") == 0) {
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectCourier(table[0])
	    });
	}
	if (table[4].indexOf("border") == 0) {
		panel.SetPanelEvent("onactivate", function() { 
	 		SelectBorder(table[0])
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
    		$("#CouriersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	$("#CouriersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
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
    	for (var i = 0; i < $("#EffectsPanel").GetChildCount(); i++) {
    		$("#EffectsPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	$("#EffectsPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
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
    	for (var i = 0; i < $("#BannersPanel").GetChildCount(); i++) {
    		$("#BannersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").SetHasClass("item_deactive", false)
        	$("#BannersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
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

//////////// ФУНКЦИЯ ПОКУПКИ /////////

function BuyItemFunction(panel, table) 
{
	if ((typeof player_table.doge_coin !== 'undefined') && (typeof player_table.birzha_coin !== 'undefined')) 
    {
		if (table[1] == "gold") 
        {
			GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			LoadingCreated()
		} 
        else if (table[1] == "gem") 
        {
			GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			LoadingCreated()
		}

		if (!table[5]) 
        {
			if (panel.id != "buyplus_1" && panel.id != "buyplus_2")
			{
				panel.SetPanelEvent("onactivate", function() {} );
				panel.FindChildTraverse("BuyItemPanel").SetHasClass("item_buying", true)
				panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_bought" )
				panel.FindChildTraverse("PriceIcon").DeleteAsync( 0 );
			}
		    if (table[0] == "21") 
            {
		    	subscribe_buy = true
		    }
		    if (table[0] == "135") 
            {
		    	subscribe_buy = true
		    }
		}
	}
	$.Schedule( 0.25, function()
    {
		InitMainPanel()
		InitItems()
		InitInventory()
	})
}

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПРИ ПЕРВОМ ОТКРЫТИИ /////////
function SetMainCurrency() 
{
	if ((typeof player_table.doge_coin !== 'undefined') && (typeof player_table.birzha_coin !== 'undefined')) 
    {
		$("#Currency").text = String(player_table.birzha_coin)
		$("#Currency2").text = 	String(player_table.doge_coin)	
	}
} 

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПОСЛЕ ПОКУПКИ /////////
function SetCurrency(data) 
{
	if (data) {
		if (typeof data.bitcoin !== 'undefined') {
			$("#Currency").text = String(data.bitcoin)
		}
		if (typeof data.dogecoin !== 'undefined') {
			$("#Currency2").text = 	String(data.dogecoin)	
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

    if (data.error_name == "shop_no_bitcoin" || data.error_name == "shop_no_dogecoin")
    {
        SwitchTab('ItemsContainer', 'DonateItemsButton');
        SwitchShopTab('CurrencysDonateItems', 'CurrencyButton');
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

function UpdateItemActivate(id) {
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
    $("#BPCostBig").text = "Price $2"

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
			$("#BirzhaPassWindowActive").style.visibility = "collapse"
			$("#BirzhaPassWindowDeactive").style.visibility = "visible"
            let player_link = "https://bmemov.strangerdev.ru/donate/birzhaplus/" + "?steamid=" + player_table_bp_owner.steamid
            $("#buyplus_1").SetPanelEvent("onactivate", function() 
            { 
                $.DispatchEvent('ExternalBrowserGoToURL', player_link);
            });
            $("#buyplus_2").SetPanelEvent("onactivate", function() 
            { 
                $.DispatchEvent('ExternalBrowserGoToURL', 'https://www.patreon.com/BirzhaMemov');
            });
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

var toggle_smiles = false;
var cooldown_panel_smiles = false

function ToggleSmiles() {
    if (toggle_smiles === false) {
        if (cooldown_panel_smiles == false) {
            toggle_smiles = true;
            if ($("#SmilesWindow").BHasClass("sethidden")) {
                $("#SmilesWindow").RemoveClass("sethidden");
            }
            InitSmiles()
            $("#SmilesWindow").AddClass("setvisible");
            $("#SmilesWindow").style.visibility = "visible"
            cooldown_panel_smiles = true
            $.Schedule( 0.503, function(){
                cooldown_panel_smiles = false
            })
        }
    } else {
        if (cooldown_panel_smiles == false) {
            toggle_smiles = false;
            if ($("#SmilesWindow").BHasClass("setvisible")) {
                $("#SmilesWindow").RemoveClass("setvisible");
            }
            $("#SmilesWindow").AddClass("sethidden");
            cooldown_panel_smiles = true
            $.Schedule( 0.503, function(){
                cooldown_panel_smiles = false
                $("#SmilesWindow").style.visibility = "collapse"
            })
        }
    }
}

CheckSmileContainer()

function CheckSmileContainer()
{
    var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("HudChat");
    if (parentHUDElements && !parentHUDElements.BHasClass("Active"))
    {
       if (toggle_smiles == true)
       {
            ToggleSmiles()
       } 
    }
    $.Schedule(0.1, CheckSmileContainer)
}

function InitSmiles()
{
    $("#SmilesWindow").RemoveAndDeleteChildren()
    for (var i = 0; i < smiles.length; i++) {
        CreateSmiles(smiles[i])
    }
}

function CreateSmiles(smile_table)
{
    let SmileBlock = $.CreatePanel("Panel", $("#SmilesWindow"), "");
    SmileBlock.AddClass("SmileBlock");

    let SmileIcon = $.CreatePanel("Panel", SmileBlock, "");
    SmileIcon.AddClass("SmileIcon");
    SmileIcon.style.backgroundImage = 'url("file://{images}/custom_game/smiles/' + smile_table[1] + '.png")';
    SmileIcon.style.backgroundSize = "100%"

    var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
	var player_table_js = []

	for (var d = 1; d < 300; d++) {
		player_table_js.push(player_table.player_items[d])
	}

    let smile_deactivate = true
    
    for ( let item of player_table_js )
    {
        if (item == smile_table[0]) {
            smile_deactivate = false
            break
        }
    }

    if (smile_deactivate)
    {
        let blocked = $.CreatePanel("Panel", SmileBlock, "" );
        blocked.AddClass("BlockSmile");
    } else {
        SmileBlock.SetPanelEvent("onactivate", function() { 
            GameEvents.SendCustomGameEventToServer("SelectSmile", {id : smile_table[0], smile_icon : smile_table[1]});
        } );
    }
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
        var player_table = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()))
        if (player_table)
        {
            if (player_table.games > 1)
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

UselessFunction()