var CURRENT_DROP_ID = null
var rarity_color = // Цвет рарности
{
    common : "#b0c3d9",
    uncommon : "#5e98d9", 
    rare: "#4b69ff",
    mythical : "#8847ff", 
    legendary : "#d32ce6", 
    immortal : "#e4ae39", 
} 
var DELAY_SPAWN_ITEMS_ANIM = 0.07 // 0 - off
var STARTING_SPEED = 6000
var DROP_SLOT = 70
var DROP_POS = [0,0] // Позиция дропнутого айтема
var SOUND_TICK_WIDTH = 128
var last_chest_info = null

GameEvents.Subscribe('shop_birzha_open_chest_information', shop_birzha_open_chest_information)
function shop_birzha_open_chest_information(data)
{
    last_chest_info = data.chest_info
    InitChest(data.chest_info)
}

GameEvents.Subscribe('shop_birzha_open_chest_active', shop_birzha_open_chest_active)
function shop_birzha_open_chest_active(data)
{
    if (data.drop_id == null)
    {
        return
    }
    let item_position_in_drop_list = GetItemPositionInDropList(data.drop_id, data.items)
    if (item_position_in_drop_list == null)
    {
        return 
    }
    CURRENT_DROP_ID = item_position_in_drop_list
    OpenChest(data.items)
}

function InitChest(data, reopen)
{
    ClearOldChest()
    $("#ChestName").text = $.Localize("#"+data.chest_name)
    ChestInitItemsInRoll(data.chest_items)
    ChestInitItemsInChest(data.chest_items)
    ButtonSet(data.chest_id, data.chest_cost, data.chest_items, data.chest_cost_alt)
    $("#ChestHudMainPanel").style.opacity = "1"
    $("#ChestHudMainPanel").hittest = true
    $("#ChestCostLabel").text = data.chest_cost
    $.Msg(data.chest_cost_alt)
    if (data.chest_cost_alt && data.chest_cost_alt > 0)
    {
        $("#ChestCostLabelAlt").text = data.chest_cost_alt
        $("#AltCost").style.visibility = "visible"
    }
    else
    {
        $("#AltCost").style.visibility = "collapse"
    }
    $("#ChestHudMainPanel").SetPanelEvent("onactivate", function() {})
    $("#ChestHudMainPanel").SetHasClass("ChestHudAnimClose", false)
    $("#ChestHudMainPanel").SetHasClass("ChestHudAnimOpen", true)
    $("#OpenChestButton").style.visibility = "visible"
    if (!reopen)
    {
        Game.EmitSound("UI.Shop_Buy_start")
    }
}

function ButtonSet(chest_id, cost, chest_items, alt_cost)
{
    if (alt_cost == null || alt_cost == "undefined")
    {
        alt_cost = 0
    }
    if (player_table == null)
    {
        $("#OpenChestButton").SetPanelEvent('onactivate', function() {})
        $("#OpenChestButton").SetHasClass("no_money", true)
        $("#ChestCostLabel").SetHasClass("chest_cost_no_money", true)
        $("#ChestCostLabelAlt").SetHasClass("chest_cost_no_money", true)
        return
    }
    if (alt_cost && alt_cost > 0)
    {

        $.Msg(player_table_bp_owner.candies_count, alt_cost)

        if (player_table_bp_owner.candies_count < alt_cost && player_table.birzha_coin < cost)
        {
            $("#OpenChestButton").SetPanelEvent('onactivate', function() {})
            $("#OpenChestButton").SetHasClass("no_money", true)
            $("#ChestCostLabel").SetHasClass("chest_cost_no_money", true)
            $("#ChestCostLabelAlt").SetHasClass("chest_cost_no_money", true)
            return
        }
        if (player_table_bp_owner.candies_count < alt_cost)
        {
            $("#ChestCostLabelAlt").SetHasClass("chest_cost_no_money", true)
        }
        if (player_table.birzha_coin < cost)
        {
            $("#ChestCostLabel").SetHasClass("chest_cost_no_money", true)
        }
    }
    else
    {
        if (player_table.birzha_coin < cost)
        {
            $("#OpenChestButton").SetPanelEvent('onactivate', function() {})
            $("#OpenChestButton").SetHasClass("no_money", true)
            $("#ChestCostLabel").SetHasClass("chest_cost_no_money", true)
            $("#ChestCostLabelAlt").SetHasClass("chest_cost_no_money", true)
            return
        }
    }
    if (player_table_bp_owner.candies_count >= alt_cost)
    {
        $("#ChestCostLabelAlt").SetHasClass("chest_cost_no_money", false)
    }
    if (player_table.birzha_coin >= cost)
    {
        $("#ChestCostLabel").SetHasClass("chest_cost_no_money", false)
    }
    if (IsHeroHasAllItemsInChest(chest_items))
    {
        $("#OpenChestButton").SetPanelEvent('onactivate', function() {})
        $("#OpenChestButton").SetHasClass("has_all_items", true)
        return
    }
    $("#OpenChestButton").SetHasClass("no_money", false)
    $("#OpenChestButton").SetPanelEvent('onactivate', function()
    {
        GameEvents.SendCustomGameEventToServer( "shop_birzha_open_chest_get_reward", { chest_id : chest_id } );
    })
}

