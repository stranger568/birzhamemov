GameEvents.Subscribe( 'chat_birzha_sound', ChatSound );
GameEvents.Subscribe( 'random_hero_chat', RandomHeroChat );
GameEvents.Subscribe( 'double_rating_chat', DoubleRatingChat );
GameEvents.Subscribe( 'win_predict_chat', win_predict_chat );
GameEvents.Subscribe( 'chat_bm_smile', ChatSmile );

function ChatSound( data )
{
	let Hudchat = FindDotaHudElement("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")
	let hero_icon = "file://{images}/custom_game/hight_hood/heroes/" + data.hero_name + ".png"
	let player_name = Players.GetPlayerName( data.player_id )
	let sound_name = data.sound_name
	let color = GetPlayerColor(data.player_id)
	if (IsPlayerFullMuted(data.player_id)) 
    {
        return
    }
	Game.EmitSound(data.sound_name_global)
	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	$.CreatePanel("Image", ChatPanelSound, "", { src:`${hero_icon}`, style:"width:40px;height:23px;margin-right:4px;border:1px solid black;" }); 
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	$.CreatePanel("Image", ChatPanelSound, "", { class:"ChatWheelIcon", src:"file://{images}/hud/reborn/icon_scoreboard_mute_sound.psd" }); 
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${sound_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });
	$.Schedule( 7, function()
    {
        if (ChatPanelSound) 
        {
            ChatPanelSound.AddClass('ChatLine');  
        }
    })
}     

function RandomHeroChat( data )
{
	let Hudchat = FindDotaHudElement("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")
	let player_name = Players.GetPlayerName( data.id )
	let hero_name = $.Localize("#birzha_random_hero") + $.Localize("#"+data.hero) 
	let color = GetPlayerColor(data.id)
	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });
	$.Schedule( 7, function()
    {
        if (ChatPanelSound) 
        {
            ChatPanelSound.AddClass('ChatLine');  
        }
    })
}  


function DoubleRatingChat( data )
{
	let Hudchat = FindDotaHudElement("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")
	let player_name = Players.GetPlayerName( data.id )
	let hero_name = $.Localize("#birzha_double_rating")
	let color = GetPlayerColor(data.id)
	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });
	$.Schedule( 7, function()
    {
        if (ChatPanelSound) 
        {
            ChatPanelSound.AddClass('ChatLine');  
        }
    })
}  

function win_predict_chat( data )
{
	let Hudchat = FindDotaHudElement("HudChat")
	let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")
	let player_name = Players.GetPlayerName( data.id )
	let hero_name = $.Localize("#birzha_win_predict") + " " + data.count
	let color = GetPlayerColor(data.id)
	let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
	let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
	$.CreatePanel("Label", ChatPanelSound, "", { text:`${hero_name}`, style:"font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:white;" });
	$.Schedule( 7, function()
    {
        if (ChatPanelSound) 
        {
            ChatPanelSound.AddClass('ChatLine');  
        }
    })
} 

function ChatSmile( data )
{
    let Hudchat = FindDotaHudElement("HudChat")
    let LinesPanel = Hudchat.FindChildTraverse("ChatLinesPanel")
    let hero_icon = "file://{images}/custom_game/hight_hood/heroes/" + data.hero_name + ".png"
    let smile_icon = "file://{images}/custom_game/smiles/" + data.smile_icon + ".png"
    let player_name = Players.GetPlayerName( data.player_id )
    let color = GetPlayerColor(data.player_id)
    let player_color_style = "font-size:18px;font-weight:bold;text-shadow: 1px 1.5px 0px 2 black;color:" + color
    let ChatPanelSound = $.CreatePanel("Panel", LinesPanel, "", { style:"margin-left:37px;flow-children: right;width:100%;" });
    $.CreatePanel("Image", ChatPanelSound, "", { src:`${hero_icon}`, style:"width:40px;height:23px;margin-right:4px;border:1px solid black;" }); 
    $.CreatePanel("Label", ChatPanelSound, "", { text:`${player_name}` + ":", style:`${player_color_style}` });
    $.CreatePanel("Image", ChatPanelSound, "", { class:"SmileIcon", style:"width:35px;height:35px;", src:`${smile_icon}` }); 
    $.Schedule( 7, function()
    {
        if (ChatPanelSound) 
        {
            ChatPanelSound.AddClass('ChatLine');  
        }
    })
}