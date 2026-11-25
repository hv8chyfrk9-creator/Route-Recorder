 not lastRecordPos then lastRecordPos = root.Position
		elseif (root.Position - lastRecordPos).Magnitude >= (tonumber(autoBox.Text) or autoStuds) then
			addPoint(root.CFrame)
		end
	end
	-- Auto por tiempo (0.5s) con los modos seleccionados
	if timedRecord then
		local now = tick()
		if now - (lastTimedRecord or 0) >= (timedRecordEvery or 0.5) then
			lastTimedRecord = now
			addPoint(root.CFrame, nil, currentPointKind, currentWaitSec, false, currentModes)
		end
	end
end)

addRelBtn.MouseButton1Click:Connect(function()
	local root = hrp()
	if not root then setStatus("Sin personaje") return end
	local front = tonumber(relFront.Text) or 0
	local side = tonumber(relSide.Text) or 0
	local up = tonumber(relUp.Text) or 0
	addPoint(root.CFrame * CFrame.new(side, up, -front))
end)

goBtn.MouseButton1Click:Connect(function()
	local n = tonumber(idxBox.Text)
	if not n or not points[n] then setStatus("Índice inválido") return end
	local root = hrp()
	if not root then return end
	root.CFrame = points[n].cf
	root.AssemblyLinearVelocity = Vector3.new()
	setStatus("TP a CF " .. n)
end)

updateBtn.MouseButton1Click:Connect(function()
	local n = tonumber(idxBox.Text)
	local root = hrp()
	if not n or not points[n] or not root then setStatus("Índice inválido") return end
	pushUndo()
	-- Actualizar usa la posición real del jugador (Y/X fija no aplica a CFs ya existentes)
	local cf = root.CFrame
	points[n].cf = cf
	if points[n].marker then points[n].marker.CFrame = cf end
	rebuildLines()
	refreshPointList()
	setStatus("CF " .. n .. " actualizado")
end)

delIdxBtn.MouseButton1Click:Connect(function()
	local n = tonumber(idxBox.Text)
	if n then removeAt(n) end
end)

