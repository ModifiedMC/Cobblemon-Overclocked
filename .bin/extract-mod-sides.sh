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
# Skip first 3 header rows
log_info "Processing spreadsheet data..."
client_count=0
server_count=0

# Skip header rows (first 3 lines)
tail -n +4 "$TEMP_CSV" | while IFS=, read -r modname modid client_value server_value rest; do
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
        ((client_count++))
    elif [ "$client_value" != "true" ] && [ "$server_value" = "true" ]; then
        echo "$modid" >> "$SERVER_MODS_FILE"
        log_success "Added $modname to server-only mods"
        ((server_count++))
    fi
done

log_info "Spreadsheet processing complete"
log_info "Client-only mods: $client_count"
log_info "Server-only mods: $server_count"

# Add special cases manually
log_info "Adding special cases..."

# What's That Slot should be client-only
if ! grep -q "whats-that-slot" "$CLIENT_MODS_FILE"; then
    echo "whats-that-slot" >> "$CLIENT_MODS_FILE"
    log_success "Added What's That Slot to client-only mods"
    ((client_count++))
fi

log_info "Final counts - Client-only: $client_count, Server-only: $server_count"
log_info "Data extraction complete!"
