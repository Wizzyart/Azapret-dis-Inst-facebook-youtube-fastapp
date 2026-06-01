param(
    [string]$Owner = 'Wizzyart',
    [string]$Repo = 'Azapret-dis-Inst-facebook-youtube-fastapp',
    [string]$Tag = 'public-csgo2-ttl-20260601',
    [string]$NotesPath = (Join-Path $PSScriptRoot 'RELEASE-NOTES-public-csgo2-ttl-20260601.md')
)

$ErrorActionPreference = 'Stop'

if (-not $env:GITHUB_TOKEN) {
    throw 'GITHUB_TOKEN is not set in this PowerShell session.'
}

if (-not (Test-Path -LiteralPath $NotesPath)) {
    throw "Release notes file not found: $NotesPath"
}

$headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    Accept = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
}

$release = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$Owner/$Repo/releases/tags/$Tag" -Headers $headers
$body = Get-Content -LiteralPath $NotesPath -Raw -Encoding UTF8
$payload = @{ body = $body } | ConvertTo-Json -Depth 4

Invoke-RestMethod -Method Patch -Uri $release.url -Headers $headers -Body $payload -ContentType 'application/json' | Out-Null

"Updated release body: $($release.html_url)"
