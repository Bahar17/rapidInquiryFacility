USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_INVESTIGATIONS]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
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
	[ROWID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [T_RIF40_INVESTIGATIONS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT (user_name()) FOR [USERNAME]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ('QUANTILE') FOR [CLASSIFIER]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ((5)) FOR [CLASSIFIER_BANDS]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ('C') FOR [INVESTIGATION_STATE]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT ('No Test') FOR [MH_TEST_TYPE]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] ADD  DEFAULT (newid()) FOR [ROWID]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_NUMER_TAB_FK] FOREIGN KEY([NUMER_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_NUMER_TAB_FK]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_STUDY_ID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_STUDY_ID_FK]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_CLASS_BANDS_CK] CHECK  (([CLASSIFIER_BANDS]>=(2) AND [CLASSIFIER_BANDS]<=(20)))
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_CLASS_BANDS_CK]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_CLASSIFIER_CK] CHECK  (([CLASSIFIER]='UNIQUE_INTERVAL' OR [CLASSIFIER]='STANDARD_DEVIATION' OR [CLASSIFIER]='QUANTILE' OR [CLASSIFIER]='JENKS' OR [CLASSIFIER]='EQUAL_INTERVAL'))
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_CLASSIFIER_CK]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_GENDERS_CK] CHECK  (([GENDERS]>=(1) AND [GENDERS]<=(3)))
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_GENDERS_CK]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_MH_TEST_TYPE_CK] CHECK  (([MH_TEST_TYPE]='Unexposed Area' OR [MH_TEST_TYPE]='Comparison Areas' OR [MH_TEST_TYPE]='No Test'))
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_MH_TEST_TYPE_CK]
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_INV_STATE_CK] CHECK  (([INVESTIGATION_STATE]='U' OR [INVESTIGATION_STATE]='R' OR [INVESTIGATION_STATE]='E' OR [INVESTIGATION_STATE]='V' OR [INVESTIGATION_STATE]='C'))
GO
ALTER TABLE [dbo].[T_RIF40_INVESTIGATIONS] CHECK CONSTRAINT [T_RIF40_INV_STATE_CK]
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
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.T_RIF40_INVESTIGATIONS_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_INVESTIGATIONS_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.T_RIF40_INV_CLASS_BANDS_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_INV_CLASS_BANDS_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.T_RIF40_INV_CLASSIFIER_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_INV_CLASSIFIER_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.T_RIF40_INV_GENDERS_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_INV_GENDERS_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.T_RIF40_INV_MH_TEST_TYPE_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_INV_MH_TEST_TYPE_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_INVESTIGATIONS.T_RIF40_INV_STATE_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_INVESTIGATIONS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_INV_STATE_CK'
GO
