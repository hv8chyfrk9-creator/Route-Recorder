nd
	-- Panel flotante (misma fuente de verdad: currentModes)
	if qModeN and qModeN.Parent then paintModeBtn(qModeN, currentModes.normal, "N") end
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

local assignModesBtn = makeBtn(secG2, "Aplicar modos al CF del índice", 5, Color3.fromRGB(55, 70, 100))
assignModesBtn.MouseButton1Click:Connect(function()
	local n = tonumber(idxBox.Text)
	if not n or not points[n] then setStatus("Índice inválido") return end
	pushUndo()
	points[n].modes = modesCopy(currentModes)
	refreshLabels()
	refreshPointList()
	rebuildLines()
	setStatus("CF " .. n .. " modos → " .. modesLabel(points[n].modes))
end)

-- Editor de modos por CFrame (On/Off individual)
makeLabel(secG2, "Editar modos de un CF por número", 6)
local editModeIdx = makeBox(secG2, "Número de CFrame", 7, "1")
local editNBtn = makeBtn(secG2, "CF N: —", 8, Color3.fromRGB(36, 36, 48))
local editFBtn = makeBtn(secG2, "CF F: —", 9, Color3.fromRGB(36, 36, 48))
local editSBtn = makeBtn(secG2, "CF S: —", 10, Color3.fromRGB(36, 36, 48))

local function refreshEditModeBtns()
	local n = tonumber(editModeIdx.Text)
	local p = n and points[n]
	if not p then
		editNBtn.Text, editFBtn.Text, editSBtn.Text = "CF N: —", "CF F: —", "CF S: —"
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
	if not n or not points[n] then setStatus("Índice inválido") return end
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
	setStatus("CF " .. n .. " → " .. modesLabel(m))
end

editModeIdx.FocusLost:Connect(refreshEditModeBtns)
editNBtn.MouseButton1Click:Connect(function() togglePointMode("normal") end)
editFBtn.MouseButton1Click:Connect(function() togglePointMode("fast") end)
editSBtn.MouseButton1Click:Connect(function() togglePointMode("super") end)

makeLabel(secG2, "Tipo extra (plant/wait/jump) — opcional", 11)
local kindBtn = makeBtn(secG2, "Tipo: normal", 12, Color3.fromRGB(40, 100, 55))
local waitBox = makeBox(secG2, "Segundos si wait (0.25)", 13, "0.25")
kindBtn.MouseButton1Click:Connect(function()
	local order = { "normal", "plant", "wait", "jump" }
	local i = 1
	for k, v in ipairs(order) do if v == currentPointKind then i = k break end end
	currentPointKind = order[(i % #order) + 1]
	kindBtn.Text = "Tipo: " .. currentPointKind
	kindBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 55)
	if currentPointKind == "plant" then kindBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 30) end
	if currentPointKind == "wait" then kindBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 140) end
	if currentPointKind == "jump" then kindBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 140) end
end)
waitBox.FocusLost:Connect(function()
	currentWaitSec = tonumber(waitBox.Text) or 0.25
end)

local secG3 = section(g, "Auto / ejes fijos / relativo", 3)
local autoBox = makeBox(secG3, "Auto cada X studs", 1, "10")
local autoBtn = makeBtn(secG3, "Auto studs: OFF", 2, Color3.fromRGB(36, 36, 48))
local timedBtn = makeBtn(secG3, "Grabar cada 0.5s: OFF", 3, Color3.fromRGB(36, 36, 48))
local fixedYBtn = makeBtn(secG3, "Y fija: OFF", 4, Color3.fromRGB(36, 36, 48))
local fixedXBtn = makeBtn(secG3, "X fija: OFF", 5, Color3.fromRGB(36, 36, 48))
local relFront = makeBox(secG3, "Enfrente", 6, "5")
local relSide = makeBox(secG3, "Lado (+der/-izq)", 7, "0")
local relUp = makeBox(secG3, "Arriba", 8, "0")
local addRelBtn = makeBtn(secG3, "Añadir relativo", 9, Color3.fromRGB(45, 75, 120))

local secG4 = section(g, "Panel flotante rápido", 4)
local floatPanelBtn = makeBtn(secG4, "Panel flotante: OFF", 1, Color3.fromRGB(36, 36, 48))
local autoSaveBox = makeBox(secG4, "Auto-guardar cada N puntos (0=off)", 2, "5")
autoSaveBox.FocusLost:Connect(function()
	autoSaveEvery = math.max(0, tonumber(autoSaveBox.Text) or 5)
end)

-- ==========================================
-- TAB RUTA
-- ==========================================
local r = pages.Ruta
local secR1 = section(r, "Navegar / editar", 1)
local idxBox = makeBox(secR1, "Número de CFrame", 1, "1")
local goBtn = makeBtn(secR1, "TP a ese CFrame", 2, Color3.fromRGB(50, 85, 130))
local updateBtn = makeBtn(secR1, "Actualizar ese CF a mi posición", 3, Color3.fromRGB(55, 90, 70))
local delIdxBtn = makeBtn(secR1, "Borrar ese CFrame", 4, Color3.fromRGB(110, 50, 50))
local insertBtn = makeBtn(secR1, "Insertar aquí en índice", 5, Color3.fromRGB(55, 70, 100))

