USE db1;
GO

/* =========================
   1. TABLAS MAESTRAS
========================= */

-- Departamento
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'departamento')
CREATE TABLE departamento (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) UNIQUE NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'activo',
    fecha_creacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Docente (base para relación)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'docente')
CREATE TABLE docente (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    correo VARCHAR(100)
);
GO

-- Aliado
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'aliado')
CREATE TABLE aliado (
    nit INT PRIMARY KEY,
    razon_social VARCHAR(150) NOT NULL,
    nombre_contacto VARCHAR(150),
    correo VARCHAR(100),
    telefono VARCHAR(45),
    ciudad VARCHAR(45)
);
GO

/* =========================
   2. TABLAS DE PROGRAMAS
========================= */

-- Programa académico principal
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'programa')
CREATE TABLE programa (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) UNIQUE,
    codigo VARCHAR(50) UNIQUE,
    estado VARCHAR(20) DEFAULT 'activo'
);
GO

-- Programa AC
CREATE TABLE programa_ac (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    codigo VARCHAR(50)
);
GO

-- Programa PE
CREATE TABLE programa_pe (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    periodo VARCHAR(100)
);
GO

-- Programa CS
CREATE TABLE programa_cs (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    tipo VARCHAR(100)
);
GO

/* =========================
   3. TABLAS COMPLEMENTARIAS
========================= */

-- Análisis programa
CREATE TABLE an_programa (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    anio INT
);
GO

-- Asignaturas
CREATE TABLE aa_pe (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    codigo VARCHAR(50)
);
GO

-- Enfoque
CREATE TABLE enfoque_rc (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    descripcion TEXT,
    caracteristicas TEXT
);
GO

/* =========================
   4. RELACIONES
========================= */

-- Docente - Departamento (N:M)
CREATE TABLE docente_departamento (
    id_docente INT,
    id_depto INT,
    dedicacion VARCHAR(45),
    modalidad VARCHAR(45),
    fecha_ingreso DATE,
    fecha_salida DATE,
    PRIMARY KEY (id_docente, id_depto),
    FOREIGN KEY (id_docente) REFERENCES docente(id),
    FOREIGN KEY (id_depto) REFERENCES departamento(id)
);
GO

-- Alianza (relación con aliado)
CREATE TABLE alianza (
    id INT IDENTITY PRIMARY KEY,
    tipo VARCHAR(100),
    fecha_inicio DATE,
    fecha_fin DATE,
    nit_aliado INT,
    docente_lider INT,
    FOREIGN KEY (nit_aliado) REFERENCES aliado(nit),
    FOREIGN KEY (docente_lider) REFERENCES docente(id)
);
GO

-- Pasantía
CREATE TABLE pasantia (
    id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150),
    pais VARCHAR(45),
    empresa VARCHAR(150),
    descripcion TEXT,
    id_programa INT,
    FOREIGN KEY (id_programa) REFERENCES programa(id)
);
GO

/* =========================
   5. DATOS DE PRUEBA
========================= */

INSERT INTO departamento (nombre, descripcion) VALUES
('Informática', 'Computación'),
('Educación', 'Pedagogía');

INSERT INTO docente (nombre, correo) VALUES
('Juan Pérez', 'juan@mail.com'),
('Ana Gómez', 'ana@mail.com');

INSERT INTO aliado VALUES
(123, 'Empresa Tech', 'Carlos', 'carlos@mail.com', '300000', 'Medellín');

INSERT INTO programa (nombre, codigo) VALUES
('Ingeniería de Software', 'IS-01');

INSERT INTO alianza (tipo, fecha_inicio, nit_aliado, docente_lider) VALUES
('Empresarial', GETDATE(), 123, 1);
GO

/* =========================
   6. TABLAS INSTITUCIONALES
========================= */

-- Universidad
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'universidad')
CREATE TABLE universidad (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    ciudad VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE()
);
GO

-- Facultad
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'facultad')
CREATE TABLE facultad (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'activo',
    id_universidad INT NULL,
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (id_universidad) REFERENCES universidad(id)
);
GO

