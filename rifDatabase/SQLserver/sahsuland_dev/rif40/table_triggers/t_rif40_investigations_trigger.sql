/*
Check - USERNAME exists.
Check - USERNAME is Kerberos USER on INSERT.
Check - UPDATE only allowed on own records for INVESTIGATION_STATE.
Check - DELETE only allowed on own records.
Check - NUMER_TAB is a valid Oracle name and a numerator, and user has access.
Check - YEAR_START, YEAR_STOP, MAX_AGE_GROUP, MIN_AGE_GROUP.
Check - INV_NAME is a valid Oracle name of 20 characters only.
Check - AGE_GROUP_ID, AGE_SEX_GROUP/AGE_GROUP/SEX_FIELD_NAMES are the same between numerator, denonminator and direct standardisation tables
*/


IF EXISTS (SELECT *  FROM sys.triggers tr
INNER JOIN sys.tables t ON tr.parent_id = t.object_id
WHERE t.schema_id = SCHEMA_ID(N'rif40') 
and tr.name=N'tr_investigations')
BEGIN
	DROP TRIGGER [rif40].[tr_investigations]
END
GO

create trigger [tr_investigations]
on [rif40].[t_rif40_investigations]
for insert , update , delete
as
BEGIN 

Declare  @XTYPE varchar(5)
	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @XTYPE = 'D'
	END;
	
	IF EXISTS (SELECT * FROM INSERTED)
	BEGIN
		IF (@XTYPE = 'D')
			SET @XTYPE = 'U'
		ELSE 
			SET @XTYPE = 'I'
	END;

--
-- Save sequence in current valid sequences object for later use by
-- CURRVAL function: [rif40].[rif40_sequence_current_value]()
--
DECLARE @log_msg1 VARCHAR(MAX) = '@XTYPE='+COALESCE(@XTYPE, 'NULL')+
	'; OBJECT_ID tempdb..##t_rif40_investigations_seq='+
	COALESCE(CAST(OBJECT_ID('tempdb..##t_rif40_investigations_seq') AS VARCHAR), 'NULL');
EXEC [rif40].[rif40_log] 'DEBUG1', '[rif40].[t_rif40_investigations]', @log_msg1;
	
IF @XTYPE = 'I' AND OBJECT_ID('tempdb..##t_rif40_investigations_seq') IS NOT NULL BEGIN
	INSERT INTO ##t_rif40_investigations_seq(inv_id)
	SELECT inv_id
	  FROM INSERTED;
END;
  
DECLARE @has_studies_check VARCHAR(MAX) = 
(
	SELECT count(study_id) as total
	FROM [rif40].[t_rif40_results]
);
		
IF @xtype = 'I' or @xtype = 'U'
BEGIN
	DECLARE @not_current_user VARCHAR(MAX) =
	(	
		SELECT username
		FROM inserted
		WHERE username != SUSER_SNAME()
		FOR XML PATH('')
	);
	IF @not_current_user IS NOT NULL
	BEGIN
		IF SUSER_SNAME() = 'RIF40' and @has_studies_check=0
		BEGIN
			EXEC [rif40].[rif40_log] 'DEBUG1', '[rif40].[t_rif40_investigations]', 't_rif40_investigations insert/update allowed during build';
		END;
		ELSE
			BEGIN TRY
				rollback;
				DECLARE @err_msg1 VARCHAR(MAX) = formatmessage(51077, @not_current_user);
				THROW 51077, @err_msg1, 1;
			END TRY
			BEGIN CATCH
				EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
				THROW 51077, @err_msg1, 1;
			END CATCH;	
	END;
END;

--can only update or delete own records
IF @xtype = 'U' or @xtype = 'D'
BEGIN
	DECLARE @different_old_users VARCHAR(MAX) = 
	(
		SELECT username
		from deleted 
		WHERE username != SUSER_SNAME()
		FOR XML PATH('')
	);
	IF @different_old_users IS NOT NULL
	BEGIN TRY
		rollback;
		DECLARE @err_msg2 VARCHAR(MAX) = formatmessage(51078, @different_old_users);
		THROW 51078, @err_msg2, 1;
	END TRY
	BEGIN CATCH
		EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
		THROW 51078, @err_msg2, 1;
	END CATCH;	
