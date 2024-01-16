// ----------------------------------------------------------
// Vector Targeting Library
// ========================
// Version: 1.0
// Github: https://github.com/Nibuja05/dota_vector_targeting
// ----------------------------------------------------------

/// Vector Targeting
const CONSUME_EVENT = true;
const CONTINUE_PROCESSING_EVENT = false;

//main variables
var vectorTargetParticleNew;
var marci_vectorTargetParticle;
var GogogoParticle;
var vectorTargetUnit;
var vectorStartPosition;
var vectorRange = 800;
var useDual = false;
var currentlyActiveVectorTargetAbility;
var marci_vectorTargetUnit;
var marci_vectorStartPosition;
var marci_vectorRange = 800;
var marci_currentlyActiveVectorTargetAbility;
var marci_current_target_index;

const defaultAbilities = ["jull_crive_realy", "ruby_ranged_mode", "haku_jump", "thomas_ability_three", "puchkov_hurricane"];
const ignoreAbilites = ["pangolier_swashbuckle", "enraged_wildkin_hurricane"]

var radius_min = 0
var radius_max = 0

GameUI.SetMouseCallback(function(eventName, arg, arg2, arg3)
{
	if(GameUI.GetClickBehaviors() == 3 && currentlyActiveVectorTargetAbility != undefined){
		const netTable = CustomNetTables.GetTableValue( "vector_targeting", currentlyActiveVectorTargetAbility )
		OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength, netTable.dual, netTable.ignoreArrow);
		currentlyActiveVectorTargetAbility = undefined;
	}
	return CONTINUE_PROCESSING_EVENT;
});

$.RegisterForUnhandledEvent("StyleClassesChanged", CheckAbilityVectorTargeting );

function CheckAbilityVectorTargeting(panel){
	if(panel == null){return;}

	//Check if the panel is an ability or item panel
	const abilityIndex = GetAbilityFromPanel(panel)
	if (abilityIndex >= 0) {

		//Check if the ability/item is vector targeted
		const netTable = CustomNetTables.GetTableValue("vector_targeting", abilityIndex);
		if (netTable == undefined) {
			let behavior = Abilities.GetBehavior(abilityIndex);
			if ((behavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) !== 0) {

				GameEvents.SendCustomGameEventToServer("check_ability", {"abilityIndex" : abilityIndex} );
			}
			return;
		}

		//Check if the ability/item gets activated or is finished
		if (panel.BHasClass("is_active")) {
			currentlyActiveVectorTargetAbility = abilityIndex;

			if(GameUI.GetClickBehaviors() == 9 ) {

				OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength, netTable.dual, netTable.ignoreArrow);
			}
		} else {
			OnVectorTargetingEnd();

		}
	}
}

//Find the ability/item entindex from the panorama panel
function GetAbilityFromPanel(panel) {
	if (panel.paneltype == "DOTAAbilityPanel") {

		// Be sure that it is a default ability Button
		const parent = panel.GetParent();
		if (parent != undefined && (parent.id == "abilities" || parent.id == "inventory_list")) {
			const abilityImage = panel.FindChildTraverse("AbilityImage")
			let abilityIndex = abilityImage.contextEntityIndex;
			let abilityName = abilityImage.abilityname

			//Will be undefined for items
			if (abilityName) {
				return abilityIndex;
			}

			//Return item entindex instead
			const itemImage = panel.FindChildTraverse("ItemImage")
			abilityIndex = itemImage.contextEntityIndex;
			return abilityIndex;
		}
	}
	return -1;
}


