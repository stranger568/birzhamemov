function GetHeroID(heroName) 
{
    var result = heroes_ids[heroName];
    if (result == null) return -1;
    return result;
}

function TalentOver(panel, hero_id) 
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAHUDShowHeroStatBranchTooltip', panel, hero_id, 0)
    });

    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHUDHideStatBranchTooltip', panel);
    });
}

function UpdateLockedHeroes()
{
    let picked_heroes = CustomNetTables.GetTableValue("birzha_pick", "picked_heroes")
    let banned_heroes = CustomNetTables.GetTableValue("birzha_pick", "banned_heroes")
    if (picked_heroes)
    {
        UpdatePickedHeroes(picked_heroes)
    }
    if (banned_heroes)
    {
        UpdateBannedHeroes(banned_heroes)
    }
}

function UpdateBannedHeroes(data)
{
    for (let i = 1; i <= 3; i++)
    {
        let main_panel = $("#panel_with_heroes_" + i)
        if (main_panel)
        {
            for (let d = 0; d < main_panel.GetChildCount(); d++) 
            {
                main_panel.GetChild(d).SetHasClass("Banned", false)
            }
        }
    }
    for (var i = 1; i <= Object.keys(data).length; i++) 
    {
        let hero_name = data[i]
        var hero_panel = $("#" + hero_name);
        if (hero_panel)
        {
            hero_panel.SetHasClass("Banned", true)
        }
    }
}

function UpdatePickedHeroes(data)
{    
    for (let i = 1; i <= 3; i++)
    {
        let main_panel = $("#panel_with_heroes_" + i)
        if (main_panel)
        {
            for (let d = 0; d < main_panel.GetChildCount(); d++) 
            {
                main_panel.GetChild(d).SetHasClass("Picked", false)
            }
        }
    }
    for (var i = 1; i <= Object.keys(data).length; i++) 
    {
        let hero_name = data[i]
        var hero_panel = $("#" + hero_name);
        if (hero_panel)
        {
            hero_panel.SetHasClass("Picked", true)
        }
    }
}

function SetPSelectEvent(p, n)
{
    p.SetPanelEvent("onactivate", function() 
    { 
        ChangeHeroInfo(n);
    });        
}

function SetShowText(panel, text)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });       
}

function SetShowAbDesc(panel, ability)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function GetHeroAbility(hn) 
{
    var ab = CustomNetTables.GetTableValue("birzha_pick", hn);
    if (ab)
    {
        return ab;
    } 
    return [];
}

function GetPlayerTokensCount()
{
    var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    if (p_info)
    {
        return getTokens() - p_info.token_used
    }
    return 0
}

function getTokens()     
{
    let token_max = 10
    let token_items = 
    [
        219,
        220,
        221,
        222,
        223,
        224,
        225,
        226,
        227,
        228,
    ]
    for (var i = 0; i < token_items.length; i++) 
    {
        if (HasItemInventory(token_items[i]))
        {
            token_max = token_max + 1
        }
    }
    return token_max
}

