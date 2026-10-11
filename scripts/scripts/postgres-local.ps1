param(
    [ValidateSet('Start', 'Stop', 'Status', 'Init')]
    [string]$Action = 'Status',
    [string]$PgBin = (Join-Path $env:TEMP 'th1-postgresql11/pgsql/bin'),
    [int]$Port = 5432
)

$ErrorActionPreference = 'Stop'
$dataDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../postgres/data'))
$sqlFile = Join-Path $PSScriptRoot '../../postgres/postgres/createdatabases.sql'
$pgCtl = Join-Path $PgBin 'pg_ctl.exe'
$psql = Join-Path $PgBin 'psql.exe'
if (-not (Test-Path -LiteralPath $pgCtl)) { throw "Portable PostgreSQL not found: $PgBin" }

switch ($Action) {
    'Start' {
        if (-not (Test-Path (Join-Path $dataDir 'PG_VERSION'))) {
            if ((Test-Path $dataDir) -and (Get-ChildItem -LiteralPath $dataDir -Force)) {
                throw 'Data directory is not empty. Refusing to initialize over existing files.'
            }
            $passwordFile = [IO.Path]::GetTempFileName()
            try {
                [IO.File]::WriteAllText($passwordFile, 'lab_pass')
                & (Join-Path $PgBin 'initdb.exe') -D $dataDir -U postgres `
                    --auth=md5 --encoding=UTF8 --locale=C --pwfile=$passwordFile
                if ($LASTEXITCODE -ne 0) { throw 'initdb failed.' }
            }
            finally { Remove-Item -LiteralPath $passwordFile }
        }
        & $pgCtl status -D $dataDir
        if ($LASTEXITCODE -eq 0) { return }
        & $pgCtl start -D $dataDir -l (Join-Path $dataDir 'server.log') `
            -o "-h 127.0.0.1 -p $Port" -w
        if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL startup failed. See postgres/data/server.log.' }
    }
    'Stop' {
        & $pgCtl stop -D $dataDir -m fast -w
        if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL shutdown failed.' }
    }
    'Status' {
        & $pgCtl status -D $dataDir
        if ($LASTEXITCODE -ne 0) { throw 'Local PostgreSQL is not running.' }
    }
    'Init' {
        $databases = [regex]::Matches((Get-Content -LiteralPath $sqlFile -Raw),
            '(?im)^\s*CREATE\s+DATABASE\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;') |
            ForEach-Object { $_.Groups[1].Value }
        if (-not $databases) { throw 'No databases found in the supplied SQL.' }
        $existing = & $psql -h 127.0.0.1 -p $Port -U postgres -d postgres -At `
            -c 'SELECT datname FROM pg_database'
        if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect existing databases.' }
        $alreadyCreated = @($databases | Where-Object { $_ -in $existing })
        if ($alreadyCreated.Count -eq $databases.Count) {
            Write-Host 'All databases from createdatabases.sql already exist.'
            return
        }
        if ($alreadyCreated.Count -gt 0) {
            throw 'Some databases already exist. Refusing to rerun SQL over partial initialization.'
        }
        & $psql -h 127.0.0.1 -p $Port -U postgres -d postgres `
            -v ON_ERROR_STOP=1 -f $sqlFile
        if ($LASTEXITCODE -ne 0) { throw 'The supplied database initialization SQL failed.' }
    }
}
