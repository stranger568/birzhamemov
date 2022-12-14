function OnItemWillSpawn( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "item_will_spawn", true );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	GameUI.PingMinimapAtLocation( msg.spawn_location );
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#ItemWillSpawn" );
	$.Schedule( 3, ClearItemSpawnMessage );
}

function OnItemHasSpawned( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", true );
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#ItemHasSpawned" );		
	$.Schedule( 3, ClearItemSpawnMessage );
}
		
function ClearItemSpawnMessage()
{
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	$( "#AlertMessage" ).text = "";
}

function OnItemDrop( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "recent_item_drop", true );
	$( "#PickupMessage_Hero_Text" ).SetDialogVariable( "hero_id", $.Localize( "#"+msg.hero_id ) + " " + $.Localize("#OverthrowTextPickup") );
	$("#PickupMessage_Item_Text").text = $.Localize("#DOTA_Tooltip_Ability_" + msg.dropped_item);

	$.Schedule( 3, ClearDropMessage );
}
		
function ClearDropMessage()
{
	$.GetContextPanel().SetHasClass( "recent_item_drop", false );
}

function OnLeaderKilled( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "leader_has_been_killed", true );
	$( "#KillMessage_Hero" ).SetDialogVariable( "hero_id", $.Localize( "#"+msg.hero_id ) );
	$.Schedule( 2.5, ClearKillMessage );
}
		
function ClearKillMessage()
{
	$.GetContextPanel().SetHasClass( "leader_has_been_killed", false );
} 

function BristTrue( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "bristleback_killed", true );
	$.Schedule( 3, RemoveBristTrue );
}

function LolTrue( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "lolblade_killed", true );
	$.Schedule( 3, RemoveLolTrue );
}

function FoutainTrue( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "fountain_close", true );
	$.Schedule( 4, RemoveFoutainTrue );
}

function pucci_accept_quest( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "pucci_quest", true );
	$("#PucciLabel").text = $.Localize("#Birzha_warning_pucci") + " " + msg.count + " / 14" + " " + $.Localize("#Birzha_warning_pucci_quest");
	$.Schedule( 4, RemovePucciTrue );
}

function RemoveBristTrue()
{
	$.GetContextPanel().SetHasClass( "bristleback_killed", false );
}

function RemoveLolTrue()
{
	$.GetContextPanel().SetHasClass( "lolblade_killed", false );
}

function RemoveFoutainTrue()
{
	$.GetContextPanel().SetHasClass( "fountain_close", false );
}

function RemovePucciTrue()
{
	$.GetContextPanel().SetHasClass( "pucci_quest", false );
}

function ContractWillSpawn( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "contract_has_spawned", true );
	$( "#ContractSpawnLabel" ).text = $.Localize( "#ContractWillSpawn" );
	$.Schedule( 3, ContractWillSpawnRemove );
}

function ContractSpawn( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "contract_spawned", true );
	$( "#ContractSpawnLabel" ).text = $.Localize( "#ContractHasSpawned" );	
	$.Schedule( 3, ContractSpawnRemove );
}

function ContractAccept( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "contract_accepted", true );
	$( "#ContractAcceptLabel" ).text = $.Localize( "#" + msg.caster ) + " " + $.Localize("#AcceptContract") + " " + $.Localize( "#" + msg.target );
	$.Schedule( 3, ContractAcceptRemove );
}

function ContractCancel( msg )
{
	RemoveAllEvents()
	$.GetContextPanel().SetHasClass( "contract_canceles", true );
	$( "#ContractCancelLabel" ).text = $.Localize( "#" + msg.target ) + " " + $.Localize("#CancelContract") + " " + $.Localize( "#" + msg.caster );
	$.Schedule( 3, ContractCancelRemove );
}

function ContractWillSpawnRemove()
{
	$.GetContextPanel().SetHasClass( "contract_has_spawned", false );
}

function ContractSpawnRemove()
{
	$.GetContextPanel().SetHasClass( "contract_spawned", false );
}

function ContractAcceptRemove()
{
	$.GetContextPanel().SetHasClass( "contract_accepted", false );
}

function ContractCancelRemove()
{
	$.GetContextPanel().SetHasClass( "contract_canceles", false );
}

function RemoveAllEvents()
{
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	$.GetContextPanel().SetHasClass( "recent_item_drop", false );
	$.GetContextPanel().SetHasClass( "leader_has_been_killed", false );
	$.GetContextPanel().SetHasClass( "bristleback_killed", false );
	$.GetContextPanel().SetHasClass( "lolblade_killed", false );
	$.GetContextPanel().SetHasClass( "fountain_close", false );
	$.GetContextPanel().SetHasClass( "contract_has_spawned", false );
	$.GetContextPanel().SetHasClass( "contract_spawned", false );
	$.GetContextPanel().SetHasClass( "contract_accepted", false );
	$.GetContextPanel().SetHasClass( "contract_canceles", false );
}


(function () {
	GameEvents.Subscribe( "item_will_spawn", OnItemWillSpawn );
	GameEvents.Subscribe( "item_has_spawned", OnItemHasSpawned );
	GameEvents.Subscribe( "overthrow_item_drop", OnItemDrop );
    GameEvents.Subscribe( "kill_alert", OnLeaderKilled );


    GameEvents.Subscribe( "bristlekek_killed_true", BristTrue );
	GameEvents.Subscribe( "lolblade_killed_true", LolTrue );
	GameEvents.Subscribe( "fountain_true", FoutainTrue );
	GameEvents.Subscribe( "pucci_accept_quest", pucci_accept_quest );

	GameEvents.Subscribe( "contract_event_will", ContractWillSpawn );
	GameEvents.Subscribe( "contract_event_spawn", ContractSpawn );
	GameEvents.Subscribe( "contract_event_accept", ContractAccept );
	GameEvents.Subscribe( "contract_event_cancel", ContractCancel );
})();

