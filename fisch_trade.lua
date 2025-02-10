local jay = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()

local Window = jay:CreateWindow({
    Title = "Jay | " .. game:GetService("MarketplaceService"):GetProductInfo(16732694052).Name,
    SubTitle = "by Rhancis ",
    TabWidth = 180,
    Size = UDim2.fromOffset(525, 380),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.Insert
})

local ClickButton = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ImageLabel = Instance.new("ImageLabel")
local TextButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UICorner_2 = Instance.new("UICorner")

ClickButton.Name = "ClickButton"
ClickButton.Parent = game.CoreGui
ClickButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ClickButton
MainFrame.AnchorPoint = Vector2.new(1, 0)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(1, -60, 0, 10)
MainFrame.Size = UDim2.new(0, 45, 0, 45)

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

UICorner_2.CornerRadius = UDim.new(0, 10)
UICorner_2.Parent = ImageLabel

ImageLabel.Parent = MainFrame
ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel.Size = UDim2.new(0, 45, 0, 45)
ImageLabel.Image = "rbxassetid://110144880465730"  -- Set the asset as the image

TextButton.Parent = MainFrame
TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
TextButton.BackgroundTransparency = 1
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0, 0, 0, 0)
TextButton.Size = UDim2.new(0, 45, 0, 45)
TextButton.AutoButtonColor = false
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = ""  -- Empty text since we're using the image
TextButton.TextColor3 = Color3.new(1, 1, 1)
TextButton.TextSize = 20

TextButton.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Insert", false, game)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Insert", false, game)
end)

local Tabs = {
    Trade = Window:AddTab({ Title = "Trade", Icon = "rbxassetid://7072724538" })
}

local function GetPlayerList()
    local Players = game:GetService("Players")
    local PlayerNames = {}

    for _, player in pairs(Players:GetPlayers()) do
        table.insert(PlayerNames, player.Name)
    end

    if #PlayerNames == 0 then
        PlayerNames = {"No players found"}
    end

    return PlayerNames
end

local PlayerDropdown = Tabs.Trade:AddDropdown("PlayerDropdown", {
    Title = "Select a Player",
    Values = GetPlayerList(),
    Multi = false,
    Default = "No players found",
})

local equippedFish = nil
local function get_fish_name()
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()

    local function onToolEquipped(tool)
        equippedFish = tool.Name
    end

    local function setupToolDetection(character)
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                onToolEquipped(tool)
            end
        end

        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                onToolEquipped(child)
            end
        end)
    end

    setupToolDetection(char)
    lp.CharacterAdded:Connect(setupToolDetection)
end

get_fish_name()

local function SendTradeRequest(playerName)
    if playerName == "No players found" or not equippedFish then
        return
    end

    local args = {
        [1] = game:GetService("Players"):WaitForChild(playerName)
    }

    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character

    if char and char:FindFirstChild(equippedFish) then
        char:FindFirstChild(equippedFish).offer:FireServer(unpack(args))
    end
end

task.spawn(function()
    while true do
        local PlayerNames = GetPlayerList()
        PlayerDropdown:SetValues(PlayerNames)
        task.wait(1)
    end
end)

Tabs.Trade:AddButton({
    Title = "Trade",
    Callback = function()
        SendTradeRequest(PlayerDropdown.Value)
    end
})

local autoTrade = false
Tabs.Trade:AddToggle("AutoTrade", {
    Title = "Auto Trade",
    Default = false,
    Callback = function(value)
        autoTrade = value
        if autoTrade then
            jay:Notify({
                Title = "Auto Trade Enabled",
                Content = "Automatically trading every 0.5s.",
                Duration = 2
            })
        else
            jay:Notify({
                Title = "Auto Trade Disabled",
                Content = "Stopped auto trading.",
                Duration = 2
            })
        end
    end
})

task.spawn(function()
    while true do
        if autoTrade and PlayerDropdown.Value ~= "No players found" and equippedFish then
            SendTradeRequest(PlayerDropdown.Value)
        end
        task.wait(0.5)
    end
end)
