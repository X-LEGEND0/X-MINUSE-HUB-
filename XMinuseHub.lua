-- X-MINUSE HUB: Circuit du Mans Auto Race (Exact TP + 27th CP Updated) + Circuit Race Mod
local player = game.Players.LocalPlayer
pcall(function() for _,c in ipairs(getconnections(player.Idled)) do c:Disable() end end)

-- Circuit du Mans checkpoints
local checkpoints = {
    Vector3.new(313.4, 46.7, -9075.5), Vector3.new(-197.8, 62.1, -8359.7), 
    Vector3.new(-531.8, 74.2, -8024.9), Vector3.new(-1108.7, 89.3, -7735.4), 
    Vector3.new(-1701.5, 95.8, -7625.3), Vector3.new(-2390.9, 107.1, -7497.1), 
    Vector3.new(-2916.2, 90.6, -7341.1), Vector3.new(-3241.0, 80.6, -7588.2), 
    Vector3.new(-2583.2, 84.3, -7943.9), Vector3.new(-1884.6, 75.4, -8089.5), 
    Vector3.new(-2093.1, 67.0, -8403.4), Vector3.new(-2773.8, 53.6, -8322.4), 
    Vector3.new(-3296.6, 44.3, -8185.9), Vector3.new(-3683.6, 40.3, -8083.5), 
    Vector3.new(-3721.4, 38.0, -8355.4), Vector3.new(-3396.6, 37.4, -8462.5), 
    Vector3.new(-2764.8, 34.9, -8654.4), Vector3.new(-1998.6, 27.8, -8917.1), 
    Vector3.new(-1246.3, 16.6, -9206.2), Vector3.new(-1198.5, 14.3, -9461.5), 
    Vector3.new(-716.4, 11.5, -9961.6), Vector3.new(-286.4, 20.7, -10308.9), 
    Vector3.new(-53.4, 25.5, -10203.6), Vector3.new(170.9, 32.9, -9875.5), 
    Vector3.new(528.6, 30.8, -10075.6), Vector3.new(816.5, 36.2, -10330.7), 
    Vector3.new(821.1, 36.9, -10327.7), Vector3.new(1010.5, 41.0, -10150.3),
    Vector3.new(843.5, 38.7, -9884.4), Vector3.new(644.9, 41.4, -9576.9), 
    Vector3.new(321.7, 46.7, -9070.6) 
}

-- Circuit Race checkpoints
local checkpoints_Circuit = {
    Vector3.new(-4994.97, 6.02, -1772.46), Vector3.new(-5178.76, 6.01, -1927.89),
    Vector3.new(-5230.3, 6.01, -2127.3), Vector3.new(-4955.23, 5.98, -2495.80),
    Vector3.new(-4783.0, 5.1, -2423.7), Vector3.new(-4824.41, 5.98, -2256.90),
    Vector3.new(-4969.5, 6.1, -2072.0), Vector3.new(-4814.86, 6.01, -2009.12),
    Vector3.new(-4359.51, 32.98, -2171.05), Vector3.new(-3995.0, 28.0, -2339.6),
    Vector3.new(-3741.43, 27.92, -2533.93), Vector3.new(-3820.29, 27.93, -2699.30),
    Vector3.new(-4073.64, 27.92, -2602.78), Vector3.new(-4277.96, 27.92, -2538.74),
    Vector3.new(-4232.47, 27.95, -2783.61), Vector3.new(-3830.7, 18.0, -2985.7),
    Vector3.new(-3483.84, 6.20, -3186.68), Vector3.new(-3280.59, 5.94, -3469.65),
    Vector3.new(-3465.94, 5.92, -3637.56), Vector3.new(-3859.04, 5.92, -3354.30),
    Vector3.new(-4251.90, 5.96, -2975.56), Vector3.new(-4556.27, 5.97, -2547.75),
    Vector3.new(-4360.93, 5.98, -2232.40), Vector3.new(-4088.7, 6.1, -1916.8),
    Vector3.new(-4013.17, 6.03, -1580.38), Vector3.new(-4138.38, 6.06, -1324.62),
    Vector3.new(-4500.03, 6.02, -1405.42), Vector3.new(-4773.27, 6.02, -1595.26)
}

local running, paused, raceActive = false, false, false
local currentIndex, delayTime = 1, 1.15
local raceActive_Circuit, currentIndex_Circuit = false, 1

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "CheckpointTeleportUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,280)
frame.Position = UDim2.new(0.4,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke",frame).Color = Color3.fromRGB(0,200,255)

-- Make draggable function
local function makeDraggable(obj)
    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame)

