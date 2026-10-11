# Tuff Advance Hud [ QBCore , ESX , QBOX , vMenu and Standalone ]

Thank you for Purchasing Tuff Advance Hud !

## Installation

Visit Tuff Scripts Documentation for detailed installation Guide !

- https://tuff-scripts.gitbook.io/tuff-scripts/scripts/tuff-advanced-hud

## ESX Framework Seatbelt Not Working, Try this

- First of all make sure you are not runing any other seatbelt script

- Go to esx_cruisecontrol/config.lua and disable Seatbelt

```lua
    Seatbelt = {
        Enable = false,
        Key = "B",
        EjectCheckSpeed = 45, -- MPH
        RagdollTime = 1,      -- MS
        Export = function(state)
            exports[Config.HudResource]:SeatbeltState(state)
        end
    }
```

## Need Support Come to my Discord

- My Discord Username : tuffscripts
- Discord Invite: https://discord.gg/rJGkVkqcMe
- Tebex Link : https://tuff-scripts.tebex.io/
