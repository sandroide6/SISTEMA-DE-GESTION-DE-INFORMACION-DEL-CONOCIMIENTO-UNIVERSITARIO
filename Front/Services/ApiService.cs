using System.Net.Http.Json;
using System.Text.Json;
using System.Net.Http.Headers;

namespace FrontBlazor_AppiGenericaCsharp.Services
{
    public class ApiService
    {
        private readonly HttpClient _http;
        private readonly AuthSessionService _sesion;

        private readonly JsonSerializerOptions _jsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };

        public ApiService(HttpClient http, AuthSessionService sesion)
        {
            _http = http;
            _sesion = sesion;
        }

        public async Task<(bool exito, string mensaje)> LoginAsync(string username, string password)
        {
            // CORRECCIÓN: El payload ahora incluye la tabla y los nombres de columna reales de tu BD
            var payload = new 
            { 
                tabla = "usuario",
                campoUsuario = "username",      // Nombre de la columna en SQL Server
                campoContrasena = "password",   // Nombre de la columna en SQL Server
                usuario = username,             // Valor ingresado en el input
                contrasena = password           // Valor ingresado en el input
            };

            var request = CrearRequest(HttpMethod.Post, "/api/login");
            request.Content = JsonContent.Create(payload);

            var response = await _http.SendAsync(request);
            var contenido = await LeerContenidoJson(response);

            if (!response.IsSuccessStatusCode)
            {
                return (false, ExtraerMensaje(contenido, "No fue posible iniciar sesión."));
            }

            // Extracción de datos del JSON de respuesta
            string token = contenido.TryGetProperty("token", out var tokenProp) ? tokenProp.GetString() ?? "" : "";
            
            string userId = contenido.TryGetProperty("usuario", out var usuarioProp) &&
                            usuarioProp.TryGetProperty("id", out var idProp)
                ? idProp.ToString()
                : "";

            string user = contenido.TryGetProperty("usuario", out var usuario2) &&
                          usuario2.TryGetProperty("username", out var usernameProp)
                ? usernameProp.GetString() ?? username
                : username;

            var roles = new List<string>();
            if (contenido.TryGetProperty("usuario", out var usuario3) &&
                usuario3.TryGetProperty("roles", out var rolesProp) &&
                rolesProp.ValueKind == JsonValueKind.Array)
            {
                foreach (var r in rolesProp.EnumerateArray())
                {
                    var rol = r.GetString();
                    if (!string.IsNullOrWhiteSpace(rol))
                        roles.Add(rol);
                }
            }

            if (string.IsNullOrWhiteSpace(token))
                return (false, "La API no devolvió un token válido.");

            // Guardar la sesión en el navegador
            _sesion.IniciarSesion(token, userId, user, roles);
            return (true, "Sesión iniciada correctamente.");
        }

        public Task LogoutAsync()
        {
            _sesion.CerrarSesion();
            return Task.CompletedTask;
        }

        public async Task<List<Dictionary<string, object?>>> ListarAsync(string tabla, int? limite = null)
        {
            try
            {
                string url = $"/api/{tabla}";
                if (limite.HasValue)
                    url += $"?limite={limite.Value}";

                var request = CrearRequest(HttpMethod.Get, url);
                var httpResponse = await _http.SendAsync(request);
                if (!httpResponse.IsSuccessStatusCode)
                    return new List<Dictionary<string, object?>>();

                var respuesta = await httpResponse.Content.ReadFromJsonAsync<JsonElement>(_jsonOptions);

                if (respuesta.TryGetProperty("datos", out JsonElement datos))
                {
                    return ConvertirDatos(datos);
                }

                return new List<Dictionary<string, object?>>();
            }
            catch (HttpRequestException ex)
            {
                Console.WriteLine($"Error al listar {tabla}: {ex.Message}");
                return new List<Dictionary<string, object?>>();
            }
        }

        public async Task<(bool exito, string mensaje)> CrearAsync(
            string tabla, Dictionary<string, object?> datos,
            string? camposEncriptar = null)
        {
            try
            {
                string url = $"/api/{tabla}";
                if (!string.IsNullOrEmpty(camposEncriptar))
                    url += $"?camposEncriptar={camposEncriptar}";

                var request = CrearRequest(HttpMethod.Post, url);
                request.Content = JsonContent.Create(datos);
                var respuesta = await _http.SendAsync(request);
                var contenido = await LeerContenidoJson(respuesta);
                return (respuesta.IsSuccessStatusCode, ExtraerMensaje(contenido, "Operacion completada."));
            }
            catch (HttpRequestException ex)
            {
                return (false, $"Error de conexion: {ex.Message}");
            }
        }

