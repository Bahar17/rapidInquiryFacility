USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_STUDIES]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
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

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT (user_name()) FOR [USERNAME]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT (sysdatetime()) FOR [STUDY_DATE]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT ('C') FOR [STUDY_STATE]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT ((0)) FOR [EXTRACT_PERMITTED]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT ((0)) FOR [TRANSFER_PERMITTED]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] ADD  DEFAULT (@@spid) FOR [AUDSID]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_STUDIES_PROJECT_FK] FOREIGN KEY([PROJECT])
REFERENCES [dbo].[T_RIF40_PROJECTS] ([PROJECT])
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [RIF40_STUDIES_PROJECT_FK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_DENOM_TAB_FK] FOREIGN KEY([DENOM_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_DENOM_TAB_FK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_DIRECT_STAND_FK] FOREIGN KEY([DIRECT_STAND_TAB])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_DIRECT_STAND_FK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_EXTRACT_PERM_CK] CHECK  (([EXTRACT_PERMITTED]=(1) OR [EXTRACT_PERMITTED]=(0)))
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_EXTRACT_PERM_CK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUD_TRANSFER_PERM_CK] CHECK  (([TRANSFER_PERMITTED]=(1) OR [TRANSFER_PERMITTED]=(0)))
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUD_TRANSFER_PERM_CK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDIES_STUDY_STATE_CK] CHECK  (([STUDY_STATE]='U' OR [STUDY_STATE]='R' OR [STUDY_STATE]='E' OR [STUDY_STATE]='V' OR [STUDY_STATE]='C'))
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUDIES_STUDY_STATE_CK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDIES_STUDY_TYPE_CK] CHECK  (([STUDY_TYPE]=(15) OR [STUDY_TYPE]=(14) OR [STUDY_TYPE]=(13) OR [STUDY_TYPE]=(12) OR [STUDY_TYPE]=(11) OR [STUDY_TYPE]=(1)))
GO
ALTER TABLE [dbo].[T_RIF40_STUDIES] CHECK CONSTRAINT [T_RIF40_STUDIES_STUDY_TYPE_CK]
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
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.T_RIF40_STUDIES_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUDIES_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.T_RIF40_STUD_EXTRACT_PERM_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUD_EXTRACT_PERM_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.T_RIF40_STUD_TRANSFER_PERM_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUD_TRANSFER_PERM_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.T_RIF40_STUDIES_STUDY_STATE_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUDIES_STUDY_STATE_CK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDIES.T_RIF40_STUDIES_STUDY_TYPE_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDIES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUDIES_STUDY_TYPE_CK'
GO
