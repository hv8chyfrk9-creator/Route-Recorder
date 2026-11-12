-- Route Recorder v2.2
print("[RR] cargando...")
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function get(p)
	local ok, b = pcall(function() return game:HttpGet(BASE .. p) end)
	if not ok or type(b) ~= "string" or #b < 5 then error("[RR] fail " .. tostring(p)) end
	return b
end
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64dec(data)
	data = string.gsub(data, "[^" .. alphabet .. "=]", "")
	return (data:gsub(".", function(x)
		if x == "=" then return "" end
		local r, f = "", (alphabet:find(x) - 1)
		for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
		end
		return r
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then return "" end
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
		end
		return string.char(c)
	end))
end
local src = ""
for i = 1, 12 do
	print("[RR] " .. i .. "/12")
	src = src .. b64dec(get("b" .. i .. ".txt"))
end
print("[RR] " .. #src .. " chars")
local fn, err = loadstring(src)
if not fn then error("[RR] syntax: " .. tostring(err)) end
local ok, e2 = pcall(fn)
if not ok then error("[RR] runtime: " .. tostring(e2)) end
print("[RR] OK")
