function toy(event)
	local caster = event.caster
	local ability = event.ability
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		100,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_NONE,
		FIND_ANY_ORDER,
		false)

	for _,unit in pairs(targets) do
		local distance = (caster:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
		local direction = (caster:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()
		local bump_point = unit:GetAbsOrigin() - direction * distance
		local knockbackProperties =
		{
			center_x = bump_point.x,
			center_y = bump_point.y,
			center_z = bump_point.z,
			duration = 0.4,
			knockback_duration = 0.4,
			knockback_distance = 300,
			knockback_height = 0
		}
		
		caster:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
		EmitSoundOn( "General.Pig", caster )
	end
end

function toyDragon(event)
	local caster = event.caster
	local ability = event.ability
	local OWNER = caster
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		300,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_NONE,
		FIND_ANY_ORDER,
		false)

	for _,unit in pairs(targets) do
		OWNER = unit
	end
	
	local Owner_location = OWNER:GetAbsOrigin()
	local Pet_location = caster:GetAbsOrigin()
	local vector_distance = Owner_location - Pet_location
	local distance = vector_distance:Length2D()
	
	if distance > 400 and distance < 900 then
		local order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
			TargetIndex = OWNER:entindex()
		}	
		ExecuteOrderFromTable(order)
	elseif distance < 325 then
		caster:Stop()
		local order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = Owner_location + RandomVector( RandomFloat(0, 300))
		}	
		ExecuteOrderFromTable(order)
	elseif distance > 900 then
		caster:SetAbsOrigin(Owner_location + RandomVector( RandomFloat(0, 100)))
	end
end


function CreatedModel (keys)
	local caster = keys.caster
	Timers:CreateTimer(20, function()
		caster:Destroy()
	end)
end
