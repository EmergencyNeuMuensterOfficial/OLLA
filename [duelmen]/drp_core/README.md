# drp_core

The minimal custom framework core for Dülmen Roleplay. It requires `oxmysql` and creates its `drp_players` table automatically when the resource starts.

## Install

Copy the `resources/[duelmen]/drp_core` folder into the server-data `resources/[duelmen]` folder, then add this start order to `server.cfg`:

```cfg
ensure oxmysql
ensure drp_core
```

`mysql_connection_string` must be configured before `ensure oxmysql`.

## Exports

```lua
local player = exports.drp_core:GetPlayer(source)
exports.drp_core:AddMoney(source, 'bank', 100, 'salary')
exports.drp_core:RemoveMoney(source, 'cash', 50, 'purchase')
```

Only server-side code may change money. Do not trust values sent from a client.
