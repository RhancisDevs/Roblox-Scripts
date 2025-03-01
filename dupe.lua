local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character

local NPCs = Workspace.world.npcs
local WebhookURL = "https://ap-is-ivory.vercel.app/api/webhook"

local function sendStatus(message)
    local data = {
        embeds = {{
            title = "Script Status",
            description = message,
            color = 65280
        }}
    }

    request({
        Url = WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

sendStatus(LocalPlayer.Name .. " has started the AFK duping script.")

task.spawn(function()
    while task.wait(300) do
        sendStatus(LocalPlayer.Name .. " is still running the script.")
    end
end)

local Desired = Character:FindFirstChildOfClass('Tool')
if not Desired then return end

local DesiredName = Desired.Name

RunService.RenderStepped:Connect(function()
    local Tool = Character:FindFirstChild(DesiredName)

    if not Tool then
        Tool = LocalPlayer.Backpack:FindFirstChild(DesiredName)
    end

    if not Tool then return end
    Tool.Parent = Character
end)

local LastAppraise
task.spawn(function()
    while task.wait() do
        if LastAppraise then
            repeat task.wait() until tick() - LastAppraise > 1
        end

        task.spawn(pcall, function()
            ReplicatedStorage.packages.Net["RF/AppraiseAnywhere/Fire"]:InvokeServer()
        end)

        pcall(function()
            NPCs.Appraiser.appraiser.appraise:InvokeServer()
        end)

        LastAppraise = tick()
    end
end)
