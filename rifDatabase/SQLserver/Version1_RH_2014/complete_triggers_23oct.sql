
---------------------------------------------------------------------------------------------------
/****** Object:  Trigger [tr_covariates_check]    Script Date: 23/10/2014 11:50:16 ******/

---------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------
--trigger_covariate
------------------------------------------
--Check <T_RIF40_GEOLEVELS.COVARIATE_TABLE>.<COVARIATE_NAME> column exists.
--Check - min < max, max/min precison is appropriate to type --NEED TO TEST THIS
-- eror msgs -- 50010 - 50014



-------------------------------------
-- start of trigger code
-------------------------------------
CREATE TRIGGER [tr_covariates_check]
on [RIF40_COVARIATES]
for insert ,update 
as 
SET XACT_ABORT off
begin
--------------------------------
-- MIN value is greater than MAX
--------------------------------
DECLARE @min NVARCHAR(MAX)= 
( 
 SELECT cast(min as varchar(20)) , ':' ,covariate_name + '  '
 FROM   inserted  
 WHERE   min>=max 
 FOR XML PATH('') 
);
BEGIN TRY
IF @min IS NOT NULL 
	BEGIN 
		RAISERROR(50010,16,1,@min); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-----------------------------------
-- Type is 1 and MAX is not INT
-----------------------------------
DECLARE @type NVARCHAR(MAX)= --- NEED TO TEST THIS : type field has acheck constraint
( 
 SELECT cast(max as varchar(20)), ':' ,covariate_name + '  '
 FROM   inserted  
 WHERE   type=1 and round(max,0)<>max 
 FOR XML PATH('') 
); 
BEGIN TRY
IF @type IS NOT NULL 
	BEGIN 
		raiserror(50011,16,1,@type); 
		rollback
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-----------------------------------
-- Type is 1 and MIN is not INT
-----------------------------------	
DECLARE @type2 NVARCHAR(MAX)= --- NEED TO TEST THIS : type field has acheck constraint
( 
 SELECT cast(min as varchar(20)), ':' ,covariate_name + '  '
 FROM   inserted  
 WHERE   type=1 and round(min,0)<>min -- DID IT WORK ?
 FOR XML PATH('') 
); 
BEGIN TRY
IF @type2 IS NOT NULL 
	BEGIN 
		raiserror(50012,16,1,@type2); 
		rollback
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-----------------------------------
-- Type is 1 and MIN <0
-----------------------------------
DECLARE @type3 NVARCHAR(MAX)= --- NEED TO TEST THIS : type field has a check constraint
( 
 SELECT min ,geolevel_name, ':' ,covariate_name + '  '
 FROM   inserted  
 WHERE   type=1 and min<0 
 FOR XML PATH('') 
); 
BEGIN TRY
IF @type3 IS NOT NULL 
	BEGIN 
		raiserror(50013,16,1,@type3); 
		rollback
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
---------------------------------------------------------------------------------
--Check <T_RIF40_GEOLEVELS.COVARIATE_TABLE>.<COVARIATE_NAME> column exists.
---------------------------------------------------------------------------------

DECLARE @covar_name NVARCHAR(MAX)= 
( 
 SELECT covariate_name + ' , '
 FROM   inserted  
 WHERE  covariate_name in (select covariate_name from T_RIF40_GEOLEVELS)
 FOR XML PATH('') 
); 
BEGIN TRY
IF @covar_name IS NOT NULL 
	BEGIN 
		raiserror(50014,16,1,@covar_name); 
		rollback 
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
END

