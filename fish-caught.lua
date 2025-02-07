local lp = game.Players.LocalPlayer
local playerGui = lp:FindFirstChild("PlayerGui")

local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"
local fishName = nil
local findingReel = true

local desiredRarities = { "Exotic", "Secret" }
local desiredFish = { "Great White Shark", "Great Hammerhead Shark", "Whale Shark", "Nuke" }

local rarityLookup, fishLookup = {}, {}
for _, v in ipairs(desiredRarities) do rarityLookup[v] = true end
for _, v in ipairs(desiredFish) do fishLookup[v] = true end

-- Function to get fish rarity from API
local function getFishRarity(fish)
    local httpService = game:GetService("HttpService")
    local apiUrl = "https://ap-is-ivory.vercel.app/api/fish-info?name=" .. fish

    local success, response = pcall(function()
        return httpService:GetAsync(apiUrl)
    end)

    if success then
        local data = httpService:JSONDecode(response)
        return data.info or "Unknown"
    end

    warn("Failed to fetch fish rarity:", response)
    return "Unknown"
end

local function sendWebhook(fish)
    local rarity = getFishRarity(fish)
    if rarityLookup[rarity] or fishLookup[fish] then
        local payload = {
            ["content"] = string.format("🎣 **Jay Fisch Catch**\n🐟 You caught: **%s**!\n🌟 Rarity: **%s**", fish, rarity)
        }

        local success, response = pcall(function()
            return (syn and syn.request or request)({
                Url = webhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)

        if not success then warn("Webhook failed:", response) end
    end
end

while true do
    wait(0.5)

    local reel = playerGui and playerGui:FindFirstChild("reel")
    if findingReel and reel then
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
        findingReel = false
    elseif not findingReel then
        if not playerGui:FindFirstChild("reel") and fishName then
            sendWebhook(fishName)
            fishName, findingReel = nil, true
        end
    end
end
