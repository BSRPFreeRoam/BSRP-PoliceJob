local cuffed = {} -- [src] = true
local jailed = {} -- [src] = releaseGameTimer

local function getPlayer(src)
    if GetResourceState('bsrp') ~= 'started' then return nil end
    return exports.bsrp:GetPlayer(src)
end

local function jobType(job)
    if GetResourceState('bsrp') ~= 'started' then return 'civ' end
    return exports.bsrp:GetJobType(job) or 'civ'
end

local function isLeoPlayer(player)
    if not player then return false end
    if Config.LeoJobs and Config.LeoJobs[player.job] then return true end
    return jobType(player.job) == 'leo'
end

local function notify(src, msg, nType)
    TriggerClientEvent('bsrp:client:notify', src, msg, nType or 'info')
end

local function registerStashes()
    if GetResourceState('ox_inventory') ~= 'started' then return end
    pcall(function()
        exports.ox_inventory:RegisterStash('police_trash', 'Police Trash', 50, 200000, false)
        for i = 1, 5 do
            exports.ox_inventory:RegisterStash('police_evidence_' .. i, 'Evidence Locker #' .. i, 100, 500000, false)
        end
    end)
end

CreateThread(function()
    Wait(1000)
    registerStashes()
end)

local function updateBlips()
    local list = {}
    for src, player in pairs(exports.bsrp:GetPlayers() or {}) do
        if isLeoPlayer(player) and player.duty then
            local ped = GetPlayerPed(src)
            local coords = ped and ped ~= 0 and GetEntityCoords(ped) or nil
            list[#list + 1] = {
                src = src,
                label = ('%s | %s'):format(player.name or 'Unit', player.job_label or player.job),
                coords = coords and { x = coords.x, y = coords.y, z = coords.z } or nil,
            }
        end
    end
    for src, player in pairs(exports.bsrp:GetPlayers() or {}) do
        if isLeoPlayer(player) and player.duty then
            TriggerClientEvent('bsrp-police:client:updateBlips', src, list)
        end
    end
end

RegisterNetEvent('bsrp-police:server:updateCops', function()
    updateBlips()
end)

RegisterNetEvent('bsrp-police:server:setCuff', function(state)
    local src = source
    cuffed[src] = state and true or false
end)

RegisterNetEvent('bsrp-police:server:armory', function(item, amount)
    local src = source
    local player = getPlayer(src)
    if not player or not isLeoPlayer(player) or not player.duty then
        notify(src, 'On-duty LEO only', 'error')
        return
    end
    amount = tonumber(amount) or 1
    local grade = player.job_grade or 0
    local allowed = false
    for _, entry in ipairs(Config.Armory) do
        if entry.name == item and grade >= (entry.grade or 0) then
            allowed = true
            break
        end
    end
    if not allowed then
        notify(src, 'Not authorized for that item', 'error')
        return
    end
    if GetResourceState('ox_inventory') ~= 'started' then return end
    local ok = exports.ox_inventory:AddItem(src, item, amount)
    if ok then
        notify(src, ('Issued %sx %s'):format(amount, item), 'success')
    else
        notify(src, 'Could not issue item (inventory full?)', 'error')
    end
end)

RegisterNetEvent('bsrp-police:server:openStash', function(kind, index)
    local src = source
    local player = getPlayer(src)
    if not player or not isLeoPlayer(player) or not player.duty then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end

    if kind == 'personal' then
        local id = 'police_locker_' .. tostring(player.identifier or src):gsub('[^%w_]', '_')
        pcall(function()
            exports.ox_inventory:RegisterStash(id, 'Police Locker', 50, 100000, true)
        end)
        TriggerClientEvent('bsrp-police:client:openStash', src, id)
    elseif kind == 'trash' then
        TriggerClientEvent('bsrp-police:client:openStash', src, 'police_trash')
    elseif kind == 'evidence' then
        local id = 'police_evidence_' .. tostring(index or 1)
        TriggerClientEvent('bsrp-police:client:openStash', src, id)
    end
end)

RegisterNetEvent('bsrp-police:server:fingerprint', function(target)
    local src = source
    local player = getPlayer(src)
    local other = getPlayer(target)
    if not player or not isLeoPlayer(player) or not player.duty then return end
    if not other then
        notify(src, 'Target offline', 'error')
        return
    end
    TriggerClientEvent('bsrp-police:client:showFingerprint', src, {
        name = other.name or 'Unknown',
        id = other.identifier or tostring(target),
        job = other.job_label or other.job or 'Civilian',
        cid = other.id or target,
    })
end)

-- Jail timer release
CreateThread(function()
    while true do
        Wait(15000)
        local now = os.time()
        for src, releaseAt in pairs(jailed) do
            if now >= releaseAt then
                jailed[src] = nil
                if getPlayer(src) then
                    TriggerClientEvent('bsrp-police:client:unjail', src)
                    exports.bsrp:SetMetadata(src, 'injail', 0)
                    notify(src, 'Jail time served', 'success')
                end
            end
        end
        if GetResourceState('bsrp') == 'started' then
            updateBlips()
        end
    end
end)

RegisterNetEvent('bsrp-police:server:jail', function(target, minutes)
    local src = source
    local player = getPlayer(src)
    local other = getPlayer(target)
    if not player or not isLeoPlayer(player) or not player.duty then return end
    if not other then
        notify(src, 'Target offline', 'error')
        return
    end
    minutes = math.min(math.max(tonumber(minutes) or 1, 1), Config.Jail.maxMinutes)
    jailed[target] = os.time() + (minutes * 60)
    exports.bsrp:SetMetadata(target, 'injail', minutes)
    TriggerClientEvent('bsrp-police:client:jail', target, minutes)
    notify(src, ('Jailed %s for %s min'):format(other.name, minutes), 'success')
    notify(target, ('You were jailed for %s minutes'):format(minutes), 'error')
end)

RegisterNetEvent('bsrp-police:server:unjail', function(target)
    local src = source
    local player = getPlayer(src)
    if not player or not isLeoPlayer(player) or not player.duty then return end
    target = tonumber(target)
    if not target or not getPlayer(target) then return end
    jailed[target] = nil
    exports.bsrp:SetMetadata(target, 'injail', 0)
    TriggerClientEvent('bsrp-police:client:unjail', target)
    notify(src, 'Player unjailed', 'success')
end)

RegisterNetEvent('bsrp-police:server:fine', function(target, amount)
    local src = source
    local player = getPlayer(src)
    local other = getPlayer(target)
    if not player or not isLeoPlayer(player) then
        notify(src, 'LEO only', 'error')
        return
    end
    if not other then
        notify(src, 'Target offline', 'error')
        return
    end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        notify(src, 'Invalid amount', 'error')
        return
    end
    if src == target then
        notify(src, 'Cannot fine yourself', 'error')
        return
    end
    local removed = exports.bsrp:RemoveMoney(target, 'bank', amount, 'police-fine')
    if not removed then
        removed = exports.bsrp:RemoveMoney(target, 'cash', amount, 'police-fine')
    end
    if removed then
        notify(src, ('Fined $%s'):format(amount), 'success')
        notify(target, ('You were fined $%s by %s'):format(amount, player.name), 'error')
    else
        notify(src, 'Target could not pay', 'error')
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    cuffed[src] = nil
    jailed[src] = nil
end)

exports('IsCuffed', function(src)
    return cuffed[src] == true
end)
