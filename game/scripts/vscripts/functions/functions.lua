LinkLuaModifier( "modifier_birzha_premium", "modifiers/donate_modifiers/modifier_birzha_premium", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_vip", "modifiers/donate_modifiers/modifier_birzha_vip", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_gob", "modifiers/donate_modifiers/modifier_birzha_gob", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dragonball_effect", "modifiers/donate_modifiers/modifier_dragonball_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_leader_effect", "modifiers/donate_modifiers/modifier_leader_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_invul", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

function CDOTA_BaseNPC:DioMudaMudaMuda()
	local victim_angle = self:GetAnglesAsVector()
	local victim_angle_rad = victim_angle.y * math.pi/180
	local victim_position = self:GetAbsOrigin()
	local new_position = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
	return new_position
end

function CDOTA_BaseNPC:HasTalent(talentName)
    talentName = string.lower(talentName)
    if self:HasAbility(talentName) then
        local ability = self:FindAbilityByName(talentName)
        if ability and ability:GetLevel() > 0 then
            return true
        end
    end
    return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName, key)
    talentName = string.lower(talentName)
    if self:HasTalent(talentName) then
        local value_name = key or "value"
        return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
    end
    return 0
end

function CDOTA_BaseNPC:BirzhaTrueKill(ability, killer)
    if CDOTA_BaseNPC ~= nil and CDOTA_BaseNPC:IsNull() then return end
    if ability~= nil and ability:IsNull() then ability = nil end
    if killer ~= nil and killer:IsNull() then killer = nil end
    self:Kill(ability, killer)
    if self:IsAlive() then
        local modifiers_to_remove = 
        {
            "modifier_Overlord_spell_10_invul",
            "modifier_Overlord_spell_10_buff",
            "modifier_item_uebator_active",
            "modifier_LenaGolovach_Radio_god",
            "modifier_kurumi_god",
            "modifier_Felix_WaterShield",
            "modifier_ExplosionMagic_immunity",
            "modifier_item_nimbus_active",
            "modifier_haku_help",
            "modifier_item_birzha_blade_mail_active",
            "modifier_invulnerable",
            "modifier_item_aeon_disk_buff",
            "modifier_papich_reincarnation_wraith_form",
            "modifier_pucci_passive_wave_immortality",
            "modifier_polnaref_requeim",
            "modifier_homunculus_iborn_immortality_active",
            "modifier_scp682_ultimate",
            "modifier_overlord_terror_legion_talent",
            "polnaref_requeim",
        }
        for k, v in pairs(modifiers_to_remove) do
            if self:HasModifier(v) then
                self:RemoveModifierByName(v)
            end
        end
        self:Kill(ability, killer)
    end
end



function CalculateDistance(ent1, ent2)
    local pos1 = ent1
    local pos2 = ent2
    if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
    if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
    local distance = (pos1 - pos2):Length2D()
    return distance
end




function DisplayError(playerID, message)
    local player = PlayerResource:GetPlayer(playerID)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message=message})
    end
end

function CDOTA_BaseNPC:IsBoss()
    if self:GetUnitName() == "npc_dota_LolBlade" or self:GetUnitName() == "npc_dota_bristlekek" then
        return true
    end
    return false
end

function CDOTA_BaseNPC:IsDuel()
    if self:HasModifier("modifier_pistoletov_deathfight") or self:HasModifier("modifier_brb_test") then
        return true
    end
    return false
end

function CDOTA_BaseNPC:RemoveDonate()
    self:RemoveModifierByName("modifier_birzha_premium")
    self:RemoveModifierByName("modifier_birzha_gob")
    self:RemoveModifierByName("modifier_birzha_vip")
    self:RemoveModifierByName("modifier_dragonball_effect")
    self:RemoveModifierByName("modifier_leader_effect")
end

function CDOTA_BaseNPC:AddDonate(style)
    if style == "premium" then
        self:AddNewModifier( self, nil, "modifier_birzha_premium", {})
    end
    
    if style == "gob" then
        self:AddNewModifier( self, nil, "modifier_birzha_gob", {})
    end
    
    if style == "vip" then
        self:AddNewModifier( self, nil, "modifier_birzha_vip", {})
    end

    if style == "dragonball" then
        self:AddNewModifier( self, nil, "modifier_dragonball_effect", {})
    end

    if style == "leader" then
        self:AddNewModifier( self, nil, "modifier_leader_effect", {})
    end
end





function CDOTA_BaseNPC:AddInvul(duration)
    if duration then
        self:AddNewModifier( self, nil, "modifier_birzha_invul", {duration = duration})
    else
        self:AddNewModifier( self, nil, "modifier_birzha_invul", {})
    end
end









function CDOTA_BaseNPC:GetPhysicalArmorReduction()
    local armornpc = self:GetPhysicalArmorValue(false)
    local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
    armor_reduction = 100 - (armor_reduction * 100)
    return armor_reduction
end

function GetReductionFromArmor(armor)
    return (0.052 * armor) / (0.9 + 0.048 * math.abs(armor))
end

