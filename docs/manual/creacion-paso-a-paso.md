# Manual de creación de Nexo y SQLite

<!-- Fuente editorial: scripts/manual_creacion_content.py; contenido común generado en creacion-paso-a-paso.json. -->

Reproducción real del 28 de noviembre de 2026. Versión documental 1.1. Incremento de referencia I01.1.

Construir y comprobar la aplicación local de acceso con dos perfiles, desde una carpeta nueva, utilizando las fuentes de Nexo.

Las capturas de comandos muestran registros reales abiertos en Bloc de notas. La captura de la aplicación procede del navegador. Los originales se conservan; las anotaciones añaden recuadros y notas sin sustituir el contenido.

Requisitos de desarrollo: Windows, PowerShell 7, SDK .NET 10.0.401, fuentes locales de Nexo y Python 3 para la inspección de SQLite. El paquete final no requiere estas herramientas de desarrollo.

Las secciones explican la secuencia, la configuración y las decisiones de implementación. La última contiene el script por fases para repetir el proceso completo. Los fragmentos se sitúan en la raíz de la reproducción salvo indicación contraria. Las cinco capturas anotadas se incluyen en el Word y el PDF; su publicación externa sigue pendiente.

## 1. Crear la solución y los proyectos

La reproducción se ejecutó el 28 de noviembre de 2026 en una carpeta nueva. Desde la raíz de las fuentes de Nexo se creó un destino independiente, se copiaron global.json y Directory.Build.props y se ejecutaron los comandos siguientes dentro de ese destino.

```
dotnet --version
dotnet new sln --name Nexo --format sln
dotnet new webapp --name Nexo.Web --output src/Nexo.Web --framework net10.0 --auth None --no-restore
dotnet new xunit --name Nexo.Web.Tests --output tests/Nexo.Web.Tests --framework net10.0 --no-restore
dotnet sln Nexo.sln add src/Nexo.Web/Nexo.Web.csproj tests/Nexo.Web.Tests/Nexo.Web.Tests.csproj
dotnet add tests/Nexo.Web.Tests/Nexo.Web.Tests.csproj reference src/Nexo.Web/Nexo.Web.csproj
```

> Figura 1. Registro real de la fase Preparar, abierto en Bloc de notas. La plantilla crea la estructura inicial. Véase la captura anotada en el Word o PDF del manual.

Los comandos de plantilla crean una aplicación genérica. Las funciones de Nexo se incorporan en el paso siguiente mediante sus fuentes editables. La plantilla no genera las reservas ni las reglas del producto.

## 2. Incorporar las dependencias y las fuentes

Se añaden los paquetes de persistencia, diseño de migraciones e integración de Identity con EF Core. Se fija la versión 10.0.15, que es la utilizada en esta reproducción.

```
dotnet add src/Nexo.Web/Nexo.Web.csproj package Microsoft.EntityFrameworkCore.Sqlite --version 10.0.15 --no-restore
dotnet add src/Nexo.Web/Nexo.Web.csproj package Microsoft.EntityFrameworkCore.Design --version 10.0.15 --no-restore
dotnet add src/Nexo.Web/Nexo.Web.csproj package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 10.0.15 --no-restore
```

El script conserva las carpetas de plantilla en plantillas e incorpora 37 archivos de la revisión local de Nexo. Copia las clases, páginas, estilos, proyectos, pruebas y archivos de bloqueo; excluye bin, obj y las migraciones antiguas. El manifiesto fuentes-incorporadas.json registra sus hashes.

| Archivo o carpeta | Configuración que aporta |
| --- | --- |
| global.json | SDK .NET 10.0.401. |
| Directory.Build.props | Compilación determinista, avisos como errores y bloqueo de paquetes. |
| .config/dotnet-tools.json | Herramienta local dotnet-ef 10.0.15. |
| src/Nexo.Web/Data | Contexto, usuario, factoría de diseño e inicialización. |
| src/Nexo.Web/Infrastructure | Ruta de datos, bloqueo de instancia y hora de la sede. |
| src/Nexo.Web/Pages y wwwroot | Páginas Razor, navegación y recursos locales de Nexo. |
| tests/Nexo.Web.Tests | Batería de integración del acceso y la persistencia. |
| scripts | Arranque, publicación y validación del paquete. |

