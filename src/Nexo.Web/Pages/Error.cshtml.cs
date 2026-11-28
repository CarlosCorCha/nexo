using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Nexo.Web.Pages;

[AllowAnonymous, IgnoreAntiforgeryToken]
public sealed class ErrorModel : PageModel
{
    public void OnGet() => Response.StatusCode = StatusCodes.Status500InternalServerError;
    public void OnPost() => Response.StatusCode = StatusCodes.Status500InternalServerError;
}
