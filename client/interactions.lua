local function requireDuty()
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return false
    end
    return true
end

RegisterNetEvent('bsrp-police:client:cuff', function()
    if not requireDuty() then return end
    local _, dist, sid = FW.ClosestPlayer(Config.CuffDistance)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        FW.Notify('Exit the vehicle first', 'error')
        return
    end
    if not FW.HasItem(Config.HandCuffItem, 1) then
        FW.Notify('You need handcuffs', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:cuff', sid, true)
end)

RegisterNetEvent('bsrp-police:client:softCuff', function()
    if not requireDuty() then return end
    local _, _, sid = FW.ClosestPlayer(Config.CuffDistance)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    if not FW.HasItem(Config.HandCuffItem, 1) then
        FW.Notify('You need handcuffs', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:cuff', sid, false)
end)

RegisterNetEvent('bsrp-police:client:escortAction', function()
    if not requireDuty() then return end
    local _, _, sid = FW.ClosestPlayer(Config.EscortDistance)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:escort', sid)
end)

RegisterNetEvent('bsrp-police:client:putInVehAction', function()
    if not requireDuty() then return end
    local _, _, sid = FW.ClosestPlayer(3.0)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:putInVehicle', sid)
end)

RegisterNetEvent('bsrp-police:client:setOutVehAction', function()
    if not requireDuty() then return end
    local _, _, sid = FW.ClosestPlayer(4.0)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:setOutVehicle', sid)
end)

RegisterNetEvent('bsrp-police:client:searchPlayer', function()
    if not requireDuty() then return end
    local _, _, sid = FW.ClosestPlayer(Config.SearchDistance)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:search', sid)
end)

RegisterNetEvent('bsrp-police:client:jailPrompt', function()
    if not requireDuty() then return end
    local _, _, sid = FW.ClosestPlayer(3.0)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    local input = lib.inputDialog('Jail Player', {
        { type = 'number', label = 'Minutes', default = 5, min = 1, max = Config.Jail.maxMinutes },
    })
    if not input or not input[1] then return end
    TriggerServerEvent('bsrp-police:server:jail', sid, tonumber(input[1]))
end)

RegisterNetEvent('bsrp-police:client:finePrompt', function()
    if not requireDuty() then return end
    local input = lib.inputDialog('Issue Fine', {
        { type = 'number', label = 'Player ID', required = true },
        { type = 'number', label = 'Amount', required = true, min = 1 },
    })
    if not input then return end
    TriggerServerEvent('bsrp-police:server:fine', tonumber(input[1]), tonumber(input[2]))
end)

-- ox_target on players for LEO
CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do Wait(200) end
    exports.ox_target:addGlobalPlayer({
        {
            name = 'bsrp_police_cuff',
            icon = 'fa-solid fa-handcuffs',
            label = 'Cuff / Uncuff',
            distance = 2.0,
            canInteract = function()
                return FW.IsLeoOnDuty()
            end,
            onSelect = function(data)
                local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('bsrp-police:server:cuff', sid, true)
            end,
        },
        {
            name = 'bsrp_police_escort',
            icon = 'fa-solid fa-person-walking',
            label = 'Escort',
            distance = 2.0,
            canInteract = function()
                return FW.IsLeoOnDuty()
            end,
            onSelect = function(data)
                local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('bsrp-police:server:escort', sid)
            end,
        },
        {
            name = 'bsrp_police_search',
            icon = 'fa-solid fa-magnifying-glass',
            label = 'Search',
            distance = 2.0,
            canInteract = function()
                return FW.IsLeoOnDuty()
            end,
            onSelect = function(data)
                local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('bsrp-police:server:search', sid)
            end,
        },
    })
end)