function OnVectorTargetingStart(fStartWidth, fEndWidth, fCastLength, bDual, bIgnoreArrow)
{
	if (vectorTargetParticleNew) 
	{
		Particles.DestroyParticleEffect(vectorTargetParticleNew, true)
		vectorTargetParticleNew = undefined;
		vectorTargetUnit = undefined;
	}

	if (marci_vectorTargetParticle && GogogoParticle) 
	{
		Particles.DestroyParticleEffect(marci_vectorTargetParticle, true)
		Particles.DestroyParticleEffect(GogogoParticle, true)
		marci_vectorTargetParticle = undefined;
		GogogoParticle = undefined;
	}

	const iPlayerID = Players.GetLocalPlayer();
	const selectedEntities = Players.GetSelectedEntities( iPlayerID );
	const mainSelected = Players.GetLocalPlayerPortraitUnit();
	const mainSelectedName = Entities.GetUnitName(mainSelected);
	vectorTargetUnit = mainSelected;
	const cursor = GameUI.GetCursorPosition();
	const worldPosition = GameUI.GetScreenWorldPosition(cursor);

	
	const abilityName = Abilities.GetAbilityName(currentlyActiveVectorTargetAbility);
	if (ignoreAbilites.includes(abilityName)) return;

	if (abilityName == "jull_crive_realy")
	{
		let talent_ability = Entities.GetAbilityByName( mainSelected, "special_bonus_birzha_jull_7" )

		let particleName = "particles/birzha_actions/jull_radius.vpcf";
		vectorTargetParticleNew = Particles.CreateParticle(particleName, ParticleAttachment_t.PATTACH_WORLDORIGIN, 0);
		vectorTargetUnit = mainSelected

		if (abilityName == "jull_crive_realy")
		{
			radius_min = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "min_radius");
			radius_max = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "max_radius");
		}

		if (Abilities.GetLevel( talent_ability ) == 1)
		{
			radius_min = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "min_radius") + Abilities.GetSpecialValueFor(talent_ability, "value");
			radius_max = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "max_radius") + Abilities.GetSpecialValueFor(talent_ability, "value");
			$.Msg(Abilities.GetSpecialValueFor(talent_ability, "value"))
		}

		Particles.SetParticleControl(vectorTargetParticleNew, 0, Vector_raiseZ(worldPosition, 100));
		Particles.SetParticleControl(vectorTargetParticleNew, 1, [radius_min, 0, 0]);
		vectorStartPosition = worldPosition;

		const unitPosition = Entities.GetAbsOrigin(mainSelected);
		const direction = Vector_normalize(Vector_sub(vectorStartPosition, unitPosition));
		const newPosition = Vector_add(vectorStartPosition, Vector_mult(direction, vectorRange));
		ShowVectorTargetingParticle();
	}
	else if (abilityName == "haku_jump")
	{
		let startWidth = fStartWidth || 125;
		let endWidth = fEndWidth || startWidth;
		var marci_vectorRange = fCastLength || 800;
		let ignoreArrowWidth = bIgnoreArrow;

		const abilityName = Abilities.GetAbilityName(currentlyActiveVectorTargetAbility);
		if (abilityName != "haku_jump")
		{
			return 
		}
		if (defaultAbilities.includes(abilityName)) 
		{
			marci_vectorRange = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "min_jump_distance");
			radius = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "landing_radius");
			ability_min_cast_range = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "min_jump_distance");
			ability_max_cast_range = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "max_jump_distance") - 50;
			cast_range = Abilities.GetCastRange( currentlyActiveVectorTargetAbility ) -50
		}
		let particleName = "particles/ui_mouseactions/range_finder_generic_aoe_nocenter.vpcf";
		let gogogoParticleName = "particles/ui_mouseactions/range_finder_line_moving_dash.vpcf"
		var ent=GameUI.FindScreenEntities(GameUI.GetCursorPosition())
		if (ent[0] != null && ent[0].entityIndex != Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() )) 
		{
			marci_current_target_index = ent[0].entityIndex
		}

		marci_vectorTargetParticle = Particles.CreateParticle(particleName, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, mainSelected);
		GogogoParticle = Particles.CreateParticle(gogogoParticleName, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, mainSelected);

		Particles.SetParticleControl(GogogoParticle, 0, Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())));
		const direction_2 = Vector_normalize(Vector_sub(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())), Entities.GetAbsOrigin( marci_current_target_index )));
		const newPosition_2 = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_2, 800));
		Particles.SetParticleControl(GogogoParticle, 1, newPosition_2);
		Particles.SetParticleControl(GogogoParticle, 2, Entities.GetAbsOrigin( marci_current_target_index ));
		vectorTargetUnit = mainSelected
		marci_vectorStartPosition = worldPosition;
		Particles.SetParticleControl(marci_vectorTargetParticle, 0, Entities.GetAbsOrigin( marci_current_target_index ));
		Particles.SetParticleControl(marci_vectorTargetParticle, 1, Entities.GetAbsOrigin( marci_current_target_index ));
		const direction_3 = Vector_normalize(Vector_sub(Entities.GetAbsOrigin( marci_current_target_index ), Vector_raiseZ(worldPosition, 100)));
		const newPosition_3 = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_3, radius/2));
		Particles.SetParticleControl(marci_vectorTargetParticle, 2, newPosition_3);
		Particles.SetParticleControl(marci_vectorTargetParticle, 3, [radius, radius, radius]);
		Particles.SetParticleControl(marci_vectorTargetParticle, 12, Vector_raiseZ(worldPosition, 100));
		const unitPosition = Entities.GetAbsOrigin(mainSelected);
		const direction = Vector_normalize(Vector_sub(marci_vectorStartPosition, unitPosition));
		const newPosition = Vector_add(marci_vectorStartPosition, Vector_mult(direction, marci_vectorRange));
		MarciShowVectorTargetingParticle();

	} else {

		let startWidth = fStartWidth || 125;
		let endWidth = fEndWidth || startWidth;
		vectorRange = fCastLength || 800;
		let ignoreArrowWidth = bIgnoreArrow;
		useDual = bDual == 1;

		if (defaultAbilities.includes(abilityName)) 
		{
			if (abilityName == "ruby_ranged_mode") 
			{
				startWidth = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "start_radius");
				endWidth = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "end_radius");
				vectorRange = Abilities.GetSpecialValueFor(currentlyActiveVectorTargetAbility, "range");
			}

			if (useDual) 
			{
				vectorRange = vectorRange / 2;
			}

			let particleName = "particles/ui_mouseactions/custom_range_finder_cone.vpcf";

			if (useDual) 
			{
				particleName = "particles/ui_mouseactions/custom_range_finder_cone_dual.vpcf"
			}

			vectorTargetParticleNew = Particles.CreateParticle(particleName, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, mainSelected);
			vectorTargetUnit = mainSelected
			Particles.SetParticleControl(vectorTargetParticleNew, 1, Vector_raiseZ(worldPosition, 100));
			Particles.SetParticleControl(vectorTargetParticleNew, 3, [endWidth, startWidth, ignoreArrowWidth]);
			Particles.SetParticleControl(vectorTargetParticleNew, 4, [0, 255, 0]);

			vectorStartPosition = worldPosition;
			const unitPosition = Entities.GetAbsOrigin(mainSelected);
			const direction = Vector_normalize(Vector_sub(vectorStartPosition, unitPosition));
			const newPosition = Vector_add(vectorStartPosition, Vector_mult(direction, vectorRange));

			if (!useDual) {
				Particles.SetParticleControl(vectorTargetParticleNew, 2, newPosition);
			} else {
				Particles.SetParticleControl(vectorTargetParticleNew, 7, newPosition);
				const secondPosition = Vector_add(vectorStartPosition, Vector_mult(Vector_negate(direction), vectorRange));
				Particles.SetParticleControl(vectorTargetParticleNew, 8, secondPosition);
			}

			ShowVectorTargetingParticleDefault();
		}
	}

	return CONTINUE_PROCESSING_EVENT;
}

