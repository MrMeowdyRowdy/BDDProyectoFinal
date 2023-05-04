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

-----------------------------------------------------------------
--Creacion de regla para estructura dato mail
-----------------------------------------------------------------
CREATE RULE mail_ruleInterpretia
AS
@value LIKE '_%@_%._%';
GO
-----------------------------------------------------------------
--Creacion de regla para estructura dato Identificacion
-----------------------------------------------------------------
CREATE RULE cedula_ruleInterpretia
AS
@value LIKE '[0-1][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
OR @value LIKE '[2][0-4][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
OR @value LIKE '[3][0][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';
GO

-----------------------------------------------------------------
--Creacion Tabla Empleado
-----------------------------------------------------------------
CREATE TABLE Empleado(

)