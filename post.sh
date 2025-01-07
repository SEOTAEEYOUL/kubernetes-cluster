#!/bin/bash
set -e

# Clean up apt cache
apt-get clean
apt-get autoremove -y


# Remove old kernels
old_kernels=$(dpkg -l | grep -E 'linux-image-[0-9]+' | grep -v $(uname -r) | awk '{print $2}')
if [ ! -z "$old_kernels" ]; then
    apt-get purge -y $old_kernels
fi

# Remove temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clear systemd journal logs
journalctl --vacuum-time=1d

# Clear audit logs
[ -f /var/log/audit/audit.log ] && cat /dev/null > /var/log/audit/audit.log

# Clear system logs
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
find /var/log -type f -name "*.gz" -exec rm {} \;

# Clear bash history for all users
find /home -type f -name ".bash_history" -exec cat /dev/null > {} \;
find /root -type f -name ".bash_history" -exec cat /dev/null > {} \;

# # Clear command history and exit
# history -c && exit

# Clear bash history.
cat /dev/null > ~/.bash_history && history -c && exit