param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Preparar','Configurar','Migrar','Arrancar','Comprobar','Verificar','Publicar','Detener')]
    [string]$Fase,
    [string]$Destino = (Join-Path $PSScriptRoot '..\artifacts\reproduccion-20261128'),
    [int]$Puerto = 5191,
    [string]$PythonPath = 'python'
)
$ErrorActionPreference = 'Stop'
$taskRepo = Split-Path $PSScriptRoot -Parent
$taskWorkspace = Split-Path $taskRepo -Parent
$taskRoot = [IO.Path]::GetFullPath($Destino)
$taskAllowed = [IO.Path]::GetFullPath((Join-Path $taskRepo 'artifacts')) + [IO.Path]::DirectorySeparatorChar
if (-not $taskRoot.StartsWith($taskAllowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'La reproducción debe estar dentro de artifacts.' }
if ($Fase -eq 'Preparar') {
    if (Test-Path -LiteralPath $taskRoot) { throw 'La carpeta ya existe. Usa otro destino para conservar la reproducción anterior.' }
    New-Item -ItemType Directory -Path (Join-Path $taskRoot 'registros') | Out-Null
}
if (-not (Test-Path -LiteralPath (Join-Path $taskRoot 'registros') -PathType Container)) { throw 'Primero ejecuta la fase Preparar.' }
$taskNumber = @{Preparar='01';Configurar='02';Migrar='03';Arrancar='04';Comprobar='05';Verificar='06';Publicar='07';Detener='08'}[$Fase]
$taskLog = Join-Path $taskRoot ('registros\'+$taskNumber+'-'+$Fase.ToLower()+'.txt')
if (Test-Path -LiteralPath $taskLog) { throw 'La fase ya tiene un registro. Se conserva sin sobrescribir.' }
$taskZone = [TimeZoneInfo]::FindSystemTimeZoneById('Romance Standard Time')
function Log([string]$Text) { $Text | Tee-Object -FilePath $taskLog -Append }
function Command([string[]]$Arguments) {
    Log ('> dotnet '+($Arguments -join ' '))
    $taskStarted = [DateTimeOffset]::UtcNow.ToString('o')
    & dotnet @Arguments 2>&1 | Tee-Object -FilePath $taskLog -Append | Out-Host
    $taskExit = $LASTEXITCODE
    [pscustomobject]@{phase=$Fase;program='dotnet';arguments=$Arguments;directory=$taskRoot;startedUtc=$taskStarted;endedUtc=[DateTimeOffset]::UtcNow.ToString('o');exitCode=$taskExit} | ConvertTo-Json -Compress -Depth 6 | Add-Content -LiteralPath (Join-Path $taskRoot 'registros\comandos.jsonl') -Encoding utf8
    if ($taskExit -ne 0) { throw ('Falló dotnet '+($Arguments -join ' ')) }
}
function Confine([string]$Path) {
    $taskAbsolute = [IO.Path]::GetFullPath($Path)
    if (-not $taskAbsolute.StartsWith($taskRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Una ruta sale de la reproducción.' }
    return $taskAbsolute
}
function Copy-Source([string]$Relative) {
    $taskSource = Join-Path $taskRepo $Relative
    $taskTarget = Confine (Join-Path $taskRoot $Relative)
    New-Item -ItemType Directory -Path (Split-Path $taskTarget -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $taskSource -Destination $taskTarget
}
function Inspect([string]$Folder,[string]$Name) {
    Log ('> inspeccionar-sqlite.py '+$Folder+'/nexo.db (solo lectura)')
    & $PythonPath (Join-Path $PSScriptRoot 'inspeccionar-sqlite.py') (Join-Path $taskRoot ($Folder+'\nexo.db')) --output (Join-Path $taskRoot ('registros\'+$Name+'.json')) 2>&1 | Tee-Object -FilePath $taskLog -Append | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'La inspección SQLite ha fallado.' }
}
function Start-Reproduction {
    $taskListeners = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
    if ($taskListeners.Port -contains $Puerto) { throw 'El puerto ya está ocupado; no se termina ningún proceso existente.' }
    $taskAssembly = Join-Path $taskRoot 'src\Nexo.Web\bin\Release\net10.0\Nexo.Web.dll'
    $taskTag = [Guid]::NewGuid().ToString('N').Substring(0,8)
    $taskProcess = Start-Process -FilePath (Get-Command dotnet).Source -ArgumentList ('"'+$taskAssembly+'"') `
        -WorkingDirectory (Join-Path $taskRoot 'src\Nexo.Web') -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $taskRoot ('registros\servidor-'+$taskTag+'.out.log')) `
        -RedirectStandardError (Join-Path $taskRoot ('registros\servidor-'+$taskTag+'.err.log')) `
        -Environment @{NEXO_PORT="$Puerto";NEXO_DATA_DIR=(Join-Path $taskRoot 'DatosApp');NEXO_OPEN_BROWSER='0';DOTNET_ENVIRONMENT='Production'}
    for ($taskAttempt=0;$taskAttempt -lt 50;$taskAttempt++) {
        if ($taskProcess.HasExited) { throw 'La aplicación terminó antes de responder.' }
        try {
            if ((Invoke-RestMethod -Uri "http://127.0.0.1:$Puerto/salud" -TimeoutSec 1).estado -eq 'disponible') {
                $taskInfo = [pscustomobject]@{pid=$taskProcess.Id;assembly=$taskAssembly;port=$Puerto;data=(Join-Path $taskRoot 'DatosApp')}
                $taskInfo | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskRoot 'registros\proceso.json') -Encoding utf8
                Log "Servidor disponible en http://127.0.0.1:$Puerto"
                return
            }
        } catch {}
        Start-Sleep -Milliseconds 200
    }
    throw 'No se pudo confirmar el arranque de la aplicación.'
}
function Stop-Reproduction {
    $taskInfo = Get-Content -LiteralPath (Join-Path $taskRoot 'registros\proceso.json') -Raw | ConvertFrom-Json
    $taskProcess = Get-CimInstance Win32_Process -Filter ('ProcessId='+$taskInfo.pid)
    if ($null -eq $taskProcess -or -not $taskProcess.CommandLine.Contains($taskInfo.assembly)) { throw 'El proceso ya no corresponde a esta reproducción.' }
    $taskOwner = Get-NetTCPConnection -State Listen -LocalPort $taskInfo.port
    if ($taskOwner.OwningProcess -notcontains $taskInfo.pid) { throw 'El puerto pertenece a otro proceso.' }
    Stop-Process -Id $taskInfo.pid
    Log 'Se detuvo únicamente el proceso de esta reproducción.'
}
Log 'NEXO - REPRODUCCIÓN REAL DEL MANUAL'
Log ('Fecha Madrid: '+[TimeZoneInfo]::ConvertTime([DateTimeOffset]::UtcNow,$taskZone).ToString('dd/MM/yyyy HH:mm zzz'))
Log ('Fase: '+$Fase)
Log 'Los resultados corresponden a esta ejecución, no a la creación histórica.'
Log ''
$env:DOTNET_CLI_HOME = Join-Path $taskWorkspace 'tmp\dotnet-home'
$env:NUGET_PACKAGES = Join-Path $taskWorkspace 'tmp\nuget'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:UseSharedCompilation = 'false'
$env:MSBUILDDISABLENODEREUSE = '1'
$env:DOTNET_CLI_USE_MSBUILD_SERVER = '0'
Push-Location $taskRoot
try {
    switch ($Fase) {
        Preparar {
            Copy-Source 'global.json'
            Copy-Source 'Directory.Build.props'
            Command @('--version')
            Command @('new','sln','--name','Nexo','--format','sln')
            Command @('new','webapp','--name','Nexo.Web','--output','src/Nexo.Web','--framework','net10.0','--auth','None','--no-restore')
            Command @('new','xunit','--name','Nexo.Web.Tests','--output','tests/Nexo.Web.Tests','--framework','net10.0','--no-restore')
            Command @('sln','Nexo.sln','add','src/Nexo.Web/Nexo.Web.csproj','tests/Nexo.Web.Tests/Nexo.Web.Tests.csproj')
            Command @('add','tests/Nexo.Web.Tests/Nexo.Web.Tests.csproj','reference','src/Nexo.Web/Nexo.Web.csproj')
            Log 'Resultado: solución, proyecto web y proyecto de pruebas creados.'
        }
        Configurar {
            foreach ($taskPackage in @('Microsoft.EntityFrameworkCore.Sqlite','Microsoft.EntityFrameworkCore.Design','Microsoft.AspNetCore.Identity.EntityFrameworkCore')) {
                Command @('add','src/Nexo.Web/Nexo.Web.csproj','package',$taskPackage,'--version','10.0.15','--no-restore')
            }
            New-Item -ItemType Directory -Path (Join-Path $taskRoot 'plantillas') | Out-Null
            foreach ($taskRelative in @('src\Nexo.Web','tests\Nexo.Web.Tests')) {
                $taskGenerated = Confine (Join-Path $taskRoot $taskRelative)
                $taskBackup = Confine (Join-Path $taskRoot ('plantillas\'+(Split-Path $taskRelative -Leaf)))
                Move-Item -LiteralPath $taskGenerated -Destination $taskBackup
            }
            $taskHashes = @()
            foreach ($taskArea in @('src\Nexo.Web','tests\Nexo.Web.Tests')) {
                foreach ($taskFile in Get-ChildItem -LiteralPath (Join-Path $taskRepo $taskArea) -File -Recurse) {
                    $taskRelative = [IO.Path]::GetRelativePath($taskRepo,$taskFile.FullName)
                    if ($taskRelative -match '(^|[\\/])(bin|obj|Migrations)([\\/]|$)') { continue }
                    Copy-Source $taskRelative
                    $taskHashes += [pscustomobject]@{path=$taskRelative;sha256=(Get-FileHash -LiteralPath $taskFile.FullName -Algorithm SHA256).Hash.ToLower()}
                }
            }
            Copy-Source '.config\dotnet-tools.json'
            foreach ($taskFile in @('validar.ps1','publicar.ps1','probar-paquete.ps1','INICIAR.cmd','LEEME.txt')) { Copy-Source ('scripts\'+$taskFile) }
            $taskHashes | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $taskRoot 'registros\fuentes-incorporadas.json') -Encoding utf8
            Log ('Fuentes incorporadas desde la revisión local de Nexo: '+$taskHashes.Count+' archivos.')
            Log 'La plantilla genérica no genera estas funciones; se incorporan las clases, páginas, estilos y pruebas de Nexo.'
            Log 'Las plantillas generadas se conservan en plantillas. No se copian migraciones antiguas, bin ni obj.'
            Command @('restore','Nexo.sln','--locked-mode')
            Command @('tool','restore')
            Command @('ef','--version')
            Command @('build','Nexo.sln','--no-restore','-c','Release','-p:UseSharedCompilation=false','-m:1','--disable-build-servers')
        }
        Migrar {
            if (Test-Path -LiteralPath (Join-Path $taskRoot 'src\Nexo.Web\Data\Migrations')) { throw 'Ya hay migraciones; se conserva el estado.' }
            Command @('ef','migrations','add','InitialAccess','--project','src/Nexo.Web','--output-dir','Data/Migrations','--configuration','Release','--no-build')
            Command @('build','Nexo.sln','--no-restore','-c','Release','-p:UseSharedCompilation=false','-m:1','--disable-build-servers')
            Command @('ef','migrations','script','0','--project','src/Nexo.Web','--configuration','Release','--no-build','--output','registros/esquema.sql')
            Log ('Base de ejecución creada por generar la migración: '+(Test-Path -LiteralPath (Join-Path $taskRoot 'DatosApp\nexo.db')))
            Log 'Resultado: migración y SQL generados; la base de ejecución todavía no existe.'
        }
        Arrancar {
            if (Test-Path -LiteralPath (Join-Path $taskRoot 'DatosApp\nexo.db')) { throw 'La demostración de primera creación necesita una carpeta nueva.' }
            Log 'Antes del arranque: DatosApp/nexo.db no existe.'
            Log '> dotnet src/Nexo.Web/bin/Release/net10.0/Nexo.Web.dll'
            Log ('Configuración: NEXO_PORT='+$Puerto+'; NEXO_DATA_DIR=DatosApp; NEXO_OPEN_BROWSER=0')
            Start-Reproduction
            Inspect 'DatosApp' 'sqlite-primer-arranque'
            Log 'Resultado: la aplicación creó SQLite, aplicó la migración y precargó dos cuentas y dos perfiles.'
        }
        Comprobar {
            $taskHandler = [Net.Http.HttpClientHandler]::new()
            $taskHandler.AllowAutoRedirect = $false
            $taskHandler.CookieContainer = [Net.CookieContainer]::new()
            $taskClient = [Net.Http.HttpClient]::new($taskHandler)
            $taskBase = "http://127.0.0.1:$Puerto"
            try {
                $taskLogin = $taskClient.GetStringAsync($taskBase+'/Acceso/Entrar').Result
                $taskToken = [Net.WebUtility]::HtmlDecode([regex]::Match($taskLogin,'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value)
                $taskForm = [Collections.Generic.Dictionary[string,string]]::new()
                $taskForm.Add('Input.UserName','carlos');$taskForm.Add('Input.Password','Nexo.Carlos2026!');$taskForm.Add('__RequestVerificationToken',$taskToken)
                $taskResponse = $taskClient.PostAsync($taskBase+'/Acceso/Entrar',[Net.Http.FormUrlEncodedContent]::new($taskForm)).Result
                if ([int]$taskResponse.StatusCode -ne 302) { throw 'El acceso de prueba ha fallado.' }
                Log 'Acceso HTTP de Carlos correcto; la aplicación guardó su último acceso.'
                Inspect 'DatosApp' 'sqlite-antes-reinicio'
                Stop-Reproduction
                Start-Reproduction
                Inspect 'DatosApp' 'sqlite-despues-reinicio'
                $taskBefore = Get-Content -LiteralPath (Join-Path $taskRoot 'registros\sqlite-antes-reinicio.json') -Raw | ConvertFrom-Json
                $taskAfter = Get-Content -LiteralPath (Join-Path $taskRoot 'registros\sqlite-despues-reinicio.json') -Raw | ConvertFrom-Json
                $taskEqual = @{}
                foreach ($taskField in @('users','roles','relations','migrations')) {
                    $taskEqual[$taskField] = (ConvertTo-Json -InputObject $taskBefore.$taskField -Depth 8 -Compress) -eq (ConvertTo-Json -InputObject $taskAfter.$taskField -Depth 8 -Compress)
                    if (-not $taskEqual[$taskField]) { throw ('Diferencias tras reiniciar: '+$taskField) }
                }
                if ($taskAfter.integrity -ne 'ok') { throw 'SQLite no ha superado la comprobación de integridad.' }
                $taskProfile = $taskClient.GetAsync($taskBase+'/Perfil').Result
                if ([int]$taskProfile.StatusCode -ne 200) { throw 'No se conservó la sesión de prueba.' }
                $taskEqual | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskRoot 'registros\persistencia.json') -Encoding utf8
                Log 'Reinicio correcto: mismos usuarios, perfiles, relaciones, migración y último acceso; sesión conservada.'
            } finally { $taskClient.Dispose();$taskHandler.Dispose() }
            New-Item -ItemType Directory -Path (Join-Path $taskRoot 'DatosManual') | Out-Null
            Command @('ef','database','update','--project','src/Nexo.Web','--configuration','Release','--no-build','--connection',('Data Source='+(Join-Path $taskRoot 'DatosManual\nexo.db')))
            Inspect 'DatosManual' 'sqlite-ruta-manual'
            Log 'Ruta manual opcional: creó el esquema, pero no cargó cuentas; esa inicialización pertenece al arranque de Nexo.'
        }
        Verificar {
            Command @('test','Nexo.sln','--no-build','--no-restore','-c','Release','--disable-build-servers','--logger','trx;LogFileName=reproduccion.trx','--results-directory','artifacts/pruebas-reproduccion')
        }
        Publicar {
            $taskDestination = Join-Path $taskRoot 'artifacts\Nexo-reproduccion-win-x64'
            if (Test-Path -LiteralPath $taskDestination) { throw 'La publicación ya existe.' }
            Command @('restore','src/Nexo.Web/Nexo.Web.csproj','-r','win-x64','-p:RuntimeFrameworkVersion=10.0.15','-p:NuGetLockFilePath=packages.win-x64.lock.json','--locked-mode')
            Command @('publish','src/Nexo.Web/Nexo.Web.csproj','-c','Release','-r','win-x64','--self-contained','true','--no-restore','-p:RuntimeFrameworkVersion=10.0.15','-p:NuGetLockFilePath=packages.win-x64.lock.json','-p:UseSharedCompilation=false','-p:PublishSingleFile=false','-o',$taskDestination)
            Copy-Item -LiteralPath (Join-Path $taskRoot 'scripts\INICIAR.cmd') -Destination $taskDestination
            Copy-Item -LiteralPath (Join-Path $taskRoot 'scripts\LEEME.txt') -Destination $taskDestination
            Compress-Archive -LiteralPath $taskDestination -DestinationPath ($taskDestination+'.zip')
            Log ('ZIP generado: '+(Get-Item -LiteralPath ($taskDestination+'.zip')).Name)
            Log ('SHA256: '+(Get-FileHash -LiteralPath ($taskDestination+'.zip') -Algorithm SHA256).Hash)
        }
        Detener { Stop-Reproduction }
    }
    Log ''
    Log 'FASE COMPLETADA CORRECTAMENTE'
} finally { Pop-Location }
