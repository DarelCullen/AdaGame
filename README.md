# The Quest of the Ada Knight ⚔️🛡️

A 2D retro action-adventure game written in **Ada 2012** using the **Alire** package manager and **SDL2** (`sdlada`).

---

## 📖 Story & Quest

The kingdom of **Aethelgard** is descending into shadow as an ominous void portal opens at the heart of the realm. You play as the **Ada Knight**, dispatched to gather the **Three Sacred Crystals of Power**:

1. **The Forest Emerald** — hidden deep in the perilous *Sunken Cavern* guarded by bouncing slimes.
2. **The Cavern Sapphire** — sealed in the catacombs of the *Lich Crypt*.
3. **The Dungeon Ruby Core** — locked behind heavy iron doors in the inner sanctum.

Bring all three crystals to the **Altar of Light** in the **Sacred Citadel** to banish the darkness and seal the portal forever!

---

## 🗺️ World & Biomes

- **Whispering Woods**: Lush starting grove with wildflower patches, a tranquil pond, a patrolling forest slime, and a treasure chest containing a bronze key.
- **Oakhaven Village**: A bustling hamlet with timber houses, village fountain, and **Elder Eldrin**, who guides your journey.
- **Sunken Cavern**: Murky subterranean grotto with underground streams, active spike traps, and slimes. Contains the *Forest Emerald*.
- **Lich Crypt & Dungeon**: Dark cobblestone dungeons with patrolling skeletons and locked gates. Contains the *Cavern Sapphire* and *Dungeon Ruby Core*.
- **The Sacred Citadel**: High marble halls with grand pillars and the ancient Altar of Light.

---

## 🎮 Controls

| Action | Key(s) |
| :--- | :--- |
| **Move** | `W` / `A` / `S` / `D` or `Arrow Keys` (Up, Down, Left, Right) |
| **Attack (Sword Slash)** | `Space` or `Z` |
| **Interact / Open / Talk** | `E` or `Enter` |
| **Close Dialogue** | `E` or `Enter` or `Space` |
| **Restart Game** | `R` (on Game Over or Victory screens) |
| **Menu / Quit** | `Escape` |

---

## 🏗️ Technical Architecture

The game is structured in idiomatic, strongly-typed Ada packages:

- **`Game_Types` (`src/game_types.ads`)**: Universal game definitions, grid dimensions ($20 \times 13$ tiles @ 40px), directions, room IDs, and 32-bit RGBA color palettes.
- **`Game_Font` (`src/game_font.ads`, `src/game_font.adb`)**: A self-contained $5 \times 7$ retro bitmap font engine rendered using vector rectangles. Does not require external TTF files or OS font packages.
- **`Game_Sprites` (`src/game_sprites.ads`, `src/game_sprites.adb`)**: Procedural pixel-art rendering for:
  - Knight: directional visors, armor plates, shield, walking leg animations, sword swing arcs, invulnerability blinking.
  - Monsters: animated squishing Slimes and skeletal warriors with glowing eye sockets.
  - NPCs: Elder with flowing white beard and staff, Citadel Guards in plated armor.
  - Tiles: lush grass, cobblestones, shimmering water reflections, stone walls, timber buildings, iron gates, and altars.
- **`Game_World` (`src/game_world.ads`, `src/game_world.adb`)**: Complete 5-room world layout, collision detection with tile grids, entity state management, chest loot, enemy AI patrolling, and room transitions.
- **`Game_Engine` (`src/game_engine.ads`, `src/game_engine.adb`)**: State machine (Title, Playing, Dialogue, Game Over, Victory), 60 FPS real-time monotonic frame limiter via `Ada.Real_Time`, event polling, combat calculations, and HUD rendering.
- **`Ada_Adventure` (`src/ada_adventure.adb`)**: Application entry point.

---

## 🚀 How to Build and Run

### Run directly with Alire:
```bash
alr run
```

### Or launch the compiled binary:
```bash
./bin/ada_adventure
```

---

## 📜 License

This project is licensed under the **GNU General Public License v2.0** (`GPL-2.0-only`).
See the [LICENSE](LICENSE) file for the full license text.

All source files carry the SPDX license identifier:
```ada
--  SPDX-License-Identifier: GPL-2.0-only
```

