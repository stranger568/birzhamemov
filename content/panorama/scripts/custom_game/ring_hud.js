var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("AbilitiesAndStatBranch");
$("#ButtonRingHud").SetParent(parentHUDElements.FindChildrenWithClassTraverse("LeftRightFlow")[0]);

var button_ring =  $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("AbilitiesAndStatBranch").FindChildrenWithClassTraverse("LeftRightFlow")[0].FindChildTraverse("ButtonRingHud").FindChildTraverse("ButtonRingHud_b")
var button_ring_2 =  $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements").FindChildTraverse("AbilitiesAndStatBranch").FindChildrenWithClassTraverse("LeftRightFlow")[0].FindChildTraverse("ButtonRingHud")

button_ring.SetPanelEvent('onmouseover', function() {	
	var pos = button_ring.GetPositionWithinWindow()
	var table_gamble = CustomNetTables.GetTableValue('gamble_item', String(  Entities.GetUnitName( Players.GetLocalPlayerPortraitUnit() )   ));
	if (table_gamble) {
		$("#RingHudPanel").FindChild("Strength").text = $.Localize("#gamble_Strength") + table_gamble.str
		$("#RingHudPanel").FindChild("Agility").text = $.Localize("#gamble_Agility") + table_gamble.agi
		$("#RingHudPanel").FindChild("Intellect").text = $.Localize("#gamble_Intellect") + table_gamble.int
		$("#RingHudPanel").FindChild("Damage").text = $.Localize("#gamble_Damage") + table_gamble.damage
		$("#RingHudPanel").FindChild("Attackspeed").text = $.Localize("#gamble_Attackspeed") + table_gamble.attack_speed
		$("#RingHudPanel").FindChild("Movespeed").text = $.Localize("#gamble_Movespeed") + table_gamble.movespeed
		$("#RingHudPanel").FindChild("Armor").text = $.Localize("#gamble_Armor") + table_gamble.armor
		$("#RingHudPanel").FindChild("Magicresist").text = $.Localize("#gamble_Magicresist") + table_gamble.mag_resist + "%"
		$("#RingHudPanel").FindChild("Regenhp").text = $.Localize("#gamble_Regenhp") + table_gamble.hp_regen
		$("#RingHudPanel").FindChild("Regenmana").text = $.Localize("#gamble_Regenmana") + table_gamble.mana_regen
		$("#RingHudPanel").FindChild("Magicdamage").text = $.Localize("#gamble_Magicdamage") + table_gamble.mag_damage + "%"

		if ($("#two_bonus")) {
			$("#two_bonus").DeleteAsync( 0 );
		}

		if (table_gamble.two_bonus == "none") 
		{
			$("#RingHudPanelTwo").style.visibility = "collapse"
		} 
		else if (table_gamble.two_bonus == "lifesteal") 
		{
			$("#RingHudPanelTwo").style.visibility = "visible"
			var two_bonus = $.CreatePanel("Label", $("#RingHudPanel"), "two_bonus");
            two_bonus.text = $.Localize("#gamble_lifesteal") + table_gamble.two_bonus_int + "%"
		} 
		else if (table_gamble.two_bonus == "cooldown") 
		{
			$("#RingHudPanelTwo").style.visibility = "visible"
			var two_bonus = $.CreatePanel("Label", $("#RingHudPanel"), "two_bonus");
            two_bonus.text = $.Localize("#gamble_cooldown") + table_gamble.two_bonus_int + "%"
		}
		else if (table_gamble.two_bonus == "evasion") 
		{
			$("#RingHudPanelTwo").style.visibility = "visible"
			var two_bonus = $.CreatePanel("Label", $("#RingHudPanel"), "two_bonus");
            two_bonus.text = $.Localize("#gamble_evasion") + table_gamble.two_bonus_int + "%"
		}
		else if (table_gamble.two_bonus == "all_stats") 
		{
			$("#RingHudPanelTwo").style.visibility = "visible"
			var two_bonus = $.CreatePanel("Label", $("#RingHudPanel"), "two_bonus");
            two_bonus.text = $.Localize("#gamble_mainattribute") + table_gamble.two_bonus_int
		}
		else if (table_gamble.two_bonus == "resist") 
		{
			$("#RingHudPanelTwo").style.visibility = "visible"
			var two_bonus = $.CreatePanel("Label", $("#RingHudPanel"), "two_bonus");
            two_bonus.text = $.Localize("#gamble_statusresist") + table_gamble.two_bonus_int + "%"
		}
		else if (table_gamble.two_bonus == "incoming") 
		{
			$("#RingHudPanelTwo").style.visibility = "visible"
			var two_bonus = $.CreatePanel("Label", $("#RingHudPanel"), "two_bonus");
            two_bonus.text = $.Localize("#gamble_outgoingdmg") + table_gamble.two_bonus_int + "%"
		}

	} else {
		$("#RingHudPanel").FindChild("Strength").text = $.Localize("#gamble_Strength") + 0
		$("#RingHudPanel").FindChild("Agility").text = $.Localize("#gamble_Agility") + 0
		$("#RingHudPanel").FindChild("Intellect").text = $.Localize("#gamble_Intellect") + 0
		$("#RingHudPanel").FindChild("Damage").text = $.Localize("#gamble_Damage") + 0
		$("#RingHudPanel").FindChild("Attackspeed").text = $.Localize("#gamble_Attackspeed") + 0
		$("#RingHudPanel").FindChild("Movespeed").text = $.Localize("#gamble_Movespeed") +0
		$("#RingHudPanel").FindChild("Armor").text = $.Localize("#gamble_Armor") + 0
		$("#RingHudPanel").FindChild("Magicresist").text = $.Localize("#gamble_Magicresist") + 0 + "%"
		$("#RingHudPanel").FindChild("Regenhp").text = $.Localize("#gamble_Regenhp") + 0
		$("#RingHudPanel").FindChild("Regenmana").text = $.Localize("#gamble_Regenmana") + 0
		$("#RingHudPanel").FindChild("Magicdamage").text = $.Localize("#gamble_Magicdamage") + 0 + "%"
		$("#RingHudPanelTwo").style.visibility = "collapse"
	}
	$("#RingHudPanel").style.visibility = "visible"
});

button_ring.SetPanelEvent('onmouseout', function() {
    $("#RingHudPanel").style.visibility = "collapse"
});


function Hack()
{
	if ( Entities.IsHero( Players.GetLocalPlayerPortraitUnit() ) && ( Entities.HasItemInInventory( Players.GetLocalPlayerPortraitUnit(), "item_gamble_gold_ring" )  ||  Entities.HasItemInInventory( Players.GetLocalPlayerPortraitUnit(), "item_gamble_gold_ring_2" )  ) ) {
		button_ring_2.visible = true;
	} else {
		button_ring_2.visible = false;
	}
    $.Schedule(1/144, Hack)
}

Hack()