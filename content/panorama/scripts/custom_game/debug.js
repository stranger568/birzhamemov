GameEvents.Subscribe( 'NetTableDebugErrors', NetTableDebugErrors );

errorLabels = []

function NetTableDebugErrors() {
	var table = CustomNetTables.GetTableValue("debug", "errors");

	$( "#DebugPanel" ).visible = true

	let i = 0

	for ( let k in table ) {
		if ( !errorLabels[i] ) {
			errorLabels[i] = $.CreatePanel( "Label", $( "#ErrorContainer" ), "" )
		}
			
		errorLabels[i].visible = true
		errorLabels[i].text = table[k]

		i++
	}

	while ( true ) {
		let err = errorLabels[i]

		if ( err ) {
			err.visible = false
		} else {
			break
		}

		i++
	}
}
$( "#DebugPanel" ).visible = false