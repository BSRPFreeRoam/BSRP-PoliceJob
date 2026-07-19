local function spawnJobVehicle(model, coords)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then
        FW.Notify('Invalid vehicle model', 'error')
        return
    end
    lib.requestModel(hash, 5000)
    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w or 0.0, true, false)
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, 'LSPD' .. tostring(math.random(1000, 9999)))
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(hash)
    local plate = FW.GetPlate(veh)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
    Entity(veh).state:set('fuel', 100.0, true)
    FW.Notify(('Deployed %s'):format(model), 'success')
end

local function vehiclesForGrade(grade)
    local list = {}
    for g, vehicles in pairs(Config.AuthorizedVehicles) do
        if grade >= g then
            for _, v in ipairs(vehicles) do
                list[#list + 1] = v
            end
        end
    end
    return list
end

local function openGarage(spawnCoords)
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return
    end
    local grade = FW.Grade()
    local options = {}
    for _, v in ipairs(vehiclesForGrade(grade)) do
        options[#options + 1] = {
            title = v.label,
            description = v.model,
            icon = 'car',
            onSelect = function()
                spawnJobVehicle(v.model, spawnCoords)
            end,
        }
    end
    if #options == 0 then
        FW.Notify('No vehicles authorized for your rank', 'error')
        return
    end
    lib.registerContext({ id = 'bsrp_police_garage', title = 'FLEET DEPLOY', options = options })
    lib.showContext('bsrp_police_garage')
end

local function openArmory()
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return
    end
    local grade = FW.Grade()
    local options = {}
    for _, item in ipairs(Config.Armory) do
        if grade >= (item.grade or 0) then
            options[#options + 1] = {
                title = item.name,
                description = ('x%s'):format(item.amount or 1),
                icon = 'gun',
                onSelect = function()
                    TriggerServerEvent('bsrp-police:server:armory', item.name, item.amount or 1)
                end,
            }
        end
    end
    lib.registerContext({ id = 'bsrp_police_armory', title = 'ARMORY', options = options })
    lib.showContext('bsrp_police_armory')
end

local function openFingerprint()
    if not FW.IsLeoOnDuty() then return end
    local _, _, sid = FW.ClosestPlayer(2.5)
    if not sid then
        FW.Notify('No one nearby', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:fingerprint', sid)
end

RegisterNetEvent('bsrp-police:client:openStash', function(id)
    if GetResourceState('ox_inventory') ~= 'started' or not id then return end
    exports.ox_inventory:openInventory('stash', id)
end)

RegisterNetEvent('bsrp-police:client:showFingerprint', function(payload)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'fingerprint', data = payload })
end)

RegisterNUICallback('closeFingerprint', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeFingerprint' })
    cb(1)
end)

local function registerTargets()
    if GetResourceState('ox_target') ~= 'started' then return end

    for i, coords in ipairs(Config.Locations.duty or {}) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.2,
            debug = false,
            options = {
                {
                    name = 'bsrp_police_duty_' .. i,
                    icon = 'fa-solid fa-clipboard-user',
                    label = 'Toggle Duty',
                    canInteract = function()
                        return FW.IsLeo()
                    end,
                    onSelect = function()
                        TriggerServerEvent('bsrp:server:toggleDuty')
                    end,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.stash or {}) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.2,
            options = {
                {
                    name = 'bsrp_police_stash_' .. i,
                    icon = 'fa-solid fa-box',
                    label = 'Personal Locker',
                    canInteract = function() return FW.IsLeoOnDuty() end,
                    onSelect = function()
                        TriggerServerEvent('bsrp-police:server:openStash', 'personal')
                    end,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.armory or {}) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.2,
            options = {
                {
                    name = 'bsrp_police_armory_' .. i,
                    icon = 'fa-solid fa-gun',
                    label = 'Armory',
                    canInteract = function() return FW.IsLeoOnDuty() end,
                    onSelect = openArmory,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.trash or {}) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.0,
            options = {
                {
                    name = 'bsrp_police_trash_' .. i,
                    icon = 'fa-solid fa-trash',
                    label = 'Trash',
                    canInteract = function() return FW.IsLeoOnDuty() end,
                    onSelect = function()
                        TriggerServerEvent('bsrp-police:server:openStash', 'trash')
                    end,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.evidence or {}) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.2,
            options = {
                {
                    name = 'bsrp_police_evidence_' .. i,
                    icon = 'fa-solid fa-flask',
                    label = 'Evidence Locker',
                    canInteract = function() return FW.IsLeoOnDuty() end,
                    onSelect = function()
                        TriggerServerEvent('bsrp-police:server:openStash', 'evidence', i)
                    end,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.fingerprint or {}) do
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.2,
            options = {
                {
                    name = 'bsrp_police_fp_' .. i,
                    icon = 'fa-solid fa-fingerprint',
                    label = 'Fingerprint Scan',
                    canInteract = function() return FW.IsLeoOnDuty() end,
                    onSelect = openFingerprint,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.vehicle or {}) do
        exports.ox_target:addSphereZone({
            coords = vec3(coords.x, coords.y, coords.z),
            radius = 2.0,
            options = {
                {
                    name = 'bsrp_police_garage_' .. i,
                    icon = 'fa-solid fa-car',
                    label = 'Police Garage',
                    canInteract = function() return FW.IsLeoOnDuty() end,
                    onSelect = function()
                        openGarage(coords)
                    end,
                },
                {
                    name = 'bsrp_police_store_' .. i,
                    icon = 'fa-solid fa-square-parking',
                    label = 'Store Vehicle',
                    canInteract = function()
                        return FW.IsLeoOnDuty() and IsPedInAnyVehicle(PlayerPedId(), false)
                    end,
                    onSelect = function()
                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        if veh and veh ~= 0 then
                            DeleteEntity(veh)
                            FW.Notify('Vehicle stored', 'success')
                        end
                    end,
                },
            },
        })
    end

    for i, coords in ipairs(Config.Locations.helicopter or {}) do
        exports.ox_target:addSphereZone({
            coords = vec3(coords.x, coords.y, coords.z),
            radius = 2.5,
            options = {
                {
                    name = 'bsrp_police_heli_' .. i,
                    icon = 'fa-solid fa-helicopter',
                    label = 'Police Helicopter',
                    canInteract = function() return FW.IsLeoOnDuty() and FW.Grade() >= 2 end,
                    onSelect = function()
                        spawnJobVehicle(Config.PoliceHelicopter, coords)
                    end,
                },
            },
        })
    end
end

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do Wait(200) end
    Wait(500)
    registerTargets()
end)