```
dotnet restore Nexo.sln --locked-mode
dotnet tool restore
dotnet ef --version
dotnet build Nexo.sln --no-restore -c Release -p:UseSharedCompilation=false -m:1 --disable-build-servers
```

La restauración bloqueada valida las dependencias después de añadir sus referencias sin restauración inmediata. La compilación terminó con cero errores y cero advertencias.

## 3. Configurar la aplicación y la persistencia

Estos fragmentos muestran la configuración relevante de los archivos incorporados. La reproducción utiliza las clases completas conservadas en src/Nexo.Web; no requiere completar manualmente los fragmentos.

ApplicationDbContext hereda el modelo técnico de Identity y establece el nombre visible como obligatorio. NexoUser añade el nombre y el último acceso a la cuenta.

```
public sealed class ApplicationDbContext(
    DbContextOptions<ApplicationDbContext> options)
    : IdentityDbContext<NexoUser>(options)
{
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.Entity<NexoUser>().Property(x => x.DisplayName)
            .HasMaxLength(100).IsRequired();
    }
}

public sealed class NexoUser : IdentityUser
{
    public string DisplayName { get; set; } = "";
    public DateTimeOffset? LastAccessUtc { get; set; }
}
```

Program.cs registra el contexto con el proveedor SQLite. DataDirectory resuelve la ruta completa, crea la carpeta y comprueba la escritura. El bloqueo exclusivo impide dos procesos sobre los mismos datos.

```
builder.Services.AddDbContext<ApplicationDbContext>(
    (services, options) => options.UseSqlite(
        new SqliteConnectionStringBuilder {
            DataSource = services.GetRequiredService<DataDirectory>()
                                 .DatabasePath,
            ForeignKeys = true,
            DefaultTimeout = 30
        }.ToString()));
```

La ruta predeterminada es Datos junto al ejecutable; NEXO_DATA_DIR permite indicar otra carpeta. No se necesita un servidor SQL independiente. La configuración ordinaria de appsettings.json mantiene el puerto local y la apertura del navegador:

```
{
  "Nexo": {"Port": 5187, "OpenBrowser": true},
  "AllowedHosts": "localhost;127.0.0.1;[::1]"
}
```

ASP.NET Core Identity gestiona las contraseñas y la sesión. Las páginas protegidas exigen autenticación; la consulta de Administración añade la autorización por rol en servidor.

## 4. Decisiones de implementación y flujo de acceso

Las plantillas de .NET aportan el esqueleto del proyecto; el comportamiento de Nexo está en las clases y páginas incorporadas. Para localizar una función se parte de la petición del navegador y se sigue su PageModel hasta Identity y el contexto de datos. No se identifica la copia de las fuentes con su implementación histórica.

| Componente | Responsabilidad y decisión |
| --- | --- |
| Program.cs | Compone dependencias, sesión, autorización, conexión y arranque. La escucha se limita a 127.0.0.1. |
| Entrar.cshtml y Entrar.cshtml.cs | El formulario envía usuario, contraseña y token; el servidor valida la entrada y las credenciales. |
| UserManager y SignInManager | Identity comprueba el hash, el bloqueo y el perfil. Se evita implementar un algoritmo propio de contraseñas. |
| ApplicationDbContext y NexoUser | EF Core conserva el modelo técnico de cuentas y el último acceso; no representa el modelo completo de la oficina. |
| Perfil.cshtml.cs y Administración | El perfil se obtiene de la identidad autenticada. La consulta administrativa exige el rol en servidor. |
| DataDirectory y DemoAccounts | Resuelven ruta y exclusión de procesos, aplican migraciones e inicializan únicamente cuentas ausentes. |

Un acceso correcto actualiza LastAccessUtc en SQLite y emite la cookie de sesión; la redirección solo admite destinos locales. Una contraseña inválida devuelve un error genérico. El cierre de sesión usa POST y protección antifalsificación. Las pruebas de integración recorren estas peticiones con la aplicación y una base temporal reales.

Razor Pages mantiene cerca cada pantalla y su lógica del servidor. SQLite evita instalar un servicio de base de datos y facilita la entrega en una carpeta; EF Core versiona el esquema. El paquete autocontenido elimina la instalación del runtime para el evaluador. Esta elección se ajusta a una demostración local, no pretende acreditar un despliegue multiusuario en la nube.

