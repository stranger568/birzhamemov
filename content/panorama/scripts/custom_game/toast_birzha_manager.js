var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements");
$.GetContextPanel().SetParent(parentHUDElements);

GameEvents.Subscribe("TipPlayerNotification", TipPlayerNotification);

function TipPlayerNotification(data)
{
	var playerInfo_1 = Game.GetPlayerInfo( data.player_id_1 );
	var playerInfo_2 = Game.GetPlayerInfo( data.player_id_2 );

	let notification = $.CreatePanel("Panel", $("#ToastBirzhaInfo"), "")
	notification.AddClass("notification")
	notification.AddClass("visible")

	let notification_info = $.CreatePanel("Panel", notification, "")
	notification_info.AddClass("notification_info")

	let one_player = $.CreatePanel("Panel", notification_info, "")
	one_player.AddClass("playerbox")

	let one_player_portrait = $.CreatePanel("Panel", one_player, "")
	one_player_portrait.AddClass("one_player_portrait")
	one_player_portrait.style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + playerInfo_1.player_selected_hero + '.png")'
	one_player_portrait.style.backgroundSize = "100%"

	let one_player_nickname = $.CreatePanel("Label", one_player, "")
	one_player_nickname.AddClass("one_player_nickname")
	one_player_nickname.text = playerInfo_1.player_name

	let label_tip = $.CreatePanel("Label", notification_info, "")
	label_tip.AddClass("label_tip")
	label_tip.text = $.Localize("#tipped_" + data.type)

	let two_player = $.CreatePanel("Panel", notification_info, "")
	two_player.AddClass("playerbox_two")
	 
	let two_player_portrait = $.CreatePanel("Panel", two_player, "")
	two_player_portrait.AddClass("two_player_portrait")
	two_player_portrait.style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + playerInfo_2.player_selected_hero + '.png")'
	two_player_portrait.style.backgroundSize = "100%"

	let two_player_nickname = $.CreatePanel("Label", two_player, "")
	two_player_nickname.AddClass("two_player_nickname")
	two_player_nickname.text = playerInfo_2.player_name

	if (HasItemInventory(185, data.player_id_1))
  	{
  		Game.EmitSound("tip.silver.ti11")
  		$.CreatePanel("DOTAParticleScenePanel", notification, "particle", { style: "width:100%;height:92%;z-index:-1;vertical-align:center;opacity-mask: url('s2r://panorama/images/masks/bg_vignette_psd.vtex');", particleName: "particles/ui/battle_pass/ui_bp_2022_diretide_find_match.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"15", squarePixels:"true" });
  	} else {
  		Game.EmitSound("General.Coins")
  	}

  	if ( GameUI.CustomUIConfig().team_colors )
  	{
    	var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo_1.player_team_id ]
	    if ( teamColor )
	    {
	      	one_player_nickname.style.color = teamColor
	    }
  	}

  	if ( GameUI.CustomUIConfig().team_colors )
  	{
    	var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo_2.player_team_id ]
    	if ( teamColor )
    	{
     	 	two_player_nickname.style.color = teamColor
    	}
  	}

	$.Schedule(4.5, function() 
	{
		notification.RemoveClass("visible")
	})

	notification.DeleteAsync(5)
}

function HasItemInventory(item_id, id)
{
	let player_table = CustomNetTables.GetTableValue("birzhashop", String(id))
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

GameEvents.Subscribe("birzha_toast_manager_create", birzha_toast_manager_create);

function birzha_toast_manager_create(data)
{
    $.Msg(data.sound)
    if (data.sound)
    {
        Game.EmitSound(data.sound)
    }
    else
    {
        Game.EmitSound("NeutralLootDrop.Notification")
    }
    let notification = $.CreatePanel("Panel", $("#ToastBirzhaInfo"), "")
    notification.AddClass("game_notification")
    $.Schedule(0.1, function() 
    {
        notification.AddClass("visible")
    })
    let skill_icon = $.CreatePanel("Panel", notification, "")
    skill_icon.AddClass("game_notification_icon")
    skill_icon.style.backgroundImage = 'url( "file://{images}/custom_game/events/' + data.icon + '.png" )';
    skill_icon.style.backgroundSize = "100%"

    let skill_desc = $.CreatePanel("Label", notification, "")
    skill_desc.AddClass("game_notification_description")
    skill_desc.html = true

    if (data.target && data.caster)
    {
        skill_desc.text = $.Localize("#system_of_contracts") + " <font color='#FFD700'>" + $.Localize( "#" + data.caster ) + "</font> " + " " + $.Localize("#"+data.text) + " " + " <font color='#FF8C00'>" + $.Localize( "#" + data.target ) + "</font> ";
    }
    else if (data.pucci)
    {
        skill_desc.text = $.Localize("#system_pucci_quest") + $.Localize("#Birzha_warning_pucci") + " <font color='#FFD700'>" + data.count + " / 14" + " </font>" + $.Localize("#Birzha_warning_pucci_quest");
    }
    else if (data.dropped_item)
    {
        skill_desc.text = " <font color='#FFD700'>" + $.Localize( "#"+data.hero_id ) + "</font> " + $.Localize("#OverthrowTextPickup") + " <font color='#FF8C00'>" + $.Localize("#DOTA_Tooltip_Ability_" + data.dropped_item)
    }
    else if (data.kill)
    {
        skill_desc.text = " <font color='#FFD700'>" + $.Localize( "#"+data.hero_id ) + "</font> " + " " + $.Localize("#KillMessageText") + " <font color='#FF8C00'>" + data.gold + $.Localize("#KillMessageText_gold") + data.exp + $.Localize("#KillMessageText_exp")
    }
    else
    {
        skill_desc.text = $.Localize("#"+data.text)
    }

    $.Schedule(6, function() {
        notification.RemoveClass("visible")
    })
    notification.DeleteAsync(7)    
}

GameEvents.Subscribe("contract_heroes_activate", contract_heroes_activate);
function contract_heroes_activate(data)
{
    let heroes = data.heroes
    for (var i = 1; i <= Object.keys(heroes).length; i++) 
    {
        if (heroes[i])
        {
            let find = $("#ContractSelector").FindChildTraverse(heroes[i])
            if (find == null)
            {
                let HeroSelect = $.CreatePanel("Panel", $("#ContractSelector"), heroes[i])
                HeroSelect.AddClass("HeroSelect")
                let HeroPortrait = $.CreatePanel("Panel", HeroSelect, "")
                HeroPortrait.AddClass("HeroPortrait")
                HeroPortrait.style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + heroes[i] + '.png")'
                HeroPortrait.style.backgroundSize = "100%"
                let d = i
                let hero_name = heroes[d]
                HeroSelect.SetPanelEvent("onactivate", function() 
                { 
                    GameEvents.SendCustomGameEventToServer("birzha_contract_target_selected", {hero_name :  hero_name});
                });
            }
        }
    }
}

GameEvents.Subscribe("contract_heroes_close", contract_heroes_close);
function contract_heroes_close()
{
    $("#ContractSelector").RemoveAndDeleteChildren()
}