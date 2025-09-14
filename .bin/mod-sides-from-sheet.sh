#!/bin/bash

# This script downloads mod data from the provided Google Spreadsheet and sets the side property 
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

# Create a working directory
WORK_DIR="/tmp/mod_sides"
mkdir -p "$WORK_DIR"

# Download the CSV data from the Google Spreadsheet
download_spreadsheet_data() {
    log_info "Downloading mod data from spreadsheet..."
    
    # The spreadsheet ID from the URL
    SPREADSHEET_ID="1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
    
    # The GID for the specific sheet (default is 0)
    GID="0"
    
    # URL to export as CSV
    CSV_URL="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv&gid=$GID"
    
    # Download the CSV data with redirect following
    if curl -s -L "$CSV_URL" -o "$WORK_DIR/mod_data.csv"; then
        # Check if we got actual CSV data and not HTML
        if grep -q "<HTML>" "$WORK_DIR/mod_data.csv"; then
            log_error "Received HTML instead of CSV data. Authentication may be required."
            return 1
        else
            log_success "Downloaded mod data successfully"
            
            # Print some rows from CSV to verify format
            log_info "CSV sample (first 5 rows):"
            head -n 5 "$WORK_DIR/mod_data.csv"
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
    
    # Count total rows for progress tracking
    total_rows=$(wc -l < "$WORK_DIR/mod_data.csv")
    log_info "Total rows in CSV: $total_rows"
    
    # Create files to store the processed data
    > "$WORK_DIR/client_mods.txt"
    > "$WORK_DIR/server_mods.txt" 
    > "$WORK_DIR/both_mods.txt"
    
    # Skip the header rows (first 2) and process each line
    # Based on user guidance:
    # - Column A (1): Mod ID
    # - Column B (2): Client flag (TRUE/FALSE)
    # - Column C (3): Server flag (TRUE/FALSE)
    
    log_info "Parsing CSV data..."
    awk -F, 'NR > 2 { 
        # Skip empty rows
        if (NF < 3) next;
        
        # Get mod ID from column A (1)
        mod_id = $1;
        gsub(/^"|"$|^ | $/, "", mod_id);
        
        # Get client flag from column B (2)
        client = toupper($2);
        gsub(/^"|"$|^ | $/, "", client);
        
        # Get server flag from column C (3)
        server = toupper($3);
        gsub(/^"|"$|^ | $/, "", server);
        
        # Skip rows with empty mod IDs
        if (mod_id == "") next;
        
        # Determine side based on flags
        if (client == "TRUE" && server == "FALSE") {
            print mod_id > "/tmp/mod_sides/client_mods.txt";
        } else if (client == "FALSE" && server == "TRUE") {
            print mod_id > "/tmp/mod_sides/server_mods.txt";
        } else if (client == "TRUE" && server == "TRUE") {
            print mod_id > "/tmp/mod_sides/both_mods.txt";
        } else {
            # Default to both if flags are unclear
            print mod_id > "/tmp/mod_sides/both_mods.txt";
        }
    }' "$WORK_DIR/mod_data.csv"
    
    # Count mods in each category
    client_count=$(wc -l < "$WORK_DIR/client_mods.txt")
    server_count=$(wc -l < "$WORK_DIR/server_mods.txt")
    both_count=$(wc -l < "$WORK_DIR/both_mods.txt")
    total_count=$((client_count + server_count + both_count))
    
    log_info "CSV Processing Results:"
    log_info "- Client-only mods: $client_count"
    log_info "- Server-only mods: $server_count"
    log_info "- Both sides: $both_count" 
    log_info "- Total parsed mods: $total_count"
    
    if [ "$total_count" -gt 0 ]; then
        # Sample the first few entries from each category to verify
        log_info "Sample of client-only mods:"
        head -n 5 "$WORK_DIR/client_mods.txt"
        
        log_info "Sample of server-only mods:"
        head -n 5 "$WORK_DIR/server_mods.txt"
        
        log_info "Sample of both-sides mods:"
        head -n 5 "$WORK_DIR/both_mods.txt"
        
        log_success "Processed $total_count mods from spreadsheet"
        return 0
    else
        log_error "No mods were processed from the spreadsheet"
        return 1
    fi
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

