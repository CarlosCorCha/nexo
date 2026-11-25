using System.Net;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;

namespace Nexo.Web.Tests;

public sealed class NexoFactory(string directory) : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(
            new Dictionary<string, string?> { ["Nexo:DataDirectory"] = directory, ["NEXO_DATA_DIR"] = directory,
                ["Nexo:OpenBrowser"] = "false", ["Logging:LogLevel:Default"] = "Warning" }));
    }

    public HttpClient Browser() => CreateClient(new WebApplicationFactoryClientOptions
        { AllowAutoRedirect = false, HandleCookies = true, BaseAddress = new Uri("http://localhost") });

    public static async Task<string> TokenAsync(HttpClient client, string path = "/Acceso/Entrar")
    {
        var html = await client.GetStringAsync(path);
        var match = Regex.Match(html, "name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"");
        Assert.True(match.Success, "La página debe incluir un token antifalsificación.");
        return WebUtility.HtmlDecode(match.Groups[1].Value);
    }

    public static async Task<HttpResponseMessage> LoginAsync(HttpClient client, string user = "carlos",
        string password = "Nexo.Carlos2026!", string? returnUrl = null) =>
        await client.PostAsync("/Acceso/Entrar", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["Input.UserName"] = user, ["Input.Password"] = password,
            ["ReturnUrl"] = returnUrl ?? "", ["__RequestVerificationToken"] = await TokenAsync(client)
        }));
}
