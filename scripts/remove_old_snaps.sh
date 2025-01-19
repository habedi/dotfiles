#!/bin/bash

# This script is used to manage Snap package revisions on a system.
# It sets the Snap revision retain limit to 2 and cleans up old revisions of snaps.

# Display the current Snap revision retain limit
snap get system refresh.retain

# Set the Snap revision retain limit to 2
sudo snap set system refresh.retain=2

# Display the updated Snap revision retain limit
snap get system refresh.retain

# Function to clean up old revisions of snaps
cleanup_snaps() {
    echo "Starting Snap cleanup..."

    # List all installed snaps and their revisions
    snap list --all | awk 'NR>1 {print $1}' | sort -u | while read -r snapname; do
        # Get all revisions for the snap, sorted by revision number
        revisions=( $(snap list --all | awk -v snap="$snapname" '$1 == snap {print $3}' | sort -nr) )

        # Check if more than 2 revisions exist
        if [ "${#revisions[@]}" -gt 2 ]; then
            # Remove all but the two most recent revisions
            for ((i=2; i<${#revisions[@]}; i++)); do
                echo "Removing $snapname revision ${revisions[i]}..."
                sudo snap remove --purge "$snapname" --revision="${revisions[i]}"
            done
        else
            echo "$snapname has 2 or fewer revisions; no cleanup needed."
        fi
    done

    echo "Snap cleanup completed."
}

# Function to set the revision limit
set_revision_limit() {
    echo "Setting Snap revision retain limit to 2..."
    sudo snap set system refresh.retain=2
    echo "Snap revision retain limit set."
}

# Set revision limit
set_revision_limit

# Run the cleanup function
cleanup_snaps
