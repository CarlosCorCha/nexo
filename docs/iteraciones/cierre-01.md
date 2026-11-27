# Informe 1 · Preparación del cierre y planificación 2

Preparado el 27 de noviembre de 2026. Periodo previsto de la primera iteración: 25–30 de noviembre.
Estado: revisión de la entrega; no se ha enviado al campus.

## Resultado disponible

Arranque local Windows x64, SQLite y acceso con Carlos (Empleado) y Ana (Administrador).
La revisión de Carlos se complementó el 27/11 con acceso directo denegado, reinicio con datos conservados y protección de páginas tras salir.

| Elemento | Estado al 27/11 |
|---|---|
| GE01 · Repositorio y tablero de seguimiento | Hecho |
| GE02 · Planificación y revisión de iteraciones | En curso; aportación parcial |
| ET01 · Arquitectura y contratos internos | Hecho |
| ET02 · Modelo completo y restricciones de datos | En curso; aportación parcial |
| ET05 · Datos ficticios y escenarios de demostración | En curso; aportación parcial |
| HU01 · Arranque local y persistencia | En curso; aportación parcial |
| HU02 · Inicio y cierre de sesión | Hecho |
| HU03 · Permisos según el perfil | En curso; aportación parcial |

Avance ponderado: 6 de 121 PH, equivalente a 5,0 % redondeado. Los parciales no se computan como terminados.
Tres de los cuarenta elementos están cerrados. Las 16 horas son estimadas; la dedicación humana no se ha confirmado.

## Comprobaciones

| Prueba | Resultado |
|---|---|
| V01 · URL directa de Administración con Carlos | La navegación termina en /Acceso/Denegado?ReturnUrl=%2FAdministracion y muestra ACCESO / 403. |
| V02 · Detener y reiniciar el paquete local | Dos usuarios y dos roles antes y después; igualdad de todos los campos comparados, relaciones, migración y claves. SQLite quick_check devuelve ok. |
| V03 · Recargar el perfil tras reiniciar | El perfil de Carlos sigue accesible y conserva 27/11/2026 22:47, hora Europe/Madrid. |
| V04 · Pedir /Perfil después de cerrar sesión | Redirección a /Acceso/Entrar?ReturnUrl=%2FPerfil. |
| V05 · Recorrido aportado por Carlos con ambos perfiles | Sin incidencias visibles; Ana consulta las dos cuentas y Carlos ve su perfil de empleado. La grabación no sustituye a las comprobaciones de URL y reinicio. |

[Resultados y procedencia de las capturas](../manual/verificacion-20261127.json).
El registro del 25/11 contiene 17 casos de integración y 12 comprobaciones del ZIP correctas. No se presentan como nuevas ejecuciones del 27/11.

## Problemas y retrospectiva

El primer calendario terminaba el 8 de diciembre y se ajustó al plazo del aula del 30 de noviembre, manteniendo el inicio real del 25/11. La excepción inicial de seis días queda documentada.
La revisión del vídeo no demostraba por sí sola el rechazo de una URL ni la persistencia. Se completaron ambas comprobaciones sobre el paquete real el 27/11, con resultados correctos.

Funcionó disponer de un ZIP con runtime propio y un recorrido corto con dos cuentas ficticias.
Las pruebas de servidor y de reinicio complementan la revisión visual; ocultar un menú o ver un perfil no basta para probar permisos o persistencia.
En la siguiente iteración se fijarán desde el inicio escenarios, resultados esperados y evidencias por historia. Los elementos parciales conservarán sus criterios pendientes.

## Planificación siguiente

[Segunda iteración, del 1 al 13 de diciembre](iteracion-02.md).
El vídeo base y el PDF combinado se preparan para revisión. Su versión final y el acceso al vídeo deben comprobarse antes de la entrega del 30/11.
