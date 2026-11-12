 = false
Float.Active = true
Float.Draggable = true
corner(Float, 24)

MinBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	Float.Visible = true
end)
Float.MouseButton1Click:Connect(function()
	Main.Visible = true
	Float.Visible = false
end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Parent = Main
TabBar.BackgroundTransparency = 1
TabBar.Position = UDim2.new(0, 6, 0, 44)
TabBar.Size = UDim2.new(1, -12, 0, 34)
local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = TabBar
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local pages, tabBtns = {}, {}
local function makeTab(name, order)
	local b = Instance.new("TextButton")
	b.Parent = TabBar
	b.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
	b.Size = UDim2.new(0, 56, 1, 0)
	b.Font = Enum.Font.GothamBold
	b.Text = name
	b.TextColor3 = Color3.fromRGB(200, 200, 210)
	b.TextSize = 11
	b.LayoutOrder = order
	corner(b, 8)
	local page = Instance.new("ScrollingFrame")
	page.Parent = Main
	page.BackgroundTransparency = 1
	page.Position = UDim2.new(0, 8, 0, 84)
	page.Size = UDim2.new(1, -16, 1, -94)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollBarThickness = 4
	page.BorderSizePixel = 0
	page.Visible = false
	local lay = Instance.new("UIListLayout")
	lay.Parent = page
	lay.Padding = UDim.new(0, 8)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	pages[name] = page
	tabBtns[name] = b
	return b
end

local tabNames = { "Grabar", "Ruta", "Wins", "Probar", "Export" }
for i, n in ipairs(tabNames) do makeTab(n, i) end

local function showTab(name)
	for n, p in pairs(pages) do
		p.Visible = (n == name)
		tabBtns[n].BackgroundColor3 = (n == name) and Color3.fromRGB(55, 90, 160) or Color3.fromRGB(32, 32, 42)
		tabBtns[n].TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
	end
end
for _, n in ipairs(tabNames) do
	tabBtns[n].MouseButton1Click:Connect(function() showTab(n) end)
end
showTab("Grabar")

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = Main
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 10, 1, -18)
statusLabel.Size = UDim2.new(1, -20, 0, 14)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Listo"
statusLabel.TextColor3 = Color3.fromRGB(120, 220, 140)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
-- raise page bottom so status visible
for _, p in pairs(pages) do
	p.Size = UDim2.new(1, -16, 1, -110)
end

local function setStatus(t)
	statusLabel.Text = t
end

-- ==========================================
-- MA