-- Tab system
local function createTab(txt, posX)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0,60,0,25)
    btn.Position = UDim2.new(0,posX,0,65)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.Text = txt
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",btn)
    return btn
end

local homeTab = createTab("Home", 10)
local racesTab = createTab("Races", 80)

local homeSec, racesSec = Instance.new("Frame",frame), Instance.new("Frame",frame)
for _,sec in pairs({homeSec, racesSec}) do
    sec.Size = UDim2.new(1,0,1,-100)
    sec.Position = UDim2.new(0,0,0,95)
    sec.BackgroundTransparency = 1
    sec.Visible = false
    sec.Parent = frame
end
homeSec.Visible = true

local function switchTab(tab)
    homeSec.Visible = (tab=="home")
    racesSec.Visible = (tab=="races")
    homeTab.BackgroundColor3 = tab=="home" and Color3.fromRGB(80,80,80) or Color3.fromRGB(50,50,50)
    racesTab.BackgroundColor3 = tab=="races" and Color3.fromRGB(80,80,80) or Color3.fromRGB(50,50,50)
end

homeTab.MouseButton1Click:Connect(function() switchTab("home") end)
racesTab.MouseButton1Click:Connect(function() switchTab("races") end)

-- Header
local title = Instance.new("TextLabel", frame)
title.Text = "X-MINUSE HUB"
title.Size = UDim2.new(1,-50,0,30)
title.Position = UDim2.new(0,10,0,5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0,120,255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left

local author = Instance.new("TextLabel", frame)
author.Text = "By X-LEGEND"
author.Size = UDim2.new(1,0,0,20)
author.Position = UDim2.new(0,0,0,35)
author.BackgroundTransparency = 1
author.TextColor3 = Color3.new(1,1,1)
author.Font = Enum.Font.GothamBold
author.TextSize = 16

-- Button creator
local function createBtn(txt, y, color, parent)
    local btn = Instance.new("TextButton",parent)
    btn.Size = UDim2.new(0,220,0,36)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = txt
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    return btn
end

-- Home tab content
local discordBtn = createBtn("📋 Copy Discord Link",10,Color3.fromRGB(0,140,255),homeSec)
discordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/MWWmYUsVvs")
    discordBtn.Text = "✅ Copied!"
    task.delay(2,function() discordBtn.Text = "📋 Copy Discord Link" end)
end)

-- Circuit du Mans Race
local circuitLabel = Instance.new("TextLabel",racesSec)
circuitLabel.Size = UDim2.new(1,-20,0,24)
circuitLabel.Position = UDim2.new(0,10,0,10)
circuitLabel.BackgroundTransparency = 1
circuitLabel.Font = Enum.Font.GothamBold
circuitLabel.TextSize = 16
circuitLabel.TextColor3 = Color3.new(1,1,1)
circuitLabel.TextXAlignment = Enum.TextXAlignment.Left
circuitLabel.Text = "Circuit du Mans"

local circuitBtn = createBtn("🚦 Start Race: OFF",50,Color3.fromRGB(200,0,0),racesSec)
circuitBtn.MouseButton1Click:Connect(function()
    raceActive = not raceActive
    if raceActive then
        paused = false
        running = false
        currentIndex = 1
        circuitBtn.Text = "🚦 Starting..."
        local rs = game:GetService("ReplicatedStorage")
        local raceEvent = rs:WaitForChild("Event"):WaitForChild("Races"):WaitForChild("ClickedOnStartButton")
        raceEvent:FireServer("Circuit du Mans Race", true)
        local endurance = rs:WaitForChild("Event"):WaitForChild("Races"):FindFirstChild("EnduranceRaceStart")
        if endurance then endurance:FireServer("Circuit du Mans Race") end
        task.delay(6, function() if raceActive then running = true end end)
    else
        running = false
        paused = false
        currentIndex = 1
    end
    circuitBtn.Text = "🚦 Start Race: " .. (raceActive and "ON" or "OFF")
end)

-- Teleport function
local function getVehicle()
    local char = player.Character or player.CharacterAdded:Wait()
    local h = char:FindFirstChildOfClass("Humanoid")
    if h and h.SeatPart then
        return h.SeatPart:FindFirstAncestorOfClass("Model")
    end
end

local function teleport(pos)
    local rayOrigin = pos + Vector3.new(0, 50, 0)
    local rayDir = Vector3.new(0, -100, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character, getVehicle()}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(rayOrigin, rayDir, rayParams)
    local yPos = result and result.Position.Y + 3 or pos.Y + 5
    local finalPos = Vector3.new(pos.X, yPos, pos.Z)
    
    local v = getVehicle()
    if v and v.PrimaryPart then
        v:SetPrimaryPartCFrame(CFrame.new(finalPos))
    else
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(finalPos)
            task.wait(0.05)
            root.CFrame = root.CFrame * CFrame.new(0.5, 0, 0)
        end
    end
