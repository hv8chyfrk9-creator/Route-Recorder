RKERS / VISUALS
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
	dtxt