function CalculateDamageIgnoringArmor(damage, armor)
    return 1 / (1 - GetReductionFromArmor(armor)) * damage
end

function FindEntities(caster,point,radius,team,targets,flags,find_order)
  local team = team or DOTA_UNIT_TARGET_TEAM_BOTH
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  local flags = flags or 0
  local find_order = find_order or FIND_CLOSEST
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            team,
                            targets,
                            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                            find_order,
                            false)
end

function WorldParticle(particle_name,position,table_cp_vectors)
  local p = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(p, 0, position)

  if table_cp_vectors then
    for k,v in pairs(table_cp_vectors) do
      ParticleManager:SetParticleControl(p, k, v)
    end
  end
  
  return p
end

function BroadcastMessage( sMessage, fDuration )
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
  local list = shallowcopy( orig_list )
  local result = {}
  local count = #list
  for i = 1, count do
    local pick = RandomInt( 1, #list )
    result[ #result + 1 ] = list[ pick ]
    table.remove( list, pick )
  end
  return result
end

function TableCount( t )
  local n = 0
  for _ in pairs( t ) do
    n = n + 1
  end
  return n
end

function TableFindKey( table, val )
  if table == nil then
    print( "nil" )
    return nil
  end

  for k, v in pairs( table ) do
    if v == val then
      return k
    end
  end
  return nil
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER + 1
    local t = nCOUNTDOWNTIMER
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "GameTimer", broadcast_gametimer )
end

function ItemTimer(time)
    local t = time
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
end

function SetTimer( cmdName, time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end

function CountdownFountainTimer()
    FountainTimer = FountainTimer - 1
    local t = FountainTimer
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local kek = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "fountain", kek )
end

function CountdownEventTimer()
    EventTimer = EventTimer - 1
    local t = EventTimer
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local kek1 = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "eventcart", kek1 )
end

function CountdownEndGameTimer()
    GameEndTimer = GameEndTimer - 1
    local t = GameEndTimer
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local kek3 = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "endgametimer", kek3 )
end

function CDOTA_Modifier_Lua:CheckMotionControllers()
    local parent = self:GetParent()
    local modifier_priority = self:GetMotionControllerPriority()
    local is_motion_controller = false
    local motion_controller_priority
    local found_modifier_handler

    local non_imba_motion_controllers =
    {"modifier_brewmaster_storm_cyclone",
     "modifier_dark_seer_vacuum",
     "modifier_eul_cyclone",
     "modifier_earth_spirit_rolling_boulder_caster",
     "modifier_huskar_life_break_charge",
     "modifier_invoker_tornado",
     "modifier_item_forcestaff_active",
     "modifier_rattletrap_hookshot",
     "modifier_phoenix_icarus_dive",
     "modifier_shredder_timber_chain",
     "modifier_slark_pounce",
     "modifier_spirit_breaker_charge_of_darkness",
     "modifier_tusk_walrus_punch_air_time",
     "modifier_earthshaker_enchant_totem_leap"}

    local modifiers = parent:FindAllModifiers() 
    for _,modifier in pairs(modifiers) do       
        if self ~= modifier then            
            if modifier.IsMotionController then
                if modifier:IsMotionController() then
                    found_modifier_handler = modifier
                    is_motion_controller = true
                    motion_controller_priority = modifier:GetMotionControllerPriority()             
                    break
                end
            end
            for _,non_imba_motion_controller in pairs(non_imba_motion_controllers) do               
                if modifier:GetName() == non_imba_motion_controller then
                    found_modifier_handler = modifier
                    is_motion_controller = true
                    motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST                
                    break
                end
            end
        end
    end

    if is_motion_controller and motion_controller_priority then
        if motion_controller_priority > modifier_priority then          
            return false
        elseif motion_controller_priority == modifier_priority then         
            if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then              
                return false
            else                
                found_modifier_handler:Destroy()
                return true
            end
        else            
            parent:InterruptMotionControllers(true)
            found_modifier_handler:Destroy()
            return true
        end
    else
        return true
    end
end

function StartTimerLoading()  
    local timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "hero_selection_timer" })
    timer:SetThink( _TimerThinker, 1 )
end

local _TimerThinker__Timers = {}
local _TimerThinker__Events = {}
local _TimerThinker__Events_Index = {}
local timer_dt = 1/30
local timer_time = 0
function _TimerThinker()
    local i = 1
    while _TimerThinker__Events_Index[i] and _TimerThinker__Events_Index[i] <= timer_time do
        local event_time = _TimerThinker__Events_Index[i]
        local tRemove_timers = {}
        
        for _, timer_id in pairs( _TimerThinker__Events[ event_time ] ) do
            local next_event_time = event_time
            if next_event_time and next_event_time <= timer_time then
                local interval = (_TimerThinker__Timers[ timer_id ])()
                if type(interval) ~= 'number' or interval < 0 then
                    next_event_time = nil
                else
                    next_event_time = next_event_time + interval
                end
            end
            
            if next_event_time then
                _AddTimerEvent( next_event_time, timer_id )
            else
                tRemove_timers[ timer_id ] = true
            end
        end
        
        for timer_id in pairs( tRemove_timers ) do
            _RemoveTimer( timer_id )
        end
        
        _RemoveTimerEvent( i )      
        i = i + 1
    end
    
    timer_time = timer_time + timer_dt
    return timer_dt
