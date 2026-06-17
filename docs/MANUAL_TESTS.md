# Manual MVP Test Checklist

Use this checklist before and after small MVP changes. The goal is to confirm the first fun test is still understandable, gentle, and focused on the smallest playable loop.

## First Fun Loop

- [ ] Open the project in Godot 4.
- [ ] Run `res://game/scenes/debug/first_fun_test.tscn`.
- [ ] Confirm WASD movement works.
- [ ] Confirm pressing R restarts the prototype scene.
- [ ] Confirm the player and Saintmoth render as temporary sprite placeholders instead of polygon-only shapes.
- [ ] Confirm Lantern Lily produces Light after roughly 5 seconds.
- [ ] Confirm pressing Space with less than 2 Light fails clearly in the debug log.
- [ ] Confirm pressing Space with 2 or more Light grants shield.
- [ ] Confirm Saintmoth grants a useful but not runaway shield amount.
- [ ] Confirm a visible blue placeholder shield ring appears around the player when shield is active.
- [ ] Confirm Light is spent when Saintmoth grants shield.
- [ ] Confirm the debug UI updates resources, health, shield, garden rows, status, and event log.

## Enemy Pressure

- [ ] Confirm the Drifter renders as a temporary sprite placeholder instead of a polygon-only shape.
- [ ] Confirm the Drifter slowly follows the player.
- [ ] Confirm Drifter contact damage reduces shield before health.
- [ ] Confirm the visible shield ring disappears when shield reaches 0.
- [ ] Confirm Drifter contact damage reduces health after shield is gone.
- [ ] Confirm player defeat is visible through the debug status or defeat signal behavior.
- [ ] Confirm Grave Bell or another enemy damage effect can damage Drifter when triggered.
- [ ] Confirm defeated Drifter logs a death event and disappears.
- [ ] Confirm Gravecap produces Rot after a Drifter death if Gravecap is placed.

## Garden Placement

- [ ] Confirm the visual Garden panel shows a 3x3 grid.
- [ ] Confirm Saintmoth appears in the visually distinct Heart Tile.
- [ ] Confirm the currently selected garden cell has a visible selection highlight.
- [ ] Confirm Lantern Lily appears in its starting cell.
- [ ] Confirm occupied garden cells show temporary placeholder icons alongside readable text.
- [ ] Confirm the reward panel appears after the survival room timer completes.
- [ ] Confirm selecting a reward starts manual garden placement instead of immediately placing the piece.
- [ ] Confirm Arrow keys move the highlighted placement cell in the visual Garden panel.
- [ ] Confirm cells adjacent to the pending placement are highlighted.
- [ ] Confirm adjacent pieces that match the pending piece's likes get a stronger synergy highlight.
- [ ] Confirm placement status shows simple "Works with" hints when relevant.
- [ ] Confirm Enter or E places the chosen piece in the highlighted valid cell.
- [ ] Confirm Escape cancels placement and returns to reward choice.
- [ ] Confirm the visual Garden panel updates after reward placement.
- [ ] Confirm the Heart Tile cannot be overwritten.
- [ ] Confirm occupied cells reject placement.
- [ ] Confirm garden debug rows update after placement.

## Expedition Map

- [ ] Confirm the Expedition Map panel is visible.
- [ ] Confirm the starting room is marked as current.
- [ ] Clear a room and claim/place the reward.
- [ ] Confirm adjacent cardinal rooms are revealed after the room is cleared.
- [ ] Confirm Arrow keys select revealed adjacent rooms when not placing a reward.
- [ ] Confirm Enter or E travels to the selected adjacent room.
- [ ] Confirm backtracking to a revealed adjacent room is allowed.
- [ ] Confirm hidden or non-adjacent rooms cannot be selected for travel.

## Bloomchain

- [ ] Choose Bellflower from the reward panel.
- [ ] Wait until Lantern Lily has produced at least 2 Light.
- [ ] Press Space to Pulse Saintmoth.
- [ ] Confirm triggered garden cells briefly flash or show an event marker in the visual Garden panel.
- [ ] Confirm different trigger types use readable markers such as production `+`, movement/copy `>`, damage `!`, and repeat `x`.
- [ ] Confirm the Bloomchain reaches length 3: Lantern Lily -> Saintmoth -> Bellflower.
- [ ] Wait for the short chain finalization timeout.
- [ ] Confirm the finalized Bloomchain appears in the debug UI.
- [ ] Confirm the finalized Bloomchain is recorded in the journal.
- [ ] Confirm failed Saintmoth Pulse attempts do not count as successful Bloomchain steps.

## Flora Events

- [ ] Choose Blood Rose from the reward panel in a run where it is offered.
- [ ] Place Blood Rose in any valid non-heart cell.
- [ ] Let shield drop to 0.
- [ ] Let Drifter deal health damage.
- [ ] Confirm Blood Rose produces +1 Blood after actual health damage.
- [ ] Confirm shield-only damage does not trigger Blood Rose.

## Fauna Events

- [ ] Place Rotling before or after Gravecap.
- [ ] Defeat Drifter while Gravecap is placed.
- [ ] Confirm Gravecap produces Rot and Rotling consumes 2 Rot when enough Rot is available.
- [ ] Confirm Rotling logs a placeholder larva helper request.
- [ ] Place Mawlet and Blood Rose.
- [ ] Let Blood Rose produce at least 2 Blood through actual health damage.
- [ ] Confirm Mawlet consumes 2 Blood and repeats the previous successful garden trigger without looping forever.
- [ ] Place Glass Beetle adjacent to a producer and another piece that can use that resource.
- [ ] Confirm Glass Beetle reacts only when the resource source is adjacent and a valid adjacent target exists.

## Object Events

- [ ] Place Grave Bell before Bellflower produces Echo.
- [ ] Confirm Grave Bell stores Echo.
- [ ] Confirm Grave Bell rings and damages Drifter when it reaches 3 stored Echo.
- [ ] Place Mirror Shard opposite a producing or damaging piece across the 3x3 grid.
- [ ] Confirm Mirror Shard copies the opposite tile output at reduced strength.
- [ ] Place Bone Trellis adjacent to two Flora.
- [ ] Confirm Bone Trellis logs its connection marker and shares adjacent resource availability to connected Flora.
- [ ] Place Tiny Fence adjacent to Lantern Lily or another Flora.
- [ ] Confirm adjacent Flora production is boosted by the Tiny Fence MVP production bonus.

## Notes

- Keep this checklist focused on the current MVP. Do not add tests for future companions, bosses, biomes, procedural generation, art polish, or additional resources until those systems exist.
