# 🚀 Módulo de Innovación Curricular — Primera Entrega

Sistema web desarrollado como **primera entrega (20%) del proyecto académico** del módulo **Innovación Curricular**.  
El sistema implementa un **sitio web corporativo con operaciones CRUD** para gestionar información institucional relacionada con innovación curricular.

La aplicación está desarrollada con **C# y ASP.NET Core 9.0**, utilizando **Blazor Server** para la interfaz de usuario y **SQL Server** como base de datos.

---

# 📌 Descripción General

Este proyecto demuestra la construcción de una **aplicación web completa con arquitectura cliente-servidor**, compuesta por:

- **API REST genérica** para operaciones CRUD
- **Frontend en Blazor** para interacción del usuario
- **Base de datos SQL Server**
- **Autenticación simulada con JWT**
- **Interfaz responsive con Bootstrap**

La arquitectura permite que **cualquier tabla nueva pueda ser gestionada automáticamente por el sistema**, gracias al uso de un **controlador CRUD genérico**.

---

# 🧱 Arquitectura del Proyecto

El proyecto está dividido en **dos aplicaciones principales**:

```
📦 Proyecto
 ┣ 📂 BackApiGenericaCsharp-main
 ┃ ┗ API REST en ASP.NET Core
 ┣ 📂 FrontBlazor_AppiGenericaCsharp-main
 ┃ ┗ Interfaz de usuario con Blazor Server
```

| Componente | Descripción |
|-------------|-------------|
| Backend API | Maneja lógica de negocio y acceso a base de datos |
| Frontend Blazor | Interfaz web para gestionar los datos |
| Base de datos | SQL Server con tablas del módulo |

---

# ⚙️ Tecnologías Utilizadas

| Tecnología | Uso |
|------------|-----|
| C# 13 | Lenguaje principal |
| ASP.NET Core 9 | Desarrollo del backend |
| Blazor Server | Interfaz web |
| Bootstrap 5 | Diseño responsive |
| SQL Server | Base de datos |
| ADO.NET | Acceso a datos |
| PowerShell | Automatización de scripts |

---

# 🧠 Arquitectura Backend

El backend sigue una estructura basada en **capas y principios SOLID**.

```
BackApiGenericaCsharp-main
│
├── Controllers
│   ├── EntidadesController.cs
│   ├── AutenticacionController.cs
│   └── ConsultasController.cs
│
├── Servicios
│   ├── ServicioCrud.cs
│   └── Abstracciones
│
├── Repositorios
│   ├── RepositorioLecturaSqlServer.cs
│   └── Abstracciones
│
├── appsettings.json
└── Program.cs
```

### Flujo de ejecución

```
Petición HTTP
      ↓
Controller
      ↓
Servicio
      ↓
Repositorio
      ↓
Base de Datos
```

---

# 🔗 API REST Genérica

El sistema utiliza un **controlador genérico** que recibe el nombre de la tabla en la URL.

Ejemplo:

```
/api/alianza
/api/docente_departamento
```

## Endpoints principales

| Método | Endpoint | Función |
|------|------|------|
| GET | /api/{tabla} | Listar registros |
| GET | /api/{tabla}/{id} | Obtener registro |
| POST | /api/{tabla} | Crear registro |
| PUT | /api/{tabla}/{clave}/{valor} | Actualizar |
| DELETE | /api/{tabla}/{clave}/{valor} | Eliminación lógica |


---

# 🖥️ Frontend con Blazor

La interfaz de usuario está desarrollada con **Blazor Server** y **Bootstrap 5**, permitiendo crear páginas dinámicas usando **C# sin JavaScript**.

### Estructura

```
FrontBlazor_AppiGenericaCsharp-main
│
├── Components
│   ├── Pages
│   │   ├── Home.razor
│   │   ├── Login.razor
│   │   ├── Alianza.razor
│   │   └── ...
│
├── Layout
│   ├── MainLayout.razor
│   └── NavMenu.razor
│
├── Services
│   └── ApiService.cs
│
└── Program.cs
```

---

# 📊 Base de Datos

El sistema trabaja con **8 tablas sin claves foráneas**, según los requisitos de la primera entrega.

| Tabla | Descripción |
|------|------|
| docente_departamento | Departamentos de docentes |
| alianza | Alianzas institucionales |
| programa_ac | Programas de acreditación |
| an_programa | Análisis de programas |
| programa_pe | Programas piloto |
| aa_pe | Asignaturas por programa |
| programa_cs | Programas de capacitación |
| enfoque_rc | Enfoques de investigación |

Cada tabla incluye:

```
id
nombre
descripcion
estado
eliminado_en
fecha_creacion
fecha_actualizacion
```

---

# 🚀 Ejecución del Proyecto

## Requisitos

- .NET 9 SDK
- SQL Server
- PowerShell
- Windows

---

## Ejecutar backend

```
cd BackApiGenericaCsharp-main
dotnet run
```

Servidor:

```
http://localhost:5035
```

Swagger:

```
http://localhost:5035/swagger
```

---

## Ejecutar frontend

```
cd FrontBlazor_AppiGenericaCsharp-main
dotnet run
```

Aplicación:

```
http://localhost:5100
```

---


# 🎯 Conclusión

Este proyecto demuestra la construcción de un **sistema web completo basado en arquitectura limpia**, utilizando tecnologías modernas del ecosistema .NET.

La implementación de un **API CRUD genérico** permite que el sistema sea **escalable, reutilizable y fácil de mantener**, mientras que el frontend en Blazor proporciona una experiencia de usuario moderna.

---

