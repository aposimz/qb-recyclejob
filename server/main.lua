local QBCore = exports['qb-core']:GetCoreObject()

-- Events

RegisterNetEvent('qb-recyclejob:server:getItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- ox_inventory用重量オーバー対策 nekot
    local function AddRecycleItem(itemName, amount)
        local playerInv = exports.ox_inventory:GetInventory(src)
        
        if not playerInv then
            print(string.format('[qb-recyclejob] ERROR: Could not get inventory for player %s', src))
            return
        end

        local currentWeight = playerInv.weight
        local maxWeight = playerInv.maxWeight

        -- print(string.format('[qb-recyclejob] Pre-Check LOG (New Logic): Player %s - Current: %s, Max: %s (Checking if Current < Max). Item: %s x%d',
        --    src, tostring(currentWeight), tostring(maxWeight), itemName, amount))

        if currentWeight < maxWeight then
            -- print(string.format('[qb-recyclejob] Pre-Check PASSED (Current < Max). Attempting to add item %s x%d via ox_inventory', itemName, amount))
            exports.ox_inventory:AddItem(src, itemName, amount)
        else
            -- print(string.format('[qb-recyclejob] Pre-Check FAILED (Current >= Max). Did NOT attempt to add item %s x%d', itemName, amount))
            QBCore.Functions.Notify(src, "これ以上持てません", "error")
        end
    end

    -- Add random items from table
    for _ = 1, math.random(1, Config.MaxItemsReceived), 1 do
        local randItem = Config.ItemTable[math.random(1, #Config.ItemTable)]
        local amount = math.random(Config.MinItemReceivedQty, Config.MaxItemReceivedQty)
        AddRecycleItem(randItem, amount)
        Wait(500)
    end

    -- Add chance item
    local chance = math.random(1, 100)
    if chance < 7 then
        AddRecycleItem(Config.ChanceItem, 1)
    end

    -- Add lucky item
    local luck = math.random(1, 10)
    local odd = math.random(1, 10)
    if luck == odd then
        local random = math.random(1, 3)
        AddRecycleItem(Config.LuckyItem, random)
    end
end)
