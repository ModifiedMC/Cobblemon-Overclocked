#!/bin/bash

# Color definitions for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
MODS_DIR="$SCRIPT_DIR/../mods"
CLIENT_MODS_FILE="$SCRIPT_DIR/client-only-mods.txt"
SERVER_MODS_FILE="$SCRIPT_DIR/server-only-mods.txt"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if files exist
if [[ ! -f "$CLIENT_MODS_FILE" ]]; then
    log_error "Client mods file not found: $CLIENT_MODS_FILE"
    exit 1
fi

if [[ ! -f "$SERVER_MODS_FILE" ]]; then
    log_error "Server mods file not found: $SERVER_MODS_FILE"
    exit 1
fi

# Load mod lists into arrays
readarray -t client_mods < <(grep -v "^#" "$CLIENT_MODS_FILE" | awk -F, '{print tolower($2)}' | sed 's/ *$//' | grep -v "^$")
readarray -t server_mods < <(grep -v "^#" "$SERVER_MODS_FILE" | awk -F, '{print tolower($2)}' | sed 's/ *$//' | grep -v "^$")

log_info "Loaded ${#client_mods[@]} client-only mods and ${#server_mods[@]} server-only mods"

# Function to set mod side
set_mod_side() {
    local file=$1
    local side=$2
    local mod_name=$(basename "$file" .pw.toml)
    
    # Get current side if exists
    current_side=$(grep -Po 'side = "\K[^"]*' "$file" || echo "none")
    
    # Only update if different
    if [[ "$current_side" != "$side" ]]; then
        if [[ "$current_side" == "none" ]]; then
            # Add side after name line
            sed -i '/name = /a side = "'"$side"'"' "$file"
        else
            # Replace existing side
            sed -i 's/side = "[^"]*"/side = "'"$side"'"/' "$file"
        fi
        log_success "Updated $mod_name from \"$current_side\" to \"$side\""
        return 0
    fi
    return 1
}

# Process all mod files
total_updated=0
total_client=0
total_server=0
total_both=0

log_info "Setting mod sides based strictly on the provided text files..."

for mod_file in "$MODS_DIR"/*.pw.toml; do
    mod_name=$(basename "$mod_file" .pw.toml)
    mod_name_lower=$(echo "$mod_name" | tr '[:upper:]' '[:lower:]')
    
    # Default to both unless specifically found in client or server lists
    mod_side="both"
    
    # Check if this mod is in client-only list
    for client_mod in "${client_mods[@]}"; do
        if [[ -n "$client_mod" ]] && [[ "$mod_name_lower" == *"$client_mod"* ]]; then
            mod_side="client"
            log_info "Found in client list: $mod_name"
            break
        fi
    done
    
    # Check if this mod is in server-only list
    if [[ "$mod_side" != "client" ]]; then
        for server_mod in "${server_mods[@]}"; do
            if [[ -n "$server_mod" ]] && [[ "$mod_name_lower" == *"$server_mod"* ]]; then
                mod_side="server"
                log_info "Found in server list: $mod_name"
                break
            fi
        done
    fi
    
    # Apply the side
    if set_mod_side "$mod_file" "$mod_side"; then
        ((total_updated++))
    fi
    
    # Track statistics
    if [[ "$mod_side" == "client" ]]; then
        ((total_client++))
    elif [[ "$mod_side" == "server" ]]; then
        ((total_server++))
    else
        ((total_both++))
    fi
done

log_info "Updated $total_updated mod side tags"
log_info "Final mod side statistics:"
log_info "- Client-only mods: $total_client"
log_info "- Server-only mods: $total_server"
log_info "- Both sides: $total_both"
log_info "- Total: $((total_client + total_server + total_both)) mods"

# Special cases based on user's explicit requirements
log_info "Applying explicit mod side requirements..."

# COBBLEMON IS A BOTH SIDE MOD
for file in "$MODS_DIR"/cobblemon.pw.toml "$MODS_DIR"/cobblemon-*.pw.toml; do
    if [[ -f "$file" ]] && [[ ! "$file" == *spawn-notification* ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Cobblemon mod to 'both' side"
        fi
    fi
done

# COSMETIC ARMOUR IS A BOTH MOD
for file in "$MODS_DIR"/cosmetic*armor*.pw.toml "$MODS_DIR"/cosmeticarmorreworked*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Cosmetic Armor mod to 'both' side"
        fi
    fi
done

# CHUNKY IS SUPPOSED TO BE ON BOTH SIDES
for file in "$MODS_DIR"/chunky*.pw.toml "$MODS_DIR"/chunky-*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Chunky mod to 'both' side"
        fi
    fi
done

# SMOOTH CHUNK SAVES BOTH
for file in "$MODS_DIR"/*smooth*chunk*save*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Smooth Chunk Save mod to 'both' side"
        fi
    fi
done

# RELIQUIFIED MODS SHOULD BE BOTH
for file in "$MODS_DIR"/reliquified*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Reliquified mod to 'both' side"
        fi
    fi
done

# COBBLEMON SPAWN NOTIFICATION IS A BOTH MOD
for file in "$MODS_DIR"/*cobblemon*spawn*notification*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Cobblemon Spawn Notification mod to 'both' side"
        fi
    fi
done

# PLACEBO SHOULD BE BOTH
for file in "$MODS_DIR"/placebo.pw.toml "$MODS_DIR"/placebo-*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_success "Set Placebo mod to 'both' side"
        fi
    fi
done

# WHAT'S THAT SLOT SHOULD BE CLIENT
for file in "$MODS_DIR"/*whats*that*slot*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "client"; then
            log_success "Set What's That Slot mod to 'client' side"
        fi
    fi
done

log_info "Mod tagging process complete!"
