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

    spawn(function() -- Runs the request asynchronously
        local success, response = pcall(function()
            return request({
                Url = apiUrl,
                Method = "GET",
                Headers = { ["Content-Type"] = "application/json" }
            })
        end)

        if success and response and response.Body then
            local data = httpService:JSONDecode(response.Body)
            fishRarity = data.info -- Store rarity instantly
        else
            warn("Failed to fetch fish rarity:", response and response.Body or "No response")
            fishRarity = "Unknown"
        end
    end)
end

local function sendWebhook(fish, rarity)
    if rarity and isDesiredRarity(rarity) or isDesiredFish(fish) then
        local payload = {
            ["content"] = "🎣 **Jay Fisch Catch**\n🐟 You caught: **" .. fish .. "**!\n🌟 Rarity: **" .. (rarity or "Unknown") .. "**"
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
            warn("Failed to send webhook:", response and response.Body or "No response")
        end
    else
        print("Caught fish does not match criteria:", fish, "(", rarity or "Unknown", ")")
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
                        fishRarity = nil -- Reset rarity before fetching
                        fetchFishRarity(fishName) -- Start fetching rarity immediately
                    end
                end
            end
        end
    elseif not findingReel then
        local reel = playerGui:FindFirstChild("reel")
        if not reel and fishName then
            wait(1) -- Give time for API response if it's still pending
            sendWebhook(fishName, fishRarity)
          
            fishName = nil
            fishRarity = nil
            findingReel = true
        end
    end
end
