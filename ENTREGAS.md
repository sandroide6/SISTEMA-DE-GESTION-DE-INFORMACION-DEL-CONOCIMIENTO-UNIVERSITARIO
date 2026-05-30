# SIGCU — Historial de Entregas Académicas

Documento que describe los cambios, funcionalidades implementadas y decisiones técnicas tomadas en cada entrega del proyecto **Sistema Integrado de Gestión del Conocimiento Universitario (SIGCU)**.

---

## Primera Entrega — 09 de marzo (20%)

**Requisito:** CRUD de las tablas que **no requieren claves foráneas** (APIREST + FRONT-END)

### ¿Qué se implementó?

#### Backend (API REST)

- Proyecto **ASP.NET Core 9** con arquitectura genérica: un solo controlador maneja todas las tablas
- **`EntidadesController`**: endpoints `GET`, `POST`, `PUT`, `DELETE` para `/api/{tabla}`
- Soporte multi-proveedor de base de datos: **SQL Server**, PostgreSQL, MySQL, MariaDB
- Swagger UI y ReDoc para documentación de la API
- `appsettings.json` con configuración de conexión y JWT base

#### Frontend (Blazor Server)

- Proyecto **Blazor Server .NET 9** con componentes interactivos
- **`ApiService.cs`**: cliente HTTP genérico con soporte para CRUD
- **`AuthSessionService.cs`**: manejo de sesión en memoria
- Layout principal con menú lateral (`NavMenu.razor`)

#### Tablas con CRUD implementado (sin FK)

| Tabla | Ruta frontend | Campos principales |
|-------|--------------|-------------------|
| `universidad` | `/dashboard/universidad` | nombre, tipo, ciudad |
| `departamento` | `/dashboard/departamento` | nombre |
| `docente` | `/dashboard/docente` | nombre, email |
| `aliado` | `/dashboard/aliado` | nombre, tipo, nit, correo, telefono |
| `area_conocimiento` | `/dashboard/area-conocimiento` | gran_area, area, disciplina |
| `aspecto_normativo` | `/dashboard/aspecto-normativo` | tipo, descripcion, fuente |
| `car_innovacion` | `/dashboard/car-innovacion` | nombre, descripcion, tipo |
| `enfoque` | `/dashboard/enfoque` | nombre, descripcion |
| `practica_estrategia` | `/dashboard/practica-estrategia` | tipo, nombre, descripcion |
| `disenio` | `/dashboard/disenio` | nombre, descripcion |

#### Base de datos

- Script `BD.sql` con definición de las 10 tablas base
- Sin datos de ejemplo en esta entrega

---

## Segunda Entrega — 06 de abril (20%)

**Requisito:** CRUD de **todas las tablas** incluyendo las que tienen FK (APIREST + FRONT-END). Rama individual en GitHub.

### ¿Qué se implementó?

#### Backend

- CRUD completo para las 15 tablas adicionales con FK
- Manejo correcto de relaciones: tablas con PK compuesta (sin IDENTITY), tabla con PK `varchar` (`registro_calificado`)
- Soporte para campo `espejo` tipo BIT en `activ_academica`
- Endpoint `GET /api/{tabla}/{campo}/{valor}` para filtros

#### Frontend — Nuevas páginas CRUD

