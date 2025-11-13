var dotaHud = FindDotaHudElement("HUDElements");

function HighFiveInit()
{
    let high_five_custom = FindDotaHudElement("high_five_custom")
    if (high_five_custom)
    {
        high_five_custom.DeleteAsync(0);
    }
 
    let TertiaryAbilityContainer = dotaHud.FindChildrenWithClassTraverse("TertiaryAbilityContainer")[0];
    if (TertiaryAbilityContainer)
    {
        var high_five = $.CreatePanel("Button", $.GetContextPanel(), "high_five_custom");
        high_five.BLoadLayoutSnippet("HighFiveSnippet");
        high_five.SetPanelEvent("onactivate", () => HighFive());
        high_five.SetPanelEvent("onmouseover", () => 
        {
            var entindex = Players.GetLocalPlayerPortraitUnit();
            $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", high_five, "plus_high_five", entindex);
        });
        high_five.SetPanelEvent("onmouseout", () => $.DispatchEvent("DOTAHideAbilityTooltip", high_five));
        high_five.SetParent(TertiaryAbilityContainer);
    }

    SetCustomBind()
    SetBuffs()
    Tick()
}

function HighFive()
{
    var selected_index = Players.GetLocalPlayerPortraitUnit();
    let heroIndex = Game.GetPlayerInfo(Game.GetLocalPlayerID()).player_selected_hero_entity_index
    if (heroIndex != selected_index)
    {
        return;
    }
    GameEvents.SendCustomGameEventToServer( "StartHighFive", {} );
}

function Tick(fast) 
{
    let high_five_custom = FindDotaHudElement("high_five_custom")
    var selected_index = Players.GetLocalPlayerPortraitUnit();
    let heroIndex = Game.GetPlayerInfo(Game.GetLocalPlayerID()).player_selected_hero_entity_index
    if (high_five_custom)
    {
        high_five_custom.SetHasClass("Hidden", !Entities.IsRealHero(selected_index));
    }
    if (!fast)
    {
        $.Schedule(0.03, () => Tick());
    }
}

function SetBuffs() 
{
    var buffs = FindDotaHudElement("buffs");
    if (buffs)
    {
        buffs.style.marginBottom = "196px";
    }
    var debuffs = FindDotaHudElement("debuffs");
    if (debuffs)
    {
        debuffs.style.marginBottom = "196px";
    }
}

function SetCustomBind()
{
    let GameTime = Game.GetGameTime()
    Game.CreateCustomKeyBind("ALT+CAPSLOCK", "HighFive" + GameTime)
    Game.AddCommand("HighFive" + GameTime, HighFive, "", 0)
}

HighFiveInit()