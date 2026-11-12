-- Route Recorder v2.2 — si este archivo es corto, usa el de artifacts o espera c1..c6
-- Loader:
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(p)
	local ok, b = pcall(function() return game:HttpGet(BASE .. p) end)
	if not ok or type(b) ~= "string" or #b < 20 then error("[RR] " .. p) end
	return b
end
local src = ""
for i = 1, 6 do src = src .. get("c" .. i .. ".lua") end
assert(loadstring(src))()
