)", dist or 0) or " (no hallado, nombre forzado)"))
end)

winClearBtn.MouseButton1Click:Connect(function()
	winBlocks = {}
	refreshWinLabel()
	setStatus("WinBlocks limpios")
end)

local secW2 = section(w, "Limpieza al inicio (export)", 2)
makeLabel(secW2, "Exactos separados por coma", 1)
local cleanExactBox = makeBox(secW2, "TarantulaS13,WindZonesS14,Lava_Stage15", 2, "TarantulaS13,WindZonesS14,Lava_Stage15")
makeLabel(secW2, "Prefijos (Pair = todo Pair*)", 3)
local cleanPrefixBox = makeBox(secW2, "Pair", 4, "Pair")
local cleanApplyBtn = makeBtn(secW2, "Aplicar listas cleanup", 5, Color3.fromRGB(50, 80, 100))
cleanApplyBtn.MouseButton1Click:Connect(function()
	cleanupExact = {}
	for part in string.gmatch(cleanExactBox.Text or "", "[^,]+") do
		part = string.gsub(part, "^%s*(.-)%s*$", "%1")
		if part ~= "" then table.insert(cleanupExact, part) end
	end
	cleanupPrefix = {}
	for part in string.gmatch(cleanPrefixBox.Text or "", "[^,]+") do
		part = string.gsub(part, "^%s*(.-)%s*$", "%1")
		if part ~= "" then table.insert(cleanupPrefix, part) end
	end
	setStatus("Cleanup actualizado")
end)

-- ==========================================
-- TAB PROBAR
-- ==========================================
local ptab = pages.Probar
local secP1 = section(ptab, "Prueba de ruta", 1)
local speedBox = makeBox(secP1, "Velocidad (50-500)", 1, "220")
local modeBtn = makeBtn(secP1, "Modo: Normal (min 0)", 2, Color3.fromRGB(40, 100, 55))
local noclipBtn = makeBtn(secP1, "Noclip prueba: OFF", 3, Color3.fromRGB(36, 36, 48))
local testAllBtn = makeBtn(secP1, "Probar / Terminar recorrido", 4, Color3.fromRGB(50, 100, 55))
local stopAtBtn = makeBtn(secP1, "Probar hasta índice", 5, Color3.fromRGB(90, 80, 40))
local simDeathBtn = makeBtn(secP1, "Simular muerte (para prueba)", 6, Color3.fromRGB(120, 50, 50))

modeBtn.MouseButton1Click:Connect(function()
	if testMode == "normal" then
		testMode = "fast"
		modeBtn.Text = "Modo: Rapido (min 50)"
	elseif testMode == "fast" then
		testMode = "ultra"
		modeBtn.Text = "Modo: Super (min 150)"
	else
		testMode = "normal"
		modeBtn.Text = "Modo: Normal (min 0)"
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipTest = not noclipTest
	noclipBtn.Text = noclipTest and "Noclip prueba: ON" or "Noclip prueba: OFF"
	noclipBtn.BackgroundColor3 = noclipTest and Color3.fromRGB(40, 110, 60) or Color3.fromRGB(36, 36, 48)
end)

local function approachSpeed(distance, maxSpeed)
	maxSpeed = maxSpeed or 220
	local brake, floorSpeed = 18, 0
	if testMode == "fast" then brake, floorSpeed = 8, 50
	elseif testMode == "ultra" then brake, floorSpeed = 5, 150 end
	if distance >= brake then return maxSpeed end
	local t = math.clamp(distance / brake, 0, 1)
	return math.max(maxSpeed * t * t, floorSpeed)
end

local function stopTesting()
	testing = false
	local root = hrp()
	if root then
		root.AssemblyLinearVelocity = Vector3.new()
		local bv = root:FindFirstChild("DeltaRecBV")
		if bv then bv:Destroy() end
	end
	testAllBtn.Text = "Probar / Terminar recorrido"
	testAllBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 55)
	setStatus("Prueba detenida")
end

