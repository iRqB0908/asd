local Keys = {
    ["ESC"] = 322,
    ["F1"] = 288,
    ["F2"] = 289,
    ["F3"] = 170,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["F8"] = 169,
    ["F9"] = 56,
    ["F10"] = 57,
    ["~"] = 243,
    ["-"] = 84,
    ["="] = 83,
    ["BACKSPACE"] = 177,
    ["TAB"] = 37,
    ["Q"] = 44,
    ["W"] = 32,
    ["E"] = 38,
    ["R"] = 45,
    ["T"] = 245,
    ["Y"] = 246,
    ["U"] = 303,
    ["P"] = 199,
    ["["] = 39,
    ["]"] = 40,
    ["ENTER"] = 18,
    ["CAPS"] = 137,
    ["A"] = 34,
    ["S"] = 8,
    ["D"] = 9,
    ["F"] = 23,
    ["G"] = 47,
    ["H"] = 74,
    ["K"] = 311,
    ["L"] = 182,
    ["LEFTSHIFT"] = 21,
    ["Z"] = 20,
    ["X"] = 73,
    ["C"] = 26,
    ["V"] = 0,
    ["B"] = 29,
    ["N"] = 249,
    ["M"] = 244,
    [","] = 82,
    ["."] = 81,
    ["LEFTCTRL"] = 36,
    ["LEFTALT"] = 19,
    ["SPACE"] = 22,
    ["RIGHTCTRL"] = 70,
    ["HOME"] = 213,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["DELETE"] = 178,
    ["LEFT"] = 174,
    ["RIGHT"] = 175,
    ["TOP"] = 27,
    ["DOWN"] = 173,
    ["NENTER"] = 201,
    ["N4"] = 108,
    ["N5"] = 60,
    ["N6"] = 107,
    ["N+"] = 96,
    ["N-"] = 97,
    ["N7"] = 117,
    ["N8"] = 61,
    ["N9"] = 118
}

ESX = nil

local inVehicle = false
local currentVehicleParts = nil
local currentVehicle = nil
local currentMulti = 0
local turboPower = 0
local nitroPower = 0
local currentVehicleHandling = nil
local currentWear = 0
local currentPlate = nil
local currentMileage = 0
local oldpos = nil
local nitroActive = false

local repairMode = false
local repairPartType = ""
local repairing = false
local repairPart = ""
local repairInstall = false

local trailpurgeVehicles = {}
local trailpurgeParticles = {}

local purgeVehicles = {}
local purgeParticles = {}

local checkEngine = false
local lowOil = false

local job = ""

Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    ESX = obj
                end
            )
            Citizen.Wait(0)
        end

        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end

        job = ESX.GetPlayerData().job.name
        currentWear = Config.WearRate
    end
)

RegisterNetEvent("esx:setJob")
AddEventHandler(
    "esx:setJob",
    function(JobInfo)
        job = JobInfo.name
    end
)

