## Step 1: Prepare Your Server

1. **Choose a server**: Use a dedicated VPS or physical machine.  
2. **Operating system**: Linux distributions like Ubuntu, Debian, or CentOS are commonly used.  
3. **Domain name**: Ensure you own a domain name (e.g., `yourdomain.com`) and have DNS control.  
4. **Update your server**:  

    ```bash
    apt update && apt upgrade -y
    ```

## Step 2: Set Up DNS Records

Configure DNS records for your domain:

- **A Record**: Points your domain to your server's IP address.
     - `mail.yourdomain.com` → `[Your Server IP]`
- **MX Record**: Directs emails to your mail server.
     - `yourdomain.com` → `mail.yourdomain.com` (Priority: 10)
- **PTR Record**: Set up reverse DNS with your hosting provider (PTR record should match `mail.yourdomain.com`).
- **SPF Record**: Helps prevent email spoofing.
     - `v=spf1 mx ~all`
- **DKIM Record**: For email authenticity.
- **DMARC Record**: To specify your domain’s email policy.

### Step 1: Set Up DKIM

1. Install DKIM Tools:

     On Debian/Ubuntu:

     ```bash
     sudo apt install opendkim opendkim-tools
     ```

2. Generate DKIM Keys:

     ```bash
     mkdir -p /etc/opendkim/keys
     cd /etc/opendkim/keys
     opendkim-genkey -s mail -d yourdomain.com
     ```

     - `-s mail`: The selector name (used in DNS records).
     - `-d yourdomain.com`: Your domain name.

     This will generate two files:

     - `mail.private`: Private key for signing emails.
     - `mail.txt`: Public key to be published in your DNS.