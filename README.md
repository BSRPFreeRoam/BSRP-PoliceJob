# 👮 BSRP Police Job

A modern law enforcement system built exclusively for the **BSRP Framework**.

BSRP Police Job provides a complete police roleplay experience, allowing law enforcement personnel to manage duties, respond to incidents, enforce the law, and interact with the community while integrating directly with the BSRP ecosystem. Designed for performance, realism, and immersive roleplay, it serves as the foundation for police operations across BSRP resources.

---

## Features

* 👮 Police job system
* 🚓 Duty management
* 🚨 Emergency response system
* 📋 Police interactions
* 🔍 Investigation support
* 🚔 Police vehicle support
* 🔒 Evidence and enforcement tools
* 📡 Dispatch integration
* ⚡ Optimized performance
* 🔗 Full BSRP Framework integration

---

## Framework Requirements

This resource requires:

* BSRP Framework
* oxmysql
* ox_lib

Recommended:

* ox_inventory
* bsrp-characters
* bsrp-dispatch
* bsrp-mdt
* bsrp-vehicles
* bsrp-garages

---

## Installation

### 1. Place Resource

```text
resources/
└── bsrp-policejob/
```

### 2. Ensure Dependencies

```cfg
ensure oxmysql
ensure ox_lib

ensure bsrp
ensure bsrp-policejob
```

> BSRP Police Job must start after the `bsrp` core resource.

---

## Database

Import the provided SQL file if included:

```sql
sql/bsrp-policejob.sql
```

If automatic database initialization is enabled, required tables will be created automatically.

---

## Configuration

Configuration options can be found in:

```text
config.lua
```

Available settings may include:

* Police departments
* Duty locations
* Rank permissions
* Police vehicles
* Equipment settings
* Arrest settings
* Evidence settings
* Notification options

---

## Police System

### Duty System

Officers can:

* Clock in and out of duty
* Access police equipment
* Respond to calls
* Perform law enforcement actions

---

### Officer Actions

Police members can:

* Interact with civilians
* Conduct traffic stops
* Arrest suspects
* Issue citations
* Manage incidents
* Perform investigations

---

### Law Enforcement Tools

Supports:

* Police vehicles
* Emergency equipment
* Officer permissions
* Dispatch communication
* Investigation features

---

## Police Data

Each officer may have access to:

* Character Identifier
* Rank Information
* Department Information
* Duty Status
* Incident Records
* Arrest Records
* Evidence Information

---

## Framework Integration

### Get Player

```lua
local player = exports.bsrp:GetPlayer(source)

if player then
    print(player.PlayerData.citizenid)
end
```

---

### Check Police Job

```lua
if player.PlayerData.job.name == "police" then
    -- Police actions
end
```

---

### Check Character Loaded

```lua
if player and player.loaded then
    -- Character is active
end
```

---

## Police Events

Example usage:

```lua
RegisterNetEvent('bsrp:policeDutyChanged', function(state)
    print('Duty status:', state)
end)
```

```lua
RegisterNetEvent('bsrp:policeActionCompleted', function()
    print('Police action completed.')
end)
```

> Event names may vary depending on implementation.

---

## Permissions

Administrative police actions can utilize the BSRP permission system:

```lua
if exports.bsrp:IsAdmin(source, 2) then
    -- Police administration actions
end
```

---

## Compatibility

| Resource          | Supported |
| ----------------- | --------- |
| BSRP Framework    | ✅         |
| oxmysql           | ✅         |
| ox_lib            | ✅         |
| ox_inventory      | ✅         |
| bsrp-characters   | ✅         |
| bsrp-dispatch     | ✅         |
| bsrp-mdt          | ✅         |
| bsrp-vehicles     | ✅         |

---

## Police Lifecycle

### Officer Joins

1. Player connects to the server
2. Character data loads
3. Police job information is synchronized
4. Officer systems become available

---

### Police Operations

1. Officer goes on duty
2. Calls and incidents are received
3. Officer responds
4. Actions are performed
5. Records are saved

---

### Data Saving

Police information is saved during:

* Duty changes
* Incident updates
* Character switching
* Player logout
* Server restart

---

## Development

When creating resources that depend on police data:

```lua
local player = exports.bsrp:GetPlayer(source)

if not player then
    return
end

if player.PlayerData.job.name == "police" then
    -- Police resource logic
end
```

Always verify officer permissions and player data server-side before processing law enforcement actions.
