# Modified Cobblemon: PLUS!

## Requirements

* [packwiz](https://github.com/packwiz/packwiz)
* [jq](https://jqlang.org/download/)

## Development

Before starting, you will need to download the Complementary + Euphoria shaders and put them in `shaderpacks`. This files are gitignored and not distributed as part of the git repo. You can get a copy of the latest ones from the [zip on CurseForge](https://www.curseforge.com/minecraft/modpacks/modified-cobblemon-plus/files/all).

### File Structure

* `*.pw.toml` files  - basically placeholder files for files that need to be downloaded by packwiz. These files are managed by packwiz you should largely avoid editing them.
* `index.toml` - the "lock" file for the pack. It contains the master list of all of the checksums and hashes of the all of the files included in the pack. You should _never_ edit this file. It can be updated with `packwiz refresh`.
* `pack.toml` - main configuration file for the pack
* `.packwizignore` - a file that lets you tell packwiz what files to _ignore_ for including in the modpack

### Basic Usage

```bash
# Update all of the hashes of the files to included in the modpack
packwiz refresh

# Create CurseForge client .zip in build/
.bin/build-client

# Update a specific file
packwiz update path/to/.pw.toml file

# Updates all mods/resource packs/shader packs
packwiz update --all

# Add a CurseForge mod
packwiz cf install https://www.curseforge.com/minecraft/mc-mods/indium

# Add a Modrinth mod
packwiz modrinth install https://modrinth.com/mod/indium
```
`.bin/build-client` can be used to build out a zip file inside of the `build` folder that can be manually imported into a CurseForge compatible launcher or uploaded to CurseForge.

* [packwiz docs](https://packwiz.infra.link/tutorials/creating/getting-started/)
