ARG BUILD_FROM=ghcr.io/usetrmnl/larapaper:0.40.0
FROM ${BUILD_FROM}

# The upstream image runs unprivileged (www-data), but the add-on's entrypoint
# hook must take ownership of the Supervisor-mounted /data volume (root:root)
# before Laravel touches it. serversideup-php based images support a root
# start — PHP-FPM workers still drop to www-data via the pool config.
USER root

# serversideup-php entrypoint hook: runs on every container start, in
# alphabetical order, BEFORE 50-laravel-automations.sh (migrations + config
# cache) — so everything the hook writes to .env is picked up each boot.
COPY rootfs/etc/entrypoint.d/10-calendhd-paper.sh /etc/entrypoint.d/10-calendhd-paper.sh
RUN chmod +x /etc/entrypoint.d/10-calendhd-paper.sh
