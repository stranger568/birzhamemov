var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");
if ($("#ShopButton")) {
	if (parentHUDElements.FindChildTraverse("ShopButton")){
		$("#ShopButton").DeleteAsync( 0 );
	} else {
		$("#ShopButton").SetParent(parentHUDElements);
	}
}

var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";
var subscribe_buy = false

//////////ССЫЛКИ НА КНОПКИ С ДОНАТОМ ПРИ ПОКУПКЕ ВАЛЮТЫ///////////

var button_donate_link_1 = "https://www.patreon.com/BirzhaMemov"
var button_donate_link_2 = ""
var button_donate_link_3 = "https://bmemov.ru/donate/bitcoins/"

	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)

var Items_recomended = [
	["21", "gold", "300", "subscribe", "subscribe_1", false],
	["34", "gold", "500", "item_for_sobolev", "item_for_sobolev", false],
	["29", "gold", "2500", "item_for_papich", "item_for_papich", false],
	["33", "gold", "2500", "item_for_druzhko", "item_for_druzhko", false],
	["27", "gold", "2500", "item_for_never", "item_for_never", false],
]

//////////МАССИВ ОКОШЕК НА ГЛАВНОЙ///////////

var Items_ADS = [
	["ads_name_1", "new_item"],
	["ads_name_2", "birzhaplus"], // переменная названия в локализации, ИКОНКА(именно название png файла)
]

//
//////////МАССИВ ПИТОМЦЕВ///////////

var Items_dogecoins = [

]

//////////МАССИВ ПИТОМЦЕВ///////////

var Items_pets = [
	["1", "gold", "100", "pet_1", "pet_1", false], 
	["2", "gem", "150", "pet_2", "pet_2", false],
	["3", "gem", "150", "pet_3", "pet_3", false],
	["4", "gold", "200", "pet_4", "pet_4", false],
	["5", "gold", "200", "pet_5", "pet_5", false],
	["6", "gold", "200", "pet_6", "pet_6", false],
	["7", "gold", "200", "pet_7", "pet_7", false],
	["8", "gold", "500", "pet_8", "pet_8", false],
	["9", "gold", "100", "pet_9", "pet_9", false],
	["10", "gold", "100", "pet_10", "pet_10", false],
	["11", "gold", "200", "pet_11", "pet_11", false],
	["12", "gold", "200", "pet_12", "pet_12", false],
	["13", "gold", "100", "pet_13", "pet_13", false],
	["14", "gold", "100", "pet_14", "pet_14", false],
	["15", "gold", "200", "pet_15", "pet_15", false],
	["16", "gold", "200", "pet_16", "pet_16", false],
	["17", "gold", "50", "pet_17", "pet_17", false],
	["18", "gold", "50", "pet_18", "pet_18", false],
	["19", "gold", "100", "pet_19", "pet_19", false],
]

//////////МАССИВ ЭФФЕКТОВ///////////

var Items_effects = [
	["20", "gem", "250", "particle_1", "particle_1", false],
	["40", "gem", "500", "particle_2", "particle_2", false],
	["41", "gold", "500", "particle_3", "particle_3", false],
	["42", "gold", "500", "particle_4", "particle_4", false],

	["43", "gold", "1000", "particle_5", "particle_5", false],
	["44", "gold", "1000", "particle_6", "particle_6", false],
	["45", "gem", "250", "particle_7", "particle_7", false],
	["46", "gem", "250", "particle_8", "particle_8", false],

	["47", "gem", "250", "particle_9", "particle_9", false],
	["48", "gem", "250", "particle_10", "particle_10", false],
	["49", "gold", "1000", "particle_11", "particle_11", false],
	["50", "gold", "250", "particle_12", "particle_12", false],

	["51", "gold", "250", "particle_13", "particle_13", false],
]

//////////МАССИВ ПОДПИСКИ///////////

var Items_subscribe = [
	["21", "gold", "300", "subscribe", "subscribe_1", false],
	["135", "gold", "1500", "subscribe", "subscribe_2", false],
]


