import requests

# Proxmox API details
base_url = "https://10.0.0.1:8006/api2/json"
username = "root@pam"
password = "byHhHNIg072qh&hM@r4kT8O0"

# Get a ticket (login)
response = requests.post(f"{base_url}/access/ticket", data={
    "username": username,
    "password": password
}, verify=False)  # Disable SSL verification for simplicity

response_data = response.json()
ticket = response_data["data"]["ticket"]
csrf_token = response_data["data"]["CSRFPreventionToken"]

# Fetch container details
headers = {"CSRFPreventionToken": csrf_token}
cookies = {"PVEAuthCookie": ticket}
# Fetch container details for host01 to host05
hosts = ["host01", "host02", "host03", "host04", "host05"]
container_data = {}

for host in hosts:
    containers = requests.get(f"{base_url}/nodes/{host}/lxc", headers=headers, cookies=cookies, verify=False).json()
    for container in containers["data"]:
        container_data[container["name"]] = container["vmid"]

# Print container names and IDs
for container_name, container_id in container_data.items():
    print(f"Container name: {container_name}, ID: {container_id}")