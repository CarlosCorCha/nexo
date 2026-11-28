# Planificación 1 de Nexo

Versión documental 1.1 para presentación el 28/11/2026. Plan inicial elaborado el 25/11/2026.
Periodo de trabajo: 25–30 de noviembre de 2026.

Esta entrega formaliza la planificación elaborada el 25/11/2026 para la primera iteración de Nexo. Conservo su objetivo, selección de elementos y estimaciones. El periodo termina el 30/11; los resultados y la planificación siguiente se presentarán en la actividad de cierre correspondiente.

Responsable: Carlos Daniel Cordero Chaparro. Modalidad individual.

## Objetivo e incremento esperado

Obtener y verificar un primer incremento ejecutable en Windows x64 que arranque desde una carpeta, cree y conserve su base SQLite y permita iniciar y cerrar sesión con los perfiles Empleado y Administrador.

El incremento se centra en la estructura técnica, la persistencia inicial y el acceso. Se conserva el diseño del producto completo y la implementación prevista de cinco de sus veinticinco mantenimientos. El plano, las reservas y los catálogos se abordarán en las siguientes iteraciones.

## Fechas y estimación

El calendario inicial finalizaba el 8 de diciembre y se ajustó al 30 de noviembre, plazo máximo del aula para esta planificación y el primer cierre. Mantengo el inicio real del 25/11. Esta primera iteración comprende excepcionalmente seis días naturales; las siguientes recuperarán la duración ordinaria de siete a veintiún días prevista en el backlog.

Las 21 tareas suman 16 horas estimadas. La referencia agregada pasa de 14 a 16 al explicitar dos tareas de gestión ya cubiertas por el backlog: preparar el informe con la planificación siguiente (1 h estimada), y revisar el incremento con retrospectiva y vídeo (1 h estimada). Son previsiones de esfuerzo; no registran horas trabajadas.

Las horas son estimaciones del esfuerzo previsto para las tareas de esta iteración. No son un registro de horas trabajadas por mí. La dedicación real se documentará por separado en el informe de cierre.

## Selección de elementos

