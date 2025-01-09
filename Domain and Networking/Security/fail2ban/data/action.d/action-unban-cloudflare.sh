AUTH_EMAIL="cloudflare@tomis.online"
AUTH_KEY="9ccbc0f537b908ea62b45ee64dc43e3a0f295"
TARGET_IP=$1

json=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/62cc17fa10ecda5e920683038d4d3aa1/firewall/access_rules/rules" \
  -H "Authorization: Bearer d7_h3NT88T6Mr9g1hHt1_-2lJsgBFFejgPtPOtDY" \
  -H "Content-Type: application/json")

RULE_ID=$(echo "$json" | jq -r --arg value "$TARGET_IP" '.result[] | select(.configuration.value == $value) | .id')

# Check if the RULE_ID was found
if [ -n "$RULE_ID" ] && [ "$RULE_ID" != "null" ]; then
  DELETE_RESPONSE=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/62cc17fa10ecda5e920683038d4d3aa1/firewall/access_rules/rules/$RULE_ID" \
    -H "X-Auth-Email: $AUTH_EMAIL" \
    -H "X-Auth-Key: $AUTH_KEY" \
    -H "Content-Type: application/json")

  SUCCESS=$(echo "$DELETE_RESPONSE" | jq -r '.success')
  if [ "$SUCCESS" == "true" ]; then
    echo "Rule successfully deleted."
    bash /etc/fail2ban/action.d/telegram_notif.sh -u "$TARGET_IP"
  else
    bash /etc/fail2ban/action.d/telegram_notif.sh -r "Failed to unban $TARGET_IP. Response: $DELETE_RESPONSE"
  fi