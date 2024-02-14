var parentHUDElements = FindDotaHudElement("HUDElements");
if (parentHUDElements)
{
    var center_block = parentHUDElements.FindChildTraverse("center_block");
    $.GetContextPanel().SetParent(center_block);
}

GameEvents.Subscribe( 'thomas_shelby_buff_update', thomas_shelby_buff_update);
function thomas_shelby_buff_update(data)
{
    $("#ShelbyPanelAbilities").RemoveAndDeleteChildren()
    for (var i = 0; i < Object.keys(data.abilities).length; i++) 
    {
        let ability = Object.keys(data.abilities)[i]
        let ability_panel = $.CreatePanel("Panel", $("#ShelbyPanelAbilities"), "" );
        ability_panel.AddClass("ability_panel")
        if (ability == "attack")
        {
            let BuffImage = $.CreatePanel("DOTAAbilityImage", ability_panel, "")
            BuffImage.AddClass("BuffImage")
            BuffImage.abilityname = "action_attack";
            let lock_button = $.CreatePanel("Panel", ability_panel, "")
            lock_button.AddClass("lock_button")
            BuffImage.SetImage( "s2r://panorama/images/spellicons/action_attack_png.vtex" )
        }
        else if (ability.indexOf("item") !== -1) 
        {
            let BuffImage = $.CreatePanel("DOTAItemImage", ability_panel, "")
            BuffImage.AddClass("BuffImageItem")
            BuffImage.itemname = ability;
            let lock_button = $.CreatePanel("Panel", ability_panel, "")
            lock_button.AddClass("lock_button")
        }
        else
        {
            let BuffImage = $.CreatePanel("DOTAAbilityImage", ability_panel, "")
            BuffImage.AddClass("BuffImage")
            BuffImage.abilityname = ability;
            let lock_button = $.CreatePanel("Panel", ability_panel, "")
            lock_button.AddClass("lock_button")
        }
    }
}

function UpdateHeroHudBuffs()
{
	let hero_id = Players.GetLocalPlayerPortraitUnit()
	let hero = Entities.GetUnitName(hero_id)
	if ((hero === "npc_dota_hero_thomas_bebra")) 
    {
        $("#ShelbyPanelAbilities").style.visibility = "visible"
    } 
    else 
    {
    	$("#ShelbyPanelAbilities").style.visibility = "collapse"
    }
	$.Schedule(1/144, UpdateHeroHudBuffs)
}

UpdateHeroHudBuffs();