function OnVectorTargetingEnd()
{
	currentlyActiveVectorTargetAbility = undefined
	
	if (vectorTargetParticleNew) 
	{
		Particles.DestroyParticleEffect(vectorTargetParticleNew, true)
		vectorTargetParticleNew = undefined;
		vectorTargetUnit = undefined;
	}

	if (marci_vectorTargetParticle && GogogoParticle) 
	{
		Particles.DestroyParticleEffect(marci_vectorTargetParticle, true)
		Particles.DestroyParticleEffect(GogogoParticle, true)
		marci_vectorTargetParticle = undefined;
		GogogoParticle = undefined;
	}
}

function ShowVectorTargetingParticle()
{
	if (vectorTargetParticleNew !== undefined)
	{
		const mainSelected = Players.GetLocalPlayerPortraitUnit();
		const cursor = GameUI.GetCursorPosition();
		const worldPosition = GameUI.GetScreenWorldPosition(cursor);

		if (worldPosition == null)
		{
			$.Schedule(1 / 144, ShowVectorTargetingParticle);
			return;
		}

		const testVec = Vector_sub(worldPosition, vectorStartPosition);

		if (!(testVec[0] == 0 && testVec[1] == 0 && testVec[2] == 0))
		{
			let direction = Vector_normalize(Vector_sub(vectorStartPosition, worldPosition));
			direction = Vector_flatten(Vector_negate(direction));
			const newPosition = Vector_add(vectorStartPosition, Vector_mult(direction, vectorRange));
			let distance = Vector_Distance(vectorStartPosition, worldPosition)
			if (vectorTargetParticleNew)
			{
				Particles.DestroyParticleEffect(vectorTargetParticleNew, true)
				let particleName = "particles/birzha_actions/jull_radius.vpcf";
				vectorTargetParticleNew = Particles.CreateParticle(particleName, ParticleAttachment_t.PATTACH_WORLDORIGIN, 0);
				Particles.SetParticleControl(vectorTargetParticleNew, 0, Vector_raiseZ(vectorStartPosition, 100));

				if (distance <= radius_min)
				{
					Particles.SetParticleControl(vectorTargetParticleNew, 1, [radius_min, 0, 0]);
				} else if (distance >= radius_max)
				{	
					Particles.SetParticleControl(vectorTargetParticleNew, 1, [radius_max, 0, 0]);
				} else {
					Particles.SetParticleControl(vectorTargetParticleNew, 1, [distance, 0, 0]);
				}
			}
		}



		if( mainSelected != vectorTargetUnit ){
			GameUI.SelectUnit(vectorTargetUnit, false )
		}
		$.Schedule(1 / 144, ShowVectorTargetingParticle);
	}
}