local w1, w2, w3, w4 = true, true, true, true
local done = 0

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            if repairMode then
                local bone = GetEntityBoneIndexByName(currentVehicle, "bonnet")
                local pos = GetWorldPositionOfEntityBone(currentVehicle, bone)
                local off = GetOffsetFromEntityGivenWorldCoords(currentVehicle, pos.x, pos.y, pos.z)
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)

                if repairPartType == "engine" then
                    if GetVehicleDoorAngleRatio(currentVehicle, 4) ~= 0 then
                        local coords = GetOffsetFromEntityInWorldCoords(currentVehicle, off.x, off.y + 0.8, off.z - 0.1)

                        if not repairing then
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Install Engine")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Repair Engine")
                            end
                        else
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Engine is being installed")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Engine is being repaired")
                            end
                        end

                        if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - coords) < 2.0 then
                            repairing = true

                            Citizen.CreateThread(
                                function()
                                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

                                    if repairInstall then
                                        Citizen.Wait(Config.EngineInstallTime)
                                    else
                                        Citizen.Wait(Config.EngineRepairTime)
                                    end

                                    ClearPedTasks(ped)
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                end
                            )
                        end
                    end
                elseif repairPartType == "turbo" then
                    if GetVehicleDoorAngleRatio(currentVehicle, 4) ~= 0 then
                        local coords = GetOffsetFromEntityInWorldCoords(currentVehicle, off.x, off.y + 0.8, off.z - 0.1)

                        if not repairing then
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Install Turbo")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Repair Turbo")
                            end
                        else
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Turbo is being installed")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Turbo is being repaired")
                            end
                        end

                        if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - coords) < 2.0 then
                            repairing = true

                            Citizen.CreateThread(
                                function()
                                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

                                    if repairInstall then
                                        Citizen.Wait(Config.TurboInstallTime)
                                    else
                                        Citizen.Wait(Config.TurboRepairTime)
                                    end

                                    ClearPedTasks(ped)
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                end
                            )
                        end
                    end
                elseif repairPartType == "nitro" then
                    if GetVehicleDoorAngleRatio(currentVehicle, 4) ~= 0 then
                        local coords = GetOffsetFromEntityInWorldCoords(currentVehicle, off.x, off.y + 0.8, off.z - 0.1)

                        if not repairing then
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Install Nitro")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Repair Nitro")
                            end
                        else
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Nitro is being installed")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Nitro is being repaired")
                            end
                        end

                        if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - coords) < 2.0 then
                            repairing = true

                            Citizen.CreateThread(
                                function()
                                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

                                    if repairInstall then
                                        Citizen.Wait(Config.NitroInstallTime)
                                    else
                                        Citizen.Wait(Config.NitroRepairTime)
                                    end
                                    ClearPedTasks(ped)
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        Citizen.Trace(repairPartType .. " " .. repairPart)
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                end
                            )
                        end
                    end
                elseif repairPartType == "oil" then
                    if GetVehicleDoorAngleRatio(currentVehicle, 4) ~= 0 then
                        local coords = GetOffsetFromEntityInWorldCoords(currentVehicle, off.x, off.y + 0.8, off.z - 0.1)

                        if not repairing then
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Refill Oil")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Refill Oil")
                            end
                        else
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Oil is being refilled")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Oil is being repaired")
                            end
                        end

                        if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - coords) < 2.0 then
                            repairing = true

                            Citizen.CreateThread(
                                function()
                                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

                                    if repairInstall then
                                        Citizen.Wait(Config.OilInstallTime)
                                    else
                                        Citizen.Wait(Config.OilRepairTime)
                                    end
                                    ClearPedTasks(ped)
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                end
                            )
                        end
                    end
                elseif repairPartType == "transmition" then
                    if GetVehicleDoorAngleRatio(currentVehicle, 4) ~= 0 then
                        local coords = GetOffsetFromEntityInWorldCoords(currentVehicle, off.x, off.y + 0.8, off.z - 0.1)

                        if not repairing then
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Install Transmition")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "[~r~E~w~] Repair Transmition")
                            end
                        else
                            if repairInstall then
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Transmition is being installed")
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "~r~Transmition is being repaired")
                            end
                        end

                        if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - coords) < 2.0 then
                            repairing = true

                            Citizen.CreateThread(
                                function()
                                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

                                    if repairInstall then
                                        Citizen.Wait(Config.TransmitionInstallTime)
                                    else
                                        Citizen.Wait(Config.TransmitionRepairTime)
                                    end
                                    ClearPedTasks(ped)
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                end
                            )
                        end
                    end
                elseif repairPartType == "tires" then
                    local wheel1 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x + 0.9, off.y + 0.6, off.z - 0.4)
                    local wheel2 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x - 0.9, off.y + 0.6, off.z - 0.4)
                    local wheel3 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x + 0.9, off.y - 2.27, off.z - 0.4)
                    local wheel4 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x - 0.9, off.y - 2.27, off.z - 0.4)

                    if not repairing then
                        if repairInstall then
                            if w1 then
                                DrawText3D(wheel1.x, wheel1.y, wheel1.z, "[~r~E~w~] Install Tire")
                            end
                            if w2 then
                                DrawText3D(wheel2.x, wheel2.y, wheel2.z, "[~r~E~w~] Install Tire")
                            end
                            if w3 then
                                DrawText3D(wheel3.x, wheel3.y, wheel3.z, "[~r~E~w~] Install Tire")
                            end
                            if w4 then
                                DrawText3D(wheel4.x, wheel4.y, wheel4.z, "[~r~E~w~] Install Tire")
                            end
                        else
                            if w1 then
                                DrawText3D(wheel1.x, wheel1.y, wheel1.z, "[~r~E~w~] Repair Tire")
                            end
                            if w2 then
                                DrawText3D(wheel2.x, wheel2.y, wheel2.z, "[~r~E~w~] Repair Tire")
                            end
                            if w3 then
                                DrawText3D(wheel3.x, wheel3.y, wheel3.z, "[~r~E~w~] Repair Tire")
                            end
                            if w4 then
                                DrawText3D(wheel4.x, wheel4.y, wheel4.z, "[~r~E~w~] Repair Tire")
                            end
                        end
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel1) < 1.5 and w1 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.TireInstallTime)
                                else
                                    Citizen.Wait(Config.TireRepairTime)
                                end

                                ClearPedTasks(ped)

                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w1 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel2) < 1.5 and w2 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.TireInstallTime)
                                else
                                    Citizen.Wait(Config.TireRepairTime)
                                end

                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w2 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel3) < 1.5 and w3 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.TireInstallTime)
                                else
                                    Citizen.Wait(Config.TireRepairTime)
                                end

                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w3 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel4) < 1.5 and w4 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.TireInstallTime)
                                else
                                    Citizen.Wait(Config.TireRepairTime)
                                end

                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w4 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end
                elseif repairPartType == "brakes" then
                    local wheel1 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x + 0.9, off.y + 0.6, off.z - 0.4)
                    local wheel2 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x - 0.9, off.y + 0.6, off.z - 0.4)
                    local wheel3 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x + 0.9, off.y - 2.27, off.z - 0.4)
                    local wheel4 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x - 0.9, off.y - 2.27, off.z - 0.4)

                    if not repairing then
                        if repairInstall then
                            if w1 then
                                DrawText3D(wheel1.x, wheel1.y, wheel1.z, "[~r~E~w~] Install Breaks")
                            end
                            if w2 then
                                DrawText3D(wheel2.x, wheel2.y, wheel2.z, "[~r~E~w~] Install Breaks")
                            end
                            if w3 then
                                DrawText3D(wheel3.x, wheel3.y, wheel3.z, "[~r~E~w~] Install Breaks")
                            end
                            if w4 then
                                DrawText3D(wheel4.x, wheel4.y, wheel4.z, "[~r~E~w~] Install Breaks")
                            end
                        else
                            if w1 then
                                DrawText3D(wheel1.x, wheel1.y, wheel1.z, "[~r~E~w~] Repair Breaks")
                            end
                            if w2 then
                                DrawText3D(wheel2.x, wheel2.y, wheel2.z, "[~r~E~w~] Repair Breaks")
                            end
                            if w3 then
                                DrawText3D(wheel3.x, wheel3.y, wheel3.z, "[~r~E~w~] Repair Breaks")
                            end
                            if w4 then
                                DrawText3D(wheel4.x, wheel4.y, wheel4.z, "[~r~E~w~] Repair Breaks")
                            end
                        end
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel1) < 1.5 and w1 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.BreaksInstallTime)
                                else
                                    Citizen.Wait(Config.BreaksRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w1 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel2) < 1.5 and w2 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.BreaksInstallTime)
                                else
                                    Citizen.Wait(Config.BreaksRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w2 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel3) < 1.5 and w3 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.BreaksInstallTime)
                                else
                                    Citizen.Wait(Config.BreaksRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w3 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel4) < 1.5 and w4 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.BreaksInstallTime)
                                else
                                    Citizen.Wait(Config.BreaksRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w4 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end
                elseif repairPartType == "suspension" then
                    local wheel1 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x + 0.9, off.y + 0.6, off.z - 0.4)
                    local wheel2 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x - 0.9, off.y + 0.6, off.z - 0.4)
                    local wheel3 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x + 0.9, off.y - 2.27, off.z - 0.4)
                    local wheel4 =
                        GetOffsetFromEntityInWorldCoords(currentVehicle, off.x - 0.9, off.y - 2.27, off.z - 0.4)

                    if not repairing then
                        if repairInstall then
                            if w1 then
                                DrawText3D(wheel1.x, wheel1.y, wheel1.z, "[~r~E~w~] Install Suspension")
                            end
                            if w2 then
                                DrawText3D(wheel2.x, wheel2.y, wheel2.z, "[~r~E~w~] Install Suspension")
                            end
                            if w3 then
                                DrawText3D(wheel3.x, wheel3.y, wheel3.z, "[~r~E~w~] Install Suspension")
                            end
                            if w4 then
                                DrawText3D(wheel4.x, wheel4.y, wheel4.z, "[~r~E~w~] Install Suspension")
                            end
                        else
                            if w1 then
                                DrawText3D(wheel1.x, wheel1.y, wheel1.z, "[~r~E~w~] Repair Suspension")
                            end
                            if w2 then
                                DrawText3D(wheel2.x, wheel2.y, wheel2.z, "[~r~E~w~] Repair Suspension")
                            end
                            if w3 then
                                DrawText3D(wheel3.x, wheel3.y, wheel3.z, "[~r~E~w~] Repair Suspension")
                            end
                            if w4 then
                                DrawText3D(wheel4.x, wheel4.y, wheel4.z, "[~r~E~w~] Repair Suspension")
                            end
                        end
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel1) < 1.5 and w1 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.SuspensionInstallTime)
                                else
                                    Citizen.Wait(Config.SuspensionRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w1 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel2) < 1.5 and w2 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.SuspensionInstallTime)
                                else
                                    Citizen.Wait(Config.SuspensionRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w2 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel3) < 1.5 and w3 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.SuspensionInstallTime)
                                else
                                    Citizen.Wait(Config.SuspensionRepairTime)
                                end
                                ClearPedTasks(ped)
                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w3 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end

                    if IsControlJustReleased(0, Keys["E"]) and #(pedCoords - wheel4) < 1.5 and w4 then
                        repairing = true

                        Citizen.CreateThread(
                            function()
                                TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

                                if repairInstall then
                                    Citizen.Wait(Config.SuspensionInstallTime)
                                else
                                    Citizen.Wait(Config.SuspensionRepairTime)
                                end
                                ClearPedTasks(ped)

                                if done == 3 then
                                    repairing = false
                                    repairMode = false

                                    if repairInstall then
                                        currentVehicleParts[repairPartType] = {}
                                        currentVehicleParts[repairPartType].health = 100.0
                                        currentVehicleParts[repairPartType].type = repairPart
                                    else
                                        currentVehicleParts[repairPartType].health = 100.0
                                        SetVehicleEngineHealth(currentVehicle, 1000.0)
                                    end
                                    saveVehicleData(currentPlate)
                                    SendTextMessage(Config.Text["mechanic_action_complete"])
                                else
                                    w4 = false
                                    repairing = false
                                    done = done + 1
                                end
                            end
                        )
                    end
                end
            else
                Citizen.Wait(500)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(200)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped)
            local seat = 0
            if veh ~= 0 then
                seat = GetPedInVehicleSeat(veh, -1)
            else
                seat = 0
            end

            if seat == ped and not inVehicle then
               

                if not repairMode then

                	 SendNUIMessage(
                    {
                        type = "showinfo",
                        bottom = Config.InfoBottom,
                        right = Config.InfoRight
                    }
                )
                	
                    currentPlate = string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")

                    currentVehicle = veh

                    TriggerServerEvent("core_vehicle:getVehicleHandling", currentPlate)

                    TriggerServerEvent("core_vehicle:getVehicleParts", currentPlate)
                    inVehicle = true
                end
            elseif inVehicle and seat == 0 then
                inVehicle = false
                saveVehicleData(currentPlate)
                currentMulti = 0
                turboPower = 0
                nitroPower = 0
                checkEngine = false
                lowOil = false
                nitroActive = false

                SendNUIMessage(
                    {
                        type = "hideinfo"
                    }
                )
            end

            if inVehicle and currentVehicleParts ~= nil then
                local rpm = GetVehicleCurrentRpm(currentVehicle)
                local gear = GetVehicleCurrentGear(currentVehicle)
                local kmh = (GetEntitySpeed(currentVehicle) * 3.6)
                local coords = GetEntityCoords(veh)

                local mileage = 0
                if Config.UseMiles then
                    mileage = currentMileage / 1609.34
                else
                    mileage = currentMileage / 1000
                end

                SendNUIMessage(
                    {
                        type = "info",
                        mileage = math.floor(mileage * 100) / 100,
                        check = checkEngine,
                        oil = lowOil
                    }
                )

                if IsVehicleOnAllWheels(veh) then
                    if oldpos ~= nil then
                        local dst = #(coords - oldpos)
                        currentMileage = currentMileage + dst
                    end
                    oldpos = coords
                end

                --ENGINE WEAR
                if currentVehicleParts["engine"].health <= 0 then
                    SetVehicleEngineHealth(currentVehicle, -4000)
                else
                    if currentVehicleParts["engine"].health < 30 then
                        checkEngine = true
                    end

                    currentVehicleParts["engine"].health = GetVehicleEngineHealth(currentVehicle) / 10
                    SetVehicleEngineHealth(
                        currentVehicle,
                        (currentVehicleParts["engine"].health * 10) -
                            ((100 - Config.Engines[currentVehicleParts["engine"].type].durability) *
                                ((kmh / (currentWear / 2)) + (rpm / (currentWear))))
                    )
                end

                --TIRE WEAR
                if currentVehicleParts["tires"] then
                    if currentVehicleParts["tires"].health < 0 then
                        currentVehicleParts["tires"].health = 0
                        SetVehicleTyreBurst(currentVehicle, 0, true, 900.0)
                        SetVehicleTyreBurst(currentVehicle, 1, true, 900.0)
                        SetVehicleTyreBurst(currentVehicle, 2, true, 900.0)
                        SetVehicleTyreBurst(currentVehicle, 3, true, 900.0)
                        SetVehicleTyreBurst(currentVehicle, 4, true, 900.0)
                        SetVehicleTyreBurst(currentVehicle, 5, true, 900.0)
                    elseif currentVehicleParts["tires"].health > 0 then
                        currentVehicleParts["tires"].health =
                            currentVehicleParts["tires"].health -
                            ((100 - Config.Tires[currentVehicleParts["tires"].type].durability) *
                                ((kmh / (currentWear * 100)) + (rpm / (currentWear))))
                    end
                end

                --TRANSMITION WEAR
                if currentVehicleParts["transmition"] then
                    if currentVehicleParts["transmition"].health < 0 then
                        currentVehicleParts["transmition"].health = 0

                        SetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fClutchChangeRateScaleDownShift", 0.0)
                        SetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fClutchChangeRateScaleUpShift", 0.0)
                    elseif currentVehicleParts["transmition"].health > 0 then
                        if currentVehicleParts["transmition"].health < 30 then
                            checkEngine = true
                        end

                        currentVehicleParts["transmition"].health =
                            currentVehicleParts["transmition"].health -
                            ((100 - Config.Transmitions[currentVehicleParts["transmition"].type].durability) *
                                ((kmh / (currentWear * 90)) + (rpm / (currentWear * 10))))
                    end
                end

                --SUSPENSION WEAR
                if currentVehicleParts["suspension"] then
                    if currentVehicleParts["suspension"].health < 0 then
                        currentVehicleParts["suspension"].health = 0

                        SetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fSuspensionRaise", -0.10)
                        SetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fTractionCurveMax", 0.5)
                    elseif currentVehicleParts["suspension"].health > 0 then
                        if currentVehicleParts["suspension"].health < 30 then
                            checkEngine = true
                        end

                        currentVehicleParts["suspension"].health =
                            currentVehicleParts["suspension"].health -
                            ((100 - Config.Suspensions[currentVehicleParts["suspension"].type].durability) *
                                ((kmh / (currentWear * 110)) + (rpm / (currentWear * 10))))
                    end
                end

                --BREAKS WEAR
                if currentVehicleParts["brakes"] then
                    if currentVehicleParts["brakes"].health < 0 then
                        currentVehicleParts["brakes"].health = 0

                        SetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fBrakeForce", 0.0)
                    elseif currentVehicleParts["brakes"].health > 0 then
                        if currentVehicleParts["brakes"].health < 30 then
                            checkEngine = true
                        end

                        currentVehicleParts["brakes"].health =
                            currentVehicleParts["brakes"].health -
                            ((100 - Config.Brakes[currentVehicleParts["brakes"].type].durability) *
                                ((kmh / (currentWear * 150)) + (rpm / (currentWear * 10))))
                    end
                end

                --TURBO WEAR
                if currentVehicleParts["turbo"] then
                    if currentVehicleParts["turbo"].health < 0 then
                        currentVehicleParts["turbo"] = nil
                        turboPower = 0
                    else
                        if currentVehicleParts["turbo"].health < 30 then
                            checkEngine = true
                        end

                        if turboPower > 0 then
                            if rpm > 0.4 and not nitroActive then
                                SetVehicleEnginePowerMultiplier(currentVehicle, currentMulti + (turboPower * rpm))

                                currentVehicleParts["turbo"].health =
                                    currentVehicleParts["turbo"].health -
                                    ((100 - Config.Turbos[currentVehicleParts["turbo"].type].durability) *
                                        (((kmh / (currentWear * 200)) + (rpm / (currentWear * 200))) *
                                            Config.Turbos[currentVehicleParts["turbo"].type].power))
                            end
                        end
                    end
                end

                --NITRO
                if currentVehicleParts["nitro"] then
                    if currentVehicleParts["nitro"].health < 0 then
                        currentVehicleParts["nitro"] = nil
                        SetVehicleNitroPurgeEnabled(currentVehicle, false)
                        SetVehicleLightTrailEnabled(currentVehicle, false)
                        TriggerServerEvent("core_vehicle:syncNitro", false, false, false)
                        StopGameplayCamShaking(true)
                        SetTransitionTimecycleModifier("default", 0.35)
                        nitroActive = false

                        if not currentVehicleParts["turbo"] then
                            SetVehicleEnginePowerMultiplier(currentVehicle, currentMulti)
                        end
                    else
                        if nitroPower > 0 and IsControlPressed(0, Keys[Config.NitroKey]) then
                            if not nitroActive then
                                currentWear = Config.WearRate / 10
                                if IsControlPressed(0, 71) then
                                    SetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fDriveInertia", 2.0)
                                    SetVehicleBoostActive(currentVehicle, true)
                                    SetVehicleLightTrailEnabled(currentVehicle, true)
                                    TriggerServerEvent("core_vehicle:syncNitro", true, false, false)
                                else
                                    SetVehicleNitroPurgeEnabled(currentVehicle, true)
                                    TriggerServerEvent("core_vehicle:syncNitro", false, true, false)
                                end
                            end
                            nitroActive = true

                            if IsControlPressed(0, 71) then
                                SetVehicleNitroPurgeEnabled(currentVehicle, false)

                                CreateVehicleExhaustBackfire(currentVehicle, 1.25)

                                StopScreenEffect("RaceTurbo")
                                StartScreenEffect("RaceTurbo", 0, false)
                                SetTimecycleModifier("rply_motionblur")
                                ShakeGameplayCam("SKY_DIVING_SHAKE", 0.25)

                                SetVehicleEnginePowerMultiplier(
                                    currentVehicle,
                                    currentMulti + nitroPower + (turboPower * rpm)
                                )
                            end

                            currentVehicleParts["nitro"].health =
                                currentVehicleParts["nitro"].health -
                                ((100 / Config.Nitros[currentVehicleParts["nitro"].type].durability) / 5)
                        else
                            if nitroActive then
                                SetVehicleHandlingFloat(
                                    currentVehicle,
                                    "CHandlingData",
                                    "fDriveInertia",
                                    currentVehicleHandling["fDriveInertia"]
                                )

                                SetVehicleNitroPurgeEnabled(currentVehicle, false)
                                if not currentVehicleParts["turbo"] then
                                    SetVehicleEnginePowerMultiplier(currentVehicle, currentMulti)
                                end

                                SetVehicleLightTrailEnabled(currentVehicle, false)
                                TriggerServerEvent("core_vehicle:syncNitro", false, false, false)

                                StopGameplayCamShaking(true)
                                SetTransitionTimecycleModifier("default", 0.35)
                            end
                            nitroActive = false
                        end
                    end
                end

                --OIL CONSUMPTION
                if currentVehicleParts["oil"].health <= 0 then
                    currentWear = Config.WearRate / 200
                    currentVehicleParts["oil"].health = 0
                else
                    if currentVehicleParts["oil"].health < 10 then
                        lowOil = true
                    end

                    if not nitroActive then
                        currentWear = Config.WearRate
                    end
                    currentVehicleParts["oil"].health =
                        currentVehicleParts["oil"].health -
                        ((100 - Config.Oils[currentVehicleParts["oil"].type].durability) *
                            ((kmh / (currentWear * 50)) + (rpm / (currentWear * 50))))
                end
            end
        end
    end
)

