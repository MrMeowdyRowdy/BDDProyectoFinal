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

USE master
DROP DATABASE IF EXISTS Interpretia
DROP CERTIFICATE Certificate_encryption
DROP MASTER KEY
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'InterpretiaBDD.'
GO
CREATE CERTIFICATE Certificate_encryption WITH SUBJECT = 'Proteccion de datos'
GO
CREATE DATABASE Interpretia
GO
USE Interpretia
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE Certificate_encryption;
GO
ALTER DATABASE Interpretia
SET ENCRYPTION ON
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

-----------------------------------------------------------------
--Creacion de perfil para envio de correos
-----------------------------------------------------------------
USE msdb;
GO

IF EXISTS (SELECT name FROM dbo.sysmail_profile WHERE name = 'AdminCorreo')
BEGIN
	EXECUTE dbo.sysmail_delete_profile_sp
    @profile_name = 'AdminCorreo';
END
GO

IF EXISTS (SELECT name FROM dbo.sysmail_account WHERE name = 'OperadorCorreo')
BEGIN
	EXECUTE dbo.sysmail_delete_account_sp
    @account_name = 'OperadorCorreo';
END
GO

EXECUTE dbo.sysmail_add_account_sp
    @account_name = 'OperadorCorreo',
    @email_address = 'notificacionesBDgrupo6@hotmail.com',
    @display_name = 'Perfil del operador de correo',
    @replyto_address = 'notificacionesBDgrupo6@hotmail.com',
    @mailserver_name = 'smtp.office365.com',
    @port = 587,
	@username = 'notificacionesBDgrupo6@hotmail.com', 
    @password = 'DPX_1234',
    @use_default_credentials = 0,
	@enable_ssl = 1 ;
GO
EXECUTE dbo.sysmail_add_profile_sp
    @profile_name = 'AdminCorreo',
    @description = 'Perfil de administracion para envio de correos';
GO
EXECUTE dbo.sysmail_add_profileaccount_sp
    @profile_name = 'AdminCorreo',
    @account_name = 'OperadorCorreo',
    @sequence_number = 1;
GO
EXECUTE dbo.sysmail_add_principalprofile_sp
    @principal_name = 'public',
    @profile_name = 'AdminCorreo',
    @is_default = 1;
GO

-----------------------------------------------------------------
--Desarrollo para BDD Interpretia
-----------------------------------------------------------------
Use Interpretia
GO
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
GRANT SELECT (CRID,nombre,apellido) ON Empleado TO QA1
GRANT INSERT ON OBJECT::[dbo].[SesionQA] TO QA1
GRANT UPDATE ON OBJECT::[dbo].[SesionQA] TO QA1

-----------------------------------------------------------------
--Creacion de Users - LTL
-----------------------------------------------------------------
CREATE USER [LeadTeamLeader] FOR LOGIN [LeadTeamLeader]
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
ALTER ROLE [Lector] ADD MEMBER [Interprete]
GO
--Permisos en la tabla Llamada y RCP
GRANT SELECT ON OBJECT::[dbo].[Llamada] TO [Interprete]
GRANT INSERT ON OBJECT::[dbo].[RCP] TO [Interprete]
GRANT INSERT ON OBJECT::[dbo].[Llamada] TO [Interprete]
GRANT UPDATE ON OBJECT::[dbo].[Llamada] TO [Interprete]


USE Interpretia
GO

---------------------------------------------------------------------------------------------------------------------------------
--Creacion objetos programables
---------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de usuarios
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarEmpleado_sp
GO

CREATE PROC InsertarEmpleado_sp

@nroIdentificacion IDENTIFICACION,
@sede VARCHAR(50),
@apellido NVARCHAR(30),
@nombre NVARCHAR(30),
@tlfContacto TELEFONO,
@emailPersonal MAIL,
@fullTime BIT

AS
BEGIN

DECLARE @CRID INT
SET @CRID = CONCAT(LEFT(@nroIdentificacion, 2),RIGHT(@nroIdentificacion, 4))
DECLARE @emailRackspace MAIL
SET @emailRackspace = CONCAT(@crid,'@megonetworks.pe')

INSERT INTO Empleado(CRID, nroIdentificacion, sede, apellido, nombre, tlfContacto, emailPersonal,emailRackspace,fullTime) 
VALUES (@crid, @nroIdentificacion, @sede, @apellido, @nombre, @tlfContacto, @emailPersonal,@emailRackspace,@fullTime)

