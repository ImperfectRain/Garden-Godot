# System: Resources

## Plainspeak

Resources are what the living garden passes around. The MVP only has four: Light, Rot, Blood, and Echo.

Do not add more resources until these are fun.

## Technical

Owner file: `game/scripts/garden/resource_manager.gd`

Autoload name: `GardenResources`

Resource ids:

- `light`
- `rot`
- `blood`
- `echo`

Primary APIs:

- `reset()`
- `get_amount(resource_id) -> int`
- `get_all() -> Dictionary`
- `add(resource_id, amount) -> int`
- `can_spend(resource_id, amount) -> bool`
- `spend(resource_id, amount) -> bool`
- `set_cap(resource_id, cap)`

Signals:

- `resource_changed(resource_id, amount, delta)`
- `resource_spent(resource_id, amount)`
- `resource_failed(resource_id, requested, available)`

Implementation notes:

- First-pass resources are global to the garden, not per tile.
- Future work may add per-piece storage for Grave Bell and similar objects.
- If a trigger cannot pay a cost, the trigger should not be recorded as a successful Bloomchain step.
