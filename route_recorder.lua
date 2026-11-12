-- Route Recorder v2.2
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Route-Recorder/main/"
local function http(path)
	local ok, body = pcall(function() return game:HttpGet(BASE .. path) end)
	if not ok or type(body) ~= "string" then error("[RR] download " .. path) end
	return body
end
local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64dec(data)
	data = string.gsub(data, "[^" .. b .. "=]", "")
	return (data:gsub(".", function(x)
		if x == "=" then return "" end
		local r, f = "", (b:find(x) - 1)
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
local acc = ""
for i = 1, 12 do
	acc = acc .. http("b" .. i .. ".txt")
end
local src = b64dec(acc)
local fn, err = loadstring(src)
if not fn then error("[RR] load: " .. tostring(err)) end
fn()
