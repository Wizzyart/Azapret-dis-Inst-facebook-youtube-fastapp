@echo off
chcp 65001 > nul
set "ROOT=%~dp0..\"
set "SCRIPT=%~dp0test-faceit-cs2-profiles.ps1"

echo FACEIT/CS2 TTL profile test
echo.
echo Optional: enter CS/FACEIT server as IP:PORT or host:PORT.
echo Example: 1.2.3.4:27015
echo Leave empty to test only Discord/YouTube and DNS.
echo.
set /p "CSSERVER=CS server: "

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -CsServer "%CSSERVER%" -KillExistingWinws

echo.
echo Test finished. Check app\test-results\faceit-cs2-ttl-test-*.txt
pause
