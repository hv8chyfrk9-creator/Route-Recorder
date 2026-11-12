-- Route Recorder v2.2
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(p)
	local ok, b = pcall(function() return game:HttpGet(BASE .. p) end)
	if not ok or type(b) ~= "string" or #b < 10 then
		error("[Route Recorder] Falta " .. p .. " en el repo")
	end
	return b
end
local src = ""
for i = 1, 8 do
	src = src .. get("p" .. i .. ".lua")
end
local fn, err = loadstring(src)
if not fn then error("[Route Recorder] " .. tostring(err)) end
fn()
