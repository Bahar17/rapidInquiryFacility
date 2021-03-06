/*
Adapted from http://stackoverflow.com/questions/17173260/check-if-extended-property-description-already-exists-before-adding

The change needs to be committed explicitly after procedure is run.

Requires:
grant execute to (user/role)
grant alter on schema::rif_data to (user/role)
grant alter on schema::rif40 to (user/role)
*/
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[rif40].[rif40_addorupdate_comment]')
                  AND type IN ( N'P', N'FN', N'IF', N'TF', N'FS', N'FT' ))
    DROP PROCEDURE [rif40].[rif40_addorupdate_comment]
GO

CREATE PROCEDURE [rif40].[rif40_addorupdate_comment]
	@schema	nvarchar(128) = null, -- schema name
    @table nvarchar(128) = null,  -- table name
    @column nvarchar(128) = null, -- column name, NULL if description for table
    @descr sql_variant  = null    -- description text
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @c nvarchar(128) = NULL;
	DECLARE @full_tb_name nvarchar(128) = NULL;

    IF @column IS NOT NULL
        SET @c = N'COLUMN';

	
	IF @schema IS NULL or @table IS NULL
	BEGIN TRY
		DECLARE @err1 VARCHAR(max);
		SET @err1 = formatmessage(51151, @table);
		THROW 51151, @err1, 1;
		END TRY
		BEGIN CATCH
			EXEC [rif40].[ErrorLog_proc] @Error_Location='[rif40].[rif40_addorupdate_comment]';
			THROW 51151, @err1, 1; --rethrow
		END CATCH;		
		
	SET @full_tb_name = @schema+'.'+@table;
	IF @column IS NOT NULL
	BEGIN
            IF NOT EXISTS (SELECT 1 FROM SYS.EXTENDED_PROPERTIES
            WHERE [major_id] = OBJECT_ID(@full_tb_name) AND [name] = N'MS_Description'
                  AND [minor_id] = (SELECT [column_id]
                                    FROM SYS.COLUMNS WHERE [name] = @column AND [object_id] = OBJECT_ID(@full_tb_name)))
                EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = @descr,
                                               @level0type = N'SCHEMA', @level0name = @schema, @level1type = N'TABLE',
                                               @level1name = @table, @level2type = N'COLUMN', @level2name = @column;
            ELSE
                EXECUTE sp_updateextendedproperty @name = N'MS_Description',
                                                  @value = @descr, @level0type = N'SCHEMA', @level0name = @schema,
                                                  @level1type = N'TABLE', @level1name = @table,
                                                  @level2type = N'COLUMN', @level2name = @column;
	END  ELSE
	BEGIN
            IF NOT EXISTS (SELECT 1 FROM SYS.EXTENDED_PROPERTIES
            WHERE [major_id] = OBJECT_ID(@full_tb_name) AND [name] = N'MS_Description'
                  AND [minor_id] = 0)
                EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = @descr,
                                               @level0type = N'SCHEMA', @level0name = @schema,
                                               @level1type = N'TABLE', @level1name = @table;
            ELSE
                EXECUTE sp_updateextendedproperty @name = N'MS_Description', @value = @descr,
                                                  @level0type = N'SCHEMA', @level0name = @schema,
                                                  @level1type = N'TABLE', @level1name = @table;
    END    
END
