if report_system == nil then
    report_system = class({})
end

report_system.report_table_game = {}

function report_system:player_reported_select(data)
    local report_id = data.report_id
    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID] then
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted then
            local has_reported = false
            for count = #BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted, 1, -1 do
                if BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted[count] and (BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted[count] == report_id) then
                    table.remove(BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted, count)
                    has_reported = true
                end
            end
            if #BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted >= 2 then
                return
            end
            if not has_reported then
                table.insert(BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted, report_id)
            end
            CustomNetTables:SetTableValue("reported_info", tostring(data.PlayerID), {reported_info = BirzhaData.PLAYERS_GLOBAL_INFORMATION[data.PlayerID].players_repoted})
        end
    end
end

function report_system:UpdateReportsInfo()
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        BirzhaData.PLAYERS_GLOBAL_INFORMATION[id].has_report = report_system:GetReportSystem(player_info.server_data.reports, id)
    end
end

function report_system:GetReportSystem(data, pid)
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if id ~= pid then
            for _, info in pairs(data) do
                if tostring(info.player_1) == tostring(player_info.steamid) then
                    return info.ban_days
                end
                if tostring(info.player_2) == tostring(player_info.steamid) then
                    return info.ban_days
                end
            end
        end
    end
    return 0
end