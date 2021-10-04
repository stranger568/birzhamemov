function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
			DonateThink()
		return 5
	end)
end

function DonateThink()
	local Owner_location = Vector( 0, 0, 0 )
	local Pet_location = thisEntity:GetAbsOrigin()
	local vector_distance = Owner_location - Pet_location
	local distance = vector_distance:Length2D()
	
	if distance > 2500 then
		local order = 
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			TargetIndex = Owner_location
		}	
		ExecuteOrderFromTable(order)
	else
		thisEntity:Stop()
		local order = 
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = Pet_location + RandomVector( RandomFloat(400, 800))
		}	
		ExecuteOrderFromTable(order)
	end
end