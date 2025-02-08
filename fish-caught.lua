local jay = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

if getgenv().JayFishingLoggerRunning then
        jay:Notify({
        Title = "Jay Logger | Fisch",
        Content = "Catch webhook is already running!",
        Duration = 2
    })
    return
end
getgenv().JayFishingLoggerRunning = true

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
local fishRarity = nil
local findingReel = true

local desiredRarities = { "Exotic", "Secret" }
local desiredFish = { "Great White Shark", "Great Hammerhead Shark", "Whale Shark", "Nuke" }

local function isDesiredRarity(rarity)
    for _, r in pairs(desiredRarities) do
        if r == rarity then
            return true
        end
    end
    return false
end

local function isDesiredFish(fish)
    for _, f in pairs(desiredFish) do
        if f == fish then
            return true
        end
    end
    return false
end

local function fetchFishRarity(fish)
    local httpService = game:GetService("HttpService")
    local apiUrl = "https://ap-is-ivory.vercel.app/api/fish-info?name=" .. fish

    spawn(function()
        local success, response = pcall(function()
            return request({
                Url = apiUrl,
                Method = "GET",
                Headers = { ["Content-Type"] = "application/json" }
            })
        end)

        if success and response and response.Body then
            local data = httpService:JSONDecode(response.Body)
            fishRarity = data.info
        else
            jay:Notify({
                Title = "Error",
                Content = "Failed to fetch fish rarity.",
                Duration = 2
            })
            fishRarity = "Unknown"
        end
    end)
end

local function sendWebhook(fish, rarity)
    if rarity and isDesiredRarity(rarity) or isDesiredFish(fish) then
        local username = lp.Name
        local coins = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Coins") and lp.leaderstats.Coins.Value or "N/A"
        local level = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Level") and lp.leaderstats.Level.Value or "N/A"

        local payload = {
            ["embeds"] = {
                {
                    ["title"] = "Jay Logger | Fisch",
                    ["color"] = 16755200,
                    ["fields"] = {
                        {
                            ["name"] = "→ Profile:",
                            ["value"] = "> **Username:** " .. username,
                            ["inline"] = false
                        },
                        {
                            ["name"] = "→ Stats:",
                            ["value"] = "> **Coins:** C$" .. coins .. "\n> **Level:** " .. level,
                            ["inline"] = false
                        },
                        {
                            ["name"] = "→ Caught:",
                            ["value"] = "> **Name:** " .. fish .. "\n> **Rarity:** " .. (rarity or "Unknown"),
                            ["inline"] = false
                        }
                    },
                    ["footer"] = {
                        ["text"] = "Fishing Logger | " .. os.date("%Y-%m-%d %H:%M:%S")
                    }
                }
            }
        }

        local success, response = pcall(function()
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
                SubContent = "Rarity: " .. (rarity or "Unknown"),
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
                        fishRarity = nil
                        fetchFishRarity(fishName)
                    end
                end
            end
        end
    elseif not findingReel then
        local reel = playerGui:FindFirstChild("reel")
        if not reel and fishName then
            wait
(1)
            sendWebhook(fishName, fishRarity)
            fishName = nil
            fishRarity = nil
            findingReel = true
        end
    end
end