end

-- Circuit du Mans loop
task.spawn(function()
    while true do
        if running and not paused and raceActive then
            if currentIndex > #checkpoints then
                currentIndex = 1
            end
            circuitBtn.Text = "🚦 Start Race: ON ("..currentIndex.."/"..#checkpoints..")"
            teleport(checkpoints[currentIndex])
            currentIndex += 1
            local delay = delayTime + math.random(10, 30) / 100
            for i = 1, math.floor(delay/0.1) do
                if paused or not running or not raceActive then break end
                task.wait(0.1)
            end
        end
        task.wait(0.1)
    end
end)

-- Minimize button
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -28, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextSize = 16
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

local minimizedIcon = Instance.new("TextButton")
minimizedIcon.Name = "XMinimized"
minimizedIcon.Size = UDim2.new(0, 52, 0, 52)
minimizedIcon.Position = UDim2.new(0, 10, 0, 10)
minimizedIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minimizedIcon.Text = "X"
minimizedIcon.TextColor3 = Color3.fromRGB(0, 120, 255)
minimizedIcon.TextSize = 34
minimizedIcon.Font = Enum.Font.GothamBlack
minimizedIcon.Visible = false
minimizedIcon.Parent = gui
Instance.new("UICorner", minimizedIcon).CornerRadius = UDim.new(1, 0)

minimizeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    minimizedIcon.Visible = true
end)

minimizedIcon.MouseButton1Click:Connect(function()
    frame.Visible = true
    minimizedIcon.Visible = false
end)
makeDraggable(minimizedIcon)

-- Circuit Race UI
local circuit2Label = Instance.new("TextLabel",racesSec)
circuit2Label.Size = UDim2.new(1,-20,0,24)
circuit2Label.Position = UDim2.new(0,10,0,100)
circuit2Label.BackgroundTransparency = 1
circuit2Label.Font = Enum.Font.GothamBold
circuit2Label.TextSize = 16
circuit2Label.TextColor3 = Color3.new(1,1,1)
circuit2Label.TextXAlignment = Enum.TextXAlignment.Left
circuit2Label.Text = "Circuit Race"

local circuit2Btn = createBtn("🚦 Start Race: OFF",140,Color3.fromRGB(200,0,0),racesSec)
circuit2Btn.MouseButton1Click:Connect(function()
    raceActive_Circuit = not raceActive_Circuit
    if raceActive_Circuit then
        currentIndex_Circuit = 1
        circuit2Btn.Text = "🚦 Starting..."
        local rs = game:GetService("ReplicatedStorage")
        local raceEvent = rs:WaitForChild("Event"):WaitForChild("Races"):WaitForChild("ClickedOnStartButton")
        raceEvent:FireServer("Circuit Race", true)
        task.delay(6, function()
            if raceActive_Circuit then
                circuit2Btn.Text = "🚦 Start Race: ON"
            end
        end)
    else
        currentIndex_Circuit = 1
        circuit2Btn.Text = "🚦 Start Race: OFF"
    end
end)

-- Modified Circuit Race loop with 2-lap pit stop
task.spawn(function()
    local lapCount = 0
    while true do
        if raceActive_Circuit then
            if currentIndex_Circuit > #checkpoints_Circuit then
                currentIndex_Circuit = 1
                lapCount = lapCount + 1
                
                -- Every 2 laps, teleport to special position and wait 16 seconds
                if lapCount % 2 == 0 then
                    circuit2Btn.Text = "🚦 Pit Stop (16s)"
                    teleport(Vector3.new(527.2, 5.0, -1592.8))
                    for i = 1, 16 do
                        if not raceActive_Circuit then break end
                        circuit2Btn.Text = "🚦 Pit Stop ("..(16-i).."s)"
                        task.wait(1)
                    end
                    lapCount = 0 -- Reset after pit stop
                end
            end
            
            circuit2Btn.Text = "🚦 Start Race: ON ("..currentIndex_Circuit.."/"..#checkpoints_Circuit..")"
            teleport(checkpoints_Circuit[currentIndex_Circuit])
            currentIndex_Circuit += 1
            
            local delay = delayTime + math.random(10, 30) / 100
            for i = 1, math.floor(delay/0.1) do
                if not raceActive_Circuit then break end
                task.wait(0.1)
            end
        end
        task.wait(0.1)
    end
