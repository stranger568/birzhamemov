function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Игнорируем FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

function GetValueCount(table, value)
local count = 0
	for _,v in pairs (table) do
		if v == value then
		count = count + 1
		end
	end
return count	
end

function GetPlayerMmr(id)
local table = CustomNetTables:GetTableValue("birzha_mmr", tostring(id)) or {}
return table.mmr
end

function SorthTableDESC(team)
local sort = {}
	for v = 0, #team do
		local max = team[0]
		local i_c = 0
			for i = 1, #team do
				if max < team[i] then
				max = team[i]
				i_c = i
				end
				
			end
		table.remove(team, i_c)
		table.insert(sort, i_c)
	end
	return sort
end

function SortMmrTable(t)
local sorted = {}
local c = #t
	for	 i = 1, c do
		local player_count = 1
		local mmr = t[player_count].mmr
			for d = 2, #t do
				if mmr < t[d].mmr then
				player_count = d
				mmr = t[d].mmr
				end
			end	
			table.insert(sorted, t[player_count])
			table.remove(t, player_count)
	end
	return sorted
end
