@echo off
chcp 65001 > nul
echo This will close Chrome and Edge, then clear site cache for the configured package.
pause
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0clear-browser-site-cache.ps1"
pause
