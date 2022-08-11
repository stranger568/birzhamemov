var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements");
$.GetContextPanel().SetParent(parentHUDElements);

GameEvents.Subscribe("TipPlayerNotification", TipPlayerNotification);

function TipPlayerNotification(data)
{
	Game.EmitSound("General.Coins")

	var playerInfo_1 = Game.GetPlayerInfo( data.player_id_1 );
	var playerInfo_2 = Game.GetPlayerInfo( data.player_id_2 );

	let notification = $.CreatePanel("Panel", $("#PlayersTipHistory"), "")
	notification.AddClass("notification")
	notification.AddClass("visible")

	let one_player = $.CreatePanel("Panel", notification, "")
	one_player.AddClass("playerbox")

	let one_player_portrait = $.CreatePanel("Panel", one_player, "")
	one_player_portrait.AddClass("one_player_portrait")
	one_player_portrait.style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + playerInfo_1.player_selected_hero + '.png")'
	one_player_portrait.style.backgroundSize = "100%"

	let one_player_nickname = $.CreatePanel("Label", one_player, "")
	one_player_nickname.AddClass("one_player_nickname")
	one_player_nickname.text = playerInfo_1.player_name

	let label_tip = $.CreatePanel("Label", notification, "")
	label_tip.AddClass("label_tip")
	label_tip.text = $.Localize("#tipped_" + getRandomInt(17))
     

	let two_player = $.CreatePanel("Panel", notification, "")
	two_player.AddClass("playerbox_two")
	 
	let two_player_portrait = $.CreatePanel("Panel", two_player, "")
	two_player_portrait.AddClass("two_player_portrait")
	two_player_portrait.style.backgroundImage = 'url("file://{images}/custom_game/hight_hood/heroes/' + playerInfo_2.player_selected_hero + '.png")'
	two_player_portrait.style.backgroundSize = "100%"

	let two_player_nickname = $.CreatePanel("Label", two_player, "")
	two_player_nickname.AddClass("two_player_nickname")
	two_player_nickname.text = playerInfo_2.player_name

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

	$.Schedule(4.5, function() {
		notification.RemoveClass("visible")
	})

	notification.DeleteAsync(5)
}

function getRandomInt(max) {
  	return Math.floor(Math.random() * max);
}