rchivo completo (mejor en móvil / Delta)
		local fileOk = pcall(function()
			if writefile then
				writefile(fileName, full)
			else
				error("no writefile")
			end
		end)

		-- 2) un solo clipboard con TODO
		local clipOk = copyText(full)

		if fileOk and clipOk then
			setStatus("Listo: archivo + clipboard (" .. fileName .. ")")
		elseif fileOk then
			setStatus("Listo en archivo: " .. fileName .. " (sin clipboard)")
		elseif clipOk then
			setStatus("Listo en clipboard (sin writefile)")
		else
			print(full)
			setStatus("Sin file/clipboard → mira la consola (print)")
		end
	end)
end

-- compat nombre viejo
local function exportInChunks(lines, header, footer)
	exportBuildAndDeliver(lines, header, footer, "Route_Export.lua")
end

exportBtn.MouseButton1Click:Connect(function()
	if #points == 0 then setStatus("Nada") return end
	local from = tonumber(exportFromBox.Text) or 1
	local to = tonumber(exportToBox.Text) or #points
	local lines = buildCFrameLines(from, to, false)
	exportInChunks(lines, "-- PlaceId: " .. tostring(PLACE_ID) .. "\nlocal routeCFrames = {", "}")
end)

exportFullBtn.MouseButton1Click:Connect(function()
	if #points == 0 then setStatus("Nada") return end
	local from = tonumber(exportFromBox.Text) or 1
	local to = tonumber(exportToBox.Text) or #points
	local lines = buildCFrameLines(from, to, true)
	exportInChunks(lines, "-- PlaceId: " .. tostring(PLACE_ID) .. "\nlocal routeCFrames = {", "}")
end)

