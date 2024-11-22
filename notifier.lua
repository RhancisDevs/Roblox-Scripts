-- Configuration
local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"

-- Function to send the current time to Discord webhook
local function sendToDiscord(currentTime)
    local data = {
        content = string.format("Current Time (Asia/Manila): %s", currentTime),
        username = "Time Bot"
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(data)

    -- Send POST request to the Discord webhook
    local success, response = pcall(function()
        game:GetService("HttpService"):PostAsync(webhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Failed to send data to Discord webhook: " .. response)
    end
end

-- Function to get the current time in Asia/Manila timezone
local function getManilaTime()
    local utcTime = os.time()  -- Get the current time in UTC
    local manilaOffset = 8 * 3600  -- Manila is UTC+8
    local manilaTime = utcTime + manilaOffset  -- Adjust for Manila timezone

    -- Convert to a formatted string (YYYY-MM-DD HH:MM:SS)
    return os.date("%Y-%m-%d %H:%M:%S", manilaTime)
end

-- Track player uptime
game.Players.PlayerAdded:Connect(function(player)
    -- Send current time every minute
    local function sendTimeLoop()
        while player.Parent do
            local currentTime = getManilaTime()  -- Get the current time in Manila timezone
            sendToDiscord(currentTime)  -- Send the time to Discord webhook

            wait(60)  -- Wait for 1 minute before sending again
        end
    end

    -- Start sending the current time every 1 minute
    spawn(sendTimeLoop)
end)
