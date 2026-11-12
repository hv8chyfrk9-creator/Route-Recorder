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
	i