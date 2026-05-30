<<<<<<< HEAD

USE db1;
GO

-- Tabla: docente_departamento
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'docente_departamento')
CREATE TABLE docente_departamento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: alianza
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'alianza')
CREATE TABLE alianza (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: programa_ac
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'programa_ac')
CREATE TABLE programa_ac (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    codigo VARCHAR(50) UNIQUE,
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: an_programa
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'an_programa')
CREATE TABLE an_programa (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    anio INT,
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: programa_pe
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'programa_pe')
CREATE TABLE programa_pe (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    periodo VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: aa_pe
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'aa_pe')
CREATE TABLE aa_pe (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    aa_codigo VARCHAR(50) UNIQUE,
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: programa_cs
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'programa_cs')
CREATE TABLE programa_cs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    cs_tipo VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabla: enfoque_rc
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'enfoque_rc')
CREATE TABLE enfoque_rc (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    caracteristicas TEXT,
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Insertar datos de ejemplo
INSERT INTO docente_departamento (nombre, descripcion) VALUES
('Departamento de Informática', 'Docentes especializados en computación'),
('Departamento de Educación', 'Docentes en pedagogía y didáctica'),
('Departamento de Administración', 'Docentes en gestión empresarial');

INSERT INTO alianza (nombre, descripcion, tipo) VALUES
('Alianza Tecnológica', 'Colaboración con empresas del sector TI', 'Empresarial'),
('Alianza Educativa', 'Red de instituciones educativas', 'Académica'),
('Alianza Internacional', 'Convenios con universidades extranjeras', 'Internacional');

INSERT INTO programa_ac (nombre, descripcion, codigo) VALUES
('Programa de Acreditación Básica', 'Proceso inicial de acreditación', 'AC-001'),
('Programa de Acreditación Avanzada', 'Acreditación de alto nivel', 'AC-002'),
('Programa de Acreditación Especializada', 'Acreditación por especialidad', 'AC-003');

INSERT INTO an_programa (nombre, descripcion, anio) VALUES
('Análisis 2024', 'Análisis curricular del año 2024', 2024),
('Análisis 2025', 'Análisis curricular del año 2025', 2025),
('Análisis 2026', 'Análisis curricular del año 2026', 2026);

INSERT INTO programa_pe (nombre, descripcion, periodo) VALUES
('Programa Piloto Semestral', 'Programa experimental de 6 meses', 'Semestral'),
('Programa Piloto Anual', 'Programa experimental de 12 meses', 'Anual'),
('Programa Piloto Trimestral', 'Programa experimental de 3 meses', 'Trimestral');

INSERT INTO aa_pe (nombre, descripcion, aa_codigo) VALUES
('Asignatura Básica', 'Asignatura fundamental del currículo', 'AA-001'),
('Asignatura Avanzada', 'Asignatura de especialización', 'AA-002'),
('Asignatura Electiva', 'Asignatura opcional', 'AA-003');

INSERT INTO programa_cs (nombre, descripcion, cs_tipo) VALUES
('Programa de Capacitación Docente', 'Formación continua para profesores', 'Capacitación'),
('Programa de Supervisión', 'Monitoreo y evaluación de programas', 'Supervisión'),
('Programa de Certificación', 'Certificación de competencias', 'Certificación');

INSERT INTO enfoque_rc (nombre, descripcion) VALUES
('Enfoque por Competencias', 'Desarrollo de habilidades específicas'),
('Enfoque por Proyectos', 'Aprendizaje basado en proyectos'),
('Enfoque por Investigación', 'Método científico aplicado');


GO
=======
USE db1;
GO

/*
  Modelo del modulo: Innovacion Curricular
  Incluye:
  - Tablas base sin FK
  - Tablas relacionales con FK
  - Tablas de usuarios (admin)
*/

-- Limpieza controlada (orden para evitar conflictos de FK)
DROP TABLE IF EXISTS rol_usuario, usuario, rol;
DROP TABLE IF EXISTS enfoque_rc, aa_rc, registro_calificado, programa_pe, programa_ci, programa_ac, premio, pasantia;
DROP TABLE IF EXISTS docente_departamento, an_programa, alianza, activ_academica, acreditacion, programa, facultad;
DROP TABLE IF EXISTS docente, departamento, aliado, disenio;
DROP TABLE IF EXISTS universidad, practica_estrategia, enfoque, car_innovacion, aspecto_normativo, area_conocimiento;
GO

-- =========================
-- ENTREGA 1: SIN FK
-- =========================
CREATE TABLE area_conocimiento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    gran_area VARCHAR(120) NOT NULL,
    area VARCHAR(120) NOT NULL,
    disciplina VARCHAR(120) NOT NULL
);

