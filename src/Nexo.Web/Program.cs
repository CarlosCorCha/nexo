using System.Diagnostics;
using System.Net;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.DataProtection.KeyManagement;
using Microsoft.AspNetCore.DataProtection.Repositories;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Nexo.Web.Data;
using Nexo.Web.Infrastructure;

try
{
    var builder = WebApplication.CreateBuilder(args);
    builder.WebHost.ConfigureKestrel((context, options) =>
    {
        var configured = context.Configuration["NEXO_PORT"] ?? context.Configuration["Nexo:Port"] ?? "5187";
        if (!int.TryParse(configured, out var port) || port is < 1 or > 65535)
            throw new InvalidOperationException("El puerto configurado debe estar entre 1 y 65535.");
        options.Listen(IPAddress.Loopback, port);
    });
    builder.Services.AddSingleton<DataDirectory>();
    builder.Services.AddSingleton<InstanceLock>();
    builder.Services.AddDbContext<ApplicationDbContext>((services, options) =>
        options.UseSqlite(new SqliteConnectionStringBuilder
        {
            DataSource = services.GetRequiredService<DataDirectory>().DatabasePath,
            ForeignKeys = true, DefaultTimeout = 30
        }.ToString()));
    builder.Services.AddDataProtection().SetApplicationName("Nexo.OficinasHibridas");
    builder.Services.AddOptions<KeyManagementOptions>().Configure<DataDirectory, ILoggerFactory>((options, data, logs) =>
        options.XmlRepository = new FileSystemXmlRepository(new DirectoryInfo(data.KeysPath), logs));
    builder.Services.AddIdentity<NexoUser, IdentityRole>(options =>
    {
        options.Password.RequiredLength = 12;
        options.Lockout.MaxFailedAccessAttempts = 5;
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(10);
        options.User.RequireUniqueEmail = true;
    }).AddEntityFrameworkStores<ApplicationDbContext>().AddDefaultTokenProviders();
    builder.Services.ConfigureApplicationCookie(options =>
    {
        options.Cookie.Name = "Nexo.Sesion";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
        options.LoginPath = "/Acceso/Entrar";
        options.AccessDeniedPath = "/Acceso/Denegado";
        options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
        options.SlidingExpiration = true;
    });
    builder.Services.AddAuthorizationBuilder().SetFallbackPolicy(
        new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build());
    builder.Services.AddRazorPages();
    var app = builder.Build();
    _ = app.Services.GetRequiredService<InstanceLock>();
    await using (var scope = app.Services.CreateAsyncScope())
        await DemoAccounts.InitializeAsync(scope.ServiceProvider);
    app.UseExceptionHandler("/Error");
    app.Use(async (context, next) =>
    {
        context.Response.Headers.ContentSecurityPolicy = "default-src 'self'; style-src 'self'; script-src 'self'; img-src 'self' data:; frame-ancestors 'none'; form-action 'self'; base-uri 'self'";
        context.Response.Headers.XContentTypeOptions = "nosniff";
        context.Response.Headers["Referrer-Policy"] = "no-referrer";
        context.Response.Headers.CacheControl = "no-cache, no-store";
        await next();
    });
    app.UseStaticFiles();
    app.UseRouting();
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapGet("/salud", () => Results.Json(new { estado = "disponible" })).AllowAnonymous();
    app.MapRazorPages();
    await app.StartAsync();
    var address = app.Urls.FirstOrDefault() ?? "http://127.0.0.1:5187";
    Console.WriteLine($"\nNexo está disponible en {address}\nMantén esta ventana abierta. Para detener Nexo, pulsa Ctrl+C.\n");
    if (!app.Environment.IsEnvironment("Testing") && builder.Configuration.GetValue("Nexo:OpenBrowser", true)
        && builder.Configuration["NEXO_OPEN_BROWSER"] != "0")
    {
        try { Process.Start(new ProcessStartInfo(address) { UseShellExecute = true }); }
        catch (System.ComponentModel.Win32Exception) { Console.WriteLine("Abre la dirección anterior en tu navegador."); }
    }
    await app.WaitForShutdownAsync();
    await app.DisposeAsync();
    return 0;
}
catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or InvalidOperationException or SqliteException)
{
    Console.Error.WriteLine("No se puede iniciar Nexo. Comprueba que la carpeta permita escritura y que el puerto esté libre. " + ex.Message);
    return 1;
}

public partial class Program { }
