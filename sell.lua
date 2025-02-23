local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sellEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("SellAll")

local function buyAndSell()
    if sellEvent then
        for i = 1, 10 do
            sellEvent:InvokeServer()
        end
    end
end

while true do
    buyAndSell()
    task.wait(0.5)
end