GO
/****** Object:  Trigger [tr_error_msg_checks]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create trigger [tr_error_msg_checks]
  on  [RIF40_ERROR_MESSAGES]
  for insert , update 
  as
  begin
	 DECLARE @tablelist nvarchar(MAX) =
    (
    SELECT 
		[TABLE_NAME] + ', '
        FROM inserted
        WHERE OBJECT_ID([TABLE_NAME], 'U') IS NULL
        FOR XML PATH('')
    );

	IF @tablelist IS NOT NULL
	BEGIN
		RAISERROR('These table/s do not exist: %s', 16, 1, @tablelist) with log;
	END;
  
 end 
GO
/****** Object:  Trigger [tr_GEOGRAPHY]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------
--create trigger code 
---------------------------------------

-- Check postal_population_table if set and expected columns
-- Check HIERARCHYTABLE exists.
-- Error msg 50020 - 50027

CREATE trigger [tr_GEOGRAPHY]
on [RIF40_GEOGRAPHIES]
instead of insert, update
as
begin
DECLARE @HIERARCHYTABLE nvarchar(MAX) =
    (
    SELECT 
		HIERARCHYTABLE + ', '
        FROM inserted
        WHERE OBJECT_ID(HIERARCHYTABLE, 'U') IS NULL
        FOR XML PATH('')
    );
BEGIN TRY
IF @HIERARCHYTABLE IS NOT NULL
	BEGIN
		RAISERROR(50020, 16, 1, @HIERARCHYTABLE) with log;
		ROLLBACK
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
--Check postal_population_table if set and expected columns-- 

DECLARE @postal_pop nvarchar(MAX) =
    (
    SELECT 
		postal_population_table + ', '
        FROM inserted
        WHERE OBJECT_ID(postal_population_table, 'U') IS NULL
        FOR XML PATH('')
    );
BEGIN TRY 
IF @postal_pop IS NOT NULL
	BEGIN
		RAISERROR(50021, 16, 1, @postal_pop) with log;
		ROLLBACK
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
--Check postal_population_column 

DECLARE @postal_point_col nvarchar(MAX) =
(
	SELECT concat (postal_population_table,'-', postal_point_column )
		 + '  '
		FROM inserted  ic 
		where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.POSTAL_POPULATION_TABLE and c.name=ic.POSTAL_POINT_COLUMN )
   FOR XML PATH('')

);
BEGIN TRY 
IF @postal_point_col IS NOT NULL
	BEGIN
		RAISERROR(50022, 16, 1, @postal_point_col) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
--check column names MALES , FEMALES , TOTAL, XCOORDINATE, YCOORDINATE 
DECLARE @MALES nvarchar(MAX) =
(
	SELECT postal_population_table 
		 + '  '
		FROM inserted  ic 
		where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.POSTAL_POPULATION_TABLE and c.name='MALES' )
   FOR XML PATH('')

);
BEGIN TRY
IF @MALES IS NOT NULL
	BEGIN
		RAISERROR(50023, 16, 1, @MALES) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

--CHECK females 
DECLARE @FEMALES nvarchar(MAX) =
(
	SELECT postal_population_table 
		 + '  '
		FROM inserted  ic 
		where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.POSTAL_POPULATION_TABLE and c.name='FEMALES' )
   FOR XML PATH('')

);
BEGIN TRY 
IF @FEMALES IS NOT NULL
	BEGIN
		RAISERROR(50024, 16, 1, @FEMALES) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
--CHECK TOTAL 
DECLARE @TOTAL nvarchar(MAX) =
(
	SELECT postal_population_table 
		 + '  '
		FROM inserted  ic 
		where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.POSTAL_POPULATION_TABLE and c.name='TOTAL' )
   FOR XML PATH('')

);
BEGIN TRY 
IF @TOTAL IS NOT NULL
	BEGIN
		RAISERROR(50025, 16, 1, @TOTAL) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

--XCOORDINATE

DECLARE @XCOORDINATE nvarchar(MAX) =
(
	SELECT postal_population_table 
		 + '  '
		FROM inserted  ic 
		where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.POSTAL_POPULATION_TABLE and c.name='XCOORDINATE' )
   FOR XML PATH('')

);
BEGIN TRY 
IF @XCOORDINATE IS NOT NULL
	BEGIN
		RAISERROR(50026, 16, 1, @XCOORDINATE) with log;
		ROLLBACK
	END;
END TRY 

BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

--YCOORDINATE

DECLARE @YCOORDINATE nvarchar(MAX) =
(
	SELECT postal_population_table 
		 + '  '
		FROM inserted  ic 
		where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.POSTAL_POPULATION_TABLE and c.name='YCOORDINATE' )
   FOR XML PATH('')

);
BEGIN TRY 
IF @YCOORDINATE IS NOT NULL
	BEGIN
		RAISERROR(50027, 16, 1, @YCOORDINATE) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
END

GO
/****** Object:  Trigger [tr_study_outcome_check]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_study_outcome_check]
on [RIF40_OUTCOMES]
instead of insert, update
as
begin

--Check current_lookup table exists
DECLARE @tablelist nvarchar(MAX) =
    (
    SELECT 
        CURRENT_LOOKUP_TABLE + ' '
        FROM inserted
        WHERE OBJECT_ID(CURRENT_LOOKUP_TABLE, 'U') IS NULL
        FOR XML PATH('')
    );

IF @tablelist IS NOT NULL
BEGIN
    RAISERROR(50200, 16, 1, @tablelist) with log;
END;
--Check previous lookup table exists if NOT NULL
 IF exists ( select 1 from inserted where [PREVIOUS_LOOKUP_TABLE] IS NOT NULL) or 
	   ( UPDATE([PREVIOUS_LOOKUP_TABLE]))
	begin
	   DECLARE @prevtablelist nvarchar(MAX) =
		(
		 SELECT 
        [PREVIOUS_LOOKUP_TABLE] + ' '
        FROM inserted
        WHERE OBJECT_ID([PREVIOUS_LOOKUP_TABLE], 'U') IS NULL
        FOR XML PATH('')
		 );

IF @prevtablelist IS NOT NULL
BEGIN
    RAISERROR(50201, 16, 1, @prevtablelist) with log;
END;
	   end 
END 
GO
/****** Object:  Trigger [tr_STUDY_SHARES]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_STUDY_SHARES]
on [RIF40_STUDY_SHARES]
for insert , update 
as

begin
--------------------------------------
--to  Determine the type of transaction 
---------------------------------------
Declare  @xtype varchar(5)

	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @XTYPE = 'D'
	END
	IF EXISTS (SELECT * FROM INSERTED)
		BEGIN
			IF (@XTYPE = 'D')
		BEGIN
			SET @XTYPE = 'U'
		END
	ELSE
		BEGIN
			SET @XTYPE = 'I'
		END
------------------------------------------------
--When Transaction is an Update  then rollback 
-------------------------------------------------
	IF (@XTYPE = 'U')
		BEGIN
		 	Raiserror (50081, 16,1 );
			rollback tran
		  end 
END
-- STUDY NOT FOUND 
	DECLARE @study nvarchar(MAX) =
		(
		SELECT 
			STUDY_ID + ', '
			FROM inserted
			WHERE study_id NOT in (select STUDY_ID from  t_rif40_studies)
			FOR XML PATH('')
		);
	BEGIN TRY 
		IF @study IS NOT NULL
		BEGIN
			RAISERROR(50082, 16, 1, @study) with log;
		END;
	END TRY 
	BEGIN CATCH
			EXEC [ErrorLog_proc]
	END CATCH 

-- Grantor is NOT owner of the study
DECLARE @GRANTOR nvarchar(MAX) =
		(
		SELECT 
			USERNAME + ', '
			FROM t_rif40_studies
			WHERE study_id in (select STUDY_ID from  INSERTED )
			AND USERNAME not IN (SELECT GRANTOR FROM inserted)
			FOR XML PATH('')
		);
	BEGIN TRY 
		IF @GRANTOR IS NOT NULL
		BEGIN
			RAISERROR(50083, 16, 1, @GRANTOR) with log;
		END;
	END TRY 
	BEGIN CATCH
			EXEC [ErrorLog_proc]
	END CATCH 
END  
GO
/****** Object:  Trigger [TR_TABLE_OUTCOME]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE TRIGGER [TR_TABLE_OUTCOME]
 ON [RIF40_TABLE_OUTCOMES]
 FOR INSERT ,  UPDATE 
 AS
 BEGIN 

 DECLARE @table  nvarchar(MAX) =
		(
		SELECT 
        concat(a.OUTCOME_GROUP_NAME , a.numer_tab)+ ' '
		FROM inserted a
        where a.NUMER_TAB not in (select TABLE_NAME from rif40_tables )
		
        FOR XML PATH('')
		 );

IF @table is NOT NULL
BEGIN
    RAISERROR('table does not exist %s', 16, 1, @table) with log;
END;

 -------check current start year  

	   DECLARE @STARTYEAR nvarchar(MAX) =
		(
		SELECT 
        concat(a.OUTCOME_GROUP_NAME , a.[CURRENT_VERSION_START_YEAR])+ ' '
		FROM inserted a
		inner join rif40_tables b
        on a.NUMER_TAB=b.TABLE_NAME
		where a.CURRENT_VERSION_START_YEAR between b.YEAR_START and b.YEAR_STOP and a.CURRENT_VERSION_START_YEAR is not null 
        FOR XML PATH('')
		 );

IF @STARTYEAR is NOT NULL
BEGIN
    RAISERROR('Current version start date didnt match for %s', 16, 1, @STARTYEAR) with log;
END;
END 




GO
/****** Object:  Trigger [tr_version]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  trigger [tr_version]
on [RIF40_VERSION]
for insert , update ,delete 
As
Begin

-- Determine the type of transaction 
Declare  @xtype varchar(5)

	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @XTYPE = 'D'
	END
	IF EXISTS (SELECT * FROM INSERTED)
		BEGIN
			IF (@XTYPE = 'D')
		BEGIN
			SET @XTYPE = 'U'
		END
	ELSE
		BEGIN
			SET @XTYPE = 'I'
		END
--When Transaction is an insert 
	IF (@XTYPE = 'I')
		BEGIN
		  if (SELECT COUNT(*) total FROM rif40_version) > 0 
		  begin 
			Raiserror ('Error: RIF40_VERSION INSERT disallowed', 16,1 );
			rollback tran
		  end 
		END
--When Transaction is a delete  
    IF (@XTYPE = 'D')
		begin
			raiserror( 'Error: RIF40_VERSION DELETE disallowed',16,1)
			rollback tran
		end 
   End 
 end 



GO
/****** Object:  Trigger [tr_CONTEXTUAL_STATS]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_CONTEXTUAL_STATS]
on [T_RIF40_CONTEXTUAL_STATS]
for insert, update 
as

Declare  @xtype varchar(5)

	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @XTYPE = 'D'
	END
	IF EXISTS (SELECT * FROM INSERTED)
		BEGIN
			IF (@XTYPE = 'D')
		BEGIN
			SET @XTYPE = 'U'
		END
	ELSE
		BEGIN
			SET @XTYPE = 'I'
		END
------------------------------------------------
--When Transaction is an Update  then rollback 
-------------------------------------------------
	IF (@XTYPE = 'U')
		BEGIN
		 	Raiserror (50088, 16,1 );
			rollback tran
		  end 

--Entered username is not current user 
DECLARE @user nvarchar(MAX) =
    (
    SELECT 
		USERNAME + ', '
        FROM inserted
        WHERE username <> SUSER_SNAME() 
        FOR XML PATH('')
    );
BEGIN TRY 
	IF @user IS NOT NULL
	BEGIN
		RAISERROR(50089, 16, 1, @user) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

--Delete allowed on own record only 
	DECLARE @user2 nvarchar(MAX) =
    (
    SELECT 
		USERNAME + ', '
        FROM deleted
        WHERE username not in (select username from inserted)
        FOR XML PATH('')
    );
BEGIN TRY 
	IF @user2 IS NOT NULL and  @XTYPE = 'D'
	BEGIN
		RAISERROR(50090, 16, 1, @user) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
END

GO
/****** Object:  Trigger [tr_geolevel_check]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_geolevel_check]
on [T_RIF40_GEOLEVELS]
instead of insert, update
as
begin

-- check covariate table
DECLARE @covariatetablelist nvarchar(MAX) =
    (
    SELECT 
		[COVARIATE_TABLE] + ', '
        FROM inserted
        WHERE OBJECT_ID([COVARIATE_TABLE], 'U') IS NULL
        FOR XML PATH('')
    );
BEGIN TRY 
	IF @covariatetablelist IS NOT NULL
	BEGIN
		RAISERROR(50040, 16, 1, @covariatetablelist) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

-- check geolevel name 
DECLARE @geolevelname NVARCHAR(MAX)= 
( 
 SELECT [GEOLEVEL_NAME] + ' , '
 FROM   inserted  
 WHERE   GEOLEVEL_NAME NOT IN (SELECT GEOLEVEL_NAME FROM [RIF40_COVARIATES])
 FOR XML PATH('') 
); 
BEGIN TRY 
IF @geolevelname IS NOT NULL 
	BEGIN 
		RAISERROR(50041,16,1,@geolevelname); 
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-- check covariate table YEAR column  	
DECLARE @covariatetablelist2 nvarchar(MAX) =
    (
	select [COVARIATE_TABLE]
	from inserted ic 
   	where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.COVARIATE_TABLE and c.name='YEAR' )
    );
BEGIN TRY  
	IF @covariatetablelist2 IS NOT NULL
	BEGIN
		RAISERROR(50042, 16, 1, @covariatetablelist2) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
---CHECK GEOLEVEL name exists in covariate table 
DECLARE @covariatetablelist3 nvarchar(MAX) =
    (
	select [COVARIATE_TABLE]
	from inserted ic 
   	where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.COVARIATE_TABLE and c.name=ic.GEOLEVEL_NAME )
    );
BEGIN TRY  
	IF @covariatetablelist3 IS NOT NULL
	BEGIN
		RAISERROR(50043, 16, 1, @covariatetablelist3) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-------------------------
--check lookup table 
-------------------------
DECLARE @lookuptablelist nvarchar(MAX) =
    (
    SELECT 
		LOOKUP_TABLE + ', '
        FROM inserted
        WHERE OBJECT_ID(LOOKUP_TABLE, 'U') IS NULL
        FOR XML PATH('')
    );
BEGIN TRY 
	IF @lookuptablelist IS NOT NULL
	BEGIN
		RAISERROR(50044, 16, 1, @lookuptablelist) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-----------------------------------
-- check lookup table x-cord 
-----------------------------------
DECLARE @lookuptablelist2  nvarchar(MAX) =
    (
	select LOOKUP_TABLE
	from inserted ic 
   	where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.LOOKUP_TABLE and c.name=ic.CENTROIDXCOORDINATE_COLUMN )
    );
BEGIN TRY  
	IF @lookuptablelist2 IS NOT NULL
	BEGIN
		RAISERROR(50045, 16, 1, @lookuptablelist2) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
-----------------------------------
-- check lookup table y-cord 
-----------------------------------
DECLARE @lookuptablelist3  nvarchar(MAX) =
    (
	select LOOKUP_TABLE
	from inserted ic 
   	where not EXISTS (SELECT 1  
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =ic.LOOKUP_TABLE and c.name=ic.CENTROIDYCOORDINATE_COLUMN )
    );
BEGIN TRY  
	IF @lookuptablelist3 IS NOT NULL
	BEGIN
		RAISERROR(50046, 16, 1, @lookuptablelist3) with log;
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 	
-- Check &lt;postal_population_table&gt;.&lt;GEOLEVEL_NAME&gt; column exists if POSTAL_POPULATION_TABLE set if RIF40_GEOGAPHIES

DECLARE @TABLE_NAMES table 
(
ID INT IDENTITY(1,1), Name VARCHAR(255)
)

INSERT INTO @TABLE_NAMES (Name)
select distinct B.POSTAL_POPULATION_TABLE 
		from inserted  a
		left outer join RIF40_GEOGRAPHIES b
		on a.GEOGRAPHY=b.GEOGRAPHY
		where	b.POSTAL_POPULATION_TABLE is not null and --TO CLARIFY THIS LOGIC WITH PH 
				(a.CENTROIDXCOORDINATE_COLUMN is not null and a.CENTROIDYCOORDINATE_COLUMN is not null) OR
				a.CENTROIDSFILE is not null 

DECLARE @TABLE_NAMES2 nvarchar(MAX) =
(
SELECT name + ' '
FROM @TABLE_NAMES
where OBJECT_ID(Name) is null 
FOR XML PATH('') 
)
BEGIN TRY 
	if @TABLE_NAMES2 is not null 
	begin 
	raiserror ('Table/s do not exist: %s' ,16,1, @TABLE_NAMES2)
	end 
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

END  
GO
/****** Object:  Trigger [tr_inv_covariate]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_inv_covariate]
 on [T_RIF40_INV_COVARIATES]
 for insert, update 
 as
 begin 

 Declare  @xtype varchar(5)
 	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @XTYPE = 'D'
	END
	IF EXISTS (SELECT * FROM INSERTED)
		BEGIN
			IF (@XTYPE = 'D')
		BEGIN
			SET @XTYPE = 'U'
		END
	ELSE
		BEGIN
			SET @XTYPE = 'I'
		END
------------------------------------------------
--When Transaction is an Update  then rollback 
-------------------------------------------------
	IF (@XTYPE = 'U')
		BEGIN
		 	Raiserror (50091, 16,1 );
			rollback tran
		  end 
END


 ----------------------------------------
 -- check covariates : if min< expected 
 ----------------------------------------
	 DECLARE @min nvarchar(MAX) =
		(
		SELECT 
        cast(ic.[min] as varchar(20))+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].rif40_covariates c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  c.covariate_name=ic.covariate_name and -- can comment it out to test 
			  ic.[min]<c.[min])
        FOR XML PATH('')
		 );

	IF @min IS NOT NULL
		BEGIN
			RAISERROR(50092, 16, 1, @min) with log;
		END;
-----------------------------------------
-- check covariates --if max> expected 
-----------------------------------------
 DECLARE @max nvarchar(MAX) =
		(
		SELECT 
        cast(ic.[max] as varchar(20))+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].rif40_covariates c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  c.covariate_name=ic.covariate_name and -- can comment it out to test 
			  ic.[max]>c.[max])
        FOR XML PATH('')
		 );

	IF @max IS NOT NULL
		BEGIN
			RAISERROR(50093, 16, 1, @max) with log;
		END;


-------------------------------
----Remove when supported
--------------------------------
 DECLARE @type2 nvarchar(MAX) =
		(
		SELECT 
        [STUDY_ID]+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].rif40_covariates c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  c.covariate_name=ic.covariate_name and -- can comment it out to test 
			  c.type =2)
        FOR XML PATH('')
		 );

	IF @type2 IS NOT NULL
		BEGIN
			RAISERROR(50094, 16, 1,@type2 ) with log;
		END;


 DECLARE @type1 nvarchar(MAX) =
		(
		SELECT 
        [STUDY_ID]+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].rif40_covariates c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  c.covariate_name=ic.covariate_name and -- can comment it out to test 
			  c.type =1 and 
			  ic.MAX <> round(ic.MAX,0))
        FOR XML PATH('')
		 );

	IF @type1 IS NOT NULL
		BEGIN
			RAISERROR(50095, 16, 1,@type1 ) with log;
		END;

 DECLARE @type1b nvarchar(MAX) =
		(
		SELECT 
        [STUDY_ID]+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].rif40_covariates c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  c.covariate_name=ic.covariate_name and -- can comment it out to test 
			  c.type =1 and 
			  ic.MIN<> round(ic.MIN,0))
        FOR XML PATH('')
		 );

	IF @type1b IS NOT NULL
		BEGIN
			RAISERROR(50096, 16, 1,@type1b ) with log;
		END;

 DECLARE @type1_min nvarchar(MAX) =
		(
		SELECT 
        [STUDY_ID]+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].rif40_covariates c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  c.covariate_name=ic.covariate_name and -- can comment it out to test 
			  c.type =1 and 
			  ic.MIN<0)
        FOR XML PATH('')
		 );

	IF @type1_min IS NOT NULL
		BEGIN
			RAISERROR(50097, 16, 1,@type1_min ) with log;
		END;
-------------------------------
--Check - study_geolevel_name.
-------------------------------

DECLARE @study_geolevel_nm nvarchar(MAX) =
		(
		SELECT 
        [STUDY_GEOLEVEL_NAME]+ ' '
		FROM inserted ic 
		where EXISTS (SELECT 1 FROM [dbo].[T_RIF40_GEOLEVELS] c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
			  c.geolevel_name=ic.study_geolevel_name and
			  ic.STUDY_GEOLEVEL_NAME is not Null 
					)
        FOR XML PATH('')
		 );

	IF @study_geolevel_nm IS NOT NULL
		BEGIN
			RAISERROR(50098, 16, 1, @study_geolevel_nm) with log;
		END;

end

GO
/****** Object:  Trigger [tr_investigations]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [tr_investigations]
on [T_RIF40_INVESTIGATIONS]
for insert , update 
as
begin 
declare @investigation_state_only_flag int -- MIGHT NOT WORK FOR BATCH INSERTS 
	IF exists (
			select ic.username  
		    from inserted ic , [T_RIF40_INVESTIGATIONS] iv
			where   ic.username= iv.username AND
 					ic.inv_name = iv.inv_name AND
 					ic.inv_description = iv.inv_description AND
 					ic.year_start = iv.year_start AND
 					ic.year_stop = iv.year_stop AND
 					ic.max_age_group = iv.max_age_group AND
 					ic.min_age_group = iv.min_age_group AND
 					ic.genders = iv.genders AND
 					ic.numer_tab = iv.numer_tab AND
 					ic.geography = iv.geography AND
 					ic.study_id = iv.study_id AND
 					ic.inv_id = iv.inv_id AND
 					ic.classifier = iv.classifier AND
 					ic.classifier_bands = iv.classifier_bands AND
 					ic.mh_test_type = iv.mh_test_type  AND
 					ic.investigation_state <> iv.investigation_state
					) 
			begin 
				set @investigation_state_only_flag = 1
			end 


	-- this needs instread of trigger
	--INSERT MyTable(col1, [other columns])
 --   SELECT UPPER(i.col1)
 --       , i.[other columns]
 --   FROM Inserted i

-----------------------------
---define #t2
-----------------------------
select t.*
into #t2
from #t1 t
inner join  inserted ic 
on t.TABLE_NAME = ic.NUMER_TAB


-----------------------------
---define #t3
-----------------------------
select t.*
into #t3
from [dbo].[T_RIF40_STUDIES] s 
inner join inserted ic 
on s.STUDY_ID=ic.STUDY_ID
inner join #t1 t
on s.DENOM_TAB = t.TABLE_NAME


-----------------------------
---define #t4
-----------------------------
select t.*
into #t4
from [dbo].[T_RIF40_STUDIES] s 
inner join inserted  ic 
on s.STUDY_ID=ic.STUDY_ID
inner join #t1 t
on s.DIRECT_STAND_TAB = t.TABLE_NAME

DECLARE @numer_tab NVARCHAR(MAX)= 
( 
SELECT TABLE_NAME
FROM	rif40_tables a 
WHERE	table_name in (select [NUMER_TAB] from [dbo].[T_RIF40_INVESTIGATIONS] where ISNUMERATOR <>1)
 FOR XML PATH('') 
);
BEGIN TRY
IF @numer_tab IS NOT NULL 
	BEGIN 
		RAISERROR(50050,16,1,@numer_tab); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

-----------------------
--year start
-----------------------
DECLARE @year_start NVARCHAR(MAX)= 
( 
SELECT concat(TABLE_NAME ,' / ', b.YEAR_START)  + ' , '
FROM	rif40_tables a 
inner join [dbo].[T_RIF40_INVESTIGATIONS] b
on a.TABLE_NAME=b.NUMER_TAB
where b.YEAR_START is not null and 
b.YEAR_START < a.YEAR_START
 FOR XML PATH('') 
);
BEGIN TRY
IF @year_start IS NOT NULL 
	BEGIN 
		RAISERROR(50051,16,1,@year_start); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 


-----------------------
--year stop
-----------------------
DECLARE @year_stop NVARCHAR(MAX)= 
( 
SELECT concat(TABLE_NAME ,' / ', b.YEAR_STOP)  + ' , '
FROM	rif40_tables a 
inner join [dbo].[T_RIF40_INVESTIGATIONS] b
on a.TABLE_NAME=b.NUMER_TAB
where b.YEAR_START is not null and 
b.YEAR_START > a.YEAR_STOP
 FOR XML PATH('') 
);
BEGIN TRY
IF @year_stop IS NOT NULL 
	BEGIN 
		RAISERROR(50052,16,1,@year_stop); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

---------------
-- MIN AGE 
---------------

SELECT a.table_name, a.year_start, a.year_stop, a.isindirectdenominator, a.isdirectdenominator, a.isnumerator,
	   a.age_sex_group_field_name, a.sex_field_name, a.age_group_field_name, a.total_field, a.AGE_GROUP_ID,
       MIN(g.offset) min_age_group, MAX(g.offset) max_age_group
into #t1
FROM rif40_tables a
LEFT OUTER JOIN rif40_age_groups g ON (g.age_group_id  = a.age_group_id)
--WHERE table_name = 'UK91_DEATHS'
GROUP BY a.year_start, a.year_stop, a.isindirectdenominator, a.isdirectdenominator, a.isnumerator,
		 a.age_sex_group_field_name, a.sex_field_name, a.age_group_field_name, a.total_field,a.table_name , a.AGE_GROUP_ID


DECLARE @min_age NVARCHAR(MAX)= 
( 
select * from #t1 a 
inner join [dbo].[T_RIF40_INVESTIGATIONS] b 
on a.table_name = b.numer_tab and 
a.min_age_group is not null and
b.MIN_AGE_GROUP<a.min_age_group
 FOR XML PATH('') 
)
BEGIN TRY
IF @min_age IS NOT NULL 
	BEGIN 
		RAISERROR(50053,16,1,@min_age); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

---------------
-- Max AGE 
---------------
DECLARE @no_age_group NVARCHAR(MAX)= 
( 
select concat(a.min_age_group ,' / ', a.max_age_group)  + ' , '
from #t1 a 
inner join [dbo].[T_RIF40_INVESTIGATIONS] b 
on a.table_name = b.numer_tab and 
a.max_age_group is  null or
a.min_age_group is  null 
 FOR XML PATH('') 
)
BEGIN TRY
IF @no_age_group IS NOT NULL 
	BEGIN 
		RAISERROR(50054,16,1,@no_age_group); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

-----------------------------------------------
--min >max age group: just for inserted table 
--------------------- --------------------------
DECLARE @min_max NVARCHAR(MAX)= 
( 
select a.min_age_group + ' , '
from inserted a 
where a.min_age_group> a.max_age_group
FOR XML PATH('') 
)
BEGIN TRY
IF @min_max IS NOT NULL 
	BEGIN 
		RAISERROR(50055,16,1,@min_max); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

-----------------------------------------------
--year start > year stop : just for inserted table 
--------------------- --------------------------
DECLARE @year NVARCHAR(MAX)= 
( 
select a.YEAR_START + ' , '
from inserted a 
where a.YEAR_START> a.YEAR_STOP
FOR XML PATH('') 
)
BEGIN TRY
IF @year IS NOT NULL 
	BEGIN 
		RAISERROR(50055,16,1,@year); 
		rollback 
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

--------------------------------
-- verify column existence  
----------------------------------

DECLARE @sex_field_name nvarchar(MAX) =
(
	select a.SEX_FIELD_NAME+ ' , '
	from #t1 a
	inner join inserted b
	on a.TABLE_NAME=b.NUMER_TAB 
	where a.SEX_FIELD_NAME is not null and 
	a.SEX_FIELD_NAME not in (SELECT c.name 
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =b.NUMER_TAB)
   FOR XML PATH('')

);
BEGIN TRY 
IF @sex_field_name IS NOT NULL
	BEGIN
		RAISERROR(50057, 16, 1, @sex_field_name) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 


DECLARE @age_group_field_name nvarchar(MAX) =
(
	select a.AGE_GROUP_FIELD_NAME+ ' , '
	from #t1 a
	inner join inserted b
	on a.TABLE_NAME=b.NUMER_TAB 
	where a.SEX_FIELD_NAME is not null and 
	a.AGE_GROUP_FIELD_NAME not in (SELECT c.name 
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =b.NUMER_TAB)
   FOR XML PATH('')

);
BEGIN TRY 
IF @age_group_field_name IS NOT NULL
	BEGIN
		RAISERROR(50058, 16, 1, @age_group_field_name) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 


DECLARE @age_sex_group_field_name nvarchar(MAX) =
(
	select a.AGE_SEX_GROUP_FIELD_NAME+ ' , '
	from #t1 a
	inner join inserted b
	on a.TABLE_NAME=b.NUMER_TAB 
	where a.SEX_FIELD_NAME is not null and 
	a.AGE_SEX_GROUP_FIELD_NAME not in (SELECT c.name 
							from sys.columns c 
							inner join  sys.tables t 
							on c.object_id=t.object_id 
							where t.name =b.NUMER_TAB)
   FOR XML PATH('')

);
BEGIN TRY 
IF @age_sex_group_field_name IS NOT NULL
	BEGIN
		RAISERROR(50059, 16, 1, @age_sex_group_field_name) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 


--#t2 = c1a_rec
--#t3 = c1b_rec
--#t4 = c1c_rec


-------------------------------------------------------------
-- verify field names are the same : batch insert wont work 
-------------------------------------------------------------
DECLARE @age_group_id nvarchar(MAX) =
(
	select t.AGE_GROUP_ID
	from #t1 t 
	where t.AGE_GROUP_ID <> (select t2.AGE_GROUP_ID from #t2 t2 ) or 
	t.AGE_GROUP_ID <> (select t3.AGE_GROUP_ID from #t3 t3)
	FOR XML PATH('')

);
BEGIN TRY 
IF @age_group_id IS NOT NULL
	BEGIN
		RAISERROR(50060, 16, 1, @age_group_id) with log;
		ROLLBACK
	END;
END TRY 
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 

end 
GO
/****** Object:  Trigger [tr_num_denom]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_num_denom]
  on [T_RIF40_NUM_DENOM]
  for insert , update
  as
  begin 

  -- check numerator table 
  DECLARE @num nvarchar(MAX) =
    (
    SELECT 
		[NUMERATOR_TABLE] + ', '
        FROM inserted ic 
        WHERE [NUMERATOR_TABLE] NOT in  (select TABLE_NAME from rif40_tables)
        FOR XML PATH('')
    );
	IF @num IS NOT NULL
		BEGIN
			RAISERROR(50075, 16, 1, @num) with log;
		END;

 --- check isnumerator status for numerator tables  
   DECLARE @num_status  nvarchar(MAX) =
    (
    SELECT 
		[NUMERATOR_TABLE] + ', '
        FROM inserted ic 
        WHERE [NUMERATOR_TABLE] IN (select TABLE_NAME from rif40_tables where ISNUMERATOR <>1) 
		FOR XML PATH('')
    );
	IF @num_status IS NOT NULL
		BEGIN
			RAISERROR(50076, 16, 1, @num_status) with log;
		END;
 -- check denominator table  
   DECLARE @dnom nvarchar(MAX) =
    (
    SELECT 
		DENOMINATOR_TABLE + ', '
        FROM inserted ic 
        WHERE DENOMINATOR_TABLE not in  (select TABLE_NAME from rif40_tables)
        FOR XML PATH('')
    );
	IF @dnom IS NOT NULL
		BEGIN
			RAISERROR(50077, 16, 1, @dnom) with log;
		END;
	-- check denominator status table 
	 DECLARE @denom_status  nvarchar(MAX) =
    (
    SELECT 
		DENOMINATOR_TABLE + ', '
        FROM inserted ic 
        WHERE DENOMINATOR_TABLE IN (select TABLE_NAME from rif40_tables where ISNUMERATOR =1) 
		FOR XML PATH('')
    );
	IF @denom_status IS NOT NULL
		BEGIN
			RAISERROR(50078, 16, 1, @denom_status) with log;
		END;

  end  


GO
/****** Object:  Trigger [tr_result_checks]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [tr_result_checks] 
on [T_RIF40_RESULTS]
for insert , update 
as

 DECLARE @Standard nvarchar(MAX) =
		(
		SELECT 
        cast(ic.[DIRECT_STANDARDISATION] as varchar(20))+ ' '
		FROM inserted ic 
		where ic.[DIRECT_STANDARDISATION]=1 and 
			(
			ic.relative_risk IS NOT NULL OR
			ic.smoothed_relative_risk IS NOT NULL OR
			ic.posterior_probability IS NOT NULL OR
			ic.posterior_probability_lower95 IS NOT NULL OR
			ic.posterior_probability_upper95 IS NOT NULL OR
			ic.smoothed_smr IS NOT NULL OR
			ic.smoothed_smr_lower95 IS NOT NULL OR
			ic.smoothed_smr_upper95 IS NOT NULL OR
			ic.residual_relative_risk IS NOT NULL OR
			ic.residual_rr_lower95 IS NOT NULL OR
			ic.residual_rr_upper95 IS NOT NULL
			)
        FOR XML PATH('')
		 );

	IF @Standard IS NOT NULL
		BEGIN
			RAISERROR('Expecting NULL relative_risk with direct standardised results: %s', 16, 1, @Standard) with log;
		END;
GO
/****** Object:  Trigger [tr_studies_checks]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_studies_checks]
on [T_RIF40_STUDIES]
for insert , update 
as
BEGIN 
------------------------------------------------------------------------------------------
--Check - Comparison area geolevel name. 
--Must be a valid GEOLEVEL_NAME for the study GEOGRPAHY in T_RIF40_GEOLEVELS, with COMPAREA=1
------------------------------------------------------------------------------------------------

	 DECLARE @geolevel_name nvarchar(MAX) =
		(
		SELECT concat ([STUDY_ID],'-', [COMPARISON_GEOLEVEL_NAME], '-', geography )
		 + '  '
		FROM inserted ic 
		where not EXISTS (SELECT 1 FROM [dbo].[T_RIF40_GEOLEVELS] c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
				    c.geolevel_name=ic.[COMPARISON_GEOLEVEL_NAME] and
					c.[COMPAREA]=1)
        FOR XML PATH('')
		 );

	IF @geolevel_name IS NOT NULL
		BEGIN
			RAISERROR('Geolevel name not found ,studyid-comparison_geolevel_name-geography: %s', 16, 1, @geolevel_name) with log;
		END;
-----------------------------------------------------------------------------------------------------------
-- Check - STUDY_GEOLEVEL_NAME. Must be a valid GEOLEVEL_NAME for the study GEOGRPAHY in T_RIF40_GEOLEVELS
-----------------------------------------------------------------------------------------------------------

	 DECLARE @geolevel_name2 nvarchar(MAX) =
		(
		SELECT concat ([STUDY_ID],'-', [STUDY_GEOLEVEL_NAME], '-', geography )
		 + '  '
		FROM inserted ic 
		where not EXISTS (SELECT 1 FROM [dbo].[T_RIF40_GEOLEVELS] c 
              WHERE ic.[geography]=c.[GEOGRAPHY] and 
				    c.geolevel_name=ic.[STUDY_GEOLEVEL_NAME] 
						)
        FOR XML PATH('')
		 );

	IF @geolevel_name2 IS NOT NULL
		BEGIN
			RAISERROR('Geolevel name not found ,studyid-study_geolevel_name-geography: %s', 16, 1, @geolevel_name2) with log;
		END;
-------------------------------------
-- Check -  direct denominator
------------------------------------

DECLARE @direct_denom nvarchar(MAX) =
 (
SELECT a.TABLE_NAME + '  '
FROM rif40_tables a
WHERE table_name IN (select direct_stand_tab from [dbo].[T_RIF40_STUDIES] where direct_stand_tab is not null)
and a.ISDIRECTDENOMINATOR <>1
 FOR XML PATH('')
)

IF @direct_denom IS NOT NULL
		BEGIN
			RAISERROR('direct standardisation table: %s is not a direct denominator table: %s', 16, 1, @direct_denom) with log;
		END;

DECLARE @indirect_denom nvarchar(MAX) =
 (
SELECT a.TABLE_NAME + '  '
FROM rif40_tables a
WHERE table_name IN (select direct_stand_tab from [dbo].[T_RIF40_STUDIES] where direct_stand_tab is not null)
and a.ISINDIRECTDENOMINATOR <>1
 FOR XML PATH('')
)

IF @indirect_denom IS NOT NULL
		BEGIN
			RAISERROR('study %s denominator: %s is not a denominator table: %s', 16, 1, @indirect_denom) with log;
		END;
------------------------------
-- max/min age group is null-- NEED TO FINISH 
------------------------------
DECLARE @min_age nvarchar(MAX) =
 (
SELECT a.TABLE_NAME + '  '
FROM rif40_tables a
LEFT OUTER JOIN rif40_age_groups g ON (g.age_group_id  = a.age_group_id)
WHERE table_name IN (select direct_stand_tab from [dbo].[T_RIF40_STUDIES] where direct_stand_tab is not null)
GROUP BY a.TABLE_NAME,a.year_start, a.year_stop, a.isindirectdenominator, a.isdirectdenominator, a.isnumerator,
a.age_sex_group_field_name, a.sex_field_name, a.age_group_field_name, a.total_field
having MAX(g.offset) is  null or MIN(g.offset) is  null 
 FOR XML PATH('')
)

IF @min_age IS NOT NULL
		BEGIN
			RAISERROR('study %s denominator: %s is not a denominator table: %s', 16, 1, @min_age) with log;
		END;


-------------------------------------------------------------------------------------------------
-- Check - Comparison area geolevel name(COMPARISON_GEOLEVEL_NAME). 
--Must be a valid GEOLEVEL_NAME for the study GEOGRPAHY in T_RIF40_GEOLEVELS, with COMPAREA=1.
--------------------------------------------------------------------------------------------------

DECLARE @COMP_GEOLEVEL nvarchar(MAX) =
 (
SELECT a.GEOLEVEL_NAME + '  '
FROM T_RIF40_GEOLEVELS a
WHERE A.GEOLEVEL_NAME IN	(select COMPARISON_GEOLEVEL_NAME from INSERTED 
							 where COMPARISON_GEOLEVEL_NAME is not null AND COMPARISON_GEOLEVEL_NAME <>'') and 
		a.GEOGRAPHY IN		(select GEOGRAPHY from INSERTED)
		 FOR XML PATH('')
 
)
IF @COMP_GEOLEVEL IS NOT NULL
		BEGIN
			RAISERROR('omparison area geolevel name: "%" not found in RIF40_GEOLEVELS: %s', 16, 1, @COMP_GEOLEVEL) with log;
		END;

DECLARE @COMP_GEOLEVEL2 nvarchar(MAX) =
(
SELECT a.GEOLEVEL_NAME + '  '
FROM T_RIF40_GEOLEVELS a
WHERE A.GEOLEVEL_NAME IN	(select COMPARISON_GEOLEVEL_NAME from INSERTED 
							 where COMPARISON_GEOLEVEL_NAME is not null AND COMPARISON_GEOLEVEL_NAME <>'') and 
		a.GEOGRAPHY IN		(select GEOGRAPHY from INSERTED) and 
		a.COMPAREA <>1 
		 FOR XML PATH('')

)
IF @COMP_GEOLEVEL IS NOT NULL
		BEGIN
			RAISERROR('comparison area geolevel name in RIF40_GEOLEVELS is not a comparison area: %s', 16, 1, @COMP_GEOLEVEL) with log;
		END;
	
DECLARE @COMP_GEOLEVEL3 nvarchar(MAX) =
(
SELECT a.STUDY_ID + '  '
FROM inserted  a
WHERE a.COMPARISON_GEOLEVEL_NAME is null 
		 FOR XML PATH('')

)
IF @COMP_GEOLEVEL3 IS NOT NULL
		BEGIN
			RAISERROR('study has NULL comparison area geolevel name: %s', 16, 1, @COMP_GEOLEVEL3) with log;
		END;
		
END	
	
GO
/****** Object:  Trigger [tr_STUDY_AREAS]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create trigger [tr_STUDY_AREAS]
on [T_RIF40_STUDY_AREAS]
for insert, update 
as

Declare  @xtype varchar(5)

	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @XTYPE = 'D'
	END
	IF EXISTS (SELECT * FROM INSERTED)
		BEGIN
			IF (@XTYPE = 'D')
		BEGIN
			SET @XTYPE = 'U'
		END
	ELSE
		BEGIN
			SET @XTYPE = 'I'
		END
------------------------------------------------
--When Transaction is an Update  then rollback 
-------------------------------------------------
	IF (@XTYPE = 'U')
		BEGIN
		 	Raiserror (50100, 16,1 );
			rollback tran
		  end 
END


GO
/****** Object:  Trigger [tr_USER_PROJECTS]    Script Date: 23/10/2014 11:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [tr_USER_PROJECTS]
on [T_RIF40_USER_PROJECTS]
for insert , update 
as
begin

-- Check project has not ended
DECLARE @date_ended NVARCHAR(MAX)= 
( 
  SELECT ic.project +' , '
		 FROM inserted  ic
		 WHERE ic.project = (select [PROJECT] from [dbo].[T_RIF40_PROJECTS] where DATE_ENDED is null)
 FOR XML PATH('') 
); 
BEGIN TRY
IF @date_ended IS NOT NULL 
	BEGIN 
		raiserror(50070,16,1,@date_ended); 
		rollback
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 


DECLARE @sysdate NVARCHAR(MAX)= 
( 
  SELECT cast(p.DATE_ENDED as varchar(50)) +' , '
		 FROM inserted  ic , [T_RIF40_PROJECTS] p
		 WHERE ic.project = (select [PROJECT] from [dbo].[T_RIF40_PROJECTS] where DATE_ENDED < getdate())
 FOR XML PATH('') 
); 
BEGIN TRY
IF @sysdate IS NOT NULL 
	BEGIN 
		raiserror(50071,16,1,@sysdate); 
		rollback
	END;
END TRY
BEGIN CATCH
		EXEC [ErrorLog_proc]
END CATCH 
end 

GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_COMPARISON_AREAS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_COMPARISON_AREAS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_COMPARISON_AREAS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_COMPARISON_AREAS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_COMPARISON_AREAS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_COMPARISON_AREAS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS.BAND_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'BAND_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_A_AND_E.A_AND_E_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_A_AND_E', @level2type=N'COLUMN',@level2name=N'A_AND_E_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_A_AND_E.TEXT_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_A_AND_E', @level2type=N'COLUMN',@level2name=N'TEXT_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_A_AND_E' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_A_AND_E'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUP_NAMES.AGE_GROUP_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUP_NAMES', @level2type=N'COLUMN',@level2name=N'AGE_GROUP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUP_NAMES.AGE_GROUP_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUP_NAMES', @level2type=N'COLUMN',@level2name=N'AGE_GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUP_NAMES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUP_NAMES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUPS.AGE_GROUP_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUPS', @level2type=N'COLUMN',@level2name=N'AGE_GROUP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUPS.OFFSET' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUPS', @level2type=N'COLUMN',@level2name=N'OFFSET'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUPS.LOW_AGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUPS', @level2type=N'COLUMN',@level2name=N'LOW_AGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUPS.HIGH_AGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUPS', @level2type=N'COLUMN',@level2name=N'HIGH_AGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUPS.FIELDNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUPS', @level2type=N'COLUMN',@level2name=N'FIELDNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_AGE_GROUPS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_AGE_GROUPS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES.GEOLEVEL_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES', @level2type=N'COLUMN',@level2name=N'GEOLEVEL_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES.COVARIATE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES', @level2type=N'COLUMN',@level2name=N'COVARIATE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES.MIN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES', @level2type=N'COLUMN',@level2name=N'MIN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES.MAX' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES', @level2type=N'COLUMN',@level2name=N'MAX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES."TYPE"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES', @level2type=N'COLUMN',@level2name=N'TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_COVARIATES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_COVARIATES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.ERROR_CODE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'ERROR_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.TAG' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'TAG'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.TABLE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.CAUSE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'CAUSE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.ACTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'ACTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.MESSAGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.HIERARCHYTABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'HIERARCHYTABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.SRID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'SRID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.DEFAULTCOMPAREA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'DEFAULTCOMPAREA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.DEFAULTSTUDYAREA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'DEFAULTSTUDYAREA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.POSTAL_POPULATION_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'POSTAL_POPULATION_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.POSTAL_POINT_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'POSTAL_POINT_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES."PARTITION"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'PARTITION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.MAX_GEOJSON_DIGITS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'MAX_GEOJSON_DIGITS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_HEALTH_STUDY_THEMES.THEME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_HEALTH_STUDY_THEMES', @level2type=N'COLUMN',@level2name=N'THEME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_HEALTH_STUDY_THEMES.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_HEALTH_STUDY_THEMES', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_HEALTH_STUDY_THEMES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_HEALTH_STUDY_THEMES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD_O_3.ICD_O_3_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD_O_3', @level2type=N'COLUMN',@level2name=N'ICD_O_3_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD_O_3.ICD_O_3_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD_O_3', @level2type=N'COLUMN',@level2name=N'ICD_O_3_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD_O_3.TEXT_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD_O_3', @level2type=N'COLUMN',@level2name=N'TEXT_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD_O_3.TEXT_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD_O_3', @level2type=N'COLUMN',@level2name=N'TEXT_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD_O_3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD_O_3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10.ICD10_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10', @level2type=N'COLUMN',@level2name=N'ICD10_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10.ICD10_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10', @level2type=N'COLUMN',@level2name=N'ICD10_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10.ICD10_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10', @level2type=N'COLUMN',@level2name=N'ICD10_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10.TEXT_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10', @level2type=N'COLUMN',@level2name=N'TEXT_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10.TEXT_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10', @level2type=N'COLUMN',@level2name=N'TEXT_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10.TEXT_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10', @level2type=N'COLUMN',@level2name=N'TEXT_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD10' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD10'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD9.ICD9_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD9', @level2type=N'COLUMN',@level2name=N'ICD9_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD9.ICD9_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD9', @level2type=N'COLUMN',@level2name=N'ICD9_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD9.TEXT_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD9', @level2type=N'COLUMN',@level2name=N'TEXT_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD9.TEXT_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD9', @level2type=N'COLUMN',@level2name=N'TEXT_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ICD9' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ICD9'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4.OPCS4_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4', @level2type=N'COLUMN',@level2name=N'OPCS4_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4.OPCS4_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4', @level2type=N'COLUMN',@level2name=N'OPCS4_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4.OPCS4_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4', @level2type=N'COLUMN',@level2name=N'OPCS4_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4.TEXT_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4', @level2type=N'COLUMN',@level2name=N'TEXT_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4.TEXT_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4', @level2type=N'COLUMN',@level2name=N'TEXT_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4.TEXT_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4', @level2type=N'COLUMN',@level2name=N'TEXT_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OPCS4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OPCS4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_GROUP_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_GROUP_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_GROUP_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.FIELD_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'FIELD_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.MULTIPLE_FIELD_COUNT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'MULTIPLE_FIELD_COUNT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.OUTCOME_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'OUTCOME_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.OUTCOME_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'OUTCOME_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_VERSION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VERSION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_SUB_VERSION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_SUB_VERSION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_VERSION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_VERSION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_SUB_VERSION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_SUB_VERSION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_LOOKUP_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_LOOKUP_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_LOOKUP_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_LOOKUP_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_VALUE_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VALUE_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_VALUE_2CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VALUE_2CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_VALUE_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VALUE_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_VALUE_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VALUE_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_VALUE_5CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VALUE_5CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_DESCRIPTION_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_DESCRIPTION_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_DESCRIPTION_2CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_DESCRIPTION_2CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_DESCRIPTION_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_DESCRIPTION_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_DESCRIPTION_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_DESCRIPTION_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.CURRENT_DESCRIPTION_5CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_DESCRIPTION_5CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_VALUE_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_VALUE_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_VALUE_2CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_VALUE_2CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_VALUE_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_VALUE_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_VALUE_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_VALUE_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_VALUE_5CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_VALUE_5CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_DESCRIPTION_1CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_DESCRIPTION_1CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_DESCRIPTION_2CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_DESCRIPTION_2CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_DESCRIPTION_3CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_DESCRIPTION_3CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_DESCRIPTION_4CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_DESCRIPTION_4CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES.PREVIOUS_DESCRIPTION_5CHAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES', @level2type=N'COLUMN',@level2name=N'PREVIOUS_DESCRIPTION_5CHAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOMES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOMES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_US."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_US', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_US.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_US', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_US.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_US', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_US' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_US'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_WORLD."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_WORLD', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_WORLD.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_WORLD', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_WORLD.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_WORLD', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_WORLD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_WORLD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_PREDEFINED_GROUPS.PREDEFINED_GROUP_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_PREDEFINED_GROUPS', @level2type=N'COLUMN',@level2name=N'PREDEFINED_GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_PREDEFINED_GROUPS.PREDEFINED_GROUP_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_PREDEFINED_GROUPS', @level2type=N'COLUMN',@level2name=N'PREDEFINED_GROUP_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_PREDEFINED_GROUPS.OUTCOME_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_PREDEFINED_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_PREDEFINED_GROUPS.CONDITION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_PREDEFINED_GROUPS', @level2type=N'COLUMN',@level2name=N'CONDITION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_PREDEFINED_GROUPS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_PREDEFINED_GROUPS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_REFERENCE_TABLES.TABLE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_REFERENCE_TABLES', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_REFERENCE_TABLES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_REFERENCE_TABLES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_STUDY_SHARES.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_STUDY_SHARES', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_STUDY_SHARES.GRANTOR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_STUDY_SHARES', @level2type=N'COLUMN',@level2name=N'GRANTOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_STUDY_SHARES.GRANTEE_USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_STUDY_SHARES', @level2type=N'COLUMN',@level2name=N'GRANTEE_USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_STUDY_SHARES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_STUDY_SHARES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLE_OUTCOMES.OUTCOME_GROUP_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLE_OUTCOMES', @level2type=N'COLUMN',@level2name=N'OUTCOME_GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLE_OUTCOMES.NUMER_TAB' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLE_OUTCOMES', @level2type=N'COLUMN',@level2name=N'NUMER_TAB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLE_OUTCOMES.CURRENT_VERSION_START_YEAR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLE_OUTCOMES', @level2type=N'COLUMN',@level2name=N'CURRENT_VERSION_START_YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLE_OUTCOMES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLE_OUTCOMES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.THEME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'THEME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.TABLE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.YEAR_START' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'YEAR_START'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.YEAR_STOP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'YEAR_STOP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.TOTAL_FIELD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'TOTAL_FIELD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.ISINDIRECTDENOMINATOR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'ISINDIRECTDENOMINATOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.ISDIRECTDENOMINATOR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'ISDIRECTDENOMINATOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.ISNUMERATOR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'ISNUMERATOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.AUTOMATIC' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'AUTOMATIC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.SEX_FIELD_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'SEX_FIELD_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.AGE_GROUP_FIELD_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'AGE_GROUP_FIELD_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.AGE_SEX_GROUP_FIELD_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP_FIELD_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.AGE_GROUP_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'AGE_GROUP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES.VALIDATION_DATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES', @level2type=N'COLUMN',@level2name=N'VALIDATION_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_TABLES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_TABLES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_VERSION.VERSION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_VERSION', @level2type=N'COLUMN',@level2name=N'VERSION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_VERSION.SCHEMA_CREATED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_VERSION', @level2type=N'COLUMN',@level2name=N'SCHEMA_CREATED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_VERSION.SCHEMA_AMENDED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_VERSION', @level2type=N'COLUMN',@level2name=N'SCHEMA_AMENDED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_VERSION.CVS_REVISION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_VERSION', @level2type=N'COLUMN',@level2name=N'CVS_REVISION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_VERSION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_VERSION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.ICD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'ICD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL3."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL3', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL3.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL3', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL3.SES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL3', @level2type=N'COLUMN',@level2name=N'SES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL3.ETHNICITY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL3', @level2type=N'COLUMN',@level2name=N'ETHNICITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.SES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'SES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.AREATRI1KM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'AREATRI1KM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.NEAR_DIST' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'NEAR_DIST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.TRI_1KM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'TRI_1KM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL1.LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL1', @level2type=N'COLUMN',@level2name=N'LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL1."NAME"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL1', @level2type=N'COLUMN',@level2name=N'NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL2.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL2', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL2."NAME"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL2', @level2type=N'COLUMN',@level2name=N'NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL3.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL3', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL3."NAME"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL3', @level2type=N'COLUMN',@level2name=N'NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL4.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL4', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL4."NAME"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL4', @level2type=N'COLUMN',@level2name=N'NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL4.X_COORDINATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL4', @level2type=N'COLUMN',@level2name=N'X_COORDINATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL4.Y_COORDINATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL4', @level2type=N'COLUMN',@level2name=N'Y_COORDINATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP.LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_POP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_POP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_COMPARISON_AREAS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_COMPARISON_AREAS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_COMPARISON_AREAS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_COMPARISON_AREAS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_COMPARISON_AREAS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_COMPARISON_AREAS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_COMPARISON_AREAS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_COMPARISON_AREAS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.INV_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'INV_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.AREA_POPULATION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'AREA_POPULATION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.AREA_OBSERVED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'AREA_OBSERVED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.TOTAL_COMPARISION_POPULATION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'TOTAL_COMPARISION_POPULATION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.VARIANCE_HIGH' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'VARIANCE_HIGH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.VARIANCE_LOW' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'VARIANCE_LOW'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.TABLE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.CREATE_STATUS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'CREATE_STATUS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.ERROR_MESSAGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'ERROR_MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.DATE_CREATED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'DATE_CREATED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.ROWTEST_PASSED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'ROWTEST_PASSED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.GEOLEVEL_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'GEOLEVEL_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.GEOLEVEL_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'GEOLEVEL_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.LOOKUP_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'LOOKUP_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.LOOKUP_DESC_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'LOOKUP_DESC_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.CENTROIDXCOORDINATE_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'CENTROIDXCOORDINATE_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.CENTROIDYCOORDINATE_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'CENTROIDYCOORDINATE_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.SHAPEFILE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'SHAPEFILE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.CENTROIDSFILE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'CENTROIDSFILE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.SHAPEFILE_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'SHAPEFILE_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.SHAPEFILE_AREA_ID_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'SHAPEFILE_AREA_ID_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.SHAPEFILE_DESC_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'SHAPEFILE_DESC_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.ST_SIMPLIFY_TOLERANCE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'ST_SIMPLIFY_TOLERANCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.CENTROIDS_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'CENTROIDS_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.CENTROIDS_AREA_ID_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'CENTROIDS_AREA_ID_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.AVG_NPOINTS_GEOM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'AVG_NPOINTS_GEOM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.AVG_NPOINTS_OPT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'AVG_NPOINTS_OPT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.FILE_GEOJSON_LEN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'FILE_GEOJSON_LEN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.LEG_GEOM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'LEG_GEOM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.LEG_OPT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'LEG_OPT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.COVARIATE_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'COVARIATE_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.RESTRICTED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'RESTRICTED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.RESOLUTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'RESOLUTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.COMPAREA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'COMPAREA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS.LISTING' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS', @level2type=N'COLUMN',@level2name=N'LISTING'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_GEOLEVELS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_GEOLEVELS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_CONDITIONS.INV_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_CONDITIONS', @level2type=N'COLUMN',@level2name=N'INV_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_CONDITIONS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_CONDITIONS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_CONDITIONS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_CONDITIONS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_CONDITIONS.LINE_NUMBER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_CONDITIONS', @level2type=N'COLUMN',@level2name=N'LINE_NUMBER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_CONDITIONS.CONDITION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_CONDITIONS', @level2type=N'COLUMN',@level2name=N'CONDITION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_CONDITIONS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_CONDITIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.INV_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'INV_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.COVARIATE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'COVARIATE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.STUDY_GEOLEVEL_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'STUDY_GEOLEVEL_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.MIN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'MIN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES.MAX' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES', @level2type=N'COLUMN',@level2name=N'MAX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INV_COVARIATES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INV_COVARIATES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.INV_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'INV_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.INV_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'INV_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.INV_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'INV_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.CLASSIFIER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'CLASSIFIER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.CLASSIFIER_BANDS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'CLASSIFIER_BANDS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.GENDERS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'GENDERS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.NUMER_TAB' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'NUMER_TAB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.YEAR_START' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'YEAR_START'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.YEAR_STOP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'YEAR_STOP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.MAX_AGE_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'MAX_AGE_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.MIN_AGE_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'MIN_AGE_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.INVESTIGATION_STATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'INVESTIGATION_STATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.MH_TEST_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'COLUMN',@level2name=N'MH_TEST_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_NUM_DENOM.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_NUM_DENOM', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_NUM_DENOM.NUMERATOR_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_NUM_DENOM', @level2type=N'COLUMN',@level2name=N'NUMERATOR_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_NUM_DENOM.DENOMINATOR_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_NUM_DENOM', @level2type=N'COLUMN',@level2name=N'DENOMINATOR_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_NUM_DENOM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_NUM_DENOM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.PARAM_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'COLUMN',@level2name=N'PARAM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.PARAM_VALUE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'COLUMN',@level2name=N'PARAM_VALUE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.PARAM_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'COLUMN',@level2name=N'PARAM_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PROJECTS.PROJECT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PROJECTS', @level2type=N'COLUMN',@level2name=N'PROJECT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PROJECTS.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PROJECTS', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PROJECTS.DATE_STARTED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PROJECTS', @level2type=N'COLUMN',@level2name=N'DATE_STARTED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PROJECTS.DATE_ENDED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PROJECTS', @level2type=N'COLUMN',@level2name=N'DATE_ENDED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PROJECTS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PROJECTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.INV_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'INV_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.BAND_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'BAND_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.GENDERS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'GENDERS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.ADJUSTED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'ADJUSTED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.DIRECT_STANDARDISATION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'DIRECT_STANDARDISATION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.OBSERVED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'OBSERVED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.EXPECTED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'EXPECTED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.LOWER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'LOWER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.UPPER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'UPPER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.RELATIVE_RISK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'RELATIVE_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.SMOOTHED_RELATIVE_RISK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'SMOOTHED_RELATIVE_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.POSTERIOR_PROBABILITY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'POSTERIOR_PROBABILITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.POSTERIOR_PROBABILITY_LOWER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'POSTERIOR_PROBABILITY_LOWER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.POSTERIOR_PROBABILITY_UPPER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'POSTERIOR_PROBABILITY_UPPER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.RESIDUAL_RELATIVE_RISK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'RESIDUAL_RELATIVE_RISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.RESIDUAL_RR_LOWER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'RESIDUAL_RR_LOWER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.RESIDUAL_RR_UPPER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'RESIDUAL_RR_UPPER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.SMOOTHED_SMR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'SMOOTHED_SMR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.SMOOTHED_SMR_LOWER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'SMOOTHED_SMR_LOWER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS.SMOOTHED_SMR_UPPER95' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS', @level2type=N'COLUMN',@level2name=N'SMOOTHED_SMR_UPPER95'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_RESULTS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_RESULTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.PROJECT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'PROJECT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.STUDY_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'STUDY_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.SUMMARY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'SUMMARY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.OTHER_NOTES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'OTHER_NOTES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.EXTRACT_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'EXTRACT_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.MAP_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'MAP_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.STUDY_DATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'STUDY_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.STUDY_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'STUDY_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.STUDY_STATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'STUDY_STATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.COMPARISON_GEOLEVEL_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'COMPARISON_GEOLEVEL_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.STUDY_GEOLEVEL_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'STUDY_GEOLEVEL_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.DENOM_TAB' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'DENOM_TAB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.DIRECT_STAND_TAB' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'DIRECT_STAND_TAB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.SUPPRESSION_VALUE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'SUPPRESSION_VALUE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.EXTRACT_PERMITTED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'EXTRACT_PERMITTED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.TRANSFER_PERMITTED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'TRANSFER_PERMITTED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.AUTHORISED_BY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'AUTHORISED_BY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.AUTHORISED_ON' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'AUTHORISED_ON'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.AUTHORISED_NOTES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'AUTHORISED_NOTES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.AUDSID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'COLUMN',@level2name=N'AUDSID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.BAND_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'BAND_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.STATEMENT_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'STATEMENT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.STATEMENT_NUMBER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'STATEMENT_NUMBER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.SQL_TEXT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'SQL_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.LINE_NUMBER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'LINE_NUMBER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL.STATUS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL', @level2type=N'COLUMN',@level2name=N'STATUS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STATEMENT_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'STATEMENT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STATEMENT_NUMBER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'STATEMENT_NUMBER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.LOG_MESSAGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'LOG_MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.LOG_SQLCODE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'LOG_SQLCODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG."ROWCOUNT"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'ROWCOUNT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.START_TIME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'START_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.ELAPSED_TIME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'ELAPSED_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.AUDSID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'AUDSID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_USER_PROJECTS.PROJECT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_USER_PROJECTS', @level2type=N'COLUMN',@level2name=N'PROJECT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_USER_PROJECTS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_USER_PROJECTS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_USER_PROJECTS.GRANT_DATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_USER_PROJECTS', @level2type=N'COLUMN',@level2name=N'GRANT_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_USER_PROJECTS.REVOKE_DATE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_USER_PROJECTS', @level2type=N'COLUMN',@level2name=N'REVOKE_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_USER_PROJECTS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_USER_PROJECTS'
GO
