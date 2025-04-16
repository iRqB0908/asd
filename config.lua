Config = {

-------------------------------------------------------------
-- IMPORTANT  
-- All parts need to be added to inventory
-- Custom vehicle sounds for engines (https://www.gta5-mods.com/vehicles/brabus-inspired-custom-engine-sound-add-on-sound)
-------------------------------------------------------------


WearRate = 100000, -- The rate parts wear off (Higher the value less wear on the parts)
UseMiles = true, -- If set to false it will use kilometers
UseRelativeValues = true, -- If set to true cars performance wouldnt be affected with stock parts. Otherwise stock car parts will make the car slower


--Times to repair/install certain parts in miliseconds
EngineRepairTime = 10000, 
EngineInstallTime = 15000,

TurboRepairTime = 10000, 
TurboInstallTime = 15000,

NitroInstallTime = 10000,

OilInstallTime = 5000,

TransmitionInstallTime = 14000,
TransmitionRepairTime = 10000,

TireRepairTime = 3000,
TireInstallTime = 3000,

BreaksInstallTime = 4000,
BreaksRepairTime = 4000,

SuspensionInstallTime = 5000,
SuspensionRepairTime = 5000,


MechanicWorkshop = { -- Mechanic Workshops where mechanics can use MechanicWorkshopAccess

    {coords = vector3(110.4730758667,6626.2397460938,31.78723144531), radius = 20.0}

},

--Check engine, Low oil, Mileage location on screen
InfoBottom = 1,
InfoRight = 1,


-- Parts of vehicle certain condicions can access! For example with mechanic tool box you will be able to access parts mentioned in MechanicTools
-- PART LIST (engine, oil, brakes, suspension, turbo, nitro )

BearHandsAccessCommand = 'inspect',
BearHandsAccess = {
	['oil'] = true,
    ['nitro'] = true

},

ToolBoxAccess = {
	['oil'] = true,
    ['tires'] = true,
     ['nitro'] = true
},

MechanicToolsAccess = {
    ['brakes'] = true,
    ['oil'] = true,
    ['tires'] = true,
    ['suspension'] = true,
    ['nitro'] = true
},

MechanicWorkshopAccess = {
    ['brakes'] = true,
    ['oil'] = true,
    ['nitro'] = true,
    ['tires'] = true,
    ['suspension'] = true,
    ['engine'] = true,
    ['transmition'] = true,
    ['turbo'] = true
},


-- Parts that your vehicle will be able to use to modify its performance on the road. These parts also need to be added to the item databse.
-- usability - is to exclude some parts to be used on some vehicles exclusive is usually car spawn code
-- power - depends if using relative values but it will increase vehicles power
-- durability - (IMPORTANT) Enter value from 0 to 100. 100 means that the part will never break
-- repair - enter ingrediants to fix up the part. If part is at 0 percent you will need to replace.

Turbos = { -- Turbos affect your car speed at higher rpm's. When turbos break you lose power

    ['turbo_lvl_1'] = {
        label = "GARET TURBO", 
        usability = {exclusive = {}, vehicletypes = {}}, 
        power = 10.0,
        durability = 50.0,
        repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
    }

},

NitroKey = 'LEFTSHIFT', -- Key to use nitro when available

Nitros = { -- Nitro affect vehicle power and increases vehicle wear during usage

    ['nos'] = {
        label = "NOS", 
        usability = {exclusive = {}, vehicletypes = {}},
        power = 100.0,
        durability = 30.0 -- Here enter seconds until nitro will run out
    }

},

Transmitions = {

['stock_transmition'] = {
    label = "STOCK TRANSMITION", 
    usability = {exclusive = {}, vehicletypes = {}},
    shiftingtime = 0.9,
    drivingwheels = 'DEFAULT',
    durability = 80.0,
    repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
},

['race_transmition'] = {
    label = "RACE TRANSMITION", 
    usability = {exclusive = {}, vehicletypes = {}},
    shiftingtime = 3.0,
    drivingwheels = 'RWD',
    durability = 50.0,
    repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
}

},

Suspensions = { -- Suspension will affect handling and will look super cool. Decrease power to lower the vehicle and give better handling.

['stock_suspension'] = {
    label = "STOCK SUSPENSION", 
    usability = {exclusive = {}, vehicletypes = {}},
    height = 0,
    traction = 0,
    durability = 80.0,
    repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
},

['race_suspension'] = {
    label = "RACE SUSPENSION", 
    usability = {exclusive = {}, vehicletypes = {}},
    height = -0.04,
    traction = 1.0,
    durability = 50.0,
    repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
},



},

Oils = { -- Oils keep your car cool and happy if oil runs out car parts will start to wear off fast.

['stock_oil'] = {
    label = "STOCK OIL", 
    usability = {exclusive = {}, vehicletypes = {}},
    durability = 10.0,
},

['shell_oil'] = {
    label = "SHELL OIL", 
    usability = {exclusive = {}, vehicletypes = {}},
    durability = 50.0,
}

},



Engines = { -- Engines will make your car faster and will give it a different sound. Increase power to make car faster. 

['stock_engine'] = {
        label = "STOCK ENGINE", 
        power = 0.0,
        durability = 80.0,
        usability = {exclusive = {}, vehicletypes = {}},
        sound = "DEFAULT",
        repair = {
            ['iron'] = {amount = 10, reusable = false},
            ['piston'] = {amount = 3, reusable = false}
        }
}, 

['v8engine'] = {
        label = "V8 ENGINE", 
        power = 30.0,
        durability = 50.0,
        usability = {exclusive = {}, vehicletypes = {}},
        sound = "brabus850", -- These sounds are not in by default download from (https://www.gta5-mods.com/vehicles/brabus-inspired-custom-engine-sound-add-on-sound)
        repair = {
            ['iron'] = {amount = 10, reusable = false},
            ['piston'] = {amount = 8, reusable = false}
        }
}, 

['2jzengine'] = {
        label = "2JZ ENGINE", 
        power = 50.0,
        durability = 50.0,
        usability = {exclusive = {}, vehicletypes = {}},
        sound = "toysupmk4", -- These sounds are not in by default download from (https://www.gta5-mods.com/vehicles/brabus-inspired-custom-engine-sound-add-on-sound)
        repair = {
            ['iron'] = {amount = 10, reusable = false},
            ['piston'] = {amount = 6, reusable = false}
        }
}, 

},
 
Tires = { -- Tires affect your cars handling when launching and in corners. Increase traction for better grip or decrease for more drift. When they wear off you will drive without tires lol

['stock_tires'] = {
    label = "STOCK TIRES", 
    usability = {exclusive = {}, vehicletypes = {}},
    traction = -0.04,
    lowspeedtraction = 0.0,
    durability = 80.0,
    repair = {
            ['rubber'] = {amount = 5, reusable = false}
        }
},

['michelin_tires'] = {
    label = "MICHELIN", 
    usability = {exclusive = {}, vehicletypes = {}},
    traction = 1.0,
    lowspeedtraction = -2.7,
    durability = 30.0,
    repair = {
            ['rubber'] = {amount = 5, reusable = false}
        }
},


},

Brakes = { -- Brakes allow you to stop your car. Increase power to make brakes more affective. When brakes break you will lose ability to break 

['stock_brakes'] = {
    label = "STOCK BRAKES", 
    usability = {exclusive = {}, vehicletypes = {}},
    power = 1.0,
    durability = 30.0,
    repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
},

['race_brakes'] = {
    label = "CERAMIC BRAKES", 
    usability = {exclusive = {}, vehicletypes = {}},
    power = 2.0,
    durability = 30.0,
    repair = {
            ['iron'] = {amount = 5, reusable = false}
        }
}

},



Text = {

    ['hood_closed'] = 'Hood is closed!',
    ['mechanic_action_complete'] = 'Repair completed',
    ['mechanic_action_started'] = 'Repair started',
    ['wrong_job'] = 'Incorrect job',
    ['not_enough'] = 'Not enough items'

}

}



function SendTextMessage(msg)

        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(0,1)

        --EXAMPLE USED IN VIDEO
        --exports['mythic_notify']:SendAlert('inform', msg)

end
