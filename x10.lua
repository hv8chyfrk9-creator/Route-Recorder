sLabel(m))
end

editModeIdx.FocusLost:Connect(refreshEditModeBtns)
editNBtn.MouseButton1Click:Connect(function() togglePointMode("normal") end)
editFBtn.MouseButton1Click:Connect(function() togglePointMode("fast") end)
editSBtn.MouseButton1Click:Connect(function() togglePointMode("super") end)

makeLabel(secG2, "Tipo extra (plant/wait/jump) - opcional", 11)
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
local addRelBtn = makeBtn(secG3, "Anadir relativo", 9, Color3.fromRGB(45, 75, 120))

local secG4 = section(g, "Panel flotante rapido", 4)
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
local idxBox = makeBox(secR1, "Numero de CFrame", 1, "1")
local goBtn = makeBtn(secR1, "TP a ese CFrame", 2, Color3.fromRGB(50, 85, 130))
local updateBtn = makeBtn(secR1, "Actualizar ese CF a mi posicion", 3, Color3.fromRGB(55, 90, 70))
local delIdxBtn = makeBtn(secR1, "Borrar 