-- Simple DNA bag fill using empty_evidence_bag

RegisterCommand('takedna', function(_, args)
    if not FW.IsLeoOnDuty() then
        FW.Notify('On-duty LEO only', 'error')
        return
    end
    local target = tonumber(args[1])
    if not target then
        local _, _, sid = FW.ClosestPlayer(2.5)
        target = sid
    end
    if not target then
        FW.Notify('No target', 'error')
        return
    end
    TriggerServerEvent('bsrp-police:server:takedna', target)
end, false)

RegisterCommand('clearcasings', function()
    if not FW.IsLeoOnDuty() then return end
    FW.Notify('Area casings cleared (local)', 'success')
end, false)

RegisterCommand('clearblood', function()
    if not FW.IsLeoOnDuty() then return end
    FW.Notify('Area blood cleared (local)', 'success')
end, false)
