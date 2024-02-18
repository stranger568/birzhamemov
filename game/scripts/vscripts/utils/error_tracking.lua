ErrorTracking = ErrorTracking or {}
ErrorTracking.collected_errors = ErrorTracking.collected_errors or ""

debug.oldTraceback = debug.oldTraceback or debug.traceback
debug.traceback = function(...)
	local stack = debug.oldTraceback(...)
	ErrorTracking.Collect(stack)
	return stack
end

function ErrorTracking.Collect(stack)
	stack = stack:gsub(": at 0x%x+", ": at 0x")
	if IsInToolsMode() then
		--print(stack)
	end
    print(stack)
    stack = stack:sub(1, stack:find("stack traceback:")-1)
    stack = string.gsub(stack, "\\", "__")
    stack = string.gsub(stack, "'", "")
    local post_data = 
    {
        ["error"] = tostring(stack),
    }
    SendData('https://' ..BirzhaData.url .. '/data/post_error_data.php', post_data, nil)
	ErrorTracking.collected_errors = ErrorTracking.collected_errors.."\n"..stack
	ErrorTracking.collected_errors = ""
end

function ErrorTracking.Try(callback, ...)
	return xpcall(callback, debug.traceback, ...)
end