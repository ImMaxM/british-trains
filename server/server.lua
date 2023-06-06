RegisterNetEvent("trains:requestSpeedUpdate", function(train, speed)
    TriggerClientEvent("trains:updateSpeed", -1, train, speed)
end)

RegisterNetEvent("trains:requestDoorUpdate", function(train, carriage, open)
    TriggerClientEvent("trains:updateDoors", -1, train, carriage, open)
end)