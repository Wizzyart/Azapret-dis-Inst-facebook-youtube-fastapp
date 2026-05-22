@echo off
chcp 65001 > nul
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    powershell.exe -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Stopping zapret/winws emergency...
taskkill /IM winws.exe /F >nul 2>&1
net stop zapret >nul 2>&1
net stop WinDivert >nul 2>&1
net stop WinDivert14 >nul 2>&1
ipconfig /flushdns
echo.
echo Done. If the network is still unavailable, disable/enable the network adapter or reboot Windows.
pause
