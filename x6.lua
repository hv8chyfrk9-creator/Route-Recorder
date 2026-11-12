.TextColor3 = Color3.fromRGB(255, 230, 120)
	dtxt.TextSize = 11
	corner(dtxt, 4)
	return holder, distBb
end

local function rebuildLines()
	for _, p in ipairs(points) do
		if p.line then p.line:Destroy() p.line = nil end
		if p.distLabel then p.distLabel:Destroy() p.distLabel = nil end
		if p.modeLines then
			for _, holder in pairs(p.modeLines) do
				if holder and holder.Parent then holder:Destroy() end
			end
			p.modeLines = nil
		end
	end
	-- limpia huerfanos
	for _, c in ipairs(folder:GetChildren()) do
		if c.Name == "RouteLine" or c.Name == "DistAnchor" then
			pcall(function() c:Destroy() end)
		end
	end
	-- lineas por modo: N con N, F con F, S con S
	local modeColors = {
		normal = Color3.fromRGB(60, 220, 100),
		fast = Color3.fromRGB(255, 200, 50),
		super = Color3.fromRGB(80, 170, 255),
	}
	local yOff = { normal = 0, fast = 0.4, super = -0.4 }
	for _, mode in ipairs({ "normal", "fast", "super" }) do
		local prev = nil
		for i, p in ipairs(points) do
			if pointInMode(p, mode) then
				if prev then
					local a = prev.cf.Position + Vector3.new(0, yOff[mode], 0)
					local b = p.cf.Position + Vector3.new(0, yOff[mode], 0)
					local line, distAnchor = makeLine(a, b, modeColors[mode])
					p.modeLines = p.modeLines or {}
					-- guarda holders para poder destruirlos
					local bag = Instance.new("Folder")
					bag.Name = "ModeLineBag"
					bag.Parent = folder
					if line then line.Parent = bag end
					if distAnchor then distAnchor.Parent = bag end
					p.modeLines[mode] = bag
				end
				prev = p
			end
		end
	end
end

local function refreshLabels()
	for i, p in ipairs(points) do
		if p.marker then
			p.marker.Name = "CF_" .. i
			p.marker.Color = kindColor[p.kind or "normal"] or kindColor.normal
			if p.label then p.label:Destroy() end
			local tag = "CF " .. i .. " " .. modesLabel(p.modes)
			if p.kind and p.kind ~= "normal" then
				tag = tag .. " [" .. p.kind .. "]"
			end
			p.label = makeBillboard(p.marker, tag, 2.4, kindColor[p.kind or "normal"])
		end
	end
end

local listFrame -- filled later, refreshed on point change
local function refreshPointList() end -- forward

local function addPoint(cf, atIndex, kind, waitSec, skipUndo, modes, light)
	if not skipUndo and not light then pushUndo() end
	kind = kind or currentPointKind or "normal"
	waitSec = waitSec or (kind == "wait" and currentWaitSec or 0)
	modes = modesCopy(modes or currentModes)
	-- al menos un modo
	if not (modes.normal or modes.fast or modes.super) then
		modes.normal = true
	end
	-- Y/X fija SOLO al grabar puntos nuevos (no modifica los ya existentes)
	do
		local pos = cf.Position
		local x = (fixedXMode and fixedXValue) and fixedXValue or pos.X
		local y = (fixedYMode and fixe