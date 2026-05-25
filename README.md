# Sistema de Gestión de Información del Conocimiento Universitario

Sistema web full-stack para la gestión de información académica universitaria: programas, acreditaciones, docentes, alianzas, actividades académicas y más. Cuenta con autenticación JWT, control de acceso por roles y CRUD completo para todas las entidades.

---

## Tabla de Contenidos

1. [Tecnologías](#tecnologías)
2. [Requisitos Previos](#requisitos-previos)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Configuración de la Base de Datos](#configuración-de-la-base-de-datos)
5. [Ejecutar el Backend (API)](#ejecutar-el-backend-api)
6. [Ejecutar el Frontend (Blazor)](#ejecutar-el-frontend-blazor)
7. [🔐 Credenciales de Acceso](#-credenciales-de-acceso)
8. [Tutorial de Uso del Sistema](#tutorial-de-uso-del-sistema)
9. [API REST - Endpoints](#api-rest---endpoints)
10. [Pruebas con Swagger](#pruebas-con-swagger)
11. [Pruebas con Postman](#pruebas-con-postman)
12. [Control de Acceso por Roles](#control-de-acceso-por-roles)
13. [Tablas del Sistema](#tablas-del-sistema)

---

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| Backend | ASP.NET Core 9 Web API |
| Frontend | Blazor Server (.NET 9) |
| Base de Datos | SQL Server (remoto) |
| Autenticación | JWT Bearer Tokens |
| Hashing | BCrypt.Net-Next |
| Documentación API | Swagger / OpenAPI |
| Estilos | Bootstrap 5 + Bootstrap Icons |

---

## Requisitos Previos

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- Acceso a internet (la BD está en servidor remoto `db51269.databaseasp.net`)
- (Opcional) [Postman](https://www.postman.com/) para pruebas de API

---

## Estructura del Proyecto

```
📁 SISTEMA-DE-GESTION.../
├── 📁 Back/                    ← API REST (ASP.NET Core 9)
│   ├── Controllers/
│   │   ├── EntidadesController.cs   ← CRUD genérico para TODAS las tablas
│   │   └── LoginController.cs       ← Autenticación JWT
│   ├── Middlewares/
│   │   └── RoleAuthorizationMiddleware.cs ← Control de acceso por rol
│   ├── Servicios/
│   │   └── ServicioCrud.cs          ← Lógica de negocio
│   ├── Repositorios/
│   │   └── RepositorioCrud.cs       ← Acceso a datos (SQL Server)
│   └── appsettings.json             ← Configuración (JWT, ConnectionString)
│
├── 📁 Front/                   ← Blazor Server (Frontend)
│   ├── Components/
│   │   ├── Layout/
│   │   │   └── NavMenu.razor        ← Menú de navegación
│   │   └── Pages/                   ← Páginas CRUD de cada entidad
│   └── Services/
│       ├── ApiService.cs            ← Cliente HTTP con JWT
│       └── AuthSessionService.cs    ← Sesión en memoria
│
└── BD.sql                      ← Script completo de base de datos
```

---

## Configuración de la Base de Datos

La base de datos ya está configurada en servidor remoto. Si necesitas recrearla:

1. Conéctate al servidor SQL Server: `db51269.databaseasp.net`
2. Usuario: `db51269` | Contraseña: `p=8JRz_29Ae#`
3. Ejecuta el script `BD.sql` en orden (crea tablas + inserta datos semilla)

> **Nota:** El script crea automáticamente el usuario `admin` (contraseña: `admin123`) y el usuario `viewer` (contraseña: `viewer123`).

---

## Ejecutar el Backend (API)

```bash
# 1. Navegar al directorio del Backend
cd Back

# 2. Restaurar dependencias
dotnet restore

# 3. Ejecutar
dotnet run
```

La API quedará disponible en:
- **HTTP:** `http://localhost:5035`
- **HTTPS:** `https://localhost:7231`
- **Swagger UI:** `http://localhost:5035/swagger`

---

## Ejecutar el Frontend (Blazor)

Abrir una **nueva terminal** y ejecutar:

```bash
# 1. Navegar al directorio del Frontend
cd Front

# 2. Restaurar dependencias
dotnet restore

# 3. Ejecutar
dotnet run
```

El frontend quedará disponible en: **`http://localhost:5100`**

>  **El Backend debe estar ejecutándose antes de iniciar el Frontend.**

---

##  Credenciales de Acceso

### Administrador (CRUD completo)
| Campo | Valor |
|-------|-------|
| **Usuario** | `admin` |
| **Contraseña** | `admin123` |
| **Rol** | Administrador — puede crear, editar y eliminar registros |

### Visualizador (solo lectura)
| Campo | Valor |
|-------|-------|
| **Usuario** | `c` |
| **Contraseña** | `viewer123` |
| **Rol** | Usuario estándar — solo puede consultar registros |

---

## Tutorial de Uso del Sistema

### 1. Iniciar Sesión

1. Abre el navegador en `http://localhost:5100`
2. Haz clic en **"Iniciar sesión"** en el menú lateral
3. Ingresa las credenciales (ej: `admin` / `admin123`)
4. Haz clic en **"Ingresar"**
5. Serás redirigido al Dashboard con acceso a todas las tablas

### 2. Navegar por las Tablas

El menú lateral izquierdo muestra todas las tablas organizadas por entrega:

- **Entrega 1:** Universidades, Facultades, Programas, Docentes, Departamentos, Docente-Departamento, Aliados, Alianzas, Áreas de Conocimiento, Programa-Área
- **Entrega 2:** Acreditaciones, Registros Calificados, Diseños, Actividades Académicas, Pasantías, Premios, Aspectos Normativos, AN-Programa, Enfoques, Enfoque-RC, Prácticas y Estrategias, Programa-PE, Car. Innovación, Programa-CI, AA-RC
- **Administración** *(solo admin)*: Usuarios, Roles, Rol-Usuario

### 3. Crear un Registro (Solo Admin)

1. Selecciona una tabla del menú lateral (ej: **Programas**)
2. Haz clic en el botón **"Nuevo"** (azul, esquina superior derecha)
3. Completa los campos del formulario
4. Los campos con `*` rojo son **obligatorios**
5. Para campos que referencian otra tabla, ingresa el **ID numérico** (hay un enlace de ayuda)
6. Haz clic en **"Guardar"**
7. El sistema mostrará un mensaje verde de éxito

### 4. Editar un Registro (Solo Admin)

1. En la tabla, localiza el registro a editar
2. Haz clic en el botón amarillo ✏️ (lápiz) de la fila correspondiente
3. El formulario se pre-cargará con los datos actuales
4. Modifica los campos necesarios
5. Haz clic en **"Guardar"**

### 5. Eliminar un Registro (Solo Admin)

1. En la tabla, localiza el registro a eliminar
2. Haz clic en el botón rojo 🗑️ (papelera) de la fila
3. El registro se elimina **inmediatamente**

### 6. Cargar más Registros

Por defecto se muestran 20 registros. Para ver más:
1. Cambia el valor en el campo **"Límite"** (ej: 50, 100)
2. Haz clic en el botón **"Cargar"** ( ícono de recarga)

### 7. Cerrar Sesión

Haz clic en el botón **"Cerrar sesión"** al final del menú lateral.

---

## API REST - Endpoints

La API usa un controlador genérico: la misma ruta sirve para TODAS las tablas.

### Autenticación

```
POST /api/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**Respuesta exitosa:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "admin",
  "roles": ["admin"]
}
```

### CRUD Genérico

| Método | Ruta | Descripción | Requiere |
|--------|------|-------------|---------|
| `GET` | `/api/{tabla}` | Listar registros | JWT válido |
| `GET` | `/api/{tabla}?limite=50` | Listar con límite | JWT válido |
| `POST` | `/api/{tabla}` | Crear registro | JWT + rol admin |
| `PUT` | `/api/{tabla}/{campo}/{valor}` | Actualizar por campo | JWT + rol admin |
| `DELETE` | `/api/{tabla}/{campo}/{valor}` | Eliminar por campo | JWT + rol admin |

**Ejemplos:**
```
GET    /api/programa?limite=20
POST   /api/programa
PUT    /api/programa/id/5
DELETE /api/programa/id/5
GET    /api/docente
POST   /api/usuario          (solo admin)
```

---

## Pruebas con Swagger

1. Asegúrate de que el backend esté corriendo
2. Abre `http://localhost:5035/swagger` en el navegador
3. **Para autenticarte en Swagger:**
   - Primero ejecuta `POST /api/login` con las credenciales
   - Copia el valor del campo `token` de la respuesta
   - Haz clic en el botón **"Authorize"**  (esquina superior derecha)
   - Escribe: `Bearer {token_copiado}` y haz clic en **"Authorize"**
4. Ahora puedes probar todos los endpoints autenticado

### Ejemplo paso a paso en Swagger

**Paso 1: Login**
- Expande `POST /api/login`
- Clic en "Try it out"
- En el body escribe:
```json
{ "username": "admin", "password": "admin123" }
```
- Clic en "Execute"
- Copia el token de la respuesta

**Paso 2: Listar programas**
- Haz clic en "Authorize" → pega el Bearer token
- Expande `GET /api/{tabla}`
- Parámetro `tabla`: `programa`
- Clic en "Execute"

**Paso 3: Crear un programa**
- Expande `POST /api/{tabla}`
- Parámetro `tabla`: `programa`
- Body:
```json
{
  "nombre": "Ingeniería de Sistemas",
  "tipo": "Pregrado",
  "nivel": "Profesional",
  "ciudad": "Bogotá",
  "cant_graduados": 500,
  "facultad": 1
}
```

---

## Pruebas con Postman

### Configuración inicial

1. Crea una nueva **Collection** llamada "Universidad API"
2. En Variables de la colección, agrega:
   - `base_url` = `http://localhost:5035`
   - `token` = (vacío, se llenará al hacer login)

### Request 1: Login

```
POST {{base_url}}/api/login
Headers: Content-Type: application/json
Body (raw JSON):
{
  "username": "admin",
  "password": "admin123"
}
```

En la pestaña **Tests** del request de login, agrega este script para guardar el token automáticamente:
```javascript
var json = pm.response.json();
pm.collectionVariables.set("token", json.token);
```

### Request 2: Listar (GET)

```
GET {{base_url}}/api/programa?limite=20
Headers: Authorization: Bearer {{token}}
```

### Request 3: Crear (POST)

```
POST {{base_url}}/api/facultad
Headers:
  Authorization: Bearer {{token}}
  Content-Type: application/json
Body:
{
  "nombre": "Facultad de Ingeniería",
  "tipo": "Ingeniería",
  "fecha_fun": "1990-03-15",
  "universidad": 1
}
```

### Request 4: Actualizar (PUT)

```
PUT {{base_url}}/api/facultad/id/1
Headers:
  Authorization: Bearer {{token}}
  Content-Type: application/json
Body:
{
  "nombre": "Facultad de Ingeniería y Ciencias",
  "tipo": "Ingeniería"
}
```

### Request 5: Eliminar (DELETE)

```
DELETE {{base_url}}/api/programa/id/5
Headers: Authorization: Bearer {{token}}
```

---

## Control de Acceso por Roles

El sistema implementa autorización en dos niveles:

### Nivel de Middleware (Backend)
El `RoleAuthorizationMiddleware` aplica las siguientes reglas automáticamente:

| Operación | Rol Requerido |
|-----------|--------------|
| `GET` en cualquier tabla | JWT válido (cualquier rol) |
| `POST`, `PUT`, `DELETE` en cualquier tabla | Rol `admin` |
| Acceso a tablas `usuario`, `rol`, `rol_usuario` | Rol `admin` exclusivamente |

### Nivel de UI (Frontend)
- Los botones **Nuevo**, **Editar** (✏️) y **Eliminar** (🗑️) solo se muestran si el usuario tiene rol `admin`
- Los usuarios con rol `usuario` solo ven los datos en modo lectura
- Las páginas de Usuarios, Roles y Rol-Usuario no son accesibles para no-admins

---

## Tablas del Sistema

### Entrega 1 — Estructura Institucional

| Tabla | Ruta Frontend | Descripción |
|-------|--------------|-------------|
| `universidad` | `/dashboard/universidad` | Universidades registradas |
| `facultad` | `/dashboard/facultad` | Facultades por universidad |
| `programa` | `/dashboard/programa` | Programas académicos |
| `docente` | `/dashboard/docente` | Docentes |
| `departamento` | `/dashboard/departamento` | Departamentos académicos |
| `docente_departamento` | `/dashboard/docente-departamento` | Relación docente-departamento |
| `aliado` | `/dashboard/aliado` | Entidades aliadas |
| `alianza` | `/dashboard/alianza` | Alianzas inter-institucionales |
| `area_conocimiento` | `/dashboard/area-conocimiento` | Áreas de conocimiento |
| `programa_ac` | `/dashboard/programa-ac` | Relación programa-área conocimiento |

### Entrega 2 — Gestión Curricular

| Tabla | Ruta Frontend | Descripción |
|-------|--------------|-------------|
| `acreditacion` | `/dashboard/acreditacion` | Acreditaciones de programas |
| `registro_calificado` | `/dashboard/registro-calificado` | Registros calificados |
| `disenio` | `/dashboard/disenio` | Diseños curriculares |
| `activ_academicas` | `/dashboard/activ-academica` | Actividades académicas |
| `pasantia` | `/dashboard/pasantia` | Pasantías |
| `premio` | `/dashboard/premio` | Premios y reconocimientos |
| `aspecto_normativo` | `/dashboard/aspecto-normativo` | Aspectos normativos |
| `an_programa` | `/dashboard/an-programa` | Aspectos normativos por programa |
| `enfoque` | `/dashboard/enfoque` | Enfoques curriculares |
| `enfoque_rc` | `/dashboard/enfoque-rc` | Relación enfoque-registro calificado |
| `practica_estrategia` | `/dashboard/practica-estrategia` | Prácticas y estrategias pedagógicas |
| `programa_pe` | `/dashboard/programa-pe` | Relación programa-práctica estrategia |
| `car_innovacion` | `/dashboard/car-innovacion` | Características de innovación |
| `programa_ci` | `/dashboard/programa-ci` | Relación programa-car. innovación |
| `aa_rc` | `/dashboard/aa-rc` | Relación actividad académica-reg. calificado |

### Entrega 3 — Administración

| Tabla | Ruta Frontend | Descripción | Acceso |
|-------|--------------|-------------|--------|
| `usuario` | `/usuario` | Usuarios del sistema | Solo admin |
| `rol` | `/rol` | Roles disponibles | Solo admin |
| `rol_usuario` | `/rol-usuario` | Asignación de roles | Solo admin |

---

##  Seguridad

- Las contraseñas se almacenan hasheadas con **BCrypt** (factor de costo 12)
- Los tokens JWT expiran en **60 minutos**
- Las rutas sensibles están protegidas por middleware de autorización
- El frontend redirige a `/login` si el usuario no está autenticado

---

##  Notas Adicionales

- El campo `resolucion` en `acreditacion` es la **clave primaria** y no se puede editar después de creado
- El campo `codigo` en `registro_calificado` es la **clave primaria** textual
- Las tablas relacionales (`docente_departamento`, `programa_ac`, `programa_pe`, etc.) usan **claves primarias compuestas**
- Para tablas con FK, el formulario muestra un enlace a la tabla referenciada para consultar los IDs válidos
