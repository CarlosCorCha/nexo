# Iteración 2 · Modelo, datos y primeros catálogos

Planificación 0.1 del 27/11/2026. Periodo: 1–13 de diciembre de 2026.
Estado: planificada, pendiente de inicio. No se declaran tareas realizadas en el futuro.
Vista de seguimiento: https://github.com/users/CarlosCorCha/projects/1/views/4

Completar el modelo de dominio y los escenarios de demostración, e incorporar los mantenimientos de organización y empleados con persistencia, validaciones y autorización en servidor.
Se incorporan dos de los cinco CRUD programados aprobados. Los veinte CRUD de diseño siguen sin programarse; no se añaden servicios cloud, registro de usuarios ni funcionalidades nuevas.
Primero se completa el modelo y se preparan datos reproducibles; después se aplican los permisos de los catálogos y se implementa organización antes que empleados. Solo se usa la parte disponible de las dependencias transversales; los criterios de reserva, plano e informes no se dan por terminados.

Referencia de esfuerzo: 14 horas estimadas; no equivalen a horas reales ni se obtienen convirtiendo puntos de historia.

Las etiquetas de iteración conservan el histórico de selección aunque un elemento parcial continúe en la siguiente.

## Planificación y revisión de iteraciones

Gestionar iteraciones individuales de siete a veintiún días y adaptar el backlog con las evidencias de cada incremento.

Prioridad: 99. Estimación original: 3 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-GE02-T01 | Confirmar objetivo, tareas, capacidad y seguimiento | 0.5 |
| I02-GE02-T02 | Revisar el incremento y preparar informe, vídeo y planificación siguiente | 1.5 |

Gestión de la segunda iteración.
El tablero, las fechas, el informe y el vídeo describen los mismos resultados y remanentes.

## Modelo completo y restricciones de datos

Modelar el producto completo y preparar la persistencia del prototipo conservando la integridad de sus relaciones.

Prioridad: 97. Estimación original: 5 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-ET02-T01 | Modelar entidades, relaciones y cobertura de los veinticinco CRUD | 1.5 |
| I02-ET02-T02 | Completar diccionario y justificación de normalización | 1.5 |
| I02-ET02-T03 | Definir restricciones y migración del esquema del prototipo | 1 |

Cierre previsto del modelo completo.
La matriz cubre los veinticinco mantenimientos; el diccionario y las claves justifican tres formas normales. La migración crea el esquema previsto y los invariantes quedan documentados.

## Datos ficticios y escenarios de demostración

Preparar datos reproducibles de una organización, sede, planta, cuatro zonas y dieciséis puestos para evaluar sin información empresarial real.

Prioridad: 96. Estimación original: 3 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-ET05-T01 | Preparar organización, personas, equipos y espacios ficticios | 0.75 |
| I02-ET05-T02 | Crear escenarios relativos de reserva, espera y vencimiento y su restablecimiento | 0.75 |
| I02-ET05-T03 | Probar inicialización idempotente y conservación de operaciones | 0.5 |

Cierre previsto de los datos de demostración.
Los datos incluyen una sede, una planta, cuatro zonas, dieciséis puestos y los casos aprobados. El reinicio normal no duplica ni desplaza datos; solo el restablecimiento explícito recrea escenarios.

## Arranque local y persistencia

Como evaluador, quiero arrancar Nexo en mi equipo y conservar sus datos para revisar el circuito sin preparar un entorno de desarrollo.

Prioridad: 95. Estimación original: 2 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-HU01-T01 | Comprobar conservación de cambios de organización y empleados tras reiniciar | 0.25 |
| I02-HU01-T02 | Revisar el paquete y sus recursos locales tras incorporar los catálogos | 0.25 |

Ampliación parcial de la persistencia.
Los cambios de los nuevos catálogos permanecen al reiniciar el paquete. El criterio completo del plano sin Internet continúa pendiente hasta incorporar el plano.

## Permisos según el perfil

Como empleado, quiero gestionar mis solicitudes y consultar mi equipo, mientras la administración queda reservada al perfil autorizado.

Prioridad: 93. Estimación original: 3 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-HU03-T01 | Contrastar perfiles, tareas y relaciones parametrizables con el modelo completo | 0.5 |
| I02-HU03-T02 | Aplicar permisos en servidor a los nuevos mantenimientos | 0.5 |
| I02-HU03-T03 | Probar acceso directo y rechazo de operaciones con el perfil empleado | 0.5 |

Ampliación parcial de permisos.
Carlos no consulta ni modifica los catálogos mediante URL o petición directa; Ana realiza las operaciones autorizadas. No se añaden pantallas de administración de cuentas. Los permisos sobre reservas e informes siguen pendientes.

## Datos generales de la organización

Como administrador, quiero mantener los datos de la organización para identificarlos en la aplicación y sus informes.

Prioridad: 92. Estimación original: 2 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-HU04-T01 | Construir alta, lista, detalle, modificación y baja lógica | 0.75 |
| I02-HU04-T02 | Validar organización activa y bloqueo de bajas con relaciones | 0.75 |
| I02-HU04-T03 | Probar datos inválidos, nombre persistido y reinicio | 0.5 |

Cierre previsto del mantenimiento de organización.
Las cuatro operaciones cumplen los criterios aprobados; solo existe una organización activa, una baja incompatible se bloquea y el nombre mostrado procede de los datos guardados.

## Mantenimiento de empleados

Como administrador, quiero crear, consultar, modificar y dar de baja empleados para mantener el catálogo de personas de la oficina.

Prioridad: 91. Estimación original: 3 PH.
| Tarea | Trabajo previsto | Horas |
|---|---|---:|
| I02-HU05-T01 | Construir alta, lista, detalle, modificación y baja lógica | 0.75 |
| I02-HU05-T02 | Validar obligatorios, duplicados y relaciones activas | 0.75 |
| I02-HU05-T03 | Probar historial, persistencia y separación entre empleado y cuenta | 0.5 |

Cierre previsto del mantenimiento de empleados.
Las operaciones persisten, se rechazan duplicados y bajas con solicitudes activas, y se conserva el historial. Dar de alta un empleado no crea una cuenta de acceso.

## Criterios de cierre

Comparar resultados con los criterios originales; revisar permisos, errores, duplicados, relaciones activas y persistencia.
Conservar los remanentes de las historias transversales sin marcarlas como completas.
Preparar el informe de avance y la planificación tercera en un mismo PDF y un vídeo de hasta cinco minutos para el 13/12.
