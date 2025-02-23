local ReplicatedStorage = game:GetService("ReplicatedStorage")
local purchaseEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("purchase")

local function buyBait(amount)
    if purchaseEvent then
        purchaseEvent:FireServer("Bait Crate", "Fish", nil, amount)
    end
end

local function purchaseItem(selectedTotem, amount)
    if purchaseEvent and selectedTotem and amount and amount > 0 then
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
    purchaseItem("Aurora Totem", 100)
    purchaseItem("Sundial Totem", 100)
    purchaseItem("Poseidon Wrath Totem", 100)
    task.wait(5)
    buyBait(100)
    task.wait(10)
end