var Items_heroes = [
	["22", "gem", "300", "item_for_scp", "item_for_scp", false],
	["23", "gold", "1000", "item_for_silvername", "item_for_silvername", false],
	["24", "gold", "500", "item_for_gorin", "item_for_gorin", false],
	["25", "gold", "1500", "item_for_fatmum", "item_for_fatmum", false],
	["26", "gold", "2000",  "item_for_kurumi", "item_for_kurumi", false],
	["27", "gold", "2500", "item_for_never", "item_for_never", false],
	["28", "gold", "1500", "item_for_valakas", "item_for_valakas", false],
	["29", "gold", "2500", "item_for_papich", "item_for_papich", false],
	["30", "gold", "600", "item_for_johncena", "item_for_johncena", false],
	["31", "gold", "600", "item_for_jew", "item_for_jew", false],
	["32", "gold", "200", "item_for_poroshenko", "item_for_poroshenko", false],
	["33", "gold", "2500", "item_for_druzhko", "item_for_druzhko", false],
	["34", "gold", "500", "item_for_sobolev", "item_for_sobolev", false],
	["126", "gold", "1500", "item_for_ayano", "item_for_ayano", false],

	["35", "gem", "300", "item_for_knuckles", "item_for_knuckles", false],
	["36", "gem", "600", "item_for_bigrussianboss", "item_for_bigrussianboss", false],
	["37", "gem", "1000", "item_for_versuta", "item_for_versuta", false],
	["38", "gem", "1000", "item_for_robbie", "item_for_robbie", false],
	["39", "gem", "600", "item_for_fatmum_2", "item_for_fatmum_2", false],
	["130", "gem", "2000", "item_for_boy", "item_for_boy", false],
]


//////////МАССИВ ВАЛЮТЫ///////////

var Items_currency = [

	["0", "", "2 $ / 150 Рублей", "donate_2", "donate_bitcoin_1", true], 
	["0", "", "5 $ / 400 Рублей", "donate_5", "donate_bitcoin_2", true],
	["0", "", "10 $ / 800 Рублей", "donate_10", "donate_bitcoin_3", true],
	["0", "", "50 $ / 4000 Рублей", "donate_50", "donate_bitcoin_4", true],

	["0", "gold", "125", "donate_2_2", "Ddonate_dogecoin_1", true], 
	["0", "gold", "625", "donate_5_2", "Ddonate_dogecoin_2", true],
	["0", "gold", "1250", "donate_10_2", "Ddonate_dogecoin_3", true],
	["0", "gold", "6225", "donate_50_2", "Ddonate_dogecoin_4", true],
]

