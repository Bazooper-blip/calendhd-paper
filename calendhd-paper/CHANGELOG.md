# Changelog

## 1.2.0

- Update larapaper to 0.41.0 ([release notes](https://github.com/usetrmnl/larapaper/releases/tag/0.41.0)).

## 1.1.0

- Update larapaper to 0.40.0 ([release notes](https://github.com/usetrmnl/larapaper/releases/tag/0.40.0)).

## 1.0.0

- Initial release: [larapaper](https://github.com/usetrmnl/larapaper) **0.39.0** packaged as a Home Assistant add-on (`amd64` + `aarch64`, tracking the upstream image's published architectures).
- SQLite database, generated screen images, and the Laravel `APP_KEY` persist in `/data` — they survive add-on updates and ride along in Home Assistant backups. Paths mirror the upstream `docker/prod/docker-compose.yml` volumes.
- Add-on options: `app_url` (device-reachable base URL, used to build screen-image links) and `registration_enabled` (leave on for first-run account creation, then turn off). Home Assistant's timezone is applied automatically via the Supervisor's `TZ`.
- Web UI + TRMNL device API on host port **4567** (container 8080), matching the upstream compose convention.
- Written to pair with the calenDHD add-on's read-only TRMNL feed (`/api/calendhd/trmnl`) over the LAN — fully local e-ink dashboard, nothing exposed to the internet. See DOCS for the pairing walkthrough.
