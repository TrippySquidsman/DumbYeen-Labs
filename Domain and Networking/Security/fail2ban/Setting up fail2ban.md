To configure Fail2ban for general safety, you can enable protections for commonly targeted services like SSH, web servers, and authentication systems. Below is a guide tailored for improving overall server security.
1. Install Fail2ban

First, ensure Fail2ban is installed:

    apt update
    apt install fail2ban -y

2. Backup and Edit Configuration

Copy the default configuration and edit the local version:

    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    nano /etc/fail2ban/jail.local

3. Configure Global Defaults

In the [DEFAULT] section, set up global security options:

Whitelist trusted IPs (optional): Add your local or trusted IPs to avoid locking yourself out:

    ignoreip = 127.0.0.1/8 ::1 <YOUR_TRUSTED_IP>

Ban time for attackers: Use a reasonable ban time (e.g., 15 minutes, 1 hour, or permanent):

    bantime = 1h

Time window to detect attacks: Look for repeated failures within this period:

    findtime = 10m

Number of retries before banning: Set how many failures trigger a ban:

    maxretry = 5

4. Enable Common Jails

Scroll down in jail.local and configure the following commonly used jails.
4.1 SSH (Critical for Remote Access)

Protect the SSH service from brute-force attacks:

    [sshd]
    enabled = true
    port = ssh
    filter = sshd
    logpath = /var/log/auth.log
    maxretry = 5

4.2 Fail2ban Logins

Enable bans for failed authentication attempts (e.g., PAM authentication):

    [recidive]
    enabled = true
    logpath = /var/log/fail2ban.log
    bantime = 1d
    findtime = 1h
    maxretry = 5

5. Restart Fail2ban

Save changes to jail.local and restart Fail2ban:

    systemctl restart fail2ban
    systemctl enable fail2ban

6. Monitor and Manage Fail2ban

Check running jails:

    fail2ban-client status

View specific jail info:

    fail2ban-client status sshd

Unban an IP (if needed):

    sudo fail2ban-client unban <IP>

8. Test Your Configuration

Simulate failed login attempts for SSH or other services to ensure the bans work:

    ssh wronguser@yourserver

Then check if Fail2ban bans the IP:

    fail2ban-client status sshd

This setup provides basic general safety by covering key services (SSH, web servers, and FTP). For enhanced security, consider configuring Fail2ban for any additional services you use.
