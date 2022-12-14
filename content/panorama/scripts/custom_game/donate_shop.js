var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("MenuButtons");

if (parentHUDElements)
{
	if ($("#ShopButton")) {
		if (parentHUDElements.FindChildTraverse("ShopButton")){
			$("#ShopButton").DeleteAsync( 0 );
		} else {
			$("#ShopButton").SetParent(parentHUDElements);
		}
	}
	if ($("#BirzhaPlusButton")) {
		if (parentHUDElements.FindChildTraverse("BirzhaPlusButton")){
			$("#BirzhaPlusButton").DeleteAsync( 0 );
		} else {
			$("#BirzhaPlusButton").SetParent(parentHUDElements);
		}
	}
	if ($("#BattlepassButton")) {
		if (parentHUDElements.FindChildTraverse("BattlepassButton")){
			$("#BattlepassButton").DeleteAsync( 0 );
		} else {
			$("#BattlepassButton").SetParent(parentHUDElements);
		}
	}
}

var dotaHudChatControls = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("ChatControls");
$("#SmilesButton").SetParent(dotaHudChatControls);
dotaHudChatControls.MoveChildBefore(dotaHudChatControls.FindChildTraverse("SmilesButton"), dotaHudChatControls.FindChildTraverse("ChatEmoticonButton"))
dotaHudChatControls.FindChildTraverse("ChatEmoticonButton").style.visibility = "collapse"

var toggle = false;
var first_time = false;
var cooldown_panel = false
var current_sub_tab = "";
var subscribe_buy = false
var timer_loading = -1

//////////ССЫЛКИ НА КНОПКИ С ДОНАТОМ ПРИ ПОКУПКЕ ВАЛЮТЫ///////////

var button_donate_link_1 = "https://www.patreon.com/BirzhaMemov"
var button_donate_link_2 = ""
var button_donate_link_3 = "https://bmemov.ru/donate/bitcoins/"

	// ID ПРЕДМЕТА для проверки или для добавления в базу,ВАЛЮТА,СТОИМОСТЬ,ИКОНКА(именно название png файла),переменная названия в локализации, можно покупать много раз или один раз(проверка на покупку в базе)

var Items_recomended = [
	["21", "gold", "500", "subscribe", "subscribe_1", false],
	["34", "gold", "1000", "item_for_sobolev", "item_for_sobolev", false],
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
	["1", "gem", "1500", "pet_1", "pet_1", false], 
	["2", "gem", "1500", "pet_2", "pet_2", false],
	["3", "gem", "1500", "pet_3", "pet_3", false],
	["4", "gem", "1500", "pet_4", "pet_4", false],
	["5", "gem", "1500", "pet_5", "pet_5", false],
	["6", "gem", "1500", "pet_6", "pet_6", false],
	["7", "gem", "1500", "pet_7", "pet_7", false],
	["8", "gem", "1500", "pet_8", "pet_8", false],
	["9", "gem", "1500", "pet_9", "pet_9", false],
	["10", "gem", "1500", "pet_10", "pet_10", false],
	["11", "gem", "1500", "pet_11", "pet_11", false],
	["12", "gem", "1500", "pet_12", "pet_12", false],
	["13", "gem", "1500", "pet_13", "pet_13", false],
	["14", "gem", "1500", "pet_14", "pet_14", false],
	["15", "gem", "1500", "pet_15", "pet_15", false],
	["16", "gem", "1500", "pet_16", "pet_16", false],
	["17", "gem", "1500", "pet_17", "pet_17", false],
	["18", "gem", "1500", "pet_18", "pet_18", false],
	["19", "gem", "1500", "pet_19", "pet_19", false],
]

//////////МАССИВ ЭФФЕКТОВ///////////

var Items_effects = 
[
	["20", "gem", "2000", "particle_1", "particle_1", false],
	["40", "gem", "2000", "particle_2", "particle_2", false],
	["41", "gem", "2000", "particle_3", "particle_3", false],
	["42", "gem", "2000", "particle_4", "particle_4", false],
	["43", "gem", "2000", "particle_5", "particle_5", false],
	["44", "gem", "2000", "particle_6", "particle_6", false],
	["45", "gem", "2000", "particle_7", "particle_7", false],
	["46", "gem", "2000", "particle_8", "particle_8", false],
	["47", "gem", "2000", "particle_9", "particle_9", false],
	["48", "gem", "2000", "particle_10", "particle_10", false],
	["49", "gem", "2000", "particle_11", "particle_11", false],
	["50", "gem", "2000", "particle_12", "particle_12", false],
	["51", "gem", "2000", "particle_13", "particle_13", false],
]