-- Programa completo (con FK a facultad)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'programa_academico')
CREATE TABLE programa_academico (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    codigo VARCHAR(50) UNIQUE,
    tipo VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    descripcion TEXT,
    num_creditos INT,
    num_semestres INT,
    id_facultad INT NULL,
    eliminado_en DATETIME2 NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (id_facultad) REFERENCES facultad(id)
);
GO

-- Datos de ejemplo institucionales
INSERT INTO universidad (nombre, ciudad) VALUES
('Universidad Nacional', 'Bogotá'),
('Universidad de Antioquia', 'Medellín'),
('Universidad del Valle', 'Cali');
GO

INSERT INTO facultad (nombre, descripcion, id_universidad) VALUES
('Facultad de Ingeniería', 'Ciencias e ingeniería aplicada', 1),
('Facultad de Ciencias Humanas', 'Humanidades y ciencias sociales', 1),
('Facultad de Ciencias Económicas', 'Economía y administración', 2);
GO

INSERT INTO programa_academico (nombre, codigo, tipo, descripcion, num_creditos, num_semestres, id_facultad) VALUES
('Ingeniería de Sistemas', 'IS-001', 'Pregrado', 'Formación en tecnologías y desarrollo de software', 165, 10, 1),
('Ingeniería Industrial', 'II-001', 'Pregrado', 'Optimización de procesos industriales', 170, 10, 1),
('Administración de Empresas', 'AE-001', 'Pregrado', 'Gestión y dirección empresarial', 155, 9, 3);
GO

/* =========================
   PROCEDIMIENTOS ALMACENADOS POR MÓDULO
========================= */

/* ────────────────────────────────────────
   MÓDULO 1: TABLAS MAESTRAS
──────────────────────────────────────── */

-- SP: Listar Departamentos
CREATE OR ALTER PROCEDURE sp_ListarDepartamentos
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, descripcion, estado, fecha_creacion FROM departamento ORDER BY fecha_creacion DESC
END;
GO

-- SP: Crear Departamento
CREATE OR ALTER PROCEDURE sp_CrearDepartamento
    @nombre VARCHAR(150),
    @descripcion TEXT,
    @estado VARCHAR(20) = 'activo'
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM departamento WHERE nombre = @nombre)
    BEGIN
        INSERT INTO departamento (nombre, descripcion, estado) VALUES (@nombre, @descripcion, @estado)
        SELECT 1 as exito, 'Departamento creado exitosamente' as mensaje
    END
    ELSE
        SELECT 0 as exito, 'El nombre ya existe' as mensaje
END;
GO

-- SP: Actualizar Departamento
CREATE OR ALTER PROCEDURE sp_ActualizarDepartamento
    @id INT,
    @nombre VARCHAR(150),
    @descripcion TEXT,
    @estado VARCHAR(20)
AS
BEGIN
    UPDATE departamento SET nombre = @nombre, descripcion = @descripcion, estado = @estado WHERE id = @id
    SELECT 1 as exito, 'Departamento actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Departamento
CREATE OR ALTER PROCEDURE sp_EliminarDepartamento
    @id INT
AS
BEGIN
    DELETE FROM departamento WHERE id = @id
    SELECT 1 as exito, 'Departamento eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Docentes
CREATE OR ALTER PROCEDURE sp_ListarDocentes
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, correo FROM docente ORDER BY nombre
END;
GO

-- SP: Crear Docente
CREATE OR ALTER PROCEDURE sp_CrearDocente
    @nombre VARCHAR(150),
    @correo VARCHAR(100)
AS
BEGIN
    INSERT INTO docente (nombre, correo) VALUES (@nombre, @correo)
    SELECT 1 as exito, 'Docente creado exitosamente' as mensaje
END;
GO

-- SP: Actualizar Docente
CREATE OR ALTER PROCEDURE sp_ActualizarDocente
    @id INT,
    @nombre VARCHAR(150),
    @correo VARCHAR(100)
AS
BEGIN
    UPDATE docente SET nombre = @nombre, correo = @correo WHERE id = @id
    SELECT 1 as exito, 'Docente actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Docente
CREATE OR ALTER PROCEDURE sp_EliminarDocente
    @id INT
