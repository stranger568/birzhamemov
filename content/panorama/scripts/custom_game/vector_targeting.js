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
var vectorTargetUnit;
var vectorStartPosition;
var vectorRange = 800;
var useDual = false;
var currentlyActiveVectorTargetAbility;

const defaultAbilities = ["jull_crive_realy"];
const ignoreAbilites = ["pangolier_swashbuckle", "enraged_wildkin_hurricane"]

var radius_min = 0
var radius_max = 0

//Mouse Callback to check whever this ability was quick casted or not
GameUI.SetMouseCallback(function(eventName, arg, arg2, arg3)
{
	if(GameUI.GetClickBehaviors() == 3 && currentlyActiveVectorTargetAbility != undefined){
		const netTable = CustomNetTables.GetTableValue( "vector_targeting", currentlyActiveVectorTargetAbility )
		OnVectorTargetingStart(netTable.startWidth, netTable.endWidth, netTable.castLength, netTable.dual, netTable.ignoreArrow);
		currentlyActiveVectorTargetAbility = undefined;
	}
	return CONTINUE_PROCESSING_EVENT;
});

//Listen for class changes
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

// Start the vector targeting
function OnVectorTargetingStart(fStartWidth, fEndWidth, fCastLength, bDual, bIgnoreArrow)
{
	if (vectorTargetParticleNew) {
		Particles.DestroyParticleEffect(vectorTargetParticleNew, true)
		vectorTargetParticleNew = undefined;
		vectorTargetUnit = undefined;
	}

	const iPlayerID = Players.GetLocalPlayer();
	const selectedEntities = Players.GetSelectedEntities( iPlayerID );
	const mainSelected = Players.GetLocalPlayerPortraitUnit();
	const mainSelectedName = Entities.GetUnitName(mainSelected);
	vectorTargetUnit = mainSelected;
	const cursor = GameUI.GetCursorPosition();
	const worldPosition = GameUI.GetScreenWorldPosition(cursor);

	// redo dota's default particles
	const abilityName = Abilities.GetAbilityName(currentlyActiveVectorTargetAbility);
	if (ignoreAbilites.includes(abilityName)) return;


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
	return CONTINUE_PROCESSING_EVENT;
}

function OnVectorTargetingEnd()
{
	currentlyActiveVectorTargetAbility = undefined
	
	if (vectorTargetParticleNew) {
		Particles.DestroyParticleEffect(vectorTargetParticleNew, true)
		vectorTargetParticleNew = undefined;
		vectorTargetUnit = undefined;
	}
}

//Updates the particle effect and detects when the ability is actually casted
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