La versión de referencia de esta revisión es I01.1, con su migración histórica y su ZIP propio. Esta reproducción didáctica genera una migración independiente en otra carpeta. El manifiesto docs/entregas/I01.1.json distingue ambas procedencias; la segunda no sustituye al paquete de referencia ni modifica el alcance aprobado.

## 5. Generar la migración y revisar el SQL

Una vez incorporado el modelo, se genera una migración nueva en la copia de reproducción. Se recompila para incluirla en el ensamblado y se obtiene el SQL del esquema. No se modifica la migración histórica del repositorio.

```
dotnet ef migrations add InitialAccess --project src/Nexo.Web --output-dir Data/Migrations --configuration Release --no-build
dotnet build Nexo.sln --no-restore -c Release -p:UseSharedCompilation=false -m:1 --disable-build-servers
dotnet ef migrations script 0 --project src/Nexo.Web --configuration Release --no-build --output registros/esquema.sql
```

EF Core generó 20261128001906_InitialAccess.cs, sus metadatos Designer y ApplicationDbContextModelSnapshot.cs. El identificador temporal corresponde a esta reproducción y puede variar en otra ejecución.

> Figura 2. Registro de la migración y del SQL. La comprobación confirma que todavía no existe DatosApp/nexo.db. Véase la captura anotada en el Word o PDF del manual.

Una migración describe cambios del esquema; el archivo SQLite se crea cuando esos cambios se aplican. El esquema.sql permite revisar tablas, claves e índices sin abrir la base.

La factoría de diseño utiliza nexo-design.db como conexión predeterminada de las herramientas. Para crear manualmente otra base se debe pasar --connection de forma explícita; el ejemplo de la última sección usa DatosManual y conserva separada la base de ejecución.

## 6. Crear SQLite con el primer arranque

Antes del primer arranque se comprobó que DatosApp/nexo.db no existía. El script inició la aplicación en el puerto 5191, con su directorio de trabajo en src/Nexo.Web y una ruta de datos independiente. La secuencia equivalente en una consola, partiendo de la raíz de la reproducción, es:

```
$env:NEXO_PORT = '5191'
$env:NEXO_DATA_DIR = Join-Path (Get-Location) 'DatosApp'
$env:NEXO_OPEN_BROWSER = '0'
$env:DOTNET_ENVIRONMENT = 'Production'
Set-Location src/Nexo.Web
dotnet .\bin\Release\net10.0\Nexo.Web.dll
```

Durante el arranque, DemoAccounts.InitializeAsync aplica Database.MigrateAsync y prepara las cuentas ausentes dentro de una transacción. Después se puede abrir http://127.0.0.1:5191 en el navegador. Para los comandos de las secciones siguientes se vuelve a la raíz de la reproducción.

> Figura 3. Inspección real de SQLite en modo de solo lectura, después de la creación y del reinicio. Véase la captura anotada en el Word o PDF del manual.

| Grupo de tablas | Contenido técnico comprobado |
| --- | --- |
| AspNetUsers, AspNetRoles y AspNetUserRoles | Cuentas, perfiles y asignaciones. |
| Cuatro tablas auxiliares de Identity | Claims de usuarios y roles, accesos externos y tokens. |
| __EFMigrationsHistory y __EFMigrationsLock | Migración aplicada y bloqueo de migraciones. |
| sqlite_sequence | Secuencias internas de SQLite. |

Las diez tablas son técnicas. El modelo de oficina, puestos y reservas sigue pendiente; esta base de acceso no representa el modelo completo del producto.

## 7. Inicializar las cuentas y verificar el reinicio

La inicialización aplica primero el esquema. Después crea los perfiles ausentes y las cuentas ficticias de Carlos y Ana, y asigna sus roles. Antes de crear una cuenta comprueba si existe, de modo que un reinicio no la duplica ni restablece su contraseña.

```
var db = services.GetRequiredService<ApplicationDbContext>();
await db.Database.MigrateAsync();
await using var transaction = await db.Database.BeginTransactionAsync();
// Tras preparar los perfiles ausentes, AddAsync comprueba cada cuenta.
await AddAsync("carlos", "Carlos", "Nexo.Carlos2026!", EmployeeRole);
await AddAsync("ana", "Ana", "Nexo.Ana2026!", AdministratorRole);
await transaction.CommitAsync();
```