var Items_sounds = [
	["52",  "gem", "100", "sound_1", "sounds_1", false], 
	["53",  "gold", "25", "sound_2", "sounds_2", false], 
	["54",  "gold", "25", "sound_3", "sounds_3", false], 
	["55",  "gem", "50", "sound_4", "sounds_4", false],

	["56",  "gold", "25", "sound_5", "sounds_5", false], 
	["57",  "gold", "25", "sound_6", "sounds_6", false], 
	["58",  "gold", "50", "sound_7", "sounds_7", false], 
	["59",  "gold", "50", "sound_8", "sounds_8", false], 

	["60",  "gold", "50", "sound_9", "sounds_9", false], 
	["61",  "gold", "50", "sound_10", "sounds_10", false], 
	["62",  "gold", "100", "sound_11", "sounds_11", false], 
	["63",  "gem", "25", "sound_12", "sounds_12", false], 

	["64",  "gold", "25", "sound_13", "sounds_13", false], 
	["65",  "gold", "100", "sound_14", "sounds_14", false], 
	["66",  "gold", "25", "sound_15", "sounds_15", false], 
	["67",  "gold", "100", "sound_16", "sounds_16", false],

	["68",  "gold", "100", "sound_17", "sounds_17", false], 
	["69",  "gold", "25", "sound_18", "sounds_18", false], 
	["70",  "gold", "200", "sound_19", "sounds_19", false], 
	["71",  "gold", "50", "sound_20", "sounds_20", false], 

	["72",  "gold", "50", "sound_21", "sounds_21", false], 
	["73",  "gold", "25", "sound_22", "sounds_22", false], 
	["74",  "gold", "200", "sound_23", "sounds_23", false], 
	["75",  "gold", "100", "sound_24", "sounds_24", false],

	["76",  "gold", "50", "sound_25", "sounds_25", false], 
	["77",  "gold", "100", "sound_26", "sounds_26", false], 
	["78",  "gold", "100", "sound_27", "sounds_27", false], 
	["79",  "gold", "100", "sound_28", "sounds_28", false], 

	["80",  "gold", "100", "sound_29", "sounds_29", false], 
	["81",  "gold", "200", "sound_30", "sounds_30", false], 
	["82",  "gold", "300", "sound_31", "sounds_31", false], 
	["83",  "gem", "5", "sound_32", "sounds_32", false], 

	["84",  "gem", "50", "sound_33", "sounds_33", false], 
	["85",  "gem", "50", "sound_34", "sounds_34", false], 
	["86",  "gem", "50", "sound_35", "sounds_35", false], 
	["87",  "gem", "100", "sound_36", "sounds_36", false], 

	["113",  "gold", "300", "sound_37", "sounds_37", false], 
	["114",  "gem", "500", "sound_38", "sounds_38", false], 




	["118",  "gold", "500", "sound", "sounds_39", false], 
	["119",  "gem",  "100", "sound", "sounds_40", false], 
	["120",  "gold", "300", "sound", "sounds_41", false], 
	["121",  "gold", "500", "sound", "sounds_42", false], 
	["122",  "gold", "300", "sound", "sounds_43", false], 
	["123",  "gold", "1000", "sound", "sounds_44", false], 


	["131",  "gold", "100", "sound", "sounds_45", false], 
	["132",  "gold", "50", "sound", "sounds_46", false], 
	["133",  "gold", "200", "sound", "sounds_47", false], 
	["134",  "gold", "200", "sound", "sounds_48", false], 
]

var Items_sprays = [
	["88",  "gem", "50", "spray_1", "spray_1", false], 
	["89",  "gold", "50", "spray_2", "spray_2", false], 
	["90",  "gem", "25", "spray_3", "spray_3", false], 
	["91",  "gem", "25", "spray_4", "spray_4", false], 

	["92",  "gold", "50", "spray_5", "spray_5", false], 
	["93",  "gem", "50", "spray_6", "spray_6", false], 
	["94",  "gold", "50", "spray_7", "spray_7", false], 
	["95",  "gold", "50", "spray_8", "spray_8", false],

	["96",  "gem", "25", "spray_9", "spray_9", false], 
	["97",  "gem", "50", "spray_10", "spray_10", false], 
	["98",  "gold", "50", "spray_11", "spray_11", false], 
	["99",  "gold", "50", "spray_12", "spray_12", false], 

	["100",  "gold", "100", "spray_13", "spray_13", false], 
	["101",  "gem", "50", "spray_14", "spray_14", false], 
	["102",  "gold", "25", "spray_15", "spray_15", false], 
	["103",  "gold", "50", "spray_16", "spray_16", false],

	["104",  "gem", "25", "spray_17", "spray_17", false], 
	["105",  "gem", "50", "spray_18", "spray_18", false], 
	["106",  "gem", "50", "spray_19", "spray_19", false], 
	["107",  "gem", "50", "spray_20", "spray_20", false],

	["108",  "gem", "25", "spray_21", "spray_21", false], 
	["109",  "gem", "25", "spray_22", "spray_22", false], 
	["110",  "gem", "50", "spray_23", "spray_23", false], 
	["111",  "gem", "5", "spray_24", "spray_24", false],  
]

var Items_borders = [ 
	["112",  "gold", "1000", "border_1", "border_1", false], 
	["115",  "gem", "1000", "border_2", "border_2", false], 
	["116",  "gold", "1000", "border_3", "border_3", false], 
	["117",  "gold", "1000", "border_4", "border_4", false], 

	["127",  "gold", "1000", "border_5", "border_5", false], 
	["128",  "gold", "1000", "border_6", "border_6", false], 
	["129",  "gem", "1000", "border_7", "border_7", false], 
]

