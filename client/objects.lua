local spawned = {}
local spikeCount = 0

local function spawnObject(key)
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return
    end
    local def = Config.Objects[key]
    if not def then return end
    if key == 'spike' or key == 'spikestrip' then
        if spikeCount >= Config.MaxSpikes then
            FW.Notify('Max spike strips reached', 'error')
            return
        end
    end

    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, 0.0)
    local heading = GetEntityHeading(ped)
    local model = def.model or `p_ld_stinger_s`

    if key == 'spike' then
        model = `p_ld_stinger_s`
    end

    lib.requestModel(model, 5000)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(obj, heading)
    PlaceObjectOnGroundProperly(obj)
    if def.freeze then
        FreezeEntityPosition(obj, true)
    end
    spawned[#spawned + 1] = obj
    if key == 'spike' then
        spikeCount = spikeCount + 1
    end
    SetModelAsNoLongerNeeded(model)
    FW.Notify('Object placed', 'success')
end

local function deleteClosestObject()
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local closest, cdist, cidx = nil, 3.0, nil
    for i, obj in ipairs(spawned) do
        if DoesEntityExist(obj) then
            local d = #(GetEntityCoords(obj) - pcoords)
            if d < cdist then
                closest, cdist, cidx = obj, d, i
            end
        end
    end
    if closest then
        DeleteEntity(closest)
        table.remove(spawned, cidx)
        spikeCount = math.max(0, spikeCount - 1)
        FW.Notify('Object removed', 'success')
    else
        FW.Notify('No object nearby', 'error')
    end
end

RegisterNetEvent('bsrp-police:client:objectMenu', function()
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return
    end
    lib.registerContext({
        id = 'bsrp_police_objects',
        title = 'PLACE OBJECT',
        options = {
            { title = 'Cone', icon = 'traffic-cone', onSelect = function() spawnObject('cone') end },
            { title = 'Barrier', icon = 'road-barrier', onSelect = function() spawnObject('barrier') end },
            { title = 'Road Sign', icon = 'sign-hanging', onSelect = function() spawnObject('roadsign') end },
            { title = 'Tent', icon = 'campground', onSelect = function() spawnObject('tent') end },
            { title = 'Work Light', icon = 'lightbulb', onSelect = function() spawnObject('light') end },
            { title = 'Spike Strip', icon = 'road-spikes', onSelect = function() spawnObject('spike') end },
            { title = 'Remove Closest', icon = 'trash', onSelect = deleteClosestObject },
        }
    })
    lib.showContext('bsrp_police_objects')
end)

RegisterCommand('spikestrip', function()
    spawnObject('spike')
end, false)

RegisterCommand('pobject', function(_, args)
    local t = args[1] or 'cone'
    if t == 'delete' then
        deleteClosestObject()
    else
        spawnObject(t)
    end
end, false)

-- Spike tyre burst
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            sleep = 200
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) == ped then
                local vcoords = GetEntityCoords(veh)
                for _, obj in ipairs(spawned) do
                    if DoesEntityExist(obj) and GetEntityModel(obj) == `p_ld_stinger_s` then
                        if #(GetEntityCoords(obj) - vcoords) < 3.5 then
                            for i = 0, 7 do
                                SetVehicleTyreBurst(veh, i, true, 1000.0)
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
