#!/bin/bash
JAIL_LOCAL="/etc/fail2ban/jail.local"  # Path to your jail.local file
CF_IPS_URL="https://www.cloudflare.com/ips-v4"
TEMP_FILE="/tmp/cloudflare_ips.txt"

# Fetch Cloudflare IPs and check if successful
curl -s "$CF_IPS_URL" -o "$TEMP_FILE"
if [[ $? -ne 0 ]]; then
    echo "Failed to fetch Cloudflare IPs."
    exit 1
else
    echo "Successfully fetched Cloudflare IPs: $TEMP_FILE"
fi

# Read IPs into a single line
CF_IPS=$(tr '\n' ' ' < "$TEMP_FILE" | sed 's/ $//')

# Read existing IPs from jail.local
EXISTING_IPS=$(grep -oP 'ignoreip = \K.*' "$JAIL_LOCAL")

# Compare the existing IPs with the new IPs
if [[ "$CF_IPS" == "$EXISTING_IPS" ]]; then
    echo "No changes detected in the Cloudflare IPs."
    exit 0
fi

# If there are changes, make note additions and removals
ADDED_IPS=$(comm -13 <(echo "$EXISTING_IPS" | tr ' ' '\n' | sort) <(echo "$CF_IPS" | tr ' ' '\n' | sort) | tr '\n' ' ')
REMOVED_IPS=$(comm -23 <(echo "$EXISTING_IPS" | tr ' ' '\n' | sort) <(echo "$CF_IPS" | tr ' ' '\n' | sort) | tr '\n' ' ')

# Make a nice table to of the changes to add to the telegram message
# Create the table header
TABLE="📢 *Cloudflare IP Ignore List Update* 📢\n\n"
TABLE+="\`\`\`\n"
TABLE+="| Status | IP Address       |\n"
TABLE+="|--------|------------------|\n"

# Add rows for added IPs
if [[ -n "$ADDED_IPS" ]]; then
    for ip in $ADDED_IPS; do
        TABLE+="| Added  | $ip             |\n"
    done
fi

# Add rows for removed IPs
if [[ -n "$REMOVED_IPS" ]]; then
    for ip in $REMOVED_IPS; do
        TABLE+="| Removed| $ip             |\n"
    done
fi

TABLE+="\`\`\`\n"
TABLE+="⚠️ *fail2ban will be rebooting shortly.* ⚠️"

# Send the table as a telegram message
bash /etc/fail2ban/action.d/telegram_notif.sh -r "$TABLE"

# Update the jail.local file
if grep -q "^ignoreip" "$JAIL_LOCAL"; then
    # Replace existing ignoreip line
    sed -i "s/^ignoreip.*/ignoreip = 127.0.0.1/8 $CF_IPS/" "$JAIL_LOCAL"
else
    # Add ignoreip line if it doesn't exist
    echo "ignoreip = 127.0.0.1/8 $CF_IPS" >> "$JAIL_LOCAL"
fi

# Restart Fail2ban to apply changes
systemctl restart fail2ban