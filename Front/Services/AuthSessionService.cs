namespace FrontBlazor_AppiGenericaCsharp.Services;

public class AuthSessionService
{
    public event Action? OnChange;

    public bool EstaAutenticado => !string.IsNullOrWhiteSpace(Token);
    public string? Token { get; private set; }
    public string? Username { get; private set; }
    public string? UserId { get; private set; }
    public IReadOnlyList<string> Roles => _roles;

    private readonly List<string> _roles = new();

    public bool EsAdmin => _roles.Any(r => string.Equals(r, "admin", StringComparison.OrdinalIgnoreCase));

    public void IniciarSesion(string token, string? userId, string username, IEnumerable<string>? roles)
    {
        Token = token;
        UserId = userId;
        Username = username;
        _roles.Clear();
        if (roles is not null)
            _roles.AddRange(roles.Where(r => !string.IsNullOrWhiteSpace(r)));
        OnChange?.Invoke();
    }

    public void CerrarSesion()
    {
        Token = null;
        UserId = null;
        Username = null;
        _roles.Clear();
        OnChange?.Invoke();
    }
}