END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de Horario
-----------------------------------------------------------------

DROP PROC IF EXISTS InsertarHorario_sp
GO

CREATE PROC InsertarHorario_sp

@horaInicio TIME(0),
@horaFin TIME(0),
@minutosBreak TINYINT

AS
BEGIN
INSERT INTO Horario(horaInicio, horaFin, minutosBreak) 
VALUES (@horaInicio, @horaFin, @minutosBreak)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de Interprete
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarInterprete_sp
GO

CREATE PROC InsertarInterprete_sp

@CRID INT,
@horario TINYINT,
@categoria CHAR(3),
@lenguajesCertificados VARCHAR(100),
@habilidadAlcanzada VARCHAR(20),
@NHO DATE

AS
BEGIN
INSERT INTO Interprete(CRID, horario, categoria,lenguajesCertificados,habilidadAlcanzada,NHO) 
VALUES (@CRID, @horario, @categoria,@lenguajesCertificados,@habilidadAlcanzada,@NHO)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de Operaciones
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarOperaciones_sp
GO

CREATE PROC InsertarOperaciones_sp

@CRID INT,
@horario TINYINT,
@categoria CHAR(3)

AS
BEGIN
INSERT INTO Operaciones(CRID, horario, categoria) 
VALUES (@CRID, @horario, @categoria)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de QA
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarQA_sp
GO

CREATE PROC InsertarQA_sp

@CRID INT,
@horario TINYINT,
@categoria CHAR(3)

AS
BEGIN
INSERT INTO QA(CRID, horario, categoria) 
VALUES (@CRID, @horario, @categoria)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de SesionQA
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarSesionQA_sp
GO

CREATE PROC InsertarSesionQA_sp

@QAID INT,
@CRID INT,
@fecha DATE,
@horaInicio TIME(0),
@horaFin TIME(0),
@porcentaje PERCENTAJE,
@feedback VARCHAR(1000)

AS
BEGIN

DECLARE @interpreteID INT
SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)

INSERT INTO SesionQA(QAID, interpreteID, fecha, horaInicio, horaFin, porcentaje, feedback) 
VALUES (@QAID, @interpreteID, @fecha, @horaInicio, @horaFin, @porcentaje, @feedback)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de Llamada
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarLlamada_sp
GO

CREATE PROC InsertarLlamada_sp

@CRID INT,
@fecha DATE,
@horaInicio TIME(0),
@horaFin TIME(0),
@empresaCliente VARCHAR(40),
@proveedor VARCHAR(40),
@lenguaLEP VARCHAR(30),
@tipo CHAR(5),
@especializacion CHAR(3)

AS
BEGIN

DECLARE @interpreteID INT
SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)

INSERT INTO Llamada(interpreteID, fecha, horaInicio, horaFin, empresaCliente, proveedor, lenguaLEP, tipo, especializacion) 
VALUES (@interpreteID, @fecha, @horaInicio, @horaFin, @empresaCliente, @proveedor, @lenguaLEP, @tipo, @especializacion)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de TipoRCP
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarTipoRCP_sp
GO

CREATE PROC InsertarTipoRCP_sp

@descripcion varchar(1000)

AS
BEGIN
INSERT INTO TipoRCP(descripcion) 
VALUES (@descripcion)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de RCP
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarRCP_sp
GO

CREATE PROC InsertarRCP_sp

@CRID INT,
@llamadaID INT,
@tipoID INT,
@subcategoria VARCHAR(60),
@mensaje VARCHAR(1000)

AS
BEGIN

DECLARE @interpreteID INT
SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)

INSERT INTO RCP(interpreteID, llamadaID, tipoID, subcategoria, mensaje) 
VALUES (@interpreteID, @llamadaID, @tipoID, @subcategoria, @mensaje)
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de ReporteOPS
-----------------------------------------------------------------
DROP PROC IF EXISTS InsertarReporteOPS_sp
GO

CREATE PROC InsertarReporteOPS_sp

@CRID INT,
@opsID INT,
@fechaHora DATETIME2(0),
@mensaje VARCHAR(1000)

AS
BEGIN

DECLARE @interpreteID INT
SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)

INSERT INTO ReporteOPS(interpreteID, opsID, fechaHora, mensaje) 
VALUES (@interpreteID, @opsID, @fechaHora, @mensaje)
END

