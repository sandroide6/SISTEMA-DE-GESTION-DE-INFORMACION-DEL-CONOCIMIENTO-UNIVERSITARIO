
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
