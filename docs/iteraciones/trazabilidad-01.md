# Trazabilidad de la primera iteración

Versión I01.1. Corte real: 28/11/2026. Periodo previsto: 25–30/11/2026.

Los textos de aceptación se conservan literalmente del backlog aprobado 1.4. El identificador de criterio corresponde a su posición original. Cubierto exige una comprobación concreta; Parcial conserva el remanente indicado.

La revisión de código y documentos constituye evidencia de diseño; las pruebas automatizadas y del ZIP constituyen evidencia de ejecución. Los archivos TRX y las capturas originales se conservan localmente con las huellas del manifiesto de versión.

## Criterios y resultados

| Elemento y criterio | Criterio aprobado | Estado | Comprobación | Resultado y remanente |
|---|---|---|---|---|
| GE01-CA01 | El repositorio contiene las fuentes y las instrucciones; el tablero registra identificador, prioridad, estimación, criterio de aceptación, responsable y estado de cada elemento. | Cubierto | Repositorio y vistas con campos y enlaces | Revisión del README y del tablero público; fuentes e instrucciones versionadas. |
| GE01-CA02 | Se dispone de columnas Por hacer, En curso, En revisión y Hecho; las tareas se vinculan a su historia y los enlaces reales se incorporan cuando estén creados. | Cubierto | Vistas y tareas vinculadas al elemento | Cuatro estados y selección original; desglose de 21 tareas en este registro. |
| GE02-CA01 | Cada planificación fija objetivo, fechas, historias seleccionadas, tareas estimadas en horas y dedicación real; se mantiene un registro breve del trabajo y los impedimentos. | Parcial | Plan de 21 tareas; dedicación confirmada | Periodo inicial de seis días, excepción documentada; 16 h estimadas y 3 h personales de ámbito distinto. |
| GE02-CA02 | Cada cierre incluye informe, vídeo de cinco minutos, revisión, retrospectiva y próxima iteración. Un cambio de alcance registra motivo, efecto y aprobación cuando corresponda. | Pendiente | Informe y planificación preparados | Vídeo definitivo y revisión final de declaración de IA aplazados por Carlos. El elemento permanece abierto. |
| ET01-CA01 | Existe un diagrama con navegador, servidor local, SQLite y procesos periódicos, indicando responsabilidades y llamadas. | Cubierto | docs/arquitectura.md, diagrama y responsabilidades | Separación entre componentes y procesos futuros identificada. |
| ET01-CA02 | Se documentan entradas, resultados y errores de reserva, confirmación, cancelación y asignación, así como sus límites transaccionales. | Cubierto | docs/arquitectura.md, contratos y transacciones | Revisión documental de reserva, confirmación, cancelación y asignación; constituye diseño. |
| ET02-CA01 | El modelo cubre los veinticinco mantenimientos, relaciones, estados, eventos y asignaciones, con claves, cardinalidades y justificación de las tres primeras formas normales. | Pendiente | Modelo técnico Identity disponible | Modelo completo de los veinticinco mantenimientos y justificación de normalización pendientes. |
| ET02-CA02 | El diccionario de datos y las restricciones explican unicidad activa por empleado y puesto, bajas lógicas y puesto opcional en espera; las migraciones crean la base del prototipo. | Parcial | Migración inicial y prueba de arranque del ZIP | Migración técnica comprobada. Diccionario e invariantes del dominio pendientes. |
| ET05-CA01 | Se precargan cuentas y perfiles, equipos y pertenencias, ubicaciones y relaciones auxiliares; Carlos y Ana aparecen en los escenarios del equipo. | Parcial | Restart_preserves_identity_access_time_and_does_not_reset_password_or_duplicate_seed | Dos cuentas, roles y relaciones conservados. Equipos, ubicaciones y datos de oficina pendientes. |
| ET05-CA02 | Un restablecimiento explícito crea escenarios relativos al día de ejecución: reserva futura, zona llena con espera y pendiente ya vencida. El arranque normal no borra operaciones ni desplaza sus fechas. | Pendiente | Escenarios de reservas aún no implementados | Restablecimiento explícito y fechas relativas pendientes. |
| HU01-CA01 | Dada una carpeta con escritura, al iniciar la aplicación se abre la página local y se utiliza SQLite; el servidor solo escucha en la interfaz de bucle local. | Cubierto | ZIP: arranque, SQLite y escucha solo en 127.0.0.1 | Correcto en Windows x64. El lanzador conserva los mismos bytes de la versión histórica. |
| HU01-CA02 | Tras guardar una operación válida y reiniciar, permanecen los mismos datos e identificadores; un segundo arranque no duplica los datos iniciales. | Parcial | Restart_preserves_identity_access_time_and_does_not_reset_password_or_duplicate_seed; ZIP: reinicio | Persistencia de cuentas y último acceso correcta; operaciones del circuito pendientes. |
| HU01-CA03 | Sin conexión a Internet, se cargan la interfaz, los estilos y el plano; un puerto ocupado produce un mensaje comprensible y no cierra otros procesos. | Parcial | Login_resources_are_local_and_security_headers_present; ZIP: puerto ocupado | Recursos locales y puerto ocupado correctos. Plano y prueba del circuito sin Internet pendientes. |
| HU02-CA01 | Las credenciales válidas de empleado y administrador abren su área; una contraseña incorrecta no inicia sesión y muestra un error sin revelar datos de la cuenta. | Cubierto | Valid_account_gets_its_profile; Unknown_and_wrong_password_show_same_error_without_session | Carlos y Ana acceden; error genérico sin sesión. Comprobación visual del paquete I01.1. |
| HU02-CA02 | Al cerrar sesión, una petición posterior a una función protegida exige autenticación, también mediante acceso directo a su dirección. | Cubierto | Login_and_logout_require_antiforgery_and_get_does_not_log_out; Anonymous_requires_login | Tras salir, las funciones protegidas exigen autenticación. |
| HU02-CA03 | Las contraseñas se almacenan mediante el hash de Identity; las acciones de cambio exigen una sesión válida y protección frente a peticiones falsificadas. | Cubierto | Restart_preserves_identity_access_time_and_does_not_reset_password_or_duplicate_seed; Login_and_logout_require_antiforgery_and_get_does_not_log_out | Hash de Identity y protección antifalsificación comprobados en las acciones disponibles. |
| HU03-CA01 | Un empleado puede operar sobre sus solicitudes y consultar las reservas de su equipo; el administrador accede a catálogos, solicitudes e informes globales. | Parcial | Administrator_can_read_preloaded_accounts; Profile_ignores_another_account_identifier | Perfiles y consulta propia correctos; solicitudes, equipos e informes pendientes. |
| HU03-CA02 | Al cambiar en una petición el identificador de una solicitud ajena, el servidor rechaza la modificación; ocultar el botón no es la única protección. | Pendiente | Profile_ignores_another_account_identifier solo comprueba el perfil | La prueba de identificadores de solicitudes ajenas se ejecutará al implementar solicitudes. |
| HU03-CA03 | Un empleado no accede a catálogos ni informes globales mediante una URL directa; la respuesta no expone datos restringidos. | Parcial | Employee_direct_admin_url_is_denied_without_restricted_data; ZIP: acceso restringido | Administración denegada a Carlos. Catálogos e informes globales pendientes. |