En la reproducción se realizó un acceso HTTP de Carlos y se leyó SQLite antes de detener el servidor. Después se arrancó el mismo ensamblado sobre la misma carpeta y se compararon los registros.

| Comprobación | Resultado real |
| --- | --- |
| Usuarios y sus identificadores | Iguales antes y después: dos cuentas. |
| Roles y relaciones | Iguales: dos perfiles y dos asignaciones. |
| Migración aplicada | Igual: 20261128001906_InitialAccess. |
| Último acceso de Carlos | Conservado sin realizar otro inicio de sesión. |
| Sesión de prueba | El perfil respondió HTTP 200 tras el reinicio. |
| PRAGMA quick_check | ok. |

La inspección utiliza consultas de solo lectura; no extrae contraseñas ni hashes. Las consultas relevantes son:

```
PRAGMA quick_check;
SELECT MigrationId, ProductVersion FROM __EFMigrationsHistory;
SELECT UserName, DisplayName, LastAccessUtc
FROM AspNetUsers ORDER BY UserName;
SELECT Name FROM AspNetRoles ORDER BY Name;
SELECT COUNT(*) FROM AspNetUserRoles;
```

Los resultados originales están en registros/sqlite-antes-reinicio.json, sqlite-despues-reinicio.json y persistencia.json. La carpeta de datos y sus claves se conservan fuera del control de versiones.

## 8. Comprobar la aplicación en el navegador

La aplicación reconstruida sirvió su formulario real desde http://127.0.0.1:5191. La captura siguiente es un detalle del navegador, no una maqueta ni una imagen de la plantilla genérica.

> Figura 4. Pantalla de acceso de la reproducción del 28/11/2026. Véase la captura anotada en el Word o PDF del manual.

| Persona | Usuario | Perfil |
| --- | --- | --- |
| Carlos | carlos | Empleado |
| Ana | ana | Administrador |

Las contraseñas ficticias de demostración están en el README de Nexo y en la pantalla de acceso. La validación del perfil propio, del rechazo de Administración para el empleado y de la salida se cubre con las pruebas de integración de la sección siguiente.

El servidor temporal se detuvo al terminar la captura. Los datos de la reproducción permanecen guardados; las instancias de Nexo utilizadas antes de esta reproducción no se modificaron.

## 9. Compilar y ejecutar las pruebas

La solución reconstruida se compiló en Release sin errores ni advertencias. A continuación se ejecutaron las pruebas existentes contra carpetas SQLite de prueba independientes:

```
dotnet test Nexo.sln --no-build --no-restore -c Release --disable-build-servers --logger "trx;LogFileName=reproduccion.trx" --results-directory artifacts/pruebas-reproduccion
```

> Figura 5. Registro real de las pruebas de integración de la aplicación reconstruida. Véase la captura anotada en el Word o PDF del manual.

| Validación de esta reproducción | Resultado |
| --- | --- |
| Pruebas de integración | 17 correctas, 0 fallidas y 0 omitidas. |
| ZIP extraído y ejecutado con su runtime | 12 comprobaciones correctas. |

La batería incluye acceso válido e inválido, bloqueo temporal, sesión, antifalsificación, permisos, identidad del perfil propio y persistencia tras reiniciar. El informe TRX conserva los resultados por caso.

La prueba del ZIP comprueba, además, el bucle local, los recursos de la carpeta, la segunda instancia, el puerto ocupado y los errores de ubicación de datos. Los resultados corresponden al ZIP generado en esta reproducción, no a otra publicación anterior.

## 10. Publicar el paquete autocontenido

La publicación usa su propio archivo de bloqueo para Windows x64. Se restaura ese destino y se publica con el runtime 10.0.15 incluido. Los comandos se ejecutan desde la raíz de la reproducción:

```
dotnet restore src/Nexo.Web/Nexo.Web.csproj -r win-x64 -p:RuntimeFrameworkVersion=10.0.15 -p:NuGetLockFilePath=packages.win-x64.lock.json --locked-mode
dotnet publish src/Nexo.Web/Nexo.Web.csproj -c Release -r win-x64 --self-contained true --no-restore -p:RuntimeFrameworkVersion=10.0.15 -p:NuGetLockFilePath=packages.win-x64.lock.json -p:UseSharedCompilation=false -p:PublishSingleFile=false -o artifacts/Nexo-reproduccion-win-x64
```