RegisterNetEvent("core_vehicle:SendTextMessage")
AddEventHandler(
    "core_vehicle:SendTextMessage",
    function(msg)
        SendTextMessage(msg)
    end
)

RegisterNetEvent("core_vehicle:toolUsed")
AddEventHandler(
    "core_vehicle:toolUsed",
    function(tool)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if tool == "mechanic_tools" then
            if job == "mechanic" then
                local workshop = false
                for _, v in ipairs(Config.MechanicWorkshop) do
                    if #(v.coords - coords) < v.radius then
                        workshop = true
                    end
                end

                local veh, dst = ESX.Game.GetClosestVehicle(coords)

                if dst < 3.0 then
                    currentVehicle = veh
                    currentPlate = string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")
                    TriggerServerEvent("core_vehicle:getVehicleHandling", string.gsub(currentPlate, "%s+", ""))

                    TriggerServerEvent("core_vehicle:getVehicleParts", string.gsub(currentPlate, "%s+", ""))
                    Citizen.Wait(300)
                    local parts = {}

                    for b, g in pairs(currentVehicleParts) do
                        parts[b] = g
                    end

                    for k, v in pairs(parts) do
                        if Config.Engines[v.type] ~= nil then
                            v.label = Config.Engines[v.type].label
                        end
                        if Config.Turbos[v.type] ~= nil then
                            v.label = Config.Turbos[v.type].label
                        end
                        if Config.Transmitions[v.type] ~= nil then
                            v.label = Config.Transmitions[v.type].label
                        end
                        if Config.Suspensions[v.type] ~= nil then
                            v.label = Config.Suspensions[v.type].label
                        end
                        if Config.Oils[v.type] ~= nil then
                            v.label = Config.Oils[v.type].label
                        end
                        if Config.Tires[v.type] ~= nil then
                            v.label = Config.Tires[v.type].label
                        end
                        if Config.Brakes[v.type] ~= nil then
                            v.label = Config.Brakes[v.type].label
                        end
                        if Config.Nitros[v.type] ~= nil then
                            v.label = Config.Nitros[v.type].label
                        end

                        if workshop then
                            if Config.MechanicWorkshopAccess[k] == nil then
                                parts[k] = nil
                            end
                        else
                            if Config.MechanicToolsAccess[k] == nil then
                                parts[k] = nil
                            end
                        end
                    end

                    local mileage = 0
                    if Config.UseMiles then
                        mileage = currentMileage / 1609.34
                    else
                        mileage = currentMileage / 1000
                    end

                    local allparts = {}

                    allparts["engine"] = Config.Engines
                    allparts["turbo"] = Config.Turbos
                    allparts["brakes"] = Config.Brakes
                    allparts["suspension"] = Config.Suspensions
                    allparts["transmition"] = Config.Transmitions
                    allparts["oil"] = Config.Oils
                    allparts["tires"] = Config.Tires
                    allparts["nitro"] = Config.Nitros

                    SetNuiFocus(true, true)
                    SendNUIMessage(
                        {
                            type = "open",
                            parts = parts,
                            plate = currentPlate,
                            allparts = allparts,
                            mileage = math.floor(mileage * 100) / 100,
                            workshop = workshop,
                            vehicleType = GetVehicleClass(currentVehicle),
                            model = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
                        }
                    )
                end
            else
                SendTextMessage(Config.Text["wrong_job"])
            end
        elseif tool == "toolbox" then
            local veh, dst = ESX.Game.GetClosestVehicle(coords)

            if dst < 3.0 then
                currentVehicle = veh
                currentPlate = string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")
                TriggerServerEvent("core_vehicle:getVehicleHandling", string.gsub(currentPlate, "%s+", ""))

                TriggerServerEvent("core_vehicle:getVehicleParts", string.gsub(currentPlate, "%s+", ""))
                Citizen.Wait(300)
                local parts = {}

                for b, g in pairs(currentVehicleParts) do
                    parts[b] = g
                end

                for k, v in pairs(parts) do
                    if Config.Engines[v.type] ~= nil then
                        v.label = Config.Engines[v.type].label
                    end
                    if Config.Turbos[v.type] ~= nil then
                        v.label = Config.Turbos[v.type].label
                    end
                    if Config.Transmitions[v.type] ~= nil then
                        v.label = Config.Transmitions[v.type].label
                    end
                    if Config.Suspensions[v.type] ~= nil then
                        v.label = Config.Suspensions[v.type].label
                    end
                    if Config.Oils[v.type] ~= nil then
                        v.label = Config.Oils[v.type].label
                    end
                    if Config.Tires[v.type] ~= nil then
                        v.label = Config.Tires[v.type].label
                    end
                    if Config.Brakes[v.type] ~= nil then
                        v.label = Config.Brakes[v.type].label
                    end
                    if Config.Nitros[v.type] ~= nil then
                        v.label = Config.Nitros[v.type].label
                    end

                    if Config.ToolBoxAccess[k] == nil then
                        parts[k] = nil
                    end
                end

                local mileage = 0
                if Config.UseMiles then
                    mileage = currentMileage / 1609.34
                else
                    mileage = currentMileage / 1000
                end

                local allparts = {}

                allparts["engine"] = Config.Engines
                allparts["turbo"] = Config.Turbos
                allparts["brakes"] = Config.Brakes
                allparts["suspension"] = Config.Suspensions
                allparts["transmition"] = Config.Transmitions
                allparts["oil"] = Config.Oils
                allparts["tires"] = Config.Tires
                allparts["nitro"] = Config.Nitros

                SetNuiFocus(true, true)
                SendNUIMessage(
                    {
                        type = "open",
                        parts = parts,
                        plate = currentPlate,
                        allparts = allparts,
                        mileage = math.floor(mileage * 100) / 100,
                        workshop = false,
                        vehicleType = GetVehicleClass(currentVehicle),
                        model = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
                    }
                )
            end
        end
    end
)