local function runRoute(limitIndex)
	if testing then
		stopTesting()
		return
	end
	if #points < 1 then
		setStatus("No hay puntos")
		return
	end
	testing = true
	testSpeed = math.clamp(tonumber(speedBox.Text) or 220, 50, 500)
	testAllBtn.Text = "Terminar recorrido"
	testAllBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
	setStatus(limitIndex and ("Probando hasta " .. limitIndex) or "Probando ruta")

	task.spawn(function()
		local root = hrp()
		local human = hum()
		if not root or not human then
			stopTesting()
			return
		end
		root.CFrame = points[1].cf
		root.AssemblyLinearVelocity = Vector3.new()
		task.wait(0.12)
		local bv = Instance.new("BodyVelocity")
		bv.Name = "DeltaRecBV"
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = Vector3.new()
		bv.Parent = root
		local last = limitIndex or #points
		for i = 2, last do
			if not testing then break end
			-- filtrar por modo de prueba (normal/fast/ultra)
			if not pointInMode(points[i], testMode) then
				continue
			end
			if noclipTest and player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
			local target = points[i].cf.Position
			local kind = points[i].kind or "normal"
			local reach = (kind == "plant") and 0.5 or 1.2
			while testing and root.Parent and human.Health > 0 do
				local dist = (root.Position - target).Magnitude
				if dist <= reach then break end
				local spd = approachSpeed(dist, testSpeed)
				if kind == "plant" and dist < 8 then spd = math.min(spd, 30) end
				bv.Velocity = (target - root.Position).Unit * spd
				RunService.Stepped:Wait()
			end
			if testing and root.Parent then
				bv.Velocity = Vector3.new()
				root.CFrame = points[i].cf
				root.AssemblyLinearVelocity = Vector3.new()
				if kind == "wait" then
					task.wait(points[i].waitSec or 0.25)
				elseif kind == "plant" then
					task.wait(0.15)
				else
					task.wait(0.04)
				end
			end
			if human.Health <= 0 then break end
		end
		if bv then bv:Destroy() end
		testing = false
		testAllBtn.Text = "Probar / Terminar recorrido"
		testAllBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 55)
		setStatus("Prueba terminada")
	end)
end

