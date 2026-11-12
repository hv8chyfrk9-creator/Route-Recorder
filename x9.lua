	if qModeF and qModeF.Parent then paintModeBtn(qModeF, currentModes.fast, "F") end
	if qModeS and qModeS.Parent then paintModeBtn(qModeS, currentModes.super, "S") end
end

modeNBtn.MouseButton1Click:Connect(function()
	currentModes.normal = not currentModes.normal
	if not (currentModes.normal or currentModes.fast or currentModes.super) then
		currentModes.normal = true
	end
	refreshModeBtns()
end)
modeFBtn.MouseButton1Click:Connect(function()
	currentModes.fast = not currentModes.fast
	if not (currentModes.normal or currentModes.fast or currentModes.super) then
		currentModes.fast = true
	end
	refreshModeBtns()
end)
modeSBtn.MouseButton1Click:Connect(function()
	currentModes.super = not currentModes.super
	if not (currentModes.normal or currentModes.fast or currentModes.super) then
		currentModes.super = true
	end
	refreshModeBtns()
end)

local assignModesBtn = makeBtn(secG2, "Aplicar modos al CF del indice", 5, Color3.fromRGB(55, 70, 100))
assignModesBtn.MouseButton1Click:Connect(function()
	local n = tonumber(idxBox.Text)
	if not n or not points[n] then setStatus("Indice invalido") return end
	pushUndo()
	points[n].modes = modesCopy(currentModes)
	refreshLabels()
	refreshPointList()
	rebuildLines()
	setStatus("CF " .. n .. " modos -> " .. modesLabel(points[n].modes))
end)

-- Editor de modos por CFrame (On/Off individual)
makeLabel(secG2, "Editar modos de un CF por numero", 6)
local editModeIdx = makeBox(secG2, "Numero de CFrame", 7, "1")
local editNBtn = makeBtn(secG2, "CF N: -", 8, Color3.fromRGB(36, 36, 48))
local editFBtn = makeBtn(secG2, "CF F: -", 9, Color3.fromRGB(36, 36, 48))
local editSBtn = makeBtn(secG2, "CF S: -", 10, Color3.fromRGB(36, 36, 48))

local function refreshEditModeBtns()
	local n = tonumber(editModeIdx.Text)
	local p = n and points[n]
	if not p then
		editNBtn.Text, editFBtn.Text, editSBtn.Text = "CF N: -", "CF F: -", "CF S: -"
		editNBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
		editFBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
		editSBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
		return
	end
	local m = p.modes or { normal = true, fast = true, super = true }
	paintModeBtn(editNBtn, m.normal, "CF N")
	paintModeBtn(editFBtn, m.fast, "CF F")
	paintModeBtn(editSBtn, m.super, "CF S")
end

local function togglePointMode(key)
	local n = tonumber(editModeIdx.Text)
	if not n or not points[n] then setStatus("Indice invalido") return end
	pushUndo()
	local m = modesCopy(points[n].modes)
	m[key] = not m[key]
	if not (m.normal or m.fast or m.super) then
		m[key] = true -- no dejar sin modos
	end
	points[n].modes = m
	refreshLabels()
	refreshPointList()
	rebuildLines()
	refreshEditModeBtns()
	setStatus("CF " .. n .. " -> " .. mode