insertBtn.MouseButton1Click:Connect(function()
	local root = hrp()
	if not root then return end
	local n = tonumber(idxBox.Text) or (#points + 1)
	addPoint(root.CFrame, n)
end)

fillBtn.MouseButton1Click:Connect(function()
	local a = tonumber(fillFrom.Text)
	local b = tonumber(fillTo.Text)
	local step = tonumber(fillStep.Text) or 8
	if not a or not b or not points[a] or not points[b] or a >= b then
		setStatus("Índices inválidos")
		return
	end
	pushUndo()
	local fromPos = points[a].cf.Position
	local toPos = points[b].cf.Position
	local dist = (toPos - fromPos).Magnitude
	if dist < step * 2 then setStatus("Muy cerca para rellenar") return end
	local dir = (toPos - fromPos).Unit
	local insertAt = a + 1
	local t = step
	local added = 0
	while t < dist - step * 0.5 do
		local pos = fromPos + dir * t
		local cf = CFrame.new(pos)
		-- approximate look along path
		cf = CFrame.lookAt(pos, pos + dir)
		table.insert(points, insertAt, { cf = cf, kind = "normal", waitSec = 0 })
		local ball = Instance.new("Part")
		ball.Shape = Enum.PartType.Ball
		ball.Size = Vector3.new(1.2, 1.2, 1.2)
		ball.Anchored = true
		ball.CanCollide = false
		ball.CanTouch = false
		ball.CanQuery = false
		ball.Material = Enum.Material.Neon
		ball.Color = kindColor.normal
		ball.Transparency = 0.2
		ball.CFrame = cf
		ball.Parent = folder
		points[insertAt].marker = ball
		insertAt = insertAt + 1
		added = added + 1
		t = t + step
	end
	refreshLabels()
	rebuildLines()
	refreshPointList()
	setStatus("Rellenados " .. added .. " puntos")
end)

smoothBtn.MouseButton1Click:Connect(function()
	local minD = tonumber(smoothDist.Text) or 2
	if #points < 3 then setStatus("Muy pocos puntos") return end
	pushUndo()
	local kept = { points[1] }
	for i = 2, #points - 1 do
		local prev = kept[#kept].cf.Position
		local cur = points[i].cf.Position
		if (cur - prev).Magnitude >= minD then
			table.insert(kept, points[i])
		else
			clearVisualsFor(i)
		end
	end
	table.insert(kept, points[#points])
	-- rebuild markers for kept that lost index
	points = kept
	for i, p in ipairs(points) do
		if p.marker and p.marker.Parent then
			p.marker.Name = "CF_" .. i
			p.marker.CFrame = p.cf
		else
			local ball = Instance.new("Part")
			ball.Shape = Enum.PartType.Ball
			ball.Size = Vector3.new(1.4, 1.4, 1.4)
			ball.Anchored = true
			ball.CanCollide = false
			ball.CanTouch = false
			ball.CanQuery = false
			ball.Material = Enum.Material.Neon
			ball.Color = kindColor[p.kind or "normal"]
			ball.Transparency = 0.15
			ball.CFrame = p.cf
			ball.Parent = folder
			p.marker = ball
		end
	end
	refreshLabels()
	rebuildLines()
	refreshPointList()
	setStatus("Suavizado → " .. #points .. " puntos")
end)

-- Preview relativo
RunService.RenderStepped:Connect(function()
	local root = hrp()
	if not root then
		if previewMarker then previewMarker.Transparency = 1 end
		return
	end
	local front = tonumber(relFront.Text) or 0
	local side = tonumber(relSide.Text) or 0
	local up = tonumber(relUp.Text) or 0
	local cf = root.CFrame * CFrame.new(side, up, -front)
	if not previewMarker or not previewMarker.Parent then
		previewMarker = Instance.new("Part")
		previewMarker.Name = "PreviewPoint"
		previewMarker.Shape = Enum.PartType.Ball
		previewMarker.Size = Vector3.new(1.1, 1.1, 1.1)
		previewMarker.Anchored = true
		previewMarker.CanCollide = false
		previewMarker.CanTouch = false
		previewMarker.CanQuery = false
		previewMarker.Material = Enum.Material.Neon
		previewMarker.Color = Color3.fromRGB(80, 160, 255)
		previewMarker.Parent = folder
	end
	previewMarker.CFrame = cf
	previewMarker.Transparency = 0.4
end)

-- ==========================================
-- PANEL FLOTANTE RÁPIDO (idea 25)
-- ==========================================
local Quick = Instance.new("Frame")
Quick.Name = "QuickPanel"
Quick.Parent = ScreenGui
Quick.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Quick.Position = UDim2.new(1, -170, 0.35, 0)
Quick.Size = UDim2.new(0, 150, 0, 360)
Quick.Visible = false
Quick.Active = true
Quick.Draggable = true
corner(Quick, 10)
local qStroke = Instance.new("UIStroke")
qStroke.Color = Color3.fromRGB(50, 50, 70)
qStroke.Parent = Quick

local qTop = Instance.new("Frame")
qTop.Parent = Quick
qTop.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
qTop.Size = UDim2.new(1, 0, 0, 28)
corner(qTop, 10)
local qTitle = Instance.new("TextLabel")
qTitle.Parent = qTop
qTitle.BackgroundTransparency = 1
qTitle.Size = UDim2.new(1, -28, 1, 0)
qTitle.Position = UDim2.new(0, 8, 0, 0)
qTitle.Font = Enum.Font.GothamBold
qTitle.Text = "Grabar"
qTitle.TextColor3 = Color3.fromRGB(240, 240, 250)
qTitle.TextSize = 12
qTitle.TextXAlignment = Enum.TextXAlignment.Left
local qMin = Instance.new("TextButton")
qMin.Parent = qTop
qMin.BackgroundTransparency = 1
qMin.Position = UDim2.new(1, -28, 0, 0)
qMin.Size = UDim2.new(0, 28, 1, 0)
qMin.Text = "—"
qMin.TextColor3 = Color3.fromRGB(180, 180, 195)
qMin.Font = Enum.Font.GothamBold
qMin.TextSize = 14

local qBody = Instance.new("Frame")
qBody.Parent = Quick
qBody.BackgroundTransparency = 1
qBody.Position = UDim2.new(0, 6, 0, 32)
qBody.Size = UDim2.new(1, -12, 1, -38)
local qLay = Instance.new("UIListLayout")
qLay.Parent = qBody
qLay.Padding = UDim.new(0, 5)
qLay.SortOrder = Enum.SortOrder.LayoutOrder

local function qBtn(text, order, color)
	local b = Instance.new("TextButton")
	b.Parent = qBody
	b.BackgroundColor3 = color or Color3.fromRGB(36, 36, 48)
	b.Size = UDim2.new(1, 0, 0, 30)
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 11
	b.LayoutOrder = order
	corner(b, 6)
	return b
end

local qRec = qBtn("Grabar", 1, Color3.fromRGB(40, 110, 60))
qModeN = qBtn("N: ON", 2, Color3.fromRGB(40, 110, 60))
qModeF = qBtn("F: ON", 3, Color3.fromRGB(40, 110, 60))
qModeS = qBtn("S: ON", 4, Color3.fromRGB(40, 110, 60))
local qUndo = qBtn("Deshacer", 5, Color3.fromRGB(90, 70, 40))
local qTest = qBtn("Probar/Parar", 6, Color3.fromRGB(50, 100, 55))
local qTp = qBtn("TP a índice", 7, Color3.fromRGB(50, 85, 130))
local qLast = qBtn("TP último CF", 8, Color3.fromRGB(70, 100, 50))
local qIdx = Instance.new("TextBox")
qIdx.Parent = qBody
qIdx.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
qIdx.Size = UDim2.new(1, 0, 0, 28)
qIdx.Font = Enum.Font.Gotham
qIdx.PlaceholderText = "Índice CF"
qIdx.Text = "1"
qIdx.TextColor3 = Color3.fromRGB(255, 255, 255)
qIdx.TextSize = 11
qIdx.LayoutOrder = 9
qIdx.ClearTextOnFocus = false
corner(qIdx, 6)
local qCount = Instance.new("TextLabel")
qCount.Parent = qBody
qCount.BackgroundTransparency = 1
qCount.Size = UDim2.new(1, 0, 0, 18)
qCount.Font = Enum.Font.Gotham
qCount.Text = "Puntos: 0"
qCount.TextColor3 = Color3.fromRGB(170, 170, 185)
qCount.TextSize = 11
qCount.LayoutOrder = 10

local quickVisible = false
local quickMinimized = false
floatPanelBtn.MouseButton1Click:Connect(function()
	quickVisible = not quickVisible
	Quick.Visible = quickVisible
	floatPanelBtn.Text = quickVisible and "Panel flotante: ON" or "Panel flotante: OFF"
	floatPanelBtn.BackgroundColor3 = quickVisible and Color3.fromRGB(40, 110, 60) or Color3.fromRGB(36, 36, 48)
	if quickVisible then refreshModeBtns() end
end)

qMin.MouseButton1Click:Connect(function()
	quickMinimized = not quickMinimized
	if quickMinimized then
		Quick.Size = UDim2.new(0, 150, 0, 28)
		qBody.Visible = false
		qMin.Text = "+"
	else
		Quick.Size = UDim2.new(0, 150, 0, 360)
		qBody.Visible = true
		qMin.Text = "—"
	end
end)

qRec.MouseButton1Click:Connect(recordHere)
local function toggleCurrentMode(key)
	currentModes[key] = not currentModes[key]
	if not (currentModes.normal or currentModes.fast or currentModes.super) then
		currentModes[key] = true
	end
	refreshModeBtns()
end
qModeN.MouseButton1Click:Connect(function() toggleCurrentMode("normal") end)
qModeF.MouseButton1Click:Connect(function() toggleCurrentMode("fast") end)
qModeS.MouseButton1Click:Connect(function() toggleCurrentMode("super") end)
-- sincroniza visual al abrir
refreshModeBtns()

qUndo.MouseButton1Click:Connect(doUndo)
qTest.MouseButton1Click:Connect(function() runRoute(nil) end)
qTp.MouseButton1Click:Connect(function()
	local n = tonumber(qIdx.Text)
	if not n or not points[n] then setStatus("Índice inválido") return end
	local root = hrp()
	if root then
		root.CFrame = points[n].cf
		root.AssemblyLinearVelocity = Vector3.new()
	end
end)

qLast.MouseButton1Click:Connect(function()
	if #points == 0 then setStatus("No hay puntos") return end
	local root = hrp()
	if root then
		root.CFrame = points[#points].cf
		root.AssemblyLinearVelocity = Vector3.new()
		setStatus("TP al último CF (#" .. #points .. ")")
	end
end)

-- keep quick count updated
task.spawn(function()
	while ScreenGui.Parent do
		qCount.Text = "Puntos: " .. tostring(#points)
		task.wait(0.4)
	end
end)

refreshPointList()
setStatus("Listo - PlaceId " .. tostring(PLACE_ID) .. " - G = grabar")
print("[Route Recorder v2.2] OK - PlaceId " .. tostring(PLACE_ID))