AS
BEGIN
    DELETE FROM docente WHERE id = @id
    SELECT 1 as exito, 'Docente eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Aliados
CREATE OR ALTER PROCEDURE sp_ListarAliados
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) nit, razon_social, nombre_contacto, correo, telefono, ciudad FROM aliado ORDER BY razon_social
END;
GO

-- SP: Crear Aliado
CREATE OR ALTER PROCEDURE sp_CrearAliado
    @nit INT,
    @razon_social VARCHAR(150),
    @nombre_contacto VARCHAR(150),
    @correo VARCHAR(100),
    @telefono VARCHAR(45),
    @ciudad VARCHAR(45)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM aliado WHERE nit = @nit)
    BEGIN
        INSERT INTO aliado (nit, razon_social, nombre_contacto, correo, telefono, ciudad) 
        VALUES (@nit, @razon_social, @nombre_contacto, @correo, @telefono, @ciudad)
        SELECT 1 as exito, 'Aliado creado exitosamente' as mensaje
    END
    ELSE
        SELECT 0 as exito, 'El NIT ya existe' as mensaje
END;
GO

-- SP: Actualizar Aliado
CREATE OR ALTER PROCEDURE sp_ActualizarAliado
    @nit INT,
    @razon_social VARCHAR(150),
    @nombre_contacto VARCHAR(150),
    @correo VARCHAR(100),
    @telefono VARCHAR(45),
    @ciudad VARCHAR(45)
AS
BEGIN
    UPDATE aliado SET razon_social = @razon_social, nombre_contacto = @nombre_contacto, 
                      correo = @correo, telefono = @telefono, ciudad = @ciudad WHERE nit = @nit
    SELECT 1 as exito, 'Aliado actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Aliado
CREATE OR ALTER PROCEDURE sp_EliminarAliado
    @nit INT
AS
BEGIN
    DELETE FROM aliado WHERE nit = @nit
    SELECT 1 as exito, 'Aliado eliminado exitosamente' as mensaje
END;
GO

/* ────────────────────────────────────────
   MÓDULO 2: INNOVACIÓN CURRICULAR
──────────────────────────────────────── */

-- SP: Listar Alianzas con joins
CREATE OR ALTER PROCEDURE sp_ListarAlianzas
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) 
        a.id, a.tipo, a.fecha_inicio, a.fecha_fin, a.nit_aliado, a.docente_lider,
        al.razon_social, d.nombre as docente_nombre
    FROM alianza a
    LEFT JOIN aliado al ON a.nit_aliado = al.nit
    LEFT JOIN docente d ON a.docente_lider = d.id
    ORDER BY a.id DESC
END;
GO

-- SP: Crear Alianza
CREATE OR ALTER PROCEDURE sp_CrearAlianza
    @tipo VARCHAR(100),
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL,
    @nit_aliado INT,
    @docente_lider INT
AS
BEGIN
    INSERT INTO alianza (tipo, fecha_inicio, fecha_fin, nit_aliado, docente_lider) 
    VALUES (@tipo, @fecha_inicio, @fecha_fin, @nit_aliado, @docente_lider)
    SELECT 1 as exito, 'Alianza creada exitosamente' as mensaje
END;
GO

-- SP: Actualizar Alianza
CREATE OR ALTER PROCEDURE sp_ActualizarAlianza
    @id INT,
    @tipo VARCHAR(100),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @nit_aliado INT,
    @docente_lider INT
AS
BEGIN
    UPDATE alianza SET tipo = @tipo, fecha_inicio = @fecha_inicio, fecha_fin = @fecha_fin,
                       nit_aliado = @nit_aliado, docente_lider = @docente_lider WHERE id = @id
    SELECT 1 as exito, 'Alianza actualizada exitosamente' as mensaje
END;
GO

-- SP: Eliminar Alianza
CREATE OR ALTER PROCEDURE sp_EliminarAlianza
    @id INT
AS
BEGIN
    DELETE FROM alianza WHERE id = @id
    SELECT 1 as exito, 'Alianza eliminada exitosamente' as mensaje
END;
GO

