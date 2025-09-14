#!/bin/bash

# This script sets specific mod sides based on known patterns and requirements
# To use: Run this script from the modpack root directory

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log with colors
log_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Update mod side in TOML file
update_mod_side() {
    local mod_file=$1
    local side=$2
    local mod_name=$(basename "$mod_file" .pw.toml)
    
    # Extract current side if it exists
    if grep -q "^side = " "$mod_file"; then
        current_side=$(grep -E "^side = " "$mod_file" | sed 's/side = "\(.*\)"/\1/')
        
        # Update if different
        if [[ "$current_side" != "$side" ]]; then
            sed -i "s/side = \"$current_side\"/side = \"$side\"/" "$mod_file"
            log_success "Updated $mod_name from \"$current_side\" to \"$side\""
            return 0
        else
            return 1
        fi
    else
        # No side defined, add it after name line
        sed -i "/^name = /a side = \"$side\"" "$mod_file"
        log_success "Added side = \"$side\" to $mod_name"
        return 0
    fi
}

# Set mod sides for known patterns
set_mod_sides() {
    log_info "Setting mod sides for known patterns..."
    
    # List of known client-only mods (patterns to match filenames)
    declare -a client_patterns=(
        # UI and visual mods
        "journeymap"
        "jade"
        "jei"
        "emi"
        "appleskin"
        "enchantment-descriptions"
        "xaeros"
        "paperdoll"
        "itemzoom"
        "fancymenu"
        "betterf3"
        "armourers-workshop"
        "betteradvancements"
        "better-advancements"
        "badoptimizations"
        "bad-optimizations"
        "desiredservers"
        "desired-servers"
        "world-host"
        "worldhost"
        "server-browser"
        "serverbrowser"
        
        # Graphics and optimization client-side mods
        "iris"
        "irisshaders"
        "sodium"
        "oculus"
        "embeddium"
        "ferrite"
        "entity-texture"
        "entity-model"
        "modernfix"
        "no-chat-reports"
        "skin-layers"
        "3d-skin"
        "sound-physics"
        "ambientsounds"
        "waveycapes"
        "cloth-config"
        "dynamic-fps"
        "smoothboot"
        "better-fps"
        "fastworkbench"
        "lightoverlay"
        "light-overlay"
        "mousewheelie"
        "controlling"
        "betterfoliage"
        "betterleaves"
        "chat-heads"
        "chat-notif"
        "bwncr"
        "bwnc"
        "chattoggle"
        "modmenu"
        "blur"
        "entity-culling"
        "entityculling"
        "mipmap"
        "shaders"
        "fast-ip"
        "chatnotify"
        "smoothchunk"
        "inventory-tweaks"
        "inventorytweaks"
        "inventory-hud"
        "tooltips"
        "shader"
        "magnesium-extras"
        "minimap"
        "render"
        "reeses"
        "options"
        "flickerfix"
        "flicker-fix"
        "immersive-hud"
        "immersivehud"
        "fancy"
        "athena"
        "welcome-screen"
        "welcomescreen"
        "resourcepack"
        "keybind"
        "loading-screen"
        "level-text"
        "level-text-fix"
        "konkrete"
        "fusion-connected"
        "euphoria-patches"
        "smithing-template-viewer"
        "whats-that-slot"
        "lithostitched"
        
        # Client utilities
        "mousewheelie"
        "crashassistant"
        "crash-assistant"
        "cosmeticarmor"
        "cosmetic-armor"
        "simple-rpc"
        "dashloader"
        "loadmyresources"
        "better-ping"
        "durability"
        "not-enough-animations"
        "betterplacement"
        "better-placement"
        "better-third-person"
        "camera-utils"
        "cmdcam"
        "exposure"
        "biome-music"
        "distraction-free"
        "searchables"
        "drippy"
        "dynamic-lights"
        "dynamiclights"
        "fuel-info"
        "packet-fixer"
        "legendary-tooltips"
        "journeymap-integration"
        "fast-paintings"
        "max-health-fix"
        "beautiful-enchanted-books"
        "colorful-hearts"
    )
    
    # List of known server-only mods
    declare -a server_patterns=(
        "spark"
        "clumps"
        "alternate-current"
        "ai-improvements"
        "luckperms"
        "servercore"
        "chunky"
        "chunky-pregenerator"
        "c2me"
        "fastbackup"
        "simple-backup"
        "nofog"
        "chunksender"
    )
    
    client_count=0
    server_count=0
    both_count=0
    
    # Default everything to "both" first
    log_info "Setting all mods to 'both' by default..."
    for mod_file in $(find /home/jake/Cobblemon-Overclocked/mods -name "*.pw.toml"); do
        if update_mod_side "$mod_file" "both"; then
            both_count=$((both_count + 1))
        fi
    done
    
    # Then set client-only mods
    log_info "Identifying client-only mods..."
    for pattern in "${client_patterns[@]}"; do
        for mod_file in $(find /home/jake/Cobblemon-Overclocked/mods -name "*${pattern}*.pw.toml"); do
            if update_mod_side "$mod_file" "client"; then
                client_count=$((client_count + 1))
                both_count=$((both_count - 1))
            fi
        done
    done
    
    # Then set server-only mods
    log_info "Identifying server-only mods..."
    for pattern in "${server_patterns[@]}"; do
        for mod_file in $(find /home/jake/Cobblemon-Overclocked/mods -name "*${pattern}*.pw.toml"); do
            if update_mod_side "$mod_file" "server"; then
                server_count=$((server_count + 1))
                both_count=$((both_count - 1))
            fi
        done
    done
    
    log_info "Mod sides updated successfully"
}

# Main function
main() {
    log_info "Starting mod side tagging..."
    
    # Set mod sides based on known patterns
    set_mod_sides
    
    # Count sides for final statistics
    client_count=0
    server_count=0 
    both_count=0
    
    if ls /home/jake/Cobblemon-Overclocked/mods/*.pw.toml >/dev/null 2>&1; then
        client_count=$(grep -l "^side = \"client\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l)
        server_count=$(grep -l "^side = \"server\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l)
        both_count=$(grep -l "^side = \"both\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l)
    fi
    
    total_mods=$((client_count + server_count + both_count))
    
    log_info "Final Mod Side Statistics:"
    log_info "- Client-only mods: $client_count"
    log_info "- Server-only mods: $server_count"
    log_info "- Both sides: $both_count"
    log_info "- Total mods: $total_mods"
    
    log_info "Mod tagging complete!"
}

# Run the main function
main
