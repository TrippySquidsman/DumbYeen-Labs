import requests

# NGINX Proxy Manager Credentials
base_url = "http://100.100.130.30:81"  # Replace with your NPM URL
username = "admin@tomis.online"
password = "S8c#UTpV^dNiPwBgty!XB*"

domain_name = input("Enter the subdomain name: ") + ".tomis.online"
forward_host = input("Enter the internal host IP: ")
forward_port = int(input("Enter the internal host port: "))

# Login to get token
login_url = f"{base_url}/api/tokens"
login_data = {"identity": username, "secret": password}

response = requests.post(login_url, json=login_data)
if response.status_code == 200:
    token = response.json()["token"]
    print("Login successful. Token acquired.")
else:
    print("Login failed:", response.text)
    exit()

# Create a new proxy host
proxy_url = f"{base_url}/api/nginx/proxy-hosts"
headers = {"Authorization": f"Bearer {token}"}

proxy_data = {
    "domain_names": [domain_name],  # List of domain names
    "forward_scheme": "http",       # HTTP or HTTPS for the upstream service
    "forward_host": forward_host,   # IP or hostname of the upstream service
    "forward_port": forward_port,   # Port of the upstream service
    "access_list_id": None,         # Optional, leave as None if no access list is used
    "certificate_id": 1,  # ID of the SSL certificate to use
    "ssl_forced": True,             # Enforce HTTPS if set to True
    "meta": {
        "letsencrypt_agree": False  # Use False for custom SSL certificates
    },
    "allow_websocket_upgrade": True,  # True if WebSocket is needed
    "block_exploits": True,          # True to block common exploits
    "http2_support": True,            # True to enable HTTP/2
    "hsts_enabled": True,            # True to enable HTTP Strict Transport Security
}

response = requests.post(proxy_url, headers=headers, json=proxy_data)
if response.status_code == 201:
    proxy_host = response.json()
    print("Proxy host created successfully:")
    print(f"{'Key':<20} {'Value'}")
    print("-" * 40)
    for key, value in proxy_host.items():
        print(f"{key:<20} {value}")
else:
    print("Failed to create proxy host:", response.text)

input("Press Enter to continue...")