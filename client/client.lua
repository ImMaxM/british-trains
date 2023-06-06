-- Thanks to @TheNickoos for these locations :)
MetroTrainstops = {
    -- Los Santos AirPort (airport front door entrance)
    { x = -1088.627, y = -2709.362, z = -7.137033 },
    { x = -1081.309, y = -2725.259, z = -7.137033 },

    -- Los Santos AirPort (car park/highway entrance)
    { x = -889.2755, y = -2311.825, z = -11.45941 },
    { x = -876.7512, y = -2323.808, z = -11.45609 },

    -- Little Seoul (near los santos harbor)
    { x = -545.3138, y = -1280.548, z = 27.09238 },
    { x = -536.8082, y = -1286.096, z = 27.08238 },

    -- Strawberry (near strip club)
    { x = 270.2029,  y = -1210.818, z = 39.25398 },
    { x = 265.3616,  y = -1198.051, z = 39.23406 },

    -- Rockford Hills (San Vitus Blvd)
    { x = -286.3837, y = -318.877,  z = 10.33625 },
    { x = -302.6719, y = -322.995,  z = 10.33629 },

    -- Rockford Hills (Near golf club)
    { x = -826.3845, y = -134.7151, z = 20.22362 },
    { x = -816.7159, y = -147.4567, z = 20.2231 },

    -- Del Perro (Near beach)
    { x = -1351.282, y = -481.2916, z = 15.318 },
    { x = -1341.085, y = -467.674,  z = 15.31838 },

    -- Little Seoul
    { x = -496.0209, y = -681.0325, z = 12.08264 },
    { x = -495.8456, y = -665.4668, z = 12.08244 },

    -- Pillbox Hill (Downtown)
    { x = -218.2868, y = -1031.54,  z = 30.51112 },
    { x = -209.6845, y = -1037.544, z = 30.50939 },

    -- Davis (Gang / hood area)
    { x = 112.3714,  y = -1729.233, z = 30.24097 },
    { x = 120.0308,  y = -1723.956, z = 30.31433 },
}

metroTrainSpawns = {
    {x = -1060.48, y = -2700.24, z = -8.28},
    {x = -530.51, y = -1271.72, z = 25.9},
    {x = -287.04, y = -297.93, z = 9.19},
    {x = -1362.52, y = -431.04, z = 14.15},
    {x = -464.16, y = -680.68, z = 10.92},
    {x = 103.44, y = -1710.18, z = 29.13},
}

trainDoors = {
    {0, 2, 4},
    {1, 3, 5}
}

AddEventHandler("playerSpawned", function()
    spawnMetroTrains(MetroTrainstops)

    detectStations()
end)

function spawnMetroTrains(spawns)
    local trainModel = "metrotrain"
    local driverModel = "s_m_m_gentransport"

    -- Request train model
    RequestModel(GetHashKey(trainModel))
    while not HasModelLoaded(trainModel) do
        RequestModel(GetHashKey(trainModel))
        Citizen.Wait(0)
    end
    -- Request driver model
    RequestModel(GetHashKey(driverModel))
    while not HasModelLoaded(driverModel) do
        RequestModel(GetHashKey(driverModel))
        Wait(0)
    end

    for _, station in pairs(metroTrainSpawns) do
        local x = station.x
        local y = station.y
        local z = station.z

        -- Create the train

        local train = CreateMissionTrain(25, x, y, z, true)

        -- Add a blip to the train
        local TrainBlip = AddBlipForEntity(train)
        SetBlipSprite(TrainBlip, 795)
        SetBlipDisplay(TrainBlip, 4)
        SetBlipScale(TrainBlip, 0.8)
        SetBlipColour(TrainBlip, 49)
        SetBlipAsShortRange(TrainBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Circle Line: Train")
        EndTextCommandSetBlipName(TrainBlip)

        local carriage = GetTrainCarriage(train, 1)
        
        local driver = CreatePedInsideVehicle(train, 26, driverModel, -1, true, true)

        SetBlockingOfNonTemporaryEvents(driver, true)
        SetPedFleeAttributes(driver, 0, 0)
        SetEntityInvincible(driver, true)
        SetEntityAsMissionEntity(driver, true)

        SetEntityAsMissionEntity(train, true, true)

        SetEntityInvincible(train, true)

        SetTrainsForceDoorsOpen(false)

        TriggerServerEvent("trains:requestSpeedUpdate", train, 25.0)

    end
    
    -- Unload models Train and Driver
    SetModelAsNoLongerNeeded(GetHashKey(trainModel))
    SetModelAsNoLongerNeeded(GetHashKey(driverModel))
end

function detectStations()
    while true do
        for i = 1, #trains do
            local train = trains[i].train
            local carriage = trains[i].carriage
            local driver = trains[i].driver

            local trainCoords = GetEntityCoords(train)
            local trainSpeed = GetEntitySpeed(train)

            for j = 1, #MetroTrainstops do
                local station = MetroTrainstops[j]
                local stationCoords = vector3(station.x, station.y, station.z)

                if GetDistanceBetweenCoords(stationCoords, trainCoords) < 32.0 and trainSpeed > 24.9 then
                    Citizen.CreateThread(function()
                        TriggerServerEvent("trains:requestSpeedUpdate", train, 0.0) 
                        Citizen.Wait(5000)

                        TriggerServerEvent("trains:requestDoorUpdate", train, carriage, true)

                        Citizen.Wait(25000)

                        TriggerServerEvent("trains:requestDoorUpdate", train, carriage, false)

                        Citizen.Wait(5000)

                        TriggerServerEvent("trains:requestSpeedUpdate", train, 25.0)
                    end)
                end
            end
        end
        Citizen.Wait(100)
    end
end

RegisterNetEvent("trains:updateSpeed", function(train, speed)
    SetTrainCruiseSpeed(train, speed)
end)

RegisterNetEvent("trains:updateDoors", function(train, carriage, open)
    for i = 0.0, 1.5, 0.1 do
        SetTrainDoorOpenRatio(train, 0, open and i or 1.0 - i)
        SetTrainDoorOpenRatio(train, 2, open and i or 1.0 - i)
        SetTrainDoorOpenRatio(train, 4, open and i or 1.0 - i)
        SetTrainDoorOpenRatio(carriage, 1, open and i or 1.0 - i)
        SetTrainDoorOpenRatio(carriage, 3, open and i or 1.0 - i)
        SetTrainDoorOpenRatio(carriage, 5, open and i or 1.0 - i)
        Wait(100)
    end
end)

-- On resource stop, remove all trains
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for i = 1, #trains do
            local train = trains[i].train
            local driver = trains[i].driver
            local carriage = trains[i].carriage

            DeleteEntity(driver)
            DeleteEntity(train)
            DeleteEntity(carriage)
        end
    end
end)