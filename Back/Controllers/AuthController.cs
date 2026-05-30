// AuthController.cs
// Controlador de autenticación y autorización.
//
// Endpoints:
//   POST /auth/register  — Registro de nuevo usuario (público)
//   POST /auth/login     — Login, devuelve JWT (público)
//   POST /auth/logout    — Cerrar sesión (requiere JWT)
//
// Seguridad:
//   - Contraseñas hasheadas con BCrypt (costo 12)
//   - Token JWT firmado con HMAC-SHA256
//   - Expiración configurable (mínimo 8 horas)
//   - Payload incluye: id, email, username, roles

using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ApiGenericaCsharp.Modelos;
using ApiGenericaCsharp.Servicios.Abstracciones;
using ApiGenericaCsharp.Servicios.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace ApiGenericaCsharp.Controllers
{
    [ApiController]
    [Route("auth")]
    public class AuthController : ControllerBase
    {
        private readonly IServicioCrud _servicioCrud;
        private readonly ConfiguracionJwt _configuracionJwt;
        private readonly ILogger<AuthController> _logger;

        // Tablas usadas para autenticación
        private const string TablaUsuario = "usuario";
        private const string TablaRol = "rol";
        private const string TablaRolUsuario = "rol_usuario";

        public AuthController(
            IServicioCrud servicioCrud,
            IOptions<ConfiguracionJwt> opcionesJwt,
            ILogger<AuthController> logger)
        {
            _servicioCrud = servicioCrud ?? throw new ArgumentNullException(nameof(servicioCrud));
            _configuracionJwt = opcionesJwt.Value;
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        // ──────────────────────────────────────────────────────────────
        // POST /auth/register
        // Registro de usuario nuevo.
        // Valida campos, hashea contraseña y guarda en la tabla usuario.
        // ──────────────────────────────────────────────────────────────
        /// <summary>
        /// Registra un nuevo usuario en el sistema.
        /// </summary>
        /// <remarks>
        /// Ejemplo de request:
        ///
        ///     POST /auth/register
        ///     {
        ///         "username": "nuevo_usuario",
        ///         "email": "nuevo@test.com",
        ///         "password": "MiClave123*",
        ///         "nombreCompleto": "Nombre Apellido"
        ///     }
        ///
        /// </remarks>
        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            // ── 1. Validación de campos requeridos ──
            if (string.IsNullOrWhiteSpace(request.Username))
                return BadRequest(new { estado = 400, mensaje = "El campo 'username' es requerido." });

            if (string.IsNullOrWhiteSpace(request.Email))
                return BadRequest(new { estado = 400, mensaje = "El campo 'email' es requerido." });

            if (string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { estado = 400, mensaje = "El campo 'password' es requerido." });

            if (request.Password.Length < 8)
                return BadRequest(new { estado = 400, mensaje = "La contraseña debe tener mínimo 8 caracteres." });

            if (!request.Email.Contains('@') || !request.Email.Contains('.'))
                return BadRequest(new { estado = 400, mensaje = "El formato del email no es válido." });

            try
            {
                // ── 2. Verificar que el email no esté ya registrado ──
                var usuariosExistentes = await _servicioCrud.ObtenerPorClaveAsync(
                    TablaUsuario, null, "email", request.Email.Trim().ToLower());

                if (usuariosExistentes.Count > 0)
                    return Conflict(new { estado = 409, mensaje = "Ya existe un usuario registrado con ese email." });

                // ── 3. Verificar que el username no esté tomado ──
                var porUsername = await _servicioCrud.ObtenerPorClaveAsync(
                    TablaUsuario, null, "username", request.Username.Trim());

                if (porUsername.Count > 0)
                    return Conflict(new { estado = 409, mensaje = "El nombre de usuario ya está en uso." });

                // ── 4. Hashear contraseña con BCrypt ──
                string passwordHash = EncriptacionBCrypt.Encriptar(request.Password);

                // ── 5. Insertar usuario ──
                var datosUsuario = new Dictionary<string, object?>
                {
                    ["username"]        = request.Username.Trim(),
                    ["email"]           = request.Email.Trim().ToLower(),
                    ["password"]        = passwordHash,
                    ["nombre_completo"] = request.NombreCompleto?.Trim() ?? "",
                    ["activo"]          = 1
                };

                bool creado = await _servicioCrud.CrearAsync(TablaUsuario, null, datosUsuario);

                if (!creado)
                    return StatusCode(500, new { estado = 500, mensaje = "No se pudo crear el usuario. Intente nuevamente." });

                // ── 6. Asignar rol "usuario" por defecto ──
                await AsignarRolPorDefecto(request.Username.Trim(), "usuario");

                _logger.LogInformation("REGISTRO — Nuevo usuario: {Username} ({Email})", request.Username, request.Email);

                return Ok(new
                {
                    estado = 200,
                    mensaje = "Usuario registrado exitosamente.",
                    usuario = new
                    {
                        username = request.Username.Trim(),
                        email = request.Email.Trim().ToLower(),
                        nombreCompleto = request.NombreCompleto?.Trim() ?? "",
                        rol = "usuario"
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "ERROR REGISTRO — {Username}", request.Username);
                return StatusCode(500, new { estado = 500, mensaje = "Error interno al registrar usuario.", detalle = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // POST /auth/login
        // Login. Verifica credenciales y retorna JWT firmado.
        // ──────────────────────────────────────────────────────────────
        /// <summary>
        /// Inicia sesión y devuelve un token JWT.
        /// </summary>
        /// <remarks>
        /// Ejemplo de request:
        ///
        ///     POST /auth/login
        ///     {
        ///         "username": "admin@test.com",
        ///         "password": "Admin123*"
        ///     }
        ///
        /// Respuesta exitosa incluye token JWT para usar en: Authorization: Bearer {token}
        /// </remarks>
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            // ── 1. Validación básica ──
            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { estado = 400, mensaje = "Los campos 'username' y 'password' son obligatorios." });

            try
            {
                // ── 2. Detectar si el username es email o nombre de usuario ──
                string campoIdentificador = request.Username.Contains('@') ? "email" : "username";

                // ── 3. Verificar contraseña con BCrypt ──
                var (codigo, mensajeVerif) = await _servicioCrud.VerificarContrasenaAsync(
                    TablaUsuario, null,
                    campoIdentificador, "password",
                    request.Username.Trim(), request.Password);

                if (codigo == 404)
                    return NotFound(new { estado = 404, mensaje = "Usuario no encontrado." });

                if (codigo == 401)
                    return Unauthorized(new { estado = 401, mensaje = "Credenciales inválidas." });

                if (codigo != 200)
                    return StatusCode(500, new { estado = 500, mensaje = "Error al verificar credenciales.", detalle = mensajeVerif });

                // ── 4. Cargar datos del usuario ──
                var usuarios = await _servicioCrud.ObtenerPorClaveAsync(
                    TablaUsuario, null, campoIdentificador, request.Username.Trim());

                var usuario = usuarios.FirstOrDefault();
                if (usuario is null)
                    return Unauthorized(new { estado = 401, mensaje = "No fue posible cargar el usuario." });

                // ── 5. Verificar que el usuario esté activo ──
                if (usuario.TryGetValue("activo", out var activoObj) && !EsActivo(activoObj))
                    return Unauthorized(new { estado = 401, mensaje = "Usuario inactivo. Contacte al administrador." });

                string usuarioId = Convert.ToString(usuario.GetValueOrDefault("id")) ?? "";
                string username  = Convert.ToString(usuario.GetValueOrDefault("username")) ?? request.Username;
                string email     = Convert.ToString(usuario.GetValueOrDefault("email")) ?? "";

                if (string.IsNullOrWhiteSpace(usuarioId))
                    return Unauthorized(new { estado = 401, mensaje = "Usuario sin identificador válido." });

                // ── 6. Obtener roles del usuario ──
                var roles = await ObtenerRolesAsync(usuarioId);
                if (roles.Count == 0)
                    roles.Add("usuario");

                // ── 7. Construir claims del JWT ──
                var claims = new List<Claim>
                {
                    new(ClaimTypes.NameIdentifier, usuarioId),
                    new(ClaimTypes.Name, username),
                    new(ClaimTypes.Email, email),
                    new("id", usuarioId),
                    new("email", email)
                };
                claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

                // ── 8. Generar token JWT ──
                var jwtKey = Environment.GetEnvironmentVariable("JWT_SECRET") ?? _configuracionJwt.Key;
                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
                var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
                int duracion = _configuracionJwt.DuracionMinutos > 0 ? _configuracionJwt.DuracionMinutos : 480;

                var token = new JwtSecurityToken(
                    issuer: _configuracionJwt.Issuer,
                    audience: _configuracionJwt.Audience,
                    claims: claims,
                    expires: DateTime.UtcNow.AddMinutes(duracion),
                    signingCredentials: creds);

                string tokenStr = new JwtSecurityTokenHandler().WriteToken(token);

                _logger.LogInformation("LOGIN EXITOSO — Usuario: {Username}, Roles: {Roles}",
                    username, string.Join(", ", roles));

                return Ok(new
                {
                    estado = 200,
                    mensaje = "Autenticación exitosa.",
                    token = tokenStr,
                    expiracion = token.ValidTo,
                    usuario = new
                    {
                        id = usuarioId,
                        username,
                        email,
                        roles
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "ERROR LOGIN — {Username}", request.Username);
                return StatusCode(500, new { estado = 500, mensaje = "Error interno al autenticar.", detalle = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // POST /auth/logout
        // Cierra la sesión del usuario autenticado.
        // En JWT la invalidación real es del lado del cliente (eliminar el token).
        // ──────────────────────────────────────────────────────────────
        /// <summary>
        /// Cierra la sesión del usuario. El cliente debe eliminar el token JWT.
        /// </summary>
        [Authorize]
        [HttpPost("logout")]
        public IActionResult Logout()
        {
            var username = User.FindFirstValue(ClaimTypes.Name) ?? "desconocido";
            _logger.LogInformation("LOGOUT — Usuario: {Username}", username);

            return Ok(new
            {
                estado = 200,
                mensaje = "Sesión cerrada exitosamente. Elimine el token del cliente.",
                usuario = username,
                timestamp = DateTime.UtcNow
            });
        }

        // ──────────────────────────────────────────────────────────────
        // HELPERS PRIVADOS
        // ──────────────────────────────────────────────────────────────

        private async Task<List<string>> ObtenerRolesAsync(string usuarioId)
        {
            var relaciones = await _servicioCrud.ObtenerPorClaveAsync(
                TablaRolUsuario, null, "usuario_id", usuarioId);

            var roles = new List<string>();
            foreach (var rel in relaciones)
            {
                string? rolId = Convert.ToString(rel.GetValueOrDefault("rol_id"));
                if (string.IsNullOrWhiteSpace(rolId)) continue;

                var rolesTabla = await _servicioCrud.ObtenerPorClaveAsync(TablaRol, null, "id", rolId);
                var rol = rolesTabla.FirstOrDefault();
                if (rol is null) continue;

                string? nombre = Convert.ToString(rol.GetValueOrDefault("nombre"));
                if (string.IsNullOrWhiteSpace(nombre)) continue;

                if (rol.TryGetValue("activo", out var activo) && !EsActivo(activo)) continue;
                roles.Add(nombre);
            }

            return roles.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        }

        private async Task AsignarRolPorDefecto(string username, string nombreRol)
        {
            try
            {
                // Obtener ID del usuario recién creado
                var usuarios = await _servicioCrud.ObtenerPorClaveAsync(TablaUsuario, null, "username", username);
                var usuario = usuarios.FirstOrDefault();
                if (usuario is null) return;

                string? usuarioId = Convert.ToString(usuario.GetValueOrDefault("id"));
                if (string.IsNullOrWhiteSpace(usuarioId)) return;

                // Obtener ID del rol
                var roles = await _servicioCrud.ObtenerPorClaveAsync(TablaRol, null, "nombre", nombreRol);
                var rol = roles.FirstOrDefault();
                if (rol is null) return;

                string? rolId = Convert.ToString(rol.GetValueOrDefault("id"));
                if (string.IsNullOrWhiteSpace(rolId)) return;

                // Asignar rol
                await _servicioCrud.CrearAsync(TablaRolUsuario, null, new Dictionary<string, object?>
                {
                    ["usuario_id"] = int.Parse(usuarioId),
                    ["rol_id"]     = int.Parse(rolId)
                });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo asignar rol por defecto al usuario {Username}", username);
            }
        }

        private static bool EsActivo(object? valor) => valor switch
        {
            null          => false,
            bool b        => b,
            byte by       => by > 0,
            short s       => s > 0,
            int i         => i > 0,
            long l        => l > 0,
            string st when bool.TryParse(st, out var b) => b,
            string st when int.TryParse(st, out var i)  => i > 0,
            _             => false
        };
    }

    // ──────────────────────────────────────────────────────────────
    // DTOs
    // ──────────────────────────────────────────────────────────────

    /// <summary>Datos necesarios para registrar un nuevo usuario.</summary>
    public class RegisterRequest
    {
        /// <summary>Nombre de usuario único (no puede contener espacios)</summary>
        public string Username { get; set; } = string.Empty;

        /// <summary>Correo electrónico único y válido</summary>
        public string Email { get; set; } = string.Empty;

        /// <summary>Contraseña en texto plano (mínimo 8 caracteres). Se guarda hasheada.</summary>
        public string Password { get; set; } = string.Empty;

        /// <summary>Nombre completo del usuario (opcional)</summary>
        public string? NombreCompleto { get; set; }
    }

    /// <summary>Credenciales para iniciar sesión.</summary>
    public class LoginRequest
    {
        /// <summary>Puede ser el username o el email del usuario</summary>
        public string Username { get; set; } = string.Empty;

        /// <summary>Contraseña en texto plano</summary>
        public string Password { get; set; } = string.Empty;
    }
}