-- SP: Listar Programas AC
CREATE OR ALTER PROCEDURE sp_ListarProgramaAC
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, codigo FROM programa_ac ORDER BY nombre
END;
GO

-- SP: Crear Programa AC
CREATE OR ALTER PROCEDURE sp_CrearProgramaAC
    @nombre VARCHAR(150),
    @codigo VARCHAR(50)
AS
BEGIN
    INSERT INTO programa_ac (nombre, codigo) VALUES (@nombre, @codigo)
    SELECT 1 as exito, 'Programa AC creado exitosamente' as mensaje
END;
GO

-- SP: Actualizar Programa AC
CREATE OR ALTER PROCEDURE sp_ActualizarProgramaAC
    @id INT,
    @nombre VARCHAR(150),
    @codigo VARCHAR(50)
AS
BEGIN
    UPDATE programa_ac SET nombre = @nombre, codigo = @codigo WHERE id = @id
    SELECT 1 as exito, 'Programa AC actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Programa AC
CREATE OR ALTER PROCEDURE sp_EliminarProgramaAC
    @id INT
AS
BEGIN
    DELETE FROM programa_ac WHERE id = @id
    SELECT 1 as exito, 'Programa AC eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Análisis Programas
CREATE OR ALTER PROCEDURE sp_ListarAnPrograma
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, anio FROM an_programa ORDER BY anio DESC
END;
GO

-- SP: Crear Análisis Programa
CREATE OR ALTER PROCEDURE sp_CrearAnPrograma
    @nombre VARCHAR(150),
    @anio INT
AS
BEGIN
    INSERT INTO an_programa (nombre, anio) VALUES (@nombre, @anio)
    SELECT 1 as exito, 'Análisis de programa creado exitosamente' as mensaje
END;
GO

-- SP: Actualizar Análisis Programa
CREATE OR ALTER PROCEDURE sp_ActualizarAnPrograma
    @id INT,
    @nombre VARCHAR(150),
    @anio INT
AS
BEGIN
    UPDATE an_programa SET nombre = @nombre, anio = @anio WHERE id = @id
    SELECT 1 as exito, 'Análisis de programa actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Análisis Programa
CREATE OR ALTER PROCEDURE sp_EliminarAnPrograma
    @id INT
AS
BEGIN
    DELETE FROM an_programa WHERE id = @id
    SELECT 1 as exito, 'Análisis de programa eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Programas PE
CREATE OR ALTER PROCEDURE sp_ListarProgramaPE
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, periodo FROM programa_pe ORDER BY nombre
END;
GO

-- SP: Crear Programa PE
CREATE OR ALTER PROCEDURE sp_CrearProgramaPE
    @nombre VARCHAR(150),
    @periodo VARCHAR(100)
AS
BEGIN
    INSERT INTO programa_pe (nombre, periodo) VALUES (@nombre, @periodo)
    SELECT 1 as exito, 'Programa PE creado exitosamente' as mensaje
END;
GO

-- SP: Actualizar Programa PE
CREATE OR ALTER PROCEDURE sp_ActualizarProgramaPE
    @id INT,
    @nombre VARCHAR(150),
    @periodo VARCHAR(100)
AS
BEGIN
    UPDATE programa_pe SET nombre = @nombre, periodo = @periodo WHERE id = @id
    SELECT 1 as exito, 'Programa PE actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Programa PE
CREATE OR ALTER PROCEDURE sp_EliminarProgramaPE
    @id INT
AS
BEGIN
    DELETE FROM programa_pe WHERE id = @id
    SELECT 1 as exito, 'Programa PE eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Asignaturas PE
CREATE OR ALTER PROCEDURE sp_ListarAaPE
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, codigo FROM aa_pe ORDER BY nombre
END;
GO

-- SP: Crear Asignatura PE
CREATE OR ALTER PROCEDURE sp_CrearAaPE
    @nombre VARCHAR(150),
    @codigo VARCHAR(50)
AS
BEGIN
    INSERT INTO aa_pe (nombre, codigo) VALUES (@nombre, @codigo)
    SELECT 1 as exito, 'Asignatura PE creada exitosamente' as mensaje
END;
GO

