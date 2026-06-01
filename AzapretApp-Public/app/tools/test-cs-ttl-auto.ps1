param(
    [Parameter(Mandatory = $true)]
    [string]$CsServer,
    [switch]$ApplyBest
)

$ErrorActionPreference = 'Continue'
$appRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$bypassDir = Join-Path $appRoot 'bypasses'
$logDir = Join-Path $appRoot 'test-results'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logPath = Join-Path $logDir "cs-ttl-auto-$stamp.txt"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Write-Log {
    param([string]$Message)
    $line = '[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $Message
    $line | Tee-Object -FilePath $logPath -Append
}

function Stop-Winws {
    Get-Process -Name 'winws' -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Write-Log "Stopping winws PID $($_.Id)"
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
        } catch {
            Write-Log "Failed to stop winws PID $($_.Id): $($_.Exception.Message)"
        }
    }
    Start-Sleep -Seconds 2
}

function Split-CsServer {
    param([string]$Value)
    $text = $Value.Trim()
    if ($text -match '^(.+):(\d+)$') {
        return [pscustomobject]@{ Host = $Matches[1].Trim(); Port = [int]$Matches[2] }
    }
    return [pscustomobject]@{ Host = $text; Port = 27015 }
}

function Test-CsServer {
    param([object]$Target)

    $avg = 999999
    $loss = 100
    $pingOk = $false
    $udpSent = $false

    try {
        $ping = @(Test-Connection -ComputerName $Target.Host -Count 4 -ErrorAction Stop)
        $avg = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 1)
        $loss = 100 - [math]::Round(($ping.Count / 4) * 100, 0)
        $pingOk = $true
        Write-Log "CS ping: OK avg=$avg ms loss=$loss%"
    } catch {
        Write-Log "CS ping: FAIL/blocked $($_.Exception.Message)"
    }

    try {
        $client = [Net.Sockets.UdpClient]::new()
        $payload = [Text.Encoding]::ASCII.GetBytes('Azapret-CS2-UDP-probe')
        [void]$client.Send($payload, $payload.Length, $Target.Host, $Target.Port)
        $client.Close()
        $udpSent = $true
        Write-Log "CS UDP probe: SENT $($Target.Host):$($Target.Port)"
    } catch {
        Write-Log "CS UDP probe: FAIL $($_.Exception.Message)"
    }

    return [pscustomobject]@{ PingOk = $pingOk; AvgMs = $avg; LossPct = $loss; UdpSent = $udpSent }
}

function Set-GameFilterUdpOnly {
    $utilsDir = Join-Path $appRoot 'utils'
    New-Item -ItemType Directory -Path $utilsDir -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $utilsDir 'game_filter.enabled') -Value 'udp' -Encoding ASCII
    Write-Log 'Game Filter set to UDP only'
}

$target = Split-CsServer -Value $CsServer
$results = New-Object System.Collections.Generic.List[object]

Write-Log "CS TTL auto test started: $($target.Host):$($target.Port)"
Set-GameFilterUdpOnly

foreach ($ttl in 3..7) {
    $profile = Join-Path $bypassDir "general (FACEIT CS2 TTL$ttl).bat"
    Write-Log "================ TTL$ttl ================"
    if (-not (Test-Path -LiteralPath $profile)) {
        Write-Log "TTL$ttl profile missing: $profile"
        continue
    }

    Stop-Winws
    Write-Log "Starting TTL$ttl profile"
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', "`"$profile`"" -WorkingDirectory $appRoot -WindowStyle Minimized | Out-Null
    Start-Sleep -Seconds 8

    $test = Test-CsServer -Target $target
    $results.Add([pscustomobject]@{
        TTL = $ttl
        Profile = $profile
        PingOk = $test.PingOk
        AvgMs = $test.AvgMs
        LossPct = $test.LossPct
        UdpSent = $test.UdpSent
    }) | Out-Null
}

$best = $results | Sort-Object @{ Expression = { if ($_.PingOk) { 0 } else { 1 } } }, LossPct, AvgMs, TTL | Select-Object -First 1
Write-Log '================ SUMMARY ================'
foreach ($item in $results) {
    Write-Log "TTL$($item.TTL): pingOk=$($item.PingOk) avg=$($item.AvgMs)ms loss=$($item.LossPct)% udpSent=$($item.UdpSent)"
}

if ($best) {
    Write-Log "BEST: TTL$($best.TTL) avg=$($best.AvgMs)ms loss=$($best.LossPct)%"
    if ($ApplyBest) {
        Stop-Winws
        Write-Log "Applying best profile TTL$($best.TTL) temporarily"
        Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', "`"$($best.Profile)`"" -WorkingDirectory $appRoot -WindowStyle Minimized | Out-Null
        Start-Sleep -Seconds 5
    } else {
        Stop-Winws
    }
}

Write-Log "Log saved: $logPath"
