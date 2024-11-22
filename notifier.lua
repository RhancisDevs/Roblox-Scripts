-- Configuration
local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"

-- Ensure HTTP Service is enabled
local httpService = game:GetService("HttpService")

-- Function to send the current time to Discord webhook
local function sendToDiscord(currentTime)
    local data = {
        content = string.format("Current Time (Asia/Manila): %s", currentTime)
    }

    local jsonData
    local success, encodeError = pcall(function()
        jsonData = httpService:JSONEncode(data) -- Encode data to JSON
    end)

    if not success then
        warn("Failed to encode JSON: " .. encodeError)
        return
    end

    -- Send POST request to the webhook
    local postSuccess, postError = pcall(function()
        httpService:PostAsync(webhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not postSuccess then
        warn("Failed to send POST request: " .. postError)
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

-- Send current time every minute
local function sendTimeLoop()
    while true do
        local currentTime = getManilaTime()  -- Get the current time in Manila timezone
        sendToDiscord(currentTime)  -- Send the time to the webhook

        wait(60)  -- Wait for 1 minute before sending again
    end
end

-- Start the time loop
spawn(sendTimeLoop)
