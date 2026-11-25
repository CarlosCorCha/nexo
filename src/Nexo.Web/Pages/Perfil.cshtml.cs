using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Nexo.Web.Data;

namespace Nexo.Web.Pages;

public sealed class PerfilModel(UserManager<NexoUser> users) : PageModel
{
    public NexoUser Account { get; private set; } = null!;
    public IList<string> Roles { get; private set; } = [];
    public async Task OnGetAsync()
    {
        Account = (await users.GetUserAsync(User))!;
        Roles = await users.GetRolesAsync(Account);
    }
}