testAllBtn.MouseButton1Click:Connect(function() runRoute(nil) end)
stopAtBtn.MouseButton1Click:Connect(function()
	local n = tonumber(idxBox.Text)
	if not n then setStatus("Índice inválido") return end
	runRoute(math.min(n, #points))
end)

simDeathBtn.MouseButton1Click:Connect(function()
	local human = hum()
	if human then
		human.Health = 0
		setStatus("Muerte simulada")
	end
end)

-- ==========================================
-- TAB EXPORT + PRESETS
-- ==========================================
local e = pages.Export
local secE1 = section(e, "Exportar (clipboard en 4 partes)", 1)
local exportFromBox = makeBox(secE1, "Desde N", 1, "1")
local exportToBox = makeBox(secE1, "Hasta N (vacío=fin)", 2, "")
local exportBtn = makeBtn(secE1, "Export CFrames (pos) → archivo+clip", 3, Color3.fromRGB(75, 55, 120))
local exportFullBtn = makeBtn(secE1, "Export CFrames (rot) → archivo+clip", 4, Color3.fromRGB(70, 50, 110))
local exportMetaBtn = makeBtn(secE1, "Copiar WinBlocks + Cleanup", 5, Color3.fromRGB(60, 80, 100))
local exportAllBtn = makeBtn(secE1, "Export pack completo → archivo+clip", 6, Color3.fromRGB(50, 90, 70))

local secE2 = section(e, "Guardar / cargar / presets", 2)
local routeNameBox = makeBox(secE2, "Nombre ruta / preset", 1, "mi_ruta")
local saveBtn = makeBtn(secE2, "Guardar local", 2, Color3.fromRGB(40, 90, 70))
local loadBtn = makeBtn(secE2, "Cargar local", 3, Color3.fromRGB(40, 70, 100))
local presetBox = makeBox(secE2, "Preset mundo: Hallowen / Galaxia2 / Mundo3", 4, "Hallowen")
local savePresetBtn = makeBtn(secE2, "Guardar preset mundo", 5, Color3.fromRGB(50, 80, 60))
local loadPresetBtn = makeBtn(secE2, "Cargar preset mundo", 6, Color3.fromRGB(50, 70, 90))

local function copyText(out)
	local ok = pcall(function()
		if setclipboard then setclipboard(out)
		elseif toclipboard then toclipboard(out)
		else error("no clipboard") end
	end)
	return ok
end

local function buildCFrameLines(from, to, full)
	from = math.clamp(from or 1, 1, math.max(1, #points))
	to = math.clamp(to or #points, from, #points)
	local lines = {}
	for i = from, to do
		local cf = points[i].cf
		local kind = points[i].kind or "normal"
		local ml = modesLabel(points[i].modes)
		local comma = (i < to) and "," or ""
		local comment = string.format(" -- CFrame %d modes:%s", i, ml)
		if kind ~= "normal" then
			comment = comment .. " [" .. kind
			if kind == "wait" then comment = comment .. " " .. tostring(points[i].waitSec or 0) .. "s" end
			comment = comment .. "]"
		end
		if full then
			local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
			table.insert(lines, string.format(
				"\tCFrame.new(%.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f)%s%s",
				x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22, comma, comment
			))
		else
			local p = cf.Position
			table.insert(lines, string.format(
				"\tCFrame.new(%.6f, %.6f, %.6f)%s%s",
				p.X, p.Y, p.Z, comma, comment
			))
		end
	end
	return lines
end

-- Tabla paralela de modos para que el hub filtre (índice = CF)
local function buildModesTable(from, to)
	from = math.clamp(from or 1, 1, math.max(1, #points))
	to = math.clamp(to or #points, from, #points)
	local lines = { "local routeModes = {" }
	for i = from, to do
		local m = points[i].modes or { normal = true, fast = true, super = true }
		local comma = (i < to) and "," or ""
		table.insert(lines, string.format(
			"\t[%d] = { normal = %s, fast = %s, super = %s }%s -- CF %d",
			i,
			m.normal and "true" or "false",
			m.fast and "true" or "false",
			m.super and "true" or "false",
			comma,
			i
		))
	end
	table.insert(lines, "}")
	return lines
end

-- Construye el texto por partes (no traba el teléfono) y al final entrega TODO
-- 1) writefile completo  2) un solo setclipboard
local function exportBuildAndDeliver(lines, header, footer, fileName)
	fileName = fileName or "Route_Export.lua"
	task.spawn(function()
		if (not lines or #lines == 0) and not header and not footer then
			setStatus("Nada que exportar")
			return
		end

		local chunks = {}
		local function push(str)
			if str and str ~= "" then table.insert(chunks, str) end
		end

		setStatus("Export: preparando...")
		task.wait()

		if header then
			push(header)
			setStatus("Export: header listo")
			task.wait(0.05)
		end

		-- armar lineas en bloques de ~25 para no congelar
		local block = {}
		local total = #lines
		for i, line in ipairs(lines) do
			table.insert(block, line)
			if #block >= 25 or i == total then
				push(table.concat(block, "\n"))
				block = {}
				setStatus(string.format("Export: cargando lineas %d/%d", i, total))
				task.wait(0.03)
			end
		end

		if footer then
			-- footer puede ser grande (modes + meta): partirlo
			local footLines = {}
			for part in string.gmatch(footer .. "\n", "(.-)\n") do
				table.insert(footLines, part)
			end
			local fblock = {}
			for i, fl in ipairs(footLines) do
				table.insert(fblock, fl)
				if #fblock >= 30 or i == #footLines then
					push(table.concat(fblock, "\n"))
					fblock = {}
					setStatus(string.format("Export: footer %d/%d", i, #footLines))
					task.wait(0.03)
				end
			end
		end

		setStatus("Export: uniendo texto...")
		task.wait(0.05)
		local full = table.concat(chunks, "\n")

		-- 1) a