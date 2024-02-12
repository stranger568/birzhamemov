var vectorTargetParticle;
var lastAbility = -1;

function Think()
{
	if (Abilities.GetLocalPlayerActiveAbility() != lastAbility) {
		lastAbility = Abilities.GetLocalPlayerActiveAbility()
		if (vectorTargetParticle) {
			Particles.DestroyParticleEffect(vectorTargetParticle, true)
			vectorTargetParticle = undefined;
		}
		if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "scp682_bite") ) {
			vectorTargetParticle = Particles.CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_range_finder_aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, Players.GetLocalPlayerPortraitUnit() );
		}
		if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "kakashi_graze_wave") ) {
			vectorTargetParticle = Particles.CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_range_finder_aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, Players.GetLocalPlayerPortraitUnit() );
		}
		if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "puchkov_smeh") ) {
			vectorTargetParticle = Particles.CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble_range_finder_aoe.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, Players.GetLocalPlayerPortraitUnit() );
		}
		if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "item_birzha_ward") ) {
			vectorTargetParticle = Particles.CreateParticle("particles/ui_mouseactions/range_finder_ward_aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, Players.GetLocalPlayerPortraitUnit() );
		}
		if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "puchkov_pigs") ) {
			vectorTargetParticle = Particles.CreateParticle("particles/ui_mouseactions/custom_range_finder_cone.vpcf", ParticleAttachment_t.PATTACH_WORLDORIGIN, Players.GetLocalPlayerPortraitUnit() );
		}

	}

	if (vectorTargetParticle)
	{
		const cursor = GameUI.GetCursorPosition();
		const worldPosition = GameUI.GetScreenWorldPosition(cursor);

	    if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "kakashi_graze_wave") ) {

	    	let point_blank = 0
	    	let origin = Entities.GetAbsOrigin( Players.GetLocalPlayerPortraitUnit() )
	    	let direction = Vector_normalize(Vector_sub(origin, worldPosition));
	    	let cast_range = Abilities.GetCastRange( Abilities.GetLocalPlayerActiveAbility() )

	    	Particles.SetParticleControl(vectorTargetParticle, 0, origin );
			Particles.SetParticleControl(vectorTargetParticle, 1, Vector_sub(origin, Vector_mult(direction, cast_range)) );
			Particles.SetParticleControl(vectorTargetParticle, 6, Vector_sub(origin, Vector_mult(direction, point_blank)) );
	    }

	    if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "scp682_bite") ) {

	    	let point_blank = Abilities.GetSpecialValueFor(Abilities.GetLocalPlayerActiveAbility(), "point_blank_range");
	    	let origin = Entities.GetAbsOrigin( Players.GetLocalPlayerPortraitUnit() )

	    	if (HasModifier(Players.GetLocalPlayerPortraitUnit(), "modifier_scp682_ultimate")) {
	    		point_blank = point_blank + 150
	    	}

	    	let direction = Vector_normalize(Vector_sub(origin, worldPosition));
	    	let cast_range = Abilities.GetCastRange( Abilities.GetLocalPlayerActiveAbility() )

	    	Particles.SetParticleControl(vectorTargetParticle, 0, origin );
			Particles.SetParticleControl(vectorTargetParticle, 1, Vector_sub(origin, Vector_mult(direction, cast_range)) );
			Particles.SetParticleControl(vectorTargetParticle, 6, Vector_sub(origin, Vector_mult(direction, point_blank)) );
	    }

	   	if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "puchkov_smeh") ) {

	    	let radius = Abilities.GetSpecialValueFor(Abilities.GetLocalPlayerActiveAbility(), "radius");
	    	let origin = Entities.GetAbsOrigin( Players.GetLocalPlayerPortraitUnit() )

	    	Particles.SetParticleControl(vectorTargetParticle, 1, [radius, radius, radius] );

		    let c = Math.sqrt( 2 ) * 0.5 * radius 
		    let x_offset = [ -radius, -c, 0.0, c, radius, c, 0.0, -c ]
		    let y_offset = [ 0.0, c, radius, c, 0.0, -c, -radius, -c ]

		    Particles.SetParticleControl(vectorTargetParticle, 0, worldPosition );
		    Particles.SetParticleControl(vectorTargetParticle, 2, Vector_add(worldPosition,[x_offset[0], y_offset[0], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 3, Vector_add(worldPosition,[x_offset[1], y_offset[1], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 4, Vector_add(worldPosition,[x_offset[2], y_offset[2], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 5, Vector_add(worldPosition,[x_offset[3], y_offset[3], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 6, Vector_add(worldPosition,[x_offset[4], y_offset[4], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 7, Vector_add(worldPosition,[x_offset[5], y_offset[5], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 8, Vector_add(worldPosition,[x_offset[6], y_offset[6], 0]) );
		    Particles.SetParticleControl(vectorTargetParticle, 9, Vector_add(worldPosition,[x_offset[7], y_offset[7], 0]) );
	    }
	    if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "item_birzha_ward") ) {
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

	    if ( (Abilities.GetLocalPlayerActiveAbility() != -1) && (Abilities.GetAbilityName(Abilities.GetLocalPlayerActiveAbility()) == "puchkov_pigs") ) 
        {
	    	let origin = Entities.GetAbsOrigin( Players.GetLocalPlayerPortraitUnit() )
	    	let distance = Abilities.GetSpecialValueFor(Abilities.GetLocalPlayerActiveAbility(), "distance");
	    	let direction = Vector_normalize(Vector_sub(origin, worldPosition));
			Particles.SetParticleControl(vectorTargetParticle, 2, Vector_sub(origin, Vector_mult(direction, distance)) );
	    	Particles.SetParticleControl( vectorTargetParticle, 0, origin );
			Particles.SetParticleControl( vectorTargetParticle, 1, origin );
			Particles.SetParticleControl( vectorTargetParticle, 3, [125, 125, 1] );
			Particles.SetParticleControl( vectorTargetParticle, 4, [0, 255, 0] );
			Particles.SetParticleControl( vectorTargetParticle, 6, [1, 0, 0] );

	    }
	}

    $.Schedule(1/144, Think)
}

function HasModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            return true
        }
    }
    return false
}

function FindModifier(unit, modifier) 
{
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            return Entities.GetBuff(unit, i);
        }
    }
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

Think()

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

function Vector_distance (vec1, vec2) {
	return Math.sqrt(((vec2[0] - vec1[0]) ** 2) + ((vec2[1] - vec1[1]) ** 2));
}










