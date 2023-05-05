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
DROP TYPE IF EXISTS percentaje
DROP RULE IF EXISTS mail_rule
DROP RULE IF EXISTS identificacion_rule
DROP RULE IF EXISTS telefono_rule
DROP RULE IF EXISTS percentaje_rule
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
nroIdentificacion IDENTIFICACION NOT NULL,
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
CONSTRAINT UK_EmpleadoCRID UNIQUE (tlfContacto),
CONSTRAINT UK_EmpleadoCRID UNIQUE (emailPersonal),
CONSTRAINT UK_EmpleadoCRID UNIQUE (emailRackspace)
)
-----------------------------------------------------------------
--Creacion Tabla Horario
-----------------------------------------------------------------
CREATE TABLE Horario(
--Se establece las columnas
horarioID INT IDENTITY(1,1) NOT NULL,
horaInicio TIME NOT NULL,
horaFin TIME NOT NULL,
minutosBreak TINYINT NOT NULL

--Se establece Constraints
CONSTRAINT PK_Horario PRIMARY KEY (horarioID)
)
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
CONSTRAINT FK_InterpreteHorario FOREIGN KEY (horario) REFERENCES Horario(horarioID)
)
-----------------------------------------------------------------
--Creacion Tabla Operaciones
-----------------------------------------------------------------
CREATE TABLE Operaciones(
--Se establece las columnas
opsID INT IDENTITY(1,1) NOT NULL,
CRID INT NOT NULL,
horario TINYINT NOT NULL,
categoria CHAR(3),

--Se establece Constraints
CONSTRAINT PK_Ops PRIMARY KEY (opsID),
CONSTRAINT FK_OpsEmpleado FOREIGN KEY (CRID) REFERENCES Empleado(CRID),
CONSTRAINT FK_OpsHorario FOREIGN KEY (horario) REFERENCES Horario(horarioID)
)
-----------------------------------------------------------------
--Creacion Tabla QA
-----------------------------------------------------------------
CREATE TABLE Operaciones(
--Se establece las columnas
QAID INT IDENTITY(1,1) NOT NULL,
CRID INT NOT NULL,
horario TINYINT NOT NULL,
categoria CHAR(3),

--Se establece Constraints
CONSTRAINT PK_QA PRIMARY KEY (QAID),
CONSTRAINT FK_QAEmpleado FOREIGN KEY (CRID) REFERENCES Empleado(CRID),
CONSTRAINT FK_QAHorario FOREIGN KEY (horario) REFERENCES Horario(horarioID)
)
-----------------------------------------------------------------
--Creacion Tabla SesionQA
-----------------------------------------------------------------
CREATE TABLE SesionQA(
--Se establece las columnas
sesionQAID INT IDENTITY(1,1) NOT NULL,
QAID INT NOT NULL,
interpreteID INT NOT NULL,
date DATE NOT NULL,
horaInicio TIME NOT NULL,
horaFin TIME NOT NULL,
porcentaje PERCENTAJE NOT NULL,
feedback VARCHAR(1000) NULL

--Se establece Constraints
CONSTRAINT PK_SesionQA PRIMARY KEY (sesionQAID),
CONSTRAINT FK_SesionQAQA FOREIGN KEY (QAID) REFERENCES QA(QAID),
CONSTRAINT FK_SesionQAQInterprete FOREIGN KEY (interpreteID) REFERENCES Interprete(interpreteID)
)
