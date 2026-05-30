// RoleAuthorizationMiddleware.cs
// Middleware de autorización por roles para todas las rutas /api/* y /auth/*
//
// Reglas de acceso:
//   GET     cualquier tabla:       Público (AllowAnonymous en el controlador)
//   POST    cualquier tabla:       Requiere JWT válido (cualquier rol)
//   PUT     cualquier tabla:       Requiere JWT válido (cualquier rol)
//   DELETE  cualquier tabla:       Requiere JWT + rol ADMIN
//   *       tablas admin:          Requiere JWT + rol ADMIN (usuario, rol, rol_usuario)
//
// Rutas exentas:
//   /auth/register  — público
//   /auth/login     — público
//   /api/login      — público (compat.)
//   /swagger        — público
//   /redoc          — público

using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace ApiGenericaCsharp.Middlewares;

public class RoleAuthorizationMiddleware
{
    // Tablas que requieren rol ADMIN para cualquier operación
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
        // 1. Si el endpoint tiene [AllowAnonymous], pasar directamente
        var endpoint = context.GetEndpoint();
        if (endpoint?.Metadata.GetMetadata<IAllowAnonymous>() is not null)
        {
            await _next(context);
            return;
        }

        // 2. Solo controlar rutas /api/* y /auth/* (no /swagger, /redoc, etc.)
        var path = context.Request.Path.Value ?? "";
        bool esRutaApi  = path.StartsWith("/api", StringComparison.OrdinalIgnoreCase);
        bool esRutaAuth = path.StartsWith("/auth", StringComparison.OrdinalIgnoreCase);

        if (!esRutaApi && !esRutaAuth)
        {
            await _next(context);
            return;
        }

        // 3. Detectar tabla en la URL: /api/{tabla}/...
        var segmentos = path.Split('/', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        string? tabla = segmentos.Length >= 2 &&
                        string.Equals(segmentos[0], "api", StringComparison.OrdinalIgnoreCase)
            ? segmentos[1]
            : null;

        var method = context.Request.Method;
        bool esGet    = HttpMethods.IsGet(method);
        bool esPost   = HttpMethods.IsPost(method);
        bool esPut    = HttpMethods.IsPut(method);
        bool esDelete = HttpMethods.IsDelete(method);

        // 4. GET en rutas /api → pasan sin requerir autenticación
        //    (los métodos del controlador tienen [AllowAnonymous])
        if (esGet && esRutaApi)
        {
            await _next(context);
            return;
        }

        // 5. Para rutas /auth/* los endpoints PUBLIC tienen [AllowAnonymous] → ya pasaron en paso 1
        //    Si llegamos aquí para /auth, necesitamos JWT (ej: /auth/logout)
        var user = context.User;
        bool estaAutenticado = user?.Identity?.IsAuthenticated == true;

        if (!estaAutenticado)
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(new
            {
                estado = 401,
                mensaje = "Token JWT requerido. Use: Authorization: Bearer <token>"
            });
            return;
        }

        // 6. Determinar si el usuario tiene rol admin
        bool esAdmin = user!.Claims.Any(c =>
            (c.Type == ClaimTypes.Role || c.Type == "role") &&
            string.Equals(c.Value, "admin", StringComparison.OrdinalIgnoreCase));

        // 7. Acceso a tablas de administración: solo ADMIN
        bool esTablaAdmin = tabla is not null && TablasSoloAdmin.Contains(tabla);
        if (esTablaAdmin && !esAdmin)
        {
            context.Response.StatusCode = StatusCodes.Status403Forbidden;
            await context.Response.WriteAsJsonAsync(new
            {
                estado = 403,
                mensaje = $"Acceso denegado. La tabla '{tabla}' solo es accesible con rol ADMIN."
            });
            return;
        }

        // 8. DELETE: solo ADMIN
        if (esDelete && !esAdmin)
        {
            context.Response.StatusCode = StatusCodes.Status403Forbidden;
            await context.Response.WriteAsJsonAsync(new
            {
                estado = 403,
                mensaje = "Acceso denegado. Las operaciones DELETE requieren rol ADMIN."
            });
            return;
        }

        // 9. POST / PUT: cualquier usuario autenticado puede continuar
        await _next(context);
    }
}
