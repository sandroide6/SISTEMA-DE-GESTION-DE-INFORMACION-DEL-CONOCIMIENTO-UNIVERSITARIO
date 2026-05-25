using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ApiGenericaCsharp.Modelos;
using ApiGenericaCsharp.Servicios.Abstracciones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace ApiGenericaCsharp.Controllers;

[ApiController]
[Route("api/login")]
public class LoginController : ControllerBase
{
    private readonly IServicioCrud _servicioCrud;
    private readonly ConfiguracionJwt _configuracionJwt;

    public LoginController(IServicioCrud servicioCrud, IOptions<ConfiguracionJwt> opcionesJwt)
    {
        _servicioCrud = servicioCrud;
        _configuracionJwt = opcionesJwt.Value;
    }

    [AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { estado = 400, mensaje = "username y password son obligatorios." });
        }

        var (codigo, mensaje) = await _servicioCrud.VerificarContrasenaAsync(
            "usuario",
            null,
            "username",
            "password",
            request.Username,
            request.Password);

        if (codigo == 404)
            return NotFound(new { estado = 404, mensaje = "Usuario no encontrado." });

        if (codigo == 401)
            return Unauthorized(new { estado = 401, mensaje = "Credenciales inválidas." });

        if (codigo != 200)
            return StatusCode(500, new { estado = 500, mensaje = "Error validando credenciales.", detalle = mensaje });

        var usuarios = await _servicioCrud.ObtenerPorClaveAsync("usuario", null, "username", request.Username);
        var usuario = usuarios.FirstOrDefault();
        if (usuario is null)
            return Unauthorized(new { estado = 401, mensaje = "No fue posible cargar el usuario." });

        if (usuario.TryGetValue("activo", out var activoObj) && !EsActivo(activoObj))
            return Unauthorized(new { estado = 401, mensaje = "Usuario inactivo." });

        string usuarioId = Convert.ToString(usuario.GetValueOrDefault("id")) ?? string.Empty;
        if (string.IsNullOrWhiteSpace(usuarioId))
            return Unauthorized(new { estado = 401, mensaje = "Usuario sin identificador válido." });

        var roles = await ObtenerRolesUsuarioAsync(usuarioId);
        if (roles.Count == 0)
            roles.Add("usuario");

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, usuarioId),
            new(ClaimTypes.Name, request.Username)
        };
        claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuracionJwt.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var duracion = _configuracionJwt.DuracionMinutos > 0 ? _configuracionJwt.DuracionMinutos : 60;

        var token = new JwtSecurityToken(
            issuer: _configuracionJwt.Issuer,
            audience: _configuracionJwt.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(duracion),
            signingCredentials: creds);

        return Ok(new
        {
            estado = 200,
            mensaje = "Autenticación exitosa.",
            token = new JwtSecurityTokenHandler().WriteToken(token),
            expiracion = token.ValidTo,
            usuario = new
            {
                id = usuarioId,
                username = request.Username,
                roles
            }
        });
    }

    private async Task<List<string>> ObtenerRolesUsuarioAsync(string usuarioId)
    {
        var relaciones = await _servicioCrud.ObtenerPorClaveAsync("rol_usuario", null, "usuario_id", usuarioId);
        var roles = new List<string>();

        foreach (var relacion in relaciones)
        {
            string? rolId = Convert.ToString(relacion.GetValueOrDefault("rol_id"));
            if (string.IsNullOrWhiteSpace(rolId))
                continue;

            var rolesTabla = await _servicioCrud.ObtenerPorClaveAsync("rol", null, "id", rolId);
            var rol = rolesTabla.FirstOrDefault();
            if (rol is null)
                continue;

            string? nombre = Convert.ToString(rol.GetValueOrDefault("nombre"));
            if (string.IsNullOrWhiteSpace(nombre))
                continue;

            if (rol.TryGetValue("activo", out var activoObj) && !EsActivo(activoObj))
                continue;

            roles.Add(nombre);
        }

        return roles
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static bool EsActivo(object? valor)
    {
        return valor switch
        {
            null => false,
            bool b => b,
            byte by => by > 0,
            short s => s > 0,
            int i => i > 0,
            long l => l > 0,
            string st when bool.TryParse(st, out var b) => b,
            string st when int.TryParse(st, out var i) => i > 0,
            _ => false
        };
    }
}

public class LoginRequest
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
