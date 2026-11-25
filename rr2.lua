 _, p in pairs(pages) do
	p.Size = UDim2.new(1, -16, 1, -110)
end

local function setStatus(t)
	statusLabel.Text = t
end

-- ==========================================
-- MARKERS / VISUALS
-- ==========================================
local kindColor = {
	normal = Color3.fromRGB(40, 220, 100),
	plant = Color3.fromRGB(255, 180, 60),
	wait = Color3.fromRGB(100, 160, 255),
	jump = Color3.fromRGB(220, 100, 255),
}

local function clearVisualsFor(i)
	local p = points[i]
	if not p then return end
	if p.marker then p.marker:Destroy() end
	if p.label then p.label:Destroy() end
	if p.line then p.line:Destroy() end
	if p.distLabel then p.distLabel:Destroy() end
	p.marker, p.label, p.line, p.distLabel = nil, nil, nil, nil
end

local function makeBillboard(part, text, yOffset, color)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 100, 0, 26)
	bb.StudsOffset = Vector3.new(0, yOffset or 2.2, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = part
	bb.Parent = part
	local tl = Instance.new("TextLabel")
	tl.Parent = bb
	tl.BackgroundTransparency = 0.3
	tl.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.Font = Enum.Font.GothamBold
	tl.Text = text
	tl.TextColor3 = color or Color3.fromRGB(120, 255, 140)
	tl.TextSize = 12
	corner(tl, 4)
	return bb
end

local function makeLine(fromPos, toPos, color)
	color = color or Color3.fromRGB(60, 220, 100)
	local mid = (fromPos + toPos) / 2
	local dist = (toPos - fromPos).Magnitude
	local holder = Instance.new("Folder")
	holder.Name = "RouteLine"
	holder.Parent = folder
	local dir = (toPos - fromPos)
	if dist > 0.1 then
		local unit = dir.Unit
		local step = 2
		local t = 0
		while t < dist do
			local len = math.min(0.9, dist - t)
			local a = fromPos + unit * t
			local b = fromPos + unit * (t + len)
			local m = (a + b) / 2
			local seg = Instance.new("Part")
			seg.Anchored = true
			seg.CanCollide = false
			seg.CanTouch = false
			seg.CanQuery = false
			seg.Material = Enum.Material.Neon
			seg.Color = color
			seg.Transparency = 0.15
			seg.Size = Vector3.new(0.12, 0.12, len)
			seg.CFrame = CFrame.lookAt(m, b)
			seg.Parent = holder
			t = t + step
		end
	end
	local distBb = Instance.new("Part")
	distBb.Name = "DistAnchor"
	distBb.Anchored = true
	distBb.CanCollide = false
	distBb.CanTouch = false
	distBb.CanQuery = false
	distBb.Transparency = 1
	distBb.Size = Vector3.new(0.2, 0.2, 0.2)
	distBb.Position = mid + Vector3.new(0, 1.5, 0)
	distBb.Parent = folder
	local dlab = Instance.new("BillboardGui")
	dlab.Size = UDim2.new(0, 78, 0, 20)
	dlab.AlwaysOnTop = true
	dlab.Adornee = distBb
	dlab.Parent = distBb
	local dtxt = Instance.new("TextLabel")
	dtxt.Parent = dlab
	dtxt.BackgroundTransparency = 0.35
	dtxt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dtxt.Size = UDim2.new(1, 0, 1, 0)
	dtxt.Font = Enum.Font.GothamBold
	dtxt.Text = string.format("%.1f", dist)
	dtxt.TextColor3 = Color3.fromRGB(255, 230, 120)
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
	-- limpia huérfanos
	for _, c in ipairs(folder:GetChildren()) do
		if c.Name == "RouteLine" or c.Name == "DistAnchor" then
			pcall(function() c:Destroy() end)
		end
	end
	-- líneas por modo: N con N, F con F, S con S
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

local function addPoint(cf, atIndex, kind, waitSec, skipUndo, modes)
	if not skipUndo then pushUndo() end
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
		local y = (fixedYMode and fixedYValue) and fixedYValue or pos.Y
		if x ~= pos.X or y ~= pos.Y then
			cf = CFrame.new(x, y, pos.Z) * (cf - cf.Position)
		end
	end
	local idx
	if atIndex and atIndex >= 1 and atIndex <= #points + 1 then
		idx = atIndex
		table.insert(points, idx, { cf = cf, kind = kind, waitSec = waitSec, modes = modes })
	else
		idx = #points + 1
		points[idx] = { cf = cf, kind = kind, waitSec = waitSec, modes = modes }
	end

	local ball = Instance.new("Part")
	ball.Name = "CF_" .. idx
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(1.4, 1.4, 1.4)
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanTouch = false
	ball.CanQuery = false
	ball.Material = Enum.Material.Neon
	ball.Color = kindColor[kind] or kindColor.normal
	ball.Transparency = 0.15
	ball.CFrame = cf
	ball.Parent = folder
	points[idx].marker = ball
	local tag = "CF " .. idx .. " " .. modesLabel(modes)
	if kind ~= "normal" then tag = tag .. " [" .. kind .. "]" end
	points[idx].label = makeBillboard(ball, tag, 2.4, kindColor[kind])

	if atIndex then
		for i, p in ipairs(points) do
			if p.marker and p.marker.Parent then
				p.marker.CFrame = p.cf
				p.marker.Color = kindColor[p.kind or "normal"]
			end
		end
		refreshLabels()
	end
	rebuildLines()
	refreshPointList()
	lastRecordPos = cf.Position
	setStatus("Añadido CF " .. idx .. " (" .. kind .. " | " .. modesLabel(modes) .. ")")

	pointsSinceSave = pointsSinceSave + 1
	if autoSaveEvery > 0 and pointsSinceSave >= autoSaveEvery then
		pointsSinceSave = 0
		-- soft auto-save under name "autosave"
		pcall(function()
			local pack = packState()
			local all = {}
			if isfile and isfile(saveFile) then
				local okR, decoded = pcall(function() return HttpService:JSONDecode(readfile(saveFile)) end)
				if okR and type(decoded) == "table" then all = decoded end
			end
			all["autosave"] = pack
			writefile(saveFile, HttpService:JSONEncode(all))
			setStatus("Auto-guardado")
		end)
	end
end

local function removeLast()
	if #points == 0 then return end
	pushUndo()
	local i = #points
	clearVisualsFor(i)
	table.remove(points, i)
	rebuildLines()
	refreshPointList()
	setStatus("Borrado último")
end

local function removeAt(n)
	if not points[n] then
		setStatus("Índice inválido")
		return
	end
	pushUndo()
	clearVisualsFor(n)
	table.remove(points, n)
	for i, p in ipairs(points) do
		if p.marker then p.marker.Name = "CF_" .. i end
	end
	refreshLabels()
	rebuildLines()
	refreshPointList()
	setStatus("Borrado CF " .. n)
end

local function clearAll()
	pushUndo()
	for i = #points, 1, -1 do clearVisualsFor(i) end
	points = {}
	if folder then
		for _, c in ipairs(folder:GetChildren()) do c:Destroy() end
	end
	refreshPointList()
	setStatus("Limpio")
end

local function applySnapshot(snap)
	for i = #points, 1, -1 do clearVisualsFor(i) end
	points = {}
	if folder then
		for _, c in ipairs(folder:GetChildren()) do
			if c.Name ~= "PreviewPoint" then c:Destroy() end
		end
	end
	for _, s in ipairs(snap) do
		addPoint(s.cf, nil, s.kind, s.waitSec, true, s.modes)
	end
	refreshPointList()
end

local function doUndo()
	if #undoStack == 0 then
		setStatus("Nada que deshacer")
		return
	end
	table.insert(redoStack, deepCopyPoints())
	local snap = table.remove(undoStack)
	applySnapshot(snap)
	setStatus("Deshecho")
end

local function doRedo()
	if #redoStack == 0 then
		setStatus("Nada que rehacer")
		return
	end
	table.insert(undoStack, deepCopyPoints())
	local snap = table.remove(redoStack)
	applySnapshot(snap)
	setStatus("Rehecho")
end

-- ==========================================
-- TAB GRABAR
-- ==========================================
local g = pages.Grabar
local secG1 = section(g, "Grabación", 1)
local countLabel = makeLabel(secG1, "Puntos: 0", 1)
local recBtn = makeBtn(secG1, "Grabar punto (G)", 2, Color3.fromRGB(40, 110, 60))
local undoBtn = makeBtn(secG1, "Deshacer", 3, Color3.fromRGB(90, 70, 40))
local redoBtn = makeBtn(secG1, "Rehacer", 4, Color3.fromRGB(70, 70, 100))
local remLastBtn = makeBtn(secG1, "Borrar último", 5, Color3.fromRGB(100, 45, 45))
local clearBtn = makeBtn(secG1, "Limpiar todo", 6, Color3.fromRGB(80, 30, 30))

local secG2 = section(g, "Modos del punto (Normal / Fast / Super)", 2)
makeLabel(secG2, "Activa en qué velocidades de farm debe usarse este CF", 1)

local modeNBtn = makeBtn(secG2, "Normal: ON", 2, Color3.fromRGB(40, 110, 60))
local modeFBtn = makeBtn(secG2, "Fast: ON", 3, Color3.fromRGB(40, 110, 60))
local modeSBtn = makeBtn(secG2, "Super: ON", 4, Color3.fromRGB(40, 110, 60))

local function paintModeBtn(btn, on, label)
	btn.Text = label .. (on and ": ON" or ": OFF")
	btn.BackgroundColor3 = on and Color3.fromRGB(40, 110, 60) or Color3.fromRGB(36, 36, 48)
	btn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
end

local function refreshModeBtns()
	-- UI principal
	if modeNBtn then paintModeBtn(modeNBtn, currentModes.normal, "Normal") end
	if modeFBtn then paintModeBtn(modeFBtn, currentModes.fast, "Fast") end
	if modeSBtn then paintModeBtn(modeSBtn, currentModes.super, "Super") e