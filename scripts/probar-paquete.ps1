param([string]$Package = (Join-Path $PSScriptRoot '..\artifacts\Nexo-iteracion-01-win-x64.zip'))
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$run = Join-Path $repo ('artifacts\prueba-paquete-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $run | Out-Null
Expand-Archive -LiteralPath $Package -DestinationPath $run
$app = (Get-ChildItem -LiteralPath $run -Directory | Select-Object -First 1).FullName
$executable = Join-Path $app 'Nexo.Web.exe'
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$listener.Start()
$port = $listener.LocalEndpoint.Port
$listener.Stop()
$baseUrl = "http://127.0.0.1:$port"
$results = [Collections.Generic.List[object]]::new()
$processes = [Collections.Generic.List[object]]::new()

function Check($name, $condition) {
    $results.Add([pscustomobject]@{ comprobacion = $name; correcta = [bool]$condition })
    if (-not $condition) { throw "Comprobación fallida: $name" }
}
function Start-Nexo($name, $data, $selectedPort) {
    $process = Start-Process -FilePath $executable -WorkingDirectory $app -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $run "$name.out.log") -RedirectStandardError (Join-Path $run "$name.err.log") `
        -Environment @{ NEXO_PORT = "$selectedPort"; NEXO_DATA_DIR = $data; NEXO_OPEN_BROWSER = '0'; DOTNET_ENVIRONMENT = 'Production' }
    $processes.Add($process)
    return $process
}
function Wait-Nexo($process) {
    for ($attempt = 0; $attempt -lt 70; $attempt++) {
        if ($process.HasExited) { throw 'El ejecutable terminó antes de estar disponible.' }
        try { if ($client.GetAsync("$baseUrl/salud").Result.IsSuccessStatusCode) { return } } catch { }
        Start-Sleep -Milliseconds 200
    }
    throw 'La aplicación no ha respondido en el plazo previsto.'
}
function Text($response) { return $response.Content.ReadAsStringAsync().Result }
function Token($html) { return [Net.WebUtility]::HtmlDecode([regex]::Match($html, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value) }
$handler = [Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$handler.CookieContainer = [Net.CookieContainer]::new()
$client = [Net.Http.HttpClient]::new($handler)
try {
    $data = Join-Path $app 'Datos'
    $first = Start-Nexo 'arranque' $data $port
    Wait-Nexo $first
    Check 'El ZIP extraído arranca con su propio runtime y crea SQLite' (Test-Path -LiteralPath (Join-Path $data 'nexo.db'))
    $bindings = @([Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners() | Where-Object Port -eq $port)
    Check 'Solo escucha en 127.0.0.1' ($bindings.Count -eq 1 -and $bindings[0].Address.Equals([Net.IPAddress]::Loopback))
    Check 'Una página protegida exige autenticación' ([int]$client.GetAsync("$baseUrl/Perfil").Result.StatusCode -eq 302)
    $login = Text ($client.GetAsync("$baseUrl/Acceso/Entrar").Result)
    $form = [Collections.Generic.Dictionary[string,string]]::new()
    $form.Add('Input.UserName', 'carlos'); $form.Add('Input.Password', 'Nexo.Carlos2026!'); $form.Add('__RequestVerificationToken', (Token $login))
    $loginResponse = $client.PostAsync("$baseUrl/Acceso/Entrar", [Net.Http.FormUrlEncodedContent]::new($form)).Result
    Check 'Acceso de Carlos en el ejecutable publicado' ([int]$loginResponse.StatusCode -eq 302)
    $profile = Text ($client.GetAsync("$baseUrl/Perfil").Result)
    Check 'El perfil propio se consulta tras acceder' ($profile.Contains('carlos@nexo.local'))
    $protected = $client.GetAsync("$baseUrl/Administracion").Result
    Check 'El ejecutable rechaza administración para el empleado' ([int]$protected.StatusCode -eq 302 -and $protected.Headers.Location.ToString().Contains('/Acceso/Denegado'))
    Check 'CSS y marca se sirven desde la carpeta publicada' ($client.GetAsync("$baseUrl/css/site.css").Result.IsSuccessStatusCode -and $client.GetAsync("$baseUrl/nexo.svg").Result.IsSuccessStatusCode)
    $second = Start-Nexo 'carpeta-bloqueada' $data ($port + 1)
    Check 'Una segunda instancia sobre los mismos datos falla de forma controlada' ($second.WaitForExit(15000) -and $second.ExitCode -ne 0 -and (Get-Content -LiteralPath (Join-Path $run 'carpeta-bloqueada.err.log') -Raw).Contains('otra instancia'))
    $occupied = Start-Nexo 'puerto-ocupado' (Join-Path $run 'otros-datos') $port
    Check 'Puerto ocupado: error comprensible sin cerrar el proceso existente' ($occupied.WaitForExit(15000) -and $occupied.ExitCode -ne 0 -and (Get-Content -LiteralPath (Join-Path $run 'puerto-ocupado.err.log') -Raw).Contains('puerto') -and -not $first.HasExited)
    $invalidPath = Join-Path $run 'no-es-carpeta.txt'
    Set-Content -LiteralPath $invalidPath -Value 'Ruta de prueba; es un archivo.'
    $invalid = Start-Nexo 'carpeta-invalida' $invalidPath ($port + 1)
    Check 'Una ubicación de datos no válida presenta un error de arranque' ($invalid.WaitForExit(15000) -and $invalid.ExitCode -ne 0 -and (Get-Content -LiteralPath (Join-Path $run 'carpeta-invalida.err.log') -Raw).Contains('carpeta'))
    Stop-Process -Id $first.Id
    $first.WaitForExit()
    $restart = Start-Nexo 'reinicio' $data $port
    Wait-Nexo $restart
    $after = $client.GetAsync("$baseUrl/Perfil").Result
    Check 'Reinicio: se conservan la sesión y la información del perfil' ([int]$after.StatusCode -eq 200 -and (Text $after).Contains('carlos@nexo.local'))
    $timePattern = '\d{2}/\d{2}/\d{4}[^<]+\d{2}:\d{2}'
    Check 'El último acceso guardado permanece sin un nuevo login' ([regex]::Match($profile, $timePattern).Success -and [regex]::Match($profile, $timePattern).Value -eq [regex]::Match((Text $after), $timePattern).Value)
} finally {
    foreach ($process in $processes) { if (-not $process.HasExited) { Stop-Process -Id $process.Id; $process.WaitForExit() } }
    $client.Dispose(); $handler.Dispose()
    [pscustomobject]@{ fechaUtc = [DateTimeOffset]::UtcNow.ToString('o'); paquete = (Resolve-Path -LiteralPath $Package).Path; comprobaciones = $results } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $run 'resultado.json') -Encoding utf8
    $results | Format-Table
    Write-Output "Evidencia conservada en $run"
}