-- SP: Actualizar Asignatura PE
CREATE OR ALTER PROCEDURE sp_ActualizarAaPE
    @id INT,
    @nombre VARCHAR(150),
    @codigo VARCHAR(50)
AS
BEGIN
    UPDATE aa_pe SET nombre = @nombre, codigo = @codigo WHERE id = @id
    SELECT 1 as exito, 'Asignatura PE actualizada exitosamente' as mensaje
END;
GO

-- SP: Eliminar Asignatura PE
CREATE OR ALTER PROCEDURE sp_EliminarAaPE
    @id INT
AS
BEGIN
    DELETE FROM aa_pe WHERE id = @id
    SELECT 1 as exito, 'Asignatura PE eliminada exitosamente' as mensaje
END;
GO

-- SP: Listar Programas CS
CREATE OR ALTER PROCEDURE sp_ListarProgramaCS
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, tipo FROM programa_cs ORDER BY nombre
END;
GO

-- SP: Crear Programa CS
CREATE OR ALTER PROCEDURE sp_CrearProgramaCS
    @nombre VARCHAR(150),
    @tipo VARCHAR(100)
AS
BEGIN
    INSERT INTO programa_cs (nombre, tipo) VALUES (@nombre, @tipo)
    SELECT 1 as exito, 'Programa CS creado exitosamente' as mensaje
END;
GO

-- SP: Actualizar Programa CS
CREATE OR ALTER PROCEDURE sp_ActualizarProgramaCS
    @id INT,
    @nombre VARCHAR(150),
    @tipo VARCHAR(100)
AS
BEGIN
    UPDATE programa_cs SET nombre = @nombre, tipo = @tipo WHERE id = @id
    SELECT 1 as exito, 'Programa CS actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Programa CS
CREATE OR ALTER PROCEDURE sp_EliminarProgramaCS
    @id INT
AS
BEGIN
    DELETE FROM programa_cs WHERE id = @id
    SELECT 1 as exito, 'Programa CS eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Enfoques RC
CREATE OR ALTER PROCEDURE sp_ListarEnfoqueRC
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, descripcion, caracteristicas FROM enfoque_rc ORDER BY nombre
END;
GO

-- SP: Crear Enfoque RC
CREATE OR ALTER PROCEDURE sp_CrearEnfoqueRC
    @nombre VARCHAR(150),
    @descripcion TEXT,
    @caracteristicas TEXT
AS
BEGIN
    INSERT INTO enfoque_rc (nombre, descripcion, caracteristicas) VALUES (@nombre, @descripcion, @caracteristicas)
    SELECT 1 as exito, 'Enfoque RC creado exitosamente' as mensaje
END;
GO

-- SP: Actualizar Enfoque RC
CREATE OR ALTER PROCEDURE sp_ActualizarEnfoqueRC
    @id INT,
    @nombre VARCHAR(150),
    @descripcion TEXT,
    @caracteristicas TEXT
AS
BEGIN
    UPDATE enfoque_rc SET nombre = @nombre, descripcion = @descripcion, caracteristicas = @caracteristicas WHERE id = @id
    SELECT 1 as exito, 'Enfoque RC actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Enfoque RC
CREATE OR ALTER PROCEDURE sp_EliminarEnfoqueRC
    @id INT
AS
BEGIN
    DELETE FROM enfoque_rc WHERE id = @id
    SELECT 1 as exito, 'Enfoque RC eliminado exitosamente' as mensaje
END;
GO

-- SP: Listar Docente - Departamento
CREATE OR ALTER PROCEDURE sp_ListarDocenteDepartamento
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite)
        dd.id_docente, dd.id_depto, dd.dedicacion, dd.modalidad, dd.fecha_ingreso, dd.fecha_salida,
        d.nombre as docente_nombre, dep.nombre as departamento_nombre
    FROM docente_departamento dd
    LEFT JOIN docente d ON dd.id_docente = d.id
    LEFT JOIN departamento dep ON dd.id_depto = dep.id
    ORDER BY d.nombre
END;
GO

