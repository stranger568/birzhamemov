GameUI.CustomUIConfig().multiteam_top_scoreboard =
{
    reorder_team_scores: true,
    LeftInjectXMLFile: "file://{resources}/layout/custom_game/overthrow_scoreboard_score/overthrow_scoreboard_left.xml",
};

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_PREGAME_STRATEGYUI, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false );

GameUI.CustomUIConfig().team_colors = {}
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#3dd296;"; // { 61, 210, 150 }	--		Teal
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "#F3C909;"; // { 243, 201, 9 }		--		Yellow
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8;"; // { 197, 77, 168 }	--		Pink
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00;"; // { 255, 108, 0 }		--		Orange
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF;"; // { 52, 85, 255 }		--		Blue
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413;"; // { 101, 212, 19 }	--		Green
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336;"; // { 129, 83, 54 }		--		Brown
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8;"; // { 27, 192, 216 }	--		Cyan
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d;"; // { 199, 228, 13 }	--		Olive
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4;"; // { 140, 42, 244 }	--		Purple

var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
dotaHud.FindChildTraverse("MorphProgress").style.visibility = "collapse";
dotaHud.FindChildTraverse("GlyphScanContainer").style.visibility = "collapse";
dotaHud.FindChildTraverse("NetGraph").style.visibility = "collapse";
dotaHud.FindChildTraverse("HUDSkinTopBarBG").style.visibility = "collapse";

GameEvents.Subscribe("CreateIngameErrorMessage", function(data) 
{
    GameEvents.SendEventClientSide("dota_hud_error_message", 
    {
        "splitscreenplayer": 0,
        "reason": data.reason || 80,
        "message": data.message
    })
})

function FindModifierByName(EntityIndex, BuffName)
{
    for (let i = 0; i <= Entities.GetNumBuffs(EntityIndex) - 1; i++)
    {
        const BuffIndex = Entities.GetBuff(EntityIndex, i )
        if(Buffs.GetName(EntityIndex, BuffIndex) == BuffName)
        {
            return BuffIndex
        }
    }
    return "none"
}

GameEvents.Subscribe("panorama_cooldown_error", function(data) 
{
    GameEvents.SendEventClientSide("dota_hud_error_message", 
    {
        "splitscreenplayer": 0,
        "reason": data.reason || 80,
        "message": $.Localize(data.message) + data.time
    })
})

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