--// CONFIG
local TARGET_NAME = "Bashing Necklace"
local TARGET_RARITY = 6 -- Mythic (sesuaikan)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1494106499813871746/Z9rtE4dFtr_nBrNSdwQTQyJk7wkX8YTj7hU5JMVXL0CSZ5lM3pVMouUnP3iHMN3HiaJ2"

--// SERVICES
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local Auctions = require(ReplicatedStorage.Systems.Auctions)
local Items = require(ReplicatedStorage.Systems.Items)

local player = Players.LocalPlayer

--// STATE
local sniperEnabled = false
local antiAfkEnabled = false

--// WEBHOOK FUNCTION
local function sendWebhook(itemName, price, rarity)
    local data = {
        ["content"] = "**SNIPED ITEM**",
        ["embeds"] = {{
            ["title"] = itemName,
            ["description"] = "Price: " .. price .. "\nRarity: " .. rarity,
            ["color"] = 65280
        }}
    }

    pcall(function()
        HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

--// SNIPER LOOP (SUPER CEPAT)
task.spawn(function()
    while true do
        if sniperEnabled then
            local auctionFolder = ReplicatedStorage:FindFirstChild("AuctionItems")

            if auctionFolder then
                for _, item in pairs(auctionFolder:GetChildren()) do
                    if not item:GetAttribute("Sold") then
                        
                        local name = item.Name
                        local price = item:GetAttribute("Price")
                        local rarity = Items:GetRarity(item)

                        if name == TARGET_NAME and rarity == TARGET_RARITY then
                            
                            print("🔥 SNIPED:", name, price)

                            -- BUY
                            pcall(function()
                                Auctions:PurchaseItem(player, item:GetAttribute("Id"))
                            end)

                            -- WEBHOOK
                            sendWebhook(name, price, rarity)
                        end
                    end
                end
            end
        end
        
        task.wait(0.05) -- 20x per detik
    end
end)

--// ANTI AFK SYSTEM
player.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Parent = ScreenGui

-- SNIPER BUTTON
local SniperButton = Instance.new("TextButton")
SniperButton.Size = UDim2.new(1, 0, 0.5, 0)
SniperButton.Text = "SNIPER: OFF"
SniperButton.TextColor3 = Color3.new(1,1,1)
SniperButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
SniperButton.Parent = Frame

SniperButton.MouseButton1Click:Connect(function()
    sniperEnabled = not sniperEnabled

    if sniperEnabled then
        SniperButton.Text = "SNIPER: ON"
        SniperButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        SniperButton.Text = "SNIPER: OFF"
        SniperButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    end
end)

-- ANTI AFK BUTTON
local AntiAfkButton = Instance.new("TextButton")
AntiAfkButton.Size = UDim2.new(1, 0, 0.5, 0)
AntiAfkButton.Position = UDim2.new(0, 0, 0.5, 0)
AntiAfkButton.Text = "ANTI AFK: OFF"
AntiAfkButton.TextColor3 = Color3.new(1,1,1)
AntiAfkButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
AntiAfkButton.Parent = Frame

AntiAfkButton.MouseButton1Click:Connect(function()
    antiAfkEnabled = not antiAfkEnabled

    if antiAfkEnabled then
        AntiAfkButton.Text = "ANTI AFK: ON"
        AntiAfkButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        AntiAfkButton.Text = "ANTI AFK: OFF"
        AntiAfkButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    end
end)
