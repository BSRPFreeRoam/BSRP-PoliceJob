local cuffed = {}

local function getPlayer(src)
    if GetResourceState('bsrp') ~= 'started' then return nil end
    return exports.bsrp:GetPlayer(src)
end

local function isLeoOnDuty(player)
    if not player then return false end
    if not player.duty then return false end
    if Config.LeoJobs and Config.LeoJobs[player.job] then return true end
    return exports.bsrp:GetJobType(player.job) == 'leo'
end

local function notify(src, msg, nType)
    TriggerClientEvent('bsrp:client:notify', src, msg, nType or 'info')
end

RegisterNetEvent('bsrp-police:server:cuff', function(target, hard)
    local src = source
    local player = getPlayer(src)
    if not isLeoOnDuty(player) then
        notify(src, 'On-duty LEO only', 'error')
        return
    end
    target = tonumber(target)
    local other = getPlayer(target)
    if not other then
        notify(src, 'No one nearby', 'error')
        return
    end

    local ped = GetPlayerPed(src)
    local tped = GetPlayerPed(target)
    if #(GetEntityCoords(ped) - GetEntityCoords(tped)) > 4.0 then
        notify(src, 'Too far', 'error')
        return
    end

    if GetResourceState('ox_inventory') == 'started' then
        local count = exports.ox_inventory:GetItemCount(src, Config.HandCuffItem)
        if not count or count < 1 then
            notify(src, 'You need handcuffs', 'error')
            return
        end
    end

    if cuffed[target] then
        cuffed[target] = nil
        TriggerClientEvent('bsrp-police:client:getUncuffed', target)
        notify(src, 'Uncuffed player', 'success')
        notify(target, 'You have been uncuffed', 'success')
    else
        cuffed[target] = true
        TriggerClientEvent('bsrp-police:client:getCuffed', target, src, hard ~= false)
        notify(src, hard ~= false and 'Player cuffed' or 'Player soft-cuffed', 'success')
    end
end)

RegisterNetEvent('bsrp-police:server:escort', function(target)
    local src = source
    local player = getPlayer(src)
    if not isLeoOnDuty(player) then return end
    target = tonumber(target)
    if not getPlayer(target) then return end
    TriggerClientEvent('bsrp-police:client:escort', target, src)
end)

RegisterNetEvent('bsrp-police:server:putInVehicle', function(target)
    local src = source
    if not isLeoOnDuty(getPlayer(src)) then return end
    target = tonumber(target)
    if not getPlayer(target) then return end
    TriggerClientEvent('bsrp-police:client:putInVehicle', target)
end)

RegisterNetEvent('bsrp-police:server:setOutVehicle', function(target)
    local src = source
    if not isLeoOnDuty(getPlayer(src)) then return end
    target = tonumber(target)
    if not getPlayer(target) then return end
    TriggerClientEvent('bsrp-police:client:setOutVehicle', target)
end)

RegisterNetEvent('bsrp-police:server:search', function(target)
    local src = source
    if not isLeoOnDuty(getPlayer(src)) then return end
    target = tonumber(target)
    if not getPlayer(target) then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end
    exports.ox_inventory:forceOpenInventory(src, 'player', target)
end)

RegisterNetEvent('bsrp-police:server:takedna', function(target)
    local src = source
    if not isLeoOnDuty(getPlayer(src)) then return end
    target = tonumber(target)
    local other = getPlayer(target)
    if not other then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end

    local removed = exports.ox_inventory:RemoveItem(src, 'empty_evidence_bag', 1)
    if not removed then
        notify(src, 'You need an empty evidence bag', 'error')
        return
    end
    local meta = {
        description = ('DNA: %s | ID: %s'):format(other.name or 'Unknown', other.identifier or target),
        label = 'DNA Evidence',
        dna = other.identifier or tostring(target),
        name = other.name,
    }
    local added = exports.ox_inventory:AddItem(src, 'filled_evidence_bag', 1, meta)
    if added then
        notify(src, 'DNA sample collected', 'success')
    else
        exports.ox_inventory:AddItem(src, 'empty_evidence_bag', 1)
        notify(src, 'Inventory full', 'error')
    end
end)

AddEventHandler('playerDropped', function()
    cuffed[source] = nil
end)
