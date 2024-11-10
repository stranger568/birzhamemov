"use strict";

var dotaHud = FindDotaHudElement("HUDElements");

class HighFive {
    constructor() {
        this.RemoveOnRestart();
        this.playerId = Players.GetLocalPlayer();
        this.button = this.CreateButton();
        this.background = this.button.FindChildTraverse("CooldownBackground");
        this.label = this.button.FindChildTraverse("CooldownLabel");
        this.HighFiveKeyButtonLabel = this.button.FindChildTraverse("HighFiveKeyButtonLabel")
        this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
        this.keybind_button = null;
        this.Tick();
    }
    RemoveOnRestart() {
        dotaHud.FindChildrenWithClassTraverse("__HF_Remove__").forEach(panel => panel.DeleteAsync(0));
    }
    CreateButton() {
        var container = dotaHud.FindChildrenWithClassTraverse("TertiaryAbilityContainer")[0];
        if (!container)
            return;
        var high_five = $.CreatePanel("Button", $.GetContextPanel(), "HighFive", { class: "__HF_Remove__" });
        high_five.BLoadLayoutSnippet("HighFiveSnippet");
        high_five.SetPanelEvent("onactivate", () => this.HighFive());
        high_five.SetPanelEvent("onmouseover", () => {
            var entindex = Players.GetLocalPlayerPortraitUnit();
            $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", this.button, "high_five", entindex);
        });
        high_five.SetPanelEvent("onmouseout", () => $.DispatchEvent("DOTAHideAbilityTooltip", high_five));
        high_five.SetParent(container);
        return high_five;
    }
    HighFive() 
    {
        var selected_index = Players.GetLocalPlayerPortraitUnit();
        if (this.heroIndex != selected_index)
            return;
        GameEvents.SendCustomGameEventToServer( "StartHighFive", {} );
    } 
    HighFiveBind() 
    {
        GameEvents.SendCustomGameEventToServer( "StartHighFive", {} );
    } 
    Tick() {
        var selected_index = Players.GetLocalPlayerPortraitUnit();
        this.button.SetHasClass("Hidden", !Entities.IsRealHero(selected_index));
        this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
        $.Schedule(0.03, () => this.Tick());
    }
}
var highfive = new HighFive();