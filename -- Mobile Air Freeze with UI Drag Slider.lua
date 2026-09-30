-- Mobile Air Freeze with UI Drag Slider Scaler
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isFloated = false
local savedPosition = nil
local currentHeight = 200 -- Starting default height
local minHeight = 20      -- Minimum slider studs
local maxHeight = 1000    -- Maximum slider studs

-- 1. Create Core Mobile Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileFloatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 110)
MainFrame.Position = UDim2.new(0.5, -130, 0.15, 0) -- Top-center of mobile screen
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Allows mobile players to drag the menu anywhere
MainFrame.Parent = ScreenGui

-- Corner styling
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Status / Title Text Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Text = "Height: " .. currentHeight .. " Studs"
TitleLabel.Parent = MainFrame

-- 2. Create the Visual Slider Line (Track)
local SliderTrack = Instance.new("Frame")
SliderTrack.Name = "SliderTrack"
SliderTrack.Size = UDim2.new(0, 200, 0, 6)
SliderTrack.Position = UDim2.new(0.5, -100, 0.45, 0)
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = MainFrame

-- Slider Fill Line
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0) -- Matches initial height ratio
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

-- Slider Handle Button (The circle you drag)
local SliderHandle = Instance.new("TextButton")
SliderHandle.Name = "SliderHandle"
SliderHandle.Size = UDim2.new(0, 16, 0, 16)
SliderHandle.Position = UDim2.new(0.2, -8, 0.5, -8)
SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderHandle.BorderSizePixel = 0
SliderHandle.Text = ""
SliderHandle.Parent = SliderTrack

local HandleCorner = Instance.new("UICorner")
HandleCorner.CornerRadius = UDim.new(1, 0) -- Makes it a circle
HandleCorner.Parent = SliderHandle

-- 3. Create the Main Toggle Activation Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 220, 0, 30)
ToggleButton.Position = UDim2.new(0.5, -110, 0.65, 5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Red initially
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Text = "FREEZE / FLOAT"
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = ToggleButton

-- 4. Core Teleport Mechanics Logic
local function updateCharacterHeight()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not savedPosition then return end

    rootPart.Anchored = false
    rootPart.CFrame = savedPosition + Vector3.new(0, currentHeight, 0)
    task.wait(0.02)
    rootPart.Anchored = true
end

local function toggleFloat()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    isFloated = not isFloated

    if isFloated then
        savedPosition = rootPart.CFrame
        rootPart.CFrame = savedPosition + Vector3.new(0, currentHeight, 0)
        task.wait(0.1)
        rootPart.Anchored = true
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 100) -- Green when active
        ToggleButton.Text = "TELEPORT BACK DOWN"
    else
        rootPart.Anchored = false
        if savedPosition then
            rootPart.CFrame = savedPosition
        end
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Red when off
        ToggleButton.Text = "FREEZE / FLOAT"
    end
end

ToggleButton.MouseButton1Click:Connect(toggleFloat)

-- 5. Mobile Drag Math Functionality
local dragging = false

SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        -- Math logic to turn slider position into stud scale values
        local mousePos = input.Position.X
        local trackLeft = SliderTrack.AbsolutePosition.X
        local trackWidth = SliderTrack.AbsoluteSize.X
        
        local percentage = math.clamp((mousePos - trackLeft) / trackWidth, 0, 1)
        
        SliderHandle.Position = UDim2.new(percentage, -8, 0.5, -8)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        -- Translates slider percentage directly to studs
        currentHeight = math.floor(minHeight + (percentage * (maxHeight - minHeight)))
        TitleLabel.Text = "Height: " .. currentHeight .. " Studs"
        
        -- Instantly adjusts your position if you are currently frozen in the sky
        if isFloated then
            updateCharacterHeight()
        end
    end
end)
