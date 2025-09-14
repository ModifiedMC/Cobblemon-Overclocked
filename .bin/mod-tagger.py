#!/usr/bin/env python3

import csv
import os
import subprocess
import sys
import requests
import re

# Define colors for terminal output
BLUE = '\033[0;34m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'  # No Color

def log_info(msg):
    print(f"{BLUE}INFO: {msg}{NC}")

def log_success(msg):
    print(f"{GREEN}✓ {msg}{NC}")

def log_warning(msg):
    print(f"{YELLOW}⚠️ {msg}{NC}")

def log_error(msg):
    print(f"{RED}✗ {msg}{NC}")

# Create working directory
WORK_DIR = "/tmp/mod_sides_py"
os.makedirs(WORK_DIR, exist_ok=True)

# Download the spreadsheet
log_info("Downloading spreadsheet data...")
SPREADSHEET_ID = "1ZRY8bUIjb1ak4pTfaeIqjhMCLwFMxapjcePJjWrYXMQ"
CSV_URL = f"https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/export?format=csv&gid=0"

try:
    response = requests.get(CSV_URL)
    if response.status_code == 200:
        with open(f"{WORK_DIR}/mod_data.csv", "wb") as f:
            f.write(response.content)
        log_success("Downloaded spreadsheet data")
    else:
        log_error(f"Failed to download spreadsheet: HTTP {response.status_code}")
        sys.exit(1)
except Exception as e:
    log_error(f"Failed to download spreadsheet: {str(e)}")
    sys.exit(1)

# Parse the CSV data
log_info("Processing spreadsheet data...")
client_mods = []
server_mods = []
both_mods = []
mod_id_mapping = {}  # Maps mod_id to mod_name for better matching
mod_sides = {}  # Maps mod_id to side

# Hard-coded overrides for specific mods
special_cases = {
    # Both sides
    "cobblemon": "both",
    "cosmetic-armor-reworked": "both",
    "cosmeticarmorreworked": "both",
    "reliquified-l-ender-s-cataclysm": "both",
    "reliquified_lenders_cataclysm": "both",
    
    # Server only
    "cobblemon-spawn-notification": "server",
    "spawnnotification": "server",
    
    # Client only - UI and visual mods
    "immediatelyfast": "client",
    "pausemenuapi": "client",
    "ftb-pause-menu-api": "client",
    "pausemenufabric": "client",
    "tmrv": "client",
    "welcomescreen": "client",
    "welcome-screen": "client",
    "keybindjs": "client",
    "keybind": "client",
    "journeymap": "client",
    "ftbchunks": "client",
    "ftb-chunks": "client",
    "ftbchunksapi": "client",
    "ftb-chunks-api": "client",
    "dynmap": "client",
    "xaeros": "client",
    "minimap": "client",
    "mapatlases": "client",
    "map-atlases": "client",
    "betterping": "client",
    "better-ping": "client",
    "fastip": "client",
    "fast-ip": "client",
    "dynamiclights": "client",
    "dynamic-lights": "client",
    "controlify": "client"
}

try:
    with open(f"{WORK_DIR}/mod_data.csv", "r", encoding="utf-8") as f:
        # Show the first 5 lines for debugging
        log_info("First 5 lines of CSV data:")
        lines = []
        for i, line in enumerate(f):
            if i < 5:
                lines.append(line.strip())
                print(line.strip())
            else:
                break
        f.seek(0)  # Reset to start of file
        
        # Skip the first two rows (headers)
        next(f)
        next(f)
        
        # Parse the CSV data
        csv_reader = csv.reader(f)
        for row in csv_reader:
            if len(row) < 4 or not row[0].strip():
                continue  # Skip empty rows or rows with insufficient data
            
            # Columns A=Mod Name, B=Mod ID, C=Client flag, D=Server flag
            mod_name = row[0].strip()
            mod_id = row[1].strip()
            client = row[2].strip().upper() == "TRUE"
            server = row[3].strip().upper() == "TRUE"
            
            # Skip empty mod IDs
            if not mod_id:
                continue
                
            # Store both the mod_name and mod_id for better matching
            mod_id_mapping[mod_id.lower()] = mod_name
            
            # Store the side directly in the mod_sides dictionary
            if client and not server:
                mod_sides[mod_id.lower()] = "client"
                client_mods.append(mod_id)
            elif not client and server:
                mod_sides[mod_id.lower()] = "server"
                server_mods.append(mod_id)
            else:
                mod_sides[mod_id.lower()] = "both"
                both_mods.append(mod_id)
                
            # Also store by mod name for better matching
            clean_mod_name = re.sub(r'[^a-zA-Z0-9]', '', mod_name.lower())
            if clean_mod_name and len(clean_mod_name) > 3:  # Only if substantial
                if client and not server:
                    mod_sides[clean_mod_name] = "client"
                elif not client and server:
                    mod_sides[clean_mod_name] = "server"
                else:
                    mod_sides[clean_mod_name] = "both"
    
    # Save the lists to files for reference
    with open(f"{WORK_DIR}/client_mods.txt", "w") as f:
        f.write("\n".join(client_mods))
    
    with open(f"{WORK_DIR}/server_mods.txt", "w") as f:
        f.write("\n".join(server_mods))
    
    with open(f"{WORK_DIR}/both_mods.txt", "w") as f:
        f.write("\n".join(both_mods))
    
    log_info(f"Spreadsheet mod counts:")
    log_info(f"- Client-only mods: {len(client_mods)}")
    log_info(f"- Server-only mods: {len(server_mods)}")
    log_info(f"- Both sides: {len(both_mods)}")
    log_info(f"- Total: {len(client_mods) + len(server_mods) + len(both_mods)} mods")
    
    # Show samples
    if client_mods:
        log_info("Sample CLIENT-ONLY mods:")
        for mod in client_mods[:10]:
            print(mod)
    
    if server_mods:
        log_info("Sample SERVER-ONLY mods:")
        for mod in server_mods[:10]:
            print(mod)
    
