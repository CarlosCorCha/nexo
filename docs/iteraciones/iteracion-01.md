# Iteración 1 · Base local y acceso

Periodo de trabajo: 25–30 de noviembre de 2026.
Versión de planificación: 0.1, revisada el 25/11/2026.
Vista de seguimiento: https://github.com/users/CarlosCorCha/projects/1/views/3

## Objetivo y límites

Obtener y verificar un primer incremento ejecutable en Windows x64 que arranque desde una carpeta, cree y conserve su base SQLite y permita iniciar y cerrar sesión con los perfiles Empleado y Administrador.
La sesión y la autorización se comprueban en servidor.
La interfaz y los estilos se sirven desde la propia carpeta.
No se añaden funcionalidades al backlog aprobado.

## Ajuste de calendario y estimación

Se adelanta el cierre del 8 de diciembre al 30 de noviembre para respetar el plazo del aula. El inicio permanece en el 25 de noviembre, fecha real del arranque. Esta primera iteración tiene excepcionalmente seis días naturales; las siguientes recuperarán la duración ordinaria de siete a veintiún días. No existe autorización de prórroga.
La demostración y los dos documentos correspondientes al primer cierre se prepararán para el 30/11/2026, antes de las 23:59 CET.
La planificación se presenta en su actividad propia; el informe de cierre y la planificación siguiente comparten otro PDF.
No se ha enviado ninguna entrega al campus ni se ha confirmado aún la aceptación del incremento.
El desglose conserva el trabajo técnico y hace explícita la preparación del informe, el vídeo y la planificación siguiente. La referencia agregada pasa de 14 a 16 horas estimadas. No representa horas humanas efectivamente dedicadas ni una conversión de los puntos de historia.
La duración excepcional se hace explícita porque la pauta ordinaria del backlog es de siete a veintiún días.

## Selección y compromiso