CREATE TABLE aspecto_normativo (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500) NULL,
    fuente VARCHAR(250) NULL
);

CREATE TABLE car_innovacion (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500) NULL,
    tipo VARCHAR(100) NULL
);

CREATE TABLE enfoque (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500) NULL
);

CREATE TABLE practica_estrategia (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500) NULL
);

CREATE TABLE universidad (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    tipo VARCHAR(80) NULL,
    ciudad VARCHAR(120) NULL
);

-- Tablas base adicionales requeridas por FK posteriores
CREATE TABLE aliado (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    tipo VARCHAR(100) NULL
);

CREATE TABLE departamento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

CREATE TABLE docente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    email VARCHAR(200) NULL
);

CREATE TABLE disenio (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500) NULL
);
GO

-- =========================
-- ENTREGA 2: CON FK
-- =========================
CREATE TABLE facultad (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    tipo VARCHAR(80) NULL,
    fecha_fun DATE NULL,
    universidad INT NOT NULL,
    CONSTRAINT FK_facultad_universidad FOREIGN KEY (universidad) REFERENCES universidad(id)
);

CREATE TABLE programa (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    tipo VARCHAR(80) NULL,
    nivel VARCHAR(80) NULL,
    fecha_creacion DATE NULL,
    fecha_cierre DATE NULL,
    cant_graduados INT NULL,
    ciudad VARCHAR(120) NULL,
    facultad INT NOT NULL,
    CONSTRAINT FK_programa_facultad FOREIGN KEY (facultad) REFERENCES facultad(id)
);

CREATE TABLE acreditacion (
    id INT IDENTITY(1,1) PRIMARY KEY,
    resolucion VARCHAR(80) NOT NULL UNIQUE,
    tipo VARCHAR(100) NULL,
    calificacion VARCHAR(80) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    programa INT NOT NULL,
    CONSTRAINT FK_acreditacion_programa FOREIGN KEY (programa) REFERENCES programa(id)
);

CREATE TABLE activ_academica (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    num_creditos INT NULL,
    tipo VARCHAR(80) NULL,
    area_formacion VARCHAR(120) NULL,
    h_acom INT NULL,
    h_indep INT NULL,
    idioma VARCHAR(60) NULL,
    espejo BIT DEFAULT 0,
    entidad_espejo VARCHAR(180) NULL,
    pais_espejo VARCHAR(120) NULL,
    disenio INT NOT NULL,
    CONSTRAINT FK_activ_academica_disenio FOREIGN KEY (disenio) REFERENCES disenio(id)
);

CREATE TABLE alianza (
    id INT IDENTITY(1,1) PRIMARY KEY,
    aliado INT NOT NULL,
    departamento INT NOT NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    docente INT NOT NULL,
    CONSTRAINT FK_alianza_aliado FOREIGN KEY (aliado) REFERENCES aliado(id),
    CONSTRAINT FK_alianza_departamento FOREIGN KEY (departamento) REFERENCES departamento(id),
    CONSTRAINT FK_alianza_docente FOREIGN KEY (docente) REFERENCES docente(id)
);

CREATE TABLE an_programa (
    id INT IDENTITY(1,1) PRIMARY KEY,
    aspecto_normativo INT NOT NULL,
    programa INT NOT NULL,
    CONSTRAINT FK_an_programa_aspecto FOREIGN KEY (aspecto_normativo) REFERENCES aspecto_normativo(id),
    CONSTRAINT FK_an_programa_programa FOREIGN KEY (programa) REFERENCES programa(id)
);

