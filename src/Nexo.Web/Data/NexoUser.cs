using Microsoft.AspNetCore.Identity;

namespace Nexo.Web.Data;

public sealed class NexoUser : IdentityUser
{
    public string DisplayName { get; set; } = "";
    public DateTimeOffset? LastAccessUtc { get; set; }
}