END;

--can only update records in INVESTIGATION_STATE
IF @xtype = 'U' 
BEGIN
	DECLARE @update_not_investigation VARCHAR(MAX) = 
	(
		SELECT ic.inv_id, ic.study_id, ic.investigation_state AS new_state,
               CASE WHEN id.study_id IS NULL THEN 'Error: study_id update'
			        WHEN id.inv_id IS NULL THEN 'Error:inv_id update'
					WHEN ic.investigation_state = id.investigation_state THEN 'Error: no state change'
					ELSE 'State/PK checks OK' END AS state_checks, 
			   CASE WHEN NOT (ic.username = iv.username AND
						ic.inv_name = iv.inv_name AND
						ic.inv_description = iv.inv_description AND
						ic.year_start = iv.year_start AND
						ic.year_stop = iv.year_stop AND
						ic.max_age_group = iv.max_age_group AND
						ic.min_age_group = iv.min_age_group AND
						ic.genders = iv.genders AND
						ic.numer_tab = iv.numer_tab AND
						ic.classifier = iv.classifier AND
						ic.classifier_bands = iv.classifier_bands AND
						ic.mh_test_type = iv.mh_test_type) THEN 'Changing fields other than investigation_state' 
				ELSE 'No other fields changed' END AS field_status
		  FROM inserted ic 
				LEFT OUTER JOIN deleted id
					ON ( ic.inv_id = id.inv_id AND ic.study_id = id.study_id )
				LEFT OUTER JOIN rif40.t_rif40_investigations iv	
					ON ( ic.inv_id = iv.inv_id AND ic.study_id = iv.study_id )
        WHERE id.study_id IS NULL OR id.inv_id IS NULL			/* i.e. updating PK! */ 
		   OR ic.investigation_state = id.investigation_state 	/* No state change */
           OR 													/* Changing fields other than investigation_state */
		   NOT (ic.username = iv.username AND
 				ic.inv_name = iv.inv_name AND
 				ic.inv_description = iv.inv_description AND
 				ic.year_start = iv.year_start AND
 				ic.year_stop = iv.year_stop AND
 				ic.max_age_group = iv.max_age_group AND
 				ic.min_age_group = iv.min_age_group AND
 				ic.genders = iv.genders AND
 				ic.numer_tab = iv.numer_tab AND
 				ic.classifier = iv.classifier AND
 				ic.classifier_bands = iv.classifier_bands AND
 				ic.mh_test_type = iv.mh_test_type)  
		FOR XML PATH('')
	);
	IF @update_not_investigation IS NOT NULL
	BEGIN TRY
		rollback;
		DECLARE @err_msg3 VARCHAR(MAX) = formatmessage(51079, @update_not_investigation);
		THROW 51079, @err_msg3, 1;
	END TRY
	BEGIN CATCH
		EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
		THROW 51079, @err_msg3, 1;
	END CATCH;	
END;

IF @xtype = 'I' or @xtype = 'U'
BEGIN
--
-- Check - NUMER_TAB is a valid Oracle name and a numerator, and user has access.
--

--valid Oracle name checks:
DECLARE num_tab_cursor CURSOR FOR
	SELECT numer_tab, inv_name
	from inserted;
DECLARE @curs_numer_tab VARCHAR(MAX), @curs_inv_name VARCHAR(MAX);
OPEN num_tab_cursor;
FETCH num_tab_cursor INTO @curs_numer_tab, @curs_inv_name;
WHILE @@FETCH_STATUS = 0  
BEGIN  
	EXEC [rif40].[rif40_db_name_check] 'NUMER_TAB', @curs_numer_tab;
	EXEC [rif40].[rif40_db_name_check] 'INV_NAME', @curs_inv_name;
	FETCH num_tab_cursor INTO @curs_numer_tab, @curs_inv_name;
