function RequestData(url, callback)
    local req = CreateHTTPRequestScriptVM("GET", url)
    if req then
	    req:Send(function(res)

	        if res.StatusCode ~= 200 then
	            print("[Birzha Request] Не удалось подключится к серверу")   
	            return
	        end

	        if callback then
	            local obj, pos, err = json.decode(res.Body)
	            callback(obj)
	        end
	    end)
	end	
end

function SendData(url, data, callback)
		AUTH_KEY = GetDedicatedServerKeyV3('birzhamemov')
		local token = AUTH_KEY
		local req = CreateHTTPRequestScriptVM("POST", url)
		local encoded = json.encode(data)
		local encoded_token = json.encode(token)
		print("[Birzha Request] Data was encoded!")
		req:SetHTTPRequestGetOrPostParameter('data', encoded)
		req:SetHTTPRequestGetOrPostParameter('token', encoded_token)
		req:Send(function(res)
		if callback then
			local obj, pos, err = json.decode(res.Body)
			callback(obj)
		end
	end)
end