function CloseChest()
{
    $("#ChestHudMainPanel").hittest = false
    $("#ChestHudMainPanel").style.opacity = "0"
    $("#DropItemPanel").SetHasClass("DropItemPanelVisible", false)
    last_chest_info = null

    Game.EmitSound("UI.Shop_Category_Open")

    $("#ChestHudMainPanel").SetHasClass("ChestHudAnimClose", true)
    $("#ChestHudMainPanel").SetHasClass("ChestHudAnimOpen", false)

    $.Schedule( 0.35, function()
    {
		InitMainPanel()
		InitItems()
    })
}

function ClearOldChest()
{
    $("#RollItemsListMain").RemoveAndDeleteChildren()
    $("#ItemsInChestBlock").RemoveAndDeleteChildren()
    $("#RollItemsListMain").style.position = "0px 0px 0px"
}

function ChestInitItemsInRoll(items)
{
    $("#RollItemsListMain").RemoveAndDeleteChildren()
    for (let i = 0; i <= 100; i++)
    {
        let randomIndex = Math.floor(1 + Math.random() * (Object.keys(items).length - 1));
        let randomElement = items[randomIndex];
        CreateItemInfo($("#RollItemsListMain"), randomElement, 0, true, DROP_SLOT == i, i)
    }
    $("#RollItemsListMain").style.position = "0px 0px 0px"
}  

function ChestInitItemsInChest(items)
{
    for (let i = 0; i <= Object.keys(items).length; i++)
    {
        let item_info = items[i]
        if (item_info)
        {
            CreateItemInfo($("#ItemsInChestBlock"), item_info, i)
        }
    }
}

function CreateItemInfo(main_panel, item_info, delay_count, roll, drop_slot, c)
{
    let rare = item_info.rare
    let name = item_info.item_name
    let icon = item_info.item_icon

    $.Schedule( DELAY_SPAWN_ITEMS_ANIM * delay_count, function()
    {
        let panel_id = ""
        
        if (drop_slot)
        {
            panel_id = "dropped_item"
        }

        let item_panel = $.CreatePanel("Panel", main_panel, panel_id)

        if (roll)
        {
            item_panel.AddClass("item_panel_roll")
        }
        else
        {
            item_panel.AddClass("item_panel")
        }

        let item_icon = $.CreatePanel("Panel", item_panel, "item_icon")
        item_icon.AddClass("item_icon")
        item_icon.style.backgroundImage = 'url("' + icon + '")';
        item_icon.style.backgroundSize = "100%"

        let item_panel_name = $.CreatePanel("Panel", item_panel, "item_panel_name")
        item_panel_name.AddClass("item_panel_name")
        item_panel_name.style.backgroundColor = rarity_color[rare]

        let item_name = $.CreatePanel("Label", item_panel_name, "item_name")
        item_name.AddClass("item_name")
        item_name.text = $.Localize("#"+name)

        let item_panel_border = $.CreatePanel("Panel", item_panel, "item_panel_border")
        item_panel_border.AddClass("item_panel_border")
        item_panel_border.style.borderBrush = 'gradient( linear, 0% 100%, 0% 20%, from(' + rarity_color[rare] + '), to( rgba(0,0,0,0.1) ) )'

        if (!roll)
        {
            if (HasItemInventory(item_info.item_id))
            {
                item_panel.AddClass("has_dropped_item")
            }
        }

        $.Schedule( 0.02, function()
        {
            item_panel.style.opacity = "1" 

            if (roll && drop_slot)
            {
                let check_pos = item_panel.style.position
                let SpaceFind = check_pos.indexOf('px');
                SOUND_TICK_WIDTH = (item_panel.actuallayoutwidth / item_panel.actualuiscale_x) + (7 * 2)
                DROP_POS[0] = -((Number(check_pos.substring(0, SpaceFind)) - ( (item_panel.actuallayoutwidth / item_panel.actualuiscale_x) * 2) - (7 * 4)) - (item_panel.actuallayoutwidth / item_panel.actualuiscale_x))
                DROP_POS[1] = -(Number(check_pos.substring(0, SpaceFind)) - ( (item_panel.actuallayoutwidth / item_panel.actualuiscale_x) * 2) - (7 * 4))
            }
        })
    }) 
}