local function buildMetaText()
	local lines = { "-- WinBlocks", "local orderedWinBlocks = {" }
	for i, wb in ipairs(winBlocks) do
		local comma = (i < #winBlocks) and "," or ""
		table.insert(lines, string.format(
			'\t{real = "%s", display = "%s", order = %d}%s',
			wb.real, wb.display, wb.order, comma
		))
	end
	table.insert(lines, "}")
	table.insert(lines, "")
	table.insert(lines, "-- Cleanup al inicio")
	table.insert(lines, "local targetNamesToDestroy = {")
	for i, n in ipairs(cleanupExact) do
		local comma = (i < #cleanupExact) and "," or ""
		table.insert(lines, string.format('\t"%s"%s', n, comma))
	end
	table.insert(lines, "}")
	table.insert(lines, "-- Prefijos:")
	for _, pref in ipairs(cleanupPrefix) do
		table.insert(lines, string.format('-- if string.sub(name, 1, %d) == "%s" then destroy end', #pref, pref))
	end
	return table.concat(lines, "\n")
end

exportMetaBtn.MouseButton1Click:Connect(function()
	local text = buildMetaText()
	if copyText(text) then setStatus("Meta copiada") else print(text) setStatus("Meta → consola") end
end)

exportAllBtn.MouseButton1Click:Connect(function()
	if #points == 0 then setStatus("Nada") return end
	local lines = buildCFrameLines(1, #points, true)
	local modeLines = buildModesTable(1, #points)
	local header = "-- PlaceId: " .. tostring(PLACE_ID) .. "\nlocal PLACE_ID = " .. tostring(PLACE_ID) .. "\nlocal routeCFrames = {"
	local footer = "}\n\n" .. table.concat(modeLines, "\n") .. "\n\n" .. buildMetaText()
	exportBuildAndDeliver(lines, header, footer, "Route_Full_Export_" .. tostring(PLACE_ID) .. ".lua")
end)

local exportModesBtn = makeBtn(secE1, "Copiar solo routeModes", 7, Color3.fromRGB(60, 70, 110))
exportModesBtn.MouseButton1Click:Connect(function()
	if #points == 0 then setStatus("Nada") return end
	local text = table.concat(buildModesTable(1, #points), "\n")
	if copyText(text) then setStatus("routeModes copiado") else print(text) setStatus("modes → consola") end
end)

local function packState()
	-- Estructura 100% objetos (sin tablas mixtas) para que JSONEncode no pierda modes/kind
	local data = {}
	for i, p in ipairs(points) do
		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = p.cf:GetComponents()
		local m = modesCopy(p.modes)
		data[i] = {
			c = { x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 },
			kind = p.kind or "normal",
			waitSec = tonumber(p.waitSec) or 0,
			modes = {
				normal = m.normal and true or false,
				fast = m.fast and true or false,
				super = m.super and true or false,
			},
		}
	end
	local wbs = {}
	for i, w in ipairs(winBlocks) do
		wbs[i] = {
			real = tostring(w.real or ""),
			display = tostring(w.display or ""),
			order = tonumber(w.order) or i,
		}
	end
	return {
		v = 2,
		points = data,
		winBlocks = wbs,
		cleanupExact = cleanupExact,
		cleanupPrefix = cleanupPrefix,
	}
end

local function loadState(pack)
	clearAll()
	winBlocks = pack.winBlocks or {}
	cleanupExact = pack.cleanupExact or cleanupExact
	cleanupPrefix = pack.cleanupPrefix or cleanupPrefix
	if cleanExactBox then cleanExactBox.Text = table.concat(cleanupExact, ",") end
	if cleanPrefixBox then cleanPrefixBox.Text = table.concat(cleanupPrefix, ",") end
	for _, t in ipairs(pack.points or {}) do
		local cf = nil
		if type(t) == "table" then
			if type(t.c) == "table" and t.c[1] then
				local c = t.c
				cf = CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
			elseif t[1] then
				cf = CFrame.new(t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12])
			end
		end
		if cf then
			local modes = t.modes
			if type(modes) ~= "table" then
				modes = { normal = true, fast = true, super = true }
			else
				modes = {
					normal = modes.normal and true or false,
					fast = modes.fast and true or false,
					super = modes.super and true or false,
				}
				if not (modes.normal or modes.fast or modes.super) then
					modes.normal = true
				end
			end
			addPoint(cf, nil, t.kind or "normal", t.waitSec or 0, true, modes)
		end
	end
	refreshWinLabel()
	refreshPointList()
	rebuildLines()
end

saveBtn.MouseButton1Click:Connect(function()
	if #points == 0 then setStatus("Nada que guardar") return end
	local name = routeNameBox.Text
	if name == "" then name = "mi_ruta" end
	setStatus("Guardando...")
	task.spawn(function()
		local ok, err = pcall(function()
			local pack = packState()
			local all = {}
			if isfile and isfile(saveFile) then
				local okR, decoded = pcall(function() return HttpService:JSONDecode(readfile(saveFile)) end)
				if okR and type(decoded) == "table" then all = decoded end
			end
			all[name] = pack
			local encoded = HttpService:JSONEncode(all)
			writefile(saveFile, encoded)
		end)
		if ok then
			setStatus("Guardado: " .. name .. " (" .. #points .. " CF)")
		else
			setStatus("Error al guardar")
			warn("[RouteRecorder] save:", err)
		end
	end)
end)

loadBtn.MouseButton1Click:Connect(function()
	local name = routeNameBox.Text
	if name == "" then setStatus("Pon nombre") return end
	local ok, err = pcall(function()
		if not (isfile and isfile(saveFile)) then error("no file") end
		local all = HttpService:JSONDecode(readfile(saveFile))
		local pack = all[name]
		if not pack then error("no existe") end
		-- support old format (array only)
		if pack[1] and pack[1][1] then
			pack = { points = pack }
		end
		loadState(pack)
	end)
	setStatus(ok and ("Cargado: " .. name) or "No se pudo cargar")
end)

savePresetBtn.MouseButton1Click:Connect(function()
	local name = "preset_" .. (presetBox.Text ~= "" and presetBox.Text or "mundo")
	if #points == 0 and #winBlocks == 0 then setStatus("Nada que guardar") return end
	local ok = pcall(function()
		local all = {}
		if isfile and isfile(saveFile) then all = HttpService:JSONDecode(readfile(saveFile)) end
		all[name] = packState()
		writefile(saveFile, HttpService:JSONEncode(all))
	end)
	setStatus(ok and ("Preset: " .. name) or "Error preset")
end)

loadPresetBtn.MouseButton1Click:Connect(function()
	local name = "preset_" .. (presetBox.Text ~= "" and presetBox.Text or "mundo")
	routeNameBox.Text = name
	local ok = pcall(function()
		if not (isfile and isfile(saveFile)) then error("no file") end
		local all = HttpService:JSONDecode(readfile(saveFile))
		local pack = all[name]
		if not pack then error("no preset") end
		if pack[1] and pack[1][1] then pack = { points = pack } end
		loadState(pack)
	end)
	setStatus(ok and ("Preset cargado: " .. name) or "Preset no encontrado")
end)

-- ==========================================
-- GRABAR ACTIONS
-- ==========================================
local function recordHere()
	local root = hrp()
	if not root then setStatus("Sin personaje") return end
	addPoint(root.CFrame, nil, currentPointKind, currentWaitSec)
end

recBtn.MouseButton1Click:Connect(recordHere)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G then recordHere() end
	if input.KeyCode == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then doUndo() end
end)

undoBtn.MouseButton1Click:Connect(doUndo)
redoBtn.MouseButton1Click:Connect(doRedo)
remLastBtn.MouseButton1Click:Connect(removeLast)
clearBtn.MouseButton1Click:Connect(clearAll)

autoBtn.MouseButton1Click:Connect(function()
	autoMode = not autoMode
	autoStuds = tonumber(autoBox.Text) or 10
	autoBtn.Text = autoMode and ("Auto: ON (" .. autoStuds .. ")") or "Auto: OFF"
	autoBtn.BackgroundColor3 = autoMode and Color3.fromRGB(40, 110, 60) or Color3.fromRGB(36, 36, 48)
	local root = hrp()
	if root then lastRecordPos = root.Position end
end)

fixedYBtn.MouseButton1Click:Connect(function()
	fixedYMode = not fixedYMode
	local root = hrp()
	if fixedYMode and root then
		fixedYValue = root.Position.Y
		fixedYBtn.Text = string.format("Y fija: ON (%.1f)", fixedYValue)
		fixedYBtn.BackgroundColor3 = Color3.fromRGB(40, 110, 60)
		setStatus(string.format("Y fija ON — solo puntos NUEVOS usarán Y=%.1f", fixedYValue))
	else
		fixedYValue = nil
		fixedYBtn.Text = "Y fija: OFF"
		fixedYBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
	end
end)

fixedXBtn.MouseButton1Click:Connect(function()
	fixedXMode = not fixedXMode
	local root = hrp()
	if fixedXMode and root then
		fixedXValue = root.Position.X
		fixedXBtn.Text = string.format("X fija: ON (%.1f)", fixedXValue)
		fixedXBtn.BackgroundColor3 = Color3.fromRGB(40, 110, 60)
		setStatus(string.format("X fija ON — solo puntos NUEVOS usarán X=%.1f", fixedXValue))
	else
		fixedXValue = nil
		fixedXBtn.Text = "X fija: OFF"
		fixedXBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
	end
end)

timedBtn.MouseButton1Click:Connect(function()
	timedRecord = not timedRecord
	lastTimedRecord = tick()
	timedBtn.Text = timedRecord and "Grabar cada 0.5s: ON" or "Grabar cada 0.5s: OFF"
	timedBtn.BackgroundColor3 = timedRecord and Color3.fromRGB(40, 110, 60) or Color3.fromRGB(36, 36, 48)
	setStatus(timedRecord and "Grabando cada 0.5s con modos actuales" or "Grabado por tiempo OFF")
end)

RunService.Heartbeat:Connect(function()
	if testing then return end
	local root = hrp()
	if not root then return end
	-- Auto por distancia
	if autoMode then
		if