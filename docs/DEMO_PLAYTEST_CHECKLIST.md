# Demo Playtest Checklist

Use this checklist when evaluating whether the current first fun test is playable as a small demo, not just whether individual systems work.

## Setup

- [ ] Open the project in Godot 4.x.
- [ ] Run `res://game/scenes/debug/first_fun_test.tscn`.
- [ ] Confirm the screen shows player, Saintmoth, Drifter, debug HUD, Garden panel, and Expedition Map panel.
- [ ] Confirm temporary placeholder sprites are visible for player, Saintmoth, and Drifter.

## First Room

- [ ] Move with WASD for at least 15 seconds and confirm movement feels readable.
- [ ] Let Lantern Lily produce Light after roughly 4 seconds.
- [ ] Press Space with less than 2 Light and confirm the failure is readable.
- [ ] Press Space with at least 2 Light and confirm Saintmoth grants shield.
- [ ] Confirm the blue shield ring, placeholder shield sound, and shield flash are visible/audible.
- [ ] Let Drifter touch the player and confirm shield absorbs damage before health.
- [ ] Defeat Drifter or survive until the reward appears.

## Reward And Placement

- [ ] Confirm reward choices appear after room completion.
- [ ] Confirm the first Meadow reward is Bellflower, so the demo teaches the first Bloomchain before branching.
- [ ] Select the offered reward with 1 or by clicking it.
- [ ] Confirm the selected reward enters placement mode instead of being placed automatically.
- [ ] Move the placement cursor with Arrow keys.
- [ ] Confirm valid, blocked, adjacent, and synergy-highlighted cells are visually distinct.
- [ ] Confirm Mirror Shard, Glass Beetle, and Bone Trellis show route/link/mirror preview hints when relevant.
- [ ] Place the reward with Enter or E.
- [ ] Confirm the Garden panel updates and the room is marked cleared.

## Safe Garden Review

- [ ] Press I after claiming a reward.
- [ ] Confirm the Garden Inspect panel opens.
- [ ] Move between garden cells with Arrow keys.
- [ ] Confirm the panel explains the selected piece using content data: descriptions, triggers, likes, synergies, and stored amounts.
- [ ] Press Escape and confirm expedition map selection works again.

## Expedition Progression

- [ ] Confirm adjacent cardinal rooms are revealed after the room is cleared.
- [ ] Select one revealed adjacent room with Arrow keys.
- [ ] Confirm hidden and non-adjacent rooms cannot be selected.
- [ ] Press Enter or E to travel to the selected room.
- [ ] Confirm a fresh Drifter appears in the new room.
- [ ] Clear at least three rooms, choosing and placing one reward after each.
- [ ] Backtrack to a revealed adjacent cleared room and confirm the map allows it.

## Garden Systems

- [ ] Create the Lantern Lily -> Saintmoth -> Bellflower Bloomchain and confirm it is shown in debug feedback.
- [ ] Confirm chain step feedback appears while the Bloomchain is building.
- [ ] Confirm the finalized Bloomchain replays its cell path with numbered pulses.
- [ ] Confirm resource badges appear in garden cells after resources are produced or stored.
- [ ] Confirm Bellflower can still produce a slow Echo trickle if the player does not Pulse immediately.
- [ ] Place Grave Bell before Echo is produced and confirm it stores Echo.
- [ ] Confirm Grave Bell gives a small placement chime so it is useful before Echo exists.
- [ ] Confirm Grave Bell rings at 3 Echo and can defeat or nearly defeat Drifter.
- [ ] Place Rotling and confirm it can request a weak helper even before the Rot engine is online.
- [ ] Place Blood Rose and Mawlet, then confirm enemy deaths or player damage can build toward Mawlet's 2 Blood cost.
- [ ] Place Bone Trellis next to Flora and confirm it improves production or resource sharing.
- [ ] Place Glass Beetle between a resource source and a valid consumer, then confirm source/carrier/target feedback appears.
- [ ] Place Mirror Shard opposite a producing or damaging tile, then confirm source/mirror feedback appears.
- [ ] Place at least one Object reward and confirm it changes garden behavior or visibly fires a marker effect.

## Feedback And End State

- [ ] Confirm shield, Bloomchain, room reward, and enemy-hit placeholder feedback is noticeable but not distracting.
- [ ] Trigger player defeat or clear the final demo room.
- [ ] Confirm the run summary appears as a clean end-state screen without the debug HUD, garden panel, or expedition map overlapping it.
- [ ] Confirm the run summary includes result, rooms cleared, garden proof status, largest Bloomchain, and resources.
- [ ] Confirm clearing all rooms without a 3-step Bloomchain reports `Garden proof incomplete`, not `Success`.
- [ ] Confirm clearing all rooms after a 3-step Bloomchain reports `Success`.
- [ ] Press R and confirm the prototype restarts cleanly.

## Pass Criteria

- [ ] A tester can explain Lantern Lily -> Light -> Saintmoth -> Shield.
- [ ] A tester can create or explain a 3-step Bloomchain.
- [ ] A tester can explain at least one placed reward interaction.
- [ ] A tester understands that room selection happens on a revealed expedition grid.
- [ ] A tester can complete at least two rooms without live explanation.
- [ ] Combat pressure feels gentle enough to read the garden.

## Known Prototype Limits

- Godot editor validation is still manual unless a Godot CLI is added to PATH.
- Expedition generation is deterministic scaffolding, not procedural yet.
- Enemy spawning is still debug-scene setup, not room encounter data.
- Audio and VFX are generated placeholders for development only.
- Garden UI and inspect mode are prototype panels, not final UX.
