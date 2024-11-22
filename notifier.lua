-- Configuration
local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"

-- Function to send uptime to Discord webhook
local function sendToDiscord(userName, uptime, serverName)
    local data = {
        content = string.format("User: %s\nUptime: %s\nServer: %s", userName, uptime, serverName),
        username = "Uptime Bot"
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

-- Function to calculate uptime
local function getUptime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    return string.format("%d days, %d hours, %d minutes", days, hours, minutes)
end

-- Track player uptime
game.Players.PlayerAdded:Connect(function(player)
    local joinTime = os.time()

    -- Send uptime every minute
    local function sendUptimeLoop()
        while player.Parent do
            local currentTime = os.time()
            local uptimeSeconds = currentTime - joinTime
            local uptimeString = getUptime(uptimeSeconds)
            
            sendToDiscord(player.Name, uptimeString, game.Name) -- send data to Discord

            wait(60)  -- Wait for 1 minute before sending again
        end
    end

    -- Start sending uptime info every 1 minute
    spawn(sendUptimeLoop)
end)
