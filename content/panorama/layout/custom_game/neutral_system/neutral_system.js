var ROLLER_PANEL = $("#NeutralsRollerPanel")
var ROLLER_BUTTON = $("#CraftNeutral")
let inventory_composition_layer_container = FindDotaHudElement("inventory_composition_layer_container")
if (inventory_composition_layer_container)
{
    $("#NeutralSlotCustom").SetParent(inventory_composition_layer_container)
    ROLLER_BUTTON = inventory_composition_layer_container.FindChildTraverse("NeutralSlotCustom")
}

let center_with_stats = FindDotaHudElement("center_with_stats")
if (center_with_stats)
{
    $("#NeutralsRollerPanel").SetParent(center_with_stats)
    ROLLER_PANEL = center_with_stats.FindChildTraverse("NeutralsRollerPanel")
}

function SetShowItemTooltip(panel, ability, level)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltipForLevel', panel, ability, level); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function OpenRollerPanel()
{
    ROLLER_PANEL.SetHasClass("Visible", !ROLLER_PANEL.BHasClass("Visible"))
}

GameEvents.Subscribe( 'birzha_create_items_neutral_list', CreateNeutralList);

function CreateNeutralList(data)
{
    let ItemsListNeutrals = ROLLER_PANEL.FindChildTraverse("ItemsListNeutrals")
    let HeaderText = ROLLER_PANEL.FindChildTraverse("HeaderText")
    HeaderText.SetDialogVariable("neutral_tier", String(data.tier));
    ItemsListNeutrals.RemoveAndDeleteChildren()
    ROLLER_BUTTON.SetHasClass("CraftCreate", true)
    for (let value_id in data.items_list)
    {
        let item_data = data.items_list[value_id]
        CreateItemChoose(ItemsListNeutrals, item_data[1], item_data[2], value_id)
    }
}

function CreateItemChoose(ItemsListNeutrals, item_first_name, item_second_name, value_id)
{
    let item_choose_panel = $.CreatePanel("Panel", $.GetContextPanel(), "")
    item_choose_panel.AddClass("item_choose_panel")

    let item_main = $.CreatePanel("Panel", item_choose_panel, "")
    item_main.AddClass("item_main_panel")

    let DOTAItem_1 = $.CreatePanel("DOTAItemImage", item_main, "", {scaling : "stretch-to-fit-y-preserve-aspect"})
    DOTAItem_1.AddClass("DOTAItemImageCustom")
    DOTAItem_1.itemname = item_first_name

    if (item_second_name)
    {
        let item_second = $.CreatePanel("Panel", item_choose_panel, "")
        item_second.AddClass("item_second_panel")

        let DOTAItem_2 = $.CreatePanel("DOTAItemImage", item_second, "", {scaling : "stretch-to-fit-y-preserve-aspect"})
        DOTAItem_2.AddClass("DOTAItemImageCustom")
        DOTAItem_2.itemname = item_second_name[1]
        
        SetShowItemTooltip(DOTAItem_2, item_second_name[1], item_second_name[2])
    }

    item_choose_panel.SetPanelEvent("onactivate", function() 
    {
        if (!ROLLER_PANEL.BHasClass("Visible")) { return }
        CloseNeutralListFaster()
        GameEvents.SendCustomGameEventToServer( "birzha_neutral_item_choose", {item_choose : value_id} );
    });

    item_choose_panel.SetParent(ItemsListNeutrals)
}

function CloseNeutralListFaster()
{
    let ItemsListNeutrals = ROLLER_PANEL.FindChildTraverse("ItemsListNeutrals")
    ItemsListNeutrals.RemoveAndDeleteChildren()
    ROLLER_BUTTON.SetHasClass("CraftCreate", false)
    ROLLER_PANEL.SetHasClass("Visible", false)
}