RegisterNetEvent("core_vehicle:startInstall")
AddEventHandler(
    "core_vehicle:startInstall",
    function(partType, part)
        w1, w2, w3, w4 = true, true, true, true
        done = 0

        SendTextMessage(Config.Text["mechanic_action_started"])
        repairMode = true
        repairPartType = partType
        repairPart = part
        repairInstall = true
    end
)

RegisterNetEvent("core_vehicle:startRepair")
AddEventHandler(
    "core_vehicle:startRepair",
    function(partType, part)
        w1, w2, w3, w4 = true, true, true, true
        done = 0

        SendTextMessage(Config.Text["mechanic_action_started"])
        repairMode = true
        repairPartType = partType
    end
)

RegisterNUICallback(
    "repair",
    function(data)
        local partType = data["parttype"]

        TriggerServerEvent("core_vehicle:canRepair", partType, currentVehicleParts[partType].type)
    end
)

RegisterNUICallback(
    "install",
    function(data)
        local part = data["part"]
        local partType = data["parttype"]

        TriggerServerEvent("core_vehicle:canInstall", partType, part)
    end
)

RegisterNUICallback(
    "replace",
    function(data)
        local part = data["part"]
        local partType = data["parttype"]

        TriggerServerEvent("core_vehicle:canInstall", partType, part)
    end
)

