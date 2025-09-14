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
MODS_DIR="$SCRIPT_DIR/../mods"
CLIENT_MODS_FILE="$SCRIPT_DIR/client-only-mods.txt"
SERVER_MODS_FILE="$SCRIPT_DIR/server-only-mods.txt"
TEMP_CSV="/tmp/mod_data.csv"

# Spreadsheet details
SPREADSHEET_ID="1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
SHEET_GID="0"
CSV_URL="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv&gid=$SHEET_GID"

# Download spreadsheet data
log_info "Downloading spreadsheet data..."
if ! curl -s -L "$CSV_URL" -o "$TEMP_CSV"; then
    log_error "Failed to download spreadsheet data"
    exit 1
fi

# Check if we got valid data
if grep -q "<HTML>" "$TEMP_CSV" || [ ! -s "$TEMP_CSV" ]; then
    log_error "Invalid spreadsheet data received"
    exit 1
fi

log_success "Downloaded spreadsheet data successfully"

# Create client-only mods file
log_info "Creating client-only mods list..."
echo "# Client-only mods list" > "$CLIENT_MODS_FILE"
echo "# Format: ModID" >> "$CLIENT_MODS_FILE"
echo "# This file contains mod IDs that should only be on the client side" >> "$CLIENT_MODS_FILE"
echo "# Generated from spreadsheet: $CSV_URL" >> "$CLIENT_MODS_FILE"
echo "" >> "$CLIENT_MODS_FILE"

# Create server-only mods file
log_info "Creating server-only mods list..."
echo "# Server-only mods list" > "$SERVER_MODS_FILE"
echo "# Format: ModID" >> "$SERVER_MODS_FILE"
echo "# This file contains mod IDs that should only be on the server side" >> "$SERVER_MODS_FILE"
echo "# Generated from spreadsheet: $CSV_URL" >> "$SERVER_MODS_FILE"
echo "" >> "$SERVER_MODS_FILE"

# Process the CSV data
# Column A: Mod Name
# Column B: Mod ID
# Column C: Client checkbox
# Column D: Server checkbox
log_info "Processing spreadsheet data..."

# Skip header row
tail -n +2 "$TEMP_CSV" | while IFS=, read -r modname modid client_value server_value rest; do
    # Remove quotes if present
    modname=$(echo "$modname" | tr -d '"' | xargs)
    modid=$(echo "$modid" | tr -d '"' | xargs)
    client_value=$(echo "$client_value" | tr -d '"' | xargs | tr '[:upper:]' '[:lower:]')
    server_value=$(echo "$server_value" | tr -d '"' | xargs | tr '[:upper:]' '[:lower:]')
    
    # Skip empty rows
    if [ -z "$modname" ] || [ -z "$modid" ]; then
        continue
    fi

    # Debug info
    log_info "Processing: $modname ($modid) - Client: $client_value, Server: $server_value"

    # Determine the side based on checkbox values
    if [ "$client_value" = "true" ] && [ "$server_value" != "true" ]; then
        echo "$modid" >> "$CLIENT_MODS_FILE"
        log_success "Added $modname to client-only mods"
    elif [ "$client_value" != "true" ] && [ "$server_value" = "true" ]; then
        echo "$modid" >> "$SERVER_MODS_FILE"
        log_success "Added $modname to server-only mods"
    fi
done

# Count how many mods we have in each category
client_count=$(grep -v "^#" "$CLIENT_MODS_FILE" | grep -v "^$" | wc -l)
server_count=$(grep -v "^#" "$SERVER_MODS_FILE" | grep -v "^$" | wc -l)

log_info "Spreadsheet processing complete"
log_info "Client-only mods: $client_count"
log_info "Server-only mods: $server_count"

# Now update all mod files based on the generated lists
log_info "Updating mod side tags based on generated lists..."

