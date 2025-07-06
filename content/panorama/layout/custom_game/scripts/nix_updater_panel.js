function GameUpdater()
{
    let hero = Players.GetLocalPlayerPortraitUnit()
    UpdateLevelPanel(hero)
    $.Schedule(1/144, GameUpdater)
}

function UpdateLevelPanelMax(ability_panel, hero)
{
    let ButtonSize = ability_panel.FindChildTraverse("ButtonSize")
    if (ButtonSize)
    {
        let max_effect = ButtonSize.FindChildTraverse("max_effect")
        if (max_effect == null)
        {
            max_effect = $.CreatePanel("DOTAScenePanel", ButtonSize, "max_effect", { style: "width:100%;height:100%;opacity:0;z-index:1;", map: "maps/max_level.vmap", particleonly:"false", hittest:"false", camera:"camera_1" });
        }
        let ability_name = ability_panel.FindChildTraverse("AbilityImage").abilityname
        let ability = Entities.GetAbilityByName( hero, ability_name )
        if (ability && HasModifier(hero, "modifier_nix_marci_r_upgrade"))
        {
            max_effect.style.opacity = "1"
        }
        else
        {
            max_effect.style.opacity = "0"
        }
    }
}

function UpdateLevelPanel(hero)
{
    let AbilitiesAndStatBranch = FindDotaHudElement("AbilitiesAndStatBranch")
    if (AbilitiesAndStatBranch == null) { return }
    let abilities = AbilitiesAndStatBranch.FindChildTraverse("abilities")
    if (abilities == null) { return }
    for (var i = 0; i < abilities.GetChildCount(); i++)
    {
        let ability_panel = abilities.GetChild(i)
        if (ability_panel)
        {
            UpdateLevelPanelMax(ability_panel, hero)
        }
    }
    current_selected_hero = hero
}

GameUpdater()