-- SP: Crear Docente - Departamento
CREATE OR ALTER PROCEDURE sp_CrearDocenteDepartamento
    @id_docente INT,
    @id_depto INT,
    @dedicacion VARCHAR(45),
    @modalidad VARCHAR(45),
    @fecha_ingreso DATE,
    @fecha_salida DATE = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM docente_departamento WHERE id_docente = @id_docente AND id_depto = @id_depto)
    BEGIN
        INSERT INTO docente_departamento (id_docente, id_depto, dedicacion, modalidad, fecha_ingreso, fecha_salida)
        VALUES (@id_docente, @id_depto, @dedicacion, @modalidad, @fecha_ingreso, @fecha_salida)
        SELECT 1 as exito, 'Relación docente-departamento creada exitosamente' as mensaje
    END
    ELSE
        SELECT 0 as exito, 'La relación ya existe' as mensaje
END;
GO

-- SP: Actualizar Docente - Departamento
CREATE OR ALTER PROCEDURE sp_ActualizarDocenteDepartamento
    @id_docente INT,
    @id_depto INT,
    @dedicacion VARCHAR(45),
    @modalidad VARCHAR(45),
    @fecha_ingreso DATE,
    @fecha_salida DATE
AS
BEGIN
    UPDATE docente_departamento 
    SET dedicacion = @dedicacion, modalidad = @modalidad, fecha_ingreso = @fecha_ingreso, fecha_salida = @fecha_salida
    WHERE id_docente = @id_docente AND id_depto = @id_depto
    SELECT 1 as exito, 'Relación docente-departamento actualizada exitosamente' as mensaje
END;
GO

-- SP: Eliminar Docente - Departamento
CREATE OR ALTER PROCEDURE sp_EliminarDocenteDepartamento
    @id_docente INT,
    @id_depto INT
AS
BEGIN
    DELETE FROM docente_departamento WHERE id_docente = @id_docente AND id_depto = @id_depto
    SELECT 1 as exito, 'Relación docente-departamento eliminada exitosamente' as mensaje
END;
GO

/* ────────────────────────────────────────
   MÓDULO 3: INSTITUCIONAL
──────────────────────────────────────── */

-- SP: Listar Universidades
CREATE OR ALTER PROCEDURE sp_ListarUniversidad
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite) id, nombre, ciudad, estado, fecha_creacion FROM universidad ORDER BY nombre
END;
GO

-- SP: Crear Universidad
CREATE OR ALTER PROCEDURE sp_CrearUniversidad
    @nombre VARCHAR(150),
    @ciudad VARCHAR(100),
    @estado VARCHAR(20) = 'activo'
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM universidad WHERE nombre = @nombre)
    BEGIN
        INSERT INTO universidad (nombre, ciudad, estado) VALUES (@nombre, @ciudad, @estado)
        SELECT 1 as exito, 'Universidad creada exitosamente' as mensaje
    END
    ELSE
        SELECT 0 as exito, 'El nombre ya existe' as mensaje
END;
GO

-- SP: Actualizar Universidad
CREATE OR ALTER PROCEDURE sp_ActualizarUniversidad
    @id INT,
    @nombre VARCHAR(150),
    @ciudad VARCHAR(100),
    @estado VARCHAR(20)
AS
BEGIN
    UPDATE universidad SET nombre = @nombre, ciudad = @ciudad, estado = @estado WHERE id = @id
    SELECT 1 as exito, 'Universidad actualizada exitosamente' as mensaje
END;
GO

-- SP: Eliminar Universidad
CREATE OR ALTER PROCEDURE sp_EliminarUniversidad
    @id INT
AS
BEGIN
    DELETE FROM universidad WHERE id = @id
    SELECT 1 as exito, 'Universidad eliminada exitosamente' as mensaje
END;
GO

-- SP: Listar Facultades con Universidad
CREATE OR ALTER PROCEDURE sp_ListarFacultad
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite)
        f.id, f.nombre, f.descripcion, f.estado, f.id_universidad, f.fecha_creacion,
        u.nombre as universidad_nombre
    FROM facultad f
    LEFT JOIN universidad u ON f.id_universidad = u.id
    ORDER BY f.nombre
END;
GO

