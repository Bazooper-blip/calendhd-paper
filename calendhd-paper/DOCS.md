# calenDHD Paper

Runs [larapaper](https://github.com/usetrmnl/larapaper) — the most popular self-hosted TRMNL BYOS server — as a Home Assistant add-on, so your TRMNL e-ink device renders the [calenDHD](https://github.com/Bazooper-blip/calendhd) dashboard **fully on your LAN**. No TRMNL cloud polling, no Cloudflare bypass rules, no feed token, nothing exposed to the internet: larapaper polls the calenDHD feed at its LAN address, renders the screen, and your device fetches the bitmap from Home Assistant.

```
TRMNL device ──HTTP──▶ calenDHD Paper (this add-on, :4567)
                            │ polls
                            ▼
                       calenDHD add-on (:8090) /api/calendhd/trmnl
```

larapaper is a general-purpose TRMNL server — it also supports the community recipe catalog (150+ recipes), screenshots, image webhooks, and mashups, and it supports both the original TRMNL and the TRMNL X. calenDHD is just the recipe this add-on was packaged for.

## Requirements

- A TRMNL device (original or X) with firmware **1.4.6+** (older firmware needs a reflash — see larapaper's README).
- For the calenDHD dashboard: the **calenDHD add-on ≥ 1.7.3** running on this Home Assistant instance.
- Architectures: `amd64` and `aarch64`. There is **no `armv7` build** (the upstream larapaper image doesn't publish one), so 32-bit hosts like the Pi 3 in 32-bit mode are not supported.

## First start

1. Install the add-on and open its **Configuration** tab:
   - **Application URL**: set to `http://<your-HA-IP>:4567` (e.g. `http://192.168.1.50:4567`). Prefer the IP over `homeassistant.local` — TRMNL firmware may not resolve mDNS names, and generated screen-image URLs are built from this value. A wrong value shows up as blank/broken screens on the device.
   - Leave **Allow account registration** on for now.
2. Start the add-on and open the Web UI (port 4567). Register your account.
3. Back in Configuration, turn **Allow account registration** off and restart the add-on, so nobody else on your network can create accounts.

The SQLite database, generated screen images, and the app's encryption key persist in the add-on's `/data` volume — they survive updates and are included in Home Assistant backups.

## Connect your TRMNL device

1. In the larapaper web UI, enable device auto-join (Devices page → *Permit Auto-Join*).
2. Factory-reset / set up your TRMNL: during Wi-Fi setup, choose **Custom Server** and enter `http://<your-HA-IP>:4567`.
3. The device appears on the Devices page. (You can also add it manually with its MAC address and API key.)

## Add the calenDHD dashboard

The calenDHD screen is a **trmnlp-format recipe** — `settings.yml` plus Liquid templates for all four layouts — maintained in the calenDHD repo under [`trmnl-plugin/`](https://github.com/Bazooper-blip/calendhd/tree/main/trmnl-plugin). Two ways to get it in, depending on your larapaper version (the UI evolves; see [larapaper's README](https://github.com/usetrmnl/larapaper#readme) for current wording):

**A. As a recipe.** In the web UI, add a custom recipe pointing at the calenDHD recipe files, and set its *calenDHD URL* field to the add-on's LAN address:

- calenDHD URL: `http://<your-HA-IP>:8090`
- Feed token: leave empty (LAN traffic never leaves your network; the feed doesn't need a token here)
- Events per day: leave empty, or set e.g. `20` on a TRMNL X (it fits more agenda rows)

**B. As a manual plugin.** Create a polling plugin/markup screen with:

- Polling URL: `http://<your-HA-IP>:8090/api/calendhd/trmnl?days=5` (append `&limit=20` on a TRMNL X)
- Markup: paste the Liquid templates from `trmnl-plugin/src/` (`full.liquid`, plus the half/quadrant variants if you use playlists/mashups)

Then assign the plugin to the device's playlist. Screens refresh on larapaper's schedule; times and labels follow your household's language (English/Swedish) and 12/24-hour settings automatically, and the templates adapt to the TRMNL X (taller agenda lists, portrait mounting, real grayscale).

## Options

| Option | Default | Notes |
|--------|---------|-------|
| `app_url` | `http://homeassistant.local:4567` | Base URL devices/browsers use. Set to your HA IP. |
| `registration_enabled` | `true` | Turn off after creating your account. |

The Supervisor passes Home Assistant's timezone into the container automatically; screens render in your local time.

## Troubleshooting

- **Device shows a blank or broken screen** → `app_url` is wrong. It must be reachable *from the device*, so use the LAN IP, not `localhost` or an mDNS name.
- **Locked out / need another account** → temporarily set `registration_enabled: true`, restart, register, turn it off again.
- **calenDHD screen is empty** → check the polling URL from another LAN machine: `curl http://<HA-IP>:8090/api/calendhd/trmnl?days=5` should return JSON. If the calenDHD add-on has a *TRMNL feed token* set, either clear it (recommended on LAN) or configure the same token in the recipe/plugin.
- **Add-on logs** show the `[calendhd-paper]` init lines (persistence, APP_URL, timezone) followed by larapaper's own startup (migrations run automatically on each boot).

## Updating

Add-on updates pin specific larapaper releases (see the Changelog). Your data lives in `/data` and carries over. To force-regenerate the app key (invalidates sessions): stop the add-on, delete `app_key` from the add-on's data via the Samba/SSH add-ons (`/addon_configs/…` → `/data` is not directly reachable; easiest is `docker exec` or simply uninstall/reinstall if you don't mind re-pairing), then start again — for normal use you never need to touch it.