CREATE TABLE docente_departamento (
    docente INT NOT NULL,
    departamento INT NOT NULL,
    dedicacion VARCHAR(80) NULL,
    modalidad VARCHAR(80) NULL,
    fecha_ingreso DATE NULL,
    fecha_salida DATE NULL,
    CONSTRAINT PK_docente_departamento PRIMARY KEY (docente, departamento),
    CONSTRAINT FK_docente_departamento_docente FOREIGN KEY (docente) REFERENCES docente(id),
    CONSTRAINT FK_docente_departamento_departamento FOREIGN KEY (departamento) REFERENCES departamento(id)
);

CREATE TABLE pasantia (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    pais VARCHAR(120) NULL,
    empresa VARCHAR(180) NULL,
    descripcion VARCHAR(500) NULL,
    programa INT NOT NULL,
    CONSTRAINT FK_pasantia_programa FOREIGN KEY (programa) REFERENCES programa(id)
);

CREATE TABLE premio (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    descripcion VARCHAR(500) NULL,
    fecha DATE NULL,
    entidad_otorgante VARCHAR(180) NULL,
    pais VARCHAR(120) NULL,
    programa INT NOT NULL,
    CONSTRAINT FK_premio_programa FOREIGN KEY (programa) REFERENCES programa(id)
);

CREATE TABLE programa_ac (
    programa INT NOT NULL,
    area_conocimiento INT NOT NULL,
    CONSTRAINT PK_programa_ac PRIMARY KEY (programa, area_conocimiento),
    CONSTRAINT FK_programa_ac_programa FOREIGN KEY (programa) REFERENCES programa(id),
    CONSTRAINT FK_programa_ac_area FOREIGN KEY (area_conocimiento) REFERENCES area_conocimiento(id)
);

CREATE TABLE programa_ci (
    programa INT NOT NULL,
    car_innovacion INT NOT NULL,
    CONSTRAINT PK_programa_ci PRIMARY KEY (programa, car_innovacion),
    CONSTRAINT FK_programa_ci_programa FOREIGN KEY (programa) REFERENCES programa(id),
    CONSTRAINT FK_programa_ci_car FOREIGN KEY (car_innovacion) REFERENCES car_innovacion(id)
);

CREATE TABLE programa_pe (
    programa INT NOT NULL,
    practica_estrategia INT NOT NULL,
    CONSTRAINT PK_programa_pe PRIMARY KEY (programa, practica_estrategia),
    CONSTRAINT FK_programa_pe_programa FOREIGN KEY (programa) REFERENCES programa(id),
    CONSTRAINT FK_programa_pe_practica FOREIGN KEY (practica_estrategia) REFERENCES practica_estrategia(id)
);

CREATE TABLE registro_calificado (
    codigo VARCHAR(50) PRIMARY KEY,
    cant_creditos INT NULL,
    hora_acom INT NULL,
    hora_ind INT NULL,
    metodologia VARCHAR(150) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    duracion_anios INT NULL,
    duracion_semestres INT NULL,
    tipo_titulacion VARCHAR(100) NULL,
    programa INT NOT NULL,
    CONSTRAINT FK_registro_calificado_programa FOREIGN KEY (programa) REFERENCES programa(id)
);

CREATE TABLE aa_rc (
    activ_academicas_idcurso INT NOT NULL,
    registro_calificado_codigo VARCHAR(50) NOT NULL,
    componente VARCHAR(120) NULL,
    semestre INT NULL,
    CONSTRAINT PK_aa_rc PRIMARY KEY (activ_academicas_idcurso, registro_calificado_codigo),
    CONSTRAINT FK_aa_rc_activ FOREIGN KEY (activ_academicas_idcurso) REFERENCES activ_academica(id),
    CONSTRAINT FK_aa_rc_rc FOREIGN KEY (registro_calificado_codigo) REFERENCES registro_calificado(codigo)
);

CREATE TABLE enfoque_rc (
    enfoque INT NOT NULL,
    registro_calificado VARCHAR(50) NOT NULL,
    CONSTRAINT PK_enfoque_rc PRIMARY KEY (enfoque, registro_calificado),
    CONSTRAINT FK_enfoque_rc_enfoque FOREIGN KEY (enfoque) REFERENCES enfoque(id),
    CONSTRAINT FK_enfoque_rc_rc FOREIGN KEY (registro_calificado) REFERENCES registro_calificado(codigo)
);
GO

