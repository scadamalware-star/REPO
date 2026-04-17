--// CONFIG
local TARGET_NAME = "Bashing Necklace"
local TARGET_RARITY = 6 -- Mythic (sesuaikan jika beda)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1494567227381256335/N6RX7FM8IQOC_eXqUqkJgT3Q3tPDWurRe1aNMjD0ChT4jgRLJIwpBmPWrBh7Nxxs4kAT"

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local AuctionItems = ReplicatedStorage:WaitForChild("AuctionItems")

--// MODULES
local Items = require(ReplicatedStorage.Systems.Items)
local Auctions = require(ReplicatedStorage.Systems.Auctions)

--// STATE
local seenItems = {}
local sniperON = false
local antiAFK = false

--// WEBHOOK
local function sendWebhook(msg)
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = msg
            })
        })
    end)
end

--// ANTI AFK
player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

--// GUI ROOT
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SniperUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10
screenGui.Parent = player:WaitForChild("PlayerGui")

--// BLACK SCREEN (AMAN)
local black = Instance.new("Frame")
black.Size = UDim2.new(1,0,1,0)
black.BackgroundColor3 = Color3.new(0,0,0)
black.BackgroundTransparency = 0.5 -- tidak nutup total
black.ZIndex = 1
black.Parent = screenGui

--// MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0,20,0,100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.ZIndex = 100
frame.Parent = screenGui

--// TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,20)
title.Text = "SNIPER PANEL"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.ZIndex = 101

--// BUTTON SNIPER
local toggleSniper = Instance.new("TextButton", frame)
toggleSniper.Size = UDim2.new(1,0,0,40)
toggleSniper.Position = UDim2.new(0,0,0,20)
toggleSniper.Text = "Sniper: OFF"
toggleSniper.BackgroundColor3 = Color3.fromRGB(100,0,0)
toggleSniper.ZIndex = 101

--// BUTTON AFK
local toggleAFK = Instance.new("TextButton", frame)
toggleAFK.Size = UDim2.new(1,0,0,40)
toggleAFK.Position = UDim2.new(0,0,0,60)
toggleAFK.Text = "Anti AFK: OFF"
toggleAFK.BackgroundColor3 = Color3.fromRGB(100,0,0)
toggleAFK.ZIndex = 101

--// TOGGLE FUNCTION
toggleSniper.MouseButton1Click:Connect(function()
    sniperON = not sniperON
    toggleSniper.Text = "Sniper: "..(sniperON and "ON" or "OFF")
    toggleSniper.BackgroundColor3 = sniperON and Color3.fromRGB(0,150,0) or Color3.fromRGB(100,0,0)
end)

toggleAFK.MouseButton1Click:Connect(function()
    antiAFK = not antiAFK
    toggleAFK.Text = "Anti AFK: "..(antiAFK and "ON" or "OFF")
    toggleAFK.BackgroundColor3 = antiAFK and Color3.fromRGB(0,150,0) or Color3.fromRGB(100,0,0)
end)

--// SCAN AWAL
for _, item in pairs(AuctionItems:GetChildren()) do
    local id = item:GetAttribute("Id")
    if id then
        seenItems[id] = true
    end
end

--// CHECK ITEM
local function checkItem(item)
    if not sniperON then return end

    local id = item:GetAttribute("Id")
    if not id or seenItems[id] then return end
    seenItems[id] = true

    local name = item.Name
    local price = item:GetAttribute("Price")
    local rarity = Items:GetRarity(item)

    if name == TARGET_NAME and rarity == TARGET_RARITY then
        
        sendWebhook("🔥 SNIPED ITEM!\nName: "..name..
            "\nPrice: "..tostring(price)..
            "\nRarity: "..tostring(rarity))

        pcall(function()
            Auctions:PurchaseItem(player, id)
        end)
    end
end

--// EVENT REALTIME
AuctionItems.ChildAdded:Connect(function(item)
    task.wait(0.05)
    checkItem(item)
end)

--// MICRO LOOP (OPSIONAL CEPAT)
task.spawn(function()
    while true do
        if sniperON then
            for _, item in pairs(AuctionItems:GetChildren()) do
                checkItem(item)
            end
        end
        task.wait(0.1)
    end
end)
