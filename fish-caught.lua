local jay = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

if _G.JayLoggerRunning then
    jay:Notify({
        Title = "Jay Logger | Fisch",
        Content = "Catch webhook is already running!",
        Duration = 2
    })
    return
end
_G.JayLoggerRunning = true

jay:Notify({
    Title = "Jay Logger | Fisch",
    Content = "Catch webhook has been successfully executed!",
    SubContent = "Catch webhook is now running...",
    Duration = 2
})

local lp = game.Players.LocalPlayer
local playerGui = lp:FindFirstChild("PlayerGui")

local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"
local fishName = nil
local findingReel = true

local desiredFish = {
    "Great White Shark", "Great Hammerhead Shark", "Whale Shark", "Nuke", "Orca", 
    "Ancient Orca", "Ancient Kraken", "The Kraken", "Lovestorm Eel Supercharged", 
    "Lovestorm Eel", "Megalodon", "Ancient Megalodon", "Phantom Megalodon", 
    "Mustard", "Long Pike", "Banana", "Treble Bass"
}

local function isDesiredFish(fish)
    for _, f in pairs(desiredFish) do
        if f == fish then
            return true
        end
    end
    return false
end

local function sendWebhook(payload)
    pcall(function()
        return request({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)
end

sendWebhook({
    ["embeds"] = {
        {
            ["title"] = "Jay Catch Webhook | Fisch",
            ["color"] = 16755200,
            ["description"] = "> Username: " .. lp.Name .. "\n\nScript has been started. Please wait until a desired fish is caught. It will automatically notify you.",
            ["footer"] = {
                ["text"] = "Fishing Logger | " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }
})

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
            if isDesiredFish(fishName) then
                local leaderstats = lp:FindFirstChild("leaderstats")
                local cash = leaderstats and leaderstats:FindFirstChild("C$") and leaderstats["C$"].Value or "N/A"
                local level = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "N/A"

                sendWebhook({
                    ["embeds"] = {
                        {
                            ["title"] = "Jay Logger | Fisch",
                            ["color"] = 16755200,
                            ["fields"] = {
                                {
                                    ["name"] = "•Profile:\n",
                                    ["value"] = "> Username: " .. lp.Name,
                                    ["inline"] = false
                                },
                                {
                                    ["name"] = "•Stats:\n",
                                    ["value"] = "> Coins: " .. cash .. "\n> Level: " .. level,
                                    ["inline"] = false
                                },
                                {
                                    ["name"] = "• Fish Caught:\n",
                                    ["value"] = "> Name: " .. fishName,
                                    ["inline"] = false
                                }
                            },
                            ["footer"] = {
                                ["text"] = "Fishing Logger | " .. os.date("%Y-%m-%d %H:%M:%S")
                            }
                        }
                    }
                })
            end
            fishName = nil
            findingReel = true
        end
    end
end
