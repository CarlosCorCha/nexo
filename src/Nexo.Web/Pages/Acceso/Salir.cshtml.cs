using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Nexo.Web.Data;

namespace Nexo.Web.Pages.Acceso;

public sealed class SalirModel(SignInManager<NexoUser> sessions) : PageModel
{
    public IActionResult OnGet() => RedirectToPage("/Index");
    public async Task<IActionResult> OnPostAsync()
    {
        await sessions.SignOutAsync();
        return RedirectToPage("/Acceso/Entrar");
    }
}
