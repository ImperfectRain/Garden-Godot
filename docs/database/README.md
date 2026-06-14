# Documentation Database

## Plainspeak

This folder is the project map. It explains what exists, how the systems fit together, and how to safely add new garden pieces, enemies, rooms, rewards, and code.

Read this folder when you want to answer:

- Where should a new thing go?
- What owns this behavior?
- How do I add content without hardcoding it?
- What should an AI agent change, and what should it leave alone?

## Technical Index

- [Codebase Index](CODEBASE_INDEX.md): all major folders, files, and responsibilities.
- [Content Schema](CONTENT_SCHEMA.md): JSON shape for garden pieces, resources, enemies, rooms, and rewards.
- [Editing Guide](EDITING_GUIDE.md): safe change process for humans and AI.
- [AI Agent Guide](AI_AGENT_GUIDE.md): bounded implementation rules for Codex-style tasks.
- [System: Content Database](systems/content_database.md): JSON loading and validation.
- [System: Garden](systems/garden_system.md): 3x3 grid, placement, Heart Tile, triggers.
- [System: Resources](systems/resource_system.md): Light, Rot, Blood, Echo accounting.
- [System: Bloomchains](systems/bloomchain_system.md): chain recording, loop limits, future visualization.
- [System: Companion](systems/companion_system.md): Saintmoth follow, Heart Tile, bond.
- [System: Run and Rooms](systems/run_room_system.md): room order, run lifecycle, completion summary.
- [System: Journal and Meta](systems/journal_meta_system.md): discoveries, run records, bond progression.

## Documentation Format Rule

Each system document has two sections:

- **Plainspeak:** non-technical explanation for quick review.
- **Technical:** exact files, ownership rules, APIs, and implementation notes.

Keep both sections updated. If only one audience can understand the document, the document is incomplete.
