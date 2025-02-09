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

local desiredFish = { "Great White Shark", "Great Hammerhead Shark", "Whale Shark", "Nuke", "Orca", "Ancient Orca", "Ancient Kraken", "Kraken", "Lovestorm Eel Supercharged", "Lovestorm Eel", "Megalodon", "Ancient Megalodon", "Phantom Megalodon", "Mustard", "Long Pike", "Banana", "Treble Bass"}

local function isDesiredFish(fish)
    for _, f in pairs(desiredFish) do
        if f == fish then
            return true
        end
    end
    return false
end

local function sendWebhook(fish)
    if isDesiredFish(fish) then
        local username = lp.Name
        local leaderstats = lp:FindFirstChild("leaderstats")
        local cash = leaderstats and leaderstats:FindFirstChild("C$") and leaderstats["C$"].Value or "N/A"
        local level = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "N/A"

        local payload = {
            ["embeds"] = {
                {
                    ["title"] = "Jay Logger | Fisch",
                    ["color"] = 16755200,
                    ["fields"] = {
                        {
                            ["name"] = "•Profile:\n",
                            ["value"] = "> **Username:** " .. username,
                            ["inline"] = false
                        },
                        {
                            ["name"] = "•Stats:\n",
                            ["value"] = "> **Coins:** C$" .. cash .. "\n> **Level:** " .. level,
                            ["inline"] = false
                        },
                        {
                            ["name"] = "•Caught:\n",
                            ["value"] = "> **Name:** " .. fish,
                            ["inline"] = false
                        }
                    },
                    ["footer"] = {
                        ["text"] = "Fishing Logger | " .. os.date("%Y-%m-%d %H:%M:%S")
                    }
                }
            }
        }

        local success = pcall(function()
            return request({
                Url = webhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)

        if not success then
            jay:Notify({
                Title = "Error",
                Content = "Failed to send webhook.",
                Duration = 2
            })
        else
            jay:Notify({
                Title = "Fish Caught!",
                Content = "You caught a **" .. fish .. "**",
                Duration = 2
            })
        end
    end
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
            wait(1)
            sendWebhook(fishName)
            fishName = nil
            findingReel = true
        end
    end
end
