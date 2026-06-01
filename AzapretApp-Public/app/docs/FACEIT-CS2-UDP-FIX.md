# FACEIT / CS2 UDP Fix

Source: https://github.com/reateroff/zapret-game-udp-fix

This Public profile adds a dedicated UDP desync rule for FACEIT and CS2 servers, especially EU providers like OVH and Hetzner.

Profile files:

`app\bypasses\general (FACEIT CS2 UDP Fix).bat`

TTL test variants:

- `app\bypasses\general (FACEIT CS2 TTL3).bat`
- `app\bypasses\general (FACEIT CS2 TTL4).bat`
- `app\bypasses\general (FACEIT CS2 TTL5).bat`
- `app\bypasses\general (FACEIT CS2 TTL6).bat`
- `app\bypasses\general (FACEIT CS2 TTL7).bat`

Key rule:

```bat
--filter-udp=1024-65535 --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-ttl=5 --dpi-desync-fake-unknown-udp="%BIN%stun.bin"
```

Notes:

- `--dpi-desync-ttl=5` is provider-dependent.
- If FACEIT/CS2 still fails, test TTL values like 3, 4, 6, 7.
- The profile is separate from regular Public profiles to avoid changing stable defaults.
- Use this profile only when FACEIT/CS2 UDP servers fail with regular profiles.

Launcher workflow:

1. Keep your normal Discord/YouTube bypass in autostart, for example `ALT11`.
2. Open `Сервисные действия`.
3. Click `CS/Faceit check`.
4. Enter the CS/FACEIT server as `IP:PORT`, for example `217.168.247.79:27345`.
5. Click `Проверить IP по всем TTL`.
6. Read the recommendation in the popup/journal.
7. Select the recommended `FACEIT CS2 TTLx` profile.
8. Click `Запустить выбранный TTL`.
9. After the match, click `Стоп TTL` or `Стоп FACEIT TTL`.

The FACEIT/CS2 TTL process runs together with the normal autostart bypass. It does not rewrite the Windows service autostart profile.

CLI helper:

Run `app\tools\test-cs-ttl-auto.ps1 -CsServer IP:PORT` as Administrator if you need a console-only TTL check.

Notes:

- UDP game servers often do not reply to simple UDP probes, so `CS UDP probe: SENT` is only a send test, not proof that the server accepted gameplay traffic.
- Use an actual FACEIT/CS2 France server IP for meaningful results.
- The selected TTL must still be confirmed in-game by checking connect, ping, and packet loss.
