using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace ApiGenericaCsharp.Middlewares;

public class RoleAuthorizationMiddleware
{
    private static readonly HashSet<string> TablasSoloAdmin = new(StringComparer.OrdinalIgnoreCase)
    {
        "usuario",
        "rol",
        "rol_usuario"
    };

    private readonly RequestDelegate _next;

    public RoleAuthorizationMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var endpoint = context.GetEndpoint();
        if (endpoint?.Metadata.GetMetadata<IAllowAnonymous>() is not null)
        {
            await _next(context);
            return;
        }

        if (!context.Request.Path.StartsWithSegments("/api", StringComparison.OrdinalIgnoreCase))
        {
            await _next(context);
            return;
        }

        var user = context.User;
        if (user?.Identity?.IsAuthenticated != true)
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(new { estado = 401, mensaje = "Token JWT requerido." });
            return;
        }

        bool esAdmin = user.Claims.Any(c =>
            (c.Type == ClaimTypes.Role || c.Type == "role") &&
            string.Equals(c.Value, "admin", StringComparison.OrdinalIgnoreCase));

        var segmentos = context.Request.Path.Value?
            .Split('/', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            ?? Array.Empty<string>();

        // /api/{tabla}/...
        string? tabla = segmentos.Length >= 2 && string.Equals(segmentos[0], "api", StringComparison.OrdinalIgnoreCase)
            ? segmentos[1]
            : null;

        bool metodoModificacion = HttpMethods.IsPost(context.Request.Method) ||
                                  HttpMethods.IsPut(context.Request.Method) ||
                                  HttpMethods.IsDelete(context.Request.Method);

        bool requiereAdmin = (tabla is not null && TablasSoloAdmin.Contains(tabla)) || metodoModificacion;

        if (requiereAdmin && !esAdmin)
        {
            context.Response.StatusCode = StatusCodes.Status403Forbidden;
            await context.Response.WriteAsJsonAsync(new
            {
                estado = 403,
                mensaje = "Acceso denegado. Esta operación requiere rol admin."
            });
            return;
        }

        await _next(context);
    }
}
