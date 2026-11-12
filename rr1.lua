-- ==========================================
-- Route Recorder v2.2 (standalone)
-- PlayerGui | Delta Executor | Movil
-- ==========================================

print("[Route Recorder] cargando v2.2 ...")
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
local metaFile = "RouteRecorder_Meta.json" -- WinBlocks + anti-lag (archivo aparte)
local autoSaveEvery = 5
local pointsSinceSave = 0
local currentPointKind = "normal"
local currentWaitSec = 0.25
-- Modos de recorrido a los que pertenece el proximo punto (y los que se graben)
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
	local f = Instance.new("Frame")
	f.Parent = parent
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	f.Size = UDim2.new(1, 0, 0, 0)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.LayoutOrder = order
	corner(f, 10)
	local pad = Instance.new("UIPadding", f)
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	local list = Instance.new("UIListLayout", f)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 6)
	local titleL = Instance.new("TextLabel")
	titleL.Parent = f
	titleL.BackgroundTransparency = 1
	titleL.Size = UDim2.new(1, 0, 0, 18)
	titleL.Font = Enum.Font.GothamBold
	titleL.Text = title
	titleL.TextColor3 = Color3.fromRGB(180, 180, 200)
	titleL.TextSize = 12
	titleL.TextXAlignment = Enum.TextXAlignment.Left
	titleL.LayoutOrder = 0
	return f
end

-- ==========================================
-- M