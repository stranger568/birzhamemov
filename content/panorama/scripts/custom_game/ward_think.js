var vectorTargetParticle;
var lastAbility = -1;

function Think()
{
	//$.Msg( Abilities.GetLocalPlayerActiveAbility())

	if (Abilities.GetLocalPlayerActiveAbility() != lastAbility) {
		lastAbility = Abilities.GetLocalPlayerActiveAbility()
		if (vectorTargetParticle) {
			Particles.DestroyParticleEffect(vectorTargetParticle, true)
			vectorTargetParticle = undefined;
		}
		if ( (Abilities.GetLocalPlayerActiveAbility() != 1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "item_birzha_ward") ) {
			vectorTargetParticle = Particles.CreateParticle("particles/ui_mouseactions/range_finder_ward_aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, Players.GetLocalPlayerPortraitUnit() );
		}

	}


	if (vectorTargetParticle)
	{
		const cursor = GameUI.GetCursorPosition();
		const worldPosition = GameUI.GetScreenWorldPosition(cursor);
		Particles.SetParticleControl(vectorTargetParticle, 0, Entities.GetAbsOrigin( Players.GetLocalPlayerPortraitUnit()) );
		Particles.SetParticleControl(vectorTargetParticle, 1, [ 255, 255, 255 ]);
		Particles.SetParticleControl(vectorTargetParticle, 6, [ 255, 255, 255 ]);
	    Particles.SetParticleControl(vectorTargetParticle, 2, worldPosition);
	    

	    var ward_table = CustomNetTables.GetTableValue('ward_type', String(Buffs.GetAbility( Players.GetLocalPlayerPortraitUnit(), FindModifier(Players.GetLocalPlayerPortraitUnit(), "modifier_item_birzha_ward") )) )

	    if (ward_table) {
	    	if (ward_table.type) {
	    		if (ward_table.type == "observer") {
	    			Particles.SetParticleControl(vectorTargetParticle, 11, [ 0, 0, 0 ]);
	    			if (HowStacks("modifier_item_birzha_ward") == 3) {
	    				Particles.SetParticleControl(vectorTargetParticle, 3, [ 1700, 1700, 1700 ]);
	    			} else {
	    				Particles.SetParticleControl(vectorTargetParticle, 3, [ 1600, 1600, 1600 ]);
	    			}
	    			
	    		} else if (ward_table.type == "sentry") {
	    			Particles.SetParticleControl(vectorTargetParticle, 11, [ 1, 0, 0 ]); 
	    			Particles.SetParticleControl(vectorTargetParticle, 3, [ 1000, 1000, 1000 ]);
	    		}
	    	}
	    }

	    

	   
	}

	//GameUI.DisplayCustomContextualTip( "dada", 3 )

	// 11 CONTROL - 0 OBS 1 SENTRY


    $.Schedule(1/144, Think)
}

function FindModifier(unit, modifier) {
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            return Entities.GetBuff(unit, i);
        }
    }
}

function HowStacks(mod) {

	var hero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() )

	for (var i = 0; i < Entities.GetNumBuffs(hero); i++) {
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

Think()