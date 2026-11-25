# Nexo · Oficinas híbridas

Aplicación académica para coordinar la asistencia a una oficina híbrida.
El primer incremento implementa arranque local, persistencia y acceso con dos perfiles.
El plano, las reservas, los catálogos y los automatismos se desarrollarán conforme al backlog aprobado.

## Probar el paquete de Windows

Extrae el ZIP completo en una carpeta con escritura y ejecuta `INICIAR.cmd`.
Se abre `http://127.0.0.1:5187`; mantén abierta la consola mientras utilizas Nexo.
El paquete incluye el runtime .NET para Windows x64 y recursos locales, sin servicios cloud.
Los datos se crean en `Datos` junto al ejecutable y se conservan al reiniciar.

| Persona | Usuario | Contraseña de demostración | Perfil |
|---|---|---|---|
| Carlos | `carlos` | `Nexo.Carlos2026!` | Empleado |
| Ana | `ana` | `Nexo.Ana2026!` | Administrador |

Son cuentas ficticias; no contienen datos ni credenciales de empresa.
Entra como Carlos y consulta el perfil; cierra sesión y repite como Ana para comprobar la consulta de administración.
Carlos no puede acceder por URL directa a `/Administracion`.

## Desarrollar y verificar

Requiere el SDK .NET 10 indicado en `global.json`.

```powershell
dotnet restore Nexo.sln --locked-mode
dotnet run --project src/Nexo.Web --no-launch-profile
```

```powershell
./scripts/validar.ps1
dotnet tool restore
dotnet ef migrations list --project src/Nexo.Web
./scripts/publicar.ps1
```

`validar.ps1` ejecuta compilación y pruebas de integración sobre carpetas SQLite temporales.
`publicar.ps1` genera el ZIP autocontenido en `artifacts`; rechaza sobreescribir una publicación existente.
Se puede definir `NEXO_PORT` para elegir otro puerto y `NEXO_OPEN_BROWSER=0` para omitir la apertura del navegador.
`NEXO_DATA_DIR` permite una carpeta alternativa de datos.
Las migraciones se aplican al arrancar; no se precisa un comando de creación manual de base de datos.

## Documentación y seguimiento

- [Primera iteración y criterios pendientes](docs/iteraciones/iteracion-01.md).
- [Arquitectura y contratos](docs/arquitectura.md).
- [Manual de implementación y evidencias](docs/manual/README.md).
- [Tablero de la primera iteración](https://github.com/users/CarlosCorCha/projects/1/views/3).
- [Backlog aprobado](https://github.com/users/CarlosCorCha/projects/1).

Carlos prioriza y verifica el incremento antes de aceptarlo.
Se utiliza asistencia de Codex para implementar, comprobar y documentar el software.