GO

-----------------------------------------------------------------
--Creacion Trigger para ingreso de ReporteOPS
-----------------------------------------------------------------
DROP PROC IF EXISTS tr_InsertarRCP
GO

CREATE TRIGGER tr_InsertarRCP
ON RCP
FOR INSERT

AS
BEGIN

DECLARE  @IDLLAMADA INT
SET @IDLLAMADA = (SELECT llamadaID FROM inserted)
DECLARE  @FECHA DATE
SET @FECHA = CONVERT (date, GETDATE())
DECLARE  @FECHALLAMADA DATE
SET @FECHALLAMADA = (SELECT L.fecha FROM Llamada L WHERE L.llamadaID=@IDLLAMADA)
	IF (DATEDIFF(DAY,@FECHA,@FECHALLAMADA)>1)
		BEGIN
			RAISERROR('Error no puede agregar un reporte 24 horas después del incidente',16,10)
			ROLLBACK TRANSACTION;
		END
	ELSE
		BEGIN
			PRINT 'Reporte generado exitosamente'
		END
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para historial de llamadas por intérprete en un periodo dado
-----------------------------------------------------------------
DROP PROC IF EXISTS historialPorInterpretePorFechas_sp
GO

CREATE PROC historialPorInterpretePorFechas_sp

@fechaInicia DATE,
@fechaFinal DATE,
@CRID INT

AS
BEGIN

	DECLARE @interpreteID INT
	IF EXISTS (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)
	BEGIN
		SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)
	END
	ELSE
	BEGIN
		RAISERROR('Error CRID ingresado no existe',16,10)
		RETURN
	END
	IF(@fechaInicia>@fechaFinal)
	BEGIN
		RAISERROR('Error la fecha de inicio debe ser menor a la fecha final',16,10)
		RETURN
	END

	SELECT I.CRID AS 'Código empleado',
	E.nombre+' '+E.apellido AS 'Nombre del interprete',
	L.empresaCliente AS 'Empresa', L.tipo AS 'Tipo de llamada',
	L.horaInicio AS 'Hora inicial', L.horaFin AS 'Hora final', L.fecha AS 'Fecha de la llamada' 
	FROM Llamada L
	INNER JOIN Interprete I ON L.interpreteID=L.interpreteID
	INNER JOIN Empleado E ON I.CRID=E.CRID
	WHERE I.interpreteID=@interpreteID and  L.fecha between @fechaInicia AND @fechaFinal
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para horarios planificados por intérprete
-----------------------------------------------------------------
DROP PROC IF EXISTS horariosPorInterprete_sp
GO

CREATE PROC horariosPorInterprete_sp

@CRID INT

AS
BEGIN

	DECLARE @interpreteID INT
	IF EXISTS (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)
	BEGIN
		SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)
	END
	ELSE
	BEGIN
		RAISERROR('Error CRID ingresado no existe',16,10)
		RETURN
	END

	SELECT I.CRID AS 'Código empleado', I.horario AS 'Horario asignado',
	H.horaInicio AS 'Hora de inicio', H.horaFin AS 'Hora de finalización', H.minutosBreak AS 'Minutos de break',
	E.nombre+' '+E.apellido AS 'Nombre del interprete' FROM Interprete I
	INNER JOIN Horario H ON I.horario=H.horarioID
	INNER JOIN Empleado E ON I.CRID=E.CRID
	WHERE I.interpreteID=@interpreteID
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para calificaciones de los intérpretes
-----------------------------------------------------------------
DROP PROC IF EXISTS calificacionPorInterprete_sp
GO

CREATE PROC calificacionPorInterprete_sp

@CRID INT

AS
BEGIN

	DECLARE @interpreteID INT
	IF EXISTS (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)
	BEGIN
		SET @interpreteID = (SELECT I.interpreteID FROM Interprete I WHERE I.CRID=@CRID)
	END
	ELSE
	BEGIN
		RAISERROR('Error CRID ingresado no existe',16,10)
		RETURN
	END

	SELECT I.CRID AS 'Código empleado',
	S.porcentaje AS 'Porcentaje de calificación', S.feedback AS 'Feedback',
	E.nombre+' '+E.apellido AS 'Nombre del interprete' FROM Interprete I
	INNER JOIN SesionQA S ON I.interpreteID=S.interpreteID
	INNER JOIN Empleado E ON I.CRID=E.CRID
	WHERE I.interpreteID=@interpreteID
