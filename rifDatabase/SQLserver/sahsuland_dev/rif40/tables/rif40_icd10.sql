
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[rif40].[rif40_icd10]') AND type in (N'U'))
BEGIN
	DROP TABLE [rif40].[rif40_icd10]
END
GO

CREATE TABLE [rif40].[rif40_icd10](
	[icd10_1char] [varchar](20) NULL,
	[icd10_3char] [varchar](3) NULL,
	[icd10_4char] [varchar](4) NOT NULL,
	[text_1char] [varchar](250) NULL,
	[text_3char] [varchar](250) NULL,
	[text_4char] [varchar](250) NULL,
 CONSTRAINT [rif40_icd10_pk] PRIMARY KEY CLUSTERED 
(
	[icd10_4char] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

GRANT SELECT ON [rif40].[rif40_icd10] TO public
GO

CREATE INDEX rif40_icd10_1char_bm
  ON [rif40].[rif40_icd10] (icd10_1char)
GO

CREATE INDEX rif40_icd10_3char_bm
  ON [rif40].[rif40_icd10] (icd10_3char)
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ICD10 code (SAHSU historic version, needs to be updated)' , @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ICD10 chapter', @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10', @level2type=N'COLUMN',@level2name=N'icd10_1char'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'3 Character ICD10 code', @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10', @level2type=N'COLUMN',@level2name=N'icd10_3char'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'4 Character ICD10 code', @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10', @level2type=N'COLUMN',@level2name=N'icd10_4char'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ICD10 chapter textual description', @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10', @level2type=N'COLUMN',@level2name=N'text_1char'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'3 Character ICD10 textual description', @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10', @level2type=N'COLUMN',@level2name=N'text_3char'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'4 Character ICD10 textual description', @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'TABLE',@level1name=N'rif40_icd10', @level2type=N'COLUMN',@level2name=N'text_4char'
GO
