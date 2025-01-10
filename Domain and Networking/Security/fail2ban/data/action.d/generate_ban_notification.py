import sys
import requests

def get_ip_geolocation(ip_address):
    try:
        response = requests.get(f"https://ipinfo.io/{ip_address}/json")
        data = response.json()
        return {
            "location": data.get("city", "Unknown") + ", " + data.get("region", "Unknown"),
            "country": data.get("country", "Unknown"),
            "org": data.get("org", "Unknown")
        }
    except Exception:
        return {"location": "Unknown", "country": "Unknown", "org": "Unknown"}

def generate_ban_notification(ip, email, reason):
    ip_info = get_ip_geolocation(ip)
    location = ip_info["location"]
    country = ip_info["country"]
    org = ip_info["org"]

    return f"""
    🚨 **Security Alert: IP Address Banned** 🚨

    The IP address **{ip}** has been **banned** for {reason}.

    **Details:**
    - 🔐 **Service:** Vaultwarden
    - 🚫 **Action Taken:** IP banned

    📍 **IP Information:**
    - 🌐 **Location:** {location}, {country}
    - 🔗 **Associated Network:** {org}
    - ✉️ **Reported By:** {email if email else 'N/A'}
    """

if __name__ == "__main__":
    ip_address = sys.argv[1]
    email = sys.argv[2]
    reason = sys.argv[3]

    notification = generate_ban_notification(ip_address, email, reason)
    print(notification)
