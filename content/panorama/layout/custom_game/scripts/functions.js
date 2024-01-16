function GetMmrSeason()
{
    return (CustomNetTables.GetTableValue('game_state', 'birzha_gameinfo') || {}).season
}

function GetCurrentSeasonDays()
{
	let table = CustomNetTables.GetTableValue("game_state", "birzha_gameinfo")
	if (table)
	{
		if (table.days_season)
		{
			return Number(table.days_season)
		}
	}
	return 0
}

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
 
function HasModifier(unit, modifier) 
 {
     for (var i = 0; i < Entities.GetNumBuffs(unit); i++) 
     {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier)
        {
            return Entities.GetBuff(unit, i)
        }
    }
    return false
}

function GetHeroExp(exp)
{
    let level = exp % 1000 + " / 1000"
    return level
} 

function GetHeroExpProgress(exp)
{
    let level = exp % 1000
    var percent = ((1000-level)*100)/1000

    if (percent >= 0) {
        return (100 - percent) +'%';
    } else {
        return '0%'
    }
} 

function GetHeroLevel(exp)
{
    let level = exp / 1000
    return Math.floor(level)
} 

function GetHeroRankIcon(level)
{
    if (level >= 35) {
        return "rank_7"
    } else if (level >= 30) {
        return "rank_6"
    } else if (level >= 25) {
        return "rank_5"
    } else if (level >= 20) {
        return "rank_4"
    } else if (level >= 15) {
        return "rank_3"
    } else if (level >= 10) {
        return "rank_2"
    } else if (level >= 5) {
        return "rank_1"
    } else {
        return "rank_0"
    }
}

function GetHeroRankName(level)
{
    if (level >= 30) {
        return $.Localize("#BP_rank_7")
    } else if (level >= 20) {
        return $.Localize("#BP_rank_6")
    } else if (level >= 10) {
        return $.Localize("#BP_rank_5")
    } else if (level >= 7) {
        return $.Localize("#BP_rank_4")
    } else if (level >= 5) {
        return $.Localize("#BP_rank_3")
    } else if (level >= 3) {
        return $.Localize("#BP_rank_2")
    } else if (level >= 1) {
        return $.Localize("#BP_rank_1")
    } else {
        return $.Localize("#BP_rank_0")
    }
}

function GetHeroInformation(info, hero)
{
    for (var i = 1; i <= Object.keys(info.heroes_matches).length; i++) {
        if (info.heroes_matches[i]["hero"] == hero)
        {
            return info.heroes_matches[i]
        }
    }
    return "No"
}  

function HasBirzhaPass(id)
{
    return (CustomNetTables.GetTableValue('birzhainfo', String(id)) || {}).bp_days > 0;
}

function GetCurrentSeasonNumber()
{
	let table = CustomNetTables.GetTableValue("game_state", "birzha_gameinfo")
	if (table)
	{
		if (table.season)
		{
			return Number(table.season)
		}
	}
}