-- =========================
-- ENTREGA 3: USUARIOS (ADMIN)
-- =========================
CREATE TABLE rol (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    descripcion VARCHAR(250) NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE usuario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    nombre_completo VARCHAR(180) NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE rol_usuario (
    usuario_id INT NOT NULL,
    rol_id INT NOT NULL,
    CONSTRAINT PK_rol_usuario PRIMARY KEY (usuario_id, rol_id),
    CONSTRAINT FK_rol_usuario_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id),
    CONSTRAINT FK_rol_usuario_rol FOREIGN KEY (rol_id) REFERENCES rol(id)
);
GO

-- Seed minimo para acceso inicial admin
INSERT INTO rol (nombre, descripcion, activo)
VALUES ('admin', 'Administrador del sistema', 1),
       ('usuario', 'Usuario estandar', 1);

INSERT INTO usuario (username, password, email, nombre_completo, activo)
VALUES (
    'admin',
    '$2b$12$rYpZjc5ksrJS6nLf3cImhugk3X1.tX1.LkemxLhqgUyvzVz0cH5Ge', -- admin123
    'admin@universidad.edu',
    'Administrador General',
    1
);

INSERT INTO rol_usuario (usuario_id, rol_id)
SELECT u.id, r.id
FROM usuario u
JOIN rol r ON r.nombre = 'admin'
WHERE u.username = 'admin';
GO

-- ============================================================
-- SEED DE USUARIOS Y CREDENCIALES
-- ============================================================
-- Credenciales de acceso:
--   Administrador : username=admin   / password=admin123
--   Visualizador  : username=viewer  / password=viewer123
-- ============================================================

-- Asegurar que admin existe con password=admin123
-- Hash BCrypt de "admin123" (costo 12):
--   $2b$12$rYpZjc5ksrJS6nLf3cImhugk3X1.tX1.LkemxLhqgUyvzVz0cH5Ge
IF EXISTS (SELECT 1 FROM usuario WHERE username = 'admin')
BEGIN
    UPDATE usuario
    SET password = '$2b$12$rYpZjc5ksrJS6nLf3cImhugk3X1.tX1.LkemxLhqgUyvzVz0cH5Ge', -- admin123
        activo = 1,
        fecha_actualizacion = GETDATE()
    WHERE username = 'admin';
    PRINT 'Contraseña de admin establecida en admin123.';
END
ELSE
BEGIN
    INSERT INTO usuario (username, password, email, nombre_completo, activo, fecha_creacion)
    VALUES (
        'admin',
        '$2b$12$rYpZjc5ksrJS6nLf3cImhugk3X1.tX1.LkemxLhqgUyvzVz0cH5Ge', -- admin123
        'admin@universidad.edu',
        'Administrador General',
        1,
        GETDATE()
    );
    -- Asignar rol admin
    INSERT INTO rol_usuario (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuario u JOIN rol r ON r.nombre = 'admin' WHERE u.username = 'admin';
    PRINT 'Usuario admin creado con password admin123.';
END
GO

-- Crear usuario viewer (solo lectura) si no existe
-- Hash BCrypt de "viewer123" (costo 12):
--   $2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
IF NOT EXISTS (SELECT 1 FROM usuario WHERE username = 'viewer')
BEGIN
    INSERT INTO usuario (username, password, email, nombre_completo, activo, fecha_creacion)
    VALUES (
        'viewer',
        '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- viewer123
        'viewer@universidad.edu',
        'Usuario Visualizador',
        1,
        GETDATE()
    );
    -- Asignar rol usuario (solo lectura)
    INSERT INTO rol_usuario (usuario_id, rol_id)
    SELECT u.id, r.id FROM usuario u JOIN rol r ON r.nombre = 'usuario' WHERE u.username = 'viewer';
    PRINT 'Usuario viewer creado con password viewer123.';
END
GO
>>>>>>> SantiagoEcheverriDev
