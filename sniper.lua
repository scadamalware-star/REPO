--// WAIT GAME
repeat task.wait() until game:IsLoaded()

--// CONFIG
local TARGET_NAME = "Bashing Necklace"
local TARGET_RARITY = 6 -- Mythic
local WEBHOOK_URL = "https://discord.com/api/webhooks/1494106499813871746/Z9rtE4dFtr_nBrNSdwQTQyJk7wkX8YTj7hU5JMVXL0CSZ5lM3pVMouUnP3iHMN3HiaJ2"

--// SERVICES
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local Auctions = require(ReplicatedStorage.Systems.Auctions)
local Items = require(ReplicatedStorage.Systems.Items)

local player = Players.LocalPlayer

--// STATE
local sniperEnabled = false
local antiAfkEnabled = false
local blackEnabled = false
local renderEnabled = true

--// WEBHOOK
local function sendWebhook(name, price, rarity)
    local data = {
        ["content"] = "**SNIPED ITEM**",
        ["embeds"] = {{
            ["title"] = name,
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

--// SNIPER LOOP
task.spawn(function()
    while true do
        if sniperEnabled then
            local folder = ReplicatedStorage:FindFirstChild("AuctionItems")

            if folder then
                for _, item in pairs(folder:GetChildren()) do
                    if not item:GetAttribute("Sold") then
                        local name = item.Name
                        local price = item:GetAttribute("Price")
                        local rarity = Items:GetRarity(item)

                        if name == TARGET_NAME and rarity == TARGET_RARITY then
                            print("🔥 SNIPED:", name, price)

                            pcall(function()
                                Auctions:PurchaseItem(player, item:GetAttribute("Id"))
                            end)

                            sendWebhook(name, price, rarity)
                        end
                    end
                end
            end
        end

        task.wait(0.05)
    end
end)

--// ANTI AFK
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
Frame.Size = UDim2.new(0, 200, 0, 180)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Parent = ScreenGui

-- BUTTON TEMPLATE FUNCTION
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0.25, 0)
    btn.Position = UDim2.new(0, 0, posY, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.Parent = Frame
    return btn
end

-- SNIPER BUTTON
local sniperBtn = createButton("SNIPER: OFF", 0)
sniperBtn.MouseButton1Click:Connect(function()
    sniperEnabled = not sniperEnabled
    sniperBtn.Text = sniperEnabled and "SNIPER: ON" or "SNIPER: OFF"
    sniperBtn.BackgroundColor3 = sniperEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

-- ANTI AFK BUTTON
local afkBtn = createButton("ANTI AFK: OFF", 0.25)
afkBtn.MouseButton1Click:Connect(function()
    antiAfkEnabled = not antiAfkEnabled
    afkBtn.Text = antiAfkEnabled and "ANTI AFK: ON" or "ANTI AFK: OFF"
    afkBtn.BackgroundColor3 = antiAfkEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

-- BLACK SCREEN
local blackFrame = nil
local blackBtn = createButton("BLACK SCREEN: OFF", 0.5)

blackBtn.MouseButton1Click:Connect(function()
    blackEnabled = not blackEnabled

    if blackEnabled then
        blackBtn.Text = "BLACK SCREEN: ON"
        blackBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)

        blackFrame = Instance.new("Frame")
        blackFrame.Size = UDim2.new(1,0,1,0)
        blackFrame.BackgroundColor3 = Color3.new(0,0,0)
        blackFrame.BorderSizePixel = 0
        blackFrame.Parent = ScreenGui
    else
        blackBtn.Text = "BLACK SCREEN: OFF"
        blackBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)

        if blackFrame then
            blackFrame:Destroy()
            blackFrame = nil
        end
    end
end)

-- RENDER TOGGLE
local renderBtn = createButton("RENDER: ON", 0.75)

renderBtn.MouseButton1Click:Connect(function()
    renderEnabled = not renderEnabled
    RunService:Set3dRenderingEnabled(renderEnabled)

    renderBtn.Text = renderEnabled and "RENDER: ON" or "RENDER: OFF"
    renderBtn.BackgroundColor3 = renderEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)
