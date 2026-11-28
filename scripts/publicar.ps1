param([string]$Version = 'iteracion-01')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$destination = Join-Path $repo "artifacts\Nexo-$Version-win-x64"
$zip = "$destination.zip"
if (Test-Path -LiteralPath $destination) { throw "Ya existe $destination. Usa otra versión para conservar el paquete anterior." }
Push-Location $repo
try {
    dotnet restore src/Nexo.Web/Nexo.Web.csproj -r win-x64 -p:RuntimeFrameworkVersion=10.0.15 `
        -p:NuGetLockFilePath=packages.win-x64.lock.json --locked-mode
    if ($LASTEXITCODE -ne 0) { throw 'La restauración bloqueada de Windows ha fallado.' }
    dotnet publish src/Nexo.Web/Nexo.Web.csproj -c Release -r win-x64 --self-contained true `
        --no-restore -p:RuntimeFrameworkVersion=10.0.15 -p:NuGetLockFilePath=packages.win-x64.lock.json `
        -p:PublishSingleFile=false -o $destination
    if ($LASTEXITCODE -ne 0) { throw 'La publicación ha fallado.' }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'INICIAR.cmd') -Destination $destination
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LEEME.txt') -Destination $destination
    Compress-Archive -LiteralPath $destination -DestinationPath $zip
    Get-FileHash -LiteralPath $zip -Algorithm SHA256
    Write-Output "Paquete: $zip"
} finally { Pop-Location }