var Items_toys = [ 
	["124",  "gold", "500", "toys_1", "toys_1", false], 
	["125",  "gem", "1500", "toys_2", "toys_2", false], 
]

for ( var item of Items_pets )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

for ( var item of Items_effects )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

for ( var item of Items_heroes )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

for ( var item of Items_sounds )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

for ( var item of Items_borders )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

for ( var item of Items_sprays )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

for ( var item of Items_toys )
{
	if (item[1] == "gem") {
		Items_dogecoins.push(item);
	}
}

GameEvents.Subscribe( 'set_player_pet_from_data', set_player_pet_from_data ); 
GameEvents.Subscribe( 'set_player_border_from_data', set_player_border_from_data ); 
//
function ToggleShop() {
    if (toggle === false) {
    	if (cooldown_panel == false) {
	        toggle = true;
	        if (first_time === false) {
	            first_time = true;
	            $("#DonateShopPanel").AddClass("sethidden");
	            InitMainPanel()
				InitItems()
				SetMainCurrency()
				InitInventory()
				InitShop()
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

function InitShop() {
	GameEvents.Subscribe( 'shop_set_currency', SetCurrency );
	GameEvents.Subscribe( 'shop_error_notification', ShopError );
}

function SwitchTab(tab, button) {
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

	$("#" + button).SetHasClass( "DonateNewMenuButtonSelected", true );

	$("#" + tab).style.visibility = "visible";
}

function SwitchShopTab(tab, button) {
	$("#AllDonateItems").style.visibility = "collapse";
	$("#DogeCoinsItems").style.visibility = "collapse";
	$("#PetsDonateItems").style.visibility = "collapse";
	$("#HeroesDonateItems").style.visibility = "collapse";
	$("#EffectsDonateItems").style.visibility = "collapse";
	$("#SubscribeDonateItems").style.visibility = "collapse";
	$("#CurrencysDonateItems").style.visibility = "collapse";
	$("#SoundsDonateItems").style.visibility = "collapse";
	$("#SpraysonateItems").style.visibility = "collapse";
	$("#BorderDonateItems").style.visibility = "collapse";
	$("#ToysDonateItems").style.visibility = "collapse";

	for (var i = 0; i < $("#MenuItems").GetChildCount(); i++) {
		$("#MenuItems").GetChild(i).style.boxShadow = "0px 0px 1px 1px black";
	}

	$("#" + button).style.boxShadow = "0px 0px 1px 1px white";

	$("#" + tab).style.visibility = "visible";
}


function InitMainPanel() {
	$('#PopularityRecomDonateItems').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_recomended.length; i++) {
		CreateItemInMain($('#PopularityRecomDonateItems'), Items_recomended, i)
	}
	$("#AdsChests").style.backgroundImage = 'url("file://{images}/custom_game/shop/ads/' + Items_ADS[0][1] + '.png")';
	$("#AdsItem_1").style.backgroundImage = 'url("file://{images}/custom_game/shop/ads/' + Items_ADS[1][1] + '.png")';
	$("#AdsChests").style.backgroundSize = "100% 100%"
	$("#AdsItem_1").style.backgroundSize = "100% 100%"
}

function InitItems() {
	$('#AllDonateItems').RemoveAndDeleteChildren()
	$('#HeroesDonateItems').RemoveAndDeleteChildren()
	$('#PetsDonateItems').RemoveAndDeleteChildren()
	$('#EffectsDonateItems').RemoveAndDeleteChildren()
	$('#SubscribeDonateItems').RemoveAndDeleteChildren()
	$('#CurrencysDonateItems').RemoveAndDeleteChildren()
	$('#SoundsDonateItems').RemoveAndDeleteChildren()
	$('#SpraysonateItems').RemoveAndDeleteChildren()
	$('#BorderDonateItems').RemoveAndDeleteChildren()
	$('#DogeCoinsItems').RemoveAndDeleteChildren()
	$('#ToysDonateItems').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_pets.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_pets, i)
		CreateItemInShop($('#PetsDonateItems'), Items_pets, i)
	}

	for (var i = 0; i < Items_effects.length; i++) {
 		CreateItemInShop($('#AllDonateItems'), Items_effects, i)
 		CreateItemInShop($('#EffectsDonateItems'), Items_effects, i)
	}

	for (var i = 0; i < Items_subscribe.length; i++) {
 		CreateItemInShop($('#AllDonateItems'), Items_subscribe, i)
 		CreateItemInShop($('#SubscribeDonateItems'), Items_subscribe, i)
	}

	for (var i = 0; i < Items_heroes.length; i++) {
		CreateItemInShop($('#AllDonateItems'), Items_heroes, i)
		CreateItemInShop($('#HeroesDonateItems'), Items_heroes, i)
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

function InitInventory() {
	$('#CouriersPanel').RemoveAndDeleteChildren()
	$('#EffectsPanel').RemoveAndDeleteChildren()
	$('#BannersPanel').RemoveAndDeleteChildren()

	for (var i = 0; i < Items_pets.length; i++) {
		CreateItemInInventory($('#CouriersPanel'), Items_pets, i)
	}
	for (var i = 0; i < Items_effects.length; i++) {
 		CreateItemInInventory($('#EffectsPanel'), Items_effects, i)
	}
	for (var i = 0; i < Items_borders.length; i++) {
 		CreateItemInInventory($('#BannersPanel'), Items_borders, i)
	}
}

function CreateItemInInventory(panel, table, i) {

	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
	var player_table_js = []

	for (var d = 1; d < 300; d++) {
		player_table_js.push(player_table.player_items[d])
	}

	for ( var item of player_table_js )
    {
		if (item == table[i][0]) {
		 	var Recom_item = $.CreatePanel("Panel", panel, "item_inventory_" + table[i][0]);
			Recom_item.AddClass("ItemInventory");
			SetItemInventory(Recom_item, table[i])

			var ItemImage = $.CreatePanel("Panel", Recom_item, "");
			ItemImage.AddClass("ItemImage");
			ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
			ItemImage.style.backgroundSize = "contain"

			var ItemName = $.CreatePanel("Label", Recom_item, "ItemName");
			ItemName.AddClass("ItemName");
			ItemName.text = $.Localize( "#" + table[i][4] )

			if ( (table[i][4].indexOf("pet") == 0) || (table[i][4].indexOf("border") == 0) )  {
				var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
				BuyItemPanel.AddClass("BuyItemPanel");

				var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
				ItemPrice.AddClass("ItemPrice");

				var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
				PriceLabel.AddClass("PriceLabel");
				PriceLabel.text = $.Localize( "#shop_activate" )

				UpdateItemActivate(table[i][0])	
			}
		}
	}
}






function CreateItemInMain(panel, table, i) {

	var Recom_item = $.CreatePanel("Panel", panel, "");
	Recom_item.AddClass("RecomItem");

	SetItemBuyFunction(Recom_item, table[i])

	var ItemImage = $.CreatePanel("Panel", Recom_item, "");
	ItemImage.AddClass("ItemImage");
	ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
	ItemImage.style.backgroundSize = "contain"

	var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
	BuyItemPanel.AddClass("BuyItemPanel");

	var ItemPrice = $.CreatePanel("Panel", BuyItemPanel, "ItemPrice");
	ItemPrice.AddClass("ItemPrice");

	var PriceIcon = $.CreatePanel("Panel", ItemPrice, "PriceIcon");
	PriceIcon.AddClass("PriceIcon" + table[i][1]);

	var PriceLabel = $.CreatePanel("Label", ItemPrice, "PriceLabel");
	PriceLabel.AddClass("PriceLabel");
	PriceLabel.text = table[i][2]

	var ItemName = $.CreatePanel("Label", Recom_item, "");
	ItemName.AddClass("ItemName");
	ItemName.text = $.Localize( "#" + table[i][4] )

	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
	var player_table_js = []

	var player_table_bp_owner = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))

	for (var d = 1; d < 300; d++) {
		player_table_js.push(player_table.player_items[d])
	}

	for ( var item of player_table_js )
    {
    	if (table[i][0] == "21") {
    		if (player_table_bp_owner) {
    			if (player_table_bp_owner.bp_days > 0 || subscribe_buy) {
	 	       		Recom_item.SetPanelEvent("onactivate", function() {} );
					BuyItemPanel.style.backgroundColor = "gray"
					PriceLabel.text = $.Localize( "#shop_bought" )
					PriceIcon.DeleteAsync( 0 );   				
    			}
    		}
    	} else {
	       	if (item == table[i][0]) {
	       		Recom_item.SetPanelEvent("onactivate", function() {} );
				BuyItemPanel.style.backgroundColor = "gray"
				PriceLabel.text = $.Localize( "#shop_bought" )
				PriceIcon.DeleteAsync( 0 );
	       	}
    	}
    }
}



function CreateItemInShop(panel, table, i) {

 	var Recom_item = $.CreatePanel("Panel", panel, "");
	Recom_item.AddClass("ItemShop");

	var ItemImage = $.CreatePanel("Panel", Recom_item, "");
	ItemImage.AddClass("ItemImage");

	ItemImage.style.backgroundImage = 'url("file://{images}/custom_game/shop/itemicon/' + table[i][3] + '.png")';
	ItemImage.style.backgroundSize = "contain"

	var BuyItemPanel = $.CreatePanel("Panel", Recom_item, "BuyItemPanel");
	BuyItemPanel.AddClass("BuyItemPanel");



	SetItemBuyFunction(Recom_item, table[i])




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

	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
	var player_table_js = []

	var player_table_bp_owner = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))

	for (var d = 1; d < 300; d++) {
		player_table_js.push(player_table.player_items[d])
	}

	for ( var item of player_table_js )
    {
    	if (table[i][0] == "21" || table[i][0] == "135") {
    		if (player_table_bp_owner) {
    			if (player_table_bp_owner.bp_days > 0 || subscribe_buy) {
	 	       		Recom_item.SetPanelEvent("onactivate", function() {} );
					BuyItemPanel.style.backgroundColor = "gray"
					PriceLabel.text = $.Localize( "#shop_bought" )
					PriceIcon.DeleteAsync( 0 );   				
    			}
    		}
    	} else {
	       	if (item == table[i][0]) {
	       		Recom_item.SetPanelEvent("onactivate", function() {} );
				BuyItemPanel.style.backgroundColor = "gray"
				PriceLabel.text = $.Localize( "#shop_bought" )
				PriceIcon.DeleteAsync( 0 );
	       	}
    	}
    }
}