-- SP: Crear Facultad
CREATE OR ALTER PROCEDURE sp_CrearFacultad
    @nombre VARCHAR(150),
    @descripcion TEXT,
    @estado VARCHAR(20) = 'activo',
    @id_universidad INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM facultad WHERE nombre = @nombre)
    BEGIN
        INSERT INTO facultad (nombre, descripcion, estado, id_universidad) 
        VALUES (@nombre, @descripcion, @estado, @id_universidad)
        SELECT 1 as exito, 'Facultad creada exitosamente' as mensaje
    END
    ELSE
        SELECT 0 as exito, 'El nombre ya existe' as mensaje
END;
GO

-- SP: Actualizar Facultad
CREATE OR ALTER PROCEDURE sp_ActualizarFacultad
    @id INT,
    @nombre VARCHAR(150),
    @descripcion TEXT,
    @estado VARCHAR(20),
    @id_universidad INT
AS
BEGIN
    UPDATE facultad SET nombre = @nombre, descripcion = @descripcion, estado = @estado, id_universidad = @id_universidad WHERE id = @id
    SELECT 1 as exito, 'Facultad actualizada exitosamente' as mensaje
END;
GO

-- SP: Eliminar Facultad
CREATE OR ALTER PROCEDURE sp_EliminarFacultad
    @id INT
AS
BEGIN
    DELETE FROM facultad WHERE id = @id
    SELECT 1 as exito, 'Facultad eliminada exitosamente' as mensaje
END;
GO

-- SP: Listar Programas Académicos con Facultad
CREATE OR ALTER PROCEDURE sp_ListarProgramaAcademico
    @limite INT = 20
AS
BEGIN
    SELECT TOP (@limite)
        pa.id, pa.nombre, pa.codigo, pa.tipo, pa.estado, pa.descripcion, pa.num_creditos, pa.num_semestres, pa.id_facultad, pa.fecha_creacion,
        f.nombre as facultad_nombre
    FROM programa_academico pa
    LEFT JOIN facultad f ON pa.id_facultad = f.id
    ORDER BY pa.nombre
END;
GO

-- SP: Crear Programa Académico
CREATE OR ALTER PROCEDURE sp_CrearProgramaAcademico
    @nombre VARCHAR(150),
    @codigo VARCHAR(50),
    @tipo VARCHAR(100),
    @estado VARCHAR(20) = 'activo',
    @descripcion TEXT,
    @num_creditos INT,
    @num_semestres INT,
    @id_facultad INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM programa_academico WHERE nombre = @nombre)
    BEGIN
        INSERT INTO programa_academico (nombre, codigo, tipo, estado, descripcion, num_creditos, num_semestres, id_facultad)
        VALUES (@nombre, @codigo, @tipo, @estado, @descripcion, @num_creditos, @num_semestres, @id_facultad)
        SELECT 1 as exito, 'Programa académico creado exitosamente' as mensaje
    END
    ELSE
        SELECT 0 as exito, 'El nombre ya existe' as mensaje
END;
GO

-- SP: Actualizar Programa Académico
CREATE OR ALTER PROCEDURE sp_ActualizarProgramaAcademico
    @id INT,
    @nombre VARCHAR(150),
    @codigo VARCHAR(50),
    @tipo VARCHAR(100),
    @estado VARCHAR(20),
    @descripcion TEXT,
    @num_creditos INT,
    @num_semestres INT,
    @id_facultad INT
AS
BEGIN
    UPDATE programa_academico 
    SET nombre = @nombre, codigo = @codigo, tipo = @tipo, estado = @estado, descripcion = @descripcion,
        num_creditos = @num_creditos, num_semestres = @num_semestres, id_facultad = @id_facultad
    WHERE id = @id
    SELECT 1 as exito, 'Programa académico actualizado exitosamente' as mensaje
END;
GO

-- SP: Eliminar Programa Académico
CREATE OR ALTER PROCEDURE sp_EliminarProgramaAcademico
    @id INT
AS
BEGIN
    DELETE FROM programa_academico WHERE id = @id
    SELECT 1 as exito, 'Programa académico eliminado exitosamente' as mensaje
END;
GO

PRINT 'Procedimientos almacenados creados exitosamente'
GO