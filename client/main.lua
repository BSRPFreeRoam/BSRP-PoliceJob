Police = Police or {}
Police.PlayerData = nil
Police.isHandcuffed = false
Police.isEscorted = false
Police.cuffType = 1

local stationBlips = {}
local dutyBlips = {}

local function clearDutyBlips()
    for _, b in pairs(dutyBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    dutyBlips = {}
end

local function createStationBlips()
    for _, b in pairs(stationBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    stationBlips = {}
    for _, st in ipairs(Config.Locations.stations or {}) do
        local blip = AddBlipForCoord(st.coords.x, st.coords.y, st.coords.z)
        SetBlipSprite(blip, st.sprite or 60)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, st.color or 29)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(st.label or 'Police')
        EndTextCommandSetBlipName(blip)
        stationBlips[#stationBlips + 1] = blip
    end
end

local function refreshPlayer()
    Police.PlayerData = FW.GetPlayerData()
end

RegisterNetEvent('bsrp:client:onPlayerLoaded', function(data)
    Police.PlayerData = data
    Police.isHandcuffed = false
    Police.isEscorted = false
    TriggerServerEvent('bsrp-police:server:setCuff', false)
    TriggerServerEvent('bsrp-police:server:updateCops')
end)

RegisterNetEvent('bsrp:client:onJobUpdate', function(job)
    -- Do not re-fire bsrp:client:jobUpdate (infinite loop / crash)
    pcall(function()
        refreshPlayer()
        if type(job) == 'table' and Police.PlayerData then
            Police.PlayerData.job = job.name
            Police.PlayerData.job_label = job.label
            Police.PlayerData.job_grade = job.grade
            Police.PlayerData.grade_label = job.grade_label
            Police.PlayerData.duty = job.duty == true
            Police.PlayerData.isboss = job.isboss
        end
        if not FW.IsLeo(Police.PlayerData) then
            clearDutyBlips()
        end
        -- Debounce blip spam when switching jobs rapidly
        SetTimeout(300, function()
            TriggerServerEvent('bsrp-police:server:updateCops')
        end)
    end)
end)

RegisterNetEvent('bsrp:client:playerData', function(data)
    Police.PlayerData = data
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    createStationBlips()
    if FW.IsLoaded() then
        refreshPlayer()
    end
end)

CreateThread(function()
    createStationBlips()
end)

-- Duty unit blips for on-duty LEO (coords only — entity blips crash if ped not streamed)
RegisterNetEvent('bsrp-police:client:updateBlips', function(list)
    pcall(function()
        clearDutyBlips()
        if not FW.IsLeoOnDuty() then return end
        for _, unit in ipairs(list or {}) do
            if unit.src ~= GetPlayerServerId(PlayerId()) and unit.coords and unit.coords.x then
                local blip = AddBlipForCoord(unit.coords.x + 0.0, unit.coords.y + 0.0, unit.coords.z + 0.0)
                if blip and blip ~= 0 then
                    SetBlipSprite(blip, 1)
                    ShowHeadingIndicatorOnBlip(blip, true)
                    SetBlipScale(blip, 0.85)
                    SetBlipColour(blip, 38)
                    SetBlipAsShortRange(blip, false)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName(tostring(unit.label or 'Unit'))
                    EndTextCommandSetBlipName(blip)
                    dutyBlips[#dutyBlips + 1] = blip
                end
            end
        end
    end)
end)

-- Handcuff loop
CreateThread(function()
    while true do
        local sleep = 1000
        if Police.isHandcuffed then
            sleep = 0
            local ped = PlayerPedId()
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            if not IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3) then
                FW.LoadAnim('mp_arresting')
                TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
            end
        end
        if Police.isEscorted then
            sleep = 0
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 75, true)
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('bsrp-police:client:getCuffed', function(cuffer, hard)
    local ped = PlayerPedId()
    Police.isHandcuffed = true
    Police.cuffType = hard and 1 or 2
    FW.LoadAnim('mp_arresting')
    TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
    SetEnableHandcuffs(ped, true)
    SetPedCanPlayGestureAnims(ped, false)
    FW.Notify(hard and 'You have been cuffed' or 'You have been soft-cuffed', 'error')
end)

RegisterNetEvent('bsrp-police:client:getUncuffed', function()
    local ped = PlayerPedId()
    Police.isHandcuffed = false
    ClearPedTasks(ped)
    SetEnableHandcuffs(ped, false)
    SetPedCanPlayGestureAnims(ped, true)
    DetachEntity(ped, true, false)
    Police.isEscorted = false
    FW.Notify('You have been uncuffed', 'success')
end)

RegisterNetEvent('bsrp-police:client:escort', function(escortSrc)
    local ped = PlayerPedId()
    if Police.isEscorted then
        Police.isEscorted = false
        DetachEntity(ped, true, false)
        return
    end
    if not Police.isHandcuffed and not IsEntityDead(ped) then
        return
    end
    local player = GetPlayerFromServerId(escortSrc)
    if player == -1 then return end
    local escortPed = GetPlayerPed(player)
    Police.isEscorted = true
    AttachEntityToEntity(ped, escortPed, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
end)

RegisterNetEvent('bsrp-police:client:putInVehicle', function()
    local ped = PlayerPedId()
    if not Police.isHandcuffed and not Police.isEscorted then return end
    local coords = GetEntityCoords(ped)
    local vehicle = lib.getClosestVehicle(coords, 5.0, false)
    if not vehicle then return end
    local seat = nil
    for i = 1, GetVehicleMaxNumberOfPassengers(vehicle) do
        if IsVehicleSeatFree(vehicle, i - 1) then
            seat = i - 1
            break
        end
    end
    if seat == nil then return end
    Police.isEscorted = false
    DetachEntity(ped, true, false)
    ClearPedTasks(ped)
    TaskWarpPedIntoVehicle(ped, vehicle, seat)
end)

RegisterNetEvent('bsrp-police:client:setOutVehicle', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end
    local veh = GetVehiclePedIsIn(ped, false)
    TaskLeaveVehicle(ped, veh, 16)
end)

RegisterNetEvent('bsrp-police:client:jail', function(minutes)
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(550)
    local j = Config.Jail.coords
    SetEntityCoords(ped, j.x, j.y, j.z, false, false, false, false)
    SetEntityHeading(ped, j.w or 0.0)
    Police.isHandcuffed = false
    Police.isEscorted = false
    DetachEntity(ped, true, false)
    ClearPedTasks(ped)
    SetEnableHandcuffs(ped, false)
    Wait(250)
    DoScreenFadeIn(500)
    FW.Notify(('Jailed for %s minutes'):format(minutes), 'error')
end)

RegisterNetEvent('bsrp-police:client:unjail', function()
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(550)
    local r = Config.Jail.release
    SetEntityCoords(ped, r.x, r.y, r.z, false, false, false, false)
    SetEntityHeading(ped, r.w or 0.0)
    Wait(250)
    DoScreenFadeIn(500)
    FW.Notify('You have been released from jail', 'success')
end)

-- Radial / F6 police menu
local function openPoliceMenu()
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return
    end
    lib.registerContext({
        id = 'bsrp_police_menu',
        title = 'LAW ENFORCEMENT',
        options = {
            { title = 'Cuff / Uncuff', description = 'Hard cuff nearest player', icon = 'handcuffs', event = 'bsrp-police:client:cuff' },
            { title = 'Soft Cuff', icon = 'link', event = 'bsrp-police:client:softCuff' },
            { title = 'Escort', icon = 'person-walking', event = 'bsrp-police:client:escortAction' },
            { title = 'Put in Vehicle', icon = 'car', event = 'bsrp-police:client:putInVehAction' },
            { title = 'Remove from Vehicle', icon = 'door-open', event = 'bsrp-police:client:setOutVehAction' },
            { title = 'Search Player', icon = 'magnifying-glass', event = 'bsrp-police:client:searchPlayer' },
            { title = 'Jail Player', icon = 'lock', event = 'bsrp-police:client:jailPrompt' },
            { title = 'Fine Player', icon = 'dollar-sign', event = 'bsrp-police:client:finePrompt' },
            { title = 'Panic Button', icon = 'bell', event = 'bsrp-police:client:panic' },
            { title = 'Open MDT', icon = 'tablet', event = 'bsrp-police:client:mdt' },
            { title = 'Place Object', icon = 'road', event = 'bsrp-police:client:objectMenu' },
        }
    })
    lib.showContext('bsrp_police_menu')
end

RegisterCommand('polmenu', openPoliceMenu, false)
RegisterKeyMapping('polmenu', 'Police Job Menu', 'keyboard', 'F6')

RegisterNetEvent('bsrp-police:client:mdt', function()
    if Config.UsePsMdt then
        FW.OpenMDT()
    end
end)

RegisterNetEvent('bsrp-police:client:panic', function()
    if not FW.IsLeoOnDuty() then return end
    if Config.UsePsDispatch then
        if not FW.Dispatch('OfficerDown') then
            FW.DispatchCustom({
                message = 'Officer in distress',
                dispatchCode = 'officerdown',
                code = '10-99',
                icon = 'fas fa-skull',
                priority = 1,
                coords = GetEntityCoords(PlayerPedId()),
                jobs = { 'leo' },
            })
        end
    end
    FW.Notify('Panic alert sent', 'error')
end)

exports('IsHandcuffed', function()
    return Police.isHandcuffed
end)

exports('IsEscorted', function()
    return Police.isEscorted
end)
