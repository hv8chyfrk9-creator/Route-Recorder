-- Route Recorder v2.2 (6 partes)
print("[RR] cargando v2.2 ...")
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(name)
	local ok, body = pcall(function()
		return game:HttpGet(BASE .. name)
	end)
	if not ok or type(body) ~= "string" or #body < 10 then
		error("[RR] no se pudo bajar " .. name .. " -> " .. tostring(body))
	end
	return body
end

local src = ""
for i = 1, 6 do
	print("[RR] parte " .. i .. "/6")
	src = src .. get("rr" .. i .. ".lua")
end
print("[RR] total " .. #src .. " chars")

local fn, err = loadstring(src)
if not fn then
	error("[RR] error de sintaxis: " .. tostring(err))
end
local ok, runtimeErr = pcall(fn)
if not ok then
	error("[RR] error al ejecutar: " .. tostring(runtimeErr))
end
print("[RR] OK")
