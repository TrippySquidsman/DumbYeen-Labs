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

3. Configure OpenDKIM: Edit the main OpenDKIM configuration file:

    ```bash
    sudo nano /etc/opendkim.conf
    ```

    Add or update the following lines:

    ```plaintext
    AutoRestart             Yes
    AutoRestartRate         10/1h
    Syslog                  yes
    SyslogSuccess           yes
    LogWhy                  yes
    Canonicalization        relaxed/simple
    ExternalIgnoreList      /etc/opendkim/trusted.hosts
    InternalHosts           /etc/opendkim/trusted.hosts
    KeyTable                /etc/opendkim/key.table
    SigningTable            /etc/opendkim/signing.table
    Socket                  inet:12345@localhost
    RequireSafeKeys         false
    ```

4. Set Up Key Table:

    ```bash
    sudo nano /etc/opendkim/key.table
    ```

    Add:

    ```plaintext
    mail._domainkey.yourdomain.com yourdomain.com:mail:/etc/opendkim/keys/mail.private
    ```

5. Set Up Signing Table:

    ```bash
    sudo nano /etc/opendkim/signing.table
    ```

    Add:

    ```plaintext
    *@yourdomain.com mail._domainkey.yourdomain.com
    ```

6. Set Up Trusted Hosts:

    ```bash
    sudo nano /etc/opendkim/trusted.hosts
    ```

    Add:

    ```plaintext
    127.0.0.1
    ::1
    yourdomain.com
    ```

7. Restart OpenDKIM:

    ```bash
    sudo systemctl restart opendkim
    sudo systemctl enable opendkim
    ```

8. Add DKIM Record to DNS: Open the mail.txt file generated earlier and copy the contents. You’ll see something like:

    ```plaintext
    mail._domainkey IN TXT "v=DKIM1; k=rsa; p=MIIBIjANBgkqh..."
    ```

    Add this as a DNS TXT record:
    - Name: `mail._domainkey.yourdomain.com`
    - Type: `TXT`
    - Value: The content after `IN TXT`

### Step 2: Set Up DMARC

Add a DNS TXT record for DMARC:
- Name: `_dmarc.yourdomain.com`
- Type: `TXT`
- Value:

    ```plaintext
    v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@yourdomain.com; ruf=mailto:dmarc-failure@yourdomain.com; pct=100; adkim=r; aspf=r
    ```

Explanation:

- `p=quarantine`: Instructs the receiving servers to quarantine emails that fail DMARC.
- `rua`: Email address to receive aggregate reports.
- `ruf`: Email address to receive forensic (failure) reports.
- `pct=100`: Applies DMARC policy to 100% of emails.
- `adkim=r`: DKIM alignment mode (r for relaxed, s for strict).
- `aspf=r`: SPF alignment mode (r for relaxed, s for strict).

### Step 3: Test Your Configuration

- Send a test email to an external address and check if DKIM is correctly signed.
- Use online tools like:
    - Mail Tester
    - MXToolbox DKIM
    - Google's DMARC Report Tool

### Step 4: Install and Configure Mail Server Software

Popular mail server software includes:

- **Postfix**: For sending emails.

    ```bash
    sudo apt install postfix
    ```

    Configure Postfix with your domain and hostname.

- **Dovecot**: For IMAP and POP3 services.

    ```bash
    sudo apt install dovecot-core dovecot-imapd
    ```

### Step 5: Install SSL/TLS Certificates

Use Let's Encrypt to secure email transmission.

```bash
sudo apt install certbot
sudo certbot certonly --standalone -d mail.yourdomain.com
```

Configure Postfix and Dovecot to use SSL.

### Step 6: Set Up Webmail (Optional)

Install a webmail client like Rainloop or Roundcube for browser-based access.

### Step 7: Testing

Use tools like Mail Tester or MXToolbox to check DNS, SPF, DKIM, and DMARC configurations.
Send test emails to ensure proper sending and receiving.