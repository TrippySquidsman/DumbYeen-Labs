#!/bin/bash
# Version 1.0
# Send Fail2ban notifications using a Telegram Bot
import requests

IP="$1"
# Telegram BOT Token 
telegramBotToken='............'
# Telegram Chat ID
telegramChatID='............'


def get_ip_geolocation(ip_address):
    try:
        # Fetch geolocation info from a public API (use your preferred service)
        response = requests.get(f"https://ipinfo.io/{IP}/json")
        data = response.json()
        return {
            "location": data.get("city", "Unknown") + ", " + data.get("region", "Unknown"),
            "country": data.get("country", "Unknown"),
            "org": data.get("org", "Unknown"),
        }
    except Exception as e:
        return {"location": "Unknown", "country": "Unknown", "org": "Unknown"}

def generate_notification(IP, email, ban_count):
    ip_info = get_ip_geolocation(IP)
    location = ip_info["location"]
    country = ip_info["country"]
    org = ip_info["org"]

    return f"""
    🚨 **Security Alert: IP Address Banned** 🚨  

    The IP address **${ip_add_ban}** has been **banned** for ${reason}.  

    **Details:**  
    - 🔐 **Service:** Vaultwarden  
    - 🚫 **Action Taken:** IP banned  
    - 🔄 **Ban Count:** {ban_count}  

    📍 **IP Information:**  
    - 🌐 **Location:** {location}, {country}  
    - 🔗 **Associated Network:** {org}   
    """


function talkToBot() {
    message=$1
    curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d text="${message}" -d chat_id=${telegramChatID} > /dev/null 2>&1
}
if [ $# -eq 0 ]; then
    echo "Usage $0 -a ( start || stop ) || -b $IP || -u $IP || -r $REASON"
    exit 1;
fi
while getopts "a:b:u:r:" opt; do
    case "$opt" in
        a)
            action=$OPTARG
        ;;
        b)
            ban=y
            ip_add_ban=$OPTARG
        ;;
        e)
            email=$OPTARG
        ;;
        u)
            unban=y
            ip_add_unban=$OPTARG
        ;;
        r)
            reason=$OPTARG
        ;;
        ?) 
            echo "Invalid option. -$OPTARG"
            exit 1
        ;;
    esac
done
if [[ ! -z ${action} ]]; then
    case "${action}" in
        start)
            talkToBot "Fail2ban has just started"
        ;;
        stop)
            talkToBot "Fail2ban has just stopped"
        ;;
        *)
            echo "Incorrect option"
            exit 1;
        ;;
    esac
elif [[ ${ban} == "y" ]]; then
    talkToBot (generate_notification(ip_add_ban, email, ban_count))
    exit 0;
elif [[ ${unban} == "y" ]]; then
    talkToBot "The IP: ${ip_add_unban} has been unbanned."
    exit 0;
else
    info
fi
