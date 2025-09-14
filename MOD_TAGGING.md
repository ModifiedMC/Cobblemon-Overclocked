# Cobblemon Overclocked Modpack

## Mod Tagging System

This modpack uses a side-tagging system to properly identify which mods should be included in client builds, server builds, or both.

### How It Works

Each mod in the pack is tagged with a `side` attribute in its `.pw.toml` file:
- `side = "client"` - Client-only mod (e.g., shaders, UI enhancements)
- `side = "server"` - Server-only mod (e.g., server performance optimization)
- `side = "both"` - Mod needed on both client and server (default)

### Tagging Mods

To ensure proper distribution of mods, run the tagging script:

```bash
.bin/tag-mods.py
```

This script:
1. Downloads the latest data from the mod spreadsheet
2. Processes each mod and determines the appropriate side
3. Updates all mod TOML files with the correct side tag

### Building the Pack

Use the build script to create client and/or server packs:

```bash
.bin/build client   # Build only the client pack
.bin/build server   # Build only the server pack
.bin/build both     # Build both client and server packs
```

The build process filters mods based on their side tags:
- Client builds exclude mods with `side = "server"`
- Server builds exclude mods with `side = "client"`

### Manual Tagging

If you need to manually tag a mod, edit its `.pw.toml` file and add or update the `side` attribute:

```toml
name = "Example Mod"
side = "client"  # Options: "client", "server", or "both"
```

## Spreadsheet Reference

The mod side information is maintained in a Google Spreadsheet:
- Column A: Mod ID
- Column B: Client flag (TRUE = include in client)
- Column C: Server flag (TRUE = include in server)

When both flags are TRUE, the mod is tagged as `both`.