except Exception as e:
    log_error(f"Error parsing CSV data: {str(e)}")
    sys.exit(1)

# Function to update mod side in TOML file
def update_mod_side(mod_file, new_side):
    try:
        mod_name = os.path.basename(mod_file)[:-8]  # Remove .pw.toml
        
        # Read the file content
        with open(mod_file, "r") as f:
            content = f.read()
        
        # Check if side is already defined
        if "side = " in content:
            import re
            current_side_match = re.search(r'side = "(client|server|both)"', content)
            if current_side_match:
                current_side = current_side_match.group(1)
                
                # Update if different
                if current_side != new_side:
                    new_content = content.replace(f'side = "{current_side}"', f'side = "{new_side}"')
                    with open(mod_file, "w") as f:
                        f.write(new_content)
                    log_success(f"Updated {mod_name} from \"{current_side}\" to \"{new_side}\"")
                    return True
        else:
            # Add side after name line
            import re
            new_content = re.sub(r'(name = "[^"]*")', r'\1\nside = "' + new_side + '"', content)
            with open(mod_file, "w") as f:
                f.write(new_content)
            log_success(f"Added side = \"{new_side}\" to {mod_name}")
            return True
        
        return False
    except Exception as e:
        log_error(f"Error updating {mod_file}: {str(e)}")
        return False

# Find the best matching mod from our lists
def find_best_match(mod_file):
    mod_name = os.path.basename(mod_file)[:-8]  # Remove .pw.toml
    mod_name_lower = mod_name.lower()
    
    # Check for special cases first - these override everything
    for special_case, side in special_cases.items():
        if special_case in mod_name_lower:
            log_info(f"Special case match: {mod_name} -> {side} (matched {special_case})")
            return side
    
    # Check for client patterns early - many UI/visual mods need to be client-side
    client_patterns = [
        "shader", "graphic", "optifine", "sodium", "iris", "ui", "hud", "minimap", 
        "map", "jei", "rei", "emi", "xaero", "journeymap", "visualize", "animation",
        "skin", "resourcepack", "texture", "sound", "music", "menu", "chat", "emote",
        "cape", "particle", "tooltip", "loading", "screen", "model", 
        "camera", "screenshot", "zoom", "keybind", "mouse", "keyboard",
        "gui", "borderless", "fullscreen", "fps", "betterf3", "highlight", 
        "advancement", "toast", "voice", "discord", "drippy", "ping", "chunk", 
        "ftb-client", "appleskin", "emiprofessions", "fast-ip", "dynamiclights",
        "controls", "controller", "gamepad", "client-craft", "clientcraft", "welcome",
        "render", "tps", "chunkanimator", "ftb-gui", "ftb-teams", "ftb-library",
        "apparel", "cosmetic", "cape", "blur", "smoothboot", "smooth-boot",
        "fast-render", "farsight", "wilds", "extrasounds", "extra-sounds",
        "haema", "pausemenu", "pause-menu"
    ]
    
    for pattern in client_patterns:
        if pattern in mod_name_lower:
            log_info(f"Client pattern match: {mod_name} -> client (matched {pattern})")
            return "client"
    
    # Check for server patterns early
    server_patterns = [
        "permission", "antigrief", "antixray", "exploitfix", "backup", "crash-exploit", 
        "ban", "kick", "protection", "safeguard", "worldedit", "worldguard", "management",
        "mending", "alternate-current", "recycle", "optimize-server", "nosium"
    ]
    
    for pattern in server_patterns:
        if pattern in mod_name_lower:
            log_info(f"Server pattern match: {mod_name} -> server (matched {pattern})")
            return "server"
            
    # Try direct match with spreadsheet data (normalize names)
    normalized_mod_name = re.sub(r'[^a-zA-Z0-9]', '', mod_name_lower)
    
    # Try to find the mod in our spreadsheet data
    for mod_id, side in mod_sides.items():
        normalized_mod_id = re.sub(r'[^a-zA-Z0-9]', '', mod_id.lower())
        
        # Direct match
        if normalized_mod_id == normalized_mod_name:
            log_info(f"Exact spreadsheet match: {mod_name} -> {side} (matched {mod_id})")
            return side
        
        # Substring match - only if one is fully contained in the other
        if normalized_mod_id in normalized_mod_name or normalized_mod_name in normalized_mod_id:
            if len(normalized_mod_id) > 4:  # Only match if mod ID is substantial
                log_info(f"Substring spreadsheet match: {mod_name} -> {side} (matched {mod_id})")
                return side
    
    # If we reach here, we couldn't determine the side from patterns or spreadsheet data
    # Default to both sides for safety
    log_info(f"No match found for {mod_name}, defaulting to both sides")
    
    # Default to both
    return "both"

