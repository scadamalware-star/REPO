--================ CONFIG ================--
local WEBHOOK_URL = "https://discord.com/api/webhooks/1494567227381256335/N6RX7FM8IQOC_eXqUqkJgT3Q3tPDWurRe1aNMjD0ChT4jgRLJIwpBmPWrBh7Nxxs4kAT"
local CHECK_DELAY = 0.5
local MIN_RARITY = 5 -- 5 = Legendary, 6 = Mythic (ubah sesuai game kamu)

--================ SERVICES ================--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- module item (WAJIB ADA di game kamu)
local Items = require(ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Items"))

local AuctionItems = ReplicatedStorage:WaitForChild("AuctionItems")

--================ DATA ================--
local trackedItems = {}
local lastSent = {}

--================ WEBHOOK FUNCTION ================--
local function sendWebhook(itemName, rarity, amount)
    local data = {
        ["content"] = "@everyone 🔥 RARE ITEM DETECTED!",
        ["embeds"] = {{
            ["title"] = itemName,
            ["description"] = "Item langka baru muncul di auction!",
            ["color"] = 16711680,
            ["fields"] = {
                {
                    ["name"] = "Rarity",
                    ["value"] = tostring(rarity),
                    ["inline"] = true
                },
                {
                    ["name"] = "Jumlah",
                    ["value"] = tostring(amount),
                    ["inline"] = true
                }
            }
        }}
    }

    local json = HttpService:JSONEncode(data)

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = json
        })
    end)
end

--================ GET CURRENT STATE ================--
local function getCurrentItems()
    local current = {}

    for _, item in pairs(AuctionItems:GetChildren()) do
        if not item:GetAttribute("Sold") then
            current[item.Name] = current[item.Name] or {
                count = 0,
                rarity = 0
            }

            current[item.Name].count += 1

            -- ambil rarity
            local rarity = Items:GetRarity(item)
            current[item.Name].rarity = rarity
        end
    end

    return current
end

--================ INIT ================--
trackedItems = getCurrentItems()

print("✅ Rare Detector Started...")

--================ LOOP DETECTOR ================--
task.spawn(function()
    while true do
        task.wait(CHECK_DELAY)

        local currentItems = getCurrentItems()

        for itemName, data in pairs(currentItems) do
            local prevData = trackedItems[itemName]
            local prevCount = prevData and prevData.count or 0

            -- 🔥 KONDISI UTAMA
            if prevCount == 0 and data.count > 0 then

                -- filter rarity
                if data.rarity >= MIN_RARITY then

                    -- anti spam (10 detik)
                    if not lastSent[itemName] or tick() - lastSent[itemName] > 10 then
                        
                        print("🔥 RARE DETECTED:", itemName, "| Rarity:", data.rarity)

                        sendWebhook(itemName, data.rarity, data.count)

                        lastSent[itemName] = tick()
                    end
                end
            end
        end

        -- update state
        trackedItems = currentItems
    end
end)
