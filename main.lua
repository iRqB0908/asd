ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

local VehicleHandling = {}

RegisterServerEvent("core_vehicle:canInstall")
AddEventHandler(
    "core_vehicle:canInstall",
    function(partType, part)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        local xItem = xPlayer.getInventoryItem(part)

        if xItem.count > 0 then
            xPlayer.removeInventoryItem(part, 1)
            TriggerClientEvent("core_vehicle:startInstall", src, partType, part)
        else
            TriggerClientEvent("core_vehicle:SendTextMessage", src, Config.Text["not_enough"])
        end
    end
)

RegisterServerEvent("core_vehicle:canRepair")
AddEventHandler(
    "core_vehicle:canRepair",
    function(partType, part)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        local repair = {}

        if Config.Engines[part] ~= nil then
            repair = Config.Engines[part].repair
        end
        if Config.Turbos[part] ~= nil then
            repair = Config.Turbos[part].repair
        end
        if Config.Transmitions[part] ~= nil then
            repair = Config.Transmitions[part].repair
        end
        if Config.Suspensions[part] ~= nil then
            repair = Config.Suspensions[part].repair
        end
        if Config.Oils[part] ~= nil then
            repair = Config.Oils[part].repair
        end
        if Config.Tires[part] ~= nil then
            repair = Config.Tires[part].repair
        end
        if Config.Brakes[part] ~= nil then
            repair = Config.Brakes[part].repair
        end
        if Config.Nitros[part] ~= nil then
            repair = Config.Nitros[part].repair
        end

        local avail = true
        for k, v in pairs(repair) do
            if xPlayer.getInventoryItem(k).count < v.amount then
                avail = false
            end
        end

        if avail then
            for k, v in pairs(repair) do
                if not v.reusable then
                    xPlayer.removeInventoryItem(k, v.amount)
                end
            end
            TriggerClientEvent("core_vehicle:startRepair", src, partType, part)
        else
            TriggerClientEvent("core_vehicle:SendTextMessage", src, Config.Text["not_enough"])
        end
    end
)

RegisterServerEvent("core_vehicle:getVehicleHandling")
AddEventHandler(
    "core_vehicle:getVehicleHandling",
    function(plate)
        local src = source

        TriggerClientEvent("core_vehicle:getVehicleHandling_c", src, plate, VehicleHandling[plate])
    end
)

RegisterServerEvent("core_vehicle:setVehicleHandling")
AddEventHandler(
    "core_vehicle:setVehicleHandling",
    function(plate, handlingData)
        VehicleHandling[plate] = handlingData
    end
)

RegisterServerEvent("core_vehicle:getVehicleParts")
AddEventHandler(
    "core_vehicle:getVehicleParts",
    function(plate)
        local src = source

        MySQL.Async.fetchAll(
            "SELECT * FROM vehicle_parts WHERE plate = @plate",
            {
                ["@plate"] = plate
            },
            function(parts)
                if parts[1] ~= nil then
                    TriggerClientEvent(
                        "core_vehicle:getVehicleParts_c",
                        src,
                        json.decode(parts[1].parts),
                        parts[1].mileage
                    )
                else
                    local defaultParts = {
                        ["engine"] = {type = "stock_engine", health = 100.0},
                        ["tires"] = {type = "stock_tires", health = 100},
                        ["oil"] = {type = "stock_oil", health = 100},
                        ["transmition"] = {type = "stock_transmition", health = 100},
                        ["brakes"] = {type = "stock_brakes", health = 100},
                        ["suspension"] = {type = "stock_suspension", health = 100}
                    }

                    MySQL.Async.execute(
                        "REPLACE INTO vehicle_parts (plate, parts) values(@plate, @parts)",
                        {["@parts"] = json.encode(defaultParts), ["@plate"] = plate},
                        function()
                        end
                    )

                    TriggerClientEvent("core_vehicle:getVehicleParts_c", src, defaultParts, 0)
                end
            end
        )
    end
)

RegisterServerEvent("core_vehicle:setVehicleParts")
AddEventHandler(
    "core_vehicle:setVehicleParts",
    function(plate, parts, mileage)
        local src = source

        MySQL.Async.execute(
            "UPDATE `vehicle_parts` SET `parts`= @parts, `mileage` = @mileage WHERE `plate` = @plate",
            {["@parts"] = parts, ["@plate"] = plate, ["@mileage"] = mileage},
            function()
            end
        )
    end
)

ESX.RegisterUsableItem(
    "toolbox",
    function(playerId)
        TriggerClientEvent("core_vehicle:toolUsed", playerId, "toolbox")
    end
)

ESX.RegisterUsableItem(
    "mechanic_tools",
    function(playerId)
        TriggerClientEvent("core_vehicle:toolUsed", playerId, "mechanic_tools")
    end
)

RegisterNetEvent("core_vehicle:syncNitro")
AddEventHandler(
    "core_vehicle:syncNitro",
    function(boostEnabled, purgeEnabled, lastVehicle)
        local source = source

        for _, player in ipairs(GetPlayers()) do
            if player ~= tostring(source) then
                TriggerClientEvent("core_vehicle:sync", player, source, boostEnabled, purgeEnabled, lastVehicle)
            end
        end
    end
)