RegisterNUICallback(
    "close",
    function(data)
        SetNuiFocus(false, false)
    end
)

RegisterCommand(
    Config.BearHandsAccessCommand,
    function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local veh, dst = ESX.Game.GetClosestVehicle(coords)

        if dst < 3.0 then
            if GetVehicleDoorAngleRatio(veh, 4) ~= 0 then
                local plate = GetVehicleNumberPlateText(veh)

                currentVehicle = veh
                currentPlate = string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")
                TriggerServerEvent("core_vehicle:getVehicleHandling", string.gsub(plate, "%s+", ""))

                TriggerServerEvent("core_vehicle:getVehicleParts", string.gsub(plate, "%s+", ""))
                Citizen.Wait(300)
                local parts = {}

                for b, g in pairs(currentVehicleParts) do
                    parts[b] = g
                end

                for k, v in pairs(parts) do
                    if Config.Engines[v.type] ~= nil then
                        v.label = Config.Engines[v.type].label
                    end
                    if Config.Turbos[v.type] ~= nil then
                        v.label = Config.Turbos[v.type].label
                    end
                    if Config.Transmitions[v.type] ~= nil then
                        v.label = Config.Transmitions[v.type].label
                    end
                    if Config.Suspensions[v.type] ~= nil then
                        v.label = Config.Suspensions[v.type].label
                    end
                    if Config.Oils[v.type] ~= nil then
                        v.label = Config.Oils[v.type].label
                    end
                    if Config.Tires[v.type] ~= nil then
                        v.label = Config.Tires[v.type].label
                    end
                    if Config.Brakes[v.type] ~= nil then
                        v.label = Config.Brakes[v.type].label
                    end
                    if Config.Nitros[v.type] ~= nil then
                        v.label = Config.Nitros[v.type].label
                    end

                    if Config.BearHandsAccess[k] == nil then
                        parts[k] = nil
                    end
                end

                local mileage = 0
                if Config.UseMiles then
                    mileage = currentMileage / 1609.34
                else
                    mileage = currentMileage / 1000
                end

                local allparts = {}

                allparts["engine"] = Config.Engines
                allparts["turbo"] = Config.Turbos
                allparts["brakes"] = Config.Brakes
                allparts["suspension"] = Config.Suspensions
                allparts["transmition"] = Config.Transmitions
                allparts["oil"] = Config.Oils
                allparts["tires"] = Config.Tires
                allparts["nitro"] = Config.Nitros

                SetNuiFocus(true, true)
                SendNUIMessage(
                    {
                        type = "open",
                        parts = parts,
                        plate = plate,
                        allparts = allparts,
                        mileage = math.floor(mileage * 100) / 100,
                        workshop = false,
                        vehicleType = GetVehicleClass(currentVehicle),
                        model = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
                    }
                )
            else
                SendTextMessage(Config.Text["hood_closed"])
            end
        end
    end
)