function HasItemInventory(item_id)
{
    let player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
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

function HasItemInventoryActive(item_id)
{
    let player_table = CustomNetTables.GetTableValue("birzhashop", String(Players.GetLocalPlayer()))
	if (player_table && player_table.player_items_active)
	{
		for (var d = 1; d <= Object.keys(player_table.player_items_active).length; d++) 
		{
			if (player_table.player_items_active[d])
			{
				if (String(player_table.player_items_active[d]) == String(item_id))
				{
					return true
				}
			}
		}
	}
	return false
}
   
function GetAverageRating() {

    let average_rating = 0
    let current_players = 0
    for ( let teamId of Game.GetAllTeamIDs() )
    {
        let teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
        for ( let playerId of teamPlayers )
        {
            current_players = current_players + 1
            let seasons = CustomNetTables.GetTableValue('game_state', "birzha_gameinfo");
            if (seasons) 
            {
                let info = CustomNetTables.GetTableValue('birzhainfo', String(playerId));
                if (info && info.mmr && info.mmr[seasons.season]) {
                    average_rating = average_rating + (info.mmr[seasons.season] || 2500)
                }
            }
        }
    }
    if (average_rating > 0) 
    {
        average_rating = average_rating / current_players
    }
    average_rating = Math.round(average_rating)
    return String(average_rating)
}

function StealButtonsAndChat()
{
    if( $.GetContextPanel().BHasClass('Deletion') ) return;

    buttons = FindDotaHudElement('MenuButtons');
    buttons_parent = buttons.GetParent();

    if( buttons )
    {
        buttons.SetParent( $.GetContextPanel() );
        buttons.FindChildTraverse('ToggleScoreboardButton').visible = false;
    }
    
    chat = FindDotaHudElement('HudChat');
    chat_parent = chat.GetParent();

    if( chat )
    {
        chat.SetParent( $.GetContextPanel() );
        chat.style.horizontalAlign = 'right';
        chat.style.y = '60px';
        chat.style.width = '660px';
    }
}

function RestoreButtonsAndChat()
{
    var HudElements = FindDotaHudElement('HUDElements');
    var button = FindDotaHudElement('MenuButtons');
    var chating = FindDotaHudElement('HudChat');

    if ( button && HudElements )
    {
        button.SetParent( HudElements );
        button.FindChildTraverse('ToggleScoreboardButton').visible = true;
    }
    
    if ( chating && HudElements )
    {
        chating.SetParent( HudElements );
        chating.style.horizontalAlign = 'center';
        chating.style.y = '-220px';
        chating.style.width = '800px';
    }
}

function InitTokens()
{
    if (TOKEN_INIT)
    {
        return
    }
    if (IsAllowForThis())
    {
        $("#DoubleRatingPanel").style.visibility = "visible"
    }
    TOKEN_INIT = true
    $("#double_rating_token_counter").text = GetPlayerTokensCount()
    if (IsHasTokenAndSubscribe())
    {
        $("#button_double_rating_activate").SetPanelEvent("onactivate", function() 
        { 
            Game.EmitSound("BUTTON_CLICK_MAJOR")
            $("#button_double_rating_activate").SetPanelEvent("onactivate", function() {});
            $("#double_rating_token_counter").text = GetPlayerTokensCount() - 1
            $("#button_double_rating_activate").SetHasClass("button_double_rating_active", false)
            GameEvents.SendCustomGameEventToServer('birzha_token_set', {});
        });
    }
    else
    {
        $("#button_double_rating_activate").SetHasClass("button_double_rating_active", false)
        SetShowText($("#button_double_rating_activate"), "#double_rating_no_subs")
    }
}
function IsHasTokenAndSubscribe()
{
    var p_info = CustomNetTables.GetTableValue('birzhainfo', String(Players.GetLocalPlayer()));
    if (p_info)
    {
        if (p_info.bp_days > 0 && getTokens() - p_info.token_used > 0)
        {
            return true
        }
    }
    return false
}

function ChangeDonateBlock(panel, button)
{
    $("#DonateBlockPanelWithItems_1").style.visibility = "collapse"
    $("#DonateBlockPanelWithItems_2").style.visibility = "collapse"
    $("#DonateBlockPanelWithItems_3").style.visibility = "collapse"
    for (var i = 0; i < $("#HeroDonateBlockButtons").GetChildCount(); i++) 
	{
		$("#HeroDonateBlockButtons").GetChild(i).SetHasClass("HeroDonateBlockButton_selected", false)
	}
    $("#"+button).SetHasClass("HeroDonateBlockButton_selected", true)
    $("#"+panel).style.visibility = "visible"
}

function IsPlusHero(hero_name)
{
    let subscribe_heroes = CustomNetTables.GetTableValue("birzha_pick", "subscribe_heroes");
    for (var d = 1; d <= Object.keys(subscribe_heroes.bp_heroes).length; d++)  
    {
        if (subscribe_heroes.bp_heroes[d] == hero_name) 
        {
            return true
        }
    }
    return false
}