//////////МАССИВ ПОДПИСКИ///////////

var Items_subscribe = [
	["21", "gold", "500", "subscribe", "subscribe_1", false],
	["135", "gold", "2500", "subscribe", "subscribe_2", false],
]


var Items_heroes = [
	["22", "gem", "500", "item_for_scp", "item_for_scp", false],
	["23", "gold", "1500", "item_for_silvername", "item_for_silvername", false],
	["24", "gold", "1000", "item_for_gorin", "item_for_gorin", false],
	["25", "gold", "2500", "item_for_fatmum", "item_for_fatmum", false],
	["26", "gold", "2500",  "item_for_kurumi", "item_for_kurumi", false],
	["27", "gold", "2500", "item_for_never", "item_for_never", false],
	["28", "gold", "1500", "item_for_valakas", "item_for_valakas", false],
	["29", "gold", "2500", "item_for_papich", "item_for_papich", false],
	["30", "gold", "1500", "item_for_johncena", "item_for_johncena", false],
	["31", "gold", "1000", "item_for_jew", "item_for_jew", false],
	["32", "gold", "500", "item_for_poroshenko", "item_for_poroshenko", false],
	["33", "gold", "2500", "item_for_druzhko", "item_for_druzhko", false],
	["34", "gold", "1000", "item_for_sobolev", "item_for_sobolev", false],
	["126", "gold", "2500", "item_for_ayano", "item_for_ayano", false],
	["35", "gem", "500", "item_for_knuckles", "item_for_knuckles", false],
	["36", "gem", "500", "item_for_bigrussianboss", "item_for_bigrussianboss", false],
	["37", "gem", "2000", "item_for_versuta", "item_for_versuta", false],
	["38", "gem", "2000", "item_for_robbie", "item_for_robbie", false],
	["39", "gem", "1000", "item_for_fatmum_2", "item_for_fatmum_2", false],
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

var Items_sounds = 
[
	["52",  "gold", "100", "sound_1", "sounds_1", false], 
	["53",  "gold", "100", "sound_2", "sounds_2", false], 
	["54",  "gold", "100", "sound_3", "sounds_3", false], 
	["55",  "gold", "100", "sound_4", "sounds_4", false],
	["56",  "gold", "100", "sound_5", "sounds_5", false], 
	["57",  "gold", "100", "sound_6", "sounds_6", false], 
	["58",  "gold", "100", "sound_7", "sounds_7", false], 
	["59",  "gold", "100", "sound_8", "sounds_8", false], 
	["60",  "gold", "200", "sound_9", "sounds_9", false], 
	["61",  "gold", "100", "sound_10", "sounds_10", false], 
	["62",  "gold", "100", "sound_11", "sounds_11", false], 
	["63",  "gold", "100", "sound_12", "sounds_12", false], 
	["64",  "gold", "100", "sound_13", "sounds_13", false], 
	["65",  "gold", "100", "sound_14", "sounds_14", false], 
	["66",  "gold", "100", "sound_15", "sounds_15", false], 
	["67",  "gold", "100", "sound_16", "sounds_16", false],
	["68",  "gold", "200", "sound_17", "sounds_17", false], 
	["69",  "gold", "100", "sound_18", "sounds_18", false], 
	["70",  "gold", "200", "sound_19", "sounds_19", false], 
	["71",  "gold", "100", "sound_20", "sounds_20", false], 
	["72",  "gold", "100", "sound_21", "sounds_21", false], 
	["73",  "gold", "100", "sound_22", "sounds_22", false], 
	["74",  "gold", "500", "sound_23", "sounds_23", false], 
	["75",  "gold", "200", "sound_24", "sounds_24", false],
	["76",  "gold", "200", "sound_25", "sounds_25", false], 
	["77",  "gold", "500", "sound_26", "sounds_26", false], 
	["78",  "gold", "100", "sound_27", "sounds_27", false], 
	["79",  "gold", "100", "sound_28", "sounds_28", false], 
	["80",  "gold", "100", "sound_29", "sounds_29", false], 
	["81",  "gold", "500", "sound_30", "sounds_30", false], 
	["82",  "gold", "500", "sound_31", "sounds_31", false], 
	["83",  "gold", "100", "sound_32", "sounds_32", false], 
	["84",  "gold", "100", "sound_33", "sounds_33", false], 
	["85",  "gold", "100", "sound_34", "sounds_34", false], 
	["86",  "gold", "100", "sound_35", "sounds_35", false], 
	["87",  "gold", "200", "sound_36", "sounds_36", false], 
	["113", "gold", "1000", "sound_37", "sounds_37", false], 
	["114", "gold", "100", "sound_38", "sounds_38", false], 
	["118", "gold", "200", "sound", "sounds_39", false], 
	["119", "gold", "100", "sound", "sounds_40", false], 
	["120", "gold", "100", "sound", "sounds_41", false], 
	["121", "gold", "100", "sound", "sounds_42", false], 
	["122", "gold", "100", "sound", "sounds_43", false], 
	["123", "gold", "2000", "sound", "sounds_44", false], 
	["131", "gold", "200", "sound", "sounds_45", false], 
	["132", "gold", "100", "sound", "sounds_46", false], 
	["133", "gold", "200", "sound", "sounds_47", false], 
	["134", "gold", "100", "sound", "sounds_48", false], 
]

var Items_sprays = 
[
	["88",  "gem", "100", "spray_1", "spray_1", false], 
	["89",  "gem", "100", "spray_2", "spray_2", false], 
	["90",  "gem", "100", "spray_3", "spray_3", false], 
	["91",  "gem", "100", "spray_4", "spray_4", false], 
	["92",  "gem", "100", "spray_5", "spray_5", false], 
	["93",  "gem", "100", "spray_6", "spray_6", false], 
	["94",  "gem", "100", "spray_7", "spray_7", false], 
	["95",  "gem", "100", "spray_8", "spray_8", false],
	["96",  "gem", "100", "spray_9", "spray_9", false], 
	["97",  "gem", "100", "spray_10", "spray_10", false], 
	["98",  "gem", "100", "spray_11", "spray_11", false], 
	["99",  "gem", "100", "spray_12", "spray_12", false], 
	["100",  "gem", "100", "spray_13", "spray_13", false], 
	["101",  "gem", "100", "spray_14", "spray_14", false], 
	["102",  "gem", "100", "spray_15", "spray_15", false], 
	["103",  "gem", "100", "spray_16", "spray_16", false],
	["104",  "gem", "100", "spray_17", "spray_17", false], 
	["105",  "gem", "100", "spray_18", "spray_18", false], 
	["106",  "gem", "100", "spray_19", "spray_19", false], 
	["107",  "gem", "100", "spray_20", "spray_20", false],
	["108",  "gem", "100", "spray_21", "spray_21", false], 
	["109",  "gem", "100", "spray_22", "spray_22", false], 
	["110",  "gem", "100", "spray_23", "spray_23", false], 
	["111",  "gem", "100", "spray_24", "spray_24", false],  
]

var Items_borders = 
[ 
	["112",  "gold", "1500", "border_1", "border_1", false], 
	["115",  "gem", "1000", "border_2", "border_2", false], 
	["116",  "gold", "1500", "border_3", "border_3", false], 
	["117",  "gold", "1500", "border_4", "border_4", false], 
	["127",  "gold", "1500", "border_5", "border_5", false], 
	["128",  "gold", "1500", "border_6", "border_6", false], 
	["129",  "gem", "1000", "border_7", "border_7", false], 
	["164",  "gold", "1500", "border_8", "border_8", false], 
]

var Items_toys = [ 
	["124",  "gold", "500", "toys_1", "toys_1", false], 
	["125",  "gem", "500", "toys_2", "toys_2", false], 
]

var sounds_lotereya =
[
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
GameEvents.Subscribe( 'shop_set_currency', SetCurrency );
GameEvents.Subscribe( 'shop_error_notification', ErrorCreated );
GameEvents.Subscribe( 'shop_accept_notification', AcceptCreated );

//
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

function SwitchTab(tab, button) {
	$("#MainContainer").style.visibility = "collapse";
	$("#ItemsContainer").style.visibility = "collapse";
	$("#CouriersContainer").style.visibility = "collapse";
	$("#EffectsContainer").style.visibility = "collapse";
	$("#BannersContainer").style.visibility = "collapse";
	$("#ChatWheelBirzhaContainer").style.visibility = "collapse";
	$("#RuletkaBirzhaContainer").style.visibility = "collapse";

	$("#DonateMainButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateItemsButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateCouriersButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateEffectsButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#DonateBannersButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#ChatWheelBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );
	$("#RuletkaBirzhaButton").SetHasClass( "DonateNewMenuButtonSelected", false );

	Game.EmitSound("ui_topmenu_select")

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
		$("#MenuItems").GetChild(i).style.border = "0px solid #A3CBEF";
	}

	Game.EmitSound("ui_select_md")

	$("#" + button).style.boxShadow = "0px 0px 16px 0px #668BBC22";
	$("#" + button).style.border = "1px solid #A3CBEF";

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
	  	return Number(a[2])-Number(b[2])
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

	for (var i = 0; i < Items_subscribe.length; i++) {
 		CreateItemInShop($('#AllDonateItems'), Items_subscribe, i)
 		CreateItemInShop($('#SubscribeDonateItems'), Items_subscribe, i)
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
    	$("#ItemNameInfo").html = true
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

			var birzhainfo = CustomNetTables.GetTableValue("birzhainfo", String(Players.GetLocalPlayer()))
			if (birzhainfo)
			{
				$("#ItemNameInfo").text = $.Localize( "#" + table[4] ) + "<br>" + $.Localize("#your_id") + birzhainfo.steamid
			} else {
				$("#ItemNameInfo").text = $.Localize( "#" + table[4] )
			}
			

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
        particle_selected = num;
    }
    else
    {
    	$("#item_inventory_"+particle_selected).FindChildTraverse("BuyItemPanel").style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #60842c ), to( #40601d ))"
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
			GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			LoadingCreated()
		} else if (table[1] == "gem") {
			GameEvents.SendCustomGameEventToServer( "donate_shop_buy_item", {item_id : table[0], price : table[2], currency : table[1], } );
			LoadingCreated()
		}

		if (!table[5]) {
			if (panel.id != "buyplus_1" && panel.id != "buyplus_2")
			{
				panel.SetPanelEvent("onactivate", function() {} );
				panel.FindChildTraverse("BuyItemPanel").style.backgroundColor = "gray"
				panel.FindChildTraverse("PriceLabel").text = $.Localize( "#shop_bought" )
				panel.FindChildTraverse("PriceIcon").DeleteAsync( 0 );
			}
		    if (table[0] == "21") {
		    	subscribe_buy = true
		    }
		    if (table[0] == "135") {
		    	subscribe_buy = true
		    }
		}
	}
	$.Schedule( 0.25, function(){
		InitMainPanel()
		InitItems()
		InitInventory()
	})
}

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПРИ ПЕРВОМ ОТКРЫТИИ /////////

function SetMainCurrency() 
{
	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))

	if ((typeof player_table.doge_coin !== 'undefined') && (typeof player_table.birzha_coin !== 'undefined')) {
		$("#Currency").text = String(player_table.birzha_coin)
		$("#Currency2").text = 	String(player_table.doge_coin)	
		if ($("#CurrencyBP"))
		{
			$("#CurrencyBP").text = String(player_table.birzha_coin)
		}
		if ($("#Currency2BP"))
		{
			$("#Currency2BP").text = 	String(player_table.doge_coin)
		}	
	}
} 

