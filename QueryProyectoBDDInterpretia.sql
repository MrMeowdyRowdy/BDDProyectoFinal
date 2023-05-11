-----------------------------------------------------------------
-- Script Base de Datos Interpretia - Proyecto Progreso 1
-- Autores:
--	 Chasipanta Pablo
--	 Ocaña Dennis
--	 Ramos Xavier
-- Version: 1.5
-- Fecha de creacion: 04/05/2023
-- Fecha de actualizacion: 07/05/2023
-----------------------------------------------------------------
--Verificaciones
-----------------------------------------------------------------
USE MASTER
DROP DATABASE IF EXISTS Interpretia
CREATE DATABASE Interpretia
GO
USE Interpretia
GO
DROP TYPE IF EXISTS mail
DROP TYPE IF EXISTS identificacion
DROP TYPE IF EXISTS telefono
DROP TYPE IF EXISTS percentaje
DROP RULE IF EXISTS mail_rule
DROP RULE IF EXISTS identificacion_rule
DROP RULE IF EXISTS telefono_rule
DROP RULE IF EXISTS percentaje_rule
GO
DROP TABLE IF EXISTS Empleado
DROP TABLE IF EXISTS Interprete
DROP TABLE IF EXISTS Operaciones
DROP TABLE IF EXISTS QA
DROP TABLE IF EXISTS Horario
DROP TABLE IF EXISTS SesionQA
DROP TABLE IF EXISTS Llamada
DROP TABLE IF EXISTS TipoRCP
DROP TABLE IF EXISTS RCP
DROP TABLE IF EXISTS ReporteOPS
GO
DROP LOGIN [QualityAssurance]
DROP LOGIN [LeadTeamLeader]
DROP LOGIN [Interprete]

GO
DROP USER IF EXISTS [QA1]
DROP USER IF EXISTS [LeadTeamLeader]
DROP USER IF EXISTS [Interprete]
GO
DROP ROLE IF EXISTS [Lector]
GO
Use Interpretia
GO
DROP MASTER KEY
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'InterpretiaBDD.'
CREATE CERTIFICATE Certificate_encryption WITH SUBJECT = 'Proteccion de datos'
CREATE SYMMETRIC KEY SymKey_encryption WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE Certificate_encryption