| Tabla | Ruta | FK principales |
|-------|------|---------------|
| `facultad` | `/dashboard/facultad` | → universidad |
| `programa` | `/dashboard/programa` | → facultad |
| `acreditacion` | `/dashboard/acreditacion` | → programa |
| `activ_academica` | `/dashboard/activ-academica` | → disenio |
| `alianza` | `/dashboard/alianza` | → aliado, departamento, docente |
| `an_programa` | `/dashboard/an-programa` | → aspecto_normativo, programa |
| `docente_departamento` | `/dashboard/docente-departamento` | → docente, departamento |
| `pasantia` | `/dashboard/pasantia` | → programa |
| `premio` | `/dashboard/premio` | → programa |
| `programa_ac` | `/dashboard/programa-ac` | → programa, area_conocimiento |
| `programa_ci` | `/dashboard/programa-ci` | → programa, car_innovacion |
| `programa_pe` | `/dashboard/programa-pe` | → programa, practica_estrategia |
| `registro_calificado` | `/dashboard/registro-calificado` | → programa (PK varchar) |
| `aa_rc` | `/dashboard/aa-rc` | → activ_academica, registro_calificado |
| `enfoque_rc` | `/dashboard/enfoque-rc` | → enfoque, registro_calificado |

#### Correcciones aplicadas en esta entrega

- Bug en `ActivAcademica.razor`: nombre de tabla `activ_academicas` (plural) corregido a `activ_academica`
- Mejora en `ApiService.ListarAsync`: captura de todas las excepciones (`Exception` en lugar de solo `HttpRequestException`) para evitar pantallas colgadas
- Manejo de respuesta `204 No Content` cuando una tabla está vacía

#### Rama GitHub

- Rama `Dev-samuel-patino` creada para desarrollo individual
- `main` administrada como rama principal del proyecto

---

## Tercera Entrega — 27 de abril (20%)

**Requisito:** JWT, variables de sesión y control de acceso a menús. Admin es el único que puede acceder al CRUD de usuarios y roles.

### ¿Qué se implementó?

#### Backend — Autenticación y Autorización

**`AuthController.cs`** — nuevos endpoints:

| Endpoint | Descripción |
|----------|-------------|
| `POST /auth/register` | Registro con validación: email único, contraseña ≥ 8 chars, BCrypt hash |
| `POST /auth/login` | Login con email o username; JWT con roles en payload; duración 480 min |
| `POST /auth/logout` | Cierre de sesión con JWT requerido |

**JWT configurado:**
- Algoritmo: HMAC-SHA256
- Payload incluye: `id`, `username`, `email`, `roles`
- `ClockSkew = Zero` (sin tolerancia de tiempo)
- Variable de entorno `JWT_SECRET` tiene prioridad sobre `appsettings.json`
- Respuestas 401/403 en JSON (no HTML vacío)

**`RoleAuthorizationMiddleware.cs`**:
- GET: público (sin JWT requerido)
- POST / PUT: JWT válido (cualquier rol)
- DELETE: JWT + rol **ADMIN**
- Tablas `usuario`, `rol`, `rol_usuario`: **solo ADMIN** para cualquier operación

**`SeederUsuarios.cs`**:
- Crea `admin@test.com / Admin123*` (rol admin)
- Crea `user@test.com / User123*` (rol usuario)
- Idempotente: no duplica usuarios si ya existen
- Se ejecuta automáticamente al iniciar la API

#### Frontend — Control de acceso

**`AuthSessionService.cs`**:
- Almacena token, userId, username, roles en memoria
- Evento `OnChange` para notificar a componentes cuando la sesión cambia
- `EsAdmin` para verificar el rol del usuario activo

**Control de acceso en menú (`NavMenu.razor`)**:
- Sección **Administración** (Usuarios, Roles, Rol-Usuario) solo visible si `Sesion.EsAdmin`
- Botones **Eliminar** en tablas solo visibles si `Sesion.EsAdmin`
- Link **Iniciar sesión** solo visible si no hay sesión activa

**Protección de rutas en páginas**:
```csharp
// En cada página de dashboard:
if (!Sesion.EstaAutenticado) { Nav.NavigateTo("/login", true); return; }

// En páginas de administración:
if (!Sesion.EsAdmin) { Nav.NavigateTo("/dashboard/universidad", false); return; }
```

**Persistencia de sesión**:
- Token guardado en `localStorage` del navegador tras login exitoso
- Al recargar, el token se restaura desde `localStorage`

#### Correcciones en esta entrega