Se copian INICIAR.cmd y LEEME.txt desde scripts y se comprime la carpeta publicada completa. No se incorpora DatosApp ni la base utilizada durante las pruebas.

```
Copy-Item scripts/INICIAR.cmd artifacts/Nexo-reproduccion-win-x64
Copy-Item scripts/LEEME.txt artifacts/Nexo-reproduccion-win-x64
Compress-Archive -LiteralPath artifacts/Nexo-reproduccion-win-x64 -DestinationPath artifacts/Nexo-reproduccion-win-x64.zip
./scripts/probar-paquete.ps1 -Package ./artifacts/Nexo-reproduccion-win-x64.zip
```

| Elemento publicado | Uso |
| --- | --- |
| Nexo.Web.exe y dependencias | Servidor y runtime de Windows x64. |
| wwwroot | Marca y estilos locales, incluido el ajuste visual del 28/11. |
| appsettings.json | Configuración predeterminada del puerto y navegador. |
| INICIAR.cmd y LEEME.txt | Arranque e instrucciones para el evaluador. |

El evaluador extrae el ZIP y ejecuta INICIAR.cmd sin instalar el SDK, Python ni un servidor de base de datos. En su primera ejecución se genera Datos junto al ejecutable. El puerto predeterminado del paquete sigue siendo 5187; 5191 se utilizó únicamente para esta reproducción.

ZIP verificado: Nexo-reproduccion-win-x64.zip. SHA256:

```
ECDECC48B566933176B852AC9FCB3C5066E67E1B0145FF089AC2ABC1A3CDE7C4
```

## 11. Repetir el procedimiento y consultar las evidencias

El script scripts/reproducir-creacion.ps1 conserva los registros por fase y rechaza sobrescribir una reproducción. Se ejecuta desde la raíz de las fuentes de Nexo con PowerShell 7, SDK .NET 10 y Python 3 para las inspecciones de SQLite. Python no forma parte del runtime de la aplicación.

```
$destino = './artifacts/mi-reproduccion'
$fases = 'Preparar','Configurar','Migrar','Arrancar',
         'Comprobar','Verificar','Publicar','Detener'
foreach ($fase in $fases) {
    ./scripts/reproducir-creacion.ps1 -Fase $fase -Destino $destino -Puerto 5191 -PythonPath python
}
```

Para comprobar la vía manual de EF Core, la fase Comprobar crea una segunda base separada. El fragmento equivalente cambia a la raíz de la copia y prepara la carpeta de datos. Se indica la conexión expresamente para no usar por accidente nexo-design.db:

```
Set-Location $destino
New-Item -ItemType Directory -Path DatosManual -Force
$baseManual = Join-Path (Get-Location) 'DatosManual/nexo.db'
dotnet ef database update --project src/Nexo.Web --configuration Release --no-build --connection "Data Source=$baseManual"
```

El resultado de esa vía manual fue diez tablas, una migración y cero usuarios y roles: database update aplica el esquema, mientras las cuentas se cargan al arrancar Nexo. La fase crea antes la carpeta DatosManual.

Registros completos: artifacts/reproduccion-20261128-r2/registros. Incluyen comandos y códigos de salida, SQL generado, hashes de las 37 fuentes incorporadas, inspecciones SQLite y comparación del reinicio. Los originales de las capturas y sus encuadres se conservan junto a sus manifiestos de procedencia.

Si una fase falla, se revisa su registro y se utiliza otro destino para una nueva reproducción. Un puerto ocupado no se libera terminando procesos ajenos. Las claves y archivos de datos no se añaden al repositorio.

Referencias técnicas: dotnet new y herramientas de EF Core en Microsoft Learn. Las instrucciones y resultados de este manual se contrastan con las fuentes y los registros locales de Nexo.

[Microsoft Learn sobre dotnet new](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-new)

[Microsoft Learn sobre migraciones de EF Core](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/managing)

[Microsoft Learn sobre la CLI de EF Core](https://learn.microsoft.com/en-us/ef/core/cli/dotnet)
