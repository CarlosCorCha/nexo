using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Nexo.Web.Pages.Acceso;

public sealed class DenegadoModel : PageModel
{
    public void OnGet() => Response.StatusCode = StatusCodes.Status403Forbidden;
}
