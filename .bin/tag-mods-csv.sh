#!/bin/bash

# This script downloads mod data from a Google Spreadsheet and sets the side property 
# (client, server, or both) for all mods based on the data
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

# Download the CSV data from the Google Spreadsheet
download_spreadsheet_data() {
    log_info "Downloading mod data from spreadsheet..."
    
    # The spreadsheet ID from the provided URL
    SPREADSHEET_ID="1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
    
    # URL to export as CSV (no specific GID needed)
    CSV_URL="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv"
    
    # Download the CSV data
    if curl -s -L "$CSV_URL" -o /tmp/mod_data.csv; then
        # Check if we got actual CSV data and not HTML
        if grep -q "<HTML>" /tmp/mod_data.csv; then
            log_error "Received HTML instead of CSV data. Authentication may be required."
            return 1
        else
            log_success "Downloaded mod data successfully"
            return 0
        fi
    else
        log_error "Failed to download mod data"
        return 1
    fi
}

# Process the CSV data to determine mod sides
process_spreadsheet_data() {
    log_info "Processing spreadsheet data..."
    
    # Create a temporary file to store the mod sides
    > /tmp/mod_sides.csv
    
    # Print the first few lines to see the structure
    log_info "CSV Structure Sample:"
    head -n 3 /tmp/mod_data.csv
    
    # Count total rows for progress tracking
    total_rows=$(wc -l < /tmp/mod_data.csv)
    log_info "Total rows in CSV: $total_rows"
    
    # Skip the header row and process each line
    # Based on user guidance: B column is client, C column is server
    awk -F, 'NR > 1 { 
        # Get mod ID from column A (1)
        mod_id = $1;
        gsub(/^"|"$|^ | $/, "", mod_id);
        
        # Get client flag from column B (2)
        client = $2;
        gsub(/^"|"$|^ | $/, "", client);
        
        # Get server flag from column C (3)
        server = $3;
        gsub(/^"|"$|^ | $/, "", server);
        
        # Skip empty mod IDs
        if (mod_id != "") {
            # Determine side based on flags
            side = "both";
            if (client == "TRUE" && server != "TRUE") {
                side = "client";
            } else if (client != "TRUE" && server == "TRUE") {
                side = "server";
            } else if (client == "TRUE" && server == "TRUE") {
                side = "both";
            }
            
            # Output to temp file
            print mod_id ":" side;
        }
    }' /tmp/mod_data.csv > /tmp/mod_sides.csv
    
    # Show some statistics
    client_count=$(grep -c ":client$" /tmp/mod_sides.csv 2>/dev/null || true)
    if [[ -z "$client_count" ]]; then client_count=0; fi
    
    server_count=$(grep -c ":server$" /tmp/mod_sides.csv 2>/dev/null || true)
    if [[ -z "$server_count" ]]; then server_count=0; fi
    
    both_count=$(grep -c ":both$" /tmp/mod_sides.csv 2>/dev/null || true)
    if [[ -z "$both_count" ]]; then both_count=0; fi
    
    total_count=$((client_count + server_count + both_count))
    
    log_info "CSV Processing Results:"
    log_info "- Client-only mods: $client_count"
    log_info "- Server-only mods: $server_count"
    log_info "- Both sides: $both_count"
    log_info "- Total parsed mods: $total_count"
    
    log_success "Processed $total_count mods from spreadsheet"
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

# Apply the CSV data to the mod TOML files
apply_mod_sides() {
    log_info "Applying mod sides to TOML files..."
    
    # Find all mod TOML files
    mod_files=$(find /home/jake/Cobblemon-Overclocked/mods -name "*.pw.toml")
    total_mods=$(echo "$mod_files" | wc -w)
    updated_mods=0
    
    for mod_file in $mod_files; do
        mod_name=$(basename "$mod_file" .pw.toml | tr -d ' ' | tr '[:upper:]' '[:lower:]')
        found_match=false
        correct_side=""
        
        # Try to find exact match first
        exact_match=$(grep -i "^$mod_name:" /tmp/mod_sides.csv)
        if [[ -n "$exact_match" ]]; then
            correct_side=$(echo "$exact_match" | cut -d':' -f2)
            found_match=true
        else
            # Try partial matching
            while IFS=: read -r csv_mod_name csv_side; do
                # Convert to lowercase for case-insensitive matching
                lower_csv_mod=$(echo "$csv_mod_name" | tr '[:upper:]' '[:lower:]')
                
                # Check for partial matches both ways
                if [[ "$mod_name" == *"$lower_csv_mod"* || "$lower_csv_mod" == *"$mod_name"* ]]; then
                    correct_side="$csv_side"
                    found_match=true
                    break
                fi
            done < /tmp/mod_sides.csv
        fi
        
        # If match found, update the mod file
        if [[ "$found_match" == "true" && -n "$correct_side" ]]; then
            if update_mod_side "$mod_file" "$correct_side"; then
                updated_mods=$((updated_mods + 1))
            fi
        else
            log_warning "No match found for $mod_name, leaving as is"
        fi
    done
    
    log_info "Updated $updated_mods out of $total_mods mod files"
}