//////////// ФУНКЦИЯ УСТАНОВКИ БАЛАНСА ПОСЛЕ ПОКУПКИ /////////

function SetCurrency(data) {
	if (data) {
		if (typeof data.bitcoin !== 'undefined') {
			$("#Currency").text = String(data.bitcoin)
			if ($("#CurrencyBP"))
			{
				$("#CurrencyBP").text = String(data.bitcoin)
			}
		}
		if (typeof data.dogecoin !== 'undefined') {
			$("#Currency2").text = 	String(data.dogecoin)	
			if ($("#Currency2BP"))
			{
				$("#Currency2BP").text = 	String(data.dogecoin)
			}	
		}
	}
}

function ErrorCreated(data) {
    Game.EmitSound("Relic.Received")
    if( timer_loading != -1 )
    {
        $.CancelScheduled(timer_loading)
    }
    LoadingClose()

    if (data && data.error_name)
    {
        $("#donate_error_label").text = $.Localize("#" + data.error_name)
    } else {
        $("#donate_error_label").text = $.Localize("#donate_shop_error")
    }

    $("#donate_error_window").style.visibility = "visible"
    $.Schedule(2 , ErrorClose);
}

function ErrorClose() {
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
		    	for ( var item of sounds_lotereya )
		    	{
					if (item[0] == String(player_table.chat_wheel[i])) {
						name = $.Localize("#" + item[1])
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
	for ( var item_inventory of player_table_js )
    {
    	for ( var item of sounds_lotereya )
    	{
			if (item_inventory == item[0]) {
				CreateChatWheelSelectItem(id, item[1], item[0])
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

var toggle_birzhaplus = false;
var first_time_birzhaplus = false;
var cooldown_panel_birzhaplus = false

GameUI.CustomUIConfig().OpenBirzhaPlus = function ToggleBattlepass() {
    if (toggle_birzhaplus === false) {
    	if (cooldown_panel_birzhaplus == false) {
    		SetMainCurrency()
    		Game.EmitSound("ui_goto_player_page")
	        toggle_birzhaplus = true;
	        if (first_time_birzhaplus === false) {
	            first_time_birzhaplus = true;
	            $("#BirzhaPassWindow").AddClass("sethidden");
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

function BPSwitchTab(tab) {
	Game.EmitSound("ui_topmenu_select")
	$("#TableInfoPlayer").style.visibility = "collapse";
	$("#HeroesInformation").style.visibility = "collapse";
	$("#" + tab).style.visibility = "visible";
}

function UpdatePlusBirzha()
{
	var table = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()))
	if (table) {
		if (table.bp_days <= 0) {
			$("#BirzhaPassWindowActive").style.visibility = "collapse"
			$("#BirzhaPassWindowDeactive").style.visibility = "visible"
			SetItemBuyFunction($("#buyplus_1"), Items_subscribe[0])
			SetItemBuyFunction($("#buyplus_2"), Items_subscribe[1])
		} else {
			$("#BirzhaPassWindowActive").style.visibility = "visible"
			$("#BirzhaPassWindowDeactive").style.visibility = "collapse"	
		}
	} else {
		$("#BirzhaPassWindowActive").style.visibility = "collapse"
		$("#BirzhaPassWindowDeactive").style.visibility = "visible"	
		SetItemBuyFunction($("#buyplus_1"), Items_subscribe[0])
		SetItemBuyFunction($("#buyplus_2"), Items_subscribe[1])
	}	
}

function Init() {
	var table = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()))

	if (table) {
		if (table.bp_days <= 0) {
			$("#BirzhaPassWindowActive").style.visibility = "collapse"
			$("#BirzhaPassWindowDeactive").style.visibility = "visible"
			SetItemBuyFunction($("#buyplus_1"), Items_subscribe[0])
			SetItemBuyFunction($("#buyplus_2"), Items_subscribe[1])
		} else {
			$("#BirzhaPassWindowActive").style.visibility = "visible"
			$("#BirzhaPassWindowDeactive").style.visibility = "collapse"	
		}
	} else {
		$("#BirzhaPassWindowActive").style.visibility = "collapse"
		$("#BirzhaPassWindowDeactive").style.visibility = "visible"	
		SetItemBuyFunction($("#buyplus_1"), Items_subscribe[0])
		SetItemBuyFunction($("#buyplus_2"), Items_subscribe[1])
	}

	var player_matches = []

	var player_all_games = 0
	var player_win_games = 0
	var player_lose_games = 0
	var player_kills_games = 0
	var player_death_games = 0
	var bp_days = 0
	var token_used = 0

	if (table) {
		if (Object.keys(table.heroes_matches).length <= 0) {
			$("#GamePlayeds").text = player_all_games
			$("#GameWins").text =    player_win_games
			$("#GameLoses").text =   player_lose_games
			$("#KillsCount").text =    player_kills_games
			$("#DeathCount").text =   player_death_games
			$("#BpStatus").text = bp_days + " " + $.Localize("#day")
			$("#PlayerTokens").text = 0
			return
		}
		for (var i = 1; i <= Object.keys(table.heroes_matches).length; i++) {
			player_matches[i-1] = []

			var win = Number(table.heroes_matches[i]["win"])
			var winrate = 0
			if (win != 0) {
				winrate = (win / table.heroes_matches[i]["games"] * 100).toFixed(0)
			}

			var deaths = Number(table.heroes_matches[i]["deaths"])
			if (deaths == 0) {
				deaths = 1
			}


			player_matches[i-1].push(table.heroes_matches[i]["hero"], table.heroes_matches[i]["games"], table.heroes_matches[i]["win"], table.heroes_matches[i]["kills"], table.heroes_matches[i]["deaths"], winrate, (Number(table.heroes_matches[i]["kills"]) / deaths).toFixed(2), table.heroes_matches[i]["experience"])
		}
		bp_days = table.bp_days	
		token_used = table.token_used	
	} else {

		$("#GamePlayeds").text = player_all_games
		$("#GameWins").text =    player_win_games
		$("#GameLoses").text =   player_lose_games
		$("#KillsCount").text =    player_kills_games
		$("#DeathCount").text =   player_death_games

		$("#BpStatus").text = bp_days + " " + $.Localize("#day")
		$("#PlayerTokens").text =  0
		return
	}

	for ( var hero of player_matches ) {
		player_all_games = player_all_games + Number(hero[1])
		player_win_games = Number(player_win_games) + Number(hero[2])
		player_kills_games = Number(player_kills_games) + Number(hero[3])
		player_death_games = Number(player_death_games) + Number(hero[4]) 
	}
 
	player_lose_games = Number(player_all_games) - Number(player_win_games)

	$("#GamePlayeds").text = player_all_games
	$("#GameWins").text =    player_win_games
	$("#GameLoses").text =   player_lose_games

	$("#KillsCount").text =    player_kills_games
	$("#DeathCount").text =   player_death_games

	let winrate_percent =  player_win_games / player_all_games 
	$("#WinrateLabel").text = ((winrate_percent) * 100).toFixed(1) + "%"

	let radial_number = 0
	radial_number = 360 * winrate_percent
	$("#PlayerCircleWinrateFG").style.clip = 'radial( 50.0% 50.0%, 0.0deg, ' + radial_number + 'deg);'

	ToggleMapBPUS("solo_plus", "birzhamemov_solo")

	$("#BpStatus").text = bp_days + " " + $.Localize("#day")
	$("#PlayerTokens").text = String((10 - Number(token_used)))

	player_matches.sort(function (a, b) {
	  return Number(b[5])-Number(a[5]) && Number(b[1])-Number(a[1])
	});

	$("#TopHero").text =    $.Localize("#" + player_matches[0][0])

    var panel_withs_heroes_stats = $.CreatePanel('Panel', $("#HeroesInformation"), 'panel_withs_heroes_stats');
    panel_withs_heroes_stats.AddClass('PanelHeroes');


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
        ChangeHeroTable(player_matches, 1);
    } ); 

    Info_HeroWinrate.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(player_matches, 5);
    } ); 

    Info_HeroKD.SetPanelEvent("onactivate", function() { 
        ChangeHeroTable(player_matches, 6);
    } );  


	player_matches.sort(function (a, b) {
	  return Number(b[1])-Number(a[1])
	});

	for ( var hero of player_matches ) {
	    var HeroRow = $.CreatePanel('Panel', PanelHeroes, 'hero_'+hero[0]);
    	HeroRow.AddClass('HeroRow');

    	var HeroIcon = $.CreatePanel('Panel', HeroRow, "HeroIcon");
    	HeroIcon.AddClass('HeroIcon');
    	HeroIcon.style.backgroundImage = 'url( "file://{images}/custom_game/hight_hood/heroes/' + hero[0] + '.png" )';
    	HeroIcon.style.backgroundSize = "100% 100%"

    	var HeroName = $.CreatePanel('Label', HeroRow, "HeroName");
    	HeroName.AddClass('HeroName');
    	HeroName.text = $.Localize("#" + hero[0])

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
		rank_player.style.width = "30px"
		rank_player.style.height = "30px"
		rank_player.style.align = "center top"
		rank_player.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero[7])) + '.png")'
		rank_player.style.backgroundSize = "100%"

		var rank_progress_panel = $.CreatePanel('Panel', HeroRank, "");
		rank_progress_panel.AddClass('rank_progress_panel');

		var rank_progress_panel_back = $.CreatePanel('Panel', rank_progress_panel, "");
		rank_progress_panel_back.AddClass('rank_progress_panel_back');

		var rank_progress_panel_front = $.CreatePanel('Panel', rank_progress_panel, "");
		rank_progress_panel_front.AddClass('rank_progress_panel_front');
		rank_progress_panel_front.style.width = GetHeroExpProgress(hero[7])

		var rank_progress_label = $.CreatePanel('Label', HeroRank, "");
		rank_progress_label.AddClass('rank_progress_label'); 
		if (GetHeroLevel(hero[7]) >= 30)
		{
			rank_progress_panel_front.style.width = "100%"
			rank_progress_label.text = GetHeroLevel(hero[7]) + " " + $.Localize("#Info_HInfo_HeroRank")
		} else {
			rank_progress_label.text = GetHeroLevel(hero[7]) + " " + $.Localize("#Info_HInfo_HeroRank") + " " + "( " + GetHeroExp(hero[7]) + " )"
		}
		
	}
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

function ChangeHeroTable(table, num) {

	$("#PanelHeroes").RemoveAndDeleteChildren();

	table.sort(function (a, b) {
	  return Number(b[num])-Number(a[num])
	});

	for ( var hero of table ) {
	    var HeroRow = $.CreatePanel('Panel', $("#PanelHeroes"), 'hero_'+hero[0]);
    	HeroRow.AddClass('HeroRow');	

    	var HeroIcon = $.CreatePanel('Panel', HeroRow, "HeroIcon");
    	HeroIcon.AddClass('HeroIcon');
    	HeroIcon.style.backgroundImage = 'url( "file://{images}/custom_game/hight_hood/heroes/' + hero[0] + '.png" )';
    	HeroIcon.style.backgroundSize = "100% 100%"

    	var HeroName = $.CreatePanel('Label', HeroRow, "HeroName");
    	HeroName.AddClass('HeroName');
    	HeroName.text = $.Localize("#" + hero[0])

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
		rank_player.style.width = "32px"
		rank_player.style.height = "32px"
		rank_player.style.align = "center center"
		rank_player.style.backgroundImage = 'url("file://{images}/custom_game/hero_rank/' + GetHeroRankIcon(GetHeroLevel(hero[7])) + '.png")'
		rank_player.style.backgroundSize = "100%"
	}
}

function GetHeroLevel(exp)
{
    let level = exp / 1000
    return Math.floor(level)
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

function HasBirzhaPass(id)
{
    return (CustomNetTables.GetTableValue('birzhainfo', String(id)) || {}).bp_days > 0;
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

var smiles = 
[
    [161, "StrangerBan"],
    [136, "4elik"],
    [137, "BirzhaMertva"],
    [138, "Blin"],
    [139, "Cat"],
    [140, "CatSad"],
    [141, "Clown"],
    [142, "CoolStory"],
    [143, "DwayneWut"],
    [144, "Gachi"],
    [145, "Head"],
    [146, "insane"],
    [147, "KekW"],
    [148, "Like"],
    [149, "Micro4el"],
    [150, "Omegalul"],
    [151, "Oreh"],
    [152, "OrehDaun"],
    [153, "PapichRetard"],
    [154, "PenguinSuck"],
    [155, "Pepega"],
    [156, "PepegaClown"],
    [157, "RoflanEbalo"],
    [158, "RoflanPominki"],
    [159, "Wut"],
    [160, "WutMeme"],
    [162, "stray"],
    [163, "microcat"],
]

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

GameEvents.Subscribe( 'bm_start_lottery', StartLottery );
GameEvents.Subscribe( 'bm_reward_lottery', RewardLottery );
GameEvents.Subscribe( 'bm_lottery_sound_client', bm_lottery_sound_client );

function StartLotteryLua()
{
	GameEvents.SendCustomGameEventToServer("LotteryStart", {});
}

function bm_lottery_sound_client()
{
	Game.EmitSound("random_wheel_lever")
}

function StartLottery(data)
{
	$("#LotteryButtonOpen").style.visibility = "collapse"
	$('#RandomTrack').style['transition-duration'] = "5s";

	$.Schedule(0.03, function () {
		$('#RandomTrack').style['position'] = "-"+data.visual+"px 0px 0px";
	})

	for (var i = 1; i <= Object.keys(data.items_list).length; i++) {
        $("#lottery_" + (i - 1)).GetChild(0).text = $.Localize("#item_" + data.items_list[i] )
        let rare = false
        for (var r = 1; r <= Object.keys(data.rarity_items).length; r++) {
        	if (data.items_list[i] == data.rarity_items[r])
        	{
        		rare = true
        	}
        }
        if (rare)
        {
        	$("#lottery_" + (i - 1)).GetChild(0).style.color = "gold"
        }
    }

    $("#lottery_19").GetChild(0).text = $.Localize("#item_" + data.drop_reward )
}

function RewardLottery(data)
{
	Game.EmitSound("Gift_Unwrap_Stinger")
	$("#lottery_reward_panel_label2").text = $.Localize("#item_"+data.item_id)
	$("#lottery_reward_panel").style.visibility = "visible"
}

function CloseRewardPanel()
{
	$("#lottery_reward_panel").style.visibility = "collapse"
	$("#LotteryButtonOpen").style.visibility = "visible"
	for (var i = 0; i <= 30; i++) {
        $("#lottery_" + i).GetChild(0).text = "???"
        $("#lottery_" + i).GetChild(0).style.color = "white"
    }
	$('#RandomTrack').style['transition-duration'] = "0s";
	$('#RandomTrack').style['position'] = "-30px 0px 0px";
	SetMainCurrency()
}


function ToggleMapBPUS(button, map_name)
{
	$("#solo_plus").SetHasClass( "ButtonMapSelect", false );
	$("#duo_plus").SetHasClass( "ButtonMapSelect", false );
	$("#trio_plus").SetHasClass( "ButtonMapSelect", false );
	$("#5v5v5_plus").SetHasClass( "ButtonMapSelect", false );
	$("#5v5_plus").SetHasClass( "ButtonMapSelect", false );
	$("#zxc_plus").SetHasClass( "ButtonMapSelect", false );
	$("#wtf_plus").SetHasClass( "ButtonMapSelect", false );
	Game.EmitSound("ui_topmenu_select")
	$("#" + button).SetHasClass( "ButtonMapSelect", true );

	$("#AllRatingSeasons").RemoveAndDeleteChildren()

	var table = CustomNetTables.GetTableValue('birzha_plus_data', String(Players.GetLocalPlayer()))

	if (table)
	{
		for (var i = 1; i <= Object.keys(table.mmr[map_name]).length; i++) {

			var MmrSeasonBlock = $.CreatePanel('Panel', $("#AllRatingSeasons"), "");
		    MmrSeasonBlock.AddClass('MmrSeasonBlock');

		    var MmrBlockPanel = $.CreatePanel('Panel', MmrSeasonBlock, "");
		    MmrBlockPanel.AddClass('MmrBlockPanelSeason');

		    var label_block_rating = $.CreatePanel('Label', MmrBlockPanel, "");
		    label_block_rating.AddClass('label_block_rating_count');
		    label_block_rating.text = i

		    var MmrBlockPanel_2 = $.CreatePanel('Panel', MmrSeasonBlock, "");
		    MmrBlockPanel_2.AddClass('MmrBlockPanel');

		    var label_block_rating_2 = $.CreatePanel('Label', MmrBlockPanel_2, "");
		    label_block_rating_2.AddClass('label_block_rating');
		    label_block_rating_2.text = String(table.mmr[map_name][i])
		}
	}
}




var toggle_battlepass = false;
var first_time_battlepass = false;
var cooldown_panel_battlepass = false

GameUI.CustomUIConfig().OpenBattlePass = function OpenBattlePass() {
    if (toggle_battlepass === false) {
    	if (cooldown_panel_battlepass == false) {
    		SetMainCurrency()
    		Game.EmitSound("ui_goto_player_page")
	        toggle_battlepass = true;
	        if (first_time_battlepass === false) {
	            first_time_battlepass = true;
	            $("#BattlePassWindow").AddClass("sethidden");
	            BattlePassInit();
	        }  
	        if ($("#BattlePassWindow").BHasClass("sethidden")) {
	            $("#BattlePassWindow").RemoveClass("sethidden");
	        }
	        $("#BattlePassWindow").AddClass("setvisible");
	        $("#BattlePassWindow").style.visibility = "visible"
	        cooldown_panel_battlepass = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel_battlepass = false
	        })
	    }
    } else {
    	if (cooldown_panel_battlepass == false) {
    		Game.EmitSound("ui_goto_player_page")
	        toggle_battlepass = false;
	        if ($("#BattlePassWindow").BHasClass("setvisible")) {
	            $("#BattlePassWindow").RemoveClass("setvisible");
	        }
	        $("#BattlePassWindow").AddClass("sethidden");
	        cooldown_panel_battlepass = true
	        $.Schedule( 0.503, function(){
	        	cooldown_panel_battlepass = false
	        	$("#BattlePassWindow").style.visibility = "collapse"
			})
		}
    }
}

function BattlePassInit()
{
	var table = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()))
	if (table) 
	{
		if (table && table.has_battlepass == 1)
		{
			$("#BuyBattlePass").style.visibility = "collapse"
			$("#PreBuyLabel").text = $.Localize("#ty_preorder")
		}
	}
} 

function BPPreOrderBuy(valute)
{
	var player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))

	if ((typeof player_table.doge_coin !== 'undefined') && (typeof player_table.birzha_coin !== 'undefined')) 
	{
		GameEvents.SendCustomGameEventToServer( "donate_shop_bp_preorder", {currency : valute } );
		LoadingCreated()
	}

	$.Schedule( 0.25, function(){
		InitMainPanel()
		InitItems()
		InitInventory()
		BattlePassInit()
	})
}