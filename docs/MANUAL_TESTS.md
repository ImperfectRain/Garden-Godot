# Manual MVP Test Checklist

Use this checklist before and after small MVP changes. The goal is to confirm the first fun test is still understandable, gentle, and focused on the smallest playable loop.

## First Fun Loop

- [ ] Open the project in Godot 4.
- [ ] Run `res://game/scenes/debug/first_fun_test.tscn`.
- [ ] Confirm WASD movement works.
- [ ] Confirm Lantern Lily produces Light after roughly 5 seconds.
- [ ] Confirm pressing Space with less than 2 Light fails clearly in the debug log.
- [ ] Confirm pressing Space with 2 or more Light grants shield.
- [ ] Confirm a visible blue placeholder shield ring appears around the player when shield is active.
- [ ] Confirm Light is spent when Saintmoth grants shield.
- [ ] Confirm the debug UI updates resources, health, shield, garden rows, status, and event log.

## Enemy Pressure

- [ ] Confirm the Drifter slowly follows the player.
- [ ] Confirm Drifter contact damage reduces shield before health.
- [ ] Confirm the visible shield ring disappears when shield reaches 0.
- [ ] Confirm Drifter contact damage reduces health after shield is gone.
- [ ] Confirm player defeat is visible through the debug status or defeat signal behavior.

## Garden Placement

- [ ] Confirm the visual Garden panel shows a 3x3 grid.
- [ ] Confirm Saintmoth appears in the visually distinct Heart Tile.
- [ ] Confirm Lantern Lily appears in its starting cell.
- [ ] Confirm the reward panel appears after the survival room timer completes.
- [ ] Confirm selecting a reward places the chosen piece into the garden.
- [ ] Confirm the visual Garden panel updates after reward placement.
- [ ] Confirm the Heart Tile cannot be overwritten.
- [ ] Confirm occupied cells reject placement.
- [ ] Confirm garden debug rows update after placement.

## Bloomchain

- [ ] Choose Bellflower from the reward panel.
- [ ] Wait until Lantern Lily has produced at least 2 Light.
- [ ] Press Space to Pulse Saintmoth.
- [ ] Confirm triggered garden cells briefly flash or show an event marker in the visual Garden panel.
- [ ] Confirm the Bloomchain reaches length 3: Lantern Lily -> Saintmoth -> Bellflower.
- [ ] Wait for the short chain finalization timeout.
- [ ] Confirm the finalized Bloomchain appears in the debug UI.
- [ ] Confirm the finalized Bloomchain is recorded in the journal.
- [ ] Confirm failed Saintmoth Pulse attempts do not count as successful Bloomchain steps.

## Notes

- Keep this checklist focused on the current MVP. Do not add tests for future companions, bosses, biomes, procedural generation, art polish, or additional resources until those systems exist.
