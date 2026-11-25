-- ==========================================
-- Route Recorder v2.2 (standalone)
-- PlayerGui | Delta Executor | Movil
-- ==========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local PLACE_ID = game.PlaceId
local GAME_ID = game.GameId
local PLACE_NAME = "Place_" .. tostring(PLACE_ID)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("RouteRecorder")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RouteRecorder"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 500
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- ==========================================
-- ESTADO
-- ==========================================
-- points[i] = { cf, kind, waitSec, marker, label, line, distLabel }
-- kind: "normal" | "plant" | "wait" | "jump"
local points = {}
local undoStack = {} -- snapshots of points (cf+kind+wait only)
local redoStack = {}
local lastRecordPos = nil
local autoMode = false
local autoStuds = 10
local fixedYMode = false
local fixedYValue = nil
local fixedXMode = false
local fixedXValue = nil
local timedRecord = false
local timedRecordEvery = 0.5
local lastTimedRecord = 0
local previewMarker = nil
local testing = false
local testSpeed = 220
local testMode = "normal" -- normal min0, fast min50, ultra min150
local noclipTest = false
local saveFile = "RouteRecorder_Routes.json"
local autoSaveEvery = 5
local pointsSinceSave = 0
local currentPointKind = "normal"
local currentWaitSec = 0.25
-- Modos de recorrido a los que pertenece el próximo punto (y los que se graben)
local currentModes = { normal = true, fast = true, super = true }
-- refs del panel flotante (se asignan al crear el panel; forward-declare para sync)
local qModeN, qModeF, qModeS

local function modesCopy(m)
	m = m or currentModes
	return {
		normal = m.normal and true or false,
		fast = m.fast and true or false,
		super = m.super and true or false,
	}
end

local function modesLabel(m)
	m = m or currentModes
	local t = {}
	if m.normal then table.insert(t, "N") end
	if m.fast then table.insert(t, "F") end
	if m.super then table.insert(t, "S") end
	if #t == 0 then return "?" end
	return table.concat(t, "")
end

local function pointInMode(p, mode)
	if not p then return false end
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
local cleanupExact = { "TarantulaS13", "WindZonesS14", "Lava_Stage15" }
local cleanupPrefix = { "Pair" }

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
	local f = Instance.new("Frame")
	f.Parent = parent
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	f.Size = UDim2.new(1, 0, 0, 0)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.LayoutOrder = order
	corner(f, 10)
	local pad = Instance.new("UIPadding")
	pad.Parent = f
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	local lay = Instance.new("UIListLayout")
	lay.Parent = f
	lay.Padding = UDim.new(0, 6)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	local t = Instance.new("TextLabel")
	t.Parent = f
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, 0, 0, 18)
	t.Font = Enum.Font.GothamBold
	t.Text = title
	t.TextColor3 = Color3.fromRGB(200, 210, 255)
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.LayoutOrder = 0
	return f
end

-- ==========================================
-- MAIN WINDOW
-- ==========================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Main.Position = UDim2.new(0, 10, 0.08, 0)
Main.Size = UDim2.new(0, 310, 0, 500)
Main.Active = true
Main.Draggable = true
corner(Main, 12)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(45, 45, 60)
mainStroke.Thickness = 1.2
mainStroke.Parent = Main

local Top = Instance.new("Frame")
Top.Parent = Main
Top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Top.Size = UDim2.new(1, 0, 0, 40)
corner(Top, 12)
local TopFix = Instance.new("Frame")
TopFix.Parent = Top
TopFix.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
TopFix.BorderSizePixel = 0
TopFix.Position = UDim2.new(0, 0, 1, -8)
TopFix.Size = UDim2.new(1, 0, 0, 8)

local Title = Instance.new("TextLabel")
Title.Parent = Top
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Route Recorder v2.1"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Top
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
MinBtn.TextSize = 18

local Float = Instance.new("TextButton")
Float.Parent = ScreenGui
Float.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Float.Position = UDim2.new(0, 12, 0.45, 0)
Float.Size = UDim2.new(0, 48, 0, 48)
Float.Font = Enum.Font.GothamBold
Float.Text = "RR"
Float.TextColor3 = Color3.fromRGB(255, 255, 255)
Float.TextSize = 14
Float.Visible = false
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
for