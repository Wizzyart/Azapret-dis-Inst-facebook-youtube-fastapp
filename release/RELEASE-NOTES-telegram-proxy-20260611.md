# Azapret Public: Local Telegram Proxy

Portable Windows build for Discord, YouTube, Telegram, Instagram, Facebook, FACEIT / CS2 and other domains from the included lists.

## What is new

- Added a built-in local Telegram MTProto proxy based on `tg-ws-proxy`.
- The Telegram button now starts a local proxy on `127.0.0.1` and opens Telegram with the correct proxy link.
- Added Windows autostart for the local Telegram proxy.
- Added a dedicated startup wrapper that writes the proxy config as UTF-8 without BOM, so the proxy secret stays stable after reboot.
- Added fallback local ports: `1443`, `2443`, `3443`, `8443`, `9443`, `10443`.
- Added `Stop TG proxy` to stop the local proxy and remove its autostart.
- Added Telegram WebSocket domains to the general list.

## Included downloads

- `AzapretApp-Public.zip` - main Public build.
- `Azapret-PublicCSGO2.zip` - Public build with CSGO2 / FACEIT TTL profiles.
- `AzapretApp-Public-CSGO2-FACEIT-TTL.zip` - alias of the CSGO2 / FACEIT TTL build.

## How to use Telegram proxy

1. Extract the archive.
2. Run `Azapret.exe`.
3. Open the Telegram tab.
4. Click `Прокси для TG` / `Fix TG App`.
5. Confirm the proxy in Telegram Desktop.

After that, the local Telegram proxy will start automatically with Windows.

If Telegram has old `127.0.0.1:1443` proxy entries, remove them and add the new one from Azapret.

## Verification

The release build was checked for:

- PowerShell syntax.
- bundled `TgWsProxy_windows.exe` presence.
- stable Telegram proxy secret after cold-start simulation.
- Windows Run autostart entry.
- local listener on `127.0.0.1:1443`.
- real Telegram connection through `kws*.web.telegram.org`.

## Third-party notice

The local Telegram proxy uses `Flowseal/tg-ws-proxy` under the MIT license. The notice is included in `app/docs/TG-WS-PROXY-NOTICE.md`.
