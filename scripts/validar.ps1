$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Push-Location $repo
try {
    dotnet restore Nexo.sln --locked-mode
    if ($LASTEXITCODE -ne 0) { throw 'Falló la restauración de dependencias.' }
    dotnet build Nexo.sln --no-restore -c Release
    if ($LASTEXITCODE -ne 0) { throw 'Falló la compilación.' }
    dotnet test Nexo.sln --no-build --no-restore -c Release --logger 'trx;LogFileName=iteracion-01.trx' --results-directory artifacts/pruebas
    if ($LASTEXITCODE -ne 0) { throw 'Hay pruebas fallidas. Revisa el informe TRX.' }
} finally { Pop-Location }
