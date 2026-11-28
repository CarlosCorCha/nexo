using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Nexo.Web.Data;

namespace Nexo.Web.Pages.Acceso;

[AllowAnonymous]
public sealed class EntrarModel(UserManager<NexoUser> users, SignInManager<NexoUser> sessions,
    ApplicationDbContext db) : PageModel
{
    [BindProperty] public InputModel Input { get; set; } = new();
    [BindProperty(SupportsGet = true)] public string? ReturnUrl { get; set; }
    public const string InvalidCredentials = "No se ha podido iniciar sesión. Revisa el usuario y la contraseña o inténtalo más tarde.";
    public IActionResult OnGet() => User.Identity?.IsAuthenticated == true ? LocalRedirect("/") : Page();

    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid) return Page();
        var name = Input.UserName.Trim();
        var user = await users.FindByNameAsync(name);
        if (user is null && name.Contains('@')) user = await users.FindByEmailAsync(name);
        var result = user is null ? Microsoft.AspNetCore.Identity.SignInResult.Failed
            : await sessions.CheckPasswordSignInAsync(user, Input.Password, lockoutOnFailure: true);
        if (!result.Succeeded || user is null)
        {
            ModelState.AddModelError(string.Empty, InvalidCredentials);
            return Page();
        }
        await db.Users.Where(x => x.Id == user.Id).ExecuteUpdateAsync(
            update => update.SetProperty(x => x.LastAccessUtc, DateTimeOffset.UtcNow));
        await sessions.SignInAsync(user, isPersistent: false);
        return LocalRedirect(Url.IsLocalUrl(ReturnUrl) ? ReturnUrl! : "/");
    }

    public sealed class InputModel
    {
        [Required(ErrorMessage = "Escribe tu usuario."), StringLength(256)]
        public string UserName { get; set; } = "";
        [Required(ErrorMessage = "Escribe tu contraseña."), DataType(DataType.Password), StringLength(256)]
        public string Password { get; set; } = "";
    }
}
