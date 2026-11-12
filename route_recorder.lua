-- Route Recorder v2.2 standalone loader
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(path)
	local ok, body = pcall(function() return game:HttpGet(BASE .. path) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		error("[Route Recorder] no se pudo descargar " .. path)
	end
	return body
end
local src = get("recorder_part1.lua") .. get("recorder_part2.lua")
local fn, err = loadstring(src)
if not fn then error("[Route Recorder] loadstring: " .. tostring(err)) end
fn()