RegisterNetEvent("core_vehicle:getVehicleParts_c")
AddEventHandler(
    "core_vehicle:getVehicleParts_c",
    function(parts, mileage)
        currentMileage = mileage
        SetUpVehicle(parts)
    end
)

RegisterNetEvent("core_vehicle:getVehicleHandling_c")
AddEventHandler(
    "core_vehicle:getVehicleHandling_c",
    function(plate, handlingData)
        if handlingData == nil then
            local handling = {}

            handling["fDriveInertia"] = GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fDriveInertia")

            if Config.UseRelativeValues then
                handling["fClutchChangeRateScaleDownShift"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fClutchChangeRateScaleDownShift")
                handling["fClutchChangeRateScaleUpShift"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fClutchChangeRateScaleUpShift")
                handling["fLowSpeedTractionLossMult"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fLowSpeedTractionLossMult")
                handling["fTractionCurveLateral"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fTractionCurveLateral")
                handling["fBrakeForce"] = GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fBrakeForce")
                handling["fSuspensionRaise"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fSuspensionRaise")
                handling["fTractionCurveMax"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fTractionCurveMax")
                handling["fTractionCurveMin"] =
                    GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fTractionCurveMin")
            else
                handling["fClutchChangeRateScaleDownShift"] = 0
                handling["fClutchChangeRateScaleUpShift"] = 0
                handling["fLowSpeedTractionLossMult"] = 0
                handling["fTractionCurveLateral"] = 0
                handling["fBrakeForce"] = 0
                handling["fSuspensionRaise"] = 0
                handling["fTractionCurveMax"] = 0
                handling["fTractionCurveMin"] = 0
            end

            TriggerServerEvent("core_vehicle:setVehicleHandling", plate, handling)
            currentVehicleHandling = handling
        else
            currentVehicleHandling = handlingData
        end
    end
)

function saveVehicleData(plate)
    TriggerServerEvent("core_vehicle:setVehicleParts", plate, json.encode(currentVehicleParts), currentMileage)
end

function SetUpVehicle(parts)
    local veh = currentVehicle
    currentVehicleParts = parts

    if currentVehicleParts["engine"] then
        setEngine(veh)
    end
    if currentVehicleParts["brakes"] then
        setBrakes(veh)
    end
    if currentVehicleParts["suspension"] then
        setSuspension(veh)
    end
    if currentVehicleParts["turbo"] then
        setTurbo(veh)
    end
    if currentVehicleParts["transmition"] then
        setTransmition(veh)
    end
    if currentVehicleParts["tires"] then
        setTires(veh)
    end
    if currentVehicleParts["nitro"] then
        setNitro(veh)
    end
end

function setEngine(veh)
    local engine = Config.Engines[currentVehicleParts["engine"].type]
    local power = engine.power - ((engine.power / currentVehicleParts["engine"].health) * 1.5)

    SetVehicleEnginePowerMultiplier(veh, currentMulti + power)
    currentMulti = currentMulti + power

    if string.upper(engine.sound) ~= "DEFAULT" then
        ForceVehicleEngineAudio(veh, engine.sound)
    end
end

function setNitro(veh)
    local nitro = Config.Nitros[currentVehicleParts["nitro"].type]

    nitroPower = 100
end

function setTurbo(veh)
    local turbo = Config.Turbos[currentVehicleParts["turbo"].type]

    SetVehicleModKit(veh, 0)
    ToggleVehicleMod(veh, 18, true)

    turboPower = turbo.power
end

function setTransmition(veh)
    local trans = Config.Transmitions[currentVehicleParts["transmition"].type]
    local shiftingtime = trans.shiftingtime
    local drivingwheels = trans.drivingwheels

    if drivingwheels == "AWD" then
        SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.5)
    elseif drivingwheels == "RWD" then
        SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.0)
    elseif drivingwheels == "FWD" then
        SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 1.0)
    end

    if currentVehicleParts["transmition"].health > 0 then
        SetVehicleHandlingFloat(
            veh,
            "CHandlingData",
            "fClutchChangeRateScaleDownShift",
            currentVehicleHandling["fClutchChangeRateScaleDownShift"] + shiftingtime
        )
        SetVehicleHandlingFloat(
            veh,
            "CHandlingData",
            "fClutchChangeRateScaleUpShift",
            currentVehicleHandling["fClutchChangeRateScaleUpShift"] + shiftingtime
        )
    else
        SetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleDownShift", 0.0)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleUpShift", 0.0)
    end
end

function setTires(veh)
    local tires = Config.Tires[currentVehicleParts["tires"].type]
    local traction = tires.traction
    local lowspeedtraction = tires.lowspeedtraction

    SetVehicleHandlingFloat(
        veh,
        "CHandlingData",
        "fLowSpeedTractionLossMult",
        currentVehicleHandling["fLowSpeedTractionLossMult"] + lowspeedtraction
    )
    SetVehicleHandlingFloat(
        veh,
        "CHandlingData",
        "fTractionCurveMin",
        currentVehicleHandling["fTractionCurveMin"] + traction
    )
end

function setSuspension(veh)
    local suspension = Config.Suspensions[currentVehicleParts["suspension"].type]
    local height = suspension.height
    local traction = suspension.traction

    if currentVehicleParts["suspension"].health > 0 then
        SetVehicleHandlingFloat(
            veh,
            "CHandlingData",
            "fSuspensionRaise",
            currentVehicleHandling["fSuspensionRaise"] + height
        )
        SetVehicleHandlingFloat(
            veh,
            "CHandlingData",
            "fTractionCurveMax",
            currentVehicleHandling["fTractionCurveMax"] + traction
        )
    else
        SetVehicleHandlingFloat(veh, "CHandlingData", "fSuspensionRaise", -0.10)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax", 0.5)
    end
end

function setBrakes(veh)
    local brakes = Config.Brakes[currentVehicleParts["brakes"].type]
    local power = brakes.power

    SetVehicleModKit(veh, 0)
    local brakes = 0
    if power > 0 and power < 0.5 then
        brakes = 1
    end
    if power > 0.5 and power < 1.0 then
        brakes = 2
    end
    if power > 1.0 and power < 1.5 then
        brakes = 3
    end
    if power > 1.5 then
        brakes = 4
    end
    SetVehicleMod(veh, 12, brakes, false)

    if currentVehicleParts["brakes"].health > 0 then
        SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", currentVehicleHandling["fBrakeForce"] + power)
    else
        SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", 0.0)
    end
end

--NITRO SYSTEM

RegisterNetEvent("core_vehicle:sync")
AddEventHandler(
    "core_vehicle:sync",
    function(playerServerId, boostEnabled, purgeEnabled, lastVehicle)
        local playerId = GetPlayerFromServerId(playerServerId)

        if not NetworkIsPlayerConnected(playerId) then
            return
        end

        local player = GetPlayerPed(playerId)
        local vehicle = GetVehiclePedIsIn(player, lastVehicle)
        local driver = GetPedInVehicleSeat(vehicle, -1)

        SetVehicleLightTrailEnabled(vehicle, boostEnabled)
        SetVehicleNitroPurgeEnabled(vehicle, purgeEnabled)
    end
)

function IsVehicleLightTrailEnabled(vehicle)
    return trailpurgeVehicles[vehicle] == true
end

function CreateVehicleLightTrail(vehicle, bone, scale)
    UseParticleFxAssetNextCall("core")
    local ptfx =
        StartParticleFxLoopedOnEntityBone(
        "veh_light_red_trail",
        vehicle,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        bone,
        scale,
        false,
        false,
        false
    )
    SetParticleFxLoopedEvolution(ptfx, "speed", 1.0, false)
    return ptfx
end

function SetVehicleLightTrailEnabled(vehicle, enabled)
    if IsVehicleLightTrailEnabled(vehicle) == enabled then
        return
    end

    if enabled then
        local ptfxs = {}

        local leftTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_l"), 1.0)
        local rightTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_r"), 1.0)

        table.insert(ptfxs, leftTrail)
        table.insert(ptfxs, rightTrail)

        trailpurgeVehicles[vehicle] = true
        trailpurgeParticles[vehicle] = ptfxs
    else
        if trailpurgeParticles[vehicle] and #trailpurgeParticles[vehicle] > 0 then
            for _, particleId in ipairs(trailpurgeParticles[vehicle]) do
                StopVehicleLightTrail(particleId, 500)
            end
        end

        trailpurgeVehicles[vehicle] = nil
        trailpurgeParticles[vehicle] = nil
    end
end

function StopVehicleLightTrail(ptfx, duration)
    Citizen.CreateThread(
        function()
            local startTime = GetGameTimer()
            local endTime = GetGameTimer() + duration
            while GetGameTimer() < endTime do
                Citizen.Wait(0)
                local now = GetGameTimer()
                local scale = (endTime - now) / duration
                SetParticleFxLoopedScale(ptfx, scale)
                SetParticleFxLoopedAlpha(ptfx, scale)
            end
            StopParticleFxLooped(ptfx)
        end
    )
end

function CreateVehicleExhaustBackfire(vehicle, scale)
    local exhaustNames = {
        "exhaust",
        "exhaust_2",
        "exhaust_3",
        "exhaust_4",
        "exhaust_5",
        "exhaust_6",
        "exhaust_7",
        "exhaust_8",
        "exhaust_9",
        "exhaust_10",
        "exhaust_11",
        "exhaust_12",
        "exhaust_13",
        "exhaust_14",
        "exhaust_15",
        "exhaust_16"
    }

    for _, exhaustName in ipairs(exhaustNames) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, exhaustName)

        if boneIndex ~= -1 then
            local pos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)

            UseParticleFxAssetNextCall("core")
            StartParticleFxNonLoopedOnEntity(
                "veh_backfire",
                vehicle,
                off.x,
                off.y,
                off.z,
                0.0,
                0.0,
                0.0,
                scale,
                false,
                false,
                false
            )
        end
    end