# Find the best match for a mod in our list
find_mod_match() {
    local mod_file=$1
    local mod_name=$(basename "$mod_file" .pw.toml | tr '[:upper:]' '[:lower:]')
    
    # Look for exact match in client mods
    if grep -Fxq "$mod_name" "$WORK_DIR/client_mods.txt"; then
        echo "client"
        return 0
    fi
    
    # Look for exact match in server mods
    if grep -Fxq "$mod_name" "$WORK_DIR/server_mods.txt"; then
        echo "server"
        return 0
    fi
    
    # Look for exact match in both mods
    if grep -Fxq "$mod_name" "$WORK_DIR/both_mods.txt"; then
        echo "both"
        return 0
    fi
    
    # Try loose matching
    # First, try mods that contain our mod name
    for side in client server both; do
        while read -r list_mod; do
            if [[ "$list_mod" == *"$mod_name"* ]]; then
                echo "$side"
                return 0
            fi
        done < "$WORK_DIR/${side}_mods.txt"
    done
    
    # Then, try mods in our list that are contained in our mod name
    for side in client server both; do
        while read -r list_mod; do
            if [[ "$mod_name" == *"$list_mod"* && "${#list_mod}" -gt 4 ]]; then
                # Only match if the list mod name is substantial (>4 chars)
                echo "$side"
                return 0
            fi
        done < "$WORK_DIR/${side}_mods.txt"
    done
    
    # Default to both if no match is found
    echo "both"
    return 1
}

# Apply sides to mods
apply_mod_sides() {
    log_info "Applying mod sides to TOML files..."
    
    # Find all mod TOML files
    mod_files=$(find /home/jake/Cobblemon-Overclocked/mods -name "*.pw.toml")
    total_mods=$(echo "$mod_files" | wc -l)
    updated_mods=0
    client_updated=0
    server_updated=0
    both_updated=0
    
    for mod_file in $mod_files; do
        # Get mod name without extension
        mod_name=$(basename "$mod_file" .pw.toml)
        
        # Find the best match for this mod
        side=$(find_mod_match "$mod_file")
        result=$?
        
        if [[ $result -eq 0 ]]; then
            # Match found
            if update_mod_side "$mod_file" "$side"; then
                updated_mods=$((updated_mods + 1))
                case "$side" in
                    "client") client_updated=$((client_updated + 1)) ;;
                    "server") server_updated=$((server_updated + 1)) ;;
                    "both") both_updated=$((both_updated + 1)) ;;
                esac
            fi
        else
            # No match found
            log_warning "No match found for $mod_name, defaulting to 'both'"
            if update_mod_side "$mod_file" "both"; then
                updated_mods=$((updated_mods + 1))
                both_updated=$((both_updated + 1))
            fi
        fi
    done
    
    log_info "Updated mod sides:"
    log_info "- Client-only: $client_updated"
    log_info "- Server-only: $server_updated"
    log_info "- Both sides: $both_updated"
    log_info "- Total: $updated_mods out of $total_mods files"
}

# Handle special cases for specific mods
handle_special_cases() {
    log_info "Handling special cases..."
    
    # Sodium and related mods should always be client-only
    declare -a forced_client=(
        "sodium"
        "sodium-extra"
        "reeses-sodium-options"
        "sodium-options-api"
        "iris"
        "oculus"
        "irisshaders"
    )
    
    # Server optimization mods should always be server-only
    declare -a forced_server=(
        "alternate-current"
        "servercore"
    )
    
    # Update forced client mods
    for mod in "${forced_client[@]}"; do
        find /home/jake/Cobblemon-Overclocked/mods -name "*${mod}*.pw.toml" | while read -r mod_file; do
            update_mod_side "$mod_file" "client"
        done
    done
    
    # Update forced server mods
    for mod in "${forced_server[@]}"; do
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
        # Apply the processed data to mod files
        apply_mod_sides
        
        # Handle special cases
        handle_special_cases
        
        # Get final statistics
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
    else
        log_error "Failed to process spreadsheet data"
        exit 1
    fi
}

# Run the main function
main