- `Rol.razor`: acceso directo `reg["id"]` reemplazado por `GetValueOrDefault` para evitar `KeyNotFoundException`
- `Routes.razor`: página 404 personalizada añadida
- `App.razor`: prerendering desactivado (`InteractiveServerRenderMode(prerender: false)`) para evitar que las páginas redirigieran al login antes de restaurar la sesión

---

## Cuarta Entrega — 11 de mayo (20%)

**Requisito:** Aplicativo WEB **sin imagen corporativa**, con **componente de reportes/dashboard** (10 consultas multitabla, mínimo 4 tablas por consulta).

### ¿Qué se implementó?

#### Módulo de Reportes (`Reportes.razor`)

Ruta: `/dashboard/reportes`

**Dashboard de métricas**: tarjetas en tiempo real con conteo de:
- Universidades, Facultades, Programas, Docentes, Acreditaciones, Alianzas, Pasantías, Registros Calificados

**10 consultas multitabla** ejecutadas vía `POST /api/consultas/ejecutarconsultaparametrizada`:

| # | Consulta | Tablas | Min tablas |
|---|----------|--------|:----------:|
| 1 | Programas con Facultades, Universidades y Acreditaciones | programa, facultad, universidad, acreditacion | 4 |
| 2 | Docentes, Departamentos, Alianzas y Aliados | docente, docente_departamento, departamento, alianza, aliado | 5 |
| 3 | Registro Calificado con Actividades y Diseño | registro_calificado, aa_rc, activ_academica, disenio, programa | 5 |
| 4 | Programas con Áreas de Conocimiento y Universidad | programa, programa_ac, area_conocimiento, facultad, universidad | 5 |
| 5 | Aspectos Normativos por Programa con Facultad | aspecto_normativo, an_programa, programa, facultad, universidad | 5 |
| 6 | Pasantías con Programa, Facultad y Universidad | pasantia, programa, facultad, universidad | 4 |
| 7 | Premios por Programa con Facultad y Universidad | premio, programa, facultad, universidad | 4 |
| 8 | Enfoques por Registro Calificado con Programa | enfoque, enfoque_rc, registro_calificado, programa, facultad | 5 |
| 9 | Características de Innovación por Programa | car_innovacion, programa_ci, programa, facultad, universidad | 5 |
| 10 | Prácticas y Estrategias por Programa con RC | practica_estrategia, programa_pe, programa, facultad, registro_calificado | 5 |

#### `ApiService.cs` — nuevo método

```csharp
public async Task<(List<Dictionary<string, object?>> datos, int total, string? error)>
    EjecutarConsultaAsync(string sql)
```

- Llama al endpoint de consultas parametrizadas
- Maneja correctamente la serialización camelCase de ASP.NET Core (`resultados`, `total`)
- Retorna lista de diccionarios para renderizado dinámico de columnas

#### Correcciones en esta entrega

- Bootstrap Icons no se cargaba: añadido CDN en `App.razor`
  ```html
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
  ```
- Tabla de resultados responsiva: scroll horizontal + `text-overflow:ellipsis` en celdas + tooltip con texto completo

---

## Quinta Entrega — 25 de mayo (20%)

**Requisito:** Imagen corporativa + reportes + servidor gratuito + ramas integradas en `main`.

### ¿Qué se implementó?

#### Imagen Corporativa — Marca SIGCU

Se creó una identidad visual completa para el sistema:

**Nombre:** SIGCU  
**Nombre completo:** Sistema Integrado de Gestión del Conocimiento Universitario  
**Paleta de colores:**
- Azul universitario: `#1a237e` (índigo profundo)
- Azul primario: `#1565c0`
- Azul claro: `#0288d1`
- Púrpura académico: `#6a1b9a`

**Archivos actualizados con la marca:**

