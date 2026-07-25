#!/bin/sh
# =============================================================================
# calenDHD Paper — Home Assistant add-on glue for larapaper.
#
# Runs via the serversideup-php entrypoint hook mechanism (/etc/entrypoint.d/,
# alphabetical order) before 50-laravel-automations.sh, which runs migrations
# and rebuilds the config cache — so everything written to .env here is live
# on every boot.
#
# Responsibilities:
#   1. Persist the SQLite database + generated screen images in /data (the
#      Supervisor-managed volume that survives add-on updates and is included
#      in Home Assistant backups).
#   2. Generate APP_KEY once and persist it — rotating it would invalidate
#      encrypted columns and sessions.
#   3. Map add-on options (/data/options.json) and the Supervisor-provided TZ
#      into Laravel's .env.
# =============================================================================
set -e

APP_DIR=/var/www/html

log() { echo "[calendhd-paper] $1"; }

# ---- 1. persistence ---------------------------------------------------------
# Replace an in-image directory with a symlink into /data, preserving whatever
# the image shipped there on first boot.
persist() {
    image_path="$1"
    data_path="$2"
    mkdir -p "$data_path"
    if [ ! -L "$image_path" ]; then
        if [ -d "$image_path" ]; then
            cp -a "$image_path/." "$data_path/" 2>/dev/null || true
            rm -rf "$image_path"
        fi
        mkdir -p "$(dirname "$image_path")"
        ln -s "$data_path" "$image_path"
        log "persisted $image_path -> $data_path"
    fi
}

# Paths match the upstream docker-compose volumes (docker/prod/docker-compose.yml).
persist "$APP_DIR/database/storage" /data/database
persist "$APP_DIR/storage/app/public/images/generated" /data/generated

# Laravel's migrate can be picky about a missing sqlite file in non-interactive
# runs; guarantee it exists. DB_DATABASE below matches the upstream compose.
[ -f /data/database/database.sqlite ] || touch /data/database/database.sqlite
chown -R www-data:www-data /data/database /data/generated

# ---- 2. app key -------------------------------------------------------------
if [ ! -s /data/app_key ]; then
    echo "base64:$(head -c 32 /dev/urandom | base64 | tr -d '\n')" > /data/app_key
    log "generated new APP_KEY"
fi
APP_KEY="$(cat /data/app_key)"

# ---- 3. add-on options -> .env ---------------------------------------------
# No bashio/jq in this image; PHP is guaranteed. Booleans map to 1/0, which is
# what larapaper's REGISTRATION_ENABLED expects.
opt() {
    php -r '$o = json_decode(file_get_contents("/data/options.json"), true) ?: [];
            $v = $o[$argv[1]] ?? "";
            echo is_bool($v) ? ($v ? "1" : "0") : $v;' "$1"
}

APP_URL="$(opt app_url)"
REGISTRATION_ENABLED="$(opt registration_enabled)"

set_env() {
    key="$1"
    value="$2"
    if grep -q "^${key}=" "$APP_DIR/.env"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$APP_DIR/.env"
    else
        echo "${key}=${value}" >> "$APP_DIR/.env"
    fi
}

set_env APP_KEY "$APP_KEY"
[ -n "$APP_URL" ] && set_env APP_URL "$APP_URL"
set_env APP_TIMEZONE "${TZ:-UTC}"
set_env REGISTRATION_ENABLED "${REGISTRATION_ENABLED:-1}"
set_env DB_DATABASE "database/storage/database.sqlite"
set_env APP_ENV "production"
set_env APP_DEBUG "false"

log "configured: APP_URL=${APP_URL:-<unset>} TZ=${TZ:-UTC} registration=${REGISTRATION_ENABLED:-1}"
