-----Config-----
local config = {
    loopCheck = {
        enabled = true, --True = Loop, False = Not Loop
        time = 300 -- time = 60 seconds equal 1 minute
    },
    webhookUrl = "https://ap-is-ivory.vercel.app/api/webhook" -- Discord webhook url
}
----------------

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local colorToCategory = {
    ["#919191"] = "Trash", ["#8EBBBF"] = "Common",
    ["#A1FFA9"] = "Uncommon", ["#C087C6"] = "Unusual",
    ["#776CB5"] = "Rare", ["#F0B56D"] = "Legendary",
    ["#FF3E78"] = "Mythical", ["#FFFFFF"] = "Items",
    ["#78FFB7"] = "Relic", ["#FF3F05"] = "Fragment",
    ["#AC39FF"] = "Gemstone", ["#465FD1"] = "Limited",
    ["#D5006D"] = "Exotic"
}

local categoryOrder = {
    "Items", "Trash", "Common", "Uncommon", "Unusual",
    "Rare", "Legendary", "Mythical", "Exotic",
    "Relic", "Fragment", "Gemstone", "Limited"
}

local function colorToHex(color3)
    return string.format("#%02X%02X%02X", color3.R * 255, color3.G * 255, color3.B * 255)
end

local function findItem(obj, ...)
    for _, key in ipairs({...}) do
        if obj then obj = obj[key] else return nil end
    end
    return obj
end

local function sendToDiscord(content, embeds)
    local payload = HttpService:JSONEncode({
        content = content,
        embeds = embeds or {},
        username = "Jay Fisch Notifier"
    })
    pcall(function()
        http_request({
            Url = config.webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
end

local function getItem()
    local player = Players.LocalPlayer
    local scrollArea = findItem(player:FindFirstChild("PlayerGui"), "hud", "safezone", "backpack", "inventory", "scroll")
    local itemColors = {}
   
    if scrollArea then
        for _, element in ipairs(scrollArea:GetDescendants()) do
            if element.Name == "hover" and element.ImageColor3 then
                local category = colorToCategory[colorToHex(element.ImageColor3)] or "Exotic"
                if not itemColors[category] then itemColors[category] = {} end
                local itemName = element.Parent.Name
                itemColors[category][itemName] = (itemColors[category][itemName] or 0) + 1
            end
        end
    end
    return itemColors
end

local function getRods()
    local player = Players.LocalPlayer
    local playerGui = player:FindFirstChild("PlayerGui")
    local rods = {}
    
    local scrollArea = findItem(playerGui, "hud", "safezone", "equipment", "rods", "scroll", "safezone")
    if scrollArea then
        for _, element in ipairs(scrollArea:GetDescendants()) do
            if element.ClassName == "Frame" and element.Parent.Name == "safezone" then
                local bg2 = element:FindFirstChild("bg2")
                if bg2 then
                    table.insert(rods, element.Name)
                end
            end
        end
    end
    return rods
end

local function main()
    local player = Players.LocalPlayer
    local rods = getRods()
    local rodsItem = ""
    
    if #rods > 0 then
        rodsItem = "\n## :fishing_pole_and_fish: ** Rods:**\n"
        for _, rodName in ipairs(rods) do
            rodsItem = rodsItem .. "💎 " .. rodName .. "\n"
        end
    end

    local messageContent = string.format(
        "## :bust_in_silhouette: **%s**\n## 💰 **Money: %s**\n## 📊 **Level: %s**%s\n\n",
        player.Name,
        player.leaderstats["C$"].Value,
        player.leaderstats.Level.Value,
        rodsItem
    )

    local itemColors = getItem()
    if next(itemColors) == nil then
        sendToDiscord(messageContent .. "**No items found in inventory!**")
        return
    end

    local embeds = {}
    for _, category in ipairs(categoryOrder) do
        local items = itemColors[category]
        if items then
            local description = ""
            for itemName, count in pairs(items) do
                description = description .. itemName .. " **[ x" .. count .. " ]**\n"
            end

            local categoryColor = ""
            for hex, cat in pairs(colorToCategory) do
                if cat == category then categoryColor = hex break end
            end
           
            local title = ":tropical_fish: ".. category
            if category == "Exotic" then
                title = "**" .. category .. "**"
            end

            table.insert(embeds, {
                title = title,
                description = description,
                color = tonumber((categoryColor ~= "" and categoryColor or "#FFFFFF"):sub(2), 16)
            })
        end
    end

    sendToDiscord(messageContent, embeds)
end

if config.loopCheck.enabled then
    while true do
        main()
        task.wait(config.loopCheck.time)
    end
else
    main()
end