END;
CLOSE num_tab_cursor ;
DEALLOCATE num_tab_cursor ;

DECLARE @numer_tab_prob VARCHAR(MAX) = 
(
	SELECT numer_tab, a.inv_id, a.study_id
	FROM inserted a, [rif40].[rif40_tables] b
	WHERE a.numer_tab=b.table_name
	AND b.isnumerator <> 1
	FOR XML PATH('')
);
IF @numer_tab_prob IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg4 VARCHAR(MAX) = formatmessage(51080, @numer_tab_prob);
	THROW 51080, @err_msg4, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 51080, @err_msg4, 1;
END CATCH;	


-----------------------
--year start
-----------------------
DECLARE @year_start_prob NVARCHAR(MAX)= 
( 
SELECT b.numer_tab, b.year_start as 'new_year_start', a.year_start as 'rif40_tables_year_start'
FROM	[rif40].[rif40_tables] a , inserted b
where TABLE_NAME=b.NUMER_TAB
and b.YEAR_START is not null and 
b.YEAR_START < a.YEAR_START
 FOR XML PATH('') 
);

IF @year_start_prob IS NOT NULL 
BEGIN TRY
	rollback;
	DECLARE @err_msg5 VARCHAR(MAX) = formatmessage(50051, @year_start_prob);
	THROW 50051, @err_msg5, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50051, @err_msg5, 1;
END CATCH;	

-----------------------
--year stop
-----------------------
DECLARE @year_stop_prob NVARCHAR(MAX)= 
( 
SELECT b.numer_tab, b.year_start as 'new_year_start', a.year_start as 'rif40_tables_year_start'
FROM	[rif40].[rif40_tables] a , inserted b
where TABLE_NAME=b.NUMER_TAB
and b.YEAR_START is not null and 
b.YEAR_START > a.YEAR_STOP
 FOR XML PATH('') 
);
IF @year_stop_prob IS NOT NULL 
BEGIN TRY
	rollback;
	DECLARE @err_msg6 VARCHAR(MAX) = formatmessage(50052, @year_stop_prob);
	THROW 50052, @err_msg6, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50052, @err_msg6, 1;
END CATCH;	


--checking min/max ages
--first check that there is linkage to age groups
DECLARE @no_age_group NVARCHAR(MAX)= 
( 
	select numer_tab
	from inserted b
	where not exists (
		select 1
		from [rif40].[rif40_tables] a, [rif40].[rif40_age_groups] g 
		where g.age_group_id  = a.age_group_id
		and a.table_name=b.numer_tab
		and g.offset is not null
	)
	FOR XML PATH('')
);
IF @no_age_group IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg9 VARCHAR(MAX) = formatmessage(50054, @no_age_group);
	THROW 50054, @err_msg9, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50054, @err_msg9, 1;
END CATCH;	

---------------
-- MIN AGE 
---------------
DECLARE @min_age_prob NVARCHAR(MAX)= 
( 
	select b.numer_tab, b.min_age_group as 'new_min_age_group', a.min_age_group as 'rif40_age_groups_min_age', a.age_group_id as 'rif40_age_groups_id'
	from inserted b, 
	(select j.numer_tab, a.age_group_id, MIN(g.offset) min_age_group
	from [rif40].[rif40_tables] a, [rif40].[rif40_age_groups] g , inserted j
	where g.age_group_id  = a.age_group_id
	and a.table_name=j.numer_tab
	group by j.numer_tab, a.age_group_id) a
	where b.numer_tab=a.numer_tab
	and a.min_age_group is not null and b.min_age_group is not null
	and b.MIN_AGE_GROUP<a.min_age_group
	FOR XML PATH('') 
);
IF @min_age_prob IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg7 VARCHAR(MAX) = formatmessage(50053, @min_age_prob);
	THROW 50053, @err_msg7, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50053, @err_msg7, 1;
END CATCH;	