end

function IsVehicleNitroPurgeEnabled(vehicle)
    return purgeVehicles[vehicle] == true
end

function SetVehicleNitroPurgeEnabled(vehicle, enabled)
    if IsVehicleNitroPurgeEnabled(vehicle) == enabled then
        return
    end

    if enabled then
        local bone = GetEntityBoneIndexByName(vehicle, "bonnet")
        local pos = GetWorldPositionOfEntityBone(vehicle, bone)
        local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)
        local ptfxs = {}

        for i = 0, 3 do
            local leftPurge = CreateVehiclePurgeSpray(vehicle, off.x - 0.5, off.y + 0.05, off.z, 40.0, -20.0, 0.0, 0.5)
            local rightPurge = CreateVehiclePurgeSpray(vehicle, off.x + 0.5, off.y + 0.05, off.z, 40.0, 20.0, 0.0, 0.5)

            table.insert(ptfxs, leftPurge)
            table.insert(ptfxs, rightPurge)
        end

        purgeVehicles[vehicle] = true
        purgeParticles[vehicle] = ptfxs
    else
        if purgeParticles[vehicle] and #purgeParticles[vehicle] > 0 then
            for _, particleId in ipairs(purgeParticles[vehicle]) do
                StopParticleFxLooped(particleId)
            end
        end

        purgeVehicles[vehicle] = nil
        purgeParticles[vehicle] = nil
    end
end

function CreateVehiclePurgeSpray(vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale)
    UseParticleFxAssetNextCall("core")
    return StartParticleFxLoopedOnEntity(
        "ent_sht_steam",
        vehicle,
        xOffset,
        yOffset,
        zOffset,
        xRot,
        yRot,
        zRot,
        scale,
        false,
        false,
        false
    )
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)

        SetTextDropshadow(1, 1, 1, 1, 255)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.55 * scale, 4)
        local width = EndTextCommandGetWidth(4)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end
