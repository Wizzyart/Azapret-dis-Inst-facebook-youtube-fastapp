param(
    [string]$CsServer = "",
    [int[]]$Ttl = @(3, 4, 5, 6, 7),
    [int]$WaitSeconds = 8,
    [switch]$KillExistingWinws,
    [switch]$SkipTraceroute
)

$ErrorActionPreference = "Continue"
$appRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$bypassDir = Join-Path $appRoot "bypasses"
$logDir = Join-Path $appRoot "test-results"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $logDir "faceit-cs2-ttl-test-$stamp.txt"

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $Message
    $line | Tee-Object -FilePath $logPath -Append
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Stop-Winws {
    $procs = @(Get-Process -Name "winws" -ErrorAction SilentlyContinue)
    if ($procs.Count -eq 0) {
        Write-Log "winws: not running"
        return
    }

    foreach ($proc in $procs) {
        try {
            Write-Log "winws: stopping PID $($proc.Id)"
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
        } catch {
            Write-Log "winws: failed to stop PID $($proc.Id): $($_.Exception.Message)"
        }
    }
    Start-Sleep -Seconds 2
}

function Test-HttpTarget {
    param(
        [string]$Name,
        [string]$Url
    )

    $sw = [Diagnostics.Stopwatch]::StartNew()
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 12 -UseBasicParsing
        $sw.Stop()
        Write-Log "$Name HTTPS: OK status=$($response.StatusCode) timeMs=$($sw.ElapsedMilliseconds) url=$Url"
    } catch {
        $sw.Stop()
        Write-Log "$Name HTTPS: FAIL timeMs=$($sw.ElapsedMilliseconds) url=$Url error=$($_.Exception.Message)"
    }
}

function Test-DnsTarget {
    param([string]$HostName)
    try {
        $records = @(Resolve-DnsName -Name $HostName -Type A -ErrorAction Stop | Where-Object { $_.IPAddress })
        $ips = ($records | Select-Object -First 5 -ExpandProperty IPAddress) -join ","
        Write-Log "$HostName DNS: OK $ips"
    } catch {
        Write-Log "$HostName DNS: FAIL $($_.Exception.Message)"
    }
}

function Split-Server {
    param([string]$Server)
    if ([string]::IsNullOrWhiteSpace($Server)) { return $null }

    $value = $Server.Trim()
    if ($value -match "^(.+):(\d+)$") {
        return [pscustomobject]@{ Host = $Matches[1]; Port = [int]$Matches[2] }
    }

    return [pscustomobject]@{ Host = $value; Port = 27015 }
}

function Test-CsTarget {
    param([object]$Target)
    if ($null -eq $Target) {
        Write-Log "CS target: not set. Use -CsServer IP:PORT for a real FACEIT/CS2 France server."
        return
    }

    Write-Log "CS target: $($Target.Host):$($Target.Port)"

    try {
        $ping = Test-Connection -ComputerName $Target.Host -Count 4 -ErrorAction Stop
        $avg = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 1)
        $loss = 100 - [math]::Round(($ping.Count / 4) * 100, 0)
        Write-Log "CS ping: OK avgMs=$avg lossPct=$loss"
    } catch {
        Write-Log "CS ping: FAIL/blocked $($_.Exception.Message)"
    }

    try {
        $client = [Net.Sockets.UdpClient]::new()
        $client.Client.SendTimeout = 2000
        $payload = [Text.Encoding]::ASCII.GetBytes("Azapret-CS2-UDP-probe")
        [void]$client.Send($payload, $payload.Length, $Target.Host, $Target.Port)
        $client.Close()
        Write-Log "CS UDP probe: SENT port=$($Target.Port) note=no response is normal for many CS/UDP servers"
    } catch {
        Write-Log "CS UDP probe: FAIL $($_.Exception.Message)"
    }

    if (-not $SkipTraceroute) {
        Write-Log "CS tracert: start"
        try {
            $trace = & tracert.exe -d -h 12 -w 700 $Target.Host 2>&1
            foreach ($line in $trace) { Write-Log "CS tracert: $line" }
        } catch {
            Write-Log "CS tracert: FAIL $($_.Exception.Message)"
        }
    }
}

Write-Log "FACEIT/CS2 TTL profile test started"
Write-Log "AppRoot: $appRoot"
Write-Log "CsServer: $(if ($CsServer) { $CsServer } else { '<not set>' })"
Write-Log "TTL list: $($Ttl -join ',')"

if (-not (Test-Admin)) {
    Write-Log "WARNING: script is not elevated. winws/WinDivert profiles usually require Administrator rights."
}

$zapret = Get-Service -Name "zapret" -ErrorAction SilentlyContinue
if ($zapret -and $zapret.Status -eq "Running") {
    Write-Log "WARNING: zapret service is running. Standalone TTL profiles may not start. Stop service first if every TTL shows same result."
}

$target = Split-Server -Server $CsServer

foreach ($ttlValue in $Ttl) {
    $profile = Join-Path $bypassDir "general (FACEIT CS2 TTL$ttlValue).bat"
    Write-Log "================ TTL$ttlValue ================"

    if (-not (Test-Path -LiteralPath $profile)) {
        Write-Log "TTL$ttlValue profile: MISSING $profile"
        continue
    }

    if ($KillExistingWinws) { Stop-Winws }

    Write-Log "TTL$ttlValue profile: starting $profile"
    try {
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "`"$profile`"" -WorkingDirectory $appRoot -WindowStyle Minimized -PassThru
        Start-Sleep -Seconds $WaitSeconds
        Write-Log "TTL$ttlValue profile: launcher pid=$($proc.Id) waitSeconds=$WaitSeconds"
    } catch {
        Write-Log "TTL$ttlValue profile: START FAIL $($_.Exception.Message)"
    }

    $winws = @(Get-Process -Name "winws" -ErrorAction SilentlyContinue)
    if ($winws.Count -gt 0) {
        Write-Log "winws: RUNNING pid=$(( $winws | Select-Object -ExpandProperty Id ) -join ',')"
    } else {
        Write-Log "winws: NOT RUNNING"
    }

    Test-DnsTarget -HostName "youtube.com"
    Test-DnsTarget -HostName "discord.com"
    Test-HttpTarget -Name "YouTube" -Url "https://www.youtube.com/generate_204"
    Test-HttpTarget -Name "Discord gateway" -Url "https://discord.com/api/v10/gateway"
    Test-CsTarget -Target $target
}

if ($KillExistingWinws) { Stop-Winws }

Write-Log "FACEIT/CS2 TTL profile test finished"
Write-Log "Log saved: $logPath"
