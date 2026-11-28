using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Nexo.Web.Data;

namespace Nexo.Web.Pages;

public sealed class IndexModel(UserManager<NexoUser> users) : PageModel
{
    public NexoUser Account { get; private set; } = null!;
    public bool IsAdministrator => User.IsInRole(DemoAccounts.AdministratorRole);
    public async Task OnGetAsync() => Account = (await users.GetUserAsync(User))!;
}