END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para registro de llamadas atendidass
-----------------------------------------------------------------
DROP PROC IF EXISTS registroLlamadasAtendidas_vw
GO

CREATE VIEW registroLlamadasAtendidas_vw

AS

	SELECT L.empresaCliente AS 'Empresa', L.tipo AS 'Tipo de llamada',
	L.horaInicio AS 'Hora inicial', L.horaFin AS 'Hora final', L.fecha AS 'Fecha de la llamada',
	E.nombre+' '+E.apellido AS 'Nombre del interprete que atendió la llamada'
	FROM Llamada L
	INNER JOIN Interprete I ON L.interpreteID = I.interpreteID
	INNER JOIN Empleado E ON I.CRID = E.CRID

GO

-----------------------------------------------------------------
--Creacion Procedimiento para registro de RPC
-----------------------------------------------------------------
DROP VIEW IF EXISTS registroRCP_vw
GO

CREATE VIEW registroRCP_vw

AS

	SELECT R.mensaje AS 'Mensaje del reporte', R.subcategoria AS 'Subcategoría del reporte',
	TR.descripcion AS 'Descripción del reporte',
	L.empresaCliente AS 'Empresa reportada', L.fecha AS 'Fecha de la llamada reportada', L.tipo AS 'Tipo de llamada reportada'
	FROM RCP R
	INNER JOIN TipoRCP TR ON R.tipoID = TR.tipoID
	INNER JOIN Interprete I ON R.interpreteID = I.interpreteID
	INNER JOIN Empleado E ON I.CRID = E.CRID
	INNER JOIN Llamada L ON  R.llamadaID = L.llamadaID

GO

-----------------------------------------------------------------
--Creacion Procedimiento para evaluación de interpretación QA
-----------------------------------------------------------------
DROP VIEW IF EXISTS evaluacionInterpretacionQA_vw
GO

CREATE VIEW evaluacionInterpretacionQA_vw

AS

	SELECT Q.QAID AS 'Id QA que realizo la evaluación', Q.categoria AS 'Categoría del QA',
	S.fecha AS 'Fecha de la evaluación', S.feedback AS 'Feedback de la evaluación', S.porcentaje AS 'Calificación en porcentaje',
	E.nombre+' '+E.apellido AS 'Nombre del interprete evaluado'
	FROM SesionQA S
	INNER JOIN QA Q ON S.QAID = Q.QAID
	INNER JOIN Interprete I ON I.interpreteID = S.interpreteID
	INNER JOIN Empleado E ON I.CRID = E.CRID

GO

-----------------------------------------------------------------
--Creacion Trigger para Generación de un RCP
-----------------------------------------------------------------
DROP PROC IF EXISTS tr_NotificacionRCP
GO

CREATE TRIGGER tr_NotificacionRCP
   ON  RCP 
   AFTER INSERT
AS 
BEGIN

    SET NOCOUNT ON;
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'AdminCorreo',
        @recipients = 'notificacionesBDgrupo6@hotmail.com',
        @subject = 'Generación de RCP',
        @body = 'Un nuevo RCP ha sido creado',
		@body_format = 'HTML'
END 

GO

-----------------------------------------------------------------
--Creacion Trigger para Nota menor a 70%
-----------------------------------------------------------------
DROP PROC IF EXISTS tr_notaMenor70
GO

CREATE TRIGGER tr_notaMenor70
   ON  SesionQA 
   AFTER INSERT
AS 
BEGIN
	DECLARE @NOTA TINYINT
	SET @NOTA = (SELECT porcentaje FROM inserted)
	DECLARE @INTERPRETE INT
	SET @INTERPRETE = (SELECT interpreteID FROM inserted)
	DECLARE @CRID INT
	SET @CRID = (SELECT CRID FROM Interprete I WHERE I.interpreteID=@INTERPRETE)
	DECLARE @body VARCHAR(1000)
	SET @body = CONCAT('Atención el interprete ',@CRID,' ha obtenido una calificación menor a 70')
	IF(@NOTA<70)
	BEGIN
		SET NOCOUNT ON;
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'AdminCorreo',
			@recipients = 'notificacionesBDgrupo6@hotmail.com',
			@subject = 'Baja nota de interprete',
			@body = @body,
			@body_format = 'HTML'
	END
    
END 

