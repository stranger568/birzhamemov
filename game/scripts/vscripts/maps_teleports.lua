function teleport_one(event)
   local unit = event.activator
   local wws= "tp_end_one"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end

function teleport_two(event)
   local unit = event.activator
   local wws= "tp_end_two"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end

function teleport_three(event)
   local unit = event.activator
   local wws= "tp_end_three"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end

function good_one(event)
   local unit = event.activator
   local wws= "good_end_one"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end

function good_two(event)
   local unit = event.activator
   local wws= "good_end_two"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end

function bad_one(event)
   local unit = event.activator
   local wws= "bad_end_one"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end

function bad_two(event)
   local unit = event.activator
   local wws= "bad_end_two"

   local ent = Entities:FindByName( nil, wws)
   local point = ent:GetAbsOrigin()
   event.activator:SetAbsOrigin( point )
   FindClearSpaceForUnit(event.activator, point, false)
   event.activator:Stop()
   event.activator:AddNewModifier( event.activator, nil, "modifier_invisible", { duration = 3 } )
end