local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
local sharedItems = exports['qb-core']:GetShared('Items')

local Recieve = {
    { item = 'metalscrap', min = 5, max = 7 },
    { item = 'plastic',    min = 5, max = 7 },
    { item = 'copper',     min = 5, max = 7 },
    { item = 'rubber',     min = 5, max = 7 },
    { item = 'iron',       min = 5, max = 7 },
    { item = 'aluminum',   min = 5, max = 7 },
    { item = 'steel',      min = 5, max = 7 },
    { item = 'glass',      min = 5, max = 7 },
}
local luckyItem = 'cryptostick' -- Item to be given as a lucky item
local maxRecieved = 3           -- Max items to be received
local dropLocation = Config.DropLocation
local LuckyItemChance = 5      -- 20% chance to get a lucky item
local uhohs = {}
local Sales, Stock, salesLoc = {}, {}, Config.SellPed


if Config.SellMaterials then
    Sales = { -- key is item, value is price
        metalscrap = 200,
        plastic = 200,
        copper = 200,
        rubber = 200,
        iron = 200,
        aluminum = 200,
        steel = 200,
        glass = 200,
    }
end
if Config.LimitedMaterials then
    Stock = { -- key is item, value is stock at restart
        metalscrap = 30000,
        plastic = 30000,
        copper = 30000,
        rubber = 30000,
        iron = 30000,
        aluminum = 30000,
        steel = 30000,
        glass = 30000,
    }
end


local function exploitKick(id, reason)
    local Player = exports['qb-core']:GetPlayer(id)
    if Player then
        uhohs[Player.PlayerData.citizenid] = nil
    end
    uhohs[id] = nil
    TriggerEvent('qb-log:server:CreateLog', 'recyclejob', 'Player Kicked', 'orange',
        string.format('%s was kicked by %s for %s', GetPlayerName(id), 'qb-recyclejob', reason), true)
    DropPlayer(id, 'リサイクル施設で不正な操作が検出されたためキックされました。')
end

local function isClose(source, loc)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or not Player.PlayerData then return false end

    local playerPed = GetPlayerPed(source)
    if not playerPed or playerPed == 0 then return false end

    local cid = Player.PlayerData.citizenid
    local playerCoords = GetEntityCoords(playerPed)
    local distance = nil

    if loc == 'turnIn' then
        distance = #(playerCoords - vector3(dropLocation.x, dropLocation.y, dropLocation.z))
    elseif loc == 'sell' then
        distance = #(playerCoords - vector3(salesLoc.x, salesLoc.y, salesLoc.z))
    else
        return false
    end

    if distance < 5.0 then
        return true
    else
        uhohs[cid] = (uhohs[cid] or 0) + 1
        if uhohs[cid] >= 3 then
            exploitKick(source, 'Exploiting distance on qb-recyclejob')
        end
        return false
    end
end

QBCore.Functions.CreateCallback('qb-recyclejob:server:getPriceList', function(source, cb)
    local src = source
    if not isClose(src, 'sell') then return false end
    cb(Sales)
end)

local function adjustStock(item, change, amount)
    if not Config.LimitedMaterials then return end
    if change == 'add' then
        Stock[item] = Stock[item] + amount
    elseif change == 'remove' then
        Stock[item] = Stock[item] - amount
    end
end

local function checkStock(source, item, amount)
    if not Config.LimitedMaterials then return true end
    if Stock[item] >= amount then
        return true
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.out_of_stock', { item = item }), 'error')
        return false
    end
end

local function sellMaterials(src, item, amount)
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end

    local price = Sales[item] * amount
    local has = Player.GetItemByName(item)
    if has and has.amount < amount then
        amount = has.amount
        price = Sales[item] * amount
    end
    if Player.RemoveItem(item, amount) then
        Player.AddMoney('cash', price)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.sold', { amount = amount, item = sharedItems[item].label, price = price }), 'success')
        adjustStock(item, 'add', amount)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.nothing_to_sell'), 'error')
        return
    end
end

local function addRecycleItem(src, item, amount, suppressNotify)
    local success = exports.ox_inventory:AddItem(src, item, amount)
    if not success then
        if not suppressNotify then
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.cannot_carry'), 'error')
        end
        return false
    end
    return true
end

RegisterNetEvent('qb-recyclejob:server:getItem', function()
    local src = source
    if not isClose(src, 'turnIn') then
        if not uhohs[src] then
            uhohs[src] = 1
            return
        end
        uhohs[src] = (uhohs[src] or 0) + 1
        if uhohs[src] >= 3 then
            exploitKick(src, 'Exploiting distance on qb-recyclejob')
        end
        return
    end
    local itemAmountRecieved = math.random(1, maxRecieved)
    local carryFailed = false

    repeat
        Wait(1)
        local reward = Recieve[math.random(1, #Recieve)]
        local itemAmount = math.random(reward.min, reward.max)
        itemAmountRecieved = itemAmountRecieved - 1

        if Config.LimitedMaterials then
            if checkStock(src, reward.item, itemAmount) then
                if addRecycleItem(src, reward.item, itemAmount, carryFailed) then
                    adjustStock(reward.item, 'remove', itemAmount)
                else
                    carryFailed = true
                end
            end
        elseif not addRecycleItem(src, reward.item, itemAmount, carryFailed) then
            carryFailed = true
        end
    until itemAmountRecieved == 0

    local luckyChance = math.random(1, 100)
    if luckyChance <= LuckyItemChance then
        addRecycleItem(src, luckyItem, 1, carryFailed)
    end
end)

RegisterNetEvent('qb-recyclejob:server:sellItem', function(item, amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end
    if not isClose(src, 'sell') then return end
    if not Sales[item] then return end
    if Config.SellMaterials then
        sellMaterials(src, item, amount)
    end
end)
