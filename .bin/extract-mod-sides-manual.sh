#!/bin/bash

# Color definitions for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Define paths and files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CLIENT_MODS_FILE="$SCRIPT_DIR/client-only-mods.txt"
SERVER_MODS_FILE="$SCRIPT_DIR/server-only-mods.txt"
TEMP_CSV="/tmp/mod_data.csv"

# Spreadsheet details
SPREADSHEET_ID="1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
SHEET_GID="0"
CSV_URL="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv&gid=$SHEET_GID"

# Define lists of known client-only and server-only mods
declare -a CLIENT_ONLY_MODS=(
    "skinlayers3d"
    "AdvancementPlaques"
    "aether_emissivity"
    "AmbientSounds"
    "bwncr"
    "BadOptimizations"
    "BetterAdvancements"
    "BetterF3"
    "biomemusic"
    "chat_heads"
    "chattoggle"
    "chatnotify"
    "cherishedworlds"
    "clientcrafting"
    "CobblemonMoveInspector"
    "colorfulhearts"
    "condensed_creative"
    "Controlling"
    "CrashAssistant"
    "desiredservers"
    "distraction_free_recipes"
    "drippyloadingscreen"
    "durabilitytooltip"
    "dynamic-fps"
    "elytra_physics"
    "emi_enchanting"
    "emi_ores"
    "EMIProfessions"
    "enchdesc"
    "entity_model_features"
    "entity_textures_features"
    "EquipmentCompare"
    "EuphoriaPatcher"
    "ExtremeSoundMuffler"
    "fancymenu"
    "fast-ip"
    "flerovium"
    "FuelInfo"
    "fusion"
    "gpumemleakfix"
    "immediatelyFast"
    "iris"
    "itemzoom"
    "jmi"
    "justenoughbreeding"
    "jeed"
    "keybindspurger"
    "LegendaryTooltips"
    "leveltextfix"
    "light-overlay"
    "LongerChatHistory"
    "melody"
    "modernworldcreation"
    "MoreCobblemonTweaks"
    "NeoAuth"
    "nolijium"
    "notenoughanimations"
    "oracle_index"
    "paperdoll"
    "particle_core"
    "Rainbows"
    "Scribble"
    "Searchables"
    "serverbrowser"
    "smithingtemplateviewer"
    "sodium"
    "sodiumdynamiclights"
    "sodiumextras"
    "sodiumoptionsapi"
    "sodiumoptionsmodcompat"
    "sodium-shadowy-path-blocks"
    "ToastControl"
    "toomanyrecipeviewers"
    "tradeuses"
    "welcomescren"
    "world-host"
    "yeetusexperimentus"
    "whats-that-slot"
)

declare -a SERVER_ONLY_MODS=(
    "almostunified"
    "alternate_current" 
    "BetterThanMending"
    "compacthelpcommand"
    "crashexploitfixer"
    "Feature-Recycler"
    "nosium"
)

# Download spreadsheet data
log_info "Creating mod side lists..."

# Create client-only mods file
log_info "Creating client-only mods list..."
echo "# Client-only mods list" > "$CLIENT_MODS_FILE"
echo "# Format: ModID" >> "$CLIENT_MODS_FILE"
echo "# This file contains mod IDs that should only be on the client side" >> "$CLIENT_MODS_FILE"
echo "# Updated manually with known client-only mods" >> "$CLIENT_MODS_FILE"
echo "" >> "$CLIENT_MODS_FILE"

for mod in "${CLIENT_ONLY_MODS[@]}"; do
    echo "$mod" >> "$CLIENT_MODS_FILE"
    log_success "Added $mod to client-only mods"
done

# Create server-only mods file
log_info "Creating server-only mods list..."
echo "# Server-only mods list" > "$SERVER_MODS_FILE"
echo "# Format: ModID" >> "$SERVER_MODS_FILE"
echo "# This file contains mod IDs that should only be on the server side" >> "$SERVER_MODS_FILE"
echo "# Updated manually with known server-only mods" >> "$SERVER_MODS_FILE"
echo "" >> "$SERVER_MODS_FILE"

for mod in "${SERVER_ONLY_MODS[@]}"; do
    echo "$mod" >> "$SERVER_MODS_FILE"
    log_success "Added $mod to server-only mods"
done

# Count how many mods we have in each category
client_count=${#CLIENT_ONLY_MODS[@]}
server_count=${#SERVER_ONLY_MODS[@]}

log_info "Client-only mods: $client_count"
log_info "Server-only mods: $server_count"
log_info "Lists generation complete!"
