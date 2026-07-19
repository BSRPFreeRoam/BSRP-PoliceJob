local function getPlayer(src)
    if GetResourceState('bsrp') ~= 'started' then return nil end
    return exports.bsrp:GetPlayer(src)
end

local function isLeoOnDuty(player)
    if not player or not player.duty then return false end
    if Config.LeoJobs and Config.LeoJobs[player.job] then return true end
    return exports.bsrp:GetJobType(player.job) == 'leo'
end

local function notify(src, msg, nType)
    TriggerClientEvent('bsrp:client:notify', src, msg, nType or 'info')
end

RegisterCommand('cuff', function(src)
    if src == 0 then return end
    if not isLeoOnDuty(getPlayer(src)) then
        notify(src, 'On-duty LEO only', 'error')
        return
    end
    TriggerClientEvent('bsrp-police:client:cuff', src)
end, false)

RegisterCommand('sc', function(src)
    if src == 0 then return end
    TriggerClientEvent('bsrp-police:client:softCuff', src)
end, false)

RegisterCommand('escort', function(src)
    if src == 0 then return end
    TriggerClientEvent('bsrp-police:client:escortAction', src)
end, false)

RegisterCommand('jail', function(src)
    if src == 0 then return end
    TriggerClientEvent('bsrp-police:client:jailPrompt', src)
end, false)

RegisterCommand('unjail', function(src, args)
    if src == 0 then return end
    if not isLeoOnDuty(getPlayer(src)) then
        notify(src, 'On-duty LEO only', 'error')
        return
    end
    local target = tonumber(args[1])
    if not target then
        notify(src, 'Usage: /unjail [id]', 'error')
        return
    end
    TriggerEvent('bsrp-police:server:unjail', target)
    -- re-fire with proper source context
    local player = getPlayer(src)
    if not player then return end
    -- call handler logic inline
    if GetResourceState('bsrp') ~= 'started' then return end
    if not getPlayer(target) then
        notify(src, 'Player offline', 'error')
        return
    end
    TriggerClientEvent('bsrp-police:client:unjail', target)
    exports.bsrp:SetMetadata(target, 'injail', 0)
    notify(src, 'Player unjailed', 'success')
end, false)

RegisterCommand('fine', function(src, args)
    if src == 0 then return end
    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    if not target or not amount then
        notify(src, 'Usage: /fine [id] [amount]', 'error')
        return
    end
    TriggerEvent('bsrp-police:server:fineInternal', src, target, amount)
end, false)

AddEventHandler('bsrp-police:server:fineInternal', function(src, target, amount)
    -- bridge for command; reuse net event path via direct call pattern
    local player = getPlayer(src)
    local other = getPlayer(target)
    if not player or not isLeoOnDuty(player) then
        notify(src, 'On-duty LEO only', 'error')
        return
    end
    if not other then
        notify(src, 'Player offline', 'error')
        return
    end
    amount = math.floor(amount)
    if amount <= 0 then return end
    local removed = exports.bsrp:RemoveMoney(target, 'bank', amount, 'police-fine')
    if not removed then
        removed = exports.bsrp:RemoveMoney(target, 'cash', amount, 'police-fine')
    end
    if removed then
        notify(src, ('Fined $%s'):format(amount), 'success')
        notify(target, ('You were fined $%s'):format(amount), 'error')
    else
        notify(src, 'Could not collect fine', 'error')
    end
end)

RegisterCommand('callsign', function(src, args)
    if src == 0 then return end
    local player = getPlayer(src)
    if not player then return end
    local sign = table.concat(args or {}, ' ')
    if sign == '' then
        notify(src, 'Usage: /callsign [name]', 'error')
        return
    end
    exports.bsrp:SetMetadata(src, 'callsign', sign)
    notify(src, ('Callsign set: %s'):format(sign), 'success')
end, false)

RegisterCommand('seizecash', function(src)
    if src == 0 then return end
    if not isLeoOnDuty(getPlayer(src)) then
        notify(src, 'On-duty LEO only', 'error')
        return
    end
    -- client will resolve closest; for simplicity require target id via input later
    notify(src, 'Use search + inventory to seize items/cash', 'info')
end, false)
