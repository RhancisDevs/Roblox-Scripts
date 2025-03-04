local jay = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()

local tradeInterval = 1

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
local tradeCount = 0
local toolDetectionEnabled = true
local lastTradeCheck = tick()

-- Store tool detection connections to disconnect them later
local toolConnections = {}

jay:Notify({
    Title = "✅ Jay Devs Trade Script",
    Content = "Script successfully executed!\n\n🎣 Trading " .. amount .. "x " .. fish_name,
    Duration = 4
})

-- Function to stop tool detection
local function disconnectToolDetection()
    toolDetectionEnabled = false
    for _, conn in ipairs(toolConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    toolConnections = {}
end

local function onToolEquipped(tool)
    if tool.Name == fish_name and toolDetectionEnabled then
    end
end

local function setupToolDetection(character)
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == fish_name and toolDetectionEnabled then
            onToolEquipped(tool)
        end
    end

    local conn = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == fish_name and toolDetectionEnabled then
            onToolEquipped(child)
        end
    end)

    table.insert(toolConnections, conn)
end

setupToolDetection(Character)
table.insert(toolConnections, LocalPlayer.CharacterAdded:Connect(function(character)
    if toolDetectionEnabled then
        setupToolDetection(character)
    end
end))

local function checkTradeAccepted()
    local hud = PlayerGui:FindFirstChild("hud")
    if not hud then return 0 end

    local safezone = hud:FindFirstChild("safezone")
    if not safezone then return 0 end

    local announcements = safezone:FindFirstChild("announcements")
    if not announcements then return 0 end

    local newTrades = 0
    local currentTime = tick()

    for _, thought in ipairs(announcements:GetChildren()) do
        if thought:IsA("Frame") then
            local mainText = thought:FindFirstChild("Main")
            if mainText and mainText:IsA("TextLabel") then
                local message = mainText.Text
                if string.find(message, "Item offer to " .. targetPlayerName .. " was accepted!") then
                    local messageTime = thought:GetAttribute("Timestamp") or currentTime
                    if messageTime > lastTradeCheck then
                        newTrades = newTrades + 1
                        thought:SetAttribute("Timestamp", currentTime)
                    end
                end
            end
        end
    end

    lastTradeCheck = currentTime
    return newTrades
end

local function sendTradeRequest()
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if not targetPlayer then return end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild(fish_name) then
        local args = {[1] = targetPlayer}
        char:FindFirstChild(fish_name).offer:FireServer(unpack(args))

        wait(1)

        local tradesAccepted = checkTradeAccepted()
        if tradesAccepted > 0 then
            tradeCount = tradeCount + tradesAccepted
            jay:Notify({
                Title = "🔄 Trade Progress",
                Content = "🎣 " .. fish_name .. " traded " .. tradeCount .. "/" .. amount,
                Duration = 1.5
            })
        end
    end
end

while tradeCount < amount do
    local char = LocalPlayer.Character
    if char and char:FindFirstChild(fish_name) then
        sendTradeRequest()
        wait(tradeInterval)
    else
        repeat wait(1) until char and char:FindFirstChild(fish_name)
    end
end

disconnectToolDetection()
jay:Notify({
    Title = "🎉 Trade Completed",
    Content = "✅ Successfully traded " .. amount .. "x " .. fish_name .. "!",
    Duration = 4
})
