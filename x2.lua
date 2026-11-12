f not p then return false end
	local m = p.modes
	if not m then return true end -- compat: sin tags = todos
	if mode == "normal" then return m.normal end
	if mode == "fast" then return m.fast end
	if mode == "ultra" or mode == "super" then return m.super end
	return m.normal
end

-- WinBlocks registrados: { real = "WinBlock10", display = "+50K Wins", order = 10 }
local winBlocks = {}
-- Cleanup names / prefixes
local cleanupExact = {}
local cleanupPrefix = {}

local folder = Workspace:FindFirstChild("RouteRecorderMarkers")
if folder then folder:Destroy() end
folder = Instance.new("Folder")
folder.Name = "RouteRecorderMarkers"
folder.Parent = Workspace

local function hrp()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function hum()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function deepCopyPoints()
	local t = {}
	for i, p in ipairs(points) do
		t[i] = {
			cf = p.cf,
			kind = p.kind or "normal",
			waitSec = p.waitSec or 0,
			modes = modesCopy(p.modes),
		}
	end
	return t
end

local function pushUndo()
	table.insert(undoStack, deepCopyPoints())
	if #undoStack > 40 then table.remove(undoStack, 1) end
	redoStack = {}
end

-- ==========================================
-- UI HELPERS
-- ==========================================
local function corner(o, r)
	Instance.new("UICorner", o).CornerRadius = UDim.new(0, r or 8)
end

local function makeBtn(parent, text, order, color)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.BackgroundColor3 = color or Color3.fromRGB(36, 36, 48)
	b.Size = UDim2.new(1, 0, 0, 36)
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 12
	b.LayoutOrder = order
	corner(b, 8)
	return b
end

local function makeBox(parent, placeholder, order, default)
	local t = Instance.new("TextBox")
	t.Parent = parent
	t.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	t.Size = UDim2.new(1, 0, 0, 34)
	t.Font = Enum.Font.Gotham
	t.PlaceholderText = placeholder
	t.Text = default or ""
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
	t.TextSize = 12
	t.LayoutOrder = order
	t.ClearTextOnFocus = false
	corner(t, 8)
	return t
end

local function makeLabel(parent, text, order, color)
	local l = Instance.new("TextLabel")
	l.Parent = parent
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, 18)
	l.Font = Enum.Font.Gotham
	l.Text = text
	l.TextColor3 = color or Color3.fromRGB(170, 170, 185)
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = order
	return l
end

local function section(parent, title, order)
	loc