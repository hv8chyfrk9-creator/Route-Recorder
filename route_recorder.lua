-- Route Recorder v2.2
print("[RR] descargando...")
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(p)
	local ok, b = pcall(function() return game:HttpGet(BASE .. p) end)
	if not ok or type(b) ~= "string" or #b < 5 then
		error("[RR] fail " .. tostring(p) .. " " .. tostring(b))
	end
	return b
end
local src = ""
for i = 1, 16 do
	print("[RR] " .. i .. "/16")
	src = src .. get("s" .. i .. ".lua")
end
print("[RR] chars=" .. #src)
local fn, err = loadstring(src)
if not fn then error("[RR] syntax: " .. tostring(err)) end
local ok, e2 = pcall(fn)
if not ok then error("[RR] runtime: " .. tostring(e2)) end
print("[RR] OK")
