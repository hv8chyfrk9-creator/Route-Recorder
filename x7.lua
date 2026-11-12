dYValue) and fixedYValue or pos.Y
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
	lastRecordPos = cf.Position
	if light then
		pointsSinceSave = pointsSinceSave + 1
		if pointsSinceSave % 10 == 0 then
			rebuildLines()
			refreshPointList()
		end
		if pointsSinceSave % 5 == 0 then
			setStatus("Grabando... CF " .. idx .. " (" .. modesLabel(modes) .. ")")
		end
	else
		rebuildLines()
		refreshPointList()
		setStatus("Anadido CF " .. idx .. " (" .. kind .. " | " .. modesLabel(modes) .. ")")
		pointsSinceSave = pointsSinceSave + 1
		if autoSaveEvery > 0 and pointsSinceSave >= autoSaveEvery then
			pointsSinceSave = 0
			task.spawn(function()
				pcall(function()
					local pack = packState()
					local all = {}
					if isfile and isfile(saveFile) then
						local okR, decoded = pcall(function() return HttpService:JSONDecode(readfile(saveFile)) end)
						if okR and type(decoded) == "table" then all = decoded end
					end
					all["autosave"] = pack
					writefile(saveFile, HttpService:JSONEncode(all))
				end)
			end)
		end
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
	setStatus("Borrado ultimo")
end

local function removeAt(n)
	if not points[n] then
		setStatus("Indice invalido")
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
e