function MarciShowVectorTargetingParticle()
{
	if (marci_vectorTargetParticle !== undefined && GogogoParticle !== undefined)
	{
		const mainSelected = Players.GetLocalPlayerPortraitUnit();
		const cursor = GameUI.GetCursorPosition();
		const worldPosition = GameUI.GetScreenWorldPosition(cursor);
		if (worldPosition == null)
		{
			$.Schedule(1 / 144, MarciShowVectorTargetingParticle);
			return;
		}
		const testVec = Vector_sub(worldPosition, marci_vectorStartPosition);
		let direction = Vector_normalize(Vector_sub(marci_vectorStartPosition, worldPosition));
		direction = Vector_flatten(Vector_negate(direction));
		const newPosition = Vector_add(marci_vectorStartPosition, Vector_mult(direction, marci_vectorRange));
		Particles.SetParticleControl(marci_vectorTargetParticle, 0, Entities.GetAbsOrigin( marci_current_target_index ));
		Particles.SetParticleControl(marci_vectorTargetParticle, 1, Entities.GetAbsOrigin( marci_current_target_index ));
		let direction_3 = Vector_normalize(Vector_sub(worldPosition, Entities.GetAbsOrigin( marci_current_target_index )));
		let direction_4 = Vector_normalize(Vector_sub(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())), Entities.GetAbsOrigin( marci_current_target_index )));
		let newPosition_3
		if (Vector_distance(worldPosition, Entities.GetAbsOrigin( marci_current_target_index )) >= ability_max_cast_range) {
			newPosition_3 = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_3, ability_max_cast_range));
			Particles.SetParticleControl(marci_vectorTargetParticle, 2, newPosition_3);	
			var line_length = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_3, ability_max_cast_range - radius));
			line_length[2] = line_length[2] + 50
			Particles.SetParticleControl(marci_vectorTargetParticle, 12, line_length);
		} else if (Vector_distance(worldPosition, Entities.GetAbsOrigin( marci_current_target_index )) <= ability_min_cast_range) {
			let distance_check = (Vector_distance(Entities.GetAbsOrigin( marci_current_target_index ), worldPosition))
			newPosition_3 = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_3, ability_min_cast_range));
			var line_length = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_3, ability_min_cast_range - radius));
			var ent=GameUI.FindScreenEntities(GameUI.GetCursorPosition())
			if (ent[0] != null && ent[0].entityIndex == marci_current_target_index) {
				newPosition_3 = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_4, -ability_min_cast_range));

				let direction_5 = Vector_normalize(Vector_sub(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())), newPosition_3));

				line_length = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_5, -ability_min_cast_range + radius));
			}
			line_length[2] = line_length[2] + 50
			Particles.SetParticleControl(marci_vectorTargetParticle, 2, newPosition_3);
			Particles.SetParticleControl(marci_vectorTargetParticle, 12, line_length);
		} else {
			var line_length = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_3, Vector_distance(worldPosition, Entities.GetAbsOrigin( marci_current_target_index )) - radius));
			line_length[2] = line_length[2] + 50
			Particles.SetParticleControl(marci_vectorTargetParticle, 2, worldPosition);
			Particles.SetParticleControl(marci_vectorTargetParticle, 12, line_length);
		}
		Particles.SetParticleControl(GogogoParticle, 0, Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())));
		const direction_2 = Vector_normalize(Vector_sub(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())), Entities.GetAbsOrigin( marci_current_target_index )));
		const newPosition_2 = Vector_add(Entities.GetAbsOrigin( marci_current_target_index ), Vector_mult(direction_2, cast_range));
		if (Vector_distance(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())), Entities.GetAbsOrigin( marci_current_target_index )) >= cast_range) {
			Particles.SetParticleControl(GogogoParticle, 1, newPosition_2);
		} else {
			Particles.SetParticleControl(GogogoParticle, 1, Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())));
		}
		Particles.SetParticleControl(GogogoParticle, 2, Entities.GetAbsOrigin( marci_current_target_index ));
		if( mainSelected != vectorTargetUnit ){
			GameUI.SelectUnit(vectorTargetUnit, false )
		}
		$.Schedule(1 / 144, MarciShowVectorTargetingParticle);
	}
}

