if not VectorTarget then
	VectorTarget = {}
end

function VectorTargetCallback( eventSourceIndex, args )
	local init_pos = Vector( args.init_pos["0"], args.init_pos["1"], args.init_pos["2"] )
	local end_pos = Vector( args.end_pos["0"], args.end_pos["1"], args.end_pos["2"] )
	local direction = Vector( args.direction["0"], args.direction["1"], args.direction["2"] )
	local ability = EntIndexToHScript( args["ability"] )

	local data = {}
	data.init_pos = init_pos
	data.end_pos = end_pos
	data.direction = direction

	-- store data
	if not ability:IsInAbilityPhase() then
		VectorTarget[ ability ] = data
	end
end

function CDOTABaseAbility:CheckVectorTargetPosition()
	if not VectorTarget[ self ] then return false end
	local data = VectorTarget[ self ]

	-- check current cast's target
	local target = self:GetCaster():GetCursorPosition()
	if (target-data.end_pos):Length2D()<(target-data.init_pos):Length2D() then
		return false
	end

	return true
end

function CDOTABaseAbility:GetVectorTargetPosition()
	if not VectorTarget[ self ] then return nil end
	local data = VectorTarget[ self ]
	VectorTarget[ self ] = nil
	return data
end

CustomGameEventManager:RegisterListener( "vector_target", VectorTargetCallback )

return VectorTarget