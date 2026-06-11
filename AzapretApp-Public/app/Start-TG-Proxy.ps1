$ErrorActionPreference = 'SilentlyContinue'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$SettingsFile = Join-Path $Root 'app-settings.json'
$ProxyExe = Join-Path $Root 'tools\tg-ws-proxy\TgWsProxy_windows.exe'
$ProxyAppDir = Join-Path $env:APPDATA 'TgWsProxy'
$ProxyConfig = Join-Path $ProxyAppDir 'config.json'

if (-not (Test-Path -LiteralPath $ProxyExe)) { exit 1 }
if (-not (Test-Path -LiteralPath $ProxyAppDir)) { New-Item -ItemType Directory -Path $ProxyAppDir -Force | Out-Null }

$port = 1443
$secret = ''
if (Test-Path -LiteralPath $SettingsFile) {
    try {
        $settings = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        try { $port = [int]$settings.tgProxyPort } catch { $port = 1443 }
        $secret = [string]$settings.tgProxySecret
    } catch {}
}

if ($port -lt 1 -or $port -gt 65535) { $port = 1443 }
if ($secret -notmatch '^[0-9a-fA-F]{32}$') {
    if (Test-Path -LiteralPath $ProxyConfig) {
        try { $secret = [string]((Get-Content -LiteralPath $ProxyConfig -Raw -Encoding UTF8 | ConvertFrom-Json).secret) } catch {}
    }
}
if ($secret -notmatch '^[0-9a-fA-F]{32}$') {
    $bytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $secret = -join ($bytes | ForEach-Object { $_.ToString('x2') })
}
$secret = $secret.ToLowerInvariant()

$config = [ordered]@{
    host = '127.0.0.1'
    port = $port
    secret = $secret
    dc_ip = @('2:149.154.167.220', '4:149.154.167.220')
    verbose = $false
    buf_kb = 256
    pool_size = 4
    log_max_mb = 5.0
    check_updates = $false
    cfproxy = $true
    cfproxy_user_domain = @()
    cfproxy_worker_domain = @()
    appearance = 'auto'
    autostart = $true
}
[System.IO.File]::WriteAllText($ProxyConfig, ($config | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
New-Item -ItemType File -Path (Join-Path $ProxyAppDir '.first_run_done_mtproto') -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $ProxyAppDir '.ipv6_warned') -Force | Out-Null

$own = (Get-Item -LiteralPath $ProxyExe).FullName.ToLowerInvariant()
$running = @(Get-CimInstance Win32_Process -Filter "name = 'TgWsProxy_windows.exe' OR name = 'TgWsProxy.exe'" | Where-Object {
    $path = [string]$_.ExecutablePath
    $cmd = [string]$_.CommandLine
    ($path -and $path.ToLowerInvariant() -eq $own) -or ($cmd -and $cmd.ToLowerInvariant().Contains($own))
})
if ($running.Count -eq 0) {
    Start-Process -FilePath $ProxyExe -WorkingDirectory (Split-Path -Parent $ProxyExe) -WindowStyle Hidden | Out-Null
}

Start-Sleep -Milliseconds 1500
if ((Test-Path -LiteralPath $SettingsFile) -and (Test-Path -LiteralPath $ProxyConfig)) {
    try {
        $actual = Get-Content -LiteralPath $ProxyConfig -Raw -Encoding UTF8 | ConvertFrom-Json
        $settings = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $settings | Add-Member -NotePropertyName tgProxySecret -NotePropertyValue ([string]$actual.secret) -Force
        $settings | Add-Member -NotePropertyName tgProxyPort -NotePropertyValue ([int]$actual.port) -Force
        $settings | Add-Member -NotePropertyName tgProxyAutostart -NotePropertyValue $true -Force
        $settings | ConvertTo-Json | Set-Content -LiteralPath $SettingsFile -Encoding UTF8
    } catch {}
}
