-- Route Recorder v2.2 standalone
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(path)
	local ok, body = pcall(function() return game:HttpGet(BASE .. path) end)
	if not ok or type(body) ~= "string" or #body < 5 then
		error("[Route Recorder] fail " .. tostring(path))
	end
	return body
end
local src = ""
for i = 1, 6 do
	src = src .. get("c" .. i .. ".lua")
end
local fn, err = loadstring(src)
if not fn then error("[Route Recorder] " .. tostring(err)) end
fn()