GO


-----------------------------------------------------------------
--Inserts Empleado
-----------------------------------------------------------------
EXEC InsertarEmpleado_sp '1721154498','Ecuador','Ocaña','Dennis','0996389675','dennisocana@gmail.com','0'
EXEC InsertarEmpleado_sp '1724540842','Ecuador','Chasipanta','Pablo','0982427705','Chasi64.z@gmail.com','0'
EXEC InsertarEmpleado_sp '1721645917','Brasil','Ramos','Xavier','0998716545','Xavier.Ramos@udla.edu.ec','1'
EXEC InsertarEmpleado_sp '1711896140','Ecuador','Chafla','Alexandra','0992599009','Chafla1980@hotmail.com','1'
EXEC InsertarEmpleado_sp '1708490097','Ecuador','Maila','Doménica','0982297973','MailaCasa19@gmail.com','1'
SELECT * FROM Empleado

-----------------------------------------------------------------
--Inserts Horario
-----------------------------------------------------------------
EXEC InsertarHorario_sp '10:00','14:00','15'
EXEC InsertarHorario_sp '07:00','15:00','30'
EXEC InsertarHorario_sp '08:00','12:00','15'
EXEC InsertarHorario_sp '16:00','23:00','15'
EXEC InsertarHorario_sp '12:00','16:00','15'
SELECT * FROM Horario

-----------------------------------------------------------------
--Inserts Interprete - borrar luego puede ser gold class, rookie o silver class
-----------------------------------------------------------------
EXEC InsertarInterprete_sp 174498,1,'VRI','Español - Ingles','Gold Class','12/07/2022'
EXEC InsertarInterprete_sp 175917,4,'VRI','Español - Ingles - Portugués','Gold Class','05/06/2020'
EXEC InsertarInterprete_sp 170842,2,'VRI','Español - Ingles','Gold Class','12/15/2020'
EXEC InsertarInterprete_sp 176140,3,'VRI','Español - Ingles','Gold Class','03/04/2018'
SELECT * FROM Interprete

-----------------------------------------------------------------
--Inserts Llamada - eliminar luego Proveedor pueden ser voice for help, pacific interpreters o LLS
-----------------------------------------------------------------
EXEC InsertarLlamada_sp 174498,'05/05/2022','10:01:09','10:30:49','St. Agnes Hospital', 'Voice for Help', 'Español', 'Video', 'MED'
EXEC InsertarLlamada_sp 170842,'02/04/2023','07:12:56','07:35:10','St. Tomas', 'Voice for Help', 'Español', 'Audio', 'MED'
EXEC InsertarLlamada_sp 174498,'02/04/2023','12:54:02','13:15:27','Parker Memorial', 'Voice for Help', 'Portgués', 'Audio', 'MED'
SELECT * FROM Llamada

-----------------------------------------------------------------
--Inserts Operaciones - eliminar luego categoria puede ser LTL o TL
-----------------------------------------------------------------
EXEC InsertarOperaciones_sp 174498,1,'LTL'
EXEC InsertarOperaciones_sp 176140,2,'TL'
EXEC InsertarOperaciones_sp 175917,4,'LTL'
SELECT * FROM Operaciones

-----------------------------------------------------------------
--Inserts QA - puede ser QA O trainer en categoria
-----------------------------------------------------------------
EXEC InsertarQA_sp 174498,1,'QA'
EXEC InsertarQA_sp 176140,2,'QA'
EXEC InsertarQA_sp 175917,4,'QA'
SELECT * FROM QA

-----------------------------------------------------------------
--Inserts TipoRCP - REVISAR DOCUMENTO PARA ESTO SOLO LOS MAYORES SE PONE
-----------------------------------------------------------------
EXEC InsertarTipoRCP_sp 'Problemas al inicio de la llamada'
EXEC InsertarTipoRCP_sp 'roblemas de audio/video'
EXEC InsertarTipoRCP_sp 'La conversación termino de manera inesperada'
EXEC InsertarTipoRCP_sp 'no se interpretó la llamada'
SELECT * FROM TipoRCP

-----------------------------------------------------------------
--Inserts RCP - SUBCAT DEBE SER CORRESPONDIENTE SEGUN EL DOC
-----------------------------------------------------------------
EXEC InsertarRCP_sp 174498,1,1,'Llamada de LEP.','LEP presiono el boton llamar del dispositivo sin querer'
EXEC InsertarRCP_sp 170842,2,2,'Llamada de LEP.',' Demasiada interferencia.'
EXEC InsertarRCP_sp 174498,1,3,'Llamada de LEP.','El cliente no volvió (se esperó según protocolo)'

