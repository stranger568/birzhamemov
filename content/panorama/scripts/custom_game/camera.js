GameEvents.Subscribe( 'set_camera_target', SetCamera );
GameEvents.Subscribe( 'chat_birzha_sound', ChatSound );
GameEvents.Subscribe( 'random_hero_chat', RandomHeroChat );
GameEvents.Subscribe( 'double_rating_chat', DoubleRatingChat );
GameEvents.Subscribe( 'win_predict_chat', win_predict_chat );
GameEvents.Subscribe( 'chat_bm_smile', ChatSmile );
GameEvents.Subscribe( 'set_player_icon', set_player_icon);

function SetCamera( data )
{
	GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin( data.id ), 0.1);
} 

function set_player_icon(data)
{	
	Entities.SetMinimapIcon( data.entity, data.icon );
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

	if (Game.IsPlayerMuted( data.player_id ) || Game.IsPlayerMutedVoice( data.player_id ) || Game.IsPlayerMutedText( data.player_id )) {
        return
    }

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

	Game.EmitSound(data.sound_name_global)

	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	let HeroIcon = $.CreatePanel("Image", ChatPanelSound, "", { src:`${hero_icon}`, style:"width:40px;height:23px;margin-right:4px;border:1px solid black;" }); 
	let LabelPlayer = $.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	let SoundIcon = $.CreatePanel("Image", ChatPanelSound, "", { class:"ChatWheelIcon", src:"file://{images}/hud/reborn/icon_scoreboard_mute_sound.psd" }); 
	let LabelSound = $.CreatePanel("Label", ChatPanelSound, "", { text:`${sound_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });

	$.Schedule( 7, function(){
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

	var playerInfo = Game.GetPlayerInfo( data.id );
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
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	let LabelPlayer = $.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	let LabelSound = $.CreatePanel("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });

	$.Schedule( 7, function(){
		if (ChatPanelSound) {
	    	ChatPanelSound.AddClass('ChatLine');  
		}
	})
}  


function DoubleRatingChat( data )
{
	let dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
	let Hudchat = dotaHud.FindChildTraverse("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")

	let player_name = Players.GetPlayerName( data.id )
	let hero_name = $.Localize("#birzha_double_rating")
	let color = "white;"

	var playerInfo = Game.GetPlayerInfo( data.id );
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
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	let LabelPlayer = $.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	let LabelSound = $.CreatePanel("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });

	$.Schedule( 7, function(){
		if (ChatPanelSound) {
	    	ChatPanelSound.AddClass('ChatLine');  
		}
	})
}  

function win_predict_chat( data )
{
	let dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
	let Hudchat = dotaHud.FindChildTraverse("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")

	let player_name = Players.GetPlayerName( data.id )
	let hero_name = $.Localize("#birzha_win_predict") + " " + data.count
	let color = "white;"

	var playerInfo = Game.GetPlayerInfo( data.id );
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
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	let LabelPlayer = $.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	let LabelSound = $.CreatePanel("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });

	$.Schedule( 7, function(){
		if (ChatPanelSound) {
	    	ChatPanelSound.AddClass('ChatLine');  
		}
	})
} 

function ChatSmile( data )
{
    let dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
    let Hudchat = dotaHud.FindChildTraverse("HudChat")
    let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")

    let hero_icon = "file://{images}/custom_game/hight_hood/heroes/" + data.hero_name + ".png"
    let smile_icon = "file://{images}/custom_game/smiles/" + data.smile_icon + ".png"
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
    let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
    let HeroIcon = $.CreatePanel("Image", ChatPanelSound, "", { src:`${hero_icon}`, style:"width:40px;height:23px;margin-right:4px;border:1px solid black;" }); 
    let LabelPlayer = $.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
    let LabelSound = $.CreatePanel("Image", ChatPanelSound, "", { class:"SmileIcon", style:"width:35px;height:35px;", src:`${smile_icon}` }); 

    $.Schedule( 7, function(){
        if (ChatPanelSound) {
            ChatPanelSound.AddClass('ChatLine');  
        }
    })
}