# Update all mod TOML files
log_info("Updating mod TOML files...")
client_updated = 0
server_updated = 0
both_updated = 0
total_updated = 0

# Track mods processed for later analysis
processed_mods = {
    "client": [],
    "server": [],
    "both": []
}

mods_dir = "/home/jake/Cobblemon-Overclocked/mods"
toml_files = [os.path.join(mods_dir, f) for f in os.listdir(mods_dir) if f.endswith(".pw.toml")]
log_info(f"Found {len(toml_files)} TOML files to process")

for mod_file in toml_files:
    # Find the best match and determine side
    side = find_best_match(mod_file)
    
    # Track processed mods
    mod_name = os.path.basename(mod_file)[:-8]
    processed_mods[side].append(mod_name)
    
    # Update the mod file
    if update_mod_side(mod_file, side):
        total_updated += 1
        if side == "client":
            client_updated += 1
        elif side == "server":
            server_updated += 1
        else:
            both_updated += 1

log_info(f"Updated mod sides:")
log_info(f"- Client-only: {client_updated}")
log_info(f"- Server-only: {server_updated}")
log_info(f"- Both sides: {both_updated}")
log_info(f"- Total updated: {total_updated}")

# Get final statistics
try:
    client_count = len(subprocess.check_output(f"grep -l '^side = \"client\"' {mods_dir}/*.pw.toml 2>/dev/null || true", shell=True).decode().strip().split("\n") if subprocess.check_output(f"grep -l '^side = \"client\"' {mods_dir}/*.pw.toml 2>/dev/null || true", shell=True).decode().strip() else [])
    server_count = len(subprocess.check_output(f"grep -l '^side = \"server\"' {mods_dir}/*.pw.toml 2>/dev/null || true", shell=True).decode().strip().split("\n") if subprocess.check_output(f"grep -l '^side = \"server\"' {mods_dir}/*.pw.toml 2>/dev/null || true", shell=True).decode().strip() else [])
    both_count = len(subprocess.check_output(f"grep -l '^side = \"both\"' {mods_dir}/*.pw.toml 2>/dev/null || true", shell=True).decode().strip().split("\n") if subprocess.check_output(f"grep -l '^side = \"both\"' {mods_dir}/*.pw.toml 2>/dev/null || true", shell=True).decode().strip() else [])
except:
    # Fallback if grep fails
    client_count = client_updated
    server_count = server_updated
    both_count = both_updated

log_info(f"Final mod side statistics:")
log_info(f"- Client-only mods: {client_count}")
log_info(f"- Server-only mods: {server_count}")
log_info(f"- Both sides: {both_count}")
log_info(f"- Total: {client_count + server_count + both_count} mods")

# Show samples of processed mods
if processed_mods["client"]:
    log_info(f"Sample CLIENT mods processed ({len(processed_mods['client'])} total):")
    for mod in processed_mods["client"][:20]:  # Show first 20
        print(mod)

if processed_mods["server"]:
    log_info(f"Sample SERVER mods processed ({len(processed_mods['server'])} total):")
    for mod in processed_mods["server"][:20]:  # Show first 20
        print(mod)

# Save processed mods to files for reference
with open(f"{WORK_DIR}/processed_client_mods.txt", "w") as f:
    f.write("\n".join(processed_mods["client"]))

with open(f"{WORK_DIR}/processed_server_mods.txt", "w") as f:
    f.write("\n".join(processed_mods["server"]))

with open(f"{WORK_DIR}/processed_both_mods.txt", "w") as f:
    f.write("\n".join(processed_mods["both"]))

log_info("Mod tagging complete!")