---------------
-- Max AGE 
---------------
DECLARE @max_age_prob VARCHAR(MAX) = 
(
	select b.numer_tab, b.max_age_group as 'new_max_age_group', a.max_age_group as 'rif40_age_groups_max_age', a.age_group_id as 'rif40_age_groups_id'
	from inserted b, 
	(select j.numer_tab, a.age_group_id, MAX(g.offset) max_age_group
	from [rif40].[rif40_tables] a, [rif40].[rif40_age_groups] g , inserted j
	where g.age_group_id  = a.age_group_id
	and a.table_name=j.numer_tab
	group by j.numer_tab, a.age_group_id) a
	where b.numer_tab=a.numer_tab
	and a.max_age_group is not null and b.max_age_group is not null
	AND b.max_age_group > a.max_age_group 
	FOR XML PATH('') 
);
IF @max_age_prob IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg8 VARCHAR(MAX) = formatmessage(51081, @max_age_prob);
	THROW 51081, @err_msg8, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 51081, @err_msg8, 1;
END CATCH;	


-----------------------------------------------
--min >max age group: just for inserted table 
--------------------- --------------------------
DECLARE @min_max_prob NVARCHAR(MAX)= 
( 
select a.min_age_group, a.max_age_group
from inserted a 
where a.min_age_group> a.max_age_group
FOR XML PATH('') 
);
IF @min_max_prob IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg10 VARCHAR(MAX) = formatmessage(50055, @max_age_prob);
	THROW 50055, @err_msg10, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50055, @err_msg10, 1;
END CATCH;	

-----------------------------------------------
--year start > year stop : just for inserted table 
--------------------- --------------------------
DECLARE @year_start_stop_prob NVARCHAR(MAX)= 
( 
select a.YEAR_START, year_stop
from inserted a 
where a.YEAR_START> a.YEAR_STOP
FOR XML PATH('') 
);
IF @year_start_stop_prob IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg11 VARCHAR(MAX) = formatmessage(50056, @year_start_stop_prob);
	THROW 50056, @err_msg11, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50056, @err_msg11, 1;
END CATCH;	

--------------------------------
-- verify column existence  
----------------------------------
IF @has_studies_check != 0
BEGIN
	DECLARE @total_field_missing VARCHAR(MAX)=
	(
		SELECT a.numer_tab, b.total_field
		FROM inserted a, [rif40].[rif40_tables] b
		WHERE b.table_name=a.numer_tab
		AND b.total_field is not null and b.total_field <> ''
		AND NOT EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS c
			where c.table_name=a.numer_tab
			and c.column_name=b.total_field
		)
		FOR XML PATH('')
	);
	IF @total_field_missing IS NOT NULL
	BEGIN TRY
		rollback;
		DECLARE @err_msg12 VARCHAR(MAX) = formatmessage(51082, @total_field_missing);
		THROW 51082, @err_msg12, 1;
	END TRY
	BEGIN CATCH
		EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
		THROW 51082, @err_msg12, 1;
	END CATCH;	
	

	DECLARE @sex_field_missing VARCHAR(MAX)=
	(
		SELECT a.numer_tab, b.sex_field_name
		FROM inserted a, [rif40].[rif40_tables] b
		WHERE b.table_name=a.numer_tab
		AND b.sex_field_name is not null and b.sex_field_name <> ''
		AND NOT EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS c
			where c.table_name=a.numer_tab
			and c.column_name=b.sex_field_name
		)
		FOR XML PATH('')
	);
	IF @sex_field_missing IS NOT NULL
	BEGIN TRY
		rollback;
		DECLARE @err_msg13 VARCHAR(MAX) = formatmessage(50057, @sex_field_missing);
		THROW 50057, @err_msg13, 1;
	END TRY
	BEGIN CATCH
		EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
		THROW 50057, @err_msg13, 1;
	END CATCH;	
	
	DECLARE @age_group_missing VARCHAR(MAX)=
	(
		SELECT a.numer_tab, b.AGE_GROUP_FIELD_NAME
		FROM inserted a, [rif40].[rif40_tables] b
		WHERE b.table_name=a.numer_tab
		AND b.AGE_GROUP_FIELD_NAME is not null and b.AGE_GROUP_FIELD_NAME <> ''
		AND NOT EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS c
			where c.table_name=a.numer_tab
			and c.column_name=b.AGE_GROUP_FIELD_NAME
		)
		FOR XML PATH('')
	);
	IF @age_group_missing IS NOT NULL
	BEGIN TRY
		rollback;
		DECLARE @err_msg14 VARCHAR(MAX) = formatmessage(50058, @age_group_missing);
		THROW 50058, @err_msg14, 1;
	END TRY
	BEGIN CATCH
		EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
		THROW 50058, @err_msg14, 1;
	END CATCH;	

	DECLARE @age_sex_group_missing VARCHAR(MAX)=
	(
		SELECT a.numer_tab, b.AGE_SEX_GROUP_FIELD_NAME
		FROM inserted a, [rif40].[rif40_tables] b
		WHERE b.table_name=a.numer_tab
		AND b.AGE_SEX_GROUP_FIELD_NAME is not null and b.AGE_SEX_GROUP_FIELD_NAME <> ''
		AND NOT EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS c
			where c.table_name=a.numer_tab
			and c.column_name=b.AGE_SEX_GROUP_FIELD_NAME
		)
		FOR XML PATH('')
	);
	IF @age_sex_group_missing IS NOT NULL
	BEGIN TRY
		rollback;
		DECLARE @err_msg15 VARCHAR(MAX) = formatmessage(50059, @age_sex_group_missing);
		THROW 50059, @err_msg15, 1;
	END TRY
	BEGIN CATCH
		EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
		THROW 50059, @err_msg15, 1;
	END CATCH;	
