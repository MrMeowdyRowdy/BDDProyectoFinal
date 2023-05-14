USE msdb;
GO

IF EXISTS (SELECT name FROM dbo.sysmail_profile WHERE name = 'AdminCorreo')
BEGIN
	EXECUTE dbo.sysmail_delete_profile_sp
    @profile_name = 'AdminCorreo';
END

IF EXISTS (SELECT name FROM dbo.sysmail_account WHERE name = 'OperadorCorreo')
BEGIN
	EXECUTE dbo.sysmail_delete_account_sp
    @account_name = 'OperadorCorreo';
END

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

EXECUTE dbo.sysmail_add_profile_sp
    @profile_name = 'AdminCorreo',
    @description = 'Perfil de administracion para envio de correos';

EXECUTE dbo.sysmail_add_profileaccount_sp
    @profile_name = 'AdminCorreo',
    @account_name = 'OperadorCorreo',
    @sequence_number = 1;

EXECUTE dbo.sysmail_add_principalprofile_sp
    @principal_name = 'public',
    @profile_name = 'AdminCorreo',
    @is_default = 1;
