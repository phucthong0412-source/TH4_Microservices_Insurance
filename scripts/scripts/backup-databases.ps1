param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../../postgres/backups'),
    [ValidateSet('Docker', 'Local')]
    [string]$Mode = 'Docker',
    [string]$PgBin = (Join-Path $env:TEMP 'th1-postgresql11/pgsql/bin'),
    [string]$Server = '127.0.0.1',
    [int]$Port = 5432,
    [string]$Username = 'postgres'
)

$ErrorActionPreference = 'Stop'
$composeFile = Join-Path $PSScriptRoot 'infra.yml'
$sqlFile = Join-Path $PSScriptRoot '../../postgres/postgres/createdatabases.sql'
$databases = [regex]::Matches((Get-Content -LiteralPath $sqlFile -Raw),
    '(?im)^\s*CREATE\s+DATABASE\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;') |
    ForEach-Object { $_.Groups[1].Value }
if (-not $databases) { throw 'No CREATE DATABASE statements found in the supplied SQL.' }

if ($Mode -eq 'Local') {
    $pgDump = Join-Path $PgBin 'pg_dump.exe'
    $pgRestore = Join-Path $PgBin 'pg_restore.exe'
    if (-not (Test-Path -LiteralPath $pgDump)) { throw "pg_dump not found: $pgDump" }
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    foreach ($database in $databases) {
        $localFile = Join-Path $OutputDirectory "$database-$timestamp.backup"
        & $pgDump --host=$Server --port=$Port --username=$Username `
            --format=custom --create --file=$localFile $database
        if ($LASTEXITCODE -ne 0) { throw "pg_dump failed for $database." }
        & $pgRestore --list $localFile | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Invalid backup archive for $database." }
        Write-Host "Backup verified: $localFile"
    }
    return
}

$containerId = & docker compose -f $composeFile ps -q postgres
if ($LASTEXITCODE -ne 0 -or -not $containerId) {
    throw 'PostgreSQL container is unavailable. Start infra.yml first.'
}
$containerId = $containerId.Trim()
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
foreach ($database in $databases) {
    $remoteFile = "/tmp/$database-$timestamp.backup"
    $localFile = Join-Path $OutputDirectory "$database-$timestamp.backup"
    & docker compose -f $composeFile exec -T postgres pg_dump -U postgres `
        --format=custom --create --file=$remoteFile $database
    if ($LASTEXITCODE -ne 0) { throw "pg_dump failed for $database." }
    & docker cp "${containerId}:$remoteFile" $localFile
    if ($LASTEXITCODE -ne 0) { throw "Copy failed for $database." }
    & docker compose -f $composeFile exec -T postgres pg_restore --list $remoteFile | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Invalid backup archive for $database." }
    Write-Host "Backup verified: $localFile"
}
