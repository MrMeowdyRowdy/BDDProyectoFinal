--  Interprete puede leer en la base de datos INTERPRETIA 

USE [master]
GO
CREATE LOGIN [Interprete] WITH PASSWORD=N'12345.MonteRojo' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
use [master];
GO
USE [Interpretia]
GO
CREATE USER [Interprete] FOR LOGIN [Interprete]
GO
USE [Interpretia]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Interprete]
GO
USE [Interpretia]
GO


-- LEAD Team Leader puede leer y escribir en la base de datos INTERPRETIA

USE [master]
GO
CREATE LOGIN [Lead Team Leader] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
use [master];
GO
USE [Interpretia]
GO
CREATE USER [Lead Team Leader] FOR LOGIN [Lead Team Leader]
GO
USE [Interpretia]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Lead Team Leader]
GO
USE [Interpretia]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Lead Team Leader]
GO
use [master]
GO
GRANT CONNECT SQL TO [Lead Team Leader]
GO
use [master]
GO
GRANT VIEW ANY DEFINITION TO [Lead Team Leader]
GO

-- Quality Assurance puede leer y escribir en la base de datos INTERPRETIA

USE [master]
GO
CREATE LOGIN [Quality Assurance] WITH PASSWORD=N'12345.Interpretia', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [Interpretia]
GO
CREATE USER [Quality Assurance] FOR LOGIN [Quality Assurance]
GO
USE [Interpretia]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Quality Assurance]
GO
USE [Interpretia]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Quality Assurance]
GO
use [master]
GO
GRANT CONNECT SQL TO [Quality Assurance]
GO


-- Envio de correos 

msdb.dbo.sp_send_dbmail @profile_name= 'Interpretiahotmail' ,@recipients = 'chasi64.z@gmail.com'
,@subject = 'Esto es una prueba',@body='Esto es una prueba Holaa',@body_format = 'HTML'
