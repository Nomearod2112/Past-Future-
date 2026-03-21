# Past & Future — Claude Code Project Context

You are a game development partner building **Past & Future**, a 2-player local co-op puzzle adventure in Godot 4 with GDScript. Two versions of the same person — Past-Lena (1974) and Future-Lena (2024) — explore the same coastal town separated by 50 years. The screen is split vertically. Actions in the past ripple forward to change the future. Information discovered in the future flows backward as awareness.

This document is the single source of truth for the game's architecture. Read it fully before writing any code.

## Project Structure

```
past-and-future/
├── CLAUDE.md                          # This file
├── project.godot
├── scenes/
│   ├── main.tscn                      # Root: split-screen container
│   ├── world/
│   │   ├── harbor_district.tscn       # Vertical slice level
│   │   ├── tiles/
│   │   │   ├── past_tileset.tres      # Warm palette tiles
│   │   │   └── future_tileset.tres    # Cool palette tiles
│   │   └── temporal_objects/          # Objects that exist in both eras
│   │       ├── tree_spot.tscn
│   │       ├── building.tscn
│   │       ├── hiding_spot.tscn
│   │       └── letterbox.tscn
│   ├── characters/
│   │   ├── past_lena.tscn
│   │   └── future_lena.tscn
│   └── ui/
│       ├── journal.tscn               # Shared journal overlay
│       ├── letterbox_ui.tscn          # Message compose/read UI
│       └── hud.tscn                   # Per-player HUD
├── scripts/
│   ├── causality/
│   │   ├── causal_graph.gd            # Core: append-only event log
│   │   ├── causal_event.gd            # Event data class
│   │   ├── propagation_rules.gd       # Action → consequence mappings
│   │   ├── propagation_rule.gd        # Single rule definition
│   │   ├── aging_simulation.gd        # Time-decay calculations
│   │   ├── conflict_resolver.gd       # Resolves temporal conflicts
│   │   ├── future_delta.gd            # Delta output from propagation
│   │   └── ripple_manager.gd          # Orchestrates visual transitions
│   ├── world/
│   │   ├── world_state.gd             # Manages PastState + FutureState
│   │   ├── temporal_object.gd         # Base class: objects affected by time
│   │   ├── past_object.gd             # Past-era object behavior
│   │   ├── future_object.gd           # Future-era object behavior
│   │   ├── awareness_manager.gd       # Tracks info backflow to Past
│   │   ├── awareness_node.gd          # Unlockable awareness definition
│   │   └── info_fragment.gd           # Discovered information piece
│   ├── characters/
│   │   ├── player_base.gd             # Shared: movement, interact
│   │   ├── player_controls.gd         # Input action mapping resource
│   │   ├── past_lena.gd               # Past-specific verbs
│   │   └── future_lena.gd             # Future-specific verbs
│   ├── communication/
│   │   ├── letterbox.gd               # Cross-time messaging
│   │   ├── env_signal.gd              # Environmental signals (stone patterns, marks)
│   │   └── shared_journal.gd          # Both players can annotate
│   ├── puzzles/
│   │   ├── puzzle_base.gd             # Base class with state machine
│   │   ├── puzzle_registry.gd         # Tracks puzzle completion
│   │   └── chapter_1/
│   │       └── locked_garden.gd       # Tutorial puzzle
│   └── autoload/
│       ├── game_manager.gd            # Global state, player references
│       ├── input_manager.gd           # Maps P1/P2 inputs
│       └── save_manager.gd            # Serializes CausalGraph
├── shaders/
│   ├── ripple.gdshader                # Temporal ripple transition
│   ├── past_color_grade.gdshader      # Warm amber post-process
│   ├── future_color_grade.gdshader    # Cool blue post-process
│   └── echo_vision.gdshader           # Future-Lena's ghost overlay
├── resources/
│   ├── propagation/                   # .tres files defining rules
│   ├── puzzles/                       # Puzzle configuration resources
│   └── dialogue/                      # Dialogue tree resources
└── assets/
    ├── sprites/
    ├── audio/
    └── tilesets/
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   main.tscn                          │
│                                                      │
│  HBoxContainer                                       │
│  ├── SubViewportContainer (left, stretch)             │
│  │   └── SubViewport (PastViewport)                  │
│  │       ├── Camera2D → follows past_lena            │
│  │       ├── past_lena.tscn                          │
│  │       └── (world is shared via world_2d)          │
│  ├── ColorRect (divider, 4px, gold #F0C75E)          │
│  └── SubViewportContainer (right, stretch)            │
│      └── SubViewport (FutureViewport)                │
│          ├── Camera2D → follows future_lena          │
│          ├── future_lena.tscn                        │
│          └── (world_2d = PastViewport.world_2d)      │
│                                                      │
│  The SAME world is rendered in both viewports.        │
│  Past objects are on layers visible only to Past cam. │
│  Future objects are on layers visible only to Future. │
│  Shared objects (terrain, fixed structures) are on    │
│  a common layer visible to both.                     │
└─────────────────────────────────────────────────────┘
```

