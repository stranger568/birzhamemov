var parentHUDElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChild("HUDElements");
if (parentHUDElements)
{
    var center_block = parentHUDElements.FindChildTraverse("center_block");
    $.GetContextPanel().SetParent(center_block);
}

 
UpdateHeroHudBuffs();
UpdateHeroHudBuffs2();

function UpdateHeroHudBuffs()
{
	let hero_id = Players.GetLocalPlayerPortraitUnit()
	let hero = Entities.GetUnitName(hero_id)

    let default_energy_max = 400;
    let default_energy_level = 40;
    let maximum_energy = default_energy_max + (default_energy_level * Entities.GetLevel(hero_id))
    let current_energy = GetCurrentStacks(hero_id, "modifier_nolik_energy")

    if (HasModifier(hero_id, "modifier_nolik_helper_energy"))
    {
        maximum_energy = maximum_energy * 2
    }

	if ((hero === "npc_dota_hero_nolik")) {
        $("#Energy").text = current_energy + " / " + maximum_energy
        $("#NolikEnergyPanel").style.visibility = "visible"
        var energy_background = $( "#EnergyPanelBackgroundGreen" )
        if ( energy_background )
        {
            if (current_energy >= 0) {
                var percent = ((maximum_energy-current_energy)*100)/maximum_energy
                if (percent >= 0) {
                    energy_background.style['width'] = (100 - percent) +'%';
                } else {
                    energy_background.style['width'] = '0%';
                }
            }
        }
    } else {
    	$("#NolikEnergyPanel").style.visibility = "collapse"
    }

	$.Schedule(1/144, UpdateHeroHudBuffs)
}

function UpdateHeroHudBuffs2()
{
  let hero_id = Players.GetLocalPlayerPortraitUnit()
  let hero = Entities.GetUnitName(hero_id)

  let stats_agility = GetCurrentStacks(hero_id, "modifier_fourtwall_agility_boost")
  let stats_strenth = GetCurrentStacks(hero_id, "modifier_fourtwall_str_boost")
  let full_stats = stats_agility + stats_strenth

  if ((hero === "npc_dota_hero_dark_willow")) 
  {
      if (full_stats > 0)
      {
        $("#MonikaStats").text = stats_strenth + " / " + stats_agility
        $("#MonikaStatsPanel").style.visibility = "visible"

        var energy_background = $( "#MonikaStatsPanelBackgroundGreen" )
        if ( energy_background )
        {
            if (stats_agility >= 0) {
                var percent = ((full_stats-stats_agility)*100)/full_stats
                if (percent >= 0) {
                    energy_background.style['width'] = (100 - percent) +'%';
                } else {
                    energy_background.style['width'] = '0%';
                }
            }
        }

        var MonikaStatsPanelBackground = $( "#MonikaStatsPanelBackground" )
        if ( MonikaStatsPanelBackground )
        {
            if (stats_strenth >= 0) {
                var percent = ((full_stats-stats_strenth)*100)/full_stats
                if (percent >= 0) {
                    MonikaStatsPanelBackground.style['width'] = (100 - percent) +'%';
                } else {
                    MonikaStatsPanelBackground.style['width'] = '0%';
                }
            }
        }
      } else {
        $("#MonikaStatsPanel").style.visibility = "collapse"
      }

    } else {
      $("#MonikaStatsPanel").style.visibility = "collapse"
    }

  $.Schedule(1/144, UpdateHeroHudBuffs2)
}

function GetCurrentStacks(hero_id, mod) {

   var hero = hero_id

   for (var i = 0; i < Entities.GetNumBuffs(hero); i++) {
      var buffID = Entities.GetBuff(hero, i)
      if (Buffs.GetName(hero, buffID ) == mod ){
         var stack = Buffs.GetStackCount(hero, buffID ) 
         return stack
      }
   }
   return 0
}

function HasModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            return Entities.GetBuff(unit, i)
        }
    }
   return false
}