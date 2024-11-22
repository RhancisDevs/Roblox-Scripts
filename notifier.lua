local HttpService = game:GetService("HttpService")
local Player = game.Players.LocalPlayer

local function getCurrentTime()
    local timeZoneOffset = 8 * 3600
    local utcTime = os.time(os.date("!*t"))
    local manilaTime = utcTime + timeZoneOffset
    return os.date("%Y-%m-%d %H:%M:%S", manilaTime)
end

local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"

local function sendNotification()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script Activated",
        Text = "The script is now sending the current time to the Discord webhook every minute.",
        Icon = "rbxassetid://1234567890",
        Duration = 5
    })
end

sendNotification()

while true do
    local currentTime = getCurrentTime()
    local payload = {
        content = "The current time in Asia/Manila is: " .. currentTime
    }
    local payloadJSON = HttpService:JSONEncode(payload)
    local success, response = pcall(function()
        return game:HttpPostAsync(webhookURL, payloadJSON, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Failed to send time. Error: " .. tostring(response))
    end
    wait(60)
end
