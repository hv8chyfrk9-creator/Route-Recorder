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

local points = {}
local undoStack = {}
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
local testMode = "normal"
local noclipTest = false
local saveFile = "RouteRecorder_Routes.json"
local metaFile = "RouteRecorder_Meta.json"
local autoSaveEvery = 5
local pointsSinceSave = 0
local currentPointKind = "normal"
local currentWaitSec = 0.25
local currentModes = { normal = true, fast = true, super = true }
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
	if not m then return true end
	if mode == "normal" then return m.normal end
	if mode == "fast" then return m.fast end
	if mode == "ultra" or mode == "super" then return m.super end
	return m.normal
end

local winBlocks = {}
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