# Function to set mod side
set_mod_side() {
    local file=$1
    local side=$2
    local mod_name=$(basename "$file" .pw.toml)
    
    # Get current side if exists
    current_side=$(grep -Po 'side = "\K[^"]*' "$file" 2>/dev/null || echo "none")
    
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

# Load the mod lists into arrays for faster processing
readarray -t client_mods < <(grep -v "^#" "$CLIENT_MODS_FILE" | sed 's/ *$//' | tr '[:upper:]' '[:lower:]' | grep -v "^$")
readarray -t server_mods < <(grep -v "^#" "$SERVER_MODS_FILE" | sed 's/ *$//' | tr '[:upper:]' '[:lower:]' | grep -v "^$")

# Process all mod files
total_updated=0
total_client=0
total_server=0
total_both=0

for mod_file in "$MODS_DIR"/*.pw.toml; do
    mod_name=$(basename "$mod_file" .pw.toml)
    mod_name_lower=$(echo "$mod_name" | tr '[:upper:]' '[:lower:]')
    
    # Determine which side this mod belongs to
    is_client=false
    is_server=false
    
    # Check if this mod is in client-only list
    for client_mod in "${client_mods[@]}"; do
        if [[ "$mod_name_lower" == *"$client_mod"* ]] || [[ "$mod_name_lower" =~ ^"$client_mod"(-|$) ]]; then
            is_client=true
            break
        fi
    done
    
    # Check if this mod is in server-only list
    for server_mod in "${server_mods[@]}"; do
        if [[ "$mod_name_lower" == *"$server_mod"* ]] || [[ "$mod_name_lower" =~ ^"$server_mod"(-|$) ]]; then
            is_server=true
            break
        fi
    done
    
    # Apply the correct side
    if [[ "$is_client" == true ]] && [[ "$is_server" == false ]]; then
        if set_mod_side "$mod_file" "client"; then
            ((total_updated++))
        fi
        ((total_client++))
    elif [[ "$is_client" == false ]] && [[ "$is_server" == true ]]; then
        if set_mod_side "$mod_file" "server"; then
            ((total_updated++))
        fi
        ((total_server++))
    else
        # Either it's both or not found in either list - default to both
        if set_mod_side "$mod_file" "both"; then
            ((total_updated++))
        fi
        ((total_both++))
    fi
done

log_info "Updated $total_updated mod side tags"
log_info "Final mod side statistics:"
log_info "- Client-only mods: $total_client"
log_info "- Server-only mods: $total_server"
log_info "- Both sides: $total_both"
log_info "- Total: $((total_client + total_server + total_both)) mods"

# Special cases that need manual intervention
log_info "Checking for specific mods that need special handling..."

# Cobblemon is always both
for file in "$MODS_DIR"/cobblemon*.pw.toml; do
    if [[ -f "$file" ]] && [[ "$(basename "$file")" != *spawn-notification* ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Cobblemon mod to 'both' side"
        fi
    fi
done

# Cosmetic armor should be both
for file in "$MODS_DIR"/cosmetic*armor*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Cosmetic Armor mod to 'both' side"
        fi
    fi
done

# Chunky should be both
for file in "$MODS_DIR"/chunky*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Chunky mod to 'both' side"
        fi
    fi
done

# Smooth chunk save should be both
for file in "$MODS_DIR"/*smooth*chunk*save*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Smooth Chunk Save mod to 'both' side"
        fi
    fi
done

# Reliquified mods should be both
for file in "$MODS_DIR"/reliquified*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Reliquified mod to 'both' side"
        fi
    fi
done

# Placebo should be both
for file in "$MODS_DIR"/placebo*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Placebo mod to 'both' side"
        fi
    fi
done

# Cobblemon spawn notification should be both
for file in "$MODS_DIR"/*cobblemon*spawn*notification*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "both"; then
            log_info "Set Cobblemon Spawn Notification mod to 'both' side"
        fi
    fi
done

# What's That Slot should be client
for file in "$MODS_DIR"/*whats*that*slot*.pw.toml; do
    if [[ -f "$file" ]]; then
        if set_mod_side "$file" "client"; then
            log_info "Set What's That Slot mod to 'client' side"
        fi
    fi
done

log_info "Mod tagging process complete!"
