#!/bin/bash
# ============================================
# Script: create_users.sh
# Purpose: Automate user creation and setup
# ============================================

INPUT_FILE="$1"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root (use: sudo ./create_users.sh users.txt)"
  exit 1
fi

# Create required directories
mkdir -p /var/secure
touch "$LOG_FILE" "$PASSWORD_FILE"
chmod 600 "$LOG_FILE" "$PASSWORD_FILE"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "❌ Input file not found: $INPUT_FILE"
  exit 1
fi

while IFS= read -r line; do
  # Skip comments and empty lines
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  username=$(echo "$line" | cut -d';' -f1 | xargs)
  groups=$(echo "$line" | cut -d';' -f2 | xargs | tr ',' ' ')

  # Create groups if needed
  for g in $groups; do
    if ! getent group "$g" >/dev/null; then
      groupadd "$g"
      log "Created group: $g"
    fi
  done

  if id "$username" &>/dev/null; then
    log "User $username already exists. Skipping."
    continue
  fi

  useradd -m -s /bin/bash -G "$(echo "$groups" | tr ' ' ',')" "$username"
  if [[ $? -ne 0 ]]; then
    log "❌ Failed to create user: $username"
    continue
  fi

  password=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)
  echo "$username:$password" | chpasswd
  echo "$username:$password" >> "$PASSWORD_FILE"

  chmod 700 "/home/$username"
  chown "$username:$username" "/home/$username"

  log "✅ Created user: $username | Groups: $groups"
  echo "User $username created successfully."
done < "$INPUT_FILE"

echo "✅ All users processed. Check $LOG_FILE for details."
while IFS= read -r line; do
  # Skip empty lines or comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  username=$(echo "$line" | cut -d';' -f1 | xargs)
  groups=$(echo "$line" | cut -d';' -f2 | xargs | tr ',' ' ')

  # Create missing groups
  for g in $groups; do
    if ! getent group "$g" >/dev/null; then
      groupadd "$g"
      log "Created group: $g"
    fi
  done

  # Skip existing users
  if id "$username" &>/dev/null; then
    log "User $username already exists. Skipping."
    continue
  fi

  # Create user with home directory and groups
  useradd -m -s /bin/bash -G "$(echo "$groups" | tr ' ' ',')" "$username"
  if [[ $? -ne 0 ]]; then
    log "❌ Failed to create user: $username"
    continue
  fi

  # Generate and assign random password
  password=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)
  echo "$username:$password" | chpasswd
  echo "$username:$password" >> "$PASSWORD_FILE"

  # Set home directory permissions
  chmod 700 "/home/$username"
  chown "$username:$username" "/home/$username"

  log "✅ Created user: $username | Groups: $groups"
  echo "User $username created successfully."
done < "$INPUT_FILE"

echo "✅ All users processed. Check $LOG_FILE for details."
