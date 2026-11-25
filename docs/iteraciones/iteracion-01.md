# Iteración 1 · Base local y acceso

Periodo de trabajo: 25 de noviembre–8 de diciembre de 2026.
Vista de seguimiento: https://github.com/users/CarlosCorCha/projects/1/views/3

## Objetivo y límites

Obtener un primer incremento ejecutable en Windows x64: arranque local, SQLite y acceso con dos perfiles de demostración.
La sesión y la autorización se comprueban en servidor.
La interfaz y los estilos se sirven desde la propia carpeta.
No se incorporan nuevos requisitos al backlog aprobado.
La fecha de inicio refleja el trabajo real; no se reconstruyen iteraciones pasadas.
Los periodos futuros vacíos que crea automáticamente GitHub no constituyen compromisos de planificación.

| Elemento original | Aportación en esta iteración | Condición para cerrar el elemento completo |
|---|---|---|
| GE01 · Repositorio y tablero de seguimiento | Repositorio, estructura y comandos | Evidencia disponible y revisión de Carlos |
| GE02 · Planificación y revisión de iteraciones | Objetivo, tareas y vista propia | Dedicación real, informe, vídeo, revisión, retrospectiva y próxima selección |
| ET01 · Arquitectura y contratos internos | Componentes y contratos del circuito | Revisión del diseño y sus límites transaccionales |
| ET02 · Modelo completo y restricciones de datos | Esquema técnico de acceso y migración inicial | Pendiente el modelo de dominio completo y los 25 CRUD diseñados |
| ET05 · Datos ficticios y escenarios de demostración | Carlos empleado y Ana administradora | Pendientes organización, equipos, puestos y solicitudes de oficina |
| HU01 · Arranque local y persistencia | ZIP, bucle local, reinicio e inicialización idempotente | El criterio del plano sin Internet se verificará al implementar disponibilidad |
| HU02 · Inicio y cierre de sesión | Acceso, salida, hash, antifalsificación y errores | Pruebas superadas y verificación final de Carlos |
| HU03 · Permisos según el perfil | Rutas protegidas y separación de áreas | Pendientes permisos sobre solicitudes propias y ajenas, catálogos e informes |

La selección no modifica prioridades ni puntos de historia aprobados.
Los elementos con criterios pendientes no pasan a Hecho.

## Tareas de la iteración

Son estimaciones iniciales de trabajo, no horas efectivamente dedicadas.
No se comparan directamente con puntos de historia.

| Tarea | Vinculación al backlog original | Resultado verificable | Estimación |
|---|---|---|---:|
| T01 · Estructura y contratos | [GE01](https://github.com/CarlosCorCha/nexo/issues/1), [ET01](https://github.com/CarlosCorCha/nexo/issues/3) | Solución, responsabilidades y documentación | 2 h |
| T02 · Persistencia y cuentas | [ET02](https://github.com/CarlosCorCha/nexo/issues/4), [ET05](https://github.com/CarlosCorCha/nexo/issues/5) | Migración, dos cuentas y semilla idempotente | 2 h |
| T03 · Arranque y distribución | [HU01](https://github.com/CarlosCorCha/nexo/issues/6) | Ejecutable local, validación de carpeta y puerto | 3 h |
| T04 · Sesión | [HU02](https://github.com/CarlosCorCha/nexo/issues/7) | Entrar, salir y gestionar errores | 3 h |
| T05 · Autorización | [HU03](https://github.com/CarlosCorCha/nexo/issues/8) | Áreas separadas y rechazo por acceso directo | 2 h |
| T06 · Verificación y manual | [GE01](https://github.com/CarlosCorCha/nexo/issues/1), [GE02](https://github.com/CarlosCorCha/nexo/issues/2), [HU01](https://github.com/CarlosCorCha/nexo/issues/6), [HU02](https://github.com/CarlosCorCha/nexo/issues/7), [HU03](https://github.com/CarlosCorCha/nexo/issues/8) | Pruebas, capturas reales e instrucciones | 2 h |

## Contratos y comportamiento esperado

- El navegador solicita páginas; las reglas y los permisos se aplican en ASP.NET Core.
- Identity valida credenciales y genera una cookie de sesión; EF Core persiste en SQLite.
- Los datos y claves se conservan en `Datos`, junto al ejecutable, salvo configuración explícita de otra carpeta.
- Las migraciones se ejecutan antes de admitir peticiones; arrancar de nuevo no duplica usuarios ni restablece sus contraseñas.
- Solo se escucha en `127.0.0.1`; un puerto ocupado no provoca el cierre de otro proceso.
- Una cuenta empleada no recibe datos de administración aunque escriba directamente la dirección.
- El identificador del perfil consultado procede de la sesión, nunca de un parámetro enviado por el cliente.
- Una petición POST sin token antifalsificación se rechaza.
- No se añaden registro de usuarios, cambio de contraseñas, reservas ni catálogos en este incremento.

## Revisión

Carlos establece prioridades y verifica el incremento antes de aceptarlo.
Codex asiste en implementación, pruebas y documentación; los registros describen las acciones realizadas y sus resultados reales.
La aceptación del responsable y la retrospectiva se registrarán cuando se lleve a cabo la revisión, sin anticiparlas.

## Registro del avance

| Fecha | Avance comprobado | Evidencia | Dedicación humana |
|---|---|---|---|
| 25/11/2026 | Vista de la iteración y ocho elementos seleccionados | Tablero y captura de planificación | Pendiente de registrar por Carlos |
| 25/11/2026 | Estructura, arquitectura, acceso, SQLite y paquete local | Fuentes y migración versionadas | Pendiente de registrar por Carlos |
| 25/11/2026 | Compilación sin advertencias, 17 pruebas de integración y 12 comprobaciones del ZIP correctas | [Informe generado](../manual/verificacion.json) y scripts reproducibles | Pendiente de registrar por Carlos |
| 25/11/2026 | Recorrido visual con ambos perfiles y capturas | [Manual](../manual/README.md) | Pendiente de registrar por Carlos |

Las estimaciones no se convierten en un parte de horas.
El informe de cierre, el vídeo de cinco minutos, la retrospectiva y la siguiente planificación quedan pendientes de la revisión del incremento.
