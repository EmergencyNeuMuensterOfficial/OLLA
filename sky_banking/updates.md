# This file includes update instructions and changelogs for new versions

**Current version 1.1.1**

## Patch from 1.1 to 1.1.1

- Fixed issues related to transfers involving account numbers that start with 0
- Fixed multichar issues on qbcore

### How to update

- Replace the source/ folder
- Download sky_base from keymaster and replace config/framework/qb.lua


## Update from 1.0 to 1.1

- Added detecting all atm points automatically
- Added ox_target support

### How to update

- Replace the source/ folder
- Replace config/style.css
- Add following code to config/config.lua:

```lua
Config.ESXCoreResource = "es_extended" -- ESX ONLY
```

- Replace fxmanifest.lua

execute the following sql query:
```sql
ALTER TABLE banking_users
ADD COLUMN totals longtext;
```