END;


-------------------------------------------------------------
-- Verify AGE_GROUP_ID, AGE_SEX_GROUP/AGE_GROUP/SEX_FIELD_NAMES are the same between numerator, denominator and direct standardisation tables
-------------------------------------------------------------

DECLARE @age_group_id_mismatch nvarchar(MAX) =
(
	select a.study_id, a.numer_tab, a.AGE_GROUP_ID as numer_age_group_id, b.denom_tab, b.age_group_id as denom_age_group_id, c.direct_stand_tab, c.age_group_id as dir_stand_age_group_id
	from (
		SELECT a.numer_tab, b.AGE_GROUP_ID, a.study_id
		FROM inserted a, [rif40].[rif40_tables] b
		WHERE b.table_name=a.numer_tab) a, 
		(
		select b.denom_tab, c.AGE_GROUP_ID, a.study_id
		from inserted a, [rif40].[t_rif40_studies] b
		left outer join [rif40].[rif40_tables] c on c.table_name=b.denom_tab and b.denom_tab is not null and b.denom_tab<>''
		where a.study_id=b.study_id
		) b, 
		(
		select b.direct_stand_tab, c.AGE_GROUP_ID, a.study_id
		from inserted a, [rif40].[t_rif40_studies] b
		left outer join [rif40].[rif40_tables] c on c.table_name=b.direct_stand_tab and b.direct_stand_tab is not null and b.direct_stand_tab <> ''
		where a.study_id=b.study_id
		) c
	where a.study_id=b.study_id and a.study_id=c.study_id
	and ((b.denom_tab is not null and a.age_group_id!=b.age_group_id)
	or (c.direct_stand_tab is not null and a.age_group_id != c.age_group_id))
	FOR XML PATH('')
);
IF @age_group_id_mismatch IS NOT NULL
BEGIN TRY
	rollback;
	DECLARE @err_msg16 VARCHAR(MAX) = formatmessage(50060, @age_group_id_mismatch);
	THROW 50060, @err_msg16, 1;
END TRY
BEGIN CATCH
	EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[t_rif40_investigations]';
	THROW 50060, @err_msg16, 1;
END CATCH;	

END;
END; 
GO

--
-- Eof
