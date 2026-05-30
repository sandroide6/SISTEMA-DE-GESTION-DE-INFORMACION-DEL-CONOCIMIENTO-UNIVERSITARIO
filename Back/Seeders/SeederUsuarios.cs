// SeederUsuarios.cs
// Crea los usuarios y roles de prueba al iniciar la aplicación.
// Solo inserta si no existen (idempotente — se puede ejecutar múltiples veces).
//
// Usuarios creados:
//   admin@test.com  / Admin123*  → rol: admin
//   user@test.com   / User123*   → rol: usuario

using ApiGenericaCsharp.Servicios.Abstracciones;
using ApiGenericaCsharp.Servicios.Utilidades;
using Microsoft.Extensions.Logging;

namespace ApiGenericaCsharp.Seeders
{
    public class SeederUsuarios
    {
        private readonly IServicioCrud _servicioCrud;
        private readonly ILogger<SeederUsuarios> _logger;

        private const string TablaRol       = "rol";
        private const string TablaUsuario   = "usuario";
        private const string TablaRolUsuario = "rol_usuario";

        public SeederUsuarios(IServicioCrud servicioCrud, ILogger<SeederUsuarios> logger)
        {
            _servicioCrud = servicioCrud ?? throw new ArgumentNullException(nameof(servicioCrud));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        /// <summary>
        /// Ejecuta el seeding de roles y usuarios de prueba.
        /// Es seguro llamarlo siempre al iniciar la app (no duplica registros).
        /// </summary>
        public async Task SeedAsync()
        {
            try
            {
                _logger.LogInformation("SEEDER — Iniciando seed de usuarios y roles...");

                // ── 1. Crear roles base ──
                int rolAdminId   = await ObtenerOCrearRolAsync("admin",   "Administrador del sistema con acceso completo");
                int rolUsuarioId = await ObtenerOCrearRolAsync("usuario", "Usuario estándar con acceso de lectura y escritura");

                if (rolAdminId <= 0 || rolUsuarioId <= 0)
                {
                    _logger.LogError("SEEDER — No se pudieron obtener los IDs de los roles. Verifique la tabla 'rol'.");
                    return;
                }

                // ── 2. Crear usuarios de prueba ──
                await ObtenerOCrearUsuarioAsync(
                    username:       "admin_test",
                    email:          "admin@test.com",
                    password:       "Admin123*",
                    nombreCompleto: "Administrador de Prueba",
                    rolId:          rolAdminId);

                await ObtenerOCrearUsuarioAsync(
                    username:       "user_test",
                    email:          "user@test.com",
                    password:       "User123*",
                    nombreCompleto: "Usuario de Prueba",
                    rolId:          rolUsuarioId);

                _logger.LogInformation("SEEDER — Seed completado exitosamente.");
            }
            catch (Exception ex)
            {
                // El seeder no debe detener el arranque de la app ante fallas
                _logger.LogWarning(ex,
                    "SEEDER — No se completó el seed de usuarios. " +
                    "Verifique que la BD esté accesible y las tablas existan (ejecute BD.sql primero).");
            }
        }

        // ──────────────────────────────────────────────────────────────
        private async Task<int> ObtenerOCrearRolAsync(string nombre, string descripcion)
        {
            try
            {
                // ¿Ya existe?
                var roles = await _servicioCrud.ObtenerPorClaveAsync(TablaRol, null, "nombre", nombre);
                if (roles.Count > 0)
                {
                    int idExistente = Convert.ToInt32(roles[0].GetValueOrDefault("id") ?? 0);
                    _logger.LogDebug("SEEDER — Rol '{Nombre}' ya existe (id={Id})", nombre, idExistente);
                    return idExistente;
                }

                // Crear rol
                await _servicioCrud.CrearAsync(TablaRol, null, new Dictionary<string, object?>
                {
                    ["nombre"]      = nombre,
                    ["descripcion"] = descripcion,
                    ["activo"]      = 1
                });

                // Recuperar el ID recién insertado
                var creados = await _servicioCrud.ObtenerPorClaveAsync(TablaRol, null, "nombre", nombre);
                int nuevoId = Convert.ToInt32(creados.FirstOrDefault()?.GetValueOrDefault("id") ?? 0);
                _logger.LogInformation("SEEDER — Rol '{Nombre}' creado (id={Id})", nombre, nuevoId);
                return nuevoId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SEEDER — Error al crear/obtener rol '{Nombre}'", nombre);
                return 0;
            }
        }

        private async Task ObtenerOCrearUsuarioAsync(
            string username, string email, string password,
            string nombreCompleto, int rolId)
        {
            try
            {
                // ¿Ya existe por email?
                var existentes = await _servicioCrud.ObtenerPorClaveAsync(TablaUsuario, null, "email", email);
                if (existentes.Count > 0)
                {
                    _logger.LogDebug("SEEDER — Usuario '{Email}' ya existe", email);
                    return;
                }

                // Hashear contraseña con BCrypt
                string passwordHash = EncriptacionBCrypt.Encriptar(password);

                // Crear usuario
                await _servicioCrud.CrearAsync(TablaUsuario, null, new Dictionary<string, object?>
                {
                    ["username"]        = username,
                    ["email"]           = email,
                    ["password"]        = passwordHash,
                    ["nombre_completo"] = nombreCompleto,
                    ["activo"]          = 1
                });

                // Obtener ID del usuario recién creado
                var creados = await _servicioCrud.ObtenerPorClaveAsync(TablaUsuario, null, "email", email);
                var usuario = creados.FirstOrDefault();
                if (usuario is null)
                {
                    _logger.LogError("SEEDER — No se pudo recuperar el ID del usuario '{Email}'", email);
                    return;
                }

                int usuarioId = Convert.ToInt32(usuario.GetValueOrDefault("id") ?? 0);
                if (usuarioId <= 0)
                {
                    _logger.LogError("SEEDER — ID inválido para usuario '{Email}'", email);
                    return;
                }

                // Asignar rol
                await _servicioCrud.CrearAsync(TablaRolUsuario, null, new Dictionary<string, object?>
                {
                    ["usuario_id"] = usuarioId,
                    ["rol_id"]     = rolId
                });

                _logger.LogInformation(
                    "SEEDER — Usuario '{Email}' creado exitosamente (id={Id}, rolId={RolId})",
                    email, usuarioId, rolId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SEEDER — Error al crear usuario '{Email}'", email);
            }
        }
    }
}