end

function _AddTimerEvent( event_time, timer_id )
    local i = 1
    while _TimerThinker__Events_Index[i] and _TimerThinker__Events_Index[i] < event_time do
        i = i + 1
    end
    
    if event_time == _TimerThinker__Events_Index[i] then
        local event = _TimerThinker__Events[ event_time ]
        table.insert( event, timer_id )
    else
        _TimerThinker__Events[ event_time ] = {timer_id}
        table.insert( _TimerThinker__Events_Index, i, event_time )
    end
    
    return i
end

function _RemoveTimerEvent( event_id )
    local event_time = _TimerThinker__Events_Index[ event_id ]
    table.remove( _TimerThinker__Events_Index, event_id )
    _TimerThinker__Events[ event_time ] = nil
end

function _AddTimer( f )
    local timer_id = 1
    while _TimerThinker__Timers[ timer_id ] do
        timer_id = timer_id + 1
    end
    _TimerThinker__Timers[ timer_id ] = f
    return timer_id
end

function _RemoveTimer( id )
    for _, event in pairs( _TimerThinker__Events ) do
        for k, timer_id in pairs( event ) do
            if timer_id == id then
                table.remove( event, k )
            end
        end
    end
    _TimerThinker__Timers[ id ] = nil
end

function Schedule( d, f )
    d = d or 0
    if type(d) ~= 'number' or d < 0 then
    end

    while d and d == 0 do
        d = f()
    end
    
    local next_trigger_time = timer_time
    if d and d > 0 then
        next_trigger_time = next_trigger_time + d
    else
        next_trigger_time = nil
    end
    
    if next_trigger_time then
        local timer_id = _AddTimer(f)
        _AddTimerEvent( next_trigger_time, timer_id )
        return timer_id
    end
end

function Timer( f, d )
    local lasttime = GameRules:GetGameTime()
    local oldcall_time = lasttime
    local interval = d
    return Schedule( d, function()
        local curtime = GameRules:GetGameTime()
        local dt = curtime - lasttime
        lasttime = curtime
        interval = ( interval or 0 ) - dt
        if interval < 1/32 then
            local new_interval = f( curtime - oldcall_time )
            oldcall_time = curtime
            if type(new_interval) == 'number' then
                interval = math.max( 0.01, interval + new_interval )
                return interval
            else
                return
            end
        end
        return math.max( interval, 0.01 )
    end )
end

function RotateVector2D(v,angle,bIsDegree)
    if bIsDegree then angle = math.rad(angle) end
    local xp = v.x * math.cos(angle) - v.y * math.sin(angle)
    local yp = v.x * math.sin(angle) + v.y * math.cos(angle)

    return Vector(xp,yp,v.z):Normalized()
end

function IsNearEntity(entities, location, distance, owner)
    for _, entity in pairs(Entities:FindAllByClassname(entities)) do
        if (entity:GetAbsOrigin() - location):Length2D() <= distance or owner and (entity:GetAbsOrigin() - location):Length2D() <= distance and entity:GetOwner() == owner then
            return true
        end
    end

    return false
end

LinkLuaModifier("modifier_burger_strength", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burger_agility", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burger_intellect", "items/items_burgers", LUA_MODIFIER_MOTION_NONE)

function BirzhaCreateIllusion(v1,v2,v3,v4,v5,v6,v7)
    local illusions = CreateIllusions(v1, v2, v3, v4, v5, v6, v7)
    
    for _, illusion in pairs(illusions) do
        if v2 and v2:HasModifier("modifier_burger_strength") then
            local modifier = v2:FindModifierByName("modifier_burger_strength")
            if modifier then
                local modifier_illusion = illusion:AddNewModifier(v2, nil, "modifier_burger_strength", {})
                if modifier_illusion then
                    modifier_illusion:SetStackCount(modifier:GetStackCount())
                end
            end
        end
        if v2 and v2:HasModifier("modifier_burger_agility") then
            local modifier = v2:FindModifierByName("modifier_burger_agility")
            if modifier then
                local modifier_illusion = illusion:AddNewModifier(v2, nil, "modifier_burger_agility", {})
                if modifier_illusion then
                    modifier_illusion:SetStackCount(modifier:GetStackCount())
                end
            end
        end
        if v2 and v2:HasModifier("modifier_burger_intellect") then
            local modifier = v2:FindModifierByName("modifier_burger_intellect")
            if modifier then
                local modifier_illusion = illusion:AddNewModifier(v2, nil, "modifier_burger_intellect", {})
                if modifier_illusion then
                    modifier_illusion:SetStackCount(modifier:GetStackCount())
                end
            end
        end
    end

    return illusions
end

function CountdownContractTimer(t)
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "contarct_time", broadcast_gametimer )
end

function CDOTA_BaseNPC:HasShard()
    if self:HasModifier("modifier_item_aghanims_shard") then
        return true
    end

    return false
end

------ 7.31