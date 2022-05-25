GameEvents.Subscribe( 'set_camera_target', SetCamera );
GameEvents.Subscribe( 'chat_birzha_sound', ChatSound );
GameEvents.Subscribe( 'random_hero_chat', RandomHeroChat );

function SetCamera( data )
{
	GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin( data.id ), 0.1);
} 

function ChatSound( data )
{
	let dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
	let Hudchat = dotaHud.FindChildTraverse("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")

	let hero_icon = "file://{images}/custom_game/hight_hood/heroes/" + data.hero_name + ".png"
	let player_name = Players.GetPlayerName( data.player_id )
	let sound_name = data.sound_name
	let color = "white;"

	var playerInfo = Game.GetPlayerInfo( data.player_id );
	if ( playerInfo )
	{
		if ( GameUI.CustomUIConfig().team_colors )
		{
			var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo.player_team_id ];
			if ( teamColor )
			{
				color = teamColor;
			}
		}
	}

	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanelWithProperties("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	let HeroIcon = $.CreatePanelWithProperties("Image", ChatPanelSound, "", { src:`${hero_icon}`, style:"width:40px;height:23px;margin-right:4px;border:1px solid black;" }); 
	let LabelPlayer = $.CreatePanelWithProperties("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	let SoundIcon = $.CreatePanelWithProperties("Image", ChatPanelSound, "", { class:"ChatWheelIcon", src:"file://{images}/hud/reborn/icon_scoreboard_mute_sound.psd" }); 
	let LabelSound = $.CreatePanelWithProperties("Label", ChatPanelSound, "", { text:`${sound_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });

	$.Schedule( 3, function(){
		if (ChatPanelSound) {
	    	ChatPanelSound.AddClass('ChatLine');  
		}
	})
}     

function RandomHeroChat( data )
{
	let dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
	let Hudchat = dotaHud.FindChildTraverse("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")

	let player_name = Players.GetPlayerName( data.id )
	let hero_name = $.Localize("#birzha_random_hero") + $.Localize("#"+data.hero) 
	let color = "white;"

	var playerInfo = Game.GetPlayerInfo( data.player_id );
	if ( playerInfo )
	{
		if ( GameUI.CustomUIConfig().team_colors )
		{
			var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo.player_team_id ];
			if ( teamColor )
			{
				color = teamColor;
			}
		}
	}

	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanelWithProperties("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	let LabelPlayer = $.CreatePanelWithProperties("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	let LabelSound = $.CreatePanelWithProperties("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });

	$.Schedule( 3, function(){
		if (ChatPanelSound) {
	    	ChatPanelSound.AddClass('ChatLine');  
		}
	})
}  