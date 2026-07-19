# bsrp-policejob

Police / LEO job for **BSRP** (no `qb-core`).

## Stack

| Resource | Role |
|----------|------|
| `bsrp` | Framework (jobs, duty, money, metadata) |
| `ox_inventory` | Armory, lockers, evidence, search |
| `ox_target` | Station interactions |
| `ox_lib` | Menus / progress / input |
| `ps-dispatch` | **Optional** panic / officer-down alerts |
| `ps-mdt` | **Optional** MDT open from police menu |

`ps-dispatch` and `ps-mdt` are **not** hard dependencies. If they are not started, related features soft-fail.

## server.cfg

```cfg
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure bsrp
ensure bsrp-policejob
# optional:
# ensure ps-dispatch
# ensure ps-mdt
```

## Features

- Duty toggle, personal locker, trash, evidence lockers, armory (ox)
- Fleet garage + helicopter
- Cuff / soft cuff / escort / vehicle seat / search
- Jail / unjail / fine
- Objects + spike strips
- Fingerprint UI (futuristic BSRP theme)
- F6 police menu, global player ox_target options
- Soft panic → `ps-dispatch` OfficerDown / CustomAlert
- Soft MDT → `ps-mdt` / `/mdt`

## Keybinds / commands

| Input | Action |
|-------|--------|
| **F6** / `/polmenu` | Police menu |
| `/cuff` `/sc` `/escort` `/jail` `/unjail` `/fine` | LEO tools |
| `/takedna` | DNA sample into evidence bag |
| `/spikestrip` `/pobject` | World objects |

## Items (ox_inventory)

`handcuffs`, `empty_evidence_bag`, `filled_evidence_bag`, `armour`, weapons/ammo as configured in `config.lua`.
