
-- this was not named before so will have a funny name like: DF__t_rif40_i__inv_i__5C979F60
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[rif40].[t_rif40_study_study_id_seq]') AND type in (N'D'))
BEGIN
--
-- Remove DEFAULT NEXT VALUE constraint
--
	ALTER TABLE [rif40].[t_rif40_studies] DROP CONSTRAINT [t_rif40_study_study_id_seq];
--	
-- Recreate sequence
--
	IF EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[rif40].[rif40_study_id_seq]') AND type in (N'SO'))
	BEGIN
		DROP SEQUENCE [rif40].[rif40_study_id_seq]
	END
	CREATE SEQUENCE [rif40].[rif40_study_id_seq]
		AS BIGINT
		START WITH 1
		INCREMENT by 1
		MINVALUE 1
		MAXVALUE 9223372036854775807
		NO CYCLE
		CACHE 1;
--
-- Put constraint back
-- 
	ALTER TABLE [rif40].[t_rif40_studies] ADD CONSTRAINT [t_rif40_study_study_id_seq] 
		DEFAULT (NEXT VALUE FOR [rif40].[rif40_study_id_seq]) FOR [study_id];	
END;
ELSE
BEGIN
	IF EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[rif40].[rif40_study_id_seq]') AND type in (N'SO'))
	BEGIN
		DROP SEQUENCE [rif40].[rif40_study_id_seq]
	END
--
	CREATE SEQUENCE [rif40].[rif40_study_id_seq]
		AS BIGINT
		START WITH 1
		INCREMENT by 1
		MINVALUE 1
		MAXVALUE 9223372036854775807
		NO CYCLE
		CACHE 1 
END;
GO
	
GRANT UPDATE ON [rif40].[rif40_study_id_seq] TO [rif_manager]
GO
GRANT UPDATE ON  [rif40].[rif40_study_id_seq] TO [rif_user]
GO

/*
COMMENT ON SEQUENCE rif40_study_id_seq
  IS 'Used as sequence for unique study index: study_id; auto populated.';
*/