[Resultados de I01.1](../manual/verificacion-I01.1.json) · [Arquitectura](../arquitectura.md) · [Versión y huellas](../entregas/I01.1.json)

## Resultado del desglose inicial

| Tarea | Trabajo previsto | Horas estimadas | Estado al corte | Evidencia |
|---|---|---:|---|---|
| GE01-T01 | Organizar fuentes, comandos y enlaces del repositorio | 0.25 | Completada | docs/iteraciones/iteracion-01.md y tablero público |
| GE01-T02 | Ajustar la vista de iteración y comprobar acceso y campos del tablero | 0.5 | Completada | docs/iteraciones/iteracion-01.md y tablero público |
| GE02-T01 | Formalizar objetivo, fechas, tareas y validación de la primera iteración | 1 | Completada | docs/iteraciones/iteracion-01.md y tablero público |
| GE02-T02 | Preparar informe de cierre y planificación siguiente en un único PDF | 1 | Preparada | Informe y planificación; vídeo y revisión final pendientes |
| GE02-T03 | Revisar el incremento, registrar retrospectiva y preparar vídeo de hasta cinco minutos | 1 | Parcial | Informe y planificación; vídeo y revisión final pendientes |
| ET01-T01 | Describir componentes, llamadas y separación de responsabilidades | 0.5 | Completada | docs/arquitectura.md |
| ET01-T02 | Definir contratos, errores y transacciones del circuito aprobado | 0.5 | Completada | docs/arquitectura.md |
| ET01-T03 | Contrastar los contratos con las reglas de reserva y los límites de implementación | 0.25 | Completada | docs/arquitectura.md |
| ET02-T01 | Definir el esquema técnico inicial de acceso y su ubicación de datos | 0.25 | Completada | docs/manual/verificacion-I01.1.json |
| ET02-T02 | Generar y verificar la migración inicial reproducible de SQLite | 0.5 | Completada | docs/manual/verificacion-I01.1.json |
| ET05-T01 | Precargar Carlos como empleado y Ana como administradora | 0.25 | Completada | docs/manual/verificacion-I01.1.json |
| ET05-T02 | Comprobar que reiniciar no duplica cuentas ni restablece contraseñas existentes | 0.5 | Completada | docs/manual/verificacion-I01.1.json |
| HU01-T01 | Preparar arranque local, carpeta de datos y errores de inicio | 1 | Completada | docs/manual/verificacion-I01.1.json |
| HU01-T02 | Publicar el ZIP Windows x64 con runtime y recursos propios | 1 | Completada | docs/manual/verificacion-I01.1.json |
| HU01-T03 | Probar el ZIP extraído, el reinicio, el puerto ocupado y las instrucciones | 1.25 | Completada | docs/manual/verificacion-I01.1.json |
| HU02-T01 | Implementar acceso y salida con Identity, hash y sesión | 1.5 | Completada | docs/manual/verificacion-I01.1.json |
| HU02-T02 | Probar credenciales válidas e inválidas, antifalsificación y redirecciones | 1.5 | Completada | docs/manual/verificacion-I01.1.json |
| HU02-T03 | Revisar ambos perfiles en el navegador y documentar el recorrido | 0.75 | Completada | docs/manual/verificacion-I01.1.json |
| HU03-T01 | Aplicar autorización en servidor a las áreas disponibles | 1 | Completada | docs/manual/verificacion-I01.1.json |
| HU03-T02 | Contrastar la matriz de permisos y la parametrización prevista en el modelo completo | 0.5 | Completada | docs/manual/verificacion-I01.1.json |
| HU03-T03 | Probar acceso directo restringido y perfil derivado de la sesión | 1 | Completada | docs/manual/verificacion-I01.1.json |

Veintiuna tareas: diecinueve completadas dentro del subconjunto previsto, una preparada y una parcial. Las horas son las estimaciones originales, no horas realizadas. Los elementos completos continúan siendo repositorio y tablero, arquitectura y contratos, e inicio y cierre de sesión: seis puntos de ciento veintiuno.

## Gestión del esfuerzo y calendario

La previsión de dieciséis horas corresponde al conjunto de trabajo de la iteración. Carlos confirmó dos horas de planificación y una de pruebas. No se dispone de un registro completo del tiempo de implementación asistida; estos ámbitos no permiten calcular una desviación de trece horas ni un porcentaje de ahorro. No se añaden horas humanas sin confirmar.

La planificación inicial se ajustó al plazo del aula manteniendo el inicio real del 25 de noviembre. Los seis días de la primera iteración son una excepción documentada respecto de los siete a veintiún días del backlog; la segunda conserva el periodo aprobado del 1 al 13 de diciembre.
