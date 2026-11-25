using System.Globalization;

namespace Nexo.Web.Infrastructure;

public static class OfficeTime
{
    public static string Format(DateTimeOffset? value) => value is null ? "Todavía no ha accedido"
        : TimeZoneInfo.ConvertTime(value.Value, TimeZoneInfo.FindSystemTimeZoneById("Europe/Madrid"))
            .ToString("dd/MM/yyyy · HH:mm", CultureInfo.GetCultureInfo("es-ES"));
}
