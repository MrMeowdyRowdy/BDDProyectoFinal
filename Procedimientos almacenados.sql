USE Interpretia
GO

-----------------------------------------------------------------
--Creacion Procedimiento para ingreso de usuarios
-----------------------------------------------------------------

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
--Creacion Vista para registro de llamadas atendidass
-----------------------------------------------------------------

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
--Creacion Vista para registro de RPC
-----------------------------------------------------------------

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
--Creacion Vista para evaluación de interpretación QA
-----------------------------------------------------------------

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
	SET @CRID = (SELECT CRID FROM Interprete)
	IF(@NOTA<70)
	DECLARE @body VARCHAR(1000)
	SET @body = CONCAT('Atención el interprete ',@CRID,' ha obtenido una calificación menor a 70')
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
DROP PROC IF EXISTS InsertarReporteOPS_sp
GO

CREATE PROC MenuEjecutable_sp

@opcion TINYINT

AS
BEGIN
	
	IF @opcion = 1
	BEGIN
		PRINT('1. Planificación de llamadas')
		PRINT('Sintaxis: ')
	END
	IF @opcion = 2
	BEGIN
		PRINT('2. Registro de llamadas atendidas')	
	END
	IF @opcion = 3
	BEGIN
		PRINT('3. Registro de RPC ')
	END
	IF @opcion = 4
	BEGIN
		PRINT('4. Evaluación de interpretación QA')
	END
	IF @opcion = 5
	BEGIN
		PRINT('5. Generación de un RCP')
	END
	IF @opcion = 6
	BEGIN
		PRINT('6. Nota menor a 70%')
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

END

GO






