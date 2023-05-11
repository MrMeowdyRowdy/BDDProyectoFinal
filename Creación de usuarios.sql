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