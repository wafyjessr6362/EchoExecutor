-- Clean up old GUI if any
pcall(function() game.Players.LocalPlayer.PlayerGui.ExecutorGUI:Destroy() end)

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ExecutorGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Function to add rounded corners
local function Roundify(ui, radius)
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, radius)
	uicorner.Parent = ui
end

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 370)
frame.Position = UDim2.new(0.5, -250, 0.5, -185)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui
Roundify(frame, 12)
frame.ZIndex = 1

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
Roundify(titleBar, 12)
titleBar.ZIndex = 2

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Echo Executor"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Parent = titleBar
titleLabel.ZIndex = 3

-- Slower Dragging functionality
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	local targetPosition = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)

	TweenService:Create(
		frame,
		TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{Position = targetPosition}
	):Play()
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		game:GetService("UserInputService").InputChanged:Connect(function(movementInput)
			if dragging and movementInput == input then
				updateDrag(movementInput)
			end
		end)
	end
end)

-- TextBox for script input
local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(1, -20, 1, -100)
textbox.Position = UDim2.new(0, 10, 0, 40)
textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
textbox.TextColor3 = Color3.fromRGB(240, 240, 240)
textbox.Font = Enum.Font.Code
textbox.TextSize = 16
textbox.TextWrapped = true
textbox.TextXAlignment = Enum.TextXAlignment.Left
textbox.TextYAlignment = Enum.TextYAlignment.Top
textbox.ClearTextOnFocus = false
textbox.MultiLine = true
textbox.Text = ""
textbox.PlaceholderText = "-- Paste your Code Using C + V"
textbox.Parent = frame
Roundify(textbox, 10)
textbox.ZIndex = 4

-- Execute button
local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0, 220, 0, 40)
execBtn.Position = UDim2.new(0, 15, 1, -50)
execBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
execBtn.Font = Enum.Font.GothamBold
execBtn.TextSize = 18
execBtn.Text = "Execute"
execBtn.Parent = frame
Roundify(execBtn, 10)
execBtn.ZIndex = 4

-- Clear button
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 220, 0, 40)
clearBtn.Position = UDim2.new(0, 265, 1, -50)
clearBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 18
clearBtn.Text = "Clear"
clearBtn.Parent = frame
Roundify(clearBtn, 10)
clearBtn.ZIndex = 4

-- Button functions
execBtn.MouseButton1Click:Connect(function()
	local code = textbox.Text
	if code and code ~= "" then
		local success, err = pcall(function()
			loadstring(code)()
		end)
		if not success then
			warn("Script error: " .. tostring(err))
		end
	end
end)

clearBtn.MouseButton1Click:Connect(function()
	textbox.Text = ""
end)

-- Minimize and Close Buttons (TOP RIGHT OF TITLE BAR)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -60, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
minBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Text = "-"
minBtn.Parent = titleBar
Roundify(minBtn, 6)
minBtn.ZIndex = 10

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Text = "X"
closeBtn.Parent = titleBar
Roundify(closeBtn, 6)
closeBtn.ZIndex = 10

-- Enable clipping so nothing overflows
frame.ClipsDescendants = true

-- Minimize Logic
local isMinimized = false
local originalSize = frame.Size

-- Recursive visibility toggle, ignoring titleBar and its children
local function toggleChildrenVisibility(parent, state)
	for _, child in ipairs(parent:GetChildren()) do
		if child ~= titleBar then
			if child:IsA("GuiObject") then
				child.Visible = state
			end
			if #child:GetChildren() > 0 then
				toggleChildrenVisibility(child, state)
			end
		end
	end
end

minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local goalSize = isMinimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 40) or originalSize

	TweenService:Create(frame, tweenInfo, { Size = goalSize }):Play()

	-- Hide everything except the titleBar and its contents
	toggleChildrenVisibility(frame, not isMinimized)
end)

-- Close Logic
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
