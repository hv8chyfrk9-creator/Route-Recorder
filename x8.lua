nd

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
local secG1 = section(g, "Grabacion", 1)
local countLabel = makeLabel(secG1, "Puntos: 0", 1)
local recBtn = makeBtn(secG1, "Grabar punto (G)", 2, Color3.fromRGB(40, 110, 60))
local undoBtn = makeBtn(secG1, "Deshacer", 3, Color3.fromRGB(90, 70, 40))
local redoBtn = makeBtn(secG1, "Rehacer", 4, Color3.fromRGB(70, 70, 100))
local remLastBtn = makeBtn(secG1, "Borrar ultimo", 5, Color3.fromRGB(100, 45, 45))
local clearBtn = makeBtn(secG1, "Limpiar todo", 6, Color3.fromRGB(80, 30, 30))

local secG2 = section(g, "Modos del punto (Normal / Fast / Super)", 2)
makeLabel(secG2, "Activa en que velocidades de farm debe usarse este CF", 1)

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
	if modeSBtn then paintModeBtn(modeSBtn, currentModes.super, "Super") end
	-- Panel flotante (misma fuente de verdad: currentModes)
	if qModeN and qModeN.Parent then paintModeBtn(qModeN, currentModes.normal, "N") end