| Archivo | Cambio |
|---------|--------|
| `App.razor` | Fuente Inter, paleta SIGCU global, estilos de tablas y botones |
| `NavMenu.razor` | Gradiente azul universitario, logo SIGCU arriba, avatar de usuario, secciones con etiquetas |
| `MainLayout.razor` | Barra superior con nombre completo de SIGCU |
| `Login.razor` | Diseño de dos paneles: izquierdo con brand, derecho con formulario |
| `Home.razor` | Navbar SIGCU, hero azul universitario, footer con logo |

#### Base de Datos — Datos completos

Se actualizó `BD.sql` para incluir datos de ejemplo en **todas las tablas**:

| Tabla | Registros |
|-------|:---------:|
| universidad | 4 |
| facultad | 3 |
| programa | 3 |
| departamento | 3 |
| docente | 3 |
| aliado | 4 |
| area_conocimiento | 6 |
| aspecto_normativo | 4 |
| car_innovacion | 4 |
| enfoque | 4 |
| practica_estrategia | 4 |
| disenio | 3 |
| acreditacion | 3 |
| activ_academica | 8 |
| alianza | 4 |
| an_programa | 7 |
| docente_departamento | 3 |
| pasantia | 4 |
| premio | 3 |
| programa_ac | 6 |
| programa_ci | 6 |
| programa_pe | 7 |
| registro_calificado | 3 |
| aa_rc | 8 |
| enfoque_rc | 6 |

#### Despliegue en Servidor Gratuito — MonsterASP.net

| Componente | URL | Servicio |
|-----------|-----|---------|
| Frontend Blazor | http://frontu.runasp.net | MonsterASP (site71278) |
| API Backend | http://sistemau.runasp.net | MonsterASP (site71274) |
| Base de datos | db53867.databaseasp.net | MonsterASP SQL Server |
| Documentación | http://sistemau.runasp.net/swagger | Swagger UI |

**Proceso de despliegue usado:**
1. `dotnet publish -c Release -o publicado` (compilar)
2. `msdeploy.exe -verb:sync ...` (subir al servidor)
3. IIS reinicia el app pool automáticamente al detectar cambio en `web.config`
4. SeederUsuarios crea usuarios de prueba en el nuevo servidor

#### Correcciones y mejoras finales

| Problema | Solución |
|----------|----------|
| Login redirigía al mismo login (loop) | Desactivado prerendering globalmente en `App.razor` |
| Sesión perdida al navegar | `AuthSessionService` con evento `OnChange` + restauración desde `localStorage` |
| Link "Inicio" del menú iba a `/` causando logout | Corregido a `href=""` que muestra la página de presentación |
| Tabla de reportes desbordaba la pantalla | `overflow-x:auto` + `text-overflow:ellipsis` + tooltip en celdas |
| Consultas retornaban "Sin resultados" | Corregida detección de propiedad `resultados` (camelCase) vs `Resultados` |
| Iconos de Bootstrap no aparecían | CDN de Bootstrap Icons añadido en `App.razor` |

#### GitHub — Integración de ramas

- Rama principal: `main`
- Ramas de desarrollo: `Dev-samuel-patino` (y demás integrantes)
- Todas las funcionalidades integradas en `main` para esta entrega

---

## Resumen General del Proyecto

| Entrega | Peso | Componentes entregados |
|---------|:----:|----------------------|
| 1ª — 09 mar | 20% | CRUD 10 tablas sin FK (API + Blazor) |
| 2ª — 06 abr | 20% | CRUD 28 tablas completas (API + Blazor) + rama GitHub |
| 3ª — 27 abr | 20% | JWT + BCrypt + control de acceso por roles |
| 4ª — 11 may | 20% | Reportes: 10 consultas multitabla + dashboard métricas |
| 5ª — 25 may | 20% | Imagen corporativa SIGCU + servidor gratuito + datos completos |

**Puntuación total esperada: 100%**

---

*Última actualización: Mayo 2026 — Entrega 5*
