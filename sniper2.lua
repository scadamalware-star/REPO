--// CONFIG
local TARGET_NAME = "Bashing Necklace"
local TARGET_RARITY = 6 -- Mythic (sesuaikan jika beda)
local WEBHOOK_URL = "MASUKKAN_WEBHOOK_KAMU"

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

--// BLACK SCREEN (tidak ganggu GUI)
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "SniperUI"
screenGui.ResetOnSpawn = false

local black = Instance.new("Frame", screenGui)
black.Size = UDim2.new(1,0,1,0)
black.BackgroundColor3 = Color3.new(0,0,0)
black.BackgroundTransparency = 0.4
black.ZIndex = 0

--// GUI
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0,20,0,100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.ZIndex = 10

local toggleSniper = Instance.new("TextButton", frame)
toggleSniper.Size = UDim2.new(1,0,0,40)
toggleSniper.Text = "Sniper: OFF"
toggleSniper.BackgroundColor3 = Color3.fromRGB(100,0,0)

local toggleAFK = Instance.new("TextButton", frame)
toggleAFK.Size = UDim2.new(1,0,0,40)
toggleAFK.Position = UDim2.new(0,0,0,40)
toggleAFK.Text = "Anti AFK: OFF"
toggleAFK.BackgroundColor3 = Color3.fromRGB(100,0,0)

--// TOGGLES
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

--// SCAN AWAL (hindari deteksi item lama)
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

    -- FILTER TARGET
    if name == TARGET_NAME and rarity == TARGET_RARITY then
        
        -- LOG
        sendWebhook("🔥 SNIPED ITEM!\nName: "..name..
            "\nPrice: "..tostring(price)..
            "\nRarity: "..tostring(rarity))

        -- AUTO BUY
        pcall(function()
            Auctions:PurchaseItem(player, id)
        end)
    end
end

--// EVENT (REALTIME)
AuctionItems.ChildAdded:Connect(function(item)
    task.wait(0.05) -- biar attribute kebaca
    checkItem(item)
end)

--// OPTIONAL: MICRO LOOP (super cepat, optional)
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
