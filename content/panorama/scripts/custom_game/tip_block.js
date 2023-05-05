var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements");
$.GetContextPanel().SetParent(parentHUDElements);

GameEvents.Subscribe("TipPlayerNotification", TipPlayerNotification);

function TipPlayerNotification(data)
{
	

	var playerInfo_1 = Game.GetPlayerInfo( data.player_id_1 );
	var playerInfo_2 = Game.GetPlayerInfo( data.player_id_2 );

	let notification = $.CreatePanel("Panel", $("#PlayersTipHistory"), "")
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
  		$.CreatePanelWithProperties("DOTAParticleScenePanel", notification, "particle", { style: "width:100%;height:92%;z-index:-1;vertical-align:center;opacity-mask: url('s2r://panorama/images/masks/bg_vignette_psd.vtex');", particleName: "particles/ui/battle_pass/ui_bp_2022_diretide_find_match.vpcf", particleonly:"true", startActive:"true", cameraOrigin:"0 0 165", lookAt:"0 0 0",  fov:"15", squarePixels:"true" });
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