using System.Net;
using Microsoft.Data.Sqlite;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Nexo.Web.Data;
using Nexo.Web.Pages.Acceso;

namespace Nexo.Web.Tests;

public sealed class AccessTests : IAsyncLifetime
{
    private readonly string directory = Path.Combine(Path.GetTempPath(), "nexo-test-" + Guid.NewGuid().ToString("N"));
    private NexoFactory factory = null!;
    public Task InitializeAsync() { factory = new NexoFactory(directory); return Task.CompletedTask; }
    public async Task DisposeAsync()
    {
        await factory.DisposeAsync();
        SqliteConnection.ClearAllPools();
        if (Directory.Exists(directory)) Directory.Delete(directory, recursive: true);
    }

    [Theory]
    [InlineData("/")]
    [InlineData("/Perfil")]
    [InlineData("/Administracion")]
    public async Task Anonymous_requires_login(string path)
    {
        using var client = factory.Browser();
        var response = await client.GetAsync(path);
        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Contains("/Acceso/Entrar", response.Headers.Location!.ToString());
    }

    [Theory]
    [InlineData("carlos", "Nexo.Carlos2026!", "Empleado")]
    [InlineData("ana", "Nexo.Ana2026!", "Administrador")]
    [InlineData("carlos@nexo.local", "Nexo.Carlos2026!", "Empleado")]
    public async Task Valid_account_gets_its_profile(string user, string password, string role)
    {
        using var client = factory.Browser();
        var response = await NexoFactory.LoginAsync(client, user, password);
        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Equal("/", response.Headers.Location!.ToString());
        Assert.Contains("Nexo.Sesion=", string.Join(";", response.Headers.GetValues("Set-Cookie")));
        var profile = await client.GetStringAsync("/Perfil");
        Assert.Contains(role, profile);
        Assert.DoesNotContain("Todavía no ha accedido", profile);
    }

