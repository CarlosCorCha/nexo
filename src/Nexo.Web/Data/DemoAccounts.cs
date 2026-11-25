using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Nexo.Web.Data;

public static class DemoAccounts
{
    public const string EmployeeRole = "Empleado";
    public const string AdministratorRole = "Administrador";

    public static async Task InitializeAsync(IServiceProvider services)
    {
        var db = services.GetRequiredService<ApplicationDbContext>();
        await db.Database.MigrateAsync();
        await using var transaction = await db.Database.BeginTransactionAsync();
        var roles = services.GetRequiredService<RoleManager<IdentityRole>>();
        var users = services.GetRequiredService<UserManager<NexoUser>>();
        foreach (var role in new[] { EmployeeRole, AdministratorRole })
            if (!await roles.RoleExistsAsync(role)) Ensure(await roles.CreateAsync(new IdentityRole(role)));
        await AddAsync("carlos", "Carlos", "Nexo.Carlos2026!", EmployeeRole);
        await AddAsync("ana", "Ana", "Nexo.Ana2026!", AdministratorRole);
        await transaction.CommitAsync();

        async Task AddAsync(string name, string display, string password, string role)
        {
            var user = await users.FindByNameAsync(name);
            if (user is null)
            {
                user = new NexoUser { UserName = name, DisplayName = display, Email = $"{name}@nexo.local",
                    EmailConfirmed = true, LockoutEnabled = true };
                Ensure(await users.CreateAsync(user, password));
            }
            if (!await users.IsInRoleAsync(user, role)) Ensure(await users.AddToRoleAsync(user, role));
        }
    }

    private static void Ensure(IdentityResult result)
    {
        if (!result.Succeeded) throw new InvalidOperationException(
            "No se pudieron preparar las cuentas de demostración: " + string.Join("; ", result.Errors.Select(x => x.Description)));
    }
}
