function GetDotaHud()
{
	let hPanel = $.GetContextPanel();

	while ( hPanel && hPanel.id !== 'Hud')
	{
        hPanel = hPanel.GetParent();
	}

	if (!hPanel)
	{
        throw new Error('Could not find Hud root from panel with id: ' + $.GetContextPanel().id);
	}

	return hPanel;
}

function FindDotaHudElement(sId)
{
	return GetDotaHud().FindChildTraverse(sId);
}

function HasModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) 
    {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier)
        {
            return true
        }
    }
    return false
}

function FindModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) 
    {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier)
        {
            return Entities.GetBuff(unit, i);
        }
    }
    return "none"
}

function HowStacks(mod) 
{
	var hero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() )
	for (var i = 0; i < Entities.GetNumBuffs(hero); i++) 
    {
		var buffID = Entities.GetBuff(hero, i)
		if (Buffs.GetName(hero, buffID ) == mod ){
			var stack = Buffs.GetStackCount(hero, buffID ) 
			if (stack == 0) {
				stack = 1
			}
			return stack
		}
	}
	return 0
}

function GetCurrentStacks(hero_id, mod) 
{
    var hero = hero_id
 
    for (var i = 0; i < Entities.GetNumBuffs(hero); i++) 
    {
       var buffID = Entities.GetBuff(hero, i)
        if (Buffs.GetName(hero, buffID ) == mod )
        {
            var stack = Buffs.GetStackCount(hero, buffID ) 
            return stack
        }
    }
    return 0
}

function IsSpectator() 
{
    const localPlayer = Players.GetLocalPlayer()
    if (Players.IsSpectator(localPlayer))
    {
        return true
    }
    const localTeam = Players.GetTeam(localPlayer)
    return localTeam !== 2 && localTeam !== 3 && localTeam !== 6 && localTeam !== 7 && localTeam !== 8 && localTeam !== 9 && localTeam !== 10 && localTeam !== 11 && localTeam !== 12 && localTeam !== 13
}

function ConvertTimeMinutes(time)
{
    var min = Math.trunc((time)/60) 
    var sec_n =  (time) - 60*Math.trunc((time)/60) 
    var min = String(min - 60*( Math.trunc(min/60) ))
    var sec = String(sec_n)
    if (sec_n < 10) 
    {
        sec = '0' + sec
    }
    if (min < 10)
    {
        min = '0' + min
    } 
    return min + ':' + sec
}

function ShowAbilityDescription(panel, ability)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability); });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function ShowAbilityDescriptionForHero(panel, ability, hero)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', panel, ability, hero); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });        
}

function ShowAbilityDescriptionLevel(panel, ability, level)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltipForLevel', panel, ability, level); });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function ShowTextForPanel(panel, text)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(text)); });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });       
}

GameEvents.Subscribe( 'set_unit_target', SetTarget );
function SetTarget( data )
{
    GameUI.SelectUnit( data.unit, false )
}

GameEvents.Subscribe( 'set_camera_target', SetCamera );
function SetCamera( data )
{
	GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin( data.id ), 0.1);
}

function Vector_normalize(vec)
{
	const val = 1 / Math.sqrt(Math.pow(vec[0], 2) + Math.pow(vec[1], 2) + Math.pow(vec[2], 2));
	return [vec[0] * val, vec[1] * val, vec[2] * val];
}

function Vector_mult(vec, mult)
{
	return [vec[0] * mult, vec[1] * mult, vec[2] * mult];
}

function Vector_add(vec1, vec2)
{
	return [vec1[0] + vec2[0], vec1[1] + vec2[1], vec1[2] + vec2[2]];
}

function Vector_sub(vec1, vec2)
{
	return [vec1[0] - vec2[0], vec1[1] - vec2[1], vec1[2] - vec2[2]];
}

function Vector_negate(vec)
{
	return [-vec[0], -vec[1], -vec[2]];
}

function Vector_flatten(vec)
{
	return [vec[0], vec[1], 0];
}

function Vector_raiseZ(vec, inc)
{
	return [vec[0], vec[1], vec[2] + inc];
}

function Vector_distance (vec1, vec2) 
{
	return Math.sqrt(((vec2[0] - vec1[0]) ** 2) + ((vec2[1] - vec1[1]) ** 2));
}

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

GameEvents.Subscribe("CreateIngameErrorMessage", function(data) 
{
    GameEvents.SendEventClientSide("dota_hud_error_message", 
    {
        "splitscreenplayer": 0,
        "reason": data.reason || 80,
        "message": data.message
    })
})

GameEvents.Subscribe("panorama_cooldown_error", function(data) 
{
    GameEvents.SendEventClientSide("dota_hud_error_message", 
    {
        "splitscreenplayer": 0,
        "reason": data.reason || 80,
        "message": $.Localize(data.message) + data.time
    })
})

function GetPlayerColor(player_id)
{
    var playerInfo = Game.GetPlayerInfo( player_id );
    if ( playerInfo )
    {
        if ( GameUI.CustomUIConfig().team_colors )
        {
            var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo.player_team_id ];
            if ( teamColor )
            {
                return teamColor;
            }
        }
    }
    return "white"
}

function IsPlayerFullMuted(player_id)
{
    if (Game.IsPlayerMuted( player_id ) || Game.IsPlayerMutedVoice( player_id ) || Game.IsPlayerMutedText( player_id )) 
    {
        return true
    }
    return false
}