local secR2 = section(r, "Rellenar / suavizar", 2)
local fillFrom = makeBox(secR2, "Desde índice", 1, "1")
local fillTo = makeBox(secR2, "Hasta índice", 2, "2")
local fillStep = makeBox(secR2, "Cada X studs", 3, "8")
local fillBtn = makeBtn(secR2, "Rellenar entre dos", 4, Color3.fromRGB(50, 90, 110))
local smoothDist = makeBox(secR2, "Quitar si más cerca de X studs", 5, "2")
local smoothBtn = makeBtn(secR2, "Suavizar ruta", 6, Color3.fromRGB(70, 70, 40))

local secR3 = section(r, "Lista de puntos", 3)
listFrame = Instance.new("Frame")
listFrame.Parent = secR3
listFrame.BackgroundTransparency = 1
listFrame.Size = UDim2.new(1, 0, 0, 0)
listFrame.AutomaticSize = Enum.AutomaticSize.Y
listFrame.LayoutOrder = 1
local listLay = Instance.new("UIListLayout")
listLay.Parent = listFrame
listLay.Padding = UDim.new(0, 4)
listLay.SortOrder = Enum.SortOrder.LayoutOrder

function refreshPointList()
	countLabel.Text = "Puntos: " .. tostring(#points)
	for _, c in ipairs(listFrame:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	if #points == 0 then
		makeLabel(listFrame, "(vacío)", 1)
		return
	end
	for i, p in ipairs(points) do
		local b = Instance.new("TextButton")
		b.Parent = listFrame
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		b.Size = UDim2.new(1, 0, 0, 30)
		b.Font = Enum.Font.Gotham
		b.TextXAlignment = Enum.TextXAlignment.Left
		local pos = p.cf.Position
		b.Text = string.format("  %d  %s %s  (%.0f, %.0f, %.0f)", i, modesLabel(p.modes), p.kind or "normal", pos.X, pos.Y, pos.Z)
		b.TextColor3 = Color3.fromRGB(230, 230, 240)
		b.TextSize = 11
		b.LayoutOrder = i
		corner(b, 6)
		b.MouseButton1Click:Connect(function()
			idxBox.Text = tostring(i)
			local root = hrp()
			if root then
				root.CFrame = p.cf
				root.AssemblyLinearVelocity = Vector3.new()
			end
			setStatus("TP lista → CF " .. i)
		end)
	end
end

-- ==========================================
-- TAB WINS + CLEANUP
-- ==========================================
local w = pages.Wins
local secW1 = section(w, "WinBlocks (ej: 1 +1   o   10 +50K)", 1)
local winBox = makeBox(secW1, "numero +wins  →  10 +50K", 1, "")
local winAddBtn = makeBtn(secW1, "Registrar WinBlock cercano", 2, Color3.fromRGB(40, 100, 60))
local winClearBtn = makeBtn(secW1, "Limpiar lista WinBlocks", 3, Color3.fromRGB(90, 40, 40))
local winListLabel = makeLabel(secW1, "Ninguno", 4)

local function refreshWinLabel()
	if #winBlocks == 0 then
		winListLabel.Text = "Ninguno"
		return
	end
	local parts = {}
	for _, wb in ipairs(winBlocks) do
		table.insert(parts, wb.real .. " = " .. wb.display)
	end
	winListLabel.Text = table.concat(parts, " | ")
	winListLabel.TextWrapped = true
	winListLabel.Size = UDim2.new(1, 0, 0, 40)
end

local function findNearestWinBlock(num)
	local root = hrp()
	if not root then return nil end
	local want = "WinBlock" .. tostring(num)
	local best, bestDist = nil, math.huge
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == want or (string.sub(obj.Name, 1, 8) == "WinBlock" and obj.Name == want) then
			local pos
			if obj:IsA("BasePart") then
				pos = obj.Position
			elseif obj:IsA("Model") then
				pos = obj:GetPivot().Position
			else
				local ok, pivot = pcall(function() return obj:GetPivot() end)
				if ok and pivot then pos = pivot.Position end
			end
			if pos then
				local d = (pos - root.Position).Magnitude
				if d < bestDist then
					bestDist = d
					best = obj
				end
			end
		end
	end
	-- fallback: any name starting WinBlock + number
	if not best then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if string.sub(obj.Name, 1, 8) == "WinBlock" then
				local n = tonumber(string.match(obj.Name, "%d+"))
				if n == num then
					best = obj
					break
				end
			end
		end
	end
	return best, bestDist
end

winAddBtn.MouseButton1Click:Connect(function()
	local text = winBox.Text or ""
	local num, rest = string.match(text, "^%s*(%d+)%s+(.+)%s*$")
	if not num then
		num = string.match(text, "^%s*(%d+)%s*$")
		rest = "+" .. tostring(num) .. " Win"
	end
	if not num then
		setStatus("Formato: 1 +1  o  10 +50K")
		return
	end
	num = tonumber(num)
	local display = rest or ("+" .. num)
	-- normalize display
	if not string.find(display, "Win") then
		display = display .. " Wins"
	end
	local obj, dist = findNearestWinBlock(num)
	local real = "WinBlock" .. tostring(num)
	if obj then real = obj.Name end
	-- replace if same order exists
	local found = false
	for i, wb in ipairs(winBlocks) do
		if wb.order == num then
			winBlocks[i] = { real = real, display = display, order = num }
			found = true
			break
		end
	end
	if not found then
		table.insert(winBlocks, { real = real, display = display, order = num })
		table.sort(winBlocks, function(a, b) return a.order < b.order end)
	end
	refreshWinLabel()
	setStatus(string.format("%s → %s%s", real, display, obj and string.format(" (%.0f studs