function OpenChest(items)
{
    Game.EmitSound("ui.treasure_count")
    let current = 0
    // НУЖНО ПЕРЕДАТЬ ДРОП АЙДИ ШМОТКИ
    if (CURRENT_DROP_ID != null)
    {
        let drop_info = items[CURRENT_DROP_ID]
        let slot_drop = $("#RollItemsListMain").FindChildTraverse("dropped_item")
        if (slot_drop)
        {   
            let item_icon = slot_drop.FindChildTraverse("item_icon")
            if (item_icon)
            {
                item_icon.style.backgroundImage = 'url("' + drop_info.item_icon + '")';
            }
            let item_panel_name = slot_drop.FindChildTraverse("item_panel_name")
            if (item_panel_name)
            {
                item_panel_name.style.backgroundColor = rarity_color[drop_info.rare]
            }
            let item_name = slot_drop.FindChildTraverse("item_name")
            if (item_name)
            {
                item_name.text = item_name.text = $.Localize("#"+drop_info.item_name)
            }
            let item_panel_border = slot_drop.FindChildTraverse("item_panel_border")
            if (item_panel_border)
            {
                item_panel_border.style.borderBrush = 'gradient( linear, 0% 100%, 0% 20%, from(' + rarity_color[drop_info.rare] + '), to( rgba(0,0,0,0.1) ) )'
            }
        }
    }

    let randomly_max_distance = Math.floor(Math.random() * (DROP_POS[1] - DROP_POS[0] + 1) + DROP_POS[0]);
    ChestAnimate(current, randomly_max_distance, STARTING_SPEED, SOUND_TICK_WIDTH, items[CURRENT_DROP_ID], items)
    $("#OpenChestButton").style.visibility = "collapse"
}

function ChestAnimate(current, drop_distance, speed, sound_tick, item_drop_info, items)
{
    if ($("#ChestHudMainPanel").BHasClass("ChestHudAnimClose"))
    {
        CURRENT_DROP_ID = null
        CloseDropPanel()
        $.Schedule( 0.35, function()
        {
            InitMainPanel()
            InitItems()
        })
        return
    }
    if (current <= drop_distance)
    {
        $.Schedule(0.1, function() 
        {
            GiveItemDrop(item_drop_info, items)
        })
        return
    }
    current = current - (speed * Game.GetGameFrameTime())
    sound_tick = sound_tick - (speed * Game.GetGameFrameTime())
    if (sound_tick <= 0)
    {
        sound_tick = SOUND_TICK_WIDTH
        Game.EmitSound("random_wheel_lever")
    }
    if (current <= 0.37 * drop_distance)
    {
        speed = speed - (speed * Game.GetGameFrameTime())
    }
    speed = Math.max(100, speed);
    $("#RollItemsListMain").style.position = current + "px 0px 0px"
    $.Schedule(Game.GetGameFrameTime(), function() 
    {
		ChestAnimate(current, drop_distance, speed, sound_tick, item_drop_info, items)
	})
}

function GiveItemDrop(item_drop_info, items)
{
    $("#OpenChestButton").style.visibility = "visible"
    $("#DropItemPanel").SetHasClass("DropItemPanelVisible", true)
    $("#ItemDropName").text = $.Localize("#"+item_drop_info.item_name)
    $("#ItemDropIcon").style.backgroundImage = 'url("' + item_drop_info.item_icon + '")';
    $("#ItemDropIcon").style.backgroundSize = "100%"

    let item_icon_terrorblade_color = $("#ItemDropIcon").FindChildTraverse("item_icon_terrorblade_color")
    if (item_icon_terrorblade_color)
    {
        item_icon_terrorblade_color.DeleteAsync(0)
    }

    $("#DropEffect").style.washColor = rarity_color[item_drop_info.rare]
    $("#DropEffect_top").style.washColor = rarity_color[item_drop_info.rare]
    $("#DropEffect_bottom").style.washColor = rarity_color[item_drop_info.rare]

    let item_drop_effect = $.CreatePanel("DOTAParticleScenePanel", $("#ChestHudMainPanel"), "", {particleName:"particles/ui/ui_generic_treasure_impact.vpcf", renderdeferred:"true", particleonly:"false", startActive:"true", cameraOrigin:"0 0 300", lookAt:"0 0 0", fov:"60"})
    item_drop_effect.AddClass("item_drop_effect")
    item_drop_effect.hittest = false
    item_drop_effect.DeleteAsync(3)

    Game.EmitSound("ui.treasure_01")

    $("#ItemDropClaimButton").SetPanelEvent('onactivate', function()
    {
        if (last_chest_info != null)
        {
            InitChest(last_chest_info, true)
        }
        CloseDropPanel()
        $.Schedule( 0.35, function()
        {
            InitMainPanel()
            InitItems()
        })
    })
    CURRENT_DROP_ID = null
}

function CloseDropPanel()
{
    $("#RollItemsListMain").style.position = "0px 0px 0px"
    $("#DropItemPanel").SetHasClass("DropItemPanelVisible", false)
}

function GetItemPositionInDropList(id, items)
{
    for (let i = 0; i <= Object.keys(items).length; i++)
    {
        let item_info = items[i]
        if (item_info && item_info.item_id == id)
        {
            return i
        }
    }
    return null
}

function IsHeroHasAllItemsInChest(items)
{
    let all_items = true
    for (let i = 0; i <= Object.keys(items).length; i++)
    {
        let item_info = items[i]
        if (item_info && !HasItemInventory(item_info.item_id))
        {
            all_items = false
            break
        }
    }
    return all_items
}