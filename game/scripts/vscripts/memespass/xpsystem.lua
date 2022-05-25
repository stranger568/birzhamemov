XP_LEVEL_NIDING = {1000,}

for lvlb = #XP_LEVEL_NIDING + 1, 5000 do
	XP_LEVEL_NIDING[lvlb] = XP_LEVEL_NIDING[lvlb - 1] + 1000
end


function GetLvlByXP(xp)
	if xp == nil then
		return 1	
	end

	for lvl,xplvl in pairs (XP_LEVEL_NIDING) do
		if xplvl > xp then
			return lvl - 1
		end
	end

	return 1
end

function GetXpTnl(xp)
	local xp
	local lvl = GetLvlByXP(xp)
	local ntlvl = lvl + 1
	return XP_LEVEL_NIDING[ntlvl] - XP_LEVEL_NIDING[lvl]
end