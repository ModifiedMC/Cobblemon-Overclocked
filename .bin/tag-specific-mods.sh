#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Define specific mod side assignments
declare -A mod_sides

# Client-only mods (UI, rendering, client performance, etc.)
client_mods=(
    "3dskinlayers"
    "advancement-plaques"
    "advancementframes"
    "advancementplaques"
    "aether-emissivity"
    "ambience"
    "ambientsounds"
    "appleskin"
    "badoptimizations"
    "better-advancements"
    "better-biome-blend"
    "better-f3"
    "better-ping-display"
    "betteradvancements"
    "betterf3"
    "biomemusic"
    "blur"
    "borderless-mining"
    "borderless-window"
    "camera-utils"
    "chat-heads"
    "chattoggle"
    "cherishedworlds"
    "cherished-worlds"
    "clickable-advancements"
    "client-crafting"
    "clienttweaks"
    "colorful-hearts"
    "concision"
    "controlling"
    "custom-crosshair-mod"
    "custom-entity-models"
    "distanthorisons"
    "distant-horizons"
    "drippy-loading-screen"
    "durability-tooltip"
    "dynamic-fps"
    "dynamiclights"
    "elytra-physics"
    "emi"
    "emi-effect"
    "emi-enchanting"
    "emi-loot"
    "emi-trades"
    "entity-culling"
    "entity-model-features"
    "entity-texture-features"
    "equipment-compare"
    "extreme-sound-muffler"
    "fancymenu"
    "fast-ip-ping"
    "ferrite-core"
    "flerovium"
    "forge-config-screens"
    "framerate-reducer"
    "fullscreen-windowed"
    "fusion-connected-textures"
    "hudcondition"
    "iris"
    "irisshaders"
    "item-highlighter"
    "item-model-fix"
    "itemzoom"
    "jade"
    "jei"
    "journeymap"
    "journeymap-integration"
    "just-enough-effect-descriptions-jeed"
    "justenoughbreeding"
    "keybindjs"
    "keybind-bundles"
    "keybind-fix"
    "keybinds"
    "language-reload"
    "lazy-language-loader"
    "legendary-tooltips"
    "light-overlay"
    "lightspeed"
    "level-text-fix"
    "longer-chat-history"
    "magnesium-extras"
    "main-menu-credits"
    "memoryleakfix"
    "modelfix"
    "modernworldcreation"
    "modernfix"
    "modelfix"
    "modmenu"
    "moretooltips"
    "mouse-wheelie"
    "nametaggs"
    "nofog"
    "no-chat-reports"
    "nochatreports"
    "nolijium"
    "not-enough-animations"
    "optigui"
    "optifabric"
    "optifine"
    "optiforge"
    "oprequestmod"
    "paperdoll"
    "particleculling"
    "ping-wheel"
    "puzzle"
    "reauth"
    "reeses-sodium-options"
    "rei"
    "screenfps"
    "searchables"
    "seethrough"
    "server-browser"
    "skin-layers-3d"
    "skinlayers3d"
    "smoothboot"
    "sodium"
    "sodium-extra"
    "sodium-options-api"
    "sodium-shadowy-path-blocks"
    "sound-physics-remastered"
    "tooltipfix"
    "torohealth"
    "trade-uses"
    "travelers-titles"
    "visuality"
    "wall-jump"
    "waveycapes"
    "what-that-slot"
    "whats-that-slot"
    "who-am-i"
    "world-host"
    "xaeros-minimap"
    "xaeros-world-map"
    "yeetusexperimentus"
    "yosbr"
    "zoomify"
    "ftb-pause-menu-api"
    "pausemenuapi"
    "welcome-screen"
    "welcomescreen"
    "tmrv"
    "immediatelyfast"
    "voice-chat"
)

# Server-only mods (server optimization, anti-grief, etc.)
server_mods=(
    "alternate-current"
    "backup-util"
    "banhammer"
    "better-than-mending"
    "compact-help-command"
    "crash-exploit-fixer"
    "crashexploitfixer"
    "fast-furnace"
    "feature-recycler"
    "function-permissions"
    "im-fast"
    "imfast"
    "login-protection"
    "mcdog"
    "nosium"
    "permissions"
    "ticket-taker"
    "ticktaker"
    "whose-pet"
)