function CloseItemInfo(){
  	$("#info_item_buy").style.visibility = "collapse"
  	$("#ItemInfoBody").RemoveAndDeleteChildren()
}



function SetItemBuyFunction(panel, table){

    panel.SetPanelEvent("onactivate", function() { 
    	$("#info_item_buy").style.visibility = "visible"

    	$("#ItemNameInfo").text = $.Localize( "#" + table[4] )

    	if (table[4].indexOf("donate") !== 0) {

    		if (table[4].indexOf("sounds") == 0) {
    			Game.EmitSound("item_wheel_"+table[0])
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
		} else {

			$("#ItemInfoBody").style.flowChildren = "right"

			var column_1 = $.CreatePanel("Panel", $("#ItemInfoBody"), "column_1");
			column_1.AddClass("column_donate");

			var column_2 = $.CreatePanel("Panel", $("#ItemInfoBody"), "column_2");
			column_2.AddClass("column_donate");

			$.CreatePanelWithProperties("Panel", column_1, "PatreonButton", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_1});` });
			$.CreatePanelWithProperties("Panel", column_2, "Qiwi", { onactivate: `ExternalBrowserGoToURL(${button_donate_link_3});` });

			var DonateButtonLabel1 = $.CreatePanel("Label", column_1, "");
			DonateButtonLabel1.AddClass("DonateButtonLabel");
			DonateButtonLabel1.text = $.Localize( "#donate_button_description_1" )

			var DonateButtonLabel2 = $.CreatePanel("Label", column_2, "");
			DonateButtonLabel2.AddClass("DonateButtonLabel");
			DonateButtonLabel2.text = $.Localize( "#donate_button_description_2" )




		} 
    } );  
}

function SetItemInventory(panel, table) {
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

    	for (var i = 0; i < $("#CouriersPanel").GetChildCount(); i++) {
    		$("#CouriersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        	$("#CouriersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_premium_pet", {pet_id: num, delete_pet:false} );
        courier_selected = num;
    }
    else
    {
    	$("#item_inventory_"+courier_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
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
    		$("#EffectsPanel").GetChild(i).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        	$("#EffectsPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        //GameEvents.SendCustomGameEventToServer( "SelectPart", { id: Players.GetLocalPlayer(),part:num, offp:false, name:num } );
        particle_selected = num;
    }
    else
    {
    	$("#item_inventory_"+particle_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        $("#item_inventory_"+particle_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        //GameEvents.SendCustomGameEventToServer( "change_premium_pet", {model : i, effect : effect} );
        particle_selected = null;
    }
}

var border_selected = null;

function SelectBorder(num)
{
    if (border_selected != num)
    {

    	for (var i = 0; i < $("#BannersPanel").GetChildCount(); i++) {
    		$("#BannersPanel").GetChild(i).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        	$("#BannersPanel").GetChild(i).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
    	} 

    	$("#item_inventory_"+num).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        $("#item_inventory_"+num).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        GameEvents.SendCustomGameEventToServer( "change_border_effect", {border_id: num, delete_pet:false} );
        border_selected = num;
    }
    else
    {
    	$("#item_inventory_"+border_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
        $("#item_inventory_"+border_selected).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_activate" )
        GameEvents.SendCustomGameEventToServer( "change_border_effect", {border_id: num, delete_pet: true} );
        border_selected = null;
    }
}


//////////// ФУНКЦИЯ ПОКУПКИ /////////

function BuyItemFunction(panel, table) {

	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))

	if ((typeof player_table.doge_coin !== 'undefined') && (typeof player_table.birzha_coin !== 'undefined')) {
		if (table[1] == "gold") {
			if (player_table.birzha_coin >= table[2]) {
				GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			} else {
				ShopErrorFromJs("shop_no_bitcoin")
				return
			}
		} else if (table[1] == "gem") {
			if (player_table.doge_coin >= table[2]) {
				GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			} else {
				ShopErrorFromJs("shop_no_dogecoin")
				return
			}
		}

		if (!table[5]) {
			panel.SetPanelEvent("onactivate", function() {} );
			panel.FindChildTraverse("BuyItemPanel").style.backgroundColor = "gray"
			panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_bought" )
			panel.FindChildTraverse("PriceIcon").DeleteAsync( 0 );
		    if (table[0] == "21") {
		    	subscribe_buy = true
		    }
		    if (table[0] == "135") {
		    	subscribe_buy = true
		    }
		}
	} else {
		ShopErrorFromJs("shop_no_player_data")
	}
	$.Schedule( 0.25, function(){
		InitMainPanel()
		InitItems()
		InitInventory()
	})
}

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПРИ ПЕРВОМ ОТКРЫТИИ /////////

function SetMainCurrency() {
	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))

	if ((typeof player_table.doge_coin !== 'undefined') && (typeof player_table.birzha_coin !== 'undefined')) {
		$("#Currency").text = String(player_table.birzha_coin)
		$("#Currency2").text = 	String(player_table.doge_coin)	
	}
} 

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПОСЛЕ ПОКУПКИ /////////

function SetCurrency(data) {
	if (data) {
		if (typeof data.bitcoin !== 'undefined') {
			$("#Currency").text = String(data.bitcoin)
		}
		if (typeof data.dogecoin !== 'undefined') {
			$("#Currency2").text = 	String(data.dogecoin)	
		}
	}
}

function ShopError(data) {
	$( "#shop_error_panel" ).style.visibility = "visible";

	if (data) {
		$( "#shop_error_label" ).text = $.Localize( "#" + data.text );
	} else {
		$( "#shop_error_label" ).text = "";
	}
	

	$( "#shop_error_label" ).SetHasClass( "error_visible", false );

	$.Schedule( 2, RemoveError );
}

function ShopErrorFromJs(text) {
	$( "#shop_error_panel" ).style.visibility = "visible";

	$( "#shop_error_label" ).text = $.Localize( "#" + text );

	$( "#shop_error_label" ).SetHasClass( "error_visible", false );

	$.Schedule( 2, RemoveError );
}

function RemoveError() {
	$( "#shop_error_panel" ).style.visibility = "collapse";
	$( "#shop_error_label" ).SetHasClass( "error_visible", true );
	$( "#shop_error_label" ).text = "";
}

function UpdateItemActivate(id) {
	if (courier_selected !== null) {
		if (id == courier_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }
	}
	if (particle_selected !== null) {
		if (id == particle_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
	if (border_selected !== null) {
		if (id == border_selected)
		{
    		$("#item_inventory_"+id).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #84302C ), to( #60321D ))"
        	$("#item_inventory_"+id).FindChildTraverse("PriceLabel").text = $.Localize( "#shop_deactivate" )
        }			
	}
}

function set_player_pet_from_data(data) {
	var pet_id = data.pet_id
	courier_selected = pet_id
}

function set_player_border_from_data(data) {
	var border_id = data.border_id
	border_selected = border_id
}

function InitBirzhaChatWheel()
{
	var player_table = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
	if (player_table)
	{
		if (player_table.chat_wheel)
		{
			for (var i = 1; i <= 8; i++) {
				
				let name = $.Localize("#chatwheel_birzha_null")
				for ( var item of Items_sounds )
				{
					if (item[0] == String(player_table.chat_wheel[i])) {
						name = $.Localize("#" + item[4])
					}
				}
				for ( var item of Items_sprays )
				{
					if (item[0] == String(player_table.chat_wheel[i])) {
						name = $.Localize("#" + item[4])
					}
				}
				for ( var item of Items_toys )
				{
					if (item[0] == String(player_table.chat_wheel[i])) {
						name = $.Localize("#" + item[4])
					}
				}



				$( "#chat_wheel_birzha_"+i ).text = name
			}
		}
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
	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
	var player_table_js = []
	for (var d = 1; d < 300; d++) {
		player_table_js.push(player_table.player_items[d])
	}

	var chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row_title");

	var chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label_title");
	chatwheel_row_label.text = $.Localize("#BirzhaPass_sound_1")

	for ( var item_inventory of player_table_js )
    {
    	for ( var item of Items_sounds )
    	{
			if (item_inventory == item[0]) {
				CreateChatWheelSelectItem(id, item[4], item[0])
			}
    	}
	}

	var chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row_title");

	var chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label_title");
	chatwheel_row_label.text = $.Localize("#BirzhaPass_sprays_1")

	for ( var item_inventory of player_table_js )
    {
    	for ( var item of Items_sprays )
    	{
			if (item_inventory == item[0]) {
				CreateChatWheelSelectItem(id, item[4], item[0])
			}
    	}
    }

    var chatwheel_row = $.CreatePanel("Panel", $("#ChatWheelSelectList"), "");
	chatwheel_row.AddClass("chatwheel_row_title");

	var chatwheel_row_label = $.CreatePanel("Label", chatwheel_row, "");
	chatwheel_row_label.AddClass("chatwheel_row_label_title");
	chatwheel_row_label.text = $.Localize("#BirzhaPass_toys_1")

    for ( var item_inventory of player_table_js )
    {
    	for ( var item of Items_toys )
    	{
			if (item_inventory == item[0]) {
				CreateChatWheelSelectItem(id, item[4], item[0])
			}
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

	chatwheel_row.SetPanelEvent("onactivate", function() { 
		GameEvents.SendCustomGameEventToServer( "select_chatwheel_player", {id : id, item : item } );
		$.Schedule( 0.25, function(){
			InitBirzhaChatWheel()
			CloseSelectChatWheel()
		})
	})
}