# calenDHD Paper — Home Assistant add-on repository

Run [larapaper](https://github.com/usetrmnl/larapaper), the self-hosted TRMNL BYOS server, as a native Home Assistant add-on — so a TRMNL e-ink device can render the [calenDHD](https://github.com/Bazooper-blip/calendhd) family calendar **fully on your LAN**: no TRMNL cloud polling, no reverse-proxy bypass rules, no feed tokens, nothing exposed to the internet.

[![Add repository to my Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FBazooper-blip%2Fcalendhd-paper)

Or manually: **Settings → Add-ons → Add-on Store → ⋮ → Repositories** → add `https://github.com/Bazooper-blip/calendhd-paper`.

```
TRMNL device ──HTTP──▶ calenDHD Paper add-on (:4567, larapaper)
                            │ polls over LAN
                            ▼
                       calenDHD add-on (:8090) /api/calendhd/trmnl
```

## Add-ons

| Add-on | Description |
|--------|-------------|
| [calenDHD Paper](calendhd-paper/) | larapaper 0.41.x BYOS server (`amd64`/`aarch64`); pairs with the calenDHD add-on's TRMNL feed, and works as a general TRMNL server (community recipes, screenshots, mashups, TRMNL OG + X) |

Setup walkthrough — including connecting the device (firmware 1.4.6+ "Custom Server") and adding the calenDHD dashboard recipe — is in the add-on's [DOCS.md](calendhd-paper/DOCS.md).

## Version tracking

The add-on pins an exact larapaper release for reproducible builds, and a scheduled workflow ([update-larapaper](.github/workflows/update-larapaper.yaml)) keeps the pin current automatically: it checks upstream releases daily, verifies the multi-arch image is on ghcr, test-builds the add-on for both architectures against the new base, then opens and merges the bump PR (new add-on version + changelog entry included). Home Assistant shows the resulting release as a normal add-on update.

## Related

- [calenDHD](https://github.com/Bazooper-blip/calendhd) — the calendar itself (also an add-on repository)
- [calenDHD TRMNL plugin](https://github.com/Bazooper-blip/calendhd/tree/main/trmnl-plugin) — the trmnlp-format recipe this add-on renders
- [larapaper](https://github.com/usetrmnl/larapaper) — the upstream BYOS server this add-on packages
