local lp = game.Players.LocalPlayer
local playerGui = lp:FindFirstChild("PlayerGui")

local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"
local fishName = nil
local findingReel = true

local function sendWebhook(fish)
    local payload = {
        ["content"] = "🎣 You caught a **" .. fish .. "**!"
    }

    local success, response = pcall(function()
        return syn and syn.request({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        }) or request({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)
end

while true do
    wait(0.5)

    if playerGui and findingReel then
        local reel = playerGui:FindFirstChild("reel")
        if reel then
            findingReel = false
            local bar = reel:FindFirstChild("bar")
            if bar then
                local nestedReel = bar:FindFirstChild("reel")
                if nestedReel then
                    local fish = nestedReel:FindFirstChild("fish")
                    if fish and fish:IsA("StringValue") then
                        fishName = fish.Value
                    end
                end
            end
        end
    elseif not findingReel then
        local reel = playerGui:FindFirstChild("reel")
        if not reel and fishName then
            sendWebhook(fishName)
            fishName = nil
            findingReel = true
        end
    end
end
