-----------------------------------------------------------------
-- Script Base de Datos Interpretia - Proyecto Progreso 1
-- Autores:
--	 Chasipanta Pablo
--	 Ocaña Dennis
--	 Ramos Xavier
-- Version: 0.1
-- Fecha de creacion: 04/05/2023
-- Fecha de actualizacion: 04/05/2023
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
DROP RULE IF EXISTS mail_rule
DROP RULE IF EXISTS identificacion_rule
DROP RULE IF EXISTS telefono_rule
GO
DROP TABLE IF EXISTS Empleado

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
CREATE RULE identificacion_rule
AS
@value LIKE '[0-1][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
OR @value LIKE '[2][0-4][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
OR @value LIKE '[3][0][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';
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
CRID INT NOT NULL,
nroIdentificacion IDENTIFICACION NOT NULL,
sede VARCHAR(50) NOT NULL,
apellido NVARCHAR(30) NOT NULL,
nombre NVARCHAR(30) NOT NULL,
tlfContacto TELEFONO NOT NULL,
emailPersonal MAIL NOT NULL,
emailRackspace MAIL NOT NULL,
fullTime BIT NOT NULL

CONSTRAINT PK_Empleado PRIMARY KEY (CRID),
CONSTRAINT UK_EmpleadoCRID UNIQUE (CRID),
CONSTRAINT UK_EmpleadoCRID UNIQUE (tlfContacto),
CONSTRAINT UK_EmpleadoCRID UNIQUE (emailPersonal),
CONSTRAINT UK_EmpleadoCRID UNIQUE (emailRackspace)
)
-----------------------------------------------------------------
--Creacion Tabla Horario
-----------------------------------------------------------------
CREATE TABLE Horario(
horarioID INT IDENTITY(1,1) NOT NULL,
horaInicio TIME NOT NULL,
horaFin TIME NOT NULL,
minutosBreak TINYINT NOT NULL

CONSTRAINT PK_Horario PRIMARY KEY (horarioID)
)