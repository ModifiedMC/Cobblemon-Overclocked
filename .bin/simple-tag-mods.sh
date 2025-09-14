#!/bin/bash

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

# Create working directory
WORK_DIR="/tmp/mod_sides_simple"
mkdir -p "$WORK_DIR"

# Download the spreadsheet
log_info "Downloading spreadsheet data..."
SPREADSHEET_ID="1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
CSV_URL="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv&gid=0"

if curl -s -L "$CSV_URL" -o "$WORK_DIR/mod_data.csv"; then
    log_success "Downloaded spreadsheet data"
else
    log_error "Failed to download spreadsheet"
    exit 1
fi

# Create files to store mod lists
> "$WORK_DIR/client_mods.txt"
> "$WORK_DIR/server_mods.txt"
> "$WORK_DIR/both_mods.txt"

# Process the CSV data line by line
log_info "Processing spreadsheet data..."

# Skip the first two lines (headers)
line_num=0
while IFS= read -r line; do
    line_num=$((line_num + 1))
    
    # Skip header rows
    if [ "$line_num" -le 2 ]; then
        continue
    fi
    
    # Parse the line into fields
    IFS=',' read -r mod_id client server <<< "$line"
    
    # Clean up fields (remove quotes, whitespace)
    mod_id=$(echo "$mod_id" | tr -d ' "')
    client=$(echo "$client" | tr -d ' "')
    server=$(echo "$server" | tr -d ' "')
    
    # Skip empty lines
    if [ -z "$mod_id" ]; then
        continue
    fi
    
    # Determine side based on flags
    if [[ "$client" == "TRUE" && "$server" == "FALSE" ]]; then
        echo "$mod_id" >> "$WORK_DIR/client_mods.txt"
    elif [[ "$client" == "FALSE" && "$server" == "TRUE" ]]; then
        echo "$mod_id" >> "$WORK_DIR/server_mods.txt"
    else
        echo "$mod_id" >> "$WORK_DIR/both_mods.txt"
    fi
    
done < "$WORK_DIR/mod_data.csv"

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

# Show the first few client-only mods
log_info "First 10 CLIENT-ONLY mods:"
head -n 10 "$WORK_DIR/client_mods.txt"

# Show the first few server-only mods
log_info "First 10 SERVER-ONLY mods:"
head -n 10 "$WORK_DIR/server_mods.txt"

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

# Function to find best match for a mod ID
find_best_match() {
    local mod_name=$1
    local list_file=$2
    
    # Check for exact match
    if grep -Fxiq "$mod_name" "$list_file"; then
        return 0
    fi
    
    # Check for mod ID in our file name
    while IFS= read -r list_id; do
        if [[ "$mod_name" == *"${list_id,,}"* ]]; then
            return 0
        fi
    done < "$list_file"
    
    return 1
}

# Update all mod TOML files
log_info "Updating mod TOML files..."
client_updated=0
server_updated=0
both_updated=0

for mod_file in $(find /home/jake/Cobblemon-Overclocked/mods -name "*.pw.toml"); do
    mod_name=$(basename "$mod_file" .pw.toml | tr '[:upper:]' '[:lower:]')
    
    # Try to find the best match
    if find_best_match "$mod_name" "$WORK_DIR/client_mods.txt"; then
        side="client"
        if update_mod_side "$mod_file" "$side"; then
            client_updated=$((client_updated + 1))
        fi
    elif find_best_match "$mod_name" "$WORK_DIR/server_mods.txt"; then
        side="server"
        if update_mod_side "$mod_file" "$side"; then
            server_updated=$((server_updated + 1))
        fi
    else
        side="both"
        if update_mod_side "$mod_file" "$side"; then
            both_updated=$((both_updated + 1))
        fi
    fi
done

log_info "Updated mod sides:"
log_info "- Client-only: $client_updated"
log_info "- Server-only: $server_updated" 
log_info "- Both sides: $both_updated"
log_info "- Total updated: $((client_updated + server_updated + both_updated))"

# Get final statistics
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
