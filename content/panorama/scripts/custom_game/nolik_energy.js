UpdateHeroHudBuffs();

function UpdateHeroHudBuffs()
{
	let hero_id = Players.GetLocalPlayerPortraitUnit()
	let hero = Entities.GetUnitName(hero_id)

   let default_energy_max = 500;
   let default_energy_level = 30;
   let maximum_energy = default_energy_max + (default_energy_level * Entities.GetLevel(hero_id))
   let current_energy = GetCurrentStacks(hero_id, "modifier_nolik_energy")

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