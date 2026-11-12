al f = Instance.new("Frame")
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
Title.Text = "Route Recorder v2.2"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Top
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
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
Float.Visible