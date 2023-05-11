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
SET @emailRackspace = CONCAT(@crid,'megonetworks.pe')

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

CREATE TRIGGER tr_InsertarReporteOPS
ON ReporteOPS
FOR INSERT

AS
BEGIN

DECLARE  @TIEMPO TIME(0)
SET @TIEMPO = CONVERT (TIME, GETDATE())
DECLARE  @TIEMPOLLAMADA TIME(0)
SET @TIEMPOLLAMADA

END

GO

CREATE TRIGGER TG_VerificarReservaIsla
ON Reserva
FOR INSERT
AS
	DECLARE  @DIAS INT
	SET @DIAS = (SELECT Dias FROM inserted)
	DECLARE  @NOCHES INT
	SET @NOCHES = (SELECT NOCHES FROM inserted)
	IF EXISTS (SELECT Id_Isla FROM inserted) AND (@DIAS=@NOCHES+1)
		BEGIN
		PRINT 'Reserva agregada exitosamente'
		END
	ELSE
		BEGIN
		RAISERROR('Error la agregar la reserva',16,10)
		ROLLBACK TRANSACTION;
		END
GO