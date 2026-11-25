using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Nexo.Web.Data;

namespace Nexo.Web.Pages.Administracion;

[Authorize(Roles = DemoAccounts.AdministratorRole)]
public sealed class IndexModel(ApplicationDbContext db) : PageModel
{
    public List<AccountRow> Accounts { get; private set; } = [];
    public async Task OnGetAsync() => Accounts = await (
        from user in db.Users.AsNoTracking()
        join link in db.UserRoles on user.Id equals link.UserId
        join role in db.Roles on link.RoleId equals role.Id
        orderby user.DisplayName
        select new AccountRow(user.DisplayName, user.UserName!, role.Name!, user.LastAccessUtc)).ToListAsync();
    public sealed record AccountRow(string Name, string UserName, string Role, DateTimeOffset? LastAccess);
}