SELECT * FROM RCP

-----------------------------------------------------------------
--Inserts ReporteOPS
-----------------------------------------------------------------
EXEC InsertarReporteOPS_sp 174498,1,'05/13/2023 10:30',''
EXEC InsertarReporteOPS_sp 170842,2,'02/04/2023 07:12:56',''
EXEC InsertarReporteOPS_sp 174498,1,'02/04/2023 12:54:02',''
SELECT * FROM ReporteOPS

-----------------------------------------------------------------
--Inserts SesionQA
-----------------------------------------------------------------
EXEC InsertarSesionQA_sp 1,174498,'05/10/2023','14:00:23','14:17:31',95,'Interprete se desenvuelve de buena manera, se recomienda pequeños ajustes en sus postura'
EXEC InsertarSesionQA_sp 2,170842,'02/04/2023','07:12:56','07:35:10',85,'Debido a fallos en la comunicación, el interpreto cometio algunos errores de lenguaje'
SELECT * FROM SesionQA

-----------------------------------------------------------------
--Creacion Procedimiento para mostrar el menú
-----------------------------------------------------------------
DROP PROC IF EXISTS MostrarMenu_sp
GO

CREATE PROC MostrarMenu_sp

AS
BEGIN

	PRINT('Menú de procedimientos INTERPRETIA')
	PRINT('Ámbitos a implementar:')
	PRINT('1. Planificación de llamadas')
	PRINT('2. Registro de llamadas atendidas')
	PRINT('3. Registro de RPC ')
	PRINT('4. Evaluación de interpretación QA')
	PRINT('Notificación:')
	PRINT('5. Generación de un RCP')
	PRINT('6. Nota menor a 70%')
	PRINT('Ámbitos a implementar:')
	PRINT('7. Historial de llamadas por intérprete en un periodo dado')
	PRINT('8. Horarios planificados por intérprete')
	PRINT('9. Calificaciones de los intérpretes')

END

GO

-----------------------------------------------------------------
--Creacion Procedimiento para ejecutar opciones del menú
-----------------------------------------------------------------
DROP PROC IF EXISTS MenuEjecutable_sp
GO

CREATE PROC MenuEjecutable_sp

@opcion TINYINT

AS
BEGIN
	
	IF @opcion = 1
	BEGIN
		PRINT('1. Planificación de llamadas')
		EXEC InsertarLlamada_sp 174498,'01/05/2022','10:01:09','11:30:49','St. Agnes Hospital', 'Voice for Help', 'Español', 'Video', 'MED'
	END
	IF @opcion = 2
	BEGIN
		PRINT('2. Registro de llamadas atendidas')	
		SELECT * FROM registroLlamadasAtendidas_vw
	END
	IF @opcion = 3
	BEGIN
		PRINT('3. Registro de RPC ')
		SELECT * FROM registroRCP_vw
	END
	IF @opcion = 4
	BEGIN
		PRINT('4. Evaluación de interpretación QA')
		SELECT * FROM evaluacionInterpretacionQA_vw	
	END
	IF @opcion = 5
	BEGIN
		PRINT('5. Generación de un RCP')
		EXEC InsertarRCP_sp 174498,1,1,'Llamada de LEP.','LEP presiono el boton llamar del dispositivo intensionadamente'
	END
	IF @opcion = 6
	BEGIN
		PRINT('6. Nota menor a 70%')
		EXEC InsertarSesionQA_sp 1,174498,'02/20/2023','14:00:23','14:17:31',60,'Interprete tiene errores menores al momento de la traducción'

	END
	IF @opcion = 7
	BEGIN
		PRINT('7. Historial de llamadas por intérprete en un periodo dado')
		EXEC historialPorInterpretePorFechas_sp '05/04/2022','05/20/2022',174498
	END
	IF @opcion = 8
	BEGIN
		PRINT('8. Horarios planificados por intérprete')
		EXEC horariosPorInterprete_sp 174498
	END
	IF @opcion = 9
	BEGIN
		PRINT('9. Calificaciones de los intérpretes')
		EXEC calificacionPorInterprete_sp 174498
	END

END

GO