function ShowVectorTargetingParticleDefault()
{
	if (vectorTargetParticleNew !== undefined)
	{
		const mainSelected = Players.GetLocalPlayerPortraitUnit();
		const cursor = GameUI.GetCursorPosition();
		const worldPosition = GameUI.GetScreenWorldPosition(cursor);

		if (worldPosition == null)
		{
			$.Schedule(1 / 144, ShowVectorTargetingParticleDefault);
			return;
		}
		const testVec = Vector_sub(worldPosition, vectorStartPosition);
		if (!(testVec[0] == 0 && testVec[1] == 0 && testVec[2] == 0))
		{
			let direction = Vector_normalize(Vector_sub(vectorStartPosition, worldPosition));
			direction = Vector_flatten(Vector_negate(direction));
			const newPosition = Vector_add(vectorStartPosition, Vector_mult(direction, vectorRange));

			if (!useDual) {
				Particles.SetParticleControl(vectorTargetParticleNew, 2, newPosition);
			} else {
				Particles.SetParticleControl(vectorTargetParticleNew, 7, newPosition);
				const secondPosition = Vector_add(vectorStartPosition, Vector_mult(Vector_negate(direction), vectorRange));
				Particles.SetParticleControl(vectorTargetParticleNew, 8, secondPosition);
			}
		}
		if( mainSelected != vectorTargetUnit ){
			GameUI.SelectUnit(vectorTargetUnit, false )
		}
		$.Schedule(1 / 144, ShowVectorTargetingParticleDefault);
	}
}

//Some Vector Functions here:
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

function Vector_Distance(vec1,vec2)
{
    return Math.sqrt(((vec2[0] - vec1[0]) ** 2) + ((vec2[1] - vec1[1]) ** 2) + ((vec2[2] - vec1[2]) ** 2));
}