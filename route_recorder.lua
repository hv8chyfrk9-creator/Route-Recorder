-- Route Recorder v2.2
print("[RR] descargando partes...")
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(p)
	local ok, b = pcall(function()
		return game:HttpGet(BASE .. p)
	end)
	if not ok or type(b) ~= "string" or #b < 20 then
		error("[RR] no se pudo bajar " .. tostring(p) .. " -> " .. tostring(b))
	end
	return b
end
local src = ""
for i = 1, 6 do
	print("[RR] parte " .. i .. "/6")
	src = src .. get("rr" .. i .. ".lua")
end
print("[RR] loadstring " .. #src .. " chars")
local fn, err = loadstring(src)
if not fn then
	error("[RR] syntax: " .. tostring(err))
end
local ok, err2 = pcall(fn)
if not ok then
	error("[RR] runtime: " .. tostring(err2))
end
print("[RR] listo")