| Elemento | Prioridad | PH | Contribución prevista |
|---|---:|---:|---|
| [GE01 · Repositorio y tablero de seguimiento](https://github.com/CarlosCorCha/nexo/issues/1) | 100 | 1 | Cierre previsto tras revisión |
| [GE02 · Planificación y revisión de iteraciones](https://github.com/CarlosCorCha/nexo/issues/2) | 99 | 3 | Trabajo de gestión de esta iteración |
| [ET01 · Arquitectura y contratos internos](https://github.com/CarlosCorCha/nexo/issues/3) | 98 | 2 | Cierre previsto tras revisión del diseño |
| [ET02 · Modelo completo y restricciones de datos](https://github.com/CarlosCorCha/nexo/issues/4) | 97 | 5 | Aportación parcial al modelo completo |
| [ET05 · Datos ficticios y escenarios de demostración](https://github.com/CarlosCorCha/nexo/issues/5) | 96 | 3 | Aportación parcial a los datos de demostración |
| [HU01 · Arranque local y persistencia](https://github.com/CarlosCorCha/nexo/issues/6) | 95 | 2 | Aportación parcial al arranque y persistencia |
| [HU02 · Inicio y cierre de sesión](https://github.com/CarlosCorCha/nexo/issues/7) | 94 | 3 | Cierre previsto tras aceptación |
| [HU03 · Permisos según el perfil](https://github.com/CarlosCorCha/nexo/issues/8) | 93 | 3 | Aportación parcial a los permisos del circuito |

Los 22 PH conservan la estimación relativa de los ocho elementos completos del backlog. Las 16 horas estimadas cubren solo las tareas seleccionadas para esta iteración, incluidas las aportaciones parciales. No se convierten puntos en horas ni se dan por terminados los elementos que mantengan criterios pendientes.

Leyenda: HU = historia de usuario; ET = tarea técnica; GE = gestión; PH = puntos de historia; T = tarea de la iteración. La prioridad cien es la máxima.

## Tareas y validación previstas

### Repositorio y tablero de seguimiento

Preparar Git, el repositorio y un tablero de GitHub Projects para versionar el trabajo y mantener su seguimiento.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| GE01-T01 | Organizar fuentes, comandos y enlaces del repositorio | 0,25 |
| GE01-T02 | Ajustar la vista de iteración y comprobar acceso y campos del tablero | 0,5 |

Cierre previsto tras revisión.
Abrir la vista sin sesión: deben verse los ocho elementos y sus prioridades, puntos y estados. Abrir sus enlaces al código y al plan.

### Planificación y revisión de iteraciones

Gestionar iteraciones individuales de siete a veintiún días y adaptar el backlog con las evidencias de cada incremento.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| GE02-T01 | Formalizar objetivo, fechas, tareas y validación de la primera iteración | 1 |
| GE02-T02 | Preparar informe de cierre y planificación siguiente en un único PDF | 1 |
| GE02-T03 | Revisar el incremento, registrar retrospectiva y preparar vídeo de hasta cinco minutos | 1 |

Trabajo de gestión de esta iteración.
Comparar el plan con el tablero y el avance real. Al cerrar deben existir informe, vídeo accesible, revisión, retrospectiva y plan siguiente con fechas coherentes.

### Arquitectura y contratos internos

Definir la separación entre presentación, servicios de negocio y acceso a datos para sostener el circuito local.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| ET01-T01 | Describir componentes, llamadas y separación de responsabilidades | 0,5 |
| ET01-T02 | Definir contratos, errores y transacciones del circuito aprobado | 0,5 |
| ET01-T03 | Contrastar los contratos con las reglas de reserva y los límites de implementación | 0,25 |

Cierre previsto tras revisión del diseño.
Revisar el diagrama y los contratos de reserva, confirmación, cancelación y asignación: entradas, resultados, errores y límites transaccionales deben estar definidos.

### Modelo completo y restricciones de datos

Modelar el producto completo y preparar la persistencia del prototipo conservando la integridad de sus relaciones.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| ET02-T01 | Definir el esquema técnico inicial de acceso y su ubicación de datos | 0,25 |
| ET02-T02 | Generar y verificar la migración inicial reproducible de SQLite | 0,5 |

Aportación parcial al modelo completo.
Arrancar sobre una carpeta vacía: se crea SQLite con la migración de acceso. Al reiniciar se conservan los registros. El modelo de dominio completo continúa pendiente.

### Datos ficticios y escenarios de demostración

Preparar datos reproducibles de una organización, sede, planta, cuatro zonas y dieciséis puestos para evaluar sin información empresarial real.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| ET05-T01 | Precargar Carlos como empleado y Ana como administradora | 0,25 |
| ET05-T02 | Comprobar que reiniciar no duplica cuentas ni restablece contraseñas existentes | 0,5 |

Aportación parcial a los datos de demostración.
Arrancar dos veces: deben seguir existiendo las mismas cuentas y perfiles, sin duplicados ni pérdida de datos. Los escenarios de oficina se completarán en iteraciones posteriores.

### Arranque local y persistencia

Como evaluador, quiero arrancar Nexo en mi equipo y conservar sus datos para revisar el circuito sin preparar un entorno de desarrollo.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| HU01-T01 | Preparar arranque local, carpeta de datos y errores de inicio | 1 |
| HU01-T02 | Publicar el ZIP Windows x64 con runtime y recursos propios | 1 |
| HU01-T03 | Probar el ZIP extraído, el reinicio, el puerto ocupado y las instrucciones | 1,25 |

Aportación parcial al arranque y persistencia.
Extraer en una carpeta con escritura y ejecutar INICIAR.cmd: debe abrir el navegador local y conservar el último acceso tras reiniciar. Un puerto ocupado debe producir un error comprensible. El plano y la persistencia de reservas siguen pendientes.

### Inicio y cierre de sesión

Como usuario de demostración, quiero identificarme y cerrar la sesión para acceder con mi perfil y proteger mis operaciones.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| HU02-T01 | Implementar acceso y salida con Identity, hash y sesión | 1,5 |
| HU02-T02 | Probar credenciales válidas e inválidas, antifalsificación y redirecciones | 1,5 |
| HU02-T03 | Revisar ambos perfiles en el navegador y documentar el recorrido | 0,75 |

Cierre previsto tras aceptación.
Carlos y Ana deben acceder con su perfil; una contraseña errónea no crea sesión ni revela la cuenta. Tras salir, /Perfil exige autenticación. Verificar hash y rechazo de peticiones sin token.

### Permisos según el perfil

Como empleado, quiero gestionar mis solicitudes y consultar mi equipo, mientras la administración queda reservada al perfil autorizado.

| Tarea | Trabajo previsto | Horas estimadas |
|---|---|---:|
| HU03-T01 | Aplicar autorización en servidor a las áreas disponibles | 1 |
| HU03-T02 | Contrastar la matriz de permisos y la parametrización prevista en el modelo completo | 0,5 |
| HU03-T03 | Probar acceso directo restringido y perfil derivado de la sesión | 1 |

Aportación parcial a los permisos del circuito.
Con Carlos, /Administracion debe rechazarse sin datos restringidos; con Ana debe permitirse. Alterar un identificador no cambia la identidad del perfil propio. Los permisos sobre solicitudes, catálogos e informes siguen pendientes.

## Condiciones de aceptación del incremento

El servidor aplicará autenticación y autorización; las comprobaciones de URL directa complementarán la navegación con ambos perfiles.
El arranque creará SQLite y las cuentas ausentes, conservará los datos al reiniciar y mostrará errores comprensibles sin cerrar procesos ajenos.
Cada comprobación se relacionará con el criterio original, los datos utilizados y el resultado obtenido. Un criterio sin cubrir mantendrá abierto su elemento.
El modelo completo de oficina, la persistencia de reservas, el plano y los permisos sobre el circuito de negocio conservan sus validaciones futuras.

## Entrega del cierre

El 30/11 presentaré el informe de la primera iteración y la planificación de la segunda en un único PDF, dentro de su propia actividad. Ese cierre incluirá los resultados, incidencias, dedicación registrada, revisión y retrospectiva, además del enlace accesible a un vídeo de hasta cinco minutos.

Esta planificación contiene el trabajo previsto. El estado de ejecución se conserva en el tablero y en los registros fechados; no se presenta como parte del informe de cierre.

[Vista de la primera iteración](https://github.com/users/CarlosCorCha/projects/1/views/3)
[Código del incremento de referencia](https://github.com/CarlosCorCha/nexo/tree/d3cd4f3576354fd0f5496f30299214242a5e278e)

Referencia académica: Sobre la planificación y cierre de las iteraciones, disponible en Materiales de la práctica.