| Elemento original | Prioridad | PH | Tratamiento en la iteración |
|---|---:|---:|---|
| [GE01 · Repositorio y tablero de seguimiento](https://github.com/CarlosCorCha/nexo/issues/1) | 100 | 1 | Cierre previsto tras revisión |
| [GE02 · Planificación y revisión de iteraciones](https://github.com/CarlosCorCha/nexo/issues/2) | 99 | 3 | Trabajo de gestión de esta iteración |
| [ET01 · Arquitectura y contratos internos](https://github.com/CarlosCorCha/nexo/issues/3) | 98 | 2 | Cierre previsto tras revisión del diseño |
| [ET02 · Modelo completo y restricciones de datos](https://github.com/CarlosCorCha/nexo/issues/4) | 97 | 5 | Aportación parcial al modelo completo |
| [ET05 · Datos ficticios y escenarios de demostración](https://github.com/CarlosCorCha/nexo/issues/5) | 96 | 3 | Aportación parcial a los datos de demostración |
| [HU01 · Arranque local y persistencia](https://github.com/CarlosCorCha/nexo/issues/6) | 95 | 2 | Aportación parcial al arranque y persistencia |
| [HU02 · Inicio y cierre de sesión](https://github.com/CarlosCorCha/nexo/issues/7) | 94 | 3 | Cierre previsto tras aceptación |
| [HU03 · Permisos según el perfil](https://github.com/CarlosCorCha/nexo/issues/8) | 93 | 3 | Aportación parcial a los permisos del circuito |

Los 22 PH corresponden a los elementos de referencia, incluidos los que reciben aportaciones parciales.
No representan 22 PH terminados ni se convierten en horas.
No se modifican los criterios originales; los elementos parciales siguen abiertos.

## Tareas técnicas y validación

Las tareas son previsiones de esfuerzo, no un parte de dedicación humana.
Cada tarea queda vinculada a un único elemento para evitar contar sus horas dos veces.

### Repositorio y tablero de seguimiento

Preparar Git, el repositorio y un tablero de GitHub Projects para versionar el trabajo y mantener su seguimiento.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| GE01-T01 | Organizar fuentes, comandos y enlaces del repositorio | 0,25 |
| GE01-T02 | Ajustar la vista de iteración y comprobar acceso y campos del tablero | 0,5 |

Validación: Abrir la vista sin sesión: deben verse los ocho elementos y sus prioridades, puntos y estados. Abrir sus enlaces al código y al plan.
Evidencia prevista: Tablero público, README y captura fechada.
Tratamiento: Cierre previsto tras revisión.

### Planificación y revisión de iteraciones

Gestionar iteraciones individuales de siete a veintiún días y adaptar el backlog con las evidencias de cada incremento.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| GE02-T01 | Formalizar objetivo, fechas, tareas y validación de la primera iteración | 1 |
| GE02-T02 | Preparar informe de cierre y planificación siguiente en un único PDF | 1 |
| GE02-T03 | Revisar el incremento, registrar retrospectiva y preparar vídeo de hasta cinco minutos | 1 |

Validación: Comparar el plan con el tablero y el avance real. Al cerrar deben existir informe, vídeo accesible, revisión, retrospectiva y plan siguiente con fechas coherentes.
Evidencia prevista: Planificación PDF; informe y vídeo pendientes del cierre.
Tratamiento: Trabajo de gestión de esta iteración.

### Arquitectura y contratos internos

Definir la separación entre presentación, servicios de negocio y acceso a datos para sostener el circuito local.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| ET01-T01 | Describir componentes, llamadas y separación de responsabilidades | 0,5 |
| ET01-T02 | Definir contratos, errores y transacciones del circuito aprobado | 0,5 |
| ET01-T03 | Contrastar los contratos con las reglas de reserva y los límites de implementación | 0,25 |

Validación: Revisar el diagrama y los contratos de reserva, confirmación, cancelación y asignación: entradas, resultados, errores y límites transaccionales deben estar definidos.
Evidencia prevista: docs/arquitectura.md y revisión del diseño.
Tratamiento: Cierre previsto tras revisión del diseño.

### Modelo completo y restricciones de datos

Modelar el producto completo y preparar la persistencia del prototipo conservando la integridad de sus relaciones.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| ET02-T01 | Definir el esquema técnico inicial de acceso y su ubicación de datos | 0,25 |
| ET02-T02 | Generar y verificar la migración inicial reproducible de SQLite | 0,5 |

Validación: Arrancar sobre una carpeta vacía: se crea SQLite con la migración de acceso. Al reiniciar se conservan los registros. El modelo de dominio completo continúa pendiente.
Evidencia prevista: Migración versionada y prueba de reinicio.
Tratamiento: Aportación parcial al modelo completo.

### Datos ficticios y escenarios de demostración

Preparar datos reproducibles de una organización, sede, planta, cuatro zonas y dieciséis puestos para evaluar sin información empresarial real.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| ET05-T01 | Precargar Carlos como empleado y Ana como administradora | 0,25 |
| ET05-T02 | Comprobar que reiniciar no duplica cuentas ni restablece contraseñas existentes | 0,5 |

Validación: Arrancar dos veces: deben seguir existiendo las mismas cuentas y perfiles, sin duplicados ni pérdida de datos. Los escenarios de oficina se completarán en iteraciones posteriores.
Evidencia prevista: Inicialización y prueba automatizada de idempotencia.
Tratamiento: Aportación parcial a los datos de demostración.

### Arranque local y persistencia

Como evaluador, quiero arrancar Nexo en mi equipo y conservar sus datos para revisar el circuito sin preparar un entorno de desarrollo.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| HU01-T01 | Preparar arranque local, carpeta de datos y errores de inicio | 1 |
| HU01-T02 | Publicar el ZIP Windows x64 con runtime y recursos propios | 1 |
| HU01-T03 | Probar el ZIP extraído, el reinicio, el puerto ocupado y las instrucciones | 1,25 |

Validación: Extraer en una carpeta con escritura y ejecutar INICIAR.cmd: debe abrir el navegador local y conservar el último acceso tras reiniciar. Un puerto ocupado debe producir un error comprensible. El plano y la persistencia de reservas siguen pendientes.
Evidencia prevista: Comprobaciones del paquete y capturas de acceso y perfil.
Tratamiento: Aportación parcial al arranque y persistencia.

### Inicio y cierre de sesión

Como usuario de demostración, quiero identificarme y cerrar la sesión para acceder con mi perfil y proteger mis operaciones.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| HU02-T01 | Implementar acceso y salida con Identity, hash y sesión | 1,5 |
| HU02-T02 | Probar credenciales válidas e inválidas, antifalsificación y redirecciones | 1,5 |
| HU02-T03 | Revisar ambos perfiles en el navegador y documentar el recorrido | 0,75 |

Validación: Carlos y Ana deben acceder con su perfil; una contraseña errónea no crea sesión ni revela la cuenta. Tras salir, /Perfil exige autenticación. Verificar hash y rechazo de peticiones sin token.
Evidencia prevista: Pruebas de acceso y capturas de ambos perfiles; aceptación pendiente.
Tratamiento: Cierre previsto tras aceptación.

### Permisos según el perfil

Como empleado, quiero gestionar mis solicitudes y consultar mi equipo, mientras la administración queda reservada al perfil autorizado.

| Tarea | Resultado de trabajo | Horas estimadas |
|---|---|---:|
| HU03-T01 | Aplicar autorización en servidor a las áreas disponibles | 1 |
| HU03-T02 | Contrastar la matriz de permisos y la parametrización prevista en el modelo completo | 0,5 |
| HU03-T03 | Probar acceso directo restringido y perfil derivado de la sesión | 1 |

Validación: Con Carlos, /Administracion debe rechazarse sin datos restringidos; con Ana debe permitirse. Alterar un identificador no cambia la identidad del perfil propio. Los permisos sobre solicitudes, catálogos e informes siguen pendientes.
Evidencia prevista: Pruebas de autorización, matriz y captura de acceso rechazado.
Tratamiento: Aportación parcial a los permisos del circuito.

## Contratos y comportamiento esperado

- Las reglas y los permisos se aplican en ASP.NET Core, desde cualquier cliente.
- Identity valida las credenciales y crea la sesión; EF Core persiste en SQLite.
- Los datos y claves se conservan en Datos, junto al ejecutable, salvo configuración explícita.
- La inicialización no duplica usuarios ni restablece sus contraseñas.
- El servidor solo escucha en 127.0.0.1 y no cierra procesos que ocupen el puerto.
- El perfil propio se deriva de la sesión; una petición POST sin token se rechaza.
- Los permisos completos sobre reservas, catálogos e informes se verifican cuando exista ese circuito.
- Debe contrastarse la parametrización de perfiles y tareas con el modelo completo antes de cerrar la historia de permisos.

## Evidencias disponibles y revisión

Las pruebas del 25/11/2026 registran 17 casos de integración y 12 comprobaciones del ZIP correctas.
Los resultados no sustituyen a la aceptación final de Carlos ni a la validación del plano, las reservas o el modelo completo.
La red del equipo no se desconectó: se comprobaron recursos locales; el recorrido sin Internet queda pendiente.
Carlos establece prioridades y verifica el incremento antes de aceptarlo.
Codex asiste en implementación, pruebas y documentación; los registros describen acciones y resultados reales.
El informe de cierre, el vídeo, la retrospectiva y el siguiente plan se registrarán cuando se realicen.

| Fecha | Avance comprobado | Evidencia | Dedicación humana |
|---|---|---|---|
| 25/11/2026 | Estructura, acceso, SQLite y paquete local | Fuentes y migración versionadas | Pendiente de registrar por Carlos |
| 25/11/2026 | 17 pruebas de integración y 12 comprobaciones del ZIP correctas | [Informe](../manual/verificacion.json) | Pendiente de registrar por Carlos |
| 25/11/2026 | Recorrido visual de ambos perfiles y capturas | [Manual](../manual/README.md) | Pendiente de registrar por Carlos |
| 25/11/2026 | Ajuste al 30/11 y desglose de tareas por elemento | Planificación 0.1 y tablero | Pendiente de registrar por Carlos |

## Preparación del cierre del 30 de noviembre

- Revisión de Carlos sobre acceso con ambos perfiles, reinicio y rechazo de administración para el empleado.
- Registrar solo los elementos y criterios efectivamente aceptados; mantener los remanentes abiertos.
- Completar el informe de avance con resultados, problemas, retrospectiva y próxima planificación.
- Grabar y comprobar el acceso al vídeo real de hasta cinco minutos.
- Incluir enlaces a tablero, repositorio y vídeo en el texto de la entrega del aula.
- Completar los apartados finales de la entrega antes de enviarla.

La fecha orientativa de inicio de la segunda iteración es el 1 de diciembre; su selección y compromiso se fijarán tras esta revisión.
Las estimaciones no se convierten automáticamente en dedicación real.

## Revisión complementaria del 27/11/2026

La [preparación del cierre](cierre-01.md) recoge el recorrido de Carlos y las comprobaciones complementarias autorizadas.
El acceso directo de Carlos a Administración se rechaza y el reinicio conserva los datos técnicos, sus identificadores y el último acceso.
Repositorio/seguimiento, arquitectura/contratos e inicio/salida se consideran terminados; los otros cinco elementos siguen parciales.
Este corte actualiza la revisión pendiente descrita en el plan del 25/11, sin alterar sus registros históricos.
El cierre previsto permanece el 30/11 y la entrega al campus no se ha realizado.
