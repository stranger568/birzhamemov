if report_system == nil then
    report_system = class({})
end

report_system.report_table_game = {}

function report_system:ReportPlayer(data)
    if data.PlayerID == nil then return end
    local player_table = CustomNetTables:GetTableValue("birzhainfo", tostring(data.PlayerID))
    if player_table then
        if player_table.reports_count > 0 then

            if not report_system.report_table_game[data.PlayerID] then
                report_system.report_table_game[data.PlayerID] = {}
            end

            for _, report_id in pairs(report_system.report_table_game[data.PlayerID]) do
                if report_id == data.id then
                    return
                end
            end

            player_table.reports_count = player_table.reports_count - 1
            CustomNetTables:SetTableValue('birzhainfo', tostring(data.PlayerID), player_table)
            table.insert(report_system.report_table_game[data.PlayerID], data.id)

            if report_system:HasTeamMate(data.id) then
                local post_data = {
                    player = {
                        {
                            steamid_target = PlayerResource:GetSteamAccountID(data.id),
                            steam_id_parent = PlayerResource:GetSteamAccountID(data.PlayerID),
                        }
                    },
                }

                SendData('https://bmemov.ru/data/post_player_report.php', post_data, nil)
            end
        end
    end
end

function report_system:HasTeamMate(id)
    if GetMapName() == "birzhamemov_solo" then
        local player_table = PLAYERS[ id ]
        local player_party = 0
        if player_table and player_table.partyid then
            player_party = player_table.partyid
        end
        if player_party > 0 then
            for pid, pinfo in pairs( PLAYERS ) do
                if pid ~= id and pinfo.partyid and pinfo.partyid == player_party then
                    return true
                end
            end
        end
    end
    return false
end