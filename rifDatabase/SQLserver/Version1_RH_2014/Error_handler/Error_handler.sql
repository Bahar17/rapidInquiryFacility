 -- Create our error log table
 CREATE TABLE rif40_ErrorLog
 (
     [Error_Number] INT NOT NULL,
     [Error_LINE] INT NOT NULL,
     [Error_Location] sysname NOT NULL,
     [Error_Message] VARCHAR(MAX),
     [SPID] INT, 
     [Program_Name] VARCHAR(255),
     [Client_Address] VARCHAR(255),
     [Authentication] VARCHAR(50),
     [Error_User_Application] VARCHAR(100),
     [Error_Date] datetime NULL
      CONSTRAINT dfltErrorLog_error_date DEFAULT (GETDATE()),
     [Error_User_System] sysname NOT NULL
     CONSTRAINT dfltErrorLog_error_user_system DEFAULT (SUSER_SNAME())
 )
 GO

--------------------------------------------
 -- create the proc 
 --------------------------------------------
 CREATE PROCEDURE [ErrorLog_proc]
 (
     @Error_Number INT = NULL,
	 @Error_LINE INT = NULL,
     @Error_Location sysname = NULL,
     @Error_Message VARCHAR(4000) = NULL,
     @UserID INT = NULL
 ) 
AS
 BEGIN
     BEGIN TRY
     
        INSERT INTO rif40_ErrorLog
         (
             [Error_Number]
			 ,[Error_LINE]
             ,[Error_Location]
             ,[Error_Message]
             ,[SPID]
             ,[Program_Name]
             ,[Client_Address]
             ,[Authentication]
             ,[Error_User_System]
             ,[Error_User_Application]
         )
         SELECT 
            [Error_Number]              = ISNULL(@Error_Number,ERROR_NUMBER())  
			,[eRROR_LINE]				= ISNULL(@Error_LINE,ERROR_LINE())  
            ,[Error_Location]           = ISNULL(@Error_Location,ERROR_MESSAGE())
             ,[Error_Message]            = ISNULL(@Error_Message,ERROR_MESSAGE())
             ,[SPID]                     = @@SPID -- SESSION_id/connection_number
             ,[Program_Name]             = ses.program_name
             ,[Client_Address]           = con.client_net_address
             ,[Authentication]           = con.auth_scheme           
            ,[Error_User_System]         = SUSER_SNAME()
             ,[Error_User_Application]   = @UserID
 
        FROM sys.dm_exec_sessions ses
         LEFT JOIN sys.dm_exec_connections con
             ON con.session_id = ses.session_id
         WHERE ses.session_id = @@SPID
             
    END TRY
     BEGIN CATCH
         -- We even failed at the log entry so let's get basic
         INSERT INTO rif40_ErrorLog
         (
             ERROR_NUMBER
             ,ERROR_LOCATION
             ,ERROR_MESSAGE
         )
         VALUES 
        (
             -100
             ,OBJECT_NAME(@@PROCID)
             ,'Error Log Procedure Errored out'
         )
     END CATCH
 
END
 GO