-----------------------------------------------------------------
--Creacion de regla para estructura dato mail
-----------------------------------------------------------------
CREATE RULE mail_rule
AS
@value LIKE '_%@_%.__%';
GO
-----------------------------------------------------------------
--Creacion de regla para estructura dato Identificacion
-----------------------------------------------------------------
CREATE RULE identificacion_rule AS @value LIKE '[2][0-4][0-5][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    OR @value LIKE '[1][0-9][0-5][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    OR @value LIKE '[0][1-9][0-5][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    OR @value LIKE '[3][0][0-5][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    AND SUBSTRING(@value, 3, 1) BETWEEN '0'
    AND '5'
    AND CAST(SUBSTRING(@value, 10, 1) AS INT) = (
        (
            2 * CAST(SUBSTRING(@value, 1, 1) AS INT) + 1 * 
			CAST(SUBSTRING(@value, 2, 1) AS INT) + 2 * CAST(SUBSTRING(@value, 3, 1) AS INT) 
			+ 1 * CAST(SUBSTRING(@value, 4, 1) AS INT) + 2 * CAST(SUBSTRING(@value, 5, 1) AS INT) 
			+ 1 * CAST(SUBSTRING(@value, 6, 1) AS INT) + 2 * CAST(SUBSTRING(@value, 7, 1) AS INT) 
			+ 1 * CAST(SUBSTRING(@value, 8, 1) AS INT) + 2 * CAST(SUBSTRING(@value, 9, 1) AS INT)
        ) % 10
    )
GO
-----------------------------------------------------------------
--Creacion de regla para estructura dato Telefono
-----------------------------------------------------------------
CREATE RULE telefono_rule
AS
@value LIKE '[0][2-7][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
OR @value LIKE '[0][9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';
GO
-----------------------------------------------------------------
--Creacion de regla para estructura dato Percentaje
-----------------------------------------------------------------
CREATE RULE percentaje_rule
AS
@value <= 100
AND @value >=0
GO

-----------------------------------------------------------------
--Creacion del dato Cedula
-----------------------------------------------------------------
CREATE TYPE identificacion
FROM CHAR(10);
-----------------------------------------------------------------
--Creacion del dato mail
-----------------------------------------------------------------
CREATE TYPE mail
FROM VARCHAR(100);
-----------------------------------------------------------------
--Creacion del dato telefono
-----------------------------------------------------------------
CREATE TYPE telefono
FROM VARCHAR(10);
-----------------------------------------------------------------
--Creacion del dato Percentaje
-----------------------------------------------------------------
CREATE TYPE percentaje
FROM TINYINT;

-----------------------------------------------------------------
--Bindeo de la regla para estructura de mail al dato mail
-----------------------------------------------------------------
GO
sp_bindrule mail_rule,'mail';
GO
-----------------------------------------------------------------
--Bindeo de la regla para estructura de mail al dato mail
-----------------------------------------------------------------
GO
sp_bindrule identificacion_rule,'identificacion';
GO
-----------------------------------------------------------------
--Bindeo de la regla para estructura de mail al dato mail
-----------------------------------------------------------------
GO
sp_bindrule telefono_rule,'telefono';
GO

-----------------------------------------------------------------
--Creacion Tabla Empleado
-----------------------------------------------------------------
CREATE TABLE Empleado(
--Se establece las columnas
CRID INT NOT NULL,
nroIdentificacion IDENTIFICACION  NOT NULL,
sede VARCHAR(50) NOT NULL,
apellido NVARCHAR(30) NOT NULL,
nombre NVARCHAR(30) NOT NULL,
tlfContacto TELEFONO NOT NULL,
emailPersonal MAIL NOT NULL,
emailRackspace MAIL NOT NULL,
fullTime BIT NOT NULL

--Se establece Constraints
CONSTRAINT PK_Empleado PRIMARY KEY (CRID),
CONSTRAINT UK_EmpleadoCRID UNIQUE (CRID),
CONSTRAINT UK_Empleadotlf UNIQUE (tlfContacto),
CONSTRAINT UK_EmpleadoMPersonal UNIQUE (emailPersonal),
CONSTRAINT UK_EmpleadoMRackspace UNIQUE (emailRackspace)
)
GO
-----------------------------------------------------------------
--Creacion Tabla Horario
-----------------------------------------------------------------
CREATE TABLE Horario(
--Se establece las columnas
horarioID TINYINT IDENTITY(1,1) NOT NULL,
horaInicio TIME(0) NOT NULL,
horaFin TIME(0) NOT NULL,
minutosBreak TINYINT NOT NULL

--Se establece Constraints
CONSTRAINT PK_Horario PRIMARY KEY (horarioID),
CONSTRAINT CK_HoraRioHoraInicio CHECK (horaInicio < horaFin)
)
GO
-----------------------------------------------------------------
--Creacion Tabla Interprete
-----------------------------------------------------------------
CREATE TABLE Interprete(
--Se establece las columnas
interpreteID INT IDENTITY(1,1) NOT NULL,
CRID INT NOT NULL,
horario TINYINT NOT NULL,
categoria CHAR(3),
lenguajesCertificados VARCHAR(100),
habilidadAlcanzada VARCHAR(20),
NHO DATE

--Se establece Constraints
CONSTRAINT PK_Interprete PRIMARY KEY (interpreteID),
CONSTRAINT FK_InterpreteEmpleado FOREIGN KEY (CRID) REFERENCES Empleado(CRID),
CONSTRAINT FK_InterpreteHorario FOREIGN KEY (horario) REFERENCES Horario(horarioID),
CONSTRAINT CK_IntCat CHECK (categoria like 'CSI' OR categoria LIKE 'MSI' OR categoria LIKE 'VRI')
)
GO
-----------------------------------------------------------------
--Creacion Tabla Operaciones
-----------------------------------------------------------------
CREATE TABLE Operaciones(
--Se establece las columnas
opsID INT IDENTITY(1,1) NOT NULL,
CRID INT NOT NULL,
horario TINYINT NOT NULL,
categoria CHAR(3)

--Se establece Constraints
CONSTRAINT PK_Ops PRIMARY KEY (opsID),
CONSTRAINT FK_OpsEmpleado FOREIGN KEY (CRID) REFERENCES Empleado(CRID),
CONSTRAINT FK_OpsHorario FOREIGN KEY (horario) REFERENCES Horario(horarioID),
CONSTRAINT CK_OPSCat CHECK (categoria like 'LTL' OR categoria LIKE 'TL')
)
GO
-----------------------------------------------------------------
--Creacion Tabla QA
-----------------------------------------------------------------
CREATE TABLE QA(
--Se establece las columnas
QAID INT IDENTITY(1,1) NOT NULL,
CRID INT NOT NULL,
horario TINYINT NOT NULL,
categoria CHAR(3)

--Se establece Constraints
CONSTRAINT PK_QA PRIMARY KEY (QAID),
CONSTRAINT FK_QAEmpleado FOREIGN KEY (CRID) REFERENCES Empleado(CRID),
CONSTRAINT FK_QAHorario FOREIGN KEY (horario) REFERENCES Horario(horarioID),
CONSTRAINT CK_QACat CHECK (categoria like 'Trainer' OR categoria LIKE 'QA')
)
GO
-----------------------------------------------------------------
--Creacion Tabla SesionQA
-----------------------------------------------------------------
CREATE TABLE SesionQA(
--Se establece las columnas
sesionQAID INT IDENTITY(1,1) NOT NULL,
QAID INT NOT NULL,
interpreteID INT NOT NULL,
fecha DATE NOT NULL,
horaInicio TIME(0) NOT NULL,
horaFin TIME(0) NOT NULL,
porcentaje PERCENTAJE NOT NULL,
feedback VARCHAR(1000) NULL

--Se establece Constraints
CONSTRAINT PK_SesionQA PRIMARY KEY (sesionQAID),
CONSTRAINT FK_SesionQAQA FOREIGN KEY (QAID) REFERENCES QA(QAID),
CONSTRAINT FK_SesionQAQInterprete FOREIGN KEY (interpreteID) REFERENCES Interprete(interpreteID)
)
GO
-----------------------------------------------------------------
--Creacion Tabla Llamada
-----------------------------------------------------------------
CREATE TABLE Llamada(
--Se establece las columnas
llamadaID INT IDENTITY(1,1) NOT NULL,
interpreteID INT NOT NULL,
fecha DATE NOT NULL,
horaInicio TIME(0) NOT NULL,
horaFin TIME(0) NOT NULL,
empresaCliente VARCHAR(40) NOT NULL,
proveedor VARCHAR(40) NOT NULL,
lenguaLEP VARCHAR(30) NOT NULL,
tipo CHAR(5) NOT NULL,
especializacion CHAR(3) NOT NULL

--Se establece Constraints
CONSTRAINT PK_Llamada PRIMARY KEY (llamadaID),
CONSTRAINT FK_LlamadaInterprete FOREIGN KEY (interpreteID) REFERENCES Interprete(interpreteID),
CONSTRAINT CK_LlamadaFecha CHECK (fecha <= GETDATE()),
CONSTRAINT CK_LlamadahoraInicio CHECK (horaInicio <= CONVERT(TIME(0),GETDATE())),
CONSTRAINT CK_LlamadahoraFin CHECK (horaFin <= CONVERT(TIME(0),GETDATE())),
CONSTRAINT CK_LlamadahoraDIFF CHECK (horaInicio < horaFin),
CONSTRAINT CK_LlamadaEspecializacion CHECK (especializacion like 'CSV' OR especializacion LIKE 'MED' OR especializacion LIKE 'LAW')
)
GO
-----------------------------------------------------------------
--Creacion Tabla TipoRCP
-----------------------------------------------------------------
CREATE TABLE TipoRCP(
--Se establece las columnas
tipoID INT IDENTITY(1,1) NOT NULL,
descripcion varchar(1000)

--Se establece Constraints
CONSTRAINT PK_TipoRCP PRIMARY KEY (tipoID)
)
GO
-----------------------------------------------------------------
--Creacion Tabla RCP
-----------------------------------------------------------------
CREATE TABLE RCP(
--Se establece las columnas
RCPID INT IDENTITY(1,1) NOT NULL,
interpreteID INT NOT NULL,
llamadaID INT NOT NULL,
tipoID INT NOT NULL,
subcategoria VARCHAR(60) NOT NULL,
mensaje VARCHAR(1000) NULL

--Se establece Constraints
CONSTRAINT PK_RCP PRIMARY KEY (RCPID),
CONSTRAINT FK_RCPInterprete FOREIGN KEY (interpreteID) REFERENCES Interprete(interpreteID),
CONSTRAINT FK_RCPLlamadaID FOREIGN KEY (llamadaID) REFERENCES Llamada(llamadaID),
CONSTRAINT FK_RCPTipo FOREIGN KEY (tipoID) REFERENCES tipoRCP(tipoID)
)
GO
-----------------------------------------------------------------
--Creacion Tabla ReporteOPS
-----------------------------------------------------------------
CREATE TABLE ReporteOPS(
--Se establece las columnas
reporteOPSID INT IDENTITY(1,1) NOT NULL,
interpreteID INT NOT NULL,
opsID INT NOT NULL,
fechaHora DATETIME2(0) NOT NULL,
mensaje VARCHAR(1000) NOT NULL

--Se establece Constraints
CONSTRAINT PK_ReporteOPS PRIMARY KEY (reporteOPSID),
CONSTRAINT FK_ReporteOPSInterprete FOREIGN KEY (interpreteID) REFERENCES Interprete(interpreteID),
CONSTRAINT FK_ReporteOPSID FOREIGN KEY (opsID) REFERENCES operaciones(opsID),
CONSTRAINT CK_ReporteOPSFechaHora CHECK (fechaHora <= GETDATE())
)
GO
-----------------------------------------------------------------
--Creacion de Rol Lector
-----------------------------------------------------------------
CREATE ROLE [Lector]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [Lector]
GO

-----------------------------------------------------------------
--Creacion de logins
-----------------------------------------------------------------
USE [master]
GO
CREATE LOGIN [QualityAssurance] WITH PASSWORD=N'QA123.', DEFAULT_DATABASE=[Interpretia], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
CREATE LOGIN [LeadTeamLeader] WITH PASSWORD=N'LeadTL123.' MUST_CHANGE, DEFAULT_DATABASE=[Interpretia], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
CREATE LOGIN [Interprete] WITH PASSWORD=N'Interpretia123.' MUST_CHANGE, DEFAULT_DATABASE=[Interpretia], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

-----------------------------------------------------------------
--Creacion de Users - QA
-----------------------------------------------------------------
USE [Interpretia]
GO
CREATE USER [QA1] FOR LOGIN [QualityAssurance]
GO
ALTER ROLE [Lector] ADD MEMBER [QA1]
GO
GRANT INSERT ON OBJECT::[dbo].[SesionQA] TO QA1
GRANT UPDATE ON OBJECT::[dbo].[SesionQA] TO QA1

-----------------------------------------------------------------
--Creacion de Users - LTL
-----------------------------------------------------------------
CREATE USER [LeadTeamLeader] FOR LOGIN [LeadTeamLeader]
GO
USE [Interpretia]
GO
ALTER ROLE [Lector] ADD MEMBER [LeadTeamLeader]
GO
--Permisos en tabla empleado
GRANT INSERT ON OBJECT::[dbo].[Empleado] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[Empleado] TO [LeadTeamLeader]
--Permisos en la tabla horario
GRANT INSERT ON OBJECT::[dbo].[Horario] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[Horario] TO [LeadTeamLeader]
--Permisos en la tabla Interprete
GRANT INSERT ON OBJECT::[dbo].[Interprete] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[Interprete] TO [LeadTeamLeader]
--Permisos en la tabla Llamada
GRANT INSERT ON OBJECT::[dbo].[Llamada] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[Llamada] TO [LeadTeamLeader]
--Permisos en la tabla OPS
GRANT INSERT ON OBJECT::[dbo].[Operaciones] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[Operaciones] TO [LeadTeamLeader]
--Permisos en la tabla QA
GRANT INSERT ON OBJECT::[dbo].[QA] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[QA] TO [LeadTeamLeader]
--Permisos en la tabla ReporteOPS
GRANT INSERT ON OBJECT::[dbo].[ReporteOPS] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[ReporteOPS] TO [LeadTeamLeader]
--Permisos en la tabla TipoRCP
GRANT INSERT ON OBJECT::[dbo].[TipoRCP] TO [LeadTeamLeader]
GRANT UPDATE ON OBJECT::[dbo].[TipoRCP] TO [LeadTeamLeader]

-----------------------------------------------------------------
--Creacion de Users - Interprete
-----------------------------------------------------------------
CREATE USER [Interprete] FOR LOGIN [Interprete]
GO
USE [Interpretia]
GO
ALTER ROLE [Lector] ADD MEMBER [Interprete]
GO
--Permisos en la tabla Llamada
GRANT INSERT ON OBJECT::[dbo].[Llamada] TO [Interprete]
GRANT UPDATE ON OBJECT::[dbo].[Llamada] TO [Interprete]