# Handle any common special cases that might be missed
handle_special_cases() {
    log_info "Handling special cases..."
    
    # List of known client-only mods
    declare -a client_mods=(
        "world-host"
        "journeymap"
        "jade"
        "jei"
        "emi"
        "iris"
        "sodium"
        "cloth-config"
        "modernfix"
        "cobblenav"
        "crash-assistant"
        "appleskin"
        "ambientsounds"
        "enchantment-descriptions"
        "xaeros"
        "sound-physics"
        "cobblemon-move-inspector"
        "reeses-sodium-options"
        "sodium-options-api"
        "sodium-embeddium-options-mod-compat"
        "sodium-shadowy-path-blocks"
        "paperdoll"
        "skin-layers-3d"
        "entity-texture-features"
        "entity-model-features"
        "better-advancements"
        "blur"
        "betterf3"
        "dynamiclights-reforged"
        "chat-heads"
        "clickable-advancements"
        "controlling"
        "cosmetic-armor-reworked"
        "equipment-compare"
        "fancymenu"
        "inventory-tweaks"
        "inventory-essentials"
        "itemzoom"
        "no-chat-reports"
        "not-enough-animations"
        "waveycapes"
    )
    
    # List of known server-only mods
    declare -a server_mods=(
        "spark"
        "clumps"
        "luckperms"
        "alternate-current"
        "ai-improvements"
        "servercore"
        "chunk-sending"
        "crashexploitfixer"
        "c2me"
        "smoothchunk"
        "packet-fixer"
        "login-protection"
        "despawn-tweaks"
    )
    
    # Update client-only mods
    for mod in "${client_mods[@]}"; do
        find /home/jake/Cobblemon-Overclocked/mods -name "*${mod}*.pw.toml" | while read -r mod_file; do
            update_mod_side "$mod_file" "client"
        done
    done
    
    # Update server-only mods
    for mod in "${server_mods[@]}"; do
        find /home/jake/Cobblemon-Overclocked/mods -name "*${mod}*.pw.toml" | while read -r mod_file; do
            update_mod_side "$mod_file" "server"
        done
    done
    
    log_success "Special cases handled"
}

# Main function
main() {
    log_info "Starting mod side tagging based on Google Spreadsheet..."
    
    # Download and process the spreadsheet data
    if download_spreadsheet_data && process_spreadsheet_data; then
        apply_mod_sides
        handle_special_cases
        
        # Count sides for final statistics
        client_count=$(grep -l "^side = \"client\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l || echo 0)
        server_count=$(grep -l "^side = \"server\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l || echo 0)
        both_count=$(grep -l "^side = \"both\"" /home/jake/Cobblemon-Overclocked/mods/*.pw.toml 2>/dev/null | wc -l || echo 0)
        
        # Make sure we have numeric values
        if [[ -z "$client_count" ]]; then client_count=0; fi
        if [[ -z "$server_count" ]]; then server_count=0; fi
        if [[ -z "$both_count" ]]; then both_count=0; fi
        
        log_info "Final Mod Side Statistics:"
        log_info "- Client-only mods: $client_count"
        log_info "- Server-only mods: $server_count"
        log_info "- Both sides: $both_count"
        log_info "- Total mods: $((client_count + server_count + both_count))"
        
        log_info "Mod tagging complete!"
    else
        log_error "Failed to process spreadsheet data"
        exit 1
    fi
}

# Run the main function
main