### Rendering Layer Strategy

- **Layer 1**: Shared terrain and fixed geography (both cameras see this)
- **Layer 2**: Past-only objects (buildings intact, NPCs, 1974 props)
- **Layer 3**: Future-only objects (ruins, overgrowth, 2024 props)
- **Layer 4**: Past-Lena and her UI elements
- **Layer 5**: Future-Lena and her UI elements
- **Layer 6**: Ripple/transition effects (Future viewport only)

Each SubViewport has a CanvasLayer with its era-specific post-processing shader (warm for Past, cool for Future).

## The Causality Engine — Core System

This is the most important system in the game. Understand it thoroughly before modifying anything.

### Three Laws of Halvmåne Causality

1. **Forward only** — Physical matter flows Past → Future. Past-Lena cannot receive objects from Future-Lena.
2. **Information is timeless** — Knowledge discovered in either era unlocks awareness in the other.
3. **No paradoxes, only echoes** — Contradictions resolve gracefully via "echo" transitions, not errors.

### CausalGraph (causal_graph.gd)

The CausalGraph is an append-only directed acyclic graph. It is the single source of truth for the game's temporal state. FutureState is always derived from BaseMap + CausalGraph.

### CausalEvent Types

- `PLANT_TREE` — Plant a sapling that grows over 50 years
- `BUILD_STRUCTURE` — Construct something that ages
- `DESTROY_STRUCTURE` — Remove a structure
- `HIDE_OBJECT` — Cache an item for Future-Lena to find
- `REDIRECT_WATER` — Change water flow patterns
- `BEFRIEND_NPC` — Build relationship with a townsperson
- `WRITE_MESSAGE` — Environmental signals or letterbox messages
- `BLUEPRINT` — Past-Lena sketches a plan
- `OIL_MECHANISM` — Maintenance that lasts decades
- `COMMISSION_WORK` — Ask an NPC to build/repair something

### Propagation Rules

Each event type has a PropagationRule that maps the past action to its 50-year consequence. Rules consider nearby events for interaction effects (e.g., PLANT_TREE near REDIRECT_WATER = bigger tree).

### Aging Simulation

- Trees: year 10 = young (not climbable), year 25 = mature, year 40 = old (hollow)
- Containers: glass_jar_with_silica → pristine, metal_box → intact, wooden_box → degraded, cloth_wrap → destroyed
- Structures: maintained → weathered but functional, unmaintained → partially collapsed

## Information Backflow System

When Future-Lena discovers information, it doesn't change the world — it unlocks AwarenessNodes for Past-Lena. This gives Past-Lena new dialogue options, object visibility, or ability to notice previously hidden details.

## The Ripple Effect — Visual System

When the future changes, a 1.7s visual transition plays (compresses to 0.8s after repeated triggers):
1. **Anticipation** (0.3s) — Divider pulses gold, chime plays
2. **Propagation** (0.8s) — Circular distortion wave with chromatic aberration
3. **Settlement** (0.4s) — New state visible, particles at changed object
4. **Confirmation** (0.2s) — Golden outline pulse, journal entry slides in

## Communication Systems

- **Letterbox**: Physical mailbox for cross-time messages. Limited to 3 uses per chapter, 80 char max.
- **Environmental Signals**: Arrange objects in Past, see aged result in Future.
- **Shared Journal**: Both players annotate; auto-receives entries from propagation.

## Locked Historical Events

These CANNOT be prevented by Past-Lena (fixed points in the timeline):
- Library fire (1982)
- Major coastal storm (1974, Chapter 3)
- Developer buys waterfront (1985)
- Town hall mural painted over (1995)
- Post office converted to café (2003)

## Color Palettes

**Past (1974) — "Golden Hour"**: warm amber #D4A056, olive #7B8C3E, burnt sienna #C45B28, cream #F5E6C8

**Future (2024) — "Blue Hour"**: steel blue #7A9BB5, muted teal #5D8A7B, faded terracotta #B8785C, cool grey #E2E5E8

**Shared (temporal mechanics)**: ripple gold #F0C75E, echo vision #D4A056 at 40%, letterbox gold #E8B84B

## Coding Conventions

- Static typing everywhere
- Class names: PascalCase; file names: snake_case
- Signals: past tense (`event_added`, `puzzle_solved`)
- Constants: UPPER_SNAKE_CASE
- Composition over inheritance
- `## doc comments` on all public functions
- Scripts under 300 lines
- Signals over direct references — the CausalGraph should never know about RippleManager

## Development Phases

**Phase 1 — Vertical Slice (current)**: One playable puzzle in harbor district, split-screen, 5 causal objects, tutorial puzzle, basic ripple, color grading.

**Phase 2 — Core Loop**: Full propagation rules, information backflow, letterbox, journal, 3 puzzles per tier, Chapter 1 complete.

**Phase 3 — Content**: Chapters 2-5, NPC dialogue, polished shader, sound, save/load.
