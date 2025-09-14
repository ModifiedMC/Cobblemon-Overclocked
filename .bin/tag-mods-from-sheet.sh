#!/bin/bash

# This script updates mod sides based on the spreadsheet data
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

# Create a working directory
WORK_DIR="/tmp/mod_sides"
mkdir -p "$WORK_DIR"

# Download the spreadsheet data
log_info "Downloading spreadsheet data..."
SPREADSHEET_ID="1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
CSV_URL="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv&gid=0"

if curl -s -L "$CSV_URL" -o "$WORK_DIR/mod_data.csv"; then
    log_success "Downloaded spreadsheet data"
    
    # Show the first few lines to verify format
    log_info "CSV format sample:"
    head -n 5 "$WORK_DIR/mod_data.csv"
else
    log_error "Failed to download spreadsheet data"
    exit 1
fi

# Parse the CSV data and create lists of mods for each side
log_info "Processing spreadsheet data..."

# Clear previous data
> "$WORK_DIR/client_mods.txt"
> "$WORK_DIR/server_mods.txt"
> "$WORK_DIR/both_mods.txt"

# Extract mod data starting from line 3 (skip headers)
tail -n +3 "$WORK_DIR/mod_data.csv" > "$WORK_DIR/mod_rows.csv"

# Process each row and determine the mod side
while IFS=, read -r mod_id client server rest; do
    # Clean up values (remove quotes, spaces)
    mod_id=$(echo "$mod_id" | tr -d ' "')
    client=$(echo "$client" | tr -d ' "')
    server=$(echo "$server" | tr -d ' "')
    
    # Skip empty lines
    if [ -z "$mod_id" ]; then
        continue
    fi
    
    # Determine side based on client/server flags
    if [ "$client" = "TRUE" ] && [ "$server" = "FALSE" ]; then
        echo "$mod_id" >> "$WORK_DIR/client_mods.txt"
    elif [ "$client" = "FALSE" ] && [ "$server" = "TRUE" ]; then
        echo "$mod_id" >> "$WORK_DIR/server_mods.txt"
    elif [ "$client" = "TRUE" ] && [ "$server" = "TRUE" ]; then
        echo "$mod_id" >> "$WORK_DIR/both_mods.txt"
    else
        # Default to both if unclear
        echo "$mod_id" >> "$WORK_DIR/both_mods.txt"
    fi
done < "$WORK_DIR/mod_rows.csv"

# Count mods in each category
client_count=$(wc -l < "$WORK_DIR/client_mods.txt")
server_count=$(wc -l < "$WORK_DIR/server_mods.txt")
both_count=$(wc -l < "$WORK_DIR/both_mods.txt")
total_count=$((client_count + server_count + both_count))

log_info "Spreadsheet mod counts:"
log_info "- Client-only mods: $client_count"
log_info "- Server-only mods: $server_count"
log_info "- Both sides: $both_count"
log_info "- Total: $total_count mods"

# Show samples of each category
log_info "Sample of CLIENT-ONLY mods:"
head -n 5 "$WORK_DIR/client_mods.txt"

log_info "Sample of SERVER-ONLY mods:"
head -n 5 "$WORK_DIR/server_mods.txt"

log_info "Sample of BOTH-SIDES mods:"
head -n 5 "$WORK_DIR/both_mods.txt"

# Function to update a mod's side in its TOML file
update_mod_side() {
    local mod_file=$1
    local new_side=$2
    local mod_name=$(basename "$mod_file" .pw.toml)
    
    # Check if side is already defined
    if grep -q "^side = " "$mod_file"; then
        # Get current side
        current_side=$(grep -E "^side = " "$mod_file" | sed 's/side = "\(.*\)"/\1/')
        
        # Update if different
        if [ "$current_side" != "$new_side" ]; then
            sed -i "s/side = \"$current_side\"/side = \"$new_side\"/" "$mod_file"
            log_success "Updated $mod_name from \"$current_side\" to \"$new_side\""
            return 0
        fi
    else
        # No side defined, add it after name line
        sed -i "/^name = /a side = \"$new_side\"" "$mod_file"
        log_success "Added side = \"$new_side\" to $mod_name"
        return 0
    fi
    
    return 1
}

# Process all mod files and update their sides
log_info "Updating mod side tags in TOML files..."

client_updated=0
server_updated=0
both_updated=0
total_updated=0

# First, process all mod files
find /home/jake/Cobblemon-Overclocked/mods -name "*.pw.toml" | while read -r mod_file; do
    mod_name=$(basename "$mod_file" .pw.toml | tr '[:upper:]' '[:lower:]')
    mod_id="$mod_name"  # Default to filename as mod ID
    
    # Try to match with spreadsheet data
    side="both"  # Default to both
    
    # Check if this mod is in the client-only list
    if grep -Fxiq "$mod_id" "$WORK_DIR/client_mods.txt"; then
        side="client"
    # Check if this mod is in the server-only list
    elif grep -Fxiq "$mod_id" "$WORK_DIR/server_mods.txt"; then
        side="server"
    # Check if this mod is in the both-sides list
    elif grep -Fxiq "$mod_id" "$WORK_DIR/both_mods.txt"; then
        side="both"
    else
        # Try partial matching for client mods
        found=false
        while IFS= read -r sheet_id; do
            sheet_id=$(echo "$sheet_id" | tr '[:upper:]' '[:lower:]')
            if [[ "$mod_id" == *"$sheet_id"* || "$sheet_id" == *"$mod_id"* ]]; then
                side="client"
                found=true
                break
            fi
        done < <(tr '[:upper:]' '[:lower:]' < "$WORK_DIR/client_mods.txt")
        
        # If not found in client mods, try server mods
        if [ "$found" = false ]; then
            while IFS= read -r sheet_id; do
                sheet_id=$(echo "$sheet_id" | tr '[:upper:]' '[:lower:]')
                if [[ "$mod_id" == *"$sheet_id"* || "$sheet_id" == *"$mod_id"* ]]; then
                    side="server"
                    found=true
                    break
                fi
            done < <(tr '[:upper:]' '[:lower:]' < "$WORK_DIR/server_mods.txt")
        fi
    fi
    
    # Update the mod side in the TOML file
    if update_mod_side "$mod_file" "$side"; then
        total_updated=$((total_updated + 1))
        case "$side" in
            client) client_updated=$((client_updated + 1)) ;;
            server) server_updated=$((server_updated + 1)) ;;
            both) both_updated=$((both_updated + 1)) ;;
        esac
    fi
done

log_info "Updated mod sides:"
log_info "- Client-only: $client_updated"
log_info "- Server-only: $server_updated" 
log_info "- Both sides: $both_updated"
log_info "- Total updated: $total_updated"

# Final stats
client_count=$(grep -l "^side = \"client\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l)
server_count=$(grep -l "^side = \"server\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l)
both_count=$(grep -l "^side = \"both\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l)
total_count=$((client_count + server_count + both_count))

log_info "Final mod side statistics:"
log_info "- Client-only mods: $client_count"
log_info "- Server-only mods: $server_count"
log_info "- Both sides: $both_count"
log_info "- Total: $total_count mods"

log_info "Mod tagging complete!"
