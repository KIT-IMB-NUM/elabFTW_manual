#!/usr/bin/env bash
set -euo pipefail

# ========================= CONFIG (EDIT ME) =========================
APP_CTR="elabftw"
DB_CTR="mysql"
STACK_DIR="${STACK_DIR:-$HOME/elabftw-stack}"
HOST_ELAB_DIR="/var/elabftw"                 # bind mount root for app + mysql datadir
HOST_ELAB_CFG="/etc/elabftw.yml"             # bind-mounted config file path
HOST_BACKUP_DIR="/var/elabftw/backup"        # where we'll place the tarball

# Your existing backups:
TARBALL="01_13052025_elabftw-backup.tar.gz"  # file currently in ~/Downloads
SRC_TARBALL="$HOME/Downloads/$TARBALL"
MYSQL_DUMP_GZ="/var/backups/elabftw/mysql_dump-2025-10-04_19-58-50.sql.gz"

# App DB user creds (only used for optional smtp_password blanking)
APP_DB_USER="elabftw"
APP_DB_PASS="qSwqo5YYCNa14AtD53mQ7fT5mqkeJe2"

# Published HTTPS port for the app (host:container)
PUBLISHED_PORT="8080"

# ===================================================================

say(){ printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
die(){ printf "\n\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }
have(){ command -v "$1" >/dev/null 2>&1; }

require_file(){ [ -f "$1" ] || die "Missing required file: $1"; }

alpine_host() {
  # Run a short-lived root Alpine with host paths mounted under /host
  docker run --rm -u 0:0 -v /:/host alpine:3.20 sh -ceu "$1"
}

alpine_mounts() {
  docker run --rm -u 0:0 \
    -v "$HOST_ELAB_DIR":/mnt/elabftw \
    -v "$HOST_ELAB_CFG":/mnt/elabftw.yml \
    -v /:/host \
    alpine:3.20 sh -ceu "$1"
}

install_docker_if_needed() {
  if have docker && docker --version >/dev/null 2>&1; then
    say "Docker already present"
  else
    if have apt-get; then
      say "Installing Docker Engine (Debian/Ubuntu)"
      apt-get update -y
      apt-get install -y ca-certificates curl gnupg lsb-release
      install -d -m 0755 /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      chmod a+r /etc/apt/keyrings/docker.gpg
      echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
$(. /etc/os-release; echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list
      apt-get update -y
      apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      systemctl enable --now docker
    else
      die "Docker not found and automatic install only supports Debian/Ubuntu. Please install Docker + Compose manually and re-run."
    fi
  fi

  if docker compose version >/dev/null 2>&1; then
    say "Docker Compose plugin is available"
  else
    die "Docker Compose plugin missing. Install 'docker-compose-plugin' and re-run."
  fi
}

create_compose_stack() {
  say "Preparing stack directory at $STACK_DIR"
  mkdir -p "$STACK_DIR"
  cat > "$STACK_DIR/docker-compose.yml" <<'YAML'
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: change-me-root
    command: ["--default-authentication-plugin=mysql_native_password"]
    volumes:
      - /var/elabftw/mysql:/var/lib/mysql
    networks: [elabnet]

  elabftw:
    image: elabftw/elabftw:latest
    container_name: elabftw
    restart: unless-stopped
    depends_on: [mysql]
    volumes:
      - /var/elabftw/web:/var/elabftw/web
      - /etc/elabftw.yml:/etc/elabftw.yml
    ports:
      - "8080:443"
    networks: [elabnet]

networks:
  elabnet:
    driver: bridge
YAML

  # Patch the published port if user changed PUBLISHED_PORT
  if [ "$PUBLISHED_PORT" != "8080" ]; then
    sed -i "s/\"8080:443\"/\"$PUBLISHED_PORT:443\"/" "$STACK_DIR/docker-compose.yml"
  fi

  say "Ensuring host paths exist"
  mkdir -p "/var/backups/elabftw"
  mkdir -p "$HOST_ELAB_DIR"
  touch "$HOST_ELAB_CFG" || true

  say "Pulling images and starting empty stack once"
  (cd "$STACK_DIR" && docker compose up -d)
}

copy_tarball_to_backup() {
  say "Verifying backups exist"
  require_file "$SRC_TARBALL"
  require_file "$MYSQL_DUMP_GZ"

  say "Creating backup dir on host and copying tarball into it"
  alpine_host "mkdir -p /host$HOST_BACKUP_DIR"
  # Use a temp helper container to docker cp the tarball
  local cid
  cid=$(docker create -v "$HOST_BACKUP_DIR":/dest alpine:3.20 sh -c 'sleep 60')
  docker cp "$SRC_TARBALL" "$cid":/dest/
  docker rm -f "$cid" >/dev/null
}

restore_files_and_perms() {
  say "Extracting backup tarball to host /"
  alpine_host "tar -xvzf /host$HOST_BACKUP_DIR/$TARBALL -C /host/"

  say "Fixing ownership and config permissions"
  alpine_host "chown -R 101:101 /host$HOST_ELAB_DIR/web || true"
  alpine_host "chmod 600 /host$HOST_ELAB_CFG || true"
}

reset_mysql_datadir() {
  say "Stopping containers"
  docker stop "$APP_CTR" "$DB_CTR" >/dev/null 2>&1 || true

  say "Rotating and recreating MySQL datadir at $HOST_ELAB_DIR/mysql"
  local ts; ts=$(date +%s)
  alpine_host "
    if [ -d /host$HOST_ELAB_DIR/mysql ]; then
      mv /host$HOST_ELAB_DIR/mysql /host$HOST_ELAB_DIR/mysql.broken.$ts || true
    fi
    mkdir -p /host$HOST_ELAB_DIR/mysql
    chown -R 999:999 /host$HOST_ELAB_DIR/mysql
  "

  say "Starting DB then app"
  (cd "$STACK_DIR" && docker compose up -d mysql)
  sleep 6
  (cd "$STACK_DIR" && docker compose up -d elabftw)
}

restore_database() {
  say "Decompressing SQL dump and copying it into mysql container"
  gunzip -c "$MYSQL_DUMP_GZ" > /tmp/elab_dump.sql
  docker cp /tmp/elab_dump.sql "$DB_CTR":/elab_dump.sql
  rm -f /tmp/elab_dump.sql

  say "Using MYSQL_ROOT_PASSWORD from container env to recreate and load DB"
  docker exec -i "$DB_CTR" bash -lc 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" \
    -e "DROP DATABASE IF EXISTS elabftw; \
        CREATE DATABASE elabftw CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci; \
        USE elabftw; SET NAMES utf8mb4; SOURCE /elab_dump.sql;"'
}

post_restore_steps() {
  say "Re-apply ownership on web directory"
  alpine_host "chown -R 101:101 /host$HOST_ELAB_DIR/web || true"

  say "Optional: Blank SMTP password (safe if missing)"
  docker exec -i "$DB_CTR" mysql -u"$APP_DB_USER" -p"$APP_DB_PASS" \
    -e "UPDATE elabftw.config SET conf_value='' WHERE conf_name='smtp_password';" || true

  say "Run schema updater inside app container"
  docker exec -it "$APP_CTR" bin/console db:update || true
}

final_info() {
  say "Done."
  cat <<EOF

Access eLabFTW at: https://$(hostname -I | awk '{print $1}'):${PUBLISHED_PORT}/

Useful commands:
  docker compose -f "$STACK_DIR/docker-compose.yml" logs -f elabftw
  docker compose -f "$STACK_DIR/docker-compose.yml" logs -f mysql
  docker ps

Backups used:
  - App/files tarball: $HOST_BACKUP_DIR/$TARBALL
  - MySQL dump:       $MYSQL_DUMP_GZ
EOF
}

# =========================== MAIN ===========================
install_docker_if_needed
create_compose_stack
copy_tarball_to_backup
restore_files_and_perms
reset_mysql_datadir
restore_database
post_restore_steps
final_info