# Both-sided mods (gameplay, content, etc.)
both_mods=(
    "accessorify"
    "accessories"
    "advancedperipherals"
    "placebo"
    "cobblemon-spawn-notification"
    "ae2"
    "applied-energistics"
    "appeng"
    "aquaculture"
    "architectury"
    "ars-nouveau"
    "ars-elemental"
    "artifacts"
    "balm"
    "baubles"
    "buildinggadgets"
    "building-gadgets"
    "cb-multipart"
    "cc-tweaked"
    "cccbridge"
    "chunky"
    "chunky-border"
    "chunky-pregenerator-forge"
    "cobblemon"
    "cofh-core"
    "computercraft"
    "create"
    "curios"
    "domum-ornamentum"
    "ecologics"
    "enchanting-infuser"
    "excavated-variants"
    "explorify"
    "farmers-delight"
    "fast-leaf-decay"
    "forge-config-api-port"
    "ftb-library"
    "ftb-mods"
    "ftb-quests"
    "ftb-teams"
    "geckolib"
    "hats"
    "hexcasting"
    "immersiveengineering"
    "ironchests"
    "kubejs"
    "little-logistics"
    "lootr"
    "mcjtylib"
    "mekanism"
    "patchouli"
    "playerrevive"
    "powder-power"
    "quartz"
    "reliquary"
    "reliquified-ars-nouveau"
    "reliquified-l-ender-s-cataclysm"
    "rftools"
    "rhino"
    "runelic"
    "shutupexperimentalsettings"
    "smooth-chunk-save"
    "sophisticated-backpacks"
    "sophisticated-storage"
    "structure-gel-api"
    "supplementaries"
    "terrablender"
    "terralith"
    "thermal"
    "cosmetic-armor-reworked"
    "cosmeticarmorreworked"
)

MODS_DIR="/home/jake/Cobblemon-Overclocked/mods"
total_updates=0

# Process client-only mods
for mod in "${client_mods[@]}"; do
    # Find matching files
    for file in "$MODS_DIR"/*$mod*.pw.toml; do
        # Skip if no match
        [[ ! -f "$file" ]] && continue

        # Get current side
        current_side=$(grep -Po 'side = "\K[^"]*' "$file" || echo "none")
        
        # Update if needed
        if [[ "$current_side" != "client" ]]; then
            if [[ "$current_side" == "none" ]]; then
                # Add side after name line
                sed -i '/name = /a side = "client"' "$file"
            else
                # Replace existing side
                sed -i 's/side = "[^"]*"/side = "client"/' "$file"
            fi
            log_success "Updated $(basename "$file" .pw.toml) from \"$current_side\" to \"client\""
            ((total_updates++))
        fi
    done
done

# Process server-only mods
for mod in "${server_mods[@]}"; do
    # Find matching files
    for file in "$MODS_DIR"/*$mod*.pw.toml; do
        # Skip if no match
        [[ ! -f "$file" ]] && continue
        
        # Get current side
        current_side=$(grep -Po 'side = "\K[^"]*' "$file" || echo "none")
        
        # Update if needed
        if [[ "$current_side" != "server" ]]; then
            if [[ "$current_side" == "none" ]]; then
                # Add side after name line
                sed -i '/name = /a side = "server"' "$file"
            else
                # Replace existing side
                sed -i 's/side = "[^"]*"/side = "server"/' "$file"
            fi
            log_success "Updated $(basename "$file" .pw.toml) from \"$current_side\" to \"server\""
            ((total_updates++))
        fi
    done
done

# Process both-sided mods
for mod in "${both_mods[@]}"; do
    # Find matching files
    for file in "$MODS_DIR"/*$mod*.pw.toml; do
        # Skip if no match
        [[ ! -f "$file" ]] && continue
        
        # Get current side
        current_side=$(grep -Po 'side = "\K[^"]*' "$file" || echo "none")
        
        # Update if needed
        if [[ "$current_side" != "both" ]]; then
            if [[ "$current_side" == "none" ]]; then
                # Add side after name line
                sed -i '/name = /a side = "both"' "$file"
            else
                # Replace existing side
                sed -i 's/side = "[^"]*"/side = "both"/' "$file"
            fi
            log_success "Updated $(basename "$file" .pw.toml) from \"$current_side\" to \"both\""
            ((total_updates++))
        fi
    done
done

# Count final mod sides
client_count=$(grep -l '^side = "client"' "$MODS_DIR"/*.pw.toml 2>/dev/null | wc -l)
server_count=$(grep -l '^side = "server"' "$MODS_DIR"/*.pw.toml 2>/dev/null | wc -l)
both_count=$(grep -l '^side = "both"' "$MODS_DIR"/*.pw.toml 2>/dev/null | wc -l)
total_mods=$((client_count + server_count + both_count))

# Print summary
log_info "Updated $total_updates mod side tags"
log_info "Final mod side statistics:"
log_info "- Client-only mods: $client_count"
log_info "- Server-only mods: $server_count"
log_info "- Both sides: $both_count"
log_info "- Total: $total_mods mods"

log_info "Mod tagging complete!"
