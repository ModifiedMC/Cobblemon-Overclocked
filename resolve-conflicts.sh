#!/bin/bash

# Script to resolve merge conflicts by accepting all changes from remote branch

# Accept remote changes for all files
git checkout --theirs index.toml
git checkout --theirs pack.toml
git checkout --theirs config/bcc-common.toml
git checkout --theirs mods/accessories-compat-layer.pw.toml
git checkout --theirs mods/cable-tiers.pw.toml
git checkout --theirs mods/cobblemon-tim-core.pw.toml
git checkout --theirs mods/create-central-kitchen.pw.toml
git checkout --theirs mods/create-dragons-plus.pw.toml
git checkout --theirs mods/create-enchantment-industry.pw.toml
git checkout --theirs mods/extra-mod-integrations.pw.toml
git checkout --theirs mods/flerovium.pw.toml
git checkout --theirs mods/minecolonies.pw.toml
git checkout --theirs mods/selene.pw.toml
git checkout --theirs mods/simple-voice-chat.pw.toml
git checkout --theirs mods/sophisticated-backpacks.pw.toml
git checkout --theirs mods/sophisticated-core.pw.toml
git checkout --theirs mods/sophisticated-storage.pw.toml

# These files were deleted in the remote branch, but modified in the local branch
# We'll accept the remote deletion
git rm mods/compact-help-command.pw.toml
git rm mods/crashexploitfixer.pw.toml
git rm mods/feature-recycler.pw.toml
git rm mods/noisium.pw.toml

# Mark all conflicts as resolved
git add .

# Commit the changes
git commit -m "Resolve merge conflicts by accepting remote changes"

# Complete the merge
git status
