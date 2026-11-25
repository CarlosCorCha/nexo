namespace Nexo.Web.Infrastructure;

public sealed class DataDirectory
{
    public string Root { get; }
    public string DatabasePath => Path.Combine(Root, "nexo.db");
    public string KeysPath => Path.Combine(Root, "claves");

    public DataDirectory(IConfiguration configuration)
    {
        Root = Path.GetFullPath(configuration["NEXO_DATA_DIR"] ?? configuration["Nexo:DataDirectory"]
            ?? Path.Combine(AppContext.BaseDirectory, "Datos"));
        Directory.CreateDirectory(Root);
        Directory.CreateDirectory(KeysPath);
        var probe = Path.Combine(Root, $".escritura-{Guid.NewGuid():N}");
        using (File.Create(probe)) { }
        File.Delete(probe);
    }
}

public sealed class InstanceLock : IDisposable
{
    private readonly FileStream handle;
    public InstanceLock(DataDirectory directory)
    {
        try { handle = new FileStream(Path.Combine(directory.Root, ".nexo.lock"), FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None); }
        catch (IOException ex) { throw new IOException("Ya hay otra instancia utilizando esta carpeta de datos. Utiliza la ventana abierta o detén esa instancia.", ex); }
    }
    public void Dispose() => handle.Dispose();
}