        public async Task<(bool exito, string mensaje)> ActualizarAsync(
            string tabla, string nombreClave, string valorClave,
            Dictionary<string, object?> datos,
            string? camposEncriptar = null)
        {
            try
            {
                string url = $"/api/{tabla}/{nombreClave}/{valorClave}";
                if (!string.IsNullOrEmpty(camposEncriptar))
                    url += $"?camposEncriptar={camposEncriptar}";

                var request = CrearRequest(HttpMethod.Put, url);
                request.Content = JsonContent.Create(datos);
                var respuesta = await _http.SendAsync(request);
                var contenido = await LeerContenidoJson(respuesta);
                return (respuesta.IsSuccessStatusCode, ExtraerMensaje(contenido, "Operacion completada."));
            }
            catch (HttpRequestException ex)
            {
                return (false, $"Error de conexion: {ex.Message}");
            }
        }

        public async Task<(bool exito, string mensaje)> EliminarAsync(
            string tabla, string nombreClave, string valorClave)
        {
            try
            {
                var request = CrearRequest(HttpMethod.Delete, $"/api/{tabla}/{nombreClave}/{valorClave}");
                var respuesta = await _http.SendAsync(request);
                var contenido = await LeerContenidoJson(respuesta);
                return (respuesta.IsSuccessStatusCode, ExtraerMensaje(contenido, "Operacion completada."));
            }
            catch (HttpRequestException ex)
            {
                return (false, $"Error de conexion: {ex.Message}");
            }
        }

        public async Task<Dictionary<string, string>?> ObtenerDiagnosticoAsync()
        {
            try
            {
                var request = CrearRequest(HttpMethod.Get, "/api/diagnostico/conexion");
                var httpResponse = await _http.SendAsync(request);
                if (!httpResponse.IsSuccessStatusCode) return null;
                var respuesta = await httpResponse.Content.ReadFromJsonAsync<JsonElement>(_jsonOptions);

                if (respuesta.TryGetProperty("servidor", out JsonElement servidor))
                {
                    var info = new Dictionary<string, string>();
                    foreach (var prop in servidor.EnumerateObject())
                    {
                        info[prop.Name] = prop.Value.ToString();
                    }
                    return info;
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        private HttpRequestMessage CrearRequest(HttpMethod method, string url)
        {
            var request = new HttpRequestMessage(method, url);
            if (!string.IsNullOrWhiteSpace(_sesion.Token))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _sesion.Token);
            }
            return request;
        }

        private async Task<JsonElement> LeerContenidoJson(HttpResponseMessage response)
        {
            try
            {
                return await response.Content.ReadFromJsonAsync<JsonElement>(_jsonOptions);
            }
            catch
            {
                return default;
            }
        }

        private static string ExtraerMensaje(JsonElement contenido, string defecto)
        {
            if (contenido.ValueKind != JsonValueKind.Undefined &&
                contenido.TryGetProperty("mensaje", out JsonElement msg))
            {
                return msg.GetString() ?? defecto;
            }
            return defecto;
        }

        private List<Dictionary<string, object?>> ConvertirDatos(JsonElement datos)
        {
            var lista = new List<Dictionary<string, object?>>();

            foreach (var fila in datos.EnumerateArray())
            {
                var diccionario = new Dictionary<string, object?>();

                foreach (var propiedad in fila.EnumerateObject())
                {
                    diccionario[propiedad.Name] = propiedad.Value.ValueKind switch
                    {
                        JsonValueKind.String => propiedad.Value.GetString(),
                        JsonValueKind.Number => propiedad.Value.TryGetInt32(out int i) ? i : propiedad.Value.GetDouble(),
                        JsonValueKind.True => true,
                        JsonValueKind.False => false,
                        JsonValueKind.Null => null,
                        _ => propiedad.Value.GetRawText()
                    };
                }

                lista.Add(diccionario);
            }

            return lista;
        }
    }
}