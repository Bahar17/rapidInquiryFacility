USE [master]
GO
/****** Object:  Database [RIF40]    Script Date: 23/10/2014 11:36:23 ******/
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'RIF40')
BEGIN
CREATE DATABASE [RIF40]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RIF40', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\RIF40.mdf' , SIZE = 640064KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'RIF40_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\RIF40_log.ldf' , SIZE = 1600KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
END

GO
ALTER DATABASE [RIF40] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RIF40].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RIF40] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RIF40] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RIF40] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RIF40] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RIF40] SET ARITHABORT OFF 
GO
ALTER DATABASE [RIF40] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RIF40] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [RIF40] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RIF40] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RIF40] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RIF40] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RIF40] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RIF40] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RIF40] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RIF40] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RIF40] SET  ENABLE_BROKER 
GO
ALTER DATABASE [RIF40] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RIF40] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RIF40] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RIF40] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RIF40] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RIF40] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RIF40] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RIF40] SET RECOVERY FULL 
GO
ALTER DATABASE [RIF40] SET  MULTI_USER 
GO
ALTER DATABASE [RIF40] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RIF40] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RIF40] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RIF40] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'RIF40', N'ON'
GO
USE [RIF40]
GO
/****** Object:  User [IC\mdouglas]    Script Date: 23/10/2014 11:36:23 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'IC\mdouglas')
CREATE USER [IC\mdouglas] FOR LOGIN [IC\mdouglas] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [rif40_manager]    Script Date: 23/10/2014 11:36:23 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'rif40_manager' AND type = 'R')
CREATE ROLE [rif40_manager]
GO
ALTER ROLE [db_owner] ADD MEMBER [IC\mdouglas]
GO
/****** Object:  Schema [o2ss]    Script Date: 23/10/2014 11:36:23 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'o2ss')
EXEC sys.sp_executesql N'CREATE SCHEMA [o2ss]'

GO
/****** Object:  Schema [test_schema]    Script Date: 23/10/2014 11:36:23 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'test_schema')
EXEC sys.sp_executesql N'CREATE SCHEMA [test_schema]'

GO
USE [RIF40]
GO
/****** Object:  Sequence [dbo].[RIF40_STUDY_ID_SEQ]    Script Date: 23/10/2014 11:36:23 ******/
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = N'RIF40_STUDY_ID_SEQ')
BEGIN
CREATE SEQUENCE [dbo].[RIF40_STUDY_ID_SEQ] 
 AS [numeric](28, 0)
 START WITH 2
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 1708
 NO CACHE 
END

GO
/****** Object:  StoredProcedure [dbo].[csv_importlvel1_proc]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csv_importlvel1_proc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' Create proc [dbo].[csv_importlvel1_proc]
 as
 BULK
 INSERT level1_import 
 FROM ''H:\GIS\rif_shapefiles\SAHSU_GRD_Level1_pipe.txt''
 WITH
 (
 FIRSTROW = 2,
 FIELDTERMINATOR = ''|'',
 ROWTERMINATOR = ''\n''
 )
' 
END
GO
/****** Object:  StoredProcedure [dbo].[csv_importlvel1_proc2]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csv_importlvel1_proc2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'  Create proc [dbo].[csv_importlvel1_proc2]
 as
 BULK
 INSERT level1_import 
 FROM ''H:\GIS\rif_shapefiles\SAHSU_GRD_Level1.csv''
 WITH
 (
 FIELDTERMINATOR = '','',
 ROWTERMINATOR = ''\n''
 )
' 
END
GO
/****** Object:  StoredProcedure [dbo].[csv_importlvel2_proc]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csv_importlvel2_proc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' Create proc [dbo].[csv_importlvel2_proc]
 as
 BULK
 INSERT level2_import 
 FROM ''H:\GIS\rif_shapefiles\SAHSU_GRD_Level2.csv''
 WITH
 (
 FIRSTROW = 2,
 FIELDTERMINATOR = '','',
 ROWTERMINATOR = ''\n''
 )
' 
END
GO
/****** Object:  StoredProcedure [dbo].[csv_importlvel2_proc_format]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csv_importlvel2_proc_format]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' Create proc [dbo].[csv_importlvel2_proc_format]
 as
 BULK
 INSERT level2_import_format 
 FROM ''H:\GIS\rif_shapefiles\SAHSU_GRD_Level2.csv''
 WITH
 (
 FIRSTROW = 2,
  FIELDTERMINATOR = '','',
 ROWTERMINATOR = ''\n''
 --FORMATFILE=''H:\GIS\rif_shapefiles\level_2.fmt''
 )
' 
END
GO
/****** Object:  StoredProcedure [dbo].[csv_importlvel3_proc]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csv_importlvel3_proc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' Create proc [dbo].[csv_importlvel3_proc]
 as
 BULK
 INSERT level3_import 
 FROM ''H:\GIS\rif_shapefiles\SAHSU_GRD_Level3_PIPE.txt''
 WITH
 (
 FIRSTROW = 2,
 FIELDTERMINATOR = ''|'',
 ROWTERMINATOR = ''\n''
 )
' 
END
GO
/****** Object:  StoredProcedure [dbo].[error_proc]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[error_proc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create  proc [dbo].[error_proc]
    @source varchar(100), 
    @msg varchar(max) ,
	@errorline int ,
	@errornumber int 
	
AS 
    
    SET NOCOUNT ON;
    insert into tbl_error_msg(error_source, msg, errorline, errornumber)
    values(@source, @msg,ERROR_LINE(),
            ERROR_number() );

' 
END
GO
/****** Object:  StoredProcedure [dbo].[ErrorLog_Ins_Error_Dtl]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ErrorLog_Ins_Error_Dtl]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ErrorLog_Ins_Error_Dtl]
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
         -- We even failed at the log entry so let''s get basic
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
             ,''Error Log Procedure Errored out''
         )
     END CATCH
 
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[ErrorLog_proc]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ErrorLog_proc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ErrorLog_proc]
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
         -- We even failed at the log entry so let''s get basic
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
             ,''Error Log Procedure Errored out''
         )
     END CATCH
 
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[ps_StudentList_Import]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ps_StudentList_Import]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[ps_StudentList_Import] 
@PathFileName varchar(100), 
@OrderID integer,
@FileType tinyint 
AS
--Step 1: Build Valid BULK INSERT Statement
DECLARE @SQL varchar(2000) IF @FileType = 1 
BEGIN
 -- Valid format: "John","Smith",john@smith.com
 SET @SQL = "BULK INSERT TmpStList FROM ''"+@PathFileName+"'' WITH (FIELDTERMINATOR = ''"",""'') " 
END 
 ELSE 
BEGIN 
-- Valid format: John,Smith,john@smith.com
 SET @SQL = "BULK INSERT TmpStList FROM ''"+@PathFileName+"'' WITH (FIELDTERMINATOR = '','') " 
END
--Step 2: Execute BULK INSERT statementEXEC (@SQL)
--Step 3: INSERT data into final table
INSERT StudentList (StFName,StLName,StEmail,OrderID) 
SELECT 
CASE WHEN @FileType = 1 THEN 
	SUBSTRING(StFName,2,DATALENGTH(StFName)-1) 
ELSE 
	StFName 
END, 
SUBSTRING(StLName,1,DATALENGTH(StLName)-0), 
CASE WHEN @FileType = 1 THEN 
	SUBSTRING(StEmail,1,DATALENGTH(StEmail)-1) 
ELSE
	StEmail 
END, 
@OrderID
 FROM tmpStList 
------------------------------
--Empty temporary table
------------------------------ 
TRUNCATE TABLE Tmp_pat_List 
' 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetErrorInfo]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetErrorInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- Create a procedure to retrieve error information.
CREATE PROCEDURE [dbo].[usp_GetErrorInfo]
AS
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() as ErrorState,
        ERROR_PROCEDURE() as ErrorProcedure,
        ERROR_LINE() as ErrorLine,
        ERROR_MESSAGE() as ErrorMessage;
' 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MyError]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_MyError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[usp_MyError]
AS
    -- This SELECT statement will generate
    -- an object name resolution error.
    SELECT * FROM NonExistentTable;
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[ObjectExists]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ObjectExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[ObjectExists](@Object VARCHAR(100), @Type VARCHAR(2)) RETURNS BIT
AS
BEGIN
  DECLARE @Exists BIT
  IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(@Object) AND type = (@Type))
    SET @Exists = 1
  ELSE
    SET @Exists = 0
  RETURN @Exists
END' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[RIF40_CONS_COLUMNS]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_CONS_COLUMNS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[RIF40_CONS_COLUMNS] 
( 
   /*
   *   SSMA informational messages:
   *   O2SS0271: Type converted according to type mapping: [VARCHAR2] -> [varchar(max)].
   */

   @constraint_name varchar(max)
)
/*
*   SSMA informational messages:
*   O2SS0271: Type converted according to type mapping: [VARCHAR2] -> [varchar(max)].
*/

RETURNS varchar(max)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 5.3.0.*/
   BEGIN

      DECLARE
         @active_spid INT, 
         @login_time DATETIME

      SET @active_spid = sysdb.ssma_oracle.GET_ACTIVE_SPID()

      SET @login_time = sysdb.ssma_oracle.GET_ACTIVE_LOGIN_TIME()

      DECLARE
         /*
         *   SSMA informational messages:
         *   O2SS0271: Type converted according to type mapping: [VARCHAR2] -> [varchar(max)].
         */

         @return_value_argument varchar(max)

      /*
      *   SSMA warning messages:
      *   O2SS0452: "xp_ora2ms_exec2_ex" when called from within UDF cannot bind to outer transaction. It can lead to dead locks and losing transaction atomicity. Consider calling $impl procedure directly.
      */

      EXECUTE master.dbo.xp_ora2ms_exec2_ex 
         @active_spid, 
         @login_time, 
         N''RIF40'', 
         N''DBO'', 
         N''RIF40_CONS_COLUMNS$IMPL'', 
         N''true'', 
         @constraint_name, 
         @return_value_argument  OUTPUT

      SELECT @return_value_argument = CAST(c_value AS varchar(max))
      FROM sysdb.ssma_oracle.db_LOB_output_session
      WHERE ordinal = 2

      RETURN @return_value_argument

   END' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[RIF40_KEY_CHECK]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_KEY_CHECK]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[RIF40_KEY_CHECK] 
( 
   /*
   *   SSMA informational messages:
   *   O2SS0271: Type converted according to type mapping: [INTEGER] -> [int].
   */

   @val1 int,
   /*
   *   SSMA informational messages:
   *   O2SS0271: Type converted according to type mapping: [INTEGER] -> [int].
   */

   @val2 int
)
/*
*   SSMA informational messages:
*   O2SS0271: Type converted according to type mapping: [INTEGER] -> [int].
*/

RETURNS int
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 5.3.0.*/
   BEGIN

      DECLARE
         @active_spid INT, 
         @login_time DATETIME

      SET @active_spid = sysdb.ssma_oracle.GET_ACTIVE_SPID()

      SET @login_time = sysdb.ssma_oracle.GET_ACTIVE_LOGIN_TIME()

      DECLARE
         /*
         *   SSMA informational messages:
         *   O2SS0271: Type converted according to type mapping: [INTEGER] -> [int].
         */

         @return_value_argument int

      /*
      *   SSMA warning messages:
      *   O2SS0452: "xp_ora2ms_exec2_ex" when called from within UDF cannot bind to outer transaction. It can lead to dead locks and losing transaction atomicity. Consider calling $impl procedure directly.
      */

      EXECUTE master.dbo.xp_ora2ms_exec2_ex 
         @active_spid, 
         @login_time, 
         N''RIF40'', 
         N''DBO'', 
         N''RIF40_KEY_CHECK$IMPL'', 
         N''true'', 
         @val1, 
         @val2, 
         @return_value_argument  OUTPUT

      RETURN @return_value_argument

   END' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[RIF40_SUPPRESSION_VALUE]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_SUPPRESSION_VALUE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[RIF40_SUPPRESSION_VALUE] 
( 
   /*
   *   SSMA informational messages:
   *   O2SS0271: Type converted according to type mapping: [VARCHAR2] -> [varchar(max)].
   */

   @param_value varchar(max) = 5,
   /*
   *   SSMA informational messages:
   *   O2SS0271: Type converted according to type mapping: [INTEGER] -> [int].
   */

   @debug int = 0
)
/*
*   SSMA informational messages:
*   O2SS0271: Type converted according to type mapping: [VARCHAR2] -> [varchar(max)].
*/

RETURNS varchar(max)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 5.3.0.*/
   BEGIN

      DECLARE
         @active_spid INT, 
         @login_time DATETIME

      SET @active_spid = sysdb.ssma_oracle.GET_ACTIVE_SPID()

      SET @login_time = sysdb.ssma_oracle.GET_ACTIVE_LOGIN_TIME()

      DECLARE
         /*
         *   SSMA informational messages:
         *   O2SS0271: Type converted according to type mapping: [VARCHAR2] -> [varchar(max)].
         */

         @return_value_argument varchar(max)

      /*
      *   SSMA warning messages:
      *   O2SS0452: "xp_ora2ms_exec2_ex" when called from within UDF cannot bind to outer transaction. It can lead to dead locks and losing transaction atomicity. Consider calling $impl procedure directly.
      */

      EXECUTE master.dbo.xp_ora2ms_exec2_ex 
         @active_spid, 
         @login_time, 
         N''RIF40'', 
         N''DBO'', 
         N''RIF40_SUPPRESSION_VALUE$IMPL'', 
         N''true'', 
         @param_value, 
         @debug, 
         @return_value_argument  OUTPUT

      SELECT @return_value_argument = CAST(c_value AS varchar(max))
      FROM sysdb.ssma_oracle.db_LOB_output_session
      WHERE ordinal = 3

      RETURN @return_value_argument

   END' 
END

GO
/****** Object:  Table [dbo].[ARP_POSTCODE_SUMMARY_R10_test]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARP_POSTCODE_SUMMARY_R10_test]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ARP_POSTCODE_SUMMARY_R10_test](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](25) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[G_RIF40_COMPARISON_AREAS]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[G_RIF40_COMPARISON_AREAS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[G_RIF40_COMPARISON_AREAS](
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [varchar](300) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[G_RIF40_STUDY_AREAS]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[G_RIF40_STUDY_AREAS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[G_RIF40_STUDY_AREAS](
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [varchar](300) NOT NULL,
	[BAND_ID] [numeric](2, 0) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[level1_import]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[level1_import]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[level1_import](
	[wkt] [varchar](max) NULL,
	[ID] [varchar](40) NULL,
	[level1] [varchar](40) NULL,
	[area] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Level2_import_REVIEW]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Level2_import_REVIEW]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Level2_import_REVIEW](
	[wkt] [varchar](max) NULL,
	[level2] [varchar](max) NULL,
	[area] [varchar](40) NULL,
	[level1] [varchar](max) NULL,
	[name] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Level3_import]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Level3_import]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Level3_import](
	[wkt] [varchar](max) NULL,
	[level2] [varchar](max) NULL,
	[level1] [varchar](max) NULL,
	[level3] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_A_AND_E]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_A_AND_E]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_A_AND_E](
	[A_AND_E_3CHAR] [varchar](4) NOT NULL,
	[TEXT_3CHAR] [varchar](200) NULL,
 CONSTRAINT [RIF40_A_AND_E_PK] PRIMARY KEY CLUSTERED 
(
	[A_AND_E_3CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_AGE_GROUP_NAMES]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUP_NAMES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_AGE_GROUP_NAMES](
	[AGE_GROUP_ID] [numeric](3, 0) NOT NULL,
	[AGE_GROUP_NAME] [varchar](50) NOT NULL,
 CONSTRAINT [RIF40_AGE_GROUP_NAMES_PK] PRIMARY KEY CLUSTERED 
(
	[AGE_GROUP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_AGE_GROUPS]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUPS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_AGE_GROUPS](
	[AGE_GROUP_ID] [numeric](3, 0) NOT NULL,
	[OFFSET] [numeric](3, 0) NOT NULL,
	[LOW_AGE] [numeric](3, 0) NOT NULL,
	[HIGH_AGE] [numeric](3, 0) NOT NULL,
	[FIELDNAME] [varchar](50) NOT NULL,
 CONSTRAINT [RIF40_AGE_GROUPS_PK] PRIMARY KEY CLUSTERED 
(
	[AGE_GROUP_ID] ASC,
	[OFFSET] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rif40_columns$]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rif40_columns$]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[rif40_columns$](
	[F1] [nvarchar](255) NULL,
	[F2] [nvarchar](255) NULL,
	[F3] [nvarchar](255) NULL,
	[F4] [nvarchar](255) NULL,
	[F5] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[RIF40_COVARIATES]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_COVARIATES](
	[GEOGRAPHY] [varchar](50) NOT NULL,
	[GEOLEVEL_NAME] [varchar](30) NOT NULL,
	[COVARIATE_NAME] [varchar](30) NOT NULL,
	[MIN] [numeric](9, 3) NOT NULL,
	[MAX] [numeric](9, 3) NOT NULL,
	[TYPE] [numeric](9, 3) NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [RIF40_COVARIATES_PK] PRIMARY KEY CLUSTERED 
(
	[GEOGRAPHY] ASC,
	[GEOLEVEL_NAME] ASC,
	[COVARIATE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_ERROR_MESSAGES]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ERROR_MESSAGES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_ERROR_MESSAGES](
	[ERROR_CODE] [numeric](5, 0) NOT NULL,
	[TAG] [varchar](80) NOT NULL,
	[TABLE_NAME] [varchar](30) NULL,
	[CAUSE] [varchar](4000) NOT NULL,
	[ACTION] [varchar](512) NOT NULL,
	[MESSAGE] [varchar](512) NOT NULL,
 CONSTRAINT [RIF40_ERROR_MESSAGES_PK] PRIMARY KEY CLUSTERED 
(
	[ERROR_CODE] ASC,
	[TAG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rif40_ErrorLog]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rif40_ErrorLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[rif40_ErrorLog](
	[Error_Number] [int] NOT NULL,
	[Error_LINE] [int] NOT NULL,
	[Error_Location] [sysname] NOT NULL,
	[Error_Message] [varchar](max) NULL,
	[SPID] [int] NULL,
	[Program_Name] [varchar](255) NULL,
	[Client_Address] [varchar](255) NULL,
	[Authentication] [varchar](50) NULL,
	[Error_User_Application] [varchar](100) NULL,
	[Error_Date] [datetime] NULL,
	[Error_User_System] [sysname] NOT NULL,
	[Id_new] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_GEOGRAPHIES]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_GEOGRAPHIES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_GEOGRAPHIES](
	[GEOGRAPHY] [varchar](50) NOT NULL,
	[DESCRIPTION] [varchar](250) NOT NULL,
	[HIERARCHYTABLE] [varchar](30) NOT NULL,
	[SRID] [numeric](6, 0) NOT NULL,
	[DEFAULTCOMPAREA] [varchar](30) NULL,
	[DEFAULTSTUDYAREA] [varchar](30) NULL,
	[POSTAL_POPULATION_TABLE] [varchar](30) NULL,
	[POSTAL_POINT_COLUMN] [varchar](30) NULL,
	[PARTITION] [numeric](1, 0) NOT NULL,
	[MAX_GEOJSON_DIGITS] [numeric](2, 0) NULL,
 CONSTRAINT [RIF40_GEOGRAPHIES_PK] PRIMARY KEY CLUSTERED 
(
	[GEOGRAPHY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_HEALTH_STUDY_THEMES]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_HEALTH_STUDY_THEMES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_HEALTH_STUDY_THEMES](
	[THEME] [varchar](30) NOT NULL,
	[DESCRIPTION] [varchar](200) NOT NULL,
 CONSTRAINT [RIF40_HEALTH_STUDY_THEMES_PK] PRIMARY KEY CLUSTERED 
(
	[THEME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_ICD_O_3]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD_O_3]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_ICD_O_3](
	[ICD_O_3_1CHAR] [varchar](20) NULL,
	[ICD_O_3_4CHAR] [varchar](4) NOT NULL,
	[TEXT_1CHAR] [varchar](250) NULL,
	[TEXT_4CHAR] [varchar](250) NULL,
 CONSTRAINT [RIF40_ICD_O_3_PK] PRIMARY KEY CLUSTERED 
(
	[ICD_O_3_4CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_ICD10]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD10]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_ICD10](
	[ICD10_1CHAR] [varchar](20) NULL,
	[ICD10_3CHAR] [varchar](3) NULL,
	[ICD10_4CHAR] [varchar](4) NOT NULL,
	[TEXT_1CHAR] [varchar](250) NULL,
	[TEXT_3CHAR] [varchar](250) NULL,
	[TEXT_4CHAR] [varchar](250) NULL,
 CONSTRAINT [RIF40_ICD10_PK] PRIMARY KEY CLUSTERED 
(
	[ICD10_4CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_ICD9]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD9]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_ICD9](
	[ICD9_3CHAR] [varchar](3) NULL,
	[ICD9_4CHAR] [varchar](4) NOT NULL,
	[TEXT_3CHAR] [varchar](250) NULL,
	[TEXT_4CHAR] [varchar](250) NULL,
 CONSTRAINT [RIF40_ICD9_PK] PRIMARY KEY CLUSTERED 
(
	[ICD9_4CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_OPCS4]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OPCS4]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_OPCS4](
	[OPCS4_1CHAR] [varchar](20) NULL,
	[OPCS4_3CHAR] [varchar](3) NULL,
	[OPCS4_4CHAR] [varchar](4) NULL,
	[TEXT_1CHAR] [varchar](250) NULL,
	[TEXT_3CHAR] [varchar](250) NULL,
	[TEXT_4CHAR] [varchar](250) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_OUTCOME_GROUPS]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_OUTCOME_GROUPS](
	[OUTCOME_TYPE] [varchar](20) NOT NULL,
	[OUTCOME_GROUP_NAME] [varchar](30) NOT NULL,
	[OUTCOME_GROUP_DESCRIPTION] [varchar](250) NOT NULL,
	[FIELD_NAME] [varchar](30) NOT NULL,
	[MULTIPLE_FIELD_COUNT] [numeric](2, 0) NOT NULL,
 CONSTRAINT [RIF40_OUTCOME_GROUPS_PK] PRIMARY KEY CLUSTERED 
(
	[OUTCOME_GROUP_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_OUTCOMES]    Script Date: 23/10/2014 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_OUTCOMES](
	[OUTCOME_TYPE] [varchar](20) NOT NULL,
	[OUTCOME_DESCRIPTION] [varchar](250) NOT NULL,
	[CURRENT_VERSION] [varchar](20) NOT NULL,
	[CURRENT_SUB_VERSION] [varchar](20) NULL,
	[PREVIOUS_VERSION] [varchar](20) NULL,
	[PREVIOUS_SUB_VERSION] [varchar](20) NULL,
	[CURRENT_LOOKUP_TABLE] [varchar](30) NULL,
	[PREVIOUS_LOOKUP_TABLE] [varchar](30) NULL,
	[CURRENT_VALUE_1CHAR] [varchar](30) NULL,
	[CURRENT_VALUE_2CHAR] [varchar](30) NULL,
	[CURRENT_VALUE_3CHAR] [varchar](30) NULL,
	[CURRENT_VALUE_4CHAR] [varchar](30) NULL,
	[CURRENT_VALUE_5CHAR] [varchar](30) NULL,
	[CURRENT_DESCRIPTION_1CHAR] [varchar](250) NULL,
	[CURRENT_DESCRIPTION_2CHAR] [varchar](250) NULL,
	[CURRENT_DESCRIPTION_3CHAR] [varchar](250) NULL,
	[CURRENT_DESCRIPTION_4CHAR] [varchar](250) NULL,
	[CURRENT_DESCRIPTION_5CHAR] [varchar](250) NULL,
	[PREVIOUS_VALUE_1CHAR] [varchar](30) NULL,
	[PREVIOUS_VALUE_2CHAR] [varchar](30) NULL,
	[PREVIOUS_VALUE_3CHAR] [varchar](30) NULL,
	[PREVIOUS_VALUE_4CHAR] [varchar](30) NULL,
	[PREVIOUS_VALUE_5CHAR] [varchar](30) NULL,
	[PREVIOUS_DESCRIPTION_1CHAR] [varchar](250) NULL,
	[PREVIOUS_DESCRIPTION_2CHAR] [varchar](250) NULL,
	[PREVIOUS_DESCRIPTION_3CHAR] [varchar](250) NULL,
	[PREVIOUS_DESCRIPTION_4CHAR] [varchar](250) NULL,
	[PREVIOUS_DESCRIPTION_5CHAR] [varchar](250) NULL,
 CONSTRAINT [RIF40_OUTCOMES_PK] PRIMARY KEY CLUSTERED 
(
	[OUTCOME_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_POPULATION_EUROPE]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_POPULATION_EUROPE]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_POPULATION_EUROPE](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[TOTAL] [numeric](10, 2) NOT NULL,
 CONSTRAINT [RIF40_POPULATION_EUROPE_PK] PRIMARY KEY CLUSTERED 
(
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[RIF40_POPULATION_US]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_POPULATION_US]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_POPULATION_US](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[TOTAL] [numeric](10, 2) NOT NULL,
 CONSTRAINT [RIF40_POPULATION_US_PK] PRIMARY KEY CLUSTERED 
(
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[RIF40_POPULATION_WORLD]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_POPULATION_WORLD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_POPULATION_WORLD](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[TOTAL] [numeric](11, 2) NOT NULL,
 CONSTRAINT [RIF40_POPULATION_WORLD_PK] PRIMARY KEY CLUSTERED 
(
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[RIF40_PREDEFINED_GROUPS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_GROUPS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_PREDEFINED_GROUPS](
	[PREDEFINED_GROUP_NAME] [varchar](30) NOT NULL,
	[PREDEFINED_GROUP_DESCRIPTION] [varchar](250) NOT NULL,
	[OUTCOME_TYPE] [varchar](20) NOT NULL,
	[CONDITION] [varchar](4000) NOT NULL,
 CONSTRAINT [RIF40_PREDEFINED_GROUPS_PK] PRIMARY KEY CLUSTERED 
(
	[PREDEFINED_GROUP_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_REFERENCE_TABLES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_REFERENCE_TABLES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_REFERENCE_TABLES](
	[TABLE_NAME] [varchar](30) NOT NULL,
 CONSTRAINT [RIF40_REFERENCE_TABLES_PK] PRIMARY KEY CLUSTERED 
(
	[TABLE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_STUDY_SHARES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_STUDY_SHARES](
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[GRANTOR] [varchar](90) NOT NULL,
	[GRANTEE_USERNAME] [varchar](90) NOT NULL,
 CONSTRAINT [RIF40_STUDY_SHARES_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[GRANTEE_USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_TABLE_OUTCOMES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TABLE_OUTCOMES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_TABLE_OUTCOMES](
	[OUTCOME_GROUP_NAME] [varchar](20) NOT NULL,
	[NUMER_TAB] [varchar](30) NOT NULL,
	[CURRENT_VERSION_START_YEAR] [numeric](4, 0) NULL,
 CONSTRAINT [RIF40_TABLE_OUTCOMES_PK] PRIMARY KEY CLUSTERED 
(
	[OUTCOME_GROUP_NAME] ASC,
	[NUMER_TAB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_TABLES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_TABLES](
	[THEME] [varchar](30) NOT NULL,
	[TABLE_NAME] [varchar](30) NOT NULL,
	[DESCRIPTION] [varchar](250) NOT NULL,
	[YEAR_START] [numeric](4, 0) NOT NULL,
	[YEAR_STOP] [numeric](4, 0) NOT NULL,
	[TOTAL_FIELD] [varchar](30) NULL,
	[ISINDIRECTDENOMINATOR] [numeric](1, 0) NOT NULL,
	[ISDIRECTDENOMINATOR] [numeric](1, 0) NOT NULL,
	[ISNUMERATOR] [numeric](1, 0) NOT NULL,
	[AUTOMATIC] [numeric](1, 0) NOT NULL,
	[SEX_FIELD_NAME] [varchar](30) NULL,
	[AGE_GROUP_FIELD_NAME] [varchar](30) NULL,
	[AGE_SEX_GROUP_FIELD_NAME] [varchar](30) NULL,
	[AGE_GROUP_ID] [numeric](3, 0) NULL,
	[VALIDATION_DATE] [datetime2](0) NULL,
	[ROWID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [RIF40_TABLES_PK] PRIMARY KEY CLUSTERED 
(
	[TABLE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[rif40_tables_and_views$]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rif40_tables_and_views$]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[rif40_tables_and_views$](
	[F1] [nvarchar](255) NULL,
	[F2] [nvarchar](255) NULL,
	[F3] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[rif40_triggers]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rif40_triggers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[rif40_triggers](
	[Column 0] [varchar](255) NULL,
	[Column 1] [varchar](255) NULL,
	[Column 2] [varchar](255) NULL,
	[Column 3] [varchar](255) NULL,
	[Column 4] [varchar](max) NULL,
	[Column 5] [varchar](255) NULL,
	[Column 6] [varchar](max) NULL,
	[Column 7] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIF40_VERSION]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_VERSION]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RIF40_VERSION](
	[VERSION] [varchar](50) NOT NULL,
	[SCHEMA_CREATED] [datetime2](0) NOT NULL,
	[SCHEMA_AMENDED] [datetime2](0) NULL,
	[CVS_REVISION] [varchar](50) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSU_CEN_Level4]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSU_CEN_Level4]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSU_CEN_Level4](
	[WKT] [varchar](50) NULL,
	[PERIMETER] [varchar](50) NULL,
	[LEVEL4] [varchar](50) NULL,
	[LEVEL2] [varchar](50) NULL,
	[LEVEL1] [varchar](50) NULL,
	[LEVEL3] [varchar](50) NULL,
	[XCentroid] [varchar](50) NULL,
	[YCentroid] [varchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_CANCER]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_CANCER](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[LEVEL1] [varchar](20) NOT NULL,
	[LEVEL2] [varchar](20) NOT NULL,
	[LEVEL3] [varchar](20) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL,
	[ICD] [varchar](4) NOT NULL,
	[TOTAL] [numeric](9, 5) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_COVARIATES_LEVEL3]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_COVARIATES_LEVEL3]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_COVARIATES_LEVEL3](
	[YEAR] [numeric](4, 0) NOT NULL,
	[LEVEL3] [varchar](20) NOT NULL,
	[SES] [numeric](1, 0) NOT NULL,
	[ETHNICITY] [numeric](1, 0) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_COVARIATES_LEVEL4]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_COVARIATES_LEVEL4]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_COVARIATES_LEVEL4](
	[YEAR] [numeric](4, 0) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL,
	[SES] [numeric](1, 0) NOT NULL,
	[AREATRI1KM] [numeric](1, 0) NOT NULL,
	[NEAR_DIST] [numeric](7, 2) NOT NULL,
	[TRI_1KM] [numeric](1, 0) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_GEOGRAPHY]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_GEOGRAPHY]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_GEOGRAPHY](
	[LEVEL1] [varchar](20) NOT NULL,
	[LEVEL2] [varchar](20) NOT NULL,
	[LEVEL3] [varchar](20) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_LEVEL1]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL1]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_LEVEL1](
	[LEVEL1] [varchar](20) NOT NULL,
	[NAME] [varchar](200) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_LEVEL2]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL2]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_LEVEL2](
	[LEVEL2] [varchar](20) NOT NULL,
	[NAME] [varchar](200) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_LEVEL3]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL3]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_LEVEL3](
	[LEVEL3] [varchar](20) NOT NULL,
	[NAME] [varchar](200) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_LEVEL4]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL4]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_LEVEL4](
	[LEVEL4] [varchar](20) NOT NULL,
	[NAME] [varchar](200) NOT NULL,
	[X_COORDINATE] [numeric](7, 0) NOT NULL,
	[Y_COORDINATE] [numeric](7, 0) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAHSULAND_POP]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SAHSULAND_POP](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[LEVEL1] [varchar](20) NOT NULL,
	[LEVEL2] [varchar](20) NOT NULL,
	[LEVEL3] [varchar](20) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL,
	[TOTAL] [numeric](9, 5) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpatialTable]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpatialTable]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SpatialTable](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[GeomCol1] [geometry] NULL,
	[GeomCol2]  AS ([GeomCol1].[STAsText]())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[T_RIF40_COMPARISON_AREAS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPARISON_AREAS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_COMPARISON_AREAS](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [varchar](300) NOT NULL,
 CONSTRAINT [T_RIF40_COMPARISON_AREAS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[AREA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_CONTEXTUAL_STATS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONTEXTUAL_STATS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[INV_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [numeric](8, 0) NOT NULL,
	[AREA_POPULATION] [numeric](38, 6) NULL,
	[AREA_OBSERVED] [numeric](38, 6) NULL,
	[TOTAL_COMPARISION_POPULATION] [numeric](38, 6) NULL,
	[VARIANCE_HIGH] [numeric](38, 6) NULL,
	[VARIANCE_LOW] [numeric](38, 6) NULL,
 CONSTRAINT [T_RIF40_CONTEXTUAL_STATS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[AREA_ID] ASC,
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_FDW_TABLES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_FDW_TABLES](
	[USERNAME] [varchar](90) NOT NULL,
	[TABLE_NAME] [varchar](30) NOT NULL,
	[CREATE_STATUS] [varchar](1) NOT NULL,
	[ERROR_MESSAGE] [varchar](300) NULL,
	[DATE_CREATED] [datetime2](0) NOT NULL,
	[ROWTEST_PASSED] [numeric](1, 0) NOT NULL,
 CONSTRAINT [T_RIF40_FDW_TABLES_PK] PRIMARY KEY CLUSTERED 
(
	[TABLE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_GEOLEVELS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_GEOLEVELS](
	[GEOGRAPHY] [varchar](50) NOT NULL,
	[GEOLEVEL_NAME] [varchar](30) NOT NULL,
	[GEOLEVEL_ID] [numeric](2, 0) NOT NULL,
	[DESCRIPTION] [varchar](250) NOT NULL,
	[LOOKUP_TABLE] [varchar](30) NOT NULL,
	[LOOKUP_DESC_COLUMN] [varchar](30) NOT NULL,
	[CENTROIDXCOORDINATE_COLUMN] [varchar](30) NULL,
	[CENTROIDYCOORDINATE_COLUMN] [varchar](30) NULL,
	[SHAPEFILE] [varchar](512) NULL,
	[CENTROIDSFILE] [varchar](512) NULL,
	[SHAPEFILE_TABLE] [varchar](30) NULL,
	[SHAPEFILE_AREA_ID_COLUMN] [varchar](30) NULL,
	[SHAPEFILE_DESC_COLUMN] [varchar](30) NULL,
	[ST_SIMPLIFY_TOLERANCE] [numeric](6, 0) NULL,
	[CENTROIDS_TABLE] [varchar](30) NULL,
	[CENTROIDS_AREA_ID_COLUMN] [varchar](30) NULL,
	[AVG_NPOINTS_GEOM] [numeric](12, 0) NULL,
	[AVG_NPOINTS_OPT] [numeric](12, 0) NULL,
	[FILE_GEOJSON_LEN] [numeric](12, 0) NULL,
	[LEG_GEOM] [numeric](12, 1) NULL,
	[LEG_OPT] [numeric](12, 1) NULL,
	[COVARIATE_TABLE] [varchar](30) NULL,
	[RESTRICTED] [numeric](1, 0) NOT NULL,
	[RESOLUTION] [numeric](1, 0) NOT NULL,
	[COMPAREA] [numeric](1, 0) NOT NULL,
	[LISTING] [numeric](1, 0) NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [T_RIF40_GEOLEVELS_PK] PRIMARY KEY CLUSTERED 
(
	[GEOGRAPHY] ASC,
	[GEOLEVEL_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_INV_CONDITIONS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CONDITIONS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_INV_CONDITIONS](
	[INV_ID] [numeric](8, 0) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[USERNAME] [varchar](90) NOT NULL,
	[LINE_NUMBER] [numeric](5, 0) NOT NULL,
	[CONDITION] [varchar](4000) NOT NULL,
 CONSTRAINT [T_RIF40_INV_CONDITIONS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[INV_ID] ASC,
	[LINE_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_INV_COVARIATES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_COVARIATES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_INV_COVARIATES](
	[INV_ID] [numeric](8, 0) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[COVARIATE_NAME] [varchar](20) NOT NULL,
	[USERNAME] [varchar](90) NOT NULL,
	[GEOGRAPHY] [varchar](30) NOT NULL,
	[STUDY_GEOLEVEL_NAME] [varchar](30) NULL,
	[MIN] [numeric](9, 3) NOT NULL,
	[MAX] [numeric](9, 3) NOT NULL,
 CONSTRAINT [T_RIF40_INV_COVARIATES_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[INV_ID] ASC,
	[COVARIATE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_INVESTIGATIONS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_INVESTIGATIONS](
	[INV_ID] [numeric](8, 0) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[USERNAME] [varchar](90) NOT NULL,
	[GEOGRAPHY] [varchar](30) NOT NULL,
	[INV_NAME] [varchar](20) NOT NULL,
	[INV_DESCRIPTION] [varchar](250) NOT NULL,
	[CLASSIFIER] [varchar](30) NOT NULL,
	[CLASSIFIER_BANDS] [numeric](2, 0) NOT NULL,
	[GENDERS] [numeric](1, 0) NOT NULL,
	[NUMER_TAB] [varchar](30) NOT NULL,
	[YEAR_START] [numeric](4, 0) NOT NULL,
	[YEAR_STOP] [numeric](4, 0) NOT NULL,
	[MAX_AGE_GROUP] [numeric](8, 0) NOT NULL,
	[MIN_AGE_GROUP] [numeric](8, 0) NOT NULL,
	[INVESTIGATION_STATE] [varchar](1) NOT NULL,
	[MH_TEST_TYPE] [varchar](50) NOT NULL,
 CONSTRAINT [T_RIF40_INVESTIGATIONS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_NUM_DENOM]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_NUM_DENOM](
	[GEOGRAPHY] [varchar](50) NOT NULL,
	[NUMERATOR_TABLE] [varchar](30) NOT NULL,
	[DENOMINATOR_TABLE] [varchar](30) NOT NULL,
 CONSTRAINT [T_RIF40_NUM_DENOM_PK] PRIMARY KEY CLUSTERED 
(
	[GEOGRAPHY] ASC,
	[NUMERATOR_TABLE] ASC,
	[DENOMINATOR_TABLE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_PARAMETERS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_PARAMETERS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_PARAMETERS](
	[PARAM_NAME] [varchar](30) NOT NULL,
	[PARAM_VALUE] [varchar](50) NOT NULL,
	[PARAM_DESCRIPTION] [varchar](250) NOT NULL,
 CONSTRAINT [T_RIF40_PARAMETERS_PK] PRIMARY KEY CLUSTERED 
(
	[PARAM_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_PROJECTS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_PROJECTS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_PROJECTS](
	[PROJECT] [varchar](30) NOT NULL,
	[DESCRIPTION] [varchar](250) NOT NULL,
	[DATE_STARTED] [datetime2](0) NOT NULL,
	[DATE_ENDED] [datetime2](0) NULL,
 CONSTRAINT [T_RIF40_PROJECTS_PK] PRIMARY KEY CLUSTERED 
(
	[PROJECT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_RESULTS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_RESULTS](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[INV_ID] [numeric](8, 0) NOT NULL,
	[BAND_ID] [numeric](8, 0) NOT NULL,
	[GENDERS] [numeric](1, 0) NOT NULL,
	[ADJUSTED] [numeric](1, 0) NOT NULL,
	[DIRECT_STANDARDISATION] [numeric](1, 0) NOT NULL,
	[OBSERVED] [numeric](38, 6) NULL,
	[EXPECTED] [numeric](38, 6) NULL,
	[LOWER95] [numeric](38, 6) NULL,
	[UPPER95] [numeric](38, 6) NULL,
	[RELATIVE_RISK] [numeric](38, 6) NULL,
	[SMOOTHED_RELATIVE_RISK] [numeric](38, 6) NULL,
	[POSTERIOR_PROBABILITY] [numeric](38, 6) NULL,
	[POSTERIOR_PROBABILITY_LOWER95] [numeric](38, 6) NULL,
	[POSTERIOR_PROBABILITY_UPPER95] [numeric](38, 6) NULL,
	[RESIDUAL_RELATIVE_RISK] [numeric](38, 6) NULL,
	[RESIDUAL_RR_LOWER95] [numeric](38, 6) NULL,
	[RESIDUAL_RR_UPPER95] [numeric](38, 6) NULL,
	[SMOOTHED_SMR] [numeric](38, 6) NULL,
	[SMOOTHED_SMR_LOWER95] [numeric](38, 6) NULL,
	[SMOOTHED_SMR_UPPER95] [numeric](38, 6) NULL,
 CONSTRAINT [T_RIF40_RESULTS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[BAND_ID] ASC,
	[INV_ID] ASC,
	[GENDERS] ASC,
	[ADJUSTED] ASC,
	[DIRECT_STANDARDISATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_STUDIES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_STUDIES](
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[USERNAME] [varchar](90) NOT NULL,
	[GEOGRAPHY] [varchar](30) NOT NULL,
	[PROJECT] [varchar](30) NOT NULL,
	[STUDY_NAME] [varchar](200) NOT NULL,
	[SUMMARY] [varchar](200) NULL,
	[DESCRIPTION] [varchar](2000) NULL,
	[OTHER_NOTES] [varchar](2000) NULL,
	[EXTRACT_TABLE] [varchar](30) NOT NULL,
	[MAP_TABLE] [varchar](30) NOT NULL,
	[STUDY_DATE] [datetime2](0) NOT NULL,
	[STUDY_TYPE] [numeric](2, 0) NOT NULL,
	[STUDY_STATE] [varchar](1) NOT NULL,
	[COMPARISON_GEOLEVEL_NAME] [varchar](30) NOT NULL,
	[STUDY_GEOLEVEL_NAME] [varchar](30) NOT NULL,
	[DENOM_TAB] [varchar](30) NOT NULL,
	[DIRECT_STAND_TAB] [varchar](30) NULL,
	[SUPPRESSION_VALUE] [numeric](2, 0) NOT NULL,
	[EXTRACT_PERMITTED] [numeric](1, 0) NOT NULL,
	[TRANSFER_PERMITTED] [numeric](1, 0) NOT NULL,
	[AUTHORISED_BY] [varchar](90) NULL,
	[AUTHORISED_ON] [datetime2](0) NULL,
	[AUTHORISED_NOTES] [varchar](200) NULL,
	[AUDSID] [varchar](90) NOT NULL,
 CONSTRAINT [T_RIF40_STUDIES_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_STUDY_AREAS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_AREAS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_STUDY_AREAS](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [varchar](300) NOT NULL,
	[BAND_ID] [numeric](8, 0) NULL,
 CONSTRAINT [T_RIF40_STUDY_AREAS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[AREA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_STUDY_SQL]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_STUDY_SQL](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[STATEMENT_TYPE] [varchar](30) NOT NULL,
	[STATEMENT_NUMBER] [numeric](6, 0) NOT NULL,
	[SQL_TEXT] [varchar](4000) NOT NULL,
	[LINE_NUMBER] [numeric](6, 0) NOT NULL,
	[STATUS] [varchar](1) NULL,
 CONSTRAINT [T_RIF40_STUDY_SQL_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[STATEMENT_NUMBER] ASC,
	[LINE_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_STUDY_SQL_LOG]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_STUDY_SQL_LOG](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[STATEMENT_TYPE] [varchar](30) NOT NULL,
	[STATEMENT_NUMBER] [numeric](6, 0) NOT NULL,
	[LOG_MESSAGE] [varchar](4000) NOT NULL,
	[LOG_SQLCODE] [varchar](5) NOT NULL,
	[ROWCOUNT] [numeric](12, 0) NOT NULL,
	[START_TIME] [datetimeoffset](6) NOT NULL,
	[ELAPSED_TIME] [numeric](10, 4) NOT NULL,
	[AUDSID] [varchar](90) NOT NULL,
 CONSTRAINT [T_RIF40_STUDY_SQL_LOG_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[STATEMENT_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RIF40_USER_PROJECTS]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[T_RIF40_USER_PROJECTS](
	[PROJECT] [varchar](30) NOT NULL,
	[USERNAME] [varchar](90) NOT NULL,
	[GRANT_DATE] [datetime2](0) NOT NULL,
	[REVOKE_DATE] [datetime2](0) NULL,
	[ROWID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [T_RIF40_USER_PROJECTS_PK] PRIMARY KEY CLUSTERED 
(
	[PROJECT] ASC,
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TEST_SAHSU_GRD_Level2_PIPE]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEST_SAHSU_GRD_Level2_PIPE]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TEST_SAHSU_GRD_Level2_PIPE](
	[WKT] [varchar](max) NULL,
	[LEVEL2] [varchar](255) NULL,
	[Area] [varchar](255) NULL,
	[LEVEL1] [varchar](255) NULL,
	[Name] [varchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UK91_RIF_POP_ASG_1_ED91]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UK91_RIF_POP_ASG_1_ED91]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UK91_RIF_POP_ASG_1_ED91](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[total] [int] NULL,
	[AGE_SEX_GROUP] [int] NULL
) ON [PRIMARY]
END
GO
/****** Object:  View [dbo].[rif40_comparison_areas]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_comparison_areas]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[rif40_comparison_areas] AS 
 SELECT c.username,
    c.study_id,
    c.area_id
   FROM t_rif40_comparison_areas c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND s.grantee_username= SUSER_SNAME() 
  WHERE (c.username = SUSER_SNAME()  OR
   IS_MEMBER(N''[rif40_manager]'') = 1  OR 
  s.grantee_username IS NOT NULL) AND 
  s.grantee_username<> ''''
  --ORDER BY c.username;
' 
GO
/****** Object:  View [dbo].[rif40_contextual_stats]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_contextual_stats]'))
EXEC dbo.sp_executesql @statement = N'-----------------------------------
-- view : rif40_contextual_stats
------------------------------------

 --drop view rif40_contextual_stats
CREATE VIEW [dbo].[rif40_contextual_stats] AS 
 SELECT c.username,
    c.study_id,
    c.inv_id,
    c.area_id,
    c.area_population,
    c.area_observed,
    c.total_comparision_population,
    c.variance_high,
    c.variance_low
   FROM t_rif40_contextual_stats c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND  s.grantee_username= SUSER_SNAME() 
   WHERE c.username = SUSER_SNAME()  OR 
   IS_MEMBER(N''[rif40_manager]'') = 1 OR 
   s.grantee_username IS NOT NULL AND
    s.grantee_username <> ''''
  --ORDER BY c.username;' 
GO
/****** Object:  View [dbo].[RIF40_FDW_TABLES]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_FDW_TABLES]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[RIF40_FDW_TABLES] (
   USERNAME, 
   TABLE_NAME, 
   CREATE_STATUS, 
   ERROR_MESSAGE, 
   DATE_CREATED, 
   ROWTEST_PASSED)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 5.3.0.*/
   SELECT 
      T_RIF40_FDW_TABLES.USERNAME, 
      T_RIF40_FDW_TABLES.TABLE_NAME, 
      T_RIF40_FDW_TABLES.CREATE_STATUS, 
      T_RIF40_FDW_TABLES.ERROR_MESSAGE, 
      T_RIF40_FDW_TABLES.DATE_CREATED, 
      T_RIF40_FDW_TABLES.ROWTEST_PASSED
   FROM dbo.T_RIF40_FDW_TABLES
   WHERE T_RIF40_FDW_TABLES.USERNAME = session_user' 