    [Fact]
    public async Task Employee_direct_admin_url_is_denied_without_restricted_data()
    {
        using var client = factory.Browser();
        await NexoFactory.LoginAsync(client);
        Assert.DoesNotContain("href=\"/Administracion\"", await client.GetStringAsync("/"));
        var response = await client.GetAsync("/Administracion");
        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Contains("/Acceso/Denegado", response.Headers.Location!.ToString());
        var denied = await client.GetAsync(response.Headers.Location);
        Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);
        Assert.DoesNotContain("Perfiles de demostración", await denied.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Administrator_can_read_preloaded_accounts()
    {
        using var client = factory.Browser();
        await NexoFactory.LoginAsync(client, "ana", "Nexo.Ana2026!");
        var response = await client.GetAsync("/Administracion");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var html = await response.Content.ReadAsStringAsync();
        Assert.Contains("Carlos", html);
        Assert.Contains("Ana", html);
        Assert.DoesNotContain("PasswordHash", html);
        Assert.DoesNotContain("Nexo.Carlos2026!", html);
    }

    [Fact]
    public async Task Profile_ignores_another_account_identifier()
    {
        using var client = factory.Browser();
        await NexoFactory.LoginAsync(client);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var ana = await db.Users.SingleAsync(x => x.UserName == "ana");
        var html = await client.GetStringAsync("/Perfil?userId=" + ana.Id);
        Assert.Contains("carlos@nexo.local", html);
        Assert.DoesNotContain("ana@nexo.local", html);
    }

    [Fact]
    public async Task Unknown_and_wrong_password_show_same_error_without_session()
    {
        using var client = factory.Browser();
        foreach (var user in new[] { "carlos", "inexistente" })
        {
            var response = await NexoFactory.LoginAsync(client, user, "incorrecta");
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            Assert.Contains(EntrarModel.InvalidCredentials, WebUtility.HtmlDecode(await response.Content.ReadAsStringAsync()));
            Assert.Equal(HttpStatusCode.Redirect, (await client.GetAsync("/Perfil")).StatusCode);
        }
    }

    [Fact]
    public async Task Five_wrong_passwords_temporarily_lock_account()
    {
        using var client = factory.Browser();
        for (var i = 0; i < 5; i++) await NexoFactory.LoginAsync(client, "carlos", "incorrecta");
        var response = await NexoFactory.LoginAsync(client);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal(HttpStatusCode.Redirect, (await client.GetAsync("/Perfil")).StatusCode);
        await using var scope = factory.Services.CreateAsyncScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<NexoUser>>();
        Assert.True(await users.IsLockedOutAsync((await users.FindByNameAsync("carlos"))!));
    }

    [Fact]
    public async Task Login_and_logout_require_antiforgery_and_get_does_not_log_out()
    {
        using var client = factory.Browser();
        var missing = await client.PostAsync("/Acceso/Entrar", new FormUrlEncodedContent(
            new Dictionary<string, string> { ["Input.UserName"] = "carlos", ["Input.Password"] = "Nexo.Carlos2026!" }));
        Assert.Equal(HttpStatusCode.BadRequest, missing.StatusCode);
        await NexoFactory.LoginAsync(client);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsync("/Acceso/Salir", new StringContent(""))).StatusCode);
        await client.GetAsync("/Acceso/Salir");
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/Perfil")).StatusCode);
        var token = await NexoFactory.TokenAsync(client, "/Perfil");
        var logout = await client.PostAsync("/Acceso/Salir", new FormUrlEncodedContent(
            new Dictionary<string, string> { ["__RequestVerificationToken"] = token }));
        Assert.Equal(HttpStatusCode.Redirect, logout.StatusCode);
        Assert.Equal(HttpStatusCode.Redirect, (await client.GetAsync("/Perfil")).StatusCode);
    }

    [Theory]
    [InlineData("https://example.org/", "/")]
    [InlineData("//example.org/", "/")]
    [InlineData("/Perfil", "/Perfil")]
    public async Task Return_destination_must_be_local(string destination, string expected)
    {
        using var client = factory.Browser();
        var response = await NexoFactory.LoginAsync(client, returnUrl: destination);
        Assert.Equal(expected, response.Headers.Location!.ToString());
    }

    [Fact]
    public async Task Login_resources_are_local_and_security_headers_present()
    {
        using var client = factory.Browser();
        var response = await client.GetAsync("/Acceso/Entrar");
        var html = await response.Content.ReadAsStringAsync();
        Assert.DoesNotContain("https://", html);
        Assert.DoesNotContain("<script", html);
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/css/site.css")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/nexo.svg")).StatusCode);
        Assert.Contains("frame-ancestors 'none'", response.Headers.GetValues("Content-Security-Policy").Single());
    }

    [Fact]
    public async Task Restart_preserves_identity_access_time_and_does_not_reset_password_or_duplicate_seed()
    {
        using (var client = factory.Browser()) await NexoFactory.LoginAsync(client);
        string id;
        DateTimeOffset? access;
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var users = scope.ServiceProvider.GetRequiredService<UserManager<NexoUser>>();
            var user = (await users.FindByNameAsync("carlos"))!;
            id = user.Id;
            access = user.LastAccessUtc;
            Assert.NotNull(access);
            Assert.NotEqual("Nexo.Carlos2026!", user.PasswordHash);
            Assert.True(await users.CheckPasswordAsync(user, "Nexo.Carlos2026!"));
            Assert.True((await users.ChangePasswordAsync(user, "Nexo.Carlos2026!", "Prueba.Nueva2026!")).Succeeded);
        }
        await factory.DisposeAsync();
        factory = new NexoFactory(directory);
        using var restarted = factory.Browser();
        await using var second = factory.Services.CreateAsyncScope();
        var db = second.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        Assert.Equal(2, await db.Users.CountAsync());
        Assert.Equal(2, await db.Roles.CountAsync());
        Assert.Equal(2, await db.UserRoles.CountAsync());
        var persisted = await db.Users.SingleAsync(x => x.UserName == "carlos");
        Assert.Equal(id, persisted.Id);
        Assert.Equal(access, persisted.LastAccessUtc);
        Assert.Equal(HttpStatusCode.OK, (await NexoFactory.LoginAsync(restarted)).StatusCode);
        Assert.Equal(HttpStatusCode.Redirect, (await NexoFactory.LoginAsync(restarted, password: "Prueba.Nueva2026!")).StatusCode);
    }
}
