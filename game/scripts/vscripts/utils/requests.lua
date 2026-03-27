function RequestData(url, callback, callback_error)
    local key = GetDedicatedServerKeyV3('birzhamemov')
    if IsInToolsMode() then
        local bmemov_key = LoadKeyValues("scripts/bmemov_key.txt")
        if bmemov_key then
            key = bmemov_key["CustomDedicatedKey"]
        end
    end
    local req = CreateHTTPRequestScriptVM("GET", url)
    if not req then
        print("[Birzha Request] Не удалось создать запрос " .. tostring(url))
        if callback_error then
            callback_error({ error = "request_create_failed" })
        end
        return
    end
    req:SetHTTPRequestHeaderValue("X-Dota-Key", key)
    req:Send(function(res)
        if not res then
            print("[Birzha Request] Нет ответа от сервера " .. tostring(url))
            if callback_error then
                callback_error({ error = "no_response" })
            end
            return
        end
        if res.StatusCode ~= 200 then
            print("[Birzha Request] Ошибка " .. res.StatusCode .. " " .. tostring(url))
            if res.Body then
                print(res.Body)
            end
            if callback_error then
                local obj = nil
                if res.Body and res.Body ~= "" then
                    pcall(function()
                        obj = json.decode(res.Body)
                    end)
                end
                callback_error(obj or { error = "http_error", status = res.StatusCode })
            end
            return
        end
        if callback then
            local obj, pos, err = json.decode(res.Body)
            callback(obj)
        end
    end)
end

function SendData(method_url, data, callback, callback_error)
    local key = GetDedicatedServerKeyV3('birzhamemov')
    if IsInToolsMode() then
        local bmemov_key = LoadKeyValues("scripts/bmemov_key.txt")
        if bmemov_key then
            key = bmemov_key["CustomDedicatedKey"]
        end
    end
    data = {data = data}
    local url = method_url
    local req = CreateHTTPRequestScriptVM("POST", url)
    local encoded = json.encode(data)
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    req:SetHTTPRequestHeaderValue("X-Dota-Key", key)
    req:SetHTTPRequestRawPostBody("application/json", encoded)
    req:Send(function(res)
        if res.StatusCode ~= 200 and res.StatusCode ~= 201 then
            print(res.Body)
            print("Не удалось отправить данные, ошибка "..res.StatusCode.." "..url)
            if callback_error then
                local obj, pos, err = json.decode(res.Body)
                callback_error(obj)
            end   
            return
        elseif callback then
            local obj, pos, err = json.decode(res.Body)
            callback(obj)
        end
    end)
end