GO
/****** Object:  View [dbo].[rif40_fdw_tables_2]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_fdw_tables_2]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[rif40_fdw_tables_2] AS 
 SELECT t_rif40_fdw_tables.username,
    t_rif40_fdw_tables.table_name,
    t_rif40_fdw_tables.create_status,
    t_rif40_fdw_tables.error_message,
    t_rif40_fdw_tables.date_created,
    t_rif40_fdw_tables.rowtest_passed
   FROM t_rif40_fdw_tables
  WHERE t_rif40_fdw_tables.username = SUSER_SNAME()' 
GO
/****** Object:  View [dbo].[rif40_inv_covariates]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_inv_covariates]'))
EXEC dbo.sp_executesql @statement = N'  CREATE VIEW [dbo].[rif40_inv_covariates] 
  AS 
 SELECT c.username,
    c.study_id,
    c.inv_id,
    c.covariate_name,
    c.min,
    c.max,
    c.geography,
    c.study_geolevel_name
   FROM t_rif40_inv_covariates c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND s.grantee_username=SUSER_SNAME()
  WHERE c.username=SUSER_SNAME() OR 
  IS_MEMBER(N''[rif40_manager]'') = 1 OR 
  (s.grantee_username IS NOT NULL AND s.grantee_username <> '''')' 
GO
/****** Object:  View [dbo].[rif40_investigations]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_investigations]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[rif40_investigations] 
  AS 
 SELECT c.username,
    c.inv_id,
    c.study_id,
    c.inv_name,
    c.year_start,
    c.year_stop,
    c.max_age_group,
    c.min_age_group,
    c.genders,
    c.numer_tab,
    c.mh_test_type,
    c.inv_description,
    c.classifier,
    c.classifier_bands,
    c.investigation_state
   FROM t_rif40_investigations c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND s.grantee_username=SUSER_SNAME()
  WHERE c.username=SUSER_SNAME() OR 
  IS_MEMBER(N''[rif40_manager]'') = 1 OR 
  (s.grantee_username IS NOT NULL AND s.grantee_username <> '''')' 
GO
/****** Object:  View [dbo].[rif40_results]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_results]'))
EXEC dbo.sp_executesql @statement = N'CREATE  VIEW [dbo].[rif40_results] AS 
 SELECT c.username,
    c.study_id,
    c.inv_id,
    c.band_id,
    c.genders,
    c.direct_standardisation,
    c.adjusted,
    c.observed,
    c.expected,
    c.lower95,
    c.upper95,
    c.relative_risk,
    c.smoothed_relative_risk,
    c.posterior_probability,
    c.posterior_probability_upper95,
    c.posterior_probability_lower95,
    c.residual_relative_risk,
    c.residual_rr_lower95,
    c.residual_rr_upper95,
    c.smoothed_smr,
    c.smoothed_smr_lower95,
    c.smoothed_smr_upper95
   FROM t_rif40_results c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND  s.grantee_username=SUSER_SNAME()
  WHERE c.username=SUSER_SNAME() OR 
  IS_MEMBER(N''[rif40_manager]'') = 1 OR 
  (s.grantee_username IS NOT NULL AND s.grantee_username <> '''')
' 
GO
/****** Object:  View [dbo].[rif40_study_areas]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_study_areas]'))
EXEC dbo.sp_executesql @statement = N'  CREATE VIEW [dbo].[rif40_study_areas] AS 
 SELECT c.username,
    c.study_id,
    c.area_id,
    c.band_id
   FROM t_rif40_study_areas c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND s.grantee_username=SUSER_SNAME()
  WHERE c.username=SUSER_SNAME() OR 
  IS_MEMBER(N''[rif40_manager]'') = 1 OR 
  (s.grantee_username IS NOT NULL AND s.grantee_username <> '''')' 
GO
/****** Object:  View [dbo].[rif40_study_sql]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_study_sql]'))
EXEC dbo.sp_executesql @statement = N'  CREATE VIEW [dbo].[rif40_study_sql] AS 
 SELECT c.username,
    c.study_id,
    c.statement_type,
    c.statement_number,
    c.sql_text,
    c.line_number,
    c.status
   FROM t_rif40_study_sql c
     LEFT JOIN rif40_study_shares s ON c.study_id = s.study_id AND s.grantee_username=SUSER_SNAME()
  WHERE c.username=SUSER_SNAME() OR 
  IS_MEMBER(N''[rif40_manager]'') = 1 OR 
  (s.grantee_username IS NOT NULL AND s.grantee_username <> '''')' 
GO
/****** Object:  View [dbo].[rif40_user_projects]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rif40_user_projects]'))
EXEC dbo.sp_executesql @statement = N'  CREATE  VIEW [dbo].[rif40_user_projects] AS 
 SELECT a.project,
    a.username,
    a.grant_date,
    a.revoke_date,
    b.description,
    b.date_started,
    b.date_ended
   FROM t_rif40_user_projects a,
    t_rif40_projects b
  WHERE a.project = b.project AND a.username= SUSER_SNAME() 
  OR  IS_MEMBER(N''[rif40_manager]'') = 1' 
GO
/****** Object:  View [dbo].[RIF40_USER_VERSION]    Script Date: 23/10/2014 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_USER_VERSION]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[RIF40_USER_VERSION] (USER_SCHEMA_REVISION)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 5.3.0.*/
   /*
   *   SSMA informational messages:
   *   O2SS0199: SELECT from the DUAL table was converted. (Migration issue #43.12)
   *   O2SS0271: Type converted according to type mapping: [NUMBER(6, 3)] -> [numeric(6, 3)].
   */

   SELECT CAST(''1.0'' AS numeric(6, 3)) AS user_schema_revision' 
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_AGE_GROUPS_PK2]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUPS]') AND name = N'RIF40_AGE_GROUPS_PK2')
CREATE UNIQUE NONCLUSTERED INDEX [RIF40_AGE_GROUPS_PK2] ON [dbo].[RIF40_AGE_GROUPS]
(
	[AGE_GROUP_ID] ASC,
	[FIELDNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_ICD_O_3_1CHAR_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD_O_3]') AND name = N'RIF40_ICD_O_3_1CHAR_BM')
CREATE NONCLUSTERED INDEX [RIF40_ICD_O_3_1CHAR_BM] ON [dbo].[RIF40_ICD_O_3]
(
	[ICD_O_3_1CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_ICD10_1CHAR_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD10]') AND name = N'RIF40_ICD10_1CHAR_BM')
CREATE NONCLUSTERED INDEX [RIF40_ICD10_1CHAR_BM] ON [dbo].[RIF40_ICD10]
(
	[ICD10_1CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_ICD10_3CHAR_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD10]') AND name = N'RIF40_ICD10_3CHAR_BM')
CREATE NONCLUSTERED INDEX [RIF40_ICD10_3CHAR_BM] ON [dbo].[RIF40_ICD10]
(
	[ICD10_3CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_ICD9_3CHAR_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ICD9]') AND name = N'RIF40_ICD9_3CHAR_BM')
CREATE NONCLUSTERED INDEX [RIF40_ICD9_3CHAR_BM] ON [dbo].[RIF40_ICD9]
(
	[ICD9_3CHAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_STUDY_SHARES_GRANTEE_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES]') AND name = N'RIF40_STUDY_SHARES_GRANTEE_BM')
CREATE NONCLUSTERED INDEX [RIF40_STUDY_SHARES_GRANTEE_BM] ON [dbo].[RIF40_STUDY_SHARES]
(
	[GRANTEE_USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [RIF40_STUDY_SHARES_GRANTOR_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES]') AND name = N'RIF40_STUDY_SHARES_GRANTOR_BM')
CREATE NONCLUSTERED INDEX [RIF40_STUDY_SHARES_GRANTOR_BM] ON [dbo].[RIF40_STUDY_SHARES]
(
	[GRANTOR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [RIF40_STUDY_SHARES_STUDY_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES]') AND name = N'RIF40_STUDY_SHARES_STUDY_ID_FK')
CREATE NONCLUSTERED INDEX [RIF40_STUDY_SHARES_STUDY_ID_FK] ON [dbo].[RIF40_STUDY_SHARES]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [SAHSULAND_CANCER_AGE_SEX_GROUP]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_AGE_SEX_GROUP')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_AGE_SEX_GROUP] ON [dbo].[SAHSULAND_CANCER]
(
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_CANCER_ICD]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_ICD')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_ICD] ON [dbo].[SAHSULAND_CANCER]
(
	[ICD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_CANCER_LEVEL1]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_LEVEL1')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_LEVEL1] ON [dbo].[SAHSULAND_CANCER]
(
	[LEVEL1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_CANCER_LEVEL2]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_LEVEL2')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_LEVEL2] ON [dbo].[SAHSULAND_CANCER]
(
	[LEVEL2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_CANCER_LEVEL3]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_LEVEL3')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_LEVEL3] ON [dbo].[SAHSULAND_CANCER]
(
	[LEVEL3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_CANCER_LEVEL4]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_LEVEL4')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_LEVEL4] ON [dbo].[SAHSULAND_CANCER]
(
	[LEVEL4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_CANCER_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_CANCER_PK] ON [dbo].[SAHSULAND_CANCER]
(
	[YEAR] ASC,
	[LEVEL4] ASC,
	[AGE_SEX_GROUP] ASC,
	[ICD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [SAHSULAND_CANCER_YEAR]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_CANCER]') AND name = N'SAHSULAND_CANCER_YEAR')
CREATE NONCLUSTERED INDEX [SAHSULAND_CANCER_YEAR] ON [dbo].[SAHSULAND_CANCER]
(
	[YEAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_COVARIATES_LEVEL3_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_COVARIATES_LEVEL3]') AND name = N'SAHSULAND_COVARIATES_LEVEL3_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_COVARIATES_LEVEL3_PK] ON [dbo].[SAHSULAND_COVARIATES_LEVEL3]
(
	[YEAR] ASC,
	[LEVEL3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_COVARIATES_LEVEL4_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_COVARIATES_LEVEL4]') AND name = N'SAHSULAND_COVARIATES_LEVEL4_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_COVARIATES_LEVEL4_PK] ON [dbo].[SAHSULAND_COVARIATES_LEVEL4]
(
	[YEAR] ASC,
	[LEVEL4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_GEOGRAPHY_BM2]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_GEOGRAPHY]') AND name = N'SAHSULAND_GEOGRAPHY_BM2')
CREATE NONCLUSTERED INDEX [SAHSULAND_GEOGRAPHY_BM2] ON [dbo].[SAHSULAND_GEOGRAPHY]
(
	[LEVEL1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_GEOGRAPHY_BM3]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_GEOGRAPHY]') AND name = N'SAHSULAND_GEOGRAPHY_BM3')
CREATE NONCLUSTERED INDEX [SAHSULAND_GEOGRAPHY_BM3] ON [dbo].[SAHSULAND_GEOGRAPHY]
(
	[LEVEL2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_GEOGRAPHY_BM4]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_GEOGRAPHY]') AND name = N'SAHSULAND_GEOGRAPHY_BM4')
CREATE NONCLUSTERED INDEX [SAHSULAND_GEOGRAPHY_BM4] ON [dbo].[SAHSULAND_GEOGRAPHY]
(
	[LEVEL3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_GEOGRAPHY_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_GEOGRAPHY]') AND name = N'SAHSULAND_GEOGRAPHY_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_GEOGRAPHY_PK] ON [dbo].[SAHSULAND_GEOGRAPHY]
(
	[LEVEL4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_LEVEL1_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL1]') AND name = N'SAHSULAND_LEVEL1_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_LEVEL1_PK] ON [dbo].[SAHSULAND_LEVEL1]
(
	[LEVEL1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_LEVEL2_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL2]') AND name = N'SAHSULAND_LEVEL2_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_LEVEL2_PK] ON [dbo].[SAHSULAND_LEVEL2]
(
	[LEVEL2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_LEVEL3_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL3]') AND name = N'SAHSULAND_LEVEL3_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_LEVEL3_PK] ON [dbo].[SAHSULAND_LEVEL3]
(
	[LEVEL3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_LEVEL4_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_LEVEL4]') AND name = N'SAHSULAND_LEVEL4_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_LEVEL4_PK] ON [dbo].[SAHSULAND_LEVEL4]
(
	[LEVEL4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [SAHSULAND_POP_AGE_SEX_GROUP]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_AGE_SEX_GROUP')
CREATE NONCLUSTERED INDEX [SAHSULAND_POP_AGE_SEX_GROUP] ON [dbo].[SAHSULAND_POP]
(
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_POP_LEVEL1]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_LEVEL1')
CREATE NONCLUSTERED INDEX [SAHSULAND_POP_LEVEL1] ON [dbo].[SAHSULAND_POP]
(
	[LEVEL1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_POP_LEVEL2]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_LEVEL2')
CREATE NONCLUSTERED INDEX [SAHSULAND_POP_LEVEL2] ON [dbo].[SAHSULAND_POP]
(
	[LEVEL2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_POP_LEVEL3]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_LEVEL3')
CREATE NONCLUSTERED INDEX [SAHSULAND_POP_LEVEL3] ON [dbo].[SAHSULAND_POP]
(
	[LEVEL3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_POP_LEVEL4]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_LEVEL4')
CREATE NONCLUSTERED INDEX [SAHSULAND_POP_LEVEL4] ON [dbo].[SAHSULAND_POP]
(
	[LEVEL4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SAHSULAND_POP_PK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_PK')
CREATE UNIQUE NONCLUSTERED INDEX [SAHSULAND_POP_PK] ON [dbo].[SAHSULAND_POP]
(
	[YEAR] ASC,
	[LEVEL4] ASC,
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [SAHSULAND_POP_YEAR]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SAHSULAND_POP]') AND name = N'SAHSULAND_POP_YEAR')
CREATE NONCLUSTERED INDEX [SAHSULAND_POP_YEAR] ON [dbo].[SAHSULAND_POP]
(
	[YEAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_COMP_AREAS_UNAME]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPARISON_AREAS]') AND name = N'T_RIF40_COMP_AREAS_UNAME')
CREATE NONCLUSTERED INDEX [T_RIF40_COMP_AREAS_UNAME] ON [dbo].[T_RIF40_COMPARISON_AREAS]
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_COMPAREAS_STUDY_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPARISON_AREAS]') AND name = N'T_RIF40_COMPAREAS_STUDY_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_COMPAREAS_STUDY_ID_FK] ON [dbo].[T_RIF40_COMPARISON_AREAS]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_CONSTATS_INV_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONTEXTUAL_STATS]') AND name = N'T_RIF40_CONSTATS_INV_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_CONSTATS_INV_ID_FK] ON [dbo].[T_RIF40_CONTEXTUAL_STATS]
(
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_CONSTATS_STUDY_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONTEXTUAL_STATS]') AND name = N'T_RIF40_CONSTATS_STUDY_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_CONSTATS_STUDY_ID_FK] ON [dbo].[T_RIF40_CONTEXTUAL_STATS]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_CONSTATS_UNAME_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONTEXTUAL_STATS]') AND name = N'T_RIF40_CONSTATS_UNAME_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_CONSTATS_UNAME_BM] ON [dbo].[T_RIF40_CONTEXTUAL_STATS]
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_GEOLEVELS_UK2]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]') AND name = N'T_RIF40_GEOLEVELS_UK2')
CREATE UNIQUE NONCLUSTERED INDEX [T_RIF40_GEOLEVELS_UK2] ON [dbo].[T_RIF40_GEOLEVELS]
(
	[GEOGRAPHY] ASC,
	[GEOLEVEL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER INDEX [T_RIF40_GEOLEVELS_UK2] ON [dbo].[T_RIF40_GEOLEVELS] DISABLE
GO
/****** Object:  Index [T_RIF40_INV_COVARIATES_SI_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_COVARIATES]') AND name = N'T_RIF40_INV_COVARIATES_SI_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_INV_COVARIATES_SI_FK] ON [dbo].[T_RIF40_INV_COVARIATES]
(
	[STUDY_ID] ASC,
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_INV_STUDY_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]') AND name = N'T_RIF40_INV_STUDY_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_INV_STUDY_ID_FK] ON [dbo].[T_RIF40_INVESTIGATIONS]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_RESULTS_BAND_ID_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]') AND name = N'T_RIF40_RESULTS_BAND_ID_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_RESULTS_BAND_ID_BM] ON [dbo].[T_RIF40_RESULTS]
(
	[BAND_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_RESULTS_INV_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]') AND name = N'T_RIF40_RESULTS_INV_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_RESULTS_INV_ID_FK] ON [dbo].[T_RIF40_RESULTS]
(
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_RESULTS_STUDY_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]') AND name = N'T_RIF40_RESULTS_STUDY_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_RESULTS_STUDY_ID_FK] ON [dbo].[T_RIF40_RESULTS]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_RESULTS_USERNAME_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]') AND name = N'T_RIF40_RESULTS_USERNAME_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_RESULTS_USERNAME_BM] ON [dbo].[T_RIF40_RESULTS]
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_EXTRACT_TABLE_UK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]') AND name = N'T_RIF40_EXTRACT_TABLE_UK')
CREATE UNIQUE NONCLUSTERED INDEX [T_RIF40_EXTRACT_TABLE_UK] ON [dbo].[T_RIF40_STUDIES]
(
	[EXTRACT_TABLE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_MAP_TABLE_UK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]') AND name = N'T_RIF40_MAP_TABLE_UK')
CREATE UNIQUE NONCLUSTERED INDEX [T_RIF40_MAP_TABLE_UK] ON [dbo].[T_RIF40_STUDIES]
(
	[MAP_TABLE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_STUDY_AREAS_BAND_ID]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_AREAS]') AND name = N'T_RIF40_STUDY_AREAS_BAND_ID')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_AREAS_BAND_ID] ON [dbo].[T_RIF40_STUDY_AREAS]
(
	[BAND_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_STUDY_AREAS_UNAME]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_AREAS]') AND name = N'T_RIF40_STUDY_AREAS_UNAME')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_AREAS_UNAME] ON [dbo].[T_RIF40_STUDY_AREAS]
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_STUDYAREAS_STUDY_ID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_AREAS]') AND name = N'T_RIF40_STUDYAREAS_STUDY_ID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDYAREAS_STUDY_ID_FK] ON [dbo].[T_RIF40_STUDY_AREAS]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_STUDY_SQL_SID_LINE_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]') AND name = N'T_RIF40_STUDY_SQL_SID_LINE_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_SQL_SID_LINE_FK] ON [dbo].[T_RIF40_STUDY_SQL]
(
	[STUDY_ID] ASC,
	[STATEMENT_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_STUDY_SQL_TYPE_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]') AND name = N'T_RIF40_STUDY_SQL_TYPE_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_SQL_TYPE_BM] ON [dbo].[T_RIF40_STUDY_SQL]
(
	[STATEMENT_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_STUDY_SQL_UNAME_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]') AND name = N'T_RIF40_STUDY_SQL_UNAME_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_SQL_UNAME_BM] ON [dbo].[T_RIF40_STUDY_SQL]
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [T_RIF40_STUDY_SQLLOG_STDID_FK]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]') AND name = N'T_RIF40_STUDY_SQLLOG_STDID_FK')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_SQLLOG_STDID_FK] ON [dbo].[T_RIF40_STUDY_SQL_LOG]
(
	[STUDY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_STUDY_SQLLOG_TYPE_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]') AND name = N'T_RIF40_STUDY_SQLLOG_TYPE_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_SQLLOG_TYPE_BM] ON [dbo].[T_RIF40_STUDY_SQL_LOG]
(
	[STATEMENT_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [T_RIF40_STUDY_SQLLOG_UNAME_BM]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]') AND name = N'T_RIF40_STUDY_SQLLOG_UNAME_BM')
CREATE NONCLUSTERED INDEX [T_RIF40_STUDY_SQLLOG_UNAME_BM] ON [dbo].[T_RIF40_STUDY_SQL_LOG]
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ROWID$INDEX]    Script Date: 23/10/2014 11:36:24 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS]') AND name = N'ROWID$INDEX')
CREATE UNIQUE NONCLUSTERED INDEX [ROWID$INDEX] ON [dbo].[T_RIF40_USER_PROJECTS]
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[dfltErrorLog_error_date]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[rif40_ErrorLog] ADD  CONSTRAINT [dfltErrorLog_error_date]  DEFAULT (getdate()) FOR [Error_Date]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[dfltErrorLog_error_user_system]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[rif40_ErrorLog] ADD  CONSTRAINT [dfltErrorLog_error_user_system]  DEFAULT (suser_sname()) FOR [Error_User_System]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_GEOG__SRID__1FCDBCEB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] ADD  DEFAULT ((0)) FOR [SRID]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_GEO__PARTI__20C1E124]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] ADD  DEFAULT ((0)) FOR [PARTITION]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_GEO__MAX_G__21B6055D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] ADD  DEFAULT ((8)) FOR [MAX_GEOJSON_DIGITS]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_POPU__YEAR__2C3393D0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_POPULATION_EUROPE] ADD  DEFAULT ((1991)) FOR [YEAR]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_POPU__YEAR__2E1BDC42]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_POPULATION_US] ADD  DEFAULT ((2000)) FOR [YEAR]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_POPU__YEAR__300424B4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_POPULATION_WORLD] ADD  DEFAULT ((1991)) FOR [YEAR]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_PRE__CONDI__31EC6D26]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_PREDEFINED_GROUPS] ADD  DEFAULT ('1=1') FOR [CONDITION]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_STU__GRANT__35BCFE0A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_STUDY_SHARES] ADD  DEFAULT (user_name()) FOR [GRANTOR]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_TAB__AUTOM__3A81B327]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_TABLES] ADD  DEFAULT ((0)) FOR [AUTOMATIC]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_TAB__AGE_S__3B75D760]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_TABLES] ADD  DEFAULT ('AGE_SEX_GROUP') FOR [AGE_SEX_GROUP_FIELD_NAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__RIF40_VER__SCHEM__3E52440B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RIF40_VERSION] ADD  DEFAULT (sysdatetime()) FOR [SCHEMA_CREATED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_C__USERN__49C3F6B7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_COMPARISON_AREAS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_C__USERN__4CA06362]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_F__USERN__4F7CD00D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_F__DATE___5070F446]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] ADD  DEFAULT (sysdatetime()) FOR [DATE_CREATED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_F__ROWTE__5165187F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] ADD  DEFAULT ((0)) FOR [ROWTEST_PASSED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_G__RESTR__534D60F1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS] ADD  DEFAULT ((0)) FOR [RESTRICTED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__USERN__5629CD9C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INV_CONDITIONS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__LINE___571DF1D5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INV_CONDITIONS] ADD  DEFAULT ((1)) FOR [LINE_NUMBER]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__CONDI__5812160E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INV_CONDITIONS] ADD  DEFAULT ('1=1') FOR [CONDITION]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__USERN__5AEE82B9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INV_COVARIATES] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__USERN__5DCAEF64]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__CLASS__5EBF139D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ('QUANTILE') FOR [CLASSIFIER]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__CLASS__5FB337D6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ((5)) FOR [CLASSIFIER_BANDS]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__INVES__60A75C0F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ('C') FOR [INVESTIGATION_STATE]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_I__MH_TE__619B8048]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ('No Test') FOR [MH_TEST_TYPE]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_P__DATE___6754599E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_PROJECTS] ADD  DEFAULT (sysdatetime()) FOR [DATE_STARTED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_R__USERN__693CA210]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_RESULTS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__USERN__6C190EBB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__STUDY__6D0D32F4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT (sysdatetime()) FOR [STUDY_DATE]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__STUDY__6E01572D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT ('C') FOR [STUDY_STATE]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__EXTRA__6EF57B66]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT ((0)) FOR [EXTRACT_PERMITTED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__TRANS__6FE99F9F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT ((0)) FOR [TRANSFER_PERMITTED]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__AUDSI__324172E1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT (@@spid) FOR [AUDSID]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__USERN__72C60C4A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__USERN__75A278F5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_S__USERN__778AC167]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_U__USERN__797309D9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_USER_PROJECTS] ADD  DEFAULT (user_name()) FOR [USERNAME]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__T_RIF40_U__GRANT__7A672E12]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[T_RIF40_USER_PROJECTS] ADD  DEFAULT (sysdatetime()) FOR [GRANT_DATE]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUP_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUPS]'))
ALTER TABLE [dbo].[RIF40_AGE_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [RIF40_AGE_GROUP_ID_FK] FOREIGN KEY([AGE_GROUP_ID])
REFERENCES [dbo].[RIF40_AGE_GROUP_NAMES] ([AGE_GROUP_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUP_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_AGE_GROUPS]'))
ALTER TABLE [dbo].[RIF40_AGE_GROUPS] CHECK CONSTRAINT [RIF40_AGE_GROUP_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES_GEOG_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]'))
ALTER TABLE [dbo].[RIF40_COVARIATES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_COVARIATES_GEOG_FK] FOREIGN KEY([GEOGRAPHY])
REFERENCES [dbo].[RIF40_GEOGRAPHIES] ([GEOGRAPHY])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES_GEOG_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]'))
ALTER TABLE [dbo].[RIF40_COVARIATES] CHECK CONSTRAINT [RIF40_COVARIATES_GEOG_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES_GEOLEVEL_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]'))
ALTER TABLE [dbo].[RIF40_COVARIATES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_COVARIATES_GEOLEVEL_FK] FOREIGN KEY([GEOGRAPHY], [GEOLEVEL_NAME])
REFERENCES [dbo].[T_RIF40_GEOLEVELS] ([GEOGRAPHY], [GEOLEVEL_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES_GEOLEVEL_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]'))
ALTER TABLE [dbo].[RIF40_COVARIATES] CHECK CONSTRAINT [RIF40_COVARIATES_GEOLEVEL_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS_TYPE_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS]'))
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [RIF40_OUTCOME_GROUPS_TYPE_FK] FOREIGN KEY([OUTCOME_TYPE])
REFERENCES [dbo].[RIF40_OUTCOMES] ([OUTCOME_TYPE])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS_TYPE_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS]'))
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS] CHECK CONSTRAINT [RIF40_OUTCOME_GROUPS_TYPE_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_TYPE_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_GROUPS]'))
ALTER TABLE [dbo].[RIF40_PREDEFINED_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [RIF40_PREDEFINED_TYPE_FK] FOREIGN KEY([OUTCOME_TYPE])
REFERENCES [dbo].[RIF40_OUTCOMES] ([OUTCOME_TYPE])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_TYPE_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_GROUPS]'))
ALTER TABLE [dbo].[RIF40_PREDEFINED_GROUPS] CHECK CONSTRAINT [RIF40_PREDEFINED_TYPE_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES]'))
ALTER TABLE [dbo].[RIF40_STUDY_SHARES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_STUDY_SHARES_STUDY_ID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_STUDY_SHARES]'))
ALTER TABLE [dbo].[RIF40_STUDY_SHARES] CHECK CONSTRAINT [RIF40_STUDY_SHARES_STUDY_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_NUMER_TAB_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLE_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_TABLE_OUTCOMES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_OUTCOME_NUMER_TAB_FK] FOREIGN KEY([NUMER_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_NUMER_TAB_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLE_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_TABLE_OUTCOMES] CHECK CONSTRAINT [RIF40_OUTCOME_NUMER_TAB_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES_AGE_GROUP_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TABLES_AGE_GROUP_ID_FK] FOREIGN KEY([AGE_GROUP_ID])
REFERENCES [dbo].[RIF40_AGE_GROUP_NAMES] ([AGE_GROUP_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES_AGE_GROUP_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TABLES_AGE_GROUP_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES_THEME_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TABLES_THEME_FK] FOREIGN KEY([THEME])
REFERENCES [dbo].[RIF40_HEALTH_STUDY_THEMES] ([THEME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES_THEME_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TABLES_THEME_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPAREAS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPARISON_AREAS]'))
ALTER TABLE [dbo].[T_RIF40_COMPARISON_AREAS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_COMPAREAS_STUDY_ID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPAREAS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_COMPARISON_AREAS]'))
ALTER TABLE [dbo].[T_RIF40_COMPARISON_AREAS] CHECK CONSTRAINT [T_RIF40_COMPAREAS_STUDY_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONSTATS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONTEXTUAL_STATS]'))
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_CONSTATS_STUDY_ID_FK] FOREIGN KEY([STUDY_ID], [INV_ID])
REFERENCES [dbo].[T_RIF40_INVESTIGATIONS] ([STUDY_ID], [INV_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONSTATS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_CONTEXTUAL_STATS]'))
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS] CHECK CONSTRAINT [T_RIF40_CONSTATS_STUDY_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES_TN_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]'))
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_FDW_TABLES_TN_FK] FOREIGN KEY([TABLE_NAME])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES_TN_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]'))
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] CHECK CONSTRAINT [T_RIF40_FDW_TABLES_TN_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS_GEOG_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_GEOLEVELS_GEOG_FK] FOREIGN KEY([GEOGRAPHY])
REFERENCES [dbo].[RIF40_GEOGRAPHIES] ([GEOGRAPHY])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS_GEOG_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS] CHECK CONSTRAINT [T_RIF40_GEOLEVELS_GEOG_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CONDITIONS_SI_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CONDITIONS]'))
ALTER TABLE [dbo].[T_RIF40_INV_CONDITIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_CONDITIONS_SI_FK] FOREIGN KEY([STUDY_ID], [INV_ID])
REFERENCES [dbo].[T_RIF40_INVESTIGATIONS] ([STUDY_ID], [INV_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CONDITIONS_SI_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CONDITIONS]'))
ALTER TABLE [dbo].[T_RIF40_INV_CONDITIONS] CHECK CONSTRAINT [T_RIF40_INV_CONDITIONS_SI_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_COVARIATES_SI_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_COVARIATES]'))
ALTER TABLE [dbo].[T_RIF40_INV_COVARIATES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_COVARIATES_SI_FK] FOREIGN KEY([STUDY_ID], [INV_ID])
REFERENCES [dbo].[T_RIF40_INVESTIGATIONS] ([STUDY_ID], [INV_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_COVARIATES_SI_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_COVARIATES]'))
ALTER TABLE [dbo].[T_RIF40_INV_COVARIATES] CHECK CONSTRAINT [T_RIF40_INV_COVARIATES_SI_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_NUMER_TAB_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_NUMER_TAB_FK] FOREIGN KEY([NUMER_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_NUMER_TAB_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_NUMER_TAB_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_STUDY_ID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_STUDY_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM_DENOM_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]'))
ALTER TABLE [dbo].[T_RIF40_NUM_DENOM]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_NUM_DENOM_DENOM_FK] FOREIGN KEY([DENOMINATOR_TABLE])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM_DENOM_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]'))
ALTER TABLE [dbo].[T_RIF40_NUM_DENOM] CHECK CONSTRAINT [T_RIF40_NUM_DENOM_DENOM_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM_GEOG_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]'))
ALTER TABLE [dbo].[T_RIF40_NUM_DENOM]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_NUM_DENOM_GEOG_FK] FOREIGN KEY([GEOGRAPHY])
REFERENCES [dbo].[RIF40_GEOGRAPHIES] ([GEOGRAPHY])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM_GEOG_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]'))
ALTER TABLE [dbo].[T_RIF40_NUM_DENOM] CHECK CONSTRAINT [T_RIF40_NUM_DENOM_GEOG_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM_NUMER_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]'))
ALTER TABLE [dbo].[T_RIF40_NUM_DENOM]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_NUM_DENOM_NUMER_FK] FOREIGN KEY([NUMERATOR_TABLE])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM_NUMER_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_NUM_DENOM]'))
ALTER TABLE [dbo].[T_RIF40_NUM_DENOM] CHECK CONSTRAINT [T_RIF40_NUM_DENOM_NUMER_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_RESULTS_STUDY_ID_FK] FOREIGN KEY([STUDY_ID], [INV_ID])
REFERENCES [dbo].[T_RIF40_INVESTIGATIONS] ([STUDY_ID], [INV_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS] CHECK CONSTRAINT [T_RIF40_RESULTS_STUDY_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDIES_PROJECT_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_STUDIES_PROJECT_FK] FOREIGN KEY([PROJECT])
REFERENCES [dbo].[T_RIF40_PROJECTS] ([PROJECT])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_STUDIES_PROJECT_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [RIF40_STUDIES_PROJECT_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_DENOM_TAB_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_DENOM_TAB_FK] FOREIGN KEY([DENOM_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_DENOM_TAB_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_DENOM_TAB_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_DIRECT_STAND_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_DIRECT_STAND_FK] FOREIGN KEY([DIRECT_STAND_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_DIRECT_STAND_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_DIRECT_STAND_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDYAREAS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_AREAS]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDYAREAS_STUDY_ID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDYAREAS_STUDY_ID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_AREAS]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS] CHECK CONSTRAINT [T_RIF40_STUDYAREAS_STUDY_ID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_SID_LINE_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDY_SQL_SID_LINE_FK] FOREIGN KEY([STUDY_ID], [STATEMENT_NUMBER])
REFERENCES [dbo].[T_RIF40_STUDY_SQL_LOG] ([STUDY_ID], [STATEMENT_NUMBER])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_SID_LINE_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL] CHECK CONSTRAINT [T_RIF40_STUDY_SQL_SID_LINE_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQLLOG_STDID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDY_SQLLOG_STDID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQLLOG_STDID_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG] CHECK CONSTRAINT [T_RIF40_STUDY_SQLLOG_STDID_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_USER_PROJECTS_PROJECT_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS]'))
ALTER TABLE [dbo].[T_RIF40_USER_PROJECTS]  WITH NOCHECK ADD  CONSTRAINT [RIF40_USER_PROJECTS_PROJECT_FK] FOREIGN KEY([PROJECT])
REFERENCES [dbo].[T_RIF40_PROJECTS] ([PROJECT])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_USER_PROJECTS_PROJECT_FK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS]'))
ALTER TABLE [dbo].[T_RIF40_USER_PROJECTS] CHECK CONSTRAINT [RIF40_USER_PROJECTS_PROJECT_FK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES_LISTING_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]'))
ALTER TABLE [dbo].[RIF40_COVARIATES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_COVARIATES_LISTING_CK] CHECK  (([TYPE]=(2) OR [TYPE]=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES_LISTING_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_COVARIATES]'))
ALTER TABLE [dbo].[RIF40_COVARIATES] CHECK CONSTRAINT [RIF40_COVARIATES_LISTING_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ERROR_MESSAGES_CODE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_ERROR_MESSAGES]'))
ALTER TABLE [dbo].[RIF40_ERROR_MESSAGES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_ERROR_MESSAGES_CODE_CK] CHECK  (([ERROR_CODE]=(-2291) OR [ERROR_CODE]=(-2290) OR [ERROR_CODE]=(-4088) OR [ERROR_CODE]=(-1) OR [ERROR_CODE]>=(-20999) AND [ERROR_CODE]<=(-20000)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_ERROR_MESSAGES_CODE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_ERROR_MESSAGES]'))
ALTER TABLE [dbo].[RIF40_ERROR_MESSAGES] CHECK CONSTRAINT [RIF40_ERROR_MESSAGES_CODE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[POSTAL_POPULATION_TABLE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_GEOGRAPHIES]'))
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES]  WITH NOCHECK ADD  CONSTRAINT [POSTAL_POPULATION_TABLE_CK] CHECK  (([POSTAL_POPULATION_TABLE] IS NOT NULL AND [POSTAL_POINT_COLUMN] IS NOT NULL OR [POSTAL_POPULATION_TABLE] IS NULL AND [POSTAL_POINT_COLUMN] IS NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[POSTAL_POPULATION_TABLE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_GEOGRAPHIES]'))
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] CHECK CONSTRAINT [POSTAL_POPULATION_TABLE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[OUTCOME_TYPE_CK2]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS]'))
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [OUTCOME_TYPE_CK2] CHECK  (([OUTCOME_TYPE]='BIRTHWEIGHT' OR [OUTCOME_TYPE]='OPCS' OR [OUTCOME_TYPE]='ICD-O' OR [OUTCOME_TYPE]='ICD' OR [OUTCOME_TYPE]='A&E'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[OUTCOME_TYPE_CK2]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOME_GROUPS]'))
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS] CHECK CONSTRAINT [OUTCOME_TYPE_CK2]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CURRENT_LOOKUP_TABLE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES]  WITH NOCHECK ADD  CONSTRAINT [CURRENT_LOOKUP_TABLE_CK] CHECK  (([CURRENT_LOOKUP_TABLE] IS NOT NULL AND [CURRENT_VERSION] IS NOT NULL AND ([CURRENT_VALUE_1CHAR] IS NOT NULL OR [CURRENT_VALUE_2CHAR] IS NOT NULL OR [CURRENT_VALUE_3CHAR] IS NOT NULL OR [CURRENT_VALUE_4CHAR] IS NOT NULL OR [CURRENT_VALUE_5CHAR] IS NOT NULL) OR [CURRENT_LOOKUP_TABLE] IS NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CURRENT_LOOKUP_TABLE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES] CHECK CONSTRAINT [CURRENT_LOOKUP_TABLE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CURRENT_VALUE_NCHAR_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES]  WITH NOCHECK ADD  CONSTRAINT [CURRENT_VALUE_NCHAR_CK] CHECK  (([CURRENT_LOOKUP_TABLE] IS NOT NULL AND [CURRENT_VERSION] IS NOT NULL AND ([CURRENT_VALUE_1CHAR] IS NOT NULL AND [CURRENT_DESCRIPTION_1CHAR] IS NOT NULL OR [CURRENT_VALUE_2CHAR] IS NOT NULL AND [CURRENT_DESCRIPTION_2CHAR] IS NOT NULL OR [CURRENT_VALUE_3CHAR] IS NOT NULL AND [CURRENT_DESCRIPTION_3CHAR] IS NOT NULL OR [CURRENT_VALUE_4CHAR] IS NOT NULL AND [CURRENT_DESCRIPTION_4CHAR] IS NOT NULL OR [CURRENT_VALUE_5CHAR] IS NOT NULL AND [CURRENT_DESCRIPTION_5CHAR] IS NOT NULL) OR [CURRENT_LOOKUP_TABLE] IS NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CURRENT_VALUE_NCHAR_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES] CHECK CONSTRAINT [CURRENT_VALUE_NCHAR_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[OUTCOME_TYPE_CK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES]  WITH NOCHECK ADD  CONSTRAINT [OUTCOME_TYPE_CK1] CHECK  (([OUTCOME_TYPE]='BIRTHWEIGHT' OR [OUTCOME_TYPE]='OPCS' OR [OUTCOME_TYPE]='ICD-O' OR [OUTCOME_TYPE]='ICD' OR [OUTCOME_TYPE]='A&E'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[OUTCOME_TYPE_CK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES] CHECK CONSTRAINT [OUTCOME_TYPE_CK1]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[PREVIOUS_LOOKUP_TABLE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES]  WITH NOCHECK ADD  CONSTRAINT [PREVIOUS_LOOKUP_TABLE_CK] CHECK  (([PREVIOUS_LOOKUP_TABLE] IS NOT NULL AND [PREVIOUS_VERSION] IS NOT NULL AND ([PREVIOUS_VALUE_1CHAR] IS NOT NULL OR [PREVIOUS_VALUE_2CHAR] IS NOT NULL OR [PREVIOUS_VALUE_3CHAR] IS NOT NULL OR [PREVIOUS_VALUE_4CHAR] IS NOT NULL OR [PREVIOUS_VALUE_5CHAR] IS NOT NULL) OR [PREVIOUS_LOOKUP_TABLE] IS NULL AND [PREVIOUS_VERSION] IS NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[PREVIOUS_LOOKUP_TABLE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES] CHECK CONSTRAINT [PREVIOUS_LOOKUP_TABLE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[PREVIOUS_VALUE_NCHAR_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES]  WITH NOCHECK ADD  CONSTRAINT [PREVIOUS_VALUE_NCHAR_CK] CHECK  (([PREVIOUS_LOOKUP_TABLE] IS NOT NULL AND ([PREVIOUS_VALUE_1CHAR] IS NOT NULL AND [PREVIOUS_DESCRIPTION_1CHAR] IS NOT NULL OR [PREVIOUS_VALUE_2CHAR] IS NOT NULL AND [PREVIOUS_DESCRIPTION_2CHAR] IS NOT NULL OR [PREVIOUS_VALUE_3CHAR] IS NOT NULL AND [PREVIOUS_DESCRIPTION_3CHAR] IS NOT NULL OR [PREVIOUS_VALUE_4CHAR] IS NOT NULL AND [PREVIOUS_DESCRIPTION_4CHAR] IS NOT NULL OR [PREVIOUS_VALUE_5CHAR] IS NOT NULL AND [PREVIOUS_DESCRIPTION_5CHAR] IS NOT NULL) OR [PREVIOUS_LOOKUP_TABLE] IS NULL AND [PREVIOUS_VERSION] IS NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[PREVIOUS_VALUE_NCHAR_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_OUTCOMES]'))
ALTER TABLE [dbo].[RIF40_OUTCOMES] CHECK CONSTRAINT [PREVIOUS_VALUE_NCHAR_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[OUTCOME_TYPE_CK3]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_GROUPS]'))
ALTER TABLE [dbo].[RIF40_PREDEFINED_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [OUTCOME_TYPE_CK3] CHECK  (([OUTCOME_TYPE]='BIRTHWEIGHT' OR [OUTCOME_TYPE]='OPCS' OR [OUTCOME_TYPE]='ICD-O' OR [OUTCOME_TYPE]='ICD' OR [OUTCOME_TYPE]='A&E'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[OUTCOME_TYPE_CK3]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_PREDEFINED_GROUPS]'))
ALTER TABLE [dbo].[RIF40_PREDEFINED_GROUPS] CHECK CONSTRAINT [OUTCOME_TYPE_CK3]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ASG_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_ASG_CK] CHECK  (([AGE_SEX_GROUP_FIELD_NAME] IS NOT NULL AND [AGE_GROUP_FIELD_NAME] IS NULL AND [SEX_FIELD_NAME] IS NULL OR [AGE_SEX_GROUP_FIELD_NAME] IS NULL AND [AGE_GROUP_FIELD_NAME] IS NOT NULL AND [SEX_FIELD_NAME] IS NOT NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ASG_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_ASG_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_AUTOMATIC_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_AUTOMATIC_CK] CHECK  (([AUTOMATIC]=(0) OR [AUTOMATIC]=(1) AND [ISNUMERATOR]=(1) OR [AUTOMATIC]=(1) AND [ISINDIRECTDENOMINATOR]=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_AUTOMATIC_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_AUTOMATIC_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_EXCLUSIVE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_EXCLUSIVE_CK] CHECK  (([ISNUMERATOR]=(1) AND [ISDIRECTDENOMINATOR]=(0) AND [ISINDIRECTDENOMINATOR]=(0) OR [ISNUMERATOR]=(0) AND [ISDIRECTDENOMINATOR]=(1) AND [ISINDIRECTDENOMINATOR]=(0) OR [ISNUMERATOR]=(0) AND [ISDIRECTDENOMINATOR]=(0) AND [ISINDIRECTDENOMINATOR]=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_EXCLUSIVE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_EXCLUSIVE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ISDIRECTDENOM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_ISDIRECTDENOM_CK] CHECK  (([ISDIRECTDENOMINATOR]=(1) OR [ISDIRECTDENOMINATOR]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ISDIRECTDENOM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_ISDIRECTDENOM_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ISINDIRECTDENOM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_ISINDIRECTDENOM_CK] CHECK  (([ISINDIRECTDENOMINATOR]=(1) OR [ISINDIRECTDENOMINATOR]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ISINDIRECTDENOM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_ISINDIRECTDENOM_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ISNUMERATOR_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_ISNUMERATOR_CK] CHECK  (([ISNUMERATOR]=(1) OR [ISNUMERATOR]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_ISNUMERATOR_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_ISNUMERATOR_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_YEARS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_TAB_YEARS_CK] CHECK  (([YEAR_START]<=[YEAR_STOP]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[RIF40_TAB_YEARS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[RIF40_TABLES]'))
ALTER TABLE [dbo].[RIF40_TABLES] CHECK CONSTRAINT [RIF40_TAB_YEARS_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES_CK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]'))
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES]  WITH CHECK ADD  CONSTRAINT [T_RIF40_FDW_TABLES_CK1] CHECK  (([CREATE_STATUS]='N' OR [CREATE_STATUS]='E' OR [CREATE_STATUS]='C'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES_CK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]'))
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] CHECK CONSTRAINT [T_RIF40_FDW_TABLES_CK1]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES_CK2]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]'))
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES]  WITH CHECK ADD  CONSTRAINT [T_RIF40_FDW_TABLES_CK2] CHECK  (([ROWTEST_PASSED]=(1) OR [ROWTEST_PASSED]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES_CK2]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_FDW_TABLES]'))
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] CHECK CONSTRAINT [T_RIF40_FDW_TABLES_CK2]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_COMPAREA_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_GEOL_COMPAREA_CK] CHECK  (([COMPAREA]=(1) OR [COMPAREA]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_COMPAREA_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS] CHECK CONSTRAINT [T_RIF40_GEOL_COMPAREA_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_LISTING_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_GEOL_LISTING_CK] CHECK  (([LISTING]=(1) OR [LISTING]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_LISTING_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS] CHECK CONSTRAINT [T_RIF40_GEOL_LISTING_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_RESOLUTION_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_GEOL_RESOLUTION_CK] CHECK  (([RESOLUTION]=(1) OR [RESOLUTION]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_RESOLUTION_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS] CHECK CONSTRAINT [T_RIF40_GEOL_RESOLUTION_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_RESTRICTED_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_GEOL_RESTRICTED_CK] CHECK  (([RESTRICTED]=(1) OR [RESTRICTED]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOL_RESTRICTED_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_GEOLEVELS]'))
ALTER TABLE [dbo].[T_RIF40_GEOLEVELS] CHECK CONSTRAINT [T_RIF40_GEOL_RESTRICTED_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CLASS_BANDS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_CLASS_BANDS_CK] CHECK  (([CLASSIFIER_BANDS]>=(2) AND [CLASSIFIER_BANDS]<=(20)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CLASS_BANDS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_CLASS_BANDS_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CLASSIFIER_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_CLASSIFIER_CK] CHECK  (([CLASSIFIER]='UNIQUE_INTERVAL' OR [CLASSIFIER]='STANDARD_DEVIATION' OR [CLASSIFIER]='QUANTILE' OR [CLASSIFIER]='JENKS' OR [CLASSIFIER]='EQUAL_INTERVAL'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_CLASSIFIER_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_CLASSIFIER_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_GENDERS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_GENDERS_CK] CHECK  (([GENDERS]>=(1) AND [GENDERS]<=(3)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_GENDERS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_GENDERS_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_MH_TEST_TYPE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_MH_TEST_TYPE_CK] CHECK  (([MH_TEST_TYPE]='Unexposed Area' OR [MH_TEST_TYPE]='Comparison Areas' OR [MH_TEST_TYPE]='No Test'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_MH_TEST_TYPE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_MH_TEST_TYPE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_STATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_STATE_CK] CHECK  (([INVESTIGATION_STATE]='U' OR [INVESTIGATION_STATE]='R' OR [INVESTIGATION_STATE]='E' OR [INVESTIGATION_STATE]='V' OR [INVESTIGATION_STATE]='C'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_INV_STATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_INVESTIGATIONS]'))
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_STATE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_PROJECTS_DATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_PROJECTS]'))
ALTER TABLE [dbo].[T_RIF40_PROJECTS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_PROJECTS_DATE_CK] CHECK  (([DATE_ENDED] IS NULL OR [DATE_ENDED]>=[DATE_STARTED]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_PROJECTS_DATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_PROJECTS]'))
ALTER TABLE [dbo].[T_RIF40_PROJECTS] CHECK CONSTRAINT [T_RIF40_PROJECTS_DATE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RES_ADJUSTED_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS]  WITH CHECK ADD  CONSTRAINT [T_RIF40_RES_ADJUSTED_CK] CHECK  (([ADJUSTED]>=(0) AND [ADJUSTED]<=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RES_ADJUSTED_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS] CHECK CONSTRAINT [T_RIF40_RES_ADJUSTED_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RES_DIR_STAND_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS]  WITH CHECK ADD  CONSTRAINT [T_RIF40_RES_DIR_STAND_CK] CHECK  (([DIRECT_STANDARDISATION]>=(0) AND [DIRECT_STANDARDISATION]<=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RES_DIR_STAND_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS] CHECK CONSTRAINT [T_RIF40_RES_DIR_STAND_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS_GENDERS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS]  WITH CHECK ADD  CONSTRAINT [T_RIF40_RESULTS_GENDERS_CK] CHECK  (([GENDERS]>=(1) AND [GENDERS]<=(3)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS_GENDERS_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_RESULTS]'))
ALTER TABLE [dbo].[T_RIF40_RESULTS] CHECK CONSTRAINT [T_RIF40_RESULTS_GENDERS_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_EXTRACT_PERM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_EXTRACT_PERM_CK] CHECK  (([EXTRACT_PERMITTED]=(1) OR [EXTRACT_PERMITTED]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_EXTRACT_PERM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_EXTRACT_PERM_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_TRANSFER_PERM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_TRANSFER_PERM_CK] CHECK  (([TRANSFER_PERMITTED]=(1) OR [TRANSFER_PERMITTED]=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUD_TRANSFER_PERM_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_TRANSFER_PERM_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES_STUDY_STATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDIES_STUDY_STATE_CK] CHECK  (([STUDY_STATE]='U' OR [STUDY_STATE]='R' OR [STUDY_STATE]='E' OR [STUDY_STATE]='V' OR [STUDY_STATE]='C'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES_STUDY_STATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUDIES_STUDY_STATE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES_STUDY_TYPE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDIES_STUDY_TYPE_CK] CHECK  (([STUDY_TYPE]=(15) OR [STUDY_TYPE]=(14) OR [STUDY_TYPE]=(13) OR [STUDY_TYPE]=(12) OR [STUDY_TYPE]=(11) OR [STUDY_TYPE]=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES_STUDY_TYPE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDIES]'))
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUDIES_STUDY_TYPE_CK]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[STATEMENT_TYPE_CK2]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL]  WITH CHECK ADD  CONSTRAINT [STATEMENT_TYPE_CK2] CHECK  (([STATEMENT_TYPE]='DENOMINATOR_CHECK' OR [STATEMENT_TYPE]='NUMERATOR_CHECK' OR [STATEMENT_TYPE]='POST_INSERT' OR [STATEMENT_TYPE]='INSERT' OR [STATEMENT_TYPE]='CREATE'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[STATEMENT_TYPE_CK2]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL] CHECK CONSTRAINT [STATEMENT_TYPE_CK2]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[STATEMENT_TYPE_CK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG]  WITH CHECK ADD  CONSTRAINT [STATEMENT_TYPE_CK1] CHECK  (([STATEMENT_TYPE]='DENOMINATOR_CHECK' OR [STATEMENT_TYPE]='NUMERATOR_CHECK' OR [STATEMENT_TYPE]='POST_INSERT' OR [STATEMENT_TYPE]='INSERT' OR [STATEMENT_TYPE]='CREATE'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[STATEMENT_TYPE_CK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_STUDY_SQL_LOG]'))
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG] CHECK CONSTRAINT [STATEMENT_TYPE_CK1]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS_DATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS]'))
ALTER TABLE [dbo].[T_RIF40_USER_PROJECTS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_USER_PROJECTS_DATE_CK] CHECK  (([REVOKE_DATE] IS NULL OR [REVOKE_DATE]>[GRANT_DATE]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS_DATE_CK]') AND parent_object_id = OBJECT_ID(N'[dbo].[T_RIF40_USER_PROJECTS]'))
ALTER TABLE [dbo].[T_RIF40_USER_PROJECTS] CHECK CONSTRAINT [T_RIF40_USER_PROJECTS_DATE_CK]
GO
USE [master]
GO
ALTER DATABASE [RIF40] SET  READ_WRITE 
GO
