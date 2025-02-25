local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local lp = game:GetService("Players").LocalPlayer
local purchaseEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("purchase")

local webhookURL = "https://ap-is-ivory.vercel.app/api/webhook"

local function sendWebhook()
    pcall(function()
        return request({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                ["embeds"] = {
                    {
                        ["title"] = "Totem Purchase Notification",
                        ["color"] = 16711680,
                        ["fields"] = {
                            {
                                ["name"] = "• Profile:",
                                ["value"] = "> Username: " .. lp.Name,
                                ["inline"] = false
                            },
                            {
                                ["name"] = "• Stats:",
                                ["value"] = "> Coins: " .. (lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("C$") and lp.leaderstats["C$"].Value or "N/A"),
                                ["inline"] = false
                            }
                        }
                    }
                }
            })
        })
    end)
end

local function buyBait(amount)
    if purchaseEvent then
        purchaseEvent:FireServer("Bait Crate", "Fish", nil, amount)
    end
end

local function purchaseItem(selectedTotem, amount)
    if purchaseEvent then
        purchaseEvent:FireServer(selectedTotem, "Item", nil, amount)
    end
end

while true do
    buyBait(100000)
    task.wait(60)
    buyBait(100)
    task.wait(5)
    buyBait(100)
    task.wait(5)
    purchaseItem("Aurora Totem", 500)
    purchaseItem("Sundial Totem", 500)
    purchaseItem("Poseidon Wrath Totem", 500)
    sendWebhook()
    buyBait(100)
    task.wait(5)
    buyBait(100)
    task.wait(5)
    buyBait(100)
    task.wait(5)
    buyBait(100)
    task.wait(10)
end
