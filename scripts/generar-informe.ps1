param([string]$Trx = (Join-Path $PSScriptRoot '..\artifacts\pruebas\iteracion-01.trx'))
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
[xml]$tests = Get-Content -LiteralPath $Trx -Raw
$latest = Get-ChildItem -Path (Join-Path $repo 'artifacts\prueba-paquete-*') -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'resultado.json') } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $latest) { throw 'Primero ejecuta la prueba del paquete.' }
$smoke = Get-Content -LiteralPath (Join-Path $latest.FullName 'resultado.json') -Raw | ConvertFrom-Json
$package = Get-Item -LiteralPath $smoke.paquete
$report = [ordered]@{
    origen = 'Resultados reales de dotnet test y scripts/probar-paquete.ps1'
    fechaPruebas = $tests.TestRun.Times.finish
    integracion = @($tests.TestRun.Results.UnitTestResult | ForEach-Object {
        [ordered]@{ prueba = $_.testName; resultado = $_.outcome; duracion = $_.duration }
    })
    fechaPaqueteUtc = $smoke.fechaUtc
    paquete = $package.Name
    bytesPaquete = $package.Length
    sha256 = (Get-FileHash -LiteralPath $package.FullName -Algorithm SHA256).Hash
    ejecutable = $smoke.comprobaciones
    limites = @('Pendiente revisión y aceptación de Carlos.', 'El plano y las reservas aún no están implementados.',
        'No se ha desconectado la red del equipo; se han comprobado referencias y recursos locales.',
        'El rechazo de permisos se ha probado en las rutas actuales; falta verificar las solicitudes propias y ajenas.')
}
$report | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath (Join-Path $repo 'docs\manual\verificacion.json') -Encoding utf8
Get-ChildItem -LiteralPath (Join-Path $repo 'docs\manual\capturas') -Filter '*.jpg' | Sort-Object Name |
    ForEach-Object { [ordered]@{ archivo = $_.Name; fechaUtc = $_.LastWriteTimeUtc.ToString('o'); bytes = $_.Length; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } } |
    ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $repo 'docs\manual\capturas.json') -Encoding utf8
Write-Output 'Informe y manifiesto de capturas generados